// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
import "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { FluidContractRate } from "../../fluidContractRate.sol";

/// @notice This contract stores the rate of USDS for 1 sUSDS in intervals to optimize gas cost.
/// @notice Properly implements all interfaces for use as IFluidCenterPrice and IFluidOracle.
/// @dev SUSDS contract; on mainnet 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD
contract SUSDSContractRate is FluidContractRate {
    constructor(
        string memory infoName_,
        address rateSource_,
        uint256 minUpdateDiffPercent_,
        uint256 minHeartBeat_
    ) FluidContractRate(infoName_, rateSource_, minUpdateDiffPercent_, minHeartBeat_) {}

    function _getNewRate1e27() internal view virtual override returns (uint256 exchangeRate_) {
        return IERC4626(_RATE_SOURCE).convertToAssets(1e27); // scale to 1e27
    }

    /// @notice Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
    /// scenario where all the conditions are met. see IERC4626
    function convertToShares(uint256 assets) external view returns (uint256 shares) {
        return (_rate * assets) / 1e27;
    }

    /// @notice Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
    /// scenario where all the conditions are met. see IERC4626
    function convertToAssets(uint256 shares) external view returns (uint256 assets) {
        return (shares * 1e27) / _rate;
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

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant DexSmartColOracle__ExchangeRateZero = 60333;

    /***********************************|
    |        DexSmartDebtOracle         | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant DexSmartDebtOracle__InvalidParams = 60341;

    /// @notice thrown when smart debt is not enabled
    uint256 internal constant DexSmartDebtOracle__SmartDebtNotEnabled = 60342;

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant DexSmartDebtOracle__ExchangeRateZero = 60343;

    /***********************************|
    |            ContractRate           | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant ContractRate__InvalidParams = 60351;

    /// @notice thrown when caller is not authorized
    uint256 internal constant ContractRate__Unauthorized = 60352;

    /// @notice thrown when minimum diff for triggering update on the stared rate is not reached
    uint256 internal constant ContractRate__MinUpdateDiffNotReached = 60353;

    /// @notice thrown when the external rate source returns 0 for the new rate
    uint256 internal constant ContractRate__NewRateZero = 60354;

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
    |              DexOracle            | 
    |__________________________________*/

    /// @notice thrown when an invalid parameter is passed to a method
    uint256 internal constant DexOracle__InvalidParams = 60381;

    /// @notice thrown when the exchange rate is zero, even after all possible fallbacks depending on config
    uint256 internal constant DexOracle__ExchangeRateZero = 60382;

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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IFluidOracle } from "./interfaces/iFluidOracle.sol";
import { FluidCenterPrice } from "./fluidCenterPrice.sol";

import { Error as OracleError } from "./error.sol";
import { ErrorTypes } from "./errorTypes.sol";

abstract contract Events {
    /// @notice emitted when rebalancer successfully changes the contract rate
    event LogRebalanceRate(uint256 oldRate, uint256 newRate);
}

abstract contract Constants {
    /// @dev external exchange rate source contract
    address internal immutable _RATE_SOURCE;

    /// @dev Minimum difference to trigger update in percent 1e4 decimals, 10000 = 1%
    uint256 internal immutable _MIN_UPDATE_DIFF_PERCENT;

    /// @dev Minimum time after which an update can trigger, even if it does not reach `_MIN_UPDATE_DIFF_PERCENT`
    uint256 internal immutable _MIN_HEART_BEAT;
}

abstract contract Variables is Constants {
    /// @dev exchange rate in 1e27 decimals
    uint216 internal _rate;

    /// @dev time when last update for rate happened
    uint40 internal _lastUpdateTime;
}

/// @notice This contract stores an exchange rate in intervals to optimize gas cost.
/// @notice Properly implements all interfaces for use as IFluidCenterPrice and IFluidOracle.
abstract contract FluidContractRate is IFluidOracle, FluidCenterPrice, Variables, Events {
    /// @dev Validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidOracleError(ErrorTypes.ContractRate__InvalidParams);
        }
        _;
    }

    constructor(
        string memory infoName_,
        address rateSource_,
        uint256 minUpdateDiffPercent_,
        uint256 minHeartBeat_
    ) validAddress(rateSource_) FluidCenterPrice(infoName_) {
        if (minUpdateDiffPercent_ == 0 || minUpdateDiffPercent_ > 1e5 || minHeartBeat_ == 0) {
            // revert if > 10% or 0
            revert FluidOracleError(ErrorTypes.ContractRate__InvalidParams);
        }
        _RATE_SOURCE = rateSource_;
        _MIN_UPDATE_DIFF_PERCENT = minUpdateDiffPercent_;
        _MIN_HEART_BEAT = minHeartBeat_;

        _rate = uint216(_getNewRate1e27());
        _lastUpdateTime = uint40(block.timestamp);
    }

    /// @dev read the exchange rate from the external contract e.g. wstETH or rsETH exchange rate, scaled to 1e27
    /// To be implemented by inheriting contract
    function _getNewRate1e27() internal view virtual returns (uint256 exchangeRate_);

    /// @inheritdoc FluidCenterPrice
    function infoName() public view override(IFluidOracle, FluidCenterPrice) returns (string memory) {
        return super.infoName();
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

    /// @notice Rebalance the contract rate by updating the stored rate with the current rate from the external contract.
    /// @dev The rate is only updated if the difference between the current rate and the new rate is greater than or
    ///      equal to the minimum update difference percentage.
    function rebalance() external {
        uint256 curRate_ = _rate;
        uint256 newRate_ = _getNewRate1e27();
        if (newRate_ == 0) {
            revert FluidOracleError(ErrorTypes.ContractRate__NewRateZero);
        }

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

    /// @inheritdoc FluidCenterPrice
    function centerPrice() external override returns (uint256 price_) {
        // heart beat check update for Dex swaps
        if (_lastUpdateTime + _MIN_HEART_BEAT < block.timestamp) {
            uint256 curRate_ = _rate;
            uint256 newRate_ = _getNewRate1e27();
            if (newRate_ == 0) {
                revert FluidOracleError(ErrorTypes.ContractRate__NewRateZero);
            }

            _rate = uint216(newRate_);
            _lastUpdateTime = uint40(block.timestamp);

            emit LogRebalanceRate(curRate_, newRate_);
        }

        return _rate;
    }

    /// @notice returns how much the new rate would be different from current rate in percent (10000 = 1%, 1 = 0.0001%).
    function configPercentDiff() public view virtual returns (uint256 configPercentDiff_) {
        uint256 curRate_ = _rate;
        uint256 newRate_ = _getNewRate1e27();

        unchecked {
            if (curRate_ > newRate_) {
                configPercentDiff_ = ((curRate_ - newRate_) * 1e6) / curRate_;
            } else if (newRate_ > curRate_) {
                configPercentDiff_ = ((newRate_ - curRate_) * 1e6) / curRate_;
            }
        }
    }

    /// @notice returns all config vars, last update timestamp, and external rate source oracle address
    function configData()
        external
        view
        returns (uint256 minUpdateDiffPercent_, uint256 minHeartBeat_, uint40 lastUpdateTime_, address rateSource_)
    {
        return (_MIN_UPDATE_DIFF_PERCENT, _MIN_HEART_BEAT, _lastUpdateTime, _RATE_SOURCE);
    }
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