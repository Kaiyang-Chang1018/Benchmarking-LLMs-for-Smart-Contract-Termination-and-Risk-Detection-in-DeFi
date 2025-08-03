// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Context Contract: Provides information about the execution context
contract Context {
    constructor () {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal pure returns (bytes memory) {
        return msg.data;
    }
}

// Ownable Contract: Provides basic ownership control
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ReentrancyGuard: Protects against reentrant calls
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// Main Presale Contract
contract Presale is Ownable, ReentrancyGuard {
    struct UserContribution {
        uint256 ethValue;
        uint256 tokens;
    }

    IERC20 public token;
    uint256 public totalTokens;
    uint256 public tokensSold;
    uint256 public pricePerToken;

    uint256 public  tokensPerEth;
    uint256 public startTime;
    uint256 public endTime;
    bool public presaleSuccessful = false;
    bool public presaleFinalized = false;

    mapping(address => UserContribution) public userContributions;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);
    event RefundClaimed(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event UnsoldTokensWithdrawn(address indexed owner, uint256 amount);
   

    constructor(
        address _tokenAddress,
        uint256 _totalTokens,
        uint256 _pricePerToken,
        uint256 _tokensPerETH,
        uint256 _startTime,
        uint256 _endTime
    ) {
        token = IERC20(_tokenAddress);
        totalTokens = _totalTokens;  
        pricePerToken = _pricePerToken;
        tokensPerEth = _tokensPerETH;
        startTime = _startTime;
        endTime = _endTime;
    }

    // Prevent direct ETH transfers
    receive() external payable {
        revert("Direct ETH transfers not allowed");
    }

    fallback() external payable {
        revert("Fallback function triggered, no direct ETH transfers allowed");
    }

    // Buy tokens during presale
    function buyTokens() external payable presaleActive nonReentrant {

        require(msg.value > 0, "You must send ETH to buy tokens");

        // Calculate the number of tokens to buy based on the ETH sent
        uint256 tokensToBuy = msg.value * tokensPerEth;

        // Ensure there are enough tokens left for sale
        require(tokensSold + tokensToBuy <= totalTokens, "Not enough tokens left to fulfill the purchase");

        // Update user's contribution and tokens sold
        userContributions[_msgSender()].ethValue += msg.value;
        userContributions[_msgSender()].tokens += tokensToBuy;

        tokensSold += tokensToBuy;
        emit TokensPurchased(_msgSender(), tokensToBuy);
        
    }



    // Finalize the presale
    function finalizePresale() external onlyOwner presaleNotFinalized {
        presaleFinalized = true;
        presaleSuccessful = tokensSold > 0;

       
    }

    // Claim tokens after successful presale
    function claimTokens() external nonReentrant {
        require(presaleFinalized && presaleSuccessful, "Presale not successful or not finalized");
        uint256 amount = userContributions[_msgSender()].tokens;
        require(amount > 0, "No tokens to claim");

        userContributions[_msgSender()].tokens = 0;

        require(token.transfer(_msgSender(), amount), "Token transfer failed");

        emit TokensClaimed(_msgSender(), amount);
    }



    // Withdraw funds after successful presale
    function withdrawFunds() external onlyOwner nonReentrant {
        // require(presaleFinalized && presaleSuccessful, "Presale not successful or not finalized");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner()).transfer(balance);

        emit FundsWithdrawn(owner(), balance);
    }


        // Extend the end time of the presale
    function extendEndTime(uint256 newEndTime) external onlyOwner presaleNotFinalized {
        require(newEndTime > endTime, "New end time must be greater than current end time");
        endTime = newEndTime;
        
    }

    function priceChange(uint256 _pricePertoken, uint _tokensPerEth) external onlyOwner  {
     
        pricePerToken = _pricePertoken;
        tokensPerEth = _tokensPerEth;
        
    }


      


    // Withdraw unsold tokens after presale
    function withdrawUnsoldTokens() external onlyOwner nonReentrant {
        require(presaleFinalized && presaleSuccessful, "Presale not successful or not finalized");
        uint256 unsoldTokens = totalTokens - tokensSold;
        require(unsoldTokens > 0, "No unsold tokens left");

        require(token.transfer(owner(), unsoldTokens), "Token transfer failed");

        emit UnsoldTokensWithdrawn(owner(), unsoldTokens);
    }

    modifier presaleActive() {

        require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale not active");
        _;
    }

    modifier presaleNotFinalized() {
        
        require(!presaleFinalized, "Presale already finalized");
        _;
    }
}

// IERC20 Interface for token transfers
interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function decimals() external  returns (uint8);


}