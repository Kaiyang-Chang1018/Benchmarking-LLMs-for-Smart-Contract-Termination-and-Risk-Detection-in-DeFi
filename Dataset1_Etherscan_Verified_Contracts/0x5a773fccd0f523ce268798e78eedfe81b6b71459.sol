// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}


contract SwagAppTokenICO is Ownable{
    struct Stage {
        uint256 rate;                       // Tokens per ETH
        uint256 stageSale;                  // Maximum sale for this stage
        uint256 startTime;                  // Stage start time
        uint256 endTime;                    // Stage end time
        uint256 currentSaleInStage;         // Total Token sales in this stage
    }

    IERC20Metadata public token;
    address payable public treasury;    // Address where ETH will be forwarded
    Stage[] public stages;
    uint256 public tokenSale;           // Token sale for ICO
    uint256 public totalTokenSale;      // Total Token sales for successful in ICO
    uint256 public totalFunds;          // Total ETH raised across all stages
    bool public isFinalized;            // Whether the ICO is finalized
    bool public isClaimable;          // Whether tokens can be claimed
    mapping(address => uint256) public contributions; // Track ETH contributions per address

    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event Refunded(address indexed contributor, uint256 ethAmount);
    event Finalized();
    event FundsWithdrawn(uint256 amount);
    event StageUpdated(uint256 indexed stageIndex, uint256 rate, uint256 cap, uint256 startTime, uint256 endTime);
    event TreasuryUpdated(address indexed newTreasury);
    event StageDeleted(uint256 indexed stageIndex);
    event TokenSaleUpdated(uint256 newTokenSale);
    event TokenAddressUpdated(address newToken);

    modifier onlyDuringStage() {
        require(currentStageIndex() >= 0, "No active stage");
        _;
    }

    modifier onlyAfterICO() {
        require(isICOEnded(), "ICO not ended yet");
        _;
    }

    constructor(address _token, address payable _treasury, uint256 _tokenSale) Ownable() {
        require(_token != address(0), "Invalid token address");
        token = IERC20Metadata(_token);
        treasury = _treasury;
        tokenSale = _tokenSale;
    }

    // Fallback function to receive ETH and forward it
    receive() external payable {
        forwardFunds();
    }

    // Fallback function for other calls
    fallback() external payable {
        forwardFunds();
    }

    // Internal function to forward funds to the receiver
    function forwardFunds() internal {
        require(msg.value > 0, "No funds to forward");
        (bool success, ) = treasury.call{value: msg.value}("");
        require(success, "Transfer failed");
    }

    function updateTreasury(address payable _newTreasury) external onlyOwner {
        require(_newTreasury != address(0), "Invalid address");
        treasury = _newTreasury;
        emit TreasuryUpdated(_newTreasury);
    }

    function icoTokenName() public view returns (string memory){
        return token.name();
    }

    function icoTokenSymbol() public view returns (string memory){
        return token.symbol();
    }

    function icoTokenDecimal() public view returns(uint8){
        return token.decimals();
    }

    function icoTokenbalance(address account) public view returns(uint256){
        return token.balanceOf(account);
    }

    // Add a new stage
    function addStage(
        uint256 rate,
        uint256 stageSale,
        uint256 startTime,
        uint256 endTime
    ) external onlyOwner {
        require(startTime < endTime, "Invalid time range");
        if (stages.length > 0) {
            require(startTime >= stages[stages.length - 1].endTime, "Overlap with previous stage");
        }
        stages.push(Stage(rate, stageSale, startTime, endTime, 0));
    }

    // Update an existing stage
    function updateStage(
        uint256 stageIndex,
        uint256 newRate,
        uint256 newStageSale,
        uint256 newStartTime,
        uint256 newEndTime
    ) external onlyOwner {
        require(stageIndex < stages.length, "Stage does not exist");
        require(newStartTime < newEndTime, "Invalid time range");

        // Validate against other stages
        if (stageIndex > 0) {
            require(newStartTime >= stages[stageIndex - 1].endTime, "Overlap with previous stage");
        }
        if (stageIndex < stages.length - 1) {
            require(newEndTime <= stages[stageIndex + 1].startTime, "Overlap with next stage");
        }

        Stage storage stage = stages[stageIndex];
        require(newStageSale >= stage.currentSaleInStage, "New cap cannot be less than already raised funds");

        // Update stage parameters
        stage.rate = newRate;
        stage.stageSale = newStageSale;
        stage.startTime = newStartTime;
        stage.endTime = newEndTime;

        emit StageUpdated(stageIndex, newRate, newStageSale, newStartTime, newEndTime);
    }

    // Function to delete a pending or upcoming stage
    function deletePendingStage(uint256 stageIndex) external onlyOwner {
        require(stageIndex < stages.length, "Stage does not exist");

        Stage memory stage = stages[stageIndex];
        
        // Ensure the stage has not started yet
        require(
            block.timestamp < stage.startTime,
            "Cannot delete a stage that has already started"
        );

        // Remove the stage from the array by shifting elements
        for (uint256 i = stageIndex; i < stages.length - 1; i++) {
            stages[i] = stages[i + 1];
        }
        stages.pop(); // Remove the last element

        emit StageDeleted(stageIndex);
    }

    // Add deleteStage function
    function deleteStage(uint256 stageIndex) external onlyOwner {
        require(stageIndex < stages.length, "Stage does not exist");

        // Validate if the stage has no sales yet
        require(
            stages[stageIndex].currentSaleInStage == 0,
            "Cannot delete a stage with token sales"
        );

        // Remove the stage from the array by shifting elements
        for (uint256 i = stageIndex; i < stages.length - 1; i++) {
            stages[i] = stages[i + 1];
        }
        stages.pop(); // Remove the last element

        emit StageDeleted(stageIndex);
    }

    // Function to update the token sale amount
    function updateTokenSale(uint256 newTokenSale) external onlyOwner {
        require(newTokenSale > totalTokenSale, "New token sale must exceed total token sales so far");
        tokenSale = newTokenSale;

        emit TokenSaleUpdated(newTokenSale);
    }

    // Function to update the token address
    function updateTokenAddress(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid token address");
        require(newToken != address(token), "New token address must be different");
        token = IERC20Metadata(newToken);

        emit TokenAddressUpdated(newToken);
    }

    // Get the active stage index, or -1 if no active stage
    function currentStageIndex() public view returns (int256) {
        for (uint256 i = 0; i < stages.length; i++) {
            if (block.timestamp >= stages[i].startTime && block.timestamp <= stages[i].endTime) {
                return int256(i);
            }
        }
        return -1;
    }

    //Get number for stage
    function getNumberOfStages() public view returns(uint256){
        return stages.length;
    }

    function buyTokens(uint256 _tokens) external payable onlyDuringStage {
        int256 stageIndex = currentStageIndex();
        require(stageIndex >= 0, "No active stage");
        Stage storage stage = stages[uint256(stageIndex)];

        require(msg.value > 0, "ETH must be greater than zero");
        require(_tokens > 0, "Token must be greater than zero");
        require(msg.value >= (_tokens * stage.rate), "Buying ETH value mismatch");
        require(stage.currentSaleInStage + _tokens <= stage.stageSale, "Stage cap exceeded");
        
        uint256 tokenAmount = _tokens * (10 ** token.decimals());
        stage.currentSaleInStage += _tokens;
        totalTokenSale += _tokens;
        totalFunds += msg.value;
        contributions[msg.sender] += msg.value;

        require(token.balanceOf(address(this)) >= tokenAmount, "ICO: transfer amount exceeds balance");
        // Forward ETH to treasury address
        (bool success, ) = treasury.call{value: msg.value}("");
        require(success, "ETH transfer to treasury failed");
        token.transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function finalizeICO() external onlyOwner onlyAfterICO {
        require(!isFinalized, "Already finalized");
        if (totalTokenSale >= tokenSale) {
            isClaimable = true;
        }
        isFinalized = true;
        emit Finalized();
    }

    function withdrawRemainingTokens() external onlyOwner onlyAfterICO {
        require(tokenSale > totalTokenSale, "All tokes are sale");
        uint256 remaining = tokenSale - totalTokenSale;
        token.transfer(msg.sender, remaining * (10 ** token.decimals()));
    }

    function emergencyWithdraw(uint256 tokens) external onlyOwner {
        uint256 tokenAmount = tokens * (10 ** token.decimals());
        token.transfer(msg.sender, tokenAmount);
    }
    
    // Check if the ICO has ended
    function isICOEnded() public view returns (bool) {
        if (stages.length == 0) return false;
        return block.timestamp > stages[stages.length - 1].endTime;
    }

    // Calculate total token amount based on contributions and stage rates
    function calculateTokenAmount(uint256 contribution) internal view returns (uint256) {
        uint256 tokenAmount = 0;
        uint256 remainingContribution = contribution;

        for (uint256 i = 0; i < stages.length; i++) {
            if (remainingContribution == 0) break;

            Stage memory stage = stages[i];
            if (stage.currentSaleInStage >= stage.stageSale) continue; // Skip fully funded stages

            uint256 maxStageContribution = stage.stageSale - stage.currentSaleInStage;
            uint256 contributionForStage = remainingContribution > maxStageContribution
                ? maxStageContribution
                : remainingContribution;

            tokenAmount += contributionForStage * stage.rate;
            remainingContribution -= contributionForStage;
        }

        return tokenAmount;
    }
}