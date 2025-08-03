/**
 *Submitted for verification at Etherscan.io on 2024-05-09
*/

/**
 *Submitted for verification at Etherscan.io on 2024-02-22
 */

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.18;

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
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
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

contract QGCPresale is Ownable {
    IERC20 public mainToken;
    AggregatorV3Interface public priceFeed;

    struct Phase {
        uint256 tokensToSell;
        uint256 totalSoldTokens;
        uint256 tokenPerETH;
    }
    mapping(uint256 => Phase) public phases;

    // Stats
    uint256 public totalStages;
    uint256 public currentStage;
    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public uniqueBuyers;

    uint256[] public tokenPerETH = [
        100000000000000000000000000,
        20000000000000000000000000
    ];
    uint256[] public tokensToSell = [
        1250000000000000000000000000,
        1250000000000000000000000000
    ];

    address payable public fundReceiver;

    bool public presaleStatus;
    bool public isPresaleEnded;
    uint256 public claimStartTime;

    address[] public UsersAddresses;
    struct User {
        uint256 invested_eth;
        uint256 purchased_tokens;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isExist;

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address indexed _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);

    constructor(IERC20 _token, address _fundReceiver) {
        mainToken = _token;
        fundReceiver = payable(_fundReceiver);
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        for (uint256 i = 0; i < tokensToSell.length; i++) {
            phases[i].tokensToSell = tokensToSell[i];
            phases[i].tokenPerETH = tokenPerETH[i];
        }
        totalStages = tokensToSell.length;
    }

    // update a presale
    function updatePresale(
        uint256 _phaseId,
        uint256 _tokensToSell,
        uint256 _tokenPerETH
    ) public onlyOwner {
        require(phases[_phaseId].tokensToSell > 0, "presale don't exist");
        phases[_phaseId].tokensToSell = _tokensToSell;
        phases[_phaseId].tokenPerETH = _tokenPerETH;
    }

    // to get real time price of Eth
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time with Eth => for web3 use
    function buyToken() public payable {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            uniqueBuyers++;
            UsersAddresses.push(msg.sender);
        }
        fundReceiver.transfer(msg.value);

        uint256 numberOfTokens;
        numberOfTokens = EthToToken(msg.value, currentStage);
        require(
            phases[currentStage].totalSoldTokens + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        soldToken = soldToken + (numberOfTokens);
        amountRaised = amountRaised + (msg.value);
        mainToken.transfer(msg.sender, numberOfTokens);
        users[msg.sender].invested_eth =
            users[msg.sender].invested_eth +
            (msg.value);
        users[msg.sender].purchased_tokens =
            users[msg.sender].purchased_tokens +
            (numberOfTokens);
        phases[currentStage].totalSoldTokens += numberOfTokens;
    }

    function getPhaseDetail(uint256 phaseInd)
        external
        view
        returns (
            uint256 tokenToSell,
            uint256 soldTokens,
            uint256 priceUsd
        )
    {
        Phase memory phase = phases[phaseInd];
        return (
            phase.tokensToSell,
            phase.totalSoldTokens,
            phase.tokenPerETH
        );
    }

    function setPresaleStatus(bool _status) external onlyOwner {
        presaleStatus = _status;
    }

    function endPresale() external onlyOwner {
        isPresaleEnded = true;
    }

    // to check number of token for given ETH
    function EthToToken(uint256 _amount, uint256 phaseId) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * phases[phaseId].tokenPerETH) / (1e18);
        return numberOfTokens;
    }

    // funtion is used to change the stage of presale
    function setCurrentStage(uint256 _stageNum) public onlyOwner {
        currentStage = _stageNum;
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
        token.transfer(msg.sender, _value);
    }
}