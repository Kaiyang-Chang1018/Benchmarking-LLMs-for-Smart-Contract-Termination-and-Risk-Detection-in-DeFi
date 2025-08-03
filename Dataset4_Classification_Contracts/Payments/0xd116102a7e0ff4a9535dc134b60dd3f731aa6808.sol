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


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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

// File: contracts/NodeSale.sol



pragma solidity ^0.8.20;



contract NodeSale is Ownable {
    uint256 public nodePrice; // Node price in tokens
    uint256 public maxNodes;  // Maximum number of nodes
    uint256 public totalNodesSold;

    address public paymentToken; // Address of the token used for payments (e.g., USDC)

    mapping(address => bool) public hasPurchasedNode;
    mapping(address => uint256) public ownerToNode;

    // Referral-related mappings
    mapping(address => uint256) public referralCounts; // Referrer => Count of referrals
    mapping(address => address) public referredBy;    // Buyer => Referrer

    event NodePurchased(address indexed user, uint256 amount);
    event ReferralRecorded(address indexed referrer, address indexed buyer);
    event MaxNodesUpdated(uint256 newMaxNodes);
    event NodePriceUpdated(uint256 newNodePrice);
    event PaymentTokenUpdated(address indexed oldToken, address indexed newToken);

    constructor(address initialOwner, address _paymentToken) Ownable(initialOwner) {
        require(_paymentToken != address(0), "Payment token cannot be the zero address");
        nodePrice = 1000 * 10**6; // Node price in USDC (assuming 6 decimals for USDC)
        maxNodes = 400; // Initial maximum number of nodes
        paymentToken = _paymentToken;
    }

    // Function to handle purchasing a node
    function purchaseNode(address referrer) external {
        require(totalNodesSold < maxNodes, "Sale has ended, all nodes sold");


        IERC20 token = IERC20(paymentToken);
        require(token.balanceOf(msg.sender) >= nodePrice, "Insufficient token balance");
        require(token.allowance(msg.sender, address(this)) >= nodePrice, "Token allowance too low");

        // Transfer tokens from buyer to contract owner
        token.transferFrom(msg.sender, owner(), nodePrice);

        // Record referral if referrer is valid and not the buyer
        if (referrer != address(0) && referrer != msg.sender) {
            referredBy[msg.sender] = referrer;
            referralCounts[referrer] += 1;
            emit ReferralRecorded(referrer, msg.sender);
        }

        // Update state variables
        hasPurchasedNode[msg.sender] = true;
        ownerToNode[msg.sender] += 1;
        totalNodesSold += 1;

        emit NodePurchased(msg.sender, 1);
    }

    // Function to update the maximum number of nodes
    function setMaxNodes(uint256 _maxNodes) external onlyOwner {
        require(_maxNodes > totalNodesSold, "New max nodes must be greater than nodes already sold");
        maxNodes = _maxNodes;
        emit MaxNodesUpdated(_maxNodes);
    }

    // Function to update the price of a node
    function setNodePrice(uint256 _nodePrice) external onlyOwner {
        require(_nodePrice > 0, "Node price must be greater than 0");
        nodePrice = _nodePrice;
        emit NodePriceUpdated(_nodePrice);
    }

    // Function to update the payment token
    function setPaymentToken(address _paymentToken) external onlyOwner {
        require(_paymentToken != address(0), "Payment token cannot be the zero address");
        address oldToken = paymentToken;
        paymentToken = _paymentToken;
        emit PaymentTokenUpdated(oldToken, _paymentToken);
    }

    // Function to get the referral count for an address
    function getReferralCount(address referrer) external view returns (uint256) {
        return referralCounts[referrer];
    }

    // Function to get the number of nodes owned by an address
    function getNodeBalance(address owner) external view returns (uint256) {
        return ownerToNode[owner];
    }

    // Function to change ownership
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        transferOwnership(newOwner);
    }
}