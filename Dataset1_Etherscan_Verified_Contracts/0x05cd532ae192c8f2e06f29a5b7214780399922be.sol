// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proximo {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 200000000000000 * 10 ** 18;
    string public name = "Proximo";
    string public symbol = "PRO";
    uint public decimals = 18;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view returns(uint) {
    return balances[account];
}

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function owner() public view returns (address) {
        return _owner;
    }


    function renounceOwnership() public {
        require(msg.sender == _owner, "Only the owner can renounce ownership");
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}