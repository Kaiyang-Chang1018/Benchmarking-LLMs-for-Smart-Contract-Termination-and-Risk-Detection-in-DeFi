// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.20;

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

contract StakingContract is Ownable{
    using SafeMath for uint;
    using SafeMath for uint256;

    struct stakeInfo{
        uint256 amount;
        uint256 lockupDays;
        uint256 stakedOn;
        uint256 lastRewardCalculated;
        uint256 pendingRewards;
        uint256 lastClaimed;
        uint256 totalClaimed;
        uint256 apy;
        uint256 unstakedOn;
        uint256 penalty;

    }

    uint256 public constant MAX_APY = 1_200_000;
    uint256 public constant MAX_LOCKUP_DAYS = 365;
    uint256 public max_penalty = 750_000;
    uint256 public constant PRECISION = 1e6;

    uint256[2] public bonusTiers = [1_000, 5_000];
    uint256[2] public bonusBoosts = [1_100_000, 1_200_000];

    mapping(address => uint256) public userStakeCount;

    address public cosmicTokenAddress;
    mapping (address user => stakeInfo[]) public userStakes;

    constructor(address _cosmicTokenAddress) Ownable(msg.sender){
        cosmicTokenAddress = _cosmicTokenAddress;
    }
    
    receive() external payable {
  	}

    function calculateBonus(uint256 _amount) public view returns(uint256){
        uint256 supply_percentage = _amount.mul(PRECISION).div(IERC20(cosmicTokenAddress).totalSupply());
        if(supply_percentage >= bonusTiers[1]){
            return bonusBoosts[1];
        }
        if(supply_percentage >= bonusTiers[0]){
            return bonusBoosts[0];
        }
        return PRECISION;
    }

    function calculateAPY(uint256 _lockupDays) public pure returns(uint256){
        return _lockupDays.mul(MAX_APY).div(365);
    }

    function calculatePenalty(uint256 _lockupDays, uint256 _daysSinceLastStaked) public view returns(uint256){
        if (_daysSinceLastStaked >= _lockupDays){
            return 0;
        }
        return max_penalty.sub(_daysSinceLastStaked.mul(max_penalty).div(_lockupDays));
    }

    function updateMaxPenalty(uint256 _newPenalty) public onlyOwner {
        max_penalty = _newPenalty;
    }
 
    function stake(uint256 _amount, uint256 _lockupDays) public{
        require(_lockupDays <= MAX_LOCKUP_DAYS, "Invalid lockup days");
        require(_lockupDays > 0, "Invalid lockup days");
        require(_amount > 0, "Invalid amount");
        IERC20(cosmicTokenAddress).transferFrom(msg.sender, address(this), _amount);
        
        uint256 apy = calculateAPY(_lockupDays);

        stakeInfo memory newStake = stakeInfo({
            amount: _amount,
            lockupDays: _lockupDays,
            stakedOn: block.timestamp,
            lastRewardCalculated: block.timestamp,
            pendingRewards: 0,
            lastClaimed: block.timestamp,
            totalClaimed: 0,
            apy: apy,
            unstakedOn: 0,
            penalty: 0
        });
        userStakeCount[msg.sender] = userStakeCount[msg.sender].add(1);
        userStakes[msg.sender].push(newStake);
    }

    function calculatePendingRewards(uint256 _index) public view returns(uint256){
        address _account = msg.sender;
        uint256 _lastRewardCalculated = userStakes[_account][_index].lastRewardCalculated;
        uint256 _amount = userStakes[_account][_index].amount;
        uint256 _apy = userStakes[_account][_index].apy;
        uint256 _currentTime = block.timestamp;
        uint256 _daysSinceLastRewardCalculated = _currentTime.sub(_lastRewardCalculated).mul(1e9).div(86400);
        uint256 _amountAfterBonus = _amount.mul(calculateBonus(_amount)).div(PRECISION);
        uint256 _pendingRewards = _amountAfterBonus.mul(_daysSinceLastRewardCalculated).mul(_apy).div(365).div(1e9).div(PRECISION);
        
        return _pendingRewards.add(userStakes[_account][_index].pendingRewards);
    }

    function calculateUnstakePenalty(uint256 _index) public view returns(uint256){
        address _account = msg.sender;
        uint256 _lastStaked = userStakes[_account][_index].stakedOn;
        uint256 _lockupDays = userStakes[_account][_index].lockupDays;
        uint256 _daysSinceLastStaked = (block.timestamp.sub(_lastStaked)).div(86400);

        uint256 _penalty = calculatePenalty(_lockupDays, _daysSinceLastStaked);
        return _penalty;
    }

    function unstake(uint256 _index) public{
        address _account = msg.sender;
        require(_index < userStakes[_account].length, "Invalid index");
        require(userStakes[_account][_index].unstakedOn == 0, "Already unstaked");
        uint256 _penalty = calculateUnstakePenalty(_index);
        uint256 _penaltyAmount = userStakes[_account][_index].amount.mul(_penalty).div(PRECISION);
        uint256 _pendingRewards = calculatePendingRewards(_index);
        uint256 _amount = userStakes[_account][_index].amount;

        userStakes[_account][_index].pendingRewards = 0;
        userStakes[_account][_index].totalClaimed = userStakes[_account][_index].totalClaimed.add(_pendingRewards);
        userStakes[_account][_index].lastRewardCalculated = block.timestamp;
        userStakes[_account][_index].amount = 0;
        userStakes[_account][_index].unstakedOn = block.timestamp;
        userStakes[_account][_index].penalty = _penalty;

        IERC20(cosmicTokenAddress).transfer(_account, _amount.sub(_penaltyAmount).add(_pendingRewards));

    }

    function claimRewards(uint256 _index) public{
        address _account = msg.sender;
        require(_index < userStakes[_account].length, "Invalid index");
        uint256 _pendingRewards = calculatePendingRewards(_index);
        userStakes[_account][_index].lastRewardCalculated = block.timestamp;
        userStakes[_account][_index].pendingRewards = 0;
        userStakes[_account][_index].totalClaimed = userStakes[_account][_index].totalClaimed.add(_pendingRewards);
        userStakes[_account][_index].lastClaimed = block.timestamp;
        IERC20(cosmicTokenAddress).transfer(_account, _pendingRewards);
    }

    function emergenceyWithdrawTokens() public onlyOwner {
        IERC20(cosmicTokenAddress).transfer(owner(), IERC20(cosmicTokenAddress).balanceOf(address(this)));
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

}