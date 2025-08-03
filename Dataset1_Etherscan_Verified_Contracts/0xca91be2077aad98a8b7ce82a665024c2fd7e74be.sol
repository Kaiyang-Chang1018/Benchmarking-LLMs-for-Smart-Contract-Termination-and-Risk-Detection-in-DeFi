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

}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Events {
    /// @notice emitted when borrow magnifier is updated at vault
    event LogUpdateBorrowRateMagnifier(uint256 oldMagnifier, uint256 newMagnifier);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IStakedUSDe is IERC4626 {
    /// @notice The amount of the last asset distribution from the controller contract into this
    /// contract + any unvested remainder at that time
    function vestingAmount() external view returns (uint256);

    /// @notice The timestamp of the last asset distribution from the controller contract into this contract
    function lastDistributionTimestamp() external view returns (uint256);

    /// @notice Returns the amount of USDe tokens that are vested in the contract.
    function totalAssets() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IFluidLiquidity } from "../../liquidity/interfaces/iLiquidity.sol";
import { IFluidReserveContract } from "../../reserve/interfaces/iReserveContract.sol";
import { IFluidVaultT1 } from "../../protocols/vault/interfaces/iVaultT1.sol";
import { LiquiditySlotsLink } from "../../libraries/liquiditySlotsLink.sol";
import { FluidVaultT1Admin } from "../../protocols/vault/vaultT1/adminModule/main.sol";
import { IStakedUSDe } from "./interfaces/iStakedUSDe.sol";
import { Variables } from "./variables.sol";
import { Events } from "./events.sol";
import { Error } from "../error.sol";
import { ErrorTypes } from "../errorTypes.sol";

/// @notice Sets borrow rate for sUSDe/debtToken vaults based on sUSDe yield rate, by adjusting the borrowRateMagnifier
contract FluidEthenaRateConfigHandler is Variables, Error, Events {
    /// @dev Validates that an address is not the zero address
    modifier validAddress(address value_) {
        if (value_ == address(0)) {
            revert FluidConfigError(ErrorTypes.EthenaRateConfigHandler__AddressZero);
        }
        _;
    }

    /// @dev Validates that an address is a rebalancer (taken from reserve contract)
    modifier onlyRebalancer() {
        if (!RESERVE_CONTRACT.isRebalancer(msg.sender)) {
            revert FluidConfigError(ErrorTypes.EthenaRateConfigHandler__Unauthorized);
        }
        _;
    }

    // vault2 is optional, set to address zero if only triggering on one vault. borrow token must be vault1 == vault2!
    constructor(
        IFluidReserveContract reserveContract_,
        IFluidLiquidity liquidity_,
        IFluidVaultT1 vault_,
        IFluidVaultT1 vault2_,
        IStakedUSDe stakedUSDe_,
        address borrowToken_,
        uint256 ratePercentMargin_,
        uint256 maxRewardsDelay_,
        uint256 utilizationPenaltyStart_,
        uint256 utilization100PenaltyPercent_
    )
        validAddress(address(reserveContract_))
        validAddress(address(liquidity_))
        validAddress(address(vault_))
        validAddress(address(stakedUSDe_))
        validAddress(borrowToken_)
    {
        if (
            ratePercentMargin_ == 0 ||
            ratePercentMargin_ >= 1e4 ||
            maxRewardsDelay_ == 0 ||
            utilizationPenaltyStart_ >= 1e4 ||
            utilization100PenaltyPercent_ == 0
        ) {
            revert FluidConfigError(ErrorTypes.EthenaRateConfigHandler__InvalidParams);
        }

        RESERVE_CONTRACT = reserveContract_;
        LIQUIDITY = liquidity_;
        SUSDE = stakedUSDe_;
        VAULT = vault_;
        VAULT2 = vault2_;
        BORROW_TOKEN = borrowToken_;

        _LIQUDITY_BORROW_TOKEN_EXCHANGE_PRICES_SLOT = LiquiditySlotsLink.calculateMappingStorageSlot(
            LiquiditySlotsLink.LIQUIDITY_EXCHANGE_PRICES_MAPPING_SLOT,
            borrowToken_
        );

        RATE_PERCENT_MARGIN = ratePercentMargin_;
        MAX_REWARDS_DELAY = maxRewardsDelay_;

        UTILIZATION_PENALTY_START = utilizationPenaltyStart_;
        UTILIZATION100_PENALTY_PERCENT = utilization100PenaltyPercent_;
    }

    /// @notice Rebalances the borrow rate magnifier for `VAULT` (and `VAULT2`) based on borrow rate at Liquidity in
    /// relation to sUSDe yield rate (`getSUSDEYieldRate()`).
    /// Emits `LogUpdateBorrowRateMagnifier` in case of update. Reverts if no update is needed.
    /// Can only be called by an authorized rebalancer.
    function rebalance() external onlyRebalancer {
        uint256 targetMagnifier_ = calculateMagnifier();
        uint256 currentMagnifier_ = currentMagnifier();

        // execute update on vault if necessary
        if (targetMagnifier_ == currentMagnifier_) {
            revert FluidConfigError(ErrorTypes.EthenaRateConfigHandler__NoUpdate);
        }

        FluidVaultT1Admin(address(VAULT)).updateBorrowRateMagnifier(targetMagnifier_);
        if (address(VAULT2) != address(0)) {
            FluidVaultT1Admin(address(VAULT2)).updateBorrowRateMagnifier(targetMagnifier_);
        }

        emit LogUpdateBorrowRateMagnifier(currentMagnifier_, targetMagnifier_);
    }

    /// @notice Calculates the new borrow rate magnifier based on sUSDe yield rate and utilization
    /// @return magnifier_ the calculated magnifier value.
    function calculateMagnifier() public view returns (uint256 magnifier_) {
        uint256 sUSDeYieldRate_ = getSUSDeYieldRate();
        uint256 exchangePriceAndConfig_ = LIQUIDITY.readFromStorage(_LIQUDITY_BORROW_TOKEN_EXCHANGE_PRICES_SLOT);

        uint256 utilization_ = (exchangePriceAndConfig_ >> LiquiditySlotsLink.BITS_EXCHANGE_PRICES_UTILIZATION) & X14;

        // calculate target borrow rate. scaled by 1e18.
        // borrow rate is based on sUSDeYieldRate_ and a margin that goes to lenders
        // e.g. when RATE_PERCENT_MARGIN = 1000 (10%), then borrow rate will be 90% of the sUSDe yield rate
        // e.g. when sUSDe yield is 60%, borrow rate would be 54%
        uint256 targetBorrowRate_ = (sUSDeYieldRate_ * (1e4 - RATE_PERCENT_MARGIN)) / 1e4;

        if (utilization_ > UTILIZATION_PENALTY_START) {
            // above UTILIZATION_PENALTY_START (e.g. 90%), penalty should rise linearly according to UTILIZATION100_PENALTY_PERCENT
            // e.g. from 10% margin at 90% utilization to 10% - penalty margin at 100% utilization
            // so from +RATE_PERCENT_MARGIN at UTILIZATION_PENALTY_START to +RATE_PERCENT_MARGIN - UTILIZATION100_PENALTY_PERCENT at 100%
            if (utilization_ < 1e4) {
                uint256 utilizationAbovePenaltyStart_ = utilization_ - UTILIZATION_PENALTY_START; // e.g. 95 - 90 = 5%
                uint256 penaltyUtilizationDiff_ = 1e4 - UTILIZATION_PENALTY_START; // e.g. 100 - 90 = 10%

                // e.g. when current utilization = 96%, start penalty utilization = 90%, penalty at 100 = 12%, rate margin = 15%:
                // utilizationAbovePenaltyStart_ = 600 (6%)
                // penaltyUtilizationDiff_ = 1000 (10%)
                // UTILIZATION100_PENALTY_PERCENT = 1200 (12%)
                // marginAfterPenalty_ = 1200 * 600 / 1000 = 720 (7.2%)
                uint256 marginAfterPenalty_ = (UTILIZATION100_PENALTY_PERCENT * utilizationAbovePenaltyStart_) /
                    penaltyUtilizationDiff_;

                // for above example, when sUSDe yield is 60%, borrow rate would become 57.89% (from 60% * (90% + 7.2%) / 100% )
                targetBorrowRate_ = (sUSDeYieldRate_ * ((1e4 - RATE_PERCENT_MARGIN) + marginAfterPenalty_)) / 1e4;
            } else {
                // above 100% utilization, cap at RATE_PERCENT_MARGIN - UTILIZATION100_PENALTY_PERCENT penalty
                targetBorrowRate_ =
                    (sUSDeYieldRate_ * (1e4 - RATE_PERCENT_MARGIN + UTILIZATION100_PENALTY_PERCENT)) /
                    1e4;
            }
        }

        // get current neutral borrow rate at Liquidity (without any magnifier).
        // exchangePriceAndConfig slot at Liquidity, first 16 bits
        uint256 liquidityBorrowRate_ = exchangePriceAndConfig_ & X16;

        if (liquidityBorrowRate_ == 0) {
            return 1e4;
        }

        // calculate magnifier needed to reach target borrow rate.
        // liquidityBorrowRate_ * x = targetBorrowRate_. so x = targetBorrowRate_ / liquidityBorrowRate_.
        // must scale liquidityBorrowRate_ from 1e2 to 1e18 as targetBorrowRate_ is in 1e18. magnifier itself is scaled
        // by 1e4 (1x = 10000)
        magnifier_ = (1e4 * targetBorrowRate_) / (liquidityBorrowRate_ * 1e16);

        // make sure magnifier is within allowed limits
        if (magnifier_ < _MIN_MAGNIFIER) {
            return _MIN_MAGNIFIER;
        }
        if (magnifier_ > _MAX_MAGNIFIER) {
            return _MAX_MAGNIFIER;
        }
    }

    /// @notice returns the currently configured borrow magnifier at the `VAULT` (and `VAULT2`).
    function currentMagnifier() public view returns (uint256) {
        // read borrow rate magnifier from Vault `vaultVariables2` located in storage slot 1, 16 bits from 16-31
        return (VAULT.readFromStorage(bytes32(uint256(1))) >> 16) & X16;
    }

    /// @notice calculates updated vesting yield rate based on `vestingAmount` and `totalAssets` of StakedUSDe contract
    /// @return rate_ sUSDe yearly yield rate scaled by 1e18 (1e18 = 1%, 1e20 = 100%)
    function getSUSDeYieldRate() public view returns (uint256 rate_) {
        if (block.timestamp > SUSDE.lastDistributionTimestamp() + _SUSDE_VESTING_PERIOD + MAX_REWARDS_DELAY) {
            // if rewards update on StakedUSDe contract is delayed by more than `MAX_REWARDS_DELAY`, we use rate as 0
            // as we can't know if e.g. funding would have gone negative and there are indeed no rewards.
            return 0;
        }

        // vestingAmount is yield per 8 hours (`SUSDE_VESTING_PERIOD`)
        rate_ = (SUSDE.vestingAmount() * 1e20) / SUSDE.totalAssets(); // 8 hours rate
        // turn into yearly yield
        rate_ = (rate_ * 365 * 24 hours) / _SUSDE_VESTING_PERIOD; // 365 days * 24 hours / 8 hours -> rate_ * 1095
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IFluidLiquidity } from "../../liquidity/interfaces/iLiquidity.sol";
import { IFluidReserveContract } from "../../reserve/interfaces/iReserveContract.sol";
import { IFluidVaultT1 } from "../../protocols/vault/interfaces/iVaultT1.sol";
import { IStakedUSDe } from "./interfaces/iStakedUSDe.sol";

abstract contract Constants {
    IFluidReserveContract public immutable RESERVE_CONTRACT;
    IFluidLiquidity public immutable LIQUIDITY;
    IFluidVaultT1 public immutable VAULT;
    IFluidVaultT1 public immutable VAULT2;
    IStakedUSDe public immutable SUSDE;
    address public immutable BORROW_TOKEN;

    /// @notice sUSDe vesting yield reward rate percent margin that goes to lenders
    /// e.g. RATE_PERCENT_MARGIN = 10% then borrow rate for debt token ends up as 90% of the sUSDe yield.
    /// (in 1e2: 100% = 10_000; 1% = 100)
    uint256 public immutable RATE_PERCENT_MARGIN;

    /// @notice max delay in seconds for rewards update after vesting period ended, after which we assume rate is 0.
    /// e.g. 15 min
    uint256 public immutable MAX_REWARDS_DELAY;

    /// @notice utilization penalty start point (in 1e2: 100% = 10_000; 1% = 100). above this, a penalty percent
    ///         is applied, to incentivize deleveraging.
    uint256 public immutable UTILIZATION_PENALTY_START;
    /// @notice penalty percent target at 100%, on top of sUSDe yield rate if utilization is above UTILIZATION_PENALTY_START
    ///         (in 1e2: 100% = 10_000; 1% = 100)
    uint256 public immutable UTILIZATION100_PENALTY_PERCENT;

    bytes32 internal immutable _LIQUDITY_BORROW_TOKEN_EXCHANGE_PRICES_SLOT;

    /// @dev vesting period defined as private constant on StakedUSDe contract
    uint256 internal constant _SUSDE_VESTING_PERIOD = 8 hours;

    uint256 internal constant X14 = 0x3fff;
    uint256 internal constant X16 = 0xffff;
    uint256 internal constant _MIN_MAGNIFIER = 1e4; // min magnifier is always at least 1x (10000)
    uint256 internal constant _MAX_MAGNIFIER = 65535; // max magnifier to fit in storage slot is 65535 (16 bits)
}

abstract contract Variables is Constants {}
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

/// @title library that represents a number in BigNumber(coefficient and exponent) format to store in smaller bits.
/// @notice the number is divided into two parts: a coefficient and an exponent. This comes at a cost of losing some precision
/// at the end of the number because the exponent simply fills it with zeroes. This precision is oftentimes negligible and can
/// result in significant gas cost reduction due to storage space reduction.
/// Also note, a valid big number is as follows: if the exponent is > 0, then coefficient last bits should be occupied to have max precision.
/// @dev roundUp is more like a increase 1, which happens everytime for the same number.
/// roundDown simply sets trailing digits after coefficientSize to zero (floor), only once for the same number.
library BigMathMinified {
    /// @dev constants to use for `roundUp` input param to increase readability
    bool internal constant ROUND_DOWN = false;
    bool internal constant ROUND_UP = true;

    /// @dev converts `normal` number to BigNumber with `exponent` and `coefficient` (or precision).
    /// e.g.:
    /// 5035703444687813576399599 (normal) = (coefficient[32bits], exponent[8bits])[40bits]
    /// 5035703444687813576399599 (decimal) => 10000101010010110100000011111011110010100110100000000011100101001101001101011101111 (binary)
    ///                                     => 10000101010010110100000011111011000000000000000000000000000000000000000000000000000
    ///                                                                        ^-------------------- 51(exponent) -------------- ^
    /// coefficient = 1000,0101,0100,1011,0100,0000,1111,1011               (2236301563)
    /// exponent =                                            0011,0011     (51)
    /// bigNumber =   1000,0101,0100,1011,0100,0000,1111,1011,0011,0011     (572493200179)
    ///
    /// @param normal number which needs to be converted into Big Number
    /// @param coefficientSize at max how many bits of precision there should be (64 = uint64 (64 bits precision))
    /// @param exponentSize at max how many bits of exponent there should be (8 = uint8 (8 bits exponent))
    /// @param roundUp signals if result should be rounded down or up
    /// @return bigNumber converted bigNumber (coefficient << exponent)
    function toBigNumber(
        uint256 normal,
        uint256 coefficientSize,
        uint256 exponentSize,
        bool roundUp
    ) internal pure returns (uint256 bigNumber) {
        assembly {
            let lastBit_
            let number_ := normal
            if gt(number_, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit_ := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit_ := add(lastBit_, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit_ := add(lastBit_, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit_ := add(lastBit_, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit_ := add(lastBit_, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit_ := add(lastBit_, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit_ := add(lastBit_, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit_ := add(lastBit_, 1)
            }
            if gt(number_, 0) {
                lastBit_ := add(lastBit_, 1)
            }
            if lt(lastBit_, coefficientSize) {
                // for throw exception
                lastBit_ := coefficientSize
            }
            let exponent := sub(lastBit_, coefficientSize)
            let coefficient := shr(exponent, normal)
            if and(roundUp, gt(exponent, 0)) {
                // rounding up is only needed if exponent is > 0, as otherwise the coefficient fully holds the original number
                coefficient := add(coefficient, 1)
                if eq(shl(coefficientSize, 1), coefficient) {
                    // case were coefficient was e.g. 111, with adding 1 it became 1000 (in binary) and coefficientSize 3 bits
                    // final coefficient would exceed it's size. -> reduce coefficent to 100 and increase exponent by 1.
                    coefficient := shl(sub(coefficientSize, 1), 1)
                    exponent := add(exponent, 1)
                }
            }
            if iszero(lt(exponent, shl(exponentSize, 1))) {
                // if exponent is >= exponentSize, the normal number is too big to fit within
                // BigNumber with too small sizes for coefficient and exponent
                revert(0, 0)
            }
            bigNumber := shl(exponentSize, coefficient)
            bigNumber := add(bigNumber, exponent)
        }
    }

    /// @dev get `normal` number from `bigNumber`, `exponentSize` and `exponentMask`
    function fromBigNumber(
        uint256 bigNumber,
        uint256 exponentSize,
        uint256 exponentMask
    ) internal pure returns (uint256 normal) {
        assembly {
            let coefficient := shr(exponentSize, bigNumber)
            let exponent := and(bigNumber, exponentMask)
            normal := shl(exponent, coefficient)
        }
    }

    /// @dev gets the most significant bit `lastBit` of a `normal` number (length of given number of binary format).
    /// e.g.
    /// 5035703444687813576399599 = 10000101010010110100000011111011110010100110100000000011100101001101001101011101111
    /// lastBit =                   ^---------------------------------   83   ----------------------------------------^
    function mostSignificantBit(uint256 normal) internal pure returns (uint lastBit) {
        assembly {
            let number_ := normal
            if gt(normal, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                number_ := shr(0x80, number_)
                lastBit := 0x80
            }
            if gt(number_, 0xFFFFFFFFFFFFFFFF) {
                number_ := shr(0x40, number_)
                lastBit := add(lastBit, 0x40)
            }
            if gt(number_, 0xFFFFFFFF) {
                number_ := shr(0x20, number_)
                lastBit := add(lastBit, 0x20)
            }
            if gt(number_, 0xFFFF) {
                number_ := shr(0x10, number_)
                lastBit := add(lastBit, 0x10)
            }
            if gt(number_, 0xFF) {
                number_ := shr(0x8, number_)
                lastBit := add(lastBit, 0x8)
            }
            if gt(number_, 0xF) {
                number_ := shr(0x4, number_)
                lastBit := add(lastBit, 0x4)
            }
            if gt(number_, 0x3) {
                number_ := shr(0x2, number_)
                lastBit := add(lastBit, 0x2)
            }
            if gt(number_, 0x1) {
                lastBit := add(lastBit, 1)
            }
            if gt(number_, 0) {
                lastBit := add(lastBit, 1)
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library LibsErrorTypes {
    /***********************************|
    |         LiquidityCalcs            | 
    |__________________________________*/

    /// @notice thrown when supply or borrow exchange price is zero at calc token data (token not configured yet)
    uint256 internal constant LiquidityCalcs__ExchangePriceZero = 70001;

    /// @notice thrown when rate data is set to a version that is not implemented
    uint256 internal constant LiquidityCalcs__UnsupportedRateVersion = 70002;

    /// @notice thrown when the calculated borrow rate turns negative. This should never happen.
    uint256 internal constant LiquidityCalcs__BorrowRateNegative = 70003;

    /***********************************|
    |           SafeTransfer            | 
    |__________________________________*/

    /// @notice thrown when safe transfer from for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFromFailed = 71001;

    /// @notice thrown when safe transfer for an ERC20 fails
    uint256 internal constant SafeTransfer__TransferFailed = 71002;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @notice library that helps in reading / working with storage slot data of Fluid Liquidity.
/// @dev as all data for Fluid Liquidity is internal, any data must be fetched directly through manual
/// slot reading through this library or, if gas usage is less important, through the FluidLiquidityResolver.
library LiquiditySlotsLink {
    /// @dev storage slot for status at Liquidity
    uint256 internal constant LIQUIDITY_STATUS_SLOT = 1;
    /// @dev storage slot for auths mapping at Liquidity
    uint256 internal constant LIQUIDITY_AUTHS_MAPPING_SLOT = 2;
    /// @dev storage slot for guardians mapping at Liquidity
    uint256 internal constant LIQUIDITY_GUARDIANS_MAPPING_SLOT = 3;
    /// @dev storage slot for user class mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_CLASS_MAPPING_SLOT = 4;
    /// @dev storage slot for exchangePricesAndConfig mapping at Liquidity
    uint256 internal constant LIQUIDITY_EXCHANGE_PRICES_MAPPING_SLOT = 5;
    /// @dev storage slot for rateData mapping at Liquidity
    uint256 internal constant LIQUIDITY_RATE_DATA_MAPPING_SLOT = 6;
    /// @dev storage slot for totalAmounts mapping at Liquidity
    uint256 internal constant LIQUIDITY_TOTAL_AMOUNTS_MAPPING_SLOT = 7;
    /// @dev storage slot for user supply double mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_SUPPLY_DOUBLE_MAPPING_SLOT = 8;
    /// @dev storage slot for user borrow double mapping at Liquidity
    uint256 internal constant LIQUIDITY_USER_BORROW_DOUBLE_MAPPING_SLOT = 9;
    /// @dev storage slot for listed tokens array at Liquidity
    uint256 internal constant LIQUIDITY_LISTED_TOKENS_ARRAY_SLOT = 10;
    /// @dev storage slot for listed tokens array at Liquidity
    uint256 internal constant LIQUIDITY_CONFIGS2_MAPPING_SLOT = 11;

    // --------------------------------
    // @dev stacked uint256 storage slots bits position data for each:

    // ExchangePricesAndConfig
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_RATE = 0;
    uint256 internal constant BITS_EXCHANGE_PRICES_FEE = 16;
    uint256 internal constant BITS_EXCHANGE_PRICES_UTILIZATION = 30;
    uint256 internal constant BITS_EXCHANGE_PRICES_UPDATE_THRESHOLD = 44;
    uint256 internal constant BITS_EXCHANGE_PRICES_LAST_TIMESTAMP = 58;
    uint256 internal constant BITS_EXCHANGE_PRICES_SUPPLY_EXCHANGE_PRICE = 91;
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_EXCHANGE_PRICE = 155;
    uint256 internal constant BITS_EXCHANGE_PRICES_SUPPLY_RATIO = 219;
    uint256 internal constant BITS_EXCHANGE_PRICES_BORROW_RATIO = 234;
    uint256 internal constant BITS_EXCHANGE_PRICES_USES_CONFIGS2 = 249;

    // RateData:
    uint256 internal constant BITS_RATE_DATA_VERSION = 0;
    // RateData: V1
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_ZERO = 4;
    uint256 internal constant BITS_RATE_DATA_V1_UTILIZATION_AT_KINK = 20;
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_KINK = 36;
    uint256 internal constant BITS_RATE_DATA_V1_RATE_AT_UTILIZATION_MAX = 52;
    // RateData: V2
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_ZERO = 4;
    uint256 internal constant BITS_RATE_DATA_V2_UTILIZATION_AT_KINK1 = 20;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK1 = 36;
    uint256 internal constant BITS_RATE_DATA_V2_UTILIZATION_AT_KINK2 = 52;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_KINK2 = 68;
    uint256 internal constant BITS_RATE_DATA_V2_RATE_AT_UTILIZATION_MAX = 84;

    // TotalAmounts
    uint256 internal constant BITS_TOTAL_AMOUNTS_SUPPLY_WITH_INTEREST = 0;
    uint256 internal constant BITS_TOTAL_AMOUNTS_SUPPLY_INTEREST_FREE = 64;
    uint256 internal constant BITS_TOTAL_AMOUNTS_BORROW_WITH_INTEREST = 128;
    uint256 internal constant BITS_TOTAL_AMOUNTS_BORROW_INTEREST_FREE = 192;

    // UserSupplyData
    uint256 internal constant BITS_USER_SUPPLY_MODE = 0;
    uint256 internal constant BITS_USER_SUPPLY_AMOUNT = 1;
    uint256 internal constant BITS_USER_SUPPLY_PREVIOUS_WITHDRAWAL_LIMIT = 65;
    uint256 internal constant BITS_USER_SUPPLY_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_SUPPLY_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_SUPPLY_BASE_WITHDRAWAL_LIMIT = 200;
    uint256 internal constant BITS_USER_SUPPLY_IS_PAUSED = 255;

    // UserBorrowData
    uint256 internal constant BITS_USER_BORROW_MODE = 0;
    uint256 internal constant BITS_USER_BORROW_AMOUNT = 1;
    uint256 internal constant BITS_USER_BORROW_PREVIOUS_BORROW_LIMIT = 65;
    uint256 internal constant BITS_USER_BORROW_LAST_UPDATE_TIMESTAMP = 129;
    uint256 internal constant BITS_USER_BORROW_EXPAND_PERCENT = 162;
    uint256 internal constant BITS_USER_BORROW_EXPAND_DURATION = 176;
    uint256 internal constant BITS_USER_BORROW_BASE_BORROW_LIMIT = 200;
    uint256 internal constant BITS_USER_BORROW_MAX_BORROW_LIMIT = 218;
    uint256 internal constant BITS_USER_BORROW_IS_PAUSED = 255;

    // Configs2
    uint256 internal constant BITS_CONFIGS2_MAX_UTILIZATION = 0;

    // --------------------------------

    /// @notice Calculating the slot ID for Liquidity contract for single mapping at `slot_` for `key_`
    function calculateMappingStorageSlot(uint256 slot_, address key_) internal pure returns (bytes32) {
        return keccak256(abi.encode(key_, slot_));
    }

    /// @notice Calculating the slot ID for Liquidity contract for double mapping at `slot_` for `key1_` and `key2_`
    function calculateDoubleMappingStorageSlot(
        uint256 slot_,
        address key1_,
        address key2_
    ) internal pure returns (bytes32) {
        bytes32 intermediateSlot_ = keccak256(abi.encode(key1_, slot_));
        return keccak256(abi.encode(key2_, intermediateSlot_));
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.21;

import { LibsErrorTypes as ErrorTypes } from "./errorTypes.sol";

/// @notice provides minimalistic methods for safe transfers, e.g. ERC20 safeTransferFrom
library SafeTransfer {
    uint256 internal constant MAX_NATIVE_TRANSFER_GAS = 20000; // pass max. 20k gas for native transfers

    error FluidSafeTransferError(uint256 errorId_);

    /// @dev Transfer `amount_` of `token_` from `from_` to `to_`, spending the approval given by `from_` to the
    /// calling contract. If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L31-L63
    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from_" argument.
            mstore(add(freeMemoryPointer, 36), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 68), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFromFailed);
        }
    }

    /// @dev Transfer `amount_` of `token_` to `to_`.
    /// If `token_` returns no value, non-reverting calls are assumed to be successful.
    /// Minimally modified from Solmate SafeTransferLib (address as input param for token, Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L65-L95
    function safeTransfer(address token_, address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to_, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to_" argument.
            mstore(add(freeMemoryPointer, 36), amount_) // Append the "amount_" argument. Masking not required as it's a full 32 byte type.

            success_ := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }

    /// @dev Transfer `amount_` of ` native token to `to_`.
    /// Minimally modified from Solmate SafeTransferLib (Custom Error):
    /// https://github.com/transmissions11/solmate/blob/50e15bb566f98b7174da9b0066126a4c3e75e0fd/src/utils/SafeTransferLib.sol#L15-L25
    function safeTransferNative(address to_, uint256 amount_) internal {
        bool success_;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not. Pass limited gas
            success_ := call(MAX_NATIVE_TRANSFER_GAS, to_, amount_, 0, 0, 0, 0)
        }

        if (!success_) {
            revert FluidSafeTransferError(ErrorTypes.SafeTransfer__TransferFailed);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

/// @title library that calculates number "tick" and "ratioX96" from this: ratioX96 = (1.0015^tick) * 2^96
/// @notice this library is used in Fluid Vault protocol for optimiziation.
/// @dev "tick" supports between -32767 and 32767. "ratioX96" supports between 37075072 and 169307877264527972847801929085841449095838922544595
library TickMath {
    /// The minimum tick that can be passed in getRatioAtTick. 1.0015**-32767
    int24 internal constant MIN_TICK = -32767;
    /// The maximum tick that can be passed in getRatioAtTick. 1.0015**32767
    int24 internal constant MAX_TICK = 32767;

    uint256 internal constant FACTOR00 = 0x100000000000000000000000000000000;
    uint256 internal constant FACTOR01 = 0xff9dd7de423466c20352b1246ce4856f; // 2^128/1.0015**1 = 339772707859149738855091969477551883631
    uint256 internal constant FACTOR02 = 0xff3bd55f4488ad277531fa1c725a66d0; // 2^128/1.0015**2 = 339263812140938331358054887146831636176
    uint256 internal constant FACTOR03 = 0xfe78410fd6498b73cb96a6917f853259; // 2^128/1.0015**4 = 338248306163758188337119769319392490073
    uint256 internal constant FACTOR04 = 0xfcf2d9987c9be178ad5bfeffaa123273; // 2^128/1.0015**8 = 336226404141693512316971918999264834163
    uint256 internal constant FACTOR05 = 0xf9ef02c4529258b057769680fc6601b3; // 2^128/1.0015**16 = 332218786018727629051611634067491389875
    uint256 internal constant FACTOR06 = 0xf402d288133a85a17784a411f7aba082; // 2^128/1.0015**32 = 324346285652234375371948336458280706178
    uint256 internal constant FACTOR07 = 0xe895615b5beb6386553757b0352bda90; // 2^128/1.0015**64 = 309156521885964218294057947947195947664
    uint256 internal constant FACTOR08 = 0xd34f17a00ffa00a8309940a15930391a; // 2^128/1.0015**128 = 280877777739312896540849703637713172762 
    uint256 internal constant FACTOR09 = 0xae6b7961714e20548d88ea5123f9a0ff; // 2^128/1.0015**256 = 231843708922198649176471782639349113087
    uint256 internal constant FACTOR10 = 0x76d6461f27082d74e0feed3b388c0ca1; // 2^128/1.0015**512 = 157961477267171621126394973980180876449
    uint256 internal constant FACTOR11 = 0x372a3bfe0745d8b6b19d985d9a8b85bb; // 2^128/1.0015**1024 = 73326833024599564193373530205717235131
    uint256 internal constant FACTOR12 = 0x0be32cbee48979763cf7247dd7bb539d; // 2^128/1.0015**2048 = 15801066890623697521348224657638773661
    uint256 internal constant FACTOR13 = 0x8d4f70c9ff4924dac37612d1e2921e;   // 2^128/1.0015**4096 = 733725103481409245883800626999235102
    uint256 internal constant FACTOR14 = 0x4e009ae5519380809a02ca7aec77;     // 2^128/1.0015**8192 = 1582075887005588088019997442108535
    uint256 internal constant FACTOR15 = 0x17c45e641b6e95dee056ff10;         // 2^128/1.0015**16384 = 7355550435635883087458926352

    /// The minimum value that can be returned from getRatioAtTick. Equivalent to getRatioAtTick(MIN_TICK). ~ Equivalent to `(1 << 96) * (1.0015**-32767)`
    uint256 internal constant MIN_RATIOX96 = 37075072;
    /// The maximum value that can be returned from getRatioAtTick. Equivalent to getRatioAtTick(MAX_TICK).
    /// ~ Equivalent to `(1 << 96) * (1.0015**32767)`, rounding etc. leading to minor difference
    uint256 internal constant MAX_RATIOX96 = 169307877264527972847801929085841449095838922544595;

    uint256 internal constant ZERO_TICK_SCALED_RATIO = 0x1000000000000000000000000; // 1 << 96 // 79228162514264337593543950336
    uint256 internal constant _1E26 = 1e26;

    /// @notice ratioX96 = (1.0015^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return ratioX96 ratio = (debt amount/collateral amount)
    function getRatioAtTick(int tick) internal pure returns (uint256 ratioX96) {
        assembly {
            let absTick_ := sub(xor(tick, sar(255, tick)), sar(255, tick))

            if gt(absTick_, MAX_TICK) {
                revert(0, 0)
            }
            let factor_ := FACTOR00
            if and(absTick_, 0x1) {
                factor_ := FACTOR01
            }
            if and(absTick_, 0x2) {
                factor_ := shr(128, mul(factor_, FACTOR02))
            }
            if and(absTick_, 0x4) {
                factor_ := shr(128, mul(factor_, FACTOR03))
            }
            if and(absTick_, 0x8) {
                factor_ := shr(128, mul(factor_, FACTOR04))
            }
            if and(absTick_, 0x10) {
                factor_ := shr(128, mul(factor_, FACTOR05))
            }
            if and(absTick_, 0x20) {
                factor_ := shr(128, mul(factor_, FACTOR06))
            }
            if and(absTick_, 0x40) {
                factor_ := shr(128, mul(factor_, FACTOR07))
            }
            if and(absTick_, 0x80) {
                factor_ := shr(128, mul(factor_, FACTOR08))
            }
            if and(absTick_, 0x100) {
                factor_ := shr(128, mul(factor_, FACTOR09))
            }
            if and(absTick_, 0x200) {
                factor_ := shr(128, mul(factor_, FACTOR10))
            }
            if and(absTick_, 0x400) {
                factor_ := shr(128, mul(factor_, FACTOR11))
            }
            if and(absTick_, 0x800) {
                factor_ := shr(128, mul(factor_, FACTOR12))
            }
            if and(absTick_, 0x1000) {
                factor_ := shr(128, mul(factor_, FACTOR13))
            }
            if and(absTick_, 0x2000) {
                factor_ := shr(128, mul(factor_, FACTOR14))
            }
            if and(absTick_, 0x4000) {
                factor_ := shr(128, mul(factor_, FACTOR15))
            }

            let precision_ := 0
            if iszero(and(tick, 0x8000000000000000000000000000000000000000000000000000000000000000)) {
                factor_ := div(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, factor_)
                // we round up in the division so getTickAtRatio of the output price is always consistent
                if mod(factor_, 0x100000000) {
                    precision_ := 1
                }
            }
            ratioX96 := add(shr(32, factor_), precision_)
        }
    }

    /// @notice ratioX96 = (1.0015^tick) * 2^96
    /// @dev Throws if ratioX96 > max ratio || ratioX96 < min ratio
    /// @param ratioX96 The input ratio; ratio = (debt amount/collateral amount)
    /// @return tick The output tick for the above formula. Returns in round down form. if tick is 123.23 then 123, if tick is -123.23 then returns -124
    /// @return perfectRatioX96 perfect ratio for the above tick
    function getTickAtRatio(uint256 ratioX96) internal pure returns (int tick, uint perfectRatioX96) {
        assembly {
            if or(gt(ratioX96, MAX_RATIOX96), lt(ratioX96, MIN_RATIOX96)) {
                revert(0, 0)
            }

            let cond := lt(ratioX96, ZERO_TICK_SCALED_RATIO)
            let factor_

            if iszero(cond) {
                // if ratioX96 >= ZERO_TICK_SCALED_RATIO
                factor_ := div(mul(ratioX96, _1E26), ZERO_TICK_SCALED_RATIO)
            }
            if cond {
                // ratioX96 < ZERO_TICK_SCALED_RATIO
                factor_ := div(mul(ZERO_TICK_SCALED_RATIO, _1E26), ratioX96)
            }

            // put in https://www.wolframalpha.com/ whole equation: (1.0015^tick) * 2^96 * 10^26 / 79228162514264337593543950336

            // for tick = 16384
            // ratioX96 = (1.0015^16384) * 2^96 = 3665252098134783297721995888537077351735
            // 3665252098134783297721995888537077351735 * 10^26 / 79228162514264337593543950336 =
            // 4626198540796508716348404308345255985.06131964639489434655721
            if iszero(lt(factor_, 4626198540796508716348404308345255985)) {
                tick := or(tick, 0x4000)
                factor_ := div(mul(factor_, _1E26), 4626198540796508716348404308345255985)
            }
            // for tick = 8192
            // ratioX96 = (1.0015^8192) * 2^96 = 17040868196391020479062776466509865
            // 17040868196391020479062776466509865 * 10^26 / 79228162514264337593543950336 =
            // 21508599537851153911767490449162.3037648642153898377655505172
            if iszero(lt(factor_, 21508599537851153911767490449162)) {
                tick := or(tick, 0x2000)
                factor_ := div(mul(factor_, _1E26), 21508599537851153911767490449162)
            }
            // for tick = 4096
            // ratioX96 = (1.0015^4096) * 2^96 = 36743933851015821532611831851150
            // 36743933851015821532611831851150 * 10^26 / 79228162514264337593543950336 =
            // 46377364670549310883002866648.9777607649742626173648716941385
            if iszero(lt(factor_, 46377364670549310883002866649)) {
                tick := or(tick, 0x1000)
                factor_ := div(mul(factor_, _1E26), 46377364670549310883002866649)
            }
            // for tick = 2048
            // ratioX96 = (1.0015^2048) * 2^96 = 1706210527034005899209104452335
            // 1706210527034005899209104452335 * 10^26 / 79228162514264337593543950336 =
            // 2153540449365864845468344760.06357108484096046743300420319322
            if iszero(lt(factor_, 2153540449365864845468344760)) {
                tick := or(tick, 0x800)
                factor_ := div(mul(factor_, _1E26), 2153540449365864845468344760)
            }
            // for tick = 1024
            // ratioX96 = (1.0015^1024) * 2^96 = 367668226692760093024536487236
            // 367668226692760093024536487236 * 10^26 / 79228162514264337593543950336 =
            // 464062544207767844008185024.950588990554136265212906454481127
            if iszero(lt(factor_, 464062544207767844008185025)) {
                tick := or(tick, 0x400)
                factor_ := div(mul(factor_, _1E26), 464062544207767844008185025)
            }
            // for tick = 512
            // ratioX96 = (1.0015^512) * 2^96 = 170674186729409605620119663668
            // 170674186729409605620119663668 * 10^26 / 79228162514264337593543950336 =
            // 215421109505955298802281577.031879604792139232258508172947569
            if iszero(lt(factor_, 215421109505955298802281577)) {
                tick := or(tick, 0x200)
                factor_ := div(mul(factor_, _1E26), 215421109505955298802281577)
            }
            // for tick = 256
            // ratioX96 = (1.0015^256) * 2^96 = 116285004205991934861656513301
            // 116285004205991934861656513301 * 10^26 / 79228162514264337593543950336 =
            // 146772309890508740607270614.667650899656438875541505058062410
            if iszero(lt(factor_, 146772309890508740607270615)) {
                tick := or(tick, 0x100)
                factor_ := div(mul(factor_, _1E26), 146772309890508740607270615)
            }
            // for tick = 128
            // ratioX96 = (1.0015^128) * 2^96 = 95984619659632141743747099590
            // 95984619659632141743747099590 * 10^26 / 79228162514264337593543950336 =
            // 121149622323187099817270416.157248837742741760456796835775887
            if iszero(lt(factor_, 121149622323187099817270416)) {
                tick := or(tick, 0x80)
                factor_ := div(mul(factor_, _1E26), 121149622323187099817270416)
            }
            // for tick = 64
            // ratioX96 = (1.0015^64) * 2^96 = 87204845308406958006717891124
            // 87204845308406958006717891124 * 10^26 / 79228162514264337593543950336 =
            // 110067989135437147685980801.568068573422377364214113968609839
            if iszero(lt(factor_, 110067989135437147685980801)) {
                tick := or(tick, 0x40)
                factor_ := div(mul(factor_, _1E26), 110067989135437147685980801)
            }
            // for tick = 32
            // ratioX96 = (1.0015^32) * 2^96 = 83120873769022354029916374475
            // 83120873769022354029916374475 * 10^26 / 79228162514264337593543950336 =
            // 104913292358707887270979599.831816586773651266562785765558183
            if iszero(lt(factor_, 104913292358707887270979600)) {
                tick := or(tick, 0x20)
                factor_ := div(mul(factor_, _1E26), 104913292358707887270979600)
            }
            // for tick = 16
            // ratioX96 = (1.0015^16) * 2^96 = 81151180492336368327184716176
            // 81151180492336368327184716176 * 10^26 / 79228162514264337593543950336 =
            // 102427189924701091191840927.762844039579442328381455567932128
            if iszero(lt(factor_, 102427189924701091191840928)) {
                tick := or(tick, 0x10)
                factor_ := div(mul(factor_, _1E26), 102427189924701091191840928)
            }
            // for tick = 8
            // ratioX96 = (1.0015^8) * 2^96 = 80183906840906820640659903620
            // 80183906840906820640659903620 * 10^26 / 79228162514264337593543950336 =
            // 101206318935480056907421312.890625
            if iszero(lt(factor_, 101206318935480056907421313)) {
                tick := or(tick, 0x8)
                factor_ := div(mul(factor_, _1E26), 101206318935480056907421313)
            }
            // for tick = 4
            // ratioX96 = (1.0015^4) * 2^96 = 79704602139525152702959747603
            // 79704602139525152702959747603 * 10^26 / 79228162514264337593543950336 =
            // 100601351350506250000000000
            if iszero(lt(factor_, 100601351350506250000000000)) {
                tick := or(tick, 0x4)
                factor_ := div(mul(factor_, _1E26), 100601351350506250000000000)
            }
            // for tick = 2
            // ratioX96 = (1.0015^2) * 2^96 = 79466025265172787701084167660
            // 79466025265172787701084167660 * 10^26 / 79228162514264337593543950336 =
            // 100300225000000000000000000
            if iszero(lt(factor_, 100300225000000000000000000)) {
                tick := or(tick, 0x2)
                factor_ := div(mul(factor_, _1E26), 100300225000000000000000000)
            }
            // for tick = 1
            // ratioX96 = (1.0015^1) * 2^96 = 79347004758035734099934266261
            // 79347004758035734099934266261 * 10^26 / 79228162514264337593543950336 =
            // 100150000000000000000000000
            if iszero(lt(factor_, 100150000000000000000000000)) {
                tick := or(tick, 0x1)
                factor_ := div(mul(factor_, _1E26), 100150000000000000000000000)
            }
            if iszero(cond) {
                // if ratioX96 >= ZERO_TICK_SCALED_RATIO
                perfectRatioX96 := div(mul(ratioX96, _1E26), factor_)
            }
            if cond {
                // ratioX96 < ZERO_TICK_SCALED_RATIO
                tick := not(tick)
                perfectRatioX96 := div(mul(ratioX96, factor_), 100150000000000000000000000)
            }
            // perfect ratio should always be <= ratioX96
            // not sure if it can ever be bigger but better to have extra checks
            if gt(perfectRatioX96, ratioX96) {
                revert(0, 0)
            }
        }
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

abstract contract Error {
    error FluidVaultError(uint256 errorId_);

    /// @notice used to simulate liquidation to find the maximum liquidatable amounts
    error FluidLiquidateResult(uint256 colLiquidated, uint256 debtLiquidated);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

library ErrorTypes {
    /***********************************|
    |           Vault Factory           | 
    |__________________________________*/

    uint256 internal constant VaultFactory__InvalidOperation = 30001;
    uint256 internal constant VaultFactory__Unauthorized = 30002;
    uint256 internal constant VaultFactory__SameTokenNotAllowed = 30003;
    uint256 internal constant VaultFactory__InvalidParams = 30004;
    uint256 internal constant VaultFactory__InvalidVault = 30005;
    uint256 internal constant VaultFactory__InvalidVaultAddress = 30006;
    uint256 internal constant VaultFactory__OnlyDelegateCallAllowed = 30007;

    /***********************************|
    |            Vault                  | 
    |__________________________________*/

    /// @notice thrown at reentrancy
    uint256 internal constant Vault__AlreadyEntered = 31001;

    /// @notice thrown when user sends deposit & borrow amount as 0
    uint256 internal constant Vault__InvalidOperateAmount = 31002;

    /// @notice thrown when msg.value is not in sync with native token deposit or payback
    uint256 internal constant Vault__InvalidMsgValueOperate = 31003;

    /// @notice thrown when msg.sender is not the owner of the vault
    uint256 internal constant Vault__NotAnOwner = 31004;

    /// @notice thrown when user's position does not exist. Sending the wrong index from the frontend
    uint256 internal constant Vault__TickIsEmpty = 31005;

    /// @notice thrown when the user's position is above CF and the user tries to make it more risky by trying to withdraw or borrow
    uint256 internal constant Vault__PositionAboveCF = 31006;

    /// @notice thrown when the top tick is not initialized. Happens if the vault is totally new or all the user's left
    uint256 internal constant Vault__TopTickDoesNotExist = 31007;

    /// @notice thrown when msg.value in liquidate is not in sync payback
    uint256 internal constant Vault__InvalidMsgValueLiquidate = 31008;

    /// @notice thrown when slippage is more on liquidation than what the liquidator sent
    uint256 internal constant Vault__ExcessSlippageLiquidation = 31009;

    /// @notice thrown when msg.sender is not the rebalancer/reserve contract
    uint256 internal constant Vault__NotRebalancer = 31010;

    /// @notice thrown when NFT of one vault interacts with the NFT of other vault
    uint256 internal constant Vault__NftNotOfThisVault = 31011;

    /// @notice thrown when the token is not initialized on the liquidity contract
    uint256 internal constant Vault__TokenNotInitialized = 31012;

    /// @notice thrown when admin updates fallback if a non-auth calls vault
    uint256 internal constant Vault__NotAnAuth = 31013;

    /// @notice thrown in operate when user tries to witdhraw more collateral than deposited
    uint256 internal constant Vault__ExcessCollateralWithdrawal = 31014;

    /// @notice thrown in operate when user tries to payback more debt than borrowed
    uint256 internal constant Vault__ExcessDebtPayback = 31015;

    /// @notice thrown when user try to withdrawal more than operate's withdrawal limit
    uint256 internal constant Vault__WithdrawMoreThanOperateLimit = 31016;

    /// @notice thrown when caller of liquidityCallback is not Liquidity
    uint256 internal constant Vault__InvalidLiquidityCallbackAddress = 31017;

    /// @notice thrown when reentrancy is not already on
    uint256 internal constant Vault__NotEntered = 31018;

    /// @notice thrown when someone directly calls operate or secondary implementation contract
    uint256 internal constant Vault__OnlyDelegateCallAllowed = 31019;

    /// @notice thrown when the safeTransferFrom for a token amount failed
    uint256 internal constant Vault__TransferFromFailed = 31020;

    /// @notice thrown when exchange price overflows while updating on storage
    uint256 internal constant Vault__ExchangePriceOverFlow = 31021;

    /// @notice thrown when debt to liquidate amt is sent wrong
    uint256 internal constant Vault__InvalidLiquidationAmt = 31022;

    /// @notice thrown when user debt or collateral goes above 2**128 or below -2**128
    uint256 internal constant Vault__UserCollateralDebtExceed = 31023;

    /// @notice thrown if on liquidation branch debt becomes lower than 100
    uint256 internal constant Vault__BranchDebtTooLow = 31024;

    /// @notice thrown when tick's debt is less than 10000
    uint256 internal constant Vault__TickDebtTooLow = 31025;

    /// @notice thrown when the received new liquidity exchange price is of unexpected value (< than the old one)
    uint256 internal constant Vault__LiquidityExchangePriceUnexpected = 31026;

    /// @notice thrown when user's debt is less than 10000
    uint256 internal constant Vault__UserDebtTooLow = 31027;

    /// @notice thrown when on only payback and only deposit the ratio of position increases
    uint256 internal constant Vault__InvalidPaybackOrDeposit = 31028;

    /// @notice thrown when liquidation just happens of a single partial or when there's nothing to liquidate
    uint256 internal constant Vault__InvalidLiquidation = 31029;

    /// @notice thrown when msg.value is sent wrong in rebalance
    uint256 internal constant Vault__InvalidMsgValueInRebalance = 31030;

    /// @notice thrown when nothing rebalanced
    uint256 internal constant Vault__NothingToRebalance = 31031;

    /// @notice thrown on unforseen liquidation scenarios. Might never come in use.
    uint256 internal constant Vault__LiquidationReverts = 31032;

    /// @notice thrown when oracle price is > 1e54
    uint256 internal constant Vault__InvalidOraclePrice = 31033;

    /// @notice thrown when constants are not set properly via contructor
    uint256 internal constant Vault__ImproperConstantsSetup = 31034;

    /// @notice thrown when externally calling fetchLatestPosition function
    uint256 internal constant Vault__FetchLatestPositionFailed = 31035;

    /// @notice thrown when dex callback is not from dex
    uint256 internal constant Vault__InvalidDexCallbackAddress = 31036;

    /// @notice thrown when dex callback is already set
    uint256 internal constant Vault__DexFromAddressAlreadySet = 31037;

    /// @notice thrown when an invalid min / max amounts config is passed to rebalance()
    uint256 internal constant Vault__InvalidMinMaxInRebalance = 31038;

    /***********************************|
    |              ERC721               | 
    |__________________________________*/

    uint256 internal constant ERC721__InvalidParams = 32001;
    uint256 internal constant ERC721__Unauthorized = 32002;
    uint256 internal constant ERC721__InvalidOperation = 32003;
    uint256 internal constant ERC721__UnsafeRecipient = 32004;
    uint256 internal constant ERC721__OutOfBoundsIndex = 32005;

    /***********************************|
    |            Vault Admin            | 
    |__________________________________*/

    /// @notice thrown when admin tries to setup invalid value which are crossing limits
    uint256 internal constant VaultAdmin__ValueAboveLimit = 33001;

    /// @notice when someone directly calls admin implementation contract
    uint256 internal constant VaultAdmin__OnlyDelegateCallAllowed = 33002;

    /// @notice thrown when auth sends NFT ID as 0 while collecting dust debt
    uint256 internal constant VaultAdmin__NftIdShouldBeNonZero = 33003;

    /// @notice thrown when trying to collect dust debt of NFT which is not of this vault
    uint256 internal constant VaultAdmin__NftNotOfThisVault = 33004;

    /// @notice thrown when dust debt of NFT is 0, meaning nothing to collect
    uint256 internal constant VaultAdmin__DustDebtIsZero = 33005;

    /// @notice thrown when final debt after liquidation is not 0, meaning position 100% liquidated
    uint256 internal constant VaultAdmin__FinalDebtShouldBeZero = 33006;

    /// @notice thrown when NFT is not liquidated state
    uint256 internal constant VaultAdmin__NftNotLiquidated = 33007;

    /// @notice thrown when total absorbed dust debt is 0
    uint256 internal constant VaultAdmin__AbsorbedDustDebtIsZero = 33008;

    /// @notice thrown when address is set as 0
    uint256 internal constant VaultAdmin__AddressZeroNotAllowed = 33009;

    /***********************************|
    |            Vault Rewards          | 
    |__________________________________*/

    uint256 internal constant VaultRewards__Unauthorized = 34001;
    uint256 internal constant VaultRewards__AddressZero = 34002;
    uint256 internal constant VaultRewards__InvalidParams = 34003;
    uint256 internal constant VaultRewards__NewMagnifierSameAsOldMagnifier = 34004;
    uint256 internal constant VaultRewards__NotTheInitiator = 34005;
    uint256 internal constant VaultRewards__NotTheGovernance = 34006;
    uint256 internal constant VaultRewards__AlreadyStarted = 34007;
    uint256 internal constant VaultRewards__RewardsNotStartedOrEnded = 34008;
    uint256 internal constant VaultRewards__InvalidStartTime = 34009;
    uint256 internal constant VaultRewards__AlreadyEnded = 34010;

    /***********************************|
    |          Vault DEX Types          | 
    |__________________________________*/

    uint256 internal constant VaultDex__InvalidOperateAmount = 35001;
    uint256 internal constant VaultDex__DebtSharesPaidMoreThanAvailableLiquidation = 35002;

    /***********************************|
    |        Vault Borrow Rewards       | 
    |__________________________________*/

    uint256 internal constant VaultBorrowRewards__Unauthorized = 36001;
    uint256 internal constant VaultBorrowRewards__AddressZero = 36002;
    uint256 internal constant VaultBorrowRewards__InvalidParams = 36003;
    uint256 internal constant VaultBorrowRewards__NewMagnifierSameAsOldMagnifier = 36004;
    uint256 internal constant VaultBorrowRewards__NotTheInitiator = 36005;
    uint256 internal constant VaultBorrowRewards__NotTheGovernance = 36006;
    uint256 internal constant VaultBorrowRewards__AlreadyStarted = 36007;
    uint256 internal constant VaultBorrowRewards__RewardsNotStartedOrEnded = 36008;
    uint256 internal constant VaultBorrowRewards__InvalidStartTime = 36009;
    uint256 internal constant VaultBorrowRewards__AlreadyEnded = 36010;
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IFluidVaultT1 {
    /// @notice returns the vault id
    function VAULT_ID() external view returns (uint256);

    /// @notice reads uint256 data `result_` from storage at a bytes32 storage `slot_` key.
    function readFromStorage(bytes32 slot_) external view returns (uint256 result_);

    struct ConstantViews {
        address liquidity;
        address factory;
        address adminImplementation;
        address secondaryImplementation;
        address supplyToken;
        address borrowToken;
        uint8 supplyDecimals;
        uint8 borrowDecimals;
        uint vaultId;
        bytes32 liquiditySupplyExchangePriceSlot;
        bytes32 liquidityBorrowExchangePriceSlot;
        bytes32 liquidityUserSupplySlot;
        bytes32 liquidityUserBorrowSlot;
    }

    /// @notice returns all Vault constants
    function constantsView() external view returns (ConstantViews memory constantsView_);

    /// @notice fetches the latest user position after a liquidation
    function fetchLatestPosition(
        int256 positionTick_,
        uint256 positionTickId_,
        uint256 positionRawDebt_,
        uint256 tickData_
    )
        external
        view
        returns (
            int256, // tick
            uint256, // raw debt
            uint256, // raw collateral
            uint256, // branchID_
            uint256 // branchData_
        );

    /// @notice calculates the updated vault exchange prices
    function updateExchangePrices(
        uint256 vaultVariables2_
    )
        external
        view
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice calculates the updated vault exchange prices and writes them to storage
    function updateExchangePricesOnStorage()
        external
        returns (
            uint256 liqSupplyExPrice_,
            uint256 liqBorrowExPrice_,
            uint256 vaultSupplyExPrice_,
            uint256 vaultBorrowExPrice_
        );

    /// @notice returns the liquidity contract address
    function LIQUIDITY() external view returns (address);

    function operate(
        uint256 nftId_, // if 0 then new position
        int256 newCol_, // if negative then withdraw
        int256 newDebt_, // if negative then payback
        address to_ // address at which the borrow & withdraw amount should go to. If address(0) then it'll go to msg.sender
    )
        external
        payable
        returns (
            uint256, // nftId_
            int256, // final supply amount. if - then withdraw
            int256 // final borrow amount. if - then payback
        );

    function liquidate(
        uint256 debtAmt_,
        uint256 colPerUnitDebt_, // min collateral needed per unit of debt in 1e18
        address to_,
        bool absorb_
    ) external payable returns (uint actualDebtAmt_, uint actualColAmt_);

    function absorb() external;

    function rebalance() external payable returns (int supplyAmt_, int borrowAmt_);

    error FluidLiquidateResult(uint256 colLiquidated, uint256 debtLiquidated);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

contract Events {
    /// @notice emitted when the supply rate magnifier config is updated
    event LogUpdateSupplyRateMagnifier(uint supplyRateMagnifier_);

    /// @notice emitted when the borrow rate magnifier config is updated
    event LogUpdateBorrowRateMagnifier(uint borrowRateMagnifier_);

    /// @notice emitted when the collateral factor config is updated
    event LogUpdateCollateralFactor(uint collateralFactor_);

    /// @notice emitted when the liquidation threshold config is updated
    event LogUpdateLiquidationThreshold(uint liquidationThreshold_);

    /// @notice emitted when the liquidation max limit config is updated
    event LogUpdateLiquidationMaxLimit(uint liquidationMaxLimit_);

    /// @notice emitted when the withdrawal gap config is updated
    event LogUpdateWithdrawGap(uint withdrawGap_);

    /// @notice emitted when the liquidation penalty config is updated
    event LogUpdateLiquidationPenalty(uint liquidationPenalty_);

    /// @notice emitted when the borrow fee config is updated
    event LogUpdateBorrowFee(uint borrowFee_);

    /// @notice emitted when the core setting configs are updated
    event LogUpdateCoreSettings(
        uint supplyRateMagnifier_,
        uint borrowRateMagnifier_,
        uint collateralFactor_,
        uint liquidationThreshold_,
        uint liquidationMaxLimit_,
        uint withdrawGap_,
        uint liquidationPenalty_,
        uint borrowFee_
    );

    /// @notice emitted when the oracle is updated
    event LogUpdateOracle(address indexed newOracle_);

    /// @notice emitted when the allowed rebalancer is updated
    event LogUpdateRebalancer(address indexed newRebalancer_);

    /// @notice emitted when funds are rescued
    event LogRescueFunds(address indexed token_);

    /// @notice emitted when dust debt is absorbed for `nftIds_`
    event LogAbsorbDustDebt(uint256[] nftIds_, uint256 absorbedDustDebt_);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Variables } from "../common/variables.sol";
import { Events } from "./events.sol";
import { ErrorTypes } from "../../errorTypes.sol";
import { Error } from "../../error.sol";
import { IFluidVaultT1 } from "../../interfaces/iVaultT1.sol";
import { BigMathMinified } from "../../../../libraries/bigMathMinified.sol";
import { TickMath } from "../../../../libraries/tickMath.sol";
import { SafeTransfer } from "../../../../libraries/safeTransfer.sol";

/// @notice Fluid Vault protocol Admin Module contract.
///         Implements admin related methods to set configs such as liquidation params, rates
///         oracle address etc.
///         Methods are limited to be called via delegateCall only. Vault CoreModule ("VaultT1" contract)
///         is expected to call the methods implemented here after checking the msg.sender is authorized.
///         All methods update the exchange prices in storage before changing configs.
contract FluidVaultT1Admin is Variables, Events, Error {
    uint private constant X8 = 0xff;
    uint private constant X10 = 0x3ff;
    uint private constant X16 = 0xffff;
    uint private constant X19 = 0x7ffff;
    uint private constant X24 = 0xffffff;
    uint internal constant X64 = 0xffffffffffffffff;
    uint private constant X96 = 0xffffffffffffffffffffffff;
    address private constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address private immutable addressThis;

    constructor() {
        addressThis = address(this);
    }

    modifier _verifyCaller() {
        if (address(this) == addressThis) {
            revert FluidVaultError(ErrorTypes.VaultAdmin__OnlyDelegateCallAllowed);
        }
        _;
    }

    /// @dev updates exchange price on storage, called on all admin methods in combination with _verifyCaller modifier so
    /// only called by authorized delegatecall
    modifier _updateExchangePrice() {
        IFluidVaultT1(address(this)).updateExchangePricesOnStorage();
        _;
    }

    function _checkLiquidationMaxLimitAndPenalty(uint liquidationMaxLimit_, uint liquidationPenalty_) private pure {
        // liquidation max limit with penalty should not go above 99.7%
        // As liquidation with penalty can happen from liquidation Threshold to max limit
        // If it goes above 100% than that means liquidator is getting more collateral than user's available
        if ((liquidationMaxLimit_ + liquidationPenalty_) > 9970) {
            revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);
        }
    }

    /// @notice updates the supply rate magnifier to `supplyRateMagnifier_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateSupplyRateMagnifier(uint supplyRateMagnifier_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateSupplyRateMagnifier(supplyRateMagnifier_);

        if (supplyRateMagnifier_ > X16) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000) |
            supplyRateMagnifier_;
    }

    /// @notice updates the borrow rate magnifier to `borrowRateMagnifier_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateBorrowRateMagnifier(uint borrowRateMagnifier_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateBorrowRateMagnifier(borrowRateMagnifier_);

        if (borrowRateMagnifier_ > X16) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2 & 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffff) |
            (borrowRateMagnifier_ << 16);
    }

    /// @notice updates the collateral factor to `collateralFactor_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateCollateralFactor(uint collateralFactor_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateCollateralFactor(collateralFactor_);

        uint vaultVariables2_ = vaultVariables2;
        uint liquidationThreshold_ = ((vaultVariables2_ >> 42) & X10);

        collateralFactor_ = collateralFactor_ / 10;

        if (collateralFactor_ >= liquidationThreshold_) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2_ & 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffc00ffffffff) |
            (collateralFactor_ << 32);
    }

    /// @notice updates the liquidation threshold to `liquidationThreshold_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateLiquidationThreshold(uint liquidationThreshold_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateLiquidationThreshold(liquidationThreshold_);

        uint vaultVariables2_ = vaultVariables2;
        uint collateralFactor_ = ((vaultVariables2_ >> 32) & X10);
        uint liquidationMaxLimit_ = ((vaultVariables2_ >> 52) & X10);

        liquidationThreshold_ = liquidationThreshold_ / 10;

        if ((collateralFactor_ >= liquidationThreshold_) || (liquidationThreshold_ >= liquidationMaxLimit_))
            revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2_ & 0xfffffffffffffffffffffffffffffffffffffffffffffffffff003ffffffffff) |
            (liquidationThreshold_ << 42);
    }

    /// @notice updates the liquidation max limit to `liquidationMaxLimit_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateLiquidationMaxLimit(uint liquidationMaxLimit_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateLiquidationMaxLimit(liquidationMaxLimit_);

        uint vaultVariables2_ = vaultVariables2;
        uint liquidationThreshold_ = ((vaultVariables2_ >> 42) & X10);
        uint liquidationPenalty_ = ((vaultVariables2_ >> 72) & X10);

        // both are in 1e2 decimals (1e2 = 1%)
        _checkLiquidationMaxLimitAndPenalty(liquidationMaxLimit_, liquidationPenalty_);

        liquidationMaxLimit_ = liquidationMaxLimit_ / 10;

        if (liquidationThreshold_ >= liquidationMaxLimit_)
            revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2_ & 0xffffffffffffffffffffffffffffffffffffffffffffffffc00fffffffffffff) |
            (liquidationMaxLimit_ << 52);
    }

    /// @notice updates the withdrawal gap to `withdrawGap_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateWithdrawGap(uint withdrawGap_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateWithdrawGap(withdrawGap_);

        withdrawGap_ = withdrawGap_ / 10;

        // withdrawGap must not be > 100%
        if (withdrawGap_ > 1000) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2 & 0xffffffffffffffffffffffffffffffffffffffffffffff003fffffffffffffff) |
            (withdrawGap_ << 62);
    }

    /// @notice updates the liquidation penalty to `liquidationPenalty_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateLiquidationPenalty(uint liquidationPenalty_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateLiquidationPenalty(liquidationPenalty_);

        uint vaultVariables2_ = vaultVariables2;
        uint liquidationMaxLimit_ = ((vaultVariables2_ >> 52) & X10);

        // Converting liquidationMaxLimit_ in 1e2 decimals (1e2 = 1%)
        _checkLiquidationMaxLimitAndPenalty((liquidationMaxLimit_ * 10), liquidationPenalty_);

        if (liquidationPenalty_ > X10) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2_ & 0xfffffffffffffffffffffffffffffffffffffffffffc00ffffffffffffffffff) |
            (liquidationPenalty_ << 72);
    }

    /// @notice updates the borrow fee to `borrowFee_`. Input in 1e2 (1% = 100, 100% = 10_000).
    function updateBorrowFee(uint borrowFee_) public _updateExchangePrice _verifyCaller {
        emit LogUpdateBorrowFee(borrowFee_);

        if (borrowFee_ > X10) revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);

        vaultVariables2 =
            (vaultVariables2 & 0xfffffffffffffffffffffffffffffffffffffffff003ffffffffffffffffffff) |
            (borrowFee_ << 82);
    }

    /// @notice updates the all Vault core settings according to input params.
    /// All input values are expected in 1e2 (1% = 100, 100% = 10_000).
    function updateCoreSettings(
        uint256 supplyRateMagnifier_,
        uint256 borrowRateMagnifier_,
        uint256 collateralFactor_,
        uint256 liquidationThreshold_,
        uint256 liquidationMaxLimit_,
        uint256 withdrawGap_,
        uint256 liquidationPenalty_,
        uint256 borrowFee_
    ) public _updateExchangePrice _verifyCaller {
        // emitting the event at the start as then we are updating numbers to store in a more optimized way
        emit LogUpdateCoreSettings(
            supplyRateMagnifier_,
            borrowRateMagnifier_,
            collateralFactor_,
            liquidationThreshold_,
            liquidationMaxLimit_,
            withdrawGap_,
            liquidationPenalty_,
            borrowFee_
        );

        _checkLiquidationMaxLimitAndPenalty(liquidationMaxLimit_, liquidationPenalty_);

        collateralFactor_ = collateralFactor_ / 10;
        liquidationThreshold_ = liquidationThreshold_ / 10;
        liquidationMaxLimit_ = liquidationMaxLimit_ / 10;
        withdrawGap_ = withdrawGap_ / 10;

        if (
            (supplyRateMagnifier_ > X16) ||
            (borrowRateMagnifier_ > X16) ||
            (collateralFactor_ >= liquidationThreshold_) ||
            (liquidationThreshold_ >= liquidationMaxLimit_) ||
            (withdrawGap_ > X10) ||
            (liquidationPenalty_ > X10) ||
            (borrowFee_ > X10)
        ) {
            revert FluidVaultError(ErrorTypes.VaultAdmin__ValueAboveLimit);
        }

        vaultVariables2 =
            (vaultVariables2 & 0xfffffffffffffffffffffffffffffffffffffffff00000000000000000000000) |
            supplyRateMagnifier_ |
            (borrowRateMagnifier_ << 16) |
            (collateralFactor_ << 32) |
            (liquidationThreshold_ << 42) |
            (liquidationMaxLimit_ << 52) |
            (withdrawGap_ << 62) |
            (liquidationPenalty_ << 72) |
            (borrowFee_ << 82);
    }

    /// @notice updates the Vault oracle to `newOracle_`. Must implement the FluidOracle interface.
    function updateOracle(address newOracle_) public _updateExchangePrice _verifyCaller {
        if (newOracle_ == address(0)) revert FluidVaultError(ErrorTypes.VaultAdmin__AddressZeroNotAllowed);

        // Removing current oracle by masking only first 96 bits then inserting new oracle as bits
        vaultVariables2 = (vaultVariables2 & X96) | (uint256(uint160(newOracle_)) << 96);

        emit LogUpdateOracle(newOracle_);
    }

    /// @notice updates the allowed rebalancer to `newRebalancer_`.
    function updateRebalancer(address newRebalancer_) public _updateExchangePrice _verifyCaller {
        if (newRebalancer_ == address(0)) revert FluidVaultError(ErrorTypes.VaultAdmin__AddressZeroNotAllowed);

        rebalancer = newRebalancer_;

        emit LogUpdateRebalancer(newRebalancer_);
    }

    /// @notice sends any potentially stuck funds to Liquidity contract.
    /// @dev this contract never holds any funds as all operations send / receive funds from user <-> Liquidity.
    function rescueFunds(address token_) external _verifyCaller {
        if (token_ == NATIVE_TOKEN) {
            SafeTransfer.safeTransferNative(IFluidVaultT1(address(this)).LIQUIDITY(), address(this).balance);
        } else {
            SafeTransfer.safeTransfer(
                token_,
                IFluidVaultT1(address(this)).LIQUIDITY(),
                IERC20(token_).balanceOf(address(this))
            );
        }

        emit LogRescueFunds(token_);
    }

    /// @notice absorbs accumulated dust debt
    /// @dev in decades if a lot of positions are 100% liquidated (aka absorbed) then dust debt can mount up
    /// which is basically sort of an extra revenue for the protocol.
    //
    // this function might never come in use that's why adding it in admin module
    function absorbDustDebt(uint[] memory nftIds_) public _verifyCaller {
        uint256 vaultVariables_ = vaultVariables;
        // re-entrancy check
        if (vaultVariables_ & 1 == 0) {
            // Updating on storage
            vaultVariables = vaultVariables_ | 1;
        } else {
            revert FluidVaultError(ErrorTypes.Vault__AlreadyEntered);
        }

        uint nftId_;
        uint posData_;
        int posTick_;
        uint tickId_;
        uint posCol_;
        uint posDebt_;
        uint posDustDebt_;
        uint tickData_;

        uint absorbedDustDebt_ = absorbedDustDebt;

        for (uint i = 0; i < nftIds_.length; ) {
            nftId_ = nftIds_[i];
            if (nftId_ == 0) {
                revert FluidVaultError(ErrorTypes.VaultAdmin__NftIdShouldBeNonZero);
            }

            // user's position data
            posData_ = positionData[nftId_];

            if (posData_ == 0) {
                revert FluidVaultError(ErrorTypes.VaultAdmin__NftNotOfThisVault);
            }

            posCol_ = (posData_ >> 45) & X64;
            // Converting big number into normal number
            posCol_ = (posCol_ >> 8) << (posCol_ & X8);

            posDustDebt_ = (posData_ >> 109) & X64;
            // Converting big number into normal number
            posDustDebt_ = (posDustDebt_ >> 8) << (posDustDebt_ & X8);

            if (posDustDebt_ == 0) {
                revert FluidVaultError(ErrorTypes.VaultAdmin__DustDebtIsZero);
            }

            // borrow position (has collateral & debt)
            posTick_ = posData_ & 2 == 2 ? int((posData_ >> 2) & X19) : -int((posData_ >> 2) & X19);
            tickId_ = (posData_ >> 21) & X24;

            posDebt_ = (TickMath.getRatioAtTick(int24(posTick_)) * posCol_) >> 96;

            // Tick data from user's tick
            tickData_ = tickData[posTick_];

            // Checking if tick is liquidated OR if the total IDs of tick is greater than user's tick ID
            if (((tickData_ & 1) == 1) || (((tickData_ >> 1) & X24) > tickId_)) {
                // User got liquidated
                (, posDebt_, , , ) = IFluidVaultT1(address(this)).fetchLatestPosition(
                    posTick_,
                    tickId_,
                    posDebt_,
                    tickData_
                );
                if (posDebt_ > 0) {
                    revert FluidVaultError(ErrorTypes.VaultAdmin__FinalDebtShouldBeZero);
                }
                // absorbing user's debt as it's 100% or almost 100% liquidated
                absorbedDustDebt_ = absorbedDustDebt_ + posDustDebt_;
                // making position as supply only
                positionData[nftId_] = 1;
            } else {
                revert FluidVaultError(ErrorTypes.VaultAdmin__NftNotLiquidated);
            }

            unchecked {
                i++;
            }
        }

        if (absorbedDustDebt_ == 0) {
            revert FluidVaultError(ErrorTypes.VaultAdmin__AbsorbedDustDebtIsZero);
        }

        uint totalBorrow_ = (vaultVariables_ >> 146) & X64;
        // Converting big number into normal number
        totalBorrow_ = (totalBorrow_ >> 8) << (totalBorrow_ & X8);
        // note: by default dust debt is not added into total borrow but on 100% liquidation (aka absorb) dust debt equivalent
        // is removed from total borrow so adding it back again here
        totalBorrow_ = totalBorrow_ + absorbedDustDebt_;
        totalBorrow_ = BigMathMinified.toBigNumber(totalBorrow_, 56, 8, BigMathMinified.ROUND_UP);

        // adding absorbed dust debt to total borrow so it will get included in the next rebalancing.
        // there is some fuzziness here as when the position got fully liquidated (aka absorbed) the exchange price was different
        // than what it'll be now. The fuzziness which will be extremely small so we can ignore it
        // updating on storage
        vaultVariables =
            (vaultVariables_ & 0xfffffffffffc0000000000000003ffffffffffffffffffffffffffffffffffff) |
            (totalBorrow_ << 146);

        // updating on storage
        absorbedDustDebt = 0;

        emit LogAbsorbDustDebt(nftIds_, absorbedDustDebt_);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.21;

contract Variables {
    /***********************************|
    |         Storage Variables         |
    |__________________________________*/

    /// note: in all variables. For tick >= 0 are represented with bit as 1, tick < 0 are represented with bit as 0
    /// note: read all the variables through storageRead.sol

    /// note: vaultVariables contains vault variables which need regular updates through transactions
    /// First 1 bit => 0 => re-entrancy. If 0 then allow transaction to go, else throw.
    /// Next 1 bit => 1 => Is the current active branch liquidated? If true then check the branch's minima tick before creating a new position
    /// If the new tick is greater than minima tick then initialize a new branch, make that as current branch & do proper linking
    /// Next 1 bit => 2 => sign of topmost tick (0 -> negative; 1 -> positive)
    /// Next 19 bits => 3-21 => absolute value of topmost tick
    /// Next 30 bits => 22-51 => current branch ID
    /// Next 30 bits => 52-81 => total branch ID
    /// Next 64 bits => 82-145 => Total supply
    /// Next 64 bits => 146-209 => Total borrow
    /// Next 32 bits => 210-241 => Total positions
    uint256 internal vaultVariables;

    /// note: vaultVariables2 contains variables which do not update on every transaction. So mainly admin/auth set amount
    /// First 16 bits => 0-15 => supply rate magnifier; 10000 = 1x (Here 16 bits should be more than enough)
    /// Next 16 bits => 16-31 => borrow rate magnifier; 10000 = 1x (Here 16 bits should be more than enough)
    /// Next 10 bits => 32-41 => collateral factor. 800 = 0.8 = 80% (max precision of 0.1%)
    /// Next 10 bits => 42-51 => liquidation Threshold. 900 = 0.9 = 90% (max precision of 0.1%)
    /// Next 10 bits => 52-61 => liquidation Max Limit. 950 = 0.95 = 95% (max precision of 0.1%) (above this 100% liquidation can happen)
    /// Next 10 bits => 62-71 => withdraw gap. 100 = 0.1 = 10%. (max precision of 0.1%) (max 7 bits can also suffice for the requirement here of 0.1% to 10%). Needed to save some limits on withdrawals so liquidate can work seamlessly.
    /// Next 10 bits => 72-81 => liquidation penalty. 100 = 0.01 = 1%. (max precision of 0.01%) (max liquidation penantly can be 10.23%). Applies when tick is in between liquidation Threshold & liquidation Max Limit.
    /// Next 10 bits => 82-91 => borrow fee. 100 = 0.01 = 1%. (max precision of 0.01%) (max borrow fee can be 10.23%). Fees on borrow.
    /// Next 4  bits => 92-95 => empty
    /// Next 160 bits => 96-255 => Oracle address
    uint256 internal vaultVariables2;

    /// note: stores absorbed liquidity
    /// First 128 bits raw debt amount
    /// last 128 bits raw col amount
    uint256 internal absorbedLiquidity;

    /// position index => position data uint
    /// if the entire variable is 0 (meaning not initialized) at the start that means no position at all
    /// First 1 bit => 0 => position type (0 => borrow position; 1 => supply position)
    /// Next 1 bit => 1 => sign of user's tick (0 => negative; 1 => positive)
    /// Next 19 bits => 2-20 => absolute value of user's tick
    /// Next 24 bits => 21-44 => user's tick's id
    /// Below we are storing user's collateral & not debt, because the position can also be only collateral with no tick but it can never be only debt
    /// Next 64 bits => 45-108 => user's supply amount. Debt will be calculated through supply & ratio.
    /// Next 64 bits => 109-172 => user's dust debt amount. User's net debt = total debt - dust amount. Total debt is calculated through supply & ratio
    /// User won't pay any extra interest on dust debt & hence we will not show it as a debt on UI. For user's there's no dust.
    mapping(uint256 => uint256) internal positionData;

    /// Tick has debt only keeps data of non liquidated positions. liquidated tick's data stays in branch itself
    /// tick parent => uint (represents bool for 256 children)
    /// parent of (i)th tick:-
    /// if (i>=0) (i / 256);
    /// else ((i + 1) / 256) - 1
    /// first bit of the variable is the smallest tick & last bit is the biggest tick of that slot
    mapping(int256 => uint256) internal tickHasDebt;

    /// mapping tickId => tickData
    /// Tick related data. Total debt & other things
    /// First bit => 0 => If 1 then liquidated else not liquidated
    /// Next 24 bits => 1-24 => Total IDs. ID should start from 1.
    /// If not liquidated:
    /// Next 64 bits => 25-88 => raw debt
    /// If liquidated
    /// The below 3 things are of last ID. This is to be updated when user creates a new position
    /// Next 1 bit => 25 => Is 100% liquidated? If this is 1 meaning it was above max tick when it got liquidated (100% liquidated)
    /// Next 30 bits => 26-55 => branch ID where this tick got liquidated
    /// Next 50 bits => 56-105 => debt factor 50 bits (35 bits coefficient | 15 bits expansion)
    mapping(int256 => uint256) internal tickData;

    /// tick id => previous tick id liquidation data. ID starts from 1
    /// One tick ID contains 3 IDs of 80 bits in it, holding liquidation data of previously active but liquidated ticks
    /// 81 bits data below
    /// #### First 85 bits ####
    /// 1st bit => 0 => Is 100% liquidated? If this is 1 meaning it was above max tick when it got liquidated
    /// Next 30 bits => 1-30 => branch ID where this tick got liquidated
    /// Next 50 bits => 31-80 => debt factor 50 bits (35 bits coefficient | 15 bits expansion)
    /// #### Second 85 bits ####
    /// 85th bit => 85 => Is 100% liquidated? If this is 1 meaning it was above max tick when it got liquidated
    /// Next 30 bits => 86-115 => branch ID where this tick got liquidated
    /// Next 50 bits => 116-165 => debt factor 50 bits (35 bits coefficient | 15 bits expansion)
    /// #### Third 85 bits ####
    /// 170th bit => 170 => Is 100% liquidated? If this is 1 meaning it was above max tick when it got liquidated
    /// Next 30 bits => 171-200 => branch ID where this tick got liquidated
    /// Next 50 bits => 201-250 => debt factor 50 bits (35 bits coefficient | 15 bits expansion)
    mapping(int256 => mapping(uint256 => uint256)) internal tickId;

    /// mapping branchId => branchData
    /// First 2 bits => 0-1 => if 0 then not liquidated, if 1 then liquidated, if 2 then merged, if 3 then closed
    /// merged means the branch is merged into it's base branch
    /// closed means all the users are 100% liquidated
    /// Next 1 bit => 2 => minima tick sign of this branch. Will only be there if any liquidation happened.
    /// Next 19 bits => 3-21 => minima tick of this branch. Will only be there if any liquidation happened.
    /// Next 30 bits => 22-51 => Partials of minima tick of branch this is connected to. 0 if master branch.
    /// Next 64 bits => 52-115 Debt liquidity at this branch. Similar to last's top tick data. Remaining debt will move here from tickData after first liquidation
    /// If not merged
    /// Next 50 bits => 116-165 => Debt factor or of this branch. (35 bits coefficient | 15 bits expansion)
    /// If merged
    /// Next 50 bits => 116-165 => Connection/adjustment debt factor of this branch with the next branch.
    /// If closed
    /// Next 50 bits => 116-165 => Debt factor as 0. As all the user's positions are now fully gone
    /// following values are present always again (merged / not merged / closed)
    /// Next 30 bits => 166-195 => Branch's ID with which this branch is connected. If 0 then that means this is the master branch
    /// Next 1 bit => 196 => sign of minima tick of branch this is connected to. 0 if master branch.
    /// Next 19 bits => 197-215 => minima tick of branch this is connected to. 0 if master branch.
    mapping(uint256 => uint256) internal branchData;

    /// Exchange prices are in 1e12
    /// First 64 bits => 0-63 => Liquidity's collateral token supply exchange price
    /// First 64 bits => 64-127 => Liquidity's debt token borrow exchange price
    /// First 64 bits => 128-191 => Vault's collateral token supply exchange price
    /// First 64 bits => 192-255 => Vault's debt token borrow exchange price
    uint256 internal rates;

    /// address of rebalancer
    address internal rebalancer;

    uint256 internal absorbedDustDebt;
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