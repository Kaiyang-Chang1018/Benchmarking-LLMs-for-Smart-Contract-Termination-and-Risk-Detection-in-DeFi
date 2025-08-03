// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract HugeOne {
    string public name = "Huge One";
    string public symbol = "HUGE";
    uint256 public totalSupply = 1000000000000000000; // total supply of 1 Coin
    uint8 public decimals = 18;
    address public owner;
    uint256 public taxRate; // Tax rate in basis points (e.g., 100 = 1%)
    mapping(address => bool) public isTaxExempt;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event TaxRateUpdated(uint256 newTaxRate);
    event TaxExemptionUpdated(address indexed account, bool isExempt);

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function setTaxRate(uint256 _taxRate) external onlyOwner {
        require(_taxRate <= 1000, "Tax rate cannot exceed 10%");
        taxRate = _taxRate;
        emit TaxRateUpdated(_taxRate);
    }

    function setTaxExempt(address _account, bool _isExempt) external onlyOwner {
        isTaxExempt[_account] = _isExempt;
        emit TaxExemptionUpdated(_account, _isExempt);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        uint256 taxAmount = 0;
        if (!isTaxExempt[msg.sender] && !isTaxExempt[_to]) {
            taxAmount = (_value * taxRate) / 10000;
        }

        balances[msg.sender] -= _value;
        balances[_to] += (_value - taxAmount);
        if (taxAmount > 0) {
            balances[owner] += taxAmount; // send tax to the owner
        }

        emit Transfer(msg.sender, _to, _value - taxAmount);
        if (taxAmount > 0) {
            emit Transfer(msg.sender, owner, taxAmount);
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        uint256 taxAmount = 0;
        if (!isTaxExempt[_from] && !isTaxExempt[_to]) {
            taxAmount = (_value * taxRate) / 10000;
        }

        balances[_from] -= _value;
        balances[_to] += (_value - taxAmount);
        allowed[_from][msg.sender] -= _value;
        if (taxAmount > 0) {
            balances[owner] += taxAmount; // send tax to the owner
        }

        emit Transfer(_from, _to, _value - taxAmount);
        if (taxAmount > 0) {
            emit Transfer(_from, owner, taxAmount);
        }

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool success) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] -= _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}