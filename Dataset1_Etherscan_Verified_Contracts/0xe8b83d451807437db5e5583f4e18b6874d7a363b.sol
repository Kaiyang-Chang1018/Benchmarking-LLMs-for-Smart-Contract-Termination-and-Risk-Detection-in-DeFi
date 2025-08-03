// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

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

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract TokenPreSale is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public usdtToken;
    AggregatorV3Interface public priceFeed;

    uint256 public tokenPriceInUSDT = 0.00030 ether; // $0.013 per token in USDT
    uint256 public totalSold;
    bool public saleActive = true;
    bool public claimEnabled = false; // New variable to control claim status

    mapping(address => uint256) public pendingTokens; // New mapping to store pending tokens for each buyer

    event Sell(address indexed sender, uint256 totalValue);
    event Withdraw(address indexed owner, uint256 amount);
    event SaleStatusChanged(bool newStatus);
    event ClaimStatusChanged(bool newStatus); // New event for claim status change
    event TokenPriceUpdated(uint256 newPrice);
    event TokensForSaleUpdated(uint256 newTokensForSale);
    event TokensClaimed(address indexed user, uint256 amount); // New event for token claim

    constructor(
        address _tokenAddress,
        address _usdtAddress,
        address _priceFeedAddress
    ) {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_usdtAddress != address(0), "Invalid USDT token address");
        require(_priceFeedAddress != address(0), "Invalid price feed address");

        token = IERC20(_tokenAddress);
        usdtToken = IERC20(_usdtAddress);
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    receive() external payable {
        buyTokens();
    }

    function getLatestETHPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price).mul(1e10); // Convert 8 decimals to 18 decimals
    }

    function getTokenPriceInETH() public view returns (uint256) {
        uint256 ethPriceInUSD = getLatestETHPrice();
        return tokenPriceInUSDT.mul(1e18).div(ethPriceInUSD);
    }

    function buyTokens() public payable {
        require(saleActive, "Token sale is not active");
        uint256 ethAmount = msg.value;

        uint256 tokenPriceInETH = getTokenPriceInETH();
        uint256 tokenAmount = ethAmount.mul(1e18).div(tokenPriceInETH);

        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in the contract");

        totalSold = totalSold.add(tokenAmount);
        pendingTokens[msg.sender] = pendingTokens[msg.sender].add(tokenAmount); // Accumulate tokens to user's pending balance

        emit Sell(msg.sender, tokenAmount);
    }

    function buyWithUSDT(uint256 usdtAmount) public {
        require(saleActive, "Token sale is not active");

        uint256 tokenAmount = usdtAmount.mul(1e18).div(tokenPriceInUSDT);

        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in the contract");
        require(usdtToken.allowance(msg.sender, address(this)) >= usdtAmount, "USDT allowance too low");
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");

        totalSold = totalSold.add(tokenAmount);
        pendingTokens[msg.sender] = pendingTokens[msg.sender].add(tokenAmount); // Accumulate tokens to user's pending balance

        emit Sell(msg.sender, tokenAmount);
    }

    // New claim function
    function claimTokens() public {
        require(claimEnabled, "Claiming is not enabled");
        uint256 amountToClaim = pendingTokens[msg.sender];
        require(amountToClaim > 0, "No tokens to claim");

        pendingTokens[msg.sender] = 0; // Reset the pending balance to zero
        require(token.transfer(msg.sender, amountToClaim), "Token transfer failed");

        emit TokensClaimed(msg.sender, amountToClaim);
    }

    // Function to enable or disable claim by the owner
    function setClaimEnabled(bool _enabled) external onlyOwner {
        claimEnabled = _enabled;
        emit ClaimStatusChanged(_enabled);
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        payable(msg.sender).transfer(contractBalance);
        emit Withdraw(msg.sender, contractBalance);
    }

    function withdrawUSDT() public onlyOwner {
        uint256 contractUSDTBalance = usdtToken.balanceOf(address(this));
        require(contractUSDTBalance > 0, "No USDT to withdraw");
        require(usdtToken.transfer(msg.sender, contractUSDTBalance), "USDT transfer failed");
        emit Withdraw(msg.sender, contractUSDTBalance);
    }

    function setSaleStatus(bool _status) external onlyOwner {
        saleActive = _status;
    }

    function endSale() public onlyOwner {
        uint256 remainingTokens = token.balanceOf(address(this));
        require(token.transfer(msg.sender, remainingTokens), "Token transfer failed");
        saleActive = false;
    }

    function updateTokenPriceInUSDT(uint256 _tokenPriceInUSDT) external onlyOwner {
        tokenPriceInUSDT = _tokenPriceInUSDT;
        emit TokenPriceUpdated(_tokenPriceInUSDT);
    }

    function emergencyWithdrawTokens() external onlyOwner {
        uint256 remainingTokens = token.balanceOf(address(this));
        require(token.transfer(msg.sender, remainingTokens), "Token transfer failed");
    }
}