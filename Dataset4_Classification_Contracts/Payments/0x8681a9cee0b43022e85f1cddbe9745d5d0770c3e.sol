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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IPinlinkOracle} from "src/oracles/IPinlinkOracle.sol";
import {ERC165, IERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

/// @title Centralized Oracle for PIN/USD price
/// @notice This contract is used to get the price of PIN in USD terms
/// @dev The price is updated regularly by the owner of the contract
contract CentralizedOracle is IPinlinkOracle, ERC165, Ownable {
    /// @notice The address of the token that this oracle is providing the price for
    address public immutable TOKEN;

    /// @notice TOKEN has 18 decimals
    uint256 public constant SCALE = 1e18;

    /// @notice The maximum time that can pass since the last price update
    uint256 public constant STALENESS_THRESHOLD = 3 days;

    /// @notice Last time the price was updated
    uint256 public lastPriceUpdateTimestamp;

    /// @notice The price of TOKEN in USD terms (18 decimals). [USD/TOKEN] = how many usd for 1 TOKEN
    /// @dev visibility is internal, so that the price is only accessed through the interface functions
    uint256 internal _tokenPriceInUsd;

    ////////////////////// ERRORS ///////////////////////
    error PinlinkCentralizedOracle__InvalidPrice();
    error PinlinkCentralizedOracle__NewPriceTooLow();
    error PinlinkCentralizedOracle__NewPriceTooHigh();

    /////////////////////////////////////////////////////
    constructor(address token_, uint256 initialPriceInUsd_) Ownable(msg.sender) {
        TOKEN = token_;

        // this is more a check for decimals than for the actual price.
        // Pin has 18 decimals, so if the price is less than 1e6, it is virtually 0
        if (initialPriceInUsd_ < 1e6) revert PinlinkCentralizedOracle__InvalidPrice();

        _tokenPriceInUsd = initialPriceInUsd_;
        lastPriceUpdateTimestamp = block.timestamp;

        emit PriceUpdated(initialPriceInUsd_);
    }

    /////////////// MUTATIVE FUNCTIONS //////////////////

    /// @notice Update the price of TOKEN in USD terms
    /// @dev The price should be expressed with 18 decimals.
    /// @dev Example. To set the TOKEN price to 0.88 USD, the input should be 880000000000000000
    function updateTokenPrice(uint256 usdPerToken) external onlyOwner {
        uint256 _currentPrice = _tokenPriceInUsd;

        // sanity checks to avoid too large deviations caused by bot/human errors
        if (usdPerToken < _currentPrice / 5) revert PinlinkCentralizedOracle__NewPriceTooLow();
        if (usdPerToken > _currentPrice * 5) revert PinlinkCentralizedOracle__NewPriceTooHigh();

        _tokenPriceInUsd = usdPerToken;
        lastPriceUpdateTimestamp = block.timestamp;

        emit PriceUpdated(usdPerToken);
    }

    ///////////////// VIEW FUNCTIONS ////////////////////

    /// @notice Convert a given amount of TOKEN to USD
    /// @dev The output will be with 18 decimals as well
    function convertToUsd(address token, uint256 tokenAmountIn) external view returns (uint256 usdAmount) {
        if (token != TOKEN) revert PinlinkCentralizedOracle__InvalidToken();
        if (tokenAmountIn == 0) return 0;

        if ((block.timestamp - lastPriceUpdateTimestamp) > STALENESS_THRESHOLD) {
            return 0;
        }

        // it is accepted that this conversion is rounded down for the purpose of this MVP
        // TOKEN[18] * price[USD/TOKEN][18] / PIN_DECIMALS[18] = USD[18]
        return (tokenAmountIn * _tokenPriceInUsd) / SCALE;
    }

    /// @notice Convert a given amount of USD to TOKEN
    /// @dev The output will be with 18 decimals as well
    /// @dev The caller is responsible for checking that the price is not 0.
    function convertFromUsd(address toToken, uint256 usdAmount) external view returns (uint256 tokenAmount) {
        if (toToken != TOKEN) revert PinlinkCentralizedOracle__InvalidToken();
        if (usdAmount == 0) return 0;

        if ((block.timestamp - lastPriceUpdateTimestamp) > STALENESS_THRESHOLD) {
            return 0;
        }

        // it is accepted that this conversion is rounded down for the purpose of this MVP
        // USD[18] * PIN_DECIMALS[18] / price[USD/TOKEN][18] = TOKEN[18]
        return (usdAmount * SCALE) / _tokenPriceInUsd;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IPinlinkOracle).interfaceId || super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {IERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

/// @title Pinlink Oracles Interface
/// @notice Interface for oracles to integrate with the PinlinkShop
interface IPinlinkOracle is IERC165 {
    ////////////////////// EVENTS ///////////////////////

    event PriceUpdated(uint256 indexed usdPerToken);

    ////////////////////// ERRORS ///////////////////////

    error PinlinkCentralizedOracle__InvalidToken();

    /// @notice Converts an amount of a token to USD (18 decimals)
    /// @dev If the price is stale, it should NOT revert, but return 0.
    function convertToUsd(address _token, uint256 _amount) external view returns (uint256);

    /// @notice Converts an amount of USD (18 decimals) to a token amount
    /// @dev If the price is stale, it should NOT revert, but return 0.
    function convertFromUsd(address _token, uint256 _usdAmount) external view returns (uint256);

    /// @notice Returns the timestamp of the last price update
    function lastPriceUpdateTimestamp() external view returns (uint256);

    /// @notice Returns the time in seconds before the price is considered stale
    function STALENESS_THRESHOLD() external view returns (uint256);
}