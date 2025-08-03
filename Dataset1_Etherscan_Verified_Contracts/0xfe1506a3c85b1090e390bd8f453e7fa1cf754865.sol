// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MOXAIPremiumMembership {
    address public owner;
    uint256 public ethPrice;
    uint256 public tokenPrice;
    address public tokenAddress;
    mapping(address => uint256) public premiumExpiry;

    event PremiumPurchased(address indexed user, uint256 expiryDate);
    event EthPriceUpdated(uint256 newPrice);
    event TokenPriceUpdated(uint256 newPrice);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
      
    }

    function buyPremiumWithETH() external payable {
        require(msg.value == ethPrice, "Incorrect ETH amount");
        _extendPremium(msg.sender);
    }

    function buyPremiumWithMoxaiToken() external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), tokenPrice), "Token transfer failed");
        _extendPremium(msg.sender);
    }

    function _extendPremium(address user) internal {
        uint256 newExpiry = block.timestamp + 30 days;
        if (premiumExpiry[user] > block.timestamp) {
            newExpiry = premiumExpiry[user] + 30 days;
        }
        premiumExpiry[user] = newExpiry;
        emit PremiumPurchased(user, newExpiry);
    }

    function isPremium(address user) external view returns (bool) {
        return premiumExpiry[user] > block.timestamp;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawToken(uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient token balance");
        require(token.transfer(owner, amount), "Token transfer failed");
    }

    function setEthPrice(uint256 _ethPrice) external onlyOwner {
        ethPrice = _ethPrice;
        emit EthPriceUpdated(_ethPrice);
    }

    function setTokenPrice(uint256 _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
        emit TokenPriceUpdated(_tokenPrice);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
                tokenAddress = _tokenAddress;
    }
}