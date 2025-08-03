/**
 *Submitted for verification at Etherscan.io on 2024-04-05
*/

/**
 *Submitted for verification at Etherscan.io on 2024-03-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XEDOAIPrivateSale {
    address payable public owner;
    

    // This mapping keeps track of users who have sent ETH to buy tokens.
    mapping(address => uint256) public buyers;

    // Event to emit when a purchase is made
    event Purchase(address indexed buyer, uint256 ethAmount);

    constructor() {
        owner = payable(msg.sender);
    }

    // Function to buy tokens
    function buyTokens() public payable {
        

        // Record the buyer's purchase.
        buyers[msg.sender] += msg.value;
        
        // Emit an event for the purchase
        emit Purchase(msg.sender, msg.value);
        
        
    }

    // Withdraw function for contract's owner to withdraw funds
    function withdraw() public {
        require(msg.sender == owner, "You are not the owner.");
        require(address(this).balance > 0, "The balance is zero.");
        
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }

    // Function to check the amount of ETH sent to the contract by a user
    function checkContribution(address user) public view returns (uint256) {
        return buyers[user];
    }
}