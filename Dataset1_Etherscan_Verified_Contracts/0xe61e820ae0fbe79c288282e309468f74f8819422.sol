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

// File: @openzeppelin/contracts/utils/Pausable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/TokenSale.sol


pragma solidity ^0.8.24;




contract TokenSale is Context, Ownable, Pausable {
    bool public allowWithdrawals;

    mapping(address => uint256) public amounts;
    address[] public participants;

    uint64 public immutable startTime;
    uint64 public endTime;
    uint64 public immutable ownerWithdrawAfter;

    event AmountAdded(address indexed buyer, uint256 amount);

    modifier ifTokenSaleStarted() {
        require(
            startTime < uint64(block.timestamp),
            "TokenSale hasn't started"
        );
        _;
    }

    constructor(
        uint64 _startTime,
        uint64 _endTime,
        uint64 _ownerWithdrawAfter
    ) Ownable(msg.sender) {
        require(
            _startTime > block.timestamp,
            "Start time must be in the future"
        );
        require(_endTime > _startTime, "End time must be after Start time");

        startTime = _startTime;
        endTime = _endTime;

        ownerWithdrawAfter = endTime + (_ownerWithdrawAfter * 1 days);
        allowWithdrawals = false;
    }

    function addFunds() external payable ifTokenSaleStarted {
        require(uint64(block.timestamp) < endTime, "TokenSale has ended");

        uint256 amount = msg.value;
        require(amount > 0, "Amount must be greater than zero");

        amounts[_msgSender()] += amount;

        // Add the buyer to the list of participants if it's the first deposit
        if (amounts[_msgSender()] == amount) {
            participants.push(_msgSender());
        }

        emit AmountAdded(_msgSender(), amount);
    }

    function setEndTime(uint64 _endTime) external onlyOwner {
        require(
            _endTime > uint64(block.timestamp),
            "Cannot set endTime in the past"
        );
        require(_endTime < endTime, "Cannot extend sale endTime");

        endTime = _endTime;
    }

    function setAllowWithdrawals(bool flag) external onlyOwner {
        require(uint64(block.timestamp) > endTime, "TokenSale is still open");

        allowWithdrawals = flag;
    }

    function setWinnersAndWithdrawFunds(
        address[] calldata winners,
        uint256[] calldata amountList,
        address payable _to
    ) external onlyOwner returns (uint256) {
        require(uint64(block.timestamp) > endTime, "TokenSale is still open");

        require(
            winners.length == amountList.length,
            "Array lengths should match"
        );

        uint256 amountToWithdraw = 0;

        for (uint16 i = 0; i < winners.length; i++) {
            amountToWithdraw += amountList[i];
            // debit user's amount
            amounts[winners[i]] -= amountList[i];
        }
        payable(_to).transfer(amountToWithdraw);
        return amountToWithdraw;
    }

    function withdrawFunds() external {
        require(uint64(block.timestamp) > endTime, "TokenSale is still open");
        require(allowWithdrawals, "Withdrawals not allowed");

        uint256 withdrawalAmount = amounts[_msgSender()];
        amounts[_msgSender()] = 0;

        payable(_msgSender()).transfer(withdrawalAmount);
    }

    function ownerWithdrawFunds(address payable _to) external onlyOwner {
        require(allowWithdrawals, "Withdrawals not allowed");
        require(
            uint64(block.timestamp) > ownerWithdrawAfter,
            "Owner cannot withdraw yet"
        );
        payable(_to).transfer(address(this).balance);
    }

    function getParticipantsCount() external view returns (uint256) {
        return participants.length;
    }
}