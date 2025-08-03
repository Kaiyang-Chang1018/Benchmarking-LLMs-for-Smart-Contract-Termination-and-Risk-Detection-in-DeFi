// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract EthereumSender {
    // Owner of the contract
    address public owner;

    // Mapping to manage spender role addresses
    mapping(address => bool) public spenders;

    // Status to prevent reentrancy attacks
    uint8 private status = 1;

    // Event emitted when tokens are sent
    event Sent(address indexed to, uint256 amount, uint256 timestamp);

    // Event emitted when a spender is added or removed
    event SpenderUpdated(address indexed spender, bool status, uint256 timestamp);

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Modifier to restrict function access to the owner or spenders
    modifier onlyOwnerOrSpender() {
        require(msg.sender == owner || spenders[msg.sender], "Not authorized");
        _;
    }

    // Modifier to prevent reentrancy attacks
    modifier nonReentrant() {
        require(status != 2, "ReentrancyGuard: reentrant call");
        status = 2;
        _;
        status = 1;
    }

    // Constructor to set the initial owner as the deployer
    constructor() {
        owner = msg.sender;
    }

    // Function to send tokens, callable by owner or spender, with anti-reentrancy guard
    function sendTokens(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwnerOrSpender nonReentrant {
        require(token != address(0), "Token address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(
            amount <= IERC20(token).balanceOf(address(this)),
            "Insufficient balance"
        );

        bool success = IERC20(token).transfer(recipient, amount);
        require(success, "Token transfer failed");

        emit Sent(recipient, amount, block.timestamp);
    }

    // Function to transfer ownership, only callable by the current owner
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }

    // Function to add or remove a spender
    function setSpender(address spender, bool isSpender) external onlyOwner {
        require(spender != address(0), "Spender address cannot be zero");
        spenders[spender] = isSpender;

        emit SpenderUpdated(spender, isSpender, block.timestamp);
    }

    // Function to check if an address is a spender
    function isSpender(address addr) external view returns (bool) {
        return spenders[addr];
    }
}