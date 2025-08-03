// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title MultiSigWallet
 * @notice A multi-signature wallet with token support and threshold-based approval system
 * @dev Supports both native token (ETH) and ERC20 tokens
 */

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract MultiSigWallet {

    // Transaction status constants
    uint8 private constant STATUS_PENDING = 1;
    uint8 private constant STATUS_APPROVED = 2;
    uint8 private constant STATUS_REJECTED = 3;
    uint8 private constant STATUS_CANCELED = 4;

    // System constants
    uint8 private constant MAX_BATCH_SIZE = 10;
    uint8 private constant MAX_RETURN_SIZE = 10;
    string public constant VERSION = "3.0.0";

    // Special addresses
    address private constant NATIVE_TOKEN_ADDRESS = address(0);     // Represents ETH transfers
    address private constant QUERY_ALL_TOKENS = address(1);         // sed in queries to represent all tokens

    address public owner;
    bool public paused;
    uint64 private transactionCounter;

    address[] public signerList;
    mapping(address => bool) public isValidSigner;
    mapping(address => uint256) public tokenThresholds;
    mapping(address => uint256) public tokenAllowances;

    struct Transaction {
        // slot 0
        uint256 amount;          // Transaction amount

        // slot 1
        address token;           // Token address (address(0) for ETH)
        uint64 submittedAt;      // Timestamp when transaction was submitted
        uint8 status;            // Current status of the transaction

        // slot 2
        address to;              // Recipient address
        uint64 confirmedAt;      // Timestamp when transaction was confirmed

        // slot 3
        address submittedBy;     // Address that submitted the transaction

        // slot 4
        address confirmedBy;     // Address that confirmed the transaction
    }

    mapping(uint64 => Transaction) private transactions;

    event SignerUpdated(address indexed signer, bool active);

    event ThresholdUpdated(address indexed token, uint256 previousThreshold, uint256 newThreshold);
    event AllowanceUpdated(address indexed token, uint256 previousAllowance, uint256 newAllowance);

    event TransactionSubmitted(uint64 indexed transactionId, address indexed token, address indexed to, uint256 amount);
    event TransactionConfirmed(uint64 indexed transactionId, address indexed confirmedBy, uint8 statusCode);
    event TokenTransferred(address indexed token, address indexed to, uint256 indexed amount);

    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, address indexed token, uint256 amount);

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);

    event Paused(address indexed account);
    event Unpaused(address indexed account);

    // Security measures
    uint256 private locked = 1;  // Reentrancy guard

    constructor() {
        owner = msg.sender;
    }

    modifier noReentrant() {
        require(locked == 1, "reentrant call");
        locked = 2;
        _;
        locked = 1;
    }

    modifier whenNotPaused() {
        require(!paused, "contract is paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlySigner() {
        require(isValidSigner[msg.sender], "not signer");
        _;
    }

    receive() external payable whenNotPaused {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function deposit() external payable whenNotPaused {
        emit Deposit(msg.sender, msg.value);
    }

    function pause() external onlyOwner {
        require(!paused, "already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        require(paused, "not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    function setTokenSettings(address token, uint256 threshold, uint256 allowance) external onlyOwner {
        setThreshold(token, threshold);
        setAllowance(token, allowance);
    }

    function setThreshold(address token, uint256 threshold) public onlyOwner {
        uint256 previousThreshold = tokenThresholds[token];
        tokenThresholds[token] = threshold;
        emit ThresholdUpdated(token, previousThreshold, threshold);
    }

    function setAllowance(address token, uint256 allowance) public onlyOwner {
        uint256 previousAllowance = tokenAllowances[token];
        tokenAllowances[token] = allowance;
        emit AllowanceUpdated(token, previousAllowance, allowance);
    }

    function getTokenSettings(address token) public view returns (uint256 threshold, uint256 allowance) {
        return (tokenThresholds[token], tokenAllowances[token]);
    }

    function updateSigner(address signer, bool active) internal {
        require(signer != address(0), "invalid signer address");

        bool currentStatus = isValidSigner[signer];
        if (currentStatus != active) {
            isValidSigner[signer] = active;

            if (active) {
                signerList.push(signer);
            } else {
                for (uint i = 0; i < signerList.length; i++) {
                    if (signerList[i] == signer) {
                        signerList[i] = signerList[signerList.length - 1];
                        signerList.pop();
                        break;
                    }
                }
            }
            emit SignerUpdated(signer, active);
        }
    }

    function setSigner(address signer, bool active) external onlyOwner {
        updateSigner(signer, active);
    }

    function setSigners(address[] calldata signerAddresses, bool[] calldata signerActives) external onlyOwner {
        require(signerAddresses.length == signerActives.length, "length mismatch");
        uint256 length = signerAddresses.length;
        unchecked {
            for (uint256 i; i < length; ++i) {
                updateSigner(signerAddresses[i], signerActives[i]);
            }
        }
    }

    function getSigners() external view returns (address[] memory) {
        return signerList;
    }

    function getSignerCount() external view returns (uint256) {
        return signerList.length;
    }

    function isSigner(address signer) external view returns (bool) {
        return isValidSigner[signer];
    }

    function approveTransaction(uint64 transactionId) external whenNotPaused {
        processTransaction(transactionId, STATUS_APPROVED);
    }

    function cancelTransaction(uint64 transactionId) external whenNotPaused {
        processTransaction(transactionId, STATUS_CANCELED);
    }

    function rejectTransaction(uint64 transactionId) external whenNotPaused {
        processTransaction(transactionId, STATUS_REJECTED);
    }

    function rejectTransactionWithStatus(uint64 transactionId, uint8 status) external whenNotPaused {
        processTransaction(transactionId, status);
    }

    function batchApproveTransactions(uint64[] calldata transactionIds) external whenNotPaused {
        uint256 length = transactionIds.length;
        require(length > 0 && length <= MAX_BATCH_SIZE, "invalid batch size");
        for (uint256 i = 0; i < length; i++) {
            processTransaction(transactionIds[i], STATUS_APPROVED);
        }
    }

    function batchCancelTransactions(uint64[] calldata transactionIds) external whenNotPaused {
        uint256 length = transactionIds.length;
        require(length > 0 && length <= MAX_BATCH_SIZE, "invalid batch size");
        for (uint256 i = 0; i < length; i++) {
            processTransaction(transactionIds[i], STATUS_CANCELED);
        }
    }

    function batchRejectTransactions(uint64[] calldata transactionIds) external whenNotPaused {
        uint256 length = transactionIds.length;
        require(length > 0 && length <= MAX_BATCH_SIZE, "invalid batch size");
        for (uint256 i = 0; i < length; i++) {
            processTransaction(transactionIds[i], STATUS_REJECTED);
        }
    }

    /**
     * @notice Process a transaction with given status
     * @dev Internal function used by approve/reject/cancel operations
     * @param transactionId The ID of transaction to process
     * @param newStatus The new status to set
     */
    function processTransaction(uint64 transactionId, uint8 newStatus) internal {
        Transaction storage transaction = transactions[transactionId];
        uint8 currentStatus = transaction.status;

        // Basic validations
        require(transaction.amount > 0, "transaction not found");
        require(currentStatus == STATUS_PENDING, "transaction not pending");
        require(transaction.confirmedBy == address(0), "already confirmed");

        // Permission checks
        if (newStatus == STATUS_CANCELED) {
            // Cancel operation: only allows the transaction submitter to cancel
            require(transaction.submittedBy == msg.sender, "only submitter can cancel");
        } else {
            // Other operations: must be a signer and not the submitter
            require(isValidSigner[msg.sender], "not signer");
            require(transaction.submittedBy != msg.sender, "submittedBy cannot confirm");
        }

        // Status transition validation
        require(newStatus == STATUS_APPROVED || newStatus == STATUS_REJECTED || newStatus == STATUS_CANCELED, "invalid status code");

        // Update transaction status
        transaction.status = newStatus;
        transaction.confirmedBy = msg.sender;
        transaction.confirmedAt = uint64(block.timestamp);

        // Execute transfer if approved
        if (newStatus == STATUS_APPROVED) {
            executeTransaction(transaction.token, transaction.to, transaction.amount);
        }

        emit TransactionConfirmed(transactionId, msg.sender, newStatus);
    }

    /**
     * @notice Execute a transaction
     * @dev Handles both ETH and token transfers with allowance check
     */
    function executeTransaction(address token, address to, uint256 amount) internal noReentrant {
        require(amount > 0, "invalid amount");
        require(to != address(this), "cannot transfer to contract itself");

        // Check and update allowance if set
        uint256 allowance = tokenAllowances[token];
        if (allowance != 0) {  // If allowance is set (0 means unlimited/not set)
            require(amount <= allowance, "exceeds allowance");
            unchecked {
                tokenAllowances[token] = allowance - amount;  // Safe due to check above
            }
        }

        if (token == NATIVE_TOKEN_ADDRESS) {
            require(address(this).balance >= amount, "insufficient ETH balance");
            (bool success,) = to.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            IToken it = IToken(token);
            require(it.balanceOf(address(this)) >= amount, "insufficient token balance");
            require(it.transfer(to, amount), "direct transaction failed");
        }

        emit TokenTransferred(token, to, amount);
    }

    function balanceOf(address token) external view returns (uint256) {
        if (token == NATIVE_TOKEN_ADDRESS) {
            return address(this).balance;
        } else {
            return IToken(token).balanceOf(address(this));
        }
    }

    function getTransactionCount() external view returns (uint64) {
        return transactionCounter;
    }

    function isTransactionExists(uint64 transactionId) public view returns (bool) {
        return transactions[transactionId].amount > 0;
    }

    function isTransactionConfirmed(uint64 transactionId, address signer) external view returns (bool) {
        Transaction storage transaction = transactions[transactionId];
        return transaction.confirmedBy == signer || transaction.submittedBy == signer;
    }

    function getTransaction(uint64 transactionId) public view returns (Transaction memory) {
        return transactions[transactionId];
    }

    /**
     * @notice Get transactions with pagination and filtering
     * @param cursor Last transaction ID from previous query (0 for first page)
     * @param limit Maximum number of transactions to return
     * @param status Filter by status (0 for all statuses)
     * @param token Filter by token address (QUERY_ALL_TOKENS for all tokens)
     * @return transactionIds Array of transaction IDs
     * @return transactionList Array of transactions
     * @return nextCursor Cursor for next page (0 if no more data)
     */
    function getTransactions(uint64 cursor, uint64 limit, uint8 status, address token) external view returns (
        uint64[] memory transactionIds, Transaction[] memory transactionList, uint64 nextCursor
    ) {
        require(limit > 0 && limit <= MAX_RETURN_SIZE, "invalid limit: max 10");

        // Initialize result array with maximum possible size
        uint64 start = cursor == 0 ? transactionCounter : cursor;

        // Iterate through transactions starting from cursor
        uint64[] memory tempIds = new uint64[](limit);
        Transaction[] memory tempTxs = new Transaction[](limit);

        uint64 count = 0;
        for (uint64 i = start; i > 0 && count < limit; i--) {
            uint64 txIndex = i - 1;
            Transaction storage transaction = transactions[txIndex];
            if (status == 0 || transaction.status == status) {
                if (token == QUERY_ALL_TOKENS ||
                    transaction.token == token) {
                    tempIds[count] = txIndex;
                    tempTxs[count] = transaction;
                    count++;
                    nextCursor = txIndex;
                }
            }
        }

        transactionIds = new uint64[](count);
        transactionList = new Transaction[](count);

        for (uint64 i = 0; i < count; i++) {
            transactionIds[i] = tempIds[i];
            transactionList[i] = tempTxs[i];
        }

        return (transactionIds, transactionList, nextCursor);
    }

    function withdraw(address token, uint256 amount) external onlyOwner noReentrant {
        if (token == NATIVE_TOKEN_ADDRESS) {
            require(address(this).balance >= amount, "insufficient ETH balance");
            payable(owner).transfer(amount);
        } else {
            IToken it = IToken(token);
            require(it.balanceOf(address(this)) >= amount, "insufficient token balance");
            require(it.transfer(owner, amount), "transfer failed");
        }

        emit TokenTransferred(token, owner, amount);
        emit Withdraw(msg.sender, token, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "invalid owner address");
        require(newOwner != owner, "same owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() external onlyOwner {
        require(owner != address(0), "owner already renounced");
        require(!paused, "cannot renounce while paused");

        emit OwnershipRenounced(owner);
        emit OwnershipTransferred(owner, address(0));

        owner = address(0);
    }

    /**
     * @notice Submit a new transaction
     * @param token Token address (use address(0) for ETH)
     * @param to Recipient address
     * @param amount Transaction amount
     * @dev Auto-approval rules:
     *      - When threshold > 0 and amount < threshold: auto-approved
     *      - When threshold = 0 or not set: requires multi-sig approval
     *      - When amount >= threshold: requires multi-sig approval
     */
    function submitTransaction(address token, address to, uint256 amount) external onlySigner whenNotPaused {
        require(to != address(0), "invalid recipient address");
        require(token != QUERY_ALL_TOKENS, "invalid token address");
        require(amount > 0, "invalid amount: zero");

        uint64 transactionId = transactionCounter++;
        uint256 threshold = tokenThresholds[token];

        bool canAutoApprove = threshold > 0 && amount < threshold;

        Transaction memory newTx = Transaction({
            amount: amount,
            token: token,
            submittedAt: uint64(block.timestamp),
            status: canAutoApprove ? STATUS_APPROVED : STATUS_PENDING,
            to: to,
            confirmedAt: canAutoApprove ? uint64(block.timestamp) : 0,
            submittedBy: msg.sender,
            confirmedBy: canAutoApprove ? msg.sender : address(0)
        });

        transactions[transactionId] = newTx;

        if (canAutoApprove) {
            executeTransaction(token, to, amount);
            emit TransactionConfirmed(transactionId, msg.sender, STATUS_APPROVED);
        } else {
            emit TransactionSubmitted(transactionId, token, to, amount);
        }
    }
}