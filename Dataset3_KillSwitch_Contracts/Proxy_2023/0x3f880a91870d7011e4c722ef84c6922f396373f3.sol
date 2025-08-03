// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Claim {
    address public owner;
    address public treasuryContract;
    IERC20 public token;

    uint256 public startTime;
    uint256 public constant INITIAL_RELEASE_PERCENTAGE = 3000; 
    uint256 public constant MONTHLY_RELEASE_PERCENTAGE = 1167; 
    uint256 public constant ONE_MONTH = 30 days; 
    uint256 public constant AirdropForfeit = 14 days;

    struct Allocation {
        uint256 airdrop;
        uint256 presale;
        uint256 claimedAirdrop;
        uint256 claimedPresale;
        bool hasClaimedInitial;
    }

    mapping(address => Allocation) public allocations;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, address _treasuryContract, uint256 _startTime) {
        owner = msg.sender;
        token = IERC20(_token);
        treasuryContract = _treasuryContract;
        startTime = _startTime;
    }

    

    function getTotalAvailableForClaim(address userAddress, uint256 presaleAmount, uint256 airdropAmount) public view returns (uint256 totalAvailable) {
        Allocation storage userAllocation = allocations[userAddress];

        if (startTime > block.timestamp){
            return totalAvailable = 0;
        }
        
        uint256 monthsElapsed = (block.timestamp - startTime) / ONE_MONTH;
        uint256 availableAirdrop = 0;
        uint256 availablePresale = 0;

        bool hasClaimedInitial = userAllocation.hasClaimedInitial;
        uint256 userPresaleAmount = hasClaimedInitial ? userAllocation.presale : presaleAmount;
        uint256 userAirdropAmount = hasClaimedInitial ? userAllocation.airdrop : airdropAmount;

         if (!hasClaimedInitial && block.timestamp <= startTime + AirdropForfeit) {
            availableAirdrop = userAirdropAmount;
        }

        if (hasClaimedInitial) {
            uint256 totalClaimablePresale = userPresaleAmount * INITIAL_RELEASE_PERCENTAGE / 10000 
                + (monthsElapsed * MONTHLY_RELEASE_PERCENTAGE * userPresaleAmount / 10000);
            totalClaimablePresale = totalClaimablePresale > userPresaleAmount ? userPresaleAmount : totalClaimablePresale;
            availablePresale = totalClaimablePresale - userAllocation.claimedPresale;
        } else if (monthsElapsed > 0) {
            uint256 initialPresaleRelease = userPresaleAmount * INITIAL_RELEASE_PERCENTAGE / 10000;
            uint256 totalClaimablePresale = initialPresaleRelease 
                + (monthsElapsed * MONTHLY_RELEASE_PERCENTAGE * userPresaleAmount / 10000);
            totalClaimablePresale = totalClaimablePresale > userPresaleAmount ? userPresaleAmount : totalClaimablePresale;
            availablePresale = totalClaimablePresale;
        } else {
            availablePresale = userPresaleAmount * INITIAL_RELEASE_PERCENTAGE / 10000;
        }

        totalAvailable = availableAirdrop + availablePresale;
    }

    function claim(uint256 airdropAmount, uint256 presaleAmount) external {
        require(startTime != 0 && block.timestamp >= startTime, "Vesting has not started or start time not set");
        
        uint256 totalAvailable = getTotalAvailableForClaim(msg.sender, presaleAmount, airdropAmount);
        require(totalAvailable > 0, "No tokens available for claim");
        
        Allocation storage userAllocation = allocations[msg.sender];

        if (!userAllocation.hasClaimedInitial) {
            userAllocation.hasClaimedInitial = true;
            
            uint256 monthsElapsed = (block.timestamp - startTime) / ONE_MONTH;

            uint256 totalClaimablePresale = 0;
            if (monthsElapsed >= 1) {
                totalClaimablePresale = (presaleAmount * INITIAL_RELEASE_PERCENTAGE / 10000) 
                                        + ((monthsElapsed * MONTHLY_RELEASE_PERCENTAGE * presaleAmount) / 10000);
            } else {
                totalClaimablePresale = presaleAmount * INITIAL_RELEASE_PERCENTAGE / 10000;
            }
            totalClaimablePresale = totalClaimablePresale > presaleAmount ? presaleAmount : totalClaimablePresale;

            if (airdropAmount > 0) {
                uint256 totalInitialClaim = airdropAmount + totalClaimablePresale;
                require(totalInitialClaim <= token.balanceOf(address(this)), "Insufficient tokens in contract");
                token.transfer(msg.sender, totalInitialClaim);
                userAllocation.claimedAirdrop += airdropAmount;
                userAllocation.claimedPresale += totalClaimablePresale;
                userAllocation.airdrop += airdropAmount;
                userAllocation.presale += presaleAmount;
            }
            else {
                require(totalClaimablePresale <= token.balanceOf(address(this)), "Insufficient tokens in contract");
                token.transfer(msg.sender, totalClaimablePresale);
                userAllocation.claimedPresale += totalClaimablePresale;
                userAllocation.presale += presaleAmount;
                userAllocation.airdrop += airdropAmount;
            }
            
            
        } else {
            uint256 monthsElapsed = (block.timestamp - startTime) / ONE_MONTH;
            uint256 totalClaimablePresale = userAllocation.presale * INITIAL_RELEASE_PERCENTAGE / 10000 
                                            + (monthsElapsed * MONTHLY_RELEASE_PERCENTAGE * userAllocation.presale / 10000);
            totalClaimablePresale = totalClaimablePresale > userAllocation.presale ? userAllocation.presale : totalClaimablePresale;

            uint256 presaleToDistribute = totalClaimablePresale - userAllocation.claimedPresale;
            if (presaleToDistribute > 0) {
                require(presaleToDistribute <= token.balanceOf(address(this)), "Insufficient tokens in contract");
                token.transfer(msg.sender, presaleToDistribute);
                userAllocation.claimedPresale += presaleToDistribute;
            }
        }
    }

    function withdrawAllTokens() external onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");
        token.transfer(treasuryContract, amount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        uint256 contractBalance = token.balanceOf(address(this));
        require(amount <= contractBalance, "Insufficient balance in contract");

        token.transfer(treasuryContract, amount);
    }

    function getClaimedAirdropAmount(address userAddress) external view returns (uint256) {
        return allocations[userAddress].claimedAirdrop;
    }

    function getClaimedPresaleAmount(address userAddress) external view returns (uint256) {
        return allocations[userAddress].claimedPresale;
    }
}