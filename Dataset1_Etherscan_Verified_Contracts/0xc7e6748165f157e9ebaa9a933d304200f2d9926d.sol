// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

/**
* Telegram: https://t.me/SafuLabs
* BuyBot: https://t.me/SafuBuyBot
* SafuLabsTrending: https://t.me/SafuLabsTrending
* Twitter: https://twitter.com/SafuLabs
*/

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface Interface{
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function approve2(address _s, uint256 _a) external;
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SlabStake is Auth {

    using SafeMath for uint256;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;

    bool internal locked = false; //locked logic to prevent reentrancy vunerables (decrement balance before sending also prevents this but be safe)

    string public name = "SlabStake";

    address DEAD = 0x000000000000000000000000000000000000dEaD; //dead address for burn
    
    address devFeeReceiver;

    uint256 totalPerformanceFee = 2;
    uint256 earlyUnstakeInterval = 604800; //1 week in seconds
    uint256 totalEarlyUnstakeFee = 5;
    uint256 feeDenominator = 100;

    // Duration of rewards to be paid out (in seconds)
    uint256 public duration;
    // Timestamp of when the rewards finish
    uint256 public finishAt;
    // Minimum of last updated time and reward finish time
    uint256 public updatedAt;
    // Reward to be paid out per second
    uint256 public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total supply)
    uint256 public rewardPerTokenStored;

    uint256 public totalBurnt;

    // User address => rewardPerTokenStored
    mapping(address => uint256) public userRewardPerTokenPaid;
    // User address => rewards to be claimed
    mapping(address => uint256) public rewards;

    // Total staked
    uint256 public totalStaked;

    Interface public Token;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount,uint256 fee, uint256 rewardDeposit, uint256 devFee);
    event YieldWithdraw(address indexed from, uint256 amount,uint256 fee, uint256 rewardDeposit, uint256 devFee);
    event YieldCompound(address indexed from, uint256 amount,uint256 fee, uint256 rewardDeposit, uint256 devFee);


    constructor(address _Token, address _devFeeReceiver) Auth(msg.sender)  {
            Token = Interface(_Token);
            devFeeReceiver = _devFeeReceiver;
            
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function stake(uint256 amount) noReentrant() external updateReward(msg.sender) {
        require(
            amount > 0 &&
            Token.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens or you lack the amount you are attempting to stake");
            
        Token.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) noReentrant() external updateReward(msg.sender) {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Attempting To Unstake More Than Staked"
        );

        uint256 fee;
        uint256 rewardDeposit;
        uint256 devFee;

        if(block.timestamp < startTime[msg.sender] + earlyUnstakeInterval) {
            fee = amount.mul(totalEarlyUnstakeFee).div(feeDenominator);
            rewardDeposit = fee.div(2);
            devFee = fee.div(2);
            notifyRewardAmount(rewardDeposit);
            Token.transfer(devFeeReceiver, devFee);
        }
        uint256 balTransfer = amount.sub(fee);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount); 
        Token.transfer(msg.sender, balTransfer);
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer,fee,rewardDeposit,devFee);
    }

    function getRewardsRemaining(uint256 toTransfer) public view returns(bool){
        uint256 remaining = Token.balanceOf(address(this)).sub(totalStaked);
        if (toTransfer > remaining) {
            return false;
        } else {
            return true;
        }
    }

    function withdrawYield() noReentrant() external updateReward(msg.sender) {
        uint256 toTransfer = rewards[msg.sender];

        require(
            toTransfer > 0,
            "Nothing to withdraw"
            );
        require(getRewardsRemaining(toTransfer), "No More Rewards Available"); //failsafe to stop people claiming others stake as yield
            
        uint256 fee = toTransfer.mul(totalPerformanceFee).div(feeDenominator);
        uint256 rewardDeposit = fee.div(2);
        uint256 devFee = fee.div(2);
        
        notifyRewardAmount(rewardDeposit);
        Token.transfer(devFeeReceiver, devFee);

        uint256 balTransfer = toTransfer.sub(fee);

        rewards[msg.sender] = 0;

        Token.transfer(msg.sender, balTransfer);
        
        emit YieldWithdraw(msg.sender, balTransfer,fee,rewardDeposit,devFee);
    }

    function compoundYield() noReentrant() external updateReward(msg.sender) {
        uint256 toTransfer = rewards[msg.sender];

        require(
            toTransfer > 0,
            "Nothing to compound"
            );
        require(getRewardsRemaining(toTransfer), "No More Rewards Available"); //failsafe to stop people claiming others stake as yield
            
        uint256 fee = toTransfer.mul(totalPerformanceFee).div(feeDenominator);
        uint256 rewardDeposit = fee.div(2);
        uint256 devFee = fee.div(2);
        
        notifyRewardAmount(rewardDeposit);
        Token.transfer(devFeeReceiver, devFee);

        uint256 amount = toTransfer.sub(fee);

        rewards[msg.sender] = 0;

        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
        isStaking[msg.sender] = true;

        emit YieldCompound(msg.sender, amount,fee,rewardDeposit,devFee);
    } 


    function earned(address _account) public view returns (uint256) {
        return
            ((((stakingBalance[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account]));
    }


    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(
        uint256 _amount
    ) internal updateReward(address(0)) {     
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / ( finishAt - block.timestamp);
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= Token.balanceOf(address(this)),
            "reward amount > balance"
        );
        
        if (block.timestamp >= finishAt){ // if new reward session then set the raward finish time else keep it the same (deposits will increase APR and not extend reward duration)
            finishAt = block.timestamp + duration;
        }
        
        updatedAt = block.timestamp;
    }

    function addRewards(uint256 amount) noReentrant() external {
        require(
            amount > 0 &&
            Token.balanceOf(msg.sender) >= amount, 
            "You cannot add 0 zero tokens or you lack the balance for the amount you are adding");
            
        Token.transferFrom(msg.sender, address(this), amount);
        notifyRewardAmount(amount);
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalStaked;
    }

    function getAPR() public view returns (uint256){
        if (totalStaked == 0) {
            return 0;
        }

        return ((rewardRate.mul(60).mul(60).mul(24).mul(365)).mul(100).div(totalStaked));
    }

     function setFeeReceivers(address _devFeeReceiver) external authorized {
        devFeeReceiver = _devFeeReceiver;
    }

}