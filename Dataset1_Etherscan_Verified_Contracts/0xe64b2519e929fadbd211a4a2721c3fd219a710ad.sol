/**
 ,  , _, ,_ ,  , ,  , , , ___,,  , ___,,  ,  _,    
 |_/ (_, |_)|\ | \_/ |\/|' |  |\ |' |  |\ | / _    
'| \  _)'|  |'\| / \ | `| _|_,|'\| _|_,|'\|'\_|`   
 '  `'   '  '  `'   `'  `'    '  `'    '  `  _|                                                '      
 */

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

contract KspnxMining is Ownable {
    uint256 public currentWeek;
    uint256 public timeStep;
    uint256 public claimDuration;
    uint256 public launchTime;
    uint256 public uniqueStakers;
    uint256 public totalStaked;
    uint256 public disributedReward;
    uint256 public calculationCounter;
    address[] public allUsers;
    bool public launched;

    IERC20 public KSPNX;

    struct StakeData {
        uint256 amount;
        uint256 checkpoint;
        uint256 startTime;
        uint256 investedWeek;
        uint256 claimedReward;
        bool isActive;
    }

    struct User {
        bool isExists;
        uint256 stakeCount;
        uint256 totalClaimedReward;
        uint256 totalStaked;
    }

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => StakeData)) public userStakes;
    mapping(uint256 => uint256) public weekStakedAmount;
    mapping(uint256 => uint256) public rewardMultiplier;
    mapping(uint256 => uint256) public calculationDivider;

    event STAKE(address Staker, uint256 amount);
    event CLAIM(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    constructor(address _TOKEN) {
        timeStep = 1 days;
        claimDuration = 7 days;
        rewardMultiplier[0] = 18;
        calculationDivider[0] = 10**9;
        KSPNX = IERC20(_TOKEN);
    }

    function updateWeekly() public {
        if (currentWeek != calculateWeek()) {
            currentWeek = calculateWeek();
        }
    }

    function calculateWeek() public view returns (uint256) {
        return (block.timestamp - launchTime) / (7 * timeStep);
    }

    function launch() external onlyOwner {
        require(!launched, "Already launched");
        launched = true;
        launchTime = block.timestamp;
    }

    function stake(uint256 _amount) public {
        require(launched, "Wait for launch");
        updateWeekly();
        User storage user = users[msg.sender];
        require(_amount >= 0, "Amount less than min amount");
        if (!user.isExists) {
            user.isExists = true;
            uniqueStakers++;
            allUsers.push(msg.sender);
        }
        KSPNX.transferFrom(msg.sender, address(this), _amount);
        StakeData storage userStake = userStakes[msg.sender][user.stakeCount];
        userStake.amount = _amount;
        userStake.startTime = block.timestamp;
        userStake.checkpoint = block.timestamp;
        userStake.investedWeek = currentWeek;
        userStake.isActive = true;
        user.stakeCount++;
        user.totalStaked += _amount;
        totalStaked += _amount;
        weekStakedAmount[currentWeek] += _amount;
        emit STAKE(msg.sender, _amount);
    }

    function claimReward(uint256 _index) public returns (uint256 _weeks) {
        updateWeekly();
        require(launched, "Wait for launch");
        User storage user = users[msg.sender];
        StakeData storage userStake = userStakes[msg.sender][_index];
        require(userStake.isActive, "This stake is not active");
        require(
            block.timestamp >= userStake.checkpoint + claimDuration,
            "Please wait for claimTime"
        );
        uint256 multiplier = (block.timestamp - userStake.checkpoint) /
            claimDuration;

        uint256 reward = calculateReward(msg.sender, _index);
        reward = reward * multiplier;
        disributedReward += reward;
        user.totalClaimedReward += reward;
        userStake.claimedReward += reward;
        bool sent = payable(msg.sender).send(reward);
        require(sent, "Failed to send Ether");
        userStake.checkpoint = block.timestamp;
        emit CLAIM(msg.sender, reward);
        _weeks = multiplier;
    }

    function calculateReward(address _user, uint256 _index)
        public
        view
        returns (uint256 reward)
    {
        StakeData storage userStake = userStakes[_user][_index];
        reward =
            (userStake.amount * rewardMultiplier[calculationCounter]) /
            calculationDivider[calculationCounter];
    }

    function withdraw(uint256 _index) public {
        updateWeekly();
        require(launched, "Wait for launch");
        StakeData storage userStake = userStakes[msg.sender][_index];
        require(userStake.isActive, "not active");
        userStake.isActive = false;
        KSPNX.transfer(msg.sender, userStake.amount);
        emit WITHDRAW(msg.sender, userStake.amount);
    }

    receive() external payable {}

    // to withdraw native funds
    function initiateTransfer(uint256 _value) external onlyOwner {
        bool sent = payable(msg.sender).send(_value);
        require(sent, "Failed to send Ether");
    }

    // to withdraw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }

    function setRewardMultiplier(
        uint256 _rewardMultiplier,
        uint256 _calculationDivider
    ) public onlyOwner {
        calculationCounter++;
        rewardMultiplier[calculationCounter] = _rewardMultiplier;
        calculationDivider[calculationCounter] = _calculationDivider;
    }

    function changeTokenAddress(IERC20 _token) public onlyOwner {
        KSPNX = _token;
    }
}