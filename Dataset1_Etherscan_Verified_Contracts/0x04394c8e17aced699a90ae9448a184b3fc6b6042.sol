// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IesLBR {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function mint(address user, uint256 amount) external returns(bool);
    function burn(address user, uint256 amount) external returns(bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IesLBR.sol";
import "./IERC20.sol";

interface IesLBRBoost {
    function getUserBoost(
        address user,
        uint256 userUpdatedAt,
        uint256 finishAt
    ) external view returns (uint256);

    function getUnlockTime(address user)
        external
        view
        returns (uint256 unlockTime);
}

interface IlybraFund {
    function refreshReward(address user) external;
}

contract StakingRewardsV2 {
    // Immutable variables for staking and rewards tokens
    IERC20 public immutable stakingToken;
    IesLBR public immutable rewardsToken;
    IesLBRBoost public esLBRBoost;
    IlybraFund public lybraFund;
    address public owner;

    // Duration of rewards to be paid out (in seconds)
    uint256 public duration = 2_592_000;
    // Timestamp of when the rewards finish
    uint256 public finishAt;
    // Minimum of last updated time and reward finish time
    uint256 public updatedAt;
    // Reward to be paid out per second
    uint256 public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total supply)
    uint256 public rewardPerTokenStored;
    // User address => rewardPerTokenStored
    mapping(address => uint256) public userRewardPerTokenPaid;
    // User address => rewards to be claimed
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userUpdatedAt;

    // Total staked
    uint256 public totalSupply;
    // User address => staked amount
    mapping(address => uint256) public balanceOf;

    constructor(
        address _stakingToken,
        address _rewardToken,
        address _boost,
        address _fund
    ) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IesLBR(_rewardToken);
        esLBRBoost = IesLBRBoost(_boost);
        lybraFund = IlybraFund(_fund);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    // Update user's claimable reward data and record the timestamp.
    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
            userUpdatedAt[_account] = block.timestamp;
        }
        _;
    }

    // Returns the last time the reward was applicable
    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(finishAt, block.timestamp);
    }

    // Calculates and returns the reward per token
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalSupply;
    }

    // Allows users to stake a specified amount of tokens
    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    // Allows users to withdraw a specified amount of staked tokens
    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function getBoost(address _account) public view returns (uint256) {
        return 100 * 1e18 + esLBRBoost.getUserBoost(
            _account,
            userUpdatedAt[_account],
            finishAt
        );
    }

    // Calculates and returns the earned rewards for a user
    function earned(address _account) public view returns (uint256) {
        return
            ((balanceOf[_account] *
                getBoost(_account) *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e38) +
            rewards[_account];
    }

    // Allows users to claim their earned rewards
    function getReward() external updateReward(msg.sender) {
        require(
            block.timestamp >= esLBRBoost.getUnlockTime(msg.sender),
            "Your lock-in period has not ended. You can't claim your esLBR now."
        );
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            lybraFund.refreshReward(msg.sender);
            rewardsToken.mint(msg.sender, reward);
        }
    }

    // Allows the owner to set the rewards duration
    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    // Allows the owner to set the boost contract address
    function setBoost(address _boost) external onlyOwner {
        esLBRBoost = IesLBRBoost(_boost);
    }

    // Allows the owner to set the mining rewards.
    function notifyRewardAmount(uint256 _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (finishAt - block.timestamp) *
                rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}