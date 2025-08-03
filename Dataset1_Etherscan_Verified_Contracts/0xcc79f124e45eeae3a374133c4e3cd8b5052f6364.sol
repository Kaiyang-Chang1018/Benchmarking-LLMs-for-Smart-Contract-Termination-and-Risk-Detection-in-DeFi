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

// File: contracts/PB TOKEN STAKING.sol

/**
 * @title PBT Staking
 * @dev This contract allows users to stake PBT tokens and earn PBT token rewards.
 */

pragma solidity 0.8.20;


contract PBTStaking {

    // Information about each user's staking status.
    struct UserInfo {
        uint256 amount;        // The amount of PBT tokens staked by the user.
        uint256 rewardDebt;    // The debt of rewards accumulated by the user.
    }

    uint256 public immutable endBlock; // The last block number when PBT distribution ends.
    uint256 public lastRewardBlock;    // Last block number that PBT distribution occurred.
    uint256 private accPbtPerShare;            // Accumulated PBT per share, times 1e12.

    // The PBT token, assumed to be completely ERC20 compatible and non-malicious
    IERC20 public immutable PBT;
    // PBT tokens minted per block.
    uint256 public immutable pbtPerBlock;

    // The source of all PBT rewards
    uint256 public pbtForRewards;
    // The total PBT deposits
    uint256 public totalDeposits;
    // Info of each user that stakes PBT tokens.
    mapping(address => UserInfo) public userInfo;

    // Events emitted for tracking user activities.
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    /**
     * @dev Constructor to initialize the PBT Staking contract.
     * @param _pbt The address of the PBT token contract.
     * @param _pbtPerBlock The number of PBT token rewards per block.
     * @param _startBlock The block number when staking rewards start.
     * @param _totalRewards The total amount of PBT tokens allocated for rewards.
     */
    constructor(IERC20 _pbt, uint256 _pbtPerBlock, uint256 _startBlock, uint256 _totalRewards) {
        require(_startBlock > block.number, "StartBlock must be in the future");
        PBT = _pbt;
        pbtPerBlock = _pbtPerBlock;
        lastRewardBlock = _startBlock;
        endBlock = _startBlock + _totalRewards / _pbtPerBlock;
    }

    /**
     * @dev View function to see pending PBT rewards on frontend.
     * @param _user The address of the user to query.
     * @return The pending PBT rewards for the user.
     */
    function pendingPbt(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 rewardPerShare = accPbtPerShare;
        uint256 denominator = totalDeposits;

        uint256 blockToUse = block.number;
        if (blockToUse > endBlock) {
            blockToUse = endBlock;
        }
        if (blockToUse > lastRewardBlock && denominator != 0) {
            uint256 pbtReward = (blockToUse - lastRewardBlock) * pbtPerBlock;
            rewardPerShare += (pbtReward * 1e12 / denominator);
        }
        return (user.amount * rewardPerShare / 1e12) - user.rewardDebt;
    }

    /**
     * @dev Deposit PBT tokens into the staking contract.
     * @param _amount The amount of PBT tokens to be deposited.
     */
    function deposit(uint256 _amount) external {
        _deposit(_amount);
    }

    /**
     * @dev Compound rewards by re-depositing earned PBT tokens.
     */
    function compoundDeposit() external {
        _deposit(0);
    }

    /**
     * @dev Withdraw PBT tokens (including deposited amount and rewards).
     * @param _amount The amount of PBT tokens to be withdrawn.
     */
    function withdraw(uint256 _amount) external {
        _withdraw(_amount);
    }

    /**
     * @dev Claim earned rewards without withdrawing deposited PBT tokens.
     */
    function claimRewards() external {
        _withdraw(0);
    }

    /**
     * @dev Emergency function to withdraw all deposited PBT tokens without caring about rewards.
     * Should only be called in emergency situations.
     */
    function emergencyWithdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToSend = user.amount;

        user.amount = 0;
        user.rewardDebt = 0;
        totalDeposits -= amountToSend;

        PBT.transfer(address(msg.sender), amountToSend);
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @dev Internal function to handle depositing PBT tokens.
     * @param _amount The amount of PBT tokens to be deposited.
     */
    function _deposit(uint256 _amount) internal {
        _updateRewards();

        UserInfo storage user = userInfo[msg.sender];

        uint256 pending;
        if (user.amount > 0) {
            pending = (user.amount * accPbtPerShare / 1e12) - user.rewardDebt;
        }
        user.amount += _amount + pending;
        user.rewardDebt = user.amount * accPbtPerShare / 1e12;

        totalDeposits += _amount + pending;
        pbtForRewards -= pending;

        if (_amount > 0) {
            PBT.transferFrom(address(msg.sender), address(this), _amount);
        }
        emit Deposit(msg.sender, _amount);
    }

    /**
     * @dev Internal function to handle withdrawing PBT tokens.
     * @param _amount The amount of PBT tokens to be withdrawn.
     */
    function _withdraw(uint256 _amount) internal {
        _updateRewards();

        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = (user.amount * accPbtPerShare / 1e12) - user.rewardDebt;

        require(_amount <= user.amount, "Withdrawal exceeds balance");
        require(PBT.balanceOf(address(this)) >= totalDeposits + pbtForRewards, "Insufficient PBT for all rewards");

        user.amount -= _amount;
        user.rewardDebt = user.amount * accPbtPerShare / 1e12;

        totalDeposits -= _amount;
        pbtForRewards -= pending;

        PBT.transfer(address(msg.sender), _amount + pending);
        emit Withdraw(msg.sender, _amount + pending);
    }

    /**
     * @dev Internal function to update rewards based on the current block.
     */
    function _updateRewards() internal {
        uint256 _lastRewardBlock = lastRewardBlock;
        uint256 _endBlock = endBlock;
        uint256 blockToUse = block.number;

        if (blockToUse <= _lastRewardBlock || _lastRewardBlock >= _endBlock) {
            return;
        }
        if (blockToUse > _endBlock) {
            blockToUse = _endBlock;
        }

        uint256 denominator = totalDeposits;
        if (denominator == 0) {
            lastRewardBlock = blockToUse;
            return;
        }
        uint256 pbtReward = (blockToUse - _lastRewardBlock) * pbtPerBlock;
        pbtForRewards += pbtReward;
        accPbtPerShare += (pbtReward * 1e12 / denominator);
        lastRewardBlock = blockToUse;
    }
}