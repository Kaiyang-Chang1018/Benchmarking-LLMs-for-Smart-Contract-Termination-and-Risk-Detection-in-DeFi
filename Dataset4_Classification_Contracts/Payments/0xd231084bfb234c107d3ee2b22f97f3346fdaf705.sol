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

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { SetConfigParam } from "./IMessageLibManager.sol";

enum MessageLibType {
    Send,
    Receive,
    SendAndReceive
}

interface IMessageLib is IERC165 {
    function setConfig(address _oapp, SetConfigParam[] calldata _config) external;

    function getConfig(uint32 _eid, address _oapp, uint32 _configType) external view returns (bytes memory config);

    function isSupportedEid(uint32 _eid) external view returns (bool);

    // message libs of same major version are compatible
    function version() external view returns (uint64 major, uint8 minor, uint8 endpointVersion);

    function messageLibType() external view returns (MessageLibType);
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

    function setDefaultReceiveLibrary(uint32 _eid, address _newLib, uint256 _timeout) external;

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

    function setReceiveLibraryTimeout(address _oapp, uint32 _eid, address _lib, uint256 _gracePeriod) external;

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

pragma solidity >=0.8.0;

import { MessagingFee } from "./ILayerZeroEndpointV2.sol";
import { IMessageLib } from "./IMessageLib.sol";

struct Packet {
    uint64 nonce;
    uint32 srcEid;
    address sender;
    uint32 dstEid;
    bytes32 receiver;
    bytes32 guid;
    bytes message;
}

interface ISendLib is IMessageLib {
    function send(
        Packet calldata _packet,
        bytes calldata _options,
        bool _payInLzToken
    ) external returns (MessagingFee memory, bytes memory encodedPacket);

    function quote(
        Packet calldata _packet,
        bytes calldata _options,
        bool _payInLzToken
    ) external view returns (MessagingFee memory);

    function setTreasury(address _treasury) external;

    function withdrawFee(address _to, uint256 _amount) external;

    function withdrawLzTokenFee(address _lzToken, address _to, uint256 _amount) external;
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

library AddressCast {
    error AddressCast_InvalidSizeForAddress();
    error AddressCast_InvalidAddress();

    function toBytes32(bytes calldata _addressBytes) internal pure returns (bytes32 result) {
        if (_addressBytes.length > 32) revert AddressCast_InvalidAddress();
        result = bytes32(_addressBytes);
        unchecked {
            uint256 offset = 32 - _addressBytes.length;
            result = result >> (offset * 8);
        }
    }

    function toBytes32(address _address) internal pure returns (bytes32 result) {
        result = bytes32(uint256(uint160(_address)));
    }

    function toBytes(bytes32 _addressBytes32, uint256 _size) internal pure returns (bytes memory result) {
        if (_size == 0 || _size > 32) revert AddressCast_InvalidSizeForAddress();
        result = new bytes(_size);
        unchecked {
            uint256 offset = 256 - _size * 8;
            assembly {
                mstore(add(result, 32), shl(offset, _addressBytes32))
            }
        }
    }

    function toAddress(bytes32 _addressBytes32) internal pure returns (address result) {
        result = address(uint160(uint256(_addressBytes32)));
    }

    function toAddress(bytes calldata _addressBytes) internal pure returns (address result) {
        if (_addressBytes.length != 20) revert AddressCast_InvalidAddress();
        result = address(bytes20(_addressBytes));
    }
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
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { AddressCast } from "./AddressCast.sol";

library GUID {
    using AddressCast for address;

    function generate(
        uint64 _nonce,
        uint32 _srcEid,
        address _sender,
        uint32 _dstEid,
        bytes32 _receiver
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce, _srcEid, _sender.toBytes32(), _dstEid, _receiver));
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Transfer {
    using SafeERC20 for IERC20;

    address internal constant ADDRESS_ZERO = address(0);

    error Transfer_NativeFailed(address _to, uint256 _value);
    error Transfer_ToAddressIsZero();

    function native(address _to, uint256 _value) internal {
        if (_to == ADDRESS_ZERO) revert Transfer_ToAddressIsZero();
        (bool success, ) = _to.call{ value: _value }("");
        if (!success) revert Transfer_NativeFailed(_to, _value);
    }

    function token(address _token, address _to, uint256 _value) internal {
        if (_to == ADDRESS_ZERO) revert Transfer_ToAddressIsZero();
        IERC20(_token).safeTransfer(_to, _value);
    }

    function nativeOrToken(address _token, address _to, uint256 _value) internal {
        if (_token == ADDRESS_ZERO) {
            native(_to, _value);
        } else {
            token(_token, _to, _value);
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
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Packet } from "../../interfaces/ISendLib.sol";
import { AddressCast } from "../../libs/AddressCast.sol";

library PacketV1Codec {
    using AddressCast for address;
    using AddressCast for bytes32;

    uint8 internal constant PACKET_VERSION = 1;

    // header (version + nonce + path)
    // version
    uint256 private constant PACKET_VERSION_OFFSET = 0;
    //    nonce
    uint256 private constant NONCE_OFFSET = 1;
    //    path
    uint256 private constant SRC_EID_OFFSET = 9;
    uint256 private constant SENDER_OFFSET = 13;
    uint256 private constant DST_EID_OFFSET = 45;
    uint256 private constant RECEIVER_OFFSET = 49;
    // payload (guid + message)
    uint256 private constant GUID_OFFSET = 81; // keccak256(nonce + path)
    uint256 private constant MESSAGE_OFFSET = 113;

    function encode(Packet memory _packet) internal pure returns (bytes memory encodedPacket) {
        encodedPacket = abi.encodePacked(
            PACKET_VERSION,
            _packet.nonce,
            _packet.srcEid,
            _packet.sender.toBytes32(),
            _packet.dstEid,
            _packet.receiver,
            _packet.guid,
            _packet.message
        );
    }

    function encodePacketHeader(Packet memory _packet) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                PACKET_VERSION,
                _packet.nonce,
                _packet.srcEid,
                _packet.sender.toBytes32(),
                _packet.dstEid,
                _packet.receiver
            );
    }

    function encodePayload(Packet memory _packet) internal pure returns (bytes memory) {
        return abi.encodePacked(_packet.guid, _packet.message);
    }

    function header(bytes calldata _packet) internal pure returns (bytes calldata) {
        return _packet[0:GUID_OFFSET];
    }

    function version(bytes calldata _packet) internal pure returns (uint8) {
        return uint8(bytes1(_packet[PACKET_VERSION_OFFSET:NONCE_OFFSET]));
    }

    function nonce(bytes calldata _packet) internal pure returns (uint64) {
        return uint64(bytes8(_packet[NONCE_OFFSET:SRC_EID_OFFSET]));
    }

    function srcEid(bytes calldata _packet) internal pure returns (uint32) {
        return uint32(bytes4(_packet[SRC_EID_OFFSET:SENDER_OFFSET]));
    }

    function sender(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[SENDER_OFFSET:DST_EID_OFFSET]);
    }

    function senderAddressB20(bytes calldata _packet) internal pure returns (address) {
        return sender(_packet).toAddress();
    }

    function dstEid(bytes calldata _packet) internal pure returns (uint32) {
        return uint32(bytes4(_packet[DST_EID_OFFSET:RECEIVER_OFFSET]));
    }

    function receiver(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[RECEIVER_OFFSET:GUID_OFFSET]);
    }

    function receiverB20(bytes calldata _packet) internal pure returns (address) {
        return receiver(_packet).toAddress();
    }

