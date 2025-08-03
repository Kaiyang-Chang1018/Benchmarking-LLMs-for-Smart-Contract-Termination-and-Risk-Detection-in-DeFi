// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock {
    address payable public owner;
    uint256 public unlockDate;

    constructor() {
        owner = payable(msg.sender);
        unlockDate = block.timestamp + 1800; // Unix timestamp for 25 Dec 2024
    }

    function deposit() public payable {
        require(msg.value > 0, "Must send some Ether");
    }

    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(block.timestamp >= unlockDate, "Cannot withdraw before correct date");

        owner.transfer(address(this).balance);
    }

    function extendUnlockDate(uint256 newUnlockDate) public {
        require(msg.sender == owner, "Only the owner can extend unlock date");
        require(newUnlockDate > unlockDate, "New unlock date must be after current unlock date");

        unlockDate = newUnlockDate;
    }
}