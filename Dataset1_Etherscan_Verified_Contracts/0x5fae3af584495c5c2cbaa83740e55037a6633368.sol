// SPDX-License-Identifier: MIT
//Telegram: https://t.me/gaslesstoken
pragma solidity ^0.8.25;

contract AssemblyGassless {
    uint256 public constant totalSupply = 10000000000000000000000;
    mapping(address => uint256) private b;
    mapping(address => mapping(address => uint256)) private a;

    string public constant name = "Gasless";
    string public constant symbol = "Gasless";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        b[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return b[account];
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
        return a[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, a[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        b[sender] -= amount;
        b[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        a[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}