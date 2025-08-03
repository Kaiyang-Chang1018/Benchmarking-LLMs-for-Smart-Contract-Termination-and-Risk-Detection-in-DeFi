// SPDX-License-Identifier: MIT

// Telegram: https://t.me/zerogastoken
pragma solidity ^0.8.25;

contract ZGAS {
    function name() external pure returns (string memory){
        return "Zero GAS";
    }

    function symbol() external pure returns (string memory){
        return "ZGAS";
    }

    uint256 public constant decimals = 18;

    uint256 public constant totalSupply = 20000;
    
    mapping(address => uint256) private y;
    mapping(address => mapping(address => uint256)) private z;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        y[msg.sender] = totalSupply * 10 ** decimals;
        emit Transfer(address(0), msg.sender, totalSupply * 10 ** decimals);
    }

    function balanceOf(address account) public view returns (uint256) {
        return y[account];
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
        y[sender] -= amount;
        y[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        z[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}