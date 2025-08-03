// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GMiladyCoin {
    string public name = "GMilady Coin";
    string public symbol = "GMilady";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * 10 ** uint256(decimals); // 1 billion GMilady

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);
    event LiquidityLocked(address indexed owner, uint256 value);
    event CircuitBreakerActivated(bool isActivated);

    address public owner;
    bool public circuitBreaker;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid spender address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function lockLiquidity(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[address(this)] += _value;
        emit LiquidityLocked(msg.sender, _value);
    }

    function activateCircuitBreaker(bool _isActivated) public onlyOwner {
        circuitBreaker = _isActivated;
        emit CircuitBreakerActivated(_isActivated);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier circuitBreakerCheck() {
        require(!circuitBreaker, "Circuit breaker is activated");
        _;
    }
}