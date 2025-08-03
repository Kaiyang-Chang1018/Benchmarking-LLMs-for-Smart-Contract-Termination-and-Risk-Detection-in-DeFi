// SPDX-License-Identifier: MIT
// Telegram: https://t.me/agas_portal

pragma solidity ^0.8.26;

contract AssemblyGas8888 {
    uint256 public constant totalSupply = 1000000000000000000000;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    string public constant name = "Assembly TOKEN";
    string public constant symbol = "ATOKEN";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balances[tx.origin] = totalSupply;
        emit Transfer(address(0), tx.origin, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}