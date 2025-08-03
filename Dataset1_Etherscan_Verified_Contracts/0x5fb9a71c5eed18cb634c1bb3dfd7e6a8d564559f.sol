// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TimeLockedWallet {
    address public owner;
    uint256 public unlockTime;

    // Events for logging deposits and withdrawals
    event EtherDeposited(address indexed sender, uint256 amount);
    event TokensDeposited(address indexed sender, address token, uint256 amount);
    event EtherWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed to, address token, uint256 amount);

    constructor(uint256 _unlockTime) payable {
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // Allow the contract to receive Ether
    receive() external payable {
        emit EtherDeposited(msg.sender, msg.value);  // Emit event when Ether is received
    }

    // Function to specifically deposit Ether and log the event
    function depositEther() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        emit EtherDeposited(msg.sender, msg.value);  // Emit an event whenever Ether is deposited
    }

    // Function to deposit ERC-20 tokens into the contract
    function depositTokens(address tokenAddress, uint256 amount) public {
        require(msg.sender == owner, "Only owner can deposit tokens");
        IERC20 token = IERC20(tokenAddress);
        bool sent = token.transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");
        emit TokensDeposited(msg.sender, tokenAddress, amount);  // Emit event when tokens are deposited
    }

    // Withdraw Ether
    function withdrawEther() public {
        require(msg.sender == owner, "You are not the owner");
        require(block.timestamp >= unlockTime, "Funds are still locked");
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit EtherWithdrawn(owner, balance);
    }

    // Withdraw ERC-20 tokens
    function withdrawTokens(address tokenAddress) public {
        require(msg.sender == owner, "You are not the owner");
        require(block.timestamp >= unlockTime, "Funds are still locked");
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(owner, tokenBalance);
        emit TokensWithdrawn(owner, tokenAddress, tokenBalance);
    }

    // Check the Ether balance of the contract
    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
}