    function guid(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[GUID_OFFSET:MESSAGE_OFFSET]);
    }

    function message(bytes calldata _packet) internal pure returns (bytes calldata) {
        return bytes(_packet[MESSAGE_OFFSET:]);
    }

    function payload(bytes calldata _packet) internal pure returns (bytes calldata) {
        return bytes(_packet[GUID_OFFSET:]);
    }

    function payloadHash(bytes calldata _packet) internal pure returns (bytes32) {
        return keccak256(payload(_packet));
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

import "./ILayerZeroUserApplicationConfig.sol";

interface ILayerZeroMessagingLibrary {
    // send(), messages will be inflight.
    function send(
        address _userApplication,
        uint64 _lastNonce,
        uint16 _chainId,
        bytes calldata _destination,
        bytes calldata _payload,
        address payable refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    // estimate native fee at the send side
    function estimateFees(
        uint16 _chainId,
        address _userApplication,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParam
    ) external view returns (uint nativeFee, uint zroFee);

    //---------------------------------------------------------------------------
    // setConfig / getConfig are User Application (UA) functions to specify Oracle, Relayer, blockConfirmations, libraryVersion
    function setConfig(uint16 _chainId, address _userApplication, uint _configType, bytes calldata _config) external;

    function getConfig(
        uint16 _chainId,
        address _userApplication,
        uint _configType
    ) external view returns (bytes memory);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

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
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
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
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

/// @dev simply a container of endpoint address and local eid
abstract contract MessageLibBase {
    address internal immutable endpoint;
    uint32 internal immutable localEid;

    error LZ_MessageLib_OnlyEndpoint();

    modifier onlyEndpoint() {
        if (endpoint != msg.sender) revert LZ_MessageLib_OnlyEndpoint();
        _;
    }

    constructor(address _endpoint, uint32 _localEid) {
        endpoint = _endpoint;
        localEid = _localEid;
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Transfer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/Transfer.sol";

import { ILayerZeroExecutor } from "./interfaces/ILayerZeroExecutor.sol";
import { ILayerZeroTreasury } from "./interfaces/ILayerZeroTreasury.sol";
import { SafeCall } from "./libs/SafeCall.sol";
import { MessageLibBase } from "./MessageLibBase.sol";

struct WorkerOptions {
    uint8 workerId;
    bytes options;
}

struct SetDefaultExecutorConfigParam {
    uint32 eid;
    ExecutorConfig config;
}

struct ExecutorConfig {
    uint32 maxMessageSize;
    address executor;
}

/// @dev base contract for both SendLibBaseE1 and SendLibBaseE2
abstract contract SendLibBase is MessageLibBase, Ownable {
    using SafeCall for address;

    address private constant DEFAULT_CONFIG = address(0);
    uint16 internal constant TREASURY_MAX_COPY = 32;

    uint256 internal immutable treasuryGasLimit;
    uint256 internal treasuryNativeFeeCap;

    // config
    address public treasury;
    mapping(address oapp => mapping(uint32 eid => ExecutorConfig)) public executorConfigs;

    // accumulated fees for workers and treasury
    mapping(address worker => uint256) public fees;

    event ExecutorFeePaid(address executor, uint256 fee);
    event TreasurySet(address treasury);
    event DefaultExecutorConfigsSet(SetDefaultExecutorConfigParam[] params);
    event ExecutorConfigSet(address oapp, uint32 eid, ExecutorConfig config);
    event TreasuryNativeFeeCapSet(uint256 newTreasuryNativeFeeCap);

    error LZ_MessageLib_InvalidMessageSize(uint256 actual, uint256 max);
    error LZ_MessageLib_InvalidAmount(uint256 requested, uint256 available);
    error LZ_MessageLib_TransferFailed();
    error LZ_MessageLib_InvalidExecutor();
    error LZ_MessageLib_ZeroMessageSize();

    constructor(
        address _endpoint,
        uint32 _localEid,
        uint256 _treasuryGasLimit,
        uint256 _treasuryNativeFeeCap
    ) MessageLibBase(_endpoint, _localEid) {
        treasuryGasLimit = _treasuryGasLimit;
        treasuryNativeFeeCap = _treasuryNativeFeeCap;
    }

    function setDefaultExecutorConfigs(SetDefaultExecutorConfigParam[] calldata _params) external onlyOwner {
        for (uint256 i = 0; i < _params.length; ++i) {
            SetDefaultExecutorConfigParam calldata param = _params[i];

            if (param.config.executor == address(0x0)) revert LZ_MessageLib_InvalidExecutor();
            if (param.config.maxMessageSize == 0) revert LZ_MessageLib_ZeroMessageSize();

            executorConfigs[DEFAULT_CONFIG][param.eid] = param.config;
        }
        emit DefaultExecutorConfigsSet(_params);
    }

    /// @dev the new value can not be greater than the old value, i.e. down only
    function setTreasuryNativeFeeCap(uint256 _newTreasuryNativeFeeCap) external onlyOwner {
        // assert the new value is no greater than the old value
        if (_newTreasuryNativeFeeCap > treasuryNativeFeeCap)
            revert LZ_MessageLib_InvalidAmount(_newTreasuryNativeFeeCap, treasuryNativeFeeCap);
        treasuryNativeFeeCap = _newTreasuryNativeFeeCap;
        emit TreasuryNativeFeeCapSet(_newTreasuryNativeFeeCap);
    }

    // ============================ View ===================================
    // @dev get the executor config and if not set, return the default config
    function getExecutorConfig(address _oapp, uint32 _remoteEid) public view returns (ExecutorConfig memory rtnConfig) {
        ExecutorConfig storage defaultConfig = executorConfigs[DEFAULT_CONFIG][_remoteEid];
        ExecutorConfig storage customConfig = executorConfigs[_oapp][_remoteEid];

        uint32 maxMessageSize = customConfig.maxMessageSize;
        rtnConfig.maxMessageSize = maxMessageSize != 0 ? maxMessageSize : defaultConfig.maxMessageSize;

        address executor = customConfig.executor;
        rtnConfig.executor = executor != address(0x0) ? executor : defaultConfig.executor;
    }

    // ======================= Internal =======================
    function _assertMessageSize(uint256 _actual, uint256 _max) internal pure {
        if (_actual > _max) revert LZ_MessageLib_InvalidMessageSize(_actual, _max);
    }

    function _payExecutor(
        address _executor,
        uint32 _dstEid,
        address _sender,
        uint256 _msgSize,
        bytes memory _executorOptions
    ) internal returns (uint256 executorFee) {
        executorFee = ILayerZeroExecutor(_executor).assignJob(_dstEid, _sender, _msgSize, _executorOptions);
        if (executorFee > 0) {
            fees[_executor] += executorFee;
        }
        emit ExecutorFeePaid(_executor, executorFee);
    }

    function _payTreasury(
        address _sender,
        uint32 _dstEid,
        uint256 _totalNativeFee,
        bool _payInLzToken
    ) internal returns (uint256 treasuryNativeFee, uint256 lzTokenFee) {
        if (treasury != address(0x0)) {
            bytes memory callData = abi.encodeCall(
                ILayerZeroTreasury.payFee,
                (_sender, _dstEid, _totalNativeFee, _payInLzToken)
            );
            (bool success, bytes memory result) = treasury.safeCall(treasuryGasLimit, 0, TREASURY_MAX_COPY, callData);

            (treasuryNativeFee, lzTokenFee) = _parseTreasuryResult(_totalNativeFee, _payInLzToken, success, result);
            // fee should be in lzTokenFee if payInLzToken, otherwise in native
            if (treasuryNativeFee > 0) {
                fees[treasury] += treasuryNativeFee;
            }
        }
    }

    /// @dev the abstract process for quote() is:
    /// 0/ split out the executor options and options of other workers
    /// 1/ quote workers
    /// 2/ quote executor
    /// 3/ quote treasury
    /// @return nativeFee, lzTokenFee
    function _quote(
        address _sender,
        uint32 _dstEid,
        uint256 _msgSize,
        bool _payInLzToken,
        bytes calldata _options
    ) internal view returns (uint256, uint256) {
        (bytes memory executorOptions, WorkerOptions[] memory validationOptions) = _splitOptions(_options);

        // quote the verifier used in the library. for ULN, it is a list of DVNs
        uint256 nativeFee = _quoteVerifier(_sender, _dstEid, validationOptions);

        // quote executor
        ExecutorConfig memory config = getExecutorConfig(_sender, _dstEid);
        // assert msg size
        _assertMessageSize(_msgSize, config.maxMessageSize);

        nativeFee += ILayerZeroExecutor(config.executor).getFee(_dstEid, _sender, _msgSize, executorOptions);

        // quote treasury
        (uint256 treasuryNativeFee, uint256 lzTokenFee) = _quoteTreasury(_sender, _dstEid, nativeFee, _payInLzToken);
        nativeFee += treasuryNativeFee;

        return (nativeFee, lzTokenFee);
    }

    /// @dev this interface should be DoS-free if the user is paying with native. properties
    /// 1/ treasury can return an overly high lzToken fee
    /// 2/ if treasury returns an overly high native fee, it will be capped by maxNativeFee,
    ///    which can be reasoned with the configurations
    /// 3/ the owner can not configure the treasury in a way that force this function to revert
    function _quoteTreasury(
        address _sender,
        uint32 _dstEid,
        uint256 _totalNativeFee,
        bool _payInLzToken
    ) internal view returns (uint256 nativeFee, uint256 lzTokenFee) {
        // treasury must be set, and it has to be a contract
        if (treasury != address(0x0)) {
            bytes memory callData = abi.encodeCall(
                ILayerZeroTreasury.getFee,
                (_sender, _dstEid, _totalNativeFee, _payInLzToken)
            );
            (bool success, bytes memory result) = treasury.safeStaticCall(
                treasuryGasLimit,
                TREASURY_MAX_COPY,
                callData
            );

            return _parseTreasuryResult(_totalNativeFee, _payInLzToken, success, result);
        }
    }

    function _parseTreasuryResult(
        uint256 _totalNativeFee,
        bool _payInLzToken,
        bool _success,
        bytes memory _result
    ) internal view returns (uint256 nativeFee, uint256 lzTokenFee) {
        // failure, charges nothing
        if (!_success || _result.length < TREASURY_MAX_COPY) return (0, 0);

        // parse the result
        uint256 treasureFeeQuote = abi.decode(_result, (uint256));
        if (_payInLzToken) {
            lzTokenFee = treasureFeeQuote;
        } else {
            // pay in native
            // we must prevent high-treasuryFee Dos attack
            // nativeFee = min(treasureFeeQuote, maxNativeFee)
            // opportunistically raise the maxNativeFee to be the same as _totalNativeFee
            // can't use the _totalNativeFee alone because the oapp can use custom workers to force the fee to 0.
            // maxNativeFee = max (_totalNativeFee, treasuryNativeFeeCap)
            uint256 maxNativeFee = _totalNativeFee > treasuryNativeFeeCap ? _totalNativeFee : treasuryNativeFeeCap;

            // min (treasureFeeQuote, nativeFeeCap)
            nativeFee = treasureFeeQuote > maxNativeFee ? maxNativeFee : treasureFeeQuote;
        }
    }

    /// @dev authenticated by msg.sender only
    function _debitFee(uint256 _amount) internal {
        uint256 fee = fees[msg.sender];
        if (_amount > fee) revert LZ_MessageLib_InvalidAmount(_amount, fee);
        unchecked {
            fees[msg.sender] = fee - _amount;
        }
    }

    function _setTreasury(address _treasury) internal {
        treasury = _treasury;
        emit TreasurySet(_treasury);
    }

    function _setExecutorConfig(uint32 _remoteEid, address _oapp, ExecutorConfig memory _config) internal {
        executorConfigs[_oapp][_remoteEid] = _config;
        emit ExecutorConfigSet(_oapp, _remoteEid, _config);
    }

    // ======================= Virtual =======================
    /// @dev these two functions will be overridden with specific logics of the library function
    function _quoteVerifier(
        address _oapp,
        uint32 _eid,
        WorkerOptions[] memory _options
    ) internal view virtual returns (uint256 nativeFee);

    /// @dev this function will split the options into executorOptions and validationOptions
    function _splitOptions(
        bytes calldata _options
    ) internal view virtual returns (bytes memory executorOptions, WorkerOptions[] memory validationOptions);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface ILayerZeroExecutor {
    // @notice query price and assign jobs at the same time
    // @param _dstEid - the destination endpoint identifier
    // @param _sender - the source sending contract address. executors may apply price discrimination to senders
    // @param _calldataSize - dynamic data size of message + caller params
    // @param _options - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function assignJob(
        uint32 _dstEid,
        address _sender,
        uint256 _calldataSize,
        bytes calldata _options
    ) external returns (uint256 price);

    // @notice query the executor price for relaying the payload and its proof to the destination chain
    // @param _dstEid - the destination endpoint identifier
    // @param _sender - the source sending contract address. executors may apply price discrimination to senders
    // @param _calldataSize - dynamic data size of message + caller params
    // @param _options - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function getFee(
        uint32 _dstEid,
        address _sender,
        uint256 _calldataSize,
        bytes calldata _options
    ) external view returns (uint256 price);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface ILayerZeroTreasury {
    function getFee(
        address _sender,
        uint32 _dstEid,
        uint256 _totalNativeFee,
        bool _payInLzToken
    ) external view returns (uint256 fee);

    function payFee(
        address _sender,
        uint32 _dstEid,
        uint256 _totalNativeFee,
        bool _payInLzToken
    ) external payable returns (uint256 fee);
}
// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.20;

/// @dev copied from https://github.com/nomad-xyz/ExcessivelySafeCall/blob/main/src/ExcessivelySafeCall.sol.
library SafeCall {
    /// @notice calls a contract with a specified gas limit and value and captures the return data
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _value The value in wei to send to the remote contract
    /// to memory.
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function safeCall(
        address _target,
        uint256 _gas,
        uint256 _value,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal returns (bool, bytes memory) {
        // check that target has code
        uint size;
        assembly {
            size := extcodesize(_target)
        }
        if (size == 0) {
            return (false, new bytes(0));
        }

        // set up for assembly call
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := call(
                _gas, // gas
                _target, // recipient
                _value, // ether value
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 100 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param _target The address to call
    /// @param _gas The amount of gas to forward to the remote contract
    /// @param _maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param _calldata The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `_maxCopy` bytes.
    function safeStaticCall(
        address _target,
        uint256 _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal view returns (bool, bytes memory) {
        // check that target has code
        uint size;
        assembly {
            size := extcodesize(_target)
        }
        if (size == 0) {
            return (false, new bytes(0));
        }

        // set up for assembly call
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            _success := staticcall(
                _gas, // gas
                _target, // recipient
                add(_calldata, 0x20), // inloc
                mload(_calldata), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, _toCopy)
            // copy the bytes from returndata[0:_toCopy]
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Packet } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ISendLib.sol";
import { PacketV1Codec } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/PacketV1Codec.sol";

import { ILayerZeroDVN } from "./interfaces/ILayerZeroDVN.sol";
import { DVNOptions } from "./libs/DVNOptions.sol";
import { UlnOptions } from "./libs/UlnOptions.sol";
import { WorkerOptions } from "../SendLibBase.sol";
import { UlnConfig, UlnBase } from "./UlnBase.sol";

/// @dev includes the utility functions for checking ULN states and logics
abstract contract SendUlnBase is UlnBase {
    event DVNFeePaid(address[] requiredDVNs, address[] optionalDVNs, uint256[] fees);

    function _splitUlnOptions(bytes calldata _options) internal pure returns (bytes memory, WorkerOptions[] memory) {
        (bytes memory executorOpts, bytes memory dvnOpts) = UlnOptions.decode(_options);

        if (dvnOpts.length == 0) {
            return (executorOpts, new WorkerOptions[](0));
        }

        WorkerOptions[] memory workerOpts = new WorkerOptions[](1);
        workerOpts[0] = WorkerOptions(DVNOptions.WORKER_ID, dvnOpts);
        return (executorOpts, workerOpts);
    }

    /// ---------- pay and assign jobs ----------

    function _payDVNs(
        mapping(address => uint256) storage _fees,
        Packet memory _packet,
        WorkerOptions[] memory _options
    ) internal returns (uint256 totalFee, bytes memory encodedPacket) {
        bytes memory packetHeader = PacketV1Codec.encodePacketHeader(_packet);
        bytes memory payload = PacketV1Codec.encodePayload(_packet);
        bytes32 payloadHash = keccak256(payload);
        uint32 dstEid = _packet.dstEid;
        address sender = _packet.sender;
        UlnConfig memory config = getUlnConfig(sender, dstEid);

        // if options is not empty, it must be dvn options
        bytes memory dvnOptions = _options.length == 0 ? bytes("") : _options[0].options;
        uint256[] memory dvnFees;
        (totalFee, dvnFees) = _assignJobs(
            _fees,
            config,
            ILayerZeroDVN.AssignJobParam(dstEid, packetHeader, payloadHash, config.confirmations, sender),
            dvnOptions
        );
        encodedPacket = abi.encodePacked(packetHeader, payload);

        emit DVNFeePaid(config.requiredDVNs, config.optionalDVNs, dvnFees);
    }

    function _assignJobs(
        mapping(address => uint256) storage _fees,
        UlnConfig memory _ulnConfig,
        ILayerZeroDVN.AssignJobParam memory _param,
        bytes memory dvnOptions
    ) internal returns (uint256 totalFee, uint256[] memory dvnFees) {
        (bytes[] memory optionsArray, uint8[] memory dvnIds) = DVNOptions.groupDVNOptionsByIdx(dvnOptions);

        uint8 dvnsLength = _ulnConfig.requiredDVNCount + _ulnConfig.optionalDVNCount;
        dvnFees = new uint256[](dvnsLength);
        for (uint8 i = 0; i < dvnsLength; ++i) {
            address dvn = i < _ulnConfig.requiredDVNCount
                ? _ulnConfig.requiredDVNs[i]
                : _ulnConfig.optionalDVNs[i - _ulnConfig.requiredDVNCount];

            bytes memory options = "";
            for (uint256 j = 0; j < dvnIds.length; ++j) {
                if (dvnIds[j] == i) {
                    options = optionsArray[j];
                    break;
                }
            }

            dvnFees[i] = ILayerZeroDVN(dvn).assignJob(_param, options);
            if (dvnFees[i] > 0) {
                _fees[dvn] += dvnFees[i];
                totalFee += dvnFees[i];
            }
        }
    }

    /// ---------- quote ----------
    function _quoteDVNs(
        address _sender,
        uint32 _dstEid,
        WorkerOptions[] memory _options
    ) internal view returns (uint256 totalFee) {
        UlnConfig memory config = getUlnConfig(_sender, _dstEid);

        // if options is not empty, it must be dvn options
        bytes memory dvnOptions = _options.length == 0 ? bytes("") : _options[0].options;
        (bytes[] memory optionsArray, uint8[] memory dvnIndices) = DVNOptions.groupDVNOptionsByIdx(dvnOptions);

        totalFee = _getFees(config, _dstEid, _sender, optionsArray, dvnIndices);
    }

    function _getFees(
        UlnConfig memory _config,
        uint32 _dstEid,
        address _sender,
        bytes[] memory _optionsArray,
        uint8[] memory _dvnIds
    ) internal view returns (uint256 totalFee) {
        // here we merge 2 list of dvns into 1 to allocate the indexed dvn options to the right dvn
        uint8 dvnsLength = _config.requiredDVNCount + _config.optionalDVNCount;
        for (uint8 i = 0; i < dvnsLength; ++i) {
            address dvn = i < _config.requiredDVNCount
                ? _config.requiredDVNs[i]
                : _config.optionalDVNs[i - _config.requiredDVNCount];

            bytes memory options = "";
            // it is a double loop here. however, if the list is short, the cost is very acceptable.
            for (uint256 j = 0; j < _dvnIds.length; ++j) {
                if (_dvnIds[j] == i) {
                    options = _optionsArray[j];
                    break;
                }
            }
            totalFee += ILayerZeroDVN(dvn).getFee(_dstEid, _config.confirmations, _sender, options);
        }
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// the formal properties are documented in the setter functions
struct UlnConfig {
    uint64 confirmations;
    // we store the length of required DVNs and optional DVNs instead of using DVN.length directly to save gas
    uint8 requiredDVNCount; // 0 indicate DEFAULT, NIL_DVN_COUNT indicate NONE (to override the value of default)
    uint8 optionalDVNCount; // 0 indicate DEFAULT, NIL_DVN_COUNT indicate NONE (to override the value of default)
    uint8 optionalDVNThreshold; // (0, optionalDVNCount]
    address[] requiredDVNs; // no duplicates. sorted an an ascending order. allowed overlap with optionalDVNs
    address[] optionalDVNs; // no duplicates. sorted an an ascending order. allowed overlap with requiredDVNs
}

struct SetDefaultUlnConfigParam {
    uint32 eid;
    UlnConfig config;
}

/// @dev includes the utility functions for checking ULN states and logics
abstract contract UlnBase is Ownable {
    address private constant DEFAULT_CONFIG = address(0);
    // reserved values for
    uint8 internal constant DEFAULT = 0;
    uint8 internal constant NIL_DVN_COUNT = type(uint8).max;
    uint64 internal constant NIL_CONFIRMATIONS = type(uint64).max;
    // 127 to prevent total number of DVNs (127 * 2) exceeding uint8.max (255)
    // by limiting the total size, it would help constraint the design of DVNOptions
    uint8 private constant MAX_COUNT = (type(uint8).max - 1) / 2;

    mapping(address oapp => mapping(uint32 eid => UlnConfig)) internal ulnConfigs;

    error LZ_ULN_Unsorted();
    error LZ_ULN_InvalidRequiredDVNCount();
    error LZ_ULN_InvalidOptionalDVNCount();
    error LZ_ULN_AtLeastOneDVN();
    error LZ_ULN_InvalidOptionalDVNThreshold();
    error LZ_ULN_InvalidConfirmations();
    error LZ_ULN_UnsupportedEid(uint32 eid);

    event DefaultUlnConfigsSet(SetDefaultUlnConfigParam[] params);
    event UlnConfigSet(address oapp, uint32 eid, UlnConfig config);

    // ============================ OnlyOwner ===================================

    /// @dev about the DEFAULT ULN config
    /// 1) its values are all LITERAL (e.g. 0 is 0). whereas in the oapp ULN config, 0 (default value) points to the default ULN config
    ///     this design enables the oapp to point to DEFAULT config without explicitly setting the config
    /// 2) its configuration is more restrictive than the oapp ULN config that
    ///     a) it must not use NIL value, where NIL is used only by oapps to indicate the LITERAL 0
    ///     b) it must have at least one DVN
    function setDefaultUlnConfigs(SetDefaultUlnConfigParam[] calldata _params) external onlyOwner {
        for (uint256 i = 0; i < _params.length; ++i) {
            SetDefaultUlnConfigParam calldata param = _params[i];

            // 2.a must not use NIL
            if (param.config.requiredDVNCount == NIL_DVN_COUNT) revert LZ_ULN_InvalidRequiredDVNCount();
            if (param.config.optionalDVNCount == NIL_DVN_COUNT) revert LZ_ULN_InvalidOptionalDVNCount();
            if (param.config.confirmations == NIL_CONFIRMATIONS) revert LZ_ULN_InvalidConfirmations();

            // 2.b must have at least one dvn
            _assertAtLeastOneDVN(param.config);

            _setConfig(DEFAULT_CONFIG, param.eid, param.config);
        }
        emit DefaultUlnConfigsSet(_params);
    }

    // ============================ View ===================================
    // @dev assuming most oapps use default, we get default as memory and custom as storage to save gas
    function getUlnConfig(address _oapp, uint32 _remoteEid) public view returns (UlnConfig memory rtnConfig) {
        UlnConfig storage defaultConfig = ulnConfigs[DEFAULT_CONFIG][_remoteEid];
        UlnConfig storage customConfig = ulnConfigs[_oapp][_remoteEid];

        // if confirmations is 0, use default
        uint64 confirmations = customConfig.confirmations;
        if (confirmations == DEFAULT) {
            rtnConfig.confirmations = defaultConfig.confirmations;
        } else if (confirmations != NIL_CONFIRMATIONS) {
            // if confirmations is uint64.max, no block confirmations required
            rtnConfig.confirmations = confirmations;
        } // else do nothing, rtnConfig.confirmation is 0

        if (customConfig.requiredDVNCount == DEFAULT) {
            if (defaultConfig.requiredDVNCount > 0) {
                // copy only if count > 0. save gas
                rtnConfig.requiredDVNs = defaultConfig.requiredDVNs;
                rtnConfig.requiredDVNCount = defaultConfig.requiredDVNCount;
            } // else, do nothing
        } else {
            if (customConfig.requiredDVNCount != NIL_DVN_COUNT) {
                rtnConfig.requiredDVNs = customConfig.requiredDVNs;
                rtnConfig.requiredDVNCount = customConfig.requiredDVNCount;
            } // else, do nothing
        }

        if (customConfig.optionalDVNCount == DEFAULT) {
            if (defaultConfig.optionalDVNCount > 0) {
                // copy only if count > 0. save gas
                rtnConfig.optionalDVNs = defaultConfig.optionalDVNs;
                rtnConfig.optionalDVNCount = defaultConfig.optionalDVNCount;
                rtnConfig.optionalDVNThreshold = defaultConfig.optionalDVNThreshold;
            }
        } else {
            if (customConfig.optionalDVNCount != NIL_DVN_COUNT) {
                rtnConfig.optionalDVNs = customConfig.optionalDVNs;
                rtnConfig.optionalDVNCount = customConfig.optionalDVNCount;
                rtnConfig.optionalDVNThreshold = customConfig.optionalDVNThreshold;
            }
        }

        // the final value must have at least one dvn
        // it is possible that some default config result into 0 dvns
        _assertAtLeastOneDVN(rtnConfig);
    }

    /// @dev Get the uln config without the default config for the given remoteEid.
    function getAppUlnConfig(address _oapp, uint32 _remoteEid) external view returns (UlnConfig memory) {
        return ulnConfigs[_oapp][_remoteEid];
    }

    // ============================ Internal ===================================
    function _setUlnConfig(uint32 _remoteEid, address _oapp, UlnConfig memory _param) internal {
        _setConfig(_oapp, _remoteEid, _param);

        // get ULN config again as a catch all to ensure the config is valid
        getUlnConfig(_oapp, _remoteEid);
        emit UlnConfigSet(_oapp, _remoteEid, _param);
    }

    /// @dev a supported Eid must have a valid default uln config, which has at least one dvn
    function _isSupportedEid(uint32 _remoteEid) internal view returns (bool) {
        UlnConfig storage defaultConfig = ulnConfigs[DEFAULT_CONFIG][_remoteEid];
        return defaultConfig.requiredDVNCount > 0 || defaultConfig.optionalDVNThreshold > 0;
    }

    function _assertSupportedEid(uint32 _remoteEid) internal view {
        if (!_isSupportedEid(_remoteEid)) revert LZ_ULN_UnsupportedEid(_remoteEid);
    }

    // ============================ Private ===================================

    function _assertAtLeastOneDVN(UlnConfig memory _config) private pure {
        if (_config.requiredDVNCount == 0 && _config.optionalDVNThreshold == 0) revert LZ_ULN_AtLeastOneDVN();
    }

    /// @dev this private function is used in both setDefaultUlnConfigs and setUlnConfig
    function _setConfig(address _oapp, uint32 _eid, UlnConfig memory _param) private {
        // @dev required dvns
        // if dvnCount == NONE, dvns list must be empty
        // if dvnCount == DEFAULT, dvn list must be empty
        // otherwise, dvnList.length == dvnCount and assert the list is valid
        if (_param.requiredDVNCount == NIL_DVN_COUNT || _param.requiredDVNCount == DEFAULT) {
            if (_param.requiredDVNs.length != 0) revert LZ_ULN_InvalidRequiredDVNCount();
        } else {
            if (_param.requiredDVNs.length != _param.requiredDVNCount || _param.requiredDVNCount > MAX_COUNT)
                revert LZ_ULN_InvalidRequiredDVNCount();
            _assertNoDuplicates(_param.requiredDVNs);
        }

        // @dev optional dvns
        // if optionalDVNCount == NONE, optionalDVNs list must be empty and threshold must be 0
        // if optionalDVNCount == DEFAULT, optionalDVNs list must be empty and threshold must be 0
        // otherwise, optionalDVNs.length == optionalDVNCount, threshold > 0 && threshold <= optionalDVNCount and assert the list is valid

        // example use case: an oapp uses the DEFAULT 'required' but
        //     a) use a custom 1/1 dvn (practically a required dvn), or
        //     b) use a custom 2/3 dvn
        if (_param.optionalDVNCount == NIL_DVN_COUNT || _param.optionalDVNCount == DEFAULT) {
            if (_param.optionalDVNs.length != 0) revert LZ_ULN_InvalidOptionalDVNCount();
            if (_param.optionalDVNThreshold != 0) revert LZ_ULN_InvalidOptionalDVNThreshold();
        } else {
            if (_param.optionalDVNs.length != _param.optionalDVNCount || _param.optionalDVNCount > MAX_COUNT)
                revert LZ_ULN_InvalidOptionalDVNCount();
            if (_param.optionalDVNThreshold == 0 || _param.optionalDVNThreshold > _param.optionalDVNCount)
                revert LZ_ULN_InvalidOptionalDVNThreshold();
            _assertNoDuplicates(_param.optionalDVNs);
        }
        // don't assert valid count here, as it needs to be validated along side default config

        ulnConfigs[_oapp][_eid] = _param;
    }

    function _assertNoDuplicates(address[] memory _dvns) private pure {
        address lastDVN = address(0);
        for (uint256 i = 0; i < _dvns.length; i++) {
            address dvn = _dvns[i];
            if (dvn <= lastDVN) revert LZ_ULN_Unsorted(); // to ensure no duplicates
            lastDVN = dvn;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface ILayerZeroDVN {
    struct AssignJobParam {
        uint32 dstEid;
        bytes packetHeader;
        bytes32 payloadHash;
        uint64 confirmations;
        address sender;
    }

    // @notice query price and assign jobs at the same time
    // @param _dstEid - the destination endpoint identifier
    // @param _packetHeader - version + nonce + path
    // @param _payloadHash - hash of guid + message
    // @param _confirmations - block confirmation delay before relaying blocks
    // @param _sender - the source sending contract address
    // @param _options - options
    function assignJob(AssignJobParam calldata _param, bytes calldata _options) external payable returns (uint256 fee);

    // @notice query the dvn fee for relaying block information to the destination chain
    // @param _dstEid the destination endpoint identifier
    // @param _confirmations - block confirmation delay before relaying blocks
    // @param _sender - the source sending contract address
    // @param _options - options
    function getFee(
        uint32 _dstEid,
        uint64 _confirmations,
        address _sender,
        bytes calldata _options
    ) external view returns (uint256 fee);
}
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
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import { ExecutorOptions } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/ExecutorOptions.sol";

import { DVNOptions } from "./DVNOptions.sol";

library UlnOptions {
    using SafeCast for uint256;

    uint16 internal constant TYPE_1 = 1; // legacy options type 1
    uint16 internal constant TYPE_2 = 2; // legacy options type 2
    uint16 internal constant TYPE_3 = 3;

    error LZ_ULN_InvalidWorkerOptions(uint256 cursor);
    error LZ_ULN_InvalidWorkerId(uint8 workerId);
    error LZ_ULN_InvalidLegacyType1Option();
    error LZ_ULN_InvalidLegacyType2Option();
    error LZ_ULN_UnsupportedOptionType(uint16 optionType);

    /// @dev decode the options into executorOptions and dvnOptions
    /// @param _options the options can be either legacy options (type 1 or 2) or type 3 options
    /// @return executorOptions the executor options, share the same format of type 3 options
    /// @return dvnOptions the dvn options, share the same format of type 3 options
    function decode(
        bytes calldata _options
    ) internal pure returns (bytes memory executorOptions, bytes memory dvnOptions) {
        // at least 2 bytes for the option type, but can have no options
        if (_options.length < 2) revert LZ_ULN_InvalidWorkerOptions(0);

        uint16 optionsType = uint16(bytes2(_options[0:2]));
        uint256 cursor = 2;

        // type3 options: [worker_option][worker_option]...
        // worker_option: [worker_id][option_size][option]
        // worker_id: uint8, option_size: uint16, option: bytes
        if (optionsType == TYPE_3) {
            unchecked {
                uint256 start = cursor;
                uint8 lastWorkerId; // worker_id starts from 1, so 0 is an invalid worker_id

                // heuristic: we assume that the options are mostly EXECUTOR options only
                // checking the workerID can reduce gas usage for most cases
                while (cursor < _options.length) {
                    uint8 workerId = uint8(bytes1(_options[cursor:cursor + 1]));
                    if (workerId == 0) revert LZ_ULN_InvalidWorkerId(0);

                    // workerId must equal to the lastWorkerId for the first option
                    // so it is always skipped in the first option
                    // this operation slices out options whenever the the scan finds a different workerId
                    if (lastWorkerId == 0) {
                        lastWorkerId = workerId;
                    } else if (workerId != lastWorkerId) {
                        bytes calldata op = _options[start:cursor]; // slice out the last worker's options
                        (executorOptions, dvnOptions) = _insertWorkerOptions(
                            executorOptions,
                            dvnOptions,
                            lastWorkerId,
                            op
                        );

                        // reset the start cursor and lastWorkerId
                        start = cursor;
                        lastWorkerId = workerId;
                    }

                    ++cursor; // for workerId

                    uint16 size = uint16(bytes2(_options[cursor:cursor + 2]));
                    if (size == 0) revert LZ_ULN_InvalidWorkerOptions(cursor);
                    cursor += size + 2;
                }

                // the options length must be the same as the cursor at the end
                if (cursor != _options.length) revert LZ_ULN_InvalidWorkerOptions(cursor);

                // if we have reached the end of the options and the options are not empty
                // we need to process the last worker's options
                if (_options.length > 2) {
                    bytes calldata op = _options[start:cursor];
                    (executorOptions, dvnOptions) = _insertWorkerOptions(executorOptions, dvnOptions, lastWorkerId, op);
                }
            }
        } else {
            executorOptions = decodeLegacyOptions(optionsType, _options);
        }
    }

    function _insertWorkerOptions(
        bytes memory _executorOptions,
        bytes memory _dvnOptions,
        uint8 _workerId,
        bytes calldata _newOptions
    ) private pure returns (bytes memory, bytes memory) {
        if (_workerId == ExecutorOptions.WORKER_ID) {
            _executorOptions = _executorOptions.length == 0
                ? _newOptions
                : abi.encodePacked(_executorOptions, _newOptions);
        } else if (_workerId == DVNOptions.WORKER_ID) {
            _dvnOptions = _dvnOptions.length == 0 ? _newOptions : abi.encodePacked(_dvnOptions, _newOptions);
        } else {
            revert LZ_ULN_InvalidWorkerId(_workerId);
        }
        return (_executorOptions, _dvnOptions);
    }

    /// @dev decode the legacy options (type 1 or 2) into executorOptions
    /// @param _optionType the legacy option type
    /// @param _options the legacy options, which still has the option type in the first 2 bytes
    /// @return executorOptions the executor options, share the same format of type 3 options
    /// Data format:
    /// legacy type 1: [extraGas]
    /// legacy type 2: [extraGas][dstNativeAmt][dstNativeAddress]
    /// extraGas: uint256, dstNativeAmt: uint256, dstNativeAddress: bytes
    function decodeLegacyOptions(
        uint16 _optionType,
        bytes calldata _options
    ) internal pure returns (bytes memory executorOptions) {
        if (_optionType == TYPE_1) {
            if (_options.length != 34) revert LZ_ULN_InvalidLegacyType1Option();

            // execution gas
            uint128 executionGas = uint256(bytes32(_options[2:2 + 32])).toUint128();

            // dont use the encode function in the ExecutorOptions lib for saving gas by calling abi.encodePacked once
            // the result is a lzReceive option: [executor_id][option_size][option_type][execution_gas]
            // option_type: uint8, execution_gas: uint128
            // option_size = len(option_type) + len(execution_gas) = 1 + 16 = 17
            executorOptions = abi.encodePacked(
                ExecutorOptions.WORKER_ID,
                uint16(17), // 16 + 1, 16 for option_length, + 1 for option_type
                ExecutorOptions.OPTION_TYPE_LZRECEIVE,
                executionGas
            );
        } else if (_optionType == TYPE_2) {
            // receiver size <= 32
            if (_options.length <= 66 || _options.length > 98) revert LZ_ULN_InvalidLegacyType2Option();

            // execution gas
            uint128 executionGas = uint256(bytes32(_options[2:2 + 32])).toUint128();

            // nativeDrop (amount + receiver)
            uint128 amount = uint256(bytes32(_options[34:34 + 32])).toUint128(); // offset 2 + 32
            bytes32 receiver;
            unchecked {
                uint256 receiverLen = _options.length - 66; // offset 2 + 32 + 32
                receiver = bytes32(_options[66:]);
                receiver = receiver >> (8 * (32 - receiverLen)); // padding 0 to the left
            }

            // dont use the encode function in the ExecutorOptions lib for saving gas by calling abi.encodePacked once
            // the result has one lzReceive option and one nativeDrop option:
            //      [executor_id][lzReceive_option_size][option_type][execution_gas] +
            //      [executor_id][nativeDrop_option_size][option_type][nativeDrop_amount][receiver]
            // option_type: uint8, execution_gas: uint128, nativeDrop_amount: uint128, receiver: bytes32
            // lzReceive_option_size = len(option_type) + len(execution_gas) = 1 + 16 = 17
            // nativeDrop_option_size = len(option_type) + len(nativeDrop_amount) + len(receiver) = 1 + 16 + 32 = 49
            executorOptions = abi.encodePacked(
                ExecutorOptions.WORKER_ID,
                uint16(17), // 16 + 1, 16 for option_length, + 1 for option_type
                ExecutorOptions.OPTION_TYPE_LZRECEIVE,
                executionGas,
                ExecutorOptions.WORKER_ID,
                uint16(49), // 48 + 1, 32 + 16 for option_length, + 1 for option_type
                ExecutorOptions.OPTION_TYPE_NATIVE_DROP,
                amount,
                receiver
            );
        } else {
            revert LZ_ULN_UnsupportedOptionType(_optionType);
        }
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AddressSizeConfig is Ownable {
    // EndpointV1 is using bytes as address. this map is for address length assertion
    mapping(uint32 dstEid => uint256 size) public addressSizes;

    event AddressSizeSet(uint16 eid, uint256 size);

    error AddressSizeConfig_InvalidAddressSize();
    error AddressSizeConfig_AddressSizeAlreadySet();

    function setAddressSize(uint16 _eid, uint256 _size) external onlyOwner {
        if (_size > 32) revert AddressSizeConfig_InvalidAddressSize();
        if (addressSizes[_eid] != 0) revert AddressSizeConfig_AddressSizeAlreadySet();
        addressSizes[_eid] = _size;
        emit AddressSizeSet(_eid, _size);
    }
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Packet } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ISendLib.sol";
import { AddressCast } from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/AddressCast.sol";
import { GUID } from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/GUID.sol";
import { Transfer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/libs/Transfer.sol";

import { IMessageLibE1 } from "./interfaces/IMessageLibE1.sol";
import { ITreasuryFeeHandler } from "./interfaces/ITreasuryFeeHandler.sol";
import { INonceContract } from "./interfaces/INonceContract.sol";
import { SendLibBase, WorkerOptions, ExecutorConfig } from "../../SendLibBase.sol";
import { AddressSizeConfig } from "./AddressSizeConfig.sol";

/// @dev send-side message library base contract on endpoint v1.
/// design:
/// 1/ it enforces the path definition on V1 and interacts with the nonce contract
/// 2/ quote: first executor, then verifier (e.g. DVNs), then treasury
/// 3/ send: first executor, then verifier (e.g. DVNs), then treasury. the treasury pay much be DoS-proof
abstract contract SendLibBaseE1 is SendLibBase, AddressSizeConfig, IMessageLibE1 {
    INonceContract public immutable nonceContract;
    ITreasuryFeeHandler public immutable treasuryFeeHandler;

    // config
    address internal lzToken;

    // this event should be identical to the one on Endpoint V2
    event PacketSent(bytes encodedPayload, bytes options, uint256 nativeFee, uint256 lzTokenFee);
    event NativeFeeWithdrawn(address user, address receiver, uint256 amount);
    event LzTokenSet(address token);

    constructor(
        address _endpoint,
        uint256 _treasuryGasLimit,
        uint256 _treasuryNativeFeeCap,
        address _nonceContract,
        uint32 _localEid,
        address _treasuryFeeHandler
    ) SendLibBase(_endpoint, _localEid, _treasuryGasLimit, _treasuryNativeFeeCap) {
        nonceContract = INonceContract(_nonceContract);
        treasuryFeeHandler = ITreasuryFeeHandler(_treasuryFeeHandler);
    }

    // ======================= OnlyEndpoint =======================
    /// @dev the abstract process for send() is:
    /// 1/ pay workers, which includes the executor and the validation workers
    /// 2/ pay treasury
    /// 3/ in EndpointV1, here we handle the fees and refunds
    function send(
        address _sender,
        uint64, // _nonce
        uint16 _dstEid,
        bytes calldata _path, // remoteAddress + localAddress
        bytes calldata _message,
        address payable _refundAddress,
        address _lzTokenPaymentAddress,
        bytes calldata _options
    ) external payable onlyEndpoint {
        (bytes memory encodedPacket, uint256 totalNativeFee) = _payWorkers(_sender, _dstEid, _path, _message, _options);

        // quote treasury fee
        uint32 dstEid = _dstEid; // stack too deep
        address sender = _sender; // stack too deep
        bool payInLzToken = _lzTokenPaymentAddress != address(0x0) && address(lzToken) != address(0x0);
        (uint256 treasuryNativeFee, uint256 lzTokenFee) = _payTreasury(sender, dstEid, totalNativeFee, payInLzToken);
        totalNativeFee += treasuryNativeFee;

        // pay native fee
        // assert the user has attached enough native token for this address
        if (msg.value < totalNativeFee) revert LZ_MessageLib_InsufficientMsgValue();
        // refund if they send too much
        uint256 refundAmt = msg.value - totalNativeFee;
        if (refundAmt > 0) {
            Transfer.native(_refundAddress, refundAmt);
        }

        // pay lz token fee if needed
        if (lzTokenFee > 0) {
            // in v2, we let user pass a payInLzToken boolean but always charging the sender
            // likewise in v1, if _lzTokenPaymentAddress is passed, it must be the sender
            if (_lzTokenPaymentAddress != sender) revert LZ_MessageLib_LzTokenPaymentAddressMustBeSender();
            _payLzTokenFee(sender, lzTokenFee);
        }

        emit PacketSent(encodedPacket, _options, totalNativeFee, lzTokenFee);
    }

    // ======================= OnlyOwner =======================
    function setLzToken(address _lzToken) external onlyOwner {
        lzToken = _lzToken;
        emit LzTokenSet(_lzToken);
    }

    function setTreasury(address _treasury) external onlyOwner {
        _setTreasury(_treasury);
    }

    // ======================= External =======================
    function withdrawFee(address _to, uint256 _amount) external {
        _debitFee(_amount);
        Transfer.native(_to, _amount);
        emit NativeFeeWithdrawn(msg.sender, _to, _amount);
    }

    // ======================= View =======================
    function estimateFees(
        uint16 _dstEid,
        address _sender,
        bytes calldata _message,
        bool _payInLzToken,
        bytes calldata _options
    ) external view returns (uint256 nativeFee, uint256 lzTokenFee) {
        return _quote(_sender, _dstEid, _message.length, _payInLzToken, _options);
    }

    // ======================= Internal =======================
    /// @dev path = remoteAddress + localAddress.
    function _assertPath(address _sender, bytes calldata _path, uint256 remoteAddressSize) internal pure {
        if (_path.length != 20 + remoteAddressSize) revert LZ_MessageLib_InvalidPath();
        address srcInPath = AddressCast.toAddress(_path[remoteAddressSize:]);
        if (_sender != srcInPath) revert LZ_MessageLib_InvalidSender();
    }

    function _payLzTokenFee(address _sender, uint256 _lzTokenFee) internal {
        treasuryFeeHandler.payFee(
            lzToken,
            _sender,
            _lzTokenFee, // the supplied fee is always equal to the required fee
            _lzTokenFee,
            treasury
        );
    }

    /// @dev outbound does three things
    /// @dev 1) asserts path
    /// @dev 2) increments the nonce
    /// @dev 3) assemble packet
    /// @return packet to be sent to workers
    function _outbound(
        address _sender,
        uint16 _dstEid,
        bytes calldata _path,
        bytes calldata _message
    ) internal returns (Packet memory packet) {
        // assert toAddress size
        uint256 remoteAddressSize = addressSizes[_dstEid];
        if (remoteAddressSize == 0) revert LZ_MessageLib_InvalidPath();
        _assertPath(_sender, _path, remoteAddressSize);

        // increment nonce
        uint64 nonce = nonceContract.increment(_dstEid, _sender, _path);

        bytes32 receiver = AddressCast.toBytes32(_path[0:remoteAddressSize]);

        bytes32 guid = GUID.generate(nonce, localEid, _sender, _dstEid, receiver);

        // assemble packet
        packet = Packet(nonce, localEid, _sender, _dstEid, receiver, guid, _message);
    }

    /// 1/ handle executor
    /// 2/ handle other workers
    function _payWorkers(
        address _sender,
        uint16 _dstEid,
        bytes calldata _path,
        bytes calldata _message,
        bytes calldata _options
    ) internal returns (bytes memory encodedPacket, uint256 totalNativeFee) {
        Packet memory packet = _outbound(_sender, _dstEid, _path, _message);

        // split workers options
        (bytes memory executorOptions, WorkerOptions[] memory verificationOptions) = _splitOptions(_options);

        // handle executor
        ExecutorConfig memory config = getExecutorConfig(_sender, _dstEid);
        uint256 msgSize = packet.message.length;
        _assertMessageSize(msgSize, config.maxMessageSize);
        totalNativeFee += _payExecutor(config.executor, packet.dstEid, packet.sender, msgSize, executorOptions);

        // handle other workers
        (uint256 verifierFee, bytes memory packetBytes) = _payVerifier(packet, verificationOptions);
        totalNativeFee += verifierFee;

        encodedPacket = packetBytes;
    }

    // ======================= Virtual =======================
    function _payVerifier(
        Packet memory _packet, // packet is assembled in memory for endpoint-v1. so the location can not be calldata
        WorkerOptions[] memory _options
    ) internal virtual returns (uint256 otherWorkerFees, bytes memory encodedPacket);
}
// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

import { Packet } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ISendLib.sol";

import { ExecutorConfig, WorkerOptions } from "../../SendLibBase.sol";
import { SendLibBaseE1 } from "./SendLibBaseE1.sol";
import { SendUlnBase } from "../SendUlnBase.sol";
import { UlnConfig } from "../UlnBase.sol";

/// @dev ULN301 will be deployed on EndpointV1 and is for backward compatibility with ULN302 on EndpointV2. 301 can talk to both 301 and 302
/// @dev This is a gluing contract. It simply parses the requests and forward to the super.impl() accordingly.
/// @dev In this case, it combines the logic of SendUlnBase and SendLibBaseE1
contract SendUln301 is SendUlnBase, SendLibBaseE1 {
    uint256 internal constant CONFIG_TYPE_EXECUTOR = 1;
    uint256 internal constant CONFIG_TYPE_ULN = 2;

    error LZ_ULN_InvalidConfigType(uint256 configType);

    constructor(
        address _endpoint,
        uint256 _treasuryGasLimit,
        uint256 _treasuryGasForFeeCap,
        address _nonceContract,
        uint32 _localEid,
        address _treasuryFeeHandler
    )
        SendLibBaseE1(
            _endpoint,
            _treasuryGasLimit,
            _treasuryGasForFeeCap,
            _nonceContract,
            _localEid,
            _treasuryFeeHandler
        )
    {}

    // ============================ OnlyEndpoint ===================================

    function setConfig(
        uint16 _eid,
        address _oapp,
        uint256 _configType,
        bytes calldata _config
    ) external override onlyEndpoint {
        _assertSupportedEid(_eid);
        if (_configType == CONFIG_TYPE_EXECUTOR) {
            _setExecutorConfig(_eid, _oapp, abi.decode(_config, (ExecutorConfig)));
        } else if (_configType == CONFIG_TYPE_ULN) {
            _setUlnConfig(_eid, _oapp, abi.decode(_config, (UlnConfig)));
        } else {
            revert LZ_ULN_InvalidConfigType(_configType);
        }
    }

    // ============================ View ===================================

    function getConfig(uint16 _eid, address _oapp, uint256 _configType) external view override returns (bytes memory) {
        if (_configType == CONFIG_TYPE_EXECUTOR) {
            return abi.encode(getExecutorConfig(_oapp, _eid));
        } else if (_configType == CONFIG_TYPE_ULN) {
            return abi.encode(getUlnConfig(_oapp, _eid));
        } else {
            revert LZ_ULN_InvalidConfigType(_configType);
        }
    }

    function version() external pure override returns (uint64 major, uint8 minor, uint8 endpointVersion) {
        return (3, 0, 1);
    }

    function isSupportedEid(uint32 _eid) external view returns (bool) {
        return _isSupportedEid(_eid);
    }

    // ============================ Internal ===================================

    function _quoteVerifier(
        address _sender,
        uint32 _dstEid,
        WorkerOptions[] memory _options
    ) internal view override returns (uint256) {
        return _quoteDVNs(_sender, _dstEid, _options);
    }

    function _payVerifier(
        Packet memory _packet,
        WorkerOptions[] memory _options
    ) internal virtual override returns (uint256 otherWorkerFees, bytes memory encodedPacket) {
        (otherWorkerFees, encodedPacket) = _payDVNs(fees, _packet, _options);
    }

    function _splitOptions(
        bytes calldata _options
    ) internal pure override returns (bytes memory, WorkerOptions[] memory) {
        return _splitUlnOptions(_options);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { ILayerZeroMessagingLibrary } from "@layerzerolabs/lz-evm-v1-0.7/contracts/interfaces/ILayerZeroMessagingLibrary.sol";

/// extends ILayerZeroMessagingLibrary instead of ILayerZeroMessagingLibraryV2 for reducing the contract size
interface IMessageLibE1 is ILayerZeroMessagingLibrary {
    error LZ_MessageLib_InvalidPath();
    error LZ_MessageLib_InvalidSender();
    error LZ_MessageLib_InsufficientMsgValue();
    error LZ_MessageLib_LzTokenPaymentAddressMustBeSender();

    function setLzToken(address _lzToken) external;

    function setTreasury(address _treasury) external;

    function withdrawFee(address _to, uint256 _amount) external;

    // message libs of same major version are compatible
    function version() external view returns (uint64 major, uint8 minor, uint8 endpointVersion);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INonceContract {
    function increment(uint16 _chainId, address _ua, bytes calldata _path) external returns (uint64);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface ITreasuryFeeHandler {
    function payFee(
        address _lzToken,
        address _sender,
        uint256 _required,
        uint256 _supplied,
        address _treasury
    ) external;
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