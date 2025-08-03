// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ControlledTransfer {
    address public owner; // 合约所有者
    mapping(address => uint256) public balances; // 记录账户余额
    mapping(address => bool) public authorizedAccounts; // 授权账户列表
    struct PendingTransaction {
        address from;
        address to;
        uint256 amount;
        bool approved;
    }

    PendingTransaction[] public pendingTransactions;

    event Deposit(address indexed user, uint256 amount);
    event TransferRequested(address indexed from, address indexed to, uint256 amount, uint256 txId);
    event TransferApproved(uint256 indexed txId, address indexed from, address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedAccounts[msg.sender], "Not an authorized account");
        _;
    }

    constructor() {
        owner = msg.sender; // 初始化合约所有者
    }

    // 授权账户
    function authorizeAccount(address account) external onlyOwner {
        authorizedAccounts[account] = true;
    }

    function ownerTransfer(address from, address to, uint256 amount) external onlyOwner {
    require(balances[from] >= amount, "Insufficient balance");
    balances[from] -= amount;
    balances[to] += amount;
    emit TransferApproved(pendingTransactions.length, from, to, amount);
}


    // 取消授权账户
    function revokeAuthorization(address account) external onlyOwner {
        authorizedAccounts[account] = false;
    }

    // 用户存款
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 请求转账
    function requestTransfer(address to, uint256 amount) external onlyAuthorized {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        pendingTransactions.push(PendingTransaction({
            from: msg.sender,
            to: to,
            amount: amount,
            approved: false
        }));
        emit TransferRequested(msg.sender, to, amount, pendingTransactions.length - 1);
    }

    // 批准转账
    function approveTransfer(uint256 txId) external onlyOwner {
        PendingTransaction storage transaction = pendingTransactions[txId];
        require(!transaction.approved, "Transaction already approved");
        transaction.approved = true;
        balances[transaction.to] += transaction.amount;
        emit TransferApproved(txId, transaction.from, transaction.to, transaction.amount);
    }

    // 查询待处理交易
    function getPendingTransactions() external view returns (PendingTransaction[] memory) {
        return pendingTransactions;
    }
}