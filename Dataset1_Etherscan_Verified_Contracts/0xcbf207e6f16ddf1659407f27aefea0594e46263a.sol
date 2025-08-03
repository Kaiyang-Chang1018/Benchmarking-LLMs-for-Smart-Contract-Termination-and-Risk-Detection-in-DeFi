// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BatchTransfer {
    address public owner;

    // Modifier to restrict function access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor sets the deployer as the initial owner
    constructor() {
        owner = msg.sender;
    }

    // Function to transfer ownership to a new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // Function to perform batch transfers (restricted to owner)
    function batchTransfer(
        address tokenAddress,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatched arrays");

        IERC20 token = IERC20(tokenAddress);
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(msg.sender, recipients[i], amounts[i]), "Transfer failed");
        }
    }

    // Function to withdraw tokens from the contract (restricted to owner)
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));
        require(amount <= contractBalance, "Insufficient balance");

        require(token.transfer(msg.sender, amount), "Withdraw failed");
    }

    // Function to perform batch ETH transfers (airdrop ETH to multiple addresses)
    function airdropETH(address[] calldata recipients, uint256[] calldata amounts) external payable onlyOwner {
        require(recipients.length == amounts.length, "Mismatched arrays");

        uint256 totalAmount = 0;

        // Calculate the total ETH to be sent
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(msg.value >= totalAmount, "Insufficient ETH sent");

        // Send ETH to recipients
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            (bool sent, ) = recipients[i].call{value: amounts[i]}("");
            require(sent, "Failed to send ETH");
        }
    }

    // Function to withdraw remaining ETH from the contract
    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to withdraw ETH");
    }

    // Fallback function to accept ETH
    receive() external payable {}
}