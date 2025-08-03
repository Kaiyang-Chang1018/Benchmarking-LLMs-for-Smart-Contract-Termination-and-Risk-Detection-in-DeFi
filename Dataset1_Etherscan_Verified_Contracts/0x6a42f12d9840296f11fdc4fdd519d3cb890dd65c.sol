// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ^0.8.20;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

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

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

// src/CustomScheduleVesting.sol

contract CustomScheduleVesting is Ownable {
    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 startTime;
        uint256 totalAmount;
        uint256[] monthlyAllocations;  // Array of monthly allocations
        uint256 released;
        bool revoked;
    }

    IERC20 public immutable token;
    mapping(bytes32 => VestingSchedule) public vestingSchedules;
    mapping(address => bytes32[]) public beneficiarySchedules;

    event ScheduleCreated(bytes32 indexed scheduleId, address indexed beneficiary);
    event TokensReleased(bytes32 indexed scheduleId, uint256 amount);
    event ScheduleRevoked(bytes32 indexed scheduleId);

    constructor(address _token) Ownable(msg.sender) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _startTime,
        uint256[] calldata _monthlyAllocations
    ) external onlyOwner returns (bytes32) {
        require(_beneficiary != address(0), "Invalid beneficiary");
        require(_startTime >= block.timestamp, "Start time must be in future");
        require(_monthlyAllocations.length > 0, "Must provide allocations");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _monthlyAllocations.length; i++) {
            totalAmount += _monthlyAllocations[i];
        }
        require(totalAmount > 0, "Total amount must be > 0");

        // Generate unique schedule ID
        bytes32 scheduleId = keccak256(
            abi.encodePacked(_beneficiary, _startTime, block.timestamp)
        );

        require(!vestingSchedules[scheduleId].initialized, "Schedule exists");

        // Create vesting schedule
        vestingSchedules[scheduleId] = VestingSchedule({
            initialized: true,
            beneficiary: _beneficiary,
            startTime: _startTime,
            totalAmount: totalAmount,
            monthlyAllocations: _monthlyAllocations,
            released: 0,
            revoked: false
        });

        beneficiarySchedules[_beneficiary].push(scheduleId);

        // Transfer tokens to contract
        require(
            token.transferFrom(msg.sender, address(this), totalAmount),
            "Transfer failed"
        );

        emit ScheduleCreated(scheduleId, _beneficiary);
        return scheduleId;
    }

    function release(bytes32 scheduleId) external {
        VestingSchedule storage schedule = vestingSchedules[scheduleId];
        require(schedule.initialized, "Schedule doesn't exist");
        require(!schedule.revoked, "Schedule was revoked");
        require(
            msg.sender == schedule.beneficiary,
            "Only beneficiary can release"
        );

        uint256 releasable = getReleasableAmount(scheduleId);
        require(releasable > 0, "No tokens to release");

        schedule.released += releasable;
        require(token.transfer(schedule.beneficiary, releasable), "Transfer failed");

        emit TokensReleased(scheduleId, releasable);
    }

    function getReleasableAmount(bytes32 scheduleId) public view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[scheduleId];
        if (!schedule.initialized || schedule.revoked) {
            return 0;
        }

        if (block.timestamp < schedule.startTime) {
            return 0;
        }
        // Calculate months passed, rounding down
        uint256 monthsPassed = (block.timestamp - schedule.startTime) / 30 days;
        // Ensure we don't exceed array bounds
        uint256 maxMonths = monthsPassed < schedule.monthlyAllocations.length ?
            monthsPassed : schedule.monthlyAllocations.length - 1;
        uint256 totalVested = 0;
        // Only sum up to maxMonths (inclusive)
        for (uint256 i = 0; i <= maxMonths; i++) {
            totalVested += schedule.monthlyAllocations[i];
        }

        return totalVested - schedule.released;
    }

    function getVestingSchedule(bytes32 scheduleId)
    external
    view
    returns (
        address beneficiary,
        uint256 startTime,
        uint256 totalAmount,
        uint256[] memory monthlyAllocations,
        uint256 released,
        bool revoked
    )
    {
        VestingSchedule storage schedule = vestingSchedules[scheduleId];
        return (
            schedule.beneficiary,
            schedule.startTime,
            schedule.totalAmount,
            schedule.monthlyAllocations,
            schedule.released,
            schedule.revoked
        );
    }

    function getBeneficiarySchedules(address beneficiary)
    external
    view
    returns (bytes32[] memory)
    {
        return beneficiarySchedules[beneficiary];
    }

    function revokeSchedule(bytes32 scheduleId) external onlyOwner {
        VestingSchedule storage schedule = vestingSchedules[scheduleId];
        require(schedule.initialized, "Schedule doesn't exist");
        require(!schedule.revoked, "Already revoked");

        uint256 remainingTokens = schedule.totalAmount - schedule.released;
        schedule.revoked = true;

        require(token.transfer(owner(), remainingTokens), "Transfer failed");
        emit ScheduleRevoked(scheduleId);
    }
}