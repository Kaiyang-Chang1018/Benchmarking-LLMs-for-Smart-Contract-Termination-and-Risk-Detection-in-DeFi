// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EthSplitter {
    address public owner;

    constructor() {
        owner = msg.sender;
    }
    
    // Function to split and send ETH to the contract
    function Split() external payable {
        require(msg.value == 0.05 ether, "Must send exactly 0.05 ETH");
    }

    // Function for the owner to withdraw the entire balance
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to accept ETH if sent directly
    receive() external payable {}
}