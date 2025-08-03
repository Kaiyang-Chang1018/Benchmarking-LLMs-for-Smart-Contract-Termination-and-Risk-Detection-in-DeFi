// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

interface IToken {
    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function decimals() external view returns (uint8);
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

contract TokenPresale is Ownable {
    IToken public token;
    IToken public USDT;
    AggregatorV3Interface public priceFeedeth;

    uint256 public tokenPrice;

    enum Rounds {
        Round1,
        Round2,
        Round3,
        Final
    }
    Rounds public currentRound;

    uint256 public totalTokensSold;
    uint256 public totalRaisedETH;
    uint256 public totalRaisedUSDT;

    uint256 public ETHRaised;
    uint256 public USDTRaised;

    uint256 public numberOfWalletsToDistribute;
    address[] public distributionWallets;

    uint256 public round1Bonus = 10; // 10% bonus
    uint256 public round2Bonus = 7; // 7% bonus
    uint256 public round3Bonus = 5; // 5% bonus
    uint256 public finalRoundBonus = 5; // Starting at 5%, decreases

    struct UserRoundData {
        uint256 tokensPurchased;
        uint256 bonusTokens;
        bool claimed;
    }

    mapping(address => mapping(Rounds => UserRoundData)) public userRoundData;
    mapping(Rounds => bool) public roundStatus;

    constructor(IToken _token) Ownable(msg.sender) {
        priceFeedeth = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        USDT = IToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        token = _token;
        tokenPrice = 35210000000000000000;
        currentRound = Rounds.Round1;
    }

    function getLatestPriceETH() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedeth.latestRoundData();
        return uint256(price);
    }

    // Buy tokens with ETH
    function buyWithETH() external payable {
        require(msg.value > 0, "Invalid amount");
        uint256 ETHAmount = msg.value;
        uint256 numberOfTokens = ethToToken(ETHAmount);
        uint256 tokensWithBonus = numberOfTokens + calculateBonus(numberOfTokens);

        uint256 totalTokensForSale = tokenForSale();
        require( totalTokensSold + tokensWithBonus <= totalTokensForSale, "Insufficient tokens in presale" );

        userRoundData[msg.sender][currentRound].tokensPurchased += numberOfTokens;
        userRoundData[msg.sender][currentRound].bonusTokens += calculateBonus(numberOfTokens);
        bool transferSuccess = token.transferFrom(owner(), address(this), tokensWithBonus);
        require(transferSuccess, "Presale Token transferFrom failed");

        totalTokensSold += tokensWithBonus;
        totalRaisedETH += ETHAmount;
        ETHRaised += ETHAmount;

        if (ETHRaised >= 1 ether) {
            distributeETH();
        }

        if(USDTRaised >= 1000 ether){
            distributeUSDT();
        }

    }

    // Buy tokens with USDT
    function buyWithUSDT(uint256 usdtAmount) external {
        require(usdtAmount > 0, "Invalid amount");
        uint256 numberOfTokens = usdtToToken(usdtAmount);
        uint256 tokensWithBonus = numberOfTokens +calculateBonus(numberOfTokens);

        uint256 totalTokensForSale = tokenForSale();
        require(totalTokensSold + tokensWithBonus <= totalTokensForSale,"Insufficient tokens in presale");

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        userRoundData[msg.sender][currentRound] .tokensPurchased += numberOfTokens;
        userRoundData[msg.sender][currentRound].bonusTokens += calculateBonus(numberOfTokens);

        bool transferSuccess = token.transferFrom(owner(), address(this), tokensWithBonus);
        require(transferSuccess, "Presale Token transferFrom failed");

        totalTokensSold += tokensWithBonus;
        totalRaisedUSDT += usdtAmount;
        USDTRaised += usdtAmount;
        if (ETHRaised >= 1 ether) {
            distributeETH();
        }

        if(USDTRaised >= 1000 ether){
            distributeUSDT();
        }
    }

    function updateUserRoundData(
        address user,
        uint256 tokensPurchased,
        uint256 round
    ) external onlyOwner {
        require(user != address(0), "Invalid user address");
        require(tokensPurchased > 0, "Amount greater than zero");

        UserRoundData storage userData = userRoundData[user][currentRound];

        userData.tokensPurchased = tokensPurchased;
        uint256 bonusTokens = calculate(tokensPurchased, round);
        userData.bonusTokens = bonusTokens;
    }

    // Claim purchased tokens during the airdrop phase
    function claimTokens(Rounds _round) external {
        require(roundStatus[_round] == true, "Round not ended yet");

        UserRoundData storage userData = userRoundData[msg.sender][_round];
        require(!userData.claimed, "Already claimed for this round");
        require(
            userData.tokensPurchased > 0,
            "No tokens to claim for this round"
        );

        uint256 claimableTokens = userData.tokensPurchased +
            userData.bonusTokens;
        userData.claimed = true;

        require(
            token.transfer(msg.sender, claimableTokens),
            "Token transfer failed"
        );
    }

