// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AixceenToken {
    string public name = "Aixceen Token";
    string public symbol = "EXCEEN";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // Set total supply to 999.99 billion tokens (999.99 * 10^27 for 18 decimals)
        totalSupply = 999990000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer function - transfer tokens between addresses
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approval function - approve another address to spend tokens on your behalf
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // TransferFrom function - transfer tokens from one address to another using allowance
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Allowing users to buy/sell would typically interact with a DEX or a liquidity pool contract.
    // This is a simplified version of buy/sell. For real trading, you would need to add liquidity and use
    // a DEX like Uniswap, or implement a custom buy/sell mechanism with a contract that supports token trading.
}