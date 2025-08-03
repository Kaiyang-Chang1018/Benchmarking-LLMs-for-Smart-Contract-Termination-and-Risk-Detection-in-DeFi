// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { GasInfo } from '../types/GasEstimationTypes.sol';
import { IInterchainGasEstimation } from './IInterchainGasEstimation.sol';
import { IUpgradable } from './IUpgradable.sol';

/**
 * @title IAxelarGasService Interface
 * @notice This is an interface for the AxelarGasService contract which manages gas payments
 * and refunds for cross-chain communication on the Axelar network.
 * @dev This interface inherits IUpgradable
 */
interface IAxelarGasService is IInterchainGasEstimation, IUpgradable {
    error InvalidAddress();
    error NotCollector();
    error InvalidAmounts();
    error InvalidGasUpdates();
    error InvalidParams();
    error InsufficientGasPayment(uint256 required, uint256 provided);

    event GasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    event ExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeExpressGasAdded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event Refunded(
        bytes32 indexed txHash,
        uint256 indexed logIndex,
        address payable receiver,
        address token,
        uint256 amount
    );

    /**
     * @notice Pay for gas for any type of contract execution on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @dev If estimateOnChain is true, the function will estimate the gas cost and revert if the payment is insufficient.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param executionGasLimit The gas limit for the contract call
     * @param estimateOnChain Flag to enable on-chain gas estimation
     * @param refundAddress The address where refunds, if any, should be sent
     * @param params Additional parameters for gas payment. This can be left empty for normal contract call payments.
     */
    function payGas(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        uint256 executionGasLimit,
        bool estimateOnChain,
        address refundAddress,
        bytes calldata params
    ) external payable;

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using native currency for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using native currency for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using native currency for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using native currency for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Add additional gas payment using native currency after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Add additional gas payment using native currency after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    /**
     * @notice Updates the gas price for a specific chain.
     * @dev This function is called by the gas oracle to update the gas prices for a specific chains.
     * @param chains Array of chain names
     * @param gasUpdates Array of gas updates
     */
    function updateGasInfo(string[] calldata chains, GasInfo[] calldata gasUpdates) external;

    /**
     * @notice Allows the gasCollector to collect accumulated fees from the contract.
     * @dev Use address(0) as the token address for native currency.
     * @param receiver The address to receive the collected fees
     * @param tokens Array of token addresses to be collected
     * @param amounts Array of amounts to be collected for each respective token address
     */
    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    /**
     * @notice Refunds gas payment to the receiver in relation to a specific cross-chain transaction.
     * @dev Only callable by the gasCollector.
     * @dev Use address(0) as the token address to refund native currency.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param receiver The address to receive the refund
     * @param token The token address to be refunded
     * @param amount The amount to refund
     */
    function refund(
        bytes32 txHash,
        uint256 logIndex,
        address payable receiver,
        address token,
        uint256 amount
    ) external;

