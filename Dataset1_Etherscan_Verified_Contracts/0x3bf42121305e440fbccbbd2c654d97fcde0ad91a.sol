// SPDX-License-Identifier: MIT
//$XRP 2.0 Was Born To Celebrate A Historic Moment In Blockchain—The Victory Of XRP, Which Announced The Legitimacy Of Blockchain And Its Resistance To Suppression And Control By Centralized Powers.
//https://xrp2.co
pragma solidity ^0.8.0;

contract XRP2Token {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    uint256 private taxRate;
    address private taxAddress;
    address private contractOwner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can call this function.");
        _;
    }

    constructor() {
        name = "XRP2.0";
        symbol = "XRP2.0";
        totalSupply = 1000000000 * 10 ** 18; // 1,000,000,000 tokens with 18 decimal places
        decimals = 18;
        taxRate = 100; // 0.1% tax rate
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address.");
        require(value <= balances[msg.sender], "Insufficient balance.");

        uint256 taxAmount = calculateTax(value);
        uint256 transferAmount = value - taxAmount;

        balances[msg.sender] -= value;
        balances[to] += transferAmount;
        balances[taxAddress] += taxAmount;

        emit Transfer(msg.sender, to, transferAmount);
        emit Transfer(msg.sender, taxAddress, taxAmount);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address.");
        require(value <= balances[from], "Insufficient balance.");
        require(value <= allowed[from][msg.sender], "Insufficient allowance.");

        uint256 taxAmount = calculateTax(value);
        uint256 transferAmount = value - taxAmount;

        balances[from] -= value;
        balances[to] += transferAmount;
        balances[taxAddress] += taxAmount;
        allowed[from][msg.sender] -= value;

        emit Transfer(from, to, transferAmount);
        emit Transfer(from, taxAddress, taxAmount);
        emit Approval(from, msg.sender, allowed[from][msg.sender]);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address ownerAddress, address spender) public view returns (uint256) {
        return allowed[ownerAddress][spender];
    }

    function setTaxAddress(address _taxAddress) public onlyOwner {
        require(_taxAddress != address(0), "Invalid tax address.");
        taxAddress = _taxAddress;
    }

    function setTaxRate(uint256 _taxRate) public onlyOwner {
        require(_taxRate <= 1000, "Invalid tax rate."); // Maximum tax rate is 10% (1000 basis points)
        taxRate = _taxRate;
    }

    function renounceOwnership() public onlyOwner {
        contractOwner = address(0);
    }

    function calculateTax(uint256 value) private view returns (uint256) {
        return (value * taxRate) / 10000;
    }
}