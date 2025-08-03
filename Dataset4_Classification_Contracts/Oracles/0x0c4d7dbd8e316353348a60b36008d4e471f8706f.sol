// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
pragma solidity >=0.4.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title RFRM Oracle
 * @notice This contract provides an oracle for RFRM token prices in various currencies.
 * @dev Reform DAO
 */
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {
    UniswapV2OracleLibrary,
    FixedPoint
} from "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";

/**
 * @title IERC20
 * @notice Interface for ERC20 tokens
 */
interface IERC20 {
    function decimals() external view returns (uint8);
}

/**
 * @title SlidingWindowOracle
 * @notice An oracle contract that calculates the average price of an asset over a sliding time window.
 */
contract SlidingWindowOracle {
    using FixedPoint for *;

    struct Observation {
        uint256 timestamp;
        uint256 price0Cumulative;
        uint256 price1Cumulative;
    }

    // Pair contract address
    address public immutable pair;

    // The desired amount of time over which the moving average should be computed, e.g., 24 hours
    uint256 public immutable windowSize;

    // The number of observations stored for each pair, i.e., how many price observations are stored for the window.
    // As granularity increases from 1, more frequent updates are needed, but moving averages become more precise.
    uint8 public immutable granularity;

    // Time period
    uint256 public immutable periodSize;

    // Observations array
    Observation[] public pairObservations;

    // Event when price is updated.
    event PriceUpdated(uint256 timestamp);

    error InvalidGranularity();
    error InvalidWindowSize();
    error MissingHistoricalObservation();
    error ZeroAddress();

    /**
     * @dev Constructor to initialize the SlidingWindowOracle.
     * @param _windowSize The desired time window for computing the moving average.
     * @param _granularity The granularity of observations.
     * @param _pair The address of the Uniswap pair contract for the token.
     */
    constructor(uint256 _windowSize, uint8 _granularity, address _pair) {
        if (_granularity <= 1) revert InvalidGranularity();
        if ((periodSize = _windowSize / _granularity) * _granularity != _windowSize) revert InvalidWindowSize();
        windowSize = _windowSize;
        granularity = _granularity;
        pair = _pair;

        // Populate the array with empty observations
        for (uint256 i = 0; i < granularity; i++) {
            pairObservations.push();
        }
    }

    /**
     * @dev Update the oracle with the latest price observation.
     */
    function update() external {
        uint8 observationIndex = observationIndexOf(block.timestamp);
        Observation storage observation = pairObservations[observationIndex];

        // We only want to commit updates once per period (i.e., windowSize / granularity)
        uint256 timeElapsed = block.timestamp - observation.timestamp;
        if (timeElapsed > periodSize) {
            (uint256 price0Cumulative, uint256 price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(
                address(pair)
            );
            observation.timestamp = block.timestamp;
            observation.price0Cumulative = price0Cumulative;
            observation.price1Cumulative = price1Cumulative;
        }

        emit PriceUpdated(block.timestamp);
    }

    /**
     * @dev Get the index of the observation corresponding to a given timestamp.
     * @param timestamp The timestamp for which to find the observation index.
     * @return index The index of the observation in the pairObservations array.
     */
    function observationIndexOf(uint256 timestamp) public view returns (uint8 index) {
        uint256 epochPeriod = timestamp / periodSize;
        return uint8(epochPeriod % granularity);
    }

    /**
     * @dev Get all observations stored in the pairObservations array.
     * @return observations An array of observations.
     */
    function getAllObservations() public view returns (Observation[] memory) {
        return pairObservations;
    }

    /**
     * @dev Get the first observation in the sliding time window.
     * @return firstObservation The first observation in the window.
     */
    function getFirstObservationInWindow() public view returns (Observation memory firstObservation) {
        uint8 observationIndex = observationIndexOf(block.timestamp);
        uint8 firstObservationIndex = (observationIndex + 1) % granularity;
        firstObservation = pairObservations[firstObservationIndex];
    }

    /**
     * @dev Consult the oracle for the amount out corresponding to the input amount.
     * @param tokenIn The input token address.
     * @param amountIn The input amount.
     * @param tokenOut The output token address.
     * @return amountOut The computed amount out.
     */
    function consult(address tokenIn, uint256 amountIn, address tokenOut) public view returns (uint256 amountOut) {
        Observation memory firstObservation = getFirstObservationInWindow();

        uint256 timeElapsed = block.timestamp - firstObservation.timestamp;
        if (timeElapsed > windowSize) revert MissingHistoricalObservation();

        (uint256 price0Cumulative, uint256 price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(
            address(pair)
        );
        address token0 = tokenIn < tokenOut ? tokenIn : tokenOut;

        if (token0 == tokenIn) {
            return computeAmountOut(firstObservation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(firstObservation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);
        }
    }

    /**
     * @dev Compute the amount out based on cumulative prices and time elapsed.
     * @param priceCumulativeStart The cumulative price at the start of the period.
     * @param priceCumulativeEnd The cumulative price at the end of the period.
     * @param timeElapsed The time elapsed in seconds.
     * @param amountIn The input amount.
     * @return amountOut The computed amount out.
     */
    function computeAmountOut(
        uint256 priceCumulativeStart,
        uint256 priceCumulativeEnd,
        uint256 timeElapsed,
        uint256 amountIn
    ) private pure returns (uint256 amountOut) {
        // Overflow is desired.
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = priceAverage.mul(amountIn).decode144();
    }
}

/**
 * @title RFRMOracle
 * @notice An extension of SlidingWindowOracle to provide RFRM token price conversions in different currencies.
 */
contract RFRMOracle is Ownable, SlidingWindowOracle {
    AggregatorV3Interface public priceFeed; // RFRM/ETH
    bool internal isUsingChainlink;

    IERC20 public immutable token;

    address public immutable weth;

    AggregatorV3Interface public immutable ethusd;

    AggregatorV3Interface public immutable usdcusd;

    AggregatorV3Interface public immutable usdtusd;

    event OracleChanged(address feed, bool isUsing);

    error PriceNotUpdated();

    /**
     * @dev Constructor to initialize the RFRMOracle.
     * @param _pair The address of the Uniswap pair contract for RFRM token.
     * @param _token The address of the RFRM token.
     * @param _weth The address of Wrapped Ether (WETH).
     * @param _ethusd The address of the ETH/USD Chainlink aggregator.
     * @param _usdcusd The address of the USDC/USD Chainlink aggregator.
     * @param _usdtusd The address of the USDT/USD Chainlink aggregator.
     * @param _windowSize The desired time window for computing the moving average.
     * @param _granularity The granularity of observations.
     */
    constructor(
        address _pair,
        address _token,
        address _weth,
        address _ethusd,
        address _usdcusd,
        address _usdtusd,
        uint256 _windowSize,
        uint8 _granularity
    ) SlidingWindowOracle(_windowSize, _granularity, _pair) {
        if (_pair == address(0) || _token == address(0)) revert ZeroAddress();
        weth = _weth;
        ethusd = AggregatorV3Interface(_ethusd);
        usdcusd = AggregatorV3Interface(_usdcusd);
        usdtusd = AggregatorV3Interface(_usdtusd);
        token = IERC20(_token);
    }

    /**
     * @dev Set the Chainlink aggregator and specify whether it is in use.
     * @param _feed The address of the Chainlink aggregator.
     * @param _isUsing True if Chainlink aggregator is in use, false otherwise.
     */
    function setChainlink(address _feed, bool _isUsing) external onlyOwner {
        if (_isUsing) {
            if (_feed == address(0)) revert ZeroAddress();
        }
        priceFeed = AggregatorV3Interface(_feed);
        isUsingChainlink = _isUsing;
        emit OracleChanged(_feed, _isUsing);
    }

    /**
     * @dev Get the price of RFRM token in USDC.
     * @param tokenAmount The amount of RFRM tokens to convert.
     * @return usdAmount The equivalent amount in USDC.
     */
    function getPriceInUSDC(uint256 tokenAmount) external view returns (uint256 usdAmount) {
        uint256 ethAmount = getPriceInETH(tokenAmount);
        usdAmount = convertETHToUSDC(ethAmount);
    }

    /**
     * @dev Get the price of RFRM token in USDT.
     * @param tokenAmount The amount of RFRM tokens to convert.
     * @return usdAmount The equivalent amount in USDT.
     */
    function getPriceInUSDT(uint256 tokenAmount) external view returns (uint256 usdAmount) {
        uint256 ethAmount = getPriceInETH(tokenAmount);
        usdAmount = convertETHToUSDT(ethAmount);
    }

    /**
     * @dev Convert USDC to Ether (ETH).
     * @param usdAmount The amount of USDC to convert.
     * @return ethAmount The equivalent amount in Ether.
     */
    function convertUSDCToETH(uint256 usdAmount) external view returns (uint256 ethAmount) {
        (uint80 ethRoundId, int256 ethPrice, , uint256 updatedAtEth, uint80 ethAnsweredInRound) = ethusd
            .latestRoundData();
        (uint80 usdcRoundId, int256 usdcPrice, , uint256 updatedAtUsdt, uint80 usdcAnsweredInRound) = usdcusd
            .latestRoundData();

        if (ethRoundId != ethAnsweredInRound || usdcRoundId != usdcAnsweredInRound) revert PriceNotUpdated();
        if (updatedAtEth == 0 || updatedAtUsdt == 0) revert PriceNotUpdated();
        if (ethPrice == 0 || usdcPrice == 0) revert PriceNotUpdated();

        ethAmount = (10 ** 18 * uint256(usdcPrice) * usdAmount) / (uint256(ethPrice) * 10 ** 6);
    }

    /**
     * @dev Convert USDT to Ether (ETH).
     * @param usdAmount The amount of USDT to convert.
     * @return ethAmount The equivalent amount in Ether.
     */
    function convertUSDTToETH(uint256 usdAmount) external view returns (uint256 ethAmount) {
        (uint80 ethRoundId, int256 ethPrice, , uint256 updatedAtEth, uint80 ethAnsweredInRound) = ethusd
            .latestRoundData();
        (uint80 usdtRoundId, int256 usdtPrice, , uint256 updatedAtUsdt, uint80 usdtAnsweredInRound) = usdtusd
            .latestRoundData();

        if (ethRoundId != ethAnsweredInRound || usdtRoundId != usdtAnsweredInRound) revert PriceNotUpdated();
        if (updatedAtEth == 0 || updatedAtUsdt == 0) revert PriceNotUpdated();
        if (ethPrice == 0 || usdtPrice == 0) revert PriceNotUpdated();

        ethAmount = (10 ** 18 * uint256(usdtPrice) * usdAmount) / (uint256(ethPrice) * 10 ** 6);
    }

    /**
     * @dev Convert USD to Ether (ETH).
     * @param usdAmount The amount of USD to convert (with 8 decimals).
     * @return ethAmount The equivalent amount in Ether.
     */
    function convertUSDToETH(uint256 usdAmount) external view returns (uint256 ethAmount) {
        usdAmount = usdAmount * 100; //Converting to 8 decimals
        (uint80 ethRoundId, int256 ethPrice, , uint256 updatedAtEth, uint80 ethAnsweredInRound) = ethusd
            .latestRoundData();

        if (ethRoundId != ethAnsweredInRound) revert PriceNotUpdated();
        if (updatedAtEth == 0) revert PriceNotUpdated();
        if (ethPrice == 0) revert PriceNotUpdated();

        ethAmount = (usdAmount * 10 ** 18) / uint256(ethPrice);
    }

    /**
     * @dev Get the price of RFRM token in Ether (ETH).
     * @param tokenAmount The amount of RFRM tokens to convert.
     * @return ethAmount The equivalent amount in Ether.
     */
    function getPriceInETH(uint256 tokenAmount) public view returns (uint256 ethAmount) {
        if (!isUsingChainlink) {
            ethAmount = consult(address(token), tokenAmount, weth);
        } else {
            // Price of 1 RFRM including decimals
            (uint80 roundId, int256 price, , uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
            if (roundId != answeredInRound) revert PriceNotUpdated();
            if (updatedAt == 0) revert PriceNotUpdated();
            if (price == 0) revert PriceNotUpdated();

            ethAmount = (uint256(price) * tokenAmount) / 10 ** token.decimals();
        }
    }

    /**
     * @dev Convert Ether (ETH) to USDC.
     * @param ethAmount The amount of Ether to convert.
     * @return usdAmount The equivalent amount in USDC.
     */
    function convertETHToUSDC(uint256 ethAmount) public view returns (uint256 usdAmount) {
        (uint80 ethRoundId, int256 ethPrice, , uint256 updatedAtEth, uint80 ethAnsweredInRound) = ethusd
            .latestRoundData();
        (uint80 usdcRoundId, int256 usdcPrice, , uint256 updatedAtUsdt, uint80 usdcAnsweredInRound) = usdcusd
            .latestRoundData();

        if (ethRoundId != ethAnsweredInRound || usdcRoundId != usdcAnsweredInRound) revert PriceNotUpdated();
        if (updatedAtEth == 0 || updatedAtUsdt == 0) revert PriceNotUpdated();
        if (ethPrice == 0 || usdcPrice == 0) revert PriceNotUpdated();

        // USDC has 6 decimals, ETH has 18
        usdAmount = (uint256(ethPrice) * 10 ** 6 * ethAmount) / (10 ** 18 * uint256(usdcPrice));
    }

    /**
     * @dev Convert Ether (ETH) to USDT.
     * @param ethAmount The amount of Ether to convert.
     * @return usdAmount The equivalent amount in USDT.
     */
    function convertETHToUSDT(uint256 ethAmount) public view returns (uint256 usdAmount) {
        (uint80 ethRoundId, int256 ethPrice, , uint256 updatedAtEth, uint80 ethAnsweredInRound) = ethusd
            .latestRoundData();
        (uint80 usdtRoundId, int256 usdtPrice, , uint256 updatedAtUsdt, uint80 usdtAnsweredInRound) = usdtusd
            .latestRoundData();

        if (ethRoundId != ethAnsweredInRound || usdtRoundId != usdtAnsweredInRound) revert PriceNotUpdated();
        if (updatedAtEth == 0 || updatedAtUsdt == 0) revert PriceNotUpdated();
        if (ethPrice == 0 || usdtPrice == 0) revert PriceNotUpdated();

        // USDT has 6 decimals, ETH has 18
        usdAmount = (uint256(ethPrice) * 10 ** 6 * ethAmount) / (10 ** 18 * uint256(usdtPrice));
    }
}