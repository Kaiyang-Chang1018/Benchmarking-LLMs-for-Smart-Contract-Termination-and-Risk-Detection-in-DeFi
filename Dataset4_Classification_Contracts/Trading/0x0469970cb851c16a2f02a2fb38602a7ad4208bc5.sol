// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint256);
}

interface IPresaleETH {
    
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);


    event claimTimeUpdated(uint256 claimStartTime, uint256 timestamp);

    /// @notice Function can not be called now
    error InvalidTimeframe();

    /// @notice Function can not be called before end of presale
    error PresaleNotEnded();

    /// @notice Trying to buy 0 tokens
    error BuyAtLeastOneToken();

    /// @notice Passed amount is more than amount of tokens remaining for presale
    /// @param tokensRemains - amount of tokens remaining for presale
    error PresaleLimitExceeded(uint256 tokensRemains);

    /// @notice User is in blacklist
    error AddressBlacklisted();

    /// @notice If zero address was passed
    /// @param contractName - name indicator of the corresponding contract
    error ZeroAddress(string contractName);

    /// @notice Passed amount of ETH is not enough to buy requested amount of tokens
    /// @param sent - amount of ETH was sent
    /// @param expected - amount of ETH necessary to buy requested amount of tokens
    error NotEnoughETH(uint256 sent, uint256 expected);

    /// @notice Provided allowance is not enough to buy requested amount of tokens
    /// @param provided - amount of allowance provided to the contract
    /// @param expected - amount of USDT necessary to buy requested amount of tokens
    error NotEnoughAllowance(uint256 provided, uint256 expected);

    /// @notice User already claimed bought tokens
    error AlreadyClaimed();

    /// @notice No tokens were purchased by this user
    error NothingToClaim();
}
/// @title Presale contract for Chancer token
contract BYBPresale is IPresaleETH{
    
    /// @notice Address of token contract
    address public immutable saleToken;
    
    /// @notice Last stage index
    uint8 public constant MAX_STAGE_INDEX = 11;

    /// @notice Total amount of purchased tokens
    uint256 public totalTokensSold;

    /// @notice Timestamp when purchased tokens claim starts
    uint256 public claimStartTime;

    /// @notice Timestamp when presale starts
    uint256 public saleStartTime;

    /// @notice Timestamp when presale ends
    uint256 public saleEndTime;

    /// @notice Array representing cap values of totalTokensSold for each presale stage
    uint32[12] public limitPerStage;

    /// @notice Sale prices for each stage
    uint64[12] public pricePerStage;

    /// @notice Index of current stage
    uint8 public currentStage;

    /// @notice claim duration time 
    uint256 public claimDurationTime =  7 days;

    /// @notice TGE % 
    uint8 public tgePer = 15;

    /// @notice caim per 
    uint8 public claimPer = 15;

    /// @notice Owner Addess
    address public owner;

    /// @notice addInvestorOwner Addess
    address private addInvestorOwner;

    event TokensBought(
        address indexed user,
        uint256 amount,
        uint256 indexed referrerId,
        uint256 timestamp
    );

    /// @notice Stores the number of tokens purchased by each user that have not yet been claimed
    mapping(address => uint256) public purchasedTokens;
    mapping(address => uint256) public remainingPurchasedTokens;

    /// @notice Indicates whether the user already claimed or not
    mapping(address => uint256) public preClaimTime;
    mapping(address => bool) public hasTgeGenereted;

    /// @notice Checks that it is now possible to purchase passed amount tokens
    /// @param amount - the number of tokens to verify the possibility of purchase
    modifier verifyPurchase(uint256 amount) {
        if (block.timestamp < saleStartTime || block.timestamp >= saleEndTime) revert InvalidTimeframe();  
        if (amount == 0) revert BuyAtLeastOneToken();
        if (amount + totalTokensSold > limitPerStage[MAX_STAGE_INDEX])
            revert PresaleLimitExceeded(limitPerStage[MAX_STAGE_INDEX] - totalTokensSold);
        _;
    }

    /// @notice Creates the contract
    /// @param tokenAddress        - Address of presailing token
    /// @param investorOwner - addInvestorOwner of presailing token
    /// @param limitPerStages    - Array representing cap values of totalTokensSold for each presale stage
    /// @param pricePerStages    - Array of prices for each presale stage
    /// @param startTime    - Sale start time
    /// @param endTime      - Sale end time
    constructor(
        address tokenAddress,
        address investorOwner,
        uint256 startTime,
        uint256 endTime,
        uint32[12] memory limitPerStages,
        uint64[12] memory pricePerStages
    ) {
        if (tokenAddress == address(0)) revert ZeroAddress("Aggregator");
        owner = msg.sender;
        saleToken = tokenAddress;
        addInvestorOwner = investorOwner;
        limitPerStage = limitPerStages;
        pricePerStage = pricePerStages;
        saleStartTime = startTime;
        saleEndTime = endTime;
    }
    modifier onlyOwner() {
        require(owner == msg.sender , "Only owner access");
        _;
    }
    modifier onlyInvestorOwner() {
        require(addInvestorOwner == msg.sender , "Only investor owner access");
        _;
    }
    modifier invalidTimeframe(){
        if (block.timestamp < claimStartTime || claimStartTime == 0) revert InvalidTimeframe();
        _;
    }

    /// @notice To update the sale start and end times
    /// @param startTime - New sales start time
    /// @param endTime   - New sales end time
    function configureSaleTimeFrame(uint256 startTime, uint256 endTime) external onlyOwner {
        if (saleStartTime != startTime) saleStartTime = startTime;
        if (saleEndTime != endTime) saleEndTime = endTime;
    }

    /// @notice To set the claim start time
    /// @param startTime - claim start time
    /// @notice Function also makes sure that presale have enough sale token balance
    /// @dev Function can be executed only after the end of the presale, so totalTokensSold value here is final and will not change
    function configureClaim(uint256 startTime) external onlyOwner {
        if (block.timestamp < saleEndTime) revert  PresaleNotEnded();
        require(IERC20(saleToken).balanceOf(address(this)) >= totalTokensSold * 1e18, "Not enough tokens on contract");
        claimStartTime = startTime;
        emit claimTimeUpdated(startTime, block.timestamp);
    }

    function configureClaimDuration(uint8 claimDurationTimeInSeconds) external onlyOwner {
        claimDurationTime = claimDurationTimeInSeconds;
    }

    function configureClaimPercentage(uint8 claimPercentage) external onlyOwner {
        claimPer = claimPercentage;
    }

    function configureTGEPercentage(uint8 tgePercentage) external onlyOwner {
        tgePer = tgePercentage;
    }

    function configurePerLimit(uint8 index, uint32 limit) external onlyOwner {
        // limitPerStage[i] < limitPerStage[i + 1]
        require(index < MAX_STAGE_INDEX && index > 0 , "Not enough tokens on contract");
        limitPerStage[index] = limit;
    }


    /// @notice To buy into a presale using ETH with referrer
    /// @param investor - investor address
    /// @param amount - Amount of tokens to buy
    /// @param referrerId - id of the referrer
    function buyToken(
        address investor,
        uint256 amount,
        uint256 referrerId
    ) public verifyPurchase(amount) onlyInvestorOwner {
        totalTokensSold += amount;
        purchasedTokens[investor] += amount * 1e18;
        remainingPurchasedTokens[investor] += amount * 1e18;
        uint8 stageAfterPurchase = _getStageByTotalSoldAmount();
        if (stageAfterPurchase > currentStage) currentStage = stageAfterPurchase;
        emit TokensBought(investor, amount,  referrerId, block.timestamp);
    }

    function TgeGenerete() external invalidTimeframe {
        if (hasTgeGenereted[msg.sender]) revert AlreadyClaimed();
        uint256 amount = purchasedTokens[msg.sender];
        if (amount == 0) revert NothingToClaim();
        uint256 tgAmount = (amount * tgePer) / 100;
        remainingPurchasedTokens[msg.sender] = amount - tgAmount; 
        preClaimTime[msg.sender] = block.timestamp;
        hasTgeGenereted[msg.sender] = true;
        bool tgeTransferResult = IERC20(saleToken).transfer(msg.sender, tgAmount );
        if(!tgeTransferResult) revert NothingToClaim();
        emit TokensClaimed(msg.sender, tgAmount, block.timestamp);
    }
// preClaimTime
    /// @notice To claim tokens after claiming starts
    function claim() external invalidTimeframe {
        
        if (!hasTgeGenereted[msg.sender]) revert("TGE is not generate");
        if (preClaimTime[msg.sender] + claimDurationTime > block.timestamp) revert InvalidTimeframe();
        uint256 claimAmount = (remainingPurchasedTokens[msg.sender] * claimPer) / 100;
        if (claimAmount == 0) revert NothingToClaim();
        remainingPurchasedTokens[msg.sender] = remainingPurchasedTokens[msg.sender] - claimAmount;
        preClaimTime[msg.sender] = block.timestamp;
        bool claimTransferResult = IERC20(saleToken).transfer(msg.sender, claimAmount);
        if(!claimTransferResult) revert NothingToClaim();
        emit TokensClaimed(msg.sender, claimAmount, block.timestamp);
    }

    /// @notice Returns price for current stage
    function getCurrentPrice() external view returns (uint256) {
        return pricePerStage[currentStage];
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
    function configurationInvestorAddress(address newInvestorOwner) public virtual onlyOwner {
        require(newInvestorOwner != address(0), "Ownable: new owner is the zero address");
        addInvestorOwner = newInvestorOwner;
    }
    function modifyStageRate(uint8 stage,uint64 rate) public virtual onlyOwner {
        pricePerStage[stage] = rate;
    }

    /// @notice Returns amount of tokens sold on current stage
    function getSoldOnCurrentStage() external view returns (uint256) {
        return totalTokensSold - ((currentStage == 0) ? 0 : limitPerStage[currentStage - 1]);
    }

    /// @notice Returns presale last stage token amount limit
    function getTotalPresaleAmount() external view returns (uint256) {
        return limitPerStage[MAX_STAGE_INDEX];
    }

    /// @notice Returns total price of sold tokens
    function totalSoldPrice() external view returns (uint256) {
        return _calculatePriceInUSDTForConditions(totalTokensSold, 0, 0);
    }

    /// @notice Recursively calculate USDT cost for specified conditions
    /// @param amount           - Amount of tokens to calculate price
    /// @param currentStageIndex     - Starting stage to calculate price
    /// @param totalTokensSoldAmount  - Starting total token sold amount to calculate price
    function _calculatePriceInUSDTForConditions(
        uint256 amount,
        uint8 currentStageIndex,
        uint256 totalTokensSoldAmount
    ) internal view returns (uint256 cost) {
        if (totalTokensSoldAmount + amount <= limitPerStage[currentStageIndex]) {
            cost = amount * pricePerStage[currentStageIndex];
        } else {
            uint256 currentStageAmount = limitPerStage[currentStageIndex] - totalTokensSoldAmount;
            uint256 nextStageAmount = amount - currentStageAmount;
            cost =
                currentStageAmount *
                pricePerStage[currentStageIndex] +
                _calculatePriceInUSDTForConditions(nextStageAmount, currentStageIndex + 1, limitPerStage[currentStageIndex]);
        }

        return cost;
    }

    /// @notice Calculate current stage index from total tokens sold amount
    function _getStageByTotalSoldAmount() internal view returns (uint8) {
        uint8 stageIndex = MAX_STAGE_INDEX;
        uint256 totalTokensSold_ = totalTokensSold;
        while (stageIndex > 0) {
            if (limitPerStage[stageIndex - 1] <= totalTokensSold_) break;
            stageIndex -= 1;
        }
        return stageIndex;
    }
    function withdrawToken(address token_address,address _address, uint256 _amount) public onlyOwner {
        uint256 contractBalance = IERC20(token_address).balanceOf(address(this));
        require(contractBalance >= _amount," Insufficient UBI token balance.");
        IERC20(token_address).transfer(_address,_amount);
    }
}