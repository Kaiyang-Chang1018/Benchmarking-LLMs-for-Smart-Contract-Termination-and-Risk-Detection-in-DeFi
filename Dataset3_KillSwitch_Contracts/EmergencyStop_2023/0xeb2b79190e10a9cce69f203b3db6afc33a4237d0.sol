// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/ECM-Coin/ECMICOV3.sol


pragma solidity ^0.8.26;






/** 
* @title ECM Token ICO Sale Contract with Affiliate System
* @notice Manages ICO stages and affiliate rewards
* @dev Implements multi-stage ICO with referral and tier-based rewards
*/
contract ECMICOV3 is ReentrancyGuard, Pausable, Ownable(msg.sender) {
    using SafeMath for uint256;

    /// @notice ECM token contract interface
    IERC20 public immutable ecmCoin;
    /// @notice Wallet to receive treasury funds
    address payable public treasuryWallet;

    /// @notice Structure for each ICO stage
    struct Stage {
        uint256 target;          // Total ECM tokens available in this stage
        uint256 price;           // Price per ECM in ETH
        uint256 ecmRefBonus;     // Referral bonus in ECM (percentage)
        uint256 ethRefBonus;     // Referral bonus in ETH (percentage)
        uint256 ecmSold;         // Amount of ECM sold in this stage
        bool isCompleted;        // Whether stage is completed
    }

    /// @notice Structure to track affiliate information
    struct AffiliatorInfo {
        uint256 totalSalesVolume;    // Total ECM sales through referrals
        uint256 affiliatorCount;     // Number of affiliators in network
        bool isAffiliator;          // Affiliator status
        mapping(uint256 => bool) tiersClaimed;  // Track claimed tier rewards
    }

    /// @notice Structure for affiliate tier information
    struct TierInfo {
        uint256 requiredAffiliators;  // Number of affiliators needed
        uint256 newAffiliators;       // New affiliators since last tier
        bool isActive;                // If tier is active
    }

    Stage[] public stages;
    TierInfo[] public tiers;

    uint256 public currentStage;
    uint256 public totalEcmSold;
    uint256 public totalECMReferralDistributed;
    uint256 public totalETHReferralDistributed;

    mapping(address => AffiliatorInfo) public affiliators;
    mapping(address => address) public referrerOf;

    uint256 public tierRewardPercentage = 2; // Default 2%
    uint256 public minECMHolding = 300 * 1e18;   // 300 ECM initial value
    uint256 public minSalesVolume = 2500 * 1e18; // 2500 ECM initial value

    // Events
    event ECMPurchased(address indexed buyer, uint256 amount, uint256 stage);
    event ReferralRewardPaid(address indexed referrer, uint256 ecmAmount, uint256 ethAmount);
    event TreasuryWalletUpdated(address indexed newWallet);
    
    event TokensWithdrawn(address indexed to, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 amount);

    event StageCompleted(uint256 stageIndex);
    event StageUpdated(uint256 stageIndex);
    event CurrentStageUpdated(uint256 newStage);
    event StageRefEcmBonusUpdated(uint256 stageIndex, uint256 newRefBonus);
    event StageRefEthBonusUpdated(uint256 stageIndex, uint256 newRefBonus);

    event MinECMHoldingUpdated(uint256 newAmount);
    event MinSalesVolumeUpdated(uint256 newAmount);

    event AffiliatorQualified(address indexed user);
    event TierRewardPercentageUpdated(uint256 newPercentage);
    event TierRewardClaimed(address indexed affiliator, uint256 tierIndex, uint256 ethAmount);
    event TierUpdated(uint256 tierIndex, uint256 requiredAffiliators, uint256 newAffiliators);

    /**
    * @notice Contract constructor to initialize the ICO stages, tiers, and treasury wallet.
    * @param _ecmCoin Address of the ECM token contract.
    * Initializes:
    * - ICO stages with predefined targets, prices, and referral bonuses.
    * - Affiliate tiers with required affiliators and rewards.
    * - Treasury wallet as the contract owner.
    */
    constructor(address _ecmCoin) {
        require(_ecmCoin != address(0), "Invalid token address");
        ecmCoin = IERC20(_ecmCoin);
        treasuryWallet = payable(owner());
        
        stages.push(Stage(200000 * 1e18, 0.00040 ether, 2, 3, 0, false));
        stages.push(Stage(200000 * 1e18, 0.00041 ether, 2, 3, 0, false));
        stages.push(Stage(200000 * 1e18, 0.00042 ether, 2, 3, 0, false));
        stages.push(Stage(100000 * 1e18, 0.00043 ether, 2, 3, 0, false));
        stages.push(Stage(100000 * 1e18, 0.00044 ether, 2, 3, 0, false));
        stages.push(Stage(50000 * 1e18, 0.00045 ether, 2, 3, 0, false));
        stages.push(Stage(50000 * 1e18, 0.00046 ether, 2, 3, 0, false));
        stages.push(Stage(50000 * 1e18, 0.00047 ether, 2, 3, 0, false));
        stages.push(Stage(50000 * 1e18, 0.00048 ether, 2, 3, 0, false));

        tiers.push(TierInfo(3, 3, true));
        tiers.push(TierInfo(7, 4, true));
        tiers.push(TierInfo(12, 5, true));
        tiers.push(TierInfo(20, 8, true));
        tiers.push(TierInfo(30, 10, true));
        tiers.push(TierInfo(50, 20, true));
    }

    /**
    * @dev Fallback function to receive ETH and purchase ECM tokens.
    * Automatically triggers a purchase for the sender with no referrer.
    * Requirements:
    * - The contract must not be paused.
    * - The ICO must not have ended.
    * - The sent ETH amount must be greater than zero.
    */
    receive() external payable whenNotPaused {
        require(currentStage < stages.length, "ICO has ended");
        require(msg.value > 0, "Invalid amount");
        _buyECM(msg.sender, address(0));
    }

    /**
    * @dev Purchase ECM tokens with an optional referrer.
    */
    function buyECM(address referrer) external payable whenNotPaused nonReentrant {
        require(currentStage < stages.length, "ICO has ended");
        _buyECM(msg.sender, referrer);
    }
    
    /**
    * @dev Internal function to handle ECM token purchases with referral logic.
    */
    function _buyECM(address buyer, address referrer) internal {
        require(msg.value > 0, "Invalid amount");

        Stage storage stage = stages[currentStage];
        require(stage.price > 0, "Invalid stage price");

        // Calculate ECM tokens to buy using SafeMath
        uint256 ecmToBuy = msg.value.mul(1e18).div(stage.price);
        require(stage.ecmSold.add(ecmToBuy) <= stage.target, "Exceeds stage target");

        // Circular referral prevention
        if (referrer != address(0) && referrer != buyer) {
            address currentReferrer = referrer;
            while (currentReferrer != address(0)) {
                require(currentReferrer != buyer, "Circular referral detected");
                currentReferrer = referrerOf[currentReferrer];
            }

            // Assign the referrer only after validating circular referral
            referrerOf[buyer] = referrer;

            // Update referrer's affiliate sales volume
            AffiliatorInfo storage refInfo = affiliators[referrer];
            refInfo.totalSalesVolume = refInfo.totalSalesVolume.add(ecmToBuy);

            // Calculate referral bonuses using SafeMath
            uint256 ethReferralAmount = msg.value.mul(stage.ethRefBonus).div(100);
            uint256 ecmReferralAmount = ecmToBuy.mul(stage.ecmRefBonus).div(100);

            // Distribute ETH referral bonus
            if (ethReferralAmount > 0) {
                (bool success, ) = payable(referrer).call{value: ethReferralAmount}("");
                require(success, "ETH referral transfer failed");
                totalETHReferralDistributed = totalETHReferralDistributed.add(ethReferralAmount);
            }

            // Distribute ECM referral bonus
            if (ecmReferralAmount > 0) {
                require(ecmCoin.allowance(owner(), address(this)) >= ecmReferralAmount, "Insufficient ECM allowance for referral");
                require(ecmCoin.transferFrom(owner(), referrer, ecmReferralAmount), "ECM referral transfer failed");
                totalECMReferralDistributed = totalECMReferralDistributed.add(ecmReferralAmount);
            }

            emit ReferralRewardPaid(referrer, ecmReferralAmount, ethReferralAmount);
            
            _checkAndUpdateAffiliatorStatus(referrer);
        }

        // Transfer ECM to the buyer
        require(ecmCoin.allowance(owner(), address(this)) >= ecmToBuy, "Insufficient ECM allowance for purchase");
        require(ecmCoin.transferFrom(owner(), buyer, ecmToBuy), "ECM transfer failed");

        // Update stage and total sales using SafeMath
        stage.ecmSold = stage.ecmSold.add(ecmToBuy);
        totalEcmSold = totalEcmSold.add(ecmToBuy);

        emit ECMPurchased(buyer, ecmToBuy, currentStage);

        // Check if the stage is completed
        if (stage.ecmSold >= stage.target) {
            stage.isCompleted = true;
            emit StageCompleted(currentStage);
            progressToNextStage();
        }
    }


    /**
    * @dev Qualifies a user as an affiliator if they meet requirements, updating referrer stats.
    * @param user The address to check.
    */
    function _checkAndUpdateAffiliatorStatus(address user) internal {
        AffiliatorInfo storage info = affiliators[user];

        if (!info.isAffiliator &&
            info.totalSalesVolume >= minSalesVolume &&
            ecmCoin.balanceOf(user) >= minECMHolding) {
            
            info.isAffiliator = true;
            
            // Update referrer's affiliator count if exists
            address referrer = referrerOf[user];
            if (referrer != address(0)) {
                affiliators[referrer].affiliatorCount++;
                _checkTierRewards(referrer);
            }
            
            emit AffiliatorQualified(user);
        }
    }

    /**
    * @dev Checks and distributes unclaimed tier rewards for a qualified affiliator.
    * @param affiliator The address of the affiliator to check.
    */
    function _checkTierRewards(address affiliator) internal {
        AffiliatorInfo storage info = affiliators[affiliator];
        
        for (uint256 i = 0; i < tiers.length; i++) {
            if (info.tiersClaimed[i] || !tiers[i].isActive) continue;

            if (info.affiliatorCount >= tiers[i].requiredAffiliators){
                uint256 ethReward = minSalesVolume
                    .mul(tiers[i].newAffiliators)
                    .mul(tierRewardPercentage)
                    .mul(stages[currentStage].price)
                    .div(100)
                    .div(1e18);
                
                info.tiersClaimed[i] = true;
                payable(affiliator).transfer(ethReward);
                
                emit TierRewardClaimed(affiliator, i, ethReward);
            }
        }
    }

    /**
    * @dev Advances to the next stage with a valid (non-zero) target.
    * If no valid stage is found, marks the ICO as completed.
    */
    function progressToNextStage() internal {
        for (uint256 i = currentStage + 1; i < stages.length; i++) {
            if (stages[i].target > 0) {
                currentStage = i;
                return;
            }
        }
        currentStage = stages.length; // Mark ICO as completed
    }


    /** ======= Start Stage Management ====== */

    /**
    * @dev Sets the current stage index.
    * Can only be called by the owner.
    * @param newStage The index of the new current stage.
    */
    function setCurrentStage(uint256 newStage) external onlyOwner {
        require(newStage < stages.length, "Invalid stage index");
        currentStage = newStage;
        emit CurrentStageUpdated(newStage);
    }

    /**
    * @dev Returns details of the current stage.
    * @return stageIndex The current stage.
    * @return target The target tokens for the stage.
    * @return price The price per token in ETH.
    * @return ecmRefBonus ECM referral bonus (percentage).
    * @return ethRefBonus ETH referral bonus (percentage).
    * @return ecmSold ECM tokens sold in the stage.
    * @return isCompleted Whether the stage is completed.
    */
    function currentStageInfo() external view returns (
        uint256 stageIndex,
        uint256 target,
        uint256 price,
        uint256 ecmRefBonus,
        uint256 ethRefBonus,
        uint256 ecmSold,
        bool isCompleted
    ) {
        require(currentStage < stages.length, "ICO has ended");
        Stage storage stage = stages[currentStage];
        return (
            currentStage,
            stage.target,
            stage.price,
            stage.ecmRefBonus,
            stage.ethRefBonus,
            stage.ecmSold,
            stage.isCompleted
        );
    }

    /**
    * @dev Updates the target tokens for a specific stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to update.
    * @param target The new target token amount.
    */
    function updateStageTarget(uint256 stageIndex, uint256 target) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        Stage storage stage = stages[stageIndex];
        require(target > stage.ecmSold, "Invalid target amount");
        stage.target = target;
        emit StageUpdated(stageIndex);
    }

    /**
    * @dev Updates the amount of ECM tokens sold in a specific stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to update.
    * @param soldAmount The new amount of ECM tokens sold.
    * Requirements:
    * - The stage index must be valid.
    * - The sold amount must not exceed the stage target.
    */
    function updateStageSold(uint256 stageIndex, uint256 soldAmount) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        Stage storage stage = stages[stageIndex];
        require(soldAmount <= stage.target, "Sold amount exceeds stage target");
        stage.ecmSold = soldAmount;
        emit StageUpdated(stageIndex);
    }

    /**
    * @dev Updates the token price for a specific stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to update.
    * @param price The new price per token in ETH.
    */
    function updateStagePrice(uint256 stageIndex, uint256 price) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        Stage storage stage = stages[stageIndex];
        require(price > 0, "Invalid price");
        stage.price = price;
        emit StageUpdated(stageIndex);
    }

    /**
    * @dev Toggles the completion status of a stage.
    * If toggling completes the current stage, progresses to the next valid stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to toggle.
    */
    function toggleCompleteStage(uint256 stageIndex) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        Stage storage stage = stages[stageIndex];
        stage.isCompleted = !stage.isCompleted;
        emit StageCompleted(stageIndex);
        if (stage.isCompleted && stageIndex == currentStage) {
            progressToNextStage();
        }
    }

    /**
    * @dev Updates the ECM referral bonus for a specific stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to update.
    * @param newRefBonus The new referral bonus in percentage.
    */
    function updateStageEcmRefBonus(uint256 stageIndex, uint256 newRefBonus) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        require(newRefBonus >= 0 && newRefBonus <= 100, "Bonus must be between 0% and 100%");
        stages[stageIndex].ecmRefBonus = newRefBonus;
        emit StageRefEcmBonusUpdated(stageIndex, newRefBonus);
    }

    /**
    * @dev Updates the ETH referral bonus for a specific stage.
    * Can only be called by the owner.
    * @param stageIndex The index of the stage to update.
    * @param newRefBonus The new referral bonus in percentage.
    */
    function updateStageEthRefBonus(uint256 stageIndex, uint256 newRefBonus) external onlyOwner {
        require(stageIndex < stages.length, "Invalid stage index");
        require(newRefBonus >= 0 && newRefBonus <= 100, "Bonus must be between 0% and 100%");
        stages[stageIndex].ethRefBonus = newRefBonus;
        emit StageRefEthBonusUpdated(stageIndex, newRefBonus);
    }
    /** ======= End Stage Management ====== */

    /** ======= Start Tier Management ====== */
    /**
    * @dev Adds a new affiliate tier with specified requirements and status.
    * @param requiredAffiliators The number of affiliators needed for the tier.
    * @param newAffiliators The number of new affiliators since the last tier.
    * @param isActive Whether the tier is active.
    */
    function addNewTier(
        uint256 requiredAffiliators,
        uint256 newAffiliators,
        bool isActive
    ) external onlyOwner {
        require(requiredAffiliators > 0, "Invalid required affiliators");
        require(newAffiliators > 0, "Invalid new affiliators");

        if (tiers.length > 0) {
            require(
                requiredAffiliators > tiers[tiers.length - 1].requiredAffiliators,
                "Must be higher than last tier"
            );
        }

        tiers.push(TierInfo(requiredAffiliators, newAffiliators, isActive));
        emit TierUpdated(tiers.length - 1, requiredAffiliators, newAffiliators);
    }

    /**
    * @dev Updates an existing affiliate tier's requirements and status.
    * @param tierIndex The index of the tier to update.
    * @param requiredAffiliators The new number of affiliators needed for the tier.
    * @param newAffiliators The new number of affiliators since the last tier.
    * @param isActive The new active status of the tier.
    */
    function updateTier(
        uint256 tierIndex,
        uint256 requiredAffiliators,
        uint256 newAffiliators,
        bool isActive
    ) external onlyOwner {
        require(tierIndex < tiers.length, "Invalid tier");
        require(requiredAffiliators > 0, "Invalid required affiliators");
        require(newAffiliators > 0, "Invalid new affiliators");

        tiers[tierIndex].requiredAffiliators = requiredAffiliators;
        tiers[tierIndex].newAffiliators = newAffiliators;
        tiers[tierIndex].isActive = isActive;

        emit TierUpdated(tierIndex, requiredAffiliators, newAffiliators);
    }

    /**
    * @dev Updates the tier reward percentage for affiliators.
    * @param newPercentage The new reward percentage (1 to 100).
    */
    function updateTierRewardPercentage(uint256 newPercentage) external onlyOwner {
        require(newPercentage > 0 && newPercentage <= 100, "Tier reward percentage must be between 1 and 100");
        tierRewardPercentage = newPercentage;
        emit TierRewardPercentageUpdated(newPercentage);
    }

    /**
    * @dev Updates the minimum ECM holding required to qualify as an affiliator.
    * @param newMinHolding The new minimum ECM token holding.
    */
    function updateMinECMHolding(uint256 newMinHolding) external onlyOwner {
        require(newMinHolding > 0, "Invalid min holding amount");
        minECMHolding = newMinHolding;
        emit MinECMHoldingUpdated(newMinHolding);
    }

    /**
    * @dev Updates the minimum sales volume required to qualify as an affiliator.
    * @param newMinVolume The new minimum ECM sales volume.
    */
    function updateMinSalesVolume(uint256 newMinVolume) external onlyOwner {
        require(newMinVolume > 0, "Invalid min sales volume");
        minSalesVolume = newMinVolume;
        emit MinSalesVolumeUpdated(newMinVolume);
    }
    /** ======= End Tier Management ====== */

    /** ======= Start Affiliadtion Management ====== */
    /**
    * @dev Returns information about an affiliator.
    * @param user The address of the affiliator.
    * @return salesVolume Total sales volume through referrals by the user.
    * @return affiliatorCount Number of affiliators referred by the user.
    * @return isAffiliator Whether the user is an active affiliator.
    */
    function getAffiliatorInfo(address user) external view returns (
        uint256 salesVolume,
        uint256 affiliatorCount,
        bool isAffiliator
    ) {
        AffiliatorInfo storage info = affiliators[user];
        return (
            info.totalSalesVolume,
            info.affiliatorCount,
            info.isAffiliator
        );
    }

    /**
    * @dev Saves affiliator info for migration, ensuring no duplicate or circular referrals.
    * @param user The address of the affiliator.
    * @param referrer The address of the referrer (if any).
    * @param totalSalesVolume Total referral sales volume of the affiliator.
    * @param affiliatorCount Number of affiliators referred by the user.
    * @param isAffiliator Whether the user qualifies as an affiliator.
    */
    function addAffiliatorInfo(
        address user,
        address referrer,
        uint256 totalSalesVolume,
        uint256 affiliatorCount,
        bool isAffiliator
    ) external onlyOwner {
        require(user != address(0), "Invalid user address");
        require(totalSalesVolume > 0, "Total sales volume must be greater than zero");
        require(affiliatorCount >= 0, "Affiliator count cannot be negative");
        require(!affiliators[user].isAffiliator, "Affiliator already exists");

        // Circular referral prevention
        if (referrer != address(0)) {
            address currentReferrer = referrer;
            while (currentReferrer != address(0)) {
                require(currentReferrer != user, "Circular referral detected");
                currentReferrer = referrerOf[currentReferrer];
            }
            referrerOf[user] = referrer; // Set the referrer after validation
        }

        // Save affiliator info
        AffiliatorInfo storage info = affiliators[user];
        info.totalSalesVolume = totalSalesVolume;
        info.affiliatorCount = affiliatorCount;
        info.isAffiliator = isAffiliator;
    }

    /**
    * @dev Checks if a specific tier reward has been claimed by a user.
    * @param user The address of the affiliator.
    * @param tierIndex The ID of the tier to check.
    * @return bool True if the tier reward has been claimed, false otherwise.
    */
    function isTierClaimed(address user, uint256 tierIndex) external view returns (bool) {
        return affiliators[user].tiersClaimed[tierIndex];
    }
    /** ======= End Affiliadtion Management ====== */

    /** ======= Start Withdrawal Management ====== */
    /**
    * @dev Withdraws a specified amount of ECM tokens to the owner's wallet.
    * Can only be called by the owner.
    * @param amount The amount of ECM tokens to withdraw.
    * Requirements:
    * - `amount` must be greater than 0.
    * - `amount` must not exceed the contract's ECM token balance.
    * Emits a `TokensWithdrawn` event.
    */
    function withdrawECM(uint256 amount) external onlyOwner {
        require(amount > 0 && amount <= ecmCoin.balanceOf(address(this)), "Invalid amount");
        require(ecmCoin.transfer(owner(), amount), "Token transfer failed");
        emit TokensWithdrawn(owner(), amount);
    }

    /**
    * @dev Withdraws a specified amount of ETH to the treasury wallet.
    * Can only be called by the owner.
    * @param amount The amount of ETH to withdraw.
    * Requirements:
    * - `amount` must be greater than 0.
    * - `amount` must not exceed the contract's ETH balance.
    * Emits a `FundsWithdrawn` event.
    */
    function withdrawFund(uint256 amount) external onlyOwner {
        require(amount > 0 && amount <= address(this).balance, "Invalid amount");
        treasuryWallet.transfer(amount);
        emit FundsWithdrawn(treasuryWallet, amount);
    }

    /**
    * @dev Withdraws all ETH and ECM tokens from the contract in case of an emergency.
    * Can only be called by the owner when the contract is paused.
    * Transfers ETH to the treasury wallet and ECM tokens to the owner's wallet.
    * Requirements:
    * - The contract must be paused.
    * - The treasury wallet must be set.
    */
    function emergencyWithdraw() external onlyOwner {
        require(paused(), "Contract must be paused");
        require(treasuryWallet != address(0), "Treasury wallet not set");
        uint256 balance = address(this).balance;
        if (balance > 0) {
            treasuryWallet.transfer(balance);
        }
        uint256 tokenBalance = ecmCoin.balanceOf(address(this));
        if (tokenBalance > 0) {
            ecmCoin.transfer(owner(), tokenBalance);
        }
    }
    /** ======= End Withdrawal Management ====== */

    /** ======= Start Contract Control ====== */
    /**
    * @dev Sets a new treasury wallet address.
    * Can only be called by the owner.
    * @param _newWallet The new treasury wallet address.
    * Requirements:
    * - `_newWallet` must not be the zero address.
    * Emits a `TreasuryWalletUpdated` event.
    */
    function setTreasuryWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0), "Invalid address");
        treasuryWallet = _newWallet;
        emit TreasuryWalletUpdated(_newWallet);
    }

    /**
    * @dev Pauses the contract, disabling critical functions.
    * Can only be called by the owner.
    * Emits a `Paused` event.
    */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @dev Unpauses the contract, re-enabling critical functions.
    * Can only be called by the owner.
    * Emits an `Unpaused` event.
    */
    function unpause() external onlyOwner {
        _unpause();
    }
    /** ======= End Contract Control ====== */

}