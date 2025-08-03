// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract VeronumPresale is Ownable {
    IERC20 public token;
    IERC20Metadata public tokenMetadata;
    AggregatorV3Interface public priceFeed;
    IERC20 public tokenUsdt;
    IERC20Metadata public tokenMetadataUsdt;
    IERC20 public tokenUsdc;
    IERC20Metadata public tokenMetadataUsdc;
    struct PayToken {
        uint256 id;
        IERC20 token;
    }
    mapping(uint256 => PayToken) public payTokens;
    address public paymentAddress;
    bool public presaleActive = true;
    uint256 public minPurchase = 5000;
    uint256 public totalSold = 0;
    uint256 public totalRaisedUsd = 0;
    uint256 public referralBonus = 5;
    uint256 public presaleStartTime = 1741426267;
    uint256 public stageDuration = 14 days;
    struct Stage {
        uint256 id;
        uint256 bonus;
        uint256 price;
    }
    mapping(uint256 => Stage) public stages;
    uint256 public maxStage = 8;
    uint256 currentStageId = 0;
    mapping(address => uint256) public purchasedTokens;
    mapping(address => uint256) public referredTokens;

    // constructor
    constructor(
        address _paymentAddress,
        address _tokenAddress,
        address _priceFeedAddress,
        address _tokenUsdt,
        address _tokenUsdc
    ) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
        tokenMetadata = IERC20Metadata(_tokenAddress);
        paymentAddress = _paymentAddress;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);

        // paytokens
        payTokens[1] = PayToken(1, IERC20(_tokenUsdt)); //usdt
        payTokens[2] = PayToken(2, IERC20(_tokenUsdc)); //usdc

        // stage data
        stages[1] = Stage(1, 35, 20000000000000000); //stage 1
        stages[2] = Stage(2, 30, 25000000000000000); //stage 2
        stages[3] = Stage(3, 25, 30000000000000000); //stage 3
        stages[4] = Stage(4, 20, 35000000000000000); //stage 4
        stages[5] = Stage(5, 15, 40000000000000000); //stage 5
        stages[6] = Stage(6, 10, 45000000000000000); //stage 6
        stages[7] = Stage(7, 5, 52000000000000000); //stage 7
        stages[8] = Stage(8, 0, 62000000000000000); //stage 8
        currentStageId = 8;
    }

    // Get the latest ETH/USD price from the Aggregator
    function getEthToUsdPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // calculate USD to ETH price
    function getUsdToEthPrice() public view returns (uint256) {
        uint256 ethToUsdPrice = getEthToUsdPrice();
        uint8 decimals = priceFeed.decimals();
        return (10**(18 + decimals)) / ethToUsdPrice;
    }

    // buyToken funtion to buy tokens
    function buyToken(uint256 _amount) public payable {
        require(presaleActive, "Presale is not active!");
        require(_amount >= 0, "Please Enter token amount!");
        require(_amount >= minPurchase, "Please Enter minimum token!");
        uint256 _id = getCurrentStageIdActive();
        require(_id > 0, "Stage not available!");
        require(_id <= maxStage, "Stage not available!");
        uint256 _totalTokenAmount = _amount * 10**tokenMetadata.decimals();
        uint256 _bonus = stages[_id].bonus;
        uint256 _bonusAmount = (_amount * _bonus) / 100;
        _bonusAmount *= 10**tokenMetadata.decimals();
        _totalTokenAmount += _bonusAmount;

        //calculate price
        uint256 _price = stages[_id].price;
        uint256 _totalPayUsd = _amount * _price;
        uint256 _usdToEth = getUsdToEthPrice();
        uint256 _totalPayAmount = (_totalPayUsd * _usdToEth) / 1e18;
        require(msg.value >= _totalPayAmount, "Not enough payment!");

        //payment price transfer to payement address
        (bool paySent, ) = paymentAddress.call{value: msg.value}("");
        require(paySent, "Failed to transfer payment!");

        //purchased tokens transfer to buyer address
        require(
            token.transfer(msg.sender, _totalTokenAmount),
            "Failed to transfer token!"
        );

        //update data
        purchasedTokens[msg.sender] += _totalTokenAmount;
        totalSold += _totalTokenAmount;
        totalRaisedUsd += _totalPayUsd;
    }

    // buyWithPayToken funtion to buy tokens
    function buyWithPayToken(uint256 _payTokensId, uint256 _amount)
        public
        payable
    {
        require(presaleActive, "Presale is not active!");
        require(_amount >= 0, "Please Enter token amount!");
        require(_amount >= minPurchase, "Please Enter minimum token!");
        uint256 _id = getCurrentStageIdActive();
        require(_id > 0, "Stage not available!");
        require(_id <= maxStage, "Stage not available!");
        uint256 _totalTokenAmount = _amount * 10**tokenMetadata.decimals();
        uint256 _bonus = stages[_id].bonus;
        uint256 _bonusAmount = (_amount * _bonus) / 100;
        _bonusAmount *= 10**tokenMetadata.decimals();
        _totalTokenAmount += _bonusAmount;

        //calculate price & payment token transfer
        uint256 _price = stages[_id].price;
        uint256 _totalPayUsd = _amount * _price;
        IERC20 _payTokenAddress = payTokens[_payTokensId].token;
        uint256 _payTokenDecimals = IERC20Metadata(address(_payTokenAddress))
            .decimals();
        _totalPayUsd /= (10**(18 - _payTokenDecimals));
        require(
            _payTokenAddress.allowance(msg.sender, address(this)) >=
                _totalPayUsd,
            "Not enough allowance!"
        );
        require(
            _payTokenAddress.transferFrom(
                msg.sender,
                paymentAddress,
                _totalPayUsd
            ),
            "Failed to transfer payment token!"
        );

        //purchased tokens transfer to buyer address
        require(
            token.transfer(msg.sender, _totalTokenAmount),
            "Failed to transfer token!"
        );

        //update data
        purchasedTokens[msg.sender] += _totalTokenAmount;
        totalSold += _totalTokenAmount;
        totalRaisedUsd += _totalPayUsd;
    }

    // buyTokenWithReferral funtion to buy tokens
    function buyTokenWithReferral(uint256 _amount, address _referralAddress)
        public
        payable
    {
        require(presaleActive, "Presale is not active!");
        require(_amount >= 0, "Please Enter token amount!");
        require(_amount >= minPurchase, "Please Enter minimum token!");
        require(_referralAddress != address(0), "Referrer is zero address!");
        require(_referralAddress != msg.sender, "You can't refer yourself!");
        uint256 _id = getCurrentStageIdActive();
        require(_id > 0, "Stage not available!");
        require(_id <= maxStage, "Stage not available!");
        uint256 _totalTokenAmount = _amount * 10**tokenMetadata.decimals();
        uint256 _bonus = stages[_id].bonus;
        uint256 _bonusAmount = (_amount * _bonus) / 100;
        _bonusAmount *= 10**tokenMetadata.decimals();
        _totalTokenAmount += _bonusAmount;

        //calculate referral
        uint256 _referralTokenAmount = (_amount * referralBonus) / 100;
        _referralTokenAmount *= 10**tokenMetadata.decimals();

        //calculate price
        uint256 _price = stages[_id].price;
        uint256 _totalPayUsd = _amount * _price;
        uint256 _usdToEth = getUsdToEthPrice();
        uint256 _totalPayAmount = (_totalPayUsd * _usdToEth) / 1e18;
        require(msg.value >= _totalPayAmount, "Not enough payment!");

        //payment price transfer to payement address
        (bool paySent, ) = paymentAddress.call{value: msg.value}("");
        require(paySent, "Failed to transfer payment!");

        //purchased tokens transfer to buyer address, referral address
        require(
            token.transfer(msg.sender, _totalTokenAmount),
            "Failed to transfer token!"
        );
        require(
            token.transfer(_referralAddress, _referralTokenAmount),
            "Failed to transfer referral token!"
        );

        //update data
        purchasedTokens[msg.sender] += _totalTokenAmount;
        referredTokens[msg.sender] += _referralTokenAmount;
        totalSold += _totalTokenAmount;
        totalRaisedUsd += _totalPayUsd;
    }

    // buyWithReferralWithPayToken funtion to buy tokens
    function buyWithReferralWithPayToken(
        uint256 _payTokensId,
        uint256 _amount,
        address _referralAddress
    ) public payable {
        require(presaleActive, "Presale is not active!");
        require(_amount >= 0, "Please Enter token amount!");
        require(_amount >= minPurchase, "Please Enter minimum token!");
        require(_referralAddress != address(0), "Referrer is zero address!");
        require(_referralAddress != msg.sender, "You can't refer yourself!");
        uint256 _id = getCurrentStageIdActive();
        require(_id > 0, "Stage not available!");
        require(_id <= maxStage, "Stage not available!");
        uint256 _totalTokenAmount = _amount * 10**tokenMetadata.decimals();
        uint256 _bonus = stages[_id].bonus;
        uint256 _bonusAmount = (_amount * _bonus) / 100;
        _bonusAmount *= 10**tokenMetadata.decimals();
        _totalTokenAmount += _bonusAmount;

        //calculate referral
        uint256 _referralTokenAmount = (_amount * referralBonus) / 100;
        _referralTokenAmount *= 10**tokenMetadata.decimals();

        //calculate price & pay token transfer
        uint256 _price = stages[_id].price;
        uint256 _totalPayUsd = _amount * _price;
        IERC20 _payTokenAddress = payTokens[_payTokensId].token;
        uint256 _payTokenDecimals = IERC20Metadata(address(_payTokenAddress))
            .decimals();
        _totalPayUsd /= (10**(18 - _payTokenDecimals));
        require(
            _payTokenAddress.allowance(msg.sender, address(this)) >=
                _totalPayUsd,
            "Not enough allowance!"
        );
        require(
            _payTokenAddress.transferFrom(
                msg.sender,
                paymentAddress,
                _totalPayUsd
            ),
            "Failed to transfer pay token!"
        );

        //purchased tokens transfer to buyer address, referral address
        require(
            token.transfer(msg.sender, _totalTokenAmount),
            "Failed to transfer token!"
        );
        require(
            token.transfer(_referralAddress, _referralTokenAmount),
            "Failed to transfer referral token!"
        );

        //update data
        purchasedTokens[msg.sender] += _totalTokenAmount;
        referredTokens[msg.sender] += _referralTokenAmount;
        totalSold += _totalTokenAmount;
        totalRaisedUsd += _totalPayUsd;
    }

    // update token address
    function setToken(address _tokenAddress) public onlyOwner {
        require(_tokenAddress != address(0), "Token is zero address!");
        token = IERC20(_tokenAddress);
        tokenMetadata = IERC20Metadata(_tokenAddress);
    }

    // update price feed address
    function setPriceFeed(address _priceFeed) public onlyOwner {
        require(_priceFeed != address(0), "Token is zero address!");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // update paementAddress
    function setPaymentAddress(address _paymentAddress) public onlyOwner {
        paymentAddress = _paymentAddress;
    }

    // flip presaleActive as true/false
    function flipPresaleActive() public onlyOwner {
        presaleActive = !presaleActive;
    }

    // update referralBonus
    function setReferralBonus(uint256 _referralBonus) public onlyOwner {
        referralBonus = _referralBonus;
    }

    // update maximum stage
    function setMaxStage(uint256 _maxStage) public onlyOwner {
        maxStage = _maxStage;
    }

     // update minPurchase
    function setMinPurchase(uint256 _minPurchase) public onlyOwner {
        minPurchase = _minPurchase;
    }

    // update totalSold
    function setTotalSold(uint256 _totalSold) public onlyOwner {
        totalSold = _totalSold;
    }

    // update totalRaisedUsd
    function setTotalRaisedUsd(uint256 _totalRaisedUsd) public onlyOwner {
        totalRaisedUsd = _totalRaisedUsd;
    }

    // update presaleStartTime
    function setPresaleStartTime(uint256 _presaleStartTime) external onlyOwner {
        presaleStartTime = _presaleStartTime;
    }

    // update stageDuration
    function setStageDuration(uint256 _stageDuration) external onlyOwner {
        stageDuration = _stageDuration * 1 days;
    }

    //update pay token
    function setPayTokens(uint256 _id, IERC20 _tokenAddress) public onlyOwner {
        require(_id > 0, "Id greater than zero(0)!");
        payTokens[_id] = PayToken(_id, IERC20(_tokenAddress));
    }

    // adding stage info
    function addStage(uint256 _bonus, uint256 _price) public onlyOwner {
        uint256 _id = currentStageId + 1;
        require(_id <= maxStage, "Maximum stage excceds!");
        require(_bonus <= 100, "Bonus should be between 0 and 100");
        currentStageId += 1;
        stages[_id] = Stage(_id, _bonus, _price);
    }

    // update stage info
    function setStage(
        uint256 _id,
        uint256 _bonus,
        uint256 _price
    ) public onlyOwner {
        require(stages[_id].id == _id, "ID doesn't exist!");
        require(_bonus <= 100, "Bonus should be between 0 and 100");
        stages[_id] = Stage(_id, _bonus, _price);
    }

    // update stage bonus
    function setStageBonus(uint256 _id, uint256 _bonus) public onlyOwner {
        require(stages[_id].id == _id, "ID doesn't exist!");
        require(_bonus <= 100, "Bonus should be between 0 and 100");
        stages[_id].bonus = _bonus;
    }

    // update stage price
    function setStagePrice(uint256 _id, uint256 _price) public onlyOwner {
        require(stages[_id].id == _id, "ID doesn't exist!");
        stages[_id].price = _price;
    }

    // get current stage id active
    function getCurrentStageIdActive() public view returns (uint256) {
        require(presaleStartTime > 0, "Presale start time not set.");
        if (block.timestamp < presaleStartTime) {
            return 0;
        } else {
            // Calculate how many stage duration periods have passed
            uint256 daysSinceStart = (block.timestamp - presaleStartTime) /
                stageDuration;
            // stage 1 starts from day 0
            uint256 _currentStageId = daysSinceStart + 1;
            return _currentStageId;
        }
    }

    // withdrawFunds functions to get remaining funds transfer
    function withdrawFunds() public onlyOwner {
        (bool withdrawSent, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(withdrawSent, "Failed withdraw!");
    }

    // withdrawTokens functions to get remaining tokens transfer
    function withdrawTokens(address _to, uint256 _amount) public onlyOwner {
        uint256 _tokenBalance = token.balanceOf(address(this));
        require(_tokenBalance >= _amount, "Exceeds token balance!");
        bool success = token.transfer(_to, _amount);
        require(success, "Failed to transfer token!");
    }
}