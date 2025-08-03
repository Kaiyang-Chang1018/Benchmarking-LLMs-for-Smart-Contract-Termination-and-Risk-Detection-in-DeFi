// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { Error } from "../error.sol";
import { ErrorTypes } from "../errorTypes.sol";

import { DexSlotsLink } from "../../libraries/dexSlotsLink.sol";
import { IFluidDexT1 } from "../../protocols/dex/interfaces/iDexT1.sol";
import { IFluidReserveContract } from "../../reserve/interfaces/iReserveContract.sol";

interface IFluidDexT1Admin {
    /// @notice sets a new fee and revenue cut for a certain dex
    /// @param fee_ new fee (scaled so that 1% = 10000)
    /// @param revenueCut_ new revenue cut
    function updateFeeAndRevenueCut(uint fee_, uint revenueCut_) external;
}

abstract contract Events {
    /// @notice emitted when rebalancer successfully changes the fee and revenue cut
    event LogRebalanceFeeAndRevenueCut(address dex, uint fee, uint revenueCut);
}

abstract contract Constants {
    // 1% = 10000
    uint256 internal constant FOUR_DECIMALS = 1e4;

    uint256 internal constant SCALE = 1e27;

    uint256 internal constant X7 = 0x7f;
    uint256 internal constant X17 = 0x1ffff;
    uint256 internal constant X40 = 0xffffffffff;
    uint256 internal constant X33 = 0x1ffffffff;
    uint256 internal constant DEFAULT_EXPONENT_SIZE = 8;
    uint256 internal constant DEFAULT_EXPONENT_MASK = 0xFF;

    uint256 public immutable MIN_FEE; // e.g. 10 -> 0.001%
    uint256 public immutable MAX_FEE; // e.g. 100 -> 0.01%
    uint256 public immutable MIN_DEVIATION; // in 1e27 scale, e.g. 3e23 -> 0.003
    uint256 public immutable MAX_DEVIATION; // in 1e27 scale, e.g. 1e24 -> 0.01

    uint256 public immutable UPDATE_FEE_TRIGGER_BUFFER = 10; // e.g. 1e4 -> 1%

    // USDC-USDT dex
    address internal immutable DEX;

    IFluidReserveContract public immutable RESERVE_CONTRACT;
}

abstract contract DynamicFee is Constants, Error, Events {
    constructor(uint256 _minFee, uint256 _maxFee, uint256 _minDeviation, uint256 _maxDeviation) {
        // check for zero values
        if (_minFee == 0 || _maxFee == 0 || _minDeviation == 0 || _maxDeviation == 0)
            revert FluidConfigError(ErrorTypes.DexFeeHandler__InvalidParams);

        // check that max fee is not greater or equal to 1%
        if (_maxFee >= 1e4) revert FluidConfigError(ErrorTypes.DexFeeHandler__InvalidParams);

        // check that min deviation is not greater than max deviation
        if (_minDeviation > _maxDeviation) revert FluidConfigError(ErrorTypes.DexFeeHandler__InvalidParams);

        // check that min fee is not greater than max fee
        if (_minFee > _maxFee) revert FluidConfigError(ErrorTypes.DexFeeHandler__InvalidParams);

        MIN_FEE = _minFee;
        MAX_FEE = _maxFee;
        MIN_DEVIATION = _minDeviation;
        MAX_DEVIATION = _maxDeviation;
    }

    function dynamicFeeFromPrice(uint256 price) external view returns (uint256) {
        // Absolute deviation from 1e27
        uint256 deviation = price > SCALE ? price - SCALE : SCALE - price;
        return _computeDynamicFee(deviation);
    }

    function dynamicFeeFromDeviation(uint256 deviation) external view returns (uint256) {
        return _computeDynamicFee(deviation);
    }

    /**
     * @dev Internal helper that implements a smooth-step curve for fee calculation
     * @param deviation Deviation from the target price in SCALE (1e27)
     * @return Fee in basis points (1e4 = 1%)
     */
    function _computeDynamicFee(uint256 deviation) internal view returns (uint256) {
        if (deviation <= MIN_DEVIATION) {
            return MIN_FEE;
        } else if (deviation >= MAX_DEVIATION) {
            return MAX_FEE;
        } else {
            // Calculate normalized position between min and max deviation (0 to 1 in SCALE)
            uint256 alpha = ((deviation - MIN_DEVIATION) * SCALE) / (MAX_DEVIATION - MIN_DEVIATION);

            // Smooth step formula: 3x² - 2x³
            // https://en.wikipedia.org/wiki/Smoothstep
            uint256 alpha2 = _scaleMul(alpha, alpha);
            uint256 alpha3 = _scaleMul(alpha2, alpha);

            uint256 smooth = _scaleMul(3 * SCALE, alpha2) - _scaleMul(2 * SCALE, alpha3);

            uint256 feeDelta = MAX_FEE - MIN_FEE;
            uint256 interpolatedFee = MIN_FEE + (_scaleMul(smooth, feeDelta));

            return interpolatedFee;
        }
    }

    function _scaleMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / SCALE;
    }
}

