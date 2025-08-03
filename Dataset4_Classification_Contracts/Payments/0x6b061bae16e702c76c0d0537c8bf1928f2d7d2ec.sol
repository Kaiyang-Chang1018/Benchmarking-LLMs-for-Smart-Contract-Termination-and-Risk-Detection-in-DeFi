// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: contracts/MerchantProtocolADM.sol


// Copyright 2024 HIPS Payment Group Ltd (hips.com)

pragma solidity ^0.8.20;



contract MerchantProtocolADM is Ownable {
    IERC20 public immutable mtoToken;
    address public immutable mtoControllerAccount;
    uint256 public constant ESCROW_PERIOD = 5 days;
    uint256 public constant PROTECTION_FEE = 5 * 10**18; // 5 MTO tokens
    uint256 public constant REPUTATION_THRESHOLD = 50; // Reputation threshold for automatic dispute resolution
    uint256 public constant SIX_MONTHS = 180 days;
    uint256 public constant MIN_TRANSACTIONS_FOR_VALID_REPUTATION = 10;

    enum TxStatus { NotFound, NotProtected, Protected, Disputed, Withdrawn, Chargebacked }

    struct Transaction {
        address buyer;
        address merchant;
        uint256 amount;
        uint256 timestamp;
        TxStatus status;
        address tokenContract;
    }

    struct MerchantReputation {
        uint256 totalTransactions;
        uint256 totalAmount;
        uint256 successfulTransactions;
        uint256 successfulAmount;
        uint256 disputedTransactions;
        uint256 disputedAmount;
        uint256 chargebackedTransactions;
        uint256 chargebackedAmount;
        uint256 creationTimestamp;
        uint256 lastUpdateTimestamp;
    }

    mapping(bytes32 => Transaction) public transactions;
    mapping(address => MerchantReputation) public merchantReputations;

    event FundsSent(bytes32 indexed txId, address indexed buyer, address indexed merchant, uint256 amount, address tokenContract);
    event ProtectionAdded(bytes32 indexed txId);
    event Disputed(bytes32 indexed txId);
    event Withdrawn(bytes32 indexed txId);
    event Chargebacked(bytes32 indexed txId);
    event ReputationUpdated(address indexed merchant, uint256 newReputation, bool isValid);

    constructor(address _mtoToken, address _mtoControllerAccount) Ownable(msg.sender) {
        mtoToken = IERC20(_mtoToken);
        mtoControllerAccount = _mtoControllerAccount;
    }

    function getEscrowPeriod() public pure returns (uint256) {
        return ESCROW_PERIOD;
    }

    function sendFunds(address merchant, address tokenContract, uint256 amount) external returns (bytes32) {
        require(IERC20(tokenContract).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        bytes32 txId = keccak256(abi.encodePacked(msg.sender, merchant, amount, block.timestamp));
        transactions[txId] = Transaction(msg.sender, merchant, amount, block.timestamp, TxStatus.NotProtected, tokenContract);
        
        MerchantReputation storage rep = merchantReputations[merchant];
        if (rep.creationTimestamp == 0) {
            rep.creationTimestamp = block.timestamp;
        }
        rep.totalTransactions++;
        rep.totalAmount += amount;
        rep.lastUpdateTimestamp = block.timestamp;
        
        emit FundsSent(txId, msg.sender, merchant, amount, tokenContract);
        return txId;
    }

    function addProtection(bytes32 txId) external {
        require(transactions[txId].buyer == msg.sender, "Not the buyer");
        require(transactions[txId].status == TxStatus.NotProtected, "Invalid status");
        require(mtoToken.transferFrom(msg.sender, address(this), PROTECTION_FEE), "Protection fee transfer failed");

        transactions[txId].status = TxStatus.Protected;
        emit ProtectionAdded(txId);
    }

    function checkTxStatus(bytes32 txId) external view returns (TxStatus) {
        return transactions[txId].status;
    }

    function withdraw(bytes32 txId) external {
        Transaction storage txn = transactions[txId];
        require(txn.merchant == msg.sender, "Not the merchant");
        require(txn.status == TxStatus.Protected, "Invalid status");
        require(block.timestamp >= txn.timestamp + ESCROW_PERIOD, "Escrow period not ended");

        txn.status = TxStatus.Withdrawn;
        IERC20(txn.tokenContract).transfer(txn.merchant, txn.amount);
        
        MerchantReputation storage rep = merchantReputations[txn.merchant];
        rep.successfulTransactions++;
        rep.successfulAmount += txn.amount;
        rep.lastUpdateTimestamp = block.timestamp;
        
        updateReputation(txn.merchant);
        
        emit Withdrawn(txId);
    }

    function dispute(bytes32 txId) external {
        Transaction storage txn = transactions[txId];
        require(txn.buyer == msg.sender, "Not the buyer");
        require(txn.status == TxStatus.Protected, "Invalid status");
        require(block.timestamp < txn.timestamp + ESCROW_PERIOD, "Escrow period ended");

        txn.status = TxStatus.Disputed;
        
        MerchantReputation storage rep = merchantReputations[txn.merchant];
        rep.disputedTransactions++;
        rep.disputedAmount += txn.amount;
        rep.lastUpdateTimestamp = block.timestamp;
        
        emit Disputed(txId);
        
        // Implement ADM logic
        (uint256 merchantReputation, bool isValid) = calculateReputation(txn.merchant);
        if (!isValid || merchantReputation < REPUTATION_THRESHOLD) {
            _chargeback(txId);
        } else {
            // In a real-world scenario, you might want to implement a more complex dispute resolution process here
            // For now, we'll just transfer the funds to the merchant
            txn.status = TxStatus.Withdrawn;
            IERC20(txn.tokenContract).transfer(txn.merchant, txn.amount);
            rep.successfulTransactions++;
            rep.successfulAmount += txn.amount;
        }
        
        updateReputation(txn.merchant);
    }
    function _chargeback(bytes32 txId) internal {
        Transaction storage txn = transactions[txId];
        require(txn.status == TxStatus.Disputed, "Invalid status"); // Adding a check
        txn.status = TxStatus.Chargebacked;
        bool transferSuccess = IERC20(txn.tokenContract).transfer(txn.buyer, txn.amount);
        require(transferSuccess, "Transfer failed"); // Check if transfer was successful
        
        MerchantReputation storage rep = merchantReputations[txn.merchant];
        rep.chargebackedTransactions++;
        rep.chargebackedAmount += txn.amount;
        rep.lastUpdateTimestamp = block.timestamp;
        
        emit Chargebacked(txId);
    }

    function calculateReputation(address merchant) public view returns (uint256 reputation, bool isValid) {
        MerchantReputation storage rep = merchantReputations[merchant];
        if (rep.totalTransactions < MIN_TRANSACTIONS_FOR_VALID_REPUTATION) {
            return (0, false);
        }
        
        uint256 accountAge = block.timestamp - rep.creationTimestamp;
        uint256 timeSinceLastUpdate = block.timestamp - rep.lastUpdateTimestamp;
        
        uint256 successRate = (rep.successfulAmount * 100) / rep.totalAmount;
        uint256 disputeRate = (rep.disputedAmount * 100) / rep.totalAmount;
        uint256 chargebackRate = (rep.chargebackedAmount * 100) / rep.totalAmount;
        
        // Apply time decay factor
        uint256 decayFactor = timeSinceLastUpdate >= SIX_MONTHS ? 50 : 100 - ((timeSinceLastUpdate * 50) / SIX_MONTHS);
        
        // Calculate base reputation
        uint256 baseReputation = successRate - disputeRate - (chargebackRate * 2);
        
        // Apply decay factor
        uint256 decayedReputation = (baseReputation * decayFactor) / 100;
        
        // Apply account age bonus (max 20% bonus for accounts older than 1 year)
        uint256 ageBonus = accountAge >= 365 days ? 20 : (accountAge * 20) / 365 days;
        
        reputation = decayedReputation + ageBonus;
        isValid = true;
        
        return (reputation, isValid);
    }

    function updateReputation(address merchant) internal {
        (uint256 newReputation, bool isValid) = calculateReputation(merchant);
        emit ReputationUpdated(merchant, newReputation, isValid);
    }

    function withdrawMTO() external {
        require(msg.sender == mtoControllerAccount, "Not authorized");
        uint256 balance = mtoToken.balanceOf(address(this));
        require(mtoToken.transfer(mtoControllerAccount, balance), "Transfer failed");
    }
}