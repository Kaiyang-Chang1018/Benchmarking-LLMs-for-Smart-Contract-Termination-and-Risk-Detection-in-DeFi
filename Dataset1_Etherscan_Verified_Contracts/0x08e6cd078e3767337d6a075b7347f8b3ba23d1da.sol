// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TRUMP {
    string public name = "TRUMP";
    string public symbol = "TRUMP";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 ether; // Total supply set to 1,000,000 CATWIF tokens
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public blacklist;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(!blacklist[msg.sender], "Sender is blacklisted");
        require(!blacklist[_to], "Recipient is blacklisted");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(!blacklist[sender], "Sender is blacklisted");
        require(!blacklist[recipient], "Recipient is blacklisted");
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function addToBlacklist(address _address) external onlyOwner {
        blacklist[_address] = true;
        emit BlacklistUpdated(_address, true);
    }

    function removeFromBlacklist(address _address) external onlyOwner {
        blacklist[_address] = false;
        emit BlacklistUpdated(_address, false);
    }
}