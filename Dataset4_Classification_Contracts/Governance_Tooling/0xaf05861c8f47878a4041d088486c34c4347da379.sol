// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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

// File: vesting.sol

pragma solidity ^0.8.0;


interface IERC20Token {
    function mint(address to, uint256 amount) external;
}

contract  TreasuryVestingContract is Ownable {
    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    uint256 public totalAmount;
    IERC20Token public token;
    uint256 public claimedAmount;
    bool public paused;

    constructor(address _token, address _beneficiary, uint256 _totalAmount, uint256 _durationInDays) Ownable(msg.sender) {
        require(_beneficiary != address(0), "Beneficiary cannot be the zero address");
        require(_totalAmount > 0, "Total amount should be greater than 0");
        require(_durationInDays > 0, "Duration should be greater than 0 days");

        token = IERC20Token(_token);
        beneficiary = _beneficiary;
        totalAmount = _totalAmount;
        duration = _durationInDays * 1 days;
        start = block.timestamp;
        paused = false;
    }

    function TreasuryClaimVesting() public {
        require(!paused, "Vesting is paused");
        require(block.timestamp >= start, "Vesting period has not started");
        uint256 vestedAmount = totalAmount * (block.timestamp - start) / duration;
        uint256 claimable = vestedAmount - claimedAmount;
        require(claimable > 0, "No tokens to claim");

        claimedAmount += claimable;
        token.mint(beneficiary, claimable);
    }

    function updateVesting(uint256 _newTotalAmount, uint256 _newDurationInDays) public onlyOwner {
        require(_newTotalAmount >= claimedAmount, "New amount must be greater than or equal to already claimed amount");
        require(_newDurationInDays > 0, "New duration must be greater than 0 days");

        totalAmount = _newTotalAmount;
        duration = _newDurationInDays * 1 days;
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }
}