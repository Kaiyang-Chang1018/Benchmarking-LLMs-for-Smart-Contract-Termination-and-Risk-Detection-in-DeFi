// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address} from "./Address.sol";
import {Context} from "./Context.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 */
abstract contract Multicall is Context {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Configurable Interface
/// @notice This interface defines the functions for manage market configurations
interface IConfigurable {
    struct MarketConfig {
        /// @notice The liquidation fee rate for per trader position,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 liquidationFeeRatePerPosition;
        /// @notice The maximum size rate for per position, denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxSizeRatePerPosition;
        /// @notice If the balance rate after increasing a long position is greater than this parameter,
        /// then the trading fee rate will be changed to the floating fee rate,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 openPositionThreshold;
        /// @notice The trading fee rate for taker increase or decrease positions,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 tradingFeeRate;
        /// @notice The maximum leverage for per trader position, for example, 100 means the maximum leverage
        /// is 100 times
        uint8 maxLeveragePerPosition;
        /// @notice The market token decimals
        uint8 decimals;
        /// @notice A system variable to calculate the `spread`
        uint120 liquidityScale;
        /// @notice The protocol fee rate as a percentage of trading fee,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 protocolFeeRate;
        /// @notice The maximum floating fee rate for increasing long position,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxFeeRate;
        /// @notice A system variable to calculate the `spreadFactor`, in seconds
        uint24 riskFreeTime;
        /// @notice The minimum entry margin required for per trader position
        uint64 minMarginPerPosition;
        /// @notice If balance rate is less than minMintingRate, the minting is disabled,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 minMintingRate;
        /// @notice If balance rate is greater than maxBurningRate, the burning is disabled,
        /// denominated in thousandths of a bip (i.e. 1e-7)
        uint24 maxBurningRate;
        /// @notice The liquidation execution fee for LP and trader positions
        uint64 liquidationExecutionFee;
        /// @notice Whether the liquidity buffer module is enabled when decreasing position
        bool liquidityBufferModuleEnabled;
        /// @notice If the total supply of the stable coin reach stableCoinSupplyCap, the minting is disabled.
        uint64 stableCoinSupplyCap;
        /// @notice The capacity of the liquidity
        uint120 liquidityCap;
    }

    /// @notice Emitted when the market is enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param cfg The new market configuration
    event MarketConfigEnabled(IERC20 indexed market, MarketConfig cfg);

    /// @notice Emitted when a market configuration is changed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param cfg The new market configuration
    event MarketConfigChanged(IERC20 indexed market, MarketConfig cfg);

    /// @notice Market is already enabled
    error MarketAlreadyEnabled(IERC20 market);
    /// @notice Market is not enabled
    error MarketNotEnabled(IERC20 market);
    /// @notice Invalid maximum leverage for trader positions
    error InvalidMaxLeveragePerPosition(uint8 maxLeveragePerPosition);
    /// @notice Invalid liquidation fee rate for trader positions
    error InvalidLiquidationFeeRatePerPosition(uint24 liquidationFeeRatePerPosition);
    /// @notice Invalid max size per rate for per position
    error InvalidMaxSizeRatePerPosition(uint24 maxSizeRatePerPosition);
    /// @notice Invalid liquidity capacity
    error InvalidLiquidityCap(uint120 liquidityCap);
    /// @notice Invalid trading fee rate
    error InvalidTradingFeeRate(uint24 tradingFeeRate);
    /// @notice Invalid protocol fee rate
    error InvalidProtocolFeeRate(uint24 protocolFeeRate);
    /// @notice Invalid min minting rate
    error InvalidMinMintingRate(uint24 minMintingRate);
    /// @notice Invalid max burning rate
    error InvalidMaxBurningRate(uint24 maxBurnningRate);
    /// @notice Invalid open position threshold
    error InvalidOpenPositionThreshold(uint24 openPositionThreshold);
    /// @notice Invalid max fee rate
    error InvalidMaxFeeRate(uint24 maxFeeRate);
    /// @notice The risk free time is zero, which is not allowed
    error ZeroRiskFreeTime();
    /// @notice The liquidity scale is zero, which is not allowed
    error ZeroLiquidityScale();
    /// @notice Invalid stable coin supply capacity
    error InvalidStableCoinSupplyCap(uint256 stablecoinSupplyCap);
    /// @notice Invalid decimals
    error InvalidDecimals(uint8 decimals);

    /// @notice Checks if a market is enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @return True if the market is enabled, false otherwise
    function isEnabledMarket(IERC20 market) external view returns (bool);

    /// @notice Get the information of market configuration
    /// @param market The target market contract address, such as the contract address of WETH
    function marketConfigs(IERC20 market) external view returns (MarketConfig memory);

    /// @notice Enable the market
    /// @dev The call will fail if caller is not the governor or the market is already enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param tokenSymbol The symbol of the LP token
    /// @param cfg The market configuration
    function enableMarket(IERC20 market, string calldata tokenSymbol, MarketConfig calldata cfg) external;

    /// @notice Update a market configuration
    /// @dev The call will fail if caller is not the governor or the market is not enabled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param newCfg The new market configuration
    function updateMarketConfig(IERC20 market, MarketConfig calldata newCfg) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILPToken is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IMarketErrors {
    /// @notice Failed to transfer ETH
    error FailedTransferETH();
    /// @notice Invalid caller
    error InvalidCaller(address requiredCaller);
    /// @notice Insufficient size to decrease
    error InsufficientSizeToDecrease(uint128 requiredSize, uint128 size);
    /// @notice Insufficient margin
    error InsufficientMargin();
    /// @notice Position not found
    error PositionNotFound(address requiredAccount);
    /// @notice Size exceeds max size per position
    error SizeExceedsMaxSizePerPosition(uint256 requiredSize, uint256 maxSizePerPosition);
    /// @notice Size exceeds max size
    error SizeExceedsMaxSize(uint256 requiredSize, uint256 maxSize);
    /// @notice Insufficient liquidity to decrease
    error InsufficientLiquidityToDecrease(uint256 liquidity, uint128 requiredLiquidity);
    /// @notice Liquidity Cap exceeded
    error LiquidityCapExceeded(uint128 liquidityBefore, uint96 liquidityDelta, uint120 liquidityCap);
    /// @notice Balance Rate Cap exceeded
    error BalanceRateCapExceeded();
    /// @notice Error thrown when min minting size cap is not met
    error MinMintingSizeCapNotMet(uint128 netSize, uint128 sizeDelta, uint128 minMintingSizeCap);
    /// @notice Error thrown when max burning size cap is exceeded
    error MaxBurningSizeCapExceeded(uint128 netSize, uint128 sizeDelta, uint256 maxBurningSizeCap);
    /// @notice Insufficient balance
    error InsufficientBalance(uint256 balance, uint256 requiredAmount);
    /// @notice Leverage is too high
    error LeverageTooHigh(uint256 margin, uint128 size, uint8 maxLeverage);
    /// @notice Position margin rate is too low
    error MarginRateTooLow(int256 margin, uint256 maintenanceMargin);
    /// @notice Position margin rate is too high
    error MarginRateTooHigh(int256 margin, uint256 maintenanceMargin);
    error InvalidAmount(uint128 requiredAmount, uint128 pusdBalance);
    error InvalidSize();
    /// @notice Stable Coin Supply Cap exceeded
    error StableCoinSupplyCapExceeded(uint256 supplyCap, uint256 totalSupply, uint256 amountDelta);
    /// @notice Error thrown when the pay amount is less than the required amount
    error TooLittlePayAmount(uint128 requiredAmount, uint128 payAmount);
    /// @notice Error thrown when the pay amount is not equal to the required amount
    error UnexpectedPayAmount(uint128 requiredAmount, uint128 payAmount);
    error NegativeReceiveAmount(int256 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./ILPToken.sol";

/// @notice Interface for managing liquidity of the protocol
interface IMarketLiquidity {
    /// @notice Emitted when the global liquidity is increased by trading fee
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityFee The increased liquidity fee
    event GlobalLiquidityIncreasedByTradingFee(IERC20 indexed market, uint96 liquidityFee);

    /// @notice Emitted when the global liquidity is settled
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param sizeDelta The change in the global liquidity
    /// @param realizedPnL The realized PnL of the global liquidity
    /// @param entryPriceAfter The entry price after the settlement
    event GlobalLiquiditySettled(IERC20 indexed market, int256 sizeDelta, int256 realizedPnL, uint64 entryPriceAfter);

    /// @notice Emitted when a new LP Token is deployed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param token The LP Token contract address
    event LPTokenDeployed(IERC20 indexed market, ILPToken indexed token);

    /// @notice Emitted when the LP Token is minted
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the LP Token
    /// @param receiver The address to receive the minted LP Token
    /// @param liquidity The liquidity provided by the LP
    /// @param tokenValue The LP Token to be minted
    event LPTMinted(
        IERC20 indexed market,
        address indexed account,
        address indexed receiver,
        uint96 liquidity,
        uint64 tokenValue
    );

    /// @notice Emitted when the LP Token is burned
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the LP Token
    /// @param receiver The address to receive the margin
    /// @param liquidity The liquidity to be returned to the LP
    /// @param tokenValue The LP Token to be burned
    event LPTBurned(
        IERC20 indexed market,
        address indexed account,
        address indexed receiver,
        uint96 liquidity,
        uint64 tokenValue
    );

    /// @notice Mint the LP Token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address to mint the liquidity. The parameter is only used for emitting event
    /// @param receiver The address to receive the minted LP Token
    /// @return tokenValue The LP Token to be minted
    function mintLPT(IERC20 market, address account, address receiver) external returns (uint64 tokenValue);

    /// @notice Burn the LP Token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address to burn the liquidity. The parameter is only used for emitting event
    /// @param receiver The address to receive the returned liquidity
    /// @return liquidity The liquidity to be returned to the LP
    function burnLPT(IERC20 market, address account, address receiver) external returns (uint96 liquidity);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPSM.sol";
import "./IConfigurable.sol";
import "./IMarketErrors.sol";
import "./IPUSDManager.sol";
import "./IMarketPosition.sol";
import "./IMarketLiquidity.sol";
import "../../oracle/interfaces/IPriceFeed.sol";
import "../../plugins/interfaces/IPluginManager.sol";
import "../../oracle/interfaces/IPriceFeed.sol";

interface IMarketManager is
    IMarketErrors,
    IMarketPosition,
    IMarketLiquidity,
    IPUSDManager,
    IConfigurable,
    IPluginManager,
    IPriceFeed,
    IPSM
{
    struct LiquidityBufferModule {
        /// @notice The debt of the liquidity buffer module
        uint128 pusdDebt;
        /// @notice The token payback of the liquidity buffer module
        uint128 tokenPayback;
    }

    struct PackedState {
        /// @notice The spread factor used to calculate spread
        int256 spreadFactorX96;
        /// @notice Last trading timestamp in seconds since Unix epoch
        uint64 lastTradingTimestamp;
        /// @notice The sum of long position sizes
        uint128 longSize;
        /// @notice The entry price of the net position
        uint64 lpEntryPrice;
        /// @notice The total liquidity of all LPs
        uint128 lpLiquidity;
        /// @notice The size of the net position held by all LPs
        uint128 lpNetSize;
    }

    struct State {
        /// @notice The packed state of the market
        PackedState packedState;
        /// @notice The value is used to track the global PUSD position
        GlobalPUSDPosition globalPUSDPosition;
        /// @notice Mapping of account to long position
        mapping(address account => Position) longPositions;
        /// @notice The value is used to track the liquidity buffer module status
        LiquidityBufferModule liquidityBufferModule;
        /// @notice The value is used to track the remaining protocol fee of the market
        uint128 protocolFee;
        /// @notice The value is used to track the token balance of the market
        uint128 tokenBalance;
        /// @notice The margin of the global stability fund
        uint256 globalStabilityFund;
    }

    /// @notice Emitted when the protocol fee is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The increased protocol fee
    event ProtocolFeeIncreased(IERC20 indexed market, uint96 amount);

    /// @notice Emitted when the protocol fee is collected
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The collected protocol fee
    event ProtocolFeeCollected(IERC20 indexed market, uint128 amount);

    /// @notice Emitted when the stability fund is used by `Gov`
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver The address that receives the stability fund
    /// @param stabilityFundDelta The amount of stability fund used
    event GlobalStabilityFundGovUsed(IERC20 indexed market, address indexed receiver, uint128 stabilityFundDelta);

    /// @notice Emitted when the liquidity of the stability fund is increased by liquidation
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidationFee The amount of the liquidation fee that is added to the stability fund.
    event GlobalStabilityFundIncreasedByLiquidation(IERC20 indexed market, uint96 liquidationFee);

    /// @notice Emitted when the liquidity of the stability fund is increased by spread
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param spread The spread incurred by the position
    event GlobalStabilityFundIncreasedBySpread(IERC20 indexed market, uint96 spread);

    /// @notice Emitted when the liquidity buffer module debt is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param pusdDebtDelta The increase in the debt of the LBM module
    /// @param tokenPaybackDelta The increase in the token payback of the LBM module
    event LiquidityBufferModuleDebtIncreased(
        IERC20 market,
        address account,
        uint128 pusdDebtDelta,
        uint128 tokenPaybackDelta
    );

    /// @notice Emitted when the liquidity buffer module debt is repaid
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param pusdDebtDelta The decrease in the debt of the LBM module
    /// @param tokenPaybackDelta The decrease in the token payback of the LBM module
    event LiquidityBufferModuleDebtRepaid(
        IERC20 market,
        address account,
        uint128 pusdDebtDelta,
        uint128 tokenPaybackDelta
    );

    /// @notice Emitted when the spread factor is changed
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param spreadFactorAfterX96 The spread factor after the trade, as a Q160.96
    event SpreadFactorChanged(IERC20 market, int256 spreadFactorAfterX96);

    /// @notice Get the packed state of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function packedStates(IERC20 market) external view returns (PackedState memory);

    /// @notice Get the remaining protocol fee of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function protocolFees(IERC20 market) external view returns (uint128);

    /// @notice Get the token balance of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function tokenBalances(IERC20 market) external view returns (uint128);

    /// @notice Collect the protocol fee of the given market
    /// @dev This function can be called without authorization
    /// @param market The target market contract address, such as the contract address of WETH
    function collectProtocolFee(IERC20 market) external;

    /// @notice Get the information of global stability fund
    /// @param market The target market contract address, such as the contract address of WETH
    function globalStabilityFunds(IERC20 market) external view returns (uint256);

    /// @notice `Gov` uses the stability fund
    /// @dev The call will fail if the caller is not the `Gov` or the stability fund is insufficient
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver The address to receive the stability fund
    /// @param stabilityFundDelta The amount of stability fund to be used
    function govUseStabilityFund(IERC20 market, address receiver, uint128 stabilityFundDelta) external;

    /// @notice Repay the liquidity buffer debt of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address for debt repayment
    /// @param receiver The address to receive the payback token
    /// @return receiveAmount The amount of payback token received
    function repayLiquidityBufferDebt(
        IERC20 market,
        address account,
        address receiver
    ) external returns (uint128 receiveAmount);

    /// @notice Get the liquidity buffer module of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    /// @return liquidityBufferModule The liquidity buffer module data
    function liquidityBufferModules(
        IERC20 market
    ) external view returns (LiquidityBufferModule memory liquidityBufferModule);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Side} from "../../types/Side.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Interface for managing market positions.
/// @dev The market position is the core component of the protocol, which stores the information of
/// all trader's positions.
interface IMarketPosition {
    struct Position {
        /// @notice The margin of the position
        uint96 margin;
        /// @notice The size of the position
        uint96 size;
        /// @notice The entry price of the position
        uint64 entryPrice;
    }

    /// @notice Emitted when the position is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The increased margin
    /// @param marginAfter The adjusted margin
    /// @param sizeDelta The increased size
    /// @param indexPrice The index price at which the position is increased.
    /// If only adding margin, it will be 0
    /// @param entryPriceAfter The adjusted entry price of the position
    /// @param tradingFee The trading fee paid by the position
    /// @param spread The spread incurred by the position
    event PositionIncreased(
        IERC20 indexed market,
        address indexed account,
        uint96 marginDelta,
        uint96 marginAfter,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 entryPriceAfter,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Emitted when the position is decreased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The decreased margin
    /// @param marginAfter The adjusted margin
    /// @param sizeDelta The decreased size
    /// @param indexPrice The index price at which the position is decreased
    /// @param realizedPnL The realized PnL
    /// @param tradingFee The trading fee paid by the position
    /// @param spread The spread incurred by the position
    /// @param receiver The address that receives the margin
    event PositionDecreased(
        IERC20 indexed market,
        address indexed account,
        uint96 marginDelta,
        uint96 marginAfter,
        uint96 sizeDelta,
        uint64 indexPrice,
        int256 realizedPnL,
        uint96 tradingFee,
        uint96 spread,
        address receiver
    );

    /// @notice Emitted when a position is liquidated
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidator The address that executes the liquidation of the position
    /// @param account The owner of the position
    /// @param sizeDelta The liquidated size
    /// @param indexPrice The index price at which the position is liquidated
    /// @param liquidationPrice The liquidation price of the position
    /// @param tradingFee The trading fee paid by the position
    /// @param liquidationFee The liquidation fee paid by the position
    /// @param liquidationExecutionFee The liquidation execution fee paid by the position
    /// @param feeReceiver The address that receives the liquidation execution fee
    event PositionLiquidated(
        IERC20 indexed market,
        address indexed liquidator,
        address indexed account,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 liquidationPrice,
        uint96 tradingFee,
        uint96 liquidationFee,
        uint64 liquidationExecutionFee,
        address feeReceiver
    );

    /// @notice Get the information of a long position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    function longPositions(IERC20 market, address account) external view returns (Position memory);

    /// @notice Increase the margin or size of a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param sizeDelta The increase in size, which can be 0
    /// @return spread The spread incurred by the position
    function increasePosition(IERC20 market, address account, uint96 sizeDelta) external returns (uint96 spread);

    /// @notice Decrease the margin or size of a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param marginDelta The decrease in margin, which can be 0. If the position size becomes zero after
    /// the decrease, the marginDelta will be ignored, and all remaining margin will be returned
    /// @param sizeDelta The decrease in size, which can be 0
    /// @param receiver The address to receive the margin
    /// @return spread The spread incurred by the position
    /// @return actualMarginDelta The actual decrease in margin
    function decreasePosition(
        IERC20 market,
        address account,
        uint96 marginDelta,
        uint96 sizeDelta,
        address receiver
    ) external returns (uint96 spread, uint96 actualMarginDelta);

    /// @notice Liquidate a position
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param feeReceiver The address that receives the liquidation execution fee
    function liquidatePosition(IERC20 market, address account, address feeReceiver) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Peg Stability Module interface
interface IPSM {
    struct CollateralState {
        uint120 cap;
        uint8 decimals;
        uint128 balance;
    }

    /// @notice Emitted when the collateral cap is updated
    event PSMCollateralUpdated(IERC20 collateral, uint120 cap);

    /// @notice Emit when PUSD is minted through the PSM module
    /// @param collateral The collateral token
    /// @param receiver Address to receive PUSD
    /// @param payAmount The amount of collateral paid
    /// @param receiveAmount The amount of PUSD minted
    event PSMMinted(IERC20 indexed collateral, address indexed receiver, uint96 payAmount, uint64 receiveAmount);

    /// @notice Emitted when PUSD is burned through the PSM module
    /// @param collateral The collateral token
    /// @param receiver Address to receive collateral
    /// @param payAmount The amount of PUSD burned
    /// @param receiveAmount The amount of collateral received
    event PSMBurned(IERC20 indexed collateral, address indexed receiver, uint64 payAmount, uint96 receiveAmount);

    /// @notice Invalid collateral token
    error InvalidCollateral();

    /// @notice Invalid collateral decimals
    error InvalidCollateralDecimals(uint8 decimals);

    /// @notice The PSM balance is insufficient
    error InsufficientPSMBalance(uint96 receiveAmount, uint128 balance);

    /// @notice Get the collateral state
    function psmCollateralStates(IERC20 collateral) external view returns (CollateralState memory);

    /// @notice Update the collateral cap
    /// @param collateral The collateral token
    /// @param cap The new cap
    function updatePSMCollateralCap(IERC20 collateral, uint120 cap) external;

    /// @notice Mint PUSD
    /// @param collateral The collateral token
    /// @param receiver Address to receive PUSD
    /// @return receiveAmount The amount of PUSD minted
    function psmMintPUSD(IERC20 collateral, address receiver) external returns (uint64 receiveAmount);

    /// @notice Burn PUSD
    /// @param collateral The collateral token
    /// @param receiver Address to receive collateral
    /// @return receiveAmount The amount of collateral received
    function psmBurnPUSD(IERC20 collateral, address receiver) external returns (uint96 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPUSDManagerCallback.sol";

/// @notice Interface for managing the minting and burning of PUSD.
interface IPUSDManager {
    struct GlobalPUSDPosition {
        /// @notice The total PUSD supply of the current market
        uint64 totalSupply;
        /// @notice The size of the position
        uint128 size;
        /// @notice The entry price of the position
        uint64 entryPrice;
    }

    /// @notice Emitted when the PUSD position is increased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver Address to receive PUSD
    /// @param sizeDelta The size of the position to increase
    /// @param indexPrice The index price at which the position is increased
    /// @param entryPriceAfter The adjusted entry price of the position
    /// @param payAmount The amount of token to pay
    /// @param receiveAmount The amount of PUSD to mint
    /// @param tradingFee The amount of trading fee to pay
    /// @param spread The spread incurred by the position
    event PUSDPositionIncreased(
        IERC20 indexed market,
        address indexed receiver,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 entryPriceAfter,
        uint96 payAmount,
        uint64 receiveAmount,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Emitted when the PUSD position is decreased
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param receiver Address to receive token
    /// @param sizeDelta The size of the position to decrease
    /// @param indexPrice The index price at which the position is decreased
    /// @param payAmount The amount of PUSD to burn
    /// @param receiveAmount The amount of token to receive
    /// @param realizedPnL The realized profit and loss of the position
    /// @param tradingFee The amount of trading fee to pay
    /// @param spread The spread incurred by the position
    event PUSDPositionDecreased(
        IERC20 indexed market,
        address indexed receiver,
        uint96 sizeDelta,
        uint64 indexPrice,
        uint64 payAmount,
        uint96 receiveAmount,
        int256 realizedPnL,
        uint96 tradingFee,
        uint96 spread
    );

    /// @notice Get the global PUSD position of the given market
    /// @param market The target market contract address, such as the contract address of WETH
    function globalPUSDPositions(IERC20 market) external view returns (GlobalPUSDPosition memory);

    /// @notice Mint PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of token to pay,
    /// otherwise, it is the amount of PUSD to mint
    /// @param callback Address to callback after minting
    /// @param data Any data to be passed to the callback
    /// @param receiver Address to receive PUSD
    /// @return payAmount The amount of token to pay
    /// @return receiveAmount The amount of PUSD to receive
    function mintPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        IPUSDManagerCallback callback,
        bytes calldata data,
        address receiver
    ) external returns (uint96 payAmount, uint64 receiveAmount);

    /// @notice Burn PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount When `exactIn` is true, it is the amount of PUSD to burn,
    /// otherwise, it is the amount of token to receive
    /// @param callback Address to callback after burning
    /// @param data Any data to be passed to the callback
    /// @param receiver Address to receive token
    /// @return payAmount The amount of PUSD to pay
    /// @return receiveAmount The amount of token to receive
    function burnPUSD(
        IERC20 market,
        bool exactIn,
        uint96 amount,
        IPUSDManagerCallback callback,
        bytes calldata data,
        address receiver
    ) external returns (uint64 payAmount, uint96 receiveAmount);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Callback for IPUSDManager.mint and IPUSDManager.burn
interface IPUSDManagerCallback {
    /// @notice Called after executing a mint or burn operation
    /// @dev In this implementation, you are required to pay the amount of `payAmount` to the caller.
    /// @dev In this implementation, you MUST check that the caller is IPUSDManager.
    /// @param payToken The token to pay
    /// @param payAmount The amount of token to pay
    /// @param receiveAmount The amount of token to receive
    /// @param data The data passed to the original `mint` or `burn` function
    function PUSDManagerCallback(IERC20 payToken, uint96 payAmount, uint96 receiveAmount, bytes calldata data) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

contract Governable {
    address private _gov;
    address private _pendingGov;

    event ChangeGovStarted(address indexed previousGov, address indexed newGov);
    event GovChanged(address indexed previousGov, address indexed newGov);

    error Forbidden();

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    constructor(address _initialGov) {
        _changeGov(_initialGov);
    }

    function gov() public view virtual returns (address) {
        return _gov;
    }

    function pendingGov() public view virtual returns (address) {
        return _pendingGov;
    }

    function changeGov(address _newGov) public virtual onlyGov {
        _pendingGov = _newGov;
        emit ChangeGovStarted(_gov, _newGov);
    }

    function acceptGov() public virtual {
        if (msg.sender != _pendingGov) revert Forbidden();

        delete _pendingGov;
        _changeGov(msg.sender);
    }

    function _changeGov(address _newGov) internal virtual {
        address previousGov = _gov;
        _gov = _newGov;
        emit GovChanged(previousGov, _newGov);
    }

    function _onlyGov() internal view {
        if (msg.sender != _gov) revert Forbidden();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Governable.sol";

abstract contract GovernableProxy {
    Governable private _impl;

    error Forbidden();

    modifier onlyGov() {
        _onlyGov();
        _;
    }

    constructor(Governable _newImpl) {
        _impl = _newImpl;
    }

    function _changeImpl(Governable _newGov) public virtual onlyGov {
        _impl = _newGov;
    }

    function gov() public view virtual returns (address) {
        return _impl.gov();
    }

    function _onlyGov() internal view {
        if (msg.sender != _impl.gov()) revert Forbidden();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.26;

import "../types/PackedValue.sol";
import "../core/interfaces/IMarketManager.sol";
import "../plugins/interfaces/ILiquidator.sol";
import "../plugins/interfaces/IPositionRouter.sol";
import "../plugins/interfaces/IPositionRouter2.sol";
import "../governance/GovernableProxy.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "../plugins/interfaces/IBalanceRateBalancer.sol";

/// @notice MixedExecutor is a contract that executes multiple calls in a single transaction
contract MixedExecutor is Multicall, GovernableProxy {
    /// @notice The address of liquidator
    ILiquidator public immutable liquidator;
    /// @notice The address of position router
    IPositionRouter public immutable positionRouter;
    /// @notice The address of position router2
    IPositionRouter2 public immutable positionRouter2;
    /// @notice The address of market manager
    IMarketManager public immutable marketManager;
    /// @notice The address of balance rate balancer
    IBalanceRateBalancer public immutable balanceRateBalancer;

    /// @notice The executors
    mapping(address => bool) public executors;

    /// @notice Emitted when an executor is updated
    /// @param executor The address of executor to update
    /// @param active Updated status
    event ExecutorUpdated(address indexed executor, bool indexed active);

    /// @notice Emitted when the position liquidate failed
    /// @dev The event is emitted when the liquidate is failed after the execution error
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The address of account
    /// @param shortenedReason The shortened reason of the execution error
    event LiquidatePositionFailed(IERC20 indexed market, address indexed account, bytes4 shortenedReason);

    /// @notice Error thrown when the execution error and `requireSuccess` is set to true
    error ExecutionFailed(bytes reason);

    modifier onlyExecutor() {
        if (!executors[msg.sender]) revert Forbidden();
        _;
    }

    constructor(
        Governable _govImpl,
        ILiquidator _liquidator,
        IPositionRouter _positionRouter,
        IPositionRouter2 _positionRouter2,
        IMarketManager _marketManager,
        IBalanceRateBalancer _balanceRateBalancer
    ) GovernableProxy(_govImpl) {
        (liquidator, positionRouter, positionRouter2) = (_liquidator, _positionRouter, _positionRouter2);
        marketManager = _marketManager;
        balanceRateBalancer = _balanceRateBalancer;
    }

    /// @notice Set executor status active or not
    /// @param _executor Executor address
    /// @param _active Status of executor permission to set
    function setExecutor(address _executor, bool _active) external virtual onlyGov {
        executors[_executor] = _active;
        emit ExecutorUpdated(_executor, _active);
    }

    /// @notice Update price
    function updatePrice(PackedValue _packedValue) external virtual onlyExecutor {
        marketManager.updatePrice(_packedValue);
    }

    /// @notice Try to execute mint LP token request. If the request is not executable, cancel it.
    /// @param _param The mint LPT request id calculation param
    function executeOrCancelMintLPT(
        IPositionRouter2.MintLPTRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter2.executeOrCancelMintLPT(_param, payable(msg.sender));
    }

    /// @notice Try to execute burn LP token request. If the request is not executable, cancel it.
    /// @param _param The burn LPT request id calculation param
    function executeOrCancelBurnLPT(
        IPositionRouter2.BurnLPTRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter2.executeOrCancelBurnLPT(_param, payable(msg.sender));
    }

    /// @notice Try to execute increase position request. If the request is not executable, cancel it.
    /// @param _param The increase position request id calculation param
    function executeOrCancelIncreasePosition(
        IPositionRouter.IncreasePositionRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelIncreasePosition(_param, payable(msg.sender));
    }

    /// @notice Try to execute decrease position request. If the request is not executable, cancel it.
    /// @param _param The decrease position request id calculation param
    function executeOrCancelDecreasePosition(
        IPositionRouter.DecreasePositionRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelDecreasePosition(_param, payable(msg.sender));
    }

    /// @notice Try to Execute mint PUSD request. If the request is not executable, cancel it.
    /// @param _param The mint PUSD request id calculation param
    function executeOrCancelMintPUSD(
        IPositionRouter.MintPUSDRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelMintPUSD(_param, payable(msg.sender));
    }

    /// @notice Try to execute burn request. If the request is not executable, cancel it.
    /// @param _param The burn PUSD request id calculation param
    function executeOrCancelBurnPUSD(
        IPositionRouter.BurnPUSDRequestIdParam calldata _param
    ) external virtual onlyExecutor {
        positionRouter.executeOrCancelBurnPUSD(_param, payable(msg.sender));
    }

    /// @notice Collect protocol fee
    function collectProtocolFee(IERC20 _market) external virtual onlyExecutor {
        marketManager.collectProtocolFee(_market);
    }

    /// @notice Collect protocol fee batch
    /// @param _markets The array of market address to collect protocol fee
    function collectProtocolFeeBatch(IERC20[] calldata _markets) external virtual onlyExecutor {
        for (uint8 i; i < _markets.length; ++i) {
            marketManager.collectProtocolFee(_markets[i]);
        }
    }

    /// @notice Liquidate a position
    /// @param _market The market address
    /// @param _packedValue The packed values of the account and require success flag:
    /// bit 0-159 represent the account, and bit 160 represent the require success flag
    function liquidatePosition(IERC20 _market, PackedValue _packedValue) external virtual onlyExecutor {
        address account = _packedValue.unpackAddress(0);
        bool requireSuccess = _packedValue.unpackBool(160);

        try liquidator.liquidatePosition(_market, payable(account), payable(msg.sender)) {} catch (
            bytes memory reason
        ) {
            if (requireSuccess) revert ExecutionFailed(reason);

            emit LiquidatePositionFailed(_market, account, _decodeShortenedReason(reason));
        }
    }

    /// @notice Try to execute increase balance rate request. If the request is not executable, cancel it.
    /// @param _param The increase balance rate request id calculation param
    /// @param _shouldCancelOnFail should cancel request when execute failed
    function executeOrCancelIncreaseBalanceRate(
        IBalanceRateBalancer.IncreaseBalanceRateRequestIdParam calldata _param,
        bool _shouldCancelOnFail
    ) external virtual onlyExecutor {
        balanceRateBalancer.executeOrCancelIncreaseBalanceRate(_param, _shouldCancelOnFail, payable(msg.sender));
    }

    /// @notice Decode the shortened reason of the execution error
    /// @dev The default implementation is to return the first 4 bytes of the reason, which is typically the
    /// selector for the error type
    /// @param _reason The reason of the execution error
    /// @return The shortened reason of the execution error
    function _decodeShortenedReason(bytes memory _reason) internal pure virtual returns (bytes4) {
        return bytes4(_reason);
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IChainLinkAggregator {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IChainLinkAggregator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../../types/PackedValue.sol";

interface IPriceFeed {
    struct PriceFeedConfig {
        /// @notice ChainLink contract address for corresponding market
        IChainLinkAggregator refPriceFeed;
        /// @notice Expected update interval of chain link price feed
        uint32 refHeartbeatDuration;
        /// @notice Maximum cumulative change ratio difference between prices and ChainLink price
        /// within a period of time.
        uint48 maxCumulativeDeltaDiff;
        /// @notice Decimals of ChainLink price
        uint8 refPriceDecimals;
    }

    struct PriceDataItem {
        /// @notice previous round id
        uint32 prevRound;
        /// @notice previous ChainLink price
        uint64 prevRefPrice;
        /// @notice cumulative value of the ChainLink price change ratio in a round
        uint64 cumulativeRefPriceDelta;
        /// @notice previous market price
        uint64 prevPrice;
        /// @notice cumulative value of the market price change ratio in a round
        uint64 cumulativePriceDelta;
    }

    struct PricePack {
        /// @notice The timestamp when updater uploads the price
        uint32 updateTimestamp;
        /// @notice Calculated maximum price
        uint64 maxPrice;
        /// @notice Calculated minimum price
        uint64 minPrice;
        /// @notice previous round id
        uint32 prevRound;
        /// @notice previous ChainLink price
        uint64 prevRefPrice;
        /// @notice cumulative value of the ChainLink price change ratio in a round
        uint64 cumulativeRefPriceDelta;
        /// @notice previous market price
        uint64 prevPrice;
        /// @notice cumulative value of the market price change ratio in a round
        uint64 cumulativePriceDelta;
    }

    /// @notice Emitted when market price updated
    /// @param market Market address
    /// @param price The price passed in by updater
    /// @param maxPrice Calculated maximum price
    /// @param minPrice Calculated minimum price
    event PriceUpdated(IERC20 indexed market, uint64 price, uint64 minPrice, uint64 maxPrice);

    /// @notice Emitted when maxCumulativeDeltaDiff exceeded
    /// @param market Market address
    /// @param price The price passed in by updater
    /// @param refPrice The price provided by ChainLink
    /// @param cumulativeDelta The cumulative value of the price change ratio
    /// @param cumulativeRefDelta The cumulative value of the ChainLink price change ratio
    event MaxCumulativeDeltaDiffExceeded(
        IERC20 indexed market,
        uint64 price,
        uint64 refPrice,
        uint64 cumulativeDelta,
        uint64 cumulativeRefDelta
    );

    /// @notice Price not be initialized
    error NotInitialized();

    /// @notice Reference price feed not set
    error ReferencePriceFeedNotSet();

    /// @notice Invalid reference price
    /// @param referencePrice Reference price
    error InvalidReferencePrice(int256 referencePrice);

    /// @notice Reference price timeout
    /// @param elapsed The time elapsed since the last price update.
    error ReferencePriceTimeout(uint256 elapsed);

    /// @notice Invalid update timestamp
    /// @param timestamp Update timestamp
    error InvalidUpdateTimestamp(uint32 timestamp);

    /// @notice Update market price feed config
    /// @param market Market address
    /// @param priceFeed ChainLink price feed
    /// @param refHeartBeatDuration Expected update interval of chain link price feed
    /// @param maxCumulativeDeltaDiff Maximum cumulative change ratio difference between prices and ChainLink price
    function updateMarketPriceFeedConfig(
        IERC20 market,
        IChainLinkAggregator priceFeed,
        uint32 refHeartBeatDuration,
        uint48 maxCumulativeDeltaDiff
    ) external;

    /// @notice Get market price feed config
    /// @param market Market address
    /// @return config The price feed config
    function marketPriceFeedConfigs(IERC20 market) external view returns (PriceFeedConfig memory config);

    /// @notice update global price feed config
    /// @param maxDeviationRatio Maximum deviation ratio between ChainLink price and market price
    /// @param cumulativeRoundDuration The duration of the round for the cumulative value of the price change ratio
    /// @param updateTxTimeout The maximum time allowed for the transaction to update the price
    /// @param ignoreReferencePriceFeedError Whether to ignore the error of the reference price feed not settled
    function updateGlobalPriceFeedConfig(
        uint24 maxDeviationRatio,
        uint32 cumulativeRoundDuration,
        uint32 updateTxTimeout,
        bool ignoreReferencePriceFeedError
    ) external;

    /// @notice Get global price feed config
    /// @return maxDeviationRatio Maximum deviation ratio between ChainLink price and market price
    /// @return cumulativeRoundDuration The duration of the round for the cumulative value of the price change ratio
    /// @return updateTxTimeout The maximum time allowed for the transaction to update the price
    /// @return ignoreReferencePriceFeedError Whether to ignore the error of the reference price feed not settled
    function globalPriceFeedConfig()
        external
        view
        returns (
            uint24 maxDeviationRatio,
            uint32 cumulativeRoundDuration,
            uint32 updateTxTimeout,
            bool ignoreReferencePriceFeedError
        );

    /// @notice Update updater
    /// @param account The account to set
    function updateUpdater(address account) external;

    /// @notice Get market price
    /// @param market Market address
    /// @return minPrice Minimum price
    /// @return maxPrice Maximum price
    function getPrice(IERC20 market) external view returns (uint64 minPrice, uint64 maxPrice);

    /// @notice Check if the account is updater
    /// @param account The account to check
    /// @return active True if the account is updater
    function isUpdater(address account) external view returns (bool active);

    /// @notice Update market price
    /// @param packedValue The packed values of the order index and require success flag: bit 0-159 represent
    /// market address, bit 160-223 represent the price and bit 223-255 represent the update timestamp
    function updatePrice(PackedValue packedValue) external;

    /// @notice Get market price data packed data
    /// @param market Market address
    /// @return pack The price packed data
    function marketPricePacks(IERC20 market) external view returns (PricePack memory pack);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../core/interfaces/IPUSDManagerCallback.sol";

interface IBalanceRateBalancer is IPUSDManagerCallback {
    struct IncreaseBalanceRateRequestIdParam {
        IERC20 market;
        IERC20 collateral;
        uint96 amount;
        uint256 executionFee;
        address account;
        address[] targets;
        bytes[] calldatas;
    }

    /// @notice Emitted when createIncreaseBalanceRate request created
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param collateral The target collateral contract address, such as the contract address of DAI
    /// @param amount The amount of pusd to burn
    /// @param executionFee Amount of fee for the executor to carry out the order
    /// @param account Owner of the request
    /// @param targets swap calldata target list
    /// @param calldatas swap calldata list
    /// @param id Id of the request
    event IncreaseBalanceRateCreated(
        IERC20 indexed market,
        IERC20 indexed collateral,
        uint128 amount,
        uint256 executionFee,
        address account,
        address[] targets,
        bytes[] calldatas,
        bytes32 id
    );

    /// @notice Emitted when createIncreaseBalanceRate request cancelled
    /// @param id Id of the cancelled request
    /// @param executionFeeReceiver Receiver of the cancelled request execution fee
    event IncreaseBalanceRateCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when createIncreaseBalanceRate request executed
    /// @param id Id of the executed request
    /// @param executionFeeReceiver Receiver of the executed request execution fee
    /// @param executionFee Actual execution fee received
    event IncreaseBalanceRateExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Execute failed
    event ExecuteFailed(bytes32 indexed id, bytes4 shortenedReason);

    /// @notice Error thrown when caller is not the market manager
    error InvalidCaller(address caller);

    /// @notice Invalid callbackData
    error InvalidCallbackData();

    /// @notice create increase balance rate request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param collateral The target collateral contract address, such as the contract address of DAI
    /// @param amount Amount of pusd to burn
    /// @param targets Address of contract to call
    /// @param data CallData to call
    /// @return id Id of the request
    function createIncreaseBalanceRate(
        IERC20 market,
        IERC20 collateral,
        uint96 amount,
        address[] calldata targets,
        bytes[] calldata data
    ) external payable returns (bytes32 id);

    /// @notice cancel increase balance rate request
    /// @param param The increase request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool);

    /// @notice Execute increase balance rate request
    /// @param param The increase request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool);

    /// @notice Execute multiple requests
    /// @param param The increase request id calculation param
    /// @param shouldCancelOnFail should cancel request when execute failed
    /// @param executionFeeReceiver Receiver of the request execution fees
    function executeOrCancelIncreaseBalanceRate(
        IncreaseBalanceRateRequestIdParam calldata param,
        bool shouldCancelOnFail,
        address payable executionFeeReceiver
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILiquidator {
    /// @notice Emitted when executor updated
    /// @param account The account to update
    /// @param active Updated status
    event ExecutorUpdated(address account, bool active);

    /// @notice Update executor
    /// @param account Account to update
    /// @param active Updated status
    function updateExecutor(address account, bool active) external;

    /// @notice Update the gas limit for executing liquidation
    /// @param executionGasLimit New execution gas limit
    function updateExecutionGasLimit(uint256 executionGasLimit) external;

    /// @notice Liquidate a position
    /// @dev See `IMarketPosition#liquidatePosition` for more information
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param account The owner of the position
    /// @param feeReceiver The address to receive the liquidation execution fee
    function liquidatePosition(IERC20 market, address payable account, address payable feeReceiver) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Plugin Manager Interface
/// @notice The interface defines the functions to manage plugins
interface IPluginManager {
    /// @notice Emitted when a plugin is updated
    /// @param plugin The plugin to update
    /// @param active Whether active after the update
    event PluginUpdated(address indexed plugin, bool active);

    /// @notice Error thrown when the plugin is inactive
    error PluginInactive(address plugin);

    /// @notice Update plugin
    /// @param plugin The plugin to update
    /// @param active Whether active after the update
    function updatePlugin(address plugin, bool active) external;

    /// @notice Checks if a plugin is registered
    /// @param plugin The plugin to check
    /// @return True if the plugin is registered, false otherwise
    function activePlugins(address plugin) external view returns (bool);

    /// @notice Transfers `amount` of `token` from `from` to `to`
    /// @param token The address of the ERC20 token
    /// @param from The address to transfer the tokens from
    /// @param to The address to transfer the tokens to
    /// @param amount The amount of tokens to transfer
    function pluginTransfer(IERC20 token, address from, address to, uint256 amount) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice PositionRouter contract interface
interface IPositionRouter {
    /// @notice The param used to calculate the increase position request id
    struct IncreasePositionRequestIdParam {
        address account;
        IERC20 market;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 acceptableIndexPrice;
        uint256 executionFee;
        bool payPUSD;
    }

    /// @notice The param used to calculate the decrease position request id
    struct DecreasePositionRequestIdParam {
        address account;
        IERC20 market;
        uint96 marginDelta;
        uint96 sizeDelta;
        uint64 acceptableIndexPrice;
        address receiver;
        uint256 executionFee;
        bool receivePUSD;
    }

    /// @notice The param used to calculate the mint PUSD request id
    struct MintPUSDRequestIdParam {
        address account;
        IERC20 market;
        bool exactIn;
        uint96 acceptableMaxPayAmount;
        uint64 acceptableMinReceiveAmount;
        address receiver;
        uint256 executionFee;
    }

    /// @notice The param used to calculate the burn PUSD request id
    struct BurnPUSDRequestIdParam {
        IERC20 market;
        address account;
        bool exactIn;
        uint64 acceptableMaxPayAmount;
        uint96 acceptableMinReceiveAmount;
        address receiver;
        uint256 executionFee;
    }

    /// @notice Emitted when open or increase an existing position size request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The increase in position margin, PUSD amount if `payUSD` is true
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param executionFee Amount of fee for the executor to carry out the request
    /// @param payPUSD Whether to pay PUSD
    /// @param id Id of the request
    event IncreasePositionCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        uint256 executionFee,
        bool payPUSD,
        bytes32 id
    );

    /// @notice Emitted when increase position request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the cancelled request execution fee
    event IncreasePositionCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when increase position request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the executed request execution fee
    /// @param executionFee Actual execution fee received
    event IncreasePositionExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when close or decrease existing position size request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param receiver Address of the margin receiver
    /// @param executionFee Amount of fee for the executor to carry out the order
    /// @param receivePUSD Whether to receive PUSD
    /// @param id Id of the request
    event DecreasePositionCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address receiver,
        uint256 executionFee,
        bool receivePUSD,
        bytes32 id
    );

    /// @notice Emitted when decrease position request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event DecreasePositionCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when decrease position request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event DecreasePositionExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when mint PUSD request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of token to pay
    /// @param acceptableMinReceiveAmount The min amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    event MintPUSDCreated(
        address indexed account,
        IERC20 indexed market,
        bool exactIn,
        uint96 acceptableMaxPayAmount,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee,
        bytes32 id
    );

    /// @notice Emitted when mint PUSD request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event MintPUSDCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when mint PUSD request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event MintPUSDExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when burn PUSD request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of PUSD to burn
    /// @param acceptableMinReceiveAmount The min amount of token to receive
    /// @param receiver Address to receive ETH
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    event BurnPUSDCreated(
        address indexed account,
        IERC20 indexed market,
        bool exactIn,
        uint64 acceptableMaxPayAmount,
        uint96 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee,
        bytes32 id
    );

    /// @notice Emitted when burn PUSD request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event BurnPUSDCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when burn PUSD request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event BurnPUSDExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Create open or increase the size of existing position request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The increase in position margin
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param permitData The permit data for the market token, optional
    /// @param id Id of the request
    function createIncreasePosition(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create open or increase the size of existing position request by paying ETH
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    function createIncreasePositionETH(
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        uint256 executionFee
    ) external payable returns (bytes32 id);

    /// @notice Create open or increase the size of existing position request, paying PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param pusdAmount The PUSD amount to pay
    /// @param sizeDelta The increase in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param permitData The permit data for the PUSD token, optional
    /// @param id Id of the request
    function createIncreasePositionPayPUSD(
        IERC20 market,
        uint64 pusdAmount,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel increase position request
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute increase position request
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute increase position request. If the request is not executable, cancel it.
    /// @param param The increase position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelIncreasePosition(
        IncreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create decrease position request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of the request
    /// @param receiver Margin recipient address
    /// @param id Id of the request
    function createDecreasePosition(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address payable receiver
    ) external payable returns (bytes32 id);

    /// @notice Create decrease position request, receiving PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param marginDelta The decrease in position margin
    /// @param sizeDelta The decrease in position size
    /// @param acceptableIndexPrice The worst index price of decreasing position of the request
    /// @param receiver Margin recipient address
    /// @param id Id of the request
    function createDecreasePositionReceivePUSD(
        IERC20 market,
        uint96 marginDelta,
        uint96 sizeDelta,
        uint64 acceptableIndexPrice,
        address receiver
    ) external payable returns (bytes32 id);

    /// @notice Cancel decrease position request
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute decrease position request
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute decrease position request. If the request is not executable, cancel it.
    /// @param param The decrease position request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelDecreasePosition(
        DecreasePositionRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create mint PUSD request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of token to pay
    /// @param acceptableMinReceiveAmount The min amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param permitData The permit data for the market token, optional
    /// @param id Id of the request
    function createMintPUSD(
        IERC20 market,
        bool exactIn,
        uint96 acceptableMaxPayAmount,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create mint PUSD request by paying ETH
    /// @param acceptableMinReceiveAmount The min acceptable amount of PUSD to mint
    /// @param receiver Address to receive PUSD
    /// @param executionFee Amount of the execution fee
    /// @param id Id of the request
    function createMintPUSDETH(
        bool exactIn,
        uint64 acceptableMinReceiveAmount,
        address receiver,
        uint256 executionFee
    ) external payable returns (bytes32 id);

    /// @notice Cancel mint PUSD request
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute mint PUSD request
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to Execute mint PUSD request. If the request is not executable, cancel it.
    /// @param param The mint PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelMintPUSD(
        MintPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create burn PUSD request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param acceptableMaxPayAmount The max amount of PUSD to burn
    /// @param acceptableMinReceiveAmount The min amount of token to receive
    /// @param receiver Address to receive ETH
    /// @param permitData The permit data for the PUSD token, optional
    /// @param id Id of the request
    function createBurnPUSD(
        IERC20 market,
        bool exactIn,
        uint64 acceptableMaxPayAmount,
        uint96 acceptableMinReceiveAmount,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel burn request
    /// @notice param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute burn request
    /// @param param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute burn request. If the request is not executable, cancel it.
    /// @param param The burn PUSD request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelBurnPUSD(
        BurnPUSDRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice PositionRouter2 contract interface
interface IPositionRouter2 {
    /// @notice The param used to calculate the mint LPT request id
    struct MintLPTRequestIdParam {
        address account;
        IERC20 market;
        uint96 liquidityDelta;
        uint256 executionFee;
        address receiver;
        bool payPUSD;
        uint96 minReceivedFromBurningPUSD;
    }

    /// @notice The param used to calculate the burn LPT request id
    struct BurnLPTRequestIdParam {
        address account;
        IERC20 market;
        uint64 amount;
        uint96 acceptableMinLiquidity;
        address receiver;
        uint256 executionFee;
        bool receivePUSD;
        uint64 minPUSDReceived;
    }

    /// @notice Emitted when mint LP token request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityDelta The liquidity to be paid, PUSD amount if `payUSD` is true
    /// @param executionFee Amount of the execution fee
    /// @param receiver The address to receive the minted LP Token
    /// @param payPUSD Whether to pay PUSD
    /// @param minReceiveAmountFromBurningPUSD The minimum amount received from burning PUSD if `payPUSD` is true
    /// @param id Id of the request
    event MintLPTCreated(
        address indexed account,
        IERC20 indexed market,
        uint96 liquidityDelta,
        uint256 executionFee,
        address receiver,
        bool payPUSD,
        uint96 minReceiveAmountFromBurningPUSD,
        bytes32 id
    );

    /// @notice Emitted when mint LP token request cancelled
    /// @param id Id of the request
    /// @param receiver Receiver of the execution fee and margin
    event MintLPTCancelled(bytes32 indexed id, address payable receiver);

    /// @notice Emitted when mint LP token request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @param executionFee Actual execution fee received
    event MintLPTExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Emitted when burn LP token request created
    /// @param account Owner of the request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param acceptableMinLiquidity The min amount of liquidity to receive, valid if `receivePUSD` is false
    /// @param receiver Address of the liquidity receiver
    /// @param executionFee  Amount of fee for the executor to carry out the request
    /// @param receivePUSD Whether to receive PUSD
    /// @param minPUSDReceived The min PUSD to receive if `receivePUSD` is true
    /// @param id Id of the request
    event BurnLPTCreated(
        address indexed account,
        IERC20 indexed market,
        uint64 amount,
        uint96 acceptableMinLiquidity,
        address receiver,
        uint256 executionFee,
        bool receivePUSD,
        uint64 minPUSDReceived,
        bytes32 id
    );

    /// @notice Emitted when burn LP token request cancelled
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    event BurnLPTCancelled(bytes32 indexed id, address payable executionFeeReceiver);

    /// @notice Emitted when burn LP token request executed
    /// @param id Id of the request
    /// @param executionFeeReceiver Receiver of the request execution fee
    // @param executionFee Actual execution fee received
    event BurnLPTExecuted(bytes32 indexed id, address payable executionFeeReceiver, uint256 executionFee);

    /// @notice Create mint LP token request by paying ERC20 token
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param liquidityDelta The liquidity to be paid
    /// @param receiver Address to receive the minted LP Token
    /// @param permitData The permit data for the market token, optional
    /// @return id Id of the request
    function createMintLPT(
        IERC20 market,
        uint96 liquidityDelta,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create mint LP token request by paying ETH
    /// @param receiver Address to receive the minted LP Token
    /// @param executionFee Amount of the execution fee
    /// @return id Id of the request
    function createMintLPTETH(address receiver, uint256 executionFee) external payable returns (bytes32 id);

    /// @notice Create mint LP token request by paying PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param pusdAmount The PUSD amount to pay
    /// @param receiver Address to receive the minted LP Token
    /// @param minReceivedFromBurningPUSD The minimum amount to receive from burning PUSD
    /// @param permitData The permit data for the PUSD token, optional
    /// @return id Id of the request
    function createMintLPTPayPUSD(
        IERC20 market,
        uint64 pusdAmount,
        address receiver,
        uint96 minReceivedFromBurningPUSD,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel mint LP token request
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute mint LP token request
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute mint LP token request. If the request is not executable, cancel it.
    /// @param param The mint LPT request id calculation param
    /// @param executionFeeReceiver Receiver of request execution fee
    function executeOrCancelMintLPT(
        MintLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;

    /// @notice Create burn LP token request
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param acceptableMinLiquidity The min amount of liquidity to receive
    /// @param receiver Address of the margin receiver
    /// @param permitData The permit data for the LPT token, optional
    /// @return id Id of the request
    function createBurnLPT(
        IERC20 market,
        uint64 amount,
        uint96 acceptableMinLiquidity,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Create burn LP token request and receive PUSD
    /// @param market The target market contract address, such as the contract address of WETH
    /// @param amount The amount of LP token that will be burned
    /// @param minPUSDReceived The min amount of PUSD to receive
    /// @param receiver Address of the margin receiver
    /// @param permitData The permit data for the LPT token, optional
    /// @return id Id of the request
    function createBurnLPTReceivePUSD(
        IERC20 market,
        uint64 amount,
        uint64 minPUSDReceived,
        address receiver,
        bytes calldata permitData
    ) external payable returns (bytes32 id);

    /// @notice Cancel burn LP token request
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return cancelled True if the cancellation succeeds or request not exists
    function cancelBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool cancelled);

    /// @notice Execute burn LP token request
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    /// @return executed True if the execution succeeds or request not exists
    function executeBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external returns (bool executed);

    /// @notice Try to execute burn LP token request. If the request is not executable, cancel it.
    /// @param param The burn LPT request id calculation param
    /// @param executionFeeReceiver Receiver of the request execution fee
    function executeOrCancelBurnLPT(
        BurnLPTRequestIdParam calldata param,
        address payable executionFeeReceiver
    ) external;
}
// This file was procedurally generated from scripts/generate/PackedValue.template.js, DO NOT MODIFY MANUALLY
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

type PackedValue is uint256;

using {
    packAddress,
    unpackAddress,
    packBool,
    unpackBool,
    packUint8,
    unpackUint8,
    packUint16,
    unpackUint16,
    packUint24,
    unpackUint24,
    packUint32,
    unpackUint32,
    packUint40,
    unpackUint40,
    packUint48,
    unpackUint48,
    packUint56,
    unpackUint56,
    packUint64,
    unpackUint64,
    packUint72,
    unpackUint72,
    packUint80,
    unpackUint80,
    packUint88,
    unpackUint88,
    packUint96,
    unpackUint96,
    packUint104,
    unpackUint104,
    packUint112,
    unpackUint112,
    packUint120,
    unpackUint120,
    packUint128,
    unpackUint128,
    packUint136,
    unpackUint136,
    packUint144,
    unpackUint144,
    packUint152,
    unpackUint152,
    packUint160,
    unpackUint160,
    packUint168,
    unpackUint168,
    packUint176,
    unpackUint176,
    packUint184,
    unpackUint184,
    packUint192,
    unpackUint192,
    packUint200,
    unpackUint200,
    packUint208,
    unpackUint208,
    packUint216,
    unpackUint216,
    packUint224,
    unpackUint224,
    packUint232,
    unpackUint232,
    packUint240,
    unpackUint240,
    packUint248,
    unpackUint248
} for PackedValue global;

function packUint8(PackedValue self, uint8 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint8(PackedValue self, uint8 position) pure returns (uint8) {
    return uint8((PackedValue.unwrap(self) >> position) & 0xff);
}

function packUint16(PackedValue self, uint16 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint16(PackedValue self, uint8 position) pure returns (uint16) {
    return uint16((PackedValue.unwrap(self) >> position) & 0xffff);
}

function packUint24(PackedValue self, uint24 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint24(PackedValue self, uint8 position) pure returns (uint24) {
    return uint24((PackedValue.unwrap(self) >> position) & 0xffffff);
}

function packUint32(PackedValue self, uint32 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint32(PackedValue self, uint8 position) pure returns (uint32) {
    return uint32((PackedValue.unwrap(self) >> position) & 0xffffffff);
}

function packUint40(PackedValue self, uint40 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint40(PackedValue self, uint8 position) pure returns (uint40) {
    return uint40((PackedValue.unwrap(self) >> position) & 0xffffffffff);
}

function packUint48(PackedValue self, uint48 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint48(PackedValue self, uint8 position) pure returns (uint48) {
    return uint48((PackedValue.unwrap(self) >> position) & 0xffffffffffff);
}

function packUint56(PackedValue self, uint56 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint56(PackedValue self, uint8 position) pure returns (uint56) {
    return uint56((PackedValue.unwrap(self) >> position) & 0xffffffffffffff);
}

function packUint64(PackedValue self, uint64 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint64(PackedValue self, uint8 position) pure returns (uint64) {
    return uint64((PackedValue.unwrap(self) >> position) & 0xffffffffffffffff);
}

function packUint72(PackedValue self, uint72 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint72(PackedValue self, uint8 position) pure returns (uint72) {
    return uint72((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffff);
}

function packUint80(PackedValue self, uint80 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint80(PackedValue self, uint8 position) pure returns (uint80) {
    return uint80((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffff);
}

function packUint88(PackedValue self, uint88 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint88(PackedValue self, uint8 position) pure returns (uint88) {
    return uint88((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffff);
}

function packUint96(PackedValue self, uint96 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint96(PackedValue self, uint8 position) pure returns (uint96) {
    return uint96((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffff);
}

function packUint104(PackedValue self, uint104 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint104(PackedValue self, uint8 position) pure returns (uint104) {
    return uint104((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffff);
}

function packUint112(PackedValue self, uint112 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint112(PackedValue self, uint8 position) pure returns (uint112) {
    return uint112((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffff);
}

function packUint120(PackedValue self, uint120 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint120(PackedValue self, uint8 position) pure returns (uint120) {
    return uint120((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffff);
}

function packUint128(PackedValue self, uint128 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint128(PackedValue self, uint8 position) pure returns (uint128) {
    return uint128((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffff);
}

function packUint136(PackedValue self, uint136 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint136(PackedValue self, uint8 position) pure returns (uint136) {
    return uint136((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffff);
}

function packUint144(PackedValue self, uint144 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint144(PackedValue self, uint8 position) pure returns (uint144) {
    return uint144((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffff);
}

function packUint152(PackedValue self, uint152 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint152(PackedValue self, uint8 position) pure returns (uint152) {
    return uint152((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffff);
}

function packUint160(PackedValue self, uint160 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint160(PackedValue self, uint8 position) pure returns (uint160) {
    return uint160((PackedValue.unwrap(self) >> position) & 0x00ffffffffffffffffffffffffffffffffffffffff);
}

function packUint168(PackedValue self, uint168 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint168(PackedValue self, uint8 position) pure returns (uint168) {
    return uint168((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffff);
}

function packUint176(PackedValue self, uint176 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint176(PackedValue self, uint8 position) pure returns (uint176) {
    return uint176((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint184(PackedValue self, uint184 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint184(PackedValue self, uint8 position) pure returns (uint184) {
    return uint184((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint192(PackedValue self, uint192 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint192(PackedValue self, uint8 position) pure returns (uint192) {
    return uint192((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint200(PackedValue self, uint200 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint200(PackedValue self, uint8 position) pure returns (uint200) {
    return uint200((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint208(PackedValue self, uint208 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint208(PackedValue self, uint8 position) pure returns (uint208) {
    return uint208((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint216(PackedValue self, uint216 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint216(PackedValue self, uint8 position) pure returns (uint216) {
    return uint216((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint224(PackedValue self, uint224 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint224(PackedValue self, uint8 position) pure returns (uint224) {
    return uint224((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint232(PackedValue self, uint232 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint232(PackedValue self, uint8 position) pure returns (uint232) {
    return
        uint232((PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
}

function packUint240(PackedValue self, uint240 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint240(PackedValue self, uint8 position) pure returns (uint240) {
    return
        uint240(
            (PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
}

function packUint248(PackedValue self, uint248 value, uint8 position) pure returns (PackedValue) {
    return PackedValue.wrap(PackedValue.unwrap(self) | (uint256(value) << position));
}

function unpackUint248(PackedValue self, uint8 position) pure returns (uint248) {
    return
        uint248(
            (PackedValue.unwrap(self) >> position) & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
}

function packBool(PackedValue self, bool value, uint8 position) pure returns (PackedValue) {
    return packUint8(self, value ? 1 : 0, position);
}

function unpackBool(PackedValue self, uint8 position) pure returns (bool) {
    return ((PackedValue.unwrap(self) >> position) & 0x1) == 1;
}

function packAddress(PackedValue self, address value, uint8 position) pure returns (PackedValue) {
    return packUint160(self, uint160(value), position);
}

function unpackAddress(PackedValue self, uint8 position) pure returns (address) {
    return address(unpackUint160(self, position));
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

Side constant LONG = Side.wrap(1);
Side constant SHORT = Side.wrap(2);

type Side is uint8;

error InvalidSide(Side side);

using {requireValid, isLong, isShort, flip, eq as ==} for Side global;

function requireValid(Side self) pure {
    if (!isLong(self) && !isShort(self)) revert InvalidSide(self);
}

function isLong(Side self) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(LONG);
}

function isShort(Side self) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(SHORT);
}

function eq(Side self, Side other) pure returns (bool) {
    return Side.unwrap(self) == Side.unwrap(other);
}

function flip(Side self) pure returns (Side) {
    return isLong(self) ? SHORT : LONG;
}