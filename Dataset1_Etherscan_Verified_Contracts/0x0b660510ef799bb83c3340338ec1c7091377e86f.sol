//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Staking {
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    uint256 private constant ACC_PRECISION = 1e12;
    uint256 public totalAmount;
    uint256 public rewardPerBlock;
    uint128 public accRewardPerShare;
    uint64 public lastRewardBlock;
    IERC20 public token;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public exec;
    bool internal entered;

    event File(bytes32 what, address data);
    event File(bytes32 what, uint256 data);
    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event Update(uint64 lastRewardBlock, uint256 totalAmount, uint256 accRewardPerShare);

    error InvalidFile();
    error Unauthorized();
    error NoReentering();

    constructor(address _token, uint256 _rewardPerBlock) {
        exec[msg.sender] = true;
        lastRewardBlock = uint64(block.number);
        rewardPerBlock = _rewardPerBlock;
        token = IERC20(_token);
    }

    modifier loop() {
        if (entered) revert NoReentering();
        entered = true;
        _;
        entered = false;
    }

    modifier auth() {
        if (!exec[msg.sender]) revert Unauthorized();
        _;
    }

    function file(bytes32 what, address data) external auth {
        if (what == "exec") {
            exec[data] = !exec[data];
        } else {
            revert InvalidFile();
        }
        emit File(what, data);
    }

    function file(bytes32 what, uint256 data) external auth {
        if (what == "rewardPerBlock") {
            rewardPerBlock = data;
        } else {
            revert InvalidFile();
        }
        emit File(what, data);
    }

    function pendingRewards(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastRewardBlock && totalAmount != 0) {
            uint256 blocks = block.number - lastRewardBlock;
            uint256 reward = blocks * rewardPerBlock;
            _accRewardPerShare = _accRewardPerShare + ((reward * ACC_PRECISION) / totalAmount);
        }
        pending = uint256(int256((user.amount * _accRewardPerShare) / ACC_PRECISION) - user.rewardDebt);
    }

    function update() public {
        if (block.number > lastRewardBlock) {
            if (totalAmount > 0) {
                uint256 blocks = block.number - lastRewardBlock;
                uint256 reward = blocks * rewardPerBlock;
                accRewardPerShare = accRewardPerShare + uint128((reward * ACC_PRECISION) / totalAmount);
            }
            lastRewardBlock = uint64(block.number);
        }
        emit Update(lastRewardBlock, totalAmount, accRewardPerShare);
    }

    function deposit(uint256 amount, address to) external loop {
        update();
        UserInfo storage user = userInfo[to];

        totalAmount += amount;
        user.amount = user.amount + amount;
        user.rewardDebt = user.rewardDebt + int256((amount * accRewardPerShare) / ACC_PRECISION);

        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom");

        emit Deposit(msg.sender, amount, to);
    }

    function withdraw(uint256 amount, address to) public loop {
        update();
        UserInfo storage user = userInfo[msg.sender];

        user.amount = user.amount - amount;
        user.rewardDebt = user.rewardDebt - int256((amount * accRewardPerShare) / ACC_PRECISION);
        totalAmount -= amount;

        token.transfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
    }

    function harvest(address to) public {
        update();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount * accRewardPerShare) / ACC_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);
        user.rewardDebt = accumulatedReward;
        if (_pendingReward != 0) {
            token.transfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }
    
    function withdrawAndHarvest(uint256 amount, address to) external {
        harvest(to);
        withdraw(amount, to);
    }
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external returns (bool);
}