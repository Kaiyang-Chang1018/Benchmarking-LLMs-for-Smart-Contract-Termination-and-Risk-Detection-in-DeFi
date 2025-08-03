// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: MIT

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

// File: contract.sol


pragma solidity ^0.8.0;



contract LinearVesting is Ownable {
    IERC20 public token;
    uint256 public startTime; // Unix timestamp for 23rd July 2024
    uint256 private constant VESTING_PERIOD = 9 * 30 days; // 9 months
    uint256 private constant RELEASE_INTERVAL = 30 days; // Monthly release
    uint256 private constant INITIAL_RELEASE = 11; // 11% per month

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    mapping(address => VestingSchedule) public vestingSchedules;

    event TokensReleased(address beneficiary, uint256 amount);
    event TokensReclaimed(uint256 amount);

    constructor(
        IERC20 _token,
        uint256 _startTime,
        address _initialOwner
    ) Ownable(_initialOwner) {
        require(address(_token) != address(0), "Token address cannot be zero");
        require(
            _startTime > block.timestamp,
            "Start time should be in the future"
        );

        token = _token;
        startTime = _startTime;
        transferOwnership(_initialOwner);
    }

    function whitelistAddresses(
        address[] calldata beneficiaries,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(
            beneficiaries.length == amounts.length,
            "Mismatched array lengths"
        );

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            vestingSchedules[beneficiaries[i]] = VestingSchedule({
                totalAmount: amounts[i],
                releasedAmount: 0
            });
        }
    }

    function vestedAmount(address beneficiary) public view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary];
        if (block.timestamp < startTime) {
            return 0;
        }

        // Calculate months elapsed, accounting for the first month
        uint256 timeElapsed = block.timestamp - startTime;

        uint256 monthsElapsed = timeElapsed / RELEASE_INTERVAL;

        // Ensure at least one month is counted, even if timeElapsed is less than RELEASE_INTERVAL
        monthsElapsed = monthsElapsed == 0 ? 1 : monthsElapsed;

        monthsElapsed = monthsElapsed > 9 ? 9 : monthsElapsed; // Cap at 9 months

        if (monthsElapsed >= 9) {
            return schedule.totalAmount;
        }

        uint256 amount = (schedule.totalAmount *
            (monthsElapsed * INITIAL_RELEASE)) / 100;
        return amount;
    }

    function availableForWithdrawal(address beneficiary)
        public
        view
        returns (uint256)
    {
        return
            vestedAmount(beneficiary) -
            vestingSchedules[beneficiary].releasedAmount;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        uint256 availableAmount = availableForWithdrawal(msg.sender);
        require(
            amount <= availableAmount,
            "Requested amount exceeds available for withdrawal"
        );

        schedule.releasedAmount += amount;
        token.transfer(msg.sender, amount);

        emit TokensReleased(msg.sender, amount);
    }

    function reclaimTokens() external onlyOwner {
        require(
            block.timestamp >= startTime + VESTING_PERIOD,
            "Vesting period not yet ended"
        );

        uint256 remainingTokens = token.balanceOf(address(this));
        token.transfer(owner(), remainingTokens);

        emit TokensReclaimed(remainingTokens);
    }

    // View functions for frontend
    function totalTokens(address beneficiary) external view returns (uint256) {
        return vestingSchedules[beneficiary].totalAmount;
    }

    function unlockedTokens(address beneficiary)
        external
        view
        returns (uint256)
    {
        return vestedAmount(beneficiary);
    }

    function availableTokensForWithdrawal(address beneficiary)
        external
        view
        returns (uint256)
    {
        return availableForWithdrawal(beneficiary);
    }

    function getVestingSchedule(address account)
        external
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedules[account];
    }
}