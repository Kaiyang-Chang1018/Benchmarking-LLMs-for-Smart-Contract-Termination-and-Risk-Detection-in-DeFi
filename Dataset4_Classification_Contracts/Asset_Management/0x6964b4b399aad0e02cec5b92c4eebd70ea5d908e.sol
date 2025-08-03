// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TimelockVault {
    address public owner;
    uint256 public unlockTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAfterUnlock() {
        require(block.timestamp >= unlockTime, "Funds are locked");
        _;
    }

    constructor(address _owner, uint256 _unlockTime) {
        owner = _owner;
        unlockTime = _unlockTime;
    }

    function depositEther() external payable {
        // Ether is automatically deposited to the contract
    }

    function depositToken(address tokenAddress, uint256 amount) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
    }

    function withdrawEther(uint256 amount) external onlyOwner onlyAfterUnlock {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function withdrawToken(address tokenAddress, uint256 amount) external onlyOwner onlyAfterUnlock {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(token.transfer(owner, amount), "Token transfer failed");
    }

    // Fallback function to receive Ether
    receive() external payable {}

    // Function to check if the contract is currently locked
    function isLocked() external view returns (bool) {
        return block.timestamp < unlockTime;
    }

    // Function to check the number of seconds until the contract unlocks
    function timeUntilUnlock() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        } else {
            return unlockTime - block.timestamp;
        }
    }

    // Function to update the unlock time if the contract is already unlocked
    function updateUnlockTime(uint256 newUnlockTime) external onlyOwner {
        require(block.timestamp >= unlockTime, "Cannot update unlock time until the current unlock period has passed");
        unlockTime = newUnlockTime;
    }
}