// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Interface for Fuses Common functions
interface IFuseCommon {
    /// @notice Market ID associated with the Fuse
    //solhint-disable-next-line
    function MARKET_ID() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title IPreHook
/// @notice Interface for pre-execution hooks in Plasma Vault operations
/// @dev This interface defines the contract that handles pre-execution validations and setup logic for vault operations.
///      Pre-hooks are essential components that run before main vault operations to ensure proper state management,
///      perform validations, or prepare the system for the upcoming operation.
///      Implementations must be gas-efficient and reentrant-safe.
interface IPreHook {
    /// @notice Executes the pre-hook logic before the main vault operation
    /// @dev This function is called by the vault before executing the main operation.
    ///      Implementations should:
    ///      - Be gas efficient
    ///      - Include proper access control
    ///      - Handle all edge cases
    ///      - Revert on validation failures
    ///      The function must not be susceptible to reentrancy attacks
    /// @param selector_ The function selector of the main operation that will be executed
    function run(bytes4 selector_) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {PreHooksLib} from "./PreHooksLib.sol";
import {IPreHook} from "./IPreHook.sol";

/// @title PreHooksHandler
/// @notice Handles pre-execution hooks for Plasma Vault operations
/// @dev Abstract contract that manages the execution of pre-hooks in the vault system.
///      This handler is responsible for:
///      - Safely executing pre-hook logic through delegate calls
///      - Managing hook execution flow
///      - Ensuring proper hook validation
///
///      Security considerations:
///      - Uses delegate calls for hook execution
///      - Implements null address checks
///      - Maintains execution context safety
///
///      Integration notes:
///      - Contracts inheriting this handler must ensure proper access control
///      - Pre-hooks are optional and can be skipped if implementation is not set
abstract contract PreHooksHandler {
    using Address for address;

    /// @notice Executes pre-hooks for a given operation
    /// @dev Internal function that runs the pre-hook logic through a delegate call.
    ///      The function:
    ///      - Retrieves the pre-hook implementation for the given selector
    ///      - Skips execution if no implementation is found (address(0))
    ///      - Executes the hook via delegate call to maintain vault's context
    ///      - Preserves the vault's storage context during execution
    /// @param selector_ The function selector of the operation requiring pre-hook execution
    function _runPreHook(bytes4 selector_) internal {
        address implementation = PreHooksLib.getPreHookImplementation(selector_);
        if (implementation == address(0)) {
            return;
        }
        implementation.functionDelegateCall(abi.encodeWithSelector(IPreHook.run.selector, selector_));
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {PlasmaVaultStorageLib} from "../../libraries/PlasmaVaultStorageLib.sol";

/// @title PreHooksLib
/// @notice Library for handling pre-execution hooks in Plasma Vault operations
/// @dev Provides validation and setup logic to run before main vault operations
///      This library manages the lifecycle of pre-hooks, including their registration,
///      updates, and removal, while maintaining efficient storage patterns
library PreHooksLib {
    /// @notice Error thrown when input arrays have different lengths
    error PreHooksLibInvalidArrayLength();
    /// @notice Error thrown when selector is zero
    error PreHooksLibInvalidSelector();

    /// @notice Emitted when a pre-hook implementation is changed for a function selector
    /// @param selector The function selector that was updated
    /// @param newImplementation The new implementation address (address(0) if it was removed)
    /// @param substrates The substrates for the new implementation
    event PreHookImplementationChanged(bytes4 indexed selector, address newImplementation, bytes32[] substrates);

    /// @notice Returns the pre-hook implementation address for a given function signature
    /// @dev Uses PlasmaVaultStorageLib to access the pre-hooks configuration
    ///      This function is used to determine which pre-hook implementation should be executed
    ///      for a specific function selector
    /// @param selector_ The function selector to get the pre-hook implementation for
    /// @return The address of the pre-hook implementation contract, or address(0) if not found
    function getPreHookImplementation(bytes4 selector_) internal view returns (address) {
        return PlasmaVaultStorageLib.getPreHooksConfig().hooksImplementation[selector_];
    }

    /// @notice Retrieves the substrates associated with a specific pre-hook implementation
    /// @dev Uses a composite key (implementation + selector) to look up substrates in storage
    ///      Substrates are additional configuration parameters that can be used by the pre-hook
    ///      implementation to customize its behavior
    /// @param selector_ The function selector associated with the pre-hook
    /// @param implementation_ The address of the pre-hook implementation
    /// @return An array of bytes32 values representing the substrates for this pre-hook
    function getPreHookSubstrates(bytes4 selector_, address implementation_) internal view returns (bytes32[] memory) {
        return
            PlasmaVaultStorageLib.getPreHooksConfig().substrates[
                keccak256(abi.encodePacked(implementation_, selector_))
            ];
    }

    /// @notice Returns all function selectors that have pre-hooks configured
    /// @dev Retrieves the complete list of selectors from storage
    ///      This function is useful for governance and administrative tasks
    ///      that need to inspect or modify the pre-hook configuration
    /// @return Array of function selectors (bytes4) with configured pre-hooks
    function getPreHookSelectors() internal view returns (bytes4[] memory) {
        return PlasmaVaultStorageLib.getPreHooksConfig().selectors;
    }

    /// @notice Sets new implementation addresses for given function selectors
    /// @dev Updates or adds new pre-hook implementations and maintains the selectors array
    /// - Setting implementation to address(0) removes/disables the pre-hook for that selector
    /// - Maintains array integrity using swap-and-pop pattern for removals
    /// - Updates indexes mapping for O(1) lookups
    ///
    /// Implementation States:
    /// - New pre-hook: oldImpl = 0, newImpl != 0
    ///   * Adds selector to array
    ///   * Sets up index mapping
    /// - Update pre-hook: oldImpl != 0, newImpl != 0
    ///   * Updates implementation only
    /// - Remove pre-hook: oldImpl != 0, newImpl = 0
    ///   * Removes selector from array
    ///   * Cleans up index mapping
    ///
    /// Storage Updates:
    /// - hooksImplementation: Maps selectors to implementations
    /// - selectors: Maintains array of active selectors
    /// - indexes: Tracks selector positions for O(1) access
    /// - substrates: Stores additional configuration for each hook
    ///
    /// Security Considerations:
    /// - Validates array lengths to prevent inconsistent state
    /// - Ensures non-zero selectors
    /// - Properly cleans up storage on removal
    ///
    /// Gas Optimization:
    /// - Uses swap-and-pop for efficient array management
    /// - Maintains O(1) lookups through index mapping
    /// - Minimizes storage operations
    ///
    /// @param selectors_ Array of function selectors to set implementations for
    /// @param implementations_ Array of implementation addresses (use address(0) to disable)
    /// @param substrates_ Array of substrate configurations for each implementation
    /// @custom:events Emits PreHookImplementationChanged for each update
    function setPreHookImplementations(
        bytes4[] calldata selectors_,
        address[] calldata implementations_,
        bytes32[][] calldata substrates_
    ) internal {
        if (selectors_.length != implementations_.length || selectors_.length != substrates_.length) {
            revert PreHooksLibInvalidArrayLength();
        }

        PlasmaVaultStorageLib.PreHooksConfig storage preHooksConfig = PlasmaVaultStorageLib.getPreHooksConfig();

        bytes4 selector;
        address newImplementation;
        address oldImplementation;
        uint256 selectorsLength = selectors_.length;

        for (uint256 i; i < selectorsLength; ++i) {
            selector = selectors_[i];
            newImplementation = implementations_[i];
            if (selector == bytes4(0)) {
                revert PreHooksLibInvalidSelector();
            }

            oldImplementation = preHooksConfig.hooksImplementation[selector];

            // If this is a new selector, add it to the array and update its index
            if (oldImplementation == address(0) && newImplementation != address(0)) {
                preHooksConfig.selectors.push(selector);
                preHooksConfig.indexes[selector] = preHooksConfig.selectors.length - 1;
                preHooksConfig.substrates[keccak256(abi.encodePacked(newImplementation, selector))] = substrates_[i];
            }
            // If we're removing an implementation, swap and pop from the selectors array
            else if (oldImplementation != address(0) && newImplementation == address(0)) {
                uint256 index = preHooksConfig.indexes[selector];
                uint256 lastIndex = preHooksConfig.selectors.length - 1;
                if (index != lastIndex) {
                    bytes4 lastSelector = preHooksConfig.selectors[lastIndex];
                    preHooksConfig.selectors[index] = lastSelector;
                    preHooksConfig.indexes[lastSelector] = index;
                }
                preHooksConfig.selectors.pop();
                delete preHooksConfig.indexes[selector];
                delete preHooksConfig.substrates[keccak256(abi.encodePacked(oldImplementation, selector))];
            }

            preHooksConfig.hooksImplementation[selector] = newImplementation;

            emit PreHookImplementationChanged(selector, newImplementation, substrates_[i]);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";

/// @title Interface for the IporFusionAccessManager contract that manages access control for the IporFusion contract and its contract satellites
interface IIporFusionAccessManager is IAccessManager {
    /// @notice The minimal delay required for the timelocked functions, value is set in the constructor, cannot be changed
    /// @return The minimal delay in seconds
    // solhint-disable-next-line func-name-mixedcase
    function REDEMPTION_DELAY_IN_SECONDS() external view returns (uint256);

    /// @notice Check if the caller can call the target with the given selector. Update the account lock time.
    /// @dev canCall cannot be a view function because it updates the account lock time.
    function canCallAndUpdate(
        address caller,
        address target,
        bytes4 selector
    ) external returns (bool immediate, uint32 delay);

    /// @notice Close or open given target to interact with methods with restricted modifiers.
    /// @dev In most cases when Vault is bootstrapping the ADMIN_ROLE  is revoked so custom method is needed to grant roles for a GUARDIAN_ROLE.
    function updateTargetClosed(address target_, bool closed_) external;

    /// @notice Converts the specified vault to a public vault - mint and deposit functions are allowed for everyone.
    /// @dev Notice! Can convert to public but cannot convert back to private.
    /// @param vault_ The address of the vault
    function convertToPublicVault(address vault_) external;

    /// @notice Enables transfer shares, transfer and transferFrom functions are allowed for everyone.
    /// @param vault_ The address of the vault
    function enableTransferShares(address vault_) external;

    /// @notice Sets the minimal execution delay required for the specified roles.
    /// @param rolesIds_ The roles for which the minimal execution delay is set
    /// @param delays_ The minimal execution delays for the specified roles
    function setMinimalExecutionDelaysForRoles(uint64[] calldata rolesIds_, uint256[] calldata delays_) external;

    /// @notice Returns the minimal execution delay required for the specified role.
    /// @param roleId_ The role for which the minimal execution delay is returned
    /// @return The minimal execution delay in seconds
    function getMinimalExecutionDelayForRole(uint64 roleId_) external view returns (uint256);

    /// @notice Returns the account lock time for the specified account.
    /// @param account_ The account for which the account lock time is returned
    /// @return The account lock time in seconds
    function getAccountLockTime(address account_) external view returns (uint256);

    /// @notice Returns the function selector for the scheduled operation that is currently being consumed.
    /// @return The function selector
    function isConsumingScheduledOp() external view returns (bytes4);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @notice FuseAction is a struct that represents a single action that can be executed by an Alpha
struct FuseAction {
    /// @notice fuse is an address of the Fuse contract
    address fuse;
    /// @notice data is a bytes data that is passed to the Fuse contract
    bytes data;
}

/// @title Plasma Vault interface with business methods
interface IPlasmaVault {
    /// @notice Returns the total assets in the market with the given marketId
    /// @param marketId_ The marketId of the market
    /// @return The total assets in the market represented in underlying token decimals
    function totalAssetsInMarket(uint256 marketId_) external view returns (uint256);

    /**
     * @notice Updates the balances of the specified markets.
     * @param marketIds_ The array of market IDs to update balances for.
     * @return The total assets in the Plasma Vault after updating the market balances.
     * @dev If the `marketIds_` array is empty, it returns the total assets without updating any market balances.
     *      This function first records the total assets before updating the market balances, then updates the balances,
     *      adds the performance fee based on the assets before the update, and finally returns the new total assets.
     */
    function updateMarketsBalances(uint256[] calldata marketIds_) external returns (uint256);

    /// @notice Gets unrealized management fee
    /// @return The unrealized management fee represented in underlying token decimals
    function getUnrealizedManagementFee() external view returns (uint256);

    /// @notice Execute fuse actions on the Plasma Vault via Fuses, by Alpha to perform actions which improve the performance earnings of the Plasma Vault
    /// @param calls_ The array of FuseActions to execute
    /// @dev Method is granted only to the Alpha
    function execute(FuseAction[] calldata calls_) external;

    /// @notice Claim rewards from the Plasma Vault via Rewards Fuses to claim rewards from connected protocols with the Plasma Vault
    /// @param calls_ The array of FuseActions to claim rewards
    /// @dev Method is granted only to the RewardsManager
    function claimRewards(FuseAction[] calldata calls_) external;

    /// @notice Deposit assets to the Plasma Vault with permit function
    /// @param assets_ The amount of underlying assets to deposit
    /// @param receiver_ The receiver of the assets
    /// @param deadline_ The deadline for the permit function
    /// @param v_ The v value of the signature
    /// @param r_ The r value of the signature
    /// @param s_ The s value of the signature
    /// @return The amount of shares minted
    function depositWithPermit(
        uint256 assets_,
        address receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (uint256);

    function redeemFromRequest(uint256 shares_, address receiver_, address owner_) external returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Plasma Vault Base interface
interface IPlasmaVaultBase {
    /// @notice Initializes the Plasma Vault
    /// @dev Method is executed only once during the Plasma Vault construction in context of Plasma Vault (delegatecall used)
    /// @param assetName_ The name of the asset
    /// @param accessManager_ The address of the Ipor Fusion Access Manager
    /// @param totalSupplyCap_ The total supply cap of the shares
    function init(string memory assetName_, address accessManager_, uint256 totalSupplyCap_) external;

    /// @notice When token are transferring, updates data in storage required for functionalities included in PlasmaVaultBase but in context of Plasma Vault (delegatecall used)
    /// @param from_ The address from which the tokens are transferred
    /// @param to_ The address to which the tokens are transferred
    /// @param value_ The amount of tokens transferred
    function updateInternal(address from_, address to_, uint256 value_) external;

    /// @notice Transfers request fee tokens from user to withdraw manager
    /// @dev This function is called during the withdraw request process to handle request fee transfers
    ///
    /// Access Control:
    /// - Restricted to TECH_WITHDRAW_MANAGER_ROLE only
    /// - Cannot be called by any other role, including admin or owner
    /// - System-level role assigned during initialization
    /// - Technical role that cannot be reassigned during runtime
    ///
    /// Fee System:
    /// - Transfers request fee tokens from user to withdraw manager
    /// - Part of the withdraw request flow
    /// - Only callable by authorized contracts (restricted)
    /// - Critical for fee collection mechanism
    ///
    /// Integration Context:
    /// - Called by WithdrawManager during requestShares
    /// - Handles fee collection for withdrawal requests
    /// - Maintains fee token balances
    /// - Supports protocol revenue model
    ///
    /// Security Features:
    /// - Access controlled (restricted to TECH_WITHDRAW_MANAGER_ROLE)
    /// - Atomic operation
    /// - State consistency checks
    /// - Integrated with vault permissions
    ///
    /// Use Cases:
    /// - Withdrawal request fee collection
    /// - Protocol revenue generation
    /// - Fee token management
    /// - Automated fee handling
    ///
    /// Related Components:
    /// - WithdrawManager contract (must have TECH_WITHDRAW_MANAGER_ROLE)
    /// - Fee management system
    /// - Access control system
    /// - Token operations
    ///
    /// @param from_ The address from which to transfer the fee tokens
    /// @param to_ The address to which the fee tokens should be transferred (usually withdraw manager)
    /// @param amount_ The amount of fee tokens to transfer
    /// @custom:access TECH_WITHDRAW_MANAGER_ROLE
    function transferRequestSharesFee(address from_, address to_, uint256 amount_) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {PlasmaVaultStorageLib} from "../libraries/PlasmaVaultStorageLib.sol";
import {InstantWithdrawalFusesParamsStruct} from "../libraries/PlasmaVaultLib.sol";
import {MarketLimit} from "../libraries/AssetDistributionProtectionLib.sol";

/// @title Plasma Vault Governance interface
interface IPlasmaVaultGovernance {
    /// @notice Checks if the market has granted the substrate
    /// @param marketId_ The marketId of the market
    /// @param substrate_ The substrate to check
    /// @return True if the market has granted the substrate
    function isMarketSubstrateGranted(uint256 marketId_, bytes32 substrate_) external view returns (bool);

    /// @notice Checks if fuse is supported
    /// @param fuse_ The address of the fuse
    /// @return True if the fuse is supported
    function isFuseSupported(address fuse_) external view returns (bool);

    /// @notice Checks if balance fuse is supported in a given market
    /// @param marketId_ The marketId of the market
    /// @param fuse_ The address of the fuse
    /// @return True if the balance fuse is supported
    function isBalanceFuseSupported(uint256 marketId_, address fuse_) external view returns (bool);

    /// @notice Checks if the markets limits protection is activated
    /// @return True if the markets limits protection is activated
    function isMarketsLimitsActivated() external view returns (bool);

    /// @notice Returns the array of market substrates granted in the market
    /// @param marketId_ The marketId of the market
    /// @return The array of substrates granted in the market
    /// @dev Substrates can be assets, vault, markets or any other parameter specific for the market and associated with market external protocol
    function getMarketSubstrates(uint256 marketId_) external view returns (bytes32[] memory);

    /// @notice Returns the array of fuses supported by the Plasma Vault
    /// @return The array of fuses
    function getFuses() external view returns (address[] memory);

    /// @notice Returns the address of the Price Oracle Middleware
    /// @return The address of the Price Oracle Middleware
    function getPriceOracleMiddleware() external view returns (address);

    /// @notice Returns the performance fee configuration data of the Plasma Vault
    /// @return feeData The performance fee configuration data, see PerformanceFeeData struct
    function getPerformanceFeeData() external view returns (PlasmaVaultStorageLib.PerformanceFeeData memory feeData);

    /// @notice Returns the management fee configuration data of the Plasma Vault
    /// @return feeData The management fee configuration data, see ManagementFeeData struct
    function getManagementFeeData() external view returns (PlasmaVaultStorageLib.ManagementFeeData memory feeData);

    /// @notice Returns the address of the Ipor Fusion Access Manager
    /// @return The address of the Ipor Fusion Access Manager
    function getAccessManagerAddress() external view returns (address);

    /// @notice Returns the address of the Rewards Claim Manager
    /// @return The address of the Rewards Claim Manager
    function getRewardsClaimManagerAddress() external view returns (address);

    /// @notice Returns the array of fuses used during the instant withdrawal process, order of the fuses is important
    /// @return The array of fuses, the order of the fuses is important
    function getInstantWithdrawalFuses() external view returns (address[] memory);

    /// @notice Returns the parameters used by the instant withdrawal fuses
    /// @param fuse_ The address of the fuse
    /// @param index_ The index of the fuse in the ordered array of fuses
    /// @return The array of parameters used by the fuse
    function getInstantWithdrawalFusesParams(address fuse_, uint256 index_) external view returns (bytes32[] memory);

    /// @notice Returns the market limit for the given market in percentage represented in 1e18
    /// @param marketId_ The marketId of the market
    /// @return The market limit in percentage represented in 1e18
    /// @dev This is percentage of the total balance in the Plasma Vault
    function getMarketLimit(uint256 marketId_) external view returns (uint256);

    /// @notice Gets the dependency balance graph for the given market, meaning the markets that are dependent on the given market and should be considered in the balance calculation
    /// @param marketId_ The marketId of the market
    /// @return Dependency balance graph is required because exists external protocols where interaction with the market can affect the balance of other markets
    function getDependencyBalanceGraph(uint256 marketId_) external view returns (uint256[] memory);

    /// @notice Returns the total supply cap
    /// @return The total supply cap, the values is represented in underlying decimals
    function getTotalSupplyCap() external view returns (uint256);

    /// @notice Adds the balance fuse to the market
    /// @param marketId_ The marketId of the market
    /// @param fuse_ The address of the balance fuse
    function addBalanceFuse(uint256 marketId_, address fuse_) external;

    /// @notice Removes the balance fuse from the market
    /// @param marketId_ The marketId of the market
    /// @param fuse_ The address of the balance fuse
    function removeBalanceFuse(uint256 marketId_, address fuse_) external;

    /// @notice Grants the substrates to the market
    /// @param marketId_ The marketId of the market
    /// @param substrates_ The substrates to grant
    /// @dev Substrates can be assets, vault, markets or any other parameter specific for the market and associated with market external protocol
    function grantMarketSubstrates(uint256 marketId_, bytes32[] calldata substrates_) external;

    /// @notice Updates the dependency balance graphs for the markets
    /// @param marketIds_ The array of marketIds
    /// @param dependencies_ dependency graph of markets
    function updateDependencyBalanceGraphs(uint256[] memory marketIds_, uint256[][] memory dependencies_) external;

    /// @notice Configures the instant withdrawal fuses. Order of the fuse is important, as it will be used in the same order during the instant withdrawal process
    /// @param fuses_ The array of InstantWithdrawalFusesParamsStruct to configure
    /// @dev Order of the fuses is important, the same fuse can be used multiple times with different parameters (for example different assets, markets or any other substrate specific for the fuse)
    function configureInstantWithdrawalFuses(InstantWithdrawalFusesParamsStruct[] calldata fuses_) external;

    /// @notice Adds the fuses supported by the Plasma Vault
    /// @param fuses_ The array of fuses to add
    function addFuses(address[] calldata fuses_) external;

    /// @notice Removes the fuses supported by the Plasma Vault
    /// @param fuses_ The array of fuses to remove
    function removeFuses(address[] calldata fuses_) external;

    /// @notice Sets the Price Oracle Middleware address
    /// @param priceOracleMiddleware_ The address of the Price Oracle Middleware
    function setPriceOracleMiddleware(address priceOracleMiddleware_) external;

    /// @notice Configures the performance fee
    /// @param feeAccount_ The address of the technical Performance Fee Account that will receive the performance fee collected by the Plasma Vault and later on distributed to IPOR DAO and recipients by FeeManager
    /// @param feeInPercentage_ The fee in percentage represented in 2 decimals, example 100% = 10000, 1% = 100, 0.01% = 1
    /// @dev feeAccount_ can be also EOA address or MultiSig address, in this case it will receive the performance fee directly
    function configurePerformanceFee(address feeAccount_, uint256 feeInPercentage_) external;

    /// @notice Configures the management fee
    /// @param feeAccount_ The address of the technical Management Fee Account that will receive the management fee collected by the Plasma Vault and later on distributed to IPOR DAO and recipients by FeeManager
    /// @param feeInPercentage_ The fee in percentage represented in 2 decimals, example 100% = 10000, 1% = 100, 0.01% = 1
    /// @dev feeAccount_ can be also EOA address or MultiSig address, in this case it will receive the management fee directly
    function configureManagementFee(address feeAccount_, uint256 feeInPercentage_) external;

    /// @notice Sets the Rewards Claim Manager address
    /// @param rewardsClaimManagerAddress_ The address of the Rewards Claim Manager
    function setRewardsClaimManagerAddress(address rewardsClaimManagerAddress_) external;

    /// @notice Sets the market limit for the given market in percentage represented in 18 decimals
    /// @param marketsLimits_ The array of MarketLimit to setup, see MarketLimit struct
    function setupMarketsLimits(MarketLimit[] calldata marketsLimits_) external;

    /// @notice Activates the markets limits protection, by default it is deactivated. After activation the limits is setup for each market separately.
    function activateMarketsLimits() external;

    /// @notice Deactivates the markets limits protection.
    function deactivateMarketsLimits() external;

    /// @notice Updates the callback handler
    /// @param handler_ The address of the handler
    /// @param sender_ The address of the sender
    /// @param sig_ The signature of the function
    function updateCallbackHandler(address handler_, address sender_, bytes4 sig_) external;

    /// @notice Sets the total supply cap
    /// @param cap_ The total supply cap, the values is represented in underlying decimals
    function setTotalSupplyCap(uint256 cap_) external;

    /// @notice Converts the specified vault to a public vault - mint and deposit functions are allowed for everyone.
    /// @dev Notice! Can convert to public but cannot convert back to private.
    function convertToPublicVault() external;

    /// @notice Enables transfer shares, transfer and transferFrom functions are allowed for everyone.
    function enableTransferShares() external;

    /// @notice Sets the minimal execution delay required for the specified roles.
    /// @param rolesIds_ The roles for which the minimal execution delay is set
    /// @param delays_ The minimal execution delays for the specified roles
    function setMinimalExecutionDelaysForRoles(uint64[] calldata rolesIds_, uint256[] calldata delays_) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {FuseAction} from "../interfaces/IPlasmaVault.sol";

/// @notice Vesting data struct
/// @custom:storage-location erc7201:io.ipor.managers.rewards.VestingData
struct VestingData {
    /// @notice vestingTime The time when the vesting is pending
    uint32 vestingTime;
    /// @notice updateBalanceTimestamp The timestamp of the last balance update
    uint32 updateBalanceTimestamp;
    /// @notice transferredTokens The number of tokens that have been transferred from RewardsClaimManager to the Plasma Vault
    uint128 transferredTokens;
    /// @notice lastUpdateBalance The balance of the last update
    uint128 lastUpdateBalance;
}

/// @title Rewards Claim Manager interface
interface IRewardsClaimManager {
    /// @notice Retrieves the balance of linear vested underlying tokens owned by RewardsClaimManager.sol contract
    /// @return balance The balance of the vesting data in uint256.
    /// @dev This method calculates the current balance based on the vesting schedule.
    /// If the `updateBalanceTimestamp` is zero, it returns zero. Otherwise, it calculates
    /// the ratio of the elapsed time to the total vesting time to determine the proportion
    /// of the balance that is currently available. The balance is adjusted by the number
    /// of tokens that have already been transferred. Thr result is in underlying token decimals.
    function balanceOf() external view returns (uint256);

    /// @notice Checks if the specified reward fuse is supported.
    /// @param fuse_ The address of the fuse to be checked.
    /// @return supported A boolean value indicating whether the reward fuse is supported.
    /// @dev This method checks the internal configuration to determine if the provided fuse address
    /// is supported for reward management.
    function isRewardFuseSupported(address fuse_) external view returns (bool);

    /// @notice Retrieves the vesting data.
    /// @return vestingData A struct containing the vesting data.
    /// @dev This method returns the current state of the vesting data, including details such as
    /// the last update balance, the transferred tokens, and the timestamp of the last update.
    function getVestingData() external view returns (VestingData memory);

    /// @notice Transfers a specified amount of an asset to a given address.
    /// @param asset_ The address of the asset to be transferred.
    /// @param to_ The address of the recipient.
    /// @param amount_ The amount of the asset to be transferred, represented in the asset's decimals.
    /// @dev This method facilitates the transfer of a specified amount of the given asset from the contract to the recipient's address.
    function transfer(address asset_, address to_, uint256 amount_) external;

    /// @notice Adds multiple reward fuses.
    /// @param fuses_ An array of addresses representing the fuses to be added.
    /// @dev This method adds the provided list of fuse addresses to the contract's configuration.
    /// It allows the inclusion of multiple fuses in a single transaction for reward management purposes.
    function addRewardFuses(address[] calldata fuses_) external;

    /// @notice Removes a specified reward fuse.
    /// @param fuses_ The addresses of the fuse to be removed.
    /// @dev This method removes the provided fuse address from the contract's configuration.
    /// It is used to manage and update the list of supported reward fuses.
    function removeRewardFuses(address[] calldata fuses_) external;

    /// @notice Claims rewards based on the provided fuse actions.
    /// @param calls_ An array of FuseAction structs representing the actions for claiming rewards.
    /// @dev This method processes the provided fuse actions to claim the corresponding rewards.
    /// Each FuseAction in the array is executed to facilitate the reward claim process.
    function claimRewards(FuseAction[] calldata calls_) external;

    /// @notice Sets up the vesting schedule with a specified delay for token release.
    /// @param releaseTokensDelay_ The delay in seconds before the tokens are released.
    /// @dev This method configures the vesting schedule by setting the delay time for token release.
    /// The delay defines the period that must pass before the tokens can be released to the beneficiary.
    // @dev setting up this to zero will stopped vesting and freeze underling token on the contract
    function setupVestingTime(uint256 releaseTokensDelay_) external;

    /// @notice Updates the balance based on the current vesting schedule and transferred tokens.
    /// @dev This method recalculates the balance considering the elapsed time, vesting schedule,
    /// and the number of tokens that have already been transferred. It updates the internal
    /// state to reflect the latest balance.
    function updateBalance() external;

    /// @notice Transfers vested underlying tokens to the Plasma Vault.
    /// @dev This method transfers the underlying tokens that have vested according to the vesting schedule
    /// to the designated Plasma Vault. It ensures that only the vested portion of the underlying tokens
    /// is transferred.
    function transferVestedTokensToVault() external;

    /// @notice Retrieves the list of reward fuses.
    /// @return An array of addresses representing the reward fuses.
    function getRewardsFuses() external view returns (address[] memory);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {PlasmaVaultStorageLib} from "./PlasmaVaultStorageLib.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Asset Distribution Protection Library - Risk Management System for Plasma Vault
 * @notice Library enforcing market exposure limits and risk distribution across DeFi protocols
 * @dev Core risk management component that:
 * 1. Enforces maximum exposure limits per market
 * 2. Tracks and validates asset distribution
 * 3. Provides activation/deactivation controls
 * 4. Maintains market-specific limit configurations
 *
 * Key Components:
 * - Market Limit System: Percentage-based exposure controls
 * - Activation Controls: System-wide protection toggle
 * - Limit Validation: Real-time balance checks
 * - Storage Integration: Uses PlasmaVaultStorageLib for persistent state
 *
 * Integration Points:
 * - Used by PlasmaVault for operation validation
 * - Managed through PlasmaVaultGovernance
 * - Coordinates with FusesLib for market balance data
 * - Works with balance fuses for position tracking
 *
 * Security Considerations:
 * - Prevents over-concentration in single markets
 * - Enforces risk distribution across protocols
 * - Maintains system-wide risk parameters
 * - Critical for vault's risk management
 *
 * @custom:security-contact security@ipor.io
 */

/**
 * @notice Market balance tracking structure for limit validation
 * @dev Used during balance updates and limit checks
 *
 * Storage Layout:
 * - marketId: Maps to protocol-specific market identifiers
 * - balanceInMarket: Standardized 18-decimal balance representation
 *
 * Integration Context:
 * - Used by checkLimits() for validation
 * - Populated during balance updates
 * - Coordinates with balance fuses
 */
struct MarketToCheck {
    /// @notice The unique identifier of the market
    /// @dev Same ID used in fuse contracts and market configurations
    uint256 marketId;
    /// @notice The current balance allocated to this market
    /// @dev Amount represented in 18 decimals for consistent comparison
    uint256 balanceInMarket;
}

/**
 * @notice Aggregated vault state for market limit validation
 * @dev Combines total vault value with per-market positions
 *
 * Components:
 * - Total vault balance for percentage calculations
 * - Array of market positions for limit checking
 *
 * Integration Context:
 * - Used during vault operations
 * - Critical for limit enforcement
 * - Updated on balance changes
 */
struct DataToCheck {
    /// @notice Total value of assets in the Plasma Vault
    /// @dev Amount represented in 18 decimals for consistent comparison
    uint256 totalBalanceInVault;
    /// @notice Array of markets and their current balances to validate
    MarketToCheck[] marketsToCheck;
}

/**
 * @notice Market-specific exposure limit configuration
 * @dev Defines maximum allowed allocation per market
 *
 * Configuration Notes:
 * - Uses fixed-point percentages (1e18 = 100%)
 * - Market ID must match protocol identifiers
 * - Zero marketId is reserved for system control
 *
 * Integration Context:
 * - Set through governance
 * - Used in limit validation
 * - Critical for risk management
 */
struct MarketLimit {
    /// @notice The unique identifier of the market
    /// @dev Must match the marketId used in fuse contracts
    uint256 marketId;
    /// @notice Maximum percentage of total vault assets allowed in this market
    /// @dev Uses fixed-point notation where 1e18 represents 100%
    uint256 limitInPercentage;
}

library AssetDistributionProtectionLib {
    /// @dev Represents 100% in fixed-point notation (1e18)
    uint256 private constant ONE_HUNDRED_PERCENT = 1e18;

    /// @notice Emitted when market limits protection is activated
    event MarketsLimitsActivated();
    /// @notice Emitted when market limits protection is deactivated
    event MarketsLimitsDeactivated();
    /// @notice Emitted when a market's limit is updated
    /// @param marketId The ID of the market whose limit was updated
    /// @param newLimit The new limit value in percentage (1e18 = 100%)
    event MarketLimitUpdated(uint256 marketId, uint256 newLimit);

    /// @notice Thrown when a market's balance exceeds its configured limit
    error MarketLimitExceeded(uint256 marketId, uint256 balanceInMarket, uint256 limit);
    /// @notice Thrown when attempting to set a limit above 100%
    error MarketLimitSetupInPercentageIsTooHigh(uint256 limit);
    /// @notice Thrown when using an invalid market ID (0 is reserved)
    error WrongMarketId(uint256 marketId);

    /**
     * @notice Activates the market exposure protection system
     * @dev Enables limit enforcement through sentinel value
     *
     * Storage Updates:
     * 1. Sets activation flag in slot 0
     * 2. Emits activation event
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance
     * - Affects all subsequent vault operations
     * - Requires prior limit configuration
     *
     * Security Considerations:
     * - Only callable through governance
     * - Critical for risk management activation
     * - Must have limits configured before use
     *
     * @custom:events Emits MarketsLimitsActivated
     * @custom:access Restricted to ATOMIST_ROLE via PlasmaVaultGovernance
     */
    function activateMarketsLimits() internal {
        PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[0] = 1;
        emit MarketsLimitsActivated();
    }

    /**
     * @notice Deactivates the market exposure protection system
     * @dev Disables limit enforcement by clearing sentinel
     *
     * Storage Updates:
     * 1. Clears activation flag in slot 0
     * 2. Emits deactivation event
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance
     * - Emergency risk control feature
     * - Affects all market operations
     *
     * Security Notes:
     * - Only callable through governance
     * - Should be used with caution
     * - Removes all limit protections
     *
     * @custom:events Emits MarketsLimitsDeactivated
     * @custom:access Restricted to ATOMIST_ROLE via PlasmaVaultGovernance
     */
    function deactivateMarketsLimits() internal {
        PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[0] = 0;
        emit MarketsLimitsDeactivated();
    }

    /**
     * @notice Configures exposure limits for multiple markets
     * @dev Sets maximum allowed allocation percentages
     *
     * Limit Configuration:
     * - Percentages use 1e18 as 100%
     * - Each market can have unique limit
     * - Zero marketId is reserved
     * - The sum of limits may exceed 100%
     *
     * Storage Updates:
     * 1. Validates each market config
     * 2. Updates limit mappings
     * 3. Emits update events
     *
     * Error Conditions:
     * - Reverts if marketId is 0
     * - Reverts if limit > 100%
     *
     * @param marketsLimits_ Array of market limit configurations
     * @custom:events Emits MarketLimitUpdated for each update
     * @custom:access Restricted to ATOMIST_ROLE via PlasmaVaultGovernance
     */
    function setupMarketsLimits(MarketLimit[] calldata marketsLimits_) internal {
        uint256 len = marketsLimits_.length;
        for (uint256 i; i < len; ++i) {
            if (marketsLimits_[i].marketId == 0) {
                revert WrongMarketId(marketsLimits_[i].marketId);
            }
            if (marketsLimits_[i].limitInPercentage > ONE_HUNDRED_PERCENT) {
                revert MarketLimitSetupInPercentageIsTooHigh(marketsLimits_[i].limitInPercentage);
            }
            PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[marketsLimits_[i].marketId] = marketsLimits_[i]
                .limitInPercentage;
            emit MarketLimitUpdated(marketsLimits_[i].marketId, marketsLimits_[i].limitInPercentage);
        }
    }

    /**
     * @notice Validates market positions against configured limits
     * @dev Core protection logic for asset distribution
     *
     * Validation Process:
     * 1. Checks system activation
     * 2. Calculates absolute limits
     * 3. Compares current positions
     * 4. Reverts if limits exceeded
     *
     * Integration Context:
     * - Called during vault operations
     * - Critical for risk management
     * - Affects all market interactions
     *
     * Error Handling:
     * - Reverts with MarketLimitExceeded
     * - Includes detailed error data
     * - Prevents limit violations
     *
     * @param data_ Struct containing vault state and positions
     * @custom:security Non-reentrant via PlasmaVault
     */
    function checkLimits(DataToCheck memory data_) internal view {
        if (!isMarketsLimitsActivated()) {
            return;
        }

        uint256 len = data_.marketsToCheck.length;
        uint256 limit;

        for (uint256 i; i < len; ++i) {
            limit = Math.mulDiv(
                PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[data_.marketsToCheck[i].marketId],
                data_.totalBalanceInVault,
                ONE_HUNDRED_PERCENT
            );
            if (limit < data_.marketsToCheck[i].balanceInMarket) {
                revert MarketLimitExceeded(
                    data_.marketsToCheck[i].marketId,
                    data_.marketsToCheck[i].balanceInMarket,
                    limit
                );
            }
        }
    }

    /**
     * @notice Checks activation status of market limits
     * @dev Uses sentinel value in storage slot 0
     *
     * Storage Pattern:
     * - Slot 0 reserved for activation flag
     * - Non-zero value indicates active
     * - Part of protection system state
     *
     * Integration Context:
     * - Used by checkLimits()
     * - Part of protection logic
     * - Critical for system control
     *
     * @return bool True if market limits are enforced
     */
    function isMarketsLimitsActivated() internal view returns (bool) {
        return PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[0] != 0;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {FuseAction} from "../interfaces/IPlasmaVault.sol";
import {PlasmaVaultStorageLib} from "./PlasmaVaultStorageLib.sol";
import {PlasmaVault} from "../vaults/PlasmaVault.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Data structure for callback execution results
/// @param asset The token address that needs approval
/// @param addressToApprove The address to approve token spending
/// @param amountToApprove The amount of tokens to approve
/// @param actionData Encoded FuseAction array to execute after callback
struct CallbackData {
    address asset;
    address addressToApprove;
    uint256 amountToApprove;
    bytes actionData;
}

/// @title Callback Handler Library for Plasma Vault
/// @notice Manages callback execution and handler registration for the Plasma Vault system
/// @dev This library is used during Fuse execution to handle callbacks from external protocols
library CallbackHandlerLib {
    using Address for address;
    using SafeERC20 for ERC20;

    /// @notice Emitted when a callback handler is updated
    /// @param handler The address of the new callback handler
    /// @param sender The address that will trigger the callback
    /// @param sig The function signature that will trigger the callback
    event CallbackHandlerUpdated(address indexed handler, address indexed sender, bytes4 indexed sig);

    /// @notice Thrown when no handler is found for a callback
    error HandlerNotFound();

    /**
     * @notice Handles callbacks during Fuse execution in the Plasma Vault system
     * @dev Manages the execution flow of protocol callbacks during Fuse operations
     * - Can only be called during PlasmaVault.execute()
     * - Requires PlasmaVaultLib.isExecutionStarted() to be true
     * - Uses delegatecall for handler execution
     *
     * Execution Flow:
     * 1. Retrieves handler based on msg.sender and msg.sig hash
     * 2. Executes handler via delegatecall with original msg.data
     * 3. Processes handler return data if present:
     *    - Decodes as CallbackData struct
     *    - Executes additional FuseActions
     *    - Sets token approvals
     *
     * Integration Context:
     * - Called by PlasmaVault's fallback function
     * - Part of protocol integration system
     * - Enables complex multi-step operations
     * - Supports protocol-specific callbacks:
     *   - Compound supply/borrow callbacks
     *   - Aave flashloan callbacks
     *   - Other protocol-specific operations
     *
     * Error Conditions:
     * - Reverts with HandlerNotFound if no handler registered
     * - Bubbles up handler execution errors
     * - Validates handler return data format
     *
     * Security Considerations:
     * - Only executable during Fuse operations
     * - Handler must be pre-registered
     * - Uses safe delegatecall pattern
     * - Critical for protocol integration security
     *
     * Gas Considerations:
     * - Single storage read for handler lookup
     * - Dynamic gas cost based on handler logic
     * - Additional gas for FuseAction execution
     * - Token approval costs if required
     */
    function handleCallback() internal {
        /// @dev msg.sender - is the address of a contract which execute callback, msg.sig - is the signature of the function
        address handler = PlasmaVaultStorageLib.getCallbackHandler().callbackHandler[
            keccak256(abi.encodePacked(msg.sender, msg.sig))
        ];

        if (handler == address(0)) {
            revert HandlerNotFound();
        }

        bytes memory data = handler.functionCall(msg.data);

        if (data.length == 0) {
            return;
        }

        CallbackData memory calls = abi.decode(data, (CallbackData));

        PlasmaVault(address(this)).executeInternal(abi.decode(calls.actionData, (FuseAction[])));

        ERC20(calls.asset).forceApprove(calls.addressToApprove, calls.amountToApprove);
    }

    /**
     * @notice Updates or registers a callback handler in the Plasma Vault system
     * @dev Manages the registration and update of protocol-specific callback handlers
     * - Only callable through PlasmaVaultGovernance by ATOMIST_ROLE
     * - Updates PlasmaVaultStorageLib.CallbackHandler mapping
     * - Critical for protocol integration configuration
     *
     * Storage Updates:
     * 1. Maps handler to combination of sender and function signature
     * 2. Overwrites existing handler if present
     * 3. Emits CallbackHandlerUpdated event
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance.updateCallbackHandler()
     * - Part of protocol integration setup
     * - Used during vault configuration
     * - Supports protocol-specific handlers:
     *   - Compound callback handlers
     *   - Aave callback handlers
     *   - Other protocol-specific handlers
     *
     * Handler Requirements:
     * - Must implement standardized return format (CallbackData)
     * - Should handle protocol-specific callback logic
     * - Must maintain vault security invariants
     * - Should be stateless and reentrant-safe
     *
     * Security Considerations:
     * - Access restricted to ATOMIST_ROLE
     * - Handler address must be validated
     * - Critical for callback security
     * - Affects vault's protocol integration security
     * - Must verify handler compatibility
     *
     * Use Cases:
     * - Initial protocol integration setup
     * - Handler upgrades and maintenance
     * - Protocol version migrations
     * - Security patches
     *
     * @param handler_ The address of the callback handler contract
     * @param sender_ The address of the protocol contract that triggers callbacks
     * @param sig_ The function signature that identifies the callback
     * @custom:events Emits CallbackHandlerUpdated when successful
     *
     * Gas Considerations:
     * - One SSTORE for mapping update
     * - Event emission cost
     */
    function updateCallbackHandler(address handler_, address sender_, bytes4 sig_) internal {
        PlasmaVaultStorageLib.getCallbackHandler().callbackHandler[
            keccak256(abi.encodePacked(sender_, sig_))
        ] = handler_;
        emit CallbackHandlerUpdated(handler_, sender_, sig_);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Fuses storage library responsible for managing storage fuses in the Plasma Vault
library FuseStorageLib {
    /**
     * @dev Storage slot for managing supported fuses in the Plasma Vault
     * @notice Maps fuse addresses to their index in the fuses array for tracking supported fuses
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgFuses")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks which fuses are supported by the vault
     * - Enables efficient fuse validation
     * - Maps fuse addresses to their array indices
     * - Core component of fuse management system
     *
     * Storage Layout:
     * - Points to Fuses struct containing:
     *   - value: mapping(address fuse => uint256 index)
     *     - Zero index indicates unsupported fuse
     *     - Non-zero index (index + 1) indicates supported fuse
     *
     * Usage Pattern:
     * - Checked during fuse operations via isFuseSupported()
     * - Updated when adding/removing fuses
     * - Used for fuse validation in vault operations
     * - Maintains synchronization with fuses array
     *
     * Integration Points:
     * - FusesLib.isFuseSupported: Validates fuse status
     * - FusesLib.addFuse: Updates supported fuses
     * - FusesLib.removeFuse: Removes fuse support
     * - PlasmaVault: References for operation validation
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Critical for controlling vault integrations
     * - Must maintain consistency with fuses array
     * - Key component of vault security
     */
    bytes32 private constant CFG_FUSES = 0x48932b860eb451ad240d4fe2b46522e5a0ac079d201fe50d4e0be078c75b5400;

    /**
     * @dev Storage slot for storing the array of supported fuses in the Plasma Vault
     * @notice Maintains ordered list of all supported fuse addresses
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgFusesArray")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Stores complete list of supported fuses
     * - Enables iteration over all supported fuses
     * - Maintains order of fuse addition
     * - Provides efficient fuse removal mechanism
     *
     * Storage Layout:
     * - Points to FusesArray struct containing:
     *   - value: address[] array of fuse addresses
     *     - Each element is a supported fuse contract address
     *     - Array index corresponds to (mapping index - 1) in CFG_FUSES
     *
     * Usage Pattern:
     * - Referenced when listing all supported fuses
     * - Updated during fuse addition/removal
     * - Used for fuse enumeration
     * - Maintains parallel structure with CFG_FUSES mapping
     *
     * Integration Points:
     * - FusesLib.getFusesArray: Retrieves complete fuse list
     * - FusesLib.addFuse: Appends new fuses
     * - FusesLib.removeFuse: Manages array updates
     * - Governance: References for fuse management
     *
     * Security Considerations:
     * - Must stay synchronized with CFG_FUSES mapping
     * - Array operations must handle index updates correctly
     * - Critical for fuse system integrity
     * - Requires careful management during removals
     */
    bytes32 private constant CFG_FUSES_ARRAY = 0xad43e358bd6e59a5a0c80f6bf25fa771408af4d80f621cdc680c8dfbf607ab00;

    /**
     * @dev Storage slot for managing Uniswap V3 NFT position token IDs in the Plasma Vault
     * @notice Tracks and manages Uniswap V3 LP positions held by the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.UniswapV3TokenIds")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks all Uniswap V3 NFT positions owned by the vault
     * - Enables efficient position management and lookup
     * - Supports liquidity provision operations
     * - Facilitates position value calculations
     *
     * Storage Layout:
     * - Points to UniswapV3TokenIds struct containing:
     *   - tokenIds: uint256[] array of Uniswap V3 NFT position IDs
     *   - indexes: mapping(uint256 tokenId => uint256 index) for position lookup
     *     - Maps each token ID to its index in the tokenIds array
     *     - Zero index indicates non-existent position
     *
     * Usage Pattern:
     * - Updated when creating new Uniswap V3 positions
     * - Referenced during position management
     * - Used for position value calculations
     * - Maintains efficient position tracking
     *
     * Integration Points:
     * - UniswapV3NewPositionFuse: Position creation and management
     * - PositionValue: NFT position valuation
     * - Balance calculation systems
     * - Withdrawal and rebalancing operations
     *
     * Security Considerations:
     * - Must accurately track all vault positions
     * - Critical for proper liquidity management
     * - Requires careful index management
     * - Essential for position ownership verification
     */
    bytes32 private constant UNISWAP_V3_TOKEN_IDS = 0x3651659bd419f7c37743f3e14a337c9f9d1cfc4d650d91508f44d1acbe960f00;

    /**
     * @dev Storage slot for managing Ramses V2 NFT position token IDs in the Plasma Vault
     * @notice Tracks and manages Ramses V2 LP positions held by the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.RamsesV2TokenIds")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks all Ramses V2 NFT positions owned by the vault
     * - Enables efficient position management and lookup
     * - Supports concentrated liquidity position tracking
     * - Mirrors Uniswap V3-style position management for Arbitrum
     *
     * Storage Layout:
     * - Points to RamsesV2TokenIds struct containing:
     *   - tokenIds: uint256[] array of Ramses V2 NFT position IDs
     *   - indexes: mapping(uint256 tokenId => uint256 index) for position lookup
     *     - Maps each token ID to its index in the tokenIds array
     *     - Zero index indicates non-existent position
     *
     * Usage Pattern:
     * - Updated when creating new Ramses V2 positions
     * - Referenced during position management
     * - Used for position value calculations
     * - Maintains efficient position tracking on Arbitrum
     *
     * Integration Points:
     * - Ramses V2 position management fuses
     * - Position value calculation systems
     * - Balance tracking mechanisms
     * - Arbitrum-specific liquidity operations
     *
     * Security Considerations:
     * - Must accurately track all vault positions
     * - Critical for Arbitrum liquidity management
     * - Requires careful index management
     * - Essential for position ownership verification
     * - Parallel structure to Uniswap V3 position tracking
     */
    bytes32 private constant RAMSES_V2_TOKEN_IDS = 0x1a3831a406f27d4d5d820158b29ce95a1e8e840bf416921917aa388e2461b700;

    /// @custom:storage-location erc7201:io.ipor.CfgFuses
    struct Fuses {
        /// @dev fuse address => If index = 0 - is not granted, otherwise - granted
        mapping(address fuse => uint256 index) value;
    }

    /// @custom:storage-location erc7201:io.ipor.CfgFusesArray
    struct FusesArray {
        /// @dev value is a fuse address
        address[] value;
    }

    /// @custom:storage-location erc7201:io.ipor.UniswapV3TokenIds
    struct UniswapV3TokenIds {
        uint256[] tokenIds;
        mapping(uint256 tokenId => uint256 index) indexes;
    }

    /// @custom:storage-location erc7201:io.ipor.RamsesV2TokenIds
    struct RamsesV2TokenIds {
        uint256[] tokenIds;
        mapping(uint256 tokenId => uint256 index) indexes;
    }

    /// @notice Gets the fuses storage pointer
    function getFuses() internal pure returns (Fuses storage fuses) {
        assembly {
            fuses.slot := CFG_FUSES
        }
    }

    /// @notice Gets the fuses array storage pointer
    function getFusesArray() internal pure returns (FusesArray storage fusesArray) {
        assembly {
            fusesArray.slot := CFG_FUSES_ARRAY
        }
    }

    /// @notice Gets the UniswapV3TokenIds storage pointer
    function getUniswapV3TokenIds() internal pure returns (UniswapV3TokenIds storage uniswapV3TokenIds) {
        assembly {
            uniswapV3TokenIds.slot := UNISWAP_V3_TOKEN_IDS
        }
    }
    /// @notice Gets the UniswapV3TokenIds storage pointer
    function getRamsesV2TokenIds() internal pure returns (RamsesV2TokenIds storage ramsesV2TokenIds) {
        assembly {
            ramsesV2TokenIds.slot := RAMSES_V2_TOKEN_IDS
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IFuseCommon} from "../fuses/IFuseCommon.sol";
import {FuseStorageLib} from "./FuseStorageLib.sol";
import {PlasmaVaultStorageLib} from "./PlasmaVaultStorageLib.sol";
/**
 * @title Fuses Library - Core Component for Plasma Vault's Fuse Management System
 * @notice Library managing the lifecycle and configuration of fuses - specialized contracts that enable
 * the Plasma Vault to interact with external DeFi protocols
 * @dev This library is a critical component that:
 * 1. Manages the addition and removal of fuses to the vault system
 * 2. Handles balance fuse associations with specific markets
 * 3. Provides validation and access functions for fuse operations
 * 4. Maintains the integrity of fuse-market relationships
 *
 * Key Components:
 * - Fuse Management: Adding/removing supported fuses
 * - Balance Fuse Control: Market-specific balance tracking
 * - Validation Functions: Fuse support verification
 * - Storage Integration: Uses FuseStorageLib for persistent storage
 *
 * Integration Points:
 * - Used by PlasmaVault.execute() to validate fuse operations
 * - Used by PlasmaVaultGovernance.sol for fuse configuration
 * - Interacts with FuseStorageLib for storage management
 * - Coordinates with PlasmaVaultStorageLib for market data
 *
 * Security Considerations:
 * - Enforces strict validation of fuse addresses
 * - Prevents duplicate fuse registrations
 * - Ensures proper market-fuse relationships
 * - Manages balance fuse removal conditions
 * - Critical for vault's protocol integration security
 *
 * @custom:security-contact security@ipor.io
 */
library FusesLib {
    using Address for address;

    event FuseAdded(address fuse);
    event FuseRemoved(address fuse);
    event BalanceFuseAdded(uint256 marketId, address fuse);
    event BalanceFuseRemoved(uint256 marketId, address fuse);

    error FuseAlreadyExists();
    error FuseDoesNotExist();
    error FuseUnsupported(address fuse);
    error BalanceFuseAlreadyExists(uint256 marketId, address fuse);
    error BalanceFuseDoesNotExist(uint256 marketId, address fuse);
    error BalanceFuseNotReadyToRemove(uint256 marketId, address fuse, uint256 currentBalance);
    error BalanceFuseMarketIdMismatch(uint256 marketId, address fuse);
    /**
     * @notice Validates if a fuse contract is registered and supported by the Plasma Vault
     * @dev Checks the FuseStorageLib mapping to verify fuse registration status
     * - A non-zero value in the mapping indicates the fuse is supported
     * - The value represents (index + 1) in the fusesArray
     * - Used by PlasmaVault.execute() to validate fuse operations
     * - Critical for security as it prevents unauthorized protocol integrations
     *
     * Integration Context:
     * - Called before any fuse operation in PlasmaVault.execute()
     * - Used by PlasmaVaultGovernance for fuse management
     * - Part of the vault's protocol integration security layer
     *
     * @param fuse_ The address of the fuse contract to check
     * @return bool Returns true if the fuse is supported, false otherwise
     *
     * Security Notes:
     * - Zero address returns false
     * - Only fuses added through governance can return true
     * - Non-existent fuses return false
     */
    function isFuseSupported(address fuse_) internal view returns (bool) {
        return FuseStorageLib.getFuses().value[fuse_] != 0;
    }

    /**
     * @notice Validates if a fuse is configured as the balance fuse for a specific market
     * @dev Checks the PlasmaVaultStorageLib mapping to verify balance fuse assignment
     * - Each market can have only one balance fuse at a time
     * - Balance fuses are responsible for tracking market-specific asset balances
     * - Used for market balance validation and updates
     *
     * Integration Context:
     * - Used during market balance updates in PlasmaVault._updateMarketsBalances()
     * - Referenced during balance fuse configuration in PlasmaVaultGovernance
     * - Critical for asset distribution protection system
     *
     * Market Balance System:
     * - Balance fuses track protocol-specific positions (e.g., Compound, Aave positions)
     * - Provides standardized balance reporting across different protocols
     * - Essential for maintaining accurate vault accounting
     *
     * @param marketId_ The unique identifier of the market to check
     * @param fuse_ The address of the balance fuse contract to verify
     * @return bool Returns true if the fuse is the designated balance fuse for the market
     *
     * Security Notes:
     * - Returns false for non-existent market-fuse pairs
     * - Only one balance fuse can be active per market
     * - Critical for preventing unauthorized balance reporting
     */
    function isBalanceFuseSupported(uint256 marketId_, address fuse_) internal view returns (bool) {
        return PlasmaVaultStorageLib.getBalanceFuses().fuseAddresses[marketId_] == fuse_;
    }

    /**
     * @notice Retrieves the designated balance fuse contract address for a specific market
     * @dev Provides direct access to the balance fuse mapping in PlasmaVaultStorageLib
     * - Returns zero address if no balance fuse is configured for the market
     * - Each market can have only one active balance fuse at a time
     *
     * Integration Context:
     * - Used by PlasmaVault._updateMarketsBalances() for balance tracking
     * - Called during market balance validation and updates
     * - Referenced by AssetDistributionProtectionLib for limit checks
     *
     * Use Cases:
     * - Balance calculation during vault operations
     * - Market position valuation
     * - Asset distribution protection checks
     * - Protocol-specific balance queries
     *
     * @param marketId_ The unique identifier of the market
     * @return address The address of the balance fuse contract for the market
     *         Returns address(0) if no balance fuse is configured
     *
     * Related Components:
     * - CompoundV3BalanceFuse
     * - AaveV3BalanceFuse
     * - Other protocol-specific balance fuses
     */
    function getBalanceFuse(uint256 marketId_) internal view returns (address) {
        return PlasmaVaultStorageLib.getBalanceFuses().fuseAddresses[marketId_];
    }

    /**
     * @notice Retrieves the complete array of supported fuse contracts in the Plasma Vault
     * @dev Provides direct access to the fuses array from FuseStorageLib
     * - Array maintains order of fuse addition
     * - Used for fuse enumeration and management
     * - Critical for vault configuration and auditing
     *
     * Storage Pattern:
     * - Array indices correspond to (mapping value - 1) in FuseStorageLib.Fuses
     * - Maintains parallel structure with fuse mapping
     * - No duplicates allowed
     *
     * Integration Context:
     * - Used by PlasmaVaultGovernance for fuse management
     * - Referenced during vault configuration
     * - Used for fuse system auditing and verification
     * - Supports protocol integration management
     *
     * Use Cases:
     * - Fuse system configuration validation
     * - Protocol integration auditing
     * - Governance operations
     * - System state inspection
     *
     * @return address[] Array of all supported fuse contract addresses
     *
     * Related Functions:
     * - addFuse(): Appends to this array
     * - removeFuse(): Maintains array ordering
     * - getFuseArrayIndex(): Maps addresses to indices
     */
    function getFusesArray() internal view returns (address[] memory) {
        return FuseStorageLib.getFusesArray().value;
    }

    /**
     * @notice Retrieves the storage index for a given fuse contract
     * @dev Maps fuse addresses to their position in the fuses array
     * - Returns the value from FuseStorageLib.Fuses mapping
     * - Return value is (array index + 1) to distinguish from unsupported fuses
     * - Zero return value indicates fuse is not supported
     *
     * Storage Pattern:
     * - Mapping value = array index + 1
     * - Example: value 1 means index 0 in fusesArray
     * - Zero value means fuse not supported
     *
     * Integration Context:
     * - Used during fuse removal operations
     * - Supports array maintenance in removeFuse()
     * - Helps maintain storage consistency
     *
     * Use Cases:
     * - Fuse removal operations
     * - Storage validation
     * - Fuse support verification
     * - Array index lookups
     *
     * @param fuse_ The address of the fuse contract to look up
     * @return uint256 The storage index value (array index + 1) of the fuse
     *         Returns 0 if fuse is not supported
     *
     * Related Functions:
     * - addFuse(): Sets this index
     * - removeFuse(): Uses this for array maintenance
     * - getFusesArray(): Contains fuses at these indices
     */
    function getFuseArrayIndex(address fuse_) internal view returns (uint256) {
        return FuseStorageLib.getFuses().value[fuse_];
    }

    /**
     * @notice Registers a new fuse contract in the Plasma Vault's supported fuses list
     * @dev Manages the addition of fuses to both mapping and array storage
     * - Updates FuseStorageLib.Fuses mapping
     * - Appends to FuseStorageLib.FusesArray
     * - Maintains storage consistency between mapping and array
     *
     * Storage Updates:
     * 1. Checks for existing fuse to prevent duplicates
     * 2. Assigns new index (length + 1) in mapping
     * 3. Appends fuse address to array
     * 4. Emits FuseAdded event
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance.addFuses()
     * - Part of vault's protocol integration system
     * - Used during initial vault setup and protocol expansion
     *
     * Error Conditions:
     * - Reverts with FuseAlreadyExists if fuse is already registered
     * - Zero address handling done at governance level
     *
     * @param fuse_ The address of the fuse contract to add
     * @custom:events Emits FuseAdded when successful
     *
     * Security Considerations:
     * - Only callable through governance
     * - Critical for protocol integration security
     * - Must maintain storage consistency
     * - Affects vault's supported protocol list
     *
     * Gas Considerations:
     * - One SSTORE for mapping update
     * - One SSTORE for array push
     * - Event emission
     */
    function addFuse(address fuse_) internal {
        FuseStorageLib.Fuses storage fuses = FuseStorageLib.getFuses();

        uint256 keyIndexValue = fuses.value[fuse_];

        if (keyIndexValue != 0) {
            revert FuseAlreadyExists();
        }

        uint256 newLastFuseId = FuseStorageLib.getFusesArray().value.length + 1;

        /// @dev for balance fuses, value is a index + 1 in the fusesArray
        fuses.value[fuse_] = newLastFuseId;

        FuseStorageLib.getFusesArray().value.push(fuse_);

        emit FuseAdded(fuse_);
    }

    /**
     * @notice Removes a fuse contract from the Plasma Vault's supported fuses list
     * @dev Manages removal while maintaining storage consistency using swap-and-pop pattern
     * - Updates both FuseStorageLib.Fuses mapping and FusesArray
     * - Uses efficient swap-and-pop for array maintenance
     *
     * Storage Updates:
     * 1. Verifies fuse exists and gets its index
     * 2. Moves last array element to removed fuse's position
     * 3. Updates mapping for moved element
     * 4. Clears removed fuse's mapping entry
     * 5. Pops last array element
     * 6. Emits FuseRemoved event
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance.removeFuses()
     * - Part of protocol integration management
     * - Used during vault maintenance and protocol removal
     *
     * Error Conditions:
     * - Reverts with FuseDoesNotExist if fuse not found
     * - Zero address handling done at governance level
     *
     * @param fuse_ The address of the fuse contract to remove
     * @custom:events Emits FuseRemoved when successful
     *
     * Security Considerations:
     * - Only callable through governance
     * - Must maintain mapping-array consistency
     * - Critical for protocol integration security
     * - Affects vault's supported protocol list
     *
     * Gas Optimization:
     * - Uses swap-and-pop instead of shifting array
     * - Minimizes storage operations
     * - Three SSTORE operations:
     *   1. Update moved element's mapping
     *   2. Clear removed fuse's mapping
     *   3. Pop array
     */
    function removeFuse(address fuse_) internal {
        FuseStorageLib.Fuses storage fuses = FuseStorageLib.getFuses();

        uint256 indexToRemove = fuses.value[fuse_];

        if (indexToRemove == 0) {
            revert FuseDoesNotExist();
        }

        address lastKeyInArray = FuseStorageLib.getFusesArray().value[FuseStorageLib.getFusesArray().value.length - 1];

        fuses.value[lastKeyInArray] = indexToRemove;

        fuses.value[fuse_] = 0;

        /// @dev balanceFuses mapping contains values as index + 1
        FuseStorageLib.getFusesArray().value[indexToRemove - 1] = lastKeyInArray;

        FuseStorageLib.getFusesArray().value.pop();

        emit FuseRemoved(fuse_);
    }

    /**
     * @notice Associates a balance tracking fuse with a specific market in the Plasma Vault
     * @dev Manages market-specific balance fuse assignments and maintains market tracking data structures
     * - Updates both fuse mapping and market tracking arrays
     * - Maintains O(1) lookup capabilities through index mapping
     *
     * Storage Updates:
     * 1. Validates no duplicate fuse assignment
     * 2. Updates fuseAddresses mapping with new fuse
     * 3. Adds market to tracking array
     * 4. Updates index mapping for O(1) lookup
     * 5. Emits BalanceFuseAdded event
     *
     * Storage Pattern:
     * - balanceFuses.indexes[marketId_] stores (array index + 1)
     * - Example: value 1 means index 0 in marketIds array
     * - Matches pattern used in FuseStorageLib.Fuses mapping
     * - Allows distinguishing between non-existent (0) and first position (1)
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance.addBalanceFuse()
     * - Part of market setup and configuration
     * - Integrates with PlasmaVaultStorageLib.BalanceFuses
     * - Supports multi-market balance tracking system
     *
     * Market Tracking:
     * - Maintains ordered list of active markets
     * - Enables efficient market iteration
     * - Supports O(1) market existence checks
     * - Critical for balance update operations
     *
     * Error Conditions:
     * - Reverts with BalanceFuseAlreadyExists if:
     *   - Market already has this balance fuse
     *   - Prevents duplicate assignments
     *
     * @param marketId_ The unique identifier of the market
     * @param fuse_ The address of the balance fuse contract
     * @custom:events Emits BalanceFuseAdded when successful
     *
     * Security Considerations:
     * - Only callable through governance
     * - Must maintain array-mapping consistency
     * - Critical for market balance tracking
     * - Affects asset distribution protection
     * - Requires proper fuse validation
     *
     * Integration Points:
     * - PlasmaVault._updateMarketsBalances: Uses registered fuses
     * - AssetDistributionProtectionLib: Market balance checks
     * - Balance Fuses: Protocol-specific balance tracking
     * - Market Operations: Balance validation and updates
     */
    function addBalanceFuse(uint256 marketId_, address fuse_) internal {
        address currentFuse = PlasmaVaultStorageLib.getBalanceFuses().fuseAddresses[marketId_];

        if (currentFuse == fuse_) {
            revert BalanceFuseAlreadyExists(marketId_, fuse_);
        }

        if (marketId_ != IFuseCommon(fuse_).MARKET_ID()) {
            revert BalanceFuseMarketIdMismatch(marketId_, fuse_);
        }

        _updateBalanceFuseStructWhenAdding(marketId_, fuse_);

        emit BalanceFuseAdded(marketId_, fuse_);
    }

    /**
     * @notice Removes a balance tracking fuse from a specific market in the Plasma Vault
     * @dev Manages safe removal of market-fuse associations and updates market tracking data structures
     * - Uses swap-and-pop pattern for efficient array maintenance
     * - Maintains O(1) lookup capabilities through index mapping
     *
     * Storage Updates:
     * 1. Validates correct fuse-market association
     * 2. Verifies balance is below dust threshold via delegatecall
     * 3. Clears fuseAddresses mapping entry
     * 4. Updates marketIds array using swap-and-pop
     * 5. Updates indexes mapping for moved market
     * 6. Emits BalanceFuseRemoved event
     *
     * Storage Pattern:
     * - balanceFuses.indexes[marketId_] stores (array index + 1)
     * - Example: value 1 means index 0 in marketIds array
     * - Matches pattern used in FuseStorageLib.Fuses mapping
     * - Allows distinguishing between non-existent (0) and first position (1)
     *
     * Integration Context:
     * - Called by PlasmaVaultGovernance.removeBalanceFuse()
     * - Part of market decommissioning process
     * - Integrates with PlasmaVaultStorageLib.BalanceFuses
     * - Coordinates with balance fuse contracts
     *
     * Market Tracking:
     * - Maintains integrity of active markets list
     * - Updates market indexes after removal
     * - Preserves O(1) lookup capability
     * - Ensures proper market list maintenance
     *
     * Balance Validation:
     * - Uses delegatecall to check current balance
     * - Compares against dust threshold based on decimals
     * - Prevents removal of active positions
     * - Dust threshold scales with token precision
     *
     * Error Conditions:
     * - Reverts with BalanceFuseDoesNotExist if:
     *   - Fuse not assigned to market
     *   - Wrong fuse-market pair provided
     * - Reverts with BalanceFuseNotReadyToRemove if:
     *   - Balance exceeds dust threshold
     *   - Active positions exist
     *
     * @param marketId_ The unique identifier of the market
     * @param fuse_ The address of the balance fuse contract to remove
     * @custom:events Emits BalanceFuseRemoved when successful
     *
     * Security Considerations:
     * - Only callable through governance
     * - Must maintain array-mapping consistency
     * - Requires safe delegatecall handling
     * - Critical for market decommissioning
     * - Protects against premature removal
     *
     * Integration Points:
     * - PlasmaVault._updateMarketsBalances: Affected by removals
     * - Balance Fuses: Balance validation
     * - Asset Protection: Market tracking updates
     * - Market Operations: State consistency
     *
     * Gas Optimization:
     * - Uses swap-and-pop for array maintenance
     * - Minimizes storage operations
     * - Efficient market list updates
     * - Optimized for minimal gas usage
     */
    function removeBalanceFuse(uint256 marketId_, address fuse_) internal {
        address currentBalanceFuse = PlasmaVaultStorageLib.getBalanceFuses().fuseAddresses[marketId_];

        if (marketId_ != IFuseCommon(fuse_).MARKET_ID()) {
            revert BalanceFuseMarketIdMismatch(marketId_, fuse_);
        }

        if (currentBalanceFuse != fuse_) {
            revert BalanceFuseDoesNotExist(marketId_, fuse_);
        }

        uint256 wadBalanceAmountInUSD = abi.decode(
            currentBalanceFuse.functionDelegateCall(abi.encodeWithSignature("balanceOf()")),
            (uint256)
        );

        if (wadBalanceAmountInUSD > _calculateAllowedDustInBalanceFuse()) {
            revert BalanceFuseNotReadyToRemove(marketId_, fuse_, wadBalanceAmountInUSD);
        }

        _updateBalanceFuseStructWhenRemoving(marketId_);

        emit BalanceFuseRemoved(marketId_, fuse_);
    }

    /**
     * @notice Retrieves the list of all active markets with registered balance fuses
     * @dev Provides direct access to the ordered array of active market IDs from BalanceFuses storage
     * - Returns the complete marketIds array without modifications
     * - Order of markets matches their registration sequence
     *
     * Storage Access:
     * - Reads from PlasmaVaultStorageLib.BalanceFuses.marketIds
     * - No storage modifications
     * - O(1) operation for array access
     * - Returns reference to complete array
     *
     * Integration Context:
     * - Used by PlasmaVault._updateMarketsBalances for iteration
     * - Referenced during multi-market operations
     * - Supports balance update coordination
     * - Essential for market state management
     *
     * Use Cases:
     * - Market balance updates
     * - Asset distribution checks
     * - Market state validation
     * - Protocol-wide operations
     *
     * Array Properties:
     * - Maintained by addBalanceFuse/removeBalanceFuse
     * - No duplicates allowed
     * - Order may change during removals (swap-and-pop)
     * - Empty array possible if no active markets
     *
     * @return uint256[] Array of active market IDs with registered balance fuses
     *
     * Integration Points:
     * - Balance Update System: Market iteration
     * - Asset Protection: Market validation
     * - Governance: Market monitoring
     * - Protocol Operations: State checks
     *
     * Performance Notes:
     * - Constant gas cost for array access
     * - No array copying - returns storage reference
     * - Efficient for bulk market operations
     * - Suitable for view function calls
     */
    function getActiveMarketsInBalanceFuses() internal view returns (uint256[] memory) {
        return PlasmaVaultStorageLib.getBalanceFuses().marketIds;
    }

    function _calculateAllowedDustInBalanceFuse() private view returns (uint256) {
        return 10 ** (PlasmaVaultStorageLib.getERC4626Storage().underlyingDecimals / 2);
    }

    function _updateBalanceFuseStructWhenAdding(uint256 marketId_, address fuse_) private {
        PlasmaVaultStorageLib.BalanceFuses storage balanceFuses = PlasmaVaultStorageLib.getBalanceFuses();

        uint256 newMarketIdIndexValue = balanceFuses.marketIds.length + 1;

        balanceFuses.fuseAddresses[marketId_] = fuse_;
        balanceFuses.marketIds.push(marketId_);
        balanceFuses.indexes[marketId_] = newMarketIdIndexValue;
    }
    function _updateBalanceFuseStructWhenRemoving(uint256 marketId_) private {
        PlasmaVaultStorageLib.BalanceFuses storage balanceFuses = PlasmaVaultStorageLib.getBalanceFuses();

        delete balanceFuses.fuseAddresses[marketId_];

        uint256 indexValue = balanceFuses.indexes[marketId_];
        uint256 marketIdsLength = balanceFuses.marketIds.length;

        if (indexValue != marketIdsLength) {
            balanceFuses.marketIds[indexValue - 1] = balanceFuses.marketIds[marketIdsLength - 1];
            balanceFuses.indexes[balanceFuses.marketIds[marketIdsLength - 1]] = indexValue;
        }
        balanceFuses.marketIds.pop();

        delete balanceFuses.indexes[marketId_];
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {PlasmaVaultStorageLib} from "./PlasmaVaultStorageLib.sol";

/// @title Plasma Vault Configuration Library responsible for managing the configuration of the Plasma Vault
library PlasmaVaultConfigLib {
    event MarketSubstratesGranted(uint256 marketId, bytes32[] substrates);

    /// @notice Checks if a given asset address is granted as a substrate for a specific market
    /// @dev This function is part of the Plasma Vault's substrate management system that controls which assets can be used in specific markets
    ///
    /// @param marketId_ The ID of the market to check
    /// @param substrateAsAsset The address of the asset to verify as a substrate
    /// @return bool True if the asset is granted as a substrate for the market, false otherwise
    ///
    /// @custom:security-notes
    /// - Substrates are stored internally as bytes32 values
    /// - Asset addresses are converted to bytes32 for storage efficiency
    /// - Part of the vault's asset distribution protection system
    ///
    /// @custom:context The function is used in conjunction with:
    /// - PlasmaVault's execute() function for validating market operations
    /// - PlasmaVaultGovernance's grantMarketSubstrates() for configuration
    /// - Asset distribution protection system for market limit enforcement
    ///
    /// @custom:example
    /// ```solidity
    /// // Check if USDC is granted for market 1
    /// bool isGranted = isSubstrateAsAssetGranted(1, USDC_ADDRESS);
    /// ```
    ///
    /// @custom:permissions
    /// - View function, no special permissions required
    /// - Substrate grants are managed by ATOMIST_ROLE through PlasmaVaultGovernance
    ///
    /// @custom:related-functions
    /// - grantMarketSubstrates(): For granting substrates to markets
    /// - isMarketSubstrateGranted(): For checking non-asset substrates
    /// - getMarketSubstrates(): For retrieving all granted substrates
    function isSubstrateAsAssetGranted(uint256 marketId_, address substrateAsAsset) internal view returns (bool) {
        PlasmaVaultStorageLib.MarketSubstratesStruct storage marketSubstrates = _getMarketSubstrates(marketId_);
        return marketSubstrates.substrateAllowances[addressToBytes32(substrateAsAsset)] == 1;
    }

    /// @notice Validates if a substrate is granted for a specific market
    /// @dev Part of the Plasma Vault's substrate management system that enables flexible market configurations
    ///
    /// @param marketId_ The ID of the market to check
    /// @param substrate_ The bytes32 identifier of the substrate to verify
    /// @return bool True if the substrate is granted for the market, false otherwise
    ///
    /// @custom:security-notes
    /// - Substrates are stored and compared as raw bytes32 values
    /// - Used for both asset and non-asset substrates (e.g., vaults, parameters)
    /// - Critical for market access control and security
    ///
    /// @custom:context The function is used for:
    /// - Validating market operations in PlasmaVault.execute()
    /// - Checking substrate permissions before market interactions
    /// - Supporting various substrate types:
    ///   * Asset addresses (converted to bytes32)
    ///   * Protocol-specific vault identifiers
    ///   * Market parameters and configuration values
    ///
    /// @custom:example
    /// ```solidity
    /// // Check if a compound vault substrate is granted
    /// bytes32 vaultId = keccak256(abi.encode("compound-vault-1"));
    /// bool isGranted = isMarketSubstrateGranted(1, vaultId);
    ///
    /// // Check if a market parameter is granted
    /// bytes32 param = bytes32("max-leverage");
    /// bool isParamGranted = isMarketSubstrateGranted(1, param);
    /// ```
    ///
    /// @custom:permissions
    /// - View function, no special permissions required
    /// - Substrate grants are managed by ATOMIST_ROLE through PlasmaVaultGovernance
    ///
    /// @custom:related-functions
    /// - isSubstrateAsAssetGranted(): For checking asset-specific substrates
    /// - grantMarketSubstrates(): For granting substrates to markets
    /// - getMarketSubstrates(): For retrieving all granted substrates
    function isMarketSubstrateGranted(uint256 marketId_, bytes32 substrate_) internal view returns (bool) {
        PlasmaVaultStorageLib.MarketSubstratesStruct storage marketSubstrates = _getMarketSubstrates(marketId_);
        return marketSubstrates.substrateAllowances[substrate_] == 1;
    }

    /// @notice Retrieves all granted substrates for a specific market
    /// @dev Part of the Plasma Vault's substrate management system that provides visibility into market configurations
    ///
    /// @param marketId_ The ID of the market to query
    /// @return bytes32[] Array of all granted substrate identifiers for the market
    ///
    /// @custom:security-notes
    /// - Returns raw bytes32 values that may represent different substrate types
    /// - Order of substrates in array is preserved from grant operations
    /// - Empty array indicates no substrates are granted
    ///
    /// @custom:context The function is used for:
    /// - Auditing market configurations
    /// - Validating substrate grants during governance operations
    /// - Supporting UI/external systems that need market configuration data
    /// - Debugging and monitoring market setups
    ///
    /// @custom:substrate-types The returned array may contain:
    /// - Asset addresses (converted to bytes32)
    /// - Protocol-specific vault identifiers
    /// - Market parameters and configuration values
    /// - Any other substrate type granted to the market
    ///
    /// @custom:example
    /// ```solidity
    /// // Get all substrates for market 1
    /// bytes32[] memory substrates = getMarketSubstrates(1);
    ///
    /// // Process different substrate types
    /// for (uint256 i = 0; i < substrates.length; i++) {
    ///     if (isSubstrateAsAssetGranted(1, bytes32ToAddress(substrates[i]))) {
    ///         // Handle asset substrate
    ///     } else {
    ///         // Handle other substrate type
    ///     }
    /// }
    /// ```
    ///
    /// @custom:permissions
    /// - View function, no special permissions required
    /// - Useful for both governance and user interfaces
    ///
    /// @custom:related-functions
    /// - isMarketSubstrateGranted(): For checking individual substrate grants
    /// - grantMarketSubstrates(): For modifying substrate grants
    /// - bytes32ToAddress(): For converting asset substrates back to addresses
    function getMarketSubstrates(uint256 marketId_) internal view returns (bytes32[] memory) {
        return _getMarketSubstrates(marketId_).substrates;
    }

    /// @notice Grants or updates substrate permissions for a specific market
    /// @dev Core function for managing market substrate configurations in the Plasma Vault system
    ///
    /// @param marketId_ The ID of the market to configure
    /// @param substrates_ Array of substrate identifiers to grant to the market
    ///
    /// @custom:security-notes
    /// - Revokes all existing substrate grants before applying new ones
    /// - Atomic operation - either all substrates are granted or none
    /// - Emits MarketSubstratesGranted event for tracking changes
    /// - Critical for market security and access control
    ///
    /// @custom:context The function is used for:
    /// - Initial market setup by governance
    /// - Updating market configurations
    /// - Managing protocol integrations
    /// - Controlling asset access per market
    ///
    /// @custom:substrate-handling
    /// - Accepts both asset and non-asset substrates:
    ///   * Asset addresses (converted to bytes32)
    ///   * Protocol-specific vault identifiers
    ///   * Market parameters
    ///   * Configuration values
    /// - Maintains a list of active substrates
    /// - Updates allowance mapping for each substrate
    ///
    /// @custom:example
    /// ```solidity
    /// // Grant multiple substrates to market 1
    /// bytes32[] memory substrates = new bytes32[](2);
    /// substrates[0] = addressToBytes32(USDC_ADDRESS);
    /// substrates[1] = keccak256(abi.encode("compound-vault-1"));
    /// grantMarketSubstrates(1, substrates);
    /// ```
    ///
    /// @custom:permissions
    /// - Should only be called by authorized governance functions
    /// - Typically restricted to ATOMIST_ROLE
    /// - Critical for vault security
    ///
    /// @custom:related-functions
    /// - isMarketSubstrateGranted(): For checking granted substrates
    /// - getMarketSubstrates(): For viewing current grants
    /// - grantSubstratesAsAssetsToMarket(): For asset-specific grants
    ///
    /// @custom:events
    /// - Emits MarketSubstratesGranted(marketId, substrates)
    function grantMarketSubstrates(uint256 marketId_, bytes32[] memory substrates_) internal {
        PlasmaVaultStorageLib.MarketSubstratesStruct storage marketSubstrates = _getMarketSubstrates(marketId_);

        _revokeMarketSubstrates(marketSubstrates);

        bytes32[] memory list = new bytes32[](substrates_.length);
        for (uint256 i; i < substrates_.length; ++i) {
            marketSubstrates.substrateAllowances[substrates_[i]] = 1;
            list[i] = substrates_[i];
        }

        marketSubstrates.substrates = list;

        emit MarketSubstratesGranted(marketId_, substrates_);
    }

    /// @notice Grants asset-specific substrates to a market
    /// @dev Specialized function for managing asset-type substrates in the Plasma Vault system
    ///
    /// @param marketId_ The ID of the market to configure
    /// @param substratesAsAssets_ Array of asset addresses to grant as substrates
    ///
    /// @custom:security-notes
    /// - Revokes all existing substrate grants before applying new ones
    /// - Converts addresses to bytes32 for storage efficiency
    /// - Atomic operation - either all assets are granted or none
    /// - Emits MarketSubstratesGranted event with converted addresses
    /// - Critical for market asset access control
    ///
    /// @custom:context The function is used for:
    /// - Setting up asset permissions for markets
    /// - Managing DeFi protocol integrations
    /// - Controlling which tokens can be used in specific markets
    /// - Implementing asset-based strategies
    ///
    /// @custom:implementation-details
    /// - Converts each address to bytes32 using addressToBytes32()
    /// - Updates both allowance mapping and substrate list
    /// - Maintains consistency between address and bytes32 representations
    /// - Ensures proper event emission with converted values
    ///
    /// @custom:example
    /// ```solidity
    /// // Grant USDC and DAI access to market 1
    /// address[] memory assets = new address[](2);
    /// assets[0] = USDC_ADDRESS;
    /// assets[1] = DAI_ADDRESS;
    /// grantSubstratesAsAssetsToMarket(1, assets);
    /// ```
    ///
    /// @custom:permissions
    /// - Should only be called by authorized governance functions
    /// - Typically restricted to ATOMIST_ROLE
    /// - Critical for vault security and asset management
    ///
    /// @custom:related-functions
    /// - grantMarketSubstrates(): For granting general substrates
    /// - isSubstrateAsAssetGranted(): For checking asset grants
    /// - addressToBytes32(): For address conversion
    ///
    /// @custom:events
    /// - Emits MarketSubstratesGranted(marketId, convertedSubstrates)
    function grantSubstratesAsAssetsToMarket(uint256 marketId_, address[] calldata substratesAsAssets_) internal {
        PlasmaVaultStorageLib.MarketSubstratesStruct storage marketSubstrates = _getMarketSubstrates(marketId_);

        _revokeMarketSubstrates(marketSubstrates);

        bytes32[] memory list = new bytes32[](substratesAsAssets_.length);

        for (uint256 i; i < substratesAsAssets_.length; ++i) {
            marketSubstrates.substrateAllowances[addressToBytes32(substratesAsAssets_[i])] = 1;
            list[i] = addressToBytes32(substratesAsAssets_[i]);
        }

        marketSubstrates.substrates = list;

        emit MarketSubstratesGranted(marketId_, list);
    }

    /// @notice Converts an Ethereum address to its bytes32 representation for substrate storage
    /// @dev Core utility function for substrate address handling in the Plasma Vault system
    ///
    /// @param address_ The Ethereum address to convert
    /// @return bytes32 The bytes32 representation of the address
    ///
    /// @custom:security-notes
    /// - Performs unchecked conversion from address to bytes32
    /// - Pads the address (20 bytes) with zeros to fill bytes32 (32 bytes)
    /// - Used for storage efficiency in substrate mappings
    /// - Critical for consistent substrate identifier handling
    ///
    /// @custom:context The function is used for:
    /// - Converting asset addresses for substrate storage
    /// - Maintaining consistent substrate identifier format
    /// - Supporting the substrate allowance system
    /// - Enabling efficient storage and comparison operations
    ///
    /// @custom:implementation-details
    /// - Uses uint160 casting to handle address bytes
    /// - Follows standard Solidity type conversion patterns
    /// - Zero-pads the upper bytes implicitly
    /// - Maintains compatibility with bytes32ToAddress()
    ///
    /// @custom:example
    /// ```solidity
    /// // Convert USDC address to substrate identifier
    /// bytes32 usdcSubstrate = addressToBytes32(USDC_ADDRESS);
    ///
    /// // Use in substrate allowance mapping
    /// marketSubstrates.substrateAllowances[usdcSubstrate] = 1;
    /// ```
    ///
    /// @custom:permissions
    /// - Pure function, no state modifications
    /// - Can be called by any function
    /// - Used internally for substrate management
    ///
    /// @custom:related-functions
    /// - bytes32ToAddress(): Complementary conversion function
    /// - grantSubstratesAsAssetsToMarket(): Uses this for address conversion
    /// - isSubstrateAsAssetGranted(): Uses converted values for comparison
    function addressToBytes32(address address_) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(address_)));
    }

    /// @notice Converts a bytes32 substrate identifier to its corresponding address representation
    /// @dev Core utility function for substrate address handling in the Plasma Vault system
    ///
    /// @param substrate_ The bytes32 substrate identifier to convert
    /// @return address The resulting Ethereum address
    ///
    /// @custom:security-notes
    /// - Performs unchecked conversion from bytes32 to address
    /// - Only the last 20 bytes (160 bits) are used
    /// - Should only be used for known substrate conversions
    /// - Critical for proper asset substrate handling
    ///
    /// @custom:context The function is used for:
    /// - Converting stored substrate identifiers back to asset addresses
    /// - Processing asset-type substrates in market operations
    /// - Interfacing with external protocols using addresses
    /// - Validating asset substrate configurations
    ///
    /// @custom:implementation-details
    /// - Uses uint160 casting to ensure proper address size
    /// - Follows standard Solidity address conversion pattern
    /// - Maintains compatibility with addressToBytes32()
    /// - Zero-pads the upper bytes implicitly
    ///
    /// @custom:example
    /// ```solidity
    /// // Convert a stored substrate back to an asset address
    /// bytes32 storedSubstrate = marketSubstrates.substrates[0];
    /// address assetAddress = bytes32ToAddress(storedSubstrate);
    ///
    /// // Use in asset validation
    /// if (assetAddress == USDC_ADDRESS) {
    ///     // Handle USDC-specific logic
    /// }
    /// ```
    ///
    /// @custom:related-functions
    /// - addressToBytes32(): Complementary conversion function
    /// - isSubstrateAsAssetGranted(): Uses this for address comparison
    /// - getMarketSubstrates(): Returns values that may need conversion
    function bytes32ToAddress(bytes32 substrate_) internal pure returns (address) {
        return address(uint160(uint256(substrate_)));
    }

    /// @notice Gets the market substrates configuration for a specific market
    function _getMarketSubstrates(
        uint256 marketId_
    ) private view returns (PlasmaVaultStorageLib.MarketSubstratesStruct storage) {
        return PlasmaVaultStorageLib.getMarketSubstrates().value[marketId_];
    }

    function _revokeMarketSubstrates(PlasmaVaultStorageLib.MarketSubstratesStruct storage marketSubstrates) private {
        uint256 length = marketSubstrates.substrates.length;
        for (uint256 i; i < length; ++i) {
            marketSubstrates.substrateAllowances[marketSubstrates.substrates[i]] = 0;
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Errors} from "./errors/Errors.sol";
import {PlasmaVaultStorageLib} from "./PlasmaVaultStorageLib.sol";
import {FusesLib} from "./FusesLib.sol";

/// @title InstantWithdrawalFusesParamsStruct
/// @notice A technical struct used to configure instant withdrawal fuses and their parameters in the Plasma Vault system
/// @dev This struct is used primarily in configureInstantWithdrawalFuses function to set up withdrawal paths
struct InstantWithdrawalFusesParamsStruct {
    /// @notice The address of the fuse contract that handles a specific withdrawal path
    /// @dev Must be a valid and supported fuse contract address that implements instant withdrawal logic
    address fuse;
    /// @notice Array of parameters specific to the fuse's withdrawal logic
    /// @dev Parameter structure:
    /// - params[0]: Always represents the withdrawal amount in underlying token decimals (set during withdrawal, not during configuration)
    /// - params[1+]: Additional fuse-specific parameters such as:
    ///   - Asset addresses
    ///   - Market IDs
    ///   - Slippage tolerances
    ///   - Protocol-specific parameters
    /// @dev The same fuse can appear multiple times with different params for different withdrawal paths
    bytes32[] params;
}

/// @title Plasma Vault Library
/// @notice Core library responsible for managing the Plasma Vault's state and operations
/// @dev Provides centralized management of vault operations, fees, configuration and state updates
///
/// Key responsibilities:
/// - Asset management and accounting
/// - Fee configuration and calculations
/// - Market balance tracking and updates
/// - Withdrawal system configuration
/// - Access control and execution state
/// - Price oracle integration
/// - Rewards claim management
library PlasmaVaultLib {
    using SafeCast for uint256;
    using SafeCast for int256;

    /// @dev Hard CAP for the performance fee in percentage - 50%
    uint256 public constant PERFORMANCE_MAX_FEE_IN_PERCENTAGE = 5000;

    /// @dev Hard CAP for the management fee in percentage - 5%
    uint256 public constant MANAGEMENT_MAX_FEE_IN_PERCENTAGE = 500;

    /// @dev The offset for the underlying asset decimals in the Plasma Vault
    uint8 public constant DECIMALS_OFFSET = 2;

    error InvalidPerformanceFee(uint256 feeInPercentage);
    error InvalidManagementFee(uint256 feeInPercentage);

    event InstantWithdrawalFusesConfigured(InstantWithdrawalFusesParamsStruct[] fuses);
    event PriceOracleMiddlewareChanged(address newPriceOracleMiddleware);
    event PerformanceFeeDataConfigured(address feeAccount, uint256 feeInPercentage);
    event ManagementFeeDataConfigured(address feeAccount, uint256 feeInPercentage);
    event RewardsClaimManagerAddressChanged(address newRewardsClaimManagerAddress);
    event DependencyBalanceGraphChanged(uint256 marketId, uint256[] newDependenceGraph);
    event WithdrawManagerChanged(address newWithdrawManager);

    /// @notice Gets the total assets in the vault for all markets
    /// @dev Retrieves the total value of assets across all integrated markets and protocols
    /// @return uint256 The total assets in the vault, represented in decimals of the underlying asset
    ///
    /// This function:
    /// - Returns the raw total of assets without considering:
    ///   - Unrealized management fees
    ///   - Unrealized performance fees
    ///   - Pending rewards
    ///   - Current vault balance
    ///
    /// Used by:
    /// - PlasmaVault.totalAssets() for share price calculations
    /// - Fee calculations and accrual
    /// - Asset distribution checks
    /// - Market limit validations
    ///
    /// @dev Important: This value represents only the tracked assets in markets,
    /// for full vault assets see PlasmaVault._getGrossTotalAssets()
    function getTotalAssetsInAllMarkets() internal view returns (uint256) {
        return PlasmaVaultStorageLib.getTotalAssets().value;
    }

    /// @notice Gets the total assets in the vault for a specific market
    /// @param marketId_ The ID of the market to query
    /// @return uint256 The total assets in the vault for the market, represented in decimals of the underlying asset
    ///
    /// @dev This function provides market-specific asset tracking and is used for:
    /// - Market balance validation
    /// - Asset distribution checks
    /// - Market limit enforcement
    /// - Balance dependency resolution
    ///
    /// Important considerations:
    /// - Returns raw balance without considering fees
    /// - Value is updated by balance fuses during market interactions
    /// - Used in conjunction with market dependency graphs
    /// - Critical for maintaining proper asset distribution across markets
    ///
    /// Integration points:
    /// - Balance Fuses: Update market balances
    /// - Asset Distribution Protection: Check market limits
    /// - Withdrawal System: Verify available assets
    /// - Market Dependencies: Track related market updates
    function getTotalAssetsInMarket(uint256 marketId_) internal view returns (uint256) {
        return PlasmaVaultStorageLib.getMarketTotalAssets().value[marketId_];
    }

    /// @notice Gets the dependency balance graph for a specific market
    /// @param marketId_ The ID of the market to query
    /// @return uint256[] Array of market IDs that depend on the queried market
    ///
    /// @dev The dependency balance graph is critical for maintaining consistent state across related markets:
    /// - Ensures atomic balance updates across dependent markets
    /// - Prevents inconsistent states in interconnected protocols
    /// - Manages complex market relationships
    ///
    /// Use cases:
    /// - Market balance updates
    /// - Withdrawal validations
    /// - Asset rebalancing
    /// - Protocol integrations
    ///
    /// Example dependencies:
    /// - Lending markets depending on underlying asset markets
    /// - LP token markets depending on constituent token markets
    /// - Derivative markets depending on base asset markets
    ///
    /// Important considerations:
    /// - Dependencies are unidirectional (A->B doesn't imply B->A)
    /// - Empty array means no dependencies
    /// - Order of dependencies may matter for some operations
    /// - Used by _checkBalanceFusesDependencies() during balance updates
    function getDependencyBalanceGraph(uint256 marketId_) internal view returns (uint256[] memory) {
        return PlasmaVaultStorageLib.getDependencyBalanceGraph().dependencyGraph[marketId_];
    }

    /// @notice Updates the dependency balance graph for a specific market
    /// @param marketId_ The ID of the market to update
    /// @param newDependenceGraph_ Array of market IDs that should depend on this market
    /// @dev Updates the market dependency relationships and emits an event
    ///
    /// This function:
    /// - Overwrites existing dependencies for the market
    /// - Establishes new dependency relationships
    /// - Triggers event for dependency tracking
    ///
    /// Security considerations:
    /// - Only callable by authorized governance functions
    /// - Critical for maintaining market balance consistency
    /// - Must prevent circular dependencies
    /// - Should validate market existence
    ///
    /// Common update scenarios:
    /// - Adding new market dependencies
    /// - Removing obsolete dependencies
    /// - Modifying existing dependency chains
    /// - Protocol integration changes
    ///
    /// @dev Important: Changes to dependency graph affect:
    /// - Balance update order
    /// - Withdrawal validations
    /// - Market rebalancing operations
    /// - Protocol interaction flows
    function updateDependencyBalanceGraph(uint256 marketId_, uint256[] memory newDependenceGraph_) internal {
        PlasmaVaultStorageLib.getDependencyBalanceGraph().dependencyGraph[marketId_] = newDependenceGraph_;
        emit DependencyBalanceGraphChanged(marketId_, newDependenceGraph_);
    }

    /// @notice Adds or subtracts an amount from the total assets in the Plasma Vault
    /// @param amount_ The signed amount to adjust total assets by, represented in decimals of the underlying asset
    /// @dev Updates the global total assets tracker based on market operations
    ///
    /// Function behavior:
    /// - Positive amount: Increases total assets
    /// - Negative amount: Decreases total assets
    /// - Zero amount: No effect
    ///
    /// Used during:
    /// - Market balance updates
    /// - Fee realizations
    /// - Asset rebalancing
    /// - Withdrawal processing
    ///
    /// Security considerations:
    /// - Handles signed integers safely using SafeCast
    /// - Only called during validated operations
    /// - Must maintain accounting consistency
    /// - Critical for share price calculations
    ///
    /// @dev Important: This function affects:
    /// - Total vault valuation
    /// - Share price calculations
    /// - Fee calculations
    /// - Asset distribution checks
    function addToTotalAssetsInAllMarkets(int256 amount_) internal {
        if (amount_ < 0) {
            PlasmaVaultStorageLib.getTotalAssets().value -= (-amount_).toUint256();
        } else {
            PlasmaVaultStorageLib.getTotalAssets().value += amount_.toUint256();
        }
    }

    /// @notice Updates the total assets in the Plasma Vault for a specific market
    /// @param marketId_ The ID of the market to update
    /// @param newTotalAssetsInUnderlying_ The new total assets value for the market
    /// @return deltaInUnderlying The net change in assets (positive or negative), represented in underlying decimals
    /// @dev Updates market-specific asset tracking and calculates the change in total assets
    ///
    /// Function behavior:
    /// - Stores new total assets for the market
    /// - Calculates delta between old and new values
    /// - Returns signed delta for total asset updates
    ///
    /// Used during:
    /// - Balance fuse updates
    /// - Market rebalancing
    /// - Protocol interactions
    /// - Asset redistribution
    ///
    /// Security considerations:
    /// - Handles asset value transitions safely
    /// - Uses SafeCast for integer conversions
    /// - Must be called within proper market context
    /// - Critical for maintaining accurate balances
    ///
    /// Integration points:
    /// - Called by balance fuses after market operations
    /// - Used in _updateMarketsBalances for batch updates
    /// - Triggers market limit validations
    /// - Affects total asset calculations
    ///
    /// @dev Important: The returned delta is used by:
    /// - addToTotalAssetsInAllMarkets
    /// - Asset distribution protection checks
    /// - Market balance event emissions
    function updateTotalAssetsInMarket(
        uint256 marketId_,
        uint256 newTotalAssetsInUnderlying_
    ) internal returns (int256 deltaInUnderlying) {
        uint256 oldTotalAssetsInUnderlying = PlasmaVaultStorageLib.getMarketTotalAssets().value[marketId_];
        PlasmaVaultStorageLib.getMarketTotalAssets().value[marketId_] = newTotalAssetsInUnderlying_;
        deltaInUnderlying = newTotalAssetsInUnderlying_.toInt256() - oldTotalAssetsInUnderlying.toInt256();
    }

    /// @notice Gets the management fee configuration data
    /// @return managementFeeData The current management fee configuration containing:
    ///         - feeAccount: Address receiving management fees
    ///         - feeInPercentage: Current fee rate (basis points, 1/10000)
    ///         - lastUpdateTimestamp: Last time fees were realized
    /// @dev Retrieves the current management fee settings from storage
    ///
    /// Fee structure:
    /// - Continuous time-based fee on assets under management (AUM)
    /// - Fee percentage limited by MANAGEMENT_MAX_FEE_IN_PERCENTAGE (5%)
    /// - Fees accrue linearly over time
    /// - Realized during vault operations
    ///
    /// Used for:
    /// - Fee calculations in totalAssets()
    /// - Fee realization during operations
    /// - Management fee distribution
    /// - Governance fee adjustments
    ///
    /// Integration points:
    /// - PlasmaVault._realizeManagementFee()
    /// - PlasmaVault.totalAssets()
    /// - FeeManager contract
    /// - Governance configuration
    ///
    /// @dev Important: Management fees:
    /// - Are calculated based on total vault assets
    /// - Affect share price calculations
    /// - Must be realized before major vault operations
    /// - Are distributed to configured fee recipients
    function getManagementFeeData()
        internal
        view
        returns (PlasmaVaultStorageLib.ManagementFeeData memory managementFeeData)
    {
        return PlasmaVaultStorageLib.getManagementFeeData();
    }

    /// @notice Configures the management fee settings for the vault
    /// @param feeAccount_ The address that will receive management fees
    /// @param feeInPercentage_ The management fee rate in basis points (100 = 1%)
    /// @dev Updates fee configuration and emits event
    ///
    /// Parameter requirements:
    /// - feeAccount_: Must be non-zero address. The address of the technical Management Fee Account that will receive the management fee collected by the Plasma Vault and later on distributed to IPOR DAO and recipients by FeeManager
    /// - feeInPercentage_: Must not exceed MANAGEMENT_MAX_FEE_IN_PERCENTAGE (5%)
    ///
    /// Fee account types:
    /// - FeeManager contract: Distributes fees to IPOR DAO and other recipients
    /// - EOA/MultiSig: Receives fees directly without distribution
    /// - Technical account: Temporary fee collection before distribution
    ///
    /// Fee percentage format:
    /// - Uses 2 decimal places (basis points)
    /// - Examples:
    ///   - 10000 = 100%
    ///   - 100 = 1%
    ///   - 1 = 0.01%
    ///
    /// Security considerations:
    /// - Only callable by authorized governance functions
    /// - Validates fee percentage against maximum limit
    /// - Emits event for tracking changes
    /// - Critical for vault economics
    ///
    /// @dev Important: Changes affect:
    /// - Future fee calculations
    /// - Share price computations
    /// - Vault revenue distribution
    /// - Total asset calculations
    function configureManagementFee(address feeAccount_, uint256 feeInPercentage_) internal {
        if (feeAccount_ == address(0)) {
            revert Errors.WrongAddress();
        }
        if (feeInPercentage_ > MANAGEMENT_MAX_FEE_IN_PERCENTAGE) {
            revert InvalidManagementFee(feeInPercentage_);
        }

        PlasmaVaultStorageLib.ManagementFeeData storage managementFeeData = PlasmaVaultStorageLib
            .getManagementFeeData();

        managementFeeData.feeAccount = feeAccount_;
        managementFeeData.feeInPercentage = feeInPercentage_.toUint16();

        emit ManagementFeeDataConfigured(feeAccount_, feeInPercentage_);
    }

    /// @notice Gets the performance fee configuration data
    /// @return performanceFeeData The current performance fee configuration containing:
    ///         - feeAccount: The address of the technical Performance Fee Account that will receive the performance fee collected by the Plasma Vault and later on distributed to IPOR DAO and recipients by FeeManager
    ///         - feeInPercentage: Current fee rate (basis points, 1/10000)
    /// @dev Retrieves the current performance fee settings from storage
    ///
    /// Fee structure:
    /// - Charged on positive vault performance
    /// - Fee percentage limited by PERFORMANCE_MAX_FEE_IN_PERCENTAGE (50%)
    /// - Calculated on realized gains only
    /// - Applied during execute() operations
    ///
    /// Used for:
    /// - Performance fee calculations
    /// - Fee realization during profitable operations
    /// - Performance fee distribution
    /// - Governance fee adjustments
    ///
    /// Integration points:
    /// - PlasmaVault._addPerformanceFee()
    /// - PlasmaVault.execute()
    /// - FeeManager contract
    /// - Governance configuration
    ///
    /// @dev Important: Performance fees:
    /// - Only charged on positive performance
    /// - Calculated based on profit since last fee realization
    /// - Minted as new vault shares
    /// - Distributed to configured fee recipients
    function getPerformanceFeeData()
        internal
        view
        returns (PlasmaVaultStorageLib.PerformanceFeeData memory performanceFeeData)
    {
        return PlasmaVaultStorageLib.getPerformanceFeeData();
    }

    /// @notice Configures the performance fee settings for the vault
    /// @param feeAccount_ The address that will receive performance fees
    /// @param feeInPercentage_ The performance fee rate in basis points (100 = 1%)
    /// @dev Updates fee configuration and emits event
    ///
    /// Parameter requirements:
    /// - feeAccount_: Must be non-zero address. The address of the technical Performance Fee Account that will receive the performance fee collected by the Plasma Vault and later on distributed to IPOR DAO and recipients by FeeManager
    /// - feeInPercentage_: Must not exceed PERFORMANCE_MAX_FEE_IN_PERCENTAGE (50%)
    ///
    /// Fee account types:
    /// - FeeManager contract: Distributes fees to IPOR DAO and other recipients
    /// - EOA/MultiSig: Receives fees directly without distribution
    /// - Technical account: Temporary fee collection before distribution
    ///
    /// Fee percentage format:
    /// - Uses 2 decimal places (basis points)
    /// - Examples:
    ///   - 10000 = 100%
    ///   - 100 = 1%
    ///   - 1 = 0.01%
    ///
    /// Security considerations:
    /// - Only callable by authorized governance functions
    /// - Validates fee percentage against maximum limit
    /// - Emits event for tracking changes
    /// - Critical for vault incentive structure
    ///
    /// @dev Important: Changes affect:
    /// - Profit sharing calculations
    /// - Alpha incentive alignment
    /// - Vault performance metrics
    /// - Revenue distribution model
    function configurePerformanceFee(address feeAccount_, uint256 feeInPercentage_) internal {
        if (feeAccount_ == address(0)) {
            revert Errors.WrongAddress();
        }
        if (feeInPercentage_ > PERFORMANCE_MAX_FEE_IN_PERCENTAGE) {
            revert InvalidPerformanceFee(feeInPercentage_);
        }

        PlasmaVaultStorageLib.PerformanceFeeData storage performanceFeeData = PlasmaVaultStorageLib
            .getPerformanceFeeData();

        performanceFeeData.feeAccount = feeAccount_;
        performanceFeeData.feeInPercentage = feeInPercentage_.toUint16();

        emit PerformanceFeeDataConfigured(feeAccount_, feeInPercentage_);
    }

    /// @notice Updates the management fee timestamp for fee accrual tracking
    /// @dev Updates lastUpdateTimestamp to current block timestamp for fee calculations
    ///
    /// Function behavior:
    /// - Sets lastUpdateTimestamp to current block.timestamp
    /// - Used to mark points of fee realization
    /// - Critical for time-based fee calculations
    ///
    /// Called during:
    /// - Fee realization operations
    /// - Deposit transactions
    /// - Withdrawal transactions
    /// - Share minting/burning
    ///
    /// Integration points:
    /// - PlasmaVault._realizeManagementFee()
    /// - PlasmaVault.deposit()
    /// - PlasmaVault.withdraw()
    /// - PlasmaVault.mint()
    ///
    /// @dev Important considerations:
    /// - Must be called after fee realization
    /// - Affects future fee calculations
    /// - Uses uint32 for timestamp storage
    /// - Critical for fee accounting accuracy
    function updateManagementFeeData() internal {
        PlasmaVaultStorageLib.ManagementFeeData storage feeData = PlasmaVaultStorageLib.getManagementFeeData();
        feeData.lastUpdateTimestamp = block.timestamp.toUint32();
    }

    /// @notice Gets the ordered list of instant withdrawal fuses
    /// @return address[] Array of fuse addresses in withdrawal priority order
    /// @dev Retrieves the configured withdrawal path sequence
    ///
    /// Function behavior:
    /// - Returns ordered array of fuse addresses
    /// - Empty array if no withdrawal paths configured
    /// - Order determines withdrawal attempt sequence
    /// - Same fuse can appear multiple times with different params
    ///
    /// Used during:
    /// - Withdrawal operations
    /// - Instant withdrawal processing
    /// - Withdrawal path validation
    /// - Withdrawal strategy execution
    ///
    /// Integration points:
    /// - PlasmaVault._withdrawFromMarkets()
    /// - Withdrawal execution logic
    /// - Balance validation
    /// - Fuse interaction coordination
    ///
    /// @dev Important considerations:
    /// - Order is critical for withdrawal efficiency
    /// - Multiple entries of same fuse allowed
    /// - Each fuse needs corresponding params
    /// - Used in conjunction with getInstantWithdrawalFusesParams
    function getInstantWithdrawalFuses() internal view returns (address[] memory) {
        return PlasmaVaultStorageLib.getInstantWithdrawalFusesArray().value;
    }

    /// @notice Gets the parameters for a specific instant withdrawal fuse at a given index
    /// @param fuse_ The address of the withdrawal fuse contract
    /// @param index_ The position of the fuse in the withdrawal sequence
    /// @return bytes32[] Array of parameters configured for this fuse instance
    /// @dev Retrieves withdrawal configuration parameters for specific fuse execution
    ///
    /// Parameter structure:
    /// - params[0]: Reserved for withdrawal amount (set during execution)
    /// - params[1+]: Fuse-specific parameters such as:
    ///   - Market identifiers
    ///   - Asset addresses
    ///   - Slippage tolerances
    ///   - Protocol-specific configuration
    ///
    /// Storage pattern:
    /// - Uses keccak256(abi.encodePacked(fuse_, index_)) as key
    /// - Allows same fuse to have different params at different indices
    /// - Supports protocol-specific parameter requirements
    ///
    /// Used during:
    /// - Withdrawal execution
    /// - Parameter validation
    /// - Withdrawal path configuration
    /// - Fuse interaction setup
    ///
    /// @dev Important considerations:
    /// - Parameters must match fuse expectations
    /// - Index must correspond to getInstantWithdrawalFuses array
    /// - First parameter reserved for withdrawal amount
    /// - Critical for proper withdrawal execution
    function getInstantWithdrawalFusesParams(address fuse_, uint256 index_) internal view returns (bytes32[] memory) {
        return
            PlasmaVaultStorageLib.getInstantWithdrawalFusesParams().value[keccak256(abi.encodePacked(fuse_, index_))];
    }

    /// @notice Configures the instant withdrawal fuse sequence and parameters
    /// @param fuses_ Array of fuse configurations with their respective parameters
    /// @dev Sets up withdrawal paths and their execution parameters
    ///
    /// Configuration process:
    /// - Creates ordered list of withdrawal fuses
    /// - Stores parameters for each fuse instance, in most cases are substrates used for instant withdraw
    /// - Validates fuse support status
    /// - Updates storage and emits event
    ///
    /// Parameter validation:
    /// - Each fuse must be supported
    /// - Parameters must match fuse requirements
    /// - Fuse order determines execution priority
    /// - Same fuse can appear multiple times
    ///
    /// Storage updates:
    /// - Clears existing configuration
    /// - Stores new fuse sequence
    /// - Maps parameters to fuse+index combinations
    /// - Maintains parameter ordering
    ///
    /// Security considerations:
    /// - Only callable by authorized governance
    /// - Validates all fuse addresses
    /// - Prevents invalid configurations
    /// - Critical for withdrawal security
    ///
    /// @dev Important: Configuration affects:
    /// - Withdrawal path selection
    /// - Execution sequence
    /// - Protocol interactions
    /// - Withdrawal efficiency
    ///
    /// Common configurations:
    /// - Multiple paths through same protocol
    /// - Different slippage per path
    /// - Market-specific parameters
    /// - Fallback withdrawal routes
    function configureInstantWithdrawalFuses(InstantWithdrawalFusesParamsStruct[] calldata fuses_) internal {
        address[] memory fusesList = new address[](fuses_.length);

        PlasmaVaultStorageLib.InstantWithdrawalFusesParams storage instantWithdrawalFusesParams = PlasmaVaultStorageLib
            .getInstantWithdrawalFusesParams();

        bytes32 key;

        for (uint256 i; i < fuses_.length; ++i) {
            if (!FusesLib.isFuseSupported(fuses_[i].fuse)) {
                revert FusesLib.FuseUnsupported(fuses_[i].fuse);
            }

            fusesList[i] = fuses_[i].fuse;
            key = keccak256(abi.encodePacked(fuses_[i].fuse, i));

            delete instantWithdrawalFusesParams.value[key];

            for (uint256 j; j < fuses_[i].params.length; ++j) {
                instantWithdrawalFusesParams.value[key].push(fuses_[i].params[j]);
            }
        }

        delete PlasmaVaultStorageLib.getInstantWithdrawalFusesArray().value;

        PlasmaVaultStorageLib.getInstantWithdrawalFusesArray().value = fusesList;

        emit InstantWithdrawalFusesConfigured(fuses_);
    }

    /// @notice Gets the Price Oracle Middleware address
    /// @return address The current price oracle middleware contract address
    /// @dev Retrieves the address of the price oracle middleware used for asset valuations
    ///
    /// Price Oracle Middleware:
    /// - Provides standardized price feeds for vault assets
    /// - Must support USD as quote currency
    /// - Critical for asset valuation and calculations
    /// - Required for market operations
    ///
    /// Used during:
    /// - Asset valuation calculations
    /// - Market balance updates
    /// - Fee computations
    /// - Share price determinations
    ///
    /// Integration points:
    /// - Balance fuses for market valuations
    /// - Withdrawal calculations
    /// - Performance tracking
    /// - Asset distribution checks
    ///
    /// @dev Important considerations:
    /// - Must be properly initialized
    /// - Critical for vault operations
    /// - Required for accurate share pricing
    /// - Core component for market interactions
    function getPriceOracleMiddleware() internal view returns (address) {
        return PlasmaVaultStorageLib.getPriceOracleMiddleware().value;
    }

    /// @notice Sets the Price Oracle Middleware address for the vault
    /// @param priceOracleMiddleware_ The new price oracle middleware contract address
    /// @dev Updates the price oracle middleware and emits event
    ///
    /// Validation requirements:
    /// - Must support USD as quote currency
    /// - Must maintain same quote currency decimals
    /// - Must be compatible with existing vault operations
    /// - Address must be non-zero
    ///
    /// Security considerations:
    /// - Only callable by authorized governance
    /// - Critical for vault operations
    /// - Must validate oracle compatibility
    /// - Affects all price-dependent operations
    ///
    /// Integration impacts:
    /// - Asset valuations
    /// - Share price calculations
    /// - Market balance updates
    /// - Fee computations
    ///
    /// @dev Important: Changes affect:
    /// - All price-dependent calculations
    /// - Market operations
    /// - Withdrawal validations
    /// - Performance tracking
    ///
    /// Called during:
    /// - Initial vault setup
    /// - Oracle upgrades
    /// - Protocol improvements
    /// - Emergency oracle changes
    function setPriceOracleMiddleware(address priceOracleMiddleware_) internal {
        PlasmaVaultStorageLib.getPriceOracleMiddleware().value = priceOracleMiddleware_;
        emit PriceOracleMiddlewareChanged(priceOracleMiddleware_);
    }

    /// @notice Gets the Rewards Claim Manager address
    /// @return address The current rewards claim manager contract address
    /// @dev Retrieves the address of the contract managing reward claims and distributions
    ///
    /// Rewards Claim Manager:
    /// - Handles protocol reward claims
    /// - Manages reward token distributions
    /// - Tracks claimable rewards
    /// - Coordinates reward strategies
    ///
    /// Used during:
    /// - Reward claim operations
    /// - Total asset calculations
    /// - Fee computations
    /// - Performance tracking
    ///
    /// Integration points:
    /// - Protocol reward systems
    /// - Asset valuation calculations
    /// - Performance fee assessments
    /// - Governance operations
    ///
    /// @dev Important considerations:
    /// - Can be zero address (rewards disabled)
    /// - Critical for reward accounting
    /// - Affects total asset calculations
    /// - Impacts performance metrics
    function getRewardsClaimManagerAddress() internal view returns (address) {
        return PlasmaVaultStorageLib.getRewardsClaimManagerAddress().value;
    }

    /// @notice Sets the Rewards Claim Manager address for the vault
    /// @param rewardsClaimManagerAddress_ The new rewards claim manager contract address
    /// @dev Updates rewards manager configuration and emits event
    ///
    /// Configuration options:
    /// - Non-zero address: Enables reward claiming functionality
    /// - Zero address: Disables reward claiming system
    ///
    /// Security considerations:
    /// - Only callable by authorized governance
    /// - Critical for reward system operation
    /// - Affects total asset calculations
    /// - Impacts performance metrics
    ///
    /// Integration impacts:
    /// - Protocol reward claiming
    /// - Asset valuation calculations
    /// - Performance tracking
    /// - Fee computations
    ///
    /// @dev Important: Changes affect:
    /// - Reward claiming capability
    /// - Total asset calculations
    /// - Performance measurements
    /// - Protocol integrations
    ///
    /// Called during:
    /// - Initial vault setup
    /// - Rewards system upgrades
    /// - Protocol improvements
    /// - Emergency system changes
    function setRewardsClaimManagerAddress(address rewardsClaimManagerAddress_) internal {
        PlasmaVaultStorageLib.getRewardsClaimManagerAddress().value = rewardsClaimManagerAddress_;
        emit RewardsClaimManagerAddressChanged(rewardsClaimManagerAddress_);
    }

    /// @notice Gets the total supply cap for the vault
    /// @return uint256 The maximum allowed total supply in underlying asset decimals
    /// @dev Retrieves the configured supply cap that limits total vault shares
    ///
    /// Supply cap usage:
    /// - Enforces maximum vault size
    /// - Limits total value locked (TVL)
    /// - Guards against excessive concentration
    /// - Supports gradual scaling
    ///
    /// Used during:
    /// - Deposit validation
    /// - Share minting checks
    /// - Fee minting operations
    /// - Governance monitoring
    ///
    /// Integration points:
    /// - ERC4626 deposit/mint functions
    /// - Fee realization operations
    /// - Governance configuration
    /// - Risk management systems
    ///
    /// @dev Important considerations:
    /// - Cap applies to total shares outstanding
    /// - Can be temporarily bypassed for fees
    /// - Critical for risk management
    /// - Affects deposit availability
    function getTotalSupplyCap() internal view returns (uint256) {
        return PlasmaVaultStorageLib.getERC20CappedStorage().cap;
    }

    /// @notice Sets the total supply cap for the vault
    /// @param cap_ The new maximum total supply in underlying asset decimals
    /// @dev Updates the vault's total supply limit and validates input
    ///
    /// Validation requirements:
    /// - Must be non-zero value
    /// - Must be sufficient for expected vault operations
    /// - Should consider asset decimals
    /// - Must accommodate fee minting
    ///
    /// Security considerations:
    /// - Only callable by authorized governance
    /// - Critical for vault size control
    /// - Affects deposit availability
    /// - Impacts risk management
    ///
    /// Integration impacts:
    /// - Deposit operations
    /// - Share minting limits
    /// - Fee realization
    /// - TVL management
    ///
    /// @dev Important: Changes affect:
    /// - Maximum vault capacity
    /// - Deposit availability
    /// - Fee minting headroom
    /// - Risk parameters
    ///
    /// Called during:
    /// - Initial vault setup
    /// - Capacity adjustments
    /// - Growth management
    /// - Risk parameter updates
    function setTotalSupplyCap(uint256 cap_) internal {
        if (cap_ == 0) {
            revert Errors.WrongValue();
        }
        PlasmaVaultStorageLib.getERC20CappedStorage().cap = cap_;
    }

    /// @notice Controls validation of the total supply cap
    /// @param flag_ The validation control flag (0 = enabled, 1 = disabled)
    /// @dev Manages temporary bypassing of supply cap checks for fee minting
    ///
    /// Flag values:
    /// - 0: Supply cap validation enabled (default)
    ///   - Enforces maximum supply limit
    ///   - Applies to deposits and mints
    ///   - Maintains TVL controls
    ///
    /// - 1: Supply cap validation disabled
    ///   - Allows exceeding supply cap
    ///   - Used during fee minting
    ///   - Temporary state only
    ///
    /// Used during:
    /// - Performance fee minting
    /// - Management fee realization
    /// - Emergency operations
    /// - System maintenance
    ///
    /// Security considerations:
    /// - Only callable by authorized functions
    /// - Should be re-enabled after fee operations
    /// - Critical for supply control
    /// - Temporary bypass only
    ///
    /// @dev Important: State affects:
    /// - Supply cap enforcement
    /// - Fee minting operations
    /// - Deposit availability
    /// - System security
    function setTotalSupplyCapValidation(uint256 flag_) internal {
        PlasmaVaultStorageLib.getERC20CappedValidationFlag().value = flag_;
    }

    /// @notice Checks if the total supply cap validation is enabled
    /// @return bool True if validation is enabled (flag = 0), false if disabled (flag = 1)
    /// @dev Provides current state of supply cap enforcement
    ///
    /// Validation states:
    /// - Enabled (true):
    ///   - Normal operation mode
    ///   - Enforces supply cap limits
    ///   - Required for deposits/mints
    ///   - Default state
    ///
    /// - Disabled (false):
    ///   - Temporary bypass mode
    ///   - Allows exceeding cap
    ///   - Used for fee minting
    ///   - Special operations only
    ///
    /// Used during:
    /// - Deposit validation
    /// - Share minting checks
    /// - Fee operations
    /// - System monitoring
    ///
    /// @dev Important considerations:
    /// - Should generally be enabled
    /// - Temporary disable for fees only
    /// - Critical for supply control
    /// - Check before cap-sensitive operations
    function isTotalSupplyCapValidationEnabled() internal view returns (bool) {
        return PlasmaVaultStorageLib.getERC20CappedValidationFlag().value == 0;
    }

    /// @notice Sets the execution state to started for Alpha operations
    /// @dev Marks the beginning of a multi-action execution sequence
    ///
    /// Execution state usage:
    /// - Tracks active Alpha operations
    /// - Enables multi-action sequences
    /// - Prevents concurrent executions
    /// - Maintains operation atomicity
    ///
    /// Used during:
    /// - Alpha strategy execution
    /// - Complex market operations
    /// - Multi-step transactions
    /// - Protocol interactions
    ///
    /// Security considerations:
    /// - Only callable by authorized Alpha
    /// - Must be paired with executeFinished
    /// - Critical for operation integrity
    /// - Prevents execution overlap
    ///
    /// @dev Important: State affects:
    /// - Operation validation
    /// - Reentrancy protection
    /// - Transaction boundaries
    /// - Error handling
    function executeStarted() internal {
        PlasmaVaultStorageLib.getExecutionState().value = 1;
    }

    /// @notice Sets the execution state to finished after Alpha operations
    /// @dev Marks the end of a multi-action execution sequence
    ///
    /// Function behavior:
    /// - Resets execution state to 0
    /// - Marks completion of Alpha operations
    /// - Enables new execution sequences
    /// - Required for proper state management
    ///
    /// Called after:
    /// - Strategy execution completion
    /// - Market operation finalization
    /// - Protocol interaction completion
    /// - Multi-step transaction end
    ///
    /// Security considerations:
    /// - Must be called after executeStarted
    /// - Critical for execution state cleanup
    /// - Prevents execution state lock
    /// - Required for new operations
    ///
    /// @dev Important: State cleanup:
    /// - Enables new operations
    /// - Releases execution lock
    /// - Required for system stability
    /// - Prevents state corruption
    function executeFinished() internal {
        PlasmaVaultStorageLib.getExecutionState().value = 0;
    }

    /// @notice Checks if an Alpha execution sequence is currently active
    /// @return bool True if execution is in progress (state = 1), false otherwise
    /// @dev Verifies current execution state for operation validation
    ///
    /// State meanings:
    /// - True (1):
    ///   - Execution sequence active
    ///   - Alpha operation in progress
    ///   - Transaction sequence ongoing
    ///   - State modifications allowed
    ///
    /// - False (0):
    ///   - No active execution
    ///   - Ready for new operations
    ///   - Normal vault state
    ///   - Awaiting next sequence
    ///
    /// Used during:
    /// - Operation validation
    /// - State modification checks
    /// - Execution flow control
    /// - Error handling
    ///
    /// @dev Important considerations:
    /// - Critical for operation safety
    /// - Part of execution control flow
    /// - Affects state modification permissions
    /// - Used in reentrancy checks
    function isExecutionStarted() internal view returns (bool) {
        return PlasmaVaultStorageLib.getExecutionState().value == 1;
    }

    /// @notice Updates the Withdraw Manager address for the vault
    /// @param newWithdrawManager_ The new withdraw manager contract address
    /// @dev Updates withdraw manager configuration and emits event
    ///
    /// Configuration options:
    /// - Non-zero address: Enables scheduled withdrawals
    ///   - Enforces withdrawal schedules
    ///   - Manages withdrawal queues
    ///   - Handles withdrawal limits
    ///   - Coordinates withdrawal timing
    ///
    /// - Zero address: Disables scheduled withdrawals
    ///   - Turns off withdrawal scheduling
    ///   - Enables instant withdrawals only
    ///   - Bypasses withdrawal queues
    ///   - Removes withdrawal timing constraints
    ///
    /// Security considerations:
    /// - Only callable by authorized governance
    /// - Critical for withdrawal control
    /// - Affects user withdrawal options
    /// - Impacts liquidity management
    ///
    /// Integration impacts:
    /// - Withdrawal mechanisms
    /// - User withdrawal experience
    /// - Liquidity planning
    /// - Market stability
    ///
    /// @dev Important: Changes affect:
    /// - Withdrawal availability
    /// - Withdrawal timing
    /// - Liquidity management
    /// - User operations
    function updateWithdrawManager(address newWithdrawManager_) internal {
        PlasmaVaultStorageLib.getWithdrawManager().manager = newWithdrawManager_;
        emit WithdrawManagerChanged(newWithdrawManager_);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @title Plasma Vault Storage Library
 * @notice Library managing storage layout and access for the PlasmaVault system using ERC-7201 namespaced storage pattern
 * @dev This library is a core component of the PlasmaVault system that:
 * 1. Defines and manages all storage structures using ERC-7201 namespaced storage pattern
 * 2. Provides storage access functions for PlasmaVault.sol, PlasmaVaultBase.sol and PlasmaVaultGovernance.sol
 * 3. Ensures storage safety for the upgradeable vault system
 *
 * Storage Components:
 * - Core ERC4626 vault storage (asset, decimals)
 * - Market management (assets, balances, substrates)
 * - Fee system storage (performance, management fees)
 * - Access control and execution state
 * - Fuse system configuration
 * - Price oracle and rewards management
 *
 * Key Integrations:
 * - Used by PlasmaVault.sol for core vault operations and asset management
 * - Used by PlasmaVaultGovernance.sol for configuration and admin functions
 * - Used by PlasmaVaultBase.sol for ERC20 functionality and access control
 *
 * Security Considerations:
 * - Uses ERC-7201 namespaced storage pattern to prevent storage collisions
 * - Each storage struct has a unique namespace derived from its purpose
 * - Critical for maintaining storage integrity in upgradeable contracts
 * - Storage slots are carefully chosen and must not be modified
 *
 * @custom:security-contact security@ipor.io
 */
library PlasmaVaultStorageLib {
    /**
     * @dev Storage slot for ERC4626 vault configuration following ERC-7201 namespaced storage pattern
     * @notice This storage location is used to store the core ERC4626 vault data (asset address and decimals)
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC4626")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Important:
     * - This value MUST NOT be changed as it's used by OpenZeppelin's ERC4626 implementation
     * - Changing this value would break storage compatibility with existing deployments
     * - Used by PlasmaVault.sol for core vault operations like deposit/withdraw
     *
     * Storage Layout:
     * - Points to ERC4626Storage struct containing:
     *   - asset: address of the underlying token
     *   - underlyingDecimals: decimals of the underlying token
     */
    bytes32 private constant ERC4626_STORAGE_LOCATION =
        0x0773e532dfede91f04b12a73d3d2acd361424f41f76b4fb79f090161e36b4e00;

    /**
     * @dev Storage slot for ERC20Capped configuration following ERC-7201 namespaced storage pattern
     * @notice This storage location manages the total supply cap functionality for the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC20Capped")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Important:
     * - This value MUST NOT be changed as it's used by OpenZeppelin's ERC20Capped implementation
     * - Changing this value would break storage compatibility with existing deployments
     * - Used by PlasmaVault.sol and PlasmaVaultBase.sol for supply cap enforcement
     *
     * Storage Layout:
     * - Points to ERC20CappedStorage struct containing:
     *   - cap: maximum total supply allowed for the vault tokens
     *
     * Usage:
     * - Enforces maximum supply limits during minting operations
     * - Can be temporarily disabled for fee-related minting operations
     * - Critical for maintaining vault supply control
     */
    bytes32 private constant ERC20_CAPPED_STORAGE_LOCATION =
        0x0f070392f17d5f958cc1ac31867dabecfc5c9758b4a419a200803226d7155d00;

    /**
     * @dev Storage slot for managing the ERC20 supply cap validation state
     * @notice Controls whether total supply cap validation is active or temporarily disabled
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.Erc20CappedValidationFlag")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Provides a mechanism to temporarily disable supply cap checks
     * - Essential for special minting operations like fee distribution
     * - Used by PlasmaVault.sol during performance and management fee minting
     *
     * Storage Layout:
     * - Points to ERC20CappedValidationFlag struct containing:
     *   - value: flag indicating if cap validation is enabled (0) or disabled (1)
     *
     * Usage Pattern:
     * - Default state: Enabled (0) - enforces supply cap
     * - Temporarily disabled (1) during:
     *   - Performance fee minting
     *   - Management fee minting
     * - Always re-enabled after special minting operations
     *
     * Security Note:
     * - Critical for maintaining controlled token supply
     * - Only disabled briefly during authorized fee operations
     * - Must be properly re-enabled to prevent unlimited minting
     */
    bytes32 private constant ERC20_CAPPED_VALIDATION_FLAG =
        0xaef487a7a52e82ae7bbc470b42be72a1d3c066fb83773bf99cce7e6a7df2f900;

    /**
     * @dev Storage slot for tracking total assets across all markets in the Plasma Vault
     * @notice Maintains the global accounting of all assets managed by the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.PlasmaVaultTotalAssetsInAllMarkets")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks the total value of assets managed by the vault across all markets
     * - Used for global vault accounting and share price calculations
     * - Critical for ERC4626 compliance and vault operations
     *
     * Storage Layout:
     * - Points to TotalAssets struct containing:
     *   - value: total assets in underlying token decimals
     *
     * Usage:
     * - Updated during deposit/withdraw operations
     * - Used in share price calculations
     * - Referenced for fee calculations
     * - Key component in asset distribution checks
     *
     * Integration Points:
     * - PlasmaVault.sol: Used in totalAssets() calculations
     * - Fee System: Used as base for fee calculations
     * - Asset Protection: Used in distribution limit checks
     *
     * Security Considerations:
     * - Must be accurately maintained for proper vault operation
     * - Critical for share price accuracy
     * - Any updates must consider all asset sources (markets, rewards, etc.)
     */
    bytes32 private constant PLASMA_VAULT_TOTAL_ASSETS_IN_ALL_MARKETS =
        0x24e02552e88772b8e8fd15f3e6699ba530635ffc6b52322da922b0b497a77300;

    /**
     * @dev Storage slot for tracking assets per individual market in the Plasma Vault
     * @notice Maintains per-market asset accounting for the vault's distributed positions
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.PlasmaVaultTotalAssetsInMarket")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks assets allocated to each market individually
     * - Enables market-specific asset distribution control
     * - Used for market balance validation and limits enforcement
     *
     * Storage Layout:
     * - Points to MarketTotalAssets struct containing:
     *   - value: mapping(uint256 marketId => uint256 assets)
     *   - Assets stored in underlying token decimals
     *
     * Usage:
     * - Updated during market operations via fuses
     * - Used in market balance checks
     * - Referenced for market limit validations
     * - Key for asset distribution protection
     *
     * Integration Points:
     * - Balance Fuses: Update market balances
     * - Asset Distribution Protection: Enforce market limits
     * - Withdrawal Logic: Check available assets per market
     *
     * Security Considerations:
     * - Critical for market-specific asset limits
     * - Must be synchronized with actual market positions
     * - Updates protected by balance fuse system
     */
    bytes32 private constant PLASMA_VAULT_TOTAL_ASSETS_IN_MARKET =
        0x656f5ca8c676f20b936e991a840e1130bdd664385322f33b6642ec86729ee600;

    /**
     * @dev Storage slot for market substrates configuration in the Plasma Vault
     * @notice Manages the configuration of supported assets and sub-markets for each market
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultMarketSubstrates")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Defines which assets/sub-markets are supported in each market
     * - Controls market-specific asset allowances
     * - Essential for market integration configuration
     *
     * Storage Layout:
     * - Points to MarketSubstrates struct containing:
     *   - value: mapping(uint256 marketId => MarketSubstratesStruct)
     *     where MarketSubstratesStruct contains:
     *     - substrateAllowances: mapping(bytes32 => uint256) for permission control
     *     - substrates: bytes32[] list of supported substrates
     *
     * Usage:
     * - Configured by governance for each market
     * - Referenced during market operations
     * - Used by fuses to validate operations
     * - Controls which assets can be used in each market
     *
     * Integration Points:
     * - Fuse System: Validates allowed substrates
     * - Market Operations: Controls available assets
     * - Governance: Manages market configurations
     *
     * Security Considerations:
     * - Critical for controlling market access
     * - Only modifiable through governance
     * - Impacts market operation permissions
     */
    bytes32 private constant CFG_PLASMA_VAULT_MARKET_SUBSTRATES =
        0x78e40624004925a4ef6749756748b1deddc674477302d5b7fe18e5335cde3900;

    /**
     * @dev Storage slot for pre-hooks configuration in the Plasma Vault
     * @notice Manages function-specific pre-execution hooks and their implementations
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultPreHooks")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Maps function selectors to their pre-execution hook implementations
     * - Enables customizable pre-execution validation and logic
     * - Provides extensible function-specific behavior
     * - Coordinates cross-function state updates
     *
     * Storage Layout:
     * - Points to PreHooksConfig struct containing:
     *   - hooksImplementation: mapping(bytes4 selector => address implementation)
     *   - selectors: bytes4[] array of registered function selectors
     *   - indexes: mapping(bytes4 selector => uint256 index) for O(1) selector lookup
     *
     * Usage Pattern:
     * - Each function can have one designated pre-hook
     * - Hooks execute before main function logic
     * - Selector array enables efficient iteration over registered hooks
     * - Index mapping provides quick hook existence checks
     *
     * Integration Points:
     * - PlasmaVault.execute: Pre-execution hook invocation
     * - PreHooksHandler: Hook execution coordination
     * - PlasmaVaultGovernance: Hook configuration
     * - Function-specific hooks: Custom validation logic
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Critical for function execution control
     * - Must validate hook implementations
     * - Requires careful state management
     * - Key component of vault security layer
     */
    bytes32 private constant CFG_PLASMA_VAULT_PRE_HOOKS =
        0xd334d8b26e68f82b7df26f2f64b6ffd2aaae5e2fc0e8c144c4b3598dcddd4b00;

    /**
     * @dev Storage slot for balance fuses configuration in the Plasma Vault
     * @notice Maps markets to their balance fuses and maintains an ordered list of active markets
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultBalanceFuses")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Associates balance fuses with specific markets for asset tracking
     * - Maintains ordered list of active markets for efficient iteration
     * - Enables market balance validation and updates
     * - Coordinates multi-market balance operations
     *
     * Storage Layout:
     * - Points to BalanceFuses struct containing:
     *   - fuseAddresses: mapping(uint256 marketId => address fuseAddress)
     *   - marketIds: uint256[] array of active market IDs
     *   - indexes: Maps market IDs to their position+1 in marketIds array
     *
     * Usage Pattern:
     * - Each market has one designated balance fuse
     * - Market IDs array enables efficient iteration over active markets
     * - Index mapping provides quick market existence checks
     * - Used during balance updates and market operations
     *
     * Integration Points:
     * - PlasmaVault._updateMarketsBalances: Market balance tracking
     * - Balance Fuses: Market position management
     * - PlasmaVaultGovernance: Fuse configuration
     * - Asset Protection: Balance validation
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Critical for accurate asset tracking
     * - Must maintain market list integrity
     * - Requires proper fuse address validation
     * - Key component of vault accounting
     */
    bytes32 private constant CFG_PLASMA_VAULT_BALANCE_FUSES =
        0x150144dd6af711bac4392499881ec6649090601bd196a5ece5174c1400b1f700;

    /**
     * @dev Storage slot for instant withdrawal fuses configuration
     * @notice Stores ordered array of fuses that can be used for instant withdrawals
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultInstantWithdrawalFusesArray")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Maintains list of fuses available for instant withdrawals
     * - Defines order of withdrawal attempts
     * - Enables efficient withdrawal path selection
     *
     * Storage Layout:
     * - Points to InstantWithdrawalFuses struct containing:
     *   - value: address[] array of fuse addresses
     *   - Order of fuses in array determines withdrawal priority
     *
     * Usage:
     * - Referenced during withdrawal operations
     * - Used by PlasmaVault.sol in _withdrawFromMarkets
     * - Determines withdrawal execution sequence
     *
     * Integration Points:
     * - Withdrawal System: Defines available withdrawal paths
     * - Fuse System: Lists supported instant withdrawal fuses
     * - Governance: Manages withdrawal configuration
     *
     * Security Considerations:
     * - Order of fuses is critical for optimal withdrawals
     * - Same fuse can appear multiple times with different params
     * - Must be carefully managed to ensure withdrawal efficiency
     */
    bytes32 private constant CFG_PLASMA_VAULT_INSTANT_WITHDRAWAL_FUSES_ARRAY =
        0xd243afa3da07e6bdec20fdd573a17f99411aa8a62ae64ca2c426d3a86ae0ac00;

    /**
     * @dev Storage slot for price oracle middleware configuration
     * @notice Stores the address of the price oracle middleware used for asset price conversions
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.PriceOracleMiddleware")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Provides price feed access for asset valuations
     * - Essential for market value calculations
     * - Used in balance conversions and limit checks
     *
     * Storage Layout:
     * - Points to PriceOracleMiddleware struct containing:
     *   - value: address of the price oracle middleware contract
     *
     * Usage:
     * - Used during market balance updates
     * - Required for USD value calculations
     * - Critical for asset distribution checks
     *
     * Integration Points:
     * - Balance Fuses: Asset value calculations
     * - Market Operations: Price conversions
     * - Asset Protection: Value-based limits
     *
     * Security Considerations:
     * - Must point to a valid and secure price oracle
     * - Critical for accurate vault valuations
     * - Only updatable through governance
     */
    bytes32 private constant PRICE_ORACLE_MIDDLEWARE =
        0x0d761ae54d86fc3be4f1f2b44ade677efb1c84a85fc6bb1d087dc42f1e319a00;

    /**
     * @dev Storage slot for instant withdrawal fuse parameters configuration
     * @notice Maps fuses to their specific withdrawal parameters for instant withdrawal execution
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultInstantWithdrawalFusesParams")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Stores configuration parameters for each instant withdrawal fuse
     * - Enables customized withdrawal behavior per fuse
     * - Supports multiple parameter sets for the same fuse at different indices
     *
     * Storage Layout:
     * - Points to InstantWithdrawalFusesParams struct containing:
     *   - value: mapping(bytes32 => bytes32[]) where:
     *     - key: keccak256(abi.encodePacked(fuse address, index))
     *     - value: array of parameters specific to the fuse
     *
     * Parameter Structure:
     * - params[0]: Always represents withdrawal amount in underlying token
     * - params[1+]: Fuse-specific parameters (e.g., slippage, path, market-specific data)
     *
     * Usage Pattern:
     * - Referenced during instant withdrawal operations in PlasmaVault
     * - Parameters are passed to fuse's instantWithdraw function
     * - Supports multiple parameter sets for same fuse with different indices
     *
     * Integration Points:
     * - PlasmaVault._withdrawFromMarkets: Uses params for withdrawal execution
     * - PlasmaVaultGovernance: Manages parameter configuration
     * - Fuse Contracts: Receive and interpret parameters during withdrawal
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Critical for controlling withdrawal behavior
     * - Parameters must be carefully validated per fuse requirements
     * - Order of parameters must match fuse expectations
     */
    bytes32 private constant CFG_PLASMA_VAULT_INSTANT_WITHDRAWAL_FUSES_PARAMS =
        0x45a704819a9dcb1bb5b8cff129eda642cf0e926a9ef104e27aa53f1d1fa47b00;

    /**
     * @dev Storage slot for fee configuration in the Plasma Vault
     * @notice Manages the fee configuration including performance and management fees
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.CfgPlasmaVaultFeeConfig")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Stores comprehensive fee configuration for the vault
     * - Manages both IPOR DAO and recipient-specific fee settings
     * - Enables flexible fee distribution model
     *
     * Storage Layout:
     * - Points to FeeConfig struct containing:
     *   - feeFactory: address of the FeeManagerFactory contract
     *   - iporDaoManagementFee: management fee percentage for IPOR DAO
     *   - iporDaoPerformanceFee: performance fee percentage for IPOR DAO
     *   - iporDaoFeeRecipientAddress: address receiving IPOR DAO fees
     *   - recipientManagementFees: array of management fee percentages for other recipients
     *   - recipientPerformanceFees: array of performance fee percentages for other recipients
     *
     * Fee Structure:
     * - Management fees: Continuous time-based fees on AUM
     * - Performance fees: Charged on positive vault performance
     * - All fees in basis points (1/10000)
     *
     * Integration Points:
     * - FeeManagerFactory: Deploys fee management contracts
     * - FeeManager: Handles fee calculations and distributions
     * - PlasmaVault: References for fee realizations
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Fee percentages must be within reasonable bounds
     * - Critical for vault economics and sustainability
     * - Must maintain proper recipient configurations
     */
    bytes32 private constant CFG_PLASMA_VAULT_FEE_CONFIG =
        0x78b5ce597bdb64d5aa30a201c7580beefe408ff13963b5d5f3dce2dc09e89c00;

    /**
     * @dev Storage slot for performance fee data in the Plasma Vault
     * @notice Stores current performance fee configuration and recipient information
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.PlasmaVaultPerformanceFeeData")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Manages performance fee settings and collection
     * - Tracks fee recipient address
     * - Controls performance-based revenue sharing
     *
     * Storage Layout:
     * - Points to PerformanceFeeData struct containing:
     *   - feeAccount: address receiving performance fees
     *   - feeInPercentage: current fee rate (basis points, 1/10000)
     *
     * Fee Mechanics:
     * - Calculated on positive vault performance
     * - Applied during execute() operations
     * - Minted as new vault shares to fee recipient
     * - Charged only on realized gains
     *
     * Integration Points:
     * - PlasmaVault._addPerformanceFee: Fee calculation and minting
     * - FeeManager: Fee configuration management
     * - PlasmaVaultGovernance: Fee settings updates
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Fee percentage must be within defined limits
     * - Critical for fair value distribution
     * - Must maintain valid fee recipient address
     * - Requires careful handling during share minting
     */
    bytes32 private constant PLASMA_VAULT_PERFORMANCE_FEE_DATA =
        0x9399757a27831a6cfb6cf4cd5c97a908a2f8f41e95a5952fbf83a04e05288400;

    /**
     * @notice Stores management fee configuration and time tracking data
     * @dev Manages continuous fee collection with time-based accrual
     * @custom:storage-location erc7201:io.ipor.PlasmaVaultManagementFeeData
     */
    bytes32 private constant PLASMA_VAULT_MANAGEMENT_FEE_DATA =
        0x239dd7e43331d2af55e2a25a6908f3bcec2957025f1459db97dcdc37c0003f00;

    /**
     * @dev Storage slot for rewards claim manager address
     * @notice Stores the address of the contract managing external protocol rewards
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.RewardsClaimManagerAddress")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Manages external protocol reward claims
     * - Tracks claimable rewards across integrated protocols
     * - Centralizes reward collection logic
     *
     * Storage Layout:
     * - Points to RewardsClaimManagerAddress struct containing:
     *   - value: address of the rewards claim manager contract
     *
     * Functionality:
     * - Coordinates reward claims from multiple protocols
     * - Tracks unclaimed rewards in underlying asset terms
     * - Included in total assets calculations when active
     * - Optional component (can be set to address(0))
     *
     * Integration Points:
     * - PlasmaVault._getGrossTotalAssets: Includes rewards in total assets
     * - PlasmaVault.claimRewards: Executes reward collection
     * - External protocols: Source of claimable rewards
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Must handle protocol-specific claim logic safely
     * - Critical for accurate reward accounting
     * - Requires careful integration testing
     * - Should handle failed claims gracefully
     */
    bytes32 private constant REWARDS_CLAIM_MANAGER_ADDRESS =
        0x08c469289c3f85d9b575f3ae9be6831541ff770a06ea135aa343a4de7c962d00;

    /**
     * @dev Storage slot for market allocation limits
     * @notice Controls maximum asset allocation per market in the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.MarketLimits")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Enforces market-specific allocation limits
     * - Prevents over-concentration in single markets
     * - Enables risk management through diversification
     *
     * Storage Layout:
     * - Points to MarketLimits struct containing:
     *   - limitInPercentage: mapping(uint256 marketId => uint256 limit)
     *   - Limits stored in basis points (1e18 = 100%)
     *
     * Limit Mechanics:
     * - Each market has independent allocation limit
     * - Limits are percentage of total vault assets
     * - Zero limit for marketId 0 deactivates all limits
     * - Non-zero limit for marketId 0 activates limit system
     *
     * Integration Points:
     * - AssetDistributionProtectionLib: Enforces limits
     * - PlasmaVault._updateMarketsBalances: Checks limits
     * - PlasmaVaultGovernance: Limit configuration
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Critical for risk management
     * - Must handle percentage calculations carefully
     * - Requires proper market balance tracking
     * - Should prevent concentration risk
     */
    bytes32 private constant MARKET_LIMITS = 0xc2733c187287f795e2e6e84d35552a190e774125367241c3e99e955f4babf000;

    /**
     * @dev Storage slot for market balance dependency relationships
     * @notice Manages interconnected market balance update requirements
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.DependencyBalanceGraph")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Tracks dependencies between market balances
     * - Ensures atomic balance updates across related markets
     * - Maintains consistency in cross-market positions
     *
     * Storage Layout:
     * - Points to DependencyBalanceGraph struct containing:
     *   - dependencyGraph: mapping(uint256 marketId => uint256[] marketIds)
     *   - Each market maps to array of dependent market IDs
     *
     * Dependency Mechanics:
     * - Markets can depend on multiple other markets
     * - When updating a market balance, all dependent markets must be updated
     * - Dependencies are unidirectional (A->B doesn't imply B->A)
     * - Empty dependency array means no dependencies
     *
     * Integration Points:
     * - PlasmaVault._checkBalanceFusesDependencies: Resolves update order
     * - PlasmaVault._updateMarketsBalances: Ensures complete updates
     * - PlasmaVaultGovernance: Dependency configuration
     *
     * Security Considerations:
     * - Only modifiable through governance
     * - Must prevent circular dependencies
     * - Critical for market balance integrity
     * - Requires careful dependency chain validation
     * - Should handle deep dependency trees efficiently
     */
    bytes32 private constant DEPENDENCY_BALANCE_GRAPH =
        0x82411e549329f2815579116a6c5e60bff72686c93ab5dba4d06242cfaf968900;

    /**
     * @dev Storage slot for tracking execution state of vault operations
     * @notice Controls execution flow and prevents concurrent operations in the vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.executeRunning")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Prevents concurrent execution of vault operations
     * - Enables callback handling during execution
     * - Acts as a reentrancy guard for execute() operations
     *
     * Storage Layout:
     * - Points to ExecuteState struct containing:
     *   - value: uint256 flag indicating execution state
     *     - 0: No execution in progress
     *   - 1: Execution in progress
     *
     * Usage Pattern:
     * - Set to 1 at start of execute() operation
     * - Checked during callback handling
     * - Reset to 0 when execution completes
     * - Used by PlasmaVault.execute() and callback system
     *
     * Integration Points:
     * - PlasmaVault.execute: Sets/resets execution state
     * - CallbackHandlerLib: Validates callbacks during execution
     * - Fallback function: Routes callbacks during execution
     *
     * Security Considerations:
     * - Critical for preventing concurrent operations
     * - Must be properly reset after execution
     * - Protects against malicious callbacks
     * - Part of vault's security architecture
     */
    bytes32 private constant EXECUTE_RUNNING = 0x054644eb87255c1c6a2d10801735f52fa3b9d6e4477dbed74914d03844ab6600;

    /**
     * @dev Storage slot for callback handler mapping in the Plasma Vault
     * @notice Maps protocol-specific callbacks to their handler contracts
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.callbackHandler")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Routes protocol-specific callbacks to appropriate handlers
     * - Enables dynamic callback handling during vault operations
     * - Supports integration with external protocols
     * - Manages protocol-specific callback logic
     *
     * Storage Layout:
     * - Points to CallbackHandler struct containing:
     *   - callbackHandler: mapping(bytes32 => address)
     *     - key: keccak256(abi.encodePacked(sender, sig))
     *     - value: address of the handler contract
     *
     * Usage Pattern:
     * - Callbacks received during execute() operations
     * - Key generated from sender address and function signature
     * - Handler contract processes protocol-specific logic
     * - Only accessible when execution is in progress
     *
     * Integration Points:
     * - PlasmaVault.fallback: Routes incoming callbacks
     * - CallbackHandlerLib: Processes callback routing
     * - Protocol-specific handlers: Implement callback logic
     * - PlasmaVaultGovernance: Manages handler configuration
     *
     * Security Considerations:
     * - Only callable during active execution
     * - Handler addresses must be trusted
     * - Prevents unauthorized callback processing
     * - Critical for secure protocol integration
     * - Must validate callback sources
     */
    bytes32 private constant CALLBACK_HANDLER = 0xb37e8684757599da669b8aea811ee2b3693b2582d2c730fab3f4965fa2ec3e00;

    /**
     * @dev Storage slot for withdraw manager contract address
     * @notice Manages withdrawal controls and permissions in the Plasma Vault
     *
     * Calculation:
     * keccak256(abi.encode(uint256(keccak256("io.ipor.WithdrawManager")) - 1)) & ~bytes32(uint256(0xff))
     *
     * Purpose:
     * - Controls withdrawal permissions and limits
     * - Manages withdrawal schedules and timing
     * - Enforces withdrawal restrictions
     * - Coordinates withdrawal validation
     *
     * Storage Layout:
     * - Points to WithdrawManager struct containing:
     *   - manager: address of the withdraw manager contract
     *   - Zero address indicates disabled withdrawal controls
     *
     * Usage Pattern:
     * - Checked during withdraw() and redeem() operations
     * - Validates withdrawal permissions
     * - Enforces withdrawal schedules
     * - Can be disabled by setting to address(0)
     *
     * Integration Points:
     * - PlasmaVault.withdraw: Checks withdrawal permissions
     * - PlasmaVault.redeem: Validates redemption requests
     * - PlasmaVaultGovernance: Manager configuration
     * - AccessManager: Permission coordination
     *
     * Security Considerations:
     * - Critical for controlling asset outflows
     * - Only modifiable through governance
     * - Must maintain withdrawal restrictions
     * - Coordinates with access control system
     * - Key component of vault security
     */
    bytes32 private constant WITHDRAW_MANAGER = 0xb37e8684757599da669b8aea811ee2b3693b2582d2c730fab3f4965fa2ec3e11;

    /**
     * @notice Maps callback signatures to their handler contracts
     * @dev Stores routing information for protocol-specific callbacks
     * @custom:storage-location erc7201:io.ipor.callbackHandler
     */
    struct CallbackHandler {
        /// @dev key: keccak256(abi.encodePacked(sender, sig)), value: handler address
        mapping(bytes32 key => address handler) callbackHandler;
    }

    /**
     * @notice Stores and manages per-market allocation limits for the vault
     * @custom:storage-location erc7201:io.ipor.MarketLimits
     */
    struct MarketLimits {
        mapping(uint256 marketId => uint256 limit) limitInPercentage;
    }

    /**
     * @notice Core storage for ERC4626 vault implementation
     * @dev Value taken from OpenZeppelin's ERC4626 implementation - DO NOT MODIFY
     * @custom:storage-location erc7201:openzeppelin.storage.ERC4626
     */
    struct ERC4626Storage {
        /// @dev underlying asset in Plasma Vault
        address asset;
        /// @dev underlying asset decimals in Plasma Vault
        uint8 underlyingDecimals;
    }

    /// @dev Value taken from ERC20VotesUpgradeable contract, don't change it!
    /// @custom:storage-location erc7201:openzeppelin.storage.ERC20Capped
    struct ERC20CappedStorage {
        uint256 cap;
    }

    /// @notice ERC20CappedValidationFlag is used to enable or disable the total supply cap validation during execution
    /// Required for situation when performance fee or management fee is minted for fee managers
    /// @custom:storage-location erc7201:io.ipor.Erc20CappedValidationFlag
    struct ERC20CappedValidationFlag {
        uint256 value;
    }

    /**
     * @notice Stores address of the contract managing protocol reward claims
     * @dev Optional component - can be set to address(0) to disable rewards
     * @custom:storage-location erc7201:io.ipor.RewardsClaimManagerAddress
     */
    struct RewardsClaimManagerAddress {
        /// @dev total assets in the Plasma Vault
        address value;
    }

    /**
     * @notice Tracks total assets across all markets in the vault
     * @dev Used for global accounting and share price calculations
     * @custom:storage-location erc7201:io.ipor.PlasmaVaultTotalAssetsInAllMarkets
     */
    struct TotalAssets {
        /// @dev total assets in the Plasma Vault
        uint256 value;
    }

    /**
     * @notice Tracks per-market asset balances in the vault
     * @dev Used for market-specific accounting and limit enforcement
     * @custom:storage-location erc7201:io.ipor.PlasmaVaultTotalAssetsInMarket
     */
    struct MarketTotalAssets {
        /// @dev marketId => total assets in the vault in the market
        mapping(uint256 => uint256) value;
    }

    /**
     * @notice Market Substrates configuration
     * @dev Substrate - abstract item in the market, could be asset or sub market in the external protocol, it could be any item required to calculate balance in the market
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultMarketSubstrates
     */
    struct MarketSubstratesStruct {
        /// @notice Define which substrates are allowed and supported in the market
        /// @dev key can be specific asset or sub market in a specific external protocol (market), value - 1 - granted, otherwise - not granted
        mapping(bytes32 => uint256) substrateAllowances;
        /// @dev it could be list of assets or sub markets in a specific protocol or any other ids required to calculate balance in the market (external protocol)
        bytes32[] substrates;
    }

    /**
     * @notice Maps markets to their supported substrate configurations
     * @dev Stores per-market substrate allowances and lists
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultMarketSubstrates
     */
    struct MarketSubstrates {
        /// @dev marketId => MarketSubstratesStruct
        mapping(uint256 => MarketSubstratesStruct) value;
    }

    /**
     * @notice Manages market-to-fuse mappings and active market tracking
     * @dev Provides efficient market lookup and iteration capabilities
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultBalanceFuses
     *
     * Storage Components:
     * - fuseAddresses: Maps each market to its designated balance fuse
     * - marketIds: Maintains ordered list of active markets for iteration
     * - indexes: Maps market IDs to their position+1 in marketIds array
     *
     * Key Features:
     * - Efficient market-fuse relationship management
     * - Fast market existence validation (index 0 means not present)
     * - Optimized iteration over active markets
     * - Maintains market list integrity
     *
     * Usage:
     * - Market balance tracking and validation
     * - Fuse assignment and management
     * - Market activation/deactivation
     * - Multi-market operations coordination
     *
     * Index Mapping Pattern:
     * - Stored value = actual array index + 1
     * - Value of 0 indicates market not present
     * - To get array index, subtract 1 from stored value
     * - Enables distinction between unset markets and first position
     *
     * Security Notes:
     * - Market IDs must be unique
     * - Index mapping must stay synchronized with array
     * - Fuse addresses must be validated before assignment
     * - Critical for vault's balance tracking system
     */
    struct BalanceFuses {
        /// @dev Maps market IDs to their corresponding balance fuse addresses
        mapping(uint256 marketId => address fuseAddress) fuseAddresses;
        /// @dev Ordered array of active market IDs for efficient iteration
        uint256[] marketIds;
        /// @dev Maps market IDs to their position+1 in the marketIds array (0 means not present)
        mapping(uint256 marketId => uint256 index) indexes;
    }

    /**
     * @notice Manages pre-execution hooks configuration for vault functions
     * @dev Provides efficient hook lookup and management for function-specific pre-execution logic
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultPreHooks
     *
     * Storage Components:
     * - hooksImplementation: Maps function selectors to their hook implementation contracts
     * - selectors: Maintains ordered list of registered function selectors
     * - indexes: Enables O(1) selector existence checks and array access
     *
     * Key Features:
     * - Efficient function-to-hook mapping management
     * - Fast hook implementation lookup
     * - Optimized iteration over registered hooks
     * - Maintains hook registry integrity
     *
     * Usage:
     * - Pre-execution validation and checks
     * - Custom function-specific behavior
     * - Hook registration and management
     * - Cross-function state coordination
     *
     * Security Notes:
     * - Function selectors must be unique
     * - Index mapping must stay synchronized with array
     * - Hook implementations must be validated before assignment
     * - Critical for vault's execution security layer
     */
    struct PreHooksConfig {
        /// @dev Maps function selectors to their corresponding hook implementation addresses
        mapping(bytes4 => address) hooksImplementation;
        /// @dev Ordered array of registered function selectors for efficient iteration
        bytes4[] selectors;
        /// @dev Maps function selectors to their position in the selectors array for O(1) lookup
        mapping(bytes4 selector => uint256 index) indexes;
        /// @dev Maps function selectors and addresses to their corresponding substrate ids
        /// @dev key is keccak256(abi.encodePacked(address, selector))
        mapping(bytes32 key => bytes32[] substrates) substrates;
    }

    /**
     * @notice Tracks dependencies between market balances for atomic updates
     * @dev Maps markets to their dependent markets requiring simultaneous balance updates
     * @custom:storage-location erc7201:io.ipor.BalanceDependenceGraph
     */
    struct DependencyBalanceGraph {
        mapping(uint256 marketId => uint256[] marketIds) dependencyGraph;
    }

    /**
     * @notice Stores ordered list of fuses available for instant withdrawals
     * @dev Order determines withdrawal attempt sequence, same fuse can appear multiple times
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultInstantWithdrawalFusesArray
     */
    struct InstantWithdrawalFuses {
        /// @dev value is a Fuse address used for instant withdrawal
        address[] value;
    }

    /**
     * @notice Stores parameters for instant withdrawal fuse operations
     * @dev Maps fuse+index pairs to their withdrawal configuration parameters
     * @custom:storage-location erc7201:io.ipor.CfgPlasmaVaultInstantWithdrawalFusesParams
     */
    struct InstantWithdrawalFusesParams {
        /// @dev key: fuse address and index in InstantWithdrawalFuses array, value: list of parameters used for instant withdrawal
        /// @dev first param always amount in underlying asset of PlasmaVault, second and next params are specific for the fuse and market
        mapping(bytes32 => bytes32[]) value;
    }

    /**
     * @notice Stores performance fee configuration and recipient data
     * @dev Manages fee percentage and recipient account for performance-based fees
     * @custom:storage-location erc7201:io.ipor.PlasmaVaultPerformanceFeeData
     */
    struct PerformanceFeeData {
        address feeAccount;
        uint16 feeInPercentage;
    }

    /**
     * @notice Stores management fee configuration and time tracking data
     * @dev Manages continuous fee collection with time-based accrual
     * @custom:storage-location erc7201:io.ipor.PlasmaVaultManagementFeeData
     */
    struct ManagementFeeData {
        address feeAccount;
        uint16 feeInPercentage;
        uint32 lastUpdateTimestamp;
    }

    /**
     * @notice Stores address of price oracle middleware for asset valuations
     * @dev Provides standardized price feed access for vault operations
     * @custom:storage-location erc7201:io.ipor.PriceOracleMiddleware
     */
    struct PriceOracleMiddleware {
        address value;
    }

    /**
     * @notice Tracks execution state of vault operations
     * @dev Used as a flag to prevent concurrent execution and manage callbacks
     * @custom:storage-location erc7201:io.ipor.executeRunning
     */
    struct ExecuteState {
        uint256 value;
    }

    /**
     * @notice Stores address of the contract managing withdrawal controls
     * @dev Handles withdrawal permissions, schedules and limits
     * @custom:storage-location erc7201:io.ipor.WithdrawManager
     */
    struct WithdrawManager {
        address manager;
    }

    function getERC4626Storage() internal pure returns (ERC4626Storage storage $) {
        assembly {
            $.slot := ERC4626_STORAGE_LOCATION
        }
    }

    function getERC20CappedStorage() internal pure returns (ERC20CappedStorage storage $) {
        assembly {
            $.slot := ERC20_CAPPED_STORAGE_LOCATION
        }
    }

    function getERC20CappedValidationFlag() internal pure returns (ERC20CappedValidationFlag storage $) {
        assembly {
            $.slot := ERC20_CAPPED_VALIDATION_FLAG
        }
    }

    function getTotalAssets() internal pure returns (TotalAssets storage totalAssets) {
        assembly {
            totalAssets.slot := PLASMA_VAULT_TOTAL_ASSETS_IN_ALL_MARKETS
        }
    }

    function getExecutionState() internal pure returns (ExecuteState storage executeRunning) {
        assembly {
            executeRunning.slot := EXECUTE_RUNNING
        }
    }

    function getCallbackHandler() internal pure returns (CallbackHandler storage handler) {
        assembly {
            handler.slot := CALLBACK_HANDLER
        }
    }

    function getDependencyBalanceGraph() internal pure returns (DependencyBalanceGraph storage dependencyBalanceGraph) {
        assembly {
            dependencyBalanceGraph.slot := DEPENDENCY_BALANCE_GRAPH
        }
    }

    function getMarketTotalAssets() internal pure returns (MarketTotalAssets storage marketTotalAssets) {
        assembly {
            marketTotalAssets.slot := PLASMA_VAULT_TOTAL_ASSETS_IN_MARKET
        }
    }

    function getMarketSubstrates() internal pure returns (MarketSubstrates storage marketSubstrates) {
        assembly {
            marketSubstrates.slot := CFG_PLASMA_VAULT_MARKET_SUBSTRATES
        }
    }

    function getBalanceFuses() internal pure returns (BalanceFuses storage balanceFuses) {
        assembly {
            balanceFuses.slot := CFG_PLASMA_VAULT_BALANCE_FUSES
        }
    }

    function getPreHooksConfig() internal pure returns (PreHooksConfig storage preHooksConfig) {
        assembly {
            preHooksConfig.slot := CFG_PLASMA_VAULT_PRE_HOOKS
        }
    }

    function getInstantWithdrawalFusesArray()
        internal
        pure
        returns (InstantWithdrawalFuses storage instantWithdrawalFuses)
    {
        assembly {
            instantWithdrawalFuses.slot := CFG_PLASMA_VAULT_INSTANT_WITHDRAWAL_FUSES_ARRAY
        }
    }

    function getInstantWithdrawalFusesParams()
        internal
        pure
        returns (InstantWithdrawalFusesParams storage instantWithdrawalFusesParams)
    {
        assembly {
            instantWithdrawalFusesParams.slot := CFG_PLASMA_VAULT_INSTANT_WITHDRAWAL_FUSES_PARAMS
        }
    }

    function getPriceOracleMiddleware() internal pure returns (PriceOracleMiddleware storage oracle) {
        assembly {
            oracle.slot := PRICE_ORACLE_MIDDLEWARE
        }
    }

    function getPerformanceFeeData() internal pure returns (PerformanceFeeData storage performanceFeeData) {
        assembly {
            performanceFeeData.slot := PLASMA_VAULT_PERFORMANCE_FEE_DATA
        }
    }

    function getManagementFeeData() internal pure returns (ManagementFeeData storage managementFeeData) {
        assembly {
            managementFeeData.slot := PLASMA_VAULT_MANAGEMENT_FEE_DATA
        }
    }

    function getRewardsClaimManagerAddress()
        internal
        pure
        returns (RewardsClaimManagerAddress storage rewardsClaimManagerAddress)
    {
        assembly {
            rewardsClaimManagerAddress.slot := REWARDS_CLAIM_MANAGER_ADDRESS
        }
    }

    function getMarketsLimits() internal pure returns (MarketLimits storage marketLimits) {
        assembly {
            marketLimits.slot := MARKET_LIMITS
        }
    }

    function getWithdrawManager() internal pure returns (WithdrawManager storage withdrawManager) {
        assembly {
            withdrawManager.slot := WITHDRAW_MANAGER
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @title Predefined roles used in the IPOR Fusion protocol
 * @notice For documentation purposes: When new roles are added by authorized property of PlasmaVault during runtime, they should be added and described here as well.
 * @dev Roles prefixed with 'TECH_' are special system roles that can only be assigned to and executed by contracts within the PlasmaVault ecosystem.
 * These technical roles are typically set during system initialization and cannot be reassigned during runtime.
 */
library Roles {
    /// @notice Account with this role has rights to manage the IporFusionAccessManager in general. The highest role, which could manage all roles including ADMIN_ROLE and OWNER_ROLE. It recommended to use MultiSig contract for this role.
    /// @dev Managed by the Admin, the highest role from AccessManager
    uint64 public constant ADMIN_ROLE = 0;

    /// @notice Account with this role has rights to manage Owners, Guardians, Atomists. It recommended to use MultiSig contract for this role.
    /// @dev Managed by the Owner, if applicable managed by the Admin
    uint64 public constant OWNER_ROLE = 1;

    /// @notice Account with this role has rights to cancel time-locked operations, pause restricted methods in PlasmaVault contracts in case of emergency
    /// @dev Managed by the Owner
    uint64 public constant GUARDIAN_ROLE = 2;

    /// @notice Technical role to limit access to methods only from the PlasmaVault contract
    /// @dev System role that can only be assigned to PlasmaVault contracts. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_PLASMA_VAULT_ROLE = 3;

    /// @notice Technical role for IPOR DAO operations
    /// @dev System role that can only be assigned to IPOR DAO contract. Set during initialization and cannot be changed afterward
    uint64 public constant IPOR_DAO_ROLE = 4;

    /// @notice Technical role to limit access to methods only from the ContextManager contract
    /// @dev System role that can only be assigned to ContextManager contract. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_CONTEXT_MANAGER_ROLE = 5;

    /// @notice Technical role to limit access to methods only from the WithdrawManager contract
    /// @dev System role that can only be assigned to WithdrawManager contract. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_WITHDRAW_MANAGER_ROLE = 6;

    /// @notice Account with this role has rights to manage the PlasmaVault. It recommended to use MultiSig contract for this role.
    /// @dev Managed by Owner
    uint64 public constant ATOMIST_ROLE = 100;

    /// @notice Account with this role has rights to execute the alpha strategy on the PlasmaVault using execute method.
    /// @dev Managed by the Atomist
    uint64 public constant ALPHA_ROLE = 200;

    /// @notice Account with this role has rights to manage the FuseManager contract, add or remove fuses, balance fuses and reward fuses
    /// @dev Managed by the Atomist
    uint64 public constant FUSE_MANAGER_ROLE = 300;

    /// @notice Technical role for the FeeManager contract's performance fee operations
    /// @dev System role that can only be assigned to FeeManager contract. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_PERFORMANCE_FEE_MANAGER_ROLE = 400;

    /// @notice Technical role for the FeeManager contract's management fee operations
    /// @dev System role that can only be assigned to FeeManager contract. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_MANAGEMENT_FEE_MANAGER_ROLE = 500;

    /// @notice Account with this role has rights to claim rewards from the PlasmaVault using and interacting with the RewardsClaimManager contract
    /// @dev Managed by the Atomist
    uint64 public constant CLAIM_REWARDS_ROLE = 600;

    /// @notice Technical role for the RewardsClaimManager contract
    /// @dev System role that can only be assigned to RewardsClaimManager contract. Set during initialization and cannot be changed afterward
    uint64 public constant TECH_REWARDS_CLAIM_MANAGER_ROLE = 601;

    /// @notice Account with this role has rights to transfer rewards from the PlasmaVault to the RewardsClaimManager
    /// @dev Managed by the Atomist
    uint64 public constant TRANSFER_REWARDS_ROLE = 700;

    /// @notice Account with this role has rights to deposit / mint and withdraw / redeem assets from the PlasmaVault
    /// @dev Managed by the Atomist
    uint64 public constant WHITELIST_ROLE = 800;

    /// @notice Account with this role has rights to configure instant withdrawal fuses order.
    /// @dev Managed by the Atomist
    uint64 public constant CONFIG_INSTANT_WITHDRAWAL_FUSES_ROLE = 900;

    /// @notice Account with this role has rights to update the markets balances in the PlasmaVault
    /// @dev Managed by the Atomist
    uint64 public constant UPDATE_MARKETS_BALANCES_ROLE = 1000;

    /// @notice Account with this role has rights to update balance in the RewardsClaimManager contract
    /// @dev Managed by the Atomist
    uint64 public constant UPDATE_REWARDS_BALANCE_ROLE = 1100;

    /// @notice Public role, no restrictions
    uint64 public constant PUBLIC_ROLE = type(uint64).max;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Errors in Ipor Fusion
library Errors {
    /// @notice Error when wrong address is used
    error WrongAddress();
    /// @notice Error when wrong value is used
    error WrongValue();
    /// @notice Error when wrong decimals are used
    error WrongDecimals();
    /// @notice Error when wrong array length is used
    error WrongArrayLength();
    /// @notice Error when wrong caller is used
    error WrongCaller(address caller);
    /// @notice Error when wrong quote currency is used
    error UnsupportedQuoteCurrencyFromOracle();
    /// @notice Error when unsupported price oracle middleware is used
    error UnsupportedPriceOracleMiddleware();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Ipor Math library with math functions
library IporMath {
    uint256 private constant WAD_DECIMALS = 18;
    uint256 public constant BASIS_OF_POWER = 10;

    /// @dev The index of the most significant bit in a 256-bit signed integer
    uint256 private constant MSB = 255;

    function min(uint256 a_, uint256 b_) internal pure returns (uint256) {
        return a_ < b_ ? a_ : b_;
    }

    /// @notice Converts the value to WAD decimals, WAD decimals are 18
    /// @param value_ The value to convert
    /// @param assetDecimals_ The decimals of the asset
    /// @return The value in WAD decimals
    function convertToWad(uint256 value_, uint256 assetDecimals_) internal pure returns (uint256) {
        if (value_ > 0) {
            if (assetDecimals_ == WAD_DECIMALS) {
                return value_;
            } else if (assetDecimals_ > WAD_DECIMALS) {
                return division(value_, BASIS_OF_POWER ** (assetDecimals_ - WAD_DECIMALS));
            } else {
                return value_ * BASIS_OF_POWER ** (WAD_DECIMALS - assetDecimals_);
            }
        } else {
            return value_;
        }
    }

    /// @notice Converts the value to WAD decimals, WAD decimals are 18
    /// @param value_ The value to convert
    /// @param assetDecimals_ The decimals of the asset
    /// @return The value in WAD decimals
    function convertWadToAssetDecimals(uint256 value_, uint256 assetDecimals_) internal pure returns (uint256) {
        if (assetDecimals_ == WAD_DECIMALS) {
            return value_;
        } else if (assetDecimals_ > WAD_DECIMALS) {
            return value_ * BASIS_OF_POWER ** (assetDecimals_ - WAD_DECIMALS);
        } else {
            return division(value_, BASIS_OF_POWER ** (WAD_DECIMALS - assetDecimals_));
        }
    }

    /// @notice Converts the int value to WAD decimals, WAD decimals are 18
    /// @param value_ The int value to convert
    /// @param assetDecimals_ The decimals of the asset
    /// @return The value in WAD decimals, int
    function convertToWadInt(int256 value_, uint256 assetDecimals_) internal pure returns (int256) {
        if (value_ == 0) {
            return 0;
        }
        if (assetDecimals_ == WAD_DECIMALS) {
            return value_;
        } else if (assetDecimals_ > WAD_DECIMALS) {
            return divisionInt(value_, int256(BASIS_OF_POWER ** (assetDecimals_ - WAD_DECIMALS)));
        } else {
            return value_ * int256(BASIS_OF_POWER ** (WAD_DECIMALS - assetDecimals_));
        }
    }

    /// @notice Divides two int256 numbers and rounds the result to the nearest integer
    /// @param x_ The numerator
    /// @param y_ The denominator
    /// @return z The result of the division
    function divisionInt(int256 x_, int256 y_) internal pure returns (int256 z) {
        uint256 absX_ = uint256(x_ < 0 ? -x_ : x_);
        uint256 absY_ = uint256(y_ < 0 ? -y_ : y_);

        // Use bitwise XOR to get the sign on MBS bit then shift to LSB
        // sign == 0x0000...0000 ==  0 if the number is non-negative
        // sign == 0xFFFF...FFFF == -1 if the number is negative
        int256 sign = (x_ ^ y_) >> MSB;

        uint256 divAbs;
        uint256 remainder;

        unchecked {
            divAbs = absX_ / absY_;
            remainder = absX_ % absY_;
        }
        // Check if we need to round
        if (sign < 0) {
            // remainder << 1 left shift is equivalent to multiplying by 2
            if (remainder << 1 > absY_) {
                ++divAbs;
            }
        } else {
            if (remainder << 1 >= absY_) {
                ++divAbs;
            }
        }

        // (sign | 1) is cheaper than (sign < 0) ? -1 : 1;
        unchecked {
            z = int256(divAbs) * (sign | 1);
        }
    }

    /// @notice Divides two uint256 numbers and rounds the result to the nearest integer
    /// @param x_ The numerator
    /// @param y_ The denominator
    /// @return z_ The result of the division
    function division(uint256 x_, uint256 y_) internal pure returns (uint256 z_) {
        z_ = x_ / y_;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AccessManaged.sol)

pragma solidity ^0.8.20;
import {AuthorityUtils} from "@openzeppelin/contracts/access/manager/AuthorityUtils.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Constant representing the function selector for setting up the context manager
 * @dev This selector (0x87ef0b87) is used to identify the context manager setup operation
 * @custom:security Used for access control and context management operations
 */
bytes4 constant CONTEXT_MANAGER_SETUP = bytes4(0x87ef0b87);

/**
 * @dev Constant representing the function selector for clearing the context manager
 * @dev This selector (0xdb99bddd) is used to identify the context manager clear operation
 * @custom:security Used for access control and context management operations
 */
bytes4 constant CONTEXT_MANAGER_CLEAR = bytes4(0xdb99bddd);

/**
 * @dev This contract module makes available a {restricted} modifier. Functions decorated with this modifier will be
 * permissioned according to an "authority": a contract like {AccessManager} that follows the {IAuthority} interface,
 * implementing a policy that allows certain callers to access certain functions.
 *
 * IMPORTANT: The `restricted` modifier should never be used on `internal` functions, judiciously used in `public`
 * functions, and ideally only used in `external` functions. See {restricted}.
 */
abstract contract AccessManagedUpgradeable is Initializable, ContextUpgradeable, IAccessManaged {
    /// @custom:storage-location erc7201:openzeppelin.storage.AccessManaged
    struct AccessManagedStorage {
        address _authority;
        bool _consumingSchedule;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessManaged")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ACCESS_MANAGED_STORAGE_LOCATION =
        0xf3177357ab46d8af007ab3fdb9af81da189e1068fefdc0073dca88a2cab40a00;

    function _getAccessManagedStorage() internal pure returns (AccessManagedStorage storage $) {
        assembly {
            $.slot := ACCESS_MANAGED_STORAGE_LOCATION
        }
    }

    /**
     * @dev Initializes the contract connected to an initial authority.
     */
    function __AccessManaged_init(address initialAuthority) internal onlyInitializing {
        // solhint-disable-previous-line func-name-mixedcase
        __AccessManaged_init_unchained(initialAuthority);
    }

    function __AccessManaged_init_unchained(address initialAuthority) internal onlyInitializing {
        // solhint-disable-previous-line func-name-mixedcase
        _setAuthority(initialAuthority);
    }

    /**
     * @dev Restricts access to a function as defined by the connected Authority for this contract and the
     * caller and selector of the function that entered the contract.
     *
     * [IMPORTANT]
     * ====
     * In general, this modifier should only be used on `external` functions. It is okay to use it on `public`
     * functions that are used as external entry points and are not called internally. Unless you know what you're
     * doing, it should never be used on `internal` functions. Failure to follow these rules can have critical security
     * implications! This is because the permissions are determined by the function that entered the contract, i.e. the
     * function at the bottom of the call stack, and not the function where the modifier is visible in the source code.
     * ====
     *
     * [WARNING]
     * ====
     * Avoid adding this modifier to the https://docs.soliditylang.org/en/v0.8.20/contracts.html#receive-ether-function[`receive()`]
     * function or the https://docs.soliditylang.org/en/v0.8.20/contracts.html#fallback-function[`fallback()`]. These
     * functions are the only execution paths where a function selector cannot be unambiguosly determined from the calldata
     * since the selector defaults to `0x00000000` in the `receive()` function and similarly in the `fallback()` function
     * if no calldata is provided. (See {_checkCanCall}).
     *
     * The `receive()` function will always panic whereas the `fallback()` may panic depending on the calldata length.
     * ====
     */
    modifier restricted() {
        _checkCanCall(_msgSender(), _msgData());
        _;
    }

    /// @inheritdoc IAccessManaged
    function authority() public view virtual returns (address) {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        return $._authority;
    }

    /// @inheritdoc IAccessManaged
    function setAuthority(address newAuthority) public virtual {
        address caller = _msgSender();
        if (caller != authority()) {
            revert AccessManagedUnauthorized(caller);
        }
        if (newAuthority.code.length == 0) {
            revert AccessManagedInvalidAuthority(newAuthority);
        }
        _setAuthority(newAuthority);
    }

    /// @inheritdoc IAccessManaged
    function isConsumingScheduledOp() public view virtual returns (bytes4) {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        return $._consumingSchedule ? this.isConsumingScheduledOp.selector : bytes4(0);
    }

    /**
     * @dev Transfers control to a new authority. Internal function with no access restriction. Allows bypassing the
     * permissions set by the current authority.
     */
    function _setAuthority(address newAuthority) internal virtual {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        $._authority = newAuthority;
        emit AuthorityUpdated(newAuthority);
    }

    /**
     * @dev Reverts if the caller is not allowed to call the function identified by a selector. Panics if the calldata
     * is less than 4 bytes long.
     */
    function _checkCanCall(address caller_, bytes calldata data_) internal virtual {
        bytes4 sig = bytes4(data_[0:4]);
        if (sig == CONTEXT_MANAGER_SETUP || sig == CONTEXT_MANAGER_CLEAR) {
            caller_ = msg.sender;
        }

        AccessManagedStorage storage $ = _getAccessManagedStorage();
        (bool immediate, uint32 delay) = AuthorityUtils.canCallWithDelay(
            authority(),
            caller_,
            address(this),
            bytes4(data_[0:4])
        );
        if (!immediate) {
            if (delay > 0) {
                $._consumingSchedule = true;
                IAccessManager(authority()).consumeScheduledOp(caller_, data_);
                $._consumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller_);
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import {IIporFusionAccessManager} from "../../interfaces/IIporFusionAccessManager.sol";

import {RedemptionDelayLib} from "./RedemptionDelayLib.sol";
import {PlasmaVault} from "../../vaults/PlasmaVault.sol";
import {RoleExecutionTimelockLib} from "./RoleExecutionTimelockLib.sol";
import {IporFusionAccessManagerInitializationLib, InitializationData} from "./IporFusionAccessManagerInitializationLib.sol";
import {Roles} from "../../libraries/Roles.sol";

/**
 * @title IporFusionAccessManager
 * @notice Contract responsible for managing access control to the IporFusion protocol
 * @dev Extends OpenZeppelin's AccessManager with custom functionality for IPOR Fusion
 *
 * Role-based permissions:
 * - ADMIN_ROLE: Can initialize the contract and manage roles
 * - GUARDIAN_ROLE: Can cancel operations and update target closed status
 * - ATOMIST_ROLE: Can manage vault configurations and market settings
 * - PUBLIC_ROLE: Used for publicly accessible functions
 * - TECH_CONTEXT_MANAGER_ROLE: Technical role for context operations
 * - TECH_PLASMA_VAULT_ROLE: Technical role for plasma vault operations
 *
 * Function permissions:
 * - initialize: Restricted to ADMIN_ROLE
 * - updateTargetClosed: Restricted to GUARDIAN_ROLE
 * - convertToPublicVault: Restricted to TECH_PLASMA_VAULT_ROLE
 * - enableTransferShares: Restricted to TECH_PLASMA_VAULT_ROLE
 * - setMinimalExecutionDelaysForRoles: Restricted to TECH_PLASMA_VAULT_ROLE
 * - grantRole: Restricted to authorized roles (via onlyAuthorized)
 *
 * Security features:
 * - Role-based execution delays
 * - Redemption delay mechanism
 * - Guardian role for emergency actions
 * - Timelock controls for sensitive operations
 *
 */
contract IporFusionAccessManager is IIporFusionAccessManager, AccessManager {
    error AccessManagedUnauthorized(address caller);
    error TooShortExecutionDelayForRole(uint64 roleId, uint32 executionDelay);
    error TooLongRedemptionDelay(uint256 redemptionDelayInSeconds);

    /// @notice Maximum allowed redemption delay in seconds (7 days)
    uint256 public constant MAX_REDEMPTION_DELAY_IN_SECONDS = 7 days;

    /// @notice Actual redemption delay in seconds for this instance
    uint256 public immutable override REDEMPTION_DELAY_IN_SECONDS;

    /// @dev Flag to track custom schedule consumption
    bool private _customConsumingSchedule;

    /**
     * @notice Modifier to restrict function access to authorized callers
     * @dev Checks if the caller can execute the function and handles scheduled operations
     */
    modifier restricted() {
        _checkCanCall(_msgSender(), _msgData());
        _;
    }

    /**
     * @notice Constructor sets up initial admin and redemption delay
     * @param initialAdmin_ Address of the initial admin
     * @param redemptionDelayInSeconds_ Initial redemption delay in seconds
     * @custom:security Validates redemption delay is within bounds
     */
    constructor(address initialAdmin_, uint256 redemptionDelayInSeconds_) AccessManager(initialAdmin_) {
        if (redemptionDelayInSeconds_ > MAX_REDEMPTION_DELAY_IN_SECONDS) {
            revert TooLongRedemptionDelay(redemptionDelayInSeconds_);
        }
        REDEMPTION_DELAY_IN_SECONDS = redemptionDelayInSeconds_;
    }

    /**
     * @notice Initializes the access manager with role configurations
     * @param initialData_ Initial configuration data for roles and permissions
     * @dev Sets up role hierarchies, function permissions, and execution delays
     * @custom:access Restricted to ADMIN_ROLE
     */
    function initialize(InitializationData calldata initialData_) external restricted {
        IporFusionAccessManagerInitializationLib.isInitialized();
        _revokeRole(ADMIN_ROLE, msg.sender);

        uint256 roleToFunctionsLength = initialData_.roleToFunctions.length;
        uint64[] memory roleIds = new uint64[](roleToFunctionsLength);
        uint256[] memory minimalDelays = new uint256[](roleToFunctionsLength);

        if (roleToFunctionsLength > 0) {
            for (uint256 i; i < roleToFunctionsLength; ++i) {
                _setTargetFunctionRole(
                    initialData_.roleToFunctions[i].target,
                    initialData_.roleToFunctions[i].functionSelector,
                    initialData_.roleToFunctions[i].roleId
                );
                roleIds[i] = initialData_.roleToFunctions[i].roleId;
                minimalDelays[i] = initialData_.roleToFunctions[i].minimalExecutionDelay;
                if (
                    initialData_.roleToFunctions[i].roleId != Roles.ADMIN_ROLE &&
                    initialData_.roleToFunctions[i].roleId != Roles.GUARDIAN_ROLE &&
                    initialData_.roleToFunctions[i].roleId != Roles.PUBLIC_ROLE
                ) {
                    _setRoleGuardian(initialData_.roleToFunctions[i].roleId, Roles.GUARDIAN_ROLE);
                }
            }
        }
        RoleExecutionTimelockLib.setMinimalExecutionDelaysForRoles(roleIds, minimalDelays);

        uint256 adminRolesLength = initialData_.adminRoles.length;
        if (adminRolesLength > 0) {
            for (uint256 i; i < adminRolesLength; ++i) {
                _setRoleAdmin(initialData_.adminRoles[i].roleId, initialData_.adminRoles[i].adminRoleId);
            }
        }

        uint256 accountToRolesLength = initialData_.accountToRoles.length;
        if (accountToRolesLength > 0) {
            for (uint256 i; i < accountToRolesLength; ++i) {
                _grantRoleInternal(
                    initialData_.accountToRoles[i].roleId,
                    initialData_.accountToRoles[i].account,
                    initialData_.accountToRoles[i].executionDelay
                );
            }
        }
    }

    /**
     * @notice Checks if a caller can execute a function and updates state if needed
     * @param caller_ Address attempting to call the function
     * @param target_ Target contract address
     * @param selector_ Function selector being called
     * @return immediate Whether the call can be executed immediately
     * @return delay The required delay before execution
     * @custom:security Updates redemption delay state if applicable
     */
    function canCallAndUpdate(
        address caller_,
        address target_,
        bytes4 selector_
    ) external override returns (bool immediate, uint32 delay) {
        RedemptionDelayLib.lockChecks(caller_, selector_);
        return super.canCall(caller_, target_, selector_);
    }

    /**
     * @notice Updates whether a target contract is closed for operations
     * @param target_ Target contract address
     * @param closed_ New closed status
     * @custom:access Restricted to GUARDIAN_ROLE
     */
    function updateTargetClosed(address target_, bool closed_) external override restricted {
        _setTargetClosed(target_, closed_);
    }

    /**
     * @notice Converts a vault to public access mode
     * @param vault_ Address of the vault to convert
     * @custom:access Restricted to TECH_PLASMA_VAULT_ROLE
     */
    function convertToPublicVault(address vault_) external override restricted {
        _setTargetFunctionRole(vault_, PlasmaVault.mint.selector, PUBLIC_ROLE);
        _setTargetFunctionRole(vault_, PlasmaVault.deposit.selector, PUBLIC_ROLE);
        _setTargetFunctionRole(vault_, PlasmaVault.depositWithPermit.selector, PUBLIC_ROLE);
    }

    /**
     * @notice Enables share transfer functionality for a vault
     * @param vault_ Address of the vault
     * @custom:access Restricted to TECH_PLASMA_VAULT_ROLE
     */
    function enableTransferShares(address vault_) external override restricted {
        _setTargetFunctionRole(vault_, PlasmaVault.transfer.selector, PUBLIC_ROLE);
        _setTargetFunctionRole(vault_, PlasmaVault.transferFrom.selector, PUBLIC_ROLE);
    }

    /**
     * @notice Sets minimal execution delays for specified roles
     * @param rolesIds_ Array of role IDs
     * @param delays_ Array of corresponding delays
     * @custom:access Restricted to TECH_PLASMA_VAULT_ROLE
     */
    function setMinimalExecutionDelaysForRoles(
        uint64[] calldata rolesIds_,
        uint256[] calldata delays_
    ) external override restricted {
        RoleExecutionTimelockLib.setMinimalExecutionDelaysForRoles(rolesIds_, delays_);
    }

    /**
     * @notice Grants a role to an account with a specified execution delay
     * @param roleId_ The role identifier to grant
     * @param account_ The account to receive the role
     * @param executionDelay_ The execution delay for the role operations
     * @dev Overrides AccessManager.grantRole to add execution delay validation
     * @custom:access
     * - Restricted to authorized roles via onlyAuthorized modifier
     * - Can only be called by the admin of the role being granted (e.g., ADMIN_ROLE can grant OWNER_ROLE, OWNER_ROLE can grant ATOMIST_ROLE)
     * - Role hierarchy must be followed according to Roles.sol documentation
     * @custom:security
     * - Validates that execution delay meets minimum requirements
     * - Role hierarchy must be respected (e.g., ADMIN_ROLE can grant OWNER_ROLE)
     * @custom:error TooShortExecutionDelayForRole if executionDelay_ is less than the minimum required
     */
    function grantRole(
        uint64 roleId_,
        address account_,
        uint32 executionDelay_
    ) public override(IAccessManager, AccessManager) onlyAuthorized {
        _grantRoleInternal(roleId_, account_, executionDelay_);
    }

    /**
     * @notice Retrieves the minimal execution delay configured for a specific role
     * @param roleId_ The role identifier to query
     * @return The minimal execution delay in seconds for the specified role
     * @dev This delay represents the minimum time that must pass between scheduling and executing an operation
     * @custom:access No access restrictions - can be called by anyone
     * @custom:security Used to enforce timelock restrictions on role operations
     */
    function getMinimalExecutionDelayForRole(uint64 roleId_) external view override returns (uint256) {
        return RoleExecutionTimelockLib.getMinimalExecutionDelayForRole(roleId_);
    }

    /**
     * @notice Retrieves the lock time for a specific account
     * @param account_ The account address to query
     * @return The timestamp until which the account is locked for redemption operations
     * @dev Used to enforce redemption delay periods after certain operations
     * @custom:access No access restrictions - can be called by anyone
     * @custom:security
     * - Part of the redemption delay mechanism
     * - Used to prevent immediate withdrawals after specific actions
     * - Lock time is managed by RedemptionDelayLib
     */
    function getAccountLockTime(address account_) external view override returns (uint256) {
        return RedemptionDelayLib.getAccountLockTime(account_);
    }

    /**
     * @notice Checks if the contract is currently consuming a scheduled operation
     * @return bytes4 Returns the function selector if consuming a scheduled operation, or bytes4(0) if not
     * @dev Used to track the state of scheduled operation execution
     * @custom:access No access restrictions - can be called by anyone
     * @custom:security
     * - Used internally to prevent reentrancy during scheduled operation execution
     * - Returns this.isConsumingScheduledOp.selector when _customConsumingSchedule is true
     * - Returns bytes4(0) when not consuming a scheduled operation
     */
    function isConsumingScheduledOp() external view override returns (bytes4) {
        return _customConsumingSchedule ? this.isConsumingScheduledOp.selector : bytes4(0);
    }

    function _grantRoleInternal(uint64 roleId_, address account_, uint32 executionDelay_) internal {
        if (executionDelay_ < RoleExecutionTimelockLib.getMinimalExecutionDelayForRole(roleId_)) {
            revert TooShortExecutionDelayForRole(roleId_, executionDelay_);
        }
        _grantRole(roleId_, account_, getRoleGrantDelay(roleId_), executionDelay_);
    }

    function _checkCanCall(address caller_, bytes calldata data_) internal virtual {
        (bool immediate, uint32 delay) = canCall(caller_, address(this), bytes4(data_[0:4]));
        if (!immediate) {
            if (delay > 0) {
                _customConsumingSchedule = true;
                IAccessManager(address(this)).consumeScheduledOp(caller_, data_);
                _customConsumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller_);
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {IporFusionAccessManagersStorageLib, InitializationFlag} from "./IporFusionAccessManagersStorageLib.sol";

/**
 * @title Role-to-Function Mapping Structure
 * @notice Defines the relationship between roles and their authorized function calls
 * @dev Used to configure function-level access control during initialization
 */
struct RoleToFunction {
    /// @notice The target contract address where the function resides
    address target;
    /// @notice The role identifier that has permission to call the function
    uint64 roleId;
    /// @notice The 4-byte function selector of the authorized function
    bytes4 functionSelector;
    /// @notice Timelock delay for function execution
    /// @dev If greater than 0, function calls require waiting for the specified delay
    uint256 minimalExecutionDelay;
}

/**
 * @title Admin Role Configuration Structure
 * @notice Defines the hierarchical relationship between roles
 * @dev Used to establish role administration rights
 */
struct AdminRole {
    /// @notice The role being administered
    uint64 roleId;
    /// @notice The role that has admin rights over roleId
    uint64 adminRoleId;
}

/**
 * @title Account-to-Role Assignment Structure
 * @notice Maps accounts to their assigned roles with optional execution delays
 * @dev Used to configure initial role assignments during initialization
 */
struct AccountToRole {
    /// @notice The role being assigned
    uint64 roleId;
    /// @notice The account receiving the role
    address account;
    /// @notice Account-specific execution delay
    /// @dev If greater than 0, the account must wait this period before executing role actions
    uint32 executionDelay;
}

/**
 * @title Access Manager Initialization Configuration
 * @notice Comprehensive structure for initializing the access control system
 * @dev Combines all necessary configuration data for one-time initialization
 */
struct InitializationData {
    /// @notice Array of function access configurations
    RoleToFunction[] roleToFunctions;
    /// @notice Array of initial role assignments
    AccountToRole[] accountToRoles;
    /// @notice Array of role hierarchy configurations
    AdminRole[] adminRoles;
}

/**
 * @title IPOR Fusion Access Manager Initialization Library
 * @notice Manages one-time initialization of access control settings
 * @dev Implements initialization protection to prevent multiple configurations
 * @custom:security-contact security@ipor.io
 */
library IporFusionAccessManagerInitializationLib {
    /// @notice Emitted when the access manager is successfully initialized
    event IporFusionAccessManagerInitialized();

    /// @notice Thrown when attempting to initialize an already initialized contract
    error AlreadyInitialized();

    /**
     * @notice Verifies and sets the initialization state
     * @dev Ensures the contract can only be initialized once
     * @custom:security Critical function that prevents multiple initializations
     * @custom:error-handling Reverts with AlreadyInitialized if already initialized
     */
    function isInitialized() internal {
        InitializationFlag storage initializationFlag = IporFusionAccessManagersStorageLib.getInitializationFlag();
        if (initializationFlag.initialized > 0) {
            revert AlreadyInitialized();
        }
        initializationFlag.initialized = 1;
        emit IporFusionAccessManagerInitialized();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {IIporFusionAccessManager} from "../../interfaces/IIporFusionAccessManager.sol";

/**
 * @title Redemption Locks Storage Structure
 * @notice Manages time-based locks for redemption operations per account
 * @dev Uses ERC-7201 namespaced storage pattern to prevent storage collisions
 * @custom:storage-location erc7201:io.ipor.managers.access.RedemptionLocks
 */
struct RedemptionLocks {
    /// @notice Maps user addresses to their deposit timestamp
    /// @dev Used to enforce redemption delays after deposits
    mapping(address acount => uint256 depositTime) redemptionLock;
}

/**
 * @title Minimal Execution Delay Storage Structure
 * @notice Stores role-specific execution delays for timelock functionality
 * @dev Uses ERC-7201 namespaced storage pattern
 * @custom:storage-location erc7201:io.ipor.managers.access.MinimalExecutionDelayForRole
 */
struct MinimalExecutionDelayForRole {
    /// @notice Maps role IDs to their required execution delays
    mapping(uint64 roleId => uint256 delay) delays;
}

/**
 * @title Initialization Flag Storage Structure
 * @notice Tracks initialization status to prevent multiple initializations
 * @dev Uses ERC-7201 namespaced storage pattern
 * @custom:storage-location erc7201:io.ipor.managers.access.InitializationFlag
 */
struct InitializationFlag {
    /// @notice Initialization status flag
    /// @dev Value greater than 0 indicates initialized state
    uint256 initialized;
}

/**
 * @title IPOR Fusion Access Managers Storage Library
 * @notice Library managing storage layouts for access control and redemption mechanisms
 * @dev Implements ERC-7201 storage pattern for namespace isolation
 * @custom:security-contact security@ipor.io
 */
library IporFusionAccessManagersStorageLib {
    using SafeCast for uint256;

    /// @notice Storage slot for RedemptionLocks
    /// @dev Computed as: keccak256(abi.encode(uint256(keccak256("io.ipor.managers.access.RedemptionLocks")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REDEMPTION_LOCKS = 0x5e07febb5bd598f6b55406c9bf939d497fd39a2dbc2b5891f20f6640c3f32500;

    /// @notice Storage slot for MinimalExecutionDelayForRole
    /// @dev Computed as: keccak256(abi.encode(uint256(keccak256("io.ipor.managers.access.MinimalExecutionDelayForRole")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MINIMAL_EXECUTION_DELAY_FOR_ROLE =
        0x2e44a6c6f75b62bc581bae68fca3a6629eb7343eef230a6702d4acd6389fd600;

    /// @notice Storage slot for InitializationFlag
    /// @dev Computed as: keccak256(abi.encode(uint256(keccak256("io.ipor.managers.access.InitializationFlag")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZATION_FLAG = 0x25e922da7c41a5d012dbc2479dd6a7bd57760f359ea3a3be13608d287fc89400;

    /// @notice Emitted when an account's redemption delay is updated
    /// @param account The address of the affected account
    /// @param redemptionDelay The new redemption delay timestamp
    event RedemptionDelayForAccountUpdated(address account, uint256 redemptionDelay);

    /**
     * @notice Retrieves the initialization flag storage pointer
     * @dev Uses assembly to access the predetermined storage slot
     * @return initializationFlag Storage pointer to the initialization flag
     */
    function getInitializationFlag() internal view returns (InitializationFlag storage initializationFlag) {
        assembly {
            initializationFlag.slot := INITIALIZATION_FLAG
        }
    }

    /**
     * @notice Retrieves the minimal execution delay storage pointer
     * @dev Uses assembly to access the predetermined storage slot
     * @return minimalExecutionDelayForRole Storage pointer to the execution delays mapping
     */
    function getMinimalExecutionDelayForRole()
        internal
        pure
        returns (MinimalExecutionDelayForRole storage minimalExecutionDelayForRole)
    {
        assembly {
            minimalExecutionDelayForRole.slot := MINIMAL_EXECUTION_DELAY_FOR_ROLE
        }
    }

    /**
     * @notice Retrieves the redemption locks storage pointer
     * @dev Uses assembly to access the predetermined storage slot
     * @return redemptionLocks Storage pointer to the redemption locks mapping
     */
    function getRedemptionLocks() internal view returns (RedemptionLocks storage redemptionLocks) {
        assembly {
            redemptionLocks.slot := REDEMPTION_LOCKS
        }
    }

    /**
     * @notice Sets redemption lock for an account after deposit or mint operations
     * @dev Enforces a time-based lock to prevent immediate withdrawals after deposits
     * @param account_ The address to set the redemption lock for
     * @custom:security This function helps prevent potential manipulation through quick deposits and withdrawals
     */
    function setRedemptionLocks(address account_) internal {
        uint256 redemptionDelay = IIporFusionAccessManager(address(this)).REDEMPTION_DELAY_IN_SECONDS();
        if (redemptionDelay == 0) {
            return;
        }
        RedemptionLocks storage redemptionLocks = getRedemptionLocks();
        uint256 redemptionLock = uint256(block.timestamp) + redemptionDelay;
        redemptionLocks.redemptionLock[account_] = redemptionLock;
        emit RedemptionDelayForAccountUpdated(account_, redemptionLock);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {PlasmaVault} from "../../vaults/PlasmaVault.sol";
import {IporFusionAccessManagersStorageLib} from "./IporFusionAccessManagersStorageLib.sol";

/**
 * @dev Function selectors for vault operations that trigger or are affected by redemption delays
 */
bytes4 constant DEPOSIT_SELECTOR = PlasmaVault.deposit.selector;
bytes4 constant DEPOSIT_WITH_PERMIT_SELECTOR = PlasmaVault.depositWithPermit.selector;
bytes4 constant MINT_SELECTOR = PlasmaVault.mint.selector;
bytes4 constant WITHDRAW_SELECTOR = PlasmaVault.withdraw.selector;
bytes4 constant REDEEM_SELECTOR = PlasmaVault.redeem.selector;
bytes4 constant TRANSFER_FROM_SELECTOR = PlasmaVault.transferFrom.selector;
bytes4 constant TRANSFER_SELECTOR = PlasmaVault.transfer.selector;

/**
 * @title Redemption Delay Library
 * @notice Implements time-based restrictions on withdrawals and redemptions after deposits
 * @dev Provides functionality to enforce cooling periods between deposits and withdrawals
 * to prevent potential manipulation and protect the vault's assets
 * @custom:security-contact security@ipor.io
 */
library RedemptionDelayLib {
    /**
     * @notice Error thrown when an account attempts to withdraw before their lock period expires
     * @param unlockTime The timestamp when the account will be unlocked
     */
    error AccountIsLocked(uint256 unlockTime);

    /**
     * @notice Retrieves the lock time for a specific account
     * @dev Used to check when an account will be able to withdraw or redeem
     * @param account_ The address to check the lock time for
     * @return The timestamp until which the account is locked
     * @custom:security This value should be checked before allowing withdrawals
     */
    function getAccountLockTime(address account_) internal view returns (uint256) {
        return IporFusionAccessManagersStorageLib.getRedemptionLocks().redemptionLock[account_];
    }

    /**
     * @notice Enforces redemption delay rules based on function calls
     * @dev Implements the following rules:
     * 1. For withdrawals/redemptions: Checks if the account is still locked
     * 2. For deposits/mints: Sets a new lock period
     * @param account_ The account performing the operation
     * @param sig_ The function selector of the operation being performed
     * @custom:security Critical function that prevents quick deposit/withdrawal cycles
     * @custom:error-handling Reverts with AccountIsLocked if withdrawal attempted during lock period
     */
    function lockChecks(address account_, bytes4 sig_) internal {
        if (
            sig_ == WITHDRAW_SELECTOR ||
            sig_ == REDEEM_SELECTOR ||
            sig_ == TRANSFER_FROM_SELECTOR ||
            sig_ == TRANSFER_SELECTOR
        ) {
            uint256 unlockTime = IporFusionAccessManagersStorageLib.getRedemptionLocks().redemptionLock[account_];
            if (unlockTime > block.timestamp) {
                revert AccountIsLocked(unlockTime);
            }
        } else if (sig_ == DEPOSIT_SELECTOR || sig_ == MINT_SELECTOR || sig_ == DEPOSIT_WITH_PERMIT_SELECTOR) {
            IporFusionAccessManagersStorageLib.setRedemptionLocks(account_);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {IporFusionAccessManagersStorageLib} from "./IporFusionAccessManagersStorageLib.sol";

/**
 * @title Role Execution Timelock Library
 * @notice Manages time-based restrictions on role execution permissions
 * @dev Implements timelock functionality for role-based actions to enhance security
 * through mandatory waiting periods
 * @custom:security-contact security@ipor.io
 */
library RoleExecutionTimelockLib {
    /**
     * @notice Emitted when a role's minimal execution delay is modified
     * @param roleId The identifier of the role whose delay was updated
     * @param delay The new minimal execution delay in seconds
     */
    event MinimalExecutionDelayForRoleUpdated(uint64 roleId, uint256 delay);

    /**
     * @notice Retrieves the minimum waiting period required before executing actions for a role
     * @dev A delay greater than 0 indicates that actions for this role are timelocked
     * @param roleId_ The identifier of the role to query
     * @return The minimum delay period in seconds
     * @custom:security This delay acts as a security measure for sensitive operations
     */
    function getMinimalExecutionDelayForRole(uint64 roleId_) internal view returns (uint256) {
        return IporFusionAccessManagersStorageLib.getMinimalExecutionDelayForRole().delays[roleId_];
    }

    /**
     * @notice Configures timelock delays for multiple roles
     * @dev Batch operation to set execution delays for multiple roles at once
     * @param roleIds_ Array of role identifiers to configure
     * @param delays_ Array of corresponding delay periods in seconds
     * @custom:security Critical function that affects access control timing
     * @custom:error-handling Arrays must be of equal length
     */
    function setMinimalExecutionDelaysForRoles(uint64[] memory roleIds_, uint256[] memory delays_) internal {
        uint256 length = roleIds_.length;
        for (uint256 i; i < length; ++i) {
            IporFusionAccessManagersStorageLib.getMinimalExecutionDelayForRole().delays[roleIds_[i]] = delays_[i];
            emit MinimalExecutionDelayForRoleUpdated(roleIds_[i], delays_[i]);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {IContextClient} from "./IContextClient.sol";
import {ContextClientStorageLib} from "./ContextClientStorageLib.sol";
import {AccessManagedUpgradeable} from "../access/AccessManagedUpgradeable.sol";

/**
 * @title ContextClient
 * @notice Contract that manages context for operations requiring sender context
 * @dev Implements IContextClient interface using ContextClientStorageLib for storage
 *
 * Role-based permissions:
 * - TECH_CONTEXT_MANAGER_ROLE: Can setup and clear context
 * - No other roles have direct access to context management
 *
 * Function permissions:
 * - setupContext: Restricted to TECH_CONTEXT_MANAGER_ROLE
 * - clearContext: Restricted to TECH_CONTEXT_MANAGER_ROLE
 * - getSenderFromContext: Internal function, no direct role restrictions
 *
 * Security considerations:
 * - Context operations are restricted to authorized managers only
 * - Single context enforcement prevents context manipulation
 * - Clear separation between context setup and usage
 *
 * @custom:security-contact security@yourproject.com
 */
abstract contract ContextClient is IContextClient, AccessManagedUpgradeable {
    /// @dev Custom errors for context-related operations
    /// @notice Thrown when attempting to set context when one is already active
    error ContextAlreadySet();
    /// @notice Thrown when attempting to clear or access context when none is set
    error ContextNotSet();
    /// @notice Thrown when an unauthorized address attempts to interact with protected functions
    error UnauthorizedSender();

    /**
     * @notice Sets up the context with the provided sender address
     * @param sender_ The address to set as the context sender
     * @dev Only callable by authorized contracts through the restricted modifier
     * @dev Uses ContextClientStorageLib for persistent storage
     * @custom:security Non-reentrant by design through single context restriction
     * @custom:access Restricted to TECH_CONTEXT_MANAGER_ROLE only
     * @custom:throws ContextAlreadySet if a context is currently active
     */
    function setupContext(address sender_) external override restricted {
        if (ContextClientStorageLib.isContextSenderSet()) {
            revert ContextAlreadySet();
        }

        ContextClientStorageLib.setContextSender(sender_);

        emit ContextSet(sender_);
    }

    /**
     * @notice Clears the current context
     * @dev Only callable by authorized contracts through the restricted modifier
     * @dev Uses ContextClientStorageLib for persistent storage
     * @custom:security Should always be called after context operations are complete
     * @custom:access Restricted to TECH_CONTEXT_MANAGER_ROLE only
     * @custom:throws ContextNotSet if no context is currently set
     */
    function clearContext() external override restricted {
        address currentSender = ContextClientStorageLib.getSenderFromContext();

        if (currentSender == address(0)) {
            revert ContextNotSet();
        }

        ContextClientStorageLib.clearContextStorage();

        emit ContextCleared(currentSender);
    }

    /**
     * @notice Retrieves the sender address from the current context
     * @dev Internal view function for derived contracts to access context
     * @return address The sender address stored in the current context
     * @custom:security Ensure proper access control in derived contracts
     * @custom:access Internal function - access controlled by inheriting contracts
     */
    function _getSenderFromContext() internal view returns (address) {
        return ContextClientStorageLib.getSenderFromContext();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title ContextClientStorageLib
/// @notice Library for managing context sender storage in DeFi vault operations
/// @dev Implements a storage pattern using an isolated storage slot to maintain sender context
/// @custom:security This library is critical for maintaining caller context across contract interactions
/// @custom:security-contact security@ipor.io
library ContextClientStorageLib {
    /// @dev Unique storage slot for context sender data
    /// @dev Calculated as: keccak256(abi.encode(uint256(keccak256("io.ipor.context.client.sender.storage")) - 1)) & ~bytes32(uint256(0xff))
    /// @dev The last byte is cleared to allow for additional storage patterns
    /// @dev This specific slot ensures no storage collision with other contract storage
    /// @custom:security Uses ERC-7201 namespaced storage pattern to prevent storage collisions
    bytes32 private constant CONTEXT_SENDER_STORAGE_SLOT =
        0x68262fe08792a71a690eb5eb2de15df1b0f463dd786bf92bdbd5f0f0d1ae8b00;

    /// @dev Structure holding the context sender information
    /// @custom:storage-location erc7201:io.ipor.context.client.storage
    /// @custom:security Isolated storage pattern to prevent unauthorized access and storage collisions
    struct ContextSenderStorage {
        /// @dev The address of the current context sender
        /// @dev If address(0), no context is set, indicating direct interaction
        /// @dev Used to track the original caller across multiple contract interactions
        address contextSender;
    }

    /// @notice Sets the context sender address for the current transaction context
    /// @dev Should be called at the beginning of a context-dependent operation
    /// @dev Critical for maintaining caller context in complex vault operations
    /// @param sender_ The address to set as the context sender
    /// @custom:security Only callable by authorized contracts in the system
    /// @custom:security-risk HIGH - Incorrect context setting can lead to unauthorized access
    function setContextSender(address sender_) internal {
        ContextSenderStorage storage $ = _getContextSenderStorage();
        $.contextSender = sender_;
    }

    /// @notice Clears the current context by setting the sender to address(0)
    /// @dev Must be called at the end of context-dependent operations
    /// @dev Prevents context leaking between different operations
    /// @custom:security Critical for security to prevent context pollution
    /// @custom:security-risk MEDIUM - Failing to clear context could lead to unauthorized access
    function clearContextStorage() internal {
        ContextSenderStorage storage $ = _getContextSenderStorage();
        $.contextSender = address(0);
    }

    /// @notice Retrieves the current context sender address
    /// @dev Returns the currently set context sender without modification
    /// @return The address of the current context sender
    /// @custom:security Returns address(0) if no context is set
    function getContextSender() internal view returns (address) {
        ContextSenderStorage storage $ = _getContextSenderStorage();
        return $.contextSender;
    }

    /// @notice Verifies if a valid context sender is currently set
    /// @dev Used to determine if we're operating within a delegated context
    /// @return bool True if a valid context sender is set, false otherwise
    /// @custom:security Used for control flow in permission checks
    function isContextSenderSet() internal view returns (bool) {
        ContextSenderStorage storage $ = _getContextSenderStorage();
        return $.contextSender != address(0);
    }

    /// @notice Gets the effective sender address for the current operation
    /// @dev Core function for determining the actual caller in vault operations
    /// @return address The effective sender address (context sender or msg.sender)
    /// @custom:security Critical for access control and permission validation
    /// @custom:security-risk HIGH - Core component of permission system
    function getSenderFromContext() internal view returns (address) {
        address sender = getContextSender();

        if (sender == address(0)) {
            return msg.sender;
        }

        return sender;
    }

    /// @dev Internal function to access the context storage slot
    /// @return $ Storage pointer to the ContextSenderStorage struct
    /// @custom:security Uses assembly to access a specific storage slot
    /// @custom:security Uses ERC-7201 namespaced storage pattern
    function _getContextSenderStorage() private pure returns (ContextSenderStorage storage $) {
        assembly {
            $.slot := CONTEXT_SENDER_STORAGE_SLOT
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @title IContextClient
 * @notice Interface for contracts that need to manage sender context in vault operations
 * @dev This interface defines the core functionality for context management in the vault system
 *
 * The context system allows for:
 * - Temporary impersonation of transaction senders
 * - Secure execution of operations with delegated permissions
 * - Clean context management with setup and cleanup
 *
 * Security considerations:
 * - Only authorized contracts should be allowed to set/clear context
 * - Context should never be nested (one context at a time)
 * - Context must always be cleared after use
 * - Proper access control should be implemented by contracts using this interface
 */
interface IContextClient {
    /**
     * @notice Sets up a new context with the specified sender address
     * @param sender_ The address to be set as the context sender
     * @dev Requirements:
     * - Must be called by an authorized contract
     * - No active context should exist when setting up new context
     * - Emits ContextSet event on successful setup
     * @custom:security Should implement access control to prevent unauthorized context manipulation
     */
    function setupContext(address sender_) external;

    /**
     * @notice Clears the current active context
     * @dev Requirements:
     * - Must be called by an authorized contract
     * - An active context must exist
     * - Emits ContextCleared event on successful cleanup
     * @custom:security Should always be called after context operations are complete
     */
    function clearContext() external;

    /**
     * @notice Emitted when a new context is successfully set
     * @param sender_ The address that was set as the context sender
     * @dev This event should be monitored for context tracking and auditing
     */
    event ContextSet(address indexed sender_);

    /**
     * @notice Emitted when an active context is cleared
     * @param sender_ The address that was removed from the context
     * @dev This event should be monitored to ensure proper context cleanup
     */
    event ContextCleared(address indexed sender_);

    /**
     * @notice Expected errors that may be thrown by implementations
     * @dev Implementations should define these errors:
     * - ContextAlreadySet(): When attempting to set context while one is active
     * - ContextNotSet(): When attempting to clear or access non-existent context
     * - UnauthorizedSender(): When unauthorized address attempts to modify context
     */
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title FeeAccount
/// @notice Account contract that holds collected fees before distribution
/// @dev Each FeeAccount is dedicated to either management or performance fees
/// @dev Uses SafeERC20 for secure token operations
contract FeeAccount {
    using SafeERC20 for IERC20;

    /// @notice Error thrown when approval is attempted by non-fee manager address
    /// @dev Ensures only the designated fee manager can set token approvals
    error OnlyFeeManagerCanApprove();

    /// @notice The address of the FeeManager contract that controls this account
    /// @dev Set during construction and cannot be changed
    /// @dev This address has exclusive rights to manage token approvals
    address public immutable FEE_MANAGER;

    /// @notice Creates a new FeeAccount instance
    /// @dev Sets the immutable fee manager address
    /// @param feeManager_ Address of the FeeManager contract that will control this account
    /// @custom:security The fee manager address cannot be changed after deployment
    constructor(address feeManager_) {
        FEE_MANAGER = feeManager_;
    }

    /// @notice Approves the fee manager to spend the maximum amount of vault tokens
    /// @dev Uses force approve to handle tokens that require approval to be set to 0 first
    /// @param plasmaVault_ Address of the ERC20 vault token to approve
    /// @custom:access Only callable by the FEE_MANAGER address
    /// @custom:security Uses SafeERC20 for safe token operations
    function approveMaxForFeeManager(address plasmaVault_) external {
        if (msg.sender != FEE_MANAGER) {
            revert OnlyFeeManagerCanApprove();
        }

        IERC20(plasmaVault_).forceApprove(FEE_MANAGER, type(uint256).max);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {AccessManagedUpgradeable} from "../access/AccessManagedUpgradeable.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {FeeAccount} from "./FeeAccount.sol";
import {PlasmaVaultGovernance} from "../../vaults/PlasmaVaultGovernance.sol";
import {RecipientFee} from "./FeeManagerFactory.sol";
import {FeeManagerStorageLib, FeeRecipientDataStorage} from "./FeeManagerStorageLib.sol";
import {ContextClient} from "../context/ContextClient.sol";

/// @notice Struct containing initialization data for the fee manager
/// @param initialAuthority Address of the initial authority
/// @param plasmaVault Address of the plasma vault
/// @param iporDaoManagementFee Management fee percentage for the DAO (in percentage with 2 decimals, example 10000 is 100%, 100 is 1%)
/// @param iporDaoPerformanceFee Performance fee percentage for the DAO (in percentage with 2 decimals, example 10000 is 100%, 100 is 1%)
/// @param iporDaoFeeRecipientAddress Address of the DAO fee recipient
/// @param recipientManagementFees Array of recipient management fees
/// @param recipientPerformanceFees Array of recipient performance fees
struct FeeManagerInitData {
    address initialAuthority;
    address plasmaVault;
    uint256 iporDaoManagementFee;
    uint256 iporDaoPerformanceFee;
    address iporDaoFeeRecipientAddress;
    RecipientFee[] recipientManagementFees;
    RecipientFee[] recipientPerformanceFees;
}

/// @notice Struct containing data for a fee recipients
/// @param recipientFees Mapping of recipient addresses to their respective fee values
/// @param recipientAddresses Array of recipient addresses
struct FeeRecipientData {
    mapping(address recipient => uint256 feeValue) recipientFees;
    address[] recipientAddresses;
}

/// @notice Enum representing the type of fee
enum FeeType {
    MANAGEMENT,
    PERFORMANCE
}

/// @title FeeManager
/// @notice Manages the fees for the IporFusion protocol, including management and performance fees.
/// Total performance fee percentage is the sum of all recipients performance fees + DAO performance fee, represented in percentage with 2 decimals, example 10000 is 100%, 100 is 1%
/// Total management fee percentage is the sum of all recipients management fees + DAO management fee, represented in percentage with 2 decimals, example 10000 is 100%, 100 is 1%
/// @dev Inherits from AccessManaged for access control.
contract FeeManager is AccessManagedUpgradeable, ContextClient {
    event HarvestManagementFee(address receiver, uint256 amount);
    event HarvestPerformanceFee(address receiver, uint256 amount);
    event PerformanceFeeUpdated(uint256 totalFee, address[] recipients, uint256[] fees);
    event ManagementFeeUpdated(uint256 totalFee, address[] recipients, uint256[] fees);

    /// @notice Thrown when trying to call a function before initialization
    error NotInitialized();

    /// @notice Thrown when trying to initialize an already initialized contract
    error AlreadyInitialized();

    /// @notice Thrown when trying to set an invalid (zero) address as a fee recipient
    error InvalidFeeRecipientAddress();

    /// @notice Thrown when trying to set an invalid authority
    error InvalidAuthority();

    uint64 private constant INITIALIZED_VERSION = 10;

    /// @notice Address of the plasma vault contract
    address public immutable PLASMA_VAULT;

    /// @notice Account where performance fees are collected before distribution to recipients and DAO
    address public immutable PERFORMANCE_FEE_ACCOUNT;

    /// @notice Account where management fees are collected before distribution to recipients and DAO
    address public immutable MANAGEMENT_FEE_ACCOUNT;

    /// @notice Management fee percentage for IPOR DAO (10000 = 100%, 100 = 1%)
    uint256 public immutable IPOR_DAO_MANAGEMENT_FEE;

    /// @notice Performance fee percentage for IPOR DAO (10000 = 100%, 100 = 1%)
    uint256 public immutable IPOR_DAO_PERFORMANCE_FEE;

    modifier onlyInitialized() {
        if (_getInitializedVersion() != INITIALIZED_VERSION) {
            revert NotInitialized();
        }
        _;
    }

    constructor(FeeManagerInitData memory initData_) initializer {
        if (initData_.initialAuthority == address(0)) revert InvalidAuthority();

        super.__AccessManaged_init_unchained(initData_.initialAuthority);
        PLASMA_VAULT = initData_.plasmaVault;

        PERFORMANCE_FEE_ACCOUNT = address(new FeeAccount(address(this)));
        MANAGEMENT_FEE_ACCOUNT = address(new FeeAccount(address(this)));

        IPOR_DAO_MANAGEMENT_FEE = initData_.iporDaoManagementFee;
        IPOR_DAO_PERFORMANCE_FEE = initData_.iporDaoPerformanceFee;

        FeeManagerStorageLib.setIporDaoFeeRecipientAddress(initData_.iporDaoFeeRecipientAddress);

        uint256 totalManagementFee = IPOR_DAO_MANAGEMENT_FEE;
        uint256 totalPerformanceFee = IPOR_DAO_PERFORMANCE_FEE;

        uint256 recipientManagementFeesLength = initData_.recipientManagementFees.length;
        uint256 recipientPerformanceFeesLength = initData_.recipientPerformanceFees.length;

        if (recipientManagementFeesLength > 0) {
            address[] memory managementFeeRecipientAddresses = new address[](recipientManagementFeesLength);

            for (uint256 i; i < recipientManagementFeesLength; i++) {
                managementFeeRecipientAddresses[i] = initData_.recipientManagementFees[i].recipient;
                totalManagementFee += initData_.recipientManagementFees[i].feeValue;
                FeeManagerStorageLib.setManagementFeeRecipientFee(
                    initData_.recipientManagementFees[i].recipient,
                    initData_.recipientManagementFees[i].feeValue
                );
            }
            FeeManagerStorageLib.setManagementFeeRecipientAddresses(managementFeeRecipientAddresses);
        }

        if (recipientPerformanceFeesLength > 0) {
            address[] memory performanceFeeRecipientAddresses = new address[](recipientPerformanceFeesLength);

            for (uint256 i; i < recipientPerformanceFeesLength; i++) {
                performanceFeeRecipientAddresses[i] = initData_.recipientPerformanceFees[i].recipient;
                totalPerformanceFee += initData_.recipientPerformanceFees[i].feeValue;
                FeeManagerStorageLib.setPerformanceFeeRecipientFee(
                    initData_.recipientPerformanceFees[i].recipient,
                    initData_.recipientPerformanceFees[i].feeValue
                );
            }
            FeeManagerStorageLib.setPerformanceFeeRecipientAddresses(performanceFeeRecipientAddresses);
        }

        /// @dev Plasma Vault fees are the sum of all recipients fees + DAO fee, respectively for performance and management fees.
        /// @dev Values stored in FeeManager have to be equal to the values stored in PlasmaVault
        FeeManagerStorageLib.setPlasmaVaultTotalPerformanceFee(totalPerformanceFee);
        FeeManagerStorageLib.setPlasmaVaultTotalManagementFee(totalManagementFee);
    }

    /// @notice Initializes the FeeManager contract by setting up fee account approvals
    /// @dev Can only be called once due to reinitializer modifier
    /// @dev Sets maximum approval for both performance and management fee accounts to interact with plasma vault
    /// @dev This is required for the fee accounts to transfer tokens to recipients during fee distribution
    /// @custom:access Can only be called once during initialization
    /// @custom:error AlreadyInitialized if called after initialization
    function initialize() external reinitializer(INITIALIZED_VERSION) {
        FeeAccount(PERFORMANCE_FEE_ACCOUNT).approveMaxForFeeManager(PLASMA_VAULT);
        FeeAccount(MANAGEMENT_FEE_ACCOUNT).approveMaxForFeeManager(PLASMA_VAULT);
    }

    /// @notice Harvests both management and performance fees
    /// @dev Can be called by any address once initialized
    /// @dev This is a convenience function that calls harvestManagementFee() and harvestPerformanceFee()
    /// @custom:access Public after initialization
    function harvestAllFees() external onlyInitialized {
        harvestManagementFee();
        harvestPerformanceFee();
    }

    /// @notice Harvests the management fee and distributes it to recipients
    /// @dev Can be called by any address once initialized
    /// @dev Distributes fees proportionally based on configured fee percentages
    /// @dev First transfers the DAO portion, then distributes remaining to other recipients
    /// @custom:access Public after initialization
    function harvestManagementFee() public onlyInitialized {
        if (FeeManagerStorageLib.getIporDaoFeeRecipientAddress() == address(0)) {
            revert InvalidFeeRecipientAddress();
        }

        uint256 totalManagementFee = FeeManagerStorageLib.getPlasmaVaultTotalManagementFee();

        if (totalManagementFee == 0) {
            /// @dev If the management fee is 0, no fees are collected
            return;
        }

        uint256 managementFeeBalance = IERC4626(PLASMA_VAULT).balanceOf(MANAGEMENT_FEE_ACCOUNT);

        if (managementFeeBalance == 0) {
            /// @dev If the balance is 0, no fees are collected
            return;
        }

        uint256 remainingBalance = _transferDaoFee(
            MANAGEMENT_FEE_ACCOUNT,
            managementFeeBalance,
            totalManagementFee,
            IPOR_DAO_MANAGEMENT_FEE,
            FeeType.MANAGEMENT
        );

        if (remainingBalance == 0) {
            return;
        }

        address[] memory feeRecipientAddresses = FeeManagerStorageLib.getManagementFeeRecipientAddresses();

        uint256 feeRecipientAddressesLength = feeRecipientAddresses.length;

        for (uint256 i; i < feeRecipientAddressesLength && remainingBalance > 0; i++) {
            remainingBalance = _transferRecipientFee(
                feeRecipientAddresses[i],
                remainingBalance,
                managementFeeBalance,
                FeeManagerStorageLib.getManagementFeeRecipientFee(feeRecipientAddresses[i]),
                totalManagementFee,
                MANAGEMENT_FEE_ACCOUNT,
                FeeType.MANAGEMENT
            );
        }
    }

    /// @notice Harvests the performance fee and distributes it to recipients
    /// @dev Can be called by any address once initialized
    /// @dev Distributes fees proportionally based on configured fee percentages
    /// @dev First transfers the DAO portion, then distributes remaining to other recipients
    /// @custom:access Public after initialization
    function harvestPerformanceFee() public onlyInitialized {
        if (FeeManagerStorageLib.getIporDaoFeeRecipientAddress() == address(0)) {
            revert InvalidFeeRecipientAddress();
        }

        uint256 totalPerformanceFee = FeeManagerStorageLib.getPlasmaVaultTotalPerformanceFee();

        if (totalPerformanceFee == 0) {
            /// @dev If the performance fee is 0, no fees are collected
            return;
        }

        uint256 performanceFeeBalance = IERC4626(PLASMA_VAULT).balanceOf(PERFORMANCE_FEE_ACCOUNT);

        if (performanceFeeBalance == 0) {
            /// @dev If the balance is 0, no fees are collected
            return;
        }

        uint256 remainingBalance = _transferDaoFee(
            PERFORMANCE_FEE_ACCOUNT,
            performanceFeeBalance,
            totalPerformanceFee,
            IPOR_DAO_PERFORMANCE_FEE,
            FeeType.PERFORMANCE
        );

        if (remainingBalance == 0) {
            return;
        }

        address[] memory feeRecipientAddresses = FeeManagerStorageLib.getPerformanceFeeRecipientAddresses();

        uint256 feeRecipientAddressesLength = feeRecipientAddresses.length;

        for (uint256 i; i < feeRecipientAddressesLength && remainingBalance > 0; i++) {
            remainingBalance = _transferRecipientFee(
                feeRecipientAddresses[i],
                remainingBalance,
                performanceFeeBalance,
                FeeManagerStorageLib.getPerformanceFeeRecipientFee(feeRecipientAddresses[i]),
                totalPerformanceFee,
                PERFORMANCE_FEE_ACCOUNT,
                FeeType.PERFORMANCE
            );
        }
    }

    /// @notice Updates management fees for all recipients
    /// @dev Only callable by ATOMIST_ROLE (role id: 100)
    /// @dev Harvests existing management fees before updating
    /// @dev Total management fee will be the sum of all recipient fees + DAO fee
    /// @param recipientFees Array of recipient fees containing address and new fee value
    /// @custom:access Restricted to ATOMIST_ROLE
    function updateManagementFee(RecipientFee[] calldata recipientFees) external restricted {
        harvestManagementFee();
        _updateFees(
            recipientFees,
            FeeManagerStorageLib._managementFeeRecipientDataStorage(),
            IPOR_DAO_MANAGEMENT_FEE,
            MANAGEMENT_FEE_ACCOUNT,
            FeeType.MANAGEMENT
        );
    }

    /// @notice Updates performance fees for all recipients
    /// @dev Only callable by ATOMIST_ROLE (role id: 100)
    /// @dev Harvests existing performance fees before updating
    /// @dev Total performance fee will be the sum of all recipient fees + DAO fee
    /// @param recipientFees Array of recipient fees containing address and new fee value
    /// @custom:access Restricted to ATOMIST_ROLE
    function updatePerformanceFee(RecipientFee[] calldata recipientFees) external restricted {
        harvestPerformanceFee();
        _updateFees(
            recipientFees,
            FeeManagerStorageLib._performanceFeeRecipientDataStorage(),
            IPOR_DAO_PERFORMANCE_FEE,
            PERFORMANCE_FEE_ACCOUNT,
            FeeType.PERFORMANCE
        );
    }

    /// @notice Sets the IPOR DAO fee recipient address
    /// @dev Only callable by IPOR_DAO_ROLE (role id: 4)
    /// @dev The DAO fee recipient receives both management and performance fees allocated to the DAO
    /// @param iporDaoFeeRecipientAddress_ The address to set as the DAO fee recipient
    /// @custom:access Restricted to IPOR_DAO_ROLE
    function setIporDaoFeeRecipientAddress(address iporDaoFeeRecipientAddress_) external restricted {
        if (iporDaoFeeRecipientAddress_ == address(0)) {
            revert InvalidFeeRecipientAddress();
        }
        FeeManagerStorageLib.setIporDaoFeeRecipientAddress(iporDaoFeeRecipientAddress_);
    }

    /// @notice Internal function to completely replace existing fee recipients with new ones
    /// @dev This function will remove all existing recipients and their fees before setting up the new ones
    /// @param recipientFees Array of recipient fees containing address and new fee value
    /// @param feeData Storage reference to the fee recipient data
    /// @param daoFee The DAO fee percentage to include in total
    /// @param feeAccount The fee account address
    /// @param feeType The type of fee (MANAGEMENT or PERFORMANCE)
    function _updateFees(
        RecipientFee[] calldata recipientFees,
        FeeRecipientDataStorage storage feeData,
        uint256 daoFee,
        address feeAccount,
        FeeType feeType
    ) internal {
        uint256 totalFee = daoFee;

        address[] memory oldRecipients = feeData.recipientAddresses;

        uint256 oldRecipientsLength = oldRecipients.length;

        for (uint256 i; i < oldRecipientsLength; i++) {
            delete feeData.recipientFees[oldRecipients[i]];
        }

        delete feeData.recipientAddresses;

        address[] memory newRecipients = new address[](recipientFees.length);
        uint256[] memory newFees = new uint256[](recipientFees.length);

        uint256 recipientFeesLength = recipientFees.length;

        for (uint256 i; i < recipientFeesLength; i++) {
            if (recipientFees[i].recipient == address(0)) {
                revert InvalidFeeRecipientAddress();
            }

            newRecipients[i] = recipientFees[i].recipient;
            newFees[i] = recipientFees[i].feeValue;

            feeData.recipientFees[recipientFees[i].recipient] = recipientFees[i].feeValue;
            totalFee += recipientFees[i].feeValue;
        }

        feeData.recipientAddresses = newRecipients;

        if (feeType == FeeType.MANAGEMENT) {
            PlasmaVaultGovernance(PLASMA_VAULT).configureManagementFee(feeAccount, totalFee);
            FeeManagerStorageLib.setPlasmaVaultTotalManagementFee(totalFee);
            emit ManagementFeeUpdated(totalFee, newRecipients, newFees);
        } else {
            PlasmaVaultGovernance(PLASMA_VAULT).configurePerformanceFee(feeAccount, totalFee);
            FeeManagerStorageLib.setPlasmaVaultTotalPerformanceFee(totalFee);
            emit PerformanceFeeUpdated(totalFee, newRecipients, newFees);
        }
    }

    /// @notice Gets all management fee recipients with their fee values
    /// @dev View function accessible by anyone
    /// @return Array of RecipientFee structs containing recipient addresses and their fee values
    /// @custom:access Public view
    function getManagementFeeRecipients() external view returns (RecipientFee[] memory) {
        address[] memory recipients = FeeManagerStorageLib.getManagementFeeRecipientAddresses();
        uint256 length = recipients.length;

        RecipientFee[] memory recipientFees = new RecipientFee[](length);

        for (uint256 i; i < length; i++) {
            recipientFees[i] = RecipientFee({
                recipient: recipients[i],
                feeValue: FeeManagerStorageLib.getManagementFeeRecipientFee(recipients[i])
            });
        }

        return recipientFees;
    }

    /// @notice Gets all performance fee recipients with their fee values
    /// @dev View function accessible by anyone
    /// @return Array of RecipientFee structs containing recipient addresses and their fee values
    /// @custom:access Public view
    function getPerformanceFeeRecipients() external view returns (RecipientFee[] memory) {
        address[] memory recipients = FeeManagerStorageLib.getPerformanceFeeRecipientAddresses();
        uint256 length = recipients.length;
        RecipientFee[] memory recipientFees = new RecipientFee[](length);

        for (uint256 i; i < length; i++) {
            recipientFees[i] = RecipientFee({
                recipient: recipients[i],
                feeValue: FeeManagerStorageLib.getPerformanceFeeRecipientFee(recipients[i])
            });
        }

        return recipientFees;
    }

    /// @notice Gets the total management fee percentage
    /// @dev View function accessible by anyone
    /// @return Total management fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    /// @custom:access Public view
    function getTotalManagementFee() external view returns (uint256) {
        return FeeManagerStorageLib.getPlasmaVaultTotalManagementFee();
    }

    /// @notice Gets the total performance fee percentage
    /// @dev View function accessible by anyone
    /// @return Total performance fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    /// @custom:access Public view
    function getTotalPerformanceFee() external view returns (uint256) {
        return FeeManagerStorageLib.getPlasmaVaultTotalPerformanceFee();
    }

    /// @notice Gets the IPOR DAO fee recipient address
    /// @dev View function accessible by anyone
    /// @return The current DAO fee recipient address
    /// @custom:access Public view
    function getIporDaoFeeRecipientAddress() external view returns (address) {
        return FeeManagerStorageLib.getIporDaoFeeRecipientAddress();
    }

    /// @notice Internal function to transfer fees to the DAO
    /// @param feeAccount_ The address of the fee account
    /// @param feeBalance_ The balance of the fee account
    /// @param totalFee_ The total fee percentage
    /// @param daoFee_ The DAO fee percentage
    /// @param feeType_ The type of fee (PERFORMANCE or MANAGEMENT)
    /// @return The remaining balance after transferring fees to the DAO
    function _transferDaoFee(
        address feeAccount_,
        uint256 feeBalance_,
        uint256 totalFee_,
        uint256 daoFee_,
        FeeType feeType_
    ) internal returns (uint256) {
        uint256 decimals = IERC4626(PLASMA_VAULT).decimals();
        uint256 numberOfDecimals = 10 ** decimals;

        uint256 percentToTransferToDao_ = (daoFee_ * numberOfDecimals) / totalFee_;
        uint256 transferAmountToDao_ = Math.mulDiv(feeBalance_, percentToTransferToDao_, numberOfDecimals);

        if (transferAmountToDao_ > 0) {
            IERC4626(PLASMA_VAULT).transferFrom(
                feeAccount_,
                FeeManagerStorageLib.getIporDaoFeeRecipientAddress(),
                transferAmountToDao_
            );
            _emitHarvestEvent(FeeManagerStorageLib.getIporDaoFeeRecipientAddress(), transferAmountToDao_, feeType_);
        }

        return feeBalance_ > transferAmountToDao_ ? feeBalance_ - transferAmountToDao_ : 0;
    }

    /// @notice Internal function to emit harvest events
    /// @param recipient_ The address of the fee recipient
    /// @param amount_ The amount of fee to be harvested
    /// @param feeType_ The type of fee (PERFORMANCE or MANAGEMENT)
    function _emitHarvestEvent(address recipient_, uint256 amount_, FeeType feeType_) internal {
        if (feeType_ == FeeType.PERFORMANCE) {
            emit HarvestPerformanceFee(recipient_, amount_);
        } else {
            emit HarvestManagementFee(recipient_, amount_);
        }
    }

    /// @notice Internal function to handle fee transfer to a recipient
    /// @param recipient_ The address of the fee recipient
    /// @param remainingBalance_ Current remaining balance to distribute
    /// @param totalFeeBalance_ Total fee balance being distributed
    /// @param recipientFeeValue_ The fee value for this specific recipient
    /// @param totalFeePercentage_ Total fee percentage (management or performance)
    /// @param feeAccount_ The fee account to transfer from
    /// @param feeType_ The type of fee ("MANAGEMENT" or "PERFORMANCE")
    /// @return The new remaining balance after transfer
    function _transferRecipientFee(
        address recipient_,
        uint256 remainingBalance_,
        uint256 totalFeeBalance_,
        uint256 recipientFeeValue_,
        uint256 totalFeePercentage_,
        address feeAccount_,
        FeeType feeType_
    ) internal returns (uint256) {
        uint256 decimals = IERC4626(PLASMA_VAULT).decimals();
        uint256 numberOfDecimals = 10 ** decimals;

        uint256 recipientPercentage = (recipientFeeValue_ * numberOfDecimals) / totalFeePercentage_;
        uint256 recipientShare = Math.mulDiv(totalFeeBalance_, recipientPercentage, numberOfDecimals);

        if (recipientShare > 0) {
            if (remainingBalance_ < recipientShare) {
                recipientShare = remainingBalance_;
            }

            remainingBalance_ -= recipientShare;

            if (recipientShare > 0) {
                IERC4626(PLASMA_VAULT).transferFrom(feeAccount_, recipient_, recipientShare);
                _emitHarvestEvent(recipient_, recipientShare, feeType_);
            }
        }

        return remainingBalance_;
    }

    /// @notice Internal function to get the message sender from context
    /// @return The address of the message sender
    function _msgSender() internal view override returns (address) {
        return _getSenderFromContext();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {FeeManager, FeeManagerInitData} from "./FeeManager.sol";

/// @notice Struct containing fee configuration for a single recipient
/// @dev All fee values are stored with 2 decimal precision
/// @param recipient The address that will receive the fees
/// @param feeValue Fee percentage allocated to this recipient (10000 = 100%, 100 = 1%)
struct RecipientFee {
    address recipient;
    uint256 feeValue;
}

/// @notice Configuration parameters for initializing a new fee management system
/// @dev Used to set up initial fee structure and recipients for a plasma vault
struct FeeConfig {
    /// @notice Address of the factory contract deploying the fee manager
    address feeFactory;
    /// @notice Base management fee allocated to the IPOR DAO
    /// @dev Percentage with 2 decimal precision (10000 = 100%, 100 = 1%)
    uint256 iporDaoManagementFee;
    /// @notice Base performance fee allocated to the IPOR DAO
    /// @dev Percentage with 2 decimal precision (10000 = 100%, 100 = 1%)
    uint256 iporDaoPerformanceFee;
    /// @notice Address that receives the IPOR DAO's portion of fees
    /// @dev Must be non-zero address
    address iporDaoFeeRecipientAddress;
    /// @notice List of additional management fee recipients and their allocations
    /// @dev Total of all management fees (including DAO) must not exceed 100%
    RecipientFee[] recipientManagementFees;
    /// @notice List of additional performance fee recipients and their allocations
    /// @dev Total of all performance fees (including DAO) must not exceed 100%
    RecipientFee[] recipientPerformanceFees;
}

/// @notice Data structure containing deployed fee manager details
/// @dev Returned after successful deployment of a new fee manager
struct FeeManagerData {
    /// @notice Address of the deployed fee manager contract
    address feeManager;
    /// @notice Address of the associated plasma vault
    address plasmaVault;
    /// @notice Account that collects performance fees before distribution
    address performanceFeeAccount;
    /// @notice Account that collects management fees before distribution
    address managementFeeAccount;
    /// @notice Total management fee percentage (sum of all recipients including DAO)
    /// @dev Stored with 2 decimal precision (10000 = 100%, 100 = 1%)
    uint256 managementFee;
    /// @notice Total performance fee percentage (sum of all recipients including DAO)
    /// @dev Stored with 2 decimal precision (10000 = 100%, 100 = 1%)
    uint256 performanceFee;
}

/// @title FeeManagerFactory
/// @notice Factory contract for deploying and initializing FeeManager instances
/// @dev Creates standardized fee management systems for plasma vaults
contract FeeManagerFactory {
    /// @notice Deploys a new FeeManager contract with the specified configuration
    /// @dev Creates and initializes a new FeeManager with associated fee accounts
    /// @param initData_ Initialization parameters for the fee manager
    /// @return Data structure containing addresses and fee information of the deployed system
    /// @custom:security Validates fee recipient addresses and fee percentages during deployment
    function deployFeeManager(FeeManagerInitData memory initData_) external returns (FeeManagerData memory) {
        FeeManager feeManager = new FeeManager(initData_);

        return
            FeeManagerData({
                feeManager: address(feeManager),
                plasmaVault: feeManager.PLASMA_VAULT(),
                performanceFeeAccount: feeManager.PERFORMANCE_FEE_ACCOUNT(),
                managementFeeAccount: feeManager.MANAGEMENT_FEE_ACCOUNT(),
                managementFee: feeManager.getTotalManagementFee(),
                performanceFee: feeManager.getTotalPerformanceFee()
            });
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

error FeeManagerStorageLibZeroAddress();

/// @notice Storage structure for DAO fee recipient data
/// @dev Stores the address that receives IPOR DAO fees
struct DaoFeeRecipientDataStorage {
    address iporDaoFeeRecipientAddress;
}

// Add new event with just the new recipient
event IporDaoFeeRecipientAddressChanged(address indexed newRecipient);

/// @notice Storage structure for total performance fee in plasma vault
/// @dev Value stored with 2 decimal precision (10000 = 100%)
struct PlasmaVaultTotalPerformanceFeeStorage {
    uint256 value;
}

/// @notice Storage structure for total management fee in plasma vault
/// @dev Value stored with 2 decimal precision (10000 = 100%)
struct PlasmaVaultTotalManagementFeeStorage {
    uint256 value;
}

/// @notice Storage structure for fee recipient data
/// @dev Maps recipient addresses to their fee allocations and maintains list of recipients
struct FeeRecipientDataStorage {
    mapping(address recipient => uint256 feeValue) recipientFees;
    address[] recipientAddresses;
}

/// @title Fee Manager Storage Library
/// @notice Library for managing fee-related storage in the IPOR Protocol's plasma vault system
/// @dev Implements diamond storage pattern for fee management including performance, management, and DAO fees
library FeeManagerStorageLib {
    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.fee.manager.dao.fee.recipient.data.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant DAO_FEE_RECIPIENT_DATA_SLOT =
        0xaf522f71ce1f2b5702c38f667fa2366c184e3c6dd86ab049ad3b02fec741fd00;

    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.fee.manager.total.performance.fee.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TOTAL_PERFORMANCE_FEE_SLOT =
        0x91a7fd667a02d876183d5e3c0caf915fa5c0b6847afae1b6a2261f7bce984500;

    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.fee.manager.total.management.fee.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant TOTAL_MANAGEMENT_FEE_SLOT =
        0xcf56f35f42e69dcdff0b7b1f2e356cc5f92476bed919f8df0cdbf41f78aa1f00;

    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.fee.manager.management.fee.recipient.data.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant MANAGEMENT_FEE_RECIPIENT_DATA_SLOT =
        0xf1a2374333eb639fe6654c1bd32856f942f1f785e32d72be0c2e035f2e0f8000;

    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.fee.manager.performance.fee.recipient.data.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant PERFORMANCE_FEE_RECIPIENT_DATA_SLOT =
        0xc456e86573d79f7b5b60c9eb824345c471d5390facece9407699845c141b2d00;

    /// @notice Retrieves management fee recipient data storage
    /// @dev Uses assembly to access diamond storage pattern slot
    /// @return $ Storage pointer to FeeRecipientDataStorage
    function _managementFeeRecipientDataStorage() internal pure returns (FeeRecipientDataStorage storage $) {
        assembly {
            $.slot := MANAGEMENT_FEE_RECIPIENT_DATA_SLOT
        }
    }

    /// @notice Retrieves performance fee recipient data storage
    /// @dev Uses assembly to access diamond storage pattern slot
    /// @return $ Storage pointer to FeeRecipientDataStorage
    function _performanceFeeRecipientDataStorage() internal pure returns (FeeRecipientDataStorage storage $) {
        assembly {
            $.slot := PERFORMANCE_FEE_RECIPIENT_DATA_SLOT
        }
    }

    /// @notice Gets the total performance fee percentage for the plasma vault
    /// @return Total performance fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    function getPlasmaVaultTotalPerformanceFee() internal view returns (uint256) {
        return _totalPerformanceFeeStorage().value;
    }

    /// @notice Sets the total performance fee percentage for the plasma vault
    /// @dev Updates the total performance fee that will be distributed among recipients
    /// @param fee_ Total performance fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    function setPlasmaVaultTotalPerformanceFee(uint256 fee_) internal {
        _totalPerformanceFeeStorage().value = fee_;
    }

    /// @notice Gets the total management fee percentage for the plasma vault
    /// @return Total management fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    function getPlasmaVaultTotalManagementFee() internal view returns (uint256) {
        return _totalManagementFeeStorage().value;
    }

    /// @notice Sets the total management fee percentage for the plasma vault
    /// @param fee_ Total management fee percentage with 2 decimals (10000 = 100%, 100 = 1%)
    function setPlasmaVaultTotalManagementFee(uint256 fee_) internal {
        _totalManagementFeeStorage().value = fee_;
    }

    /// @notice Gets the fee value for a specific management fee recipient
    /// @param recipient_ The address of the recipient
    /// @return The fee value for the recipient
    function getManagementFeeRecipientFee(address recipient_) internal view returns (uint256) {
        return _managementFeeRecipientDataStorage().recipientFees[recipient_];
    }

    /// @notice Sets the fee value for a specific management fee recipient
    /// @dev Updates individual recipient's share of the total management fee
    /// @param recipient_ The address of the recipient
    /// @param feeValue_ The fee value to set, representing recipient's share of total fee
    function setManagementFeeRecipientFee(address recipient_, uint256 feeValue_) internal {
        _managementFeeRecipientDataStorage().recipientFees[recipient_] = feeValue_;
    }

    /// @notice Gets all management fee recipient addresses
    /// @return Array of recipient addresses
    function getManagementFeeRecipientAddresses() internal view returns (address[] memory) {
        return _managementFeeRecipientDataStorage().recipientAddresses;
    }

    /// @notice Sets all management fee recipient addresses
    /// @dev Overwrites the entire array of management fee recipients
    /// @param addresses_ Array of recipient addresses to set
    /// @dev Important: This replaces all existing recipients
    function setManagementFeeRecipientAddresses(address[] memory addresses_) internal {
        _managementFeeRecipientDataStorage().recipientAddresses = addresses_;
    }

    /// @notice Gets the fee value for a specific performance fee recipient
    /// @param recipient_ The address of the recipient
    /// @return The fee value for the recipient
    function getPerformanceFeeRecipientFee(address recipient_) internal view returns (uint256) {
        return _performanceFeeRecipientDataStorage().recipientFees[recipient_];
    }

    /// @notice Sets the fee value for a specific performance fee recipient
    /// @param recipient_ The address of the recipient
    /// @param feeValue_ The fee value to set
    function setPerformanceFeeRecipientFee(address recipient_, uint256 feeValue_) internal {
        _performanceFeeRecipientDataStorage().recipientFees[recipient_] = feeValue_;
    }

    /// @notice Gets all performance fee recipient addresses
    /// @return Array of recipient addresses
    function getPerformanceFeeRecipientAddresses() internal view returns (address[] memory) {
        return _performanceFeeRecipientDataStorage().recipientAddresses;
    }

    /// @notice Sets all performance fee recipient addresses
    /// @param addresses_ Array of recipient addresses to set
    function setPerformanceFeeRecipientAddresses(address[] memory addresses_) internal {
        _performanceFeeRecipientDataStorage().recipientAddresses = addresses_;
    }

    /// @notice Gets the IPOR DAO fee recipient address
    /// @return The address of the IPOR DAO fee recipient
    function getIporDaoFeeRecipientAddress() internal view returns (address) {
        return _daoFeeRecipientDataStorage().iporDaoFeeRecipientAddress;
    }

    /// @notice Sets the IPOR DAO fee recipient address
    /// @dev Updates the address that receives DAO fees and emits an event
    /// @param recipientAddress_ The address to set as the IPOR DAO fee recipient
    /// @dev Emits IporDaoFeeRecipientAddressChanged event
    function setIporDaoFeeRecipientAddress(address recipientAddress_) internal {
        _daoFeeRecipientDataStorage().iporDaoFeeRecipientAddress = recipientAddress_;
        emit IporDaoFeeRecipientAddressChanged(recipientAddress_);
    }

    function _daoFeeRecipientDataStorage() private pure returns (DaoFeeRecipientDataStorage storage $) {
        assembly {
            $.slot := DAO_FEE_RECIPIENT_DATA_SLOT
        }
    }

    function _totalPerformanceFeeStorage() private pure returns (PlasmaVaultTotalPerformanceFeeStorage storage $) {
        assembly {
            $.slot := TOTAL_PERFORMANCE_FEE_SLOT
        }
    }

    function _totalManagementFeeStorage() private pure returns (PlasmaVaultTotalManagementFeeStorage storage $) {
        assembly {
            $.slot := TOTAL_MANAGEMENT_FEE_SLOT
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {AccessManagedUpgradeable} from "../access/AccessManagedUpgradeable.sol";
import {WithdrawManagerStorageLib} from "./WithdrawManagerStorageLib.sol";
import {WithdrawRequest} from "./WithdrawManagerStorageLib.sol";
import {ContextClient} from "../context/ContextClient.sol";
import {IPlasmaVaultBase} from "../../interfaces/IPlasmaVaultBase.sol";

struct WithdrawRequestInfo {
    uint256 shares;
    uint256 endWithdrawWindowTimestamp;
    bool canWithdraw;
    uint256 withdrawWindowInSeconds;
}
/**
 * @title WithdrawManager
 * @notice Manages withdrawal requests and their processing for the IPOR Fusion protocol
 * @dev This contract handles the scheduling and execution of withdrawals with specific time windows
 *
 * Access Control:
 * - TECH_PLASMA_VAULT_ROLE: Required for canWithdrawAndUpdate
 * - ALPHA_ROLE: Required for releaseFunds
 * - ATOMIST_ROLE: Required for updateWithdrawWindow
 * - PUBLIC_ROLE: Can call request, getLastReleaseFundsTimestamp, getWithdrawWindow, and requestInfo
 */
contract WithdrawManager is AccessManagedUpgradeable, ContextClient {
    error WithdrawManagerInvalidTimestamp(uint256 timestamp);
    error WithdrawManagerInvalidSharesToRelease(
        uint256 sharesToRelease,
        uint256 shares,
        uint256 plasmaVaultBalanceOfUnallocatedShares
    );
    error WithdrawManagerZeroShares();
    error WithdrawManagerInvalidFee(uint256 fee);

    constructor(address accessManager_) initializer {
        super.__AccessManaged_init(accessManager_);
    }

    /**
     * @notice Creates a new withdrawal request
     * @dev Publicly accessible function
     * @param shares_ The amount requested for redeem, amount of shares to redeem
     * @custom:access Public
     */
    function requestShares(uint256 shares_) external {
        if (shares_ == 0) {
            revert WithdrawManagerZeroShares();
        }

        uint256 feeRate = WithdrawManagerStorageLib.getRequestFee();
        if (feeRate > 0) {
            //@dev 1e18 is the precision of the fee rate
            uint256 feeAmount = Math.mulDiv(shares_, feeRate, 1e18);
            WithdrawManagerStorageLib.updateWithdrawRequest(_msgSender(), shares_ - feeAmount);
            IPlasmaVaultBase(getPlasmaVaultAddress()).transferRequestSharesFee(_msgSender(), address(this), feeAmount);
        } else {
            WithdrawManagerStorageLib.updateWithdrawRequest(_msgSender(), shares_);
        }
    }

    /**
     * @notice Checks if the account can withdraw the specified amount from a request
     * @dev Only callable by PlasmaVault contract (TECH_PLASMA_VAULT_ROLE)
     * @param account_ The address of the account to check
     * @param shares_ The amount to check for withdrawal
     * @return bool True if the account can withdraw the specified amount, false otherwise
     * @custom:access TECH_PLASMA_VAULT_ROLE
     */
    function canWithdrawFromRequest(address account_, uint256 shares_) external restricted returns (bool) {
        uint256 releaseFundsTimestamp = WithdrawManagerStorageLib.getLastReleaseFundsTimestamp();
        WithdrawRequest memory request = WithdrawManagerStorageLib.getWithdrawRequest(account_);

        if (
            _canWithdrawFromRequest(
                request.endWithdrawWindowTimestamp,
                WithdrawManagerStorageLib.getWithdrawWindowInSeconds(),
                releaseFundsTimestamp
            ) && request.shares >= shares_
        ) {
            WithdrawManagerStorageLib.decreaseSharesFromWithdrawRequest(account_, shares_);
            WithdrawManagerStorageLib.decreaseSharesToRelease(shares_);
            return true;
        }
        return false;
    }

    /**
     * @notice Validates and calculates withdrawal fee for unallocated balance withdrawals
     * @dev Only callable by PlasmaVault contract (TECH_PLASMA_VAULT_ROLE)
     *
     * Unallocated Balance:
     * - Represents the portion of vault's assets not committed to pending withdrawal requests
     * - Calculated as: vault's total balance - sum of all pending withdrawal requests
     * - Available for immediate withdrawals without scheduling
     * - Subject to different fee structure than scheduled withdrawals
     * - Can be accessed through standard withdraw/redeem operations
     *
     * Validation Flow:
     * 1. Balance Verification
     *    - Checks PlasmaVault's total underlying token balance
     *    - Subtracts total shares pending for scheduled withdrawals
     *    - Ensures withdrawal amount + pending releases <= total unallocated balance
     *    - Prevents double-allocation of shares
     *
     * 2. Fee Calculation
     *    - Retrieves current withdraw fee rate for unallocated withdrawals
     *    - Calculates fee amount in shares
     *    - Uses WAD precision (18 decimals)
     *    - Returns 0 if no fee configured
     *
     * Security Features:
     * - Role-based access control
     * - Balance sufficiency checks
     * - Share conversion safety
     * - Withdrawal limit enforcement
     * - Protection against over-allocation
     *
     * Integration Points:
     * - PlasmaVault: Main caller and balance source
     * - ERC4626: Share/asset conversion
     * - Storage: Fee rate and pending withdrawals
     * - BurnRequestFeeFuse: Fee burning mechanism
     *
     * Important Notes:
     * - Different from scheduled withdrawal system
     * - Immediate withdrawal pathway
     * - Separate fee structure
     * - Must maintain withdrawal request safety
     * - Critical for vault liquidity management
     *
     * Error Cases:
     * - Insufficient unallocated balance
     * - Invalid share calculations
     * - Unauthorized caller
     * - Balance allocation conflicts
     *
     * @param shares_ Amount of shares attempting to withdraw from unallocated balance
     * @return feeSharesToBurn Amount of shares to be burned as fee (0 if no fee)
     * @custom:access TECH_PLASMA_VAULT_ROLE
     */
    function canWithdrawFromUnallocated(uint256 shares_) external restricted returns (uint256) {
        address plasmaVaultAddress = msg.sender;
        uint256 feeRate = WithdrawManagerStorageLib.getWithdrawFee();
        uint256 balanceOfPlasmaVault = ERC4626(ERC4626(plasmaVaultAddress).asset()).balanceOf(plasmaVaultAddress);
        uint256 plasmaVaultBalanceOfUnallocatedShares = ERC4626(plasmaVaultAddress).convertToShares(
            balanceOfPlasmaVault
        );
        uint256 sharesToRelease = WithdrawManagerStorageLib.getSharesToRelease();

        if (plasmaVaultBalanceOfUnallocatedShares < sharesToRelease + shares_) {
            revert WithdrawManagerInvalidSharesToRelease(
                sharesToRelease,
                shares_,
                plasmaVaultBalanceOfUnallocatedShares
            );
        }
        if (feeRate > 0) {
            //@dev 1e18 is the precision of the fee rate
            return Math.mulDiv(shares_, feeRate, 1e18);
        }
        return 0;
    }

    /**
     * @notice Updates the release funds timestamp to allow withdrawals after this point
     * @dev Only callable by accounts with ALPHA_ROLE
     * @param timestamp_ The timestamp to set as the release funds timestamp
     * @param sharesToRelease_ Amount of shares released
     * @dev Reverts if the provided timestamp is in the future
     * @custom:access ALPHA_ROLE
     */
    function releaseFunds(uint256 timestamp_, uint256 sharesToRelease_) external restricted {
        if (timestamp_ < block.timestamp) {
            WithdrawManagerStorageLib.releaseFunds(timestamp_, sharesToRelease_);
        } else {
            revert WithdrawManagerInvalidTimestamp(timestamp_);
        }
    }

    /**
     * @notice Gets the last timestamp when funds were released for withdrawals
     * @dev Publicly accessible function
     * @return uint256 The timestamp of the last funds release
     * @custom:access Public
     */
    function getLastReleaseFundsTimestamp() external view returns (uint256) {
        return WithdrawManagerStorageLib.getLastReleaseFundsTimestamp();
    }

    function getSharesToRelease() external view returns (uint256) {
        return WithdrawManagerStorageLib.getSharesToRelease();
    }

    /**
     * @notice Updates the withdrawal window duration
     * @dev Only callable by accounts with ATOMIST_ROLE
     * @param window_ The new withdrawal window duration in seconds
     * @custom:access ATOMIST_ROLE
     */
    function updateWithdrawWindow(uint256 window_) external restricted {
        WithdrawManagerStorageLib.updateWithdrawWindowLength(window_);
    }

    /**
     * @notice Updates the fee rate for withdrawals from unallocated balance
     * @dev Only callable by accounts with ATOMIST_ROLE
     *
     * Fee System:
     * - Fee rate is specified in WAD (18 decimals)
     * - 1e18 represents 100% fee
     * - Fee is calculated as: amount * feeRate / 1e18
     * - Collected fees are burned through BurnRequestFeeFuse
     *
     * Access Control:
     * - Restricted to ATOMIST_ROLE
     * - Critical protocol parameter
     * - Part of fee management system
     *
     * Integration Points:
     * - Used in canWithdrawFromUnallocated
     * - Affects withdrawal costs
     * - Impacts protocol revenue
     * - Connected to burn mechanism
     *
     * Security Considerations:
     * - Maximum fee rate capped at 100%
     * - State updates through storage library
     * - Event emission for tracking
     * - Access controlled operation
     *
     * Use Cases:
     * - Protocol fee adjustment
     * - Revenue model updates
     * - Market condition responses
     * - Economic parameter tuning
     *
     * @param fee_ The new fee rate in WAD (18 decimals precision, 1e18 = 100%)
     * @custom:access ATOMIST_ROLE
     */
    function updateWithdrawFee(uint256 fee_) external restricted {
        //@dev 1e18 is the 100% of the fee rate
        if (fee_ > 1e18) {
            revert WithdrawManagerInvalidFee(fee_);
        }
        WithdrawManagerStorageLib.setWithdrawFee(fee_);
    }

    function getWithdrawFee() external view returns (uint256) {
        return WithdrawManagerStorageLib.getWithdrawFee();
    }

    /**
     * @notice Updates the fee rate for withdrawal requests
     * @dev Only callable by accounts with ATOMIST_ROLE
     *
     * Fee System:
     * - Fee rate is specified in WAD (18 decimals)
     * - 1e18 represents 100% fee
     * - Fee is calculated as: shares * feeRate / 1e18
     * - Fees are transferred to WithdrawManager during requestShares
     *
     * Access Control:
     * - Restricted to ATOMIST_ROLE
     * - Critical protocol parameter
     * - Part of request fee management system
     *
     * Integration Points:
     * - Used in requestShares function
     * - Affects request costs
     * - Impacts protocol revenue
     * - Integrates with transferRequestSharesFee
     *
     * Security Considerations:
     * - Maximum fee rate capped at 100%
     * - State updates through storage library
     * - Event emission for tracking
     * - Access controlled operation
     *
     * Use Cases:
     * - Request fee adjustment
     * - Withdrawal request cost management
     * - Protocol revenue optimization
     * - Market condition adaptation
     *
     * Related Components:
     * - WithdrawManagerStorageLib
     * - PlasmaVaultBase (for fee transfers)
     * - BurnRequestFeeFuse (eventual fee burning)
     * - Access control system
     *
     * @param fee_ The new request fee rate in WAD (18 decimals precision, 1e18 = 100%)
     * @custom:access ATOMIST_ROLE
     */
    function updateRequestFee(uint256 fee_) external restricted {
        //@dev 1e18 is the 100% of the fee rate
        if (fee_ > 1e18) {
            revert WithdrawManagerInvalidFee(fee_);
        }
        WithdrawManagerStorageLib.setRequestFee(fee_);
    }

    function getRequestFee() external view returns (uint256) {
        return WithdrawManagerStorageLib.getRequestFee();
    }

    function updatePlasmaVaultAddress(address plasmaVaultAddress_) external restricted {
        WithdrawManagerStorageLib.setPlasmaVaultAddress(plasmaVaultAddress_);
    }

    function getPlasmaVaultAddress() public view returns (address) {
        return WithdrawManagerStorageLib.getPlasmaVaultAddress();
    }

    /**
     * @notice Gets the current withdrawal window duration
     * @dev Publicly accessible function
     * @return uint256 The withdrawal window duration in seconds
     * @custom:access Public
     */
    function getWithdrawWindow() external view returns (uint256) {
        return WithdrawManagerStorageLib.getWithdrawWindowInSeconds();
    }

    /**
     * @notice Gets detailed information about a withdrawal request
     * @dev Publicly accessible function
     * @param account_ The address to get withdrawal request information for
     * @return WithdrawRequestInfo Struct containing withdrawal request details
     * @custom:access Public
     */
    function requestInfo(address account_) external view returns (WithdrawRequestInfo memory) {
        uint256 withdrawWindow = WithdrawManagerStorageLib.getWithdrawWindowInSeconds();
        uint256 releaseFundsTimestamp = WithdrawManagerStorageLib.getLastReleaseFundsTimestamp();
        WithdrawRequest memory request = WithdrawManagerStorageLib.getWithdrawRequest(account_);
        return
            WithdrawRequestInfo({
                shares: request.shares,
                endWithdrawWindowTimestamp: request.endWithdrawWindowTimestamp,
                canWithdraw: _canWithdrawFromRequest(
                    request.endWithdrawWindowTimestamp,
                    withdrawWindow,
                    releaseFundsTimestamp
                ),
                withdrawWindowInSeconds: withdrawWindow
            });
    }

    function _canWithdrawFromRequest(
        uint256 endWithdrawWindowTimestamp_,
        uint256 withdrawWindow_,
        uint256 releaseFundsTimestamp_
    ) private view returns (bool) {
        /// @dev User who never requested a withdrawal can withdraw immediately, but can't withdraw from request
        if (endWithdrawWindowTimestamp_ < withdrawWindow_) {
            return false;
        }

        uint256 requestTimestamp_ = endWithdrawWindowTimestamp_ - withdrawWindow_;

        return
            block.timestamp >= requestTimestamp_ &&
            block.timestamp <= endWithdrawWindowTimestamp_ &&
            requestTimestamp_ < releaseFundsTimestamp_;
    }

    /// @notice Internal function to get the message sender from context
    /// @return The address of the message sender
    function _msgSender() internal view override returns (address) {
        return _getSenderFromContext();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

/// @notice Represents a single withdraw request from a user
/// @dev All amounts are stored in underlying token decimals
struct WithdrawRequest {
    /// @dev The requested withdrawal shares
    uint128 shares;
    /// @dev Timestamp when the withdraw window expires (requestTimeStamp + withdrawWindowInSeconds)
    uint32 endWithdrawWindowTimestamp;
}

/// @notice Storage structure for mapping user addresses to their withdraw requests
struct WithdrawRequests {
    /// @dev Maps user addresses to their active withdraw requests
    mapping(address account => WithdrawRequest request) requests;
}

/// @notice Configuration for the withdrawal time window
struct WithdrawWindow {
    /// @dev Duration of the withdraw window in seconds
    uint256 withdrawWindowInSeconds;
}

struct RequestFee {
    /// @dev The fee amount in 18 decimals precision
    uint256 fee;
}

struct WithdrawFee {
    /// @dev The fee amount in 18 decimals precision
    uint256 fee;
}

struct PlasmaVaultAddress {
    /// @dev The address of the plasma vault
    address plasmaVault;
}

/// @notice Tracks the timestamp of the last funds release
struct ReleaseFunds {
    /// @dev Timestamp of the most recent funds release
    uint32 lastReleaseFundsTimestamp;
    /// @dev Amount of funds released
    uint128 sharesToRelease;
}

/// @title WithdrawManagerStorageLib
/// @notice Library managing storage layout and operations for the withdrawal system
/// @dev Uses assembly for storage slot access and implements withdraw request lifecycle
library WithdrawManagerStorageLib {
    using SafeCast for uint256;

    /// @notice Emitted when the withdraw window length is updated
    /// @param withdrawWindowLength New length of the withdraw window in seconds
    event WithdrawWindowLengthUpdated(uint256 withdrawWindowLength);

    /// @notice Emitted when a withdraw request is created or updated
    /// @param account Address of the account making the request
    /// @param amount Amount requested for withdrawal
    /// @param endWithdrawWindow Timestamp when the withdraw window expires
    event WithdrawRequestUpdated(address account, uint256 amount, uint32 endWithdrawWindow);

    /// @notice Emitted when funds are released
    /// @param releaseTimestamp Timestamp when funds were released
    /// @param sharesToRelease Amount of funds released
    event ReleaseFundsUpdated(uint32 releaseTimestamp, uint128 sharesToRelease);

    /// @notice Thrown when attempting to set withdraw window length to zero
    error WithdrawWindowLengthCannotBeZero();
    /// @notice Thrown when attempting to release funds with an invalid amount
    error WithdrawManagerInvalidSharesToRelease(uint256 amount_);

    /// @notice Thrown when attempting to set plasma vault address to zero
    error PlasmaVaultAddressCannotBeZero();

    /// @notice Emitted when the request fee is updated
    /// @param fee New fee amount
    event RequestFeeUpdated(uint256 fee);

    /// @notice Emitted when the withdraw fee is updated
    /// @param fee New fee amount
    event WithdrawFeeUpdated(uint256 fee);

    /// @notice Emitted when the plasma vault address is updated
    /// @param plasmaVaultAddress New plasma vault address
    event PlasmaVaultAddressUpdated(address plasmaVaultAddress);

    /// @notice Thrown when attempting to release funds with an invalid timestamp
    error WithdrawManagerInvalidTimestamp(uint256 lastReleaseFundsTimestamp, uint256 newReleaseFundsTimestamp);

    // Storage slot constants
    /// @dev Storage slot for withdraw window configuration
    bytes32 private constant WITHDRAW_WINDOW_IN_SECONDS =
        0xc98a13e0ed3915d36fc042835990f5c6fbf2b2570bd63878dcd560ca2b767c00;

    /// @dev Storage slot for withdraw requests mapping
    bytes32 private constant WITHDRAW_REQUESTS = 0x5f79d61c9d5139383097775e8e8bbfd941634f6602a18bee02d4f80d80c89f00;

    /// @dev Storage slot for last release funds
    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.withdraw.manager.wirgdraw.requests")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant LAST_RELEASE_FUNDS = 0x88d141dcaacfb8523e39ee7fba7c6f591450286f42f9c7069cc072812d539200;

    /// @dev Storage slot for request fee todo check if this is correct
    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.withdraw.manager.requests.fee")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REQUEST_FEE = 0x97f346e04a16e2eb518a1ffef159e6c87d3eaa2076a90372e699cdb1af482400;

    /// @dev Storage slot for withdraw fee
    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.withdraw.manager.withdraw.fee")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant WITHDRAW_FEE = 0x1dc9c20e1601df7037c9a39067c6ecf51e88a43bc6cd86f115a2c29716b36600;

    /// @dev Storage slot for plasma vault address
    /// @dev keccak256(abi.encode(uint256(keccak256("io.ipor.withdraw.manager.plasma.vault")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PLASMA_VAULT_ADDRESS = 0xeb1948ad07cc64342983d8dc0a37729fcf2d17dcf49a1e3705ff0fa01e7d9400;

    function getRequestFee() internal view returns (uint256) {
        return _getRequestFee().fee;
    }

    function setRequestFee(uint256 fee_) internal {
        RequestFee storage requestFee = _getRequestFee();
        requestFee.fee = fee_;

        emit RequestFeeUpdated(fee_);
    }

    function getWithdrawFee() internal view returns (uint256) {
        return _getWithdrawFee().fee;
    }

    function setWithdrawFee(uint256 fee_) internal {
        WithdrawFee storage withdrawFee = _getWithdrawFee();
        withdrawFee.fee = fee_;

        emit WithdrawFeeUpdated(fee_);
    }

    /// @notice Updates the length of the withdraw window
    /// @param withdrawWindowLength_ New length of the withdraw window in seconds
    /// @dev Reverts if the new window length is zero
    function updateWithdrawWindowLength(uint256 withdrawWindowLength_) internal {
        if (withdrawWindowLength_ == 0) {
            revert WithdrawWindowLengthCannotBeZero();
        }

        WithdrawWindow storage withdrawWindow = _getWithdrawWindowLength();
        withdrawWindow.withdrawWindowInSeconds = withdrawWindowLength_;

        emit WithdrawWindowLengthUpdated(withdrawWindowLength_);
    }

    /// @notice Gets the current withdraw window length in seconds
    /// @return Current withdraw window length
    function getWithdrawWindowInSeconds() internal view returns (uint256) {
        return _getWithdrawWindowLength().withdrawWindowInSeconds;
    }

    /// @notice Retrieves a withdraw request for a specific account
    /// @param account_ Address of the account to query
    /// @return WithdrawRequest struct containing the request details
    function getWithdrawRequest(address account_) internal view returns (WithdrawRequest memory) {
        return _getWithdrawRequests().requests[account_];
    }

    /// @notice Creates or updates a withdraw request for an account
    /// @param requester_ Address creating the withdraw request
    /// @param shares_ Shares to withdraw
    /// @dev Sets endWithdrawWindowTimestamp based on current time plus window length
    function updateWithdrawRequest(address requester_, uint256 shares_) internal {
        uint256 withdrawWindowLength = getWithdrawWindowInSeconds();
        WithdrawRequest memory request = WithdrawRequest({
            shares: shares_.toUint128(),
            endWithdrawWindowTimestamp: block.timestamp.toUint32() + withdrawWindowLength.toUint32()
        });

        _getWithdrawRequests().requests[requester_] = request;

        emit WithdrawRequestUpdated(requester_, request.shares, request.endWithdrawWindowTimestamp);
    }

    function decreaseSharesFromWithdrawRequest(address account_, uint256 shares_) internal {
        WithdrawRequest memory request = getWithdrawRequest(account_);
        if (request.shares >= shares_) {
            request.shares -= shares_.toUint128();
            emit WithdrawRequestUpdated(account_, request.shares, request.endWithdrawWindowTimestamp);
        }
    }

    /// @notice Deletes a withdraw request for an account
    /// @param account_ Address whose request should be deleted
    /// @param amount_ Amount of funds released
    function deleteWithdrawRequest(address account_, uint256 amount_) internal {
        ReleaseFunds storage releaseFundsLocal = _getReleaseFunds();
        uint128 approvedAmountToRelase = releaseFundsLocal.sharesToRelease;

        if (approvedAmountToRelase >= amount_) {
            releaseFundsLocal.sharesToRelease = approvedAmountToRelase - amount_.toUint128();
            emit WithdrawRequestUpdated(account_, 0, 0);
        } else {
            revert WithdrawManagerInvalidSharesToRelease(amount_);
        }
        delete _getWithdrawRequests().requests[account_];
    }

    /// @notice Gets the timestamp of the last funds release
    /// @return Timestamp of the last funds release
    function getLastReleaseFundsTimestamp() internal view returns (uint256) {
        return _getReleaseFunds().lastReleaseFundsTimestamp;
    }

    function getSharesToRelease() internal view returns (uint256) {
        return uint256(_getReleaseFunds().sharesToRelease);
    }

    /// @notice Updates the last funds release timestamp
    /// @param newReleaseFundsTimestamp_ New release funds timestamp to set
    /// @param sharesToRelease_ Amount of funds released
    function releaseFunds(uint256 newReleaseFundsTimestamp_, uint256 sharesToRelease_) internal {
        ReleaseFunds storage releaseFundsLocal = _getReleaseFunds();

        uint256 lastReleaseFundsTimestamp = releaseFundsLocal.lastReleaseFundsTimestamp;

        if (lastReleaseFundsTimestamp > newReleaseFundsTimestamp_) {
            revert WithdrawManagerInvalidTimestamp(lastReleaseFundsTimestamp, newReleaseFundsTimestamp_);
        }

        releaseFundsLocal.lastReleaseFundsTimestamp = newReleaseFundsTimestamp_.toUint32();
        releaseFundsLocal.sharesToRelease = sharesToRelease_.toUint128();

        emit ReleaseFundsUpdated(newReleaseFundsTimestamp_.toUint32(), sharesToRelease_.toUint128());
    }

    function decreaseSharesToRelease(uint256 shares_) internal {
        ReleaseFunds storage releaseFundsLocal = _getReleaseFunds();
        if (releaseFundsLocal.sharesToRelease >= shares_) {
            releaseFundsLocal.sharesToRelease -= shares_.toUint128();
            emit ReleaseFundsUpdated(releaseFundsLocal.lastReleaseFundsTimestamp, releaseFundsLocal.sharesToRelease);
        } else {
            revert WithdrawManagerInvalidSharesToRelease(shares_);
        }
    }

    function setPlasmaVaultAddress(address plasmaVaultAddress_) internal {
        if (plasmaVaultAddress_ == address(0)) {
            revert PlasmaVaultAddressCannotBeZero();
        }

        PlasmaVaultAddress storage plasmaVaultAddress = _getPlasmaVaultAddress();
        plasmaVaultAddress.plasmaVault = plasmaVaultAddress_;

        emit PlasmaVaultAddressUpdated(plasmaVaultAddress_);
    }

    function getPlasmaVaultAddress() internal view returns (address) {
        return _getPlasmaVaultAddress().plasmaVault;
    }

    function _getRequestFee() private view returns (RequestFee storage requestFee) {
        assembly {
            requestFee.slot := REQUEST_FEE
        }
    }

    function _getWithdrawFee() private view returns (WithdrawFee storage withdrawFee) {
        assembly {
            withdrawFee.slot := WITHDRAW_FEE
        }
    }

    /// @dev Retrieves the withdraw window configuration from storage
    function _getWithdrawWindowLength() private view returns (WithdrawWindow storage withdrawWindow) {
        assembly {
            withdrawWindow.slot := WITHDRAW_WINDOW_IN_SECONDS
        }
    }

    /// @dev Retrieves the withdraw requests mapping from storage
    function _getWithdrawRequests() private view returns (WithdrawRequests storage requests) {
        assembly {
            requests.slot := WITHDRAW_REQUESTS
        }
    }

    /// @dev Retrieves the release funds timestamp from storage
    function _getReleaseFunds() private view returns (ReleaseFunds storage releaseFundsResult) {
        assembly {
            releaseFundsResult.slot := LAST_RELEASE_FUNDS
        }
    }

    function _getPlasmaVaultAddress() private view returns (PlasmaVaultAddress storage plasmaVaultAddress) {
        assembly {
            plasmaVaultAddress.slot := PLASMA_VAULT_ADDRESS
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/// @title Interface to an aggregator of price feeds for assets, responsible for providing the prices of assets in a given quote currency
interface IPriceOracleMiddleware {
    error EmptyArrayNotSupported();
    error ArrayLengthMismatch();
    error UnexpectedPriceResult();
    error UnsupportedAsset();
    error ZeroAddress(string variableName);
    error WrongDecimals();

    /// @notice Returns the price of the given asset in given decimals
    /// @return assetPrice price in QUOTE_CURRENCY of the asset
    /// @return decimals number of decimals of the asset price
    function getAssetPrice(address asset) external view returns (uint256 assetPrice, uint256 decimals);

    /// @notice Returns the prices of the given assets in given decimals
    /// @return assetPrices prices in QUOTE_CURRENCY of the assets represented in defined decimals QUOTE_CURRENCY_DECIMALS
    /// @return decimalsList number of decimals of the asset prices
    function getAssetsPrices(
        address[] calldata assets
    ) external view returns (uint256[] memory assetPrices, uint256[] memory decimalsList);

    /// @notice Returns address of source of the asset price - it could be IPOR Price Feed or Chainlink Aggregator or any other source of price for a given asset
    /// @param asset address of the asset
    /// @return address of the source of the asset price
    function getSourceOfAssetPrice(address asset) external view returns (address);

    /// @notice Sets the sources of the asset prices
    /// @param assets array of addresses of the assets
    function setAssetsPricesSources(address[] calldata assets, address[] calldata sources) external;

    /// @notice Returns the address of the quote currency to which all the prices are relative, in IPOR Fusion it is the USD
    //solhint-disable-next-line
    function QUOTE_CURRENCY() external view returns (address);

    /// @notice Returns the number of decimals of the quote currency, can be different for other types of Price Oracles Middlewares
    //solhint-disable-next-line
    function QUOTE_CURRENCY_DECIMALS() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

struct ReadResult {
    bytes data;
}

/**
 * @title UniversalReader
 * @notice A base contract for reading data from various protocols in a secure and standardized way
 * @dev This abstract contract provides a secure pattern for delegated reads from external contracts
 *      It uses a two-step read process to ensure security:
 *      1. External call to read()
 *      2. Internal delegatecall through readInternal()
 *
 * Security considerations:
 * - Uses delegatecall for reading data while maintaining context
 * - Implements access control through onlyThis modifier
 * - Prevents calls to zero address
 * - Ensures atomic read operations
 *
 * Usage:
 * - Inherit from this contract to implement protocol-specific readers
 * - Override readInternal() if custom read logic is needed
 * - Always validate target addresses before reading
 *
 * @custom:access Public
 */
abstract contract UniversalReader {
    using Address for address;

    // Custom errors
    /// @notice Thrown when attempting to interact with zero address
    error ZeroAddress();
    /// @notice Thrown when an unauthorized caller tries to access restricted functions
    error UnauthorizedCaller();

    /**
     * @dev Modifier that restricts function access to the contract itself
     * @custom:access Internal
     */
    modifier onlyThis() {
        if (msg.sender != address(this)) {
            revert UnauthorizedCaller();
        }
        _;
    }

    /**
     * @notice Performs a secure read operation on a target contract
     * @dev Uses a two-step process to safely execute delegatecall:
     *      1. Validates target address
     *      2. Executes readInternal through a static call
     *      This ensures that the read operation cannot modify state
     *
     * @param target The address of the contract to read from
     * @param data The encoded function call data to execute on the target
     * @return result The decoded result data from the read operation
     * @custom:access Public
     */
    function read(address target, bytes memory data) external view returns (ReadResult memory result) {
        if (target == address(0)) revert ZeroAddress();

        bytes memory returnData = address(this).functionStaticCall(
            abi.encodeWithSignature("readInternal(address,bytes)", target, data)
        );

        result = abi.decode(returnData, (ReadResult));
    }

    /**
     * @notice Internal function that performs the actual delegatecall to the target
     * @dev This function:
     *      - Can only be called by the contract itself
     *      - Executes the provided data on the target contract using delegatecall
     *      - Maintains the contract's context during the call
     *
     * @param target The address of the contract to delegatecall
     * @param data The encoded function call data
     * @return result The result of the delegatecall wrapped in ReadResult struct
     * @custom:access Internal - only callable by this contract
     */
    function readInternal(address target, bytes memory data) external onlyThis returns (ReadResult memory result) {
        result.data = target.functionDelegateCall(data);
        return result;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import {AuthorityUtils} from "@openzeppelin/contracts/access/manager/AuthorityUtils.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC4626Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {Errors} from "../libraries/errors/Errors.sol";
import {IporMath} from "../libraries/math/IporMath.sol";
import {IPlasmaVault, FuseAction} from "../interfaces/IPlasmaVault.sol";
import {IFuseCommon} from "../fuses/IFuseCommon.sol";
import {IPlasmaVaultBase} from "../interfaces/IPlasmaVaultBase.sol";
import {IPlasmaVaultGovernance} from "../interfaces/IPlasmaVaultGovernance.sol";
import {IPriceOracleMiddleware} from "../price_oracle/IPriceOracleMiddleware.sol";
import {IRewardsClaimManager} from "../interfaces/IRewardsClaimManager.sol";
import {AccessManagedUpgradeable} from "../managers/access/AccessManagedUpgradeable.sol";
import {PlasmaVaultStorageLib} from "../libraries/PlasmaVaultStorageLib.sol";
import {PlasmaVaultConfigLib} from "../libraries/PlasmaVaultConfigLib.sol";
import {IporFusionAccessManager} from "../managers/access/IporFusionAccessManager.sol";
import {PlasmaVaultGovernance} from "./PlasmaVaultGovernance.sol";
import {AssetDistributionProtectionLib, DataToCheck, MarketToCheck} from "../libraries/AssetDistributionProtectionLib.sol";
import {CallbackHandlerLib} from "../libraries/CallbackHandlerLib.sol";
import {FusesLib} from "../libraries/FusesLib.sol";
import {PlasmaVaultLib} from "../libraries/PlasmaVaultLib.sol";
import {FeeManagerData, FeeManagerFactory, FeeConfig, FeeConfig} from "../managers/fee/FeeManagerFactory.sol";
import {FeeManagerInitData} from "../managers/fee/FeeManager.sol";
import {WithdrawManager} from "../managers/withdraw/WithdrawManager.sol";
import {WithdrawManager} from "../managers/withdraw/WithdrawManager.sol";
import {UniversalReader} from "../universal_reader/UniversalReader.sol";
import {ContextClientStorageLib} from "../managers/context/ContextClientStorageLib.sol";
import {PreHooksHandler} from "../handlers/pre_hooks/PreHooksHandler.sol";

/// @title PlasmaVault Initialization Data Structure
/// @notice Configuration data structure used during Plasma Vault deployment and initialization
/// @dev Encapsulates all required parameters for vault setup and protocol integration
///
/// Core Configuration:
/// - Asset details (name, symbol, underlying token)
/// - Protocol integrations (fuses, markets, substrates)
/// - Fee structure and management
/// - Access control and security settings
/// - Supply cap and withdrawal parameters
///
/// Integration Components:
/// - Price Oracle: Asset valuation and share price calculation
/// - Market Substrates: Protocol-specific market identifiers
/// - Balance Fuses: Market-specific balance tracking
/// - Fee Configuration: Performance and management fee setup
///
/// Security Features:
/// - Access Manager: Permission and role management
/// - Total Supply Cap: Vault size control
/// - Withdraw Manager: Withdrawal control and validation
/// - Base Contract: Common functionality and security
///
/// Validation Requirements:
/// - Non-zero addresses for critical components
/// - Valid fee configurations within limits
/// - Properly formatted market configs
/// - Compatible protocol integrations
struct PlasmaVaultInitData {
    /// @notice Name of the vault's share token
    /// @dev Used in ERC20 token initialization
    string assetName;
    /// @notice Symbol of the vault's share token
    /// @dev Used in ERC20 token initialization
    string assetSymbol;
    /// @notice Address of the token that the vault accepts for deposits
    /// @dev Must be a valid ERC20 token contract
    address underlyingToken;
    /// @notice Address of the price oracle middleware for asset valuation
    /// @dev Must support USD as quote currency
    address priceOracleMiddleware;
    /// @notice Configuration of market-specific substrate mappings
    /// @dev Defines protocol identifiers for each integrated market
    MarketSubstratesConfig[] marketSubstratesConfigs;
    /// @notice List of protocol integration contracts (fuses)
    /// @dev Each fuse represents a specific protocol interaction capability
    address[] fuses;
    /// @notice Configuration of market-specific balance tracking fuses
    /// @dev Maps markets to their designated balance tracking contracts
    MarketBalanceFuseConfig[] balanceFuses;
    /// @notice Fee configuration for performance and management fees
    /// @dev Includes fee rates and recipient addresses
    FeeConfig feeConfig;
    /// @notice Address of the access control manager contract
    /// @dev Manages roles and permissions for vault operations
    address accessManager;
    /// @notice Address of the base contract providing common functionality
    /// @dev Implements core vault logic through delegatecall
    address plasmaVaultBase;
    /// @notice Initial maximum total supply cap in underlying token decimals
    /// @dev Controls maximum vault size and deposit limits
    uint256 totalSupplyCap;
    /// @notice Address of the withdraw manager contract
    /// @dev Controls withdrawal permissions and limits, zero address disables managed withdrawals
    address withdrawManager;
}

/// @title Market Balance Fuse Configuration
/// @notice Configuration structure linking markets with their balance tracking contracts
/// @dev Maps protocol-specific markets to their corresponding balance fuse implementations
///
/// Balance Fuse System:
/// - Tracks protocol-specific positions and balances
/// - Provides standardized balance reporting interface
/// - Supports market-specific balance calculations
/// - Enables protocol integration monitoring
///
/// Market Integration:
/// - Market ID 0: Special case for protocol-independent fuses
/// - Non-zero Market IDs: Protocol-specific market tracking
/// - Single balance fuse per market
/// - Critical for asset distribution protection
///
/// Use Cases:
/// - Protocol position tracking
/// - Market balance monitoring
/// - Asset distribution validation
/// - Protocol integration management
///
/// Security Considerations:
/// - Validates market existence
/// - Ensures fuse compatibility
/// - Prevents duplicate assignments
/// - Critical for balance integrity
struct MarketBalanceFuseConfig {
    /// @notice Identifier of the market this fuse tracks
    /// @dev Market ID 0 indicates protocol-independent functionality (e.g., flashloan fuse)
    uint256 marketId;
    /// @notice Address of the balance tracking contract
    /// @dev Must implement protocol-specific balance calculation logic
    address fuse;
}

/// @title Market Substrates Configuration
/// @notice Configuration structure defining protocol-specific identifiers for market integration
/// @dev Maps markets to their underlying components and protocol-specific identifiers
///
/// Substrate System:
/// - Defines market components and identifiers
/// - Supports multi-protocol integration
/// - Enables complex market structures
/// - Facilitates balance tracking
///
/// Substrate Types:
/// - Protocol tokens and assets
/// - LP positions and pool identifiers
/// - Market-specific parameters
/// - Protocol vault identifiers
/// - Custom protocol identifiers
///
/// Integration Context:
/// - Used by balance fuses for position tracking
/// - Supports protocol-specific calculations
/// - Enables market validation
/// - Critical for protocol interactions
///
/// Security Considerations:
/// - Validates substrate format
/// - Ensures protocol compatibility
/// - Prevents invalid configurations
/// - Maintains market integrity
struct MarketSubstratesConfig {
    /// @notice Unique identifier for the market in the vault system
    /// @dev Used to link market operations and balance tracking
    uint256 marketId;
    /// @notice Array of protocol-specific identifiers for this market
    /// @dev Can include:
    /// - Asset addresses (as bytes32)
    /// - Pool/vault identifiers
    /// - Protocol-specific parameters
    /// - Market configuration data
    bytes32[] substrates;
}

/// @title Plasma Vault - ERC4626 Compliant DeFi Integration Hub
/// @notice Advanced vault system enabling protocol integrations and asset management through fuse system
/// @dev Implements ERC4626 standard with enhanced security and multi-protocol support
///
/// Core Features:
/// - ERC4626 tokenized vault standard compliance
/// - Multi-protocol integration via fuse system
/// - Advanced access control and permissions
/// - Performance and management fee system
/// - Market-specific balance tracking
/// - Protected asset distribution
///
/// Operational Components:
/// - Fuse System: Protocol-specific integration contracts
/// - Balance Tracking: Market-specific position monitoring
/// - Fee Management: Performance and time-based fees
/// - Access Control: Role-based operation permissions
/// - Withdrawal Control: Managed withdrawal process
///
/// Security Features:
/// - Reentrancy protection
/// - Role-based access control
/// - Asset distribution limits
/// - Market balance validation
/// - Withdrawal restrictions
///
/// Integration Architecture:
/// - Delegatecall to base contract for core logic
/// - Fuse contracts for protocol interactions
/// - Price oracle for asset valuation
/// - Balance fuses for position tracking
/// - Callback system for complex operations
///
contract PlasmaVault is
    ERC20Upgradeable,
    ERC4626Upgradeable,
    ReentrancyGuardUpgradeable,
    AccessManagedUpgradeable,
    UniversalReader,
    IPlasmaVault,
    PreHooksHandler
{
    using Address for address;
    using SafeCast for int256;
    using Math for uint256;
    /// @notice ISO-4217 currency code for USD represented as address
    /// @dev 0x348 (840 in decimal) is the ISO-4217 numeric code for USD
    address private constant USD = address(0x0000000000000000000000000000000000000348);
    /// @dev Additional offset to withdraw from markets in case of rounding issues
    uint256 private constant WITHDRAW_FROM_MARKETS_OFFSET = 10;
    /// @dev 10 attempts to withdraw from markets in case of rounding issues
    uint256 private constant REDEEM_ATTEMPTS = 10;
    uint256 public constant DEFAULT_SLIPPAGE_IN_PERCENTAGE = 2;
    uint256 private constant FEE_PERCENTAGE_DECIMALS_MULTIPLIER = 1e4; /// @dev 10000 = 100% (2 decimal places for fee percentage)

    error NoSharesToRedeem();
    error NoSharesToMint();
    error NoAssetsToWithdraw();
    error NoAssetsToDeposit();
    error NoSharesToDeposit();
    error UnsupportedFuse();
    error UnsupportedMethod();
    error WithdrawManagerInvalidSharesToRelease(uint256 sharesToRelease);
    error PermitFailed();

    event ManagementFeeRealized(uint256 unrealizedFeeInUnderlying, uint256 unrealizedFeeInShares);
    event MarketBalancesUpdated(uint256[] marketIds, int256 deltaInUnderlying);

    address public immutable PLASMA_VAULT_BASE;
    uint256 private immutable _SHARE_SCALE_MULTIPLIER; /// @dev 10^_decimalsOffset() multiplier for share scaling in ERC4626

    /// @notice Initializes the Plasma Vault with core configuration and protocol integrations
    /// @dev Sets up ERC4626 vault, fuse system, and security parameters
    ///
    /// Initialization Flow:
    /// 1. ERC20/ERC4626 Setup
    ///    - Initializes share token (name, symbol)
    ///    - Configures underlying asset
    ///    - Sets up vault parameters
    ///
    /// 2. Core Components
    ///    - Delegates base initialization to PlasmaVaultBase
    ///    - Validates price oracle compatibility
    ///    - Sets up price oracle middleware
    ///
    /// 3. Protocol Integration
    ///    - Registers protocol fuses
    ///    - Configures balance tracking fuses
    ///    - Sets up market substrates
    ///
    /// 4. Fee Configuration
    ///    - Deploys fee manager
    ///    - Sets up performance fees
    ///    - Configures management fees
    ///    - Updates fee data
    ///
    /// Security Validations:
    /// - Price oracle quote currency (USD)
    /// - Non-zero addresses for critical components
    /// - Valid fee configurations
    /// - Market substrate compatibility
    ///
    /// @param initData_ Initialization parameters encapsulated in PlasmaVaultInitData struct
    constructor(PlasmaVaultInitData memory initData_) ERC20Upgradeable() ERC4626Upgradeable() initializer {
        super.__ERC20_init(initData_.assetName, initData_.assetSymbol);
        super.__ERC4626_init(IERC20(initData_.underlyingToken));

        _SHARE_SCALE_MULTIPLIER = 10 ** _decimalsOffset();

        PLASMA_VAULT_BASE = initData_.plasmaVaultBase;
        PLASMA_VAULT_BASE.functionDelegateCall(
            abi.encodeWithSelector(
                IPlasmaVaultBase.init.selector,
                initData_.assetName,
                initData_.accessManager,
                initData_.totalSupplyCap
            )
        );

        IPriceOracleMiddleware priceOracleMiddleware = IPriceOracleMiddleware(initData_.priceOracleMiddleware);

        if (priceOracleMiddleware.QUOTE_CURRENCY() != USD) {
            revert Errors.UnsupportedQuoteCurrencyFromOracle();
        }

        PlasmaVaultLib.setPriceOracleMiddleware(initData_.priceOracleMiddleware);

        PLASMA_VAULT_BASE.functionDelegateCall(
            abi.encodeWithSelector(PlasmaVaultGovernance.addFuses.selector, initData_.fuses)
        );

        for (uint256 i; i < initData_.balanceFuses.length; ++i) {
            // @dev in the moment of construction deployer has rights to add balance fuses
            PLASMA_VAULT_BASE.functionDelegateCall(
                abi.encodeWithSelector(
                    IPlasmaVaultGovernance.addBalanceFuse.selector,
                    initData_.balanceFuses[i].marketId,
                    initData_.balanceFuses[i].fuse
                )
            );
        }

        for (uint256 i; i < initData_.marketSubstratesConfigs.length; ++i) {
            PlasmaVaultConfigLib.grantMarketSubstrates(
                initData_.marketSubstratesConfigs[i].marketId,
                initData_.marketSubstratesConfigs[i].substrates
            );
        }

        FeeManagerData memory feeManagerData = FeeManagerFactory(initData_.feeConfig.feeFactory).deployFeeManager(
            FeeManagerInitData({
                initialAuthority: initData_.accessManager,
                plasmaVault: address(this),
                iporDaoManagementFee: initData_.feeConfig.iporDaoManagementFee,
                iporDaoPerformanceFee: initData_.feeConfig.iporDaoPerformanceFee,
                iporDaoFeeRecipientAddress: initData_.feeConfig.iporDaoFeeRecipientAddress,
                recipientManagementFees: initData_.feeConfig.recipientManagementFees,
                recipientPerformanceFees: initData_.feeConfig.recipientPerformanceFees
            })
        );

        PlasmaVaultLib.configurePerformanceFee(feeManagerData.performanceFeeAccount, feeManagerData.performanceFee);
        PlasmaVaultLib.configureManagementFee(feeManagerData.managementFeeAccount, feeManagerData.managementFee);

        PlasmaVaultLib.updateManagementFeeData();
        /// @dev If the address is zero, it means that scheduled withdrawals are turned off.
        PlasmaVaultLib.updateWithdrawManager(initData_.withdrawManager);
    }

    /// @notice Fallback function handling delegatecall execution and callbacks
    /// @dev Routes execution between callback handling and base contract delegation
    ///
    /// Execution Paths:
    /// 1. During Fuse Action Execution:
    ///    - Handles callbacks from protocol interactions
    ///    - Validates callback context
    ///    - Processes protocol-specific responses
    ///
    /// 2. Normal Operation:
    ///    - Delegates calls to PlasmaVaultBase
    ///    - Maintains vault functionality
    ///    - Preserves upgrade safety
    ///
    /// Security Considerations:
    /// - Validates execution context
    /// - Prevents unauthorized callbacks
    /// - Maintains delegatecall security
    /// - Protects against reentrancy
    ///
    /// @param calldata_ Raw calldata for function execution
    /// @return bytes Empty if callback, delegated result otherwise
    // solhint-disable-next-line no-unused-vars
    fallback(bytes calldata calldata_) external returns (bytes memory) {
        if (PlasmaVaultLib.isExecutionStarted()) {
            /// @dev Handle callback can be done only during the execution of the FuseActions by Alpha
            CallbackHandlerLib.handleCallback();
            return "";
        } else {
            return PLASMA_VAULT_BASE.functionDelegateCall(msg.data);
        }
    }

    /// @notice Executes a sequence of protocol interactions through fuse contracts
    /// @dev Processes multiple fuse actions while maintaining vault security and balance tracking
    ///
    /// Execution Flow:
    /// 1. Pre-execution
    ///    - Records initial total assets
    ///    - Marks execution start
    ///    - Validates fuse support
    ///
    /// 2. Action Processing
    ///    - Executes each fuse action sequentially
    ///    - Tracks affected markets
    ///    - Handles protocol interactions
    ///    - Processes callbacks if needed
    ///
    /// 3. Post-execution
    ///    - Updates market balances
    ///    - Calculates and applies performance fees
    ///    - Marks execution end
    ///    - Validates final state
    ///
    /// Security Features:
    /// - Reentrancy protection
    /// - Role-based access control
    /// - Fuse validation
    /// - Market balance verification
    /// - Asset distribution protection
    ///
    /// Market Tracking:
    /// - Maintains unique market list
    /// - Updates balances atomically
    /// - Validates market limits
    /// - Ensures balance consistency
    ///
    /// @param calls_ Array of FuseAction structs defining protocol interactions
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access Restricted to ALPHA_ROLE (managed by ATOMIST_ROLE)
    function execute(FuseAction[] calldata calls_) external override nonReentrant restricted {
        uint256 callsCount = calls_.length;
        uint256[] memory markets = new uint256[](callsCount);
        uint256 marketIndex;
        uint256 fuseMarketId;

        uint256 totalAssetsBefore = totalAssets();

        PlasmaVaultLib.executeStarted();

        for (uint256 i; i < callsCount; ++i) {
            if (!FusesLib.isFuseSupported(calls_[i].fuse)) {
                revert UnsupportedFuse();
            }

            fuseMarketId = IFuseCommon(calls_[i].fuse).MARKET_ID();

            if (_checkIfExistsMarket(markets, fuseMarketId) == false) {
                markets[marketIndex] = fuseMarketId;
                marketIndex++;
            }

            calls_[i].fuse.functionDelegateCall(calls_[i].data);
        }

        PlasmaVaultLib.executeFinished();

        _updateMarketsBalances(markets);

        _addPerformanceFee(totalAssetsBefore);
    }

    /// @notice Updates balances for specified markets and calculates performance fees
    /// @dev Refreshes market balances and applies performance fee calculations
    ///
    /// Update Flow:
    /// 1. Balance Calculation
    ///    - Retrieves current total assets
    ///    - Updates specified market balances
    ///    - Calculates performance metrics
    ///
    /// 2. Fee Processing
    ///    - Calculates performance fee
    ///    - Updates fee data
    ///    - Applies fee adjustments
    ///
    /// Security Features:
    /// - Market validation
    /// - Balance verification
    /// - Fee calculation safety
    ///
    /// @param marketIds_ Array of market IDs to update
    /// @return uint256 Updated total assets after balance refresh
    /// @custom:access Public function, no role restrictions
    function updateMarketsBalances(uint256[] calldata marketIds_) external restricted returns (uint256) {
        if (marketIds_.length == 0) {
            return totalAssets();
        }
        uint256 totalAssetsBefore = totalAssets();
        _updateMarketsBalances(marketIds_);
        _addPerformanceFee(totalAssetsBefore);

        return totalAssets();
    }

    /// @notice Returns the number of decimals used by the vault shares
    /// @dev Overrides both ERC20 and ERC4626 decimals functions to ensure consistency
    ///
    /// Decimal Handling:
    /// - Returns same decimals as underlying asset
    /// - Maintains ERC20/ERC4626 compatibility
    /// - Critical for share price calculations
    /// - Used in conversion operations
    ///
    /// Integration Context:
    /// - Share/asset conversion
    /// - Price calculations
    /// - Balance representation
    /// - Protocol interactions
    ///
    /// @return uint8 Number of decimals used for share token
    /// @custom:access Public view function, no role restrictions
    function decimals() public view virtual override(ERC20Upgradeable, ERC4626Upgradeable) returns (uint8) {
        return super.decimals();
    }

    /// @notice Transfers vault shares between addresses
    /// @dev Overrides ERC20 transfer with additional access control
    ///
    /// Transfer Mechanics:
    /// - Validates transfer permissions
    /// - Updates share balances
    /// - Maintains voting power
    /// - Enforces access control
    ///
    /// Security Features:
    /// - Role-based access control
    /// - Balance validation
    /// - State consistency checks
    /// - Voting power updates
    ///
    /// Integration Context:
    /// - Share transferability
    /// - Secondary market support
    /// - Governance participation
    /// - Protocol interactions
    ///
    /// @param to_ Recipient address for the transfer
    /// @param value_ Amount of shares to transfer
    /// @return bool Success of the transfer operation
    /// @custom:access Initially restricted, can be set to PUBLIC_ROLE via enableTransferShares
    function transfer(
        address to_,
        uint256 value_
    ) public virtual override(IERC20, ERC20Upgradeable) restricted returns (bool) {
        return super.transfer(to_, value_);
    }

    /// @notice Transfers vault shares from one address to another with allowance
    /// @dev Overrides ERC20 transferFrom with additional access control
    ///
    /// Transfer Mechanics:
    /// - Validates transfer permissions
    /// - Checks and updates allowances
    /// - Updates share balances
    /// - Maintains voting power
    ///
    /// Security Features:
    /// - Role-based access control
    /// - Allowance validation
    /// - Balance verification
    /// - State consistency checks
    ///
    /// Integration Context:
    /// - Delegated transfers
    /// - Protocol integrations
    /// - Secondary market support
    /// - Governance participation
    ///
    /// @param from_ Address to transfer shares from
    /// @param to_ Address to transfer shares to
    /// @param value_ Amount of shares to transfer
    /// @return bool Success of the transfer operation
    /// @custom:access Initially restricted, can be set to PUBLIC_ROLE via enableTransferShares
    function transferFrom(
        address from_,
        address to_,
        uint256 value_
    ) public virtual override(IERC20, ERC20Upgradeable) restricted returns (bool) {
        return super.transferFrom(from_, to_, value_);
    }

    /// @notice Deposits underlying assets into the vault
    /// @dev Handles deposit validation, share minting, and fee realization
    ///
    /// Deposit Flow:
    /// 1. Pre-deposit Checks
    ///    - Validates deposit amount
    ///    - Verifies receiver address
    ///    - Checks deposit permissions
    ///    - Validates supply cap
    ///
    /// 2. Fee Processing
    ///    - Realizes pending management fees
    ///    - Updates fee accounting
    ///    - Adjusts share calculations
    ///
    /// 3. Asset Transfer
    ///    - Transfers assets to vault
    ///    - Calculates share amount
    ///    - Mints vault shares
    ///    - Updates balances
    ///
    /// Security Features:
    /// - Non-zero amount validation
    /// - Address validation
    /// - Reentrancy protection
    /// - Access control checks
    ///
    /// @param assets_ Amount of underlying assets to deposit
    /// @param receiver_ Address to receive the minted shares
    /// @return uint256 Amount of shares minted
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access Initially restricted to WHITELIST_ROLE, can be set to PUBLIC_ROLE via convertToPublicVault
    function deposit(uint256 assets_, address receiver_) public override nonReentrant restricted returns (uint256) {
        return _deposit(assets_, receiver_);
    }

    /// @notice Deposits assets into vault using ERC20 permit for gasless approvals
    /// @dev Combines permit signature verification with deposit operation
    ///
    /// Operation Flow:
    /// 1. Permit Processing
    ///    - Verifies permit signature
    ///    - Updates token allowance
    ///    - Validates permit parameters
    ///
    /// 2. Deposit Execution
    ///    - Processes asset transfer
    ///    - Calculates share amount
    ///    - Mints vault shares
    ///    - Updates balances
    ///
    /// Security Features:
    /// - Signature validation
    /// - Deadline enforcement
    /// - Reentrancy protection
    /// - Access control checks
    ///
    /// Integration Context:
    /// - Gasless deposits
    /// - Meta-transaction support
    /// - ERC20 permit compatibility
    /// - Vault share minting
    ///
    /// @param assets_ Amount of assets to deposit
    /// @param receiver_ Address to receive the minted shares
    /// @param deadline_ Timestamp until which the signature is valid
    /// @param v_ Recovery byte of the signature
    /// @param r_ First 32 bytes of the signature
    /// @param s_ Second 32 bytes of the signature
    /// @return uint256 Amount of shares minted
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access Initially restricted to WHITELIST_ROLE, can be set to PUBLIC_ROLE via convertToPublicVault
    function depositWithPermit(
        uint256 assets_,
        address receiver_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external override nonReentrant restricted returns (uint256) {
        try IERC20Permit(asset()).permit(_msgSender(), address(this), assets_, deadline_, v_, r_, s_) {
            /// @dev Permit successful, proceed with deposit
        } catch {
            /// @dev Check if we already have sufficient allowance
            if (IERC20(asset()).allowance(_msgSender(), address(this)) < assets_) {
                revert PermitFailed();
            }
        }
        return _deposit(assets_, receiver_);
    }

    /// @notice Mints vault shares by depositing underlying assets
    /// @dev Handles share minting with management fee realization
    ///
    /// Minting Flow:
    /// 1. Pre-mint Validation
    ///    - Validates share amount
    ///    - Checks receiver address
    ///    - Verifies permissions
    ///
    /// 2. Fee Processing
    ///    - Realizes pending management fees
    ///    - Updates fee accounting
    ///    - Adjusts share calculations
    ///
    /// 3. Share Minting
    ///    - Calculates asset amount
    ///    - Transfers assets
    ///    - Mints shares
    ///    - Updates balances
    ///
    /// Security Features:
    /// - Non-zero amount validation
    /// - Address validation
    /// - Reentrancy protection
    /// - Access control checks
    ///
    /// @param shares_ Number of vault shares to mint
    /// @param receiver_ Address to receive the minted shares
    /// @return uint256 Amount of assets deposited
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access Initially restricted to WHITELIST_ROLE, can be set to PUBLIC_ROLE via convertToPublicVault
    function mint(uint256 shares_, address receiver_) public override nonReentrant restricted returns (uint256) {
        if (shares_ == 0) {
            revert NoSharesToMint();
        }

        if (receiver_ == address(0)) {
            revert Errors.WrongAddress();
        }

        _realizeManagementFee();

        return super.mint(shares_, receiver_);
    }

    /// @notice Withdraws underlying assets from the vault
    /// @dev Handles asset withdrawal with fee realization and market rebalancing
    ///
    /// Withdrawal Flow:
    /// 1. Pre-withdrawal
    ///    - Validates withdrawal amount
    ///    - Checks addresses
    ///    - Realizes management fees
    ///    - Records initial assets
    ///
    /// 2. Market Operations
    ///    - Withdraws assets from markets
    ///    - Handles rounding with offset
    ///    - Updates market balances
    ///    - Processes performance fees
    ///
    /// 3. Asset Transfer
    ///    - Burns vault shares
    ///    - Transfers assets
    ///    - Updates balances
    ///    - Validates final state
    ///
    /// Security Features:
    /// - Withdrawal limit validation
    /// - Reentrancy protection
    /// - Access control checks
    /// - Balance verification
    /// - Market safety checks
    ///
    /// @param assets_ Amount of underlying assets to withdraw
    /// @param receiver_ Address to receive the withdrawn assets
    /// @param owner_ Owner of the vault shares
    /// @return uint256 Amount of shares burned
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access PUBLIC_ROLE with WithdrawManager restrictions if enabled
    function withdraw(
        uint256 assets_,
        address receiver_,
        address owner_
    ) public override nonReentrant restricted returns (uint256) {
        if (assets_ == 0) {
            revert NoAssetsToWithdraw();
        }

        if (receiver_ == address(0) || owner_ == address(0)) {
            revert Errors.WrongAddress();
        }

        /// @dev first realize management fee, then other actions
        _realizeManagementFee();

        uint256 totalAssetsBefore = totalAssets();

        _withdrawFromMarkets(assets_ + WITHDRAW_FROM_MARKETS_OFFSET, IERC20(asset()).balanceOf(address(this)));

        _addPerformanceFee(totalAssetsBefore);

        uint256 maxAssets = maxWithdraw(owner_);

        if (assets_ > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner_, assets_, maxAssets);
        }

        address withdrawManager = PlasmaVaultStorageLib.getWithdrawManager().manager;

        uint256 shares = convertToShares(assets_);

        if (withdrawManager != address(0)) {
            uint256 feeSharesToBurn = WithdrawManager(withdrawManager).canWithdrawFromUnallocated(shares);
            if (feeSharesToBurn > 0) {
                uint256 assetsToWithdraw = assets_ - super.convertToAssets(feeSharesToBurn);

                super._withdraw(_msgSender(), receiver_, owner_, assetsToWithdraw, shares - feeSharesToBurn);
                _burn(owner_, feeSharesToBurn);
                return assetsToWithdraw;
            }
        }

        super._withdraw(_msgSender(), receiver_, owner_, assets_, shares);
        return assets_;
    }

    function previewRedeem(uint256 shares_) public view override returns (uint256) {
        address withdrawManager = PlasmaVaultStorageLib.getWithdrawManager().manager;

        if (withdrawManager != address(0)) {
            uint256 withdrawFee = WithdrawManager(withdrawManager).getWithdrawFee();
            if (withdrawFee > 0) {
                return super.previewRedeem(Math.mulDiv(shares_, 1e18 - withdrawFee, 1e18));
            }
        }

        return super.previewRedeem(shares_);
    }

    function previewWithdraw(uint256 assets_) public view override returns (uint256) {
        address withdrawManager = PlasmaVaultStorageLib.getWithdrawManager().manager;
        if (withdrawManager != address(0)) {
            /// @dev get withdraw fee in shares with 18 decimals
            uint256 withdrawFee = WithdrawManager(withdrawManager).getWithdrawFee();

            if (withdrawFee > 0) {
                return Math.mulDiv(super.previewWithdraw(assets_), 1e18, withdrawFee);
            }
        }
        return super.previewWithdraw(assets_);
    }

    /// @notice Redeems vault shares for underlying assets
    /// @dev Handles share redemption with fee realization and iterative withdrawal
    ///
    /// Redemption Flow:
    /// 1. Pre-redemption
    ///    - Validates share amount
    ///    - Checks addresses
    ///    - Realizes management fees
    ///    - Records initial state
    ///
    /// 2. Asset Withdrawal
    ///    - Calculates asset amount
    ///    - Attempts market withdrawals
    ///    - Handles slippage protection
    ///    - Retries if needed (up to REDEEM_ATTEMPTS)
    ///
    /// 3. Fee Processing
    ///    - Calculates performance metrics
    ///    - Applies performance fees
    ///    - Updates fee accounting
    ///    - Finalizes redemption
    ///
    /// Security Features:
    /// - Multiple withdrawal attempts
    /// - Slippage protection
    /// - Reentrancy guard
    /// - Balance verification
    /// - Access control checks
    ///
    /// @param shares_ Amount of vault shares to redeem
    /// @param receiver_ Address to receive the underlying assets
    /// @param owner_ Owner of the vault shares
    /// @return uint256 Amount of underlying assets withdrawn
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access PUBLIC_ROLE with WithdrawManager restrictions if enabled
    function redeem(
        uint256 shares_,
        address receiver_,
        address owner_
    ) public override nonReentrant restricted returns (uint256) {
        uint256 maxShares = maxRedeem(owner_);
        if (shares_ > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner_, shares_, maxShares);
        }

        return _redeem(shares_, receiver_, owner_, true);
    }

    function _redeem(uint256 shares_, address receiver_, address owner_, bool withFee_) internal returns (uint256) {
        if (shares_ == 0) {
            revert NoSharesToRedeem();
        }

        if (receiver_ == address(0) || owner_ == address(0)) {
            revert Errors.WrongAddress();
        }

        /// @dev first realize management fee, then other actions
        _realizeManagementFee();

        uint256 assets;
        uint256 vaultCurrentBalanceUnderlying;

        uint256 totalAssetsBefore = totalAssets();

        for (uint256 i; i < REDEEM_ATTEMPTS; ++i) {
            assets = convertToAssets(shares_);
            vaultCurrentBalanceUnderlying = IERC20(asset()).balanceOf(address(this));
            if (vaultCurrentBalanceUnderlying >= assets) {
                break;
            }
            _withdrawFromMarkets(_includeSlippage(assets), vaultCurrentBalanceUnderlying);
        }

        _addPerformanceFee(totalAssetsBefore);

        address withdrawManager = PlasmaVaultStorageLib.getWithdrawManager().manager;

        if (!withFee_ || withdrawManager == address(0)) {
            uint256 assetsToWithdraw = convertToAssets(shares_);
            _withdraw(_msgSender(), receiver_, owner_, assetsToWithdraw, shares_);
            return assetsToWithdraw;
        }

        uint256 feeSharesToBurn = WithdrawManager(withdrawManager).canWithdrawFromUnallocated(shares_);

        if (feeSharesToBurn == 0) {
            uint256 assetsToWithdraw = convertToAssets(shares_);
            _withdraw(_msgSender(), receiver_, owner_, assetsToWithdraw, shares_);
            return assetsToWithdraw;
        }

        uint256 redeemAmount = super.redeem(shares_, receiver_, owner_);
        _burn(owner_, feeSharesToBurn);
        return redeemAmount;
    }

    /// @notice Redeems shares from a previously submitted withdrawal request
    /// @dev Processes redemption of shares that were part of an approved withdrawal request
    ///
    /// Redemption Flow:
    /// 1. Request Validation
    ///    - Verifies request exists via WithdrawManager
    ///    - Checks withdrawal window timing
    ///    - Validates share amount availability
    ///    - Confirms release funds timestamp
    ///
    /// 2. Share Processing
    ///    - Executes share redemption
    ///    - Handles asset transfer
    ///    - Updates request state
    ///    - No fee application (unlike standard redeem)
    ///
    /// Security Features:
    /// - Request-based access control
    /// - Withdrawal window enforcement
    /// - Share amount validation
    /// - State consistency checks
    /// - Atomic execution
    ///
    /// Integration Points:
    /// - WithdrawManager for request validation
    /// - ERC4626 share redemption
    /// - Asset transfer system
    /// - Balance tracking
    ///
    /// Important Notes:
    /// - Different from standard redeem
    /// - No withdrawal fee applied
    /// - Requires prior request
    /// - Time-window restricted
    /// - Request-bound redemption
    ///
    /// @param shares_ Amount of shares to redeem from the request
    /// @param receiver_ Address to receive the underlying assets
    /// @param owner_ Owner of the shares being redeemed
    /// @return uint256 Amount of underlying assets transferred to receiver
    /// @custom:access Restricted to accounts with valid withdrawal requests
    function redeemFromRequest(
        uint256 shares_,
        address receiver_,
        address owner_
    ) external override restricted returns (uint256) {
        bool canWithdraw = WithdrawManager(PlasmaVaultStorageLib.getWithdrawManager().manager).canWithdrawFromRequest(
            owner_,
            shares_
        );

        if (!canWithdraw) {
            revert WithdrawManagerInvalidSharesToRelease(shares_);
        }

        uint256 maxShares = maxRedeem(owner_);

        if (shares_ > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner_, shares_, maxShares);
        }

        return _redeem(shares_, receiver_, owner_, false);
    }

    /// @notice Calculates maximum deposit amount allowed for an address
    /// @dev Overrides ERC4626 maxDeposit considering total supply cap
    ///
    /// Calculation Flow:
    /// 1. Supply Validation
    ///    - Retrieves total supply cap
    ///    - Gets current total supply
    ///    - Checks available capacity
    ///
    /// 2. Conversion Logic
    ///    - Calculates remaining space
    ///    - Converts to asset amount
    ///    - Handles edge cases
    ///
    /// Constraints:
    /// - Returns 0 if cap is reached
    /// - Respects supply cap limits
    /// - Considers share/asset ratio
    /// - Maintains vault integrity
    ///
    /// @return uint256 Maximum amount of assets that can be deposited
    /// @custom:access Public view function, no role restrictions
    function maxDeposit(address) public view virtual override returns (uint256) {
        uint256 totalSupplyCap = PlasmaVaultLib.getTotalSupplyCap();
        uint256 totalSupply = totalSupply();

        if (totalSupply >= totalSupplyCap) {
            return 0;
        }
        return convertToAssets(totalSupplyCap - totalSupply);
    }

    /// @notice Calculates maximum number of shares that can be minted
    /// @dev Overrides ERC4626 maxMint considering total supply cap
    ///
    /// Calculation Flow:
    /// 1. Supply Validation
    ///    - Retrieves total supply cap
    ///    - Gets current total supply
    ///    - Validates remaining capacity
    ///
    /// 2. Share Calculation
    ///    - Computes available share space
    ///    - Handles cap constraints
    ///    - Returns maximum mintable shares
    ///
    /// Constraints:
    /// - Returns 0 if cap is reached
    /// - Respects total supply limit
    /// - Direct share calculation
    /// - No asset conversion needed
    ///
    /// @return uint256 Maximum number of shares that can be minted
    /// @custom:access Public view function, no role restrictions
    function maxMint(address) public view virtual override returns (uint256) {
        uint256 totalSupplyCap = PlasmaVaultLib.getTotalSupplyCap();
        uint256 totalSupply = totalSupply();

        if (totalSupply >= totalSupplyCap) {
            return 0;
        }

        return totalSupplyCap - totalSupply;
    }

    /// @notice Claims rewards from integrated protocols through fuse contracts
    /// @dev Executes reward claiming operations via delegatecall to fuses
    ///
    /// Claiming Flow:
    /// 1. Pre-claim Validation
    ///    - Validates fuse actions
    ///    - Checks permissions
    ///    - Prepares claim context
    ///
    /// 2. Reward Processing
    ///    - Executes claim operations
    ///    - Handles protocol interactions
    ///    - Processes reward tokens
    ///    - Updates reward balances
    ///
    /// Security Features:
    /// - Reentrancy protection
    /// - Role-based access
    /// - Delegatecall safety
    /// - Protocol validation
    ///
    /// @param calls_ Array of FuseAction structs defining reward claim operations
    /// @custom:security Non-reentrant and role-restricted
    /// @custom:access Restricted to TECH_REWARDS_CLAIM_MANAGER_ROLE (managed by TECH_REWARDS_CLAIM_MANAGER_ROLE)
    function claimRewards(FuseAction[] calldata calls_) external override nonReentrant restricted {
        uint256 callsCount = calls_.length;
        for (uint256 i; i < callsCount; ++i) {
            calls_[i].fuse.functionDelegateCall(calls_[i].data);
        }
    }

    /// @notice Returns the total assets in the vault
    /// @dev Calculates net total assets after management fee deduction
    ///
    /// Calculation Flow:
    /// 1. Gross Assets
    ///    - Retrieves vault balance
    ///    - Adds market positions
    ///    - Includes pending operations
    ///
    /// 2. Fee Deduction
    ///    - Calculates unrealized management fees
    ///    - Subtracts from gross total
    ///    - Handles edge cases
    ///
    /// Important Notes:
    /// - Excludes runtime accrued market interest
    /// - Excludes runtime accrued performance fees
    /// - Considers management fee impact
    /// - Returns 0 if fees exceed assets
    ///
    /// @return uint256 Net total assets in underlying token decimals
    /// @custom:access Public view function, no role restrictions
    function totalAssets() public view virtual override returns (uint256) {
        uint256 grossTotalAssets = _getGrossTotalAssets();
        uint256 unrealizedManagementFee = _getUnrealizedManagementFee(grossTotalAssets);

        if (unrealizedManagementFee >= grossTotalAssets) {
            return 0;
        } else {
            return grossTotalAssets - unrealizedManagementFee;
        }
    }

    /// @notice Returns the total assets in the vault for a specific market
    /// @dev Provides market-specific asset tracking without considering fees
    ///
    /// Balance Tracking:
    /// 1. Market Assets
    ///    - Protocol-specific positions
    ///    - Deposited collateral
    ///    - Earned yields
    ///    - Pending operations
    ///
    /// Integration Context:
    /// - Used by balance fuses
    /// - Market limit validation
    /// - Asset distribution checks
    /// - Withdrawal calculations
    ///
    /// Important Notes:
    /// - Raw balance without fees
    /// - Updated by balance fuses
    /// - Market-specific tracking
    /// - Critical for distribution
    ///
    /// @param marketId_ Identifier of the market to query
    /// @return uint256 Total assets in the market in underlying token decimals
    /// @custom:access Public view function, no role restrictions
    function totalAssetsInMarket(uint256 marketId_) public view virtual returns (uint256) {
        return PlasmaVaultLib.getTotalAssetsInMarket(marketId_);
    }

    /// @notice Returns the current unrealized management fee
    /// @dev Calculates accrued management fees since last fee realization
    ///
    /// Calculation Flow:
    /// 1. Fee Computation
    ///    - Gets gross total assets
    ///    - Retrieves fee configuration
    ///    - Calculates time-based accrual
    ///    - Applies fee percentage
    ///
    /// Fee Components:
    /// - Time elapsed since last update
    /// - Current total assets
    /// - Management fee rate
    /// - Fee recipient settings
    ///
    /// Important Notes:
    /// - Pro-rata time calculation
    /// - Based on current assets
    /// - Unrealized until claimed
    /// - Affects total assets
    ///
    /// @return uint256 Unrealized management fee in underlying token decimals
    /// @custom:access Public view function, no role restrictions
    function getUnrealizedManagementFee() public view returns (uint256) {
        return _getUnrealizedManagementFee(_getGrossTotalAssets());
    }

    /// @notice Reserved function for PlasmaVaultBase delegatecall operations
    /// @dev Prevents direct calls to updateInternal, only accessible via delegatecall
    ///
    /// Security Features:
    /// - Blocks direct execution
    /// - Preserves upgrade safety
    /// - Maintains access control
    /// - Protects vault integrity
    ///
    /// Error Handling:
    /// - Reverts with UnsupportedMethod
    /// - Prevents unauthorized updates
    /// - Guards against direct calls
    /// - Maintains security model
    ///
    /// @custom:access Internal function, reverts on direct calls
    function updateInternal(address, address, uint256) public {
        revert UnsupportedMethod();
    }

    /// @notice Internal execution function for delegated protocol interactions
    /// @dev Handles fuse actions without performance fee calculations
    ///
    /// Execution Flow:
    /// 1. Caller Validation
    ///    - Verifies self-call only
    ///    - Prevents external access
    ///    - Maintains security model
    ///
    /// 2. Action Processing
    ///    - Validates fuse support
    ///    - Tracks affected markets
    ///    - Executes protocol actions
    ///    - Updates market balances
    ///
    /// Security Features:
    /// - Self-call restriction
    /// - Fuse validation
    /// - Market tracking
    /// - Balance updates
    ///
    /// @param calls_ Array of FuseAction structs defining protocol interactions
    /// @custom:access Internal function, self-call only
    function executeInternal(FuseAction[] calldata calls_) external {
        if (address(this) != msg.sender) {
            revert Errors.WrongCaller(msg.sender);
        }
        uint256 callsCount = calls_.length;
        uint256[] memory markets = new uint256[](callsCount);
        uint256 marketIndex;
        uint256 fuseMarketId;

        for (uint256 i; i < callsCount; ++i) {
            if (!FusesLib.isFuseSupported(calls_[i].fuse)) {
                revert UnsupportedFuse();
            }

            fuseMarketId = IFuseCommon(calls_[i].fuse).MARKET_ID();

            if (_checkIfExistsMarket(markets, fuseMarketId) == false) {
                markets[marketIndex] = fuseMarketId;
                marketIndex++;
            }

            calls_[i].fuse.functionDelegateCall(calls_[i].data);
        }
        _updateMarketsBalances(markets);
    }

    function _deposit(uint256 assets_, address receiver_) internal returns (uint256) {
        if (assets_ == 0) {
            revert NoAssetsToDeposit();
        }
        if (receiver_ == address(0)) {
            revert Errors.WrongAddress();
        }

        _realizeManagementFee();

        uint256 shares = super.deposit(assets_, receiver_);

        if (shares == 0) {
            revert NoSharesToDeposit();
        }

        return shares;
    }

    function _addPerformanceFee(uint256 totalAssetsBefore_) internal {
        uint256 totalAssetsAfter = totalAssets();

        if (totalAssetsAfter < totalAssetsBefore_) {
            return;
        }

        PlasmaVaultStorageLib.PerformanceFeeData memory feeData = PlasmaVaultLib.getPerformanceFeeData();

        uint256 fee = Math.mulDiv(
            totalAssetsAfter - totalAssetsBefore_,
            feeData.feeInPercentage,
            FEE_PERCENTAGE_DECIMALS_MULTIPLIER
        );

        /// @dev total supply cap validation is disabled for fee minting
        PlasmaVaultLib.setTotalSupplyCapValidation(1);

        _mint(feeData.feeAccount, convertToShares(fee));

        /// @dev total supply cap validation is enabled when fee minting is finished
        PlasmaVaultLib.setTotalSupplyCapValidation(0);
    }

    function _realizeManagementFee() internal {
        PlasmaVaultStorageLib.ManagementFeeData memory feeData = PlasmaVaultLib.getManagementFeeData();

        uint256 unrealizedFeeInUnderlying = getUnrealizedManagementFee();

        PlasmaVaultLib.updateManagementFeeData();

        uint256 unrealizedFeeInShares = convertToShares(unrealizedFeeInUnderlying);

        if (unrealizedFeeInShares == 0) {
            return;
        }

        /// @dev minting is an act of management fee realization
        /// @dev total supply cap validation is disabled for fee minting
        PlasmaVaultLib.setTotalSupplyCapValidation(1);

        _mint(feeData.feeAccount, unrealizedFeeInShares);

        /// @dev total supply cap validation is enabled when fee minting is finished
        PlasmaVaultLib.setTotalSupplyCapValidation(0);

        emit ManagementFeeRealized(unrealizedFeeInUnderlying, unrealizedFeeInShares);
    }

    function _includeSlippage(uint256 value_) internal pure returns (uint256) {
        /// @dev increase value by DEFAULT_SLIPPAGE_IN_PERCENTAGE to cover potential slippage
        return value_ + IporMath.division(value_ * DEFAULT_SLIPPAGE_IN_PERCENTAGE, 100);
    }

    /// @notice Withdraw assets from the markets
    /// @param assets_ Amount of assets to withdraw
    /// @param vaultCurrentBalanceUnderlying_ Current balance of the vault in underlying token
    function _withdrawFromMarkets(uint256 assets_, uint256 vaultCurrentBalanceUnderlying_) internal {
        if (assets_ == 0) {
            return;
        }

        uint256 left;

        if (assets_ >= vaultCurrentBalanceUnderlying_) {
            uint256 marketIndex;
            uint256 fuseMarketId;

            bytes32[] memory params;

            /// @dev assume that the same fuse can be used multiple times
            /// @dev assume that more than one fuse can be from the same market
            address[] memory fuses = PlasmaVaultLib.getInstantWithdrawalFuses();

            uint256[] memory markets = new uint256[](fuses.length);

            left = assets_ - vaultCurrentBalanceUnderlying_;

            uint256 balanceOf;
            uint256 fusesLength = fuses.length;

            for (uint256 i; left != 0 && i < fusesLength; ++i) {
                params = PlasmaVaultLib.getInstantWithdrawalFusesParams(fuses[i], i);

                /// @dev always first param is amount, by default is 0 in storage, set to left
                params[0] = bytes32(left);

                fuses[i].functionDelegateCall(abi.encodeWithSignature("instantWithdraw(bytes32[])", params));

                balanceOf = IERC20(asset()).balanceOf(address(this));

                if (assets_ > balanceOf) {
                    left = assets_ - balanceOf;
                } else {
                    left = 0;
                }

                fuseMarketId = IFuseCommon(fuses[i]).MARKET_ID();

                if (_checkIfExistsMarket(markets, fuseMarketId) == false) {
                    markets[marketIndex] = fuseMarketId;
                    marketIndex++;
                }
            }

            _updateMarketsBalances(markets);
        }
    }

    /// @notice Update balances in the vault for markets touched by the fuses during the execution of all FuseActions
    /// @param markets_ Array of market ids touched by the fuses in the FuseActions
    function _updateMarketsBalances(uint256[] memory markets_) internal {
        uint256 wadBalanceAmountInUSD;
        DataToCheck memory dataToCheck;
        address balanceFuse;
        int256 deltasInUnderlying;
        uint256[] memory markets = _checkBalanceFusesDependencies(markets_);
        uint256 marketsLength = markets.length;

        /// @dev USD price is represented in 8 decimals
        (uint256 underlyingAssetPrice, uint256 underlyingAssePriceDecimals) = IPriceOracleMiddleware(
            PlasmaVaultLib.getPriceOracleMiddleware()
        ).getAssetPrice(asset());

        dataToCheck.marketsToCheck = new MarketToCheck[](marketsLength);

        for (uint256 i; i < marketsLength; ++i) {
            if (markets[i] == 0) {
                break;
            }

            balanceFuse = FusesLib.getBalanceFuse(markets[i]);

            wadBalanceAmountInUSD = abi.decode(
                balanceFuse.functionDelegateCall(abi.encodeWithSignature("balanceOf()")),
                (uint256)
            );
            dataToCheck.marketsToCheck[i].marketId = markets[i];

            dataToCheck.marketsToCheck[i].balanceInMarket = IporMath.convertWadToAssetDecimals(
                IporMath.division(
                    wadBalanceAmountInUSD * IporMath.BASIS_OF_POWER ** underlyingAssePriceDecimals,
                    underlyingAssetPrice
                ),
                (decimals() - _decimalsOffset())
            );

            deltasInUnderlying =
                deltasInUnderlying +
                PlasmaVaultLib.updateTotalAssetsInMarket(markets[i], dataToCheck.marketsToCheck[i].balanceInMarket);
        }

        if (deltasInUnderlying != 0) {
            PlasmaVaultLib.addToTotalAssetsInAllMarkets(deltasInUnderlying);
        }

        dataToCheck.totalBalanceInVault = _getGrossTotalAssets();

        AssetDistributionProtectionLib.checkLimits(dataToCheck);

        emit MarketBalancesUpdated(markets, deltasInUnderlying);
    }

    function _checkBalanceFusesDependencies(uint256[] memory markets_) internal view returns (uint256[] memory) {
        uint256 marketsLength = markets_.length;
        if (marketsLength == 0) {
            return markets_;
        }
        uint256[] memory marketsChecked = new uint256[](marketsLength * 2);
        uint256[] memory marketsToCheck = markets_;
        uint256 index;
        uint256[] memory tempMarketsToCheck;

        while (marketsToCheck.length > 0) {
            tempMarketsToCheck = new uint256[](marketsLength * 2);
            uint256 tempIndex;

            for (uint256 i; i < marketsToCheck.length; ++i) {
                if (!_checkIfExistsMarket(marketsChecked, marketsToCheck[i])) {
                    if (marketsChecked.length == index) {
                        marketsChecked = _increaseArray(marketsChecked, marketsChecked.length * 2);
                    }

                    marketsChecked[index] = marketsToCheck[i];
                    ++index;

                    uint256 dependentMarketsLength = PlasmaVaultLib.getDependencyBalanceGraph(marketsToCheck[i]).length;
                    if (dependentMarketsLength > 0) {
                        for (uint256 j; j < dependentMarketsLength; ++j) {
                            if (tempMarketsToCheck.length == tempIndex) {
                                tempMarketsToCheck = _increaseArray(tempMarketsToCheck, tempMarketsToCheck.length * 2);
                            }
                            tempMarketsToCheck[tempIndex] = PlasmaVaultLib.getDependencyBalanceGraph(marketsToCheck[i])[
                                j
                            ];
                            ++tempIndex;
                        }
                    }
                }
            }
            marketsToCheck = _getUniqueElements(tempMarketsToCheck);
        }

        return _getUniqueElements(marketsChecked);
    }

    function _increaseArray(uint256[] memory arr_, uint256 newSize_) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](newSize_);
        for (uint256 i; i < arr_.length; ++i) {
            result[i] = arr_[i];
        }
        return result;
    }

    function _concatArrays(
        uint256[] memory arr1_,
        uint256[] memory arr2_,
        uint256 lengthOfNewArray_
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](lengthOfNewArray_);
        uint256 i;
        uint256 lengthOfArr1 = arr1_.length;

        for (i; i < lengthOfArr1; ++i) {
            result[i] = arr1_[i];
        }

        for (uint256 j; i < lengthOfNewArray_; ++j) {
            result[i] = arr2_[j];
            ++i;
        }
        return result;
    }

    function _checkIfExistsMarket(uint256[] memory markets_, uint256 marketId_) internal pure returns (bool exists) {
        for (uint256 i; i < markets_.length; ++i) {
            if (markets_[i] == 0) {
                break;
            }
            if (markets_[i] == marketId_) {
                exists = true;
                break;
            }
        }
    }

    function _getGrossTotalAssets() internal view returns (uint256) {
        address rewardsClaimManagerAddress = PlasmaVaultLib.getRewardsClaimManagerAddress();

        if (rewardsClaimManagerAddress != address(0)) {
            return
                IERC20(asset()).balanceOf(address(this)) +
                PlasmaVaultLib.getTotalAssetsInAllMarkets() +
                IRewardsClaimManager(rewardsClaimManagerAddress).balanceOf();
        }
        return IERC20(asset()).balanceOf(address(this)) + PlasmaVaultLib.getTotalAssetsInAllMarkets();
    }

    function _getUnrealizedManagementFee(uint256 totalAssets_) internal view returns (uint256) {
        PlasmaVaultStorageLib.ManagementFeeData memory feeData = PlasmaVaultLib.getManagementFeeData();

        uint256 blockTimestamp = block.timestamp;

        if (
            feeData.feeInPercentage == 0 ||
            feeData.lastUpdateTimestamp == 0 ||
            blockTimestamp <= feeData.lastUpdateTimestamp
        ) {
            return 0;
        }
        return
            Math.mulDiv(
                totalAssets_ * (blockTimestamp - feeData.lastUpdateTimestamp),
                feeData.feeInPercentage,
                365 days * FEE_PERCENTAGE_DECIMALS_MULTIPLIER
            );
    }

    /**
     * @dev Reverts if the caller is not allowed to call the function identified by a selector. Panics if the calldata
     * is less than 4 bytes long.
     */
    function _checkCanCall(address caller_, bytes calldata data_) internal virtual override {
        bytes4 sig = bytes4(data_[0:4]);
        bool immediate;
        uint32 delay;

        if (this.transferFrom.selector == sig) {
            (address tranferFromAddress, , ) = abi.decode(_msgData()[4:], (address, address, uint256));

            /// @dev check if the owner of shares has access to transfer
            IporFusionAccessManager(authority()).canCallAndUpdate(tranferFromAddress, address(this), sig);

            /// @dev check if the caller has access to transferFrom method
            (immediate, delay) = IporFusionAccessManager(authority()).canCallAndUpdate(caller_, address(this), sig);
        } else if (this.deposit.selector == sig || this.mint.selector == sig) {
            (, address receiver) = abi.decode(_msgData()[4:], (uint256, address));

            /// @dev check if the receiver of shares has access to deposit or mint and setup delay
            IporFusionAccessManager(authority()).canCallAndUpdate(receiver, address(this), sig);
            /// @dev check if the caller has access to deposit or mint and setup delay
            (immediate, delay) = AuthorityUtils.canCallWithDelay(authority(), caller_, address(this), sig);
        } else if (this.depositWithPermit.selector == sig) {
            (, address receiver, , , , ) = abi.decode(
                _msgData()[4:],
                (uint256, address, uint256, uint8, bytes32, bytes32)
            );

            /// @dev check if the receiver of shares has access to depositWithPermit and setup delay
            IporFusionAccessManager(authority()).canCallAndUpdate(receiver, address(this), sig);
            /// @dev check if the caller has access to depositWithPermit and setup delay
            (immediate, delay) = AuthorityUtils.canCallWithDelay(authority(), caller_, address(this), sig);
        } else if (this.redeem.selector == sig || this.withdraw.selector == sig) {
            (, , address owner) = abi.decode(_msgData()[4:], (uint256, address, address));

            /// @dev check if the owner of shares has access to redeem or withdraw and setup delay
            IporFusionAccessManager(authority()).canCallAndUpdate(owner, address(this), sig);

            (immediate, delay) = IporFusionAccessManager(authority()).canCallAndUpdate(caller_, address(this), sig);
        } else if (this.transfer.selector == sig) {
            (immediate, delay) = IporFusionAccessManager(authority()).canCallAndUpdate(caller_, address(this), sig);
        } else {
            (immediate, delay) = AuthorityUtils.canCallWithDelay(authority(), caller_, address(this), sig);
        }

        if (!immediate) {
            if (delay > 0) {
                AccessManagedStorage storage $ = _getAccessManagedStorage();
                $._consumingSchedule = true;
                IAccessManager(authority()).consumeScheduledOp(caller_, data_);
                $._consumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller_);
            }
        }

        _runPreHook(sig);
    }

    function _msgSender() internal view override returns (address) {
        return ContextClientStorageLib.getSenderFromContext();
    }

    function _update(address from_, address to_, uint256 value_) internal virtual override {
        PLASMA_VAULT_BASE.functionDelegateCall(
            abi.encodeWithSelector(IPlasmaVaultBase.updateInternal.selector, from_, to_, value_)
        );
    }

    function _decimalsOffset() internal view virtual override returns (uint8) {
        return PlasmaVaultLib.DECIMALS_OFFSET;
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual override returns (uint256) {
        uint256 supply = totalSupply();

        return
            supply == 0
                ? assets * _SHARE_SCALE_MULTIPLIER
                : assets.mulDiv(supply + _SHARE_SCALE_MULTIPLIER, totalAssets() + 1, rounding);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual override returns (uint256) {
        uint256 supply = totalSupply();

        return
            supply == 0
                ? shares.mulDiv(1, _SHARE_SCALE_MULTIPLIER, rounding)
                : shares.mulDiv(totalAssets() + 1, supply + _SHARE_SCALE_MULTIPLIER, rounding);
    }

    /// @dev Notice! Amount are assets when withdraw or shares when redeem
    function _extractAmountFromWithdrawAndRedeem() private view returns (uint256) {
        (uint256 amount, , ) = abi.decode(_msgData()[4:], (uint256, address, address));
        return amount;
    }

    function _contains(uint256[] memory array_, uint256 element_, uint256 count_) private pure returns (bool) {
        for (uint256 i; i < count_; ++i) {
            if (array_[i] == element_) {
                return true;
            }
        }
        return false;
    }

    function _getUniqueElements(uint256[] memory inputArray_) private pure returns (uint256[] memory) {
        uint256[] memory tempArray = new uint256[](inputArray_.length);
        uint256 count = 0;

        for (uint256 i; i < inputArray_.length; ++i) {
            if (inputArray_[i] != 0 && !_contains(tempArray, inputArray_[i], count)) {
                tempArray[count] = inputArray_[i];
                count++;
            }
        }

        uint256[] memory uniqueArray = new uint256[](count);
        for (uint256 i; i < count; ++i) {
            uniqueArray[i] = tempArray[i];
        }

        return uniqueArray;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {FusesLib} from "../libraries/FusesLib.sol";
import {PlasmaVaultConfigLib} from "../libraries/PlasmaVaultConfigLib.sol";
import {PlasmaVaultLib, InstantWithdrawalFusesParamsStruct} from "../libraries/PlasmaVaultLib.sol";
import {IPriceOracleMiddleware} from "../price_oracle/IPriceOracleMiddleware.sol";
import {Errors} from "../libraries/errors/Errors.sol";
import {PlasmaVaultStorageLib} from "../libraries/PlasmaVaultStorageLib.sol";
import {AssetDistributionProtectionLib, MarketLimit} from "../libraries/AssetDistributionProtectionLib.sol";
import {AccessManagedUpgradeable} from "../managers/access/AccessManagedUpgradeable.sol";
import {CallbackHandlerLib} from "../libraries/CallbackHandlerLib.sol";
import {IPlasmaVaultGovernance} from "../interfaces/IPlasmaVaultGovernance.sol";
import {IIporFusionAccessManager} from "../interfaces/IIporFusionAccessManager.sol";
import {PreHooksLib} from "../handlers/pre_hooks/PreHooksLib.sol";
/// @title Plasma Vault Governance
/// @notice Core governance contract for managing Plasma Vault configuration, security, and operational parameters
/// @dev Inherits AccessManagedUpgradeable for role-based access control and security management
///
/// Key responsibilities:
/// - Market substrate management and validation
/// - Fuse system configuration and control
/// - Fee structure management (performance & management)
/// - Price oracle middleware integration
/// - Access control and permissions
/// - Asset distribution protection
/// - Withdrawal system configuration
/// - Total supply cap management
///
/// Governance functions:
/// - Market configuration and substrate grants
/// - Fuse addition/removal and validation
/// - Fee rate and recipient management
/// - Oracle updates and validation
/// - Access control modifications
/// - Market limits and protection setup
/// - Withdrawal path configuration
///
/// Security considerations:
/// - Role-based access control for all functions
/// - Market validation and protection
/// - Fee caps and recipient validation
/// - Oracle compatibility checks
/// - Fuse system security
///
/// Integration points:
/// - PlasmaVault: Main vault operations
/// - PlasmaVaultBase: Core functionality
/// - Price Oracle: Asset valuation
/// - Access Manager: Permission control
/// - Fuse System: Protocol integrations
/// - Fee Manager: Revenue distribution
///
abstract contract PlasmaVaultGovernance is IPlasmaVaultGovernance, AccessManagedUpgradeable {
    /// @notice Checks if a substrate is granted for a specific market
    /// @param marketId_ The ID of the market to check
    /// @param substrate_ The substrate identifier to verify
    /// @return bool True if the substrate is granted for the market
    /// @dev Validates substrate permissions for market operations
    ///
    /// Substrate validation:
    /// - Confirms if a specific substrate (asset/protocol) is allowed in market
    /// - Essential for market operation validation
    /// - Used during fuse execution checks
    /// - Part of market access control system
    ///
    /// Market context:
    /// - Each market has unique substrate permissions
    /// - Substrates represent:
    ///   - Underlying assets
    ///   - Protocol positions
    ///   - Trading pairs
    ///   - Market-specific identifiers
    ///
    /// Used during:
    /// - Fuse execution validation
    /// - Market operation checks
    /// - Protocol integration verification
    /// - Access control enforcement
    ///
    /// Integration points:
    /// - Balance Fuses: Operation validation
    /// - Market Configuration: Permission checks
    /// - Protocol Integration: Asset validation
    /// - Governance Operations: Market management
    ///
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function isMarketSubstrateGranted(uint256 marketId_, bytes32 substrate_) external view override returns (bool) {
        return PlasmaVaultConfigLib.isMarketSubstrateGranted(marketId_, substrate_);
    }

    /// @notice Verifies if a fuse contract is registered and supported by the Plasma Vault
    /// @dev Delegates to FusesLib for fuse support validation
    /// - Uses FuseStorageLib mapping to verify fuse registration
    /// - Part of the vault's protocol integration security layer
    /// - Critical for preventing unauthorized protocol interactions
    ///
    /// Storage Pattern:
    /// - Checks FuseStorageLib.Fuses mapping where:
    ///   - Non-zero value indicates supported fuse
    ///   - Value represents (index + 1) in fusesArray
    ///   - Zero value means fuse is not supported
    ///
    /// Integration Context:
    /// - Called before fuse operations in PlasmaVault.execute()
    /// - Used during protocol integration validation
    /// - Part of governance fuse management system
    /// - Supports multi-protocol security checks
    ///
    /// Security Considerations:
    /// - Prevents execution of unauthorized fuses
    /// - Part of vault's protocol access control
    /// - Guards against malicious protocol integrations
    /// - Zero address returns false
    ///
    /// Related Components:
    /// - FusesLib: Core fuse management logic
    /// - FuseStorageLib: Persistent fuse storage
    /// - PlasmaVault: Main execution context
    /// - Protocol-specific fuses (Compound, Aave, etc.)
    ///
    /// @param fuse_ The address of the fuse contract to check
    /// @return bool True if the fuse is supported, false otherwise
    /// @custom:security Non-privileged view function
    function isFuseSupported(address fuse_) external view override returns (bool) {
        return FusesLib.isFuseSupported(fuse_);
    }

    /// @notice Checks if a balance fuse is supported for a specific market
    /// @dev Validates if a fuse is configured as the designated balance tracker for a market
    ///
    /// Balance Fuse System:
    /// - Each market can have only one active balance fuse
    /// - Balance fuses track protocol-specific positions
    /// - Provides standardized balance reporting interface
    /// - Essential for market-specific asset tracking
    ///
    /// Integration Context:
    /// - Used during market balance updates
    /// - Part of asset distribution protection
    /// - Supports protocol-specific balance tracking
    /// - Validates balance fuse operations
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.BalanceFuses mapping
    /// - Maps marketId to balance fuse address
    /// - Zero address indicates no balance fuse
    /// - One-to-one market to fuse relationship
    ///
    /// Use Cases:
    /// - Balance calculation validation
    /// - Market position verification
    /// - Protocol integration checks
    /// - Governance operations
    ///
    /// Related Components:
    /// - CompoundV3BalanceFuse
    /// - AaveV3BalanceFuse
    /// - Other protocol-specific balance trackers
    ///
    /// @param marketId_ The ID of the market to check
    /// @param fuse_ The address of the balance fuse
    /// @return bool True if the fuse is the designated balance fuse for the market
    /// @custom:access External view
    function isBalanceFuseSupported(uint256 marketId_, address fuse_) external view override returns (bool) {
        return FusesLib.isBalanceFuseSupported(marketId_, fuse_);
    }

    /// @notice Checks if the market exposure protection system is active
    /// @dev Validates the activation status of market limits through sentinel value
    ///
    /// Protection System:
    /// - Controls enforcement of market exposure limits
    /// - Part of vault's risk management framework
    /// - Protects against over-concentration in markets
    /// - Essential for asset distribution safety
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.MarketsLimits mapping
    /// - Slot 0 reserved for activation sentinel
    /// - Non-zero value in slot 0 indicates active
    /// - Zero value means protection is disabled
    ///
    /// Integration Context:
    /// - Used during all vault operations
    /// - Critical for risk limit enforcement
    /// - Affects market position validations
    /// - Part of governance control system
    ///
    /// Risk Management:
    /// - Prevents excessive market exposure
    /// - Enforces diversification requirements
    /// - Guards against protocol concentration
    /// - Maintains vault stability
    ///
    /// Related Components:
    /// - Asset Distribution Protection System
    /// - Market Limit Configurations
    /// - Balance Validation System
    /// - Governance Controls
    ///
    /// @return bool True if market limits protection is active
    /// @custom:access Public view
    /// @custom:security Non-privileged view function
    function isMarketsLimitsActivated() public view override returns (bool) {
        return AssetDistributionProtectionLib.isMarketsLimitsActivated();
    }

    /// @notice Retrieves all granted substrates for a specific market
    /// @dev Provides access to market's substrate configuration through PlasmaVaultConfigLib
    ///
    /// Substrate System:
    /// - Returns all active substrate identifiers for a market
    /// - Substrates can represent:
    ///   * Asset addresses (converted to bytes32)
    ///   * Protocol-specific vault identifiers
    ///   * Market parameters
    ///   * Configuration values
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.MarketSubstratesStruct
    /// - Maintains ordered list of granted substrates
    /// - Preserves grant operation order
    /// - Maps substrates to their allowance status
    ///
    /// Integration Context:
    /// - Used for market configuration auditing
    /// - Supports governance operations
    /// - Enables UI/external system integration
    /// - Facilitates market setup validation
    ///
    /// Use Cases:
    /// - Market configuration verification
    /// - Protocol integration management
    /// - Asset permission auditing
    /// - System state inspection
    ///
    /// Related Components:
    /// - Market Configuration System
    /// - Substrate Management
    /// - Asset Distribution Protection
    /// - Protocol Integration Layer
    ///
    /// @param marketId_ The ID of the market to query
    /// @return bytes32[] Array of all granted substrate identifiers
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getMarketSubstrates(uint256 marketId_) external view override returns (bytes32[] memory) {
        return PlasmaVaultConfigLib.getMarketSubstrates(marketId_);
    }

    /// @notice Retrieves the complete list of supported fuse contracts
    /// @dev Provides direct access to the fuses array from FuseStorageLib
    ///
    /// Storage Pattern:
    /// - Returns FuseStorageLib.FusesArray contents
    /// - Array indices correspond to (mapping value - 1)
    /// - Maintains parallel structure with fuse mapping
    /// - Order reflects fuse addition sequence
    ///
    /// Integration Context:
    /// - Used for fuse system configuration
    /// - Supports protocol integration auditing
    /// - Enables governance operations
    /// - Facilitates system state inspection
    ///
    /// Fuse System:
    /// - Lists all protocol integration contracts
    /// - Includes both active and balance fuses
    /// - Critical for vault configuration
    /// - No duplicates allowed
    ///
    /// Use Cases:
    /// - Protocol integration verification
    /// - Governance system management
    /// - Fuse system auditing
    /// - Configuration validation
    ///
    /// Related Components:
    /// - FusesLib: Core management logic
    /// - FuseStorageLib: Storage management
    /// - Protocol-specific fuses
    /// - Balance tracking fuses
    ///
    /// @return address[] Array of all supported fuse contract addresses
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getFuses() external view override returns (address[] memory) {
        return FusesLib.getFusesArray();
    }

    /// @notice Gets the current price oracle middleware address
    /// @dev Retrieves the address of the price oracle middleware used for asset valuations
    ///
    /// Price Oracle System:
    /// - Provides standardized price feeds for vault assets
    /// - Must support USD as quote currency
    /// - Critical for asset valuation and calculations
    /// - Required for market operations
    ///
    /// Integration Context:
    /// - Used by balance fuses for market valuations
    /// - Essential for withdrawal calculations
    /// - Required for performance tracking
    /// - Core component for share price determination
    ///
    /// Valuation Use Cases:
    /// - Asset price discovery
    /// - Market balance calculations
    /// - Fee computations
    /// - Share price updates
    ///
    /// Related Components:
    /// - Balance Fuses: Market valuations
    /// - Asset Distribution Protection
    /// - Performance Fee System
    /// - Share Price Calculator
    ///
    /// @return address The price oracle middleware contract address
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getPriceOracleMiddleware() external view override returns (address) {
        return PlasmaVaultLib.getPriceOracleMiddleware();
    }

    /// @notice Gets the performance fee configuration data
    /// @dev Retrieves current performance fee settings from PlasmaVaultLib
    ///
    /// Fee Structure:
    /// - Charged on positive vault performance
    /// - Maximum fee capped at 50% (PERFORMANCE_MAX_FEE_IN_PERCENTAGE)
    /// - Calculated on realized gains only
    /// - Applied during execute() operations
    ///
    /// Configuration Data:
    /// - feeAccount: Address receiving performance fees
    /// - feeInPercentage: Current fee rate (basis points)
    /// - Percentage uses 2 decimal places (100 = 1%)
    /// - Minted as new vault shares
    ///
    /// Integration Context:
    /// - Used by PlasmaVault._addPerformanceFee()
    /// - Critical for profit sharing calculations
    /// - Part of vault incentive structure
    /// - Affects share price computations
    ///
    /// Use Cases:
    /// - Fee calculation validation
    /// - Performance monitoring
    /// - Revenue distribution
    /// - Alpha incentive alignment
    ///
    /// Related Components:
    /// - FeeManager: Fee distribution
    /// - Performance Tracking System
    /// - Share Price Calculator
    /// - Governance Configuration
    ///
    /// @return feeData The current performance fee configuration
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getPerformanceFeeData()
        external
        view
        override
        returns (PlasmaVaultStorageLib.PerformanceFeeData memory feeData)
    {
        feeData = PlasmaVaultLib.getPerformanceFeeData();
    }

    /// @notice Gets the management fee configuration data
    /// @dev Retrieves current management fee settings from PlasmaVaultLib
    ///
    /// Fee Structure:
    /// - Continuous time-based fee on assets under management (AUM)
    /// - Maximum fee capped at MANAGEMENT_MAX_FEE_IN_PERCENTAGE (5%)
    /// - Fees accrue linearly over time
    /// - Realized during vault operations
    ///
    /// Configuration Data:
    /// - feeAccount: Address receiving management fees
    /// - feeInPercentage: Current fee rate (basis points)
    /// - lastUpdateTimestamp: Last fee realization time
    /// - Percentage uses 2 decimal places (100 = 1%)
    ///
    /// Integration Context:
    /// - Used by PlasmaVault._realizeManagementFee()
    /// - Critical for total assets calculation
    /// - Part of share price computation
    /// - Affects fee distribution system
    ///
    /// Use Cases:
    /// - Fee accrual tracking
    /// - AUM fee calculation
    /// - Revenue monitoring
    /// - Operational cost coverage
    ///
    /// Related Components:
    /// - FeeManager: Fee distribution
    /// - Total Assets Calculator
    /// - Share Price System
    /// - Governance Configuration
    ///
    /// @return feeData The current management fee configuration
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getManagementFeeData()
        external
        view
        override
        returns (PlasmaVaultStorageLib.ManagementFeeData memory feeData)
    {
        feeData = PlasmaVaultLib.getManagementFeeData();
    }

    /// @notice Gets the access manager contract address
    /// @dev Retrieves the address of the contract managing role-based access control
    ///
    /// Access Control System:
    /// - Core component for role-based permissions
    /// - Manages vault access rights
    /// - Controls governance operations
    /// - Enforces security policies
    ///
    /// Role Management:
    /// - ATOMIST_ROLE: Core governance operations
    /// - FUSE_MANAGER_ROLE: Protocol integration control
    /// - TECH_PERFORMANCE_FEE_MANAGER_ROLE: Fee management
    /// - TECH_MANAGEMENT_FEE_MANAGER_ROLE: Fee configuration
    /// - OWNER_ROLE: System administration
    ///
    /// Integration Context:
    /// - Used for permission validation
    /// - Governance operation control
    /// - Protocol security enforcement
    /// - Role assignment management
    ///
    /// Security Features:
    /// - Role-based access control
    /// - Permission validation
    /// - Operation authorization
    /// - Execution delay enforcement
    ///
    /// Related Components:
    /// - IIporFusionAccessManager
    /// - AccessManagedUpgradeable
    /// - Governance System
    /// - Security Framework
    ///
    /// @return address The access manager contract address
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getAccessManagerAddress() external view override returns (address) {
        return authority();
    }

    /// @notice Gets the rewards claim manager address
    /// @dev Retrieves the address of the contract managing reward claims and distributions
    ///
    /// Rewards System:
    /// - Handles protocol reward claims
    /// - Manages reward token distributions
    /// - Tracks claimable rewards
    /// - Coordinates reward strategies
    ///
    /// Integration Context:
    /// - Used during reward claim operations
    /// - Part of total asset calculations
    /// - Affects performance metrics
    /// - Supports protocol incentives
    ///
    /// System Features:
    /// - Protocol reward claiming
    /// - Reward distribution management
    /// - Token reward tracking
    /// - Performance accounting
    ///
    /// Configuration Notes:
    /// - Can be zero address (rewards disabled)
    /// - Critical for reward accounting
    /// - Affects total asset calculations
    /// - Impacts performance metrics
    ///
    /// Related Components:
    /// - Protocol Reward Systems
    /// - Asset Valuation Calculator
    /// - Performance Tracking
    /// - Governance Configuration
    ///
    /// @return address The rewards claim manager contract address
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getRewardsClaimManagerAddress() external view override returns (address) {
        return PlasmaVaultLib.getRewardsClaimManagerAddress();
    }

    /// @notice Gets the ordered list of instant withdrawal fuses
    /// @dev Retrieves the configured withdrawal path sequence from PlasmaVaultLib
    ///
    /// Withdrawal System:
    /// - Returns ordered array of withdrawal fuse addresses
    /// - Order determines withdrawal attempt sequence
    /// - Same fuse can appear multiple times with different params
    /// - Empty array if no withdrawal paths configured
    ///
    /// Integration Context:
    /// - Used during withdrawal operations
    /// - Part of withdrawal path validation
    /// - Supports withdrawal strategy execution
    /// - Coordinates fuse interactions
    ///
    /// System Features:
    /// - Ordered withdrawal path execution
    /// - Multiple withdrawal strategies
    /// - Protocol-specific withdrawals
    /// - Fallback path support
    ///
    /// Configuration Notes:
    /// - Order is critical for withdrawal efficiency
    /// - Multiple entries of same fuse allowed
    /// - Each fuse needs corresponding params
    /// - Used with getInstantWithdrawalFusesParams
    ///
    /// Related Components:
    /// - Withdrawal Execution System
    /// - Protocol-specific Fuses
    /// - Balance Validation
    /// - Fuse Parameter Management
    ///
    /// @return address[] Array of withdrawal fuse addresses in priority order
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getInstantWithdrawalFuses() external view override returns (address[] memory) {
        return PlasmaVaultLib.getInstantWithdrawalFuses();
    }

    /// @notice Gets parameters for a specific instant withdrawal fuse instance
    /// @dev Retrieves withdrawal configuration parameters for specific fuse execution
    ///
    /// Parameter Structure:
    /// - params[0]: Reserved for withdrawal amount (set during execution)
    /// - params[1+]: Fuse-specific parameters such as:
    ///   * Market identifiers
    ///   * Asset addresses
    ///   * Slippage tolerances
    ///   * Protocol-specific configuration
    ///
    /// Storage Pattern:
    /// - Uses keccak256(abi.encodePacked(fuse_, index_)) as key
    /// - Allows same fuse to have different params at different indices
    /// - Supports protocol-specific parameter requirements
    /// - Maintains parameter ordering
    ///
    /// Integration Context:
    /// - Used during withdrawal execution
    /// - Part of withdrawal path configuration
    /// - Supports fuse interaction setup
    /// - Validates withdrawal parameters
    ///
    /// Security Considerations:
    /// - Parameters must match fuse expectations
    /// - Index must correspond to withdrawal sequence
    /// - First parameter reserved for withdrawal amount
    /// - Critical for proper withdrawal execution
    ///
    /// Related Components:
    /// - Instant Withdrawal System
    /// - Protocol-specific Fuses
    /// - Parameter Validation
    /// - Withdrawal Execution
    ///
    /// @param fuse_ The address of the withdrawal fuse contract
    /// @param index_ The position of the fuse in the withdrawal sequence
    /// @return bytes32[] Array of parameters configured for this fuse instance
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getInstantWithdrawalFusesParams(
        address fuse_,
        uint256 index_
    ) external view override returns (bytes32[] memory) {
        return PlasmaVaultLib.getInstantWithdrawalFusesParams(fuse_, index_);
    }

    /// @notice Gets the market limit percentage for a specific market
    /// @dev Retrieves market-specific allocation limit from PlasmaVaultStorageLib
    ///
    /// Market Limits System:
    /// - Enforces market-specific allocation limits
    /// - Prevents over-concentration in single markets
    /// - Part of risk management through diversification
    /// - Limits stored in basis points (1e18 = 100%)
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.MarketLimits mapping
    /// - Maps marketId to percentage limit
    /// - Zero limit for marketId 0 deactivates all limits
    /// - Non-zero limit for marketId 0 activates limit system
    ///
    /// Integration Context:
    /// - Used by AssetDistributionProtectionLib
    /// - Referenced during balance updates
    /// - Part of risk management system
    /// - Critical for market operations
    ///
    /// Risk Management:
    /// - Controls market exposure
    /// - Enforces diversification
    /// - Prevents concentration risk
    /// - Maintains system stability
    ///
    /// @param marketId_ The ID of the market to query
    /// @return uint256 The market limit percentage (1e18 = 100%)
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getMarketLimit(uint256 marketId_) external view override returns (uint256) {
        return PlasmaVaultStorageLib.getMarketsLimits().limitInPercentage[marketId_];
    }

    /// @notice Gets the dependency balance graph for a specific market
    /// @dev Retrieves the array of market IDs that depend on the queried market
    ///
    /// Dependency System:
    /// - Tracks dependencies between market balances
    /// - Ensures atomic balance updates
    /// - Maintains consistency across related markets
    /// - Manages complex market relationships
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.DependencyBalanceGraph
    /// - Maps marketId to array of dependent market IDs
    /// - Dependencies are unidirectional (A->B doesn't imply B->A)
    /// - Empty array means no dependencies
    ///
    /// Integration Context:
    /// - Used during balance updates
    /// - Critical for market synchronization
    /// - Part of withdrawal validation
    /// - Supports rebalancing operations
    ///
    /// Example Dependencies:
    /// - Lending markets depending on underlying assets
    /// - LP token markets depending on constituent tokens
    /// - Derivative markets depending on base assets
    /// - Protocol-specific market relationships
    ///
    /// @param marketId_ The ID of the market to query
    /// @return uint256[] Array of market IDs that depend on this market
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getDependencyBalanceGraph(uint256 marketId_) external view override returns (uint256[] memory) {
        return PlasmaVaultStorageLib.getDependencyBalanceGraph().dependencyGraph[marketId_];
    }

    /// @notice Gets the total supply cap for the vault
    /// @dev Retrieves the configured maximum total supply limit from PlasmaVaultLib
    ///
    /// Supply Cap System:
    /// - Enforces maximum vault size
    /// - Limits total value locked (TVL)
    /// - Guards against excessive concentration
    /// - Supports gradual scaling
    ///
    /// Storage Pattern:
    /// - Uses PlasmaVaultStorageLib.ERC20CappedStorage
    /// - Stores cap in underlying asset decimals
    /// - Can be temporarily bypassed for fees
    /// - Critical for deposit control
    ///
    /// Integration Context:
    /// - Used during deposit validation
    /// - Referenced in share minting
    /// - Part of fee minting checks
    /// - Affects deposit availability
    ///
    /// Risk Management:
    /// - Controls maximum vault exposure
    /// - Manages protocol risk
    /// - Supports controlled growth
    /// - Protects market stability
    ///
    /// Related Components:
    /// - ERC4626 Implementation
    /// - Fee Minting System
    /// - Deposit Controls
    /// - Risk Parameters
    ///
    /// @return uint256 The maximum total supply in underlying asset decimals
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getTotalSupplyCap() external view override returns (uint256) {
        return PlasmaVaultLib.getTotalSupplyCap();
    }

    /// @notice Retrieves the list of all active markets with registered balance fuses
    /// @dev Provides access to the ordered array of active market IDs from BalanceFuses storage
    ///
    /// Market Tracking System:
    /// - Returns complete list of markets with balance fuses
    /// - Order reflects market registration sequence
    /// - List maintained by add/remove operations
    /// - Critical for market state management
    ///
    /// Storage Access:
    /// - Reads from PlasmaVaultStorageLib.BalanceFuses.marketIds
    /// - No storage modifications
    /// - O(1) operation for array access
    /// - Returns complete array reference
    ///
    /// Integration Context:
    /// - Used for market balance updates
    /// - Supports multi-market operations
    /// - Essential for balance synchronization
    /// - Part of asset distribution system
    ///
    /// Array Properties:
    /// - No duplicate market IDs
    /// - Order may change during removals
    /// - Maintained through governance operations
    /// - Empty array possible if no active markets
    ///
    /// Use Cases:
    /// - Market balance validation
    /// - Asset distribution checks
    /// - Protocol state monitoring
    /// - Governance operations
    ///
    /// Related Components:
    /// - Balance Fuse System
    /// - Market Management
    /// - Asset Protection
    /// - Protocol Operations
    ///
    /// @return uint256[] Array of active market IDs with registered balance fuses
    /// @custom:access External view
    /// @custom:security Non-privileged view function
    function getActiveMarketsInBalanceFuses() external view returns (uint256[] memory) {
        return FusesLib.getActiveMarketsInBalanceFuses();
    }

    /// @notice Adds a balance fuse for a specific market
    /// @dev Manages market-specific balance fuse assignments through FusesLib
    ///
    /// Balance Fuse System:
    /// - Associates balance tracking fuse with market
    /// - Each market can have only one active balance fuse
    /// - Balance fuses track protocol-specific positions
    /// - Essential for standardized balance reporting
    ///
    /// Storage Updates:
    /// - Updates PlasmaVaultStorageLib.BalanceFuses mapping
    /// - Maps marketId to balance fuse address
    /// - Prevents duplicate fuse assignments
    /// - Emits BalanceFuseAdded event
    ///
    /// Integration Context:
    /// - Used during market setup and configuration
    /// - Part of protocol integration process
    /// - Critical for market balance tracking
    /// - Supports asset distribution protection
    ///
    /// Security Considerations:
    /// - Only callable by FUSE_MANAGER_ROLE
    /// - Validates fuse address
    /// - Prevents duplicate assignments
    /// - Critical for market balance integrity
    ///
    /// Related Components:
    /// - Balance Fuse Contracts
    /// - Market Balance System
    /// - Asset Distribution Protection
    /// - Protocol Integration Layer
    ///
    /// @param marketId_ The ID of the market
    /// @param fuse_ The address of the fuse to add
    /// @custom:access FUSE_MANAGER_ROLE restricted
    /// @custom:events Emits BalanceFuseAdded when successful
    function addBalanceFuse(uint256 marketId_, address fuse_) external override restricted {
        _addBalanceFuse(marketId_, fuse_);
    }

    /// @notice Removes a balance fuse from a specific market
    /// @dev Manages the removal of market-specific balance fuse assignments through FusesLib
    ///
    /// Balance Fuse System:
    /// - Removes association between market and balance fuse
    /// - Clears balance tracking for protocol-specific positions
    /// - Must match current assigned fuse for market
    /// - Critical for market reconfiguration
    ///
    /// Storage Updates:
    /// - Updates PlasmaVaultStorageLib.BalanceFuses mapping
    /// - Removes marketId to balance fuse mapping
    /// - Validates current fuse assignment
    /// - Emits BalanceFuseRemoved event
    ///
    /// Integration Context:
    /// - Used during market reconfiguration
    /// - Part of protocol migration process
    /// - Supports balance tracking updates
    /// - Required for market deactivation
    ///
    /// Security Considerations:
    /// - Only callable by FUSE_MANAGER_ROLE
    /// - Validates fuse address matches current
    /// - Requires zero balance before removal
    /// - Critical for market integrity
    ///
    /// Related Components:
    /// - Balance Fuse Contracts
    /// - Market Balance System
    /// - Asset Distribution Protection
    /// - Protocol Integration Layer
    ///
    /// @param marketId_ The ID of the market
    /// @param fuse_ The address of the fuse to remove
    /// @custom:access FUSE_MANAGER_ROLE restricted
    /// @custom:events Emits BalanceFuseRemoved when successful
    function removeBalanceFuse(uint256 marketId_, address fuse_) external override restricted {
        FusesLib.removeBalanceFuse(marketId_, fuse_);
    }

    /// @notice Grants substrates to a specific market
    /// @dev Manages market-specific substrate permissions through PlasmaVaultConfigLib
    ///
    /// Substrate System:
    /// - Assigns protocol-specific identifiers to markets
    /// - Substrates can represent:
    ///   * Asset addresses (converted to bytes32)
    ///   * Protocol-specific vault identifiers
    ///   * Market parameters
    ///   * Trading pair configurations
    ///
    /// Storage Pattern:
    /// - Updates PlasmaVaultStorageLib.MarketSubstratesStruct
    /// - Maintains ordered list of granted substrates
    /// - Maps substrates to their allowance status
    /// - Preserves grant operation order
    ///
    /// Integration Context:
    /// - Used during market setup and configuration
    /// - Part of protocol integration process
    /// - Critical for market permissions
    /// - Supports multi-protocol operations
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Validates substrate format
    /// - Prevents duplicate grants
    /// - Critical for market access control
    ///
    /// Related Components:
    /// - Market Configuration System
    /// - Protocol Integration Layer
    /// - Access Control System
    /// - Balance Validation
    ///
    /// @param marketId_ The ID of the market
    /// @param substrates_ Array of substrates to grant
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:events Emits MarketSubstrateGranted for each substrate
    function grantMarketSubstrates(uint256 marketId_, bytes32[] calldata substrates_) external override restricted {
        PlasmaVaultConfigLib.grantMarketSubstrates(marketId_, substrates_);
    }

    /// @notice Updates dependency balance graphs for multiple markets
    /// @dev Manages market balance dependencies and their relationships in the vault system
    ///
    /// Dependency System:
    /// - Manages relationships between market balances
    /// - Supports complex market interdependencies
    /// - Critical for maintaining balance consistency
    /// - Enables atomic balance updates
    ///
    /// Storage Pattern:
    /// - Updates PlasmaVaultStorageLib.DependencyBalanceGraph
    /// - Maps marketId to array of dependent market IDs
    /// - Dependencies are directional (A->B doesn't imply B->A)
    /// - Overwrites existing dependencies
    ///
    /// Integration Context:
    /// - Used during market configuration
    /// - Essential for balance synchronization
    /// - Supports protocol integrations
    /// - Enables complex market strategies
    ///
    /// Use Cases:
    /// - Lending market dependencies
    /// - LP token relationships
    /// - Derivative market links
    /// - Cross-protocol dependencies
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Validates array length matching
    /// - Critical for balance integrity
    /// - Affects withdrawal validation
    ///
    /// Related Components:
    /// - Balance Tracking System
    /// - Market Configuration
    /// - Withdrawal Validation
    /// - Protocol Integration Layer
    ///
    /// @param marketIds_ Array of market IDs to update
    /// @param dependencies_ Array of dependency arrays for each market
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for balance consistency
    function updateDependencyBalanceGraphs(
        uint256[] memory marketIds_,
        uint256[][] memory dependencies_
    ) external override restricted {
        uint256 marketIdsLength = marketIds_.length;
        if (marketIdsLength != dependencies_.length) {
            revert Errors.WrongArrayLength();
        }
        for (uint256 i; i < marketIdsLength; ++i) {
            PlasmaVaultStorageLib.getDependencyBalanceGraph().dependencyGraph[marketIds_[i]] = dependencies_[i];
        }
    }

    /// @notice Configures the instant withdrawal fuses. Order of the fuse is important, as it will be used in the same order during the instant withdrawal process
    /// @dev Manages the configuration of instant withdrawal paths and their execution sequence
    ///
    /// Withdrawal System:
    /// - Configures ordered sequence of withdrawal attempts
    /// - Each fuse represents a withdrawal strategy
    /// - Same fuse can be used multiple times with different params
    /// - Order determines execution priority
    ///
    /// Configuration Structure:
    /// - fuses_[].fuse: Protocol-specific withdrawal contract
    /// - fuses_[].params: Configuration parameters where:
    ///   * params[0]: Reserved for withdrawal amount
    ///   * params[1+]: Strategy-specific parameters
    ///
    /// Storage Updates:
    /// - Updates PlasmaVaultStorageLib withdrawal configuration
    /// - Stores ordered fuse sequence
    /// - Maps fuse parameters to sequence index
    /// - Maintains execution order
    ///
    /// Integration Context:
    /// - Critical for withdrawal path optimization
    /// - Supports multiple protocol withdrawals
    /// - Enables complex withdrawal strategies
    /// - Facilitates liquidity management
    ///
    /// Security Considerations:
    /// - Only callable by CONFIG_INSTANT_WITHDRAWAL_FUSES_ROLE
    /// - Validates fuse addresses
    /// - Parameter validation per fuse
    /// - Order impacts withdrawal efficiency
    ///
    /// Related Components:
    /// - Withdrawal Execution System
    /// - Protocol-specific Fuses
    /// - Parameter Management
    /// - Liquidity Optimization
    ///
    /// @param fuses_ Array of instant withdrawal fuse configurations
    /// @custom:access CONFIG_INSTANT_WITHDRAWAL_FUSES_ROLE restricted
    /// @custom:security Critical for withdrawal path security
    function configureInstantWithdrawalFuses(
        InstantWithdrawalFusesParamsStruct[] calldata fuses_
    ) external override restricted {
        PlasmaVaultLib.configureInstantWithdrawalFuses(fuses_);
    }

    /// @notice Adds new fuses to the vault
    /// @dev Manages the registration of protocol integration fuses through FusesLib
    ///
    /// Fuse System:
    /// - Registers protocol-specific integration contracts
    /// - Each fuse represents a unique protocol interaction
    /// - Maintains vault's supported protocol list
    /// - Critical for protocol integration security
    ///
    /// Storage Updates:
    /// - Updates FuseStorageLib.Fuses mapping
    /// - Appends to FuseStorageLib.FusesArray
    /// - Assigns sequential indices to fuses
    /// - Emits FuseAdded event per fuse
    ///
    /// Integration Context:
    /// - Used during protocol integration setup
    /// - Enables new protocol interactions
    /// - Part of vault expansion process
    /// - Supports protocol upgrades
    ///
    /// Security Considerations:
    /// - Only callable by FUSE_MANAGER_ROLE
    /// - Validates fuse addresses
    /// - Prevents duplicate registrations
    /// - Critical for protocol security
    ///
    /// Related Components:
    /// - Protocol-specific Fuses
    /// - FusesLib: Core management
    /// - FuseStorageLib: Storage
    /// - PlasmaVault: Execution
    ///
    /// @param fuses_ Array of fuse addresses to add
    /// @custom:access FUSE_MANAGER_ROLE restricted
    /// @custom:events Emits FuseAdded for each fuse
    function addFuses(address[] calldata fuses_) external override restricted {
        for (uint256 i; i < fuses_.length; ++i) {
            FusesLib.addFuse(fuses_[i]);
        }
    }

    /// @notice Removes fuses from the vault
    /// @dev Manages removal of protocol integration fuses using swap-and-pop pattern
    ///
    /// Fuse System:
    /// - Removes protocol-specific integration contracts
    /// - Updates vault's supported protocol list
    /// - Maintains storage consistency
    /// - Uses efficient array management
    ///
    /// Storage Updates:
    /// - Updates FuseStorageLib.Fuses mapping
    /// - Maintains FuseStorageLib.FusesArray
    /// - Uses swap-and-pop for array efficiency
    /// - Emits FuseRemoved event per fuse
    ///
    /// Integration Context:
    /// - Used during protocol removal
    /// - Part of vault maintenance
    /// - Supports protocol upgrades
    /// - Critical for security updates
    ///
    /// Storage Pattern:
    /// - Moves last array element to removed position
    /// - Updates mapping for moved element
    /// - Clears removed fuse's mapping entry
    /// - Pops last array element
    ///
    /// Security Considerations:
    /// - Only callable by FUSE_MANAGER_ROLE
    /// - Validates fuse existence
    /// - Maintains mapping-array consistency
    /// - Critical for protocol security
    ///
    /// Gas Optimization:
    /// - Uses swap-and-pop vs shifting
    /// - Minimizes storage operations
    /// - Three SSTORE per removal:
    ///   1. Update moved element mapping
    ///   2. Clear removed mapping
    ///   3. Pop array
    ///
    /// @param fuses_ Array of fuse addresses to remove
    /// @custom:access FUSE_MANAGER_ROLE restricted
    /// @custom:events Emits FuseRemoved for each fuse
    /// @custom:security Critical for protocol integration security
    function removeFuses(address[] calldata fuses_) external override restricted {
        for (uint256 i; i < fuses_.length; ++i) {
            FusesLib.removeFuse(fuses_[i]);
        }
    }

    /// @notice Sets the price oracle middleware address
    /// @dev Updates the price oracle middleware while ensuring quote currency compatibility
    ///
    /// Oracle System:
    /// - Core component for asset price discovery
    /// - Must maintain consistent quote currency
    /// - Critical for vault valuations
    /// - Enables standardized pricing
    ///
    /// Validation Requirements:
    /// - New oracle must match existing:
    ///   * Quote currency (e.g., USD)
    ///   * Quote currency decimals
    /// - Prevents incompatible oracle updates
    /// - Maintains valuation consistency
    ///
    /// Integration Context:
    /// - Used by balance fuses
    /// - Critical for:
    ///   * Share price calculation
    ///   * Performance tracking
    ///   * Fee computation
    ///   * Market valuations
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Validates oracle compatibility
    /// - Critical for system integrity
    /// - Affects all price-dependent operations
    ///
    /// Error Conditions:
    /// - Reverts if quote currency mismatch
    /// - Reverts if decimal precision mismatch
    /// - Reverts with UnsupportedPriceOracleMiddleware
    ///
    /// @param priceOracleMiddleware_ The new price oracle middleware address
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for price discovery integrity
    function setPriceOracleMiddleware(address priceOracleMiddleware_) external override restricted {
        IPriceOracleMiddleware oldPriceOracleMiddleware = IPriceOracleMiddleware(
            PlasmaVaultLib.getPriceOracleMiddleware()
        );
        IPriceOracleMiddleware newPriceOracleMiddleware = IPriceOracleMiddleware(priceOracleMiddleware_);

        if (oldPriceOracleMiddleware.QUOTE_CURRENCY() != newPriceOracleMiddleware.QUOTE_CURRENCY()) {
            revert Errors.UnsupportedPriceOracleMiddleware();
        }

        PlasmaVaultLib.setPriceOracleMiddleware(priceOracleMiddleware_);
    }

    /// @notice Configures the performance fee settings
    /// @dev Updates performance fee configuration while enforcing system constraints
    ///
    /// Fee System:
    /// - Performance fees charged on positive vault returns
    /// - Maximum fee capped at PERFORMANCE_MAX_FEE_IN_PERCENTAGE (50%)
    /// - Fees realized during profitable operations
    /// - Minted as new vault shares
    ///
    /// Parameter Requirements:
    /// - feeAccount_: Non-zero address for fee collection
    /// - feeInPercentage_: Must not exceed 50% (5000 basis points)
    /// - Uses basis points (100 = 1%)
    /// - Percentage precision: 2 decimals
    ///
    /// Fee Account Types:
    /// - FeeManager contract: Distributes to IPOR DAO
    /// - EOA/MultiSig: Direct fee collection
    /// - Technical account: Temporary collection
    /// - Protocol treasury: Revenue distribution
    ///
    /// Integration Context:
    /// - Used by PlasmaVault._addPerformanceFee()
    /// - Affects share price calculations
    /// - Part of profit sharing system
    /// - Critical for vault economics
    ///
    /// Security Considerations:
    /// - Only callable by TECH_PERFORMANCE_FEE_MANAGER_ROLE
    /// - Validates fee percentage limits
    /// - Prevents zero address fee recipient
    /// - Critical for revenue integrity
    ///
    /// Related Components:
    /// - FeeManager: Distribution logic
    /// - Performance Tracking
    /// - Share Price Calculator
    /// - Profit Assessment System
    ///
    /// @param feeAccount_ Address to receive performance fees
    /// @param feeInPercentage_ Fee percentage with 2 decimals (100 = 1%)
    /// @custom:access TECH_PERFORMANCE_FEE_MANAGER_ROLE restricted
    /// @custom:security Critical for vault revenue model
    function configurePerformanceFee(address feeAccount_, uint256 feeInPercentage_) external override restricted {
        PlasmaVaultLib.configurePerformanceFee(feeAccount_, feeInPercentage_);
    }

    /// @notice Configures the management fee settings
    /// @dev Updates management fee configuration while enforcing system constraints
    ///
    /// Fee System:
    /// - Continuous time-based fee on assets under management (AUM)
    /// - Maximum fee capped at MANAGEMENT_MAX_FEE_IN_PERCENTAGE (5%)
    /// - Fees accrue linearly over time
    /// - Realized during vault operations
    ///
    /// Parameter Requirements:
    /// - feeAccount_: Non-zero address for fee collection
    /// - feeInPercentage_: Must not exceed 5% (500 basis points)
    /// - Uses basis points (100 = 1%)
    /// - Percentage precision: 2 decimals
    ///
    /// Fee Account Types:
    /// - FeeManager contract: Distributes to IPOR DAO
    /// - EOA/MultiSig: Direct fee collection
    /// - Technical account: Temporary collection
    /// - Protocol treasury: Revenue distribution
    ///
    /// Integration Context:
    /// - Used by PlasmaVault._realizeManagementFee()
    /// - Critical for total assets calculation
    /// - Part of share price computation
    /// - Affects fee distribution system
    ///
    /// Security Considerations:
    /// - Only callable by TECH_MANAGEMENT_FEE_MANAGER_ROLE
    /// - Validates fee percentage limits
    /// - Prevents zero address fee recipient
    /// - Critical for revenue integrity
    ///
    /// Related Components:
    /// - FeeManager: Distribution logic
    /// - Total Assets Calculator
    /// - Share Price System
    /// - Fee Realization Logic
    ///
    /// @param feeAccount_ Address to receive management fees
    /// @param feeInPercentage_ Fee percentage with 2 decimals (100 = 1%)
    /// @custom:access TECH_REWARDS_CLAIM_MANAGER_ROLE (held by RewardsClaimManager) restricted
    /// @custom:security Critical for vault revenue model
    function configureManagementFee(address feeAccount_, uint256 feeInPercentage_) external override restricted {
        PlasmaVaultLib.configureManagementFee(feeAccount_, feeInPercentage_);
    }

    /// @notice Sets the rewards claim manager address
    /// @dev Updates rewards manager configuration and emits event
    ///
    /// Configuration Options:
    /// - Non-zero address: Enables reward claiming functionality
    ///   * Activates protocol reward claiming
    ///   * Enables reward token distributions
    ///   * Tracks claimable rewards
    ///   * Manages reward strategies
    ///
    /// - Zero address: Disables reward claiming system
    ///   * Deactivates reward claiming
    ///   * Suspends reward distributions
    ///   * Maintains existing balances
    ///   * Preserves historical data
    ///
    /// Integration Context:
    /// - Used during protocol reward setup
    /// - Affects total asset calculations
    /// - Part of performance tracking
    /// - Impacts fee computations
    ///
    /// System Features:
    /// - Protocol reward claiming
    /// - Reward distribution management
    /// - Token reward tracking
    /// - Performance accounting
    ///
    /// Security Considerations:
    /// - Only callable by TECH_REWARDS_CLAIM_MANAGER_ROLE which is assigned to RewardsClaimManager contract itself
    /// - RewardsClaimManager must explicitly allow this method execution through its own logic
    /// - Critical for reward system integrity
    /// - Affects total asset calculations
    /// - Impacts performance metrics
    /// - Cannot be changed if RewardsClaimManager contract does not permit it
    ///
    /// Related Components:
    /// - Protocol Reward Systems
    /// - Asset Valuation Calculator
    /// - Performance Tracking
    /// - Fee Computation Logic
    /// - RewardsClaimManager Contract
    ///
    /// @param rewardsClaimManagerAddress_ The new rewards claim manager address
    /// @custom:access TECH_REWARDS_CLAIM_MANAGER_ROLE (held by RewardsClaimManager) restricted
    /// @custom:events Emits RewardsClaimManagerAddressChanged
    /// @custom:security Critical for reward system integrity
    function setRewardsClaimManagerAddress(address rewardsClaimManagerAddress_) public override restricted {
        PlasmaVaultLib.setRewardsClaimManagerAddress(rewardsClaimManagerAddress_);
    }

    /// @notice Sets up market limits for asset distribution protection
    /// @dev Configures maximum exposure limits for multiple markets in the vault system
    ///
    /// Limit System:
    /// - Enforces maximum allocation per market
    /// - Uses fixed-point percentages (1e18 = 100%)
    /// - Prevents over-concentration risk
    /// - Critical for risk distribution
    ///
    /// Configuration Rules:
    /// - Market ID 0 is reserved (system control)
    /// - Limits must not exceed 100%
    /// - Each market can have unique limit
    /// - Supports multiple market updates
    ///
    /// Storage Updates:
    /// - Updates PlasmaVaultStorageLib.MarketsLimits
    /// - Maps marketId to percentage limit
    /// - Emits MarketLimitUpdated events
    /// - Maintains limit configurations
    ///
    /// Error Conditions:
    /// - Reverts if marketId is 0 (WrongMarketId)
    /// - Reverts if limit > 100% (MarketLimitSetupInPercentageIsTooHigh)
    /// - Validates each market configuration
    /// - Ensures limit consistency
    ///
    /// Integration Context:
    /// - Part of risk management framework
    /// - Affects market operation validation
    /// - Critical for vault stability
    /// - Supports protocol diversification
    ///
    /// Related Components:
    /// - Asset Distribution Protection
    /// - Market Balance Tracking
    /// - Risk Management System
    /// - Limit Validation Logic
    ///
    /// @param marketsLimits_ Array of market limit configurations
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:events Emits MarketLimitUpdated for each market
    /// @custom:security Critical for risk management system
    function setupMarketsLimits(MarketLimit[] calldata marketsLimits_) external override restricted {
        AssetDistributionProtectionLib.setupMarketsLimits(marketsLimits_);
    }

    /// @notice Activates the markets limits protection, by default it is deactivated
    /// @dev Enables the market exposure protection system through sentinel value
    ///
    /// Protection System:
    /// - Controls enforcement of market exposure limits
    /// - Uses slot 0 as activation sentinel
    /// - Critical for risk management activation
    /// - Affects all market operations
    ///
    /// Storage Updates:
    /// - Sets PlasmaVaultStorageLib.MarketsLimits slot 0 to 1
    /// - Enables limit validation in checkLimits()
    /// - Activates percentage-based exposure controls
    /// - Emits MarketsLimitsActivated event
    ///
    /// Integration Context:
    /// - Required after market limit configuration
    /// - Affects all subsequent vault operations
    /// - Part of risk management framework
    /// - Enables asset distribution protection
    ///
    /// System Features:
    /// - Market exposure control
    /// - Risk distribution enforcement
    /// - Protocol concentration limits
    /// - Balance validation checks
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Requires prior limit configuration
    /// - Critical for risk management
    /// - Affects all market interactions
    ///
    /// Related Components:
    /// - Asset Distribution Protection
    /// - Market Balance System
    /// - Risk Management Framework
    /// - Limit Validation Logic
    ///
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:events Emits MarketsLimitsActivated
    /// @custom:security Critical for risk management activation
    function activateMarketsLimits() public override restricted {
        AssetDistributionProtectionLib.activateMarketsLimits();
    }

    /// @notice Deactivates the markets limits protection
    /// @dev Disables the market exposure protection system by clearing sentinel value
    ///
    /// Protection System:
    /// - Disables enforcement of market exposure limits
    /// - Clears slot 0 activation sentinel
    /// - Emergency risk control feature
    /// - Affects all market operations
    ///
    /// Storage Updates:
    /// - Sets PlasmaVaultStorageLib.MarketsLimits slot 0 to 0
    /// - Disables limit validation in checkLimits()
    /// - Suspends percentage-based exposure controls
    /// - Emits MarketsLimitsDeactivated event
    ///
    /// Integration Context:
    /// - Emergency risk management tool
    /// - Affects all vault operations
    /// - Bypasses market limits
    /// - Enables unrestricted positions
    ///
    /// Use Cases:
    /// - Emergency market conditions
    /// - System maintenance
    /// - Market rebalancing
    /// - Protocol migration
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Removes all limit protections
    /// - Should be used with caution
    /// - Critical system state change
    ///
    /// Related Components:
    /// - Asset Distribution Protection
    /// - Market Balance System
    /// - Risk Management Framework
    /// - Emergency Controls
    ///
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:events Emits MarketsLimitsDeactivated
    /// @custom:security Critical for risk management system
    function deactivateMarketsLimits() public override restricted {
        AssetDistributionProtectionLib.deactivateMarketsLimits();
    }

    /// @notice Updates the callback handler configuration
    /// @dev Manages callback handler mappings for vault operations
    ///
    /// Callback System:
    /// - Maps function signatures to handler contracts
    /// - Enables protocol-specific callbacks
    /// - Supports operation hooks
    /// - Manages execution flow
    ///
    /// Configuration Components:
    /// - handler_: Contract implementing callback logic
    /// - sender_: Authorized callback initiator
    /// - sig_: Target function signature (4 bytes)
    ///
    /// Storage Updates:
    /// - Updates CallbackHandlerLib mappings
    /// - Links handler to sender and signature
    /// - Enables callback execution
    /// - Maintains handler configurations
    ///
    /// Integration Context:
    /// - Used for protocol-specific operations
    /// - Supports custom execution flows
    /// - Enables external integrations
    /// - Manages operation hooks
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Validates handler address
    /// - Critical for execution flow
    /// - Affects operation security
    ///
    /// Related Components:
    /// - CallbackHandlerLib
    /// - Protocol Integration Layer
    /// - Operation Execution System
    /// - Security Framework
    ///
    /// @param handler_ The callback handler address
    /// @param sender_ The sender address
    /// @param sig_ The function signature
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for execution flow integrity
    function updateCallbackHandler(address handler_, address sender_, bytes4 sig_) external override restricted {
        CallbackHandlerLib.updateCallbackHandler(handler_, sender_, sig_);
    }

    /// @notice Sets the total supply cap for the vault
    /// @dev Updates the vault's total supply limit while enforcing validation rules
    ///
    /// Supply Cap System:
    /// - Enforces maximum vault size
    /// - Controls total value locked (TVL)
    /// - Guards against excessive concentration
    /// - Supports gradual scaling
    ///
    /// Validation Requirements:
    /// - Must be non-zero value
    /// - Must be sufficient for operations
    /// - Should consider asset decimals
    /// - Must accommodate fee minting
    ///
    /// Storage Updates:
    /// - Updates PlasmaVaultStorageLib.ERC20CappedStorage
    /// - Stores cap in underlying asset decimals
    /// - Affects deposit availability
    /// - Impacts share minting limits
    ///
    /// Integration Context:
    /// - Used during deposit validation
    /// - Affects share minting operations
    /// - Part of risk management system
    /// - Critical for vault scaling
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Critical for vault size control
    /// - Affects deposit availability
    /// - Impacts risk parameters
    ///
    /// Related Components:
    /// - ERC4626 Implementation
    /// - Deposit Control System
    /// - Fee Minting Logic
    /// - Risk Management Framework
    ///
    /// @param cap_ The new total supply cap in underlying asset decimals
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for vault capacity management
    function setTotalSupplyCap(uint256 cap_) external override restricted {
        PlasmaVaultLib.setTotalSupplyCap(cap_);
    }

    /// @notice Converts the vault to a public vault
    /// @dev Modifies access control to enable public deposit and minting operations
    ///
    /// Access Control Updates:
    /// - Sets PUBLIC_ROLE for:
    ///   * mint() function
    ///   * deposit() function
    ///   * depositWithPermit() function
    /// - Enables unrestricted access to deposit operations
    /// - Maintains other access restrictions
    ///
    /// Integration Context:
    /// - Used during vault lifecycle transitions
    /// - Part of access control system
    /// - Enables public participation
    /// - Critical for vault accessibility
    ///
    /// System Impact:
    /// - Allows public deposits
    /// - Enables direct minting
    /// - Supports permit deposits
    /// - Maintains security controls
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Irreversible operation
    /// - Affects deposit permissions
    /// - Critical for vault access
    ///
    /// Related Components:
    /// - IporFusionAccessManager
    /// - Access Control System
    /// - Deposit Functions
    /// - Permission Management
    ///
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for vault accessibility
    function convertToPublicVault() external override restricted {
        IIporFusionAccessManager(authority()).convertToPublicVault(address(this));
    }

    /// @notice Enables transfer of shares
    /// @dev Modifies access control to enable share transfer functionality
    ///
    /// Access Control Updates:
    /// - Sets PUBLIC_ROLE for:
    ///   * transfer() function
    ///   * transferFrom() function
    /// - Enables unrestricted share transfers
    /// - Maintains other access restrictions
    /// - Critical for share transferability
    ///
    /// Integration Context:
    /// - Used during vault lifecycle transitions
    /// - Part of access control system
    /// - Enables secondary market trading
    /// - Supports share liquidity
    ///
    /// System Impact:
    /// - Allows share transfers between accounts
    /// - Enables delegated transfers
    /// - Supports trading integrations
    /// - Maintains transfer restrictions
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Irreversible operation
    /// - Affects share transferability
    /// - Critical for vault liquidity
    ///
    /// Related Components:
    /// - IporFusionAccessManager
    /// - Access Control System
    /// - Transfer Functions
    /// - Permission Management
    ///
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for share transferability
    function enableTransferShares() external override restricted {
        IIporFusionAccessManager(authority()).enableTransferShares(address(this));
    }

    /// @notice Sets minimal execution delays for roles
    /// @dev Configures timelock delays for role-based operations through IporFusionAccessManager
    ///
    /// Timelock System:
    /// - Sets minimum delay between scheduling and execution
    /// - Role-specific delay requirements
    /// - Critical for governance security
    /// - Enforces operation timelocks
    ///
    /// Configuration Components:
    /// - rolesIds_: Array of role identifiers
    /// - delays_: Corresponding minimum delays
    /// - Validates delay requirements
    /// - Maintains role security
    ///
    /// Integration Context:
    /// - Part of access control system
    /// - Affects operation execution
    /// - Supports governance security
    /// - Enables controlled changes
    ///
    /// Security Features:
    /// - Role-based execution delays
    /// - Operation scheduling
    /// - Timelock enforcement
    /// - Governance protection
    ///
    /// Security Considerations:
    /// - Only callable by OWNER_ROLE
    /// - Validates delay parameters
    /// - Critical for role security
    /// - Affects operation timing
    ///
    /// Related Components:
    /// - IporFusionAccessManager
    /// - RoleExecutionTimelockLib
    /// - Access Control System
    /// - Governance Framework
    ///
    /// @param rolesIds_ Array of role IDs to configure
    /// @param delays_ Array of corresponding minimum delays
    /// @custom:access OWNER_ROLE restricted
    /// @custom:security Critical for governance timelock system
    function setMinimalExecutionDelaysForRoles(
        uint64[] calldata rolesIds_,
        uint256[] calldata delays_
    ) external override restricted {
        IIporFusionAccessManager(authority()).setMinimalExecutionDelaysForRoles(rolesIds_, delays_);
    }

    /// @notice Sets or updates pre-hook implementations for function selectors
    /// @dev Manages the configuration of pre-execution hooks through PreHooksLib
    ///
    /// Pre-Hook System:
    /// - Maps function selectors to pre-hook implementations
    /// - Configures substrate parameters for each hook
    /// - Supports addition, update, and removal operations
    /// - Maintains hook execution order
    ///
    /// Configuration Components:
    /// - selectors_: Function signatures requiring pre-hooks
    /// - implementations_: Corresponding hook contract addresses
    /// - substrates_: Configuration parameters for each hook
    ///
    /// Storage Updates:
    /// - Updates PreHooksLib configuration
    /// - Maintains selector to implementation mapping
    /// - Stores substrate configurations
    /// - Preserves hook execution order
    ///
    /// Operation Types:
    /// - Add new pre-hook: Maps new selector to implementation
    /// - Update existing: Changes implementation or substrates
    /// - Remove pre-hook: Sets implementation to address(0)
    /// - Batch operations supported
    ///
    /// Security Considerations:
    /// - Only callable by ATOMIST_ROLE
    /// - Validates array length matching
    /// - Prevents invalid selector configurations
    /// - Critical for execution security
    ///
    /// Integration Context:
    /// - Used for vault operation customization
    /// - Supports protocol-specific validations
    /// - Enables complex operation flows
    /// - Critical for vault extensibility
    ///
    /// Related Components:
    /// - PreHooksLib: Core management
    /// - Pre-hook Implementations
    /// - Vault Operations
    /// - Security Framework
    ///
    /// @param selectors_ Array of function selectors to configure
    /// @param implementations_ Array of pre-hook implementation addresses
    /// @param substrates_ Array of substrate configurations for each hook
    /// @custom:access ATOMIST_ROLE restricted
    /// @custom:security Critical for vault operation security
    function setPreHookImplementations(
        bytes4[] calldata selectors_,
        address[] calldata implementations_,
        bytes32[][] calldata substrates_
    ) external restricted {
        PreHooksLib.setPreHookImplementations(selectors_, implementations_, substrates_);
    }

    function getPreHookSelectors() external view returns (bytes4[] memory) {
        return PreHooksLib.getPreHookSelectors();
    }

    function getPreHookImplementation(bytes4 selector_) external view returns (address) {
        return PreHooksLib.getPreHookImplementation(selector_);
    }

    function _addFuse(address fuse_) internal {
        if (fuse_ == address(0)) {
            revert Errors.WrongAddress();
        }
        FusesLib.addFuse(fuse_);
    }

    /// @notice Internal helper to add a balance fuse
    /// @param marketId_ The ID of the market
    /// @param fuse_ The address of the fuse to add
    /// @dev Validates fuse address and adds it to the market
    /// @custom:access Internal
    /// @notice Internal helper to add a balance fuse
    /// @param marketId_ The ID of the market
    /// @param fuse_ The address of the fuse to add
    /// @dev Validates fuse address and adds it to the market
    /// @custom:access Internal
    function _addBalanceFuse(uint256 marketId_, address fuse_) internal {
        if (fuse_ == address(0)) {
            revert Errors.WrongAddress();
        }
        FusesLib.addBalanceFuse(marketId_, fuse_);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
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
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManager} from "./IAccessManager.sol";
import {IAccessManaged} from "./IAccessManaged.sol";
import {Address} from "../../utils/Address.sol";
import {Context} from "../../utils/Context.sol";
import {Multicall} from "../../utils/Multicall.sol";
import {Math} from "../../utils/math/Math.sol";
import {Time} from "../../utils/types/Time.sol";

/**
 * @dev AccessManager is a central contract to store the permissions of a system.
 *
 * A smart contract under the control of an AccessManager instance is known as a target, and will inherit from the
 * {AccessManaged} contract, be connected to this contract as its manager and implement the {AccessManaged-restricted}
 * modifier on a set of functions selected to be permissioned. Note that any function without this setup won't be
 * effectively restricted.
 *
 * The restriction rules for such functions are defined in terms of "roles" identified by an `uint64` and scoped
 * by target (`address`) and function selectors (`bytes4`). These roles are stored in this contract and can be
 * configured by admins (`ADMIN_ROLE` members) after a delay (see {getTargetAdminDelay}).
 *
 * For each target contract, admins can configure the following without any delay:
 *
 * * The target's {AccessManaged-authority} via {updateAuthority}.
 * * Close or open a target via {setTargetClosed} keeping the permissions intact.
 * * The roles that are allowed (or disallowed) to call a given function (identified by its selector) through {setTargetFunctionRole}.
 *
 * By default every address is member of the `PUBLIC_ROLE` and every target function is restricted to the `ADMIN_ROLE` until configured otherwise.
 * Additionally, each role has the following configuration options restricted to this manager's admins:
 *
 * * A role's admin role via {setRoleAdmin} who can grant or revoke roles.
 * * A role's guardian role via {setRoleGuardian} who's allowed to cancel operations.
 * * A delay in which a role takes effect after being granted through {setGrantDelay}.
 * * A delay of any target's admin action via {setTargetAdminDelay}.
 * * A role label for discoverability purposes with {labelRole}.
 *
 * Any account can be added and removed into any number of these roles by using the {grantRole} and {revokeRole} functions
 * restricted to each role's admin (see {getRoleAdmin}).
 *
 * Since all the permissions of the managed system can be modified by the admins of this instance, it is expected that
 * they will be highly secured (e.g., a multisig or a well-configured DAO).
 *
 * NOTE: This contract implements a form of the {IAuthority} interface, but {canCall} has additional return data so it
 * doesn't inherit `IAuthority`. It is however compatible with the `IAuthority` interface since the first 32 bytes of
 * the return data are a boolean as expected by that interface.
 *
 * NOTE: Systems that implement other access control mechanisms (for example using {Ownable}) can be paired with an
 * {AccessManager} by transferring permissions (ownership in the case of {Ownable}) directly to the {AccessManager}.
 * Users will be able to interact with these contracts through the {execute} function, following the access rules
 * registered in the {AccessManager}. Keep in mind that in that context, the msg.sender seen by restricted functions
 * will be {AccessManager} itself.
 *
 * WARNING: When granting permissions over an {Ownable} or {AccessControl} contract to an {AccessManager}, be very
 * mindful of the danger associated with functions such as {{Ownable-renounceOwnership}} or
 * {{AccessControl-renounceRole}}.
 */
contract AccessManager is Context, Multicall, IAccessManager {
    using Time for *;

    // Structure that stores the details for a target contract.
    struct TargetConfig {
        mapping(bytes4 selector => uint64 roleId) allowedRoles;
        Time.Delay adminDelay;
        bool closed;
    }

    // Structure that stores the details for a role/account pair. This structures fit into a single slot.
    struct Access {
        // Timepoint at which the user gets the permission.
        // If this is either 0 or in the future, then the role permission is not available.
        uint48 since;
        // Delay for execution. Only applies to restricted() / execute() calls.
        Time.Delay delay;
    }

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => Access access) members;
        // Admin who can grant or revoke permissions.
        uint64 admin;
        // Guardian who can cancel operations targeting functions that need this role.
        uint64 guardian;
        // Delay in which the role takes effect after being granted.
        Time.Delay grantDelay;
    }

    // Structure that stores the details for a scheduled operation. This structure fits into a single slot.
    struct Schedule {
        // Moment at which the operation can be executed.
        uint48 timepoint;
        // Operation nonce to allow third-party contracts to identify the operation.
        uint32 nonce;
    }

    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    mapping(address target => TargetConfig mode) private _targets;
    mapping(uint64 roleId => Role) private _roles;
    mapping(bytes32 operationId => Schedule) private _schedules;

    // Used to identify operations that are currently being executed via {execute}.
    // This should be transient storage when supported by the EVM.
    bytes32 private _executionId;

    /**
     * @dev Check that the caller is authorized to perform the operation, following the restrictions encoded in
     * {_getAdminRestrictions}.
     */
    modifier onlyAuthorized() {
        _checkAuthorized();
        _;
    }

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) {
            revert AccessManagerInvalidInitialAdmin(address(0));
        }

        // admin is active immediately and without any execution delay.
        _grantRole(ADMIN_ROLE, initialAdmin, 0, 0);
    }

    // =================================================== GETTERS ====================================================
    /// @inheritdoc IAccessManager
    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) public view virtual returns (bool immediate, uint32 delay) {
        if (isTargetClosed(target)) {
            return (false, 0);
        } else if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(target, selector), 0);
        } else {
            uint64 roleId = getTargetFunctionRole(target, selector);
            (bool isMember, uint32 currentDelay) = hasRole(roleId, caller);
            return isMember ? (currentDelay == 0, currentDelay) : (false, 0);
        }
    }

    /// @inheritdoc IAccessManager
    function expiration() public view virtual returns (uint32) {
        return 1 weeks;
    }

    /// @inheritdoc IAccessManager
    function minSetback() public view virtual returns (uint32) {
        return 5 days;
    }

    /// @inheritdoc IAccessManager
    function isTargetClosed(address target) public view virtual returns (bool) {
        return _targets[target].closed;
    }

    /// @inheritdoc IAccessManager
    function getTargetFunctionRole(address target, bytes4 selector) public view virtual returns (uint64) {
        return _targets[target].allowedRoles[selector];
    }

    /// @inheritdoc IAccessManager
    function getTargetAdminDelay(address target) public view virtual returns (uint32) {
        return _targets[target].adminDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getRoleAdmin(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].admin;
    }

    /// @inheritdoc IAccessManager
    function getRoleGuardian(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].guardian;
    }

    /// @inheritdoc IAccessManager
    function getRoleGrantDelay(uint64 roleId) public view virtual returns (uint32) {
        return _roles[roleId].grantDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getAccess(
        uint64 roleId,
        address account
    ) public view virtual returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) {
        Access storage access = _roles[roleId].members[account];

        since = access.since;
        (currentDelay, pendingDelay, effect) = access.delay.getFull();

        return (since, currentDelay, pendingDelay, effect);
    }

    /// @inheritdoc IAccessManager
    function hasRole(
        uint64 roleId,
        address account
    ) public view virtual returns (bool isMember, uint32 executionDelay) {
        if (roleId == PUBLIC_ROLE) {
            return (true, 0);
        } else {
            (uint48 hasRoleSince, uint32 currentDelay, , ) = getAccess(roleId, account);
            return (hasRoleSince != 0 && hasRoleSince <= Time.timestamp(), currentDelay);
        }
    }

    // =============================================== ROLE MANAGEMENT ===============================================
    /// @inheritdoc IAccessManager
    function labelRole(uint64 roleId, string calldata label) public virtual onlyAuthorized {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }
        emit RoleLabel(roleId, label);
    }

    /// @inheritdoc IAccessManager
    function grantRole(uint64 roleId, address account, uint32 executionDelay) public virtual onlyAuthorized {
        _grantRole(roleId, account, getRoleGrantDelay(roleId), executionDelay);
    }

    /// @inheritdoc IAccessManager
    function revokeRole(uint64 roleId, address account) public virtual onlyAuthorized {
        _revokeRole(roleId, account);
    }

    /// @inheritdoc IAccessManager
    function renounceRole(uint64 roleId, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessManagerBadConfirmation();
        }
        _revokeRole(roleId, callerConfirmation);
    }

    /// @inheritdoc IAccessManager
    function setRoleAdmin(uint64 roleId, uint64 admin) public virtual onlyAuthorized {
        _setRoleAdmin(roleId, admin);
    }

    /// @inheritdoc IAccessManager
    function setRoleGuardian(uint64 roleId, uint64 guardian) public virtual onlyAuthorized {
        _setRoleGuardian(roleId, guardian);
    }

    /// @inheritdoc IAccessManager
    function setGrantDelay(uint64 roleId, uint32 newDelay) public virtual onlyAuthorized {
        _setGrantDelay(roleId, newDelay);
    }

    /**
     * @dev Internal version of {grantRole} without access control. Returns true if the role was newly granted.
     *
     * Emits a {RoleGranted} event.
     */
    function _grantRole(
        uint64 roleId,
        address account,
        uint32 grantDelay,
        uint32 executionDelay
    ) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        bool newMember = _roles[roleId].members[account].since == 0;
        uint48 since;

        if (newMember) {
            since = Time.timestamp() + grantDelay;
            _roles[roleId].members[account] = Access({since: since, delay: executionDelay.toDelay()});
        } else {
            // No setback here. Value can be reset by doing revoke + grant, effectively allowing the admin to perform
            // any change to the execution delay within the duration of the role admin delay.
            (_roles[roleId].members[account].delay, since) = _roles[roleId].members[account].delay.withUpdate(
                executionDelay,
                0
            );
        }

        emit RoleGranted(roleId, account, executionDelay, since, newMember);
        return newMember;
    }

    /**
     * @dev Internal version of {revokeRole} without access control. This logic is also used by {renounceRole}.
     * Returns true if the role was previously granted.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function _revokeRole(uint64 roleId, address account) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        if (_roles[roleId].members[account].since == 0) {
            return false;
        }

        delete _roles[roleId].members[account];

        emit RoleRevoked(roleId, account);
        return true;
    }

    /**
     * @dev Internal version of {setRoleAdmin} without access control.
     *
     * Emits a {RoleAdminChanged} event.
     *
     * NOTE: Setting the admin role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to set grant or revoke such role.
     */
    function _setRoleAdmin(uint64 roleId, uint64 admin) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        _roles[roleId].admin = admin;

        emit RoleAdminChanged(roleId, admin);
    }

    /**
     * @dev Internal version of {setRoleGuardian} without access control.
     *
     * Emits a {RoleGuardianChanged} event.
     *
     * NOTE: Setting the guardian role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to cancel any scheduled operation for such role.
     */
    function _setRoleGuardian(uint64 roleId, uint64 guardian) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        _roles[roleId].guardian = guardian;

        emit RoleGuardianChanged(roleId, guardian);
    }

    /**
     * @dev Internal version of {setGrantDelay} without access control.
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function _setGrantDelay(uint64 roleId, uint32 newDelay) internal virtual {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        uint48 effect;
        (_roles[roleId].grantDelay, effect) = _roles[roleId].grantDelay.withUpdate(newDelay, minSetback());

        emit RoleGrantDelayChanged(roleId, newDelay, effect);
    }

    // ============================================= FUNCTION MANAGEMENT ==============================================
    /// @inheritdoc IAccessManager
    function setTargetFunctionRole(
        address target,
        bytes4[] calldata selectors,
        uint64 roleId
    ) public virtual onlyAuthorized {
        for (uint256 i = 0; i < selectors.length; ++i) {
            _setTargetFunctionRole(target, selectors[i], roleId);
        }
    }

    /**
     * @dev Internal version of {setTargetFunctionRole} without access control.
     *
     * Emits a {TargetFunctionRoleUpdated} event.
     */
    function _setTargetFunctionRole(address target, bytes4 selector, uint64 roleId) internal virtual {
        _targets[target].allowedRoles[selector] = roleId;
        emit TargetFunctionRoleUpdated(target, selector, roleId);
    }

    /// @inheritdoc IAccessManager
    function setTargetAdminDelay(address target, uint32 newDelay) public virtual onlyAuthorized {
        _setTargetAdminDelay(target, newDelay);
    }

    /**
     * @dev Internal version of {setTargetAdminDelay} without access control.
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function _setTargetAdminDelay(address target, uint32 newDelay) internal virtual {
        uint48 effect;
        (_targets[target].adminDelay, effect) = _targets[target].adminDelay.withUpdate(newDelay, minSetback());

        emit TargetAdminDelayUpdated(target, newDelay, effect);
    }

    // =============================================== MODE MANAGEMENT ================================================
    /// @inheritdoc IAccessManager
    function setTargetClosed(address target, bool closed) public virtual onlyAuthorized {
        _setTargetClosed(target, closed);
    }

    /**
     * @dev Set the closed flag for a contract. This is an internal setter with no access restrictions.
     *
     * Emits a {TargetClosed} event.
     */
    function _setTargetClosed(address target, bool closed) internal virtual {
        if (target == address(this)) {
            revert AccessManagerLockedAccount(target);
        }
        _targets[target].closed = closed;
        emit TargetClosed(target, closed);
    }

    // ============================================== DELAYED OPERATIONS ==============================================
    /// @inheritdoc IAccessManager
    function getSchedule(bytes32 id) public view virtual returns (uint48) {
        uint48 timepoint = _schedules[id].timepoint;
        return _isExpired(timepoint) ? 0 : timepoint;
    }

    /// @inheritdoc IAccessManager
    function getNonce(bytes32 id) public view virtual returns (uint32) {
        return _schedules[id].nonce;
    }

    /// @inheritdoc IAccessManager
    function schedule(
        address target,
        bytes calldata data,
        uint48 when
    ) public virtual returns (bytes32 operationId, uint32 nonce) {
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        (, uint32 setback) = _canCallExtended(caller, target, data);

        uint48 minWhen = Time.timestamp() + setback;

        // if call with delay is not authorized, or if requested timing is too soon
        if (setback == 0 || (when > 0 && when < minWhen)) {
            revert AccessManagerUnauthorizedCall(caller, target, _checkSelector(data));
        }

        // Reuse variable due to stack too deep
        when = uint48(Math.max(when, minWhen)); // cast is safe: both inputs are uint48

        // If caller is authorised, schedule operation
        operationId = hashOperation(caller, target, data);

        _checkNotScheduled(operationId);

        unchecked {
            // It's not feasible to overflow the nonce in less than 1000 years
            nonce = _schedules[operationId].nonce + 1;
        }
        _schedules[operationId].timepoint = when;
        _schedules[operationId].nonce = nonce;
        emit OperationScheduled(operationId, nonce, when, caller, target, data);

        // Using named return values because otherwise we get stack too deep
    }

    /**
     * @dev Reverts if the operation is currently scheduled and has not expired.
     * (Note: This function was introduced due to stack too deep errors in schedule.)
     */
    function _checkNotScheduled(bytes32 operationId) private view {
        uint48 prevTimepoint = _schedules[operationId].timepoint;
        if (prevTimepoint != 0 && !_isExpired(prevTimepoint)) {
            revert AccessManagerAlreadyScheduled(operationId);
        }
    }

    /// @inheritdoc IAccessManager
    // Reentrancy is not an issue because permissions are checked on msg.sender. Additionally,
    // _consumeScheduledOp guarantees a scheduled operation is only executed once.
    // slither-disable-next-line reentrancy-no-eth
    function execute(address target, bytes calldata data) public payable virtual returns (uint32) {
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        (bool immediate, uint32 setback) = _canCallExtended(caller, target, data);

        // If caller is not authorised, revert
        if (!immediate && setback == 0) {
            revert AccessManagerUnauthorizedCall(caller, target, _checkSelector(data));
        }

        bytes32 operationId = hashOperation(caller, target, data);
        uint32 nonce;

        // If caller is authorised, check operation was scheduled early enough
        // Consume an available schedule even if there is no currently enforced delay
        if (setback != 0 || getSchedule(operationId) != 0) {
            nonce = _consumeScheduledOp(operationId);
        }

        // Mark the target and selector as authorised
        bytes32 executionIdBefore = _executionId;
        _executionId = _hashExecutionId(target, _checkSelector(data));

        // Perform call
        Address.functionCallWithValue(target, data, msg.value);

        // Reset execute identifier
        _executionId = executionIdBefore;

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function cancel(address caller, address target, bytes calldata data) public virtual returns (uint32) {
        address msgsender = _msgSender();
        bytes4 selector = _checkSelector(data);

        bytes32 operationId = hashOperation(caller, target, data);
        if (_schedules[operationId].timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (caller != msgsender) {
            // calls can only be canceled by the account that scheduled them, a global admin, or by a guardian of the required role.
            (bool isAdmin, ) = hasRole(ADMIN_ROLE, msgsender);
            (bool isGuardian, ) = hasRole(getRoleGuardian(getTargetFunctionRole(target, selector)), msgsender);
            if (!isAdmin && !isGuardian) {
                revert AccessManagerUnauthorizedCancel(msgsender, caller, target, selector);
            }
        }

        delete _schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        uint32 nonce = _schedules[operationId].nonce;
        emit OperationCanceled(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function consumeScheduledOp(address caller, bytes calldata data) public virtual {
        address target = _msgSender();
        if (IAccessManaged(target).isConsumingScheduledOp() != IAccessManaged.isConsumingScheduledOp.selector) {
            revert AccessManagerUnauthorizedConsume(target);
        }
        _consumeScheduledOp(hashOperation(caller, target, data));
    }

    /**
     * @dev Internal variant of {consumeScheduledOp} that operates on bytes32 operationId.
     *
     * Returns the nonce of the scheduled operation that is consumed.
     */
    function _consumeScheduledOp(bytes32 operationId) internal virtual returns (uint32) {
        uint48 timepoint = _schedules[operationId].timepoint;
        uint32 nonce = _schedules[operationId].nonce;

        if (timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (timepoint > Time.timestamp()) {
            revert AccessManagerNotReady(operationId);
        } else if (_isExpired(timepoint)) {
            revert AccessManagerExpired(operationId);
        }

        delete _schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        emit OperationExecuted(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function hashOperation(address caller, address target, bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(abi.encode(caller, target, data));
    }

    // ==================================================== OTHERS ====================================================
    /// @inheritdoc IAccessManager
    function updateAuthority(address target, address newAuthority) public virtual onlyAuthorized {
        IAccessManaged(target).setAuthority(newAuthority);
    }

    // ================================================= ADMIN LOGIC ==================================================
    /**
     * @dev Check if the current call is authorized according to admin logic.
     */
    function _checkAuthorized() private {
        address caller = _msgSender();
        (bool immediate, uint32 delay) = _canCallSelf(caller, _msgData());
        if (!immediate) {
            if (delay == 0) {
                (, uint64 requiredRole, ) = _getAdminRestrictions(_msgData());
                revert AccessManagerUnauthorizedAccount(caller, requiredRole);
            } else {
                _consumeScheduledOp(hashOperation(caller, address(this), _msgData()));
            }
        }
    }

    /**
     * @dev Get the admin restrictions of a given function call based on the function and arguments involved.
     *
     * Returns:
     * - bool restricted: does this data match a restricted operation
     * - uint64: which role is this operation restricted to
     * - uint32: minimum delay to enforce for that operation (max between operation's delay and admin's execution delay)
     */
    function _getAdminRestrictions(
        bytes calldata data
    ) private view returns (bool restricted, uint64 roleAdminId, uint32 executionDelay) {
        if (data.length < 4) {
            return (false, 0, 0);
        }

        bytes4 selector = _checkSelector(data);

        // Restricted to ADMIN with no delay beside any execution delay the caller may have
        if (
            selector == this.labelRole.selector ||
            selector == this.setRoleAdmin.selector ||
            selector == this.setRoleGuardian.selector ||
            selector == this.setGrantDelay.selector ||
            selector == this.setTargetAdminDelay.selector
        ) {
            return (true, ADMIN_ROLE, 0);
        }

        // Restricted to ADMIN with the admin delay corresponding to the target
        if (
            selector == this.updateAuthority.selector ||
            selector == this.setTargetClosed.selector ||
            selector == this.setTargetFunctionRole.selector
        ) {
            // First argument is a target.
            address target = abi.decode(data[0x04:0x24], (address));
            uint32 delay = getTargetAdminDelay(target);
            return (true, ADMIN_ROLE, delay);
        }

        // Restricted to that role's admin with no delay beside any execution delay the caller may have.
        if (selector == this.grantRole.selector || selector == this.revokeRole.selector) {
            // First argument is a roleId.
            uint64 roleId = abi.decode(data[0x04:0x24], (uint64));
            return (true, getRoleAdmin(roleId), 0);
        }

        return (false, 0, 0);
    }

    // =================================================== HELPERS ====================================================
    /**
     * @dev An extended version of {canCall} for internal usage that checks {_canCallSelf}
     * when the target is this contract.
     *
     * Returns:
     * - bool immediate: whether the operation can be executed immediately (with no delay)
     * - uint32 delay: the execution delay
     */
    function _canCallExtended(
        address caller,
        address target,
        bytes calldata data
    ) private view returns (bool immediate, uint32 delay) {
        if (target == address(this)) {
            return _canCallSelf(caller, data);
        } else {
            return data.length < 4 ? (false, 0) : canCall(caller, target, _checkSelector(data));
        }
    }

    /**
     * @dev A version of {canCall} that checks for admin restrictions in this contract.
     */
    function _canCallSelf(address caller, bytes calldata data) private view returns (bool immediate, uint32 delay) {
        if (data.length < 4) {
            return (false, 0);
        }

        if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(address(this), _checkSelector(data)), 0);
        }

        (bool enabled, uint64 roleId, uint32 operationDelay) = _getAdminRestrictions(data);
        if (!enabled) {
            return (false, 0);
        }

        (bool inRole, uint32 executionDelay) = hasRole(roleId, caller);
        if (!inRole) {
            return (false, 0);
        }

        // downcast is safe because both options are uint32
        delay = uint32(Math.max(operationDelay, executionDelay));
        return (delay == 0, delay);
    }

    /**
     * @dev Returns true if a call with `target` and `selector` is being executed via {executed}.
     */
    function _isExecuting(address target, bytes4 selector) private view returns (bool) {
        return _executionId == _hashExecutionId(target, selector);
    }

    /**
     * @dev Returns true if a schedule timepoint is past its expiration deadline.
     */
    function _isExpired(uint48 timepoint) private view returns (bool) {
        return timepoint + expiration() <= Time.timestamp();
    }

    /**
     * @dev Extracts the selector from calldata. Panics if data is not at least 4 bytes
     */
    function _checkSelector(bytes calldata data) private pure returns (bytes4) {
        return bytes4(data[0:4]);
    }

    /**
     * @dev Hashing function for execute protection
     */
    function _hashExecutionId(address target, bytes4 selector) private pure returns (bytes32) {
        return keccak256(abi.encode(target, selector));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AuthorityUtils.sol)

pragma solidity ^0.8.20;

import {IAuthority} from "./IAuthority.sol";

library AuthorityUtils {
    /**
     * @dev Since `AccessManager` implements an extended IAuthority interface, invoking `canCall` with backwards compatibility
     * for the preexisting `IAuthority` interface requires special care to avoid reverting on insufficient return data.
     * This helper function takes care of invoking `canCall` in a backwards compatible way without reverting.
     */
    function canCallWithDelay(
        address authority,
        address caller,
        address target,
        bytes4 selector
    ) internal view returns (bool immediate, uint32 delay) {
        (bool success, bytes memory data) = authority.staticcall(
            abi.encodeCall(IAuthority.canCall, (caller, target, selector))
        );
        if (success) {
            if (data.length >= 0x40) {
                (immediate, delay) = abi.decode(data, (bool, uint32));
            } else if (data.length >= 0x20) {
                immediate = abi.decode(data, (bool));
            }
        }
        return (immediate, delay);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAccessManaged.sol)

pragma solidity ^0.8.20;

interface IAccessManaged {
    /**
     * @dev Authority that manages this contract was updated.
     */
    event AuthorityUpdated(address authority);

    error AccessManagedUnauthorized(address caller);
    error AccessManagedRequiredDelay(address caller, uint32 delay);
    error AccessManagedInvalidAuthority(address authority);

    /**
     * @dev Returns the current authority.
     */
    function authority() external view returns (address);

    /**
     * @dev Transfers control to a new authority. The caller must be the current authority.
     */
    function setAuthority(address) external;

    /**
     * @dev Returns true only in the context of a delayed restricted call, at the moment that the scheduled operation is
     * being consumed. Prevents denial of service for delayed restricted calls in the case that the contract performs
     * attacker controlled calls.
     */
    function isConsumingScheduledOp() external view returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManaged} from "./IAccessManaged.sol";
import {Time} from "../../utils/types/Time.sol";

interface IAccessManager {
    /**
     * @dev A delayed operation was scheduled.
     */
    event OperationScheduled(
        bytes32 indexed operationId,
        uint32 indexed nonce,
        uint48 schedule,
        address caller,
        address target,
        bytes data
    );

    /**
     * @dev A scheduled operation was executed.
     */
    event OperationExecuted(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev A scheduled operation was canceled.
     */
    event OperationCanceled(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev Informational labelling for a roleId.
     */
    event RoleLabel(uint64 indexed roleId, string label);

    /**
     * @dev Emitted when `account` is granted `roleId`.
     *
     * NOTE: The meaning of the `since` argument depends on the `newMember` argument.
     * If the role is granted to a new member, the `since` argument indicates when the account becomes a member of the role,
     * otherwise it indicates the execution delay for this account and roleId is updated.
     */
    event RoleGranted(uint64 indexed roleId, address indexed account, uint32 delay, uint48 since, bool newMember);

    /**
     * @dev Emitted when `account` membership or `roleId` is revoked. Unlike granting, revoking is instantaneous.
     */
    event RoleRevoked(uint64 indexed roleId, address indexed account);

    /**
     * @dev Role acting as admin over a given `roleId` is updated.
     */
    event RoleAdminChanged(uint64 indexed roleId, uint64 indexed admin);

    /**
     * @dev Role acting as guardian over a given `roleId` is updated.
     */
    event RoleGuardianChanged(uint64 indexed roleId, uint64 indexed guardian);

    /**
     * @dev Grant delay for a given `roleId` will be updated to `delay` when `since` is reached.
     */
    event RoleGrantDelayChanged(uint64 indexed roleId, uint32 delay, uint48 since);

    /**
     * @dev Target mode is updated (true = closed, false = open).
     */
    event TargetClosed(address indexed target, bool closed);

    /**
     * @dev Role required to invoke `selector` on `target` is updated to `roleId`.
     */
    event TargetFunctionRoleUpdated(address indexed target, bytes4 selector, uint64 indexed roleId);

    /**
     * @dev Admin delay for a given `target` will be updated to `delay` when `since` is reached.
     */
    event TargetAdminDelayUpdated(address indexed target, uint32 delay, uint48 since);

    error AccessManagerAlreadyScheduled(bytes32 operationId);
    error AccessManagerNotScheduled(bytes32 operationId);
    error AccessManagerNotReady(bytes32 operationId);
    error AccessManagerExpired(bytes32 operationId);
    error AccessManagerLockedAccount(address account);
    error AccessManagerLockedRole(uint64 roleId);
    error AccessManagerBadConfirmation();
    error AccessManagerUnauthorizedAccount(address msgsender, uint64 roleId);
    error AccessManagerUnauthorizedCall(address caller, address target, bytes4 selector);
    error AccessManagerUnauthorizedConsume(address target);
    error AccessManagerUnauthorizedCancel(address msgsender, address caller, address target, bytes4 selector);
    error AccessManagerInvalidInitialAdmin(address initialAdmin);

    /**
     * @dev Check if an address (`caller`) is authorised to call a given function on a given contract directly (with
     * no restriction). Additionally, it returns the delay needed to perform the call indirectly through the {schedule}
     * & {execute} workflow.
     *
     * This function is usually called by the targeted contract to control immediate execution of restricted functions.
     * Therefore we only return true if the call can be performed without any delay. If the call is subject to a
     * previously set delay (not zero), then the function should return false and the caller should schedule the operation
     * for future execution.
     *
     * If `immediate` is true, the delay can be disregarded and the operation can be immediately executed, otherwise
     * the operation can be executed if and only if delay is greater than 0.
     *
     * NOTE: The IAuthority interface does not include the `uint32` delay. This is an extension of that interface that
     * is backward compatible. Some contracts may thus ignore the second return argument. In that case they will fail
     * to identify the indirect workflow, and will consider calls that require a delay to be forbidden.
     *
     * NOTE: This function does not report the permissions of this manager itself. These are defined by the
     * {_canCallSelf} function instead.
     */
    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) external view returns (bool allowed, uint32 delay);

    /**
     * @dev Expiration delay for scheduled proposals. Defaults to 1 week.
     *
     * IMPORTANT: Avoid overriding the expiration with 0. Otherwise every contract proposal will be expired immediately,
     * disabling any scheduling usage.
     */
    function expiration() external view returns (uint32);

    /**
     * @dev Minimum setback for all delay updates, with the exception of execution delays. It
     * can be increased without setback (and reset via {revokeRole} in the case event of an
     * accidental increase). Defaults to 5 days.
     */
    function minSetback() external view returns (uint32);

    /**
     * @dev Get whether the contract is closed disabling any access. Otherwise role permissions are applied.
     */
    function isTargetClosed(address target) external view returns (bool);

    /**
     * @dev Get the role required to call a function.
     */
    function getTargetFunctionRole(address target, bytes4 selector) external view returns (uint64);

    /**
     * @dev Get the admin delay for a target contract. Changes to contract configuration are subject to this delay.
     */
    function getTargetAdminDelay(address target) external view returns (uint32);

    /**
     * @dev Get the id of the role that acts as an admin for the given role.
     *
     * The admin permission is required to grant the role, revoke the role and update the execution delay to execute
     * an operation that is restricted to this role.
     */
    function getRoleAdmin(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role that acts as a guardian for a given role.
     *
     * The guardian permission allows canceling operations that have been scheduled under the role.
     */
    function getRoleGuardian(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role current grant delay.
     *
     * Its value may change at any point without an event emitted following a call to {setGrantDelay}.
     * Changes to this value, including effect timepoint are notified in advance by the {RoleGrantDelayChanged} event.
     */
    function getRoleGrantDelay(uint64 roleId) external view returns (uint32);

    /**
     * @dev Get the access details for a given account for a given role. These details include the timepoint at which
     * membership becomes active, and the delay applied to all operation by this user that requires this permission
     * level.
     *
     * Returns:
     * [0] Timestamp at which the account membership becomes valid. 0 means role is not granted.
     * [1] Current execution delay for the account.
     * [2] Pending execution delay for the account.
     * [3] Timestamp at which the pending execution delay will become active. 0 means no delay update is scheduled.
     */
    function getAccess(uint64 roleId, address account) external view returns (uint48, uint32, uint32, uint48);

    /**
     * @dev Check if a given account currently has the permission level corresponding to a given role. Note that this
     * permission might be associated with an execution delay. {getAccess} can provide more details.
     */
    function hasRole(uint64 roleId, address account) external view returns (bool, uint32);

    /**
     * @dev Give a label to a role, for improved role discoverability by UIs.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleLabel} event.
     */
    function labelRole(uint64 roleId, string calldata label) external;

    /**
     * @dev Add `account` to `roleId`, or change its execution delay.
     *
     * This gives the account the authorization to call any function that is restricted to this role. An optional
     * execution delay (in seconds) can be set. If that delay is non 0, the user is required to schedule any operation
     * that is restricted to members of this role. The user will only be able to execute the operation after the delay has
     * passed, before it has expired. During this period, admin and guardians can cancel the operation (see {cancel}).
     *
     * If the account has already been granted this role, the execution delay will be updated. This update is not
     * immediate and follows the delay rules. For example, if a user currently has a delay of 3 hours, and this is
     * called to reduce that delay to 1 hour, the new delay will take some time to take effect, enforcing that any
     * operation executed in the 3 hours that follows this update was indeed scheduled before this update.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - granted role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleGranted} event.
     */
    function grantRole(uint64 roleId, address account, uint32 executionDelay) external;

    /**
     * @dev Remove an account from a role, with immediate effect. If the account does not have the role, this call has
     * no effect.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - revoked role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function revokeRole(uint64 roleId, address account) external;

    /**
     * @dev Renounce role permissions for the calling account with immediate effect. If the sender is not in
     * the role this call has no effect.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function renounceRole(uint64 roleId, address callerConfirmation) external;

    /**
     * @dev Change admin role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleAdminChanged} event
     */
    function setRoleAdmin(uint64 roleId, uint64 admin) external;

    /**
     * @dev Change guardian role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGuardianChanged} event
     */
    function setRoleGuardian(uint64 roleId, uint64 guardian) external;

    /**
     * @dev Update the delay for granting a `roleId`.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function setGrantDelay(uint64 roleId, uint32 newDelay) external;

    /**
     * @dev Set the role required to call functions identified by the `selectors` in the `target` contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetFunctionRoleUpdated} event per selector.
     */
    function setTargetFunctionRole(address target, bytes4[] calldata selectors, uint64 roleId) external;

    /**
     * @dev Set the delay for changing the configuration of a given target contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function setTargetAdminDelay(address target, uint32 newDelay) external;

    /**
     * @dev Set the closed flag for a contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetClosed} event.
     */
    function setTargetClosed(address target, bool closed) external;

    /**
     * @dev Return the timepoint at which a scheduled operation will be ready for execution. This returns 0 if the
     * operation is not yet scheduled, has expired, was executed, or was canceled.
     */
    function getSchedule(bytes32 id) external view returns (uint48);

    /**
     * @dev Return the nonce for the latest scheduled operation with a given id. Returns 0 if the operation has never
     * been scheduled.
     */
    function getNonce(bytes32 id) external view returns (uint32);

    /**
     * @dev Schedule a delayed operation for future execution, and return the operation identifier. It is possible to
     * choose the timestamp at which the operation becomes executable as long as it satisfies the execution delays
     * required for the caller. The special value zero will automatically set the earliest possible time.
     *
     * Returns the `operationId` that was scheduled. Since this value is a hash of the parameters, it can reoccur when
     * the same parameters are used; if this is relevant, the returned `nonce` can be used to uniquely identify this
     * scheduled operation from other occurrences of the same `operationId` in invocations of {execute} and {cancel}.
     *
     * Emits a {OperationScheduled} event.
     *
     * NOTE: It is not possible to concurrently schedule more than one operation with the same `target` and `data`. If
     * this is necessary, a random byte can be appended to `data` to act as a salt that will be ignored by the target
     * contract if it is using standard Solidity ABI encoding.
     */
    function schedule(address target, bytes calldata data, uint48 when) external returns (bytes32, uint32);

    /**
     * @dev Execute a function that is delay restricted, provided it was properly scheduled beforehand, or the
     * execution delay is 0.
     *
     * Returns the nonce that identifies the previously scheduled operation that is executed, or 0 if the
     * operation wasn't previously scheduled (if the caller doesn't have an execution delay).
     *
     * Emits an {OperationExecuted} event only if the call was scheduled and delayed.
     */
    function execute(address target, bytes calldata data) external payable returns (uint32);

    /**
     * @dev Cancel a scheduled (delayed) operation. Returns the nonce that identifies the previously scheduled
     * operation that is cancelled.
     *
     * Requirements:
     *
     * - the caller must be the proposer, a guardian of the targeted function, or a global admin
     *
     * Emits a {OperationCanceled} event.
     */
    function cancel(address caller, address target, bytes calldata data) external returns (uint32);

    /**
     * @dev Consume a scheduled operation targeting the caller. If such an operation exists, mark it as consumed
     * (emit an {OperationExecuted} event and clean the state). Otherwise, throw an error.
     *
     * This is useful for contract that want to enforce that calls targeting them were scheduled on the manager,
     * with all the verifications that it implies.
     *
     * Emit a {OperationExecuted} event.
     */
    function consumeScheduledOp(address caller, bytes calldata data) external;

    /**
     * @dev Hashing function for delayed operations.
     */
    function hashOperation(address caller, address target, bytes calldata data) external view returns (bytes32);

    /**
     * @dev Changes the authority of a target managed by this manager instance.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     */
    function updateAuthority(address target, address newAuthority) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAuthority.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard interface for permissioning originally defined in Dappsys.
 */
interface IAuthority {
    /**
     * @dev Returns true if the caller can invoke on a target the function identified by a function selector.
     */
    function canCall(address caller, address target, bytes4 selector) external view returns (bool allowed);
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/types/Time.sol)

pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";
import {SafeCast} from "../math/SafeCast.sol";

/**
 * @dev This library provides helpers for manipulating time-related objects.
 *
 * It uses the following types:
 * - `uint48` for timepoints
 * - `uint32` for durations
 *
 * While the library doesn't provide specific types for timepoints and duration, it does provide:
 * - a `Delay` type to represent duration that can be programmed to change value automatically at a given point
 * - additional helper functions
 */
library Time {
    using Time for *;

    /**
     * @dev Get the block timestamp as a Timepoint.
     */
    function timestamp() internal view returns (uint48) {
        return SafeCast.toUint48(block.timestamp);
    }

    /**
     * @dev Get the block number as a Timepoint.
     */
    function blockNumber() internal view returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    // ==================================================== Delay =====================================================
    /**
     * @dev A `Delay` is a uint32 duration that can be programmed to change value automatically at a given point in the
     * future. The "effect" timepoint describes when the transitions happens from the "old" value to the "new" value.
     * This allows updating the delay applied to some operation while keeping some guarantees.
     *
     * In particular, the {update} function guarantees that if the delay is reduced, the old delay still applies for
     * some time. For example if the delay is currently 7 days to do an upgrade, the admin should not be able to set
     * the delay to 0 and upgrade immediately. If the admin wants to reduce the delay, the old delay (7 days) should
     * still apply for some time.
     *
     *
     * The `Delay` type is 112 bits long, and packs the following:
     *
     * ```
     *   | [uint48]: effect date (timepoint)
     *   |           | [uint32]: value before (duration)
     *   ↓           ↓       ↓ [uint32]: value after (duration)
     * 0xAAAAAAAAAAAABBBBBBBBCCCCCCCC
     * ```
     *
     * NOTE: The {get} and {withUpdate} functions operate using timestamps. Block number based delays are not currently
     * supported.
     */
    type Delay is uint112;

    /**
     * @dev Wrap a duration into a Delay to add the one-step "update in the future" feature
     */
    function toDelay(uint32 duration) internal pure returns (Delay) {
        return Delay.wrap(duration);
    }

    /**
     * @dev Get the value at a given timepoint plus the pending value and effect timepoint if there is a scheduled
     * change after this timepoint. If the effect timepoint is 0, then the pending value should not be considered.
     */
    function _getFullAt(Delay self, uint48 timepoint) private pure returns (uint32, uint32, uint48) {
        (uint32 valueBefore, uint32 valueAfter, uint48 effect) = self.unpack();
        return effect <= timepoint ? (valueAfter, 0, 0) : (valueBefore, valueAfter, effect);
    }

    /**
     * @dev Get the current value plus the pending value and effect timepoint if there is a scheduled change. If the
     * effect timepoint is 0, then the pending value should not be considered.
     */
    function getFull(Delay self) internal view returns (uint32, uint32, uint48) {
        return _getFullAt(self, timestamp());
    }

    /**
     * @dev Get the current value.
     */
    function get(Delay self) internal view returns (uint32) {
        (uint32 delay, , ) = self.getFull();
        return delay;
    }

    /**
     * @dev Update a Delay object so that it takes a new duration after a timepoint that is automatically computed to
     * enforce the old delay at the moment of the update. Returns the updated Delay object and the timestamp when the
     * new delay becomes effective.
     */
    function withUpdate(
        Delay self,
        uint32 newValue,
        uint32 minSetback
    ) internal view returns (Delay updatedDelay, uint48 effect) {
        uint32 value = self.get();
        uint32 setback = uint32(Math.max(minSetback, value > newValue ? value - newValue : 0));
        effect = timestamp() + setback;
        return (pack(value, newValue, effect), effect);
    }

    /**
     * @dev Split a delay into its components: valueBefore, valueAfter and effect (transition timepoint).
     */
    function unpack(Delay self) internal pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        uint112 raw = Delay.unwrap(self);

        valueAfter = uint32(raw);
        valueBefore = uint32(raw >> 32);
        effect = uint48(raw >> 64);

        return (valueBefore, valueAfter, effect);
    }

    /**
     * @dev pack the components into a Delay object.
     */
    function pack(uint32 valueBefore, uint32 valueAfter, uint48 effect) internal pure returns (Delay) {
        return Delay.wrap((uint112(effect) << 64) | (uint112(valueBefore) << 32) | uint112(valueAfter));
    }
}