// SPDX-License-Identifier: MIT

// Website: https://kabosuwifpepe.xyz/
// X: https://x.com/KabosuWifPepe
// Telegram: https://t.me/KabosuWifPepe

pragma solidity ^0.8.0;

contract KabosuWifPepe {
    // ERC20 standard variables
    string public name = "Kabosu Wif Pepe";
    string public symbol = "KAPE";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Mapping from address to account balances
    mapping(address => uint256) private balances;
    // Mapping from owner to spender allowances
    mapping(address => mapping(address => uint256)) private allowances;

    // Mapping for transaction tax exclusion
    mapping(address => bool) private isExcludedFromTax;

    // Transaction tax rate initially set to 0%
    uint256 public transactionTaxRate = 0;

    // Address of the contract owner
    address public owner;

    // Events for logging
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TaxRateModified(uint256 newRate);

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Constructor to initialize the contract
    constructor() {
        owner = msg.sender;
        totalSupply = 1000000000 * (10 ** uint256(decimals));
        balances[owner] = totalSupply;
        isExcludedFromTax[owner] = true; // Exclude owner from transaction tax
        emit Transfer(address(0), owner, totalSupply);
    }

    // Function to get the balance of an account
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Function to transfer tokens
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(balances[sender] >= amount, "Transfer amount exceeds balance");

        if (isExcludedFromTax[sender] || transactionTaxRate == 0) {
            // Direct transfer if sender is excluded from tax or tax rate is 0%
            balances[sender] -= amount;
            balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        } else {
            // Calculate tax and adjusted amount post-tax
            uint256 tax = (amount * transactionTaxRate) / 100;
            uint256 amountAfterTax = amount - tax;

            balances[sender] -= amount;
            balances[recipient] += amountAfterTax;
            balances[owner] += tax; // Tax goes to the owner
            emit Transfer(sender, recipient, amountAfterTax);
            emit Transfer(sender, owner, tax);
        }
    }

    // Function to approve tokens for third-party spending
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Internal approve function
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    // Function to get the allowance for a spender
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    // Function to transfer tokens using the allowance mechanism
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
        return true;
    }

    // Function to modify the transaction tax rate
    function modifyTransactionTax(uint256 newTaxRate) public onlyOwner {
        transactionTaxRate = newTaxRate;
        emit TaxRateModified(newTaxRate);
    }

    // Function to exclude an account from the transaction tax
    function excludeFromTax(address account) public onlyOwner {
        isExcludedFromTax[account] = true;
    }

    // Function to include an account in the transaction tax
    function includeInTax(address account) public onlyOwner {
        isExcludedFromTax[account] = false;
    }

    // Function to check if an account is excluded from the transaction tax
    function isExcluded(address account) public view returns (bool) {
        return isExcludedFromTax[account];
    }

    // Function for the owner to renounce ownership
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    // Internal function to transfer ownership
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}