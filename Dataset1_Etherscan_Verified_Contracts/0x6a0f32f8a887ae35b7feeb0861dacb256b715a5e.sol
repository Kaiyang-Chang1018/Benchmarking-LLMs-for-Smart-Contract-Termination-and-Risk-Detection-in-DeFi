/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.18;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function decimals() external view returns (uint8);
}

contract SingleStaking {
    IERC20 public stakingToken = IERC20(0x8B68F1D0246320d5CaF8CD9828faaB28D66BA749);
    address public owner;
    uint public globalDebtRatio;
    uint public minimumStake = 1_000 * 1e18; // 1_000_000 * 1e18 Minimum stake of 1 million tokens

    // Events 
    event ActionEvent(address sender, string action, uint amount);

    // Errors
    error InsufficientBalance(uint256 requested, uint256 available);
    error NotStakingEnough(uint256 requested, uint256 expected);
    error NotEnoughStaked(uint256 requested, uint256 expected);
    error AlreadyStaked();
    error NotStaked();
    
    struct StakerInfo {
        uint256 stakedAmount;
        uint256 stakingStartTime;
        uint256 userDebt;
        uint256 userStartDebtRatio;
        uint256 totalClaimed;
        uint256 numberStakes;
        uint256 numberUnstakes;
        uint256 numberClaims;
    }

    struct ContractActionStruct { 
        string sender;
        string actionType;
        uint256 amount;
    }

    mapping(address => StakerInfo) public stakers;
    
    /**
     * Global Stats for this
     */
    uint256 public totalStaked = 0;
    uint256 public totalTimesStaked = 0;
    uint256 public totalTimesUnstaked = 0;
    uint256 public totalNumberOfClaims = 0;
    uint256 public totalPaidOut = 0;
    uint256 public totalPaidIn = 0;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setMinimumStake(uint newMinimumStake) external onlyOwner {
        minimumStake = newMinimumStake * 1e18;
    }

    // Update: Record global debt ratio per user at staking start
    function stake(uint256 amount) external {
        
        if(amount > stakingToken.balanceOf(msg.sender)) {
            revert InsufficientBalance({
                available: stakingToken.balanceOf(msg.sender),
                requested: amount
            });
        }

        uint256 amountWithDecimals = amount * 10 ** stakingToken.decimals();

        if(amountWithDecimals < minimumStake) {
            revert NotStakingEnough({
                requested: amount,
                expected: minimumStake
            });
        }

        if(stakers[msg.sender].stakedAmount > 0) {
            revert AlreadyStaked();
        }

        // Always update the userStartDebtRatio to the current globalDebtRatio when staking

        if (stakers[msg.sender].stakedAmount == 0) {
            stakers[msg.sender].stakingStartTime = block.timestamp;
            stakers[msg.sender].userStartDebtRatio = globalDebtRatio;
        }

        stakingToken.transferFrom(msg.sender, address(this), amount);
        totalStaked += amount;
        totalTimesStaked += 1;
        stakers[msg.sender].stakedAmount += amount;
        stakers[msg.sender].numberStakes += 1;

        emit ActionEvent(msg.sender, "stake", amount);
    }

    function unstake(uint amount) external {

        if(stakers[msg.sender].stakedAmount == 0) {
            revert NotStaked();
        }

        if(stakers[msg.sender].stakedAmount < amount) {
            revert NotEnoughStaked({
                requested: amount,
                expected: stakers[msg.sender].stakedAmount
            });
        }
        updateRewards(msg.sender);

        totalStaked -= amount;
        totalTimesUnstaked += 1;
        stakers[msg.sender].stakedAmount -= amount;
        stakers[msg.sender].numberUnstakes += 1;
        stakingToken.transfer(msg.sender, amount);

        emit ActionEvent(msg.sender, "stake", amount);
    }

    // Unstake but forego any rewards, this basically means
    // if for whatever reason you are unable to claim your rewards
    // you can still pull your staked amount out and not lose them 
    // as this is by far the best option for the user.
    function forego(uint amount) external {
        if(stakers[msg.sender].stakedAmount < amount) {
            revert NotEnoughStaked({
                requested: amount,
                expected: stakers[msg.sender].stakedAmount
            });
        }
        totalStaked -= amount;
        totalTimesUnstaked += 1;
        stakers[msg.sender].stakedAmount -= amount;
        stakers[msg.sender].numberUnstakes += 1;
        stakingToken.transfer(msg.sender, amount);

        // Reset user rewards and debt
        stakers[msg.sender].userDebt = 0;
        stakers[msg.sender].userStartDebtRatio = globalDebtRatio;
        stakers[msg.sender].totalClaimed = 0;
        stakers[msg.sender].numberClaims = 0;
    }

    function claimRewards() external {
        updateRewards(msg.sender);
    }

    fallback() external payable {
        if (totalStaked > 0) {
            // Scale msg.value
            uint256 additionalDebt = (msg.value * 1e18) / totalStaked; 
            globalDebtRatio += additionalDebt;
        }
    }

    receive() external payable {
        totalPaidIn += msg.value;
        emit ActionEvent(msg.sender, "paidin", totalPaidIn);
        if (totalStaked > 0) {
            // Scale msg.value to the same scale as totalStaked
            uint256 additionalDebt = (msg.value * 1e18) / totalStaked; 
            globalDebtRatio += additionalDebt;
        }
    }

    function updateRewards(address user) internal {
        uint owed = claimableRewards(user);
        if (owed > 0) {
            if (address(this).balance < owed) {
                revert InsufficientBalance({
                    requested: owed,
                    available: address(this).balance
                });
            }
            payable(user).transfer(owed);
            totalPaidOut += owed;
            totalNumberOfClaims += 1;

            stakers[user].totalClaimed += owed;
            stakers[user].numberClaims += 1;

            emit ActionEvent(msg.sender, "claim", owed);
        }
        stakers[user].userDebt = stakers[user].stakedAmount * globalDebtRatio / 1e18;
    }

    
    // Update: Calculate reward based on user debt ratio
    function claimableRewardsBase(address user) public view returns (uint) {
        uint256 userDebtAtStakeStart = stakers[user].userDebt;

        if(userDebtAtStakeStart <= 0) {
            userDebtAtStakeStart = stakers[user].userStartDebtRatio * stakers[user].stakedAmount / 1e18;
        }

        // If we have already claimed then we will have user debt that is calculated
        // this is what we should use
        if(stakers[user].userDebt > 0) {
            userDebtAtStakeStart = stakers[user].userDebt;
        }
        uint256 currentDebt = globalDebtRatio * stakers[user].stakedAmount / 1e18;
        if(currentDebt < userDebtAtStakeStart) {
            return 0; // If global ratio decreases
        }
        return currentDebt - userDebtAtStakeStart;
    }

    // Update: Calculate reward based on user debt ratio with unlocked percentage
    function claimableRewards(address user) public view returns (uint) {
        uint256 baseOwed = claimableRewardsBase(user);
        uint256 unlockedPercentage = calculateUnlockedPercentage(user);
        return baseOwed * unlockedPercentage / 100;
    }

    function calculateUnlockedPercentage(address user) public view returns (uint256) {
        if (stakers[user].stakedAmount == 0) {
            return 0;
        }
        return 100;
    }

    function poolPercentage(address user) public view returns (uint256) {
        if (totalStaked == 0) return 0;
        return (stakers[user].stakedAmount * 1e18) / totalStaked; // Multiplied by 1e18 for precision
    }

    // Owner can withdraw ETH from the contract
    function withdrawETH() external onlyOwner {
        uint amount = address(this).balance;
        payable(owner).transfer(amount);
    }

    // Owner can withdraw ERC20 tokens from the contract
    function withdrawERC20() external onlyOwner {
        uint256 amount = stakingToken.balanceOf(address(this));
        stakingToken.transfer(owner, amount);
    }

    function setTokenAddress(address newTokenAddress) external onlyOwner {
        stakingToken = IERC20(newTokenAddress);
    }

    function getTotalStats() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return (totalStaked, totalTimesStaked, totalTimesUnstaked, totalNumberOfClaims, totalPaidOut, totalPaidIn);
    }
    
}