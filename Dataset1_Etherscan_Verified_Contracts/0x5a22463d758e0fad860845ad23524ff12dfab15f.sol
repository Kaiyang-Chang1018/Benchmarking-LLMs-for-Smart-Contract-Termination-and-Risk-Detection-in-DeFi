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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

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

contract Presale is Ownable {
    IERC20 public mainToken;
    IERC20 public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    uint256 public tokenPerUsdPrice;
    uint8 public tokenDecimals;

    AggregatorV3Interface public priceFeed;

    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedOverall;
    uint256 public uniqueBuyers;
    address payable public fundReceiver;

    bool public presaleStatus;
    bool public isPresaleEnded;

    address[] public UsersAddresses;
    struct User {
        uint256 native_balance;
        uint256 usdt_balance;
    }
    mapping(address => User) public users;
    mapping(address => bool) public isExist;

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);

    constructor() {
        mainToken = IERC20(0x1c5440eD1cCE47cB83EA5533FC87a3f5237dd08E);
        fundReceiver = payable(msg.sender);
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        tokenDecimals = 18;
        tokenPerUsdPrice = 666666666666660000000000;
    }

    // update a presale price
    function updatePresalePrice(uint256 _tokenPerUsdPrice) public onlyOwner {
        tokenPerUsdPrice = _tokenPerUsdPrice;
    }

    // to get real time price of BNB
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time with BNB => for web3 use
    function buyToken() public payable {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        require(
            nativeToUSD(msg.value) >= 5 * 10**6,
            "buy more than minimum amount"
        );
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
            UsersAddresses.push(msg.sender);
        }
        fundReceiver.transfer(msg.value);

        uint256 numberOfTokens;
        numberOfTokens = nativeToToken(msg.value);
        require(
            numberOfTokens <= mainToken.balanceOf(address(this)),
            "not enough tokens in Smart Contract"
        );
        soldToken = soldToken + (numberOfTokens);
        amountRaised += msg.value;
        amountRaisedOverall += nativeToUSD(msg.value);
        users[msg.sender].native_balance += (msg.value);
        mainToken.transfer(msg.sender, numberOfTokens);
    }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        require(amount >= 5 * 10**6, "buy more than minimum amount");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
            UsersAddresses.push(msg.sender);
        }
        USDT.transferFrom(msg.sender, fundReceiver, amount);

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);
        require(
            numberOfTokens <= mainToken.balanceOf(address(this)),
            "not enough tokens in Smart Contract"
        );
        soldToken = soldToken + numberOfTokens;
        amountRaisedUSDT += amount;
        amountRaisedOverall += amount;
        users[msg.sender].usdt_balance += amount;
        mainToken.transfer(msg.sender, numberOfTokens);
    }

    function setPresaleStatus(bool _status) external onlyOwner {
        presaleStatus = _status;
    }

    function endPresale() external onlyOwner {
        require(!isPresaleEnded, "Already ended");
        isPresaleEnded = true;
    }

    // to check number of token for given BNB
    function nativeToToken(uint256 _amount) public view returns (uint256) {
        uint256 ethToUsd = (_amount * (getLatestPrice())) / (1 ether);
        uint256 numberOfTokens = (ethToUsd * tokenPerUsdPrice) / (1e8);
        return numberOfTokens;
    }

    // to check number of token for given BNB
    function nativeToUSD(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPrice())) / (1e20);
        return bnbToUsd;
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * tokenPerUsdPrice) / (1e6);
        return numberOfTokens;
    }

    // change tokens
    function updateToken(address _token) external onlyOwner {
        mainToken = IERC20(_token);
    }

    //change tokens for buy
    function updateStableTokens(IERC20 _USDT) external onlyOwner {
        USDT = IERC20(_USDT);
    }

    // to withdraw funds for liquidity
    function initiateTransfer(uint256 _value) external onlyOwner {
        fundReceiver.transfer(_value);
    }

    function totalUsersCount() external view returns (uint256) {
        return UsersAddresses.length;
    }

    // to withdraw funds for liquidity
    function changeFundReciever(address _addr) external onlyOwner {
        fundReceiver = payable(_addr);
    }

    // to withdraw funds for liquidity
    function updatePriceFeed(AggregatorV3Interface _priceFeed)
        external
        onlyOwner
    {
        priceFeed = _priceFeed;
    }

    // to withdraw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(fundReceiver, _value);
    }
}