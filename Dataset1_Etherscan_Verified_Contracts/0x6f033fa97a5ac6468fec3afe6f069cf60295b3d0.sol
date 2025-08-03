// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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

interface IERC20_USDT {
    function transferFrom(address from, address to, uint value) external;
    function transfer(address, uint256) external;
}

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


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

contract WoD_Commitment is ReentrancyGuard, Ownable {
    struct Commitment {
        uint256 amount;
        bool accepted;
        bool refunded;
        uint256 timestamp;
    }

    uint256 public constant MAXIMUM_COMMITMENT = 20000e6; 
    uint256 public constant MINIMUM_COMMITMENT = 100e6;
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // ERC20 USDT Token address

    mapping(address => mapping(address => Commitment[])) public commitments;
    address[] public allowedTokens;
    address[] public participants;
    Commitment[] public allCommitments;

    event Committed(address indexed user, address indexed tokenAddress, uint256 amount, uint256 timestamp);
    event Refunded(address indexed user, uint256 amount, address indexed tokenAddress);
    event Accepted(address indexed user, address indexed tokenAddress);
    event Withdrawn(address indexed owner, uint256 amount, address indexed tokenAddress);

    constructor(address[] memory _tokenAddresses) Ownable(msg.sender) {
        require(_tokenAddresses.length > 0, "No token addresses provided");
        allowedTokens = _tokenAddresses;
    }

    function addAllowedToken(address _tokenAddress) external onlyOwner {
        allowedTokens.push(_tokenAddress);
    }

    function commit(address tokenAddress, uint256 amount) external nonReentrant {
    require(isAllowedToken(tokenAddress), "Token not allowed");
    require(amount >= MINIMUM_COMMITMENT, "Commitment amount must be greater than 100");

    uint256 totalCommitted = 0;
    for (uint256 i = 0; i < commitments[msg.sender][tokenAddress].length; i++) {
        Commitment storage existingCommitment = commitments[msg.sender][tokenAddress][i];
        require(!existingCommitment.accepted, "Commitment already accepted, cannot commit again");
        require(!existingCommitment.refunded, "Commitment already refunded, cannot commit again");
        totalCommitted += existingCommitment.amount;
    }
    require(totalCommitted + amount <= MAXIMUM_COMMITMENT, "Exceeds maximum commitment limit");

    Commitment memory newCommitment = Commitment({
        amount: amount,
        accepted: false,
        refunded: false,
        timestamp: block.timestamp
    });
    commitments[msg.sender][tokenAddress].push(newCommitment);
    allCommitments.push(newCommitment);

    if (tokenAddress == usdtAddress) {
        IERC20_USDT(tokenAddress).transferFrom(msg.sender, address(this), amount);
    } else {
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
    }

    if (commitments[msg.sender][tokenAddress].length == 1) {
        participants.push(msg.sender);
    }

    emit Committed(msg.sender, tokenAddress, amount, block.timestamp);
}

    function _refund(address user, address tokenAddress, uint256 index) private {
        Commitment storage userCommitment = commitments[user][tokenAddress][index];
        require(userCommitment.amount > 0, "No commitment to refund");
        require(!userCommitment.refunded, "Commitment already refunded");
        require(!userCommitment.accepted, "Commitment already accepted");

        uint256 amountToRefund = userCommitment.amount;

        userCommitment.refunded = true;
        userCommitment.amount = 0;

         if (tokenAddress == usdtAddress) {
        IERC20_USDT(tokenAddress).transfer(user, amountToRefund);
        } else {
        IERC20(tokenAddress).transfer(user, amountToRefund);
        }

        emit Refunded(user, amountToRefund, tokenAddress);
    }

    function _accept(address user, address tokenAddress, uint256 index) private {
        Commitment storage userCommitment = commitments[user][tokenAddress][index];
        require(userCommitment.amount > 0, "No commitment to accept");
        require(!userCommitment.refunded, "Commitment already refunded");
        require(!userCommitment.accepted, "Commitment already accepted");

        userCommitment.accepted = true;

        emit Accepted(user, tokenAddress);
    }

    function refund(address user, address tokenAddress, uint256 index) external onlyOwner nonReentrant {
        _refund(user, tokenAddress, index);
    }

    function accept(address user, address tokenAddress, uint256 index) external onlyOwner {
        _accept(user, tokenAddress, index);
    }

    function batchRefund(address[] calldata users, address tokenAddress, uint256[] calldata indexes) external onlyOwner nonReentrant {
        require(users.length == indexes.length, "Mismatched users and indexes");
        for (uint256 i = 0; i < users.length; i++) {
            _refund(users[i], tokenAddress, indexes[i]);
        }
    }

    function batchAccept(address[] calldata users, address tokenAddress, uint256[] calldata indexes) external onlyOwner {
        require(users.length == indexes.length, "Mismatched users and indexes");
        for (uint256 i = 0; i < users.length; i++) {
            _accept(users[i], tokenAddress, indexes[i]);
        }
    }

    function withdraw(address tokenAddress) external onlyOwner {
        require(isAllowedToken(tokenAddress), "Token not allowed");
        IERC20 token = IERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance > 0, "No funds to withdraw");

    if (tokenAddress == usdtAddress) {
        IERC20_USDT(tokenAddress).transfer(owner(), contractBalance);
    } else {
       token.transfer(owner(), contractBalance);
    }

        emit Withdrawn(owner(), contractBalance, tokenAddress);
    }

    function viewCommitmentsByStatus(address tokenAddress, bool acceptedStatus, bool refundedStatus) 
        external 
        view 
        returns (address[] memory, uint256[] memory) 
    {
        uint256 count = 0;
        address[] memory tempAddresses = new address[](participants.length);
        uint256[] memory tempAmounts = new uint256[](participants.length);

        for (uint256 i = 0; i < participants.length; i++) {
            address user = participants[i];
            Commitment[] storage userCommitments = commitments[user][tokenAddress];
            for (uint256 j = 0; j < userCommitments.length; j++) {
                Commitment storage commitment = userCommitments[j];
                if (commitment.amount > 0 && commitment.accepted == acceptedStatus && commitment.refunded == refundedStatus) {
                    tempAddresses[count] = user;
                    tempAmounts[count] = commitment.amount;
                    count++;
                }
            }
        }

        address[] memory users = new address[](count);
        uint256[] memory amounts = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            users[i] = tempAddresses[i];
            amounts[i] = tempAmounts[i];
        }

        return (users, amounts);
    }

    function viewLatestCommitments(uint256 limit) external view returns (Commitment[] memory) {
        uint256 count = limit > allCommitments.length ? allCommitments.length : limit;
        Commitment[] memory recentCommitments = new Commitment[](count);

        for (uint256 i = 0; i < count; i++) {
            recentCommitments[i] = allCommitments[allCommitments.length - 1 - i];
        }

        return recentCommitments;
    }

    function commitmentCountForUser(address user, address tokenAddress) external view returns (uint256) {
        return commitments[user][tokenAddress].length;
    }

    function isAllowedToken(address tokenAddress) public view returns (bool) {
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (allowedTokens[i] == tokenAddress) {
                return true;
            }
        }
        return false;
    }
}