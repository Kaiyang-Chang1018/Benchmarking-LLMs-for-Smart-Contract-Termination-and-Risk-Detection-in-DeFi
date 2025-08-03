// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract TCASHStaking is Ownable {
    IERC20 public TCASHToken; // TCASH token address
    uint256 public developmentFeeRate = 5; // 5% development fee rate
    uint256 public durationForMinimumReward = 2 minutes; // staking period at least
    uint256 public stakingStartTime; // First staked time in this contract
    uint256 public nStakers; // Number of users
    
    struct Stake {
        uint256 stakedAmount;
        uint256 removingAmount;
        uint256 stakedTime;
    }

    mapping(address => Stake) public stakes;
    address public developmentFee; // Development fee address
    address public stakedInfo; // Contract StakedInfo getting address

    event Staked(address indexed user, uint256 stakedAmount);
    event Unstaked(address indexed user, uint256 unstakedAmount, uint256 earnedETHRewards);

    constructor (
        address _TCASHToken,
        address _stakedInfo,
        address _developmentFee
    ) {
        TCASHToken = IERC20(_TCASHToken);
        stakedInfo = _stakedInfo;
        developmentFee = _developmentFee;
        stakingStartTime = block.timestamp;
        nStakers = 0;
    }

    // To get ETH into the contract
    receive() external payable {}
    fallback() external payable {}

    // Stake TCASH tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        // Stake TCASH token to this contract
        require(TCASHToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        if(stakes[msg.sender].stakedTime != 0) {
            stakes[stakedInfo].stakedAmount += amount;
            stakes[stakedInfo].removingAmount += (block.timestamp - stakingStartTime) * amount;
            stakes[msg.sender].stakedAmount += amount;
            stakes[msg.sender].removingAmount += (block.timestamp - stakingStartTime) * amount;
        } else {
            stakes[stakedInfo].stakedAmount += amount;
            stakes[stakedInfo].removingAmount += (block.timestamp - stakingStartTime) * amount;
            stakes[msg.sender] = Stake(amount, (block.timestamp - stakingStartTime) * amount, block.timestamp);
            nStakers++;
        }
        
        emit Staked(msg.sender, stakes[msg.sender].stakedAmount);
    }

    // Unstake TCASH tokens
    function unstake() external {
        require(stakes[msg.sender].stakedAmount > 0, "No staked amount");

        uint256 stakingDuration = block.timestamp - stakes[msg.sender].stakedTime;
        uint256 earnedETHRewards = 0;
        uint256 realEarnedETHRewards = 0;
        uint256 developmentFeeETHRewards = 0;
        uint256 totalETHAmountsInContract = address(this).balance;

        if (stakingDuration < durationForMinimumReward) {
            require(TCASHToken.transfer(msg.sender, stakes[msg.sender].stakedAmount), "Transfer TCASH token failed");
            stakes[stakedInfo].stakedAmount -= stakes[msg.sender].stakedAmount;
            stakes[stakedInfo].removingAmount -= stakes[msg.sender].removingAmount;
            nStakers--;
            stakes[msg.sender].stakedAmount = 0;
            stakes[msg.sender].removingAmount = 0;
            stakes[msg.sender].stakedTime = 0;
        } else {
            earnedETHRewards = (stakes[msg.sender].stakedAmount * (block.timestamp - stakingStartTime) - stakes[msg.sender].removingAmount) * totalETHAmountsInContract / (stakes[stakedInfo].stakedAmount * (block.timestamp - stakingStartTime) - stakes[stakedInfo].removingAmount);
            require(TCASHToken.transfer(msg.sender, stakes[msg.sender].stakedAmount), "Transfer TCASH token failed");
            stakes[stakedInfo].stakedAmount -= stakes[msg.sender].stakedAmount;
            stakes[stakedInfo].removingAmount -= stakes[msg.sender].removingAmount;

            nStakers--;
            stakes[msg.sender].stakedAmount = 0;
            stakes[msg.sender].removingAmount = 0;
            stakes[msg.sender].stakedTime = 0;
            //Transfer ETH
            if(earnedETHRewards > 0)
            {
                // Transfer ETH Reward to developer
                developmentFeeETHRewards = earnedETHRewards * developmentFeeRate / 100;
                payable(developmentFee).transfer(developmentFeeETHRewards);
                // Transfer ETH Reward to user
                realEarnedETHRewards = earnedETHRewards - developmentFeeETHRewards;
                payable(msg.sender).transfer(realEarnedETHRewards);
            }
        }
        emit Unstaked(msg.sender, stakes[msg.sender].stakedAmount, realEarnedETHRewards);
    }

    // Owner function to manually set staking period
    function manualSetStakingPeriod(uint256 amount) external onlyOwner {
        durationForMinimumReward = amount;
    }

    // Owner function to manually set development Fee address
    function manualSetDevelopmentFee(address developmentFeeAddress) external onlyOwner {
        developmentFee = developmentFeeAddress;
    }

    // Owner function to manually set development Fee Rate
    function manualSetDevelopmentFeeRate(uint256 devFeeRate) external onlyOwner {
        developmentFeeRate = devFeeRate;
    }
}