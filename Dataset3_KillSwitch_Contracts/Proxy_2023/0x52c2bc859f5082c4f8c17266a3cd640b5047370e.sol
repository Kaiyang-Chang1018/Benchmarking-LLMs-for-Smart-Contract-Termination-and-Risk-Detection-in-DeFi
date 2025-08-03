// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

/// @title Errors Interface
/// @notice Defines custom errors for the smart contract operations.
interface Errors {
    /// @notice Error for invalid asset address.
    error InvalidAssetAddress();

    /// @notice Error for mismatch between vault's asset and expected asset.
    error VaultAssetMismatch();

    /// @notice Error for invalid vault fees configuration.
    error InvalidVaultFees();

    /// @notice Error for invalid fee recipient address.
    error InvalidFeeRecipient();

    /// @notice Error for operations involving a zero amount.
    error ZeroAmount();

    /// @notice Error for operations involving a zero amount.
    error InvalidAmount();

    /// @notice Error for invalid recipient address.
    error InvalidRecipient();

    /// @notice Error for exceeding maximum allowed value or count.
    error MaxError();

    /// @notice Error for exceeding substraction.
    error InvalidSubstraction();

    /// @notice Error for insufficient funds in a strategy.
    /// @param strategy The strategy contract with insufficient funds.
    /// @param amount The amount attempted to be withdrawn.
    /// @param available The available amount in the strategy.
    error InsufficientFunds(IERC4626 strategy, uint256 amount, uint256 available);

    error QueueNotSet();

    error InsufficientVaultFunds(address vault, uint256 amount, uint256 available);
    /// @notice Error for total allotment exceeding allowed maximum.
    error AllotmentTotalTooHigh();

    /// @notice Error for expired permit deadline.
    /// @param deadline The deadline timestamp that has been exceeded.
    error PermitDeadlineExpired(uint256 deadline);

    /// @notice Error for invalid signer address.
    /// @param signer The address of the invalid signer.
    error InvalidSigner(address signer);

    /// @notice Error for vault being in an idle state when an active state is required.
    error VaultIsIdle();

    /// @notice Error for invalid implementation identifier.
    /// @param id The bytes32 identifier of the implementation.
    error InvalidImplementation(bytes32 id);

    /// @notice Error for failed initialization of a vault deployment.
    error VaultDeployInitFailed();

    /// @notice Error for an implementation identifier that already exists.
    /// @param id The bytes32 identifier of the existing implementation.
    error ImplementationAlreadyExists(bytes32 id);

    /// @notice Error for a non-existent implementation identifier.
    /// @param id The bytes32 identifier of the non-existent implementation.
    error ImplementationDoesNotExist(bytes32 id);

    /// @notice Error for attempting to add a vault that already exists.
    error VaultAlreadyExists();

    error VaultZeroAddress();

    error VaultDoesNotExist(address vault);

    error TotalVaultsAllowedExceeded(uint256 total);

    error VaultByTokenLimitExceeded(address token, uint256 total);

    error InvalidWithdrawlQueue();

    error InvalidDepositLimit();

    error UnfinalizedWithdrawl(address queue);

    error NotImplemented();

    error ERC20ApproveFail();

    error AdditionFail();

    error RemoveFail();

    error InvalidRewardTokenAddress();

    error RewardTokenAlreadyApproved();

    error RewardTokenNotApproved();

    error AccumulatedFeeAccountedMustBeZero();

    error MultipleProtectStrat();

    error StrategyHasLockedAssets(address strategy);

    error InvalidIndex(uint256 index);

    error InvalidLength(uint256 argLength, uint256 expectedLength);
    // TokenRegistry errors /////////////////////////////////////////////////

    /// @notice Error for a token already being registered.
    /// @param tokenAddress The address of the token.
    error TokenAlreadyRegistered(address tokenAddress);

    /// @notice Error for a token not being registered.
    /// @param tokenAddress The address of the token.
    error TokenNotRegistered(address tokenAddress);

    /// @notice Error for a token not being a reward token.
    /// @param tokenAddress The address of the token.
    error NotValidRewardToken(address tokenAddress);

    /// @notice Treasury on the TokenRegistry is already set.
    error TreasuryAlreadySet(address attacker);

    /// @notice Unregistered tokens cannot be rewards.
    /// @param tokenAddress The address of the token.
    error UnregisteredTokensCannotBeRewards(address tokenAddress);

    /// @notice Error for a the treasury to be set to the zero address on constructor.
    error InvalidTreasuryAddress();

    // Swapper errors //////////////////////////////////////////////////////

    /// @notice The amount of a reward token is not available for withdrawal.
    /// @param token The address of the reward token.
    /// @param amount The amount required.
    error NotAvailableForWithdrawal(address token, uint256 amount);

    /// @notice The treasury change request cooldown has not elapsed.
    /// @param sender The address of the sender.
    error TreasuryChangeRequestCooldownNotElapsed(address sender);

    // RewardManager errors /////////////////////////////////////////////////

    /// @notice The base reward rate must be less than 100%.
    error SwapperBaseRewardrate();

    /// @notice The maximum progression factor must be less than 100%.
    error SwapperMaxProgressionFactor();

    /// @notice The bonus reward rate for the user must be less than 100%.
    error SwapperBonusRewardrateUser();

    /// @notice The bonus reward rate for the ctToken must be less than 100%.
    error SwapperBonusRewardrateCtToken();

    /// @notice The bonus reward rate for the swap token must be less than 100%.
    error SwapperBonusRewardrateSwapToken();

    /// @notice Invalid Address
    error InvalidUserAddress();

    //Oracle plug
    /// @notice Invalid Token Registry Address
    error InvalidTokenRegistry();

    //Claim Router errors //////////////////////////////////////////////////

    error InvalidVaultRegistry();

    error BlueprintUnauthorizedAccount(address account);

    error InvalidDefaultAdminAddress();

    error NoProtectionStrategiesFound();

    error OnlyVault(address caller);

    //Protect strategy errors ///////////////////////////////////////////////

    error ProtectUnauthorizedAccount(address account);

    error ClaimRouterUnauthorizedAccount(address account);

    error InvalidClaimRouterAddress();
}
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

import {IStrategy} from "./IStrategy.sol";

// Example performanceFee: [{0000, 500, 300}, {501, 2000, 1000}, {2001, 5000, 2000}, {5001, 10000, 5000}]
// == 0-5% increase 3%, 5.01-20% increase 10%, 20.01-50% increase 20%, 50.01-100% increase 50%
struct GraduatedFee {
    uint256 lowerBound;
    uint256 upperBound;
    uint64 fee;
}

///@notice VaultFees are represented in BPS
///@dev all downstream math needs to be / 10_000 because 10_000 bps == 100%
struct VaultFees {
    uint64 depositFee;
    uint64 withdrawalFee;
    uint64 protocolFee;
    GraduatedFee[] performanceFee;
}

struct Allocation {
    uint256 index;
    uint256 amount; // Represented in BPS of the amount of ETF that should go into strategy
}

struct Strategy {
    IStrategy strategy;
    Allocation allocation;
}

struct VaultInitParams {
    address feeRecipient;
    VaultFees fees;
    uint256 depositLimit;
    address owner;
}

interface IConcreteMultiStrategyVault {
    event FeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event ToggleVaultIdle(bool pastValue, bool newValue);
    event StrategyAdded(address newStrategy);
    event StrategyRemoved(address oldStrategy);
    event DepositLimitSet(uint256 limit);
    event StrategyAllocationsChanged(Allocation[] newAllocations);
    event WithdrawalQueueUpdated(address oldQueue, address newQueue);

    function pause() external;
    function unpause() external;
    function setVaultFees(VaultFees calldata newFees_) external;
    function setFeeRecipient(address newRecipient_) external;
    function toggleVaultIdle() external;
    function addStrategy(uint256 index_, bool replace_, Strategy calldata newStrategy_) external;
    function removeStrategy(uint256 index_) external;
    function changeAllocations(Allocation[] calldata allocations_, bool redistribute_) external;
    function setDepositLimit(uint256 limit_) external;
    function pushFundsToStrategies() external;
    function pushFundsIntoSingleStrategy(uint256 index_, uint256 amount) external;
    function pushFundsIntoSingleStrategy(uint256 index_) external;
    function pullFundsFromStrategies() external;
    function pullFundsFromSingleStrategy(uint256 index_) external;
    function protectStrategy() external view returns (address);
    function getAvailableAssetsForWithdrawal() external view returns (uint256);
    function requestFunds(uint256 amount_) external;
    function setWithdrawalQueue(address withdrawalQueue_) external;
    function batchClaimWithdrawal(uint256 maxRequests) external;
}
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

struct ReturnedRewards {
    address rewardAddress;
    uint256 rewardAmount;
}

interface IStrategy is IERC4626 {
    function getAvailableAssetsForWithdrawal() external view returns (uint256);

    function isProtectStrategy() external returns (bool);

    function harvestRewards(bytes memory) external returns (ReturnedRewards[] memory);
}
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

interface IWithdrawalQueue {
    function requestWithdrawal(address recipient, uint256 amount) external;
    function prepareWithdrawal(uint256 _requestId, uint256 _avaliableAssets)
        external
        returns (address recipient, uint256 amount, uint256 avaliableAssets);

    function unfinalizedAmount() external view returns (uint256);
    function getLastFinalizedRequestId() external view returns (uint256);
    function getLastRequestId() external view returns (uint256);
    //slither-disable-next-line naming-convention
    function _finalize(uint256 _lastRequestIdToBeFinalized) external;
}
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MAX_BASIS_POINTS} from "../utils/Constants.sol";
import {VaultFees, Strategy} from "../interfaces/IConcreteMultiStrategyVault.sol";
import {IStrategy} from "../interfaces/IStrategy.sol";

library MultiStrategyVaultHelper {
    using Math for uint256;
    using SafeERC20 for IERC20;

    error InvalidVaultFees();
    error InvalidAssetAddress();
    error InvalidFeeRecipient();
    error VaultAssetMismatch();
    error ERC20ApproveFail();
    error InvalidIndex(uint256 index);
    error AllotmentTotalTooHigh();
    error MultipleProtectStrat();
    error StrategyHasLockedAssets(address strategy);

    /// @notice Initializes, validates, and approves the base asset for each strategy.
    /// @param strategies_ The array of strategies to be initialized.
    /// @param baseAsset_ The base asset (IERC20 token) for approval.
    /// @param protectStrategy_ The address of the current protect strategy, if any.
    /// @param strategies The storage array where validated strategies will be stored.
    /// @return address The updated protect strategy address.
    function initializeStrategies(
        Strategy[] memory strategies_,
        IERC20 baseAsset_,
        address protectStrategy_,
        Strategy[] storage strategies
    ) private returns (address) {
        uint256 len = strategies_.length;

        for (uint256 i = 0; i < len;) {
            IStrategy currentStrategy = strategies_[i].strategy;

            // Validate that the strategy asset matches the base asset
            if (currentStrategy.asset() != address(baseAsset_)) {
                revert VaultAssetMismatch();
            }

            // Check if the strategy is a protect strategy and ensure only one is allowed
            if (currentStrategy.isProtectStrategy()) {
                if (protectStrategy_ != address(0)) revert MultipleProtectStrat();
                protectStrategy_ = address(currentStrategy);
            }

            // Add the validated strategy to the storage array
            strategies.push(strategies_[i]);

            // Approve the base asset for the strategy
            baseAsset_.forceApprove(address(currentStrategy), type(uint256).max);

            // Use unchecked increment to avoid gas cost for overflow checks (safe since len is controlled)
            unchecked {
                i++;
            }
        }

        return protectStrategy_;
    }

    /// @notice Validates and assigns fee values from `fees_` to `fees`.
    /// @param fees_ The input VaultFees structure containing fee values to validate and assign.
    /// @param fees The storage VaultFees structure where validated fees will be stored.
    function validateAndSetFees(VaultFees memory fees_, VaultFees storage fees) private {
        // Validate basic fee values to ensure they don't exceed MAX_BASIS_POINTS
        if (
            fees_.depositFee >= MAX_BASIS_POINTS || fees_.withdrawalFee >= MAX_BASIS_POINTS
                || fees_.protocolFee >= MAX_BASIS_POINTS
        ) {
            revert InvalidVaultFees();
        }

        // Assign validated fee values
        fees.depositFee = fees_.depositFee;
        fees.withdrawalFee = fees_.withdrawalFee;
        fees.protocolFee = fees_.protocolFee;

        // Copy the performanceFee array to storage with a loop
        uint256 len = fees_.performanceFee.length;
        for (uint256 i = 0; i < len;) {
            fees.performanceFee.push(fees_.performanceFee[i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Validates and initializes essential vault parameters, including the base asset, strategies, and fee structure.
     * @dev Ensures the provided base asset address is valid, initializes strategies with allocations,
     *      adjusts decimals for the base asset, and validates and sets vault fees.
     *      Reverts if the base asset address is zero or if the fees or strategy allocations are invalid.
     * @param baseAsset_ The IERC20 token that serves as the base asset of the vault.
     * @param decimalOffset The offset to be added to the base asset's decimals to calculate vault decimals.
     * @param strategies_ The array of strategies with allocation data to be initialized for the vault.
     * @param protectStrategy_ The current protect strategy address, if any, to be used for specific operations.
     * @param strategies The storage array where validated and initialized strategies will be stored.
     * @param fees_ The memory VaultFees structure containing the initial fee values for the vault.
     * @param fees The storage VaultFees structure where validated fees will be stored and used by the vault.
     * @return protectStrategy The address of the protect strategy if set after initialization.
     * @return decimals The calculated number of decimals for the vault based on the base asset and decimal offset.
     * @custom:reverts InvalidAssetAddress if the base asset address is zero.
     * @custom:reverts AllotmentTotalTooHigh if the total strategy allocations exceed 100%.
     * @custom:reverts InvalidVaultFees if any fee value exceeds the maximum basis points allowed.
     */
    function validateVaultParameters(
        IERC20 baseAsset_,
        uint8 decimalOffset,
        Strategy[] memory strategies_,
        address protectStrategy_,
        Strategy[] storage strategies,
        VaultFees memory fees_,
        VaultFees storage fees
    ) public returns (address protectStrategy, uint8 decimals) {
        if (address(baseAsset_) == address(0)) {
            revert InvalidAssetAddress();
        }

        protectStrategy = initializeStrategies(strategies_, baseAsset_, protectStrategy_, strategies);

        decimals = IERC20Metadata(address(baseAsset_)).decimals() + decimalOffset;

        validateAndSetFees(fees_, fees);
    }

    /// @notice Calculates the tiered fee based on share value and high water mark.
    /// @param shareValue The current value of a share in assets.
    /// @param highWaterMark The high water mark for performance fee calculation.
    /// @param totalSupply The total supply of shares in the vault.
    /// @param fees The fee structure containing performance fee tiers.
    /// @return fee The calculated performance fee.
    /// @dev This function Must only be called when the share value strictly exceeds the high water mark.
    function calculateTieredFee(uint256 shareValue, uint256 highWaterMark, uint256 totalSupply, VaultFees storage fees)
        public
        view
        returns (uint256 fee)
    {
        if (shareValue <= highWaterMark) return 0;
        // Calculate the percentage difference (diff) between share value and high water mark
        uint256 diff =
            uint256(shareValue.mulDiv(MAX_BASIS_POINTS, highWaterMark, Math.Rounding.Floor)) - uint256(MAX_BASIS_POINTS);

        // Loop through performance fee tiers
        uint256 len = fees.performanceFee.length;
        if (len == 0) return 0;
        for (uint256 i = 0; i < len;) {
            if (diff < fees.performanceFee[i].upperBound && diff > fees.performanceFee[i].lowerBound) {
                fee = ((shareValue - highWaterMark) * totalSupply).mulDiv(
                    fees.performanceFee[i].fee, MAX_BASIS_POINTS * 1e18, Math.Rounding.Floor
                );
                break; // Exit loop once the correct tier is found
            }
            unchecked {
                i++;
            }
        }
    }

    /// @notice Distributes assets to each strategy based on their allocation.
    /// @param strategies The array of strategies, each with a specified allocation.
    /// @param _totalAssets The total amount of assets to be distributed.
    function distributeAssetsToStrategies(Strategy[] storage strategies, uint256 _totalAssets) public {
        uint256 len = strategies.length;

        for (uint256 i = 0; i < len;) {
            // Calculate the amount to allocate to each strategy based on its allocation percentage
            uint256 amountToDeposit =
                _totalAssets.mulDiv(strategies[i].allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Floor);

            // Deposit the allocated amount into the strategy
            strategies[i].strategy.deposit(amountToDeposit, address(this));

            unchecked {
                i++;
            }
        }
    }

    /// @notice Adds or replaces a strategy, ensuring allotment limits and setting protect strategy if needed.
    /// @param strategies The storage array of current strategies.
    /// @param newStrategy_ The new strategy to add or replace.
    /// @param replace_ Boolean indicating if the strategy should replace an existing one.
    /// @param index_ The index at which to replace the strategy if `replace_` is true.
    /// @param protectStrategy The current protect strategy address, which may be updated.
    /// @param asset The asset of the vault for approving the strategy.
    /// @return protectStrategy The address of the new protect strategy.
    /// @return newStrategyIfc The interface of the new strategy.
    /// @return stratToBeReplacedIfc The interface of the strategy to be replaced. (could be empty if not replacing)
    function addOrReplaceStrategy(
        Strategy[] storage strategies,
        Strategy memory newStrategy_,
        bool replace_,
        uint256 index_,
        address protectStrategy_,
        IERC20 asset
    ) public returns (address protectStrategy, IStrategy newStrategyIfc, IStrategy stratToBeReplacedIfc) {
        // Calculate total allotments of current strategies
        protectStrategy = protectStrategy_;
        uint256 allotmentTotals = 0;
        uint256 len = strategies.length;
        for (uint256 i = 0; i < len;) {
            allotmentTotals += strategies[i].allocation.amount;
            unchecked {
                i++;
            }
        }

        // Adding or replacing strategy based on `replace_` flag
        if (replace_) {
            if (index_ >= len) revert InvalidIndex(index_);

            // Ensure replacing doesn't exceed total allotment limit
            if (
                allotmentTotals - strategies[index_].allocation.amount + newStrategy_.allocation.amount
                    > MAX_BASIS_POINTS
            ) {
                revert AllotmentTotalTooHigh();
            }

            // Replace the strategy at `index_`
            stratToBeReplacedIfc = strategies[index_].strategy;
            protectStrategy_ = removeStrategy(stratToBeReplacedIfc, protectStrategy_, asset);

            strategies[index_] = newStrategy_;
        } else {
            // Ensure adding new strategy doesn't exceed total allotment limit
            if (allotmentTotals + newStrategy_.allocation.amount > MAX_BASIS_POINTS) {
                revert AllotmentTotalTooHigh();
            }

            // Add the new strategy to the array
            strategies.push(newStrategy_);
        }

        // Handle protect strategy assignment if applicable
        if (newStrategy_.strategy.isProtectStrategy()) {
            if (protectStrategy_ != address(0)) revert MultipleProtectStrat();
            protectStrategy = address(newStrategy_.strategy);
        }

        // Approve the asset for the new strategy
        asset.forceApprove(address(newStrategy_.strategy), type(uint256).max);

        // Return the address of the new strategy
        newStrategyIfc = newStrategy_.strategy;
    }

    /// @notice Removes a strategy, redeeming assets if necessary, and resets protect strategy if applicable.
    /// @param stratToBeRemoved_ The strategy to be removed.
    /// @param protectStrategy_ The current protect strategy address, which may be updated.
    /// @param asset The asset of the vault for resetting the allowance to the strategy.
    /// @return protectStrategy The address of the removed strategy.
    function removeStrategy(IStrategy stratToBeRemoved_, address protectStrategy_, IERC20 asset)
        public
        returns (address protectStrategy)
    {
        protectStrategy = protectStrategy_;
        // Check if the strategy has any locked assets that cannot be withdrawn
        if (stratToBeRemoved_.getAvailableAssetsForWithdrawal() != stratToBeRemoved_.totalAssets()) {
            revert StrategyHasLockedAssets(address(stratToBeRemoved_));
        }

        // Redeem all assets from the strategy if it has any assets
        if (stratToBeRemoved_.totalAssets() > 0) {
            stratToBeRemoved_.redeem(stratToBeRemoved_.balanceOf(address(this)), address(this), address(this));
        }

        // Reset protect strategy if the strategy being removed is the protect strategy
        if (protectStrategy_ == address(stratToBeRemoved_)) {
            protectStrategy = address(0);
        } else {
            protectStrategy = protectStrategy_;
        }

        // Reset allowance to zero for the strategy being removed
        asset.forceApprove(address(stratToBeRemoved_), 0);
    }

    function withdrawAssets(
        address asset, // The main asset token
        uint256 amount, // The requested withdrawal amount
        address protectStrategy, // The address of the strategy to skip
        Strategy[] storage strategies // Array of strategy structs
    ) public returns (uint256) {
        uint256 availableAssets = IERC20(asset).balanceOf(address(this));
        uint256 accumulated = availableAssets;

        // If available assets in main balance are insufficient, try strategies
        if (availableAssets < amount) {
            uint256 len = strategies.length;

            for (uint256 i = 0; i < len; i++) {
                IStrategy currentStrategy = strategies[i].strategy;

                // Skip the protect strategy
                if (address(currentStrategy) == protectStrategy) {
                    continue;
                }

                uint256 pending = amount - accumulated;

                // Check available assets in the strategy
                uint256 availableInStrategy = currentStrategy.getAvailableAssetsForWithdrawal();

                // Skip if the strategy has no assets available for withdrawal
                if (availableInStrategy == 0) {
                    continue;
                }

                // Determine the amount to withdraw from this strategy
                uint256 toWithdraw = availableInStrategy < pending ? availableInStrategy : pending;

                // Update the accumulated amount
                accumulated += toWithdraw;

                // Withdraw from the strategy
                currentStrategy.withdraw(toWithdraw, address(this), address(this));

                // Break if the accumulated amount satisfies the requested amount
                if (accumulated >= amount) {
                    break;
                }
            }
        }

        return accumulated;
    }
}
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;


uint256 constant MAX_BASIS_POINTS = 10_000; // Maximum basis points value
//SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.24;

import {
    ERC4626Upgradeable,
    IERC20,
    IERC20Metadata
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {
    VaultFees, Strategy, IConcreteMultiStrategyVault, Allocation
} from "../interfaces/IConcreteMultiStrategyVault.sol";
import {Errors} from "../interfaces/Errors.sol";
import {IStrategy, ReturnedRewards} from "../interfaces/IStrategy.sol";
import {IWithdrawalQueue} from "../interfaces/IWithdrawalQueue.sol";
import {MultiStrategyVaultHelper} from "../libraries/MultiStrategyVaultHelper.sol";
import {MAX_BASIS_POINTS} from "../utils/Constants.sol";
/**
 * @title ConcreteMultiStrategyVault
 * @author Concrete
 * @notice An ERC4626 compliant vault that manages multiple yield generating strategies
 * @dev This vault:
 *      - Implements ERC4626 standard for tokenized vaults
 *      - Manages multiple yield strategies simultaneously
 *      - Handles fee collection and distribution
 *      - Supports emergency pausing
 *      - Provides withdrawal queueing mechanism
 */

contract ConcreteMultiStrategyVault is
    ERC4626Upgradeable,
    Errors,
    ReentrancyGuard,
    PausableUpgradeable,
    OwnableUpgradeable,
    IConcreteMultiStrategyVault
{
    using SafeERC20 for IERC20;
    using Math for uint256;

    uint32 private constant DUST = 1e8;
    uint256 private constant PRECISION = 1e36;
    uint256 public firstDeposit = 0;
    /// @dev Public variable storing the address of the protectStrategy contract.
    address public protectStrategy;
    /// @dev Represents the number of seconds in a year, accounting for leap years.
    uint256 private constant SECONDS_PER_YEAR = 365.25 days;
    /// @dev Internal variable to store the number of decimals the vault's shares will have.
    uint8 private _decimals;
    /// @notice The offset applied to decimals to prevent inflation attacks.
    /// @dev Public constant representing the offset applied to the vault's share decimals.
    uint8 public constant decimalOffset = 9;
    /// @notice The highest value of share price recorded, used for performance fee calculation.
    /// @dev Public variable to store the high water mark for performance fee calculation.
    uint256 public highWaterMark;
    /// @notice The maximum amount of assets that can be deposited into the vault.
    /// @dev Public variable to store the deposit limit of the vault.
    uint256 public depositLimit;
    /// @notice The timestamp at which the fees were last updated.
    /// @dev Public variable to store the last update time of the fees.
    uint256 public feesUpdatedAt;
    /// @notice The recipient address for any fees collected by the vault.
    /// @dev Public variable to store the address of the fee recipient.
    address public feeRecipient;
    /// @notice Indicates if the vault is in idle mode, where deposits are not passed to strategies.
    /// @dev Public boolean indicating if the vault is idle.
    bool public vaultIdle;

    /// @notice The array of strategies that the vault can interact with.
    /// @dev Public array storing the strategies associated with the vault.
    Strategy[] internal strategies;
    /// @notice The fee structure of the vault.
    /// @dev Public variable storing the fees associated with the vault.
    VaultFees private fees;

    IWithdrawalQueue public withdrawalQueue;

    //Rewards Management
    // Array to store reward addresses
    address[] private rewardAddresses;

    // Mapping to get the index of each reward address
    mapping(address => uint256) public rewardIndex;

    // Mapping to store the reward index for each user and reward address
    mapping(address => mapping(address => uint256)) public userRewardIndex;

    // Mapping to store the total rewards claimed by user for each reward address
    mapping(address => mapping(address => uint256)) public totalRewardsClaimed;

    event Initialized(address indexed vaultName, address indexed underlyingAsset);

    event RequestedFunds(address indexed protectStrategy, uint256 amount);

    event RewardsHarvested();
    /// @notice Modifier to restrict access to only the designated protection strategy account.
    /// @dev Reverts the transaction if the sender is not the protection strategy account.

    modifier onlyProtect() {
        if (protectStrategy != _msgSender()) {
            revert ProtectUnauthorizedAccount(_msgSender());
        }
        _;
    }

    ///@notice Modifier that allows protocol to take fees
    modifier takeFees() {
        uint256 totalFee = accruedProtocolFee() + accruedPerformanceFee();
        uint256 shareValue = convertToAssets(1e18);
        uint256 _totalAssets = totalAssets();

        if (shareValue > highWaterMark) highWaterMark = shareValue;

        if (totalFee > 0 && _totalAssets > 0) {
            uint256 supply = totalSupply();
            uint256 feeInShare =
                supply == 0 ? totalFee : totalFee.mulDiv(supply, _totalAssets - totalFee, Math.Rounding.Floor);
            _mint(feeRecipient, feeInShare);
        }
        feesUpdatedAt = block.timestamp;
        _;
    }

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the vault with its core parameters
     * @dev Sets up the vault's initial state including strategies, fees, and limits
     * @param baseAsset_ The underlying asset token address
     * @param shareName_ The name for the vault's share token
     * @param shareSymbol_ The symbol for the vault's share token
     * @param strategies_ Array of initial strategies
     * @param feeRecipient_ Address to receive collected fees
     * @param fees_ Initial fee structure
     * @param depositLimit_ Maximum deposit amount allowed
     * @param owner_ Address of the vault owner
     */
    // slither didn't detect the nonReentrant modifier
    // slither-disable-next-line reentrancy-no-eth,reentrancy-benign,calls-loop,costly-loop
    function initialize(
        IERC20 baseAsset_,
        string memory shareName_,
        string memory shareSymbol_,
        Strategy[] memory strategies_,
        address feeRecipient_,
        VaultFees memory fees_,
        uint256 depositLimit_,
        address owner_
    ) external initializer nonReentrant {
        __Pausable_init();
        __ERC4626_init(baseAsset_);
        __ERC20_init(shareName_, shareSymbol_);
        __Ownable_init(owner_);

        if (address(baseAsset_) == address(0)) revert InvalidAssetAddress();

        (protectStrategy, _decimals) = MultiStrategyVaultHelper.validateVaultParameters(
            baseAsset_, decimalOffset, strategies_, protectStrategy, strategies, fees_, fees
        );
        if (feeRecipient_ == address(0)) {
            revert InvalidFeeRecipient();
        }
        feeRecipient = feeRecipient_;

        highWaterMark = 1e9; // Set the initial high water mark for performance fee calculation.
        depositLimit = depositLimit_;

        // By default, the vault is not idle. It can be set to idle mode using toggleVaultIdle(true).
        vaultIdle = false;

        emit Initialized(address(this), address(baseAsset_));
    }

    /**
     * @notice Returns the decimals of the vault's shares.
     * @dev Overrides the decimals function in inherited contracts to return the custom vault decimals.
     * @return The decimals of the vault's shares.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Pauses all deposit and withdrawal functions.
     * @dev Can only be called by the owner. Emits a `Paused` event.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the vault, allowing deposit and withdrawal functions.
     * @dev Can only be called by the owner. Emits an `Unpaused` event.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    // ========== PUBLIC ENTRY DEPOSIT/WITHDRAW =============
    /**
     * @notice Allows a user to deposit assets into the vault in exchange for shares.
     * @dev This function is a wrapper that calls the main deposit function with the sender's address as the receiver.
     * @param assets_ The amount of assets to deposit.
     * @return The number of shares minted for the deposited assets.
     */
    function deposit(uint256 assets_) external returns (uint256) {
        return deposit(assets_, msg.sender);
    }

    /**
     * @notice Deposits assets into the vault on behalf of a receiver, in exchange for shares.
     * @dev Calculates the deposit fee, mints shares to the fee recipient and the receiver, then transfers the assets from the sender.
     *      If the vault is not idle, it also allocates the assets into the strategies according to their allocation.
     * @param assets_ The amount of assets to deposit.
     * @param receiver_ The address for which the shares will be minted.
     * @return shares The number of shares minted for the deposited assets.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function deposit(uint256 assets_, address receiver_)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        _validateAndUpdateDepositTimestamps(receiver_);

        if (assets_ > maxDeposit(receiver_) || assets_ > depositLimit) revert MaxError();

        // Calculate the fee in shares
        uint256 feeShares = _convertToShares(
            assets_.mulDiv(uint256(fees.depositFee), MAX_BASIS_POINTS, Math.Rounding.Floor), Math.Rounding.Floor
        );

        // Calculate the net shares to mint for the deposited assets
        shares = _convertToShares(assets_, Math.Rounding.Floor) - feeShares;
        if (shares <= DUST) revert ZeroAmount();

        // Mint shares to fee recipient and receiver
        if (feeShares > 0) _mint(feeRecipient, feeShares);
        _mint(receiver_, shares);

        // Transfer the assets from the sender to the vault
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets_);

        // If the vault is not idle, allocate the assets into strategies
        if (!vaultIdle) {
            uint256 len = strategies.length;
            for (uint256 i; i < len;) {
                //We control both the length of the array and the external call
                //slither-disable-next-line unused-return,calls-loop
                strategies[i].strategy.deposit(
                    assets_.mulDiv(strategies[i].allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Floor),
                    address(this)
                );
                unchecked {
                    i++;
                }
            }
        }
        emit Deposit(msg.sender, receiver_, assets_, shares);
    }

    /**
     * @notice Allows a user to mint shares in exchange for assets.
     * @dev This function is a wrapper that calls the main mint function with the sender's address as the receiver.
     * @param shares_ The number of shares to mint.
     * @return The amount of assets deposited in exchange for the minted shares.
     */
    function mint(uint256 shares_) external returns (uint256) {
        return mint(shares_, msg.sender);
    }

    /**
     * @notice Mints shares on behalf of a receiver, in exchange for assets.
     * @dev Calculates the deposit fee in shares, mints shares to the fee recipient and the receiver, then transfers the assets from the sender.
     *      If the vault is not idle, it also allocates the assets into the strategies according to their allocation.
     * @param shares_ The number of shares to mint.
     * @param receiver_ The address for which the shares will be minted.
     * @return assets The amount of assets deposited in exchange for the minted shares.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function mint(uint256 shares_, address receiver_)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        _validateAndUpdateDepositTimestamps(receiver_);

        if (shares_ == 0) revert ZeroAmount();

        // Calculate the deposit fee in shares
        uint256 depositFee = uint256(fees.depositFee);
        uint256 feeShares =
            shares_.mulDiv(MAX_BASIS_POINTS, MAX_BASIS_POINTS - depositFee, Math.Rounding.Floor) - shares_;

        // Calculate the total assets required for the minted shares, including fees
        assets = _convertToAssets(shares_ + feeShares, Math.Rounding.Ceil);

        if (assets > maxMint(receiver_)) revert MaxError();

        // Mint shares to fee recipient and receiver
        if (feeShares > 0) _mint(feeRecipient, feeShares);
        _mint(receiver_, shares_);

        // Transfer the assets from the sender to the vault
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);

        // If the vault is not idle, allocate the assets into strategies
        if (!vaultIdle) {
            uint256 len = strategies.length;
            for (uint256 i; i < len;) {
                //We control both the length of the array and the external call
                // slither-disable-next-line unused-return,calls-loop
                strategies[i].strategy.deposit(
                    assets.mulDiv(strategies[i].allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Ceil), address(this)
                );
                unchecked {
                    i++;
                }
            }
        }
    }

    /**
     * @notice Redeems shares for the caller and sends the assets to the caller.
     * @dev This is a convenience function that calls the main redeem function with the caller as both receiver and owner.
     * @param shares_ The number of shares to redeem.
     * @return assets The amount of assets returned in exchange for the redeemed shares.
     */
    function redeem(uint256 shares_) external returns (uint256) {
        return redeem(shares_, msg.sender, msg.sender);
    }

    /**
     * @notice Redeems shares on behalf of an owner and sends the assets to a receiver.
     * @dev Redeems the specified amount of shares from the owner's balance, deducts the withdrawal fee in shares, burns the shares, and sends the assets to the receiver.
     *      If the caller is not the owner, it requires approval.
     * @param shares_ The number of shares to redeem.
     * @param receiver_ The address to receive the assets.
     * @param owner_ The owner of the shares being redeemed.
     * @return assets The amount of assets returned in exchange for the redeemed shares.
     */
    function redeem(uint256 shares_, address receiver_, address owner_)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        if (receiver_ == address(0)) revert InvalidRecipient();
        if (shares_ == 0) revert ZeroAmount();
        if (shares_ > maxRedeem(owner_)) revert MaxError();

        uint256 feeShares = shares_.mulDiv(uint256(fees.withdrawalFee), MAX_BASIS_POINTS, Math.Rounding.Ceil);

        assets = _convertToAssets(shares_ - feeShares, Math.Rounding.Floor);

        _withdraw(assets, receiver_, owner_, shares_, feeShares);
    }

    /**
     * @notice Withdraws a specified amount of assets for the caller.
     * @dev This is a convenience function that calls the main withdraw function with the caller as both receiver and owner.
     * @param assets_ The amount of assets to withdraw.
     * @return shares The number of shares burned in exchange for the withdrawn assets.
     */
    function withdraw(uint256 assets_) external returns (uint256) {
        return withdraw(assets_, msg.sender, msg.sender);
    }

    /**
     * @notice Withdraws a specified amount of assets on behalf of an owner and sends them to a receiver.
     * @dev Calculates the number of shares equivalent to the assets requested, deducts the withdrawal fee in shares, burns the shares, and sends the assets to the receiver.
     *      If the caller is not the owner, it requires approval.
     * @param assets_ The amount of assets to withdraw.
     * @param receiver_ The address to receive the withdrawn assets.
     * @param owner_ The owner of the shares equivalent to the assets being withdrawn.
     * @return shares The number of shares burned in exchange for the withdrawn assets.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function withdraw(uint256 assets_, address receiver_, address owner_)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        if (receiver_ == address(0)) revert InvalidRecipient();
        if (assets_ > maxWithdraw(owner_)) revert MaxError();
        shares = _convertToShares(assets_, Math.Rounding.Ceil);
        if (shares <= DUST) revert ZeroAmount();

        // If msg.sender is the withdrawal queue, go straght to the actual withdrawal
        uint256 withdrawalFee = uint256(fees.withdrawalFee);
        uint256 feeShares = msg.sender != feeRecipient
            ? shares.mulDiv(MAX_BASIS_POINTS, MAX_BASIS_POINTS - withdrawalFee, Math.Rounding.Floor) - shares
            : 0;
        shares += feeShares;

        _withdraw(assets_, receiver_, owner_, shares, feeShares);
    }

    /**
     * @notice Consumes allowance, burn shares, mint fees and transfer assets to receiver
     * @dev internal function for redeem and withdraw
     * @param assets_ The amount of assets to withdraw.
     * @param receiver_ The address to receive the withdrawn assets.
     * @param owner_ The owner of the shares equivalent to the assets being withdrawn.
     * @param shares The address to receive the withdrawn assets.
     * @param feeShares The owner of the shares equivalent to the assets being withdrawn.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function _withdraw(uint256 assets_, address receiver_, address owner_, uint256 shares, uint256 feeShares) private {
        if (msg.sender != owner_) {
            _approve(owner_, msg.sender, allowance(owner_, msg.sender) - shares);
        }
        _burn(owner_, shares);
        if (feeShares > 0) _mint(feeRecipient, feeShares);
        uint256 availableAssetsForWithdrawal = getAvailableAssetsForWithdrawal();
        if (availableAssetsForWithdrawal >= assets_) {
            _withdrawStrategyFunds(assets_, receiver_);
        } else {
            if (address(withdrawalQueue) == address(0)) {
                revert InsufficientVaultFunds(address(this), assets_, availableAssetsForWithdrawal);
            }
            withdrawalQueue.requestWithdrawal(receiver_, assets_);
        }
        emit Withdraw(msg.sender, receiver_, owner_, assets_, shares);
    }

    /**
     * @dev Internal function to withdraw funds from strategies to fulfill withdrawal requests.
     * @param amount_ The amount of assets to withdraw.
     * @param receiver_ The address to receive the withdrawn assets.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function _withdrawStrategyFunds(uint256 amount_, address receiver_) private {
        IERC20 asset_ = IERC20(asset());
        //Not in a loop
        //slither-disable-next-line calls-loop
        uint256 float = asset_.balanceOf(address(this));

        if (amount_ <= float) {
            asset_.safeTransfer(receiver_, amount_);
        } else {
            uint256 diff = amount_ - float;
            uint256 totalWithdrawn = 0;
            uint256 len = strategies.length;
            for (uint256 i; i < len;) {
                Strategy memory strategy = strategies[i];
                //We control both the length of the array and the external call
                //slither-disable-next-line calls-loop
                uint256 withdrawable = strategy.strategy.previewRedeem(strategy.strategy.balanceOf(address(this)));
                if (diff.mulDiv(strategy.allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Ceil) > withdrawable) {
                    revert InsufficientFunds(strategy.strategy, diff * strategy.allocation.amount, withdrawable);
                }
                uint256 amountToWithdraw =
                    amount_.mulDiv(strategy.allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Ceil);
                //We control both the length of the array and the external call
                //slither-disable-next-line unused-return,calls-loop
                strategy.strategy.withdraw(amountToWithdraw, receiver_, address(this));
                totalWithdrawn += amountToWithdraw;
                unchecked {
                    i++;
                }
            }
            if (totalWithdrawn < amount_ && amount_ - totalWithdrawn <= float) {
                asset_.safeTransfer(receiver_, amount_ - totalWithdrawn);
            }
        }
    }

    /**
     * @notice Prepares and executes the withdrawal process for a specific withdrawal request.
     * @dev Calls the prepareWithdrawal function to obtain withdrawal details such as recipient address, withdrawal amount, and updated available assets.
     * @dev Compares the original available assets with the updated available assets to determine if funds need to be withdrawn from the strategy.
     * @dev If the available assets have changed, calls the _withdrawStrategyFunds function to withdraw funds from the strategy and transfer them to the recipient.
     * @param _requestId The identifier of the withdrawal request.
     * @param avaliableAssets The amount of available assets for withdrawal.
     * @return The new available assets after processing the withdrawal.
     */
    //we control the external call
    //slither-disable-next-line calls-loop,naming-convention
    function claimWithdrawal(uint256 _requestId, uint256 avaliableAssets) private returns (uint256) {
        (address recipient, uint256 amount, uint256 newAvaliableAssets) =
            withdrawalQueue.prepareWithdrawal(_requestId, avaliableAssets);

        if (avaliableAssets != newAvaliableAssets) {
            _withdrawStrategyFunds(amount, recipient);
        }
        return newAvaliableAssets;
    }

    function getRewardTokens() public view returns (address[] memory) {
        return rewardAddresses;
    }

    function getAvailableAssetsForWithdrawal() public view returns (uint256 totalAvailable) {
        totalAvailable = IERC20(asset()).balanceOf(address(this));
        uint256 len = strategies.length;
        for (uint256 i; i < len;) {
            Strategy memory strategy = strategies[i];
            //We control both the length of the array and the external call
            //slither-disable-next-line calls-loop
            totalAvailable += strategy.strategy.getAvailableAssetsForWithdrawal();
            unchecked {
                i++;
            }
        }
        return totalAvailable;
    }

    /**
     * @notice Updates the user rewards to the current reward index.
     * @dev Calculates the rewards to be transferred to the user based on the difference between the current and previous reward indexes.
     * @param userAddress The address of the user to update rewards for.
     */
    //slither-disable-next-line unused-return,calls-loop,reentrancy-no-eth
    function getUserRewards(address userAddress) external view returns (ReturnedRewards[] memory) {
        uint256 userBalance = balanceOf(userAddress);
        uint256 len = rewardAddresses.length;
        ReturnedRewards[] memory returnedRewards = new ReturnedRewards[](len);
        for (uint256 i; i < len;) {
            uint256 tokenRewardIndex = rewardIndex[rewardAddresses[i]];
            uint256 calculatedRewards = (tokenRewardIndex - userRewardIndex[userAddress][rewardAddresses[i]]).mulDiv(
                userBalance, PRECISION, Math.Rounding.Floor
            );
            returnedRewards[i] = ReturnedRewards(rewardAddresses[i], calculatedRewards);
            unchecked {
                i++;
            }
        }
        return returnedRewards;
    }

    // function to return all the rewards claimed by a user for all the reward tokens in the vault
    function getTotalRewardsClaimed(address userAddress) external view returns (ReturnedRewards[] memory) {
        uint256 len = rewardAddresses.length;
        ReturnedRewards[] memory claimedRewards = new ReturnedRewards[](len);
        for (uint256 i; i < len;) {
            claimedRewards[i] =
                ReturnedRewards(rewardAddresses[i], totalRewardsClaimed[userAddress][rewardAddresses[i]]);
            unchecked {
                i++;
            }
        }
        return claimedRewards;
    }
    // ================= ACCOUNTING =====================
    /**
     * @notice Calculates the total assets under management in the vault, including those allocated to strategies.
     * @dev Sums the balance of the vault's asset held directly and the assets managed by each strategy.
     * @return total The total assets under management in the vault.
     */

    function totalAssets() public view override returns (uint256 total) {
        total = IERC20(asset()).balanceOf(address(this));
        for (uint256 i; i < strategies.length;) {
            //We control both the length of the array and the external call
            //slither-disable-next-line calls-loop
            total += strategies[i].strategy.convertToAssets(strategies[i].strategy.balanceOf(address(this)));
            unchecked {
                i++;
            }
        }
        uint256 unfinalized = 0;
        if (address(withdrawalQueue) != address(0)) {
            unfinalized = withdrawalQueue.unfinalizedAmount();
        }

        //not a timestamp
        //slither-disable-next-line timestamp
        if (total < unfinalized) revert InvalidSubstraction();
        total -= unfinalized;
    }

    /**
     * @notice Provides a preview of the number of shares that would be minted for a given deposit amount, after fees.
     * @dev Calculates the deposit fee and subtracts it from the deposit amount to determine the net amount for share conversion.
     * @param assets_ The amount of assets to be deposited.
     * @return The number of shares that would be minted for the given deposit amount.
     */
    function previewDeposit(uint256 assets_) public view override returns (uint256) {
        uint256 netAssets = assets_
            - (
                msg.sender != feeRecipient
                    ? assets_.mulDiv(uint256(fees.depositFee), MAX_BASIS_POINTS, Math.Rounding.Floor)
                    : 0
            );
        return _convertToShares(netAssets, Math.Rounding.Floor);
    }

    /**
     * @notice Provides a preview of the amount of assets required to mint a specific number of shares, after accounting for deposit fees.
     * @dev Adds the deposit fee to the share amount to determine the gross amount for asset conversion.
     * @param shares_ The number of shares to be minted.
     * @return The amount of assets required to mint the specified number of shares.
     */
    function previewMint(uint256 shares_) public view override returns (uint256) {
        uint256 grossShares = shares_.mulDiv(MAX_BASIS_POINTS, MAX_BASIS_POINTS - fees.depositFee, Math.Rounding.Floor);
        return _convertToAssets(grossShares, Math.Rounding.Floor);
    }

    /**
     * @notice Provides a preview of the number of shares that would be burned for a given withdrawal amount, after fees.
     * @dev Calculates the withdrawal fee and adds it to the share amount to determine the gross shares for asset conversion.
     * @param assets_ The amount of assets to be withdrawn.
     * @return shares The number of shares that would be burned for the given withdrawal amount.
     */
    function previewWithdraw(uint256 assets_) public view override returns (uint256 shares) {
        shares = _convertToShares(assets_, Math.Rounding.Ceil);
        shares = msg.sender != feeRecipient
            ? shares.mulDiv(MAX_BASIS_POINTS, MAX_BASIS_POINTS - fees.withdrawalFee, Math.Rounding.Floor)
            : shares;
    }

    /**
     * @notice Provides a preview of the amount of assets that would be redeemed for a specific number of shares, after withdrawal fees.
     * @dev Subtracts the withdrawal fee from the share amount to determine the net shares for asset conversion.
     * @param shares_ The number of shares to be redeemed.
     * @return The amount of assets that would be redeemed for the specified number of shares.
     */
    function previewRedeem(uint256 shares_) public view override returns (uint256) {
        uint256 netShares = shares_
            - (
                msg.sender != feeRecipient
                    ? shares_.mulDiv(uint256(fees.withdrawalFee), MAX_BASIS_POINTS, Math.Rounding.Floor)
                    : 0
            );
        return _convertToAssets(netShares, Math.Rounding.Floor);
    }

    /**
     * @notice Calculates the maximum amount of assets that can be minted, considering the deposit limit and current total assets.
     * @dev Returns zero if the vault is paused or if the total assets are equal to or exceed the deposit limit.
     * @return The maximum amount of assets that can be minted.
     */
    //We're not using the timestamp for comparisions
    //slither-disable-next-line timestamp
    function maxMint(address) public view override returns (uint256) {
        return (paused() || totalAssets() >= depositLimit) ? 0 : depositLimit - totalAssets();
    }

    /**
     * @notice Converts an amount of assets to the equivalent amount of shares, considering the current share price and applying the specified rounding.
     * @dev Utilizes the total supply and total assets to calculate the share price for conversion.
     * @param assets The amount of assets to convert to shares.
     * @param rounding The rounding direction to use for the conversion.
     * @return shares The equivalent amount of shares for the given assets.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view override returns (uint256 shares) {
        shares = assets.mulDiv(totalSupply() + 10 ** decimalOffset, totalAssets() + 1, rounding);
    }

    /**
     * @notice Converts an amount of shares to the equivalent amount of assets, considering the current share price and applying the specified rounding.
     * @dev Utilizes the total assets and total supply to calculate the asset price for conversion.
     * @param shares The amount of shares to convert to assets.
     * @param rounding The rounding direction to use for the conversion.
     * @return The equivalent amount of assets for the given shares.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** decimalOffset, rounding);
    }

    // ============ FEE ACCOUNTING =====================
    /**
     * @notice Calculates the accrued protocol fee based on the current protocol fee rate and time elapsed.
     * @dev The protocol fee is calculated as a percentage of the total assets, prorated over time since the last fee update.
     * @return The accrued protocol fee in asset units.
     */
    function accruedProtocolFee() public view returns (uint256) {
        // Only calculate if a protocol fee is set
        if (fees.protocolFee > 0) {
            // Calculate the fee based on time elapsed and total assets, using floor rounding for precision
            return uint256(fees.protocolFee).mulDiv(
                totalAssets() * (block.timestamp - feesUpdatedAt), SECONDS_PER_YEAR, Math.Rounding.Floor
            ) / 10000; // Normalize the fee percentage
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculates the accrued performance fee based on the vault's performance relative to the high water mark.
     * @dev The performance fee is calculated as a percentage of the profit (asset value increase) since the last high water mark update.
     * @return fee The accrued performance fee in asset units.
     */
    // We're not using the timestamp for comparisions
    // slither-disable-next-line timestamp
    function accruedPerformanceFee() public view returns (uint256 fee) {
        // Calculate the share value in assets
        uint256 shareValue = convertToAssets(1e18);
        // Only calculate if a performance fee is set and the share value exceeds the high water mark
        if (fees.performanceFee.length > 0 && shareValue > highWaterMark) {
            fee = MultiStrategyVaultHelper.calculateTieredFee(shareValue, highWaterMark, totalSupply(), fees);
        }
    }

    /**
     * @notice Retrieves the current fee structure of the vault.
     * @dev Returns the vault's fees including deposit, withdrawal, protocol, and performance fees.
     * @return A `VaultFees` struct containing the current fee rates.
     */
    function getVaultFees() public view returns (VaultFees memory) {
        return fees;
    }

    // ============== FEE LOGIC ===================

    /**
     * @notice Placeholder function for taking portfolio and protocol fees.
     * @dev This function is intended to be overridden with actual fee-taking logic.
     */
    function takePortfolioAndProtocolFees() external nonReentrant takeFees {
        // Intentionally left blank for override
    }

    /**
     * @notice Updates the vault's fee structure.
     * @dev Can only be called by the vault owner. Emits an event upon successful update.
     * @param newFees_ The new fee structure to apply to the vault.
     */
    function setVaultFees(VaultFees calldata newFees_) external takeFees onlyOwner {
        fees = newFees_; // Update the fee structure
        feesUpdatedAt = block.timestamp; // Record the time of the fee update
    }

    /**
     * @notice Sets a new fee recipient address for the vault.
     * @dev Can only be called by the vault owner. Reverts if the new recipient address is the zero address.
     * @param newRecipient_ The address of the new fee recipient.
     */
    function setFeeRecipient(address newRecipient_) external onlyOwner {
        // Validate the new recipient address
        if (newRecipient_ == address(0)) revert InvalidFeeRecipient();

        // Emit an event for the fee recipient update
        emit FeeRecipientUpdated(feeRecipient, newRecipient_);

        feeRecipient = newRecipient_; // Update the fee recipient
    }

    /**
     * @notice Sets a new fee recipient address for the vault.
     * @dev Can only be called by the vault owner. Reverts if the new recipient address is the zero address.
     * @param withdrawalQueue_ The address of the new withdrawlQueue.
     */
    function setWithdrawalQueue(address withdrawalQueue_) external onlyOwner {
        // Validate the new recipient address
        if (withdrawalQueue_ == address(0)) revert InvalidWithdrawlQueue();
        if (address(withdrawalQueue) != address(0)) {
            if (withdrawalQueue.unfinalizedAmount() != 0) revert UnfinalizedWithdrawl(address(withdrawalQueue));
        }
        // Emit an event for the fee recipient update
        emit WithdrawalQueueUpdated(address(withdrawalQueue), withdrawalQueue_);

        withdrawalQueue = IWithdrawalQueue(withdrawalQueue_); // Update the fee recipient
    }
    // ============= STRATEGIES ===================
    /**
     * @notice Retrieves the current strategies employed by the vault.
     * @dev Returns an array of `Strategy` structs representing each strategy.
     * @return An array of `Strategy` structs.
     */

    function getStrategies() external view returns (Strategy[] memory) {
        return strategies;
    }

    /**
     * @notice Toggles the vault's idle state.
     * @dev Can only be called by the vault owner. Emits a `ToggleVaultIdle` event with the previous and new state.
     */
    function toggleVaultIdle() external onlyOwner {
        emit ToggleVaultIdle(vaultIdle, !vaultIdle);
        vaultIdle = !vaultIdle;
    }

    /**
     * @notice Adds a new strategy or replaces an existing one.
     * @dev Can only be called by the vault owner. Validates the total allocation does not exceed 100%.
     *      Emits a `StrategyAdded` or/and `StrategyRemoved` event.
     * @param index_ The index at which to add or replace the strategy. If replacing, this is the index of the existing strategy.
     * @param replace_ A boolean indicating whether to replace an existing strategy.
     * @param newStrategy_ The new strategy to add or replace the existing one with.
     */
    // slither didn't detect the nonReentrant modifier
    // slither-disable-next-line reentrancy-no-eth
    function addStrategy(uint256 index_, bool replace_, Strategy calldata newStrategy_)
        external
        nonReentrant
        onlyOwner
        takeFees
    {
        IStrategy newStrategy;
        IStrategy removedStrategy;
        (protectStrategy, newStrategy, removedStrategy) = MultiStrategyVaultHelper.addOrReplaceStrategy(
            strategies, newStrategy_, replace_, index_, protectStrategy, IERC20(asset())
        );
        if (address(removedStrategy) != address(0)) emit StrategyRemoved(address(removedStrategy));
        emit StrategyAdded(address(newStrategy));
    }

    /**
     * @notice Adds a new strategy or replaces an existing one.
     * @dev Can only be called by the vault owner. Validates that the index to be removed exists.
     *      Emits a `StrategyRemoved` event.
     * @param index_ The index of the strategy to be removed.
     */
    // slither didn't detect the nonReentrant modifier
    // slither-disable-next-line reentrancy-no-eth
    function removeStrategy(uint256 index_) external nonReentrant onlyOwner takeFees {
        uint256 len = strategies.length;
        if (index_ >= len) revert InvalidIndex(index_);

        IStrategy stratToBeRemoved = strategies[index_].strategy;
        protectStrategy = MultiStrategyVaultHelper.removeStrategy(stratToBeRemoved, protectStrategy, IERC20(asset()));
        emit StrategyRemoved(address(stratToBeRemoved));

        strategies[index_] = strategies[len - 1];
        strategies.pop();
    }

    /**
     * @notice ERC20 _update function override.
     */
    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0)) updateUserRewardsToCurrent(from);
        if (to != address(0)) updateUserRewardsToCurrent(to);
        super._update(from, to, value);
    }

    /**
     * @notice Changes strategies allocations.
     * @dev Can only be called by the vault owner. Validates the total allocation does not exceed 100% and the length corresponds with the strategies array.
     *      Emits a `StrategyAllocationsChanged`
     * @param allocations_ The array with the new allocations.
     * @param redistribute A boolean indicating whether to redistributes allocations.
     */
    function changeAllocations(Allocation[] calldata allocations_, bool redistribute)
        external
        nonReentrant
        onlyOwner
        takeFees
    {
        uint256 len = allocations_.length;

        if (len != strategies.length) revert InvalidLength(len, strategies.length);

        uint256 allotmentTotals = 0;
        for (uint256 i; i < len;) {
            allotmentTotals += allocations_[i].amount;
            strategies[i].allocation = allocations_[i];
            unchecked {
                i++;
            }
        }
        if (allotmentTotals != 10000) revert AllotmentTotalTooHigh();

        if (redistribute) {
            pullFundsFromStrategies();
            pushFundsToStrategies();
        }

        emit StrategyAllocationsChanged(allocations_);
    }

    /**
     * @notice Pushes funds from the vault into all strategies based on their allocation.
     * @dev Can only be called by the vault owner. Reverts if the vault is idle.
     */
    function pushFundsToStrategies() public onlyOwner {
        if (vaultIdle) revert VaultIsIdle();
        uint256 _totalAssets = IERC20(asset()).balanceOf(address(this));

        // Call the library function to distribute assets
        MultiStrategyVaultHelper.distributeAssetsToStrategies(strategies, _totalAssets);
    }

    /**
     * @notice Pulls funds back from all strategies into the vault.
     * @dev Can only be called by the vault owner.
     */
    // We are aware that we aren't using the return value
    // We control both the length of the array and the external call
    //slither-disable-next-line unused-return,calls-loop
    function pullFundsFromStrategies() public onlyOwner {
        uint256 len = strategies.length;

        for (uint256 i; i < len;) {
            pullFundsFromSingleStrategy(i);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Pulls funds back from a single strategy into the vault.
     * @dev Can only be called by the vault owner.
     * @param index_ The index of the strategy from which to pull funds.
     */

    // We are aware that we aren't using the return value
    // We control both the length of the array and the external call
    //slither-disable-next-line unused-return,calls-loop
    function pullFundsFromSingleStrategy(uint256 index_) public onlyOwner {
        IStrategy strategy = strategies[index_].strategy;
        // slither-disable-next-line unused-return
        if (strategy.getAvailableAssetsForWithdrawal() != strategy.totalAssets()) {
            strategy.withdraw(strategy.getAvailableAssetsForWithdrawal(), address(this), address(this));
            return;
        }
        strategy.redeem(strategy.balanceOf(address(this)), address(this), address(this));
    }

    /**
     * @notice Pushes funds from the vault into a single strategy based on its allocation.
     * @dev Can only be called by the vault owner. Reverts if the vault is idle.
     * @param index_ The index of the strategy into which to push funds.
     */
    function pushFundsIntoSingleStrategy(uint256 index_) external onlyOwner {
        uint256 _totalAssets = IERC20(asset()).balanceOf(address(this));

        if (index_ >= strategies.length) revert InvalidIndex(index_);

        if (vaultIdle) revert VaultIsIdle();
        Strategy memory strategy = strategies[index_];
        // slither-disable-next-line unused-return
        strategy.strategy.deposit(
            _totalAssets.mulDiv(strategy.allocation.amount, MAX_BASIS_POINTS, Math.Rounding.Floor), address(this)
        );
    }

    /**
     * @notice Pushes the amount sent from the vault into a single strategy.
     * @dev Can only be called by the vault owner. Reverts if the vault is idle.
     * @param index_ The index of the strategy into which to push funds.
     * @param amount The index of the strategy into which to push funds.
     */
    function pushFundsIntoSingleStrategy(uint256 index_, uint256 amount) external onlyOwner {
        uint256 balance = IERC20(asset()).balanceOf(address(this));
        if (amount > balance) revert InsufficientVaultFunds(address(this), amount, balance);
        if (vaultIdle) revert VaultIsIdle();
        // slither-disable-next-line unused-return
        strategies[index_].strategy.deposit(amount, address(this));
    }

    /**
     * @notice Sets a new deposit limit for the vault.
     * @dev Can only be called by the vault owner. Emits a `DepositLimitSet` event with the new limit.
     * @param newLimit_ The new deposit limit to set.
     */
    function setDepositLimit(uint256 newLimit_) external onlyOwner {
        depositLimit = newLimit_;
        emit DepositLimitSet(newLimit_);
    }

    /**
     * @notice Harvest rewards on every strategy.
     * @dev Calculates de reward index for each reward found.
     */
    //we control the external call
    //slither-disable-next-line unused-return,calls-loop,reentrancy-no-eth
    function harvestRewards(bytes memory encodedData) external onlyOwner nonReentrant {
        uint256[] memory indices;
        bytes[] memory data;
        if (encodedData.length != 0) {
            (indices, data) = abi.decode(encodedData, (uint256[], bytes[]));
        }
        uint256 totalSupply = totalSupply();
        bytes memory rewardsData;
        for (uint256 i; i < strategies.length;) {
            //We control both the length of the array and the external call
            //slither-disable-next-line unused-return,calls-loop

            for (uint256 k = 0; k < indices.length; k++) {
                if (indices[k] == i) {
                    rewardsData = data[k];
                    break;
                }
                rewardsData = "";
            }
            ReturnedRewards[] memory returnedRewards = strategies[i].strategy.harvestRewards(rewardsData);

            for (uint256 j; j < returnedRewards.length;) {

                uint256 amount = returnedRewards[j].rewardAmount;
                address rewardToken = returnedRewards[j].rewardAddress;
                if (amount != 0) {
                    if (rewardIndex[rewardToken] == 0) rewardAddresses.push(rewardToken);
                    rewardIndex[rewardToken] += amount.mulDiv(PRECISION, totalSupply, Math.Rounding.Floor);
                }
                unchecked {
                    j++;
                }
            }
            unchecked {
                i++;
            }
        }
        emit RewardsHarvested();
    }

    /**
     * @notice Updates the user rewards to the current reward index.
     * @dev Calculates the rewards to be transferred to the user based on the difference between the current and previous reward indexes.
     * @param userAddress The address of the user to update rewards for.
     */
    //slither-disable-next-line unused-return,calls-loop,reentrancy-no-eth
    function updateUserRewardsToCurrent(address userAddress) private {
        //retrieves user balance in shares
        uint256 userBalance = balanceOf(userAddress);
        uint256 len = rewardAddresses.length;
        for (uint256 i; i < len;) {
            uint256 tokenRewardIndex = rewardIndex[rewardAddresses[i]];
            if (userBalance != 0) {
                uint256 rewardsToTransfer = (tokenRewardIndex - userRewardIndex[userAddress][rewardAddresses[i]]).mulDiv(
                    userBalance, PRECISION, Math.Rounding.Floor
                );
                if (rewardsToTransfer != 0) {
                    totalRewardsClaimed[userAddress][rewardAddresses[i]] += rewardsToTransfer;
                    IERC20(rewardAddresses[i]).safeTransfer(userAddress, rewardsToTransfer);
                }
            }
            userRewardIndex[userAddress][rewardAddresses[i]] = tokenRewardIndex;
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Claims multiple withdrawal requests starting from the lasFinalizedRequestId.
     * @dev This function allows the contract owner to claim multiple withdrawal requests in batches.
     * @param maxRequests The maximum number of withdrawal requests to be processed in this batch.
     */
    function batchClaimWithdrawal(uint256 maxRequests) external onlyOwner nonReentrant {
        if (address(withdrawalQueue) == address(0)) revert QueueNotSet();
        uint256 availableAssets = getAvailableAssetsForWithdrawal();

        uint256 lastFinalizedId = withdrawalQueue.getLastFinalizedRequestId();
        uint256 lastCreatedId = withdrawalQueue.getLastRequestId();
        uint256 newLastFinalized = lastFinalizedId;

        uint256 max = lastCreatedId < lastFinalizedId + maxRequests ? lastCreatedId : lastFinalizedId + maxRequests;

        for (uint256 i = lastFinalizedId + 1; i <= max;) {
            uint256 newAvailiableAssets = claimWithdrawal(i, availableAssets);
            // slither-disable-next-line incorrect-equality
            if (newAvailiableAssets == availableAssets) break;

            availableAssets = newAvailiableAssets;
            newLastFinalized = i;
            unchecked {
                i++;
            }
        }

        if (newLastFinalized != lastFinalizedId) {
            withdrawalQueue._finalize(newLastFinalized);
        }
    }

    function claimRewards() external {
        updateUserRewardsToCurrent(msg.sender);
    }

    /**
     * @notice Requests funds from available assets.
     * @dev This function allows the protect strategy to request funds from available assets, withdraws from other strategies if necessary,
     * and deposits the requested funds into the protect strategy.
     * @param amount The amount of funds to request.
     */
    //we control the external call, only callable by the protect strategy
    //slither-disable-next-line calls-loop,,reentrancy-events
    function requestFunds(uint256 amount) external onlyProtect {

        uint256 acumulated = MultiStrategyVaultHelper.withdrawAssets(asset(), amount, protectStrategy, strategies);


        //after requesting funds deposits them into the protect strategy
        if (acumulated < amount) {
            revert InsufficientFunds(IStrategy(address(this)), amount, acumulated);
        }
        //slither-disable-next-line unused-return
        IStrategy(protectStrategy).deposit(amount, address(this));
        emit RequestedFunds(protectStrategy, amount);
    }

    // Helper function ////////////////////////

    function _validateAndUpdateDepositTimestamps(address receiver_) private {
        if (receiver_ == address(0)) revert InvalidRecipient();
        if (totalSupply() == 0) feesUpdatedAt = block.timestamp;

        if (firstDeposit == 0) {
            firstDeposit = block.timestamp;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Ownable
    struct OwnableStorage {
        address _owner;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Ownable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OwnableStorageLocation = 0x9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300;

    function _getOwnableStorage() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

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
    function __Ownable_init(address initialOwner) internal onlyInitializing {
        __Ownable_init_unchained(initialOwner);
    }

    function __Ownable_init_unchained(address initialOwner) internal onlyInitializing {
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
        OwnableStorage storage $ = _getOwnableStorage();
        return $._owner;
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
        OwnableStorage storage $ = _getOwnableStorage();
        address oldOwner = $._owner;
        $._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ContextUpgradeable} from "../../utils/ContextUpgradeable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata, IERC20Errors {
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC20
    struct ERC20Storage {
        mapping(address account => uint256) _balances;

        mapping(address account => mapping(address spender => uint256)) _allowances;

        uint256 _totalSupply;

        string _name;
        string _symbol;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20StorageLocation = 0x52c63247e1f47db19d5ce0460030c497f067ca4cebf71ba98eeadabe20bace00;

    function _getERC20Storage() private pure returns (ERC20Storage storage $) {
        assembly {
            $.slot := ERC20StorageLocation
        }
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC20Storage storage $ = _getERC20Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        ERC20Storage storage $ = _getERC20Storage();
        return $._allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            $._totalSupply += value;
        } else {
            uint256 fromBalance = $._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                $._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                $._totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                $._balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        ERC20Storage storage $ = _getERC20Storage();
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        $._allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20Upgradeable} from "../ERC20Upgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the ERC4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[EIP-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation uses virtual assets and shares to mitigate that risk. The `_decimalsOffset()`
 * corresponds to an offset in the decimal representation between the underlying asset's decimals and the vault
 * decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which itself
 * determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default offset
 * (0) makes it non-profitable, as a result of the value being captured by the virtual shares (out of the attacker's
 * donation) matching the attacker's expected gains. With a larger offset, the attack becomes orders of magnitude more
 * expensive than it is profitable. More details about the underlying math can be found
 * xref:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 */
abstract contract ERC4626Upgradeable is Initializable, ERC20Upgradeable, IERC4626 {
    using Math for uint256;

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC4626
    struct ERC4626Storage {
        IERC20 _asset;
        uint8 _underlyingDecimals;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC4626")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC4626StorageLocation = 0x0773e532dfede91f04b12a73d3d2acd361424f41f76b4fb79f090161e36b4e00;

    function _getERC4626Storage() private pure returns (ERC4626Storage storage $) {
        assembly {
            $.slot := ERC4626StorageLocation
        }
    }

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC20 or ERC777).
     */
    function __ERC4626_init(IERC20 asset_) internal onlyInitializing {
        __ERC4626_init_unchained(asset_);
    }

    function __ERC4626_init_unchained(IERC20 asset_) internal onlyInitializing {
        ERC4626Storage storage $ = _getERC4626Storage();
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        $._underlyingDecimals = success ? assetDecimals : 18;
        $._asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20Upgradeable) returns (uint8) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return $._underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual returns (address) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return address($._asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        ERC4626Storage storage $ = _getERC4626Storage();
        return $._asset.balanceOf(address(this));
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}.
     *
     * As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        ERC4626Storage storage $ = _getERC4626Storage();
        // If _asset is ERC777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom($._asset, caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        ERC4626Storage storage $ = _getERC4626Storage();
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        SafeERC20.safeTransfer($._asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "../utils/ContextUpgradeable.sol";
import {Initializable} from "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:storage-location erc7201:openzeppelin.storage.Pausable
    struct PausableStorage {
        bool _paused;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Pausable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PausableStorageLocation = 0xcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f03300;

    function _getPausableStorage() private pure returns (PausableStorage storage $) {
        assembly {
            $.slot := PausableStorageLocation
        }
    }

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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        PausableStorage storage $ = _getPausableStorage();
        $._paused = false;
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
        PausableStorage storage $ = _getPausableStorage();
        return $._paused;
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
        PausableStorage storage $ = _getPausableStorage();
        $._paused = true;
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
        PausableStorage storage $ = _getPausableStorage();
        $._paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
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
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

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
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20, IERC20Metadata, ERC20} from "../ERC20.sol";
import {SafeERC20} from "../utils/SafeERC20.sol";
import {IERC4626} from "../../../interfaces/IERC4626.sol";
import {Math} from "../../../utils/math/Math.sol";

/**
 * @dev Implementation of the ERC4626 "Tokenized Vault Standard" as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[EIP-4626].
 *
 * This extension allows the minting and burning of "shares" (represented using the ERC20 inheritance) in exchange for
 * underlying "assets" through standardized {deposit}, {mint}, {redeem} and {burn} workflows. This contract extends
 * the ERC20 standard. Any additional extensions included along it would affect the "shares" token represented by this
 * contract and not the "assets" token which is an independent contract.
 *
 * [CAUTION]
 * ====
 * In empty (or nearly empty) ERC-4626 vaults, deposits are at high risk of being stolen through frontrunning
 * with a "donation" to the vault that inflates the price of a share. This is variously known as a donation or inflation
 * attack and is essentially a problem of slippage. Vault deployers can protect against this attack by making an initial
 * deposit of a non-trivial amount of the asset, such that price manipulation becomes infeasible. Withdrawals may
 * similarly be affected by slippage. Users can protect against this attack as well as unexpected slippage in general by
 * verifying the amount received is as expected, using a wrapper that performs these checks such as
 * https://github.com/fei-protocol/ERC4626#erc4626router-and-base[ERC4626Router].
 *
 * Since v4.9, this implementation uses virtual assets and shares to mitigate that risk. The `_decimalsOffset()`
 * corresponds to an offset in the decimal representation between the underlying asset's decimals and the vault
 * decimals. This offset also determines the rate of virtual shares to virtual assets in the vault, which itself
 * determines the initial exchange rate. While not fully preventing the attack, analysis shows that the default offset
 * (0) makes it non-profitable, as a result of the value being captured by the virtual shares (out of the attacker's
 * donation) matching the attacker's expected gains. With a larger offset, the attack becomes orders of magnitude more
 * expensive than it is profitable. More details about the underlying math can be found
 * xref:erc4626.adoc#inflation-attack[here].
 *
 * The drawback of this approach is that the virtual shares do capture (a very small) part of the value being accrued
 * to the vault. Also, if the vault experiences losses, the users try to exit the vault, the virtual shares and assets
 * will cause the first user to exit to experience reduced losses in detriment to the last users that will experience
 * bigger losses. Developers willing to revert back to the pre-v4.9 behavior just need to override the
 * `_convertToShares` and `_convertToAssets` functions.
 *
 * To learn more, check out our xref:ROOT:erc4626.adoc[ERC-4626 guide].
 * ====
 */
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    /**
     * @dev Attempted to mint more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    /**
     * @dev Attempted to withdraw more assets than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxWithdraw(address owner, uint256 assets, uint256 max);

    /**
     * @dev Attempted to redeem more shares than the max amount for `receiver`.
     */
    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);

    /**
     * @dev Set the underlying asset contract. This must be an ERC20-compatible contract (ERC20 or ERC777).
     */
    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }

    /**
     * @dev Attempts to fetch the asset decimals. A return value of false indicates that the attempt failed in some way.
     */
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeCall(IERC20Metadata.decimals, ())
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }

    /**
     * @dev Decimals are computed by adding the decimal offset on top of the underlying asset's decimals. This
     * "original" value is cached during construction of the vault contract. If this read operation fails (e.g., the
     * asset has not been created yet), a default of 18 is used to represent the underlying asset's decimals.
     *
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Ceil);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}.
     *
     * As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     */
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        // If _asset is ERC777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        _burn(owner, shares);
        SafeERC20.safeTransfer(_asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}