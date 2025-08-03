// SPDX-License-Identifier: MIT

// Twitter: https://x.com/tokenrusheth
// Telegram: https://t.me/tokenrushportal
// Website: https://tokenrush.app 
pragma solidity ^0.8.26;

contract tokenRush {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    bool public initialized;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function initialize(string memory _name, string memory _symbol, uint256 initialSupply, address owner) external {
        require(tx.origin != msg.sender);
        require(!initialized, "Contract already initialized");
        initialized = true;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = initialSupply * (10 ** decimals);
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}