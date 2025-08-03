/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.18;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function decimals() external view returns (uint8);
}

contract Staking {
    IERC20 public stakingToken = IERC20(0x84253d5333f308318aC55372112292cb11445269);
    address public owner;
    uint public globalDebtRatio;
    uint public minimumStake = 1_000 * 1e18; // 1_000_000 * 1e18 Minimum stake of 1 million tokens

    // Events 
    event Received(address sender, uint amount);

    // Errors
    error InsufficientBalance(uint256 requested, uint256 available);
    error NotStakingEnough(uint256 requested, uint256 expected);
    error NotEnoughStaked(uint256 requested, uint256 expected);
    
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
    
    ContractActionStruct[] public contractActions;
    uint256 public contractActionsLength = 0;

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

        updateRewards(msg.sender);

        // Always update the userStartDebtRatio to the current globalDebtRatio when staking
        stakers[msg.sender].userStartDebtRatio = globalDebtRatio;

        if (stakers[msg.sender].stakedAmount == 0) {
            stakers[msg.sender].stakingStartTime = block.timestamp;
        }
        stakingToken.transferFrom(msg.sender, address(this), amount);
        totalStaked += amount;
        totalTimesStaked += 1;
        stakers[msg.sender].stakedAmount += amount;
        stakers[msg.sender].numberStakes += 1;

        addContractAction(msg.sender, "stake", amount);
    }

    function unstake(uint amount) external {
        updateRewards(msg.sender);
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

        addContractAction(msg.sender, "unstake", amount);
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
        emit Received(msg.sender, msg.value);
        totalPaidIn += msg.value;
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

            addContractAction(user, "claim", owed);
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

    // Do all the contract action things 
    function addContractAction (address sender, string memory actionType, uint256 amount) internal {
        contractActions.push(ContractActionStruct({
            sender: getLast5Chars(sender),
            actionType: actionType,
            amount: amount
        }));

        contractActionsLength += 1;
    }

    function getRecentActions(uint256 amount, uint256 page) public view returns (ContractActionStruct[] memory) {
        // Default values
        if (amount == 0) {
            amount = 50;
        }
        if (page == 0) {
            page = 0;
        }

        uint256 start = page * amount;
        uint256 end = start + amount;

        if(contractActionsLength == 0) {
            return new ContractActionStruct[](0);
        }

        // Ensure we do not exceed the array bounds
        if (end > contractActionsLength) {
            end = contractActionsLength;
        }

        if (start > contractActionsLength) {
            start = contractActionsLength;
        }

        // Calculate the number of entries to return
        uint256 numberOfEntries = end - start;

        ContractActionStruct[] memory recentEntries = new ContractActionStruct[](numberOfEntries);

        for (uint256 i = 0; i < numberOfEntries; i++) {
            recentEntries[i] = contractActions[contractActionsLength - 1 - start - i];
        }

        return recentEntries;
    }

    // Function to get the last 5 characters of an address
    function getLast5Chars(address _addr) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(_addr);
        bytes memory hexBytes = "0123456789abcdef";

        bytes memory result = new bytes(10); // Last 5 characters (5 * 2 hex characters)
        for (uint256 i = 0; i < 5; i++) {
            result[i * 2] = hexBytes[uint8(addressBytes[20 - 5 + i] >> 4)];
            result[i * 2 + 1] = hexBytes[uint8(addressBytes[20 - 5 + i] & 0x0f)];
        }

        return string(result);
    }
    
}