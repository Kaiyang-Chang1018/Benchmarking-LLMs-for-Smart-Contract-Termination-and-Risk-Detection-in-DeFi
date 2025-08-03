// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { BytesLib } from "solidity-bytes-utils/contracts/BytesLib.sol";

import { BitMap256 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/BitMaps.sol";
import { CalldataBytesLib } from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/CalldataBytesLib.sol";

library DVNOptions {
    using CalldataBytesLib for bytes;
    using BytesLib for bytes;

    uint8 internal constant WORKER_ID = 2;
    uint8 internal constant OPTION_TYPE_PRECRIME = 1;

    error DVN_InvalidDVNIdx();
    error DVN_InvalidDVNOptions(uint256 cursor);

    /// @dev group dvn options by its idx
    /// @param _options [dvn_id][dvn_option][dvn_id][dvn_option]...
    ///        dvn_option = [option_size][dvn_idx][option_type][option]
    ///        option_size = len(dvn_idx) + len(option_type) + len(option)
    ///        dvn_id: uint8, dvn_idx: uint8, option_size: uint16, option_type: uint8, option: bytes
    /// @return dvnOptions the grouped options, still share the same format of _options
    /// @return dvnIndices the dvn indices
    function groupDVNOptionsByIdx(
        bytes memory _options
    ) internal pure returns (bytes[] memory dvnOptions, uint8[] memory dvnIndices) {
        if (_options.length == 0) return (dvnOptions, dvnIndices);

        uint8 numDVNs = getNumDVNs(_options);

        // if there is only 1 dvn, we can just return the whole options
        if (numDVNs == 1) {
            dvnOptions = new bytes[](1);
            dvnOptions[0] = _options;

            dvnIndices = new uint8[](1);
            dvnIndices[0] = _options.toUint8(3); // dvn idx
            return (dvnOptions, dvnIndices);
        }

        // otherwise, we need to group the options by dvn_idx
        dvnIndices = new uint8[](numDVNs);
        dvnOptions = new bytes[](numDVNs);
        unchecked {
            uint256 cursor = 0;
            uint256 start = 0;
            uint8 lastDVNIdx = 255; // 255 is an invalid dvn_idx

            while (cursor < _options.length) {
                ++cursor; // skip worker_id

                // optionLength asserted in getNumDVNs (skip check)
                uint16 optionLength = _options.toUint16(cursor);
                cursor += 2;

                // dvnIdx asserted in getNumDVNs (skip check)
                uint8 dvnIdx = _options.toUint8(cursor);

                // dvnIdx must equal to the lastDVNIdx for the first option
                // so it is always skipped in the first option
                // this operation slices out options whenever the scan finds a different lastDVNIdx
                if (lastDVNIdx == 255) {
                    lastDVNIdx = dvnIdx;
                } else if (dvnIdx != lastDVNIdx) {
                    uint256 len = cursor - start - 3; // 3 is for worker_id and option_length
                    bytes memory opt = _options.slice(start, len);
                    _insertDVNOptions(dvnOptions, dvnIndices, lastDVNIdx, opt);

                    // reset the start and lastDVNIdx
                    start += len;
                    lastDVNIdx = dvnIdx;
                }

                cursor += optionLength;
            }

            // skip check the cursor here because the cursor is asserted in getNumDVNs
            // if we have reached the end of the options, we need to process the last dvn
            uint256 size = cursor - start;
            bytes memory op = _options.slice(start, size);
            _insertDVNOptions(dvnOptions, dvnIndices, lastDVNIdx, op);

            // revert dvnIndices to start from 0
            for (uint8 i = 0; i < numDVNs; ++i) {
                --dvnIndices[i];
            }
        }
    }

    function _insertDVNOptions(
        bytes[] memory _dvnOptions,
        uint8[] memory _dvnIndices,
        uint8 _dvnIdx,
        bytes memory _newOptions
    ) internal pure {
        // dvnIdx starts from 0 but default value of dvnIndices is 0,
        // so we tell if the slot is empty by adding 1 to dvnIdx
        if (_dvnIdx == 255) revert DVN_InvalidDVNIdx();
        uint8 dvnIdxAdj = _dvnIdx + 1;

        for (uint256 j = 0; j < _dvnIndices.length; ++j) {
            uint8 index = _dvnIndices[j];
            if (dvnIdxAdj == index) {
                _dvnOptions[j] = abi.encodePacked(_dvnOptions[j], _newOptions);
                break;
            } else if (index == 0) {
                // empty slot, that means it is the first time we see this dvn
                _dvnIndices[j] = dvnIdxAdj;
                _dvnOptions[j] = _newOptions;
                break;
            }
        }
    }

    /// @dev get the number of unique dvns
    /// @param _options the format is the same as groupDVNOptionsByIdx
    function getNumDVNs(bytes memory _options) internal pure returns (uint8 numDVNs) {
        uint256 cursor = 0;
        BitMap256 bitmap;

        // find number of unique dvn_idx
        unchecked {
            while (cursor < _options.length) {
                ++cursor; // skip worker_id

                uint16 optionLength = _options.toUint16(cursor);
                cursor += 2;
                if (optionLength < 2) revert DVN_InvalidDVNOptions(cursor); // at least 1 byte for dvn_idx and 1 byte for option_type

                uint8 dvnIdx = _options.toUint8(cursor);

                // if dvnIdx is not set, increment numDVNs
                // max num of dvns is 255, 255 is an invalid dvn_idx
                // The order of the dvnIdx is not required to be sequential, as enforcing the order may weaken
                // the composability of the options. e.g. if we refrain from enforcing the order, an OApp that has
                // already enforced certain options can append additional options to the end of the enforced
                // ones without restrictions.
                if (dvnIdx == 255) revert DVN_InvalidDVNIdx();
                if (!bitmap.get(dvnIdx)) {
                    ++numDVNs;
                    bitmap = bitmap.set(dvnIdx);
                }

                cursor += optionLength;
            }
        }
        if (cursor != _options.length) revert DVN_InvalidDVNOptions(cursor);
    }

    /// @dev decode the next dvn option from _options starting from the specified cursor
    /// @param _options the format is the same as groupDVNOptionsByIdx
    /// @param _cursor the cursor to start decoding
    /// @return optionType the type of the option
    /// @return option the option
    /// @return cursor the cursor to start decoding the next option
    function nextDVNOption(
        bytes calldata _options,
        uint256 _cursor
    ) internal pure returns (uint8 optionType, bytes calldata option, uint256 cursor) {
        unchecked {
            // skip worker id
            cursor = _cursor + 1;

            // read option size
            uint16 size = _options.toU16(cursor);
            cursor += 2;

            // read option type
            optionType = _options.toU8(cursor + 1); // skip dvn_idx

            // startCursor and endCursor are used to slice the option from _options
            uint256 startCursor = cursor + 2; // skip option type and dvn_idx
            uint256 endCursor = cursor + size;
            option = _options[startCursor:endCursor];
            cursor += size;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IOAppCore, ILayerZeroEndpointV2 } from "./interfaces/IOAppCore.sol";

/**
 * @title OAppCore
 * @dev Abstract contract implementing the IOAppCore interface with basic OApp configurations.
 */
abstract contract OAppCore is IOAppCore, Ownable {
    // The LayerZero endpoint associated with the given OApp
    ILayerZeroEndpointV2 public immutable endpoint;

    // Mapping to store peers associated with corresponding endpoints
    mapping(uint32 eid => bytes32 peer) public peers;

    /**
     * @dev Constructor to initialize the OAppCore with the provided endpoint and delegate.
     * @param _endpoint The address of the LOCAL Layer Zero endpoint.
     * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
     *
     * @dev The delegate typically should be set as the owner of the contract.
     */
    constructor(address _endpoint, address _delegate) {
        endpoint = ILayerZeroEndpointV2(_endpoint);

        if (_delegate == address(0)) revert InvalidDelegate();
        endpoint.setDelegate(_delegate);
    }

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Indicates that the peer is trusted to send LayerZero messages to this OApp.
     * @dev Set this to bytes32(0) to remove the peer address.
     * @dev Peer is a bytes32 to accommodate non-evm chains.
     */
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {
        _setPeer(_eid, _peer);
    }

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     *
     * @dev Indicates that the peer is trusted to send LayerZero messages to this OApp.
     * @dev Set this to bytes32(0) to remove the peer address.
     * @dev Peer is a bytes32 to accommodate non-evm chains.
     */
    function _setPeer(uint32 _eid, bytes32 _peer) internal virtual {
        peers[_eid] = _peer;
        emit PeerSet(_eid, _peer);
    }

    /**
     * @notice Internal function to get the peer address associated with a specific endpoint; reverts if NOT set.
     * ie. the peer is set to bytes32(0).
     * @param _eid The endpoint ID.
     * @return peer The address of the peer associated with the specified endpoint.
     */
    function _getPeerOrRevert(uint32 _eid) internal view virtual returns (bytes32) {
        bytes32 peer = peers[_eid];
        if (peer == bytes32(0)) revert NoPeer(_eid);
        return peer;
    }

    /**
     * @notice Sets the delegate address for the OApp.
     * @param _delegate The address of the delegate to be set.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Provides the ability for a delegate to set configs, on behalf of the OApp, directly on the Endpoint contract.
     */
    function setDelegate(address _delegate) public onlyOwner {
        endpoint.setDelegate(_delegate);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MessagingParams, MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { OAppCore } from "./OAppCore.sol";

/**
 * @title OAppSender
 * @dev Abstract contract implementing the OAppSender functionality for sending messages to a LayerZero endpoint.
 */
abstract contract OAppSender is OAppCore {
    using SafeERC20 for IERC20;

    // Custom error messages
    error NotEnoughNative(uint256 msgValue);
    error LzTokenUnavailable();

    // @dev The version of the OAppSender implementation.
    // @dev Version is bumped when changes are made to this contract.
    uint64 internal constant SENDER_VERSION = 1;

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol contract.
     * @return receiverVersion The version of the OAppReceiver.sol contract.
     *
     * @dev Providing 0 as the default for OAppReceiver version. Indicates that the OAppReceiver is not implemented.
     * ie. this is a SEND only OApp.
     * @dev If the OApp uses both OAppSender and OAppReceiver, then this needs to be override returning the correct versions
     */
    function oAppVersion() public view virtual returns (uint64 senderVersion, uint64 receiverVersion) {
        return (SENDER_VERSION, 0);
    }

    /**
     * @dev Internal function to interact with the LayerZero EndpointV2.quote() for fee calculation.
     * @param _dstEid The destination endpoint ID.
     * @param _message The message payload.
     * @param _options Additional options for the message.
     * @param _payInLzToken Flag indicating whether to pay the fee in LZ tokens.
     * @return fee The calculated MessagingFee for the message.
     *      - nativeFee: The native fee for the message.
     *      - lzTokenFee: The LZ token fee for the message.
     */
    function _quote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payInLzToken
    ) internal view virtual returns (MessagingFee memory fee) {
        return
            endpoint.quote(
                MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _payInLzToken),
                address(this)
            );
    }

    /**
     * @dev Internal function to interact with the LayerZero EndpointV2.send() for sending a message.
     * @param _dstEid The destination endpoint ID.
     * @param _message The message payload.
     * @param _options Additional options for the message.
     * @param _fee The calculated LayerZero fee for the message.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @param _refundAddress The address to receive any excess fee values sent to the endpoint.
     * @return receipt The receipt for the sent message.
     *      - guid: The unique identifier for the sent message.
     *      - nonce: The nonce of the sent message.
     *      - fee: The LayerZero fee incurred for the message.
     */
    function _lzSend(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        MessagingFee memory _fee,
        address _refundAddress
    ) internal virtual returns (MessagingReceipt memory receipt) {
        // @dev Push corresponding fees to the endpoint, any excess is sent back to the _refundAddress from the endpoint.
        uint256 messageValue = _payNative(_fee.nativeFee);
        if (_fee.lzTokenFee > 0) _payLzToken(_fee.lzTokenFee);

        return
            // solhint-disable-next-line check-send-result
            endpoint.send{ value: messageValue }(
                MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _fee.lzTokenFee > 0),
                _refundAddress
            );
    }

    /**
     * @dev Internal function to pay the native fee associated with the message.
     * @param _nativeFee The native fee to be paid.
     * @return nativeFee The amount of native currency paid.
     *
     * @dev If the OApp needs to initiate MULTIPLE LayerZero messages in a single transaction,
     * this will need to be overridden because msg.value would contain multiple lzFees.
     * @dev Should be overridden in the event the LayerZero endpoint requires a different native currency.
     * @dev Some EVMs use an ERC20 as a method for paying transactions/gasFees.
     * @dev The endpoint is EITHER/OR, ie. it will NOT support both types of native payment at a time.
     */
    function _payNative(uint256 _nativeFee) internal virtual returns (uint256 nativeFee) {
        if (msg.value != _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }

    /**
     * @dev Internal function to pay the LZ token fee associated with the message.
     * @param _lzTokenFee The LZ token fee to be paid.
     *
     * @dev If the caller is trying to pay in the specified lzToken, then the lzTokenFee is passed to the endpoint.
     * @dev Any excess sent, is passed back to the specified _refundAddress in the _lzSend().
     */
    function _payLzToken(uint256 _lzTokenFee) internal virtual {
        // @dev Cannot cache the token because it is not immutable in the endpoint.
        address lzToken = endpoint.lzToken();
        if (lzToken == address(0)) revert LzTokenUnavailable();

        // Pay LZ token fee by sending tokens to the endpoint.
        IERC20(lzToken).safeTransferFrom(msg.sender, address(endpoint), _lzTokenFee);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

/**
 * @title IOAppCore
 */
interface IOAppCore {
    // Custom error messages
    error OnlyPeer(uint32 eid, bytes32 sender);
    error NoPeer(uint32 eid);
    error InvalidEndpointCall();
    error InvalidDelegate();

    // Event emitted when a peer (OApp) is set for a corresponding endpoint
    event PeerSet(uint32 eid, bytes32 peer);

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol contract.
     * @return receiverVersion The version of the OAppReceiver.sol contract.
     */
    function oAppVersion() external view returns (uint64 senderVersion, uint64 receiverVersion);

    /**
     * @notice Retrieves the LayerZero endpoint associated with the OApp.
     * @return iEndpoint The LayerZero endpoint as an interface.
     */
    function endpoint() external view returns (ILayerZeroEndpointV2 iEndpoint);

    /**
     * @notice Retrieves the peer (OApp) associated with a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @return peer The peer address (OApp instance) associated with the corresponding endpoint.
     */
    function peers(uint32 _eid) external view returns (bytes32 peer);

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     */
    function setPeer(uint32 _eid, bytes32 _peer) external;

    /**
     * @notice Sets the delegate address for the OApp Core.
     * @param _delegate The address of the delegate to be set.
     */
    function setDelegate(address _delegate) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { BytesLib } from "solidity-bytes-utils/contracts/BytesLib.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import { ExecutorOptions } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/ExecutorOptions.sol";
import { DVNOptions } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/libs/DVNOptions.sol";

/**
 * @title OptionsBuilder
 * @dev Library for building and encoding various message options.
 */
library OptionsBuilder {
    using SafeCast for uint256;
    using BytesLib for bytes;

    // Constants for options types
    uint16 internal constant TYPE_1 = 1; // legacy options type 1
    uint16 internal constant TYPE_2 = 2; // legacy options type 2
    uint16 internal constant TYPE_3 = 3;

    // Custom error message
    error InvalidSize(uint256 max, uint256 actual);
    error InvalidOptionType(uint16 optionType);

    // Modifier to ensure only options of type 3 are used
    modifier onlyType3(bytes memory _options) {
        if (_options.toUint16(0) != TYPE_3) revert InvalidOptionType(_options.toUint16(0));
        _;
    }

    /**
     * @dev Creates a new options container with type 3.
     * @return options The newly created options container.
     */
    function newOptions() internal pure returns (bytes memory) {
        return abi.encodePacked(TYPE_3);
    }

    /**
     * @dev Adds an executor LZ receive option to the existing options.
     * @param _options The existing options container.
     * @param _gas The gasLimit used on the lzReceive() function in the OApp.
     * @param _value The msg.value passed to the lzReceive() function in the OApp.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed by the executor
     * eg. if (_gas: 200k, and _value: 1 ether) AND (_gas: 100k, _value: 0.5 ether) are sent in an option to the LayerZeroEndpoint,
     * that becomes (300k, 1.5 ether) when the message is executed on the remote lzReceive() function.
     */
    function addExecutorLzReceiveOption(
        bytes memory _options,
        uint128 _gas,
        uint128 _value
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeLzReceiveOption(_gas, _value);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_LZRECEIVE, option);
    }

    /**
     * @dev Adds an executor native drop option to the existing options.
     * @param _options The existing options container.
     * @param _amount The amount for the native value that is airdropped to the 'receiver'.
     * @param _receiver The receiver address for the native drop option.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed by the executor on the remote chain.
     */
    function addExecutorNativeDropOption(
        bytes memory _options,
        uint128 _amount,
        bytes32 _receiver
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeNativeDropOption(_amount, _receiver);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_NATIVE_DROP, option);
    }

    /**
     * @dev Adds an executor LZ compose option to the existing options.
     * @param _options The existing options container.
     * @param _index The index for the lzCompose() function call.
     * @param _gas The gasLimit for the lzCompose() function call.
     * @param _value The msg.value for the lzCompose() function call.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed PER index by the executor on the remote chain.
     * @dev If the OApp sends N lzCompose calls on the remote, you must provide N incremented indexes starting with 0.
     * ie. When your remote OApp composes (N = 3) messages, you must set this option for index 0,1,2
     */
    function addExecutorLzComposeOption(
        bytes memory _options,
        uint16 _index,
        uint128 _gas,
        uint128 _value
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeLzComposeOption(_index, _gas, _value);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_LZCOMPOSE, option);
    }

    /**
     * @dev Adds an executor ordered execution option to the existing options.
     * @param _options The existing options container.
     * @return options The updated options container.
     */
    function addExecutorOrderedExecutionOption(
        bytes memory _options
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_ORDERED_EXECUTION, bytes(""));
    }

    /**
     * @dev Adds a DVN pre-crime option to the existing options.
     * @param _options The existing options container.
     * @param _dvnIdx The DVN index for the pre-crime option.
     * @return options The updated options container.
     */
    function addDVNPreCrimeOption(
        bytes memory _options,
        uint8 _dvnIdx
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return addDVNOption(_options, _dvnIdx, DVNOptions.OPTION_TYPE_PRECRIME, bytes(""));
    }

    /**
     * @dev Adds an executor option to the existing options.
     * @param _options The existing options container.
     * @param _optionType The type of the executor option.
     * @param _option The encoded data for the executor option.
     * @return options The updated options container.
     */
    function addExecutorOption(
        bytes memory _options,
        uint8 _optionType,
        bytes memory _option
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return
            abi.encodePacked(
                _options,
                ExecutorOptions.WORKER_ID,
                _option.length.toUint16() + 1, // +1 for optionType
                _optionType,
                _option
            );
    }

    /**
     * @dev Adds a DVN option to the existing options.
     * @param _options The existing options container.
     * @param _dvnIdx The DVN index for the DVN option.
     * @param _optionType The type of the DVN option.
     * @param _option The encoded data for the DVN option.
     * @return options The updated options container.
     */
    function addDVNOption(
        bytes memory _options,
        uint8 _dvnIdx,
        uint8 _optionType,
        bytes memory _option
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return
            abi.encodePacked(
                _options,
                DVNOptions.WORKER_ID,
                _option.length.toUint16() + 2, // +2 for optionType and dvnIdx
                _dvnIdx,
                _optionType,
                _option
            );
    }

    /**
     * @dev Encodes legacy options of type 1.
     * @param _executionGas The gasLimit value passed to lzReceive().
     * @return legacyOptions The encoded legacy options.
     */
    function encodeLegacyOptionsType1(uint256 _executionGas) internal pure returns (bytes memory) {
        if (_executionGas > type(uint128).max) revert InvalidSize(type(uint128).max, _executionGas);
        return abi.encodePacked(TYPE_1, _executionGas);
    }

    /**
     * @dev Encodes legacy options of type 2.
     * @param _executionGas The gasLimit value passed to lzReceive().
     * @param _nativeForDst The amount of native air dropped to the receiver.
     * @param _receiver The _nativeForDst receiver address.
     * @return legacyOptions The encoded legacy options of type 2.
     */
    function encodeLegacyOptionsType2(
        uint256 _executionGas,
        uint256 _nativeForDst,
        bytes memory _receiver // @dev Use bytes instead of bytes32 in legacy type 2 for _receiver.
    ) internal pure returns (bytes memory) {
        if (_executionGas > type(uint128).max) revert InvalidSize(type(uint128).max, _executionGas);
        if (_nativeForDst > type(uint128).max) revert InvalidSize(type(uint128).max, _nativeForDst);
        if (_receiver.length > 32) revert InvalidSize(32, _receiver.length);
        return abi.encodePacked(TYPE_2, _executionGas, _nativeForDst, _receiver);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { MessagingReceipt, MessagingFee } from "../../oapp/OAppSender.sol";

/**
 * @dev Struct representing token parameters for the OFT send() operation.
 */
struct SendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

/**
 * @dev Struct representing OFT limit information.
 * @dev These amounts can change dynamically and are up the the specific oft implementation.
 */
struct OFTLimit {
    uint256 minAmountLD; // Minimum amount in local decimals that can be sent to the recipient.
    uint256 maxAmountLD; // Maximum amount in local decimals that can be sent to the recipient.
}

/**
 * @dev Struct representing OFT receipt information.
 */
struct OFTReceipt {
    uint256 amountSentLD; // Amount of tokens ACTUALLY debited from the sender in local decimals.
    // @dev In non-default implementations, the amountReceivedLD COULD differ from this value.
    uint256 amountReceivedLD; // Amount of tokens to be received on the remote side.
}

/**
 * @dev Struct representing OFT fee details.
 * @dev Future proof mechanism to provide a standardized way to communicate fees to things like a UI.
 */
struct OFTFeeDetail {
    int256 feeAmountLD; // Amount of the fee in local decimals.
    string description; // Description of the fee.
}

/**
 * @title IOFT
 * @dev Interface for the OftChain (OFT) token.
 * @dev Does not inherit ERC20 to accommodate usage by OFTAdapter as well.
 * @dev This specific interface ID is '0x02e49c2c'.
 */
interface IOFT {
    // Custom error messages
    error InvalidLocalDecimals();
    error SlippageExceeded(uint256 amountLD, uint256 minAmountLD);

    // Events
    event OFTSent(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 dstEid, // Destination Endpoint ID.
        address indexed fromAddress, // Address of the sender on the src chain.
        uint256 amountSentLD, // Amount of tokens sent in local decimals.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );
    event OFTReceived(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 srcEid, // Source Endpoint ID.
        address indexed toAddress, // Address of the recipient on the dst chain.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );

    /**
     * @notice Retrieves interfaceID and the version of the OFT.
     * @return interfaceId The interface ID.
     * @return version The version.
     *
     * @dev interfaceId: This specific interface ID is '0x02e49c2c'.
     * @dev version: Indicates a cross-chain compatible msg encoding with other OFTs.
     * @dev If a new feature is added to the OFT cross-chain msg encoding, the version will be incremented.
     * ie. localOFT version(x,1) CAN send messages to remoteOFT version(x,1)
     */
    function oftVersion() external view returns (bytes4 interfaceId, uint64 version);

    /**
     * @notice Retrieves the address of the token associated with the OFT.
     * @return token The address of the ERC20 token implementation.
     */
    function token() external view returns (address);

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev Allows things like wallet implementers to determine integration requirements,
     * without understanding the underlying token implementation.
     */
    function approvalRequired() external view returns (bool);

    /**
     * @notice Retrieves the shared decimals of the OFT.
     * @return sharedDecimals The shared decimals of the OFT.
     */
    function sharedDecimals() external view returns (uint8);

    /**
     * @notice Provides a quote for OFT-related operations.
     * @param _sendParam The parameters for the send operation.
     * @return limit The OFT limit information.
     * @return oftFeeDetails The details of OFT fees.
     * @return receipt The OFT receipt information.
     */
    function quoteOFT(
        SendParam calldata _sendParam
    ) external view returns (OFTLimit memory, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory);

    /**
     * @notice Provides a quote for the send() operation.
     * @param _sendParam The parameters for the send() operation.
     * @param _payInLzToken Flag indicating whether the caller is paying in the LZ token.
     * @return fee The calculated LayerZero messaging fee from the send() operation.
     *
     * @dev MessagingFee: LayerZero msg fee
     *  - nativeFee: The native fee.
     *  - lzTokenFee: The lzToken fee.
     */
    function quoteSend(SendParam calldata _sendParam, bool _payInLzToken) external view returns (MessagingFee memory);

    /**
     * @notice Executes the send() operation.
     * @param _sendParam The parameters for the send operation.
     * @param _fee The fee information supplied by the caller.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @param _refundAddress The address to receive any excess funds from fees etc. on the src.
     * @return receipt The LayerZero messaging receipt from the send() operation.
     * @return oftReceipt The OFT receipt information.
     *
     * @dev MessagingReceipt: LayerZero msg receipt
     *  - guid: The unique identifier for the sent message.
     *  - nonce: The nonce of the sent message.
     *  - fee: The LayerZero fee incurred for the message.
     */
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory, OFTReceipt memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library OFTComposeMsgCodec {
    // Offset constants for decoding composed messages
    uint8 private constant NONCE_OFFSET = 8;
    uint8 private constant SRC_EID_OFFSET = 12;
    uint8 private constant AMOUNT_LD_OFFSET = 44;
    uint8 private constant COMPOSE_FROM_OFFSET = 76;

    /**
     * @dev Encodes a OFT composed message.
     * @param _nonce The nonce value.
     * @param _srcEid The source endpoint ID.
     * @param _amountLD The amount in local decimals.
     * @param _composeMsg The composed message.
     * @return _msg The encoded Composed message.
     */
    function encode(
        uint64 _nonce,
        uint32 _srcEid,
        uint256 _amountLD,
        bytes memory _composeMsg // 0x[composeFrom][composeMsg]
    ) internal pure returns (bytes memory _msg) {
        _msg = abi.encodePacked(_nonce, _srcEid, _amountLD, _composeMsg);
    }

    /**
     * @dev Retrieves the nonce from the composed message.
     * @param _msg The message.
     * @return The nonce value.
     */
    function nonce(bytes calldata _msg) internal pure returns (uint64) {
        return uint64(bytes8(_msg[:NONCE_OFFSET]));
    }

    /**
     * @dev Retrieves the source endpoint ID from the composed message.
     * @param _msg The message.
     * @return The source endpoint ID.
     */
    function srcEid(bytes calldata _msg) internal pure returns (uint32) {
        return uint32(bytes4(_msg[NONCE_OFFSET:SRC_EID_OFFSET]));
    }

    /**
     * @dev Retrieves the amount in local decimals from the composed message.
     * @param _msg The message.
     * @return The amount in local decimals.
     */
    function amountLD(bytes calldata _msg) internal pure returns (uint256) {
        return uint256(bytes32(_msg[SRC_EID_OFFSET:AMOUNT_LD_OFFSET]));
    }

    /**
     * @dev Retrieves the composeFrom value from the composed message.
     * @param _msg The message.
     * @return The composeFrom value.
     */
    function composeFrom(bytes calldata _msg) internal pure returns (bytes32) {
        return bytes32(_msg[AMOUNT_LD_OFFSET:COMPOSE_FROM_OFFSET]);
    }

    /**
     * @dev Retrieves the composed message.
     * @param _msg The message.
     * @return The composed message.
     */
    function composeMsg(bytes calldata _msg) internal pure returns (bytes memory) {
        return _msg[COMPOSE_FROM_OFFSET:];
    }

    /**
     * @dev Converts an address to bytes32.
     * @param _addr The address to convert.
     * @return The bytes32 representation of the address.
     */
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /**
     * @dev Converts bytes32 to an address.
     * @param _b The bytes32 value to convert.
     * @return The address representation of bytes32.
     */
    function bytes32ToAddress(bytes32 _b) internal pure returns (address) {
        return address(uint160(uint256(_b)));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/**
 * @title ILayerZeroComposer
 */
interface ILayerZeroComposer {
    /**
     * @notice Composes a LayerZero message from an OApp.
     * @dev To ensure non-reentrancy, implementers of this interface MUST assert msg.sender is the corresponding EndpointV2 contract (i.e., onlyEndpointV2).
     * @param _from The address initiating the composition, typically the OApp where the lzReceive was called.
     * @param _guid The unique identifier for the corresponding LayerZero src/dst tx.
     * @param _message The composed message payload in bytes. NOT necessarily the same payload passed via lzReceive.
     * @param _executor The address of the executor for the composed message.
     * @param _extraData Additional arbitrary data in bytes passed by the entity who executes the lzCompose.
     */
    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { IMessageLibManager } from "./IMessageLibManager.sol";
import { IMessagingComposer } from "./IMessagingComposer.sol";
import { IMessagingChannel } from "./IMessagingChannel.sol";
import { IMessagingContext } from "./IMessagingContext.sol";

struct MessagingParams {
    uint32 dstEid;
    bytes32 receiver;
    bytes message;
    bytes options;
    bool payInLzToken;
}

struct MessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MessagingFee fee;
}

struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

struct Origin {
    uint32 srcEid;
    bytes32 sender;
    uint64 nonce;
}

interface ILayerZeroEndpointV2 is IMessageLibManager, IMessagingComposer, IMessagingChannel, IMessagingContext {
    event PacketSent(bytes encodedPayload, bytes options, address sendLibrary);

    event PacketVerified(Origin origin, address receiver, bytes32 payloadHash);

    event PacketDelivered(Origin origin, address receiver);

    event LzReceiveAlert(
        address indexed receiver,
        address indexed executor,
        Origin origin,
        bytes32 guid,
        uint256 gas,
        uint256 value,
        bytes message,
        bytes extraData,
        bytes reason
    );

    event LzTokenSet(address token);

    event DelegateSet(address sender, address delegate);

    function quote(MessagingParams calldata _params, address _sender) external view returns (MessagingFee memory);

    function send(
        MessagingParams calldata _params,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory);

    function verify(Origin calldata _origin, address _receiver, bytes32 _payloadHash) external;

    function verifiable(Origin calldata _origin, address _receiver) external view returns (bool);

    function initializable(Origin calldata _origin, address _receiver) external view returns (bool);

    function lzReceive(
        Origin calldata _origin,
        address _receiver,
        bytes32 _guid,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable;

    // oapp can burn messages partially by calling this function with its own business logic if messages are verified in order
    function clear(address _oapp, Origin calldata _origin, bytes32 _guid, bytes calldata _message) external;

    function setLzToken(address _lzToken) external;

    function lzToken() external view returns (address);

    function nativeToken() external view returns (address);

    function setDelegate(address _delegate) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

struct SetConfigParam {
    uint32 eid;
    uint32 configType;
    bytes config;
}

interface IMessageLibManager {
    struct Timeout {
        address lib;
        uint256 expiry;
    }

    event LibraryRegistered(address newLib);
    event DefaultSendLibrarySet(uint32 eid, address newLib);
    event DefaultReceiveLibrarySet(uint32 eid, address newLib);
    event DefaultReceiveLibraryTimeoutSet(uint32 eid, address oldLib, uint256 expiry);
    event SendLibrarySet(address sender, uint32 eid, address newLib);
    event ReceiveLibrarySet(address receiver, uint32 eid, address newLib);
    event ReceiveLibraryTimeoutSet(address receiver, uint32 eid, address oldLib, uint256 timeout);

    function registerLibrary(address _lib) external;

    function isRegisteredLibrary(address _lib) external view returns (bool);

    function getRegisteredLibraries() external view returns (address[] memory);

    function setDefaultSendLibrary(uint32 _eid, address _newLib) external;

    function defaultSendLibrary(uint32 _eid) external view returns (address);

    function setDefaultReceiveLibrary(uint32 _eid, address _newLib, uint256 _gracePeriod) external;

    function defaultReceiveLibrary(uint32 _eid) external view returns (address);

    function setDefaultReceiveLibraryTimeout(uint32 _eid, address _lib, uint256 _expiry) external;

    function defaultReceiveLibraryTimeout(uint32 _eid) external view returns (address lib, uint256 expiry);

    function isSupportedEid(uint32 _eid) external view returns (bool);

    function isValidReceiveLibrary(address _receiver, uint32 _eid, address _lib) external view returns (bool);

    /// ------------------- OApp interfaces -------------------
    function setSendLibrary(address _oapp, uint32 _eid, address _newLib) external;

    function getSendLibrary(address _sender, uint32 _eid) external view returns (address lib);

    function isDefaultSendLibrary(address _sender, uint32 _eid) external view returns (bool);

    function setReceiveLibrary(address _oapp, uint32 _eid, address _newLib, uint256 _gracePeriod) external;

    function getReceiveLibrary(address _receiver, uint32 _eid) external view returns (address lib, bool isDefault);

    function setReceiveLibraryTimeout(address _oapp, uint32 _eid, address _lib, uint256 _expiry) external;

    function receiveLibraryTimeout(address _receiver, uint32 _eid) external view returns (address lib, uint256 expiry);

    function setConfig(address _oapp, address _lib, SetConfigParam[] calldata _params) external;

    function getConfig(
        address _oapp,
        address _lib,
        uint32 _eid,
        uint32 _configType
    ) external view returns (bytes memory config);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IMessagingChannel {
    event InboundNonceSkipped(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce);
    event PacketNilified(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce, bytes32 payloadHash);
    event PacketBurnt(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce, bytes32 payloadHash);

    function eid() external view returns (uint32);

    // this is an emergency function if a message cannot be verified for some reasons
    // required to provide _nextNonce to avoid race condition
    function skip(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce) external;

    function nilify(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external;

    function burn(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external;

    function nextGuid(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (bytes32);

    function inboundNonce(address _receiver, uint32 _srcEid, bytes32 _sender) external view returns (uint64);

    function outboundNonce(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (uint64);

    function inboundPayloadHash(
        address _receiver,
        uint32 _srcEid,
        bytes32 _sender,
        uint64 _nonce
    ) external view returns (bytes32);

    function lazyInboundNonce(address _receiver, uint32 _srcEid, bytes32 _sender) external view returns (uint64);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IMessagingComposer {
    event ComposeSent(address from, address to, bytes32 guid, uint16 index, bytes message);
    event ComposeDelivered(address from, address to, bytes32 guid, uint16 index);
    event LzComposeAlert(
        address indexed from,
        address indexed to,
        address indexed executor,
        bytes32 guid,
        uint16 index,
        uint256 gas,
        uint256 value,
        bytes message,
        bytes extraData,
        bytes reason
    );

    function composeQueue(
        address _from,
        address _to,
        bytes32 _guid,
        uint16 _index
    ) external view returns (bytes32 messageHash);

    function sendCompose(address _to, bytes32 _guid, uint16 _index, bytes calldata _message) external;

    function lzCompose(
        address _from,
        address _to,
        bytes32 _guid,
        uint16 _index,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IMessagingContext {
    function isSendingMessage() external view returns (bool);

    function getSendContext() external view returns (uint32 dstEid, address sender);
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

library CalldataBytesLib {
    function toU8(bytes calldata _bytes, uint256 _start) internal pure returns (uint8) {
        return uint8(_bytes[_start]);
    }

    function toU16(bytes calldata _bytes, uint256 _start) internal pure returns (uint16) {
        unchecked {
            uint256 end = _start + 2;
            return uint16(bytes2(_bytes[_start:end]));
        }
    }

    function toU32(bytes calldata _bytes, uint256 _start) internal pure returns (uint32) {
        unchecked {
            uint256 end = _start + 4;
            return uint32(bytes4(_bytes[_start:end]));
        }
    }

    function toU64(bytes calldata _bytes, uint256 _start) internal pure returns (uint64) {
        unchecked {
            uint256 end = _start + 8;
            return uint64(bytes8(_bytes[_start:end]));
        }
    }

    function toU128(bytes calldata _bytes, uint256 _start) internal pure returns (uint128) {
        unchecked {
            uint256 end = _start + 16;
            return uint128(bytes16(_bytes[_start:end]));
        }
    }

    function toU256(bytes calldata _bytes, uint256 _start) internal pure returns (uint256) {
        unchecked {
            uint256 end = _start + 32;
            return uint256(bytes32(_bytes[_start:end]));
        }
    }

    function toAddr(bytes calldata _bytes, uint256 _start) internal pure returns (address) {
        unchecked {
            uint256 end = _start + 20;
            return address(bytes20(_bytes[_start:end]));
        }
    }

    function toB32(bytes calldata _bytes, uint256 _start) internal pure returns (bytes32) {
        unchecked {
            uint256 end = _start + 32;
            return bytes32(_bytes[_start:end]);
        }
    }
}
// SPDX-License-Identifier: MIT

// modified from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol
pragma solidity ^0.8.20;

type BitMap256 is uint256;

using BitMaps for BitMap256 global;

library BitMaps {
    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap256 bitmap, uint8 index) internal pure returns (bool) {
        uint256 mask = 1 << index;
        return BitMap256.unwrap(bitmap) & mask != 0;
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap256 bitmap, uint8 index) internal pure returns (BitMap256) {
        uint256 mask = 1 << index;
        return BitMap256.wrap(BitMap256.unwrap(bitmap) | mask);
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { CalldataBytesLib } from "../../libs/CalldataBytesLib.sol";

library ExecutorOptions {
    using CalldataBytesLib for bytes;

    uint8 internal constant WORKER_ID = 1;

    uint8 internal constant OPTION_TYPE_LZRECEIVE = 1;
    uint8 internal constant OPTION_TYPE_NATIVE_DROP = 2;
    uint8 internal constant OPTION_TYPE_LZCOMPOSE = 3;
    uint8 internal constant OPTION_TYPE_ORDERED_EXECUTION = 4;

    error Executor_InvalidLzReceiveOption();
    error Executor_InvalidNativeDropOption();
    error Executor_InvalidLzComposeOption();

    /// @dev decode the next executor option from the options starting from the specified cursor
    /// @param _options [executor_id][executor_option][executor_id][executor_option]...
    ///        executor_option = [option_size][option_type][option]
    ///        option_size = len(option_type) + len(option)
    ///        executor_id: uint8, option_size: uint16, option_type: uint8, option: bytes
    /// @param _cursor the cursor to start decoding from
    /// @return optionType the type of the option
    /// @return option the option of the executor
    /// @return cursor the cursor to start decoding the next executor option
    function nextExecutorOption(
        bytes calldata _options,
        uint256 _cursor
    ) internal pure returns (uint8 optionType, bytes calldata option, uint256 cursor) {
        unchecked {
            // skip worker id
            cursor = _cursor + 1;

            // read option size
            uint16 size = _options.toU16(cursor);
            cursor += 2;

            // read option type
            optionType = _options.toU8(cursor);

            // startCursor and endCursor are used to slice the option from _options
            uint256 startCursor = cursor + 1; // skip option type
            uint256 endCursor = cursor + size;
            option = _options[startCursor:endCursor];
            cursor += size;
        }
    }

    function decodeLzReceiveOption(bytes calldata _option) internal pure returns (uint128 gas, uint128 value) {
        if (_option.length != 16 && _option.length != 32) revert Executor_InvalidLzReceiveOption();
        gas = _option.toU128(0);
        value = _option.length == 32 ? _option.toU128(16) : 0;
    }

    function decodeNativeDropOption(bytes calldata _option) internal pure returns (uint128 amount, bytes32 receiver) {
        if (_option.length != 48) revert Executor_InvalidNativeDropOption();
        amount = _option.toU128(0);
        receiver = _option.toB32(16);
    }

    function decodeLzComposeOption(
        bytes calldata _option
    ) internal pure returns (uint16 index, uint128 gas, uint128 value) {
        if (_option.length != 18 && _option.length != 34) revert Executor_InvalidLzComposeOption();
        index = _option.toU16(0);
        gas = _option.toU128(2);
        value = _option.length == 34 ? _option.toU128(18) : 0;
    }

    function encodeLzReceiveOption(uint128 _gas, uint128 _value) internal pure returns (bytes memory) {
        return _value == 0 ? abi.encodePacked(_gas) : abi.encodePacked(_gas, _value);
    }

    function encodeNativeDropOption(uint128 _amount, bytes32 _receiver) internal pure returns (bytes memory) {
        return abi.encodePacked(_amount, _receiver);
    }

    function encodeLzComposeOption(uint16 _index, uint128 _gas, uint128 _value) internal pure returns (bytes memory) {
        return _value == 0 ? abi.encodePacked(_index, _gas) : abi.encodePacked(_index, _gas, _value);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

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
    constructor(address initialOwner) {
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
        return _owner;
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
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

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
    constructor() {
        _paused = false;
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
        return _paused;
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
        _paused = true;
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
        _paused = false;
        emit Unpaused(_msgSender());
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// Solidity does not support splitting import across multiple lines
// solhint-disable-next-line max-line-length
import { IOFT, SendParam, MessagingFee, MessagingReceipt, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

/// @notice Stargate implementation type.
enum StargateType {
    Pool,
    OFT
}

/// @notice Ticket data for bus ride.
struct Ticket {
    uint72 ticketId;
    bytes passengerBytes;
}

/// @title Interface for Stargate.
/// @notice Defines an API for sending tokens to destination chains.
interface IStargate is IOFT {
    /// @dev This function is same as `send` in OFT interface but returns the ticket data if in the bus ride mode,
    /// which allows the caller to ride and drive the bus in the same transaction.
    function sendToken(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt, Ticket memory ticket);

    /// @notice Returns the Stargate implementation type.
    function stargateType() external pure returns (StargateType);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IPeripheryImmutableState {
    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title QuoterV2 Interface
/// @notice Supports quoting the calculated amounts from exact input or exact output swaps.
/// @notice For each pool also tells you the number of initialized ticks crossed and the sqrt price of the pool after the swap.
/// @dev These functions are not marked view because they rely on calling non-view functions and reverting
/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoterV2 {
    /// @notice Returns the amount out received for a given exact input swap without executing the swap
    /// @param path The path of the swap, i.e. each token pair and the pool fee
    /// @param amountIn The amount of the first token to swap
    /// @return amountOut The amount of the last token that would be received
    /// @return sqrtPriceX96AfterList List of the sqrt price after the swap for each pool in the path
    /// @return initializedTicksCrossedList List of the initialized ticks that the swap crossed for each pool in the path
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Returns the amount out received for a given exact input but for a swap of a single pool
    /// @param params The params for the quote, encoded as `QuoteExactInputSingleParams`
    /// tokenIn The token being swapped in
    /// tokenOut The token being swapped out
    /// fee The fee of the token pool to consider for the pair
    /// amountIn The desired input amount
    /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountOut The amount of `tokenOut` that would be received
    /// @return sqrtPriceX96After The sqrt price of the pool after the swap
    /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );

    /// @notice Returns the amount in required for a given exact output swap without executing the swap
    /// @param path The path of the swap, i.e. each token pair and the pool fee. Path must be provided in reverse order
    /// @param amountOut The amount of the last token to receive
    /// @return amountIn The amount of first token required to be paid
    /// @return sqrtPriceX96AfterList List of the sqrt price after the swap for each pool in the path
    /// @return initializedTicksCrossedList List of the initialized ticks that the swap crossed for each pool in the path
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        returns (
            uint256 amountIn,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Returns the amount in required to receive the given exact output amount but for a swap of a single pool
    /// @param params The params for the quote, encoded as `QuoteExactOutputSingleParams`
    /// tokenIn The token being swapped in
    /// tokenOut The token being swapped out
    /// fee The fee of the token pool to consider for the pair
    /// amountOut The desired output amount
    /// sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountIn The amount required as the input for the swap in order to receive `amountOut`
    /// @return sqrtPriceX96After The sqrt price of the pool after the swap
    /// @return initializedTicksCrossed The number of initialized ticks that the swap crossed
    /// @return gasEstimate The estimate of the gas that the swap consumes
    function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
        external
        returns (
            uint256 amountIn,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDepositPool {
    /// @notice ERC-2612 permit. Always use this contract as spender and use
    /// msg.sender as owner
    struct PermitInput {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    event Deposited(
        address indexed from,
        address indexed to,
        address token,
        uint256 amount,
        address lsd,
        uint256 lsdAmount,
        uint256 timestamp,
        bytes32 guid,
        uint256 fee
    );

    event Withdrawn(address indexed _to, address _token, uint256 _amount, address _lsd);

    event NewWithdrawer(address withdrawer);
    event NewDepositCap(uint256 cap);
    event NewTreasury(address treasury);
    event NewLzReceiveGasLimit(uint128 gasLimit);
    event SmartSavingsOnGravityUpdated(address addr);
    event TotalLsdMintedInitialized(uint256 amount);

    error InvalidLSD();
    error InvalidVaultToken();
    error InvalidDepositAmount();
    error AmountExceedsDepositCap();
    error InvalidDepositCap(uint256 _cap);
    error SendFailed(address to, uint256 amount);
    error InvalidWithdrawer(address withdrawer);
    error InvalidWithdrawalAmount(uint256 amount);
    error InvalidAddress(address addr);
    error DepositAmountTooSmall(uint256 amount);
    error InsufficientFee(uint256 wanted, uint256 provided);
    error NotImplemented(bytes4 selector);
    error InvalidInitialLsdMinted(uint256 amount);

    function deposit(address _to, uint256 _amount, bool mintOnGravity) external payable;
    function depositWithPermit(
        address _to,
        uint256 _amount,
        bool mintOnGravity,
        PermitInput calldata _permit
    ) external payable;

    function setDepositCap(uint256 _amount) external;

    function setWithdrawer(address _withdrawer) external;

    function setTreasury(address _treasury) external;

    function withdraw(uint256 _amount) external;

    function remainingDepositCap() external view returns (uint256);
    function depositFee(address _to) external view returns (uint256);

    function LSD() external view returns (address); // solhint-disable-line style-guide-casing
    function ASSET_TOKEN() external view returns (address); // solhint-disable-line style-guide-casing
    function ASSET_TOKEN_DECIMALS() external view returns (uint256); // solhint-disable-line style-guide-casing
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title LSD Cross Chain Swap && Deposit
/// @notice Functions for process and quote cross chain swap && deposit
interface ILSDSwapV2 {
    struct ERC20PermitParam {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct BridgeTokenSwapParam {
        uint256 minOut;
        /// @notice Only ERC20 tokens can be encoded.
        ///  Use wrapped token if meets native token.
        bytes path;
    }

    /// @notice SwapStart: Cross chain swap start
    event SwapStart(
        bytes32 indexed guid,
        address indexed receipent,
        address from,
        uint256 amount,
        address sourceToken,
        address targetToken,
        uint256 targetEndPointId,
        uint256 bridgeFee,
        uint256 targetTokenMinOut
    );
    /// @notice SwapSuccess: Cross chain swap success
    event SwapSuccess(bytes32 indexed guid, address indexed receipent, address token, uint256 amount);
    /// @notice SwapFail: Cross chain swap failed on destination chain, bridge token has been refund to user
    event SwapFail(bytes32 indexed guid, address indexed receipent, address refundToken, uint256 refundAmount);

    /// @notice DepositStart: Swap deposit start
    event DepositStart(
        bytes32 indexed guid,
        address indexed receipent,
        address from,
        uint256 amount,
        address sourceToken,
        address depositPool,
        uint256 bridgeFee,
        uint256 bridgeTokenMinOut
    );
    /// @notice DepositStartOnChain: Swap deposit start on deposit pool chain
    event DepositStartOnChain(
        address indexed receipent,
        address from,
        uint256 amount,
        address sourceToken,
        address depositPool,
        uint256 amountOut
    );
    /// @notice DepositSuccess: Swap deposit success
    event DepositSuccess(bytes32 indexed guid, address indexed receipent, address depositPool, uint256 amount);
    /// @notice DepositFail: Swap deposit failed on destination chain, bridge token has been refund to user
    event DepositFail(bytes32 indexed guid, address indexed receipent, address refundToken, uint256 refundAmount);

    error ReturnToUserError(address user, uint256 valueToReturn);
    error InvalidEndpointId(uint32 endpointId);
    error InvalidSwap(address sourceToken, address targetToken);
    error AlreadyRefund(bytes32 guid);
    error InvalidDepositPool(address depositPool);
    error InvalidComposeFrom(uint32 srcEid, address composeFrom);
    error InvalidRefundSetter(address refundSetter);
    error DepositMessageFeeExceedCap(uint256 fee, uint256 cap);
    error InvalidSwapPath(bytes path, address sourceToken, address targetToken);

    /// @dev It will swap source token to target token by following path: source token -> bridge token -> target token
    /// @notice Either source token or target token should be LSD token. Otherwise it will revert InvalidSwap error
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @param targetToken Target token address
    /// @param sourceSwap Source token swap param for (source token, bridge token) swap on source chain
    /// @param targetSwap Target token swap param for (bridge token, target token) swap on target chain
    /// @param nativeDrop Native token drop on target chain for LayerZero option
    /// @param bridgeGasLimit Gas limit for execute tx on target chain when bridge message is received
    ///        zero to use default gas limit
    function crossChainSwap(
        address recipient,
        address sourceToken,
        uint256 amount,
        uint32 targetEndpointId,
        address targetToken,
        BridgeTokenSwapParam calldata sourceSwap,
        BridgeTokenSwapParam calldata targetSwap,
        ERC20PermitParam calldata permitParam,
        uint128 nativeDrop,
        uint128 bridgeGasLimit
    ) external payable;

    /// @dev swapDeposit swap source token to bridge token
    /// if on ethereum mainnet, call deposit pool directly
    /// if not, use cross chain bridge to call deposit pool on the ethereum mainnet
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param depositPool Deposit pool address
    /// @param sourceSwap Source token swap param for (source token, bridge token) swap on source chain
    function swapDeposit(
        address recipient,
        address sourceToken,
        uint256 amount,
        address depositPool,
        BridgeTokenSwapParam calldata sourceSwap,
        ERC20PermitParam calldata permitParam
    ) external payable;

    /// @dev set a cross chain swap to refund status
    ///      it will refund the bridge token to user in next lzCompose call
    /// @param guid Cross chain swap transaction guid for LayerZero
    function setSwapToRefund(bytes32 guid) external;

    /// @dev quoteCrossChainSwap, quote for bridge message fee and bridge token amount on source chain
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @param targetToken Target token address
    /// @param nativeDrop Native token drop on target chain for LayerZero option
    /// @param sourceSwapPath The swap path for swap `sourceToken` to `bridgeToken`
    /// @param targetSwapPath The swap path for swap `bridgeToken` to `targetToken`
    /// @param bridgeGasLimit Gas limit for execute tx on target chain when bridge message is received
    /// @return messageFee Message fee(in native token) for cross chain bridge message fee
    /// @return bridgeToken Bridge token address for cross chain bridge on source chain
    /// @return beforeBridgeAmountOut Amount of bridge token on source chain after swap sourceToken to bridgeToken
    /// @return afterBridgeAmountOut Amount of bridge token on target chain
    function quoteCrossChainSwap(
        address recipient,
        address sourceToken,
        uint256 amount,
        uint32 targetEndpointId,
        address targetToken,
        uint128 nativeDrop,
        bytes calldata sourceSwapPath,
        bytes calldata targetSwapPath,
        uint128 bridgeGasLimit
    )
        external
        returns (uint256 messageFee, address bridgeToken, uint256 beforeBridgeAmountOut, uint256 afterBridgeAmountOut);

    /// @dev quoteSwap, quote for swap amount of target token
    /// @param swapPath Swap path for swap `sourceToken` to `targetToken`
    /// @param amount Source token amount
    /// @return amountOut Amount of target token
    function quoteSwap(bytes memory swapPath, uint256 amount) external returns (uint256 amountOut);

    /// @dev quoteSwapDeposit, quote for swap amount of bridge token
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param depositPool Deposit pool address
    /// @param sourceSwapPath The swap path for swap `sourceToken` to `bridgeToken`
    /// @return messageFee Message fee(in native token) for cross chain bridge message fee
    /// @return bridgeToken Bridge token address for cross chain bridge on source chain
    /// @return amountOut Amount of bridge token on target chain
    function quoteSwapDeposit(
        address recipient,
        address sourceToken,
        uint256 amount,
        address depositPool,
        bytes calldata sourceSwapPath
    ) external returns (uint256 messageFee, address bridgeToken, uint256 amountOut);

    /// @dev Retrieve the bridge token address on both the source and target chains for LSD cross-chain swaps
    /// @param lsdAddr LSD token address for swap in or out
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @return sourcebridgeToken Bridge token address for cross chain bridge on current chain
    function getBridgeTokenAddress(
        address lsdAddr,
        uint32 targetEndpointId
    ) external view returns (address sourcebridgeToken);
}
/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ILayerZeroComposer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";
import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import { StargateHelper } from "../stargate/StargateHelper.sol";
import { ILSDSwapV2 } from "./ILSDSwapV2.sol";
import { SwapMessageLibV2 } from "./SwapMessageLibV2.sol";
import { IDepositPool } from "../depositPool/IDepositPool.sol";

/// @title LSDSwapV2 Contract
/// @notice This contract handles cross-chain swaps and deposits using LayerZero and Stargate protocols.
/// @dev This contract is abstract and extends multiple OpenZeppelin and LayerZero contracts.
/// The virtual functions should be implemented in the child contracts with dex.
abstract contract LSDSwapV2 is Ownable2Step, Pausable, StargateHelper, ILayerZeroComposer, ILSDSwapV2 {
    using SafeERC20 for IERC20;

    struct EndpointIdAddrPair {
        uint32 endpointId;
        address addr;
    }

    struct LSDAddrBridgeTokenPair {
        address lsdAddr;
        uint32 endpointId;
        address sourceBridgeToken;
    }

    struct DepositPoolBridgeTokenPair {
        address depositPoolAddr;
        address bridgeToken;
        bool forDeposit;
    }

    /// @notice LayerZero Ethereum Mainnet endpoint id
    uint32 public constant DEPOSIT_ENDPOINT_ID = 30101;
    /// @notice Message fee to call deposit pool on Ethereum Mainnet
    uint256 public depositMessageFee;
    /// @notice Message fee cap for cross chain deposit
    uint256 public depositMessageFeeCap = 0.01 ether;
    /// @notice Deposit pool address => current chain bridge token address
    /// @dev Bridge token may be native token
    mapping(address => address) public depositPoolToBridgeToken;
    /// @notice Deposit chain bridge token address => Deposit pool address
    mapping(address => address) public bridgeTokenToDepositPool;
    /// @notice Supported deposit pool addresses
    mapping(address => bool) public depositPools;

    /// @notice LayerZero endpoint id => LSDCrossChainSwap contract address
    mapping(uint32 => address) public endpointIdToContract;
    /// @notice (LSDAddress, targetEndpointID) => source chain bridge token address
    mapping(bytes32 => address) public lsdAddrToSourceBridgeToken;
    /// @notice Supported LSD token addresses
    mapping(address => bool) public lsdAddrs;
    /// @notice LayerZero message guid => swap need refund status
    mapping(bytes32 => bool) public swapNeedRefund;
    /// @notice Address to set message to refund.
    address public refundSetter;

    /// @notice Path for swapping bridge token to asset token which is allowed to be deposited to deposit pool
    /// @dev bridgeToken => swap path
    /// @dev Use zero address if bridge token is a native token
    mapping(address => bytes) public bridgeTokenSwapPathes;
    /// @notice The difference in decimals between bridge token and asset token has already been considered for.
    ///  Minimum amount of asset token:
    ///   bridgeTokenAmount * bridgeTokenSwapMinRate / 10^18
    /// @dev bridgeToken => mint swap rate
    mapping(address => uint256) public bridgeTokenSwapMinRates;
    /// @notice Deposit pool address => asset token address
    /// @dev Asset token may be native token
    mapping(address => address) public depositPoolToAssetToken;

    /// @dev events for config changes
    event NewEndpointAddrMapping(uint32 endpointId, address addr);
    event NewLSDBridgeTokenMapping(address lsdAddr, uint32 endpointId, address sourceBridgeToken);
    event NewDepositPoolBridgeTokenMapping(address depositPoolAddr, address bridgeToken);
    event NewDepositMessageFee(uint256 fee);
    event NewRefundSetter(address setter);
    event DeprecatedDepositPool(address depositPool);
    event DeprecatedLSDAddr(address lsdAddr);
    event NewBridgeTokenSwapPath(address bridgeToken, bytes path, uint256 minRate);

    modifier onlyValidEId(uint32 endpointId) {
        // check if endpointId is supported
        address receiveAddr = endpointIdToContract[endpointId];
        if (receiveAddr == address(0)) {
            revert InvalidEndpointId(endpointId);
        }
        _;
    }

    modifier onlyValidCrossChainSwapPair(address sourceToken, address targetToken) {
        // check if sourceToken or targetToken is LSD token
        if (!lsdAddrs[sourceToken] && !lsdAddrs[targetToken]) {
            revert InvalidSwap(sourceToken, targetToken);
        }
        _;
    }

    modifier onlyValidDepositPool(address depositPool) {
        // check if depositPool is valid
        if (!depositPools[depositPool]) {
            revert InvalidDepositPool(depositPool);
        }
        _;
    }

    modifier onlyValidComposeFrom(bytes calldata message) {
        (uint32 srcEid, address composeFrom, , ) = _parseComposeMsg(message);
        if (endpointIdToContract[srcEid] != composeFrom) {
            revert InvalidComposeFrom(srcEid, composeFrom);
        }
        _;
    }

    modifier onlyRefundSetter() {
        if (msg.sender != refundSetter) {
            revert InvalidRefundSetter(msg.sender);
        }
        _;
    }

    constructor(address _lzEndpointAddr, address _owner) Ownable(_owner) StargateHelper(_lzEndpointAddr) {}

    receive() external payable {}

    /// @notice Stops accepting new call.
    /// @dev Emit a `Paused` event.
    function pause() external onlyOwner {
        _pause();
    }
    /// @notice Resumes accepting new call.
    /// @dev Emit a `Unpaused` event.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev implement the LayerZero interface to receive cross chain compose message & token
    /// @param _from Sender OApp address, should be Stargate Pool address
    /// @param _guid Message guid, unique id for each cross chain swap
    /// @param _message Message data, LayerZero OFTComposeMsgCodec encoded message
    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) external payable override onlyValidEndpoint onlyStargate(_from) onlyValidComposeFrom(_message) {
        // swap token to user
        (, , uint256 amountLD, bytes memory composeMessage) = _parseComposeMsg(_message);
        // parse params from message
        SwapMessageLibV2.Message memory message = SwapMessageLibV2.unpack(composeMessage);

        address bridgeToken = _getBridgeToken(_from);
        if (swapNeedRefund[_guid]) {
            // if swap need refund, refund bridge token to user
            _sendTokenToUser(bridgeToken, message.tokenReceiver, amountLD);
            if (message.messageType == SwapMessageLibV2.SWAP_TYPE) {
                emit SwapFail(_guid, message.tokenReceiver, bridgeToken, amountLD);
            } else if (message.messageType == SwapMessageLibV2.DEPOSIT_TYPE) {
                emit DepositFail(_guid, message.tokenReceiver, bridgeToken, amountLD);
            }
            return;
        }
        if (message.messageType == SwapMessageLibV2.SWAP_TYPE) {
            // if swap message, swap bridge token to target token and send to user
            _handleSwapOnTargetChain(bridgeToken, amountLD, _guid, message);
        } else if (message.messageType == SwapMessageLibV2.DEPOSIT_TYPE) {
            // if deposit message, deposit bridge token to deposit pool
            _handleDepositOnTargetChain(bridgeToken, amountLD, _guid, message);
        }
    }

    /// @dev set a cross chain swap to refund status
    ///      it will refund the bridge token to user in next lzCompose call
    /// @param guid Cross chain swap transaction guid for LayerZero
    function setSwapToRefund(bytes32 guid) external onlyRefundSetter {
        swapNeedRefund[guid] = true;
    }

    /// @dev setRefundSetter, set address to set swap to refund status
    /// @param setter Address to set swap to refund status
    function setRefundSetter(address setter) external onlyOwner {
        refundSetter = setter;
        emit NewRefundSetter(setter);
    }

    /// @notice Set a swap path and min exchange rate for `bridgeToken` to `assetToken`.
    /// @dev Emits a `NewBridgeTokenSwapPath` event.
    /// @param _bridgeToken The bridge token to swap from
    /// @param _path The swap path
    /// @param _minRate The min exchange rate from `bridgeToken` to `assetToken`
    function setBridgeTokenSwapPath(address _bridgeToken, bytes calldata _path, uint256 _minRate) external onlyOwner {
        bridgeTokenSwapPathes[_bridgeToken] = _path;
        bridgeTokenSwapMinRates[_bridgeToken] = _minRate;
        emit NewBridgeTokenSwapPath(_bridgeToken, _path, _minRate);
    }

    /// @dev quoteCrossChainSwap, get message fee for cross chain swap
    /// @param recipient The recipient address
    /// @param sourceToken Source token address
    /// @param amount The amount of source token
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @param targetToken Target token address
    /// @param nativeDrop Native token drop on target chain for layerzero option
    /// @param sourceSwapPath The swap path for swap `sourceToken` to `bridgeToken`
    /// @param targetSwapPath The swap path for swap `bridgeToken` to `targetToken`
    /// @param bridgeGasLimit Gas limit for execute tx on target chain when bridge message is received
    /// @return messageFee Message fee for cross chain swap
    /// @return bridgeToken Bridge token address for cross chain bridge on source chain
    /// @return beforeBridgeAmountOut Amount of bridge token on source chain after swap sourceToken to bridgeToken
    /// @return afterBridgeAmountOut Amount of bridge token on target chain
    function quoteCrossChainSwap(
        address recipient,
        address sourceToken,
        uint256 amount,
        uint32 targetEndpointId,
        address targetToken,
        uint128 nativeDrop,
        bytes calldata sourceSwapPath,
        bytes calldata targetSwapPath,
        uint128 bridgeGasLimit
    )
        external
        returns (uint256 messageFee, address bridgeToken, uint256 beforeBridgeAmountOut, uint256 afterBridgeAmountOut)
    {
        bridgeToken = _getBridgeTokenByLSD(sourceToken, targetToken, targetEndpointId);
        if (bridgeToken != sourceToken) {
            beforeBridgeAmountOut = _quoteTokenSwap(sourceSwapPath, amount);
        } else {
            beforeBridgeAmountOut = amount;
        }
        bytes memory composeMsg = SwapMessageLibV2.pack(
            SwapMessageLibV2.Message({
                messageType: SwapMessageLibV2.SWAP_TYPE,
                tokenReceiver: recipient,
                targetToken: targetToken,
                targetSwapMinOut: 0, // not needed for quoting
                targetSwapPath: targetSwapPath // needed for message fee calculation
            })
        );
        (messageFee, afterBridgeAmountOut) = _quoteMessageFee(
            bridgeToken,
            targetEndpointId,
            beforeBridgeAmountOut,
            nativeDrop,
            endpointIdToContract[targetEndpointId],
            composeMsg,
            bridgeGasLimit
        );
        return (messageFee, bridgeToken, beforeBridgeAmountOut, afterBridgeAmountOut);
    }
    /// @dev quoteSwap, quote for swap amount of target token on current chain via dex
    /// @param swapPath Swap path for swap `sourceToken` to `targetToken`
    /// @param amount Source token amount
    /// @return amountOut Amount of target token
    function quoteSwap(bytes memory swapPath, uint256 amount) external returns (uint256 amountOut) {
        return _quoteTokenSwap(swapPath, amount);
    }

    /// @dev quoteSwapDeposit, quote for swap amount of bridge token
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param depositPool Deposit pool address
    /// @param sourceSwapPath The swap path for swap `sourceToken` to `bridgeToken`
    /// @return messageFee Message fee(in native token) for cross chain bridge message fee
    /// @return bridgeToken Bridge token address for cross chain bridge on source chain
    /// @return amountOut Amount of bridge token on target chain
    function quoteSwapDeposit(
        address recipient,
        address sourceToken,
        uint256 amount,
        address depositPool,
        bytes calldata sourceSwapPath
    ) external returns (uint256 messageFee, address bridgeToken, uint256 amountOut) {
        bridgeToken = depositPoolToBridgeToken[depositPool];
        if (bridgeToken != sourceToken) {
            amountOut = _quoteTokenSwap(sourceSwapPath, amount);
        } else {
            amountOut = amount;
        }
        // depositMessageFee means the message fee for calling deposit pool on ethereum mainnet
        messageFee = depositMessageFee;
        if (!_isOnDepositChain()) {
            // if not on ethereum mainnet, need to bridge to ethereum mainnet
            // which leading to a extra messageFee from this chain to ethereum mainnet
            bytes memory composeMsg = SwapMessageLibV2.pack(
                SwapMessageLibV2.Message({
                    messageType: SwapMessageLibV2.DEPOSIT_TYPE,
                    tokenReceiver: recipient,
                    targetToken: address(0),
                    targetSwapMinOut: 0,
                    targetSwapPath: bytes("")
                })
            );
            (uint256 bridgeFee, uint256 afterBridgeAmountOut) = _quoteMessageFee(
                bridgeToken,
                DEPOSIT_ENDPOINT_ID,
                amountOut,
                uint128(depositMessageFee),
                endpointIdToContract[DEPOSIT_ENDPOINT_ID],
                composeMsg,
                0
            );
            messageFee = bridgeFee;
            amountOut = afterBridgeAmountOut;
        }
        return (messageFee, bridgeToken, amountOut);
    }

    /// @dev setEndpointIdToContract, set endpoint id to contract address mapping
    /// @param pairs Config pairs to set mapping
    function setEndpointIdToContract(EndpointIdAddrPair[] calldata pairs) public onlyOwner {
        for (uint256 i = 0; i < pairs.length; i++) {
            endpointIdToContract[pairs[i].endpointId] = pairs[i].addr;
            emit NewEndpointAddrMapping(pairs[i].endpointId, pairs[i].addr);
        }
    }

    /// @dev removeLSDAddrs, remove LSD token addresses
    /// @param addrs LSD token addresses to be removed
    function removeLSDAddrs(address[] calldata addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            lsdAddrs[addrs[i]] = false;
            emit DeprecatedLSDAddr(addrs[i]);
        }
    }

    /// @dev setLSDAddrToBridgeToken, set LSD token address to bridge token address mapping
    /// @param pairs Config pairs to set mapping
    function setLSDAddrToBridgeToken(LSDAddrBridgeTokenPair[] calldata pairs) public onlyOwner {
        bytes32 key;
        for (uint256 i = 0; i < pairs.length; i++) {
            key = _getLSDBridgeTokenKey(pairs[i].lsdAddr, pairs[i].endpointId);
            lsdAddrs[pairs[i].lsdAddr] = true;
            lsdAddrToSourceBridgeToken[key] = pairs[i].sourceBridgeToken;

            emit NewLSDBridgeTokenMapping(pairs[i].lsdAddr, pairs[i].endpointId, pairs[i].sourceBridgeToken);
        }
    }

    /// @dev setDepositPoolToBridgeToken, set deposit pool address to source bridge token address mapping
    /// @param pairs Config pairs to set mapping
    function setDepositPoolToBridgeToken(DepositPoolBridgeTokenPair[] calldata pairs) public onlyOwner {
        for (uint256 i = 0; i < pairs.length; i++) {
            bridgeTokenToDepositPool[pairs[i].bridgeToken] = pairs[i].depositPoolAddr;
            depositPools[pairs[i].depositPoolAddr] = true;
            if (_isOnDepositChain()) {
                depositPoolToAssetToken[pairs[i].depositPoolAddr] = IDepositPool(pairs[i].depositPoolAddr)
                    .ASSET_TOKEN();
            }
            if (pairs[i].forDeposit) {
                depositPoolToBridgeToken[pairs[i].depositPoolAddr] = pairs[i].bridgeToken;
            }
            emit NewDepositPoolBridgeTokenMapping(pairs[i].depositPoolAddr, pairs[i].bridgeToken);
        }
    }

    /// @dev removeDepositPools, remove deposit pool addresses
    /// @param addrs Deposit pool addresses to be removed
    function removeDepositPools(address[] calldata addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            depositPools[addrs[i]] = false;
            emit DeprecatedDepositPool(addrs[i]);
        }
    }

    /// @dev Set deposit message fee
    /// @param fee New message fee for deposit
    function setDepositMessageFee(uint256 fee) public onlyOwner {
        if (fee > depositMessageFeeCap) {
            revert DepositMessageFeeExceedCap(fee, depositMessageFeeCap);
        }
        depositMessageFee = fee;
        emit NewDepositMessageFee(fee);
    }

    /// @dev Set all of configurations for the contract
    /// @notice if you want to change only one configuration
    /// you can call the specific function instead of this function for saving gas
    /// @param tokens The token configuration
    /// @param endpointIdAddrs The endpoint id to contract address mapping
    /// @param lsdAddrBridgeTokens The LSD address to bridge token mapping
    /// @param depositPoolAddrs The deposit pool address to bridge token mapping
    function setConfig(
        TokenConfigPair[] calldata tokens,
        EndpointIdAddrPair[] calldata endpointIdAddrs,
        LSDAddrBridgeTokenPair[] calldata lsdAddrBridgeTokens,
        DepositPoolBridgeTokenPair[] calldata depositPoolAddrs,
        uint256 _depositMessageFee
    ) public onlyOwner {
        setTokenConfig(tokens);
        setEndpointIdToContract(endpointIdAddrs);
        setLSDAddrToBridgeToken(lsdAddrBridgeTokens);
        setDepositPoolToBridgeToken(depositPoolAddrs);
        setDepositMessageFee(_depositMessageFee);
    }

    /// @dev It will swap source token to target token by following path: source token -> bridge token -> target token
    /// @notice Either source token or target token should be LSD token. Otherwise it will revert InvalidSwap error
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @param targetToken Target token address
    /// @param sourceSwap Source token swap param for (source token, bridge token) swap on source chain
    /// @param targetSwap Target token swap param for (bridge token, target token) swap on target chain
    /// @param permitParam ERC20 permit param for transferring source token from caller to the contract
    /// @param nativeDrop Native token drop on target chain for layerzero option
    /// @param bridgeGasLimit Gas limit for execute tx on target chain when bridge message is received
    function crossChainSwap(
        address recipient,
        address sourceToken,
        uint256 amount,
        uint32 targetEndpointId,
        address targetToken,
        BridgeTokenSwapParam calldata sourceSwap,
        BridgeTokenSwapParam calldata targetSwap,
        ERC20PermitParam calldata permitParam,
        uint128 nativeDrop,
        uint128 bridgeGasLimit
    ) public payable whenNotPaused onlyValidEId(targetEndpointId) {
        // transfer source token to the contract
        if (sourceToken != address(0)) {
            amount = _transferInERC20TokenCompatible(sourceToken, amount, permitParam);
        }
        // sourceToken or targetToken should be LSD token
        // get bridge token from LSD token
        address bridgeToken = _getBridgeTokenByLSD(sourceToken, targetToken, targetEndpointId);

        // swap sourceToken to bridgeToken
        uint256 amountOut = _tokenSwap(sourceToken, bridgeToken, amount, sourceSwap.minOut, sourceSwap.path);
        // send bridgeToken and message to stargate
        bytes memory composeMsg = SwapMessageLibV2.pack(
            SwapMessageLibV2.Message({
                messageType: SwapMessageLibV2.SWAP_TYPE,
                tokenReceiver: recipient,
                targetToken: targetToken,
                targetSwapMinOut: targetSwap.minOut,
                targetSwapPath: targetSwap.path
            })
        );
        uint256 valueToSend = _getBridgeValueToSend(sourceToken, amount, bridgeToken, amountOut);
        (bytes32 guid, uint256 bridgeFee, , ) = _crossChainBridge(
            targetEndpointId,
            bridgeToken,
            amountOut,
            nativeDrop,
            endpointIdToContract[targetEndpointId],
            recipient,
            composeMsg,
            valueToSend,
            bridgeGasLimit
        );
        // emit swap start event on the source chain
        emit SwapStart(
            guid,
            recipient,
            msg.sender,
            amount,
            sourceToken,
            targetToken,
            targetEndpointId,
            bridgeFee,
            targetSwap.minOut
        );
    }

    /// @dev swapDeposit, swap source token to bridge token
    /// then use cross chain bridge to call deposit pool on the ethereum mainnet
    /// @param recipient Recipient address on target chain
    /// @param sourceToken Source token address
    /// @param amount Source token amount
    /// @param depositPool Deposit pool address
    /// @param sourceSwap Source token swap param for (source token, bridge token) swap on source chain
    /// @param permitParam ERC20 permit param for transferring source token from caller to the contract
    function swapDeposit(
        address recipient,
        address sourceToken,
        uint256 amount,
        address depositPool,
        BridgeTokenSwapParam calldata sourceSwap,
        ERC20PermitParam calldata permitParam
    ) public payable onlyValidDepositPool(depositPool) whenNotPaused {
        // transfer source token to the contract
        if (sourceToken != address(0)) {
            amount = _transferInERC20TokenCompatible(sourceToken, amount, permitParam);
        }
        // get current chain bridge token by deposit pool
        address bridgeToken = depositPoolToBridgeToken[depositPool];

        // swap sourceToken to bridgeToken
        uint256 amountOut = _tokenSwap(sourceToken, bridgeToken, amount, sourceSwap.minOut, sourceSwap.path);
        uint256 valueToSend = _getBridgeValueToSend(sourceToken, amount, bridgeToken, amountOut);

        if (_getLZEndpointId() == DEPOSIT_ENDPOINT_ID) {
            // if on ethereum mainnet, call deposit pool directly
            _deposit(depositPool, recipient, amountOut, valueToSend, msg.sender);
            emit DepositStartOnChain(recipient, msg.sender, amount, sourceToken, depositPool, amountOut);
        } else {
            // if need cross chain deposit, send bridge token to deposit pool on ethereum mainnet
            bytes memory composeMsg = SwapMessageLibV2.pack(
                SwapMessageLibV2.Message({
                    messageType: SwapMessageLibV2.DEPOSIT_TYPE,
                    tokenReceiver: recipient,
                    targetToken: address(0),
                    targetSwapMinOut: 0,
                    targetSwapPath: bytes("")
                })
            );
            (bytes32 guid, uint256 bridgeFee, , uint256 amountReceived) = _crossChainBridge(
                DEPOSIT_ENDPOINT_ID,
                bridgeToken,
                amountOut,
                uint128(depositMessageFee), // drop fixed message fee to contract for calling deposit pool
                endpointIdToContract[DEPOSIT_ENDPOINT_ID],
                endpointIdToContract[DEPOSIT_ENDPOINT_ID],
                composeMsg,
                valueToSend,
                0 // use default gas limit
            );
            // emit deposit start event on the source chain
            emit DepositStart(guid, recipient, msg.sender, amount, sourceToken, depositPool, bridgeFee, amountReceived);
        }
    }

    /// @dev Retrieve the bridge token address on both the source and target chains for LSD cross-chain swaps
    /// @param lsdAddr LSD token address for swap in or out
    /// @param targetEndpointId Target chain layer zero endpoint id
    /// @return sourcebridgeToken Bridge token address for cross chain bridge on current chain
    function getBridgeTokenAddress(
        address lsdAddr,
        uint32 targetEndpointId
    ) public view returns (address sourcebridgeToken) {
        bytes32 key = _getLSDBridgeTokenKey(lsdAddr, targetEndpointId);
        return lsdAddrToSourceBridgeToken[key];
    }

    /// @dev _handleSwapOnTargetChain, handle swap message on target chain
    /// @param bridgeToken Bridge token address
    /// @param amountLD Amount of bridge token
    /// @param _guid Cross chain swap transaction guid for LayerZero
    /// @param message Swap message
    function _handleSwapOnTargetChain(
        address bridgeToken,
        uint256 amountLD,
        bytes32 _guid,
        SwapMessageLibV2.Message memory message
    ) internal {
        uint256 amountOut = _tokenSwap(
            bridgeToken,
            message.targetToken,
            amountLD,
            message.targetSwapMinOut,
            message.targetSwapPath
        );
        _sendTokenToUser(message.targetToken, message.tokenReceiver, amountOut);
        emit SwapSuccess(_guid, message.tokenReceiver, message.targetToken, amountOut);
    }

    /// @dev _handleDepositOnTargetChain, handle deposit message on target chain
    /// @param bridgeToken Bridge token address
    /// @param amountLD Amount of bridge token
    /// @param _guid Cross chain swap transaction guid for LayerZero
    /// @param message Deposit message
    function _handleDepositOnTargetChain(
        address bridgeToken,
        uint256 amountLD,
        bytes32 _guid,
        SwapMessageLibV2.Message memory message
    ) internal {
        address depositPool = bridgeTokenToDepositPool[bridgeToken];
        if (!depositPools[depositPool]) {
            revert InvalidDepositPool(depositPool);
        }
        uint256 valueToSend = depositMessageFee;
        if (bridgeToken == address(0)) {
            // if bridge token is native token
            // need to send amountLD + depositMessageFee to
            valueToSend += amountLD;
        }

        uint256 depositAmount = amountLD;

        // if bridge token is not asset token, swap to asset token
        address assetToken = depositPoolToAssetToken[depositPool];
        if (assetToken != bridgeToken) {
            bytes memory swapPath = bridgeTokenSwapPathes[bridgeToken];
            uint256 minAssetAmount = (amountLD * bridgeTokenSwapMinRates[bridgeToken]) / 1e18;
            depositAmount = _tokenSwap(bridgeToken, assetToken, amountLD, minAssetAmount, swapPath);
        }

        _deposit(depositPool, message.tokenReceiver, depositAmount, valueToSend, message.tokenReceiver);
        emit DepositSuccess(_guid, message.tokenReceiver, depositPool, amountLD);
    }

    /// @dev _transferInERC20TokenCompatible, transfer ERC20 token from msg.sender to the contract
    /// support reflective token
    /// @param token Token address
    /// @param amount Token amount
    /// @param permitParam ERC20 permit param for transferring token
    function _transferInERC20TokenCompatible(
        address token,
        uint256 amount,
        ERC20PermitParam calldata permitParam
    ) internal returns (uint256 amountIn) {
        try
            IERC20Permit(token).permit(
                msg.sender,
                address(this),
                amount,
                permitParam.deadline,
                permitParam.v,
                permitParam.r,
                permitParam.s
            )
        //solhint-disable-next-line no-empty-blocks
        {
            //solhint-disable-next-line no-empty-blocks
        } catch {}
        // compatible with reflective tokens
        uint256 beforeBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 afterBalance = IERC20(token).balanceOf(address(this));
        return afterBalance - beforeBalance;
    }

    /// @dev _universalSendToUser, send token or eth to user
    /// @param token Token address, 0 for eth
    /// @param user User address
    /// @param amount Token amount or eth value
    function _sendTokenToUser(address token, address user, uint256 amount) internal {
        if (token != address(0)) {
            IERC20(token).safeTransfer(user, amount);
        } else {
            (bool sent, ) = user.call{ value: amount }("");
            if (!sent) {
                revert ReturnToUserError(user, amount);
            }
        }
    }

    /// @dev _deposit, deposit bridge token to deposit pool
    /// @param depositPool Deposit pool address
    /// @param recipient Recipient address on target chain
    /// @param tokenAmount Deposit pool asset token amount
    /// @param valueToSend Value to send to deposit pool
    /// @param refundAddress Refund address for the rest value
    function _deposit(
        address depositPool,
        address recipient,
        uint256 tokenAmount,
        uint256 valueToSend,
        address refundAddress
    ) internal {
        address token = depositPoolToAssetToken[depositPool];
        uint256 beforeBalance = address(this).balance;
        if (token != address(0)) {
            IERC20(token).forceApprove(depositPool, tokenAmount);
        }
        IDepositPool(depositPool).deposit{ value: valueToSend }(recipient, tokenAmount, true);
        // depositPool will refund to the msg.sender, which is this contract
        // so we need to refund to the msg.sender
        uint256 afterBalance = address(this).balance;
        uint256 actualSent = beforeBalance - afterBalance;
        uint256 refund = valueToSend - actualSent;
        if (refund > 0) {
            _sendTokenToUser(address(0), refundAddress, refund);
        }
    }

    /// @dev _tokenSwap, swap source token to target token on current chain with dex along the specified path
    /// @param fromToken Source token address
    /// @param toToken Target token address
    /// @param amount Source token amount
    /// @param minAmountOut Min target token amount to receive
    /// @param path Swap path
    /// @return amountOut Target token amount received
    function _tokenSwap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minAmountOut,
        bytes memory path
    ) internal virtual returns (uint256 amountOut);

    /// @dev _quoteTokenSwap, quote source token to target token on current chain with dex along the specified path
    /// @param path Swap path
    /// @param amount Source token amount
    /// @return amountOut Estimated target token amount received
    function _quoteTokenSwap(bytes memory path, uint256 amount) internal virtual returns (uint256 amountOut);

    /// @dev check if the swap path is valid, reverts if not
    ///   the first token in the path must be sourceToken, and the last token must be targetToken
    /// @param path Swap path
    /// @param sourceToken Source token address
    /// @param targetToken Target token address
    function _checkSwapPath(bytes memory path, address sourceToken, address targetToken) internal {
        sourceToken = _getRealToken(sourceToken);
        targetToken = _getRealToken(targetToken);
        if (path.length != 0 || sourceToken != targetToken) {
            (address decodedSourceToken, address decodedTargetToken) = _decodeSourceTargetTokenFromV3SwapPath(path);
            if (decodedSourceToken != sourceToken || decodedTargetToken != targetToken) {
                revert InvalidSwapPath(path, sourceToken, targetToken);
            }
        }
    }

    /// @dev To decode the source and target token from the path.
    ///   It is compatible with both Uniswap V3 and Camelot V3 path.
    /// @param path The swap path in Uniswap V3 format
    ///   Multiple pool swaps are encoded through bytes called a `path`.
    ///   A path is a sequence of token addresses and poolFees that define the pools used in the swaps.
    ///   The format for pool encoding is (tokenIn, fee, tokenOut/tokenIn, fee, tokenOut) where
    ///   tokenIn/tokenOut parameter is the shared token across the pools.
    ///   Since we are swapping DAI to USDC and then USDC to WETH9 the path encoding is (DAI, 0.3%, USDC, 0.3%, WETH9).
    /// @return sourceToken Source token address
    /// @return targetToken Target token address
    function _decodeSourceTargetTokenFromV3SwapPath(
        bytes memory path
    ) internal virtual returns (address sourceToken, address targetToken) {
        uint256 len = path.length;
        /* solhint-disable no-inline-assembly */
        assembly {
            sourceToken := mload(add(path, 20))
            targetToken := mload(add(path, len))
        }
        /* solhint-enable no-inline-assembly */
    }

    /// @dev _getBridgeValueToSend, get value to send to bridge contract(eg: stargate)
    /// @param sourceToken Source token address
    /// @param sourceAmount Source token amount from user
    /// @param bridgeToken Bridge token address
    /// @param bridgeAmount Bridge token amount swapped by dex
    /// @return valueToSend Value to send to bridge contract
    function _getBridgeValueToSend(
        address sourceToken,
        uint256 sourceAmount,
        address bridgeToken,
        uint256 bridgeAmount
    ) internal view returns (uint256) {
        if (sourceToken == address(0) && bridgeToken != address(0)) {
            // if source token is ETH and bridge token is not ETH
            // sourceAmount ETH are swapped to bridgeToken, send the rest
            return msg.value - sourceAmount;
        } else if (sourceToken != address(0) && bridgeToken == address(0)) {
            // if source token is not ETH and bridge token is ETH
            // get bridgeAmount ETH from dex, send these with msg.value
            return msg.value + bridgeAmount;
        } else {
            return msg.value;
        }
    }

    /// @dev _getTokenBalance, get token balance of the contract
    /// @param token Token address, 0 for eth
    /// @return balance Token balance of the contract
    function _getTokenBalance(address token) internal view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    /// @dev _getBridgeTokenByLSD, get bridge token from LSD token address
    /// @notice Either sourceToken or targetToken should be LSD token, otherwise revert InvalidSwap error
    /// @param sourceToken Source token address
    /// @param targetToken Target token address
    /// @param endpointId The endpoint ID of the chain where the bridge token is located
    /// @return sourceBridgeToken Bridge token address for cross chain bridge on current chain
    function _getBridgeTokenByLSD(
        address sourceToken,
        address targetToken,
        uint32 endpointId
    ) internal view onlyValidCrossChainSwapPair(sourceToken, targetToken) returns (address sourceBridgeToken) {
        if (lsdAddrs[sourceToken]) {
            return getBridgeTokenAddress(sourceToken, endpointId);
        } else {
            return getBridgeTokenAddress(targetToken, endpointId);
        }
    }

    /// @dev _isOnDepositChain, check if the contract is on the deposit chain
    /// @return isOnDepositChain True if the contract is on the deposit chain
    function _isOnDepositChain() internal view returns (bool) {
        return _getLZEndpointId() == DEPOSIT_ENDPOINT_ID;
    }

    /// @dev Get the real token address for the given token
    ///      if token is ETH, return WETH address
    /// @param token The token address
    /// @return realToken The real token address
    function _getRealToken(address token) internal view virtual returns (address realToken);

    /// @dev _getLSDBridgeTokenKey, get key for LSD token address and target endpoint id
    /// @param lsdAddr LSD token address
    /// @param endpointId Target chain layer zero endpoint id
    /// @return Key for LSD token => bridge token mapping
    function _getLSDBridgeTokenKey(address lsdAddr, uint32 endpointId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(lsdAddr, endpointId));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { LSDSwapV2 } from "./LSDSwapV2.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { IQuoterV2 } from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import { IPeripheryImmutableState } from "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import { IWETH9 } from "../weth9/IWETH9.sol";

/// @title LSDSwapWithUniswapV2
/// @dev This contract extends LSDSwapV2 to integrate with Uniswap for token swaps.
contract LSDSwapWithUniswapV2 is LSDSwapV2 {
    /// @notice The address of the uniswap router contract
    address public immutable SWAP_ROUTER;
    /// @notice The address of the uniswap quoter contract
    address public immutable SWAP_QUOTER;
    /// @notice The address of the uniswap v3 factory contract
    address public immutable SWAP_FACTORY;

    /// @dev Constructor to initialize the LSDCrossChainSwap contract with the LzEndpointV2 contract address
    /// @param _swapRouter The address of the uniswap swap router
    /// @param _swapQuoter The address of the uniswap swap quoter
    /// @param _swapFactory The address of the uniswap v3 factory
    /// @param _lzEndpointAddr The address of the LzEndpointV2 contract of LayerZero
    /// @param _owner The address of the owner of the contract
    constructor(
        address _swapRouter,
        address _swapQuoter,
        address _swapFactory,
        address _lzEndpointAddr, // solhint-disable-line no-unused-vars
        address _owner // solhint-disable-line no-unused-vars
    ) LSDSwapV2(_lzEndpointAddr, _owner) {
        SWAP_ROUTER = _swapRouter;
        SWAP_QUOTER = _swapQuoter;
        SWAP_FACTORY = _swapFactory;
    }

    /// @dev Swap tokens using Uniswap
    /// @param fromToken The token to swap from
    /// @param toToken The token to swap to
    /// @param amount The amount of fromToken to swap
    /// @param minAmountOut The minimum amount of toToken to receive
    /// @param path Swap path
    /// @return amountOut The amount of toToken received
    function _tokenSwap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minAmountOut,
        bytes memory path
    ) internal virtual override returns (uint256 amountOut) {
        if (fromToken == toToken) {
            return amount;
        }

        address weth9 = IPeripheryImmutableState(SWAP_ROUTER).WETH9();
        address realFromToken = fromToken;
        if (fromToken == address(0)) {
            realFromToken = weth9;
            // if fromToken is ETH, convert it to WETH for swap
            IWETH9(weth9).deposit{ value: amount }();
        }
        address realToToken = toToken;
        if (toToken == address(0)) {
            realToToken = weth9;
        }

        if (realFromToken == realToToken) {
            amountOut = amount;
        } else {
            _checkSwapPath(path, realFromToken, realToToken);

            TransferHelper.safeApprove(realFromToken, SWAP_ROUTER, amount);
            ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                deadline: block.timestamp + 30 hours,
                amountIn: amount,
                amountOutMinimum: minAmountOut
            });
            amountOut = ISwapRouter(SWAP_ROUTER).exactInput(params);
        }

        // if toToken is ETH, swap for WETH and then withdraw for ETH
        if (toToken == address(0)) {
            IWETH9(realToToken).withdraw(amountOut);
        }
        return amountOut;
    }

    /// @dev Quote token swap using Uniswap
    /// @param path Swap path
    /// @param amount The amount of fromToken to swap
    /// @return amountOut The amount of toToken received
    function _quoteTokenSwap(bytes memory path, uint256 amount) internal virtual override returns (uint256 amountOut) {
        (amountOut, , , ) = IQuoterV2(SWAP_QUOTER).quoteExactInput(path, amount);
        return amountOut;
    }

    /// @dev Get the real token address for the given token
    ///      if token is ETH, return WETH address
    /// @param token The token address
    /// @return realToken The real token address
    function _getRealToken(address token) internal view virtual override returns (address realToken) {
        address weth9 = IPeripheryImmutableState(SWAP_ROUTER).WETH9();
        if (token == address(0)) {
            return weth9;
        }
        return token;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { BytesLib } from "solidity-bytes-utils/contracts/BytesLib.sol";

/// @title SwapMessageLibV2
/// @dev Library for handling cross-chain swap and deposit messages.
library SwapMessageLibV2 {
    using BytesLib for bytes;

    /// @notice Messages are transferred between chains
    ///         The first 8 bits are the message type.
    ///         If message type is SWAP_TYPE:
    ///           The next 160 bits are the token receiver.
    ///           The next 160 bits are the target token.
    ///           The next 256 bits are the minOut for swap(bridge token => target token);
    ///           The remaining bits are the swap path for swap(bridge token => target token);
    ///         If message type is DEPOSIT_TYPE:
    ///           The next 160 bits are the token receiver.
    struct Message {
        uint8 messageType;
        address tokenReceiver;
        address targetToken;
        uint256 targetSwapMinOut;
        bytes targetSwapPath;
    }

    uint8 public constant VERSION = 1;

    /// @dev Message types, first 3 bits for version, last 5 bits for type.
    uint8 public constant SWAP_TYPE = (VERSION << 5) | 1;
    uint8 public constant DEPOSIT_TYPE = (VERSION << 5) | 2;

    error InvalidMessageType(uint8 messageType);

    /// @notice Extracts a Message from bytes.
    function unpack(bytes memory b) internal pure returns (Message memory m) {
        uint8 messageType;
        address tokenReceiver;
        address targetToken;
        uint256 minOut;
        bytes memory swapPath;

        /* solhint-disable no-inline-assembly */
        assembly {
            messageType := mload(add(b, 1))
        }

        if (messageType == SWAP_TYPE) {
            assembly {
                tokenReceiver := mload(add(b, 21))
                targetToken := mload(add(b, 41))
                minOut := mload(add(b, 73))
            }
            // 1 + 20 + 20 + 32 = 73
            swapPath = b.slice(73, b.length - 73);
        } else if (messageType == DEPOSIT_TYPE) {
            assembly {
                tokenReceiver := mload(add(b, 21))
            }
        } else {
            revert InvalidMessageType(messageType);
        }
        /* solhint-enable no-inline-assembly */

        return Message(messageType, tokenReceiver, targetToken, minOut, swapPath);
    }

    /// @notice Packs a Message into bytes.
    function pack(Message memory m) internal pure returns (bytes memory) {
        if (m.messageType == SWAP_TYPE) {
            return
                abi.encodePacked(m.messageType, m.tokenReceiver, m.targetToken, m.targetSwapMinOut, m.targetSwapPath);
        } else if (m.messageType == DEPOSIT_TYPE) {
            return abi.encodePacked(m.messageType, m.tokenReceiver);
        }
        revert InvalidMessageType(m.messageType);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IStargate } from "@stargatefinance/stg-evm-v2/src/interfaces/IStargate.sol";
import {
    MessagingFee,
    MessagingReceipt,
    OFTReceipt,
    SendParam
} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { OFTComposeMsgCodec } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTComposeMsgCodec.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

/// @title StargateHelper
/// @dev This abstract contract provides helper functions for interacting with Stargate and LayerZero protocols.
/// It is abstract to prevent direct deployment.
/// Because it is designed to be a Stargate integration helper.
abstract contract StargateHelper is Ownable2Step {
    /// @notice use this statement to implement OptionsBuilder.addXXXOption.addYYYOption....
    using OptionsBuilder for bytes;
    using SafeERC20 for IERC20;

    struct TokenConfigPair {
        address tokenAddr;
        address stargateAddr;
    }

    /// @notice LayerZero endpoint address
    address public immutable LZ_ENDPOINT;

    /// @notice Gas limit for execute lzCompose in destination chain
    uint128 public composeGasLimit = 500_000;

    /// @notice Bridge token address(WETH, USDT, etc) => stargate token pool address
    /// @dev Stargate has its pools for each bridge token.
    /// Token address and stargate pool address can be found in stargate developer docs
    mapping(address => address) public bridgeTokenToStargatePool;
    /// @notice valid stargate pools, keys are equal to bridgeTokenToStargatePool.values
    mapping(address => bool) public stargatePools;

    /// @dev Event emitted when token address <=> stargate address mapping is changed
    event NewBridgeTokenStargatePoolMapping(address bridgeToken, address stargatePool);
    /// @dev Event emitted when compose gas limit is changed
    event NewComposeGasLimit(uint128 composeGasLimit);
    /// @dev Event emitted when stargate pool is removed
    event DeprecatedStargatePool(address stargatePool);

    error InvalidSender(address sender);
    error InvalidEndpoint(address endpoint);
    error InvalidBridgeToken(address bridgeToken);
    error InsufficientValueToSend(uint256 sendValue, uint256 needValue);
    error SendToUserError(address user, uint256 valueToSend);

    modifier onlyValidEndpoint() {
        if (msg.sender != LZ_ENDPOINT) {
            revert InvalidEndpoint(msg.sender);
        }
        _;
    }

    modifier onlyStargate(address _from) {
        if (!stargatePools[_from]) {
            revert InvalidSender(_from);
        }
        _;
    }

    modifier onlyValidBridgeToken(address bridgeToken) {
        address stargatePool = bridgeTokenToStargatePool[bridgeToken];
        if (stargatePool == address(0)) {
            revert InvalidBridgeToken(bridgeToken);
        }
        if (!stargatePools[stargatePool]) {
            revert InvalidBridgeToken(bridgeToken);
        }
        _;
    }

    constructor(address _lzEndpointAddr) {
        if (_lzEndpointAddr == address(0)) {
            revert InvalidEndpoint(_lzEndpointAddr);
        }
        LZ_ENDPOINT = _lzEndpointAddr;
    }

    /// @dev Remove stargate pools.
    ///      Used to remove some pools, because the setTokenConfig function will add pools automatically
    /// @param deletePools Array of stargate pool addresses to be removed
    function removeStargatePools(address[] calldata deletePools) public onlyOwner {
        for (uint256 i = 0; i < deletePools.length; i++) {
            stargatePools[deletePools[i]] = false;
            emit DeprecatedStargatePool(deletePools[i]);
        }
    }

    /// @dev Set token config for bridge token
    /// @param pairs Array of token config pair
    function setTokenConfig(TokenConfigPair[] calldata pairs) public onlyOwner {
        for (uint256 i = 0; i < pairs.length; i++) {
            bridgeTokenToStargatePool[pairs[i].tokenAddr] = pairs[i].stargateAddr;
            stargatePools[pairs[i].stargateAddr] = true;

            emit NewBridgeTokenStargatePoolMapping(pairs[i].tokenAddr, pairs[i].stargateAddr);
        }
    }

    /// @dev Set compose gas limit
    /// @param _composeGasLimit Gas limit for execute lzCompose in destination chain
    function setComposeGasLimit(uint128 _composeGasLimit) public onlyOwner {
        composeGasLimit = _composeGasLimit;
        emit NewComposeGasLimit(_composeGasLimit);
    }

    /// @dev Cross chain bridge
    /// @param endpointId Target chain Endpoint id for LayerZero
    /// @param bridgeToken Bridge token enum, e.g. ETH, USDT, USDC etc. stargate supported assets
    /// @param amount Amount if bridge token to bridge
    /// @param nativeDrop Native token drop on target chain
    /// @param receiver Receiver address on target chain
    /// @param nativeDropReceiver Native token drop receiver address on target chain
    /// @param composeMsg Compose message for lzCompose
    /// @param valueToSend Value to send to stargate pool
    ///        Pay for messaging fee, native token drop,
    ///        and if bridge token is native token, it's included in valueToSend
    /// @param gasLimit Gas limit for lzCompose
    function _crossChainBridge(
        uint32 endpointId,
        address bridgeToken,
        uint256 amount,
        uint128 nativeDrop,
        address receiver,
        address nativeDropReceiver,
        bytes memory composeMsg,
        uint256 valueToSend,
        uint128 gasLimit
    )
        internal
        onlyValidBridgeToken(bridgeToken)
        returns (bytes32 guid, uint256 bridgeFee, uint256 amountSent, uint256 amountReceived)
    {
        address stargateAddr = bridgeTokenToStargatePool[bridgeToken];
        if (bridgeToken != address(0)) {
            IERC20(bridgeToken).forceApprove(stargateAddr, amount);
        }
        (uint256 quoteValueToSend, SendParam memory sendParam, MessagingFee memory messagingFee) = _prepareTakeTaxi(
            endpointId,
            amount,
            nativeDrop,
            receiver,
            nativeDropReceiver,
            composeMsg,
            stargateAddr,
            gasLimit
        );
        if (valueToSend < quoteValueToSend) {
            revert InsufficientValueToSend(valueToSend, quoteValueToSend);
        }
        uint256 messageValue = messagingFee.nativeFee;
        if (bridgeToken != address(0x0)) {
            // if bridge token is not native token, stargate will check msg.value = MessagingFee.nativeFee
            // otherwise stargate will check msg.value >= MessagingFee.nativeFee + sendParam.amountLD
            messageValue = valueToSend;
        }
        (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt, ) = IStargate(stargateAddr).sendToken{
            value: valueToSend
        }(
            sendParam,
            MessagingFee(messageValue, 0),
            // if valueToSend > quoteValueToSend, LayerZero will refund the excess value to msg.sender
            payable(msg.sender)
        );
        if ((bridgeToken != address(0)) && (amount > oftReceipt.amountSentLD)) {
            // if bridgeToken is native token, stargate will refund the remaining amount to user
            // otherwise it will take oftReceipt.amountSentLD token
            // we should refund the remaining amount to user
            IERC20(bridgeToken).safeTransfer(msg.sender, amount - oftReceipt.amountSentLD);
        }
        return (msgReceipt.guid, messagingFee.nativeFee, oftReceipt.amountSentLD, oftReceipt.amountReceivedLD);
    }

    /// @dev prepare to send cross chain message && token to target chain via stargate taxi mode
    /// @param _dstEid Target chain Endpoint id for LayerZero
    /// @param _amount Amount if bridge token to bridge
    /// @param _nativeDrop Native token drop on target chain
    /// @param _receiver Receiver address on target chain
    /// @param _nativeDropReceiver Native token drop receiver address on target chain
    /// @param _composeMsg Compose message for lzCompose
    /// @param stargateAddr Stargate pool address
    /// @param _gasLimit Gas limit for lzCompose
    function _prepareTakeTaxi(
        uint32 _dstEid,
        uint256 _amount,
        uint128 _nativeDrop,
        address _receiver,
        address _nativeDropReceiver,
        bytes memory _composeMsg,
        address stargateAddr,
        uint128 _gasLimit
    ) internal view returns (uint256 valueToSend, SendParam memory sendParam, MessagingFee memory messagingFee) {
        bytes memory extraOptions = bytes("");
        if (_composeMsg.length > 0) {
            // compose gas limit
            _gasLimit = _getComposeGasLimit(_gasLimit);
            extraOptions = OptionsBuilder.newOptions().addExecutorLzComposeOption(0, _gasLimit, 0);
        }
        if (_nativeDrop > 0) {
            if (extraOptions.length == 0) {
                extraOptions = OptionsBuilder.newOptions();
            }
            extraOptions = extraOptions.addExecutorNativeDropOption(
                _nativeDrop,
                _addressToBytes32(_nativeDropReceiver)
            );
        }
        sendParam = SendParam({
            dstEid: _dstEid,
            to: _addressToBytes32(_receiver),
            amountLD: _amount,
            minAmountLD: _amount,
            extraOptions: extraOptions,
            composeMsg: _composeMsg,
            oftCmd: ""
        });
        IStargate istargate = IStargate(stargateAddr);

        (, , OFTReceipt memory receipt) = istargate.quoteOFT(sendParam);
        sendParam.minAmountLD = receipt.amountReceivedLD;

        messagingFee = istargate.quoteSend(sendParam, false);
        valueToSend = messagingFee.nativeFee;

        if (istargate.token() == address(0x0)) {
            valueToSend += sendParam.amountLD;
        }
    }

    /// @dev Quote message fee for cross chain bridge
    /// @param bridgeToken Bridge token address, e.g. ETH, USDT, USDC etc. stargate supported assets
    /// @param _dstEid Target chain Endpoint id for LayerZero
    /// @param _amount Amount if bridge token to bridge
    /// @param _nativeDrop Native token drop on target chain
    /// @param _receiver Receiver address on target chain
    /// @param _composeMsg Compose message for lzCompose
    /// @param _gasLimit Gas limit for lzCompose
    function _quoteMessageFee(
        address bridgeToken,
        uint32 _dstEid,
        uint256 _amount,
        uint128 _nativeDrop,
        address _receiver,
        bytes memory _composeMsg,
        uint128 _gasLimit
    ) internal view returns (uint256 messageFee, uint256 amountLD) {
        address stargateAddr = bridgeTokenToStargatePool[bridgeToken];
        bytes memory extraOptions = bytes("");
        if (_composeMsg.length > 0) {
            // compose gas limit
            _gasLimit = _getComposeGasLimit(_gasLimit);
            extraOptions = OptionsBuilder.newOptions().addExecutorLzComposeOption(0, _gasLimit, 0);
        }
        if (_nativeDrop > 0) {
            if (extraOptions.length == 0) {
                extraOptions = OptionsBuilder.newOptions();
            }
            extraOptions = extraOptions.addExecutorNativeDropOption(_nativeDrop, _addressToBytes32(_receiver));
        }
        SendParam memory sendParam = SendParam({
            dstEid: _dstEid,
            to: _addressToBytes32(_receiver),
            amountLD: _amount,
            minAmountLD: _amount,
            extraOptions: extraOptions,
            composeMsg: _composeMsg,
            oftCmd: ""
        });

        IStargate istargate = IStargate(stargateAddr);

        MessagingFee memory messagingFee = istargate.quoteSend(sendParam, false);

        (, , OFTReceipt memory receipt) = istargate.quoteOFT(sendParam);
        return (messagingFee.nativeFee, receipt.amountReceivedLD);
    }

    /// @dev Get bridge token address from stargate pool address
    /// @param stargatePool Stargate pool address
    /// @return bridgeToken Bridge token address
    function _getBridgeToken(address stargatePool) internal view returns (address bridgeToken) {
        return IStargate(stargatePool).token();
    }

    /// @dev Get LayerZero endpoint id
    /// @return eid LayerZero endpoint id
    function _getLZEndpointId() internal view returns (uint32 eid) {
        return ILayerZeroEndpointV2(LZ_ENDPOINT).eid();
    }

    function _getComposeGasLimit(uint128 _gasLimit) internal view returns (uint128) {
        if (_gasLimit == 0) {
            return composeGasLimit;
        }
        return _gasLimit;
    }

    /// @dev Parse compose message using LayerZero OFT library
    /// @param _message Compose message delivered by LayerZero
    /// @return srcEid Source chain LayerZero endpoint id
    /// @return composeFrom Compose message sender on source chain
    /// @return amountLD Amount of token received on target chain
    /// @return composeMessage Compose message sent by source contract
    function _parseComposeMsg(
        bytes calldata _message
    ) internal pure returns (uint32 srcEid, address composeFrom, uint256 amountLD, bytes memory composeMessage) {
        srcEid = OFTComposeMsgCodec.srcEid(_message);
        bytes32 _composeFrom = OFTComposeMsgCodec.composeFrom(_message);
        amountLD = OFTComposeMsgCodec.amountLD(_message);
        composeMessage = OFTComposeMsgCodec.composeMsg(_message);
        return (srcEid, OFTComposeMsgCodec.bytes32ToAddress(_composeFrom), amountLD, composeMessage);
    }

    /// @dev Convert address to bytes32
    /// @param _addr Address to convert
    function _addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;

/// @title Interface for WETH9
interface IWETH9 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equal_nonAligned(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let endMinusWord := add(_preBytes, length)
                let mc := add(_preBytes, 0x20)
                let cc := add(_postBytes, 0x20)

                for {
                // the next line is the loop condition:
                // while(uint256(mc < endWord) + cb == 2)
                } eq(add(lt(mc, endMinusWord), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }

                // Only if still successful
                // For <1 word tail bytes
                if gt(success, 0) {
                    // Get the remainder of length/32
                    // length % 32 = AND(length, 32 - 1)
                    let numTailBytes := and(length, 0x1f)
                    let mcRem := mload(mc)
                    let ccRem := mload(cc)
                    for {
                        let i := 0
                    // the next line is the loop condition:
                    // while(uint256(i < numTailBytes) + cb == 2)
                    } eq(add(lt(i, numTailBytes), cb), 2) {
                        i := add(i, 1)
                    } {
                        if iszero(eq(byte(i, mcRem), byte(i, ccRem))) {
                            // unsuccess:
                            success := 0
                            cb := 0
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}