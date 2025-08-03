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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

contract Staking is Ownable {
    using SafeMath for uint256;

    IUniswapV2Router public uniswapRouter;
    IERC20 public token;
    uint256 public stakingDuration = 15 days;
    uint256 public withdrawalCooldown = 1 days; // Cooldown period for Ethereum withdrawals
    uint256 public dailyWithdrawalLimitPercentage = 2; // 2% daily withdrawal limit;
    address public penaltyWallet;

    mapping(address => uint256) public stakes;
    mapping(address => uint256) public ethValueOfStakes;
    mapping(address => uint256) public lastDepositTime;
    mapping(address => uint256) public lastETHWithdrawTime;
    mapping(address => uint256) public totalETHWithdrawn;

    event rewardWithdrawn(address indexed _user ,uint256 _amount, uint256 _claimDays);
    event tokensStaked(address indexed _user ,uint256 _amount);
    event tokensUnstaked(address indexed _user ,uint256 _amount);
    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    modifier onlyToken() {
        assert(msg.sender == address(token));
        _;
	}

    constructor() {
        uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }

    function updateStakingDuration(uint256 _duration) external onlyOwner {
        stakingDuration = _duration;
    }

    function updateWithdrawalCooldown(uint256 _cooldown) external onlyOwner {
        withdrawalCooldown = _cooldown;
    }

    function setDailyWithdrawalLimit(uint256 _percentage) external onlyOwner {
        require(_percentage <= 20, "Percentage must be less than 20%");
        dailyWithdrawalLimitPercentage = _percentage;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid address");
        token = IERC20(_tokenAddress);
        penaltyWallet = _tokenAddress;
    }

    function stakeTokens(address _user, uint _amount) external onlyToken {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethValue = calculateTokenValueInETH(_amount);

        // Update user's stake and ethValueOfStakes
        stakes[_user] = stakes[_user].add(_amount);
        ethValueOfStakes[_user] = ethValueOfStakes[_user].add(ethValue);

        // Update last withdrawal time
        lastDepositTime[_user] = block.timestamp;        
        emit tokensStaked(_user,_amount);
        
        if (lastETHWithdrawTime[_user] == 0){
            lastETHWithdrawTime[_user] = block.timestamp;
        }
    }

    function calculateTokenValueInETH(uint256 _amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswapRouter.WETH();

        uint256[] memory amounts = uniswapRouter.getAmountsOut(_amount, path);
        return amounts[1];
    }

    function calculateDailyWithdrawalLimit(address _user) internal view returns (uint256 total, uint256 daysSinceLastWithdrawal) {
        uint256 ethValue = ethValueOfStakes[_user];
        daysSinceLastWithdrawal = (block.timestamp.sub(lastETHWithdrawTime[_user])).div(withdrawalCooldown);
        uint256 dailyLimit = ethValue.mul(dailyWithdrawalLimitPercentage).div(100);
        total = dailyLimit.mul(daysSinceLastWithdrawal);
    }

    function withdrawReward() external {
        require(stakes[msg.sender] > 0, "No tokens staked");

        uint256 currentTime = block.timestamp;
        require(currentTime >= lastETHWithdrawTime[msg.sender].add(withdrawalCooldown), "Cooldown period not passed");

        (uint256 dailyWithdrawalAmount, uint256 claimDays) = calculateDailyWithdrawalLimit(msg.sender);
        require(dailyWithdrawalAmount > 0, "No withdrawable amount available");

        lastETHWithdrawTime[msg.sender] = currentTime;
        totalETHWithdrawn[msg.sender] = totalETHWithdrawn[msg.sender].add(dailyWithdrawalAmount);
        payable(msg.sender).transfer(dailyWithdrawalAmount);
        emit rewardWithdrawn(msg.sender, dailyWithdrawalAmount, claimDays);
    }

    function unstakeTokens() external {
        require(stakes[msg.sender] > 0, "No tokens staked");
        uint256 withdrawTokens = 0;

        uint256 stakedAmount = stakes[msg.sender];

        if(block.timestamp <= lastDepositTime[msg.sender].add(stakingDuration)){
            uint256 penalty = stakedAmount.mul(20).div(100); // 20% penalty
            withdrawTokens = stakedAmount.sub(penalty);
            token.transfer(penaltyWallet, penalty);
        }
        else{
            withdrawTokens = stakedAmount;
        }

        stakes[msg.sender] = 0;
        ethValueOfStakes[msg.sender] = 0;
        token.transfer(msg.sender, withdrawTokens);
        emit tokensUnstaked(msg.sender, withdrawTokens);
    }

    function getUserStake(address _user) external view returns (uint256 totalStakedTokens, uint256 totalrewardwithdrawn, uint256 ethValueOfStake, uint256 remainingDays) {
        totalStakedTokens = stakes[_user];
        ethValueOfStake = ethValueOfStakes[_user];
        uint256 currentTime = block.timestamp;
        totalrewardwithdrawn = totalETHWithdrawn[_user];
        if (currentTime < lastDepositTime[_user].add(stakingDuration)) {
            remainingDays = (lastDepositTime[_user].add(stakingDuration).sub(currentTime)).div(1 days);
        } else {
            remainingDays = 0;
        }
    }

    function emergencyWithdrawERC20(IERC20 erc20) external onlyOwner {
		uint256 balanceToken = erc20.balanceOf(address(this));
		erc20.transfer(owner(), balanceToken);
	}

	function emergencyWithdrawETH() external onlyOwner {
		uint256 balanceETH = address(this).balance;
		payable(msg.sender).transfer(balanceETH);
	}
}