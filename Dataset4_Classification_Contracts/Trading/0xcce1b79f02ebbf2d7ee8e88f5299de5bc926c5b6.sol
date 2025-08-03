/**
 *Submitted for verification at Etherscan.io on 2024-11-29
*/

// SPDX-License-Identifier: MIT Licensed
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Presale is Ownable {
    IERC20 public mainToken;
    IERC20 public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 public tokensToSell;
    uint256[] public tokenPerUsdPrice;
    uint256 public totalStages;
    uint8 public tokenDecimals;

    AggregatorV3Interface public priceFeed;

    struct Phase {
        uint256 tokenPerUsdPrice;
    }

    uint256 public currentStage;
    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedUSDC;
    uint256 public totalRaised;
    uint256 public uniqueBuyers;
    address payable public fundReceiver;

    bool public isPresaleEnded;

    mapping(address => User) public users;
    mapping(uint256 => Phase) public phases;
    mapping(address => bool) public isExist;

    struct User {
        uint256 native_balance;
        uint256 usdt_balance;
        uint256 usdc_balance;
        uint256 claimedAmount;
        uint256 claimAbleAmount;
        uint256 purchasedToken;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);

    constructor(IERC20 _token, address _fundReceiver) {
        mainToken = _token;
        fundReceiver = payable(_fundReceiver);
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        tokenDecimals = mainToken.decimals();
        tokensToSell = 1_000_000_000 * 10**tokenDecimals;

        tokenPerUsdPrice = [
            100 * 10**tokenDecimals,     // Phase 1: 0.001 $
            250 * 10**tokenDecimals,     // Phase 2: 0.0025 $
            500 * 10**tokenDecimals,     // Phase 3: 0.005 $
            750 * 10**tokenDecimals,     // Phase 4: 0.0075 $
            1000 * 10**tokenDecimals,    // Phase 5: 0.01 $
            1250 * 10**tokenDecimals,    // Phase 6: 0.0125 $
            1500 * 10**tokenDecimals,    // Phase 7: 0.015 $
            1750 * 10**tokenDecimals,    // Phase 8: 0.0175 $
            2000 * 10**tokenDecimals,    // Phase 9: 0.02 $
            2250 * 10**tokenDecimals,    // Phase 10: 0.0225 $
            2500 * 10**tokenDecimals,    // Phase 11: 0.025 $
            2750 * 10**tokenDecimals     // Phase 12: 0.0275 $
        ];

        totalStages = tokenPerUsdPrice.length;

        for (uint256 i = 0; i < totalStages; i++) {
            phases[i].tokenPerUsdPrice = tokenPerUsdPrice[i];
        }
    }

    function updatePresale(uint256 _phaseId, uint256 _tokenPerUsdPrice) public onlyOwner {
        uint256 oldPrice = phases[_phaseId].tokenPerUsdPrice;
        phases[_phaseId].tokenPerUsdPrice = _tokenPerUsdPrice;
        emit UpdatePrice(oldPrice, _tokenPerUsdPrice);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10); // Adjust decimal precision for price feed
    }

    function buyToken() public payable {
        require(!isPresaleEnded, "Presale ended!");
        require(msg.value > 0, "Send ETH to buy tokens");

        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
        }

        uint256 usdAmount = (msg.value * getLatestPrice()) / 1e18; // Convert ETH to USD
        uint256 numberOfTokens = nativeToToken(msg.value, currentStage);

        require(soldToken + numberOfTokens <= tokensToSell, "Phase Limit Reached");
        soldToken += numberOfTokens;
        amountRaised += msg.value;
        totalRaised += usdAmount;

        users[msg.sender].native_balance += msg.value;
        users[msg.sender].claimAbleAmount += numberOfTokens;
        users[msg.sender].purchasedToken += numberOfTokens;

        fundReceiver.transfer(msg.value);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    function buyTokenUSDT(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");

        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
        }

        uint256 numberOfTokens = usdtToToken(amount, currentStage);
        require(soldToken + numberOfTokens <= tokensToSell, "Phase Limit Reached");
        soldToken += numberOfTokens;
        amountRaisedUSDT += amount;

        users[msg.sender].usdt_balance += amount;
        users[msg.sender].claimAbleAmount += numberOfTokens;
        users[msg.sender].purchasedToken += numberOfTokens;

        USDT.transferFrom(msg.sender, fundReceiver, amount);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    function buyTokenUSDC(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");

        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
        }

        uint256 numberOfTokens = usdcToToken(amount, currentStage);
        require(soldToken + numberOfTokens <= tokensToSell, "Phase Limit Reached");
        soldToken += numberOfTokens;
        amountRaisedUSDC += amount;

        users[msg.sender].usdc_balance += amount;
        users[msg.sender].claimAbleAmount += numberOfTokens;
        users[msg.sender].purchasedToken += numberOfTokens;

        USDC.transferFrom(msg.sender, fundReceiver, amount);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    function claimTokens() public {
        require(isPresaleEnded, "Presale is not ended yet");
        require(users[msg.sender].claimAbleAmount > 0, "No claimable tokens");

        uint256 amount = users[msg.sender].claimAbleAmount;
        users[msg.sender].claimedAmount += amount;
        users[msg.sender].claimAbleAmount = 0;

        mainToken.transfer(msg.sender, amount);

        emit ClaimToken(msg.sender, amount);
    }

    function endPresale() public onlyOwner {
        isPresaleEnded = true;
    }

    function getUserInfo(address user) public view returns (uint256 nativeBalance, uint256 usdtBalance, uint256 usdcBalance, uint256 claimAbleAmount, uint256 purchasedToken) {
        return (users[user].native_balance, users[user].usdt_balance, users[user].usdc_balance, users[user].claimAbleAmount, users[user].purchasedToken);
    }

    // Conversion Functions
    function nativeToToken(uint256 amount, uint256 stage) public view returns (uint256) {
        return (amount * phases[stage].tokenPerUsdPrice) / 1e6;
    }

    function usdtToToken(uint256 amount, uint256 stage) public view returns (uint256) {
        return (amount * phases[stage].tokenPerUsdPrice) / 1e6;
    }

    function usdcToToken(uint256 amount, uint256 stage) public view returns (uint256) {
        return (amount * phases[stage].tokenPerUsdPrice) / 1e6;
    }
}