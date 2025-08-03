/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IIntentSource} from "./interfaces/IIntentSource.sol";
import {BaseProver} from "./prover/BaseProver.sol";
import {Intent, Route, Reward, Call} from "./types/Intent.sol";
import {Semver} from "./libs/Semver.sol";

import {Vault} from "./Vault.sol";

/**
 * @title IntentSource
 * @notice Source chain contract for the Eco Protocol's intent system
 * @dev Used to create intents and withdraw associated rewards. Works in conjunction with
 *      an inbox contract on the destination chain. Verifies intent fulfillment through
 *      a prover contract on the source chain
 * @dev This contract should not hold any funds or hold any roles for other contracts.
 */
contract IntentSource is IIntentSource, Semver {
    using SafeERC20 for IERC20;

    mapping(bytes32 intentHash => VaultStorage) public vaults;

    constructor() {}

    /**
     * @notice Retrieves reward status for a given intent hash
     * @param intentHash Hash of the intent to query
     * @return status Current status of the intent
     */
    function getRewardStatus(
        bytes32 intentHash
    ) external view returns (RewardStatus status) {
        return RewardStatus(vaults[intentHash].state.status);
    }

    /**
     * @notice Retrieves vault state for a given intent hash
     * @param intentHash Hash of the intent to query
     * @return VaultState struct containing vault information
     */
    function getVaultState(
        bytes32 intentHash
    ) external view returns (VaultState memory) {
        return vaults[intentHash].state;
    }

    /**
     * @notice Retrieves the permitContact address funding an intent
     */
    function getPermitContract(
        bytes32 intentHash
    ) external view returns (address) {
        return vaults[intentHash].permitContract;
    }

    /**
     * @notice Calculates the hash of an intent and its components
     * @param intent The intent to hash
     * @return intentHash Combined hash of route and reward
     * @return routeHash Hash of the route component
     * @return rewardHash Hash of the reward component
     */
    function getIntentHash(
        Intent calldata intent
    )
        public
        pure
        returns (bytes32 intentHash, bytes32 routeHash, bytes32 rewardHash)
    {
        routeHash = keccak256(abi.encode(intent.route));
        rewardHash = keccak256(abi.encode(intent.reward));
        intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));
    }

    /**
     * @notice Calculates the deterministic address of the intent vault
     * @param intent Intent to calculate vault address for
     * @return Address of the intent vault
     */
    function intentVaultAddress(
        Intent calldata intent
    ) external view returns (address) {
        (bytes32 intentHash, bytes32 routeHash, ) = getIntentHash(intent);
        return _getIntentVaultAddress(intentHash, routeHash, intent.reward);
    }

    /**
     * @notice Creates an intent without funding
     * @param intent The complete intent struct to be published
     * @return intentHash Hash of the created intent
     */
    function publish(
        Intent calldata intent
    ) external returns (bytes32 intentHash) {
        (intentHash, , ) = getIntentHash(intent);
        VaultState memory state = vaults[intentHash].state;

        _validateAndPublishIntent(intent, intentHash, state);
    }

    /**
     * @notice Creates and funds an intent in a single transaction
     * @param intent The complete intent struct to be published and funded
     * @return intentHash Hash of the created and funded intent
     */
    function publishAndFund(
        Intent calldata intent,
        bool allowPartial
    ) external payable returns (bytes32 intentHash) {
        bytes32 routeHash;
        (intentHash, routeHash, ) = getIntentHash(intent);
        VaultState memory state = vaults[intentHash].state;

        _validateInitialFundingState(state, intentHash);
        _validateSourceChain(intent.route.source, intentHash);
        _validateAndPublishIntent(intent, intentHash, state);

        address vault = _getIntentVaultAddress(
            intentHash,
            routeHash,
            intent.reward
        );
        _fundIntent(intentHash, intent.reward, vault, msg.sender, allowPartial);

        _returnExcessEth(intentHash, address(this).balance);
    }

    /**
     * @notice Funds an existing intent
     * @param routeHash Hash of the route component
     * @param reward Reward structure containing distribution details
     * @return intentHash Hash of the funded intent
     */
    function fund(
        bytes32 routeHash,
        Reward calldata reward,
        bool allowPartial
    ) external payable returns (bytes32 intentHash) {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));
        VaultState memory state = vaults[intentHash].state;

        _validateInitialFundingState(state, intentHash);

        address vault = _getIntentVaultAddress(intentHash, routeHash, reward);
        _fundIntent(intentHash, reward, vault, msg.sender, allowPartial);

        _returnExcessEth(intentHash, address(this).balance);
    }

    /**
     * @notice Funds an intent for a user with permit/allowance
     * @param routeHash Hash of the route component
     * @param reward Reward structure containing distribution details
     * @param funder Address to fund the intent from
     * @param permitContact Address of the permitContact instance
     * @param allowPartial Whether to allow partial funding
     * @return intentHash Hash of the funded intent
     */
    function fundFor(
        bytes32 routeHash,
        Reward calldata reward,
        address funder,
        address permitContact,
        bool allowPartial
    ) external returns (bytes32 intentHash) {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));
        VaultState memory state = vaults[intentHash].state;

        address vault = _getIntentVaultAddress(intentHash, routeHash, reward);

        _fundIntentFor(
            state,
            reward,
            intentHash,
            routeHash,
            vault,
            funder,
            permitContact,
            allowPartial
        );
    }

    /**
     * @notice Creates and funds an intent using permit/allowance
     * @param intent The complete intent struct
     * @param funder Address to fund the intent from
     * @param permitContact Address of the permitContact instance
     * @param allowPartial Whether to allow partial funding
     * @return intentHash Hash of the created and funded intent
     */
    function publishAndFundFor(
        Intent calldata intent,
        address funder,
        address permitContact,
        bool allowPartial
    ) external returns (bytes32 intentHash) {
        bytes32 routeHash;
        (intentHash, routeHash, ) = getIntentHash(intent);
        VaultState memory state = vaults[intentHash].state;

        _validateAndPublishIntent(intent, intentHash, state);
        _validateSourceChain(intent.route.source, intentHash);

        address vault = _getIntentVaultAddress(
            intentHash,
            routeHash,
            intent.reward
        );

        _fundIntentFor(
            state,
            intent.reward,
            intentHash,
            routeHash,
            vault,
            funder,
            permitContact,
            allowPartial
        );
    }

    /**
     * @notice Checks if an intent is completely funded
     * @param intent Intent to validate
     * @return True if intent is completely funded, false otherwise
     */
    function isIntentFunded(
        Intent calldata intent
    ) external view returns (bool) {
        if (intent.route.source != block.chainid) return false;

        (bytes32 intentHash, bytes32 routeHash, ) = getIntentHash(intent);
        address vault = _getIntentVaultAddress(
            intentHash,
            routeHash,
            intent.reward
        );

        return _isRewardFunded(intent.reward, vault);
    }

    /**
     * @notice Withdraws rewards associated with an intent to its claimant
     * @param routeHash Hash of the intent's route
     * @param reward Reward structure of the intent
     */
    function withdrawRewards(bytes32 routeHash, Reward calldata reward) public {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        address claimant = BaseProver(reward.prover).provenIntents(intentHash);
        VaultState memory state = vaults[intentHash].state;

        // Claim the rewards if the intent has not been claimed
        if (
            claimant != address(0) &&
            state.status != uint8(RewardStatus.Claimed) &&
            state.status != uint8(RewardStatus.Refunded)
        ) {
            state.status = uint8(RewardStatus.Claimed);
            state.mode = uint8(VaultMode.Claim);
            state.allowPartialFunding = 0;
            state.usePermit = 0;
            state.target = claimant;
            vaults[intentHash].state = state;

            emit Withdrawal(intentHash, claimant);

            new Vault{salt: routeHash}(intentHash, reward);

            return;
        }

        if (claimant == address(0)) {
            revert UnauthorizedWithdrawal(intentHash);
        } else {
            revert RewardsAlreadyWithdrawn(intentHash);
        }
    }

    /**
     * @notice Batch withdraws multiple intents
     * @param routeHashes Array of route hashes for the intents
     * @param rewards Array of reward structures for the intents
     */
    function batchWithdraw(
        bytes32[] calldata routeHashes,
        Reward[] calldata rewards
    ) external {
        uint256 length = routeHashes.length;

        if (length != rewards.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < length; ++i) {
            withdrawRewards(routeHashes[i], rewards[i]);
        }
    }

    /**
     * @notice Refunds rewards to the intent creator
     * @param routeHash Hash of the intent's route
     * @param reward Reward structure of the intent
     */
    function refund(bytes32 routeHash, Reward calldata reward) external {
        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        VaultState memory state = vaults[intentHash].state;

        if (
            state.status != uint8(RewardStatus.Claimed) &&
            state.status != uint8(RewardStatus.Refunded)
        ) {
            address claimant = BaseProver(reward.prover).provenIntents(
                intentHash
            );
            // Check if the intent has been proven to prevent unauthorized refunds
            if (claimant != address(0)) {
                revert IntentNotClaimed(intentHash);
            }
            // Revert if intent has not expired
            if (block.timestamp <= reward.deadline) {
                revert IntentNotExpired(intentHash);
            }
        }

        if (state.status != uint8(RewardStatus.Claimed)) {
            state.status = uint8(RewardStatus.Refunded);
        }

        state.mode = uint8(VaultMode.Refund);
        state.allowPartialFunding = 0;
        state.usePermit = 0;
        state.target = address(0);
        vaults[intentHash].state = state;

        emit Refund(intentHash, reward.creator);

        new Vault{salt: routeHash}(intentHash, reward);
    }

    /**
     * @notice Recover tokens that were sent to the intent vault by mistake
     * @dev Must not be among the intent's rewards
     * @param routeHash Hash of the intent's route
     * @param reward Reward structure of the intent
     * @param token Token address for handling incorrect vault transfers
     */
    function recoverToken(
        bytes32 routeHash,
        Reward calldata reward,
        address token
    ) external {
        if (token == address(0)) {
            revert InvalidRefundToken();
        }

        bytes32 rewardHash = keccak256(abi.encode(reward));
        bytes32 intentHash = keccak256(abi.encodePacked(routeHash, rewardHash));

        VaultState memory state = vaults[intentHash].state;

        // selfdestruct() will refund all native tokens to the creator
        // we can't refund native intents before the claim/refund happens
        // because deploying and destructing the vault will refund the native reward prematurely
        if (
            state.status != uint8(RewardStatus.Claimed) &&
            state.status != uint8(RewardStatus.Refunded) &&
            reward.nativeValue > 0
        ) {
            revert IntentNotClaimed(intentHash);
        }

        // Check if the token is part of the reward
        for (uint256 i = 0; i < reward.tokens.length; ++i) {
            if (reward.tokens[i].token == token) {
                revert InvalidRefundToken();
            }
        }

        state.mode = uint8(VaultMode.RecoverToken);
        state.allowPartialFunding = 0;
        state.usePermit = 0;
        state.target = token;
        vaults[intentHash].state = state;

        emit Refund(intentHash, reward.creator);

        new Vault{salt: routeHash}(intentHash, reward);
    }

    /**
     * @notice Validates that an intent's vault holds sufficient rewards
     * @dev Checks both native token and ERC20 token balances
     * @param reward Reward to validate
     * @param vault Address of the intent's vault
     * @return True if vault has sufficient funds, false otherwise
     */
    function _isRewardFunded(
        Reward calldata reward,
        address vault
    ) internal view returns (bool) {
        uint256 rewardsLength = reward.tokens.length;

        if (vault.balance < reward.nativeValue) return false;

        for (uint256 i = 0; i < rewardsLength; ++i) {
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(vault);

            if (balance < amount) return false;
        }

        return true;
    }

    /**
     * @notice Calculates the deterministic address of an intent vault using CREATE2
     * @dev Follows EIP-1014 for address calculation
     * @param intentHash Hash of the full intent
     * @param routeHash Hash of the route component
     * @param reward Reward structure
     * @return The calculated vault address
     */
    function _getIntentVaultAddress(
        bytes32 intentHash,
        bytes32 routeHash,
        Reward calldata reward
    ) internal view returns (address) {
        /* Convert a hash which is bytes32 to an address which is 20-byte long
        according to https://docs.soliditylang.org/en/v0.8.9/control-structures.html?highlight=create2#salted-contract-creations-create2 */
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                address(this),
                                routeHash,
                                keccak256(
                                    abi.encodePacked(
                                        type(Vault).creationCode,
                                        abi.encode(intentHash, reward)
                                    )
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice Validates and publishes a new intent
     * @param intent The intent to validate and publish
     * @param intentHash Hash of the intent
     * @param state Current vault state
     */
    function _validateAndPublishIntent(
        Intent calldata intent,
        bytes32 intentHash,
        VaultState memory state
    ) internal {
        if (
            state.status == uint8(RewardStatus.Claimed) ||
            state.status == uint8(RewardStatus.Refunded)
        ) {
            revert IntentAlreadyExists(intentHash);
        }

        emit IntentCreated(
            intentHash,
            intent.route.salt,
            intent.route.source,
            intent.route.destination,
            intent.route.inbox,
            intent.route.tokens,
            intent.route.calls,
            intent.reward.creator,
            intent.reward.prover,
            intent.reward.deadline,
            intent.reward.nativeValue,
            intent.reward.tokens
        );
    }

    /**
     * @notice Disabling fundFor for native intents
     * @dev Deploying vault in Fund mode might cause a loss of native reward
     * @param reward Reward structure to validate
     * @param vault Address of the intent vault
     * @param intentHash Hash of the intent
     */
    function _disableNativeReward(
        Reward calldata reward,
        address vault,
        bytes32 intentHash
    ) internal view {
        // selfdestruct() will refund all native tokens to the creator
        // we can't use Fund mode for intents with native value
        // because deploying and destructing the vault will refund the native reward prematurely
        if (reward.nativeValue > 0 && vault.balance > 0) {
            revert CannotFundForWithNativeReward(intentHash);
        }
    }

    /**
     * @notice Validates the initial funding state
     * @param state Current vault state
     * @param intentHash Hash of the intent
     */
    function _validateInitialFundingState(
        VaultState memory state,
        bytes32 intentHash
    ) internal pure {
        if (state.status != uint8(RewardStatus.Initial)) {
            revert IntentAlreadyFunded(intentHash);
        }
    }

    /**
     * @notice Validates the funding state for partial funding
     * @param state Current vault state
     * @param intentHash Hash of the intent
     */
    function _validateFundingState(
        VaultState memory state,
        bytes32 intentHash
    ) internal pure {
        if (
            state.status != uint8(RewardStatus.Initial) &&
            state.status != uint8(RewardStatus.PartiallyFunded)
        ) {
            revert IntentAlreadyFunded(intentHash);
        }
    }

    /**
     * @notice Handles the funding of an intent
     * @param intentHash Hash of the intent
     * @param reward Reward structure to fund
     * @param vault Address of the intent vault
     * @param funder Address providing the funds
     */
    function _fundIntent(
        bytes32 intentHash,
        Reward calldata reward,
        address vault,
        address funder,
        bool allowPartial
    ) internal {
        emit IntentFunded(intentHash, msg.sender);

        if (reward.nativeValue > 0) {
            if (msg.value < reward.nativeValue) {
                revert InsufficientNativeReward(intentHash);
            }
            payable(vault).transfer(reward.nativeValue);
        }

        uint256 rewardsLength = reward.tokens.length;

        // Iterate through each token in the reward structure
        for (uint256 i; i < rewardsLength; ++i) {
            // Get token address and required amount for current reward
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(vault);

            // Only proceed if vault needs more tokens and we have permission to transfer them
            if (amount > balance) {
                // Calculate how many more tokens the vault needs to be fully funded
                uint256 remainingAmount = amount - balance;

                // Check how many tokens this contract is allowed to transfer from funding source
                uint256 allowance = IERC20(token).allowance(
                    funder,
                    address(this)
                );

                uint256 transferAmount;
                // Calculate transfer amount as minimum of what's needed and what's allowed
                if (allowance >= remainingAmount) {
                    transferAmount = remainingAmount;
                } else if (allowPartial) {
                    transferAmount = allowance;
                } else {
                    revert InsufficientTokenAllowance(
                        token,
                        funder,
                        remainingAmount
                    );
                }

                if (transferAmount > 0) {
                    // Transfer tokens from funding source to vault using safe transfer
                    IERC20(token).safeTransferFrom(
                        funder,
                        vault,
                        transferAmount
                    );
                }
            }
        }
    }

    function _fundIntentFor(
        VaultState memory state,
        Reward calldata reward,
        bytes32 intentHash,
        bytes32 routeHash,
        address vault,
        address funder,
        address permitContact,
        bool allowPartial
    ) internal {
        _disableNativeReward(reward, vault, intentHash);
        _validateFundingState(state, intentHash);

        if (state.status == uint8(RewardStatus.Initial)) {
            state.status = allowPartial
                ? uint8(RewardStatus.PartiallyFunded)
                : uint8(RewardStatus.Funded);
        }

        state.mode = uint8(VaultMode.Fund);
        state.allowPartialFunding = allowPartial ? 1 : 0;
        state.usePermit = permitContact != address(0) ? 1 : 0;
        state.target = funder;

        if (permitContact != address(0)) {
            vaults[intentHash].permitContract = permitContact;
        }

        vaults[intentHash].state = state;

        new Vault{salt: routeHash}(intentHash, reward);

        if (state.status == uint8(RewardStatus.Funded)) {
            emit IntentFunded(intentHash, funder);
        } else if (
            state.status == uint8(RewardStatus.PartiallyFunded) &&
            _isRewardFunded(reward, vault)
        ) {
            state.status = uint8(RewardStatus.Funded);
            vaults[intentHash].state = state;

            emit IntentFunded(intentHash, funder);
        } else {
            emit IntentPartiallyFunded(intentHash, funder);
        }
    }

    /**
     * @notice Validates that the intent is being published on correct chain
     * @param sourceChain Chain ID specified in the intent
     * @param intentHash Hash of the intent
     */
    function _validateSourceChain(
        uint256 sourceChain,
        bytes32 intentHash
    ) internal view {
        if (sourceChain != block.chainid) {
            revert WrongSourceChain(intentHash);
        }
    }

    /**
     * @notice Returns excess ETH to the sender
     * @param intentHash Hash of the intent
     * @param amount Amount of ETH to return
     */
    function _returnExcessEth(bytes32 intentHash, uint256 amount) internal {
        if (amount > 0) {
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            if (!success) revert NativeRewardTransferFailed(intentHash);
        }
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IIntentSource} from "./interfaces/IIntentSource.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IPermit} from "./interfaces/IPermit.sol";

import {Reward} from "./types/Intent.sol";

/**
 * @title Vault
 * @notice A self-destructing contract that handles reward distribution for intents
 * @dev Created by IntentSource for each intent, handles token and native currency transfers,
 * then self-destructs after distributing rewards
 */
contract Vault is IVault {
    using SafeERC20 for IERC20;

    /**
     * @notice Creates and immediately executes reward distribution
     * @dev Contract self-destructs after execution
     */
    constructor(bytes32 intentHash, Reward memory reward) {
        IIntentSource intentSource = IIntentSource(msg.sender);
        VaultState memory state = intentSource.getVaultState(intentHash);

        if (state.mode == uint8(VaultMode.Fund)) {
            _fundIntent(intentSource, intentHash, state, reward);
        } else if (state.mode == uint8(VaultMode.Claim)) {
            _processRewardTokens(reward, state.target);
            _processNativeReward(reward, state.target);
        } else if (state.mode == uint8(VaultMode.Refund)) {
            _processRewardTokens(reward, reward.creator);
        } else if (state.mode == uint8(VaultMode.RecoverToken)) {
            _recoverToken(state.target, reward.creator);
        }

        selfdestruct(payable(reward.creator));
    }

    /**
     * @dev Funds the intent with required tokens
     */
    function _fundIntent(
        IIntentSource intentSource,
        bytes32 intentHash,
        VaultState memory state,
        Reward memory reward
    ) internal {
        // Get the address that is providing the tokens for funding
        address fundingSource = state.target;
        uint256 rewardsLength = reward.tokens.length;
        address permitContract;

        if (state.usePermit == 1) {
            permitContract = intentSource.getPermitContract(intentHash);
        }

        // Iterate through each token in the reward structure
        for (uint256 i; i < rewardsLength; ++i) {
            // Get token address and required amount for current reward
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(address(this));

            // Only proceed if vault needs more tokens and we have permission to transfer them
            if (amount > balance) {
                // Calculate how many more tokens the vault needs to be fully funded
                uint256 remainingAmount = amount - balance;

                if (permitContract != address(0)) {
                    remainingAmount = _transferFromPermit(
                        IPermit(permitContract),
                        fundingSource,
                        token,
                        remainingAmount
                    );
                }

                if (remainingAmount > 0) {
                    _transferFrom(
                        fundingSource,
                        token,
                        remainingAmount,
                        state.allowPartialFunding
                    );
                }
            }
        }
    }

    /**
     * @dev Processes all reward tokens
     */
    function _processRewardTokens(
        Reward memory reward,
        address claimant
    ) internal {
        uint256 rewardsLength = reward.tokens.length;

        for (uint256 i; i < rewardsLength; ++i) {
            address token = reward.tokens[i].token;
            uint256 amount = reward.tokens[i].amount;
            uint256 balance = IERC20(token).balanceOf(address(this));

            if (claimant == reward.creator || balance < amount) {
                if (claimant != reward.creator) {
                    emit RewardTransferFailed(token, claimant, amount);
                }
                if (balance > 0) {
                    _tryTransfer(token, claimant, balance);
                }
            } else {
                _tryTransfer(token, claimant, amount);

                // Return excess balance to creator
                if (balance > amount) {
                    _tryTransfer(token, reward.creator, balance - amount);
                }
            }
        }
    }

    /**
     * @dev Processes native token reward
     */
    function _processNativeReward(
        Reward memory reward,
        address claimant
    ) internal {
        if (reward.nativeValue > 0) {
            uint256 amount = reward.nativeValue;
            if (address(this).balance < reward.nativeValue) {
                emit RewardTransferFailed(address(0), claimant, amount);
                amount = address(this).balance;
            }

            (bool success, ) = payable(claimant).call{value: amount}("");
            if (!success) {
                emit RewardTransferFailed(address(0), claimant, amount);
            }
        }
    }

    /**
     * @dev Processes refund token if specified
     */
    function _recoverToken(address refundToken, address creator) internal {
        uint256 refundAmount = IERC20(refundToken).balanceOf(address(this));
        require(refundAmount > 0, ZeroRefundTokenBalance(refundToken));
        IERC20(refundToken).safeTransfer(creator, refundAmount);
    }

    /**
     * @notice Attempts to transfer tokens to a recipient, emitting an event on failure
     * @dev Uses inline assembly to safely handle return data from token transfers
     * @param token Address of the token being transferred
     * @param to Address of the recipient
     * @param amount Amount of tokens to transfer
     */
    function _tryTransfer(address token, address to, uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(
            IERC20(token).transfer.selector,
            to,
            amount
        );

        bool success;
        uint256 returnSize;
        uint256 returnValue;

        assembly ("memory-safe") {
            success := call(
                gas(),
                token,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0x20
            )
            if not(iszero(success)) {
                returnSize := returndatasize()
                returnValue := mload(0)
            }
        }

        if (
            !success ||
            (
                returnSize == 0
                    ? address(token).code.length == 0
                    : returnValue != 1
            )
        ) {
            emit RewardTransferFailed(token, to, amount);
        }
    }

    /**
     * @notice Transfers tokens from funding source to vault
     * @param fundingSource Address that is providing the tokens for funding
     * @param token Address of the token being transferred
     * @param amount Amount of tokens to transfer
     * @param allowPartialFunding Whether to allow partial funding
     */
    function _transferFrom(
        address fundingSource,
        address token,
        uint256 amount,
        uint8 allowPartialFunding
    ) internal {
        // Check how many tokens this contract is allowed to transfer from funding source
        uint256 allowance = IERC20(token).allowance(
            fundingSource,
            address(this)
        );

        uint256 transferAmount;
        // Calculate transfer amount as minimum of what's needed and what's allowed
        if (allowance >= amount) {
            transferAmount = amount;
        } else if (allowPartialFunding == 1) {
            transferAmount = allowance;
        } else {
            revert InsufficientTokenAllowance(token, fundingSource, amount);
        }

        if (transferAmount > 0) {
            // Transfer tokens from funding source to vault using safe transfer
            IERC20(token).safeTransferFrom(
                fundingSource,
                address(this),
                transferAmount
            );
        }
    }

    /**
     * @notice Transfers tokens from funding source to vault using external Permit contract
     * @param permit Permit2 like contract to use for token transfer
     * @param fundingSource Address that is providing the tokens for funding
     * @param token Address of the token being transferred
     * @param amount Amount of tokens to transfer
     * @return remainingAmount Amount of tokens that still need to be transferred
     */
    function _transferFromPermit(
        IPermit permit,
        address fundingSource,
        address token,
        uint256 amount
    ) internal returns (uint256 remainingAmount) {
        // Check how many tokens this contract is allowed to transfer from funding source
        (uint160 allowance, , ) = permit.allowance(
            fundingSource,
            token,
            address(this)
        );

        uint256 transferAmount;
        // Calculate transfer amount as minimum of what's needed and what's allowed
        if (allowance >= amount) {
            transferAmount = amount;
            remainingAmount = 0;
        } else {
            transferAmount = allowance;
            remainingAmount = amount - allowance;
        }

        if (transferAmount > 0) {
            // Transfer tokens from funding source to vault using Permit.transferFrom
            permit.transferFrom(
                fundingSource,
                address(this),
                uint160(transferAmount),
                token
            );
        }
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";
import {IVaultStorage} from "./IVaultStorage.sol";

import {Intent, Reward, Call, TokenAmount} from "../types/Intent.sol";

/**
 * @title IIntentSource
 * @notice Interface for managing cross-chain intents and their associated rewards on the source chain
 * @dev This contract works in conjunction with an inbox contract on the destination chain
 *      and a prover contract for verification. It handles intent creation, funding,
 *      and reward distribution.
 */
interface IIntentSource is ISemver, IVaultStorage {
    /**
     * @notice Indicates an attempt to fund an intent on an incorrect chain
     * @param intentHash The hash of the intent that was incorrectly targeted
     */
    error WrongSourceChain(bytes32 intentHash);

    /**
     * @notice Indicates a failed native token transfer during reward distribution
     * @param intentHash The hash of the intent whose reward transfer failed
     */
    error NativeRewardTransferFailed(bytes32 intentHash);

    /**
     * @notice Indicates an attempt to publish a duplicate intent
     * @param intentHash The hash of the pre-existing intent
     */
    error IntentAlreadyExists(bytes32 intentHash);

    /**
     * @notice Indicates an attempt to fund an already funded intent
     * @param intentHash The hash of the previously funded intent
     */
    error IntentAlreadyFunded(bytes32 intentHash);

    /**
     * @notice Indicates insufficient native token payment for the required reward
     * @param intentHash The hash of the intent with insufficient funding
     */
    error InsufficientNativeReward(bytes32 intentHash);

    /**
     * @notice Thrown when the vault has insufficient token allowance for reward funding
     */
    error InsufficientTokenAllowance(
        address token,
        address spender,
        uint256 amount
    );

    /**
     * @notice Indicates an invalid attempt to fund with native tokens
     * @param intentHash The hash of the intent that cannot accept native tokens
     */
    error CannotFundForWithNativeReward(bytes32 intentHash);

    /**
     * @notice Indicates an unauthorized reward withdrawal attempt
     * @param _hash The hash of the intent with protected rewards
     */
    error UnauthorizedWithdrawal(bytes32 _hash);

    /**
     * @notice Indicates an attempt to withdraw already claimed rewards
     * @param _hash The hash of the intent with depleted rewards
     */
    error RewardsAlreadyWithdrawn(bytes32 _hash);

    /**
     * @notice Indicates a premature withdrawal attempt before intent expiration
     * @param intentHash The hash of the unexpired intent
     */
    error IntentNotExpired(bytes32 intentHash);

    /**
     * @notice Indicates a premature refund attempt before intent completion
     * @param intentHash The hash of the unclaimed intent
     */
    error IntentNotClaimed(bytes32 intentHash);

    /**
     * @notice Indicates an invalid token specified for refund
     */
    error InvalidRefundToken();

    /**
     * @notice Indicates mismatched array lengths in batch operations
     */
    error ArrayLengthMismatch();

    /**
     * @notice Signals partial funding of an intent
     * @param intentHash The hash of the partially funded intent
     * @param fundingSource The address providing the partial funding
     */
    event IntentPartiallyFunded(bytes32 intentHash, address fundingSource);

    /**
     * @notice Signals complete funding of an intent
     * @param intentHash The hash of the fully funded intent
     * @param fundingSource The address providing the complete funding
     */
    event IntentFunded(bytes32 intentHash, address fundingSource);

    /**
     * @notice Signals the creation of a new cross-chain intent
     * @param hash Unique identifier of the intent
     * @param salt Creator-provided uniqueness factor
     * @param source Source chain identifier
     * @param destination Destination chain identifier
     * @param inbox Address of the receiving contract on the destination chain
     * @param routeTokens Required tokens for executing destination chain calls
     * @param calls Instructions to execute on the destination chain
     * @param creator Intent originator address
     * @param prover Prover contract address
     * @param deadline Timestamp for reward claim eligibility
     * @param nativeValue Native token reward amount
     * @param rewardTokens ERC20 token rewards with amounts
     */
    event IntentCreated(
        bytes32 indexed hash,
        bytes32 salt,
        uint256 source,
        uint256 destination,
        address inbox,
        TokenAmount[] routeTokens,
        Call[] calls,
        address indexed creator,
        address indexed prover,
        uint256 deadline,
        uint256 nativeValue,
        TokenAmount[] rewardTokens
    );

    /**
     * @notice Signals successful reward withdrawal
     * @param _hash The hash of the claimed intent
     * @param _recipient The address receiving the rewards
     */
    event Withdrawal(bytes32 _hash, address indexed _recipient);

    /**
     * @notice Signals successful reward refund
     * @param _hash The hash of the refunded intent
     * @param _recipient The address receiving the refund
     */
    event Refund(bytes32 _hash, address indexed _recipient);

    /**
     * @notice Retrieves the current reward claim status for an intent
     * @param intentHash The hash of the intent
     * @return status Current reward status
     */
    function getRewardStatus(
        bytes32 intentHash
    ) external view returns (RewardStatus status);

    /**
     * @notice Retrieves the current state of an intent's vault
     * @param intentHash The hash of the intent
     * @return Current vault state
     */
    function getVaultState(
        bytes32 intentHash
    ) external view returns (VaultState memory);

    /**
     * @notice Retrieves the permit contract for token transfers
     * @param intentHash The hash of the intent
     * @return Address of the permit contract
     */
    function getPermitContract(
        bytes32 intentHash
    ) external view returns (address);

    /**
     * @notice Computes the hash components of an intent
     * @param intent The intent to hash
     * @return intentHash Combined hash of route and reward components
     * @return routeHash Hash of the route specifications
     * @return rewardHash Hash of the reward specifications
     */
    function getIntentHash(
        Intent calldata intent
    )
        external
        pure
        returns (bytes32 intentHash, bytes32 routeHash, bytes32 rewardHash);

    /**
     * @notice Computes the deterministic vault address for an intent
     * @param intent The intent to calculate the vault address for
     * @return Predicted vault address
     */
    function intentVaultAddress(
        Intent calldata intent
    ) external view returns (address);

    /**
     * @notice Creates a new cross-chain intent with associated rewards
     * @dev Intent must be proven on source chain before expiration for valid reward claims
     * @param intent The complete intent specification
     * @return intentHash Unique identifier of the created intent
     */
    function publish(
        Intent calldata intent
    ) external returns (bytes32 intentHash);

    /**
     * @notice Creates and funds an intent in a single transaction
     * @param intent The complete intent specification
     * @return intentHash Unique identifier of the created and funded intent
     */
    function publishAndFund(
        Intent calldata intent,
        bool allowPartial
    ) external payable returns (bytes32 intentHash);

    /**
     * @notice Funds an existing intent
     * @param routeHash The hash of the intent's route component
     * @param reward The reward specification
     * @return intentHash The hash of the funded intent
     */
    function fund(
        bytes32 routeHash,
        Reward calldata reward,
        bool allowPartial
    ) external payable returns (bytes32 intentHash);

    /**
     * @notice Funds an intent on behalf of another address using permit
     * @param routeHash The hash of the intent's route component
     * @param reward The reward specification
     * @param fundingAddress The address providing the funding
     * @param permitContract The permit contract address for external token approvals
     * @param allowPartial Whether to accept partial funding
     * @return intentHash The hash of the funded intent
     */
    function fundFor(
        bytes32 routeHash,
        Reward calldata reward,
        address fundingAddress,
        address permitContract,
        bool allowPartial
    ) external returns (bytes32 intentHash);

    /**
     * @notice Creates and funds an intent on behalf of another address
     * @param intent The complete intent specification
     * @param funder The address providing the funding
     * @param permitContact The permit contract for token approvals
     * @param allowPartial Whether to accept partial funding
     * @return intentHash The hash of the created and funded intent
     */
    function publishAndFundFor(
        Intent calldata intent,
        address funder,
        address permitContact,
        bool allowPartial
    ) external returns (bytes32 intentHash);

    /**
     * @notice Checks if an intent's rewards are valid and fully funded
     * @param intent The intent to validate
     * @return True if the intent is properly funded
     */
    function isIntentFunded(
        Intent calldata intent
    ) external view returns (bool);

    /**
     * @notice Claims rewards for a successfully fulfilled and proven intent
     * @param routeHash The hash of the intent's route component
     * @param reward The reward specification
     */
    function withdrawRewards(
        bytes32 routeHash,
        Reward calldata reward
    ) external;

    /**
     * @notice Claims rewards for multiple fulfilled and proven intents
     * @param routeHashes Array of route component hashes
     * @param rewards Array of corresponding reward specifications
     */
    function batchWithdraw(
        bytes32[] calldata routeHashes,
        Reward[] calldata rewards
    ) external;

    /**
     * @notice Returns rewards to the intent creator
     * @param routeHash The hash of the intent's route component
     * @param reward The reward specification
     */
    function refund(bytes32 routeHash, Reward calldata reward) external;

    /**
     * @notice Recovers mistakenly transferred tokens from the intent vault
     * @dev Token must not be part of the intent's reward structure
     * @param routeHash The hash of the intent's route component
     * @param reward The reward specification
     * @param token The address of the token to recover
     */
    function recoverToken(
        bytes32 routeHash,
        Reward calldata reward,
        address token
    ) external;
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IPermit
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by checking allowed amounts
/// @dev Requires user's token approval on the Permit2 like contract
/// @dev This is the subset of the Uniswap permit2 interface
interface IPermit {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint48 newNonce,
        uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration
    );

    /// @notice Emits an event when the owner successfully sets permissions using a permit signature on a token for the spender.
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );

    /// @notice Emits an event when the owner sets the allowance back to 0 with the lockdown function.
    event Lockdown(address indexed owner, address token, address spender);

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice A mapping from owner address to token address to spender address to PackedAllowance struct, which contains details and conditions of the approval.
    /// @notice The mapping is indexed in the above order see: allowance[ownerAddress][tokenAddress][spenderAddress]
    /// @dev The packed slot holds the allowed amount, expiration at which the allowed amount is no longer valid, and current nonce thats updated on any signature based approvals.
    function allowance(
        address user,
        address token,
        address spender
    ) external view returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(
        address from,
        address to,
        uint160 amount,
        address token
    ) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(
        AllowanceTransferDetails[] calldata transferDetails
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ISemver} from "./ISemver.sol";

/**
 * @title IProver
 * @notice Interface for proving intent fulfillment
 * @dev Defines required functionality for proving intent execution with different
 * proof mechanisms (storage or Hyperlane)
 */
interface IProver is ISemver {
    /**
     * @notice Types of proofs that can validate intent fulfillment
     * @param Storage Traditional storage-based proof mechanism
     * @param Hyperlane Proof using Hyperlane's cross-chain messaging
     */
    enum ProofType {
        Storage,
        Hyperlane
    }

    /**
     * @notice Emitted when an intent is successfully proven
     * @param _hash Hash of the proven intent
     * @param _claimant Address eligible to claim the intent's rewards
     */
    event IntentProven(bytes32 indexed _hash, address indexed _claimant);

    /**
     * @notice Gets the proof mechanism type used by this prover
     * @return ProofType enum indicating the prover's mechanism
     */
    function getProofType() external pure returns (ProofType);

    /**
     * @notice Gets the address eligible to claim rewards for a proven intent
     * @param intentHash Hash of the intent to query
     * @return Address of the claimant, or zero address if unproven
     */
    function getIntentClaimant(
        bytes32 intentHash
    ) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Semver Interface
 * @dev An interface for a contract that has a version
 */
interface ISemver {
    function version() external pure returns (string memory);
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IVaultStorage} from "./IVaultStorage.sol";

/**
 * @title IVault
 * @notice Interface defining errors for the Vault.sol contract
 */
interface IVault is IVaultStorage {
    /**
     * @notice Thrown when the vault has insufficient token allowance for reward funding
     * @param token The token address
     * @param spender The spender address
     * @param amount The amount of tokens required
     */
    error InsufficientTokenAllowance(
        address token,
        address spender,
        uint256 amount
    );

    /**
     * @notice Thrown when the vault has zero balance of the refund token
     * @param token The token address
     */
    error ZeroRefundTokenBalance(address token);

    /**
     * @notice Thrown when the vault is not able to properly reward the claimant
     * @dev For edge cases where the reward balance is not sufficient etc
     */
    event RewardTransferFailed(
        address indexed token,
        address indexed to,
        uint256 amount
    );
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IVaultStorage
 * @notice Interface for the storage layout of the Vault contract
 */
interface IVaultStorage {
    enum RewardStatus {
        Initial,
        PartiallyFunded,
        Funded,
        Claimed,
        Refunded
    }

    /**
     * @notice Mode of the vault contract
     */
    enum VaultMode {
        Fund,
        Claim,
        Refund,
        RecoverToken
    }

    /**
     * @notice Status of the vault contract
     * @dev Tracks the current mode and funding status
     * @param status Current status of the vault
     * @param mode Current mode of the vault
     * @param allowPartial Whether partial funding is allowed
     * @param usePermit Whether permit is enabled
     * @param target Address of the funder in Fund, claimant in Claim or refund token in RecoverToken mode
     */
    struct VaultState {
        uint8 status; // RewardStatus
        uint8 mode; // VaultMode
        uint8 allowPartialFunding; // boolean
        uint8 usePermit; // boolean
        address target; // funder, claimant or refund token address
    }

    /**
     * @notice Storage for the vault contract
     * @dev Tracks the current state and permit contract instance
     * @param state Current state of the vault
     * @param permitContract Address of the permit contract instance
     */
    struct VaultStorage {
        VaultState state; // 1 bytes32 storage slot
        address permitContract; // permit instance when enabled
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {ISemver} from "../interfaces/ISemver.sol";

abstract contract Semver is ISemver {
    function version() external pure returns (string memory) { return "1.17.0-1b4fabc"; }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IProver} from "../interfaces/IProver.sol";

/**
 * @title BaseProver
 * @notice Base implementation for intent proving contracts
 * @dev Provides core storage and functionality for tracking proven intents
 * and their claimants
 */
abstract contract BaseProver is IProver {
    /**
     * @notice Mapping from intent hash to address eligible to claim rewards
     * @dev Zero address indicates intent hasn't been proven
     */
    mapping(bytes32 => address) public provenIntents;

    /**
     * @notice Gets the address eligible to claim rewards for a given intent
     * @param intentHash Hash of the intent to query
     * @return Address of the claimant, or zero address if unproven
     */
    function getIntentClaimant(
        bytes32 intentHash
    ) external view override returns (address) {
        return provenIntents[intentHash];
    }
}
/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @notice Represents a single contract call with encoded function data
 * @dev Used to execute arbitrary function calls on the destination chain
 * @param target The contract address to call
 * @param data ABI-encoded function call data
 * @param value Amount of native tokens to send with the call
 */
struct Call {
    address target;
    bytes data;
    uint256 value;
}

/**
 * @notice Represents a token amount pair
 * @dev Used to specify token rewards and transfers
 * @param token Address of the ERC20 token contract
 * @param amount Amount of tokens in the token's smallest unit
 */
struct TokenAmount {
    address token;
    uint256 amount;
}

/**
 * @notice Defines the routing and execution instructions for cross-chain messages
 * @dev Contains all necessary information to route and execute a message on the destination chain
 * @param salt Unique identifier provided by the intent creator, used to prevent duplicates
 * @param source Chain ID where the intent originated
 * @param destination Target chain ID where the calls should be executed
 * @param inbox Address of the inbox contract on the destination chain that receives messages
 * @param tokens Array of tokens required for execution of calls on destination chain
 * @param calls Array of contract calls to execute on the destination chain in sequence
 */
struct Route {
    bytes32 salt;
    uint256 source;
    uint256 destination;
    address inbox;
    TokenAmount[] tokens;
    Call[] calls;
}

/**
 * @notice Defines the reward and validation parameters for cross-chain execution
 * @dev Specifies who can execute the intent and what rewards they receive
 * @param creator Address that created the intent and has authority to modify/cancel
 * @param prover Address of the prover contract that must approve execution
 * @param deadline Timestamp after which the intent can no longer be executed
 * @param nativeValue Amount of native tokens offered as reward
 * @param tokens Array of ERC20 tokens and amounts offered as additional rewards
 */
struct Reward {
    address creator;
    address prover;
    uint256 deadline;
    uint256 nativeValue;
    TokenAmount[] tokens;
}

/**
 * @notice Complete cross-chain intent combining routing and reward information
 * @dev Main structure used to process and execute cross-chain messages
 * @param route Routing and execution instructions
 * @param reward Reward and validation parameters
 */
struct Intent {
    Route route;
    Reward reward;
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