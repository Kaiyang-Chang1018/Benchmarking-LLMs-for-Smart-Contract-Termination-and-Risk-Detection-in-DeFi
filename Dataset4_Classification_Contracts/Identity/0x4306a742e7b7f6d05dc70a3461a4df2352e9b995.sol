// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract btcLeaderboard {
    address public owner;
    mapping(address => string) private messages;
    uint256 private globalNonce;

    event MessageUpdated(address indexed user, string newMessage, uint256 newNonce);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier validMessage(string memory message) {
        require(bytes(message).length <= 30, "Message exceeds 30 characters");
        _;
    }

    constructor() {
        owner = msg.sender;
        globalNonce = 0;
    }

    function setMessage(string memory newMessage) public validMessage(newMessage) {
        messages[msg.sender] = newMessage;
        globalNonce++;
        emit MessageUpdated(msg.sender, newMessage, globalNonce);
    }

    function getMessage(address user) public view returns (string memory) {
        return messages[user];
    }

    function getGlobalNonce() public view returns (uint256) {
        return globalNonce;
    }

    function updateMessageForUser(address user, string memory newMessage) public onlyOwner validMessage(newMessage) {
        messages[user] = newMessage;
        globalNonce++;
        emit MessageUpdated(user, newMessage, globalNonce);
    }
}