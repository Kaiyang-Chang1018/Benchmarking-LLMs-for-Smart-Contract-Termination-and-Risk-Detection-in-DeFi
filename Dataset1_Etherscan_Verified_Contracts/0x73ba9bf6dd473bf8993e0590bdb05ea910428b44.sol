/**
 *Submitted for verification at Etherscan.io on 2024-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() private view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() private view returns (bool) {
        return _status == _ENTERED;
    }
}

contract Dogita_Staking is Ownable, ReentrancyGuard {
    struct PoolInfo {
        uint256 lockupDuration;
        uint256 returnPer;
    }
    struct OrderInfo {
        address beneficiary;
        uint256 amount;
        uint256 lockupDuration;
        uint256 returnPer;
        uint256 starttime;
        uint256 endtime;
        uint256 claimedReward;
        bool claimed;
        uint256 lastClaimTime;
    }
    uint256 private constant _1Year = 30 days;
    uint256 private constant _2Year = 60 days;
    uint256 private constant _3Year = 90 days;
    uint256 public _claimInterval = 30 days; //Interval of 6 months

    uint256 private constant _days365 = 365 days;
    IERC20 public token = IERC20(0x488542C2320F20D65405a1C03DA769Bc124F9A28);

    address feeReceiver = 0xF7fC367FBa1fc53Aa1f34308025B3BeD39525951;
    address withdrawFeeReceiver = 0xF7fC367FBa1fc53Aa1f34308025B3BeD39525951;

    bool private started = true;
    uint256 public emergencyWithdrawFees = 20; // 20%
    uint256 public withdrawFees = 10; // 10%

    uint256 private latestOrderId = 0;
    uint256 public totalStakers; // use
    uint256 public totalStaked; // use
    uint256 public minStake = 5000000 * 10**18;
    uint256 public maxStake = 100000000 * 10**18;

    mapping(uint256 => PoolInfo) public pooldata;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public totalRewardEarn;
    mapping(uint256 => OrderInfo) public orders;
    mapping(address => uint256[]) private orderIds;
    mapping(address => mapping(uint256 => bool)) public hasStaked;
    mapping(uint256 => uint256) public stakeOnPool;
    mapping(uint256 => uint256) public rewardOnPool;
    mapping(uint256 => uint256) public stakersPlan;

    event Deposit(
        address indexed user,
        uint256 indexed lockupDuration,
        uint256 amount,
        uint256 returnPer
    );
    event Withdraw(
        address indexed user,
        uint256 amount,
        uint256 reward,
        uint256 total
    );
    event WithdrawAll(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor() {
        pooldata[1].lockupDuration = _1Year;
        pooldata[1].returnPer = 17;

        pooldata[2].lockupDuration = _2Year;
        pooldata[2].returnPer = 24;

        pooldata[3].lockupDuration = _3Year;
        pooldata[3].returnPer = 31;
    }

    function deposit(uint256 _amount, uint256 _lockupDuration) external {
        PoolInfo storage pool = pooldata[_lockupDuration];
        require(_amount >= minStake, "Minimum Stake amount is not reached");
        require(
            _amount <= maxStake,
            "Maximum Stake amount Per Wallet exceeded"
        );

        require(
            pool.lockupDuration > 0,
            "TokenStaking: asked pool does not exist"
        );
        require(started, "TokenStaking: staking not yet started");
        require(_amount > 0, "TokenStaking: stake amount must be non zero");

        uint256 fees = (_amount * withdrawFees) / 100;
        uint256 depAmount = _amount - fees;

        require(
            token.transferFrom(_msgSender(), address(this), depAmount),
            "TokenStaking: token transferFrom via deposit not succeeded"
        );
        require(
            token.transferFrom(_msgSender(), withdrawFeeReceiver, fees),
            "TokenStaking: token transferFrom via deposit not succeeded"
        );

        orders[++latestOrderId] = OrderInfo(
            _msgSender(),
            depAmount,
            pool.lockupDuration,
            pool.returnPer,
            block.timestamp,
            block.timestamp + pool.lockupDuration,
            0,
            false,
            block.timestamp
        );

        if (!hasStaked[msg.sender][_lockupDuration]) {
            stakersPlan[_lockupDuration] = stakersPlan[_lockupDuration] + 1;
            totalStakers = totalStakers + 1;
        }

        //updating staking status

        hasStaked[msg.sender][_lockupDuration] = true;
        stakeOnPool[_lockupDuration] = stakeOnPool[_lockupDuration] + _amount;
        totalStaked = totalStaked + _amount;
        balanceOf[_msgSender()] += depAmount;
        orderIds[_msgSender()].push(latestOrderId);
        emit Deposit(
            _msgSender(),
            pool.lockupDuration,
            _amount,
            pool.returnPer
        );
    }

    function withdraw(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStaking: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStaking: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStaking: order already unstaked");
        require(
            block.timestamp >= orderInfo.endtime,
            "TokenStaking: stake locked until lock duration completion"
        );

        uint256 claimAvailable = pendingRewards(orderId);
        uint256 total = orderInfo.amount + claimAvailable;

        uint256 fees = (orderInfo.amount * withdrawFees) / 100;
        uint256 depAmount = total - fees;

        totalRewardEarn[_msgSender()] += claimAvailable;

        orderInfo.claimedReward += claimAvailable;
        balanceOf[_msgSender()] -= orderInfo.amount;
        orderInfo.claimed = true;

        require(
            token.transfer(address(_msgSender()), depAmount),
            "TokenStaking: token transfer via withdraw not succeeded"
        );
        require(
            token.transferFrom(_msgSender(), withdrawFeeReceiver, fees),
            "TokenStaking: token transferFrom via deposit not succeeded"
        );
        rewardOnPool[orderInfo.lockupDuration] =
            rewardOnPool[orderInfo.lockupDuration] +
            claimAvailable;
        emit Withdraw(_msgSender(), orderInfo.amount, claimAvailable, total);
    }

    function emergencyWithdraw(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStaking: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStaking: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStaking: order already unstaked");

        uint256 claimAvailable = pendingRewards(orderId);
        uint256 fees = (orderInfo.amount * emergencyWithdrawFees) / 100;
        orderInfo.amount -= fees;
        uint256 total = orderInfo.amount + claimAvailable;

        totalRewardEarn[_msgSender()] += claimAvailable;
        orderInfo.claimedReward += claimAvailable;
        balanceOf[_msgSender()] -= (orderInfo.amount + fees);

        orderInfo.claimed = true;

        require(
            token.transfer(address(_msgSender()), total),
            "TokenStaking: token transfer via emergency withdraw not succeeded"
        );
        require(
            token.transfer(feeReceiver, fees),
            "TokenStaking: token transfer via claim rewards not succeeded"
        );
        rewardOnPool[orderInfo.lockupDuration] =
            rewardOnPool[orderInfo.lockupDuration] +
            claimAvailable;
        emit WithdrawAll(_msgSender(), total);
    }

    function claimRewards(uint256 orderId) external nonReentrant {
        require(
            orderId <= latestOrderId,
            "TokenStaking: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        require(
            _msgSender() == orderInfo.beneficiary,
            "TokenStaking: caller is not the beneficiary"
        );
        require(!orderInfo.claimed, "TokenStaking: order already unstaked");
        require(
            block.timestamp >= orderInfo.lastClaimTime + _claimInterval,
            "TokenStaking: claim interval of 6 months not reached"
        );

        uint256 claimAvailable = pendingRewards(orderId);
        totalRewardEarn[_msgSender()] += claimAvailable;

        orderInfo.claimedReward += claimAvailable;
        orderInfo.lastClaimTime = block.timestamp; // New: Update the last claim time

        require(
            token.transfer(address(_msgSender()), claimAvailable),
            "TokenStaking: token transfer via claim rewards not succeeded"
        );

        rewardOnPool[orderInfo.lockupDuration] =
            rewardOnPool[orderInfo.lockupDuration] +
            claimAvailable;
        emit RewardClaimed(address(_msgSender()), claimAvailable);
    }

    function pendingRewards(uint256 orderId) public view returns (uint256) {
        require(
            orderId <= latestOrderId,
            "TokenStaking: INVALID orderId, orderId greater than latestOrderId"
        );

        OrderInfo storage orderInfo = orders[orderId];
        if (!orderInfo.claimed) {
            if (block.timestamp >= orderInfo.endtime) {
                uint256 APY = (orderInfo.amount * orderInfo.returnPer) / 100;
                uint256 reward = (APY * orderInfo.lockupDuration) / _days365;
                uint256 claimAvailable = reward - orderInfo.claimedReward;
                return claimAvailable;
            } else {
                uint256 stakeTime = block.timestamp - orderInfo.starttime;
                uint256 APY = (orderInfo.amount * orderInfo.returnPer) / 100;
                uint256 reward = (APY * stakeTime) / _days365;
                uint256 claimAvailableNow = reward - orderInfo.claimedReward;
                return claimAvailableNow;
            }
        } else {
            return 0;
        }
    }

    function setPlansApy(
        uint256 plan1Apy,
        uint256 plan2Apy,
        uint256 plan3Apy
    ) external onlyOwner {
        pooldata[1].returnPer = plan1Apy;
        pooldata[2].returnPer = plan2Apy;
        pooldata[3].returnPer = plan3Apy;
    }

    function setEmergencyWithdrawFees(uint256 _fee) external onlyOwner {
        emergencyWithdrawFees = _fee;
    }

    function setWithdrawFees(uint256 _fee) external onlyOwner {
        withdrawFees = _fee;
    }

    function setMinStake(uint256 _value) external onlyOwner {
        minStake = _value;
    }

    function setMaxStake(uint256 _value) external onlyOwner {
        maxStake = _value;
    }

    function setEmergencyFeeReceiver(address _address) external onlyOwner {
        feeReceiver = _address;
    }

    function setFeeReceiver(address _address) external onlyOwner {
        withdrawFeeReceiver = _address;
    }

    function toggleStaking(bool _start) external onlyOwner returns (bool) {
        started = _start;
        return true;
    }

    function investorOrderIds(address investor)
        external
        view
        returns (uint256[] memory ids)
    {
        uint256[] memory arr = orderIds[investor];
        return arr;
    }

    function withdrawERC20(address _tokenAddress) external onlyOwner {
        IERC20 withdrawtoken = IERC20(_tokenAddress);
        uint256 balance = withdrawtoken.balanceOf(address(this));
        require(
            withdrawtoken.transfer(msg.sender, balance),
            "Token transfer failed"
        );
    }

    function setClaimInterval(uint256 newInterval) external onlyOwner {
        require(newInterval > 0, "Claim interval must be greater than 0");
        _claimInterval = newInterval;
    }
}