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
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Staking Contract
 * @dev A staking contract that allows users to stake ERC20 tokens and earn rewards based on staking duration and tier.
 * The contract supports multiple staking periods, APRs, and tiers with multipliers for rewards.
 */
contract Staking is Ownable {
    IERC20 public stakingToken; // The ERC20 token used for staking

    struct Stake {
        uint256 tokenAmount; // Amount of tokens staked
        uint256 startTime; // Timestamp when staking started
        uint256 stakingType; // Type of staking (0 = flexible, 1+ = locked)
        address user; // Address of the staker
        uint256 id; // Unique ID of the stake
        uint256 unlockStartTime; // Timestamp when unlock was initiated
        bool finished; // Whether the stake is withdrawn
    }

    // Staking periods in days (0 = flexible, 1 = 1 month, 3 = 3 months, etc.)
    // uint256[] public stakingPeriods = [
    //     0 days,
    //     1 * 30 days,
    //     3 * 30 days,
    //     6 * 30 days,
    //     12 * 30 days
    // ];

    /// for test reduced staking time
    uint256[] public stakingPeriods = [
        0 days,
        1 hours,
        2 hours,
        3 hours,
        4 hours
    ];

    // unlock period
    // uint256 unlockPeriod = 7 days;

    /// for test reduced unlockPeriod
    uint256 unlockPeriod = 30 minutes;


    // Annual Percentage Rates (APR) for each staking type
    uint256[] public stakingAPRs = [30, 42, 60, 90, 120];

    // Tier thresholds for launchpad eligibility
    uint256[] public tierThresholds = [
        1000,
        5000,
        20000,
        50000,
        100000,
        250000
    ];

    // Multipliers for staking types (used for launchpad tier calculation)
    uint256[] public stakingMultipliers = [0, 10, 12, 15, 20];

    uint256 public constant BASE = 1000; // Base value for APR calculations

    Stake[] public stakes; // Array of all stakes
    uint256 public totalNumberOfStakes; // Total number of stakes created
    bool public isOpen; // Whether staking is open
    uint256 public totalPaidRewards;

    mapping(uint256 => uint256) public rewards; // Mapping of stake ID to reward amount

    event Deposit(address indexed user, uint256 amount, uint256 stakingType);
    event Withdraw(uint256 indexed id, uint256 rewardAmount);
    event Restake(uint256 indexed id, uint256 stakingType);

    /**
     * @dev Constructor to initialize the staking contract.
     * @param _stakingToken Address of the ERC20 token used for staking.
     */
    constructor(address _stakingToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        totalNumberOfStakes = 0;
    }

    /**
     * @dev Initializes the staking contract by transferring tokens to the contract.
     * @param _amount Amount of tokens to transfer.
     */
    function initialize(uint256 _amount) external onlyOwner {
        require(!isOpen, "Already initialized");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        isOpen = true;
    }

    /**
     * @dev Allows a user to stake tokens.
     * @param _amount Amount of tokens to stake.
     * @param _stakingType Type of staking (0 = flexible, 1+ = locked).
     */
    function stakeTokens(uint256 _amount, address _user, uint256 _stakingType) external {
        require(isOpen, "Staking is not available");
        require(_amount > 0, "Cannot stake 0 tokens");

        stakes.push(
            Stake({
                tokenAmount: _amount,
                startTime: block.timestamp,
                stakingType: _stakingType,
                user: _user,
                id: totalNumberOfStakes,
                unlockStartTime: 0,
                finished: false
            })
        );

        totalNumberOfStakes++;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount, _stakingType);
    }

    /**
     * @dev Initiates the unlock process for a locked stake.
     * @param _id ID of the stake to unlock.
     */
    function initiateUnlock(uint256 _id) external {
        Stake storage stake = stakes[_id];
        require(!stake.finished, "Stake already withdrawn");
        require(stake.user == msg.sender, "Not the stake owner");
        require(stake.unlockStartTime == 0, "Unlock already initiated");

        uint256 stakingDuration = block.timestamp - stake.startTime;
        if (stake.stakingType != 0) {
            require(
                stakingDuration > stakingPeriods[stake.stakingType],
                "Lock period not reached"
            );
        }

        stake.unlockStartTime = block.timestamp;
    }

    /**
     * @dev Allows a user to withdraw their stake and rewards.
     * @param _id ID of the stake to withdraw.
     */
    function withdrawStake(uint256 _id) external {
        Stake storage stake = stakes[_id];
        require(!stake.finished, "Stake already withdrawn");
        require(stake.user == msg.sender, "Not the stake owner");

        uint256 rewardAmount = calculateReward(_id);
        require(rewardAmount > 0, "Insufficient reward amount");

        stake.finished = true;
        stakingToken.transfer(msg.sender, stake.tokenAmount + rewardAmount);
        rewards[_id] = rewardAmount;
        totalPaidRewards += rewardAmount;
        emit Withdraw(_id, rewardAmount);
    }

    /**
     * @dev Allows a user to restake their rewards into a new stake.
     * @param _id ID of the stake to restake.
     * @param _stakingType New staking type for the restake.
     */
    function restakeRewards(uint256 _id, uint256 _stakingType) external {
        Stake storage stake = stakes[_id];
        require(!stake.finished, "Stake already withdrawn");
        require(stake.user == msg.sender, "Not the stake owner");

        uint256 rewardAmount = calculateReward(_id);
        require(rewardAmount > 0, "Insufficient reward amount");

        stake.stakingType = _stakingType;
        stake.startTime = block.timestamp;
        stake.tokenAmount += rewardAmount;
        stake.unlockStartTime = 0;
        emit Restake(_id, _stakingType);
    }

    /**
     * @dev Returns the list of stake IDs owned by a specific address.
     * @param _owner Address of the staker.
     * @return Array of stake IDs.
     */
    function getStakeIdsByOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](totalNumberOfStakes);
        uint256 count = 0;

        for (uint256 i = 0; i < totalNumberOfStakes; i++) {
            Stake storage stake = stakes[i];
            if (stake.user == _owner) {
                ids[count] = i;
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = ids[j];
        }

        return result;
    }

    /**
     * @dev Returns the Launchpad tiers and multipliers for all stakes owned by a specific address.
     * @param _owner The address of the staker.
     * @return tiers An array of tiers corresponding to each stake.
     * @return multipliers An array of multipliers corresponding to each stake.
     */
    function getLaunchpadTiersByOwner(
        address _owner
    )
        public
        view
        returns (uint256[] memory tiers, uint256[] memory multipliers)
    {
        uint256[] memory ids = getStakeIdsByOwner(_owner);
        tiers = new uint256[](ids.length);
        multipliers = new uint256[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            tiers[i] = calculateLaunchpadTier(ids[i]);

            uint256 stakingType = stakes[ids[i]].stakingType;

            multipliers[i] = stakingMultipliers[stakingType];
        }

        return (tiers, multipliers);
    }

    /**
     * @dev Calculates the launchpad tier for a specific stake.
     * @param _id ID of the stake.
     * @return Tier level (0 = no tier, 1+ = tier level).
     */
    function calculateLaunchpadTier(uint256 _id) public view returns (uint256) {
        Stake storage stake = stakes[_id];
        uint256 amount = stake.tokenAmount;
        uint256 tier = 0;
        for (uint256 i = 0; i < tierThresholds.length; i++) {
            if (amount >= tierThresholds[i] * 10 ** 9) {
                tier = i + 1;
            }
        }

        return tier;
    }

    /**
     * @dev Calculates the reward for a specific stake.
     * @param _id ID of the stake.
     * @return Reward amount.
     */
    function calculateReward(uint256 _id) public view returns (uint256) {
        Stake storage stake = stakes[_id];
        if (stake.finished) return 0;
        require(block.timestamp - stake.unlockStartTime >= unlockPeriod && stake.unlockStartTime > 0, "not reached unlock period");
        uint256 rewardTime = stakingPeriods[stake.stakingType];
        uint256 stakingDuration = block.timestamp - stake.startTime - unlockPeriod;

        if (stake.stakingType == 0) {
            rewardTime = stakingDuration;
        }

        // return
        //     (stake.tokenAmount *
        //         (rewardTime *
        //             stakingAPRs[stake.stakingType] +
        //             (stakingDuration - rewardTime) *
        //             stakingAPRs[0])) / (365 days * BASE);

        /// for test 1 Year => 2 days
        return
            (stake.tokenAmount *
                (rewardTime *
                    stakingAPRs[stake.stakingType] +
                    (stakingDuration - rewardTime) *
                    stakingAPRs[0])) / (2 days * BASE);
    }

    /**
     * @dev Returns the total number of stakes in the contract.
     * @return Total number of stakes.
     */
    function getTotalStakes() public view returns (uint256) {
        return totalNumberOfStakes;
    }

    /**
     * @dev Returns the details of a specific stake.
     * @param _id ID of the stake.
     * @return Stake details.
     */
    function getStakeDetails(uint256 _id) public view returns (Stake memory) {
        return stakes[_id];
    }

    function emergencyWithdraw() external onlyOwner(){
        stakingToken.transfer(msg.sender, stakingToken.balanceOf(address(this)));
    }
}