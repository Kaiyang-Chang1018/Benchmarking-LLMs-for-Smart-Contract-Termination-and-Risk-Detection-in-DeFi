// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationContract {
    address public owner;
    uint256 public maxDonation = 0.25 ether;
    uint256 public cap = 30 ether;
    uint256 public totalReceived;
    mapping(address => bool) public donors;

    constructor() {
        owner = 0xB5F97F9E147589e03CFA49850a64172c353fBB87;
    }

    // Modifier to restrict the access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Function to receive donations
    receive() external payable {
        require(totalReceived + msg.value <= cap, "Pre-sale Cap Reached");
        require(msg.value <= maxDonation, "Donation Exceeds Max Limit");
        require(!donors[msg.sender], "Already Deposit");

        totalReceived += msg.value;
        donors[msg.sender] = true;

        // Forward the funds to the owner
        payable(owner).transfer(msg.value);
    }

    // Function for the owner to withdraw funds (for safety, though funds are forwarded upon donation)
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }

    // Function to check the contract's current balance (total ETH received)
    function getBalance() public view returns (uint256) {
        return totalReceived;
    }
}