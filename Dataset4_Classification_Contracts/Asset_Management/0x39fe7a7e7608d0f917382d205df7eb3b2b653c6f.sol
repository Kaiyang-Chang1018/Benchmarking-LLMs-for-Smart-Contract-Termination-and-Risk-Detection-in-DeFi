// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ARTEMISStaking is Ownable, ReentrancyGuard {
    IERC20 public immutable stakingToken;

    uint256 public totalStaked;
    uint256 public totalRewardsDistributed;
    uint256 public earlyWithdrawalFee;
    uint256 public totalStakeholders;
    uint256 private constant BASIS_POINTS = 10000;

    struct StakingPackage {
        uint256 duration;
        uint256 apy;
        bool isActive;
    }

    struct UserStake {
        uint256 amount;
        uint256 startTime;
        uint256 packageId;
        uint256 lastRewardTime;
        bool exists;
    }

    mapping(uint256 => StakingPackage) public stakingPackage;
    mapping(address => UserStake) public userStakes;
    uint256 public packageCount;

    event Staked(address indexed user, uint256 amount, uint256 packageId);
    event Withdrawn(address indexed user, uint256 amount, uint256 fee);
    event RewardClaimed(address indexed user, uint256 reward);
    event PackageCreated(uint256 packageId, uint256 duration, uint256 apy);
    event PackageUpdated(uint256 packageId, uint256 apy);
    event EarlyWithdrawalFeeUpdated(uint256 newFee);

    constructor(address _stakingToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        earlyWithdrawalFee = 500;

        unchecked {
            _createPackage(30, 700);
            _createPackage(90, 2000);
            _createPackage(180, 3000);
        }
    }

    function setEarlyWithdrawalFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 3000, "Fee cannot exceed 30%");
        earlyWithdrawalFee = _newFee;
        emit EarlyWithdrawalFeeUpdated(_newFee);
    }

    function _createPackage(
        uint256 _durationInDays,
        uint256 _apyBasisPoints
    ) private {
        require(_durationInDays > 0 && _apyBasisPoints > 0, "Invalid params");

        stakingPackage[packageCount] = StakingPackage({
            duration: _durationInDays * 1 days,
            apy: _apyBasisPoints,
            isActive: true
        });

        emit PackageCreated(packageCount, _durationInDays, _apyBasisPoints);
        unchecked {
            packageCount++;
        }
    }

    function stake(uint256 _packageId, uint256 _amount) external nonReentrant {
        require(
            _packageId < packageCount && stakingPackage[_packageId].isActive,
            "Invalid package"
        );
        require(_amount > 0, "Amount must be > 0");
        require(!userStakes[msg.sender].exists, "Already staking");

        require(
            stakingToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        userStakes[msg.sender] = UserStake({
            amount: _amount,
            startTime: block.timestamp,
            packageId: _packageId,
            lastRewardTime: block.timestamp,
            exists: true
        });

        unchecked {
            totalStaked += _amount;
            totalStakeholders++;
        }

        emit Staked(msg.sender, _amount, _packageId);
    }

    function calculateReward(address _staker) public view returns (uint256) {
        UserStake memory userStakeData = userStakes[_staker];
        if (!userStakeData.exists) return 0;

        StakingPackage memory stakingPkg = stakingPackage[
            userStakeData.packageId
        ];
        uint256 timeElapsed = block.timestamp - userStakeData.lastRewardTime;

        unchecked {
            return
                (userStakeData.amount * stakingPkg.apy * timeElapsed) /
                (365 days) /
                BASIS_POINTS;
        }
    }

    function withdraw() external nonReentrant {
        UserStake storage userStakePosition = userStakes[msg.sender];
        require(userStakePosition.exists, "No stake found");

        uint256 stakedAmount = userStakePosition.amount;
        uint256 rewardAmount = calculateReward(msg.sender);
        uint256 withdrawalFee = 0;

        StakingPackage memory package = stakingPackage[
            userStakePosition.packageId
        ];
        if (block.timestamp < userStakePosition.startTime + package.duration) {
            withdrawalFee = (stakedAmount * earlyWithdrawalFee) / BASIS_POINTS;
            stakedAmount -= withdrawalFee;
        }

        unchecked {
            totalStaked -= userStakePosition.amount;
            totalStakeholders--;
            if (rewardAmount > 0) {
                totalRewardsDistributed += rewardAmount;
            }
        }

        delete userStakes[msg.sender];

        uint256 totalWithdrawAmount = stakedAmount + rewardAmount;
        if (totalWithdrawAmount > 0) {
            require(
                stakingToken.transfer(msg.sender, totalWithdrawAmount),
                "Transfer failed"
            );
        }

        emit Withdrawn(msg.sender, stakedAmount, withdrawalFee);
        if (rewardAmount > 0) {
            emit RewardClaimed(msg.sender, rewardAmount);
        }
    }

    function claimReward() external nonReentrant {
        UserStake storage userStakePosition = userStakes[msg.sender];
        require(userStakePosition.exists, "No stake found");

        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward to claim");

        userStakePosition.lastRewardTime = block.timestamp;

        unchecked {
            totalRewardsDistributed += reward;
        }

        require(stakingToken.transfer(msg.sender, reward), "Transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }

    function getStakingStats()
        external
        view
        returns (
            uint256 totalStakedAmount,
            uint256 totalRewards,
            uint256 stakeholderCount
        )
    {
        return (totalStaked, totalRewardsDistributed, totalStakeholders);
    }

    function getUserStakeInfo(
        address _user
    )
        external
        view
        returns (
            uint256 amount,
            uint256 packageId,
            uint256 startTime,
            uint256 pendingReward
        )
    {
        UserStake memory userStakeData = userStakes[_user];
        if (!userStakeData.exists) return (0, 0, 0, 0);

        return (
            userStakeData.amount,
            userStakeData.packageId,
            userStakeData.startTime,
            calculateReward(_user)
        );
    }
}