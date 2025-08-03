// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title BasicERC20 Token
/// @notice This contract implements a standard ERC20 token without any tax mechanism.
/// @dev Includes a reentrancy guard to prevent reentrant attacks.
contract ReentrancyGuard {
    uint256 private _status; // Variable to track reentrancy guard state

    /// @dev Initializes the reentrancy guard.
    constructor() {
        _status = 1; // Set initial status to "not entered"
    }

    /// @dev Modifier to prevent reentrant calls to functions.
    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call"); // Check reentrancy status
        _status = 2; // Set status to "entered"
        _; // Execute the function body
        _status = 1; // Reset status to "not entered"
    }
}

contract BasicERC20 is ReentrancyGuard {
    // Token metadata constants
    string public constant name = "BYFCoin"; // Token name
    string public constant symbol = "BYF"; // Token symbol
    uint8 public constant decimals = 18; // Number of decimal places
    uint256 public constant maxSupply = 141421268 * (10 ** uint256(decimals)); // Maximum supply: 141,421,268 BYF

    // The total supply of the token
    uint256 private _totalSupply;

    // Mapping to track balances of each address
    mapping(address => uint256) public balanceOf;

    // Mapping to track allowances for delegated transfers
    mapping(address => mapping(address => uint256)) public allowance;

    // Address of the owner (deployer of the contract)
    address public owner;

    // Events to notify external systems of key operations
    event Transfer(address indexed from, address indexed to, uint256 value); // Emitted when tokens are transferred
    event Approval(address indexed owner, address indexed spender, uint256 value); // Emitted when an approval is made
    event TransferFrom(address indexed spender, address indexed from, address indexed to, uint256 value); // Emitted on transferFrom

    /// @dev Constructor to initialize the token and assign the total supply to the deployer.
    constructor() {
        owner = msg.sender; // Assign deployer as the owner
        _totalSupply = maxSupply; // Set total supply to the max supply
        balanceOf[owner] = _totalSupply; // Assign all tokens to the owner's balance
    }

    /// @notice Returns the total supply of the token.
    /// @return The total supply of the token.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Approves a spender to transfer a specific amount of tokens on behalf of the caller.
    /// @param spender The address authorized to spend tokens.
    /// @param amount The amount of tokens the spender is authorized to spend.
    /// @return A boolean indicating success.
    function approve(address spender, uint256 amount) public returns (bool) {
        // Prevent approving oneself (a safety measure)
        require(spender != msg.sender, "ERC20: approve to caller");

        // Set the allowance amount for the spender
        allowance[msg.sender][spender] = amount;

        // Emit the Approval event to notify external systems
        emit Approval(msg.sender, spender, amount);
        
        return true;
    }

    /// @notice Transfers tokens from the caller to a recipient.
    /// @param recipient The address receiving the tokens.
    /// @param amount The amount of tokens to transfer.
    /// @return A boolean indicating success.
    function transfer(address recipient, uint256 amount) public nonReentrant returns (bool) {
        require(balanceOf[msg.sender] >= amount, "ERC20: insufficient balance"); // Check sender's balance

        // Perform the transfer
        balanceOf[msg.sender] -= amount; // Deduct amount from sender
        balanceOf[recipient] += amount; // Credit amount to recipient

        // Emit transfer event
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /// @notice Transfers tokens on behalf of a sender to a recipient.
    /// @dev The caller must have allowance to transfer the specified amount.
    /// @param sender The address sending the tokens.
    /// @param recipient The address receiving the tokens.
    /// @param amount The amount of tokens to transfer.
    /// @return A boolean indicating success.
    function transferFrom(address sender, address recipient, uint256 amount) public nonReentrant returns (bool) {
        require(balanceOf[sender] >= amount, "ERC20: insufficient balance"); // Check sender's balance
        require(allowance[sender][msg.sender] >= amount, "ERC20: allowance exceeded"); // Check allowance

        // Perform the transfer
        balanceOf[sender] -= amount; // Deduct amount from sender
        balanceOf[recipient] += amount; // Credit amount to recipient
        allowance[sender][msg.sender] -= amount; // Reduce the allowance

        // Emit transfer and transferFrom events
        emit Transfer(sender, recipient, amount);
        emit TransferFrom(msg.sender, sender, recipient, amount);
        return true;
    }
}