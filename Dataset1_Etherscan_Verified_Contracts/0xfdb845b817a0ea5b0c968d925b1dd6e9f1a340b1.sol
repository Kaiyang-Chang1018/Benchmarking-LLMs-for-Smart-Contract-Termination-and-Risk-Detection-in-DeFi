// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract EthereumHelper {
    event TransactionBroadcast(address indexed sender, bytes rawTransaction);
    event BlockDetails(uint blockNumber, bytes32 blockHash, uint timestamp);
    event BalanceDetails(address indexed account, uint balance);
    event PendingTransactions(uint pendingCount);
    event MyValueUpdated(address indexed sender, uint newValue);

    uint public myValue;

    function broadcastTransaction(bytes memory rawTransaction) public {
        emit TransactionBroadcast(msg.sender, rawTransaction);
    }

    function getBlockDetails(uint blockNumber) public {
        bytes32 blockHash = blockhash(blockNumber);
        uint timestamp = block.timestamp;
        emit BlockDetails(blockNumber, blockHash, timestamp);
    }

    function getBalance(address account) public {
        uint balance = account.balance;
        emit BalanceDetails(account, balance);
    }

    function getPendingTransactions() public {
        uint pendingCount = tx.gasprice;
        emit PendingTransactions(pendingCount);
    }

    function setMyValue(uint newValue) public {
        myValue = newValue;
        emit MyValueUpdated(msg.sender, newValue);
    }

    function getMyValue() public view returns (uint) {
        return myValue;
    }
}