    // Calculate bonus based on the current round
    function calculateBonus(uint256 tokens) internal view returns (uint256) {
        if (currentRound == Rounds.Round1) {
            return (tokens * round1Bonus) / 100;
        } else if (currentRound == Rounds.Round2) {
            return (tokens * round2Bonus) / 100;
        } else if (currentRound == Rounds.Round3) {
            return (tokens * round3Bonus) / 100;
        } else if (currentRound == Rounds.Final) {
            uint256 dynamicBonus = (finalRoundBonus *
                (tokenForSale() - totalTokensSold)) / tokenForSale();
            return (tokens * dynamicBonus) / 100;
        } else {
            return 0;
        }
    }

    function calculate(uint256 tokens, uint256 round)
        internal
        view
        returns (uint256)
    {
        if (round == 1) {
            return (tokens * round1Bonus) / 100;
        } else if (round == 2) {
            return (tokens * round2Bonus) / 100;
        } else if (round == 3) {
            return (tokens * round3Bonus) / 100;
        } else if (round == 4) {
            uint256 dynamicBonus = (finalRoundBonus *
                (tokenForSale() - totalTokensSold)) / tokenForSale();
            return (tokens * dynamicBonus) / 100;
        } else {
            return 0;
        }
    }

    function usdtToToken(uint256 _amount) public view returns (uint256) {
         uint8 usdtDecimals = IToken(address(USDT)).decimals();
        uint256 usdtAmountInWei = _amount * (10**(18 - usdtDecimals));

        uint256 totalTokens = (usdtAmountInWei * tokenPrice) / (1 ether);
        uint256 tokens = (totalTokens * (10**token.decimals())) / (1 ether);

        return tokens;
    }

    function ethToToken(uint256 _amount) public view returns (uint256) {
        uint256 ethToUsd = (_amount * getLatestPriceETH()) / (1 ether);
        uint256 numberOfTokens = (ethToUsd * tokenPrice) / 1 ether;
        uint256 tokens = (numberOfTokens * (10**token.decimals())) / 1e8;
        return tokens;
    }

    function getTotalInUSDT() public view returns (uint256) {
        uint256 ethToUsdT = (totalRaisedETH * getLatestPriceETH()) / 1e8;

        uint256 totalRaisedInUSDT = ethToUsdT + totalRaisedUSDT;

        return totalRaisedInUSDT;
    }

    function distributeUSDT() internal {
        require(
            numberOfWalletsToDistribute > 0,
            "Wallets distribution not set"
        );

        uint256 amountPerWallet = USDTRaised / numberOfWalletsToDistribute;

        for (uint256 i = 0; i < numberOfWalletsToDistribute; i++) {
            USDT.transfer(distributionWallets[i], amountPerWallet);
        }

        USDTRaised = 0;
    }

    function distributeETH() internal {
        require(
            numberOfWalletsToDistribute > 0,
            "Wallets distribution not set"
        );

        uint256 amountPerWallet = ETHRaised / numberOfWalletsToDistribute;

        for (uint256 i = 0; i < numberOfWalletsToDistribute; i++) {
            payable(distributionWallets[i]).transfer(amountPerWallet);
        }

        ETHRaised = 0;
    }

    function tokenForSale() public view returns (uint256) {
        return token.allowance(owner(), address(this));
    }

    function setDistributionWallets(address[] memory wallets)
        external
        onlyOwner
    {
        require(wallets.length > 0, "Must provide at least one wallet");

        delete distributionWallets;

        for (uint256 i = 0; i < wallets.length; i++) {
            distributionWallets.push(wallets[i]);
        }

        numberOfWalletsToDistribute = wallets.length;
    }

    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        tokenPrice = _newPrice;
    }

    // End a presale round
    function endRound(Rounds _round) external onlyOwner {
        require(roundStatus[_round] == false, "Round already ended");
        roundStatus[_round] = true;
    }

    // Start a presale round
    function startRound(Rounds _round) external onlyOwner {
        require(roundStatus[_round] == true, "Round is still active");
        roundStatus[_round] = false;
    }

    // Withdraw raised funds (ETH) by owner
    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

     // Withdraw  USDT by owner
    function withdrawUSDT() external onlyOwner {
        uint256 contractBalance = USDT.balanceOf(address(this));
        require(contractBalance > 0, "No USDT balance to withdraw");
        require(
            USDT.transfer(owner(), contractBalance),
            "USDT withdrawal failed"
        );
    }

    // Emergency token recovery function
    function withdrawTokens(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
    {
        uint256 contractBalance = IToken(_tokenAddress).balanceOf(address(this));
        require(contractBalance >= _amount, "Insufficient token balance");
        require(
            IToken(_tokenAddress).transfer(owner(), _amount),
            "Token transfer failed"
        );
    }

      // Function to set the token address
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid address");
        token = IToken(_token);
    }

    // Function to set the USDT address
    function setUSDT(address _usdt) external onlyOwner {
        require(_usdt != address(0), "Invalid address");
        USDT = IToken(_usdt);
    }

    // Function to set the price feed address
    function setPriceFeed(address _priceFeed) external onlyOwner {
        require(_priceFeed != address(0), "Invalid address");
        priceFeedeth = AggregatorV3Interface(_priceFeed);
    }
}