// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XEDOAIPrivateSale {
    address payable public owner;
    

   
    mapping(address => uint256) public buyers;

   
    event Purchase(address indexed buyer, uint256 ethAmount);

    constructor() {
        owner = payable(msg.sender);
    }

   
    function buyTokens() public payable {
        
        buyers[msg.sender] += msg.value;
        
        emit Purchase(msg.sender, msg.value);
        
        
    }

   
    function withdraw() public {
        require(msg.sender == owner, "You are not the owner.");
        require(address(this).balance > 0, "The balance is zero.");
        
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }

   
    function checkContribution(address user) public view returns (uint256) {
        return buyers[user];
    }
}