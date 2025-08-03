// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

/**
 * @dev 与标准 ERC20 类似，但仅包含 transfer，供演示用
 */
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract WithdrawalQueue {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event QueueAdded(
        uint256 indexed queueId,
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 earliestWithdrawal
    );

    event Claimed(
        uint256 indexed queueId,
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 claimTime
    );

    event QueueUpdated(
        uint256 indexed queueId,
        uint256 oldAmount,
        uint256 newAmount,
        uint256 oldEarliestWithdrawal,
        uint256 newEarliestWithdrawal
    );

    event EmergencyWithdraw(address indexed token, address indexed to, uint256 amount);

    address public owner;

    /**
     * @dev 提款队列信息
     */
    struct QueueInfo {
        address user;
        address token;
        uint256 amount;
        uint256 earliestWithdrawal; // = requestTime + 14 days
        bool claimed;
        uint256 claimTime;
        uint256 requestTime;
    }

    uint256 public currentQueueId;

    // 队列ID => 队列信息
    mapping(uint256 => QueueInfo) public queues;

    // 统计每个 Token：
    //   totalAdded[token]   = 通过 addWithdrawalQueueBatch() 添加的总量
    //   totalClaimed[token] = 已经被 claim() 领取的总量
    mapping(address => uint256) public totalAdded;
    mapping(address => uint256) public totalClaimed;

    // 每个用户对应的所有队列 ID
    mapping(address => uint256[]) private userQueueIds;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function claim(uint256 claimId) external {
        QueueInfo storage qInfo = queues[claimId];

        require(qInfo.user == msg.sender, "Not queue user");
        require(block.timestamp >= qInfo.earliestWithdrawal, "Not time to withdraw");
        require(!qInfo.claimed, "Already withdrawn");

        qInfo.claimed = true;
        qInfo.claimTime = block.timestamp;

        totalClaimed[qInfo.token] += qInfo.amount;

        _safeTransfer(qInfo.token, msg.sender, qInfo.amount);

        emit Claimed(
            claimId,
            qInfo.user,
            qInfo.token,
            qInfo.amount,
            qInfo.claimTime
        );
    }

    /**
     * @dev 批量添加取款队列
     * @param users   用户地址数组
     * @param tokens  Token 地址数组
     * @param amounts 金额数组
     * @param times   请求发起时间数组
     *
     * 注意：最早可提款时间 = 请求时间 + 14 days
     */
    function addWithdrawalQueueBatch(
        address[] calldata users,
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata times
    ) external onlyOwner {
        require(
            users.length == tokens.length &&
            tokens.length == amounts.length &&
            amounts.length == times.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < users.length; i++) {
            currentQueueId++;

            uint256 requestTime = times[i];
            uint256 earliest = requestTime + 14 days;

            queues[currentQueueId] = QueueInfo({
                user: users[i],
                token: tokens[i],
                amount: amounts[i],
                earliestWithdrawal: earliest,
                claimed: false,
                claimTime: 0,
                requestTime: requestTime
            });

            totalAdded[tokens[i]] += amounts[i];
            userQueueIds[users[i]].push(currentQueueId);

            emit QueueAdded(
                currentQueueId,
                users[i],
                tokens[i],
                amounts[i],
                earliest
            );
        }
    }

    function emergencyWithdraw(address token, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot withdraw to zero address");
        
        _safeTransfer(token, to, amount);

        emit EmergencyWithdraw(token, to, amount);
    }

    function updateQueueInfo(
        uint256 claimId,
        uint256 newAmount,
        uint256 newEarliestWithdrawal
    ) external onlyOwner {
        QueueInfo storage qInfo = queues[claimId];
        require(!qInfo.claimed, "Already claimed. Cannot update claimed record.");

        uint256 oldAmount = qInfo.amount;
        uint256 oldEarliestWithdrawal = qInfo.earliestWithdrawal;

        // 更新金额
        if (newAmount != oldAmount) {
            if (newAmount > oldAmount) {
                totalAdded[qInfo.token] += (newAmount - oldAmount);
            } else {
                totalAdded[qInfo.token] -= (oldAmount - newAmount);
            }
            qInfo.amount = newAmount;
        }

        // 更新最早可领取时间
        qInfo.earliestWithdrawal = newEarliestWithdrawal;

        emit QueueUpdated(
            claimId,
            oldAmount,
            newAmount,
            oldEarliestWithdrawal,
            newEarliestWithdrawal
        );
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function getUserQueueIds(address user) external view returns (uint256[] memory) {
        return userQueueIds[user];
    }

    /**
     * @dev 获取某个 Token 剩余待领取的数量
     */
    function getUnclaimedAmount(address token) external view returns (uint256) {
        return totalAdded[token] - totalClaimed[token];
    }

    /**
     * @dev 获取某个队列的详细信息
     */
    function getQueueInfo(uint256 claimId)
        external
        view
        returns (
            address user,
            address token,
            uint256 amount,
            uint256 earliestWithdrawal,
            bool claimed,
            uint256 claimTime,
            uint256 requestTime
        )
    {
        QueueInfo storage qInfo = queues[claimId];
        return (
            qInfo.user,
            qInfo.token,
            qInfo.amount,
            qInfo.earliestWithdrawal,
            qInfo.claimed,
            qInfo.claimTime,
            qInfo.requestTime
        );
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        bool success = IERC20(token).transfer(to, amount);
        require(success, "SafeTransfer: transfer failed");
    }
}