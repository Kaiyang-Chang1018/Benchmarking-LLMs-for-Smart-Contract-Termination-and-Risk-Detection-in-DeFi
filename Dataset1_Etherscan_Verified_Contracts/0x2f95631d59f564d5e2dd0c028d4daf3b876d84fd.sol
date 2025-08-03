// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IWstETH } from "../../interfaces/external/IWstETH.sol";
import { IFluidOracle } from "../../interfaces/iFluidOracle.sol";
import { FluidCenterPrice } from "../../fluidCenterPrice.sol";

import { Error as OracleError } from "../../error.sol";
import { ErrorTypes } from "../../errorTypes.sol";

abstract contract Events {
    /// @notice emitted when rebalancer successfully changes the contract rate
    event LogRebalanceRate(uint256 oldRate, uint256 newRate);
}

abstract contract Constants {
    /// @dev WSTETH contract; on mainnet 0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0
    IWstETH internal immutable _WSTETH;

    /// @dev Minimum difference to trigger update in percent 1e4 decimals, 10000 = 1%
    uint256 internal immutable _MIN_UPDATE_DIFF_PERCENT;

    /// @dev Minimum time after which an update can trigger, even if it does not reach `_MIN_UPDATE_DIFF_PERCENT`
    uint256 internal immutable _MIN_HEART_BEAT;
}

abstract contract Variables is Constants {
    /// @dev amount of stETH for 1 wstETH, in 1e27 decimals
    uint216 internal _rate;

    /// @dev time when last update for rate happened
    uint40 internal _lastUpdateTime;
}

/// @notice This contract stores the rate of stETH for 1 wstETH in intervals to optimize gas cost.
/// @notice Properly implements all interfaces for use as IFluidCenterPrice and IFluidOracle.
contract WstETHContractRate is IWstETH, IFluidOracle, FluidCenterPrice, Variables, Events {
    /// @dev Validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidOracleError(ErrorTypes.ContractRate__InvalidParams);
        }
        _;
    }

    constructor(
        string memory infoName_,
        IWstETH wstETH_,
        uint256 minUpdateDiffPercent_,
        uint256 minHeartBeat_
    ) validAddress(address(wstETH_)) FluidCenterPrice(infoName_) {
        if (minUpdateDiffPercent_ == 0 || minUpdateDiffPercent_ > 1e5 || minHeartBeat_ == 0) {
            // revert if > 10% or 0
            revert FluidOracleError(ErrorTypes.ContractRate__InvalidParams);
        }
        _WSTETH = wstETH_;
        _MIN_UPDATE_DIFF_PERCENT = minUpdateDiffPercent_;
        _MIN_HEART_BEAT = minHeartBeat_;
        _rate = uint216(_WSTETH.stEthPerToken() * 1e9);
        _lastUpdateTime = uint40(block.timestamp);
    }

    /// @inheritdoc FluidCenterPrice
    function infoName() public view override(IFluidOracle, FluidCenterPrice) returns (string memory) {
        return super.infoName();
    }

    /// @notice Rebalance the contract rate by updating the stored rate with the current rate from the WSTETH contract.
    /// @dev The rate is only updated if the difference between the current rate and the new rate is greater than or
    ///      equal to the minimum update difference percentage.
    function rebalance() external {
        uint256 curRate_ = _rate;
        uint256 newRate_ = _WSTETH.stEthPerToken() * 1e9; // scale to 1e27

        uint256 rateDiffPercent;
        unchecked {
            if (curRate_ > newRate_) {
                rateDiffPercent = ((curRate_ - newRate_) * 1e6) / curRate_;
            } else if (newRate_ > curRate_) {
                rateDiffPercent = ((newRate_ - curRate_) * 1e6) / curRate_;
            }
        }
        if (rateDiffPercent < _MIN_UPDATE_DIFF_PERCENT) {
            revert FluidOracleError(ErrorTypes.ContractRate__MinUpdateDiffNotReached);
        }

        _rate = uint216(newRate_);
        _lastUpdateTime = uint40(block.timestamp);

        emit LogRebalanceRate(curRate_, newRate_);
    }

    /// @inheritdoc IWstETH
    function stEthPerToken() external view override returns (uint256) {
        return _rate / 1e9; // scale to 1e18
    }

    /// @inheritdoc IWstETH
    function tokensPerStEth() external view override returns (uint256) {
        return 1e45 / _rate; // scale to 1e18
    }

    /// @inheritdoc FluidCenterPrice
    function centerPrice() external override returns (uint256 price_) {
        // heart beat check update for Dex swaps
        if (_lastUpdateTime + _MIN_HEART_BEAT < block.timestamp) {
            uint256 curRate_ = _rate;
            uint256 newRate_ = _WSTETH.stEthPerToken() * 1e9; // scale to 1e27

            _rate = uint216(newRate_);
            _lastUpdateTime = uint40(block.timestamp);

            emit LogRebalanceRate(curRate_, newRate_);
        }

        return _rate;
    }

    /// @inheritdoc IFluidOracle
    function getExchangeRate() external view virtual returns (uint256 exchangeRate_) {
        return _rate;
    }

    /// @inheritdoc IFluidOracle
    function getExchangeRateOperate() external view virtual returns (uint256 exchangeRate_) {
        return _rate;
    }

    /// @inheritdoc IFluidOracle
    function getExchangeRateLiquidate() external view virtual returns (uint256 exchangeRate_) {
        return _rate;
    }

    /// @notice returns how much the new rate would be different from current rate in percent (10000 = 1%, 1 = 0.0001%).
    function configPercentDiff() public view virtual returns (uint256 configPercentDiff_) {
        uint256 curRate_ = _rate;
        uint256 newRate_ = _WSTETH.stEthPerToken() * 1e9; // scale to 1e27

        unchecked {
            if (curRate_ > newRate_) {
                configPercentDiff_ = ((curRate_ - newRate_) * 1e6) / curRate_;
            } else if (newRate_ > curRate_) {
                configPercentDiff_ = ((newRate_ - curRate_) * 1e6) / curRate_;
            }
        }
    }

    /// @notice returns all config vars, last update timestamp, and wsteth address
    function configData()
        external
        view
        returns (uint256 minUpdateDiffPercent_, uint256 minHeartBeat_, uint40 lastUpdateTime_, address wsteth_)
    {
        return (_MIN_UPDATE_DIFF_PERCENT, _MIN_HEART_BEAT, _lastUpdateTime, address(_WSTETH));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

contract Error {
    error FluidOracleError(uint256 errorId_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |           FluidOracleL2           | 
    |__________________________________*/

    /// @notice thrown when sequencer on a L2 has an outage and grace period has not yet passed.
    uint256 internal constant FluidOracleL2__SequencerOutage = 60000;

    /***********************************|
    |     UniV3CheckCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the delta between main price source and check rate source is exceeding the allowed delta
    uint256 internal constant UniV3CheckCLRSOracle__InvalidPrice = 60001;

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant UniV3CheckCLRSOracle__InvalidParams = 60002;

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant UniV3CheckCLRSOracle__ExchangeRateZero = 60003;

    /***********************************|
    |           FluidOracle             | 
    |__________________________________*/

    /// @notice thrown when an invalid info name is passed into a fluid oracle (e.g. not set or too long)
    uint256 internal constant FluidOracle__InvalidInfoName = 60010;

    /***********************************|
    |            sUSDe Oracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant SUSDeOracle__InvalidParams = 60102;

    /***********************************|
    |           Pendle Oracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant PendleOracle__InvalidParams = 60201;

    /// @notice thrown when the Pendle market Oracle has not been initialized yet
    uint256 internal constant PendleOracle__MarketNotInitialized = 60202;

    /// @notice thrown when the Pendle market does not have 18 decimals
    uint256 internal constant PendleOracle__MarketInvalidDecimals = 60203;

    /// @notice thrown when the Pendle market returns an unexpected price
    uint256 internal constant PendleOracle__InvalidPrice = 60204;

    /***********************************|
    |    CLRS2UniV3CheckCLRSOracleL2    | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant CLRS2UniV3CheckCLRSOracleL2__ExchangeRateZero = 60301;

    /***********************************|
    |    Ratio2xFallbackCLRSOracleL2    | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant Ratio2xFallbackCLRSOracleL2__ExchangeRateZero = 60311;

    /***********************************|
    |            WeETHsOracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WeETHsOracle__InvalidParams = 60321;

    /***********************************|
    |        DexSmartColOracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant DexSmartColOracle__InvalidParams = 60331;

    /// @notice thrown when smart col is not enabled
    uint256 internal constant DexSmartColOracle__SmartColNotEnabled = 60332;

    /***********************************|
    |        DexSmartDebtOracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant DexSmartDebtOracle__InvalidParams = 60341;

    /// @notice thrown when smart debt is not enabled
    uint256 internal constant DexSmartDebtOracle__SmartDebtNotEnabled = 60342;

    /***********************************|
    |            ContractRate           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant ContractRate__InvalidParams = 60351;

    /// @notice thrown when caller is not authorized
    uint256 internal constant ContractRate__Unauthorized = 60352;

    /// @notice thrown when minimum diff for triggering update on the stared rate is not reached
    uint256 internal constant ContractRate__MinUpdateDiffNotReached = 60353;

    /***********************************|
    |            sUSDs Oracle           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant SUSDsOracle__InvalidParams = 60361;

    /***********************************|
    |            Peg Oracle             | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant PegOracle__InvalidParams = 60371;

    /***********************************|
    |          Chainlink Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant ChainlinkOracle__InvalidParams = 61001;

    /***********************************|
    |          UniswapV3 Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant UniV3Oracle__InvalidParams = 62001;

    /// @notice thrown when constructor is called with invalid ordered seconds agos values
    uint256 internal constant UniV3Oracle__InvalidSecondsAgos = 62002;

    /// @notice thrown when constructor is called with invalid delta values > 100%
    uint256 internal constant UniV3Oracle__InvalidDeltas = 62003;

    /***********************************|
    |            WstETh Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WstETHOracle__InvalidParams = 63001;

    /***********************************|
    |           Redstone Oracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant RedstoneOracle__InvalidParams = 64001;

    /***********************************|
    |          Fallback Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant FallbackOracle__InvalidParams = 65001;

    /***********************************|
    |       FallbackCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the fallback oracle source (if enabled)
    uint256 internal constant FallbackCLRSOracle__ExchangeRateZero = 66001;

    /***********************************|
    |         WstETHCLRSOracle          | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the fallback oracle source (if enabled)
    uint256 internal constant WstETHCLRSOracle__ExchangeRateZero = 67001;

    /***********************************|
    |        CLFallbackUniV3Oracle      | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the uniV3 rate
    uint256 internal constant CLFallbackUniV3Oracle__ExchangeRateZero = 68001;

    /***********************************|
    |  WstETHCLRS2UniV3CheckCLRSOracle  | 
    |__________________________________*/

    /// @notice thrown when the exchange rate is zero, even for the uniV3 rate
    uint256 internal constant WstETHCLRS2UniV3CheckCLRSOracle__ExchangeRateZero = 69001;

    /***********************************|
    |             WeETh Oracle          | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant WeETHOracle__InvalidParams = 70001;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IFluidCenterPrice } from "./interfaces/iFluidCenterPrice.sol";
import { ErrorTypes } from "./errorTypes.sol";
import { Error as OracleError } from "./error.sol";

/// @title   FluidCenterPrice
/// @notice  Base contract that any Fluid Center Price must implement
abstract contract FluidCenterPrice is IFluidCenterPrice, OracleError {
    /// @dev short helper string to easily identify the center price oracle. E.g. token symbols
    //
    // using a bytes32 because string can not be immutable.
    bytes32 private immutable _infoName;

    constructor(string memory infoName_) {
        if (bytes(infoName_).length > 32 || bytes(infoName_).length == 0) {
            revert FluidOracleError(ErrorTypes.FluidOracle__InvalidInfoName);
        }

        // convert string to bytes32
        bytes32 infoNameBytes32_;
        assembly {
            infoNameBytes32_ := mload(add(infoName_, 32))
        }
        _infoName = infoNameBytes32_;
    }

    /// @inheritdoc IFluidCenterPrice
    function infoName() public view virtual returns (string memory) {
        // convert bytes32 to string
        uint256 length_;
        while (length_ < 32 && _infoName[length_] != 0) {
            length_++;
        }
        bytes memory infoNameBytes_ = new bytes(length_);
        for (uint256 i; i < length_; i++) {
            infoNameBytes_[i] = _infoName[i];
        }
        return string(infoNameBytes_);
    }

    /// @inheritdoc IFluidCenterPrice
    function centerPrice() external virtual returns (uint256 price_);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IWstETH {
    /**
     * @notice Get amount of stETH for 1 wstETH
     * @return Amount of stETH for 1 wstETH
     */
    function stEthPerToken() external view returns (uint256);

    /**
     * @notice Get amount of wstETH for 1 stETH
     * @return Amount of wstETH for 1 stETH
     */
    function tokensPerStEth() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IFluidCenterPrice {
    /// @notice Retrieves the center price for the pool
    /// @dev This function is marked as non-constant (potentially state-changing) to allow flexibility in price fetching mechanisms.
    ///      While typically used as a read-only operation, this design permits write operations if needed for certain token pairs
    ///      (e.g., fetching up-to-date exchange rates that may require state changes).
    /// @return price_ The current price ratio of token1 to token0, expressed with 27 decimal places
    function centerPrice() external returns (uint256 price_);

    /// @notice helper string to easily identify the oracle. E.g. token symbols
    function infoName() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IFluidOracle {
    /// @dev Deprecated. Use `getExchangeRateOperate()` and `getExchangeRateLiquidate()` instead. Only implemented for
    ///      backwards compatibility.
    function getExchangeRate() external view returns (uint256 exchangeRate_);

    /// @notice Get the `exchangeRate_` between the underlying asset and the peg asset in 1e27 for operates
    function getExchangeRateOperate() external view returns (uint256 exchangeRate_);

    /// @notice Get the `exchangeRate_` between the underlying asset and the peg asset in 1e27 for liquidations
    function getExchangeRateLiquidate() external view returns (uint256 exchangeRate_);

    /// @notice helper string to easily identify the oracle. E.g. token symbols
    function infoName() external view returns (string memory);
}