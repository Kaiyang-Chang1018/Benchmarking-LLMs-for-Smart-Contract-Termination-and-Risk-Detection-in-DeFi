// SPDX-License-Identifier: MIT

// Telegram: https://t.me/lowgastoken
// Deploy TX: https://etherscan.io/tx/0x72058641d19a907fa5c4591e12d91c8527fac96d28a6cf399efa475ad759ffc0
// Runs (Optimizer) : 38
// EVM Version to target: Default
pragma solidity ^0.8.25;

contract lowGas {
    string public constant name = "Low GAS"; 
    string public constant symbol = "LOW";  
    uint256 public constant decimals = 18;

    uint256 public constant totalSupply = 30000000000000000000000;
    
    mapping(address => uint256) private t;
    mapping(address => mapping(address => uint256)) private z;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        t[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return t[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return z[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, z[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        t[sender] -= amount;
        t[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        z[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}