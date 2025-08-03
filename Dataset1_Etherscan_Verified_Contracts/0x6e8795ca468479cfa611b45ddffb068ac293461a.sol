/**
At the heart of "O" lies an aggressive scarcity protocol - a halving event occurs with every new block on the blockchain. Starting with an initial reward of 1 "O", each subsequent block sees the minting reward halved:

Block 1: Mint 1 "O"
Block 2: Mint 0.5 "O"
Block 3: Mint 0.25 "O"
...and so on
This relentless halving continues, dramatically accelerating the path to scarcity. Each block mined is a step closer to an era where "O" tokens become a symbol of ultimate digital rarity.
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract O {
    string public name = "O";
    string public symbol = "O";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public lastMintingBlock;
    uint256 public initialMintAmount = 1000000000000000000; // Starting with 1 token
    uint256 public mintStartTime = 1706406582; // UNIX timestamp for when minting can start

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        totalSupply = 1000000000000000000; // Initial supply is 1 token
        balanceOf[msg.sender] = totalSupply; // Assigning initial supply to deployer
        emit Transfer(address(0), msg.sender, totalSupply);
        lastMintingBlock = block.number;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
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
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint() public {
        require(block.timestamp >= mintStartTime, "Minting has not started yet");
        uint256 numberToMint = mintable();
        require(numberToMint > 0, "Mintable amount is too low");
        totalSupply += numberToMint;
        balanceOf[msg.sender] += numberToMint;
        lastMintingBlock = block.number;
    }

    function mintable() public view returns (uint256 numberToMint) {
        if(block.timestamp < mintStartTime) {
            return 0;
        }
        uint256 blocksSinceLastMint = block.number - lastMintingBlock;
        if(blocksSinceLastMint > 0) {
            numberToMint = initialMintAmount >> blocksSinceLastMint; // Shift right to halve the amount each block
            return numberToMint;
        } else {
            return 0;
        }
    }
}