    /**
     * @notice Returns the address of the designated gas collector.
     * @return address of the gas collector
     */
    function gasCollector() external returns (address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// General interface for upgradable contracts
interface IContractIdentifier {
    /**
     * @notice Returns the contract ID. It can be used as a check during upgrades.
     * @dev Meant to be overridden in derived contracts.
     * @return bytes32 The contract ID
     */
    function contractId() external pure returns (bytes32);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IContractIdentifier } from './IContractIdentifier.sol';

interface IImplementation is IContractIdentifier {
    error NotProxy();

    function setup(bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IInterchainAddressTracker
 * @dev Manages trusted addresses by chain, keeps track of addresses supported by the Axelar gateway contract
 */
interface IInterchainAddressTracker {
    error ZeroAddress();
    error LengthMismatch();
    error ZeroStringLength();
    error UntrustedChain();

    event TrustedAddressSet(string chain, string address_);
    event TrustedAddressRemoved(string chain);

    /**
     * @dev Gets the name of the chain this is deployed at
     */
    function chainName() external view returns (string memory);

    /**
     * @dev Gets the trusted address at a remote chain
     * @param chain Chain name of the remote chain
     * @return trustedAddress_ The trusted address for the chain. Returns '' if the chain is untrusted
     */
    function trustedAddress(string memory chain) external view returns (string memory trustedAddress_);

    /**
     * @dev Gets the trusted address hash for a chain
     * @param chain Chain name
     * @return trustedAddressHash_ the hash of the trusted address for that chain
     */
    function trustedAddressHash(string memory chain) external view returns (bytes32 trustedAddressHash_);

    /**
     * @dev Checks whether the interchain sender is a trusted address
     * @param chain Chain name of the sender
     * @param address_ Address of the sender
     * @return bool true if the sender chain/address are trusted, false otherwise
     */
    function isTrustedAddress(string calldata chain, string calldata address_) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { GasEstimationType, GasInfo } from '../types/GasEstimationTypes.sol';

/**
 * @title IInterchainGasEstimation Interface
 * @notice This is an interface for the InterchainGasEstimation contract
 * which allows for estimating gas fees for cross-chain communication on the Axelar network.
 */
interface IInterchainGasEstimation {
    error UnsupportedEstimationType(GasEstimationType gasEstimationType);

    /**
     * @notice Event emitted when the gas price for a specific chain is updated.
     * @param chain The name of the chain
     * @param info The gas info for the chain
     */
    event GasInfoUpdated(string chain, GasInfo info);

    /**
     * @notice Returns the gas price for a specific chain.
     * @param chain The name of the chain
     * @return gasInfo The gas info for the chain
     */
    function getGasInfo(string calldata chain) external view returns (GasInfo memory);

    /**
     * @notice Estimates the gas fee for a cross-chain contract call.
     * @param destinationChain Axelar registered name of the destination chain
     * @param destinationAddress Destination contract address being called
     * @param executionGasLimit The gas limit to be used for the destination contract execution,
     *        e.g. pass in 200k if your app consumes needs upto 200k for this contract call
     * @param params Additional parameters for the gas estimation
     * @return gasEstimate The cross-chain gas estimate, in terms of source chain's native gas token that should be forwarded to the gas service.
     */
    function estimateGasFee(
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        uint256 executionGasLimit,
        bytes calldata params
    ) external view returns (uint256 gasEstimate);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IOwnable Interface
 * @notice IOwnable is an interface that abstracts the implementation of a
 * contract with ownership control features. It's commonly used in upgradable
 * contracts and includes the functionality to get current owner, transfer
 * ownership, and propose and accept ownership.
 */
interface IOwnable {
    error NotOwner();
    error InvalidOwner();
    error InvalidOwnerAddress();

    event OwnershipTransferStarted(address indexed newOwner);
    event OwnershipTransferred(address indexed newOwner);

    /**
     * @notice Returns the current owner of the contract.
     * @return address The address of the current owner
     */
    function owner() external view returns (address);

    /**
     * @notice Returns the address of the pending owner of the contract.
     * @return address The address of the pending owner
     */
    function pendingOwner() external view returns (address);

    /**
     * @notice Transfers ownership of the contract to a new address
     * @param newOwner The address to transfer ownership to
     */
    function transferOwnership(address newOwner) external;

    /**
     * @notice Proposes to transfer the contract's ownership to a new address.
     * The new owner needs to accept the ownership explicitly.
     * @param newOwner The address to transfer ownership to
     */
    function proposeOwnership(address newOwner) external;

    /**
     * @notice Transfers ownership to the pending owner.
     * @dev Can only be called by the pending owner
     */
    function acceptOwnership() external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IOwnable } from './IOwnable.sol';
import { IImplementation } from './IImplementation.sol';

// General interface for upgradable contracts
interface IUpgradable is IOwnable, IImplementation {
    error InvalidCodeHash();
    error InvalidImplementation();
    error SetupFailed();

    event Upgraded(address indexed newImplementation);

    function implementation() external view returns (address);

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library StringStorage {
    struct Wrapper {
        string value;
    }

    function set(bytes32 slot, string memory value) internal {
        _getStorageStruct(slot).value = value;
    }

    function get(bytes32 slot) internal view returns (string memory value) {
        value = _getStorageStruct(slot).value;
    }

    function clear(bytes32 slot) internal {
        delete _getStorageStruct(slot).value;
    }

    function _getStorageStruct(bytes32 slot) internal pure returns (Wrapper storage wrapper) {
        assembly {
            wrapper.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title GasEstimationType
 * @notice This enum represents the gas estimation types for different chains.
 */
enum GasEstimationType {
    Default,
    OptimismEcotone,
    OptimismBedrock,
    Arbitrum,
    Scroll
}

/**
 * @title GasInfo
 * @notice This struct represents the gas pricing information for a specific chain.
 * @dev Smaller uint types are used for efficient struct packing to save storage costs.
 */
struct GasInfo {
    /// @dev Custom gas pricing rule, such as L1 data fee on L2s
    uint64 gasEstimationType;
    /// @dev Scalar value needed for specific gas estimation types, expected to be less than 1e10
    uint64 l1FeeScalar;
    /// @dev Axelar base fee for cross-chain message approval on destination, in terms of source native gas token
    uint128 axelarBaseFee;
    /// @dev Gas price of destination chain, in terms of the source chain token, i.e dest_gas_price * dest_token_market_price / src_token_market_price
    uint128 relativeGasPrice;
    /// @dev Needed for specific gas estimation types. Blob base fee of destination chain, in terms of the source chain token, i.e dest_blob_base_fee * dest_token_market_price / src_token_market_price
    uint128 relativeBlobBaseFee;
    /// @dev Axelar express fee for express execution, in terms of source chain token
    uint128 expressFee;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IInterchainAddressTracker } from '../interfaces/IInterchainAddressTracker.sol';
import { StringStorage } from '../libs/StringStorage.sol';

/**
 * @title InterchainAddressTracker
 * @dev Manages and validates trusted interchain addresses of an application.
 */
contract InterchainAddressTracker is IInterchainAddressTracker {
    bytes32 internal constant PREFIX_ADDRESS_MAPPING = keccak256('interchain-address-tracker-address-mapping');
    bytes32 internal constant PREFIX_ADDRESS_HASH_MAPPING =
        keccak256('interchain-address-tracker-address-hash-mapping');
    // bytes32(uint256(keccak256('interchain-address-tracker-chain-name')) - 1)
    bytes32 internal constant _CHAIN_NAME_SLOT = 0x0e2c162a1f4b5cff9fdbd6b34678a9bcb9898a0b9fbca695b112d61688d8b2ac;

    function _setChainName(string memory chainName_) internal {
        StringStorage.set(_CHAIN_NAME_SLOT, chainName_);
    }

    /**
     * @dev Gets the name of the chain this is deployed at
     */
    function chainName() external view returns (string memory chainName_) {
        chainName_ = StringStorage.get(_CHAIN_NAME_SLOT);
    }

    /**
     * @dev Gets the trusted address at a remote chain
     * @param chain Chain name of the remote chain
     * @return trustedAddress_ The trusted address for the chain. Returns '' if the chain is untrusted
     */
    function trustedAddress(string memory chain) public view returns (string memory trustedAddress_) {
        trustedAddress_ = StringStorage.get(_getTrustedAddressSlot(chain));
    }

    /**
     * @dev Gets the trusted address hash for a chain
     * @param chain Chain name
     * @return trustedAddressHash_ the hash of the trusted address for that chain
     */
    function trustedAddressHash(string memory chain) public view returns (bytes32 trustedAddressHash_) {
        bytes32 slot = _getTrustedAddressHashSlot(chain);
        assembly {
            trustedAddressHash_ := sload(slot)
        }
    }

    /**
     * @dev Checks whether the interchain sender is a trusted address
     * @param chain Chain name of the sender
     * @param address_ Address of the sender
     * @return bool true if the sender chain/address are trusted, false otherwise
     */
    function isTrustedAddress(string calldata chain, string calldata address_) public view returns (bool) {
        bytes32 addressHash = keccak256(bytes(address_));

        return addressHash == trustedAddressHash(chain);
    }

    /**
     * @dev Gets the key for the trusted address at a remote chain
     * @param chain Chain name of the remote chain
     * @return slot the slot to store the trusted address in
     */
    function _getTrustedAddressSlot(string memory chain) internal pure returns (bytes32 slot) {
        slot = keccak256(abi.encode(PREFIX_ADDRESS_MAPPING, chain));
    }

    /**
     * @dev Gets the key for the trusted address at a remote chain
     * @param chain Chain name of the remote chain
     * @return slot the slot to store the trusted address hash in
     */
    function _getTrustedAddressHashSlot(string memory chain) internal pure returns (bytes32 slot) {
        slot = keccak256(abi.encode(PREFIX_ADDRESS_HASH_MAPPING, chain));
    }

    /**
     * @dev Sets the trusted address and its hash for a remote chain
     * @param chain Chain name of the remote chain
     * @param address_ the string representation of the trusted address
     */
    function _setTrustedAddress(string memory chain, string memory address_) internal {
        if (bytes(chain).length == 0) revert ZeroStringLength();
        if (bytes(address_).length == 0) revert ZeroStringLength();

        StringStorage.set(_getTrustedAddressSlot(chain), address_);

        bytes32 slot = _getTrustedAddressHashSlot(chain);
        bytes32 addressHash = keccak256(bytes(address_));
        assembly {
            sstore(slot, addressHash)
        }

        emit TrustedAddressSet(chain, address_);
    }

    /**
     * @dev Remove the trusted address of the chain.
     * @param chain Chain name that should be made untrusted
     */
    function _removeTrustedAddress(string memory chain) internal {
        if (bytes(chain).length == 0) revert ZeroStringLength();

        StringStorage.clear(_getTrustedAddressSlot(chain));

        bytes32 slot = _getTrustedAddressHashSlot(chain);
        assembly {
            sstore(slot, 0)
        }

        emit TrustedAddressRemoved(chain);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError, bytes32) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[EIP 191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (EIP-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.20;

import {ECDSA} from "./ECDSA.sol";
import {IERC1271} from "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Safe Wallet (previously Gnosis Safe).
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AxelarExecutable} from "./axelar/AxelarExecutable.sol";
import {IAxelarGateway} from "./interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {InterchainAddressTracker} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/InterchainAddressTracker.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ISquidMulticall} from "./interfaces/ISquidMulticall.sol";
import {IPermit2} from "./interfaces/IPermit2.sol";
import {ISpoke} from "./interfaces/ISpoke.sol";
import {Utils} from "./libraries/Utils.sol";

contract Spoke is ISpoke, AxelarExecutable, Initializable, InterchainAddressTracker, ReentrancyGuard, EIP712 {
    using Address for address payable;
    using SafeERC20 for IERC20;

    /// @dev token address => fee amount collected in this token
    mapping(address => uint256) public tokenToCollectedFees;
    mapping(bytes32 => OrderStatus) public orderHashToStatus;
    mapping(bytes32 => SettlementStatus) public settlementToStatus;

    IAxelarGasService public gasService;
    IPermit2 public permit2;
    ISquidMulticall public squidMulticall;
    address public feeCollector;
    /// @dev Chain name must follow Axelar format
    /// https://docs.axelar.dev/dev/reference/mainnet-contract-addresses
    string public hubChainName;
    string public hubAddress;

    modifier onlyFeeCollector() {
        if (msg.sender != feeCollector) revert OnlyFeeCollector();
        _;
    }

    modifier onlyTrustedAddress(string calldata fromChainName, string calldata fromContractAddress) {
        if (!isTrustedAddress(fromChainName, fromContractAddress)) revert OnlyTrustedAddress();
        _;
    }

    constructor() AxelarExecutable(0x1111111111111111111111111111111111111111) EIP712("Spoke", "1") {}

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Initializer                       //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice One-time use initialize function for the protocol. This function is required to be called
    /// within the deploying transaction to set the initial state of the Spoke.sol contract. These parameters
    /// cannot be updated after initialization.
    /// @notice The _hubChainName and _hubAddress will be set as the trusted chain and address for Axelar
    /// general message passing. Only the trusted Hub.sol contract can execute interchain transactions
    /// in the Spoke.sol contract.
    /// @param _axelarGateway Address of the relevant Axelar's AxelarGateway.sol contract deployment.
    /// @param _axelarGasService Address of the relevant Axelar's AxelarGasService.sol contract deployment.
    /// @param _permit2 Address of the relevant Uniswap's Permit2.sol contract deployment
    /// Can be zero address if not available on current network.
    /// @param _squidMulticall Address of the relevant Squid's SquidMulticall.sol contract deployment.
    /// @param _feeCollector Address of the EOA that would collect fees from the protocol. Recommended to use
    /// a multisig wallet.
    /// @param _hubChainName Chain name of the chain the Hub.sol contract will be deployed to, must follow
    /// Axelar's chain name format. This chain name will be passed to the Axelar Gateway to determine the
    /// target chain for general message passing from the Spoke.
    /// @param _hubAddress String for the address of the relevant Hub.sol contract, this should be computed
    /// deterministically using the CREATE2 opcode to remain permissionless.
    function initialize(
        IAxelarGateway _axelarGateway,
        IAxelarGasService _axelarGasService,
        IPermit2 _permit2,
        ISquidMulticall _squidMulticall,
        address _feeCollector,
        string memory _hubChainName,
        string memory _hubAddress
    ) external initializer {
        gateway = _axelarGateway;
        gasService = _axelarGasService;
        permit2 = _permit2;
        squidMulticall = _squidMulticall;
        feeCollector = _feeCollector;
        hubChainName = _hubChainName;
        hubAddress = _hubAddress;
        _setTrustedAddress(_hubChainName, _hubAddress);
    
        emit SpokeInitialized(
            gateway,
            gasService,
            permit2,
            squidMulticall,
            feeCollector,
            hubChainName,
            hubAddress
        );
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                      Source endpoints                    //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISpoke
    function createOrder(Order calldata order) external payable {
        _createOrder(order, msg.sender);
    }

    /// @inheritdoc ISpoke
    function sponsorOrder(Order calldata order, bytes calldata signature) external {
        if (order.fromToken == Utils.NATIVE_TOKEN) revert NativeTokensNotAllowed();
        if (
            !SignatureChecker.isValidSignatureNow(
                order.fromAddress,
                _hashTypedDataV4(_hashOrderTyped(order)),
                signature
            )
        ) revert InvalidUserSignature();

        _createOrder(order, order.fromAddress);
    }

    /// @notice Executes the intent on the source chain, locking the ERC20 or native tokens in the
    /// Spoke.sol contract, setting the OrderStatus to CREATED, and making the order eligible
    /// to be filled on the destination chain.
    /// @dev Orders are tied to the keccak256 hash of the Order therefore each Order is unique 
    /// according to the parameters in the Order and can only be executed a single time.
    /// @param order Order to be executed by the Spoke.sol contract in the format of the Order struct.
    /// @param fromAddress Address of the holder of funds for a particular order.
    function _createOrder(Order calldata order, address fromAddress) private nonReentrant {
        bytes32 orderHash = keccak256(abi.encode(order));

        if (orderHashToStatus[orderHash] != OrderStatus.EMPTY) revert OrderAlreadyExists();
        if (block.timestamp > order.expiry) revert OrderExpired();
        if (order.fromChain != _getChainId()) revert InvalidSourceChain();
        if (order.fromToken != Utils.NATIVE_TOKEN && msg.value != 0) revert UnexpectedNativeToken();

        orderHashToStatus[orderHash] = OrderStatus.CREATED;

        if (order.fromToken == Utils.NATIVE_TOKEN) {
            if (msg.value != order.fromAmount) revert InvalidNativeAmount();
        } else {
            IERC20(order.fromToken).safeTransferFrom(fromAddress, address(this), order.fromAmount);
        }

        emit OrderCreated(orderHash, order);
    }

    /// @inheritdoc ISpoke
    function sponsorOrderUsingPermit2(
        Order calldata order,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external nonReentrant {
        bytes32 orderHash = keccak256(abi.encode(order));

        if (orderHashToStatus[orderHash] != OrderStatus.EMPTY) revert OrderAlreadyExists();
        if (block.timestamp > order.expiry) revert OrderExpired();
        if (order.fromChain != _getChainId()) revert InvalidSourceChain();
        if (order.fromToken == Utils.NATIVE_TOKEN) revert NativeTokensNotAllowed();

        orderHashToStatus[orderHash] = OrderStatus.CREATED;

        IPermit2.SignatureTransferDetails memory transferDetails;
        transferDetails.to = address(this);
        transferDetails.requestedAmount = order.fromAmount;

        bytes32 witness = _hashOrderTyped(order);
        permit2.permitWitnessTransferFrom(
            permit,
            transferDetails,
            order.fromAddress,
            witness,
            Utils.ORDER_WITNESS_TYPE_STRING,
            signature
        );

        emit OrderCreated(orderHash, order);
    }

    /// @inheritdoc ISpoke
    function refundOrder(Order calldata order) external nonReentrant {
        bytes32 orderHash = keccak256(abi.encode(order));

        if (orderHashToStatus[orderHash] != OrderStatus.CREATED) revert OrderStateNotCreated();
        if (msg.sender != order.filler) {
            if (!(block.timestamp > (order.expiry + 1 days))) revert OrderNotExpired();
        }
        if (order.fromChain != _getChainId()) revert InvalidSourceChain();

        orderHashToStatus[orderHash] = OrderStatus.REFUNDED;

        if (order.fromToken == Utils.NATIVE_TOKEN) {
            payable(order.fromAddress).sendValue(order.fromAmount);
        } else {
            IERC20(order.fromToken).safeTransfer(order.fromAddress, order.fromAmount);
        }

        emit OrderRefunded(orderHash);
    }

    /// @inheritdoc ISpoke
    function collectFees(address[] calldata tokens) external onlyFeeCollector {
        if (tokens.length == 0) revert InvalidArrayLength();
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 feeAmount = tokenToCollectedFees[tokens[i]];
            if (feeAmount > 0) {
                tokenToCollectedFees[tokens[i]] = 0;
                if (tokens[i] == Utils.NATIVE_TOKEN) {
                    payable(feeCollector).sendValue(feeAmount);
                } else {
                    IERC20(tokens[i]).safeTransfer(feeCollector, feeAmount);
                }
            }

            emit FeesCollected(feeCollector, tokens[i], feeAmount);
        } 
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                   Destination endpoints                  //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISpoke
    function batchFillOrder(Order[] calldata orders, ISquidMulticall.Call[][] calldata calls) external payable {
        if (
            orders.length == 0 || 
            orders.length != calls.length
        ) revert InvalidArrayLength();

        uint256 remainingNativeTokenValue = msg.value;
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].toToken == Utils.NATIVE_TOKEN) {
                if (remainingNativeTokenValue < orders[i].fillAmount) revert InvalidTotalNativeAmount();
                remainingNativeTokenValue -= orders[i].fillAmount;
            }
            _fillOrder(orders[i], calls[i]);
        }
    }

    /// @inheritdoc ISpoke
    function fillOrder(Order calldata order, ISquidMulticall.Call[] calldata calls) public payable {
        if (order.toToken == Utils.NATIVE_TOKEN && msg.value != order.fillAmount) {
            revert InvalidNativeAmount();
        }

        _fillOrder(order, calls);
    }

    /// @notice Fills an order on the destination chain, transferring the order.fillAmount of
    /// order.toToken from the order.filler to the order.toAddress, setting the SettlementStatus to
    /// FILLED, and making the order eligible to be forwarded to the Hub for processing.
    /// @dev Orders that contain post hooks (postHookHash != bytes32(0)) require SquidMulticall calls
    /// to be provided during fill. These extra calls will be ran by SquidMulticall after filling the
    /// order during the same transaction.
    /// @dev Only the order.filler can fill any particular order.
    /// @param order Order to be filled by the Spoke.sol contract in the format of the Order struct.
    /// @param calls Calls to be ran by the multicall after fill, formatted to the SquidMulticall Call struct.
    function _fillOrder(Order memory order, ISquidMulticall.Call[] calldata calls) internal nonReentrant {
        bytes32 orderHash = keccak256(abi.encode(order));

        if (settlementToStatus[orderHash] != SettlementStatus.EMPTY) revert OrderAlreadySettled();
        if (msg.sender != order.filler) revert OnlyFillerCanSettle();
        if (order.toChain != _getChainId()) revert InvalidDestinationChain();

        settlementToStatus[orderHash] = SettlementStatus.FILLED;

        if (order.toToken == Utils.NATIVE_TOKEN) {
            if (order.postHookHash != bytes32(0)) {
                bytes memory callsData = abi.encode(calls);
                if (keccak256(callsData) != order.postHookHash) revert InvalidPostHookProvided();
                ISquidMulticall(squidMulticall).run{value: order.fillAmount}(calls);
            } else {
                payable(order.toAddress).sendValue(order.fillAmount);
            }
        } else {
            if (order.postHookHash != bytes32(0)) {
                bytes memory callsData = abi.encode(calls);
                if (keccak256(callsData) != order.postHookHash) revert InvalidPostHookProvided();

                IERC20(order.toToken).safeTransferFrom(
                    order.filler,
                    address(squidMulticall),
                    order.fillAmount
                );

                ISquidMulticall(squidMulticall).run(calls);
            } else {
                IERC20(order.toToken).safeTransferFrom(
                    order.filler,
                    order.toAddress,
                    order.fillAmount
                );
            }
        }

        emit OrderFilled(orderHash, order);
    }

    /// @inheritdoc ISpoke
    function forwardSettlements(bytes32[] calldata orderHashes) external payable nonReentrant {
        if (msg.value == 0) revert GasRequired();
        if (orderHashes.length == 0) revert InvalidArrayLength();

        for (uint256 i = 0; i < orderHashes.length; i++) {
            if (
                settlementToStatus[orderHashes[i]] == SettlementStatus.EMPTY
            ) revert OrderNotSettled();
            settlementToStatus[orderHashes[i]] = SettlementStatus.FORWARDED;

            emit SettlementForwarded(orderHashes[i]);
        }

        bytes memory payload = abi.encode(orderHashes);
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            hubChainName,
            hubAddress,
            payload,
            msg.sender
        );
        gateway.callContract(hubChainName, hubAddress, payload);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                  Single chain endpoints                  //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISpoke
    function fillSingleChainAtomic(
        Order calldata order,
        ISquidMulticall.Call[] calldata calls,
        bytes calldata signature
     ) external payable nonReentrant {
        bytes32 orderHash = keccak256(abi.encode(order));

        if (
            !SignatureChecker.isValidSignatureNow(
                order.fromAddress,
                _hashTypedDataV4(_hashOrderTyped(order)),
                signature
            )
        ) revert InvalidUserSignature();
        if (orderHashToStatus[orderHash] != OrderStatus.EMPTY) revert OrderAlreadyExists();
        if (settlementToStatus[orderHash] != SettlementStatus.EMPTY) revert OrderAlreadySettled();
        if (block.timestamp > order.expiry) revert OrderExpired();
        if (order.fromChain != _getChainId()) revert InvalidSourceChain();
        if (order.toChain != _getChainId()) revert InvalidDestinationChain();
        if (order.fromToken == Utils.NATIVE_TOKEN) revert NativeTokensNotAllowed();
        if (order.toToken != Utils.NATIVE_TOKEN && msg.value != 0) revert UnexpectedNativeToken();
        if (order.fromAmount == 0) revert InvalidAmount();
        if (msg.sender != order.filler) revert OnlyFillerCanSettle();    

        uint256 fee = (order.fromAmount * order.feeRate) / Utils.FEE_DIVISOR;
        uint256 fromAmount = order.fromAmount - fee;
        tokenToCollectedFees[order.fromToken] += fee;
        orderHashToStatus[orderHash] = OrderStatus.SETTLED;

        IERC20(order.fromToken).safeTransferFrom(order.fromAddress, order.filler, fromAmount);

        settlementToStatus[orderHash] = SettlementStatus.FORWARDED;

        if (order.toToken == Utils.NATIVE_TOKEN) {
            if (order.postHookHash != bytes32(0)) {
                bytes memory callsData = abi.encode(calls);
                if (keccak256(callsData) != order.postHookHash) revert InvalidPostHookProvided();
                ISquidMulticall(squidMulticall).run{value: order.fillAmount}(calls);
            } else {
                payable(order.toAddress).sendValue(order.fillAmount);
            }
        } else {
            if (order.postHookHash != bytes32(0)) {
                bytes memory callsData = abi.encode(calls);
                if (keccak256(callsData) != order.postHookHash) revert InvalidPostHookProvided();

                IERC20(order.toToken).safeTransferFrom(
                    order.filler,
                    address(squidMulticall),
                    order.fillAmount
                );

                ISquidMulticall(squidMulticall).run(calls);
            } else {
                IERC20(order.toToken).safeTransferFrom(
                    order.filler,
                    order.toAddress,
                    order.fillAmount
                );
            }
        }

        emit OrderFilled(orderHash, order);
    }

    /// @inheritdoc ISpoke
    function batchSingleChainSettlements(
        Order[] calldata orders,
        address fromToken,
        address filler
    ) external payable {
        if (orders.length == 0) revert InvalidArrayLength();
        bytes32[] memory orderHashes = new bytes32[](orders.length);
        uint256 fromAmount = 0;
        uint256 fees = 0;

        for (uint256 i = 0; i < orders.length; i++) {
            bytes32 orderHash = keccak256(abi.encode(orders[i]));
            if (settlementToStatus[orderHash] != SettlementStatus.FILLED)
                revert OrderNotSettled();
            if (orders[i].fromChain != _getChainId()) revert InvalidDestinationChain();
            if (orders[i].toChain != _getChainId()) revert InvalidSourceChain();
            if (orders[i].filler != filler) revert InvalidSettlementFiller();
            if (orders[i].fromToken != fromToken) revert InvalidSettlementSourceToken();

            uint256 fee = (orders[i].fromAmount * orders[i].feeRate) / Utils.FEE_DIVISOR;

            settlementToStatus[orderHash] = SettlementStatus.FORWARDED;
            fees += fee;
            fromAmount += orders[i].fromAmount - fee;
            orderHashes[i] = orderHash;
        }

        _releaseBatched(orderHashes, filler, fromAmount, fees, fromToken);
    }

    /// @inheritdoc ISpoke
    function batchMultiTokenSingleChainSettlements(
        Order[] calldata orders,
        address[] calldata fromTokens,
        address filler
    ) external payable {
        if (orders.length == 0 || fromTokens.length < 2) revert InvalidArrayLength();

        bytes32[] memory orderHashes = new bytes32[](orders.length);
        uint256[] memory fromAmounts = new uint256[](fromTokens.length);
        uint256[] memory fees = new uint256[](fromTokens.length);

        for (uint256 i = 0; i < orders.length; i++) {
            bytes32 orderHash = keccak256(abi.encode(orders[i]));
            if (settlementToStatus[orderHash] != SettlementStatus.FILLED)
                revert OrderNotSettled();
            if (orders[i].fromChain != _getChainId()) revert InvalidDestinationChain();
            if (orders[i].toChain != _getChainId()) revert InvalidSourceChain();
            if (orders[i].filler != filler) revert InvalidSettlementFiller();

            uint256 tokenIndex = _findTokenIndex(orders[i].fromToken, fromTokens);
            if (tokenIndex == type(uint256).max) revert InvalidSettlementSourceToken();

            uint256 fee = (orders[i].fromAmount * orders[i].feeRate) / Utils.FEE_DIVISOR;

            settlementToStatus[orderHash] = SettlementStatus.FORWARDED;
            fees[tokenIndex] += fee;
            fromAmounts[tokenIndex] += orders[i].fromAmount - fee;
            orderHashes[i] = orderHash;
        }

        _releaseMultiTokenBatched(orderHashes, filler, fromAmounts, fees, fromTokens);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                      Axelar endpoint                     //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Called by Axelar protocol when receiving a GMP on the destination chain from the Hub.
    /// Contains logic that will parse the payload and release tokens for eligible orders to the order.filler.
    /// @dev This method will only accept GMP's from the hubChain and hubAddress set within the Spoke.sol
    /// initializer at the time of contract deployment.
    /// @dev There are two options for FillType: SINGLE and MULTI
    /// SINGLE is used when a batch of orders only contains a single unique order.fromToken, and only requires
    /// a single transfer to release the tokens for the batch of orders to the order.filler.
    /// MULTI is used when a batch of orders contains multiple unique order.fromToken, and will use as many
    /// transfers as there are unique tokens in the batch.
    /// @param fromChain Chain name of the chain that sent the GMP according to Axelar's chain name format:
    /// https://docs.axelar.dev/dev/reference/mainnet-contract-addresses
    /// @param fromContractAddress Address that sent the GMP.
    /// @param payload Value provided by the Hub containing the aggregated data for the orders being processed.
    /// Expected format is: abi.encode(ICoral.FillType fillType, bytes32[] orderHashes, address filler,
    /// uint256[] fromAmounts, uint256[] fees, address[] fromTokens)
    function _execute(
        string calldata fromChain,
        string calldata fromContractAddress,
        bytes calldata payload
    ) internal virtual override onlyTrustedAddress(fromChain, fromContractAddress) {
        (
            FillType fillType,
            bytes32[] memory orderHashes,
            address filler,
            uint256[] memory fromAmounts,
            uint256[] memory processedFees,
            address[] memory fromTokens
        ) = abi.decode(
                payload,
                (FillType, bytes32[], address, uint256[], uint256[], address[])
            );

        if (fillType == FillType.SINGLE) {
            if (
                fromTokens.length != 1 || 
                fromAmounts.length != 1 ||
                processedFees.length != 1
            ) revert InvalidArrayLength();
            _releaseBatched(orderHashes, filler, fromAmounts[0], processedFees[0], fromTokens[0]);
        } else if (fillType == FillType.MULTI) {
            _releaseMultiTokenBatched(orderHashes, filler, fromAmounts, processedFees, fromTokens);
        } else {
            revert InvalidFillType();
        }
    }

    /// @notice Checks the OrderStatus of each order hash provided to ensure all orders are set to CREATED,
    /// set the OrderStatus of all order hashes to SETTLED, increments the fees for the provided token and 
    /// processedFees, and transfers the fromAmount of ERC20 or native token from the Spoke.sol contract 
    /// to the filler in a single transfer for all orders in the batch.
    /// @dev The provided order hashes are computed on the Hub based on orders that were processed and had
    /// a matching order hash that was processed on the order.toChain of the particular orders. Orders are
    /// eligible on the Hub to be forwarded to the order.fromChain once they've been filled on the
    /// order.toChain. Cross chain messages secured by Axelar protocol allow this function to receive
    /// confirmation that derived from the order.toChain Spoke.sol contract.
    /// @dev This method is called by the SINGLE FillType, therefore this will process orders for a single
    /// unique filler and token.
    /// @param orderHashes Array of keccak256 hashes of Orders being finalized.
    /// @param filler Address of the order.filler for all orders in the particular batch.
    /// @param fromAmount Amount of order.fromToken to be released to the filler.
    /// @param processedFees Amount of order.fromToken to be reserved as protocol fees.
    /// @param fromToken Address of the order.fromToken for all orders in the particular batch.
    function _releaseBatched(
        bytes32[] memory orderHashes,
        address filler,
        uint256 fromAmount,
        uint256 processedFees,
        address fromToken
    ) internal nonReentrant {
        if (orderHashes.length == 0) revert InvalidArrayLength();
    
        for (uint256 i = 0; i < orderHashes.length; i++) {
            bytes32 orderHash = orderHashes[i];
            if (orderHashToStatus[orderHash] != OrderStatus.CREATED) revert OrderStateNotCreated();
            orderHashToStatus[orderHash] = OrderStatus.SETTLED;

            emit TokensReleased(orderHash);
        }

        tokenToCollectedFees[fromToken] += processedFees;

        if (fromToken == Utils.NATIVE_TOKEN) {
            payable(filler).sendValue(fromAmount);
        } else {
            IERC20(fromToken).safeTransfer(filler, fromAmount);
        }
    }

    /// @notice Checks the OrderStatus of each order hash provided to ensure all orders are set to CREATED,
    /// set the OrderStatus of all order hashes to SETTLED, increments the fees for each unique token provided
    /// and the related processedFees according to the array position, and transfers the fromAmounts of native
    /// token or each unique ERC20 token from the Spoke.sol contract to the filler with a transfer for each
    /// unique token in the particular batch.
    /// @dev The provided order hashes are computed on the Hub based on orders that were processed and had
    /// a matching order hash that was processed on the order.toChain of the particular orders. Orders are
    /// eligible on the Hub to be forwarded to the order.fromChain once they've been filled on the
    /// order.toChain. Cross chain messages secured by Axelar protocol allow this function to receive
    /// confirmation that derived from the order.toChain Spoke.sol contract.
    /// @dev This method is called by the MULTI FillType, therefore this will process orders for all unique
    /// tokens in the particular batch and a single filler.
    /// @param orderHashes Array of keccak256 hashes of Orders being finalized.
    /// @param filler Address of the order.filler for all orders in the particular batch.
    /// @param fromAmounts Array of amounts of order.fromToken to be released to the filler.
    /// @param processedFees Array of amounts of order.fromToken to be reserved as protocol fees.
    /// @param fromTokens Array of addresses for all unique order.fromToken in a particular batch.
    function _releaseMultiTokenBatched(
        bytes32[] memory orderHashes,
        address filler,
        uint256[] memory fromAmounts,
        uint256[] memory processedFees,
        address[] memory fromTokens
    ) internal nonReentrant {
        if (
            orderHashes.length == 0 ||
            fromAmounts.length != fromTokens.length ||
            processedFees.length != fromTokens.length ||
            fromTokens.length < 2
        ) revert InvalidArrayLength();

        for (uint256 i = 0; i < orderHashes.length; i++) {
            bytes32 orderHash = orderHashes[i];
            if (orderHashToStatus[orderHash] != OrderStatus.CREATED) revert OrderStateNotCreated();
            orderHashToStatus[orderHash] = OrderStatus.SETTLED;

            emit TokensReleased(orderHash);
        }

        for (uint256 i = 0; i < fromTokens.length; i++) {
            tokenToCollectedFees[fromTokens[i]] += processedFees[i];

            if (fromTokens[i] == Utils.NATIVE_TOKEN) {
                payable(filler).sendValue(fromAmounts[i]);
            } else {
                IERC20(fromTokens[i]).safeTransfer(filler, fromAmounts[i]);
            }
        }
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Utilities                         //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Hashes the provided order using a typed EIP-712 struct.
    /// @param order Order struct containing information about the order to be hashed.
    /// @return bytes32 EIP-712 typed hash of the provided order.
    function _hashOrderTyped(Order calldata order) private pure returns (bytes32) {
        return keccak256(abi.encode(
            Utils.ORDER_TYPEHASH,
            order.fromAddress,
            order.toAddress,
            order.filler,
            order.fromToken,
            order.toToken,
            order.expiry,
            order.fromAmount,
            order.fillAmount,
            order.feeRate,
            order.fromChain,
            order.toChain,
            order.postHookHash
        ));
    }

    /// @notice Finds the index of a given token in an array of tokens.
    /// @param token Address of the token to find in the array.
    /// @param fromTokens Array of token addresses to search for the given token.
    /// @return uint256 Index of the token in the array, or the maximum value of uint256 if the token 
    /// is not found.
    function _findTokenIndex(
        address token,
        address[] calldata fromTokens
    ) private pure returns (uint256) {
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == token) {
                return i;
            }
        }
        return type(uint256).max;
    }

    /// @notice Retrieves the current chain ID.
    /// @return uint256 The current chain ID.
    function _getChainId() private view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from '../interfaces/IAxelarGateway.sol';
import { IAxelarExecutable } from '../interfaces/IAxelarExecutable.sol';

contract AxelarExecutable is IAxelarExecutable {
    IAxelarGateway public gateway;

    constructor(address gateway_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash))
            revert NotApprovedByGateway();

        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (
            !gateway.validateContractCallAndMint(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount
            )
        ) revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title AllowanceTransfer
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by checking allowed amounts
/// @dev Requires user's token approval on the Permit2 contract
interface IAllowanceTransfer is IEIP712 {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Thrown when a transferFrom2 call does not either have regular ERC20 or permit2 allowance.
    error TransferFailed();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
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

    /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allowance
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The saved permissions
    /// @dev This info is saved per owner, per token, per spender and all signed over in the permit message
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    struct PackedAllowance {
        // amount allowed
        uint160 amount;
        // permission expiry
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice A token spender pair.
    struct TokenSpenderPair {
        // the token the spender is approved
        address token;
        // the spender address
        address spender;
    }

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
    function allowance(address user, address token, address spender)
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Approves the spender to use up to amount of the specified token up until the expiration
    /// @param token The token to approve
    /// @param spender The spender address to approve
    /// @param amount The approved amount of the token
    /// @param expiration The timestamp at which the approval is no longer valid
    /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;

    /// @notice Permit a spender to a given amount of the owners token via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitSingle Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    /// @notice Enables performing a "lockdown" of the sender's Permit2 identity
    /// by batch revoking approvals
    /// @param approvals Array of approvals to revoke.
    function lockdown(TokenSpenderPair[] calldata approvals) external;

    /// @notice Invalidate nonces for a given (token, spender) pair
    /// @param token The token to invalidate nonces for
    /// @param spender The spender to invalidate nonces for
    /// @param newNonce The new nonce to set. Invalidates all nonces less than it.
    /// @dev Can't invalidate more than 2**16 nonces per transaction.
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from './IAxelarGateway.sol';

interface IAxelarExecutable {
    error InvalidAddress();
    error NotApprovedByGateway();

    function gateway() external view returns (IAxelarGateway);

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external;

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IGovernable } from './IGovernable.sol';
import { IImplementation } from './IImplementation.sol';

interface IAxelarGateway is IImplementation, IGovernable {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(
        address indexed sender,
        string destinationChain,
        string destinationAddress,
        string symbol,
        uint256 amount
    );

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallExecuted(bytes32 indexed commandId);

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    /************************\
    |* Governance Functions *|
    \************************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function execute(bytes calldata input) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// General interface for upgradable contracts
interface IContractIdentifier {
    /**
     * @notice Returns the contract ID. It can be used as a check during upgrades.
     * @dev Meant to be overridden in derived contracts.
     * @return bytes32 The contract ID
     */
    function contractId() external pure returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoral {
    /// @notice Fill type that designates what method to be used on the Spoke on the source chain
    /// upon releasing tokens to the filler.
    /// SINGLE is used when a batch of orders only contains a single unique order.fromToken, and only requires
    /// a single transfer to release the tokens for the batch of orders to the order.filler.
    /// MULTI is used when a batch of orders contains multiple unique order.fromToken, and will use as many
    /// transfers as there are unique tokens in the batch.
    enum FillType {
        // Single token release.
        SINGLE,
        // Multi token release.
        MULTI
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IGovernable Interface
 * @notice This is an interface used by the AxelarGateway contract to manage governance and mint limiter roles.
 */
interface IGovernable {
    error NotGovernance();
    error NotMintLimiter();
    error InvalidGovernance();
    error InvalidMintLimiter();

    event GovernanceTransferred(address indexed previousGovernance, address indexed newGovernance);
    event MintLimiterTransferred(address indexed previousGovernance, address indexed newGovernance);

    /**
     * @notice Returns the governance address.
     * @return address of the governance
     */
    function governance() external view returns (address);

    /**
     * @notice Returns the mint limiter address.
     * @return address of the mint limiter
     */
    function mintLimiter() external view returns (address);

    /**
     * @notice Transfer the governance role to another address.
     * @param newGovernance The new governance address
     */
    function transferGovernance(address newGovernance) external;

    /**
     * @notice Transfer the mint limiter role to another address.
     * @param newGovernance The new mint limiter address
     */
    function transferMintLimiter(address newGovernance) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IContractIdentifier } from './IContractIdentifier.sol';

interface IImplementation is IContractIdentifier {
    error NotProxy();

    function setup(bytes calldata data) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISignatureTransfer} from "./ISignatureTransfer.sol";
import {IAllowanceTransfer} from "./IAllowanceTransfer.sol";

/// @notice Permit2 handles signature-based transfers in SignatureTransfer and allowance-based transfers in AllowanceTransfer.
/// @dev Users must approve Permit2 before calling any of the transfer functions.
interface IPermit2 is ISignatureTransfer, IAllowanceTransfer {
// IPermit2 unifies the two interfaces so users have maximal flexibility with their approval.
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAxelarGateway} from "./IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {ICoral} from "./ICoral.sol";
import {IPermit2} from "./IPermit2.sol";
import {ISquidMulticall} from "./ISquidMulticall.sol";

/// @title Spoke
/// @notice Entry point of the protocol. The Spoke.sol contract manages the state of orders, token transfers,
/// and settlement.
interface ISpoke is ICoral {
    /// @notice Order status type that tracks the state of an Order throughout its lifecycle on the Spoke.
    enum OrderStatus {
        // Order does not exist.
        EMPTY,
        // Order has been created, pending settlement.
        CREATED,
        // Order has been settled.
        SETTLED,
        // Order has been refunded.
        REFUNDED
    }

    /// @notice Settlement status type that tracks the settlement state of an Order throughout its lifecycle on the Spoke.
    enum SettlementStatus {
        // Order settlement does not exist.
        EMPTY,
        // Order has been filled.
        FILLED,
        // Order has been forwarded to the Hub pending source token release.
        FORWARDED
    }

    /// @notice Calldata format expected by the Spoke.sol contract.
    struct Order {
        // Address that will supply the fromAmount of fromToken on the fromChain.
        address fromAddress;
        // Address to receive the fillAmount of toToken on the toChain.
        address toAddress;
        // Address that will fill the Order on the toChain.
        address filler;
        // Address of the ERC20 token being supplied on the fromChain.
        // 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
        address fromToken;
        // Address of the ERC20 token being supplied on the toChain.
        // 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
        address toToken;
        // Expiration in UNIX for the Order to be created on the fromChain.
        uint256 expiry;
        // Amount of fromToken to be provided by the fromAddress.
        uint256 fromAmount;
        // Amount of toToken to be provided by the filler.
        uint256 fillAmount;
        // Protocol fees are taken out of the fromAmount and are calculated within the Spoke.sol
        // contract for single chain orders or on the Hub for cross chain orders. 
        // The following formula determines the amount of fromToken reserved as fees:
        // fee = (fromAmount * feeRate) / 1000000
        uint256 feeRate;
        // Chain ID of the chain the Order will be created on.
        uint256 fromChain;
        // Chain ID of the chain the Order will be filled on.
        uint256 toChain;
        // Keccak256 hash of the abi.encoded ISquidMulticall.Call[] calldata calls that should be provided
        // at the time of filling the order.
        bytes32 postHookHash;
    }

    /// @notice Emitted when the Spoke.sol contract is successfully initialized after contract deployment.
    /// @param gateway Address set as the relevant Axelar's AxelarGateway.sol contract deployment.
    /// @param gasService Address set as the relevant Axelar's AxelarGasService.sol contract deployment.
    /// @param permit2 Address set as the relevant Uniswap's Permit2.sol contract deployment.
    /// @param squidMulticall Address set as the relevant Squid's SquidMulticall.sol contract deployment.
    /// @param feeCollector Address set as the EOA that can collect fees from the protocol.
    /// @param hubChainName Chain name of the chain the Hub.sol contract is deployed to.
    /// @param hubAddress Address set as the relevant Hub.sol contract.
    event SpokeInitialized(
       IAxelarGateway indexed gateway,
       IAxelarGasService indexed gasService,
       IPermit2 indexed permit2,
       ISquidMulticall squidMulticall,
       address feeCollector,
       string hubChainName,
       string hubAddress
    );

    /// @dev Source events
    /// @notice Emitted when fees are collected from the Spoke.sol contract.
    /// @param feeCollector Address of the EOA that collected fees.
    /// @param token Token for which fees were collected.
    /// @param amount Amount of token for which fees were collected.
    event FeesCollected(
        address indexed feeCollector,
        address indexed token,
        uint256 indexed amount
    );
    /// @notice Emitted when an Order is created on the source chain.
    /// @param orderHash Keccak256 hash of the Order that was created.
    /// @param order Raw Order struct of the Order that was created.
    event OrderCreated(bytes32 indexed orderHash, Order order);
    /// @notice Emitted when an Order is refunded on the source chain.
    /// @param orderHash Keccak256 hash of the Order that was refunded.
    event OrderRefunded(bytes32 indexed orderHash);
    /// @notice Emitted when an Order has been settled and tokens released to the filler, completing
    /// its lifecycle.
    /// @param orderHash Keccak256 hash of the Order that was settled.
    event TokensReleased(bytes32 indexed orderHash);

    /// @dev Destination events
    /// @notice Emitted when an Order is filled on the source chain.
    /// @param orderHash Keccak256 hash of the Order that was filled.
    /// @param order Raw Order struct of the Order that was filled.
    event OrderFilled(bytes32 indexed orderHash, Order order);
    /// @notice Emitted when an Order settlement has been forwarded to the Hub for processing.
    /// @param orderHash Keccak256 hash of the Order that was forwarded.
    event SettlementForwarded(bytes32 indexed orderHash);

    /// @notice Thrown when zero msg.value is provided to a function that requires extra native tokens to be
    /// supplied to pay for gas needs.
    error GasRequired();
    /// @notice Thrown when the order.fromAmount of the provided Order is equal to zero.
    error InvalidAmount();
    /// @notice Thrown when an array has an incorrect length.
    error InvalidArrayLength();
    /// @notice Thrown when the targeted chain is not equal to the order.toChain of the provided Order.
    error InvalidDestinationChain();
    /// @notice Thrown when an invalid FillType is provided to the Axelar GMP targeting the Spoke.sol contract.
    error InvalidFillType();
    /// @notice Thrown when the provided msg.value does not match the order.fromAmount or order.fillAmount of
    /// the provided Order that deals with native tokens.
    error InvalidNativeAmount();
    /// @notice Thrown when the order.postHookHash of the provided Order does not match the keccak256 hash of
    /// the abi.encoded ISquidMulticall.Call[] calldata calls provided while filling an Order.
    error InvalidPostHookProvided();
    /// @notice Thrown when the order.filler of a provided Order does not match the provided filler when batching
    /// single chain settlements.
    error InvalidSettlementFiller();
    /// @notice Thrown when the order.fromToken of a provided Order does not match the provided fromToken when
    /// batching single chain settlements.
    error InvalidSettlementSourceToken();
    /// @notice Thrown when the targeted chain is not equal to the order.fromChain of the provided Order.
    error InvalidSourceChain();
    /// @notice Thrown when not enough msg.value is provided while batch filling orders involving native tokens.
    error InvalidTotalNativeAmount();
    /// @notice Thrown when an invalid signature is provided while executing gasless intents.
    error InvalidUserSignature();
    /// @notice Thrown when native token is selected as the order.fromToken of a provided Order and passed to a
    /// function that does not allow native tokens.
    error NativeTokensNotAllowed();
    /// @notice Thrown when the caller address is not equal to the feeCollecter address set within the initializer.
    error OnlyFeeCollector();
    /// @notice Thrown when the caller msg.sender is not equal to the order.filler of the provided Order.
    error OnlyFillerCanSettle();
    /// @notice Thrown when an Axelar GMP is executed from an address or chain that does not match the
    /// hubChainName and hubAddress set within the initializer.
    error OnlyTrustedAddress();
    /// @notice Thrown when the orderHashToStatus of the orderHash of the provided Order is not in the
    // required OrderStatus.EMPTY state.
    error OrderAlreadyExists();
    /// @notice Thrown when the settlementToStatus of the orderHash of the provided Order is not in the
    // required SettlementStatus.EMPTY state.
    error OrderAlreadySettled();
    /// @notice Thrown when the current block.timestamp is greater than the order.expiry of the provided Order.
    error OrderExpired();
    /// @notice Thrown when the current block.timestamp is not greater than the order.expiry + buffer
    /// when attempting to refund an order.
    error OrderNotExpired();
    /// @notice Thrown when the settlementToStatus of the orderHash of the provided Order is not in the
    // required SettlementStatus.FILLED state.
    error OrderNotSettled();
    /// @notice Thrown when the orderHashToStatus of the orderHash of the provided Order is not in the
    // required OrderStatus.CREATED state.
    error OrderStateNotCreated();
    /// @notice Thrown when the order.fromToken of a provided Order is not a native token and a non-zero
    /// msg.value is provided.
    error UnexpectedNativeToken();

    /// @notice Executes the intent on the source chain, locking the ERC20 or native tokens in the
    /// Spoke.sol contract, setting the OrderStatus to CREATED, and making the order eligible
    /// to be filled on the destination chain.
    /// @dev Orders are tied to the keccak256 hash of the Order therefore each Order is unique 
    /// according to the parameters in the Order and can only be executed a single time. Using this
    /// method tokens will transfer from the msg.sender, but the order will belong to the 
    /// order.fromAddress.
    /// @param order Order to be executed by the Spoke.sol contract in the format of the Order struct.
    function createOrder(Order calldata order) external payable;

    /// @notice Executes the intent on behalf of the Order signer gaslessly on the source chain, locking
    /// the ERC20 or native tokens in the Spoke.sol contract, setting the OrderStatus to CREATED, and 
    /// making the order eligible to be filled on the destination chain.
    /// @dev Orders are tied to the keccak256 hash of the Order therefore each Order is unique 
    /// according to the parameters in the Order and can only be executed a single time. Using this
    /// method tokens will transfer from the order.fromAddress.
    /// @dev The intent can be executed by the signer or a separate relayer on behalf of the signer.
    /// @dev This method requires the Order signer to have already approved the Spoke.sol contract to
    /// spend the ERC20 order.fromToken.
    /// @dev This method cannot be used with native tokens as it requires transferring tokens from the
    /// signer at the time the intent is sponsored.
    /// @param order Order to be executed by the Spoke.sol contract in the format of the Order struct.
    /// @param signature Signature calldata according to EIP-712 using eth_signTypedData_v4.
    function sponsorOrder(Order calldata order, bytes calldata signature) external;

    /// @notice Executes the intent on behalf of the Order signer gaslessly on the source chain using
    /// Uniswap's Permit2 contract, locking the ERC20 or native tokens in the Spoke.sol contract, setting 
    /// the OrderStatus to CREATED, and making the order eligible to be filled on the destination chain.
    /// @dev Orders are tied to the keccak256 hash of the Order therefore each Order is unique 
    /// according to the parameters in the Order and can only be executed a single time. Using this
    /// method tokens will transfer from the order.fromAddress.
    /// @dev The intent can be executed by the signer or a separate relayer on behalf of the signer.
    /// @dev This method requires the Order signer to have already approved the Uniswap Permit2
    /// contract on the order.fromChain for order.fromAmount of ERC20 order.fromToken.
    /// @dev See https://docs.uniswap.org/contracts/permit2/reference/signature-transfer for more
    /// information about permit2 protocol requirements.
    /// @dev This method cannot be used with native tokens as it requires transferring tokens from the
    /// signer at the time the intent is sponsored.
    /// @param order Order to be executed by the Spoke.sol contract in the format of the Order struct.
    /// @param permit Permit data according to permit2 protocol.
    /// @param signature Signature data according to permit2 protocol.
    function sponsorOrderUsingPermit2(
        Order calldata order,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external;

    /// @notice Refunds an eligible Order, transferring the order.fromAmount of order.fromToken from
    /// the Spoke.sol contract to the order.fromAddress.
    /// @dev Orders can be instantly refunded by the order.filler if the filler decides they don't wish
    /// to fill the order.
    /// @dev Orders can be refunded by anyone as long is the block.timestamp of the target chain is
    /// greater than the order.expiry + 24 hours.
    /// @param order Order to be refunded by the Spoke.sol contract in the format of the Order struct.
    function refundOrder(Order calldata order) external;

    /// @notice Transfers collected protocol fees from the Spoke.sol contract to the feeCollector and
    /// sets the fee balance for the provided tokens to zero.
    /// @dev Fees can be collected for all ERC20 and native tokens, this method will transfer the full
    /// balance of the currently collected fees per token provided.
    /// @param tokens Array of ERC20 tokens to collect fees for.
    function collectFees(address[] calldata tokens) external;

    /// @notice Fills orders in batches on the destination chain, transferring the order.fillAmount of
    /// order.toToken from the order.filler to the order.toAddress, setting the SettlementStatus to
    /// FILLED, and all orders in the batch eligible to be forwarded to the Hub for processing.
    /// @dev Orders that contain post hooks (postHookHash != bytes32(0)) require SquidMulticall calls
    /// to be provided during fill. These extra calls will be ran by SquidMulticall after filling the
    /// order during the same transaction.
    /// @dev Only the order.filler can fill any particular order.
    /// @dev In the case of filling native token orders in batches, the provided msg.value must be greater
    /// than or equal to the total order.fillAmount of native tokens in the batch. Batches can be a mix of
    /// ERC20 and native tokens.
    /// @param orders Array of Orders to be filled by the Spoke.sol contract in the format of the Order struct.
    /// @param calls Array of Calls to be ran by the multicall after fill, formatted to the SquidMulticall 
    /// Call struct.
    function batchFillOrder(Order[] calldata orders, ISquidMulticall.Call[][] calldata calls) external payable;

    /// @notice Fills an order on the destination chain, transferring the order.fillAmount of
    /// order.toToken from the order.filler to the order.toAddress, setting the SettlementStatus to
    /// FILLED, and making the order eligible to be forwarded to the Hub for processing.
    /// @dev Orders that contain post hooks (postHookHash != bytes32(0)) require SquidMulticall calls
    /// to be provided during fill. These extra calls will be ran by SquidMulticall after filling the
    /// order during the same transaction.
    /// @dev Only the order.filler can fill any particular order.
    /// @param order Order to be filled by the Spoke.sol contract in the format of the Order struct.
    /// @param calls Calls to be ran by the multicall after fill, formatted to the SquidMulticall Call struct.
    function fillOrder(Order calldata order, ISquidMulticall.Call[] calldata calls) external payable;

    /// @notice Sets the SettlementStatus of orders to FORWARDED and executes an Axelar GMP containing 
    /// an array of eligible order hashes to be sent cross chain to the Hub for processing.
    /// @dev Provided orders must have the settlementToStatus set FILLED to be eligible to be forwarded.
    /// @dev Gas is required in the form of native tokens, therefore the msg.value must contain enough
    /// native token to pay for the Axelar GMP and execution costs of the calldata on the Hub.
    /// @dev It is recommended to forward settlements in batches, the number of orders that can be forwarded
    /// in a batch is dependent on the block gas limit of the particular chain.
    /// @param orders Array of Orders to be forwarded by the Spoke.sol contract in the format of the Order struct.
    function forwardSettlements(bytes32[] calldata orders) external payable;

    /// @notice Fills a single chain order atomically, executing the signed intent transferring the
    /// order.fromAmount of ERC20 order.fromToken from the order.fromAddress to the order.filler, transfers
    /// the order.toAmount of order.toToken to the order.toAddress, sets the OrderStatus to SETTLED and the
    /// SettlementStatus to FORWARDED, and executes any additional calls via SquidMulticall, completing the
    /// full lifecycle of an order in a single transaction.
    /// @dev Orders are tied to the keccak256 hash of the Order therefore each Order is unique 
    /// according to the parameters in the Order and can only be executed a single time.
    /// @dev This method requires the order.fromChain and order.toChain to be equal.
    /// @dev This method requires the msg.sender to be equal to the order.filler.
    /// @dev This method requires the Order signer to have already approved the Spoke.sol contract to
    /// spend the ERC20 order.fromToken.
    /// @dev This method cannot be used with native tokens as it requires transferring tokens from the
    /// signer at the time the intent is executed.
    /// @param order Order to be executed by the Spoke.sol contract in the format of the Order struct.
    /// @param calls Calls to be ran by the multicall after fill, formatted to the SquidMulticall Call struct.
    /// @param signature Signature calldata according to EIP-712 using eth_signTypedData_v4.
    function fillSingleChainAtomic(
        Order calldata order,
        ISquidMulticall.Call[] calldata calls,
        bytes calldata signature
     ) external payable;

    /// @notice Processes filled single chain orders, setting the SettlementStatus to FORWARDED and 
    /// OrderStatus to SETTLED for eligible orders, calculates the fee amount based on the order.feeRate,
    /// and transfers the total amount of order.fromAmount (minus the fee amount) of order.fromToken from
    /// the Spoke.sol contract to the order.filler, and increments the available protocol fees for the
    /// order.fromToken according to the calculated fees for the orders being processed, completing the 
    /// lifecycle of single chain orders.
    /// @dev Provided orders must have the SettlementStatus set to FILLED and OrderStatus set to CREATED
    /// to be eligible.
    /// @dev This method is only available for single chain orders and does not require an Axelar GMP.
    /// @dev This method is only available for a single filler and token, therefore the order.filler and
    /// order.fromToken of all orders in a batch must be equal.
    /// @dev It is recommended to process settlements in batches, the number of orders that can be processed
    /// in a batch is dependent on the block gas limit of the particular chain.
    /// @param orders Array of single chain Orders to be processed by the Spoke.sol contract in the format of 
    /// the Order struct.
    /// @param fromToken Address of the order.fromToken for all orders in the particular batch.
    /// @param filler Address of the order.filler for all orders in the particular batch.
    function batchSingleChainSettlements(
        Order[] calldata orders,
        address fromToken,
        address filler
    ) external payable;

    /// @notice Processes filled single chain orders, setting the SettlementStatus to FORWARDED and
    /// OrderStatus to SETTLED for eligible orders, calculates the fee amount based on the order.feeRate
    /// for each token in a particular batch, and transfers the total amount of order.fromAmount (minus
    /// the fee amount) of each order.fromToken from the Spoke.sol contract to the order.filler, and increments
    /// the available protocol fees for each order.fromToken according to the calculated fees for the orders
    /// being processed, completing the lifecycle of single chain orders.
    /// @dev Provided orders must have the SettlementStatus set to FILLED and OrderStatus set to CREATED
    /// to be eligible.
    /// @dev This method is only available for single chain orders and does not require an Axelar GMP.
    /// @dev This method is only available for a single filler therefore the order.filler of all orders in a 
    /// batch must be equal.
    /// @dev This method can be used with multiple from tokens. For example, if there are 100 orders in a batch
    /// and of all order.fromToken there are 10 unique tokens, this function only requires the 10 unique tokens
    /// to be passed as the fromTokens. This will execute 10 transfers from the Spoke.sol contract to the
    /// order.filler for the total amount of order.fromAmount for each unique token being processed.
    /// @dev It is recommended to process settlements in batches, the number of orders that can be processed
    /// in a batch is dependent on the block gas limit of the particular chain.
    /// @param orders Array of single chain Orders to be processed by the Spoke.sol contract in the format of
    /// the Order struct.
    /// @param fromTokens Array of addresses for all unique order.fromToken in a particular batch.
    /// @param filler Address of the order.filler for all orders in the particular batch.
    function batchMultiTokenSingleChainSettlements(
        Order[] calldata orders,
        address[] calldata fromTokens,
        address filler
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title SquidMulticall
/// @notice Multicall logic specific to Squid calls format. The contract specificity is mainly
/// to enable ERC20 and native token amounts in calldata between two calls.
/// @dev Support receiption of NFTs.
interface ISquidMulticall {
    /// @notice Call type that enables to specific behaviours of the multicall.
    enum CallType {
        // Will simply run calldata
        Default,
        // Will update amount field in calldata with ERC20 token balance of the multicall contract.
        FullTokenBalance,
        // Will update amount field in calldata with native token balance of the multicall contract.
        FullNativeBalance,
        // Will run a safeTransferFrom to get full ERC20 token balance of the caller.
        CollectTokenBalance
    }

    /// @notice Calldata format expected by multicall.
    struct Call {
        // Call type, see CallType struct description.
        CallType callType;
        // Address that will be called.
        address target;
        // Native token amount that will be sent in call.
        uint256 value;
        // Calldata that will be send in call.
        bytes callData;
        // Extra data used by multicall depending on call type.
        // Default: unused (provide 0x)
        // FullTokenBalance: address of the ERC20 token to get balance of and zero indexed position
        // of the amount parameter to update in function call contained by calldata.
        // Expect format is: abi.encode(address token, uint256 amountParameterPosition)
        // Eg: for function swap(address tokenIn, uint amountIn, address tokenOut, uint amountOutMin,)
        // amountParameterPosition would be 1.
        // FullNativeBalance: unused (provide 0x)
        // CollectTokenBalance: address of the ERC20 token to collect.
        // Expect format is: abi.encode(address token)
        bytes payload;
    }

    /// Thrown when one of the calls fails.
    /// @param callPosition Zero indexed position of the call in the call set provided to the
    /// multicall.
    /// @param reason Revert data returned by contract called in failing call.
    error CallFailed(uint256 callPosition, bytes reason);

    /// @notice Main function of the multicall that runs the call set.
    /// @param calls Call set to be ran by multicall.
    function run(Call[] calldata calls) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/// @title Utils
/// @notice Library for general purpose functions and values.
library Utils {
    using Address for address payable;

    /// @notice Arbitrary address chosen to represent native token of current network.
    address internal constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    bytes32 internal constant ORDER_TYPEHASH = keccak256("Order(address fromAddress,address toAddress,address filler,address fromToken,address toToken,uint256 expiry,uint256 fromAmount,uint256 fillAmount,uint256 feeRate,uint256 fromChain,uint256 toChain,bytes32 postHookHash)");
    
    string internal constant ORDER_WITNESS_TYPE_STRING =
        "Order witness)Order(address fromAddress,address toAddress,address filler,address fromToken,address toToken,uint256 expiry,uint256 fromAmount,uint256 fillAmount,uint256 feeRate,uint256 fromChain,uint256 toChain,bytes32 postHookHash)TokenPermissions(address token,uint256 amount)";

    uint256 internal constant FEE_DIVISOR = 1000000;
}