contract FluidDexFeeHandler is DynamicFee {
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidConfigError(ErrorTypes.DexFeeHandler__InvalidParams);
        }
        _;
    }

    modifier onlyRebalancer() {
        if (!RESERVE_CONTRACT.isRebalancer(msg.sender)) {
            revert FluidConfigError(ErrorTypes.DexFeeHandler__Unauthorized);
        }
        _;
    }

    constructor(
        IFluidReserveContract reserveContract_,
        uint256 minFee_,
        uint256 maxFee_,
        uint256 minDeviation_,
        uint256 maxDeviation_,
        address dex_
    )
        validAddress(dex_)
        validAddress(address(reserveContract_))
        DynamicFee(minFee_, maxFee_, minDeviation_, maxDeviation_)
    {
        RESERVE_CONTRACT = reserveContract_;
        DEX = dex_;
    }

    function getDexFee() public view returns (uint256 fee_) {
        uint256 dexVariables2_ = IFluidDexT1(DEX).readFromStorage(bytes32(DexSlotsLink.DEX_VARIABLES2_SLOT));
        return (dexVariables2_ >> 2) & X17;
    }

    function getDexRevenueCut() public view returns (uint256 revenueCut_) {
        uint256 dexVariables2_ = IFluidDexT1(DEX).readFromStorage(bytes32(DexSlotsLink.DEX_VARIABLES2_SLOT));
        return (dexVariables2_ >> 19) & X7;
    }

    function getDexFeeAndRevenueCut() public view returns (uint256 fee_, uint256 revenueCut_) {
        uint256 dexVariables2_ = IFluidDexT1(DEX).readFromStorage(bytes32(DexSlotsLink.DEX_VARIABLES2_SLOT));
        fee_ = (dexVariables2_ >> 2) & X17;
        revenueCut_ = (dexVariables2_ >> 19) & X7;
    }

    function getDexVariable()
        public
        view
        returns (uint256 lastToLastStoredPrice_, uint256 lastStoredPriceOfPool_, uint256 lastInteractionTimeStamp_)
    {
        uint256 dexVariables_ = IFluidDexT1(DEX).readFromStorage(bytes32(DexSlotsLink.DEX_VARIABLES_SLOT));

        lastToLastStoredPrice_ = (dexVariables_ >> 1) & X40;
        lastToLastStoredPrice_ =
            (lastToLastStoredPrice_ >> DEFAULT_EXPONENT_SIZE) <<
            (lastToLastStoredPrice_ & DEFAULT_EXPONENT_MASK);

        lastStoredPriceOfPool_ = (dexVariables_ >> 41) & X40;
        lastStoredPriceOfPool_ =
            (lastStoredPriceOfPool_ >> DEFAULT_EXPONENT_SIZE) <<
            (lastStoredPriceOfPool_ & DEFAULT_EXPONENT_MASK);

        lastInteractionTimeStamp_ = (dexVariables_ >> 121) & X33;
    }

    function rebalance() external onlyRebalancer {
        (
            uint256 lastToLastStoredPrice_,
            uint256 lastStoredPriceOfPool_,
            uint256 lastInteractionTimeStamp_
        ) = getDexVariable();

        if (lastInteractionTimeStamp_ == block.timestamp) lastStoredPriceOfPool_ = lastToLastStoredPrice_;

        // Absolute deviation from 1e27
        uint256 deviation = lastStoredPriceOfPool_ > SCALE
            ? lastStoredPriceOfPool_ - SCALE
            : SCALE - lastStoredPriceOfPool_;

        uint256 newFee_ = _computeDynamicFee(deviation);

        (uint256 currentFee_, uint256 currentRevenueCut_) = getDexFeeAndRevenueCut();

        uint256 feePercentageChange_ = _configPercentDiff(currentFee_, newFee_);

        // should be more than 0.001% to update
        if (feePercentageChange_ > UPDATE_FEE_TRIGGER_BUFFER) {
            IFluidDexT1Admin(DEX).updateFeeAndRevenueCut(newFee_, currentRevenueCut_ * FOUR_DECIMALS);
            emit LogRebalanceFeeAndRevenueCut(DEX, newFee_, currentRevenueCut_ * FOUR_DECIMALS);
        } else {
            revert FluidConfigError(ErrorTypes.DexFeeHandler__FeeUpdateNotRequired);
        }
    }

    /// @notice returns how much new config would be different from current config in percent (100 = 1%, 1 = 0.01%).
    function configPercentDiff() public view returns (uint256) {
        (
            uint256 lastToLastStoredPrice_,
            uint256 lastStoredPriceOfPool_,
            uint256 lastInteractionTimeStamp_
        ) = getDexVariable();

        if (lastInteractionTimeStamp_ == block.timestamp) lastStoredPriceOfPool_ = lastToLastStoredPrice_;

        // Absolute deviation from 1.0
        uint256 deviation = lastStoredPriceOfPool_ > SCALE
            ? lastStoredPriceOfPool_ - SCALE
            : SCALE - lastStoredPriceOfPool_;

        uint256 newFee_ = _computeDynamicFee(deviation);

        (uint256 currentFee_, ) = getDexFeeAndRevenueCut();

        return _configPercentDiff(currentFee_, newFee_);
    }

    function _configPercentDiff(
        uint256 currentFee_,
        uint256 newFee_
    ) internal pure returns (uint256 configPercentDiff_) {
        if (currentFee_ == newFee_) {
            return 0;
        }

        if (currentFee_ > newFee_) configPercentDiff_ = currentFee_ - newFee_;
        else configPercentDiff_ = newFee_ - currentFee_;

        return (configPercentDiff_ * FOUR_DECIMALS) / currentFee_;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

contract Error {
    error FluidConfigError(uint256 errorId_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |    ExpandPercentConfigHandler     | 
    |__________________________________*/

    /// @notice thrown when an input address is zero
    uint256 internal constant ExpandPercentConfigHandler__AddressZero = 100001;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant ExpandPercentConfigHandler__Unauthorized = 100002;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant ExpandPercentConfigHandler__InvalidParams = 100003;

    /// @notice thrown when no update is currently needed
    uint256 internal constant ExpandPercentConfigHandler__NoUpdate = 100004;

    /// @notice thrown when slot is not used, e.g. when borrow token is 0 there is no borrow data
    uint256 internal constant ExpandPercentConfigHandler__SlotDoesNotExist = 100005;

    /***********************************|
    |      EthenaRateConfigHandler      | 
    |__________________________________*/

    /// @notice thrown when an input address is zero
    uint256 internal constant EthenaRateConfigHandler__AddressZero = 100011;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant EthenaRateConfigHandler__Unauthorized = 100012;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant EthenaRateConfigHandler__InvalidParams = 100013;

    /// @notice thrown when no update is currently needed
    uint256 internal constant EthenaRateConfigHandler__NoUpdate = 100014;

    /***********************************|
    |       MaxBorrowConfigHandler      | 
    |__________________________________*/

    /// @notice thrown when an input address is zero
    uint256 internal constant MaxBorrowConfigHandler__AddressZero = 100021;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant MaxBorrowConfigHandler__Unauthorized = 100022;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant MaxBorrowConfigHandler__InvalidParams = 100023;

    /// @notice thrown when no update is currently needed
    uint256 internal constant MaxBorrowConfigHandler__NoUpdate = 100024;

    /***********************************|
    |       BufferRateConfigHandler     | 
    |__________________________________*/

    /// @notice thrown when an input address is zero
    uint256 internal constant BufferRateConfigHandler__AddressZero = 100031;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant BufferRateConfigHandler__Unauthorized = 100032;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant BufferRateConfigHandler__InvalidParams = 100033;

    /// @notice thrown when no update is currently needed
    uint256 internal constant BufferRateConfigHandler__NoUpdate = 100034;

    /// @notice thrown when rate data version is not supported
    uint256 internal constant BufferRateConfigHandler__RateVersionUnsupported = 100035;

    /***********************************|
    |          FluidRatesAuth           | 
    |__________________________________*/

    /// @notice thrown when no update is currently needed
    uint256 internal constant RatesAuth__NoUpdate = 100041;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant RatesAuth__Unauthorized = 100042;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant RatesAuth__InvalidParams = 100043;

    /// @notice thrown when cooldown is not yet expired
    uint256 internal constant RatesAuth__CooldownLeft = 100044;

    /// @notice thrown when version is invalid
    uint256 internal constant RatesAuth__InvalidVersion = 100045;

    /***********************************|
    |          ListTokenAuth            | 
    |__________________________________*/

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant ListTokenAuth__Unauthorized = 100051;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant ListTokenAuth_AlreadyInitialized = 100052;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant ListTokenAuth__InvalidParams = 100053;

    /***********************************|
    |       CollectRevenueAuth          | 
    |__________________________________*/

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant CollectRevenueAuth__Unauthorized = 100061;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant CollectRevenueAuth__InvalidParams = 100062;

    /***********************************|
    |       FluidWithdrawLimitAuth      | 
    |__________________________________*/

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant WithdrawLimitAuth__NoUserSupply = 100071;

    /// @notice thrown when an unauthorized `msg.sender` calls a protected method
    uint256 internal constant WithdrawLimitAuth__Unauthorized = 100072;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant WithdrawLimitAuth__InvalidParams = 100073;

    /// @notice thrown when no more withdrawal limit can be set for the day
    uint256 internal constant WithdrawLimitAuth__DailyLimitReached = 100074;

    /// @notice thrown when no more withdrawal limit can be set for the hour
    uint256 internal constant WithdrawLimitAuth__HourlyLimitReached = 100075;

    /// @notice thrown when the withdrawal limit and userSupply difference exceeds 5%
    uint256 internal constant WithdrawLimitAuth__ExcessPercentageDifference = 100076;

    /***********************************|
    |       DexFeeHandler               | 
    |__________________________________*/

    /// @notice thrown when fee update is not required
    uint256 internal constant DexFeeHandler__FeeUpdateNotRequired = 100081;

    /// @notice thrown when invalid params are passed into a method
    uint256 internal constant DexFeeHandler__InvalidParams = 100082;

    /// @notice thrown when an unauthorized `msg.sender` calls
    uint256 internal constant DexFeeHandler__Unauthorized = 100083;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IProxy {
    function setAdmin(address newAdmin_) external;

    function setDummyImplementation(address newDummyImplementation_) external;

    function addImplementation(address implementation_, bytes4[] calldata sigs_) external;

    function removeImplementation(address implementation_) external;

    function getAdmin() external view returns (address);

    function getDummyImplementation() external view returns (address);

    function getImplementationSigs(address impl_) external view returns (bytes4[] memory);

    function getSigsImplementation(bytes4 sig_) external view returns (address);

    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @notice library that helps in reading / working with storage slot data of Fluid Dex.
/// @dev as all data for Fluid Dex is internal, any data must be fetched directly through manual
/// slot reading through this library or, if gas usage is less important, through the FluidDexResolver.
library DexSlotsLink {
    /// @dev storage slot for variables at Dex
    uint256 internal constant DEX_VARIABLES_SLOT = 0;
    /// @dev storage slot for variables2 at Dex
    uint256 internal constant DEX_VARIABLES2_SLOT = 1;
    /// @dev storage slot for total supply shares at Dex
    uint256 internal constant DEX_TOTAL_SUPPLY_SHARES_SLOT = 2;
    /// @dev storage slot for user supply mapping at Dex
    uint256 internal constant DEX_USER_SUPPLY_MAPPING_SLOT = 3;
    /// @dev storage slot for total borrow shares at Dex
    uint256 internal constant DEX_TOTAL_BORROW_SHARES_SLOT = 4;
    /// @dev storage slot for user borrow mapping at Dex
    uint256 internal constant DEX_USER_BORROW_MAPPING_SLOT = 5;
    /// @dev storage slot for oracle mapping at Dex
    uint256 internal constant DEX_ORACLE_MAPPING_SLOT = 6;
    /// @dev storage slot for range and threshold shifts at Dex
    uint256 internal constant DEX_RANGE_THRESHOLD_SHIFTS_SLOT = 7;
    /// @dev storage slot for center price shift at Dex
    uint256 internal constant DEX_CENTER_PRICE_SHIFT_SLOT = 8;

    // --------------------------------
    // @dev stacked uint256 storage slots bits position data for each:

    // UserSupplyData
    uint256 internal constant BITS_USER_SUPPLY_ALLOWED = 0;
    uint256 internal constant BITS_USER_SUPPLY_AMOUNT = 1;
    uint256 internal constant BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT = 65;
    uint256 internal constant BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT = 200;

    // UserBorrowData
    uint256 internal constant BITS_USER_BORROW_ALLOWED = 0;
    uint256 internal constant BITS_USER_BORROW_AMOUNT = 1;
    uint256 internal constant BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT = 65;
    uint256 internal constant BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_BORROW_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_BORROW_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_BORROW_BASE_BORROW_LIMIT = 200;
    uint256 internal constant BITS_USER_BORROW_MAX_BORROW_LIMIT = 218;

    // --------------------------------

    /// @notice Calculating the slot ID for Dex contract for single mapping at `slot_` for `key_`
    function calculateMappingStorageSlot(uint256 slot_, address key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    /// @notice Calculating the slot ID for Dex contract for double mapping at `slot_` for `key1_` and `key2_`
    function calculateDoubleMappingStorageSlot(
        uint256 slot_,
        address key1_,
        address key2_
    ) internal pure returns (bytes32) {
        bytes32 intermediateSlot_ = keccak256(abi.encode(key1_, slot_));
        return keccak256(abi.encode(key2_, intermediateSlot_));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Structs {
    struct AddressBool {
        address addr;
        bool value;
    }

    struct AddressUint256 {
        address addr;
        uint256 value;
    }

    /// @notice struct to set borrow rate data for version 1
    struct RateDataV1Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink usually means slow increase in rate, once utilization is above kink borrow rate increases fast
        uint256 kink;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink borrow rate when utilization is at kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink;
        ///
        /// @param rateAtUtilizationMax borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set borrow rate data for version 2
    struct RateDataV2Params {
        ///
        /// @param token for rate data
        address token;
        ///
        /// @param kink1 first kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 1 usually means slow increase in rate, once utilization is above kink 1 borrow rate increases faster
        uint256 kink1;
        ///
        /// @param kink2 second kink in borrow rate. in 1e2: 100% = 10_000; 1% = 100
        /// utilization below kink 2 usually means slow / medium increase in rate, once utilization is above kink 2 borrow rate increases fast
        uint256 kink2;
        ///
        /// @param rateAtUtilizationZero desired borrow rate when utilization is zero. in 1e2: 100% = 10_000; 1% = 100
        /// i.e. constant minimum borrow rate
        /// e.g. at utilization = 0.01% rate could still be at least 4% (rateAtUtilizationZero would be 400 then)
        uint256 rateAtUtilizationZero;
        ///
        /// @param rateAtUtilizationKink1 desired borrow rate when utilization is at first kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at first kink then rateAtUtilizationKink would be 700
        uint256 rateAtUtilizationKink1;
        ///
        /// @param rateAtUtilizationKink2 desired borrow rate when utilization is at second kink. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 7% at second kink then rateAtUtilizationKink would be 1_200
        uint256 rateAtUtilizationKink2;
        ///
        /// @param rateAtUtilizationMax desired borrow rate when utilization is maximum at 100%. in 1e2: 100% = 10_000; 1% = 100
        /// e.g. when rate should be 125% at 100% then rateAtUtilizationMax would be 12_500
        uint256 rateAtUtilizationMax;
    }

    /// @notice struct to set token config
    struct TokenConfig {
        ///
        /// @param token address
        address token;
        ///
        /// @param fee charges on borrower's interest. in 1e2: 100% = 10_000; 1% = 100
        uint256 fee;
        ///
        /// @param threshold on when to update the storage slot. in 1e2: 100% = 10_000; 1% = 100
        uint256 threshold;
        ///
        /// @param maxUtilization maximum allowed utilization. in 1e2: 100% = 10_000; 1% = 100
        ///                       set to 100% to disable and have default limit of 100% (avoiding SLOAD).
        uint256 maxUtilization;
    }

    /// @notice struct to set user supply & withdrawal config
    struct UserSupplyConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent withdrawal limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which withdrawal limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration withdrawal limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseWithdrawalLimit base limit, below this, user can withdraw the entire amount.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseWithdrawalLimit;
    }

    /// @notice struct to set user borrow & payback config
    struct UserBorrowConfig {
        ///
        /// @param user address
        address user;
        ///
        /// @param token address
        address token;
        ///
        /// @param mode: 0 = without interest. 1 = with interest
        uint8 mode;
        ///
        /// @param expandPercent debt limit expand percent. in 1e2: 100% = 10_000; 1% = 100
        /// Also used to calculate rate at which debt limit should decrease (instant).
        uint256 expandPercent;
        ///
        /// @param expandDuration debt limit expand duration in seconds.
        /// used to calculate rate together with expandPercent
        uint256 expandDuration;
        ///
        /// @param baseDebtCeiling base borrow limit. until here, borrow limit remains as baseDebtCeiling
        /// (user can borrow until this point at once without stepped expansion). Above this, automated limit comes in place.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 baseDebtCeiling;
        ///
        /// @param maxDebtCeiling max borrow ceiling, maximum amount the user can borrow.
        /// amount in raw (to be multiplied with exchange price) or normal depends on configured mode in user config for the token:
        /// with interest -> raw, without interest -> normal
        uint256 maxDebtCeiling;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { IProxy } from "../../infiniteProxy/interfaces/iProxy.sol";
import { Structs as AdminModuleStructs } from "../adminModule/structs.sol";

interface IFluidLiquidityAdmin {
    /// @notice adds/removes auths. Auths generally could be contracts which can have restricted actions defined on contract.
    ///         auths can be helpful in reducing governance overhead where it's not needed.
    /// @param authsStatus_ array of structs setting allowed status for an address.
    ///                     status true => add auth, false => remove auth
    function updateAuths(AdminModuleStructs.AddressBool[] calldata authsStatus_) external;

    /// @notice adds/removes guardians. Only callable by Governance.
    /// @param guardiansStatus_ array of structs setting allowed status for an address.
    ///                         status true => add guardian, false => remove guardian
    function updateGuardians(AdminModuleStructs.AddressBool[] calldata guardiansStatus_) external;

    /// @notice changes the revenue collector address (contract that is sent revenue). Only callable by Governance.
    /// @param revenueCollector_  new revenue collector address
    function updateRevenueCollector(address revenueCollector_) external;

    /// @notice changes current status, e.g. for pausing or unpausing all user operations. Only callable by Auths.
    /// @param newStatus_ new status
    ///        status = 2 -> pause, status = 1 -> resume.
    function changeStatus(uint256 newStatus_) external;

    /// @notice                  update tokens rate data version 1. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV1Params with rate data to set for each token
    function updateRateDataV1s(AdminModuleStructs.RateDataV1Params[] calldata tokensRateData_) external;

    /// @notice                  update tokens rate data version 2. Only callable by Auths.
    /// @param tokensRateData_   array of RateDataV2Params with rate data to set for each token
    function updateRateDataV2s(AdminModuleStructs.RateDataV2Params[] calldata tokensRateData_) external;

    /// @notice updates token configs: fee charge on borrowers interest & storage update utilization threshold.
    ///         Only callable by Auths.
    /// @param tokenConfigs_ contains token address, fee & utilization threshold
    function updateTokenConfigs(AdminModuleStructs.TokenConfig[] calldata tokenConfigs_) external;

    /// @notice updates user classes: 0 is for new protocols, 1 is for established protocols.
    ///         Only callable by Auths.
    /// @param userClasses_ struct array of uint256 value to assign for each user address
    function updateUserClasses(AdminModuleStructs.AddressUint256[] calldata userClasses_) external;

    /// @notice sets user supply configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    /// @param userSupplyConfigs_ struct array containing user supply config, see `UserSupplyConfig` struct for more info
    function updateUserSupplyConfigs(AdminModuleStructs.UserSupplyConfig[] memory userSupplyConfigs_) external;

    /// @notice sets a new withdrawal limit as the current limit for a certain user
    /// @param user_ user address for which to update the withdrawal limit
    /// @param token_ token address for which to update the withdrawal limit
    /// @param newLimit_ new limit until which user supply can decrease to.
    ///                  Important: input in raw. Must account for exchange price in input param calculation.
    ///                  Note any limit that is < max expansion or > current user supply will set max expansion limit or
    ///                  current user supply as limit respectively.
    ///                  - set 0 to make maximum possible withdrawable: instant full expansion, and if that goes
    ///                  below base limit then fully down to 0.
    ///                  - set type(uint256).max to make current withdrawable 0 (sets current user supply as limit).
    function updateUserWithdrawalLimit(address user_, address token_, uint256 newLimit_) external;

    /// @notice setting user borrow configs per token basis. Eg: with interest or interest-free and automated limits.
    ///         Only callable by Auths.
    /// @param userBorrowConfigs_ struct array containing user borrow config, see `UserBorrowConfig` struct for more info
    function updateUserBorrowConfigs(AdminModuleStructs.UserBorrowConfig[] memory userBorrowConfigs_) external;

    /// @notice pause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to pause operations for
    /// @param supplyTokens_  token addresses to pause withdrawals for
    /// @param borrowTokens_  token addresses to pause borrowings for
    function pauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice unpause operations for a particular user in class 0 (class 1 users can't be paused by guardians).
    /// Only callable by Guardians.
    /// @param user_          address of user to unpause operations for
    /// @param supplyTokens_  token addresses to unpause withdrawals for
    /// @param borrowTokens_  token addresses to unpause borrowings for
    function unpauseUser(address user_, address[] calldata supplyTokens_, address[] calldata borrowTokens_) external;

    /// @notice         collects revenue for tokens to configured revenueCollector address.
    /// @param tokens_  array of tokens to collect revenue for
    /// @dev            Note that this can revert if token balance is < revenueAmount (utilization > 100%)
    function collectRevenue(address[] calldata tokens_) external;

    /// @notice gets the current updated exchange prices for n tokens and updates all prices, rates related data in storage.
    /// @param tokens_ tokens to update exchange prices for
    /// @return supplyExchangePrices_ new supply rates of overall system for each token
    /// @return borrowExchangePrices_ new borrow rates of overall system for each token
    function updateExchangePrices(
        address[] calldata tokens_
    ) external returns (uint256[] memory supplyExchangePrices_, uint256[] memory borrowExchangePrices_);
}

interface IFluidLiquidityLogic is IFluidLiquidityAdmin {
    /// @notice Single function which handles supply, withdraw, borrow & payback
    /// @param token_ address of token (0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE for native)
    /// @param supplyAmount_ if +ve then supply, if -ve then withdraw, if 0 then nothing
    /// @param borrowAmount_ if +ve then borrow, if -ve then payback, if 0 then nothing
    /// @param withdrawTo_ if withdrawal then to which address
    /// @param borrowTo_ if borrow then to which address
    /// @param callbackData_ callback data passed to `liquidityCallback` method of protocol
    /// @return memVar3_ updated supplyExchangePrice
    /// @return memVar4_ updated borrowExchangePrice
    /// @dev to trigger skipping in / out transfers (gas optimization):
    /// -  ` callbackData_` MUST be encoded so that "from" address is the last 20 bytes in the last 32 bytes slot,
    ///     also for native token operations where liquidityCallback is not triggered!
    ///     from address must come at last position if there is more data. I.e. encode like:
    ///     abi.encode(otherVar1, otherVar2, FROM_ADDRESS). Note dynamic types used with abi.encode come at the end
    ///     so if dynamic types are needed, you must use abi.encodePacked to ensure the from address is at the end.
    /// -   this "from" address must match withdrawTo_ or borrowTo_ and must be == `msg.sender`
    /// -   `callbackData_` must in addition to the from address as described above include bytes32 SKIP_TRANSFERS
    ///     in the slot before (bytes 32 to 63)
    /// -   `msg.value` must be 0.
    /// -   Amounts must be either:
    ///     -  supply(+) == borrow(+), withdraw(-) == payback(-).
    ///     -  Liquidity must be on the winning side (deposit < borrow OR payback < withdraw).
    function operate(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_,
        address withdrawTo_,
        address borrowTo_,
        bytes calldata callbackData_
    ) external payable returns (uint256 memVar3_, uint256 memVar4_);
}

interface IFluidLiquidity is IProxy, IFluidLiquidityLogic {}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IFluidDexT1 {
    error FluidDexError(uint256 errorId);

    /// @notice used to simulate swap to find the output amount
    error FluidDexSwapResult(uint256 amountOut);

    error FluidDexPerfectLiquidityOutput(uint256 token0Amt, uint token1Amt);

    error FluidDexSingleTokenOutput(uint256 tokenAmt);

    error FluidDexLiquidityOutput(uint256 shares);

    error FluidDexPricesAndExchangeRates(PricesAndExchangePrice pex_);

    /// @notice returns the dex id
    function DEX_ID() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct Implementations {
        address shift;
        address admin;
        address colOperations;
        address debtOperations;
        address perfectOperationsAndOracle;
    }

    struct ConstantViews {
        uint256 dexId;
        address liquidity;
        address factory;
        Implementations implementations;
        address deployerContract;
        address token0;
        address token1;
        bytes32 supplyToken0Slot;
        bytes32 borrowToken0Slot;
        bytes32 supplyToken1Slot;
        bytes32 borrowToken1Slot;
        bytes32 exchangePriceToken0Slot;
        bytes32 exchangePriceToken1Slot;
        uint256 oracleMapping;
    }

    struct ConstantViews2 {
        uint token0NumeratorPrecision;
        uint token0DenominatorPrecision;
        uint token1NumeratorPrecision;
        uint token1DenominatorPrecision;
    }

    struct PricesAndExchangePrice {
        uint lastStoredPrice; // last stored price in 1e27 decimals
        uint centerPrice; // last stored price in 1e27 decimals
        uint upperRange; // price at upper range in 1e27 decimals
        uint lowerRange; // price at lower range in 1e27 decimals
        uint geometricMean; // geometric mean of upper range & lower range in 1e27 decimals
        uint supplyToken0ExchangePrice;
        uint borrowToken0ExchangePrice;
        uint supplyToken1ExchangePrice;
        uint borrowToken1ExchangePrice;
    }

    struct CollateralReserves {
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    struct DebtReserves {
        uint token0Debt;
        uint token1Debt;
        uint token0RealReserves;
        uint token1RealReserves;
        uint token0ImaginaryReserves;
        uint token1ImaginaryReserves;
    }

    function getCollateralReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0SupplyExchangePrice_,
        uint token1SupplyExchangePrice_
    ) external view returns (CollateralReserves memory c_);

    function getDebtReserves(
        uint geometricMean_,
        uint upperRange_,
        uint lowerRange_,
        uint token0BorrowExchangePrice_,
        uint token1BorrowExchangePrice_
    ) external view returns (DebtReserves memory d_);

    // reverts with FluidDexPricesAndExchangeRates(pex_);
    function getPricesAndExchangePrices() external;

    function constantsView() external view returns (ConstantViews memory constantsView_);

    function constantsView2() external view returns (ConstantViews2 memory constantsView2_);

    struct Oracle {
        uint twap1by0; // TWAP price
        uint lowestPrice1by0; // lowest price point
        uint highestPrice1by0; // highest price point
        uint twap0by1; // TWAP price
        uint lowestPrice0by1; // lowest price point
        uint highestPrice0by1; // highest price point
    }

    /// @dev This function allows users to swap a specific amount of input tokens for output tokens
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountIn_ The exact amount of input tokens to swap
    /// @param amountOutMin_ The minimum amount of output tokens the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountOut_
    /// @return amountOut_ The amount of output tokens received from the swap
    function swapIn(
        bool swap0to1_,
        uint256 amountIn_,
        uint256 amountOutMin_,
        address to_
    ) external payable returns (uint256 amountOut_);

    /// @dev Swap tokens with perfect amount out
    /// @param swap0to1_ Direction of swap. If true, swaps token0 for token1; if false, swaps token1 for token0
    /// @param amountOut_ The exact amount of tokens to receive after swap
    /// @param amountInMax_ Maximum amount of tokens to swap in
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with amountIn_
    /// @return amountIn_ The amount of input tokens used for the swap
    function swapOut(
        bool swap0to1_,
        uint256 amountOut_,
        uint256 amountInMax_,
        address to_
    ) external payable returns (uint256 amountIn_);

    /// @dev Deposit tokens in equal proportion to the current pool ratio
    /// @param shares_ The number of shares to mint
    /// @param maxToken0Deposit_ Maximum amount of token0 to deposit
    /// @param maxToken1Deposit_ Maximum amount of token1 to deposit
    /// @param estimate_ If true, function will revert with estimated deposit amounts without executing the deposit
    /// @return token0Amt_ Amount of token0 deposited
    /// @return token1Amt_ Amount of token1 deposited
    function depositPerfect(
        uint shares_,
        uint maxToken0Deposit_,
        uint maxToken1Deposit_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to withdraw a perfect amount of collateral liquidity
    /// @param shares_ The number of shares to withdraw
    /// @param minToken0Withdraw_ The minimum amount of token0 the user is willing to accept
    /// @param minToken1Withdraw_ The minimum amount of token1 the user is willing to accept
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ The amount of token0 withdrawn
    /// @return token1Amt_ The amount of token1 withdrawn
    function withdrawPerfect(
        uint shares_,
        uint minToken0Withdraw_,
        uint minToken1Withdraw_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to borrow tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to borrow
    /// @param minToken0Borrow_ Minimum amount of token0 to borrow
    /// @param minToken1Borrow_ Minimum amount of token1 to borrow
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with token0Amt_ & token1Amt_
    /// @return token0Amt_ Amount of token0 borrowed
    /// @return token1Amt_ Amount of token1 borrowed
    function borrowPerfect(
        uint shares_,
        uint minToken0Borrow_,
        uint minToken1Borrow_,
        address to_
    ) external returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to pay back borrowed tokens in equal proportion to the current debt pool ratio
    /// @param shares_ The number of shares to pay back
    /// @param maxToken0Payback_ Maximum amount of token0 to pay back
    /// @param maxToken1Payback_ Maximum amount of token1 to pay back
    /// @param estimate_ If true, function will revert with estimated payback amounts without executing the payback
    /// @return token0Amt_ Amount of token0 paid back
    /// @return token1Amt_ Amount of token1 paid back
    function paybackPerfect(
        uint shares_,
        uint maxToken0Payback_,
        uint maxToken1Payback_,
        bool estimate_
    ) external payable returns (uint token0Amt_, uint token1Amt_);

    /// @dev This function allows users to deposit tokens in any proportion into the col pool
    /// @param token0Amt_ The amount of token0 to deposit
    /// @param token1Amt_ The amount of token1 to deposit
    /// @param minSharesAmt_ The minimum amount of shares the user expects to receive
    /// @param estimate_ If true, function will revert with estimated shares without executing the deposit
    /// @return shares_ The amount of shares minted for the deposit
    function deposit(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw tokens in any proportion from the col pool
    /// @param token0Amt_ The amount of token0 to withdraw
    /// @param token1Amt_ The amount of token1 to withdraw
    /// @param maxSharesAmt_ The maximum number of shares the user is willing to burn
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The number of shares burned for the withdrawal
    function withdraw(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to borrow tokens in any proportion from the debt pool
    /// @param token0Amt_ The amount of token0 to borrow
    /// @param token1Amt_ The amount of token1 to borrow
    /// @param maxSharesAmt_ The maximum amount of shares the user is willing to receive
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with shares_
    /// @return shares_ The amount of borrow shares minted to represent the borrowed amount
    function borrow(
        uint token0Amt_,
        uint token1Amt_,
        uint maxSharesAmt_,
        address to_
    ) external returns (uint shares_);

    /// @dev This function allows users to payback tokens in any proportion to the debt pool
    /// @param token0Amt_ The amount of token0 to payback
    /// @param token1Amt_ The amount of token1 to payback
    /// @param minSharesAmt_ The minimum amount of shares the user expects to burn
    /// @param estimate_ If true, function will revert with estimated shares without executing the payback
    /// @return shares_ The amount of borrow shares burned for the payback
    function payback(
        uint token0Amt_,
        uint token1Amt_,
        uint minSharesAmt_,
        bool estimate_
    ) external payable returns (uint shares_);

    /// @dev This function allows users to withdraw their collateral with perfect shares in one token
    /// @param shares_ The number of shares to burn for withdrawal
    /// @param minToken0_ The minimum amount of token0 the user expects to receive (set to 0 if withdrawing in token1)
    /// @param minToken1_ The minimum amount of token1 the user expects to receive (set to 0 if withdrawing in token0)
    /// @param to_ Recipient of swapped tokens. If to_ == address(0) then out tokens will be sent to msg.sender. If to_ == ADDRESS_DEAD then function will revert with withdrawAmt_
    /// @return withdrawAmt_ The amount of tokens withdrawn in the chosen token
    function withdrawPerfectInOneToken(
        uint shares_,
        uint minToken0_,
        uint minToken1_,
        address to_
    ) external returns (
        uint withdrawAmt_
    );

    /// @dev This function allows users to payback their debt with perfect shares in one token
    /// @param shares_ The number of shares to burn for payback
    /// @param maxToken0_ The maximum amount of token0 the user is willing to pay (set to 0 if paying back in token1)
    /// @param maxToken1_ The maximum amount of token1 the user is willing to pay (set to 0 if paying back in token0)
    /// @param estimate_ If true, the function will revert with the estimated payback amount without executing the payback
    /// @return paybackAmt_ The amount of tokens paid back in the chosen token
    function paybackPerfectInOneToken(
        uint shares_,
        uint maxToken0_,
        uint maxToken1_,
        bool estimate_
    ) external payable returns (
        uint paybackAmt_
    );

    /// @dev the oracle assumes last set price of pool till the next swap happens.
    /// There's a possibility that during that time some interest is generated hence the last stored price is not the 100% correct price for the whole duration
    /// but the difference due to interest will be super low so this difference is ignored
    /// For example 2 swaps happened 10min (600 seconds) apart and 1 token has 10% higher interest than other.
    /// then that token will accrue about 10% * 600 / secondsInAYear = ~0.0002%
    /// @param secondsAgos_ array of seconds ago for which TWAP is needed. If user sends [10, 30, 60] then twaps_ will return [10-0, 30-10, 60-30]
    /// @return twaps_ twap price, lowest price (aka minima) & highest price (aka maxima) between secondsAgo checkpoints
    /// @return currentPrice_ price of pool after the most recent swap
    function oraclePrice(
        uint[] memory secondsAgos_
    ) external view returns (
        Oracle[] memory twaps_,
        uint currentPrice_
    );
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IFluidLiquidity } from "../../liquidity/interfaces/iLiquidity.sol";

interface IFluidReserveContract {
    function isRebalancer(address user) external returns (bool);

    function initialize(
        address[] memory _auths,
        address[] memory _rebalancers,
        IFluidLiquidity liquidity_,
        address owner_
    ) external;

    function rebalanceFToken(address protocol_) external;

    function rebalanceVault(address protocol_) external;

    function transferFunds(address token_) external;

    function getProtocolTokens(address protocol_) external;

    function updateAuth(address auth_, bool isAuth_) external;

    function updateRebalancer(address rebalancer_, bool isRebalancer_) external;

    function approve(address[] memory protocols_, address[] memory tokens_, uint256[] memory amounts_) external;

    function revoke(address[] memory protocols_, address[] memory tokens_) external;
}