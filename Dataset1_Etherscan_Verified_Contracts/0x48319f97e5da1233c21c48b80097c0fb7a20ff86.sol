// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IERC5267} from '@openzeppelin/contracts/interfaces/IERC5267.sol';

/**
 * @title IKeeperOracles
 * @author StakeWise
 * @notice Defines the interface for the KeeperOracles contract
 */
interface IKeeperOracles is IERC5267 {
  /**
   * @notice Event emitted on the oracle addition
   * @param oracle The address of the added oracle
   */
  event OracleAdded(address indexed oracle);

  /**
   * @notice Event emitted on the oracle removal
   * @param oracle The address of the removed oracle
   */
  event OracleRemoved(address indexed oracle);

  /**
   * @notice Event emitted on oracles config update
   * @param configIpfsHash The IPFS hash of the new config
   */
  event ConfigUpdated(string configIpfsHash);

  /**
   * @notice Function for verifying whether oracle is registered or not
   * @param oracle The address of the oracle to check
   * @return `true` for the registered oracle, `false` otherwise
   */
  function isOracle(address oracle) external view returns (bool);

  /**
   * @notice Total Oracles
   * @return The total number of oracles registered
   */
  function totalOracles() external view returns (uint256);

  /**
   * @notice Function for adding oracle to the set
   * @param oracle The address of the oracle to add
   */
  function addOracle(address oracle) external;

  /**
   * @notice Function for removing oracle from the set
   * @param oracle The address of the oracle to remove
   */
  function removeOracle(address oracle) external;

  /**
   * @notice Function for updating the config IPFS hash
   * @param configIpfsHash The new config IPFS hash
   */
  function updateConfig(string calldata configIpfsHash) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IKeeperOracles} from './IKeeperOracles.sol';

/**
 * @title IKeeperRewards
 * @author StakeWise
 * @notice Defines the interface for the Keeper contract rewards
 */
interface IKeeperRewards is IKeeperOracles {
  /**
   * @notice Event emitted on rewards update
   * @param caller The address of the function caller
   * @param rewardsRoot The new rewards merkle tree root
   * @param avgRewardPerSecond The new average reward per second
   * @param updateTimestamp The update timestamp used for rewards calculation
   * @param nonce The nonce used for verifying signatures
   * @param rewardsIpfsHash The new rewards IPFS hash
   */
  event RewardsUpdated(
    address indexed caller,
    bytes32 indexed rewardsRoot,
    uint256 avgRewardPerSecond,
    uint64 updateTimestamp,
    uint64 nonce,
    string rewardsIpfsHash
  );

  /**
   * @notice Event emitted on Vault harvest
   * @param vault The address of the Vault
   * @param rewardsRoot The rewards merkle tree root
   * @param totalAssetsDelta The Vault total assets delta since last sync. Can be negative in case of penalty/slashing.
   * @param unlockedMevDelta The Vault execution reward that can be withdrawn from shared MEV escrow. Only used by shared MEV Vaults.
   */
  event Harvested(
    address indexed vault,
    bytes32 indexed rewardsRoot,
    int256 totalAssetsDelta,
    uint256 unlockedMevDelta
  );

  /**
   * @notice Event emitted on rewards min oracles number update
   * @param oracles The new minimum number of oracles required to update rewards
   */
  event RewardsMinOraclesUpdated(uint256 oracles);

  /**
   * @notice A struct containing the last synced Vault's cumulative reward
   * @param assets The Vault cumulative reward earned since the start. Can be negative in case of penalty/slashing.
   * @param nonce The nonce of the last sync
   */
  struct Reward {
    int192 assets;
    uint64 nonce;
  }

  /**
   * @notice A struct containing the last unlocked Vault's cumulative execution reward that can be withdrawn from shared MEV escrow. Only used by shared MEV Vaults.
   * @param assets The shared MEV Vault's cumulative execution reward that can be withdrawn
   * @param nonce The nonce of the last sync
   */
  struct UnlockedMevReward {
    uint192 assets;
    uint64 nonce;
  }

  /**
   * @notice A struct containing parameters for rewards update
   * @param rewardsRoot The new rewards merkle root
   * @param avgRewardPerSecond The new average reward per second
   * @param updateTimestamp The update timestamp used for rewards calculation
   * @param rewardsIpfsHash The new IPFS hash with all the Vaults' rewards for the new root
   * @param signatures The concatenation of the Oracles' signatures
   */
  struct RewardsUpdateParams {
    bytes32 rewardsRoot;
    uint256 avgRewardPerSecond;
    uint64 updateTimestamp;
    string rewardsIpfsHash;
    bytes signatures;
  }

  /**
   * @notice A struct containing parameters for harvesting rewards. Can only be called by Vault.
   * @param rewardsRoot The rewards merkle root
   * @param reward The Vault cumulative reward earned since the start. Can be negative in case of penalty/slashing.
   * @param unlockedMevReward The Vault cumulative execution reward that can be withdrawn from shared MEV escrow. Only used by shared MEV Vaults.
   * @param proof The proof to verify that Vault's reward is correct
   */
  struct HarvestParams {
    bytes32 rewardsRoot;
    int160 reward;
    uint160 unlockedMevReward;
    bytes32[] proof;
  }

  /**
   * @notice Previous Rewards Root
   * @return The previous merkle tree root of the rewards accumulated by the Vaults
   */
  function prevRewardsRoot() external view returns (bytes32);

  /**
   * @notice Rewards Root
   * @return The latest merkle tree root of the rewards accumulated by the Vaults
   */
  function rewardsRoot() external view returns (bytes32);

  /**
   * @notice Rewards Nonce
   * @return The nonce used for updating rewards merkle tree root
   */
  function rewardsNonce() external view returns (uint64);

  /**
   * @notice The last rewards update
   * @return The timestamp of the last rewards update
   */
  function lastRewardsTimestamp() external view returns (uint64);

  /**
   * @notice The minimum number of oracles required to update rewards
   * @return The minimum number of oracles
   */
  function rewardsMinOracles() external view returns (uint256);

  /**
   * @notice The rewards delay
   * @return The delay in seconds between rewards updates
   */
  function rewardsDelay() external view returns (uint256);

  /**
   * @notice Get last synced Vault cumulative reward
   * @param vault The address of the Vault
   * @return assets The last synced reward assets
   * @return nonce The last synced reward nonce
   */
  function rewards(address vault) external view returns (int192 assets, uint64 nonce);

  /**
   * @notice Get last unlocked shared MEV Vault cumulative reward
   * @param vault The address of the Vault
   * @return assets The last synced reward assets
   * @return nonce The last synced reward nonce
   */
  function unlockedMevRewards(address vault) external view returns (uint192 assets, uint64 nonce);

  /**
   * @notice Checks whether Vault must be harvested
   * @param vault The address of the Vault
   * @return `true` if the Vault requires harvesting, `false` otherwise
   */
  function isHarvestRequired(address vault) external view returns (bool);

  /**
   * @notice Checks whether the Vault can be harvested
   * @param vault The address of the Vault
   * @return `true` if Vault can be harvested, `false` otherwise
   */
  function canHarvest(address vault) external view returns (bool);

  /**
   * @notice Checks whether rewards can be updated
   * @return `true` if rewards can be updated, `false` otherwise
   */
  function canUpdateRewards() external view returns (bool);

  /**
   * @notice Checks whether the Vault has registered validators
   * @param vault The address of the Vault
   * @return `true` if Vault is collateralized, `false` otherwise
   */
  function isCollateralized(address vault) external view returns (bool);

  /**
   * @notice Update rewards data
   * @param params The struct containing rewards update parameters
   */
  function updateRewards(RewardsUpdateParams calldata params) external;

  /**
   * @notice Harvest rewards. Can be called only by Vault.
   * @param params The struct containing rewards harvesting parameters
   * @return totalAssetsDelta The total reward/penalty accumulated by the Vault since the last sync
   * @return unlockedMevDelta The Vault execution reward that can be withdrawn from shared MEV escrow. Only used by shared MEV Vaults.
   * @return harvested `true` when the rewards were harvested, `false` otherwise
   */
  function harvest(
    HarvestParams calldata params
  ) external returns (int256 totalAssetsDelta, uint256 unlockedMevDelta, bool harvested);

  /**
   * @notice Set min number of oracles for confirming rewards update. Can only be called by the owner.
   * @param _rewardsMinOracles The new min number of oracles for confirming rewards update
   */
  function setRewardsMinOracles(uint256 _rewardsMinOracles) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IKeeperRewards} from './IKeeperRewards.sol';
import {IKeeperOracles} from './IKeeperOracles.sol';

/**
 * @title IKeeperValidators
 * @author StakeWise
 * @notice Defines the interface for the Keeper validators
 */
interface IKeeperValidators is IKeeperOracles, IKeeperRewards {
  /**
   * @notice Event emitted on validators approval
   * @param vault The address of the Vault
   * @param exitSignaturesIpfsHash The IPFS hash with the validators' exit signatures
   */
  event ValidatorsApproval(address indexed vault, string exitSignaturesIpfsHash);

  /**
   * @notice Event emitted on exit signatures update
   * @param caller The address of the function caller
   * @param vault The address of the Vault
   * @param nonce The nonce used for verifying Oracles' signatures
   * @param exitSignaturesIpfsHash The IPFS hash with the validators' exit signatures
   */
  event ExitSignaturesUpdated(
    address indexed caller,
    address indexed vault,
    uint256 nonce,
    string exitSignaturesIpfsHash
  );

  /**
   * @notice Event emitted on validators min oracles number update
   * @param oracles The new minimum number of oracles required to approve validators
   */
  event ValidatorsMinOraclesUpdated(uint256 oracles);

  /**
   * @notice Get nonce for the next vault exit signatures update
   * @param vault The address of the Vault to get the nonce for
   * @return The nonce of the Vault for updating signatures
   */
  function exitSignaturesNonces(address vault) external view returns (uint256);

  /**
   * @notice Struct for approving registration of one or more validators
   * @param validatorsRegistryRoot The deposit data root used to verify that oracles approved validators
   * @param deadline The deadline for submitting the approval
   * @param validators The concatenation of the validators' public key, signature and deposit data root
   * @param signatures The concatenation of Oracles' signatures
   * @param exitSignaturesIpfsHash The IPFS hash with the validators' exit signatures
   */
  struct ApprovalParams {
    bytes32 validatorsRegistryRoot;
    uint256 deadline;
    bytes validators;
    bytes signatures;
    string exitSignaturesIpfsHash;
  }

  /**
   * @notice The minimum number of oracles required to update validators
   * @return The minimum number of oracles
   */
  function validatorsMinOracles() external view returns (uint256);

  /**
   * @notice Function for approving validators registration
   * @param params The parameters for approving validators registration
   */
  function approveValidators(ApprovalParams calldata params) external;

  /**
   * @notice Function for updating exit signatures for every hard fork
   * @param vault The address of the Vault to update signatures for
   * @param deadline The deadline for submitting signatures update
   * @param exitSignaturesIpfsHash The IPFS hash with the validators' exit signatures
   * @param oraclesSignatures The concatenation of Oracles' signatures
   */
  function updateExitSignatures(
    address vault,
    uint256 deadline,
    string calldata exitSignaturesIpfsHash,
    bytes calldata oraclesSignatures
  ) external;

  /**
   * @notice Function for updating validators min oracles number
   * @param _validatorsMinOracles The new minimum number of oracles required to approve validators
   */
  function setValidatorsMinOracles(uint256 _validatorsMinOracles) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

/**
 * @title ISharedMevEscrow
 * @author StakeWise
 * @notice Defines the interface for the SharedMevEscrow contract
 */
interface ISharedMevEscrow {
  /**
   * @notice Event emitted on received MEV
   * @param assets The amount of MEV assets received
   */
  event MevReceived(uint256 assets);

  /**
   * @notice Event emitted on harvest
   * @param caller The function caller
   * @param assets The amount of assets withdrawn
   */
  event Harvested(address indexed caller, uint256 assets);

  /**
   * @notice Withdraws MEV accumulated in the escrow. Can be called only by the Vault.
   * @dev IMPORTANT: because control is transferred to the Vault, care must be
   *    taken to not create reentrancy vulnerabilities. The Vault must follow the checks-effects-interactions pattern:
   *    https://docs.soliditylang.org/en/v0.8.22/security-considerations.html#use-the-checks-effects-interactions-pattern
   * @param assets The amount of assets to withdraw
   */
  function harvest(uint256 assets) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

/**
 * @title IVaultState
 * @author StakeWise
 * @notice Defines the interface for the VaultAdmin contract
 */
interface IVaultAdmin {
  /**
   * @notice Event emitted on metadata ipfs hash update
   * @param caller The address of the function caller
   * @param metadataIpfsHash The new metadata IPFS hash
   */
  event MetadataUpdated(address indexed caller, string metadataIpfsHash);

  /**
   * @notice The Vault admin
   * @return The address of the Vault admin
   */
  function admin() external view returns (address);

  /**
   * @notice Function for updating the metadata IPFS hash. Can only be called by Vault admin.
   * @param metadataIpfsHash The new metadata IPFS hash
   */
  function setMetadata(string calldata metadataIpfsHash) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IVaultState} from './IVaultState.sol';

/**
 * @title IVaultEnterExit
 * @author StakeWise
 * @notice Defines the interface for the VaultEnterExit contract
 */
interface IVaultEnterExit is IVaultState {
  /**
   * @notice Event emitted on deposit
   * @param caller The address that called the deposit function
   * @param receiver The address that received the shares
   * @param assets The number of assets deposited by the caller
   * @param shares The number of shares received
   * @param referrer The address of the referrer
   */
  event Deposited(
    address indexed caller,
    address indexed receiver,
    uint256 assets,
    uint256 shares,
    address referrer
  );

  /**
   * @notice Event emitted on redeem
   * @param owner The address that owns the shares
   * @param receiver The address that received withdrawn assets
   * @param assets The total number of withdrawn assets
   * @param shares The total number of withdrawn shares
   */
  event Redeemed(address indexed owner, address indexed receiver, uint256 assets, uint256 shares);

  /**
   * @notice Event emitted on shares added to the exit queue
   * @param owner The address that owns the shares
   * @param receiver The address that will receive withdrawn assets
   * @param positionTicket The exit queue ticket that was assigned to the position
   * @param shares The number of shares that queued for the exit
   */
  event ExitQueueEntered(
    address indexed owner,
    address indexed receiver,
    uint256 positionTicket,
    uint256 shares
  );

  /**
   * @notice Event emitted on claim of the exited assets
   * @param receiver The address that has received withdrawn assets
   * @param prevPositionTicket The exit queue ticket received after the `enterExitQueue` call
   * @param newPositionTicket The new exit queue ticket in case not all the shares were withdrawn. Otherwise 0.
   * @param withdrawnAssets The total number of assets withdrawn
   */
  event ExitedAssetsClaimed(
    address indexed receiver,
    uint256 prevPositionTicket,
    uint256 newPositionTicket,
    uint256 withdrawnAssets
  );

  /**
   * @notice Locks shares to the exit queue. The shares continue earning rewards until they will be burned by the Vault.
   * @param shares The number of shares to lock
   * @param receiver The address that will receive assets upon withdrawal
   * @return positionTicket The position ticket of the exit queue
   */
  function enterExitQueue(
    uint256 shares,
    address receiver
  ) external returns (uint256 positionTicket);

  /**
   * @notice Get the exit queue index to claim exited assets from
   * @param positionTicket The exit queue position ticket to get the index for
   * @return The exit queue index that should be used to claim exited assets.
   *         Returns -1 in case such index does not exist.
   */
  function getExitQueueIndex(uint256 positionTicket) external view returns (int256);

  /**
   * @notice Calculates the number of shares and assets that can be claimed from the exit queue.
   * @param receiver The address that will receive assets upon withdrawal
   * @param positionTicket The exit queue ticket received after the `enterExitQueue` call
   * @param timestamp The timestamp when the shares entered the exit queue
   * @param exitQueueIndex The exit queue index at which the shares were burned. It can be looked up by calling `getExitQueueIndex`.
   * @return leftShares The number of shares that are still in the queue
   * @return claimedShares The number of claimed shares
   * @return claimedAssets The number of claimed assets
   */
  function calculateExitedAssets(
    address receiver,
    uint256 positionTicket,
    uint256 timestamp,
    uint256 exitQueueIndex
  ) external view returns (uint256 leftShares, uint256 claimedShares, uint256 claimedAssets);

  /**
   * @notice Claims assets that were withdrawn by the Vault. It can be called only after the `enterExitQueue` call by the `receiver`.
   * @param positionTicket The exit queue ticket received after the `enterExitQueue` call
   * @param timestamp The timestamp when the shares entered the exit queue
   * @param exitQueueIndex The exit queue index at which the shares were burned. It can be looked up by calling `getExitQueueIndex`.
   * @return newPositionTicket The new exit queue ticket in case not all the shares were burned. Otherwise 0.
   * @return claimedShares The number of shares claimed
   * @return claimedAssets The number of assets claimed
   */
  function claimExitedAssets(
    uint256 positionTicket,
    uint256 timestamp,
    uint256 exitQueueIndex
  ) external returns (uint256 newPositionTicket, uint256 claimedShares, uint256 claimedAssets);

  /**
   * @notice Redeems assets from the Vault by utilising what has not been staked yet. Can only be called when vault is not collateralized.
   * @param shares The number of shares to burn
   * @param receiver The address that will receive assets
   * @return assets The number of assets withdrawn
   */
  function redeem(uint256 shares, address receiver) external returns (uint256 assets);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IVaultState} from './IVaultState.sol';
import {IVaultValidators} from './IVaultValidators.sol';
import {IVaultEnterExit} from './IVaultEnterExit.sol';
import {IKeeperRewards} from './IKeeperRewards.sol';
import {IVaultMev} from './IVaultMev.sol';

/**
 * @title IVaultEthStaking
 * @author StakeWise
 * @notice Defines the interface for the VaultEthStaking contract
 */
interface IVaultEthStaking is IVaultState, IVaultValidators, IVaultEnterExit, IVaultMev {
  /**
   * @notice Deposit ETH to the Vault
   * @param receiver The address that will receive Vault's shares
   * @param referrer The address of the referrer. Set to zero address if not used.
   * @return shares The number of shares minted
   */
  function deposit(address receiver, address referrer) external payable returns (uint256 shares);

  /**
   * @notice Used by MEV escrow to transfer ETH.
   */
  function receiveFromMevEscrow() external payable;

  /**
   * @notice Updates Vault state and deposits ETH to the Vault
   * @param receiver The address that will receive Vault's shares
   * @param referrer The address of the referrer. Set to zero address if not used.
   * @param harvestParams The parameters for harvesting Keeper rewards
   * @return shares The number of shares minted
   */
  function updateStateAndDeposit(
    address receiver,
    address referrer,
    IKeeperRewards.HarvestParams calldata harvestParams
  ) external payable returns (uint256 shares);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IVaultAdmin} from './IVaultAdmin.sol';

/**
 * @title IVaultFee
 * @author StakeWise
 * @notice Defines the interface for the VaultFee contract
 */
interface IVaultFee is IVaultAdmin {
  /**
   * @notice Event emitted on fee recipient update
   * @param caller The address of the function caller
   * @param feeRecipient The address of the new fee recipient
   */
  event FeeRecipientUpdated(address indexed caller, address indexed feeRecipient);

  /**
   * @notice The Vault's fee recipient
   * @return The address of the Vault's fee recipient
   */
  function feeRecipient() external view returns (address);

  /**
   * @notice The Vault's fee percent in BPS
   * @return The fee percent applied by the Vault on the rewards
   */
  function feePercent() external view returns (uint16);

  /**
   * @notice Function for updating the fee recipient address. Can only be called by the admin.
   * @param _feeRecipient The address of the new fee recipient
   */
  function setFeeRecipient(address _feeRecipient) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IVaultState} from './IVaultState.sol';

/**
 * @title IVaultMev
 * @author StakeWise
 * @notice Common interface for the VaultMev contracts
 */
interface IVaultMev is IVaultState {
  /**
   * @notice The contract that accumulates MEV rewards
   * @return The MEV escrow contract address
   */
  function mevEscrow() external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IKeeperRewards} from './IKeeperRewards.sol';
import {IVaultFee} from './IVaultFee.sol';

/**
 * @title IVaultState
 * @author StakeWise
 * @notice Defines the interface for the VaultState contract
 */
interface IVaultState is IVaultFee {
  /**
   * @notice Event emitted on checkpoint creation
   * @param shares The number of burned shares
   * @param assets The amount of exited assets
   */
  event CheckpointCreated(uint256 shares, uint256 assets);

  /**
   * @notice Event emitted on minting fee recipient shares
   * @param receiver The address of the fee recipient
   * @param shares The number of minted shares
   * @param assets The amount of minted assets
   */
  event FeeSharesMinted(address receiver, uint256 shares, uint256 assets);

  /**
   * @notice Total assets in the Vault
   * @return The total amount of the underlying asset that is "managed" by Vault
   */
  function totalAssets() external view returns (uint256);

  /**
   * @notice Function for retrieving total shares
   * @return The amount of shares in existence
   */
  function totalShares() external view returns (uint256);

  /**
   * @notice The Vault's capacity
   * @return The amount after which the Vault stops accepting deposits
   */
  function capacity() external view returns (uint256);

  /**
   * @notice Total assets available in the Vault. They can be staked or withdrawn.
   * @return The total amount of withdrawable assets
   */
  function withdrawableAssets() external view returns (uint256);

  /**
   * @notice Queued Shares
   * @return The total number of shares queued for exit
   */
  function queuedShares() external view returns (uint128);

  /**
   * @notice Returns the number of shares held by an account
   * @param account The account for which to look up the number of shares it has, i.e. its balance
   * @return The number of shares held by the account
   */
  function getShares(address account) external view returns (uint256);

  /**
   * @notice Converts shares to assets
   * @param assets The amount of assets to convert to shares
   * @return shares The amount of shares that the Vault would exchange for the amount of assets provided
   */
  function convertToShares(uint256 assets) external view returns (uint256 shares);

  /**
   * @notice Converts assets to shares
   * @param shares The amount of shares to convert to assets
   * @return assets The amount of assets that the Vault would exchange for the amount of shares provided
   */
  function convertToAssets(uint256 shares) external view returns (uint256 assets);

  /**
   * @notice Check whether state update is required
   * @return `true` if state update is required, `false` otherwise
   */
  function isStateUpdateRequired() external view returns (bool);

  /**
   * @notice Updates the total amount of assets in the Vault and its exit queue
   * @param harvestParams The parameters for harvesting Keeper rewards
   */
  function updateState(IKeeperRewards.HarvestParams calldata harvestParams) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {IKeeperValidators} from './IKeeperValidators.sol';
import {IVaultAdmin} from './IVaultAdmin.sol';
import {IVaultState} from './IVaultState.sol';

/**
 * @title IVaultValidators
 * @author StakeWise
 * @notice Defines the interface for VaultValidators contract
 */
interface IVaultValidators is IVaultAdmin, IVaultState {
  /**
   * @notice Event emitted on validator registration
   * @param publicKey The public key of the validator that was registered
   */
  event ValidatorRegistered(bytes publicKey);

  /**
   * @notice Event emitted on keys manager address update
   * @param caller The address of the function caller
   * @param keysManager The address of the new keys manager
   */
  event KeysManagerUpdated(address indexed caller, address indexed keysManager);

  /**
   * @notice Event emitted on validators merkle tree root update
   * @param caller The address of the function caller
   * @param validatorsRoot The new validators merkle tree root
   */
  event ValidatorsRootUpdated(address indexed caller, bytes32 indexed validatorsRoot);

  /**
   * @notice The Vault keys manager address
   * @return The address that can update validators merkle tree root
   */
  function keysManager() external view returns (address);

  /**
   * @notice The Vault validators root
   * @return The merkle tree root to use for verifying validators deposit data
   */
  function validatorsRoot() external view returns (bytes32);

  /**
   * @notice The Vault validator index
   * @return The index of the next validator to be registered in the current deposit data file
   */
  function validatorIndex() external view returns (uint256);

  /**
   * @notice Function for registering single validator
   * @param keeperParams The parameters for getting approval from Keeper oracles
   * @param proof The proof used to verify that the validator is part of the validators merkle tree
   */
  function registerValidator(
    IKeeperValidators.ApprovalParams calldata keeperParams,
    bytes32[] calldata proof
  ) external;

  /**
   * @notice Function for registering multiple validators
   * @param keeperParams The parameters for getting approval from Keeper oracles
   * @param indexes The indexes of the leaves for the merkle tree multi proof verification
   * @param proofFlags The multi proof flags for the merkle tree verification
   * @param proof The proof used for the merkle tree verification
   */
  function registerValidators(
    IKeeperValidators.ApprovalParams calldata keeperParams,
    uint256[] calldata indexes,
    bool[] calldata proofFlags,
    bytes32[] calldata proof
  ) external;

  /**
   * @notice Function for updating the keys manager. Can only be called by the admin.
   * @param _keysManager The new keys manager address
   */
  function setKeysManager(address _keysManager) external;

  /**
   * @notice Function for updating the validators merkle tree root. Can only be called by the keys manager.
   * @param _validatorsRoot The new validators merkle tree root
   */
  function setValidatorsRoot(bytes32 _validatorsRoot) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

/**
 * @title IVaultsRegistry
 * @author StakeWise
 * @notice Defines the interface for the VaultsRegistry
 */
interface IVaultsRegistry {
  /**
   * @notice Event emitted on a Vault addition
   * @param caller The address that has added the Vault
   * @param vault The address of the added Vault
   */
  event VaultAdded(address indexed caller, address indexed vault);

  /**
   * @notice Event emitted on adding Vault implementation contract
   * @param impl The address of the new implementation contract
   */
  event VaultImplAdded(address indexed impl);

  /**
   * @notice Event emitted on removing Vault implementation contract
   * @param impl The address of the removed implementation contract
   */
  event VaultImplRemoved(address indexed impl);

  /**
   * @notice Event emitted on whitelisting the factory
   * @param factory The address of the whitelisted factory
   */
  event FactoryAdded(address indexed factory);

  /**
   * @notice Event emitted on removing the factory from the whitelist
   * @param factory The address of the factory removed from the whitelist
   */
  event FactoryRemoved(address indexed factory);

  /**
   * @notice Registered Vaults
   * @param vault The address of the vault to check whether it is registered
   * @return `true` for the registered Vault, `false` otherwise
   */
  function vaults(address vault) external view returns (bool);

  /**
   * @notice Registered Vault implementations
   * @param impl The address of the vault implementation
   * @return `true` for the registered implementation, `false` otherwise
   */
  function vaultImpls(address impl) external view returns (bool);

  /**
   * @notice Registered Factories
   * @param factory The address of the factory to check whether it is whitelisted
   * @return `true` for the whitelisted Factory, `false` otherwise
   */
  function factories(address factory) external view returns (bool);

  /**
   * @notice Function for adding Vault to the registry. Can only be called by the whitelisted Factory.
   * @param vault The address of the Vault to add
   */
  function addVault(address vault) external;

  /**
   * @notice Function for adding Vault implementation contract
   * @param newImpl The address of the new implementation contract
   */
  function addVaultImpl(address newImpl) external;

  /**
   * @notice Function for removing Vault implementation contract
   * @param impl The address of the removed implementation contract
   */
  function removeVaultImpl(address impl) external;

  /**
   * @notice Function for adding the factory to the whitelist
   * @param factory The address of the factory to add to the whitelist
   */
  function addFactory(address factory) external;

  /**
   * @notice Function for removing the factory from the whitelist
   * @param factory The address of the factory to remove from the whitelist
   */
  function removeFactory(address factory) external;

  /**
   * @notice Function for initializing the registry. Can only be called once during the deployment.
   * @param _owner The address of the owner of the contract
   */
  function initialize(address _owner) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

/**
 * @title Errors
 * @author StakeWise
 * @notice Contains all the custom errors
 */
library Errors {
  error AccessDenied();
  error InvalidShares();
  error InvalidAssets();
  error ZeroAddress();
  error InsufficientAssets();
  error CapacityExceeded();
  error InvalidCapacity();
  error InvalidSecurityDeposit();
  error InvalidFeeRecipient();
  error InvalidFeePercent();
  error NotHarvested();
  error NotCollateralized();
  error Collateralized();
  error InvalidProof();
  error LowLtv();
  error RedemptionExceeded();
  error InvalidPosition();
  error InvalidLtv();
  error InvalidHealthFactor();
  error InvalidReceivedAssets();
  error InvalidTokenMeta();
  error UpgradeFailed();
  error InvalidValidator();
  error InvalidValidators();
  error WhitelistAlreadyUpdated();
  error DeadlineExpired();
  error PermitInvalidSigner();
  error InvalidValidatorsRegistryRoot();
  error InvalidVault();
  error AlreadyAdded();
  error AlreadyRemoved();
  error InvalidOracles();
  error NotEnoughSignatures();
  error InvalidOracle();
  error TooEarlyUpdate();
  error InvalidAvgRewardPerSecond();
  error InvalidRewardsRoot();
  error HarvestFailed();
  error InvalidRedeemFromLtvPercent();
  error InvalidLiqThresholdPercent();
  error InvalidLiqBonusPercent();
  error InvalidLtvPercent();
  error InvalidCheckpointIndex();
  error InvalidCheckpointValue();
  error MaxOraclesExceeded();
  error ClaimTooEarly();
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.8.22;

import {ISharedMevEscrow} from '../../../interfaces/ISharedMevEscrow.sol';
import {IVaultsRegistry} from '../../../interfaces/IVaultsRegistry.sol';
import {IVaultEthStaking} from '../../../interfaces/IVaultEthStaking.sol';
import {Errors} from '../../../libraries/Errors.sol';

/**
 * @title SharedMevEscrow
 * @author StakeWise
 * @notice Accumulates received MEV. The rewards are shared by multiple Vaults.
 */
contract SharedMevEscrow is ISharedMevEscrow {
  IVaultsRegistry private immutable _vaultsRegistry;

  /// @dev Constructor
  constructor(address vaultsRegistry) {
    _vaultsRegistry = IVaultsRegistry(vaultsRegistry);
  }

  /// @inheritdoc ISharedMevEscrow
  function harvest(uint256 assets) external override {
    if (!_vaultsRegistry.vaults(msg.sender)) revert Errors.HarvestFailed();

    emit Harvested(msg.sender, assets);
    // slither-disable-next-line arbitrary-send-eth
    IVaultEthStaking(msg.sender).receiveFromMevEscrow{value: assets}();
  }

  /**
   * @dev Function for receiving MEV
   */
  receive() external payable {
    emit MevReceived(msg.value);
  }
}