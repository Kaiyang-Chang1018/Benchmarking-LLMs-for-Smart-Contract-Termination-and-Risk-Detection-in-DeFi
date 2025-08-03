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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
//import { IPAllActionV3, TokenOutput, LimitOrderData } from "@pendle/core-v2/contracts/interfaces/IPAllActionV3.sol";
//import { IPPrincipalToken } from "@pendle/core-v2/contracts/interfaces/IPPrincipalToken.sol";
import { IDepositPool } from "../depositPool/IDepositPool.sol";
import { IArbitrageBotTreasury } from "./IArbitrageBotTreasury.sol";
import { IStargate } from "@stargatefinance/stg-evm-v2/src/interfaces/IStargate.sol";
import {
    MessagingFee,
    MessagingReceipt,
    OFTReceipt,
    SendParam
} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

contract ArbitrageBotTreasury is Pausable, Ownable2Step, IArbitrageBotTreasury {
    using SafeERC20 for IERC20;

    struct AssetTokenSwapRule {
        /// @notice Address of paired liquidity token to swap to.
        /// @dev 20 bytes
        address toToken;
        /// @notice Exchange rate of asset token to liquidity token. Decimals is 6
        /// @dev 11 bytes
        uint88 minExchangeRate;
        /// @notice The difference in decimal places between the asset token and the liquidity token.
        ///   If it's less than 0, the liquidity token has fewer decimal places;
        ///   if greater than 0, the asset token has fewer decimal places.
        /// @dev 1 bytes
        int8 diffDecimals;
    }

    // @notice LayerZero Gravity chain endpoint id
    uint32 public constant GRAVITY_ENDPOINT_ID = 30294;

    // @notice Whitelist the addresses of accounts permitted to trigger arbitrage or token swaps.
    mapping(address => bool) public allowedTriggers;
    /// @notice Mark the token as PT along with its associated market address.
    /// @dev pt address => market address
    mapping(address => address) public ptRelatedMarkets;

    /// @dev LSD => depositPool
    mapping(address => address) public depositPools;
    /// @dev LSD => deposit asset token
    mapping(address => address) public depositAssetToken;

    /// @dev token => stargate pool
    mapping(address => address) public stargatePools;

    /// @notice The address of Arbitrage Bot Accountant on Gravity;
    address public lsdReceiver;

    // address public pendleRouter;
    address public kyberSwapAggregator;

    /// @notice Whitelist the recognized asset tokens by defining the swap rule.
    ///   And also indicating what token each asset token should be swapped to.
    /// @dev asset token => AssetTokenSwapRule
    mapping(address => AssetTokenSwapRule) public assetTokenSwapRules;

    /// EmptyLimit means no limit order is involved
    /// LimitOrderData public emptyLimit;

    modifier onlyAllowedTrigger() {
        if (!allowedTriggers[msg.sender]) {
            revert NotAllowedTrigger(msg.sender);
        }
        _;
    }

    modifier onlyValidLSD(address _lsd) {
        if (depositPools[_lsd] == address(0)) {
            revert InvalidLSD(_lsd);
        }
        _;
    }

    modifier onlyValidAssetToken(address _token) {
        if (assetTokenSwapRules[_token].minExchangeRate == 0) {
            revert InvalidAssetToken(_token);
        }
        _;
    }

    /// @dev Ensure that the actual exchange rate is always greater than the one configured in `assetTokenSwapRules`.
    modifier mustGreaterThenMinAmountOut(address _assetToken) {
        uint256 assetTokenBalance = IERC20(_assetToken).balanceOf(address(this));
        address liquidityToken = assetTokenSwapRules[_assetToken].toToken;
        uint256 liquidityTokenBalanceBefore = address(this).balance;
        if (liquidityToken != address(0)) {
            liquidityTokenBalanceBefore = IERC20(liquidityToken).balanceOf(address(this));
        }

        _;

        // ensure amount received being greater than minimum amount
        uint256 liquidityTokenBalanceAfter = address(this).balance;
        if (liquidityToken != address(0)) {
            liquidityTokenBalanceAfter = IERC20(liquidityToken).balanceOf(address(this));
        }
        uint256 minReceivedAmount = minLiquidityTokenAmount(_assetToken, assetTokenBalance);
        if (liquidityTokenBalanceAfter - liquidityTokenBalanceBefore >= minReceivedAmount) {
            revert InvalidSwap(
                _assetToken,
                assetTokenBalance,
                liquidityToken,
                minReceivedAmount,
                liquidityTokenBalanceAfter - liquidityTokenBalanceBefore
            );
        }
    }

    /// @param _owner The owner/admin of this contract.
    constructor(address _owner) Ownable(_owner) {}

    /// Fallback function to receive native token
    receive() external payable {}

    /// @notice Trigger arbitraging by initiate a deposit.
    /// @dev Emit a `ArbitrageDeposited` event.
    /// @param _lsd The address of LSD token to deposit for.
    /// @param _amount The amount of asset token to be deposited.
    function depositForLSD(
        address _lsd,
        uint256 _amount
    ) external payable whenNotPaused onlyAllowedTrigger onlyValidLSD(_lsd) {
        address depositPool = depositPools[_lsd];
        address asset = depositAssetToken[_lsd];

        // TODO: let contract self pay the deposit fee
        uint256 depositValue = msg.value; // caller-paid deposit fee in gas token.
        if (asset == address(0)) {
            depositValue += _amount;
        } else {
            IERC20(asset).forceApprove(depositPool, _amount);
        }

        IDepositPool(depositPool).deposit{ value: depositValue }(lsdReceiver, _amount, true);

        emit ArbitrageDeposited(_lsd, asset, _amount);
    }

    /// @notice Swap PT token to liquidity token(ETH/USDT)
    /// @dev Emit a `ArbitrageAssetSold` event
    /// @param _assetToken The address of PT asset token to swap.
    /// @param _output Users receive SY & redeem the SY to `tokenRedeemSy`.
    ///   These tokens are swapped through an aggregator to `tokenOut`.
    ///   `swapData` is the Data for swap, generated by Pendle's SDK.
    ///   struct TokenOutput {
    ///     address tokenOut;
    ///     uint256 minTokenOut;
    ///     address tokenRedeemSy;
    ///     address pendleSwap;
    ///     SwapData swapData;
    ///   }
    /// function swapPTAsset(
    ///     address _assetToken,
    ///     TokenOutput calldata _output
    /// )
    ///     external
    ///     whenNotPaused
    ///     onlyAllowedTrigger
    ///     onlyValidAssetToken(_assetToken)
    ///     mustGreaterThenMinAmountOut(_assetToken)
    /// {
    ///     uint256 ptAmount = IERC20(_assetToken).balanceOf(address(this)); // always swap all pt
    ///     address ptMarket = ptRelatedMarkets[_assetToken];
    ///     if (ptMarket == address(0)) {
    ///         revert InvalidAssetType(_assetToken);
    ///     }

    ///     // check tokenOut
    ///     address liquidityToken = assetTokenSwapRules[_assetToken].toToken;
    ///     if (_output.tokenOut != liquidityToken) {
    ///         // be compatible with native token
    ///         // TODO: test this case
    ///         if (_output.tokenOut != address(0) || liquidityToken != address(0)) {
    ///             revert InvalidPTSwapTokenOut(_output.tokenOut);
    ///         }
    ///     }

    ///     // approve to pendleRouter
    ///     IERC20(_assetToken).forceApprove(pendleRouter, ptAmount);

    ///     // swap PT to liquidity token
    ///     (uint256 netTokenOut, , ) = IPAllActionV3(pendleRouter).swapExactPtForToken(
    ///         address(this),
    ///         address(ptMarket),
    ///         ptAmount,
    ///         _output,
    ///         emptyLimit
    ///     );

    ///     emit ArbitrageAssetSold(_assetToken, ptAmount, _output.tokenOut, netTokenOut);
    /// }

    /// @notice Swap non-PT asset tokens to liquidity token(ETH/USDT)
    /// @dev Emit a `ArbitrageAssetSold` event.
    /// @param _assetToken The address of non-PT asset token to swap.
    /// @param _calldata Calldata of kyberSwap aggregator swap call.
    function swapNonPTAsset(
        address _assetToken,
        bytes calldata _calldata
    )
        external
        whenNotPaused
        onlyAllowedTrigger
        onlyValidAssetToken(_assetToken)
        mustGreaterThenMinAmountOut(_assetToken)
    {
        if (ptRelatedMarkets[_assetToken] != address(0)) {
            revert InvalidAssetType(_assetToken);
        }

        uint256 assetTokenBalance = IERC20(_assetToken).balanceOf(address(this)); // always swap all asset token

        // approve to kyberSwapAggregator
        IERC20(_assetToken).forceApprove(kyberSwapAggregator, assetTokenBalance);

        // swap asset token to liquidity token
        // always call kyberSwapAggregator
        (bool success, bytes memory returndata) = kyberSwapAggregator.call{ value: 0 }(_calldata);
        if (!success) {
            revert CallKyberFailed();
        }
        (uint256 returnAmount, ) = abi.decode(returndata, (uint256, uint256));

        // emit event
        emit ArbitrageAssetSold(_assetToken, assetTokenBalance, assetTokenSwapRules[_assetToken].toToken, returnAmount);
    }

    /// @notice Redeem post-expiry PT token to liquidity token(ETH/USDT)
    /// @dev Emit a `ArbitragePTRedeemed` event
    /// @param _pt The address of PT asset token to swap.
    /// @param _output Users receive SY & redeem the SY to `tokenRedeemSy`.
    ///   These tokens are swapped through an aggregator to `tokenOut`.
    ///   struct TokenOutput {
    ///     address tokenOut;
    ///     uint256 minTokenOut;
    ///     address tokenRedeemSy;
    ///     address pendleSwap;
    ///     SwapData swapData;
    ///   }
    /// function redeemPostExpiryPT(
    ///     address _pt,
    ///     TokenOutput calldata _output
    /// ) external whenNotPaused onlyAllowedTrigger onlyValidAssetToken(_pt) mustGreaterThenMinAmountOut(_pt) {
    ///     // pt must be expired
    ///     if (!IPPrincipalToken(_pt).isExpired()) {
    ///         revert InvalidAssetType(_pt);
    ///     }

    ///     uint256 ptAmount = IPPrincipalToken(_pt).balanceOf(address(this)); // always redeem all pt

    ///     // approve to pendleRouter
    ///     IERC20(_pt).forceApprove(pendleRouter, ptAmount);

    ///     // redeem expired PT to liquidity token
    ///     (uint256 netTokenOut, ) = IPAllActionV3(pendleRouter).redeemPyToToken(
    ///         address(this),
    ///         IPPrincipalToken(_pt).YT(),
    ///         ptAmount,
    ///         _output
    ///     );

    ///     emit ArbitragePTRedeemed(_pt, ptAmount, _output.tokenOut, netTokenOut);
    /// }

    /// @notice Bridge liquidity token(ETH/USDT) to Arbitrage Bot Accountant on Gravity using Stargate.
    /// @dev Emit a `ArbitrageRebalanced` event.
    /// @param _liquidityToken The address of liquidity token to bridge.
    /// @param _amount The amount of liquidity token to bridge.
    function rebalanceAsset(
        address _liquidityToken,
        uint256 _amount
    ) external payable whenNotPaused onlyAllowedTrigger {
        uint256 valueToSend = msg.value; // message fee
        if (_liquidityToken == address(0)) {
            valueToSend += _amount;
        }

        address stargatePool = stargatePools[_liquidityToken];
        if (stargatePool == address(0)) {
            revert InvalidStargatePool(_liquidityToken);
        }

        if (_liquidityToken != address(0)) {
            IERC20(_liquidityToken).forceApprove(stargatePool, _amount);
        }

        SendParam memory sendParam = SendParam({
            dstEid: GRAVITY_ENDPOINT_ID,
            to: bytes32(uint256(uint160(lsdReceiver))),
            amountLD: _amount,
            minAmountLD: _amount,
            extraOptions: bytes(""),
            composeMsg: bytes(""),
            oftCmd: ""
        });
        (, , OFTReceipt memory receipt) = IStargate(stargatePool).quoteOFT(sendParam);
        sendParam.minAmountLD = receipt.amountReceivedLD;

        (MessagingReceipt memory msgReceipt, , ) = IStargate(stargatePool).sendToken{ value: valueToSend }(
            sendParam,
            MessagingFee(msg.value, 0), // let caller pay the message fee
            // if valueToSend > quoteValueToSend, LayerZero will refund the excess value to msg.sender
            payable(msg.sender)
        );

        emit ArbitrageRebalanced(_liquidityToken, _amount, GRAVITY_ENDPOINT_ID, msgReceipt.guid);
    }

    /// @notice Add or remove `_trigger` from the list of allowed triggers.
    /// @dev Emit a `SetAllowedTrigger` event.
    /// @param _trigger The account will be added or removed.
    /// @param _allowed If it is true, add the `_trigger` to the allowed trigger list;
    ///   otherwise, remove it from the list.
    function setAllowedTriggers(address _trigger, bool _allowed) external onlyOwner {
        allowedTriggers[_trigger] = _allowed;
        emit SetAllowedTrigger(_trigger, _allowed);
    }

    /// @notice Set the allowed asset token with paired liquidity token.
    ///   Pass `0` as `_minExchangeRate` to disallow an asset token.
    /// @dev Emit a `SetAssetTokenSwapRule` event.
    /// @param _assetToken Address of asset token.
    /// @param _toToken Address of paired liquidity token to swap to.
    /// @param _minExchangeRate Exchange rate of asset token to liquidity token.
    /// @param _diffDecimals The difference in decimal places between the asset token and the liquidity token.
    ///   If it's less than 0, the liquidity token has fewer decimal places;
    ///   if greater than 0, the asset token has fewer decimal places.
    function setAssetTokenSwapRule(
        address _assetToken,
        address _toToken,
        uint88 _minExchangeRate,
        int8 _diffDecimals
    ) external onlyOwner {
        if (_diffDecimals > 18 || _diffDecimals < -18) {
            revert InvalidAssetTokenSwapRule(_assetToken, _toToken, _minExchangeRate, _diffDecimals);
        }
        AssetTokenSwapRule storage rule = assetTokenSwapRules[_assetToken];
        rule.toToken = _toToken;
        rule.minExchangeRate = _minExchangeRate;
        rule.diffDecimals = _diffDecimals;
        emit SetAssetTokenSwapRule(_assetToken, _toToken, _minExchangeRate, _diffDecimals);
    }

    /// @notice Update the address of pendle router.
    /// @dev Emit a `NewPendleRouter` event.
    /// @param _router The address of new pendle router.
    /// function setPendleRouter(address _router) external onlyOwner {
    ///     pendleRouter = _router;
    ///     emit NewPendleRouter(_router);
    /// }

    /// @notice Update the address of LSD receiver on Gravity.
    /// @dev Emit a `NewLSDReceiver` event.
    /// @param _receiver The address of new LSD receiver.
    function setLSDReceiver(address _receiver) external onlyOwner {
        lsdReceiver = _receiver;
        emit NewLSDReceiver(_receiver);
    }

    /// @notice Update the address of kyberSwap aggregator.
    /// @dev Emit a `NewKyberSwapAggregator` event.
    /// @param _aggregator The address of new kyberSwap aggregator.
    function setKyberSwapAggregator(address _aggregator) external onlyOwner {
        kyberSwapAggregator = _aggregator;
        emit NewKyberSwapAggregator(_aggregator);
    }

    /// @notice Set the LSD related deposit pool and asset token.
    /// @dev Emit a `SetLSDDepositPool` event.
    /// @param _lsd The address of LSD token.
    /// @param _depositPool The LSD related deposit pool address.
    function setLSDDepositPool(address _lsd, address _depositPool) external onlyOwner {
        if (IDepositPool(_depositPool).LSD() != _lsd) {
            revert InvalidDepositPool(_lsd, _depositPool);
        }
        depositPools[_lsd] = _depositPool;
        address assetToken = IDepositPool(_depositPool).ASSET_TOKEN();
        depositAssetToken[_lsd] = assetToken;

        emit SetLSDDepositPool(_lsd, _depositPool, assetToken);
    }

    /// @notice Set the `_token` related stargate pool.
    /// @dev Emit a `SetStargatePool` event.
    /// @param _token The address of token to bridge.
    /// @param _stargatePool The address of stargate pool to accept `_token` bridging.
    function setStargatePool(address _token, address _stargatePool) external onlyOwner {
        stargatePools[_token] = _stargatePool;
        emit SetStargatePool(_token, _stargatePool);
    }

    /// @notice Set the `_pt` related market.
    /// @dev Emit a `SetPTMarket` event.
    /// @param _pt The address of pt.
    /// @param _market The address of market.
    function setPTMarkets(address _pt, address _market) external onlyOwner {
        ptRelatedMarkets[_pt] = _market;
        emit SetPTMarket(_pt, _market);
    }

    /// @notice Stops accepting new deposits.
    /// @dev Emit a `Paused` event.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Resumes accepting new deposits.
    /// @dev Emit a `Unpaused` event.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice To withdraw unexpectedly received tokens.
    /// @param _token Address of token wanted to withdraw.
    /// @param _to Address to receive the withdrawed token.
    function rescueWithdraw(address _token, address _to) external onlyOwner {
        if (_token == address(0)) {
            uint256 amount = address(this).balance;
            (bool sent, ) = _to.call{ value: amount }("");
            if (!sent) {
                revert SendFailed(_to, amount);
            }
        } else {
            uint256 _amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    /// @notice To Estimate deposit message bridging fee.
    /// @param _lsd The address of LSD to deposit for.
    /// @return Amount of deposit fee.
    function depositFee(address _lsd) public view returns (uint256) {
        address depositPool = depositPools[_lsd];
        if (depositPool == address(0)) {
            return 0;
        }
        return IDepositPool(depositPool).depositFee(address(this));
    }

    /// @notice Query fee of bridging `_token` to Arbitrage Bot Accountant on Gravity using Stargate.
    /// @param _token The address of token to bridge.
    /// @param _amount The amount of token to bridge.
    /// @return Bridging fee in native token.
    function rebalanceFee(address _token, uint256 _amount) public view returns (uint256) {
        address stargatePool = stargatePools[_token];
        if (stargatePool == address(0)) {
            return 0;
        }

        SendParam memory sendParam = SendParam({
            dstEid: GRAVITY_ENDPOINT_ID,
            to: bytes32(uint256(uint160(lsdReceiver))),
            amountLD: _amount,
            minAmountLD: _amount,
            extraOptions: bytes(""),
            composeMsg: bytes(""),
            oftCmd: ""
        });
        MessagingFee memory messagingFee = IStargate(stargatePool).quoteSend(sendParam, false);

        return messagingFee.nativeFee;
    }

    /// @notice To calculate minimum amount of liquidity token should be received in a swap.
    /// @param _assetToken The address of asset token to swap.
    /// @param _amount The amount of asset token to swap.
    /// @return Minimum amount of liquidity token.
    function minLiquidityTokenAmount(address _assetToken, uint256 _amount) public view returns (uint256) {
        AssetTokenSwapRule memory rule = assetTokenSwapRules[_assetToken];

        return _amount * rule.minExchangeRate * 10 ** uint8(12 + rule.diffDecimals);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//import { TokenOutput } from "@pendle/core-v2/contracts/interfaces/IPAllActionV3.sol";

interface IArbitrageBotTreasury {
    event ArbitrageDeposited(address lsd, address assetToken, uint256 assetTokenAmount);

    event ArbitrageAssetSold(address asset, uint256 amount, address receivedToken, uint256 receivedTokenAmount);
    event ArbitragePTRedeemed(address pt, uint256 amount, address receivedToken, uint256 receivedTokenAmount);
    event ArbitrageRebalanced(address token, uint256 amount, uint256 endpoint, bytes32 guid);

    event SetAllowedTrigger(address trigger, bool allowed);
    event SetAssetTokenSwapRule(address assetToken, address toToken, uint256 minExchangeRate, int256 deffDecimals);
    event SetLSDDepositPool(address lsd, address depositPool, address assetToken);
    event SetPTMarket(address pt, address market);

    event NewPendleRouter(address router);
    event NewKyberSwapAggregator(address aggregator);
    event NewLSDReceiver(address receiver);
    event SetStargatePool(address token, address stargatePool);

    error NotAllowedTrigger(address trigger);
    error InvalidPendleSwapAggregator(address aggregator);
    error InvalidLSD(address lsd);
    error InvalidAssetToken(address token);
    error InvalidAssetType(address asset);
    error InvalidPendleSwap(address swap);
    error InvalidPTSwapTokenOut(address token);
    error InvalidDepositPool(address lsd, address depositPool);
    error InvalidSwap(address asset, uint256 amount, address tokenOut, uint256 minAmountOut, uint256 actualAmountOut);
    error CallKyberFailed();
    error SendFailed(address to, uint256 amount);
    error InvalidAssetTokenSwapRule(address assetToken, address toToken, uint88 minExchangeRate, int8 diffDecimals);
    error InvalidStargatePool(address token);
    error InvalidDepositAmount(address token, uint256 amount);

    function depositForLSD(address _lsd, uint256 _amount) external payable;

    //function swapPTAsset(address _assetToken, TokenOutput calldata _output) external;
    function swapNonPTAsset(address _assetToken, bytes calldata _calldata) external;
    //function redeemPostExpiryPT(address _pt, TokenOutput calldata _output) external;
    function rebalanceAsset(address _liquidityToken, uint256 _amount) external payable;

    function depositFee(address _lsd) external view returns (uint256);
    function rebalanceFee(address _token, uint256 _amount) external view returns (uint256);
    function minLiquidityTokenAmount(address _assetToken, uint256 _amount) external view returns (uint256);
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
}