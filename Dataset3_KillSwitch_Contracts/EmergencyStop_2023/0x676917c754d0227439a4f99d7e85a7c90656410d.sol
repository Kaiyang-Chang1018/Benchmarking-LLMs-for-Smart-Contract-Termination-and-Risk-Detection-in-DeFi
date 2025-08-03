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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "src/interfaces/IChainLinkPriceFeed.sol";

contract GarbageSale is Pausable, Ownable {
    struct User {
        uint256 ethSpent;
        uint256 tokensPurchased;
    }

    IChainLinkPriceFeed public immutable priceFeed;// Address of ChainLink ETH/USD price feed

    uint256 public saleLimit;// Total amount of tokens to be sold
    uint256 public tokenPrice;// Price for single token in USD
    uint256 public totalTokensSold;// Total amount of purchased tokens

    mapping(address => User) public users;// Stores the number of tokens purchased by each user and their claim status

    event TokensPurchased(
        address indexed user,
        uint256 indexed tokensAmount,
        uint256 indexed currentEthPrice
    );

    error ZeroPriceFeedAddress();
    error WrongOracleData();
    error TooLowValue();
    error PerWalletLimitExceeded(uint256 remainingLimit);
    error SaleLimitExceeded(uint256 remainingLimit);
    error NotEnoughEthOnContract();
    error EthSendingFailed();

    /*
        @notice Sets up contract while deploying
        @param _saleToken: Token address
        @param _oracle: ChainLink ETH/USD oracle address
        @param _usdPrice: USD price for single token
        @param _saleLimit: Total amount of tokens to be sold during sale
    **/
    constructor(
        address _priceFeed,
        uint256 _usdPrice,
        uint256 _saleLimit,
        address owner
    ) Ownable(owner) {
        if (_priceFeed == address(0)) revert ZeroPriceFeedAddress();

        priceFeed = IChainLinkPriceFeed(_priceFeed);
        saleLimit = _saleLimit * 1e18;

        tokenPrice = _usdPrice;
    }

    /// @notice Pausing sale
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpausing sale
    function unpause() external onlyOwner {
        _unpause();
    }

    /*
        @notice Function for receiving ether
        @dev amount of tokens will be calculated from received value
    **/
    receive() external payable {
        if (msg.value < 0.1 ether) revert TooLowValue();
        uint256 remainingLimit =  5 ether - users[msg.sender].ethSpent;
        if (remainingLimit < msg.value) revert PerWalletLimitExceeded(remainingLimit);

        (uint256 ethPrice, uint256 tokensAmount) = convertETHToTokensAmount(msg.value);

        if (tokensAmount + totalTokensSold > saleLimit) revert SaleLimitExceeded(saleLimit - totalTokensSold);

        totalTokensSold += tokensAmount;
        users[msg.sender].tokensPurchased += tokensAmount;
        users[msg.sender].ethSpent += msg.value;

        (bool success, ) = payable(owner()).call{ value: msg.value }("");
        if (!success) revert EthSendingFailed();

        emit TokensPurchased(msg.sender, ethPrice, tokensAmount);
    }

    /*
        @notice Function for converting eth amount to equal tokens amount
        @param _ethAmount: Amount of eth to calculate
        @return ethPrice: Current eth price in usdt
        @return tokensAmount: Amount of tokens
    **/
    function convertETHToTokensAmount(uint256 _ethAmount) public view returns (uint256 ethPrice, uint256 tokensAmount) {
        (uint80 roundID, int256 price, , uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        ethPrice = uint256(price) / 1e2;

        if (answeredInRound < roundID
            || updatedAt < block.timestamp - 3 hours
            || price < 0) revert WrongOracleData();
        tokensAmount = _ethAmount * uint256(price) / tokenPrice / 1e2;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IChainLinkPriceFeed {
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}