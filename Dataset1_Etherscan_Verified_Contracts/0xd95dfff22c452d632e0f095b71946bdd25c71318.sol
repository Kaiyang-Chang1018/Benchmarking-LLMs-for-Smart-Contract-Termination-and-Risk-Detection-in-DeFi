// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://edition.cnn.com/2024/08/04/investing/japan-nikkei-stock-rout-intl-hnk/index.html
Twitter  : https://edition.cnn.com/2024/08/04/investing/japan-nikkei-stock-rout-intl-hnk/index.html
Telegram : https://edition.cnn.com/2024/08/04/investing/japan-nikkei-stock-rout-intl-hnk/index.html
*/


contract NIKKEI {

    string public name = "Japanese Stock Market";
    string public symbol = "NIKKEI";
    uint256 public totalSupply = 999999999999999999000000000;
    uint8 public decimals = 18;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "1JapaneseStockMarket");
        require(_to != address(0), "2JapaneseStockMarket");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "3JapaneseStockMarket");
        require(allowance[_from][msg.sender] >= _value, "4JapaneseStockMarket");
        require(_to != address(0));
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "5JapaneseStockMarket");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "6JapaneseStockMarket");
        _;
    }
}