// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/GambleXTokenSale.sol


pragma solidity ^0.8.20;






/**
 * @title GambleXTokenSale
 * @notice A token sale contract with optional Chainlink price feed integration,
 *         global vesting start time, and configurable fee/duration parameters.
 */
contract GambleXTokenSale is Ownable, Pausable, ReentrancyGuard {
    // ============ Errors ============
    error SalePaused();
    error SaleInactive();
    error InvalidAddress();
    error InvalidETHPrice();
    error NoETHSent();
    error TransferFailed();
    error TransferFromFailed();
    error NotEnoughTokensAvailable();
    error VestingNotLaunched();
    error AlreadyLaunched();
    error NoVestingSchedule();
    error NoTokensToClaim();
    error ZeroAmount();
    error VestingAlreadyStarted();
    error VestingParametersLocked();

    // ============ State Variables ============

    IERC20 public token;
    AggregatorV3Interface public ethUsdPriceFeed;
    address public treasuryWallet;

    uint256 public tokensAvailable;
    uint256 public constant TOTAL_TOKENS_FOR_SALE = 5_000_000 * 10**18;

    // Token price: 0.08 USD (scaled by 1e18 for precision).
    uint256 public constant TOKEN_PRICE_IN_USD = 8e16;

    // The vesting schedule splits the locked portion into 6 intervals.
    uint256 public constant TOTAL_PORTIONS = 6;

    // portionDuration replaces the "30 days" reliance.
    // By default, it's 30 days. The owner can modify it, but ONLY before vesting starts.
    uint256 public portionDuration = 30 days; 

    // Configurable fee (default ~0.5%).
    // For instance, 1000 / 995 = ~1.005, i.e., ~0.5% difference.
    uint256 public feeNumerator = 1000;
    uint256 public feeDenominator = 995;

    // If set to true, the contract will use the fallback ETH price (ethPriceInUSD).
    bool public useFallbackPrice = false;

    // The fallback ETH price in USD (scaled by 1e18 for precision).
    uint256 public ethPriceInUSD;

    // Whether the owner has started the vesting period globally.
    bool public vestingLaunched;
    uint256 public vestingLaunchTime;

    struct VestingSchedule {
        uint256 totalAllocated; // total locked (after the immediate release)
        uint256 claimed;        // total claimed from the vesting portion
    }

    mapping(address => VestingSchedule) public vestingSchedules;

    // ============ Events ============

    event TokensPurchased(address indexed buyer, uint256 ethSpent, uint256 tokensAllocated);
    event TokensClaimed(address indexed claimer, uint256 tokensClaimed);
    event SaleStarted();
    event SaleStopped();
    event ETHPriceUpdated(uint256 newPrice);
    event UseFallbackPriceUpdated(bool useFallback);
    event PriceFeedUpdated(address newPriceFeed);
    event VestingStarted(uint256 startTime);
    event PortionDurationUpdated(uint256 newDuration);
    event FeeUpdated(uint256 newNumerator, uint256 newDenominator);

    // ============ Constructor ============

    constructor(
        address _token,
        address _ethUsdPriceFeed,
        address _treasuryWallet,
        uint256 _ethPriceInUSD
    ) Ownable(msg.sender) {
        if (_token == address(0)) revert InvalidAddress();
        if (_ethUsdPriceFeed == address(0)) revert InvalidAddress();
        if (_treasuryWallet == address(0)) revert InvalidAddress();
        if (_ethPriceInUSD == 0) revert InvalidETHPrice();

        token = IERC20(_token);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        treasuryWallet = _treasuryWallet;
        tokensAvailable = TOTAL_TOKENS_FOR_SALE;
        ethPriceInUSD = _ethPriceInUSD;
    }

    // ============ Modifiers ============

    modifier saleActive() {
        if (paused()) revert SalePaused();
        if (tokensAvailable == 0) revert SaleInactive();
        _;
    }

    // ============ Owner Functions ============

    /**
     * @notice Unpause the sale, allowing token purchases.
     */
    function startSale() external onlyOwner whenPaused {
        _unpause();
        emit SaleStarted();
    }

    /**
     * @notice Pause the sale, disallowing token purchases.
     */
    function stopSale() external onlyOwner whenNotPaused {
        _pause();
        emit SaleStopped();
    }

    /**
     * @notice Disables the buy function once vesting is launched.
     *         This is to ensure no one can buy after vesting period begins.
     */
    function startVestingPeriod() external onlyOwner {
        if (vestingLaunched) revert AlreadyLaunched();
        vestingLaunched = true;
        vestingLaunchTime = block.timestamp;
        emit VestingStarted(vestingLaunchTime);
    }

    /**
     * @notice Updates the fallback ETH price in USD (1e18 scaled).
     */
    function updateETHPrice(uint256 newEthPriceInUSD) external onlyOwner {
        if (newEthPriceInUSD == 0) revert InvalidETHPrice();
        ethPriceInUSD = newEthPriceInUSD;
        emit ETHPriceUpdated(newEthPriceInUSD);
    }

    /**
     * @notice Toggles whether the contract uses the fallback price or the Chainlink oracle.
     */
    function updateUseFallbackPrice(bool _useFallback) external onlyOwner {
        useFallbackPrice = _useFallback;
        emit UseFallbackPriceUpdated(_useFallback);
    }

    /**
     * @notice Updates the Chainlink price feed contract address.
     */
    function setPriceFeed(address newPriceFeed) external onlyOwner {
        if (newPriceFeed == address(0)) revert InvalidAddress();
        ethUsdPriceFeed = AggregatorV3Interface(newPriceFeed);
        emit PriceFeedUpdated(newPriceFeed);
    }

    /**
     * @notice Allows the owner to update the single-interval duration.
     *         By default it's 30 days, but you can set a different value to reduce reliance on "30 days".
     *         This cannot be updated once vesting has started.
     */
    function setPortionDuration(uint256 newDuration) external onlyOwner {
        if (newDuration == 0) revert ZeroAmount();
        if (vestingLaunched) revert VestingParametersLocked();
        portionDuration = newDuration;
        emit PortionDurationUpdated(newDuration);
    }

    /**
     * @notice Allows the owner to update the fee parameters.
     *         For example, to set a 1% fee, you might do (1010, 1000).
     */
    function setFee(uint256 newNumerator, uint256 newDenominator) external onlyOwner {
        if (newDenominator == 0) revert ZeroAmount();
        feeNumerator = newNumerator;
        feeDenominator = newDenominator;
        emit FeeUpdated(newNumerator, newDenominator);
    }

    // ============ View Functions ============

    function isPaused() external view returns (bool) {
        return paused();
    }

    function isSaleActive() external view returns (bool) {
        return !paused() && tokensAvailable > 0 && !vestingLaunched;
    }

    /**
     * @notice Total vesting duration in seconds = portionDuration * 6.
     */
    function getTotalVestingDuration() public view returns (uint256) {
        return portionDuration * TOTAL_PORTIONS;
    }

    /**
     * @notice Get the current ETH price (1e18 scaled).
     *         Either from Chainlink or fallback, depending on useFallbackPrice.
     */
    function getCurrentETHPrice() external view returns (uint256) {
        return _getCurrentETHPriceInternal();
    }

    /**
     * @notice Returns how many seconds remain until the next vesting portion for user.
     */
    function getTimeUntilNextVesting(address user) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        if (!vestingLaunched) {
            // If vesting hasn't started, treat as infinitely far away.
            // The user can't claim until vestingLaunched is true.
            return type(uint256).max;
        }

        uint256 portionClaimed = (schedule.claimed * TOTAL_PORTIONS) / schedule.totalAllocated;
        if (portionClaimed >= TOTAL_PORTIONS) {
            return 0; // Fully vested
        }

        uint256 nextVestingTime = vestingLaunchTime + (portionClaimed + 1) * portionDuration;
        if (block.timestamp >= nextVestingTime) {
            return 0;
        } else {
            return nextVestingTime - block.timestamp;
        }
    }

    /**
     * @notice Returns the total time left (in seconds) until all tokens are fully vested for user.
     */
    function getTotalTimeUntilVestingComplete(address user) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        if (!vestingLaunched) {
            // If vesting not launched, they still have the full interval ahead (6 portions).
            return getTotalVestingDuration();
        }

        uint256 vestingEndTime = vestingLaunchTime + getTotalVestingDuration();
        if (block.timestamp >= vestingEndTime) {
            return 0;
        } else {
            return vestingEndTime - block.timestamp;
        }
    }

    /**
     * @notice Returns how many seconds until the next vesting portion after the user claims.
     */
    function getNextVestingTime(address user) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        if (!vestingLaunched) return type(uint256).max;

        uint256 portionClaimed = (schedule.claimed * TOTAL_PORTIONS) / schedule.totalAllocated;
        if (portionClaimed >= TOTAL_PORTIONS) {
            return 0; // No more vesting remains
        }

        uint256 nextVestingTime = vestingLaunchTime + (portionClaimed + 1) * portionDuration;
        if (block.timestamp >= nextVestingTime) {
            return 0;
        } else {
            return nextVestingTime - block.timestamp;
        }
    }

    /**
     * @notice Returns how many tokens the user still has in vesting (i.e., not yet claimed).
     */
    function getRemainingTokensInVesting(address user) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        return schedule.totalAllocated - schedule.claimed;
    }

    /**
     * @notice Returns how many tokens the user has claimed so far.
     */
    function getClaimedTokens(address user) external view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[user];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        return schedule.claimed;
    }

    // ============ Emergency Functions ============

    /**
     * @notice Withdraw all ETH held in the contract to the owner.
     *         Used only in emergencies.
     */
    function emergencyWithdrawETH() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        if (balance == 0) revert ZeroAmount();
        (bool success, ) = payable(owner()).call{value: balance}("");
        if (!success) revert TransferFailed();
    }

    /**
     * @notice Withdraw tokens (held by the contract) to the owner.
     *         Used only in emergencies.
     */
    function emergencyWithdrawTokens(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert ZeroAmount();
        _safeTransfer(token, owner(), amount);
    }

    // ============ Purchase & Vesting Logic ============

    /**
     * @notice Buy tokens with ETH. Includes an immediate release and
     *         sets up the user's vesting schedule for the remainder.
     *         Disabled once vesting has started.
     */
    function buyTokens() external payable whenNotPaused saleActive nonReentrant {
        // New requirement: can't buy if vesting already launched.
        if (vestingLaunched) revert VestingAlreadyStarted();

        if (msg.value == 0) revert NoETHSent();

        uint256 tokenPriceInETH = _getTokenPriceInETH();
        if (tokenPriceInETH == 0) revert InvalidETHPrice();

        // Calculate the number of tokens to allocate (before adjusting for fee).
        uint256 tokensToAllocate = (msg.value * 1e18) / tokenPriceInETH;

        // Adjust for the fee.
        // Example: (tokens * 1000) / 995 => ~0.5% difference
        uint256 adjustedTokensToAllocate = (tokensToAllocate * feeNumerator) / feeDenominator;
        if (adjustedTokensToAllocate == 0) revert ZeroAmount();
        if (adjustedTokensToAllocate > tokensAvailable) revert NotEnoughTokensAvailable();

        // Immediate release: 1/6
        uint256 initialRelease = (adjustedTokensToAllocate * 1) / 6;
        // Remaining to be vested
        uint256 vestingAmount = adjustedTokensToAllocate - initialRelease;

        // If user already has a vesting schedule, add to it instead of overwriting
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        schedule.totalAllocated += vestingAmount;

        // Deduct tokens from sale availability
        tokensAvailable -= adjustedTokensToAllocate;

        // Transfer ETH to treasury
        (bool success, ) = payable(treasuryWallet).call{value: msg.value}("");
        if (!success) revert TransferFailed();

        // Transfer the immediate-release portion to the buyer (with fee offset again)
        uint256 effectiveInitialRelease = (initialRelease * feeNumerator) / feeDenominator;
        _safeTransferFrom(token, treasuryWallet, msg.sender, effectiveInitialRelease);

        emit TokensPurchased(msg.sender, msg.value, adjustedTokensToAllocate);
    }

    /**
     * @notice Claim the vested tokens that the sender is entitled to.
     */
    function claimTokens() external nonReentrant {
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        if (schedule.totalAllocated == 0) revert NoVestingSchedule();
        if (!vestingLaunched) revert VestingNotLaunched();

        // How many intervals have elapsed?
        uint256 intervalsElapsed = (block.timestamp - vestingLaunchTime) / portionDuration;
        if (intervalsElapsed == 0) revert NoTokensToClaim();
        if (intervalsElapsed > TOTAL_PORTIONS) {
            intervalsElapsed = TOTAL_PORTIONS;
        }

        // Max claimable is intervalsElapsed/6 of total allocated
        uint256 maxClaimable = (schedule.totalAllocated * intervalsElapsed) / TOTAL_PORTIONS;

        // The user can only claim what they haven't claimed before.
        uint256 claimable = maxClaimable - schedule.claimed;
        if (claimable == 0) revert NoTokensToClaim();

        // Adjust claimable for the fee
        uint256 effectiveClaimable = (claimable * feeNumerator) / feeDenominator;

        // Update user's claimed amount
        schedule.claimed += claimable;

        // Transfer tokens to user
        _safeTransferFrom(token, treasuryWallet, msg.sender, effectiveClaimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    /**
     * @notice Helper function to see how many tokens one would receive for a given ETH amount (pre-fee).
     */
    function calculateTokensForETH(uint256 ethAmount) external view returns (uint256) {
        uint256 tokenPriceInETH = _getTokenPriceInETH();
        if (tokenPriceInETH == 0) return 0;
        return (ethAmount * 1e18) / tokenPriceInETH;
    }

    // ============ Internal Functions ============

    /**
     * @notice Return the token price in ETH scaled to 1e18.
     */
    function _getTokenPriceInETH() internal view returns (uint256) {
        uint256 ethUsd = _getCurrentETHPriceInternal();
        // Token price in ETH = (TOKEN_PRICE_IN_USD * 1e18) / ethUsd
        // Both TOKEN_PRICE_IN_USD and ethUsd are scaled by 1e18
        if (ethUsd == 0) return 0;
        return (TOKEN_PRICE_IN_USD * 1e18) / ethUsd;
    }

    /**
     * @notice Attempt to fetch the ETH/USD price from Chainlink. 
     *         Falls back to manual price if oracle fails or if useFallbackPrice is true.
     */
    function _getCurrentETHPriceInternal() internal view returns (uint256) {
        if (!useFallbackPrice) {
            // Attempt to fetch from Chainlink
            try ethUsdPriceFeed.latestRoundData() returns (
                uint80 /*roundID*/,
                int256 price,
                uint256 /*startedAt*/,
                uint256 /*timeStamp*/,
                uint80 /*answeredInRound*/
            ) {
                if (price <= 0) {
                    // If invalid, fallback
                    return ethPriceInUSD;
                }
                // Chainlink price typically is 1e8; multiply by 1e10 to scale to 1e18.
                return uint256(price) * 1e10;
            } catch {
                // On failure, fallback
                return ethPriceInUSD;
            }
        } else {
            // Manual price only
            return ethPriceInUSD;
        }
    }

    /**
     * @notice Wrapper that ensures an ERC20 transfer reverts on failure.
     */
    function _safeTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        (bool success, bytes memory data) =
            address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }

    /**
     * @notice Wrapper that ensures an ERC20 transferFrom reverts on failure.
     */
    function _safeTransferFrom(IERC20 _token, address _from, address _to, uint256 _amount) internal {
        (bool success, bytes memory data) =
            address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFromFailed();
    }
}