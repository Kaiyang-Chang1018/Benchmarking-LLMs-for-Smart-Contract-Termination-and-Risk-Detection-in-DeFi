// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

library IBCClientLib {
    /**
     * @dev validateClientType validates the client type
     *   - clientType must be non-empty
     *   - clientType must be in the form of `^[a-z][a-z0-9-]*[a-z0-9]$`
     */
    function validateClientType(bytes memory clientTypeBytes) internal pure returns (bool) {
        uint256 byteLength = clientTypeBytes.length;
        if (byteLength == 0) {
            return false;
        }
        for (uint256 i = 0; i < byteLength; i++) {
            uint256 c = uint256(uint8(clientTypeBytes[i]));
            if (0x61 <= c && c <= 0x7a) {
                // a-z
                continue;
            } else if (c == 0x2d) {
                // hyphen cannot be the first or last character
                unchecked {
                    // SAFETY: `byteLength` is greater than 0
                    if (i == 0 || i == byteLength - 1) {
                        return false;
                    }
                }
                continue;
            } else if (0x30 <= c && c <= 0x39) {
                // 0-9
                continue;
            } else {
                return false;
            }
        }
        return true;
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";

interface IIBCClient {
    // --------------------- Data Structure --------------------- //

    struct MsgCreateClient {
        string clientType;
        bytes protoClientState;
        bytes protoConsensusState;
    }

    struct MsgUpdateClient {
        string clientId;
        bytes protoClientMessage;
    }

    // --------------------- Events --------------------- //

    /// @notice Emitted when a client identifier is generated
    /// @param clientId client identifier
    event GeneratedClientIdentifier(string clientId);

    /**
     * @dev createClient creates a new client state and populates it with a given consensus state
     */
    function createClient(MsgCreateClient calldata msg_) external returns (string memory clientId);

    /**
     * @dev updateClient updates the consensus state and the state root from a provided header
     */
    function updateClient(MsgUpdateClient calldata msg_) external;

    /**
     * @dev routeUpdateClient returns the lc contract address and the calldata to the receiving function of the client message.
     *      Light client contract may encode a client message as other encoding scheme(e.g. ethereum ABI)
     *      Check ADR-001 for details.
     */
    function routeUpdateClient(MsgUpdateClient calldata msg_) external view returns (address, bytes4, bytes memory);

    /**
     * @dev updateClientCommitments updates the commitments of the light client's states corresponding to the given heights.
     *      Check ADR-001 for details.
     */
    function updateClientCommitments(string calldata clientId, Height.Data[] calldata heights) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";

interface IIBCClientErrors {
    /// @param clientType the client type
    error IBCClientUnregisteredClientType(string clientType);

    /// @param clientId the client identifier
    error IBCClientClientNotFound(string clientId);

    /// @param clientId the client identifier
    /// @param consensusHeight the consensus height
    error IBCClientConsensusStateNotFound(string clientId, Height.Data consensusHeight);

    /// @param clientId the client identifier
    error IBCClientNotActiveClient(string clientId);

    /// @param selector the function selector
    /// @param args the calldata
    error IBCClientFailedUpdateClient(bytes4 selector, bytes args);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";

/**
 * @dev This defines an interface for Light Client contract can be integrated with ibc-solidity.
 * You can register the Light Client contract that implements this through `registerClient` on IBCHandler.
 */
interface ILightClient {
    /**
     * @dev ConsensusStateUpdate represents a consensus state update.
     */
    struct ConsensusStateUpdate {
        // commitment for updated consensusState
        bytes32 consensusStateCommitment;
        // updated height
        Height.Data height;
    }

    /**
     * @dev ClientStatus represents the status of a client.
     */
    enum ClientStatus {
        Active,
        Expired,
        Frozen
    }

    /**
     * @dev initializeClient initializes a new client with the given state.
     *      If succeeded, it returns heights at which the consensus state are stored.
     *      The function must be only called by IBCHandler.
     */
    function initializeClient(
        string calldata clientId,
        bytes calldata protoClientState,
        bytes calldata protoConsensusState
    ) external returns (Height.Data memory height);

    /**
     * @dev routeUpdateClient returns the calldata to the receiving function of the client message.
     *      Light client contract may encode a client message as other encoding scheme(e.g. ethereum ABI)
     *      Check ADR-001 for details.
     */
    function routeUpdateClient(string calldata clientId, bytes calldata protoClientMessage)
        external
        pure
        returns (bytes4 selector, bytes memory args);

    /**
     * @dev getTimestampAtHeight returns the timestamp of the consensus state at the given height.
     *      The timestamp is nanoseconds since unix epoch.
     */
    function getTimestampAtHeight(string calldata clientId, Height.Data calldata height)
        external
        view
        returns (uint64);

    /**
     * @dev getLatestHeight returns the latest height of the client state corresponding to `clientId`.
     */
    function getLatestHeight(string calldata clientId) external view returns (Height.Data memory);

    /**
     * @dev getStatus returns the status of the client corresponding to `clientId`.
     */
    function getStatus(string calldata clientId) external view returns (ClientStatus);

    /**
     * @dev getLatestInfo returns the latest height, the latest timestamp, and the status of the client corresponding to `clientId`.
     */
    function getLatestInfo(string calldata clientId)
        external
        view
        returns (Height.Data memory latestHeight, uint64 latestTimestamp, ClientStatus status);

    /**
     * @dev verifyMembership is a generic proof verification method which verifies a proof of the existence of a value at a given CommitmentPath at the specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     * This function should not perform `call` to the IBC contract. However, `staticcall` is permitted.
     */
    function verifyMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64 delayTimePeriod,
        uint64 delayBlockPeriod,
        bytes calldata proof,
        bytes calldata prefix,
        bytes calldata path,
        bytes calldata value
    ) external returns (bool);

    /**
     * @dev verifyNonMembership is a generic proof verification method which verifies the absence of a given CommitmentPath at a specified height.
     * The caller is expected to construct the full CommitmentPath from a CommitmentPrefix and a standardized path (as defined in ICS 24).
     * This function should not perform `call` to the IBC contract. However, `staticcall` is permitted.
     */
    function verifyNonMembership(
        string calldata clientId,
        Height.Data calldata height,
        uint64 delayTimePeriod,
        uint64 delayBlockPeriod,
        bytes calldata proof,
        bytes calldata prefix,
        bytes calldata path
    ) external returns (bool);

    /**
     * @dev getClientState returns the clientState corresponding to `clientId`.
     *      If it's not found, the function returns false.
     */
    function getClientState(string calldata clientId) external view returns (bytes memory, bool);

    /**
     * @dev getConsensusState returns the consensusState corresponding to `clientId` and `height`.
     *      If it's not found, the function returns false.
     */
    function getConsensusState(string calldata clientId, Height.Data calldata height)
        external
        view
        returns (bytes memory, bool);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {Version, Counterparty} from "../../proto/Connection.sol";

interface IIBCConnection {
    // --------------------- Data Structure --------------------- //

    struct MsgConnectionOpenInit {
        string clientId;
        Counterparty.Data counterparty;
        Version.Data version;
        uint64 delayPeriod;
    }

    struct MsgConnectionOpenTry {
        Counterparty.Data counterparty; // counterpartyConnectionIdentifier, counterpartyPrefix and counterpartyClientIdentifier
        uint64 delayPeriod;
        string clientId; // clientID of chainA
        bytes clientStateBytes; // clientState that chainA has for chainB
        Version.Data[] counterpartyVersions; // supported versions of chain A
        bytes proofInit; // proof that chainA stored connectionEnd in state (on ConnOpenInit)
        bytes proofClient; // proof that chainA stored a light client of chainB
        bytes proofConsensus; // proof that chainA stored chainB's consensus state at consensus height
        Height.Data proofHeight; // height at which relayer constructs proof of A storing connectionEnd in state
        Height.Data consensusHeight; // latest height of chain B which chain A has stored in its chain B client
        bytes hostConsensusStateProof; // optional proof data for host state machines that are unable to introspect their own consensus state
    }

    struct MsgConnectionOpenAck {
        string connectionId;
        bytes clientStateBytes; // client state for chainA on chainB
        Version.Data version; // version that ChainB chose in ConnOpenTry
        string counterpartyConnectionId;
        bytes proofTry; // proof that connectionEnd was added to ChainB state in ConnOpenTry
        bytes proofClient; // proof of client state on chainB for chainA
        bytes proofConsensus; // proof that chainB has stored ConsensusState of chainA on its client
        Height.Data proofHeight; // height that relayer constructed proofTry
        Height.Data consensusHeight; // latest height of chainA that chainB has stored on its chainA client
        bytes hostConsensusStateProof; // optional proof data for host state machines that are unable to introspect their own consensus state
    }

    struct MsgConnectionOpenConfirm {
        string connectionId;
        bytes proofAck;
        Height.Data proofHeight;
    }

    // --------------------- Events --------------------- //

    /// @notice Emitted when a connection identifier is generated
    /// @param connectionId connection identifier
    event GeneratedConnectionIdentifier(string connectionId);

    /**
     * @dev connectionOpenInit initialises a connection attempt on chain A. The generated connection identifier
     * is returned.
     */
    function connectionOpenInit(MsgConnectionOpenInit calldata msg_) external returns (string memory connectionId);

    /**
     * @dev connectionOpenTry relays notice of a connection attempt on chain A to chain B (this
     * code is executed on chain B).
     */
    function connectionOpenTry(MsgConnectionOpenTry calldata msg_) external returns (string memory);

    /**
     * @dev connectionOpenAck relays acceptance of a connection open attempt from chain B back
     * to chain A (this code is executed on chain A).
     */
    function connectionOpenAck(MsgConnectionOpenAck calldata msg_) external;

    /**
     * @dev connectionOpenConfirm confirms opening of a connection on chain A to chain B, after
     * which the connection is open on both chains (this code is executed on chain B).
     */
    function connectionOpenConfirm(MsgConnectionOpenConfirm calldata msg_) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {ConnectionEnd} from "../../proto/Connection.sol";

interface IIBCConnectionErrors {
    error IBCConnectionAlreadyConnectionExists();

    /// @param counterpartyConnectionId counterparty connection identifier
    error IBCConnectionInvalidCounterpartyConnectionIdentifier(string counterpartyConnectionId);

    error IBCConnectionEmptyConnectionCounterpartyVersions();

    error IBCConnectionNoMatchingVersionFound();

    error IBCConnectionVersionsAlreadySet();

    error IBCConnectionIBCVersionNotSupported();

    error IBCConnectionInvalidSelfClientState();

    error IBCConnectionInvalidHostConsensusStateProof();

    /// @param state connection state
    error IBCConnectionUnexpectedConnectionState(ConnectionEnd.State state);

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param value value
    /// @param proof proof
    /// @param height proof height
    error IBCConnectionFailedVerifyConnectionState(
        string clientId, bytes path, bytes value, bytes proof, Height.Data height
    );

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param value value
    /// @param proof proof
    /// @param height proof height
    error IBCConnectionFailedVerifyClientState(
        string clientId, bytes path, bytes value, bytes proof, Height.Data height
    );

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param value value
    /// @param proof proof
    /// @param height proof height
    error IBCConnectionFailedVerifyClientConsensusState(
        string clientId, bytes path, bytes value, bytes proof, Height.Data height
    );
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Channel} from "../../proto/Channel.sol";
import {IIBCChannelErrors} from "./IIBCChannelErrors.sol";

library IBCChannelLib {
    enum PacketReceipt {
        NONE,
        SUCCESSFUL
    }

    string internal constant ORDER_UNORDERED = "ORDER_UNORDERED";
    string internal constant ORDER_ORDERED = "ORDER_ORDERED";

    bytes32 internal constant PACKET_RECEIPT_SUCCESSFUL_KECCAK256 =
        keccak256(abi.encodePacked(PacketReceipt.SUCCESSFUL));

    function receiptCommitmentToReceipt(bytes32 commitment) internal pure returns (PacketReceipt) {
        if (commitment == bytes32(0)) {
            return PacketReceipt.NONE;
        } else if (commitment == PACKET_RECEIPT_SUCCESSFUL_KECCAK256) {
            return PacketReceipt.SUCCESSFUL;
        } else {
            revert IIBCChannelErrors.IBCChannelUnknownPacketReceiptCommitment(commitment);
        }
    }

    function buildConnectionHops(string memory connectionId) internal pure returns (string[] memory hops) {
        hops = new string[](1);
        hops[0] = connectionId;
        return hops;
    }

    function toString(Channel.Order order) internal pure returns (string memory) {
        if (order == Channel.Order.ORDER_UNORDERED) {
            return ORDER_UNORDERED;
        } else if (order == Channel.Order.ORDER_ORDERED) {
            return ORDER_ORDERED;
        } else {
            revert IIBCChannelErrors.IBCChannelUnknownChannelOrder(order);
        }
    }

    function uint64ToBigEndianBytes(uint64 v) internal pure returns (bytes memory) {
        return abi.encodePacked(bytes8(v));
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {Channel} from "../../proto/Channel.sol";

/// @notice Packet defines a type that carries data across different chains through IBC.
/// @param sequence corresponds to the order of sends and receives, where a packet with an earlier sequence number must be sent and received before a packet with a later sequence number
/// @param sourcePort identifies the port on the sending chain
/// @param sourceChannel identifies the channel end on the sending chain
/// @param destPort identifies the port on the receiving chain
/// @param destChannel identifies the channel end on the receiving chain
/// @param data is an opaque value which can be defined by the application logic of the associated modules
/// @param timeoutHeight indicates a consensus height on the destination chain after which the packet will no longer be processed, and will instead count as having timed-out
/// @param timeoutTimestamp indicates a timestamp on the destination chain after which the packet will no longer be processed, and will instead count as having timed-out
struct Packet {
    uint64 sequence;
    string sourcePort;
    string sourceChannel;
    string destinationPort;
    string destinationChannel;
    bytes data;
    Height.Data timeoutHeight;
    uint64 timeoutTimestamp;
}

interface IIBCChannelHandshake {
    // --------------------- Data Structure --------------------- //

    struct MsgChannelOpenInit {
        string portId;
        Channel.Data channel;
    }

    struct MsgChannelOpenTry {
        string portId;
        Channel.Data channel;
        string counterpartyVersion;
        bytes proofInit;
        Height.Data proofHeight;
    }

    struct MsgChannelOpenAck {
        string portId;
        string channelId;
        string counterpartyVersion;
        string counterpartyChannelId;
        bytes proofTry;
        Height.Data proofHeight;
    }

    struct MsgChannelOpenConfirm {
        string portId;
        string channelId;
        bytes proofAck;
        Height.Data proofHeight;
    }

    struct MsgChannelCloseInit {
        string portId;
        string channelId;
    }

    struct MsgChannelCloseConfirm {
        string portId;
        string channelId;
        bytes proofInit;
        Height.Data proofHeight;
    }

    // --------------------- Events --------------------- //

    /// @param channelId channel identifier
    event GeneratedChannelIdentifier(string channelId);

    // --------------------- Functions --------------------- //

    /**
     * @dev channelOpenInit is called by a module to initiate a channel opening handshake with a module on another chain.
     */
    function channelOpenInit(MsgChannelOpenInit calldata msg_)
        external
        returns (string memory channelId, string memory version);

    /**
     * @dev channelOpenTry is called by a module to accept the first step of a channel opening handshake initiated by a module on another chain.
     */
    function channelOpenTry(MsgChannelOpenTry calldata msg_)
        external
        returns (string memory channelId, string memory version);

    /**
     * @dev channelOpenAck is called by the handshake-originating module to acknowledge the acceptance of the initial request by the counterparty module on the other chain.
     */
    function channelOpenAck(MsgChannelOpenAck calldata msg_) external;

    /**
     * @dev channelOpenConfirm is called by the counterparty module to close their end of the channel, since the other end has been closed.
     */
    function channelOpenConfirm(MsgChannelOpenConfirm calldata msg_) external;

    /**
     * @dev channelCloseInit is called by either module to close their end of the channel. Once closed, channels cannot be reopened.
     */
    function channelCloseInit(MsgChannelCloseInit calldata msg_) external;

    /**
     * @dev channelCloseConfirm is called by the counterparty module to close their end of the
     * channel, since the other end has been closed.
     */
    function channelCloseConfirm(MsgChannelCloseConfirm calldata msg_) external;
}

interface IICS04SendPacket {
    // --------------------- Events --------------------- //

    /// @notice event emitted upon sending a packet
    event SendPacket(
        uint64 sequence,
        string sourcePort,
        string sourceChannel,
        Height.Data timeoutHeight,
        uint64 timeoutTimestamp,
        bytes data
    );

    // --------------------- Functions --------------------- //

    /**
     * @dev sendPacket is called by a module in order to send an IBC packet on a channel.
     * The packet sequence generated for the packet to be sent is returned. An error
     * is returned if one occurs. Also, `timeoutTimestamp` is given in nanoseconds since unix epoch.
     */
    function sendPacket(
        string calldata sourcePort,
        string calldata sourceChannel,
        Height.Data calldata timeoutHeight,
        uint64 timeoutTimestamp,
        bytes calldata data
    ) external returns (uint64);
}

interface IICS04WriteAcknowledgement {
    // --------------------- Events --------------------- //

    /// @notice event emitted upon writing an acknowledgement
    /// @param destinationPortId destination port
    /// @param destinationChannel destination channel
    /// @param sequence packet sequence
    /// @param acknowledgement acknowledgement
    event WriteAcknowledgement(
        string destinationPortId, string destinationChannel, uint64 sequence, bytes acknowledgement
    );

    // --------------------- Functions --------------------- //

    /**
     * @dev writeAcknowledgement writes the packet execution acknowledgement to the state,
     * which will be verified by the counterparty chain using AcknowledgePacket.
     */
    function writeAcknowledgement(
        string calldata destinationPortId,
        string calldata destinationChannel,
        uint64 sequence,
        bytes calldata acknowledgement
    ) external;
}

interface IIBCChannelRecvPacket {
    // --------------------- Data Structure --------------------- //

    struct MsgPacketRecv {
        Packet packet;
        bytes proof;
        Height.Data proofHeight;
    }

    // --------------------- Events --------------------- //

    /// @notice event emitted upon receiving a packet
    event RecvPacket(Packet packet);

    // --------------------- Functions --------------------- //

    /**
     * @dev recvPacket is called by a module in order to receive & process an IBC packet
     * sent on the corresponding channel end on the counterparty chain.
     */
    function recvPacket(MsgPacketRecv calldata msg_) external;
}

interface IIBCChannelAcknowledgePacket {
    // --------------------- Data Structure --------------------- //

    struct MsgPacketAcknowledgement {
        Packet packet;
        bytes acknowledgement;
        bytes proof;
        Height.Data proofHeight;
    }

    // --------------------- Events --------------------- //

    /// @notice event emitted upon acknowledging a packet
    event AcknowledgePacket(Packet packet, bytes acknowledgement);

    // --------------------- Functions --------------------- //

    /**
     * @dev AcknowledgePacket is called by a module to process the acknowledgement of a
     * packet previously sent by the calling module on a channel to a counterparty
     * module on the counterparty chain. Its intended usage is within the ante
     * handler. AcknowledgePacket will clean up the packet commitment,
     * which is no longer necessary since the packet has been received and acted upon.
     * It will also increment NextSequenceAck in case of ORDERED channels.
     */
    function acknowledgePacket(MsgPacketAcknowledgement calldata msg_) external;
}

interface IIBCChannelPacketTimeout {
    // --------------------- Data Structure --------------------- //

    struct MsgTimeoutPacket {
        Packet packet;
        bytes proof;
        Height.Data proofHeight;
        uint64 nextSequenceRecv;
    }

    struct MsgTimeoutOnClose {
        Packet packet;
        bytes proofUnreceived;
        bytes proofClose;
        Height.Data proofHeight;
        uint64 nextSequenceRecv;
        uint64 counterpartyUpgradeSequence;
    }

    // --------------------- Events --------------------- //

    /// @notice event emitted upon timeout of a packet
    event TimeoutPacket(Packet packet);

    // --------------------- Functions --------------------- //

    /**
     * @dev TimeoutPacket is called by a module which originally attempted to send a
     * packet to a counterparty module, where the timeout height has passed on the
     * counterparty chain without the packet being committed, to prove that the
     * packet can no longer be executed and to allow the calling module to safely
     * perform appropriate state transitions. Its intended usage is within the
     * ante handler.
     */
    function timeoutPacket(MsgTimeoutPacket calldata msg_) external;

    /**
     * @dev TimeoutOnClose is called by a module in order to prove that the channel to
     * which an unreceived packet was addressed has been closed, so the packet will
     * never be received (even if the timeoutHeight has not yet been reached).
     */
    function timeoutOnClose(MsgTimeoutOnClose calldata msg_) external;
}

interface IICS04Wrapper is IICS04SendPacket, IICS04WriteAcknowledgement {}

interface IIBCChannelPacketSendRecv is IICS04Wrapper, IIBCChannelRecvPacket, IIBCChannelAcknowledgePacket {}

interface IIBCChannelPacket is IIBCChannelPacketSendRecv, IIBCChannelPacketTimeout {}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {Channel} from "../../proto/Channel.sol";

interface IIBCChannelErrors {
    /// @param state channel state
    error IBCChannelUnexpectedChannelState(Channel.State state);

    /// @param portId port identifier
    /// @param channelId channel identifier
    error IBCChannelChannelNotFound(string portId, string channelId);

    /// @param ordering channel ordering
    error IBCChannelUnknownChannelOrder(Channel.Order ordering);

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param value value
    /// @param proof proof
    /// @param height proof height
    error IBCChannelFailedVerifyChannelState(string clientId, bytes path, bytes value, bytes proof, Height.Data height);

    /// @param connectionId connection identifier
    error IBCChannelConnectionNotOpened(string connectionId);

    /// @param counterpartyChannelId counterparty channel identifier
    error IBCChannelCounterpartyChannelIdNotEmpty(string counterpartyChannelId);

    /// @param length length of the connection hops
    error IBCChannelInvalidConnectionHopsLength(uint256 length);

    /// @param connectionId connection identifier
    /// @param length length of the connection hops
    error IBCChannelConnectionMultipleVersionsFound(string connectionId, uint256 length);

    /// @param ordering channel ordering
    error IBCChannelConnectionFeatureNotSupported(Channel.Order ordering);

    /// @notice timeout height and timestamp are both zero
    error IBCChannelZeroPacketTimeout();

    /// @notice receiving chain block height >= packet timeout height
    /// @param timeoutHeight packet timeout height
    /// @param latestHeight latest height of the receiving chain
    error IBCChannelPastPacketTimeoutHeight(Height.Data timeoutHeight, Height.Data latestHeight);

    /// @notice receiving chain block timestamp >= packet timeout timestamp
    /// @param timeoutTimestamp packet timeout timestamp
    /// @param latestTimestamp latest timestamp of the receiving chain
    error IBCChannelPastPacketTimeoutTimestamp(uint64 timeoutTimestamp, uint64 latestTimestamp);

    /// @notice packet timeout has not been reached for height or timestamp
    error IBCChannelTimeoutNotReached();

    /// @param commitment packet receipt commitment
    error IBCChannelUnknownPacketReceiptCommitment(bytes32 commitment);

    /// @param sourcePort source port
    /// @param sourceChannel source channel
    error IBCChannelUnexpectedPacketSource(string sourcePort, string sourceChannel);

    /// @param destinationPort destination port
    /// @param destinationChannel destination channel
    error IBCChannelUnexpectedPacketDestination(string destinationPort, string destinationChannel);

    error IBCChannelCannotRecvNextUpgradePacket(uint64 sequence, uint64 counterpartyNextSequenceSend);

    error IBCChannelPacketAlreadyProcessInPreviousUpgrade(uint64 sequence, uint64 recvStartSequence);

    error IBCChannelAckAlreadyProcessedInPreviousUpgrade(uint64 sequence, uint64 ackStartSequence);

    /// @param currentBlockNumber current block number
    /// @param timeoutHeight packet timeout height
    error IBCChannelTimeoutPacketHeight(uint256 currentBlockNumber, uint64 timeoutHeight);

    /// @param currentTimestamp current timestamp
    /// @param timeoutTimestamp packet timeout timestamp
    error IBCChannelTimeoutPacketTimestamp(uint256 currentTimestamp, uint64 timeoutTimestamp);

    /// @param destinationPort destination port
    /// @param destinationChannel destination channel
    /// @param sequence packet sequence
    error IBCChannelPacketReceiptAlreadyExists(string destinationPort, string destinationChannel, uint64 sequence);

    /// @param expected expected sequence
    error IBCChannelUnexpectedNextSequenceRecv(uint64 expected);

    /// @param portId port identifier
    /// @param channelId channel identifier
    /// @param sequence packet sequence
    error IBCChannelPacketCommitmentNotFound(string portId, string channelId, uint64 sequence);

    /// @param expected expected sequence
    error IBCChannelUnexpectedNextSequenceAck(uint64 expected);

    /// @param expected expected commitment
    /// @param actual actual commitment
    error IBCChannelPacketCommitmentMismatch(bytes32 expected, bytes32 actual);

    /// @param sequence packet sequence
    /// @param nextSequenceRecv next sequence received
    error IBCChannelPacketMaybeAlreadyReceived(uint64 sequence, uint64 nextSequenceRecv);

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param commitment packet commitment
    /// @param proof proof
    /// @param height proof height
    error IBCChannelFailedVerifyPacketCommitment(
        string clientId, bytes path, bytes32 commitment, bytes proof, Height.Data height
    );

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param commitment acknowledgement commitment
    /// @param proof proof
    /// @param height proof height
    error IBCChannelFailedVerifyPacketAcknowledgement(
        string clientId, bytes path, bytes32 commitment, bytes proof, Height.Data height
    );

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param nextSequenceRecv next sequence received
    /// @param proof proof
    /// @param height proof height
    error IBCChannelFailedVerifyNextSequenceRecv(
        string clientId, bytes path, uint64 nextSequenceRecv, bytes proof, Height.Data height
    );

    /// @param clientId client identifier
    /// @param path commitment path
    /// @param proof proof
    /// @param height proof height
    error IBCChannelFailedVerifyPacketReceiptAbsence(string clientId, bytes path, bytes proof, Height.Data height);

    /// @notice acknowledgement cannot be empty
    error IBCChannelEmptyAcknowledgement();

    /// @param destinationPort destination port
    /// @param destinationChannel destination channel
    /// @param sequence packet sequence
    error IBCChannelAcknowledgementAlreadyWritten(string destinationPort, string destinationChannel, uint64 sequence);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {Channel, Upgrade, UpgradeFields, ErrorReceipt, Timeout} from "../../proto/Channel.sol";

interface IIBCChannelUpgradeBase {
    // --------------------- Events --------------------- //

    /// @notice emitted when channelUpgradeInit is successfully executed
    event ChannelUpgradeInit(
        string portId, string channelId, uint64 upgradeSequence, UpgradeFields.Data proposedUpgradeFields
    );

    /// @notice emitted when channelUpgradeTry is successfully executed
    event ChannelUpgradeTry(
        string portId,
        string channelId,
        uint64 upgradeSequence,
        UpgradeFields.Data upgradeFields,
        Timeout.Data timeout,
        uint64 nextSequenceSend
    );

    /// @notice emitted when channelUpgradeAck is successfully executed
    /// @param channelState post channel state (FLUSHING or FLUSHCOMPLETE)
    event ChannelUpgradeAck(
        string portId,
        string channelId,
        uint64 upgradeSequence,
        Channel.State channelState,
        UpgradeFields.Data upgradeFields,
        Timeout.Data timeout,
        uint64 nextSequenceSend
    );

    /// @notice emitted when channelUpgradeConfirm is successfully executed
    /// @param channelState post channel state (FLUSHING or FLUSHCOMPLETE or OPEN)
    event ChannelUpgradeConfirm(string portId, string channelId, uint64 upgradeSequence, Channel.State channelState);

    /// @notice emitted when channelUpgradeOpen is successfully executed
    event ChannelUpgradeOpen(string portId, string channelId, uint64 upgradeSequence);

    /// @notice error when the upgrade attempt fails
    /// @param portId port identifier
    /// @param channelId channel identifier
    /// @param upgradeSequence upgrade sequence
    event WriteErrorReceipt(string portId, string channelId, uint64 upgradeSequence, string message);

    // --------------------- Structs --------------------- //

    enum UpgradeHandshakeError {
        None,
        Overwritten,
        OutOfSync,
        Timeout,
        Cancel,
        IncompatibleProposal,
        AckCallbackFailed
    }

    struct MsgChannelUpgradeInit {
        string portId;
        string channelId;
        UpgradeFields.Data proposedUpgradeFields;
    }

    struct MsgChannelUpgradeTry {
        string portId;
        string channelId;
        uint64 counterpartyUpgradeSequence;
        UpgradeFields.Data counterpartyUpgradeFields;
        string[] proposedConnectionHops;
        ChannelUpgradeProofs proofs;
    }

    struct MsgChannelUpgradeAck {
        string portId;
        string channelId;
        Upgrade.Data counterpartyUpgrade;
        ChannelUpgradeProofs proofs;
    }

    struct MsgChannelUpgradeConfirm {
        string portId;
        string channelId;
        Channel.State counterpartyChannelState;
        Upgrade.Data counterpartyUpgrade;
        ChannelUpgradeProofs proofs;
    }

    struct MsgChannelUpgradeOpen {
        string portId;
        string channelId;
        Channel.State counterpartyChannelState;
        uint64 counterpartyUpgradeSequence;
        bytes proofChannel;
        Height.Data proofHeight;
    }

    struct MsgCancelChannelUpgrade {
        string portId;
        string channelId;
        ErrorReceipt.Data errorReceipt;
        bytes proofUpgradeError;
        Height.Data proofHeight;
    }

    struct MsgTimeoutChannelUpgrade {
        string portId;
        string channelId;
        Channel.Data counterpartyChannel;
        bytes proofChannel;
        Height.Data proofHeight;
    }

    struct ChannelUpgradeProofs {
        bytes proofChannel;
        bytes proofUpgrade;
        Height.Data proofHeight;
    }
}

interface IIBCChannelUpgradeInitTryAck is IIBCChannelUpgradeBase {
    // --------------------- External Functions --------------------- //

    /**
     * @dev channelUpgradeInit is called by a module to initiate a channel upgrade handshake with
     * a module on another chain.
     * The current channel state must be OPEN. The post channel state is always OPEN.
     */
    function channelUpgradeInit(MsgChannelUpgradeInit calldata msg_) external returns (uint64 upgradeSequence);

    /**
     * @dev channelUpgradeTry is called by a module to accept the first step of a channel upgrade handshake initiated by
     * a module on another chain.
     * The current channel state must be OPEN. The post channel state will be OPEN or FLUSHING.
     * If this function is successful, the proposed upgrade will be emitted as event.
     * If the upgrade fails, the upgrade sequence will still be incremented but an error will be returned.
     */
    function channelUpgradeTry(MsgChannelUpgradeTry calldata msg_) external returns (bool ok, uint64 upgradeSequence);

    /**
     * @dev channelUpgradeAck is called by a module to accept the ACKUPGRADE handshake step of the channel upgrade protocol.
     * This method will verify that the counterparty has called the channelUpgradeTry handler.
     * and that its own upgrade is compatible with the selected counterparty version.
     *
     * NOTE: The current channel may be in either the OPEN or FLUSHING state.
     * The channel may be in OPEN if we are in the happy path.
     *   A -> Init (OPEN), B -> Try (FLUSHING), A -> Ack (begins in OPEN, ends in FLUSHING or FLUSHCOMPLETE)
     *
     * The channel may be in FLUSHING if we are in a crossing hellos situation.
     *   A -> Init (OPEN), B -> Init (OPEN) -> A -> Try (FLUSHING), B -> Try (FLUSHING), A -> Ack (begins in FLUSHING, ends in FLUSHING or FLUSHCOMPLETE)
     */
    function channelUpgradeAck(MsgChannelUpgradeAck calldata msg_) external returns (bool);
}

interface IIBCChannelUpgradeConfirmOpenTimeoutCancel is IIBCChannelUpgradeBase {
    // --------------------- External Functions --------------------- //

    /**
     * @dev channelUpgradeConfirm is called on the chain which is on FLUSHING after channelUpgradeAck is called on the counterparty.
     * This will inform the TRY chain of the timeout set on ACK by the counterparty. If the timeout has already exceeded,
     * we will write an error receipt and restore the channel to OPEN state.
     */
    function channelUpgradeConfirm(MsgChannelUpgradeConfirm calldata msg_) external returns (bool);

    /**
     * @dev channelUpgradeOpen is called by a module to complete the channel upgrade handshake and move the channel back to an OPEN state.
     * This method should only be called after both channels have flushed any in-flight packets.
     */
    function channelUpgradeOpen(MsgChannelUpgradeOpen calldata msg_) external;

    /**
     * @dev cancelChannelUpgrade proves that an error receipt was written on the counterparty
     * which constitutes a valid situation where the upgrade should be cancelled.
     * The tx reverts if sufficient evidence for cancelling the upgrade has not been provided.
     */
    function cancelChannelUpgrade(MsgCancelChannelUpgrade calldata msg_) external;

    /**
     * @dev timeoutChannelUpgrade times out an outstanding upgrade.
     * This should be used by the initialising chain when the counterparty chain has not responded to an upgrade proposal within the specified timeout period.
     */
    function timeoutChannelUpgrade(MsgTimeoutChannelUpgrade calldata msg_) external;
}

interface IIBCChannelUpgrade is IIBCChannelUpgradeInitTryAck, IIBCChannelUpgradeConfirmOpenTimeoutCancel {}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {Channel} from "../../proto/Channel.sol";
import {IIBCChannelErrors} from "./IIBCChannelErrors.sol";

interface IIBCChannelUpgradeErrors is IIBCChannelErrors {
    error IBCChannelUpgradeNoChanges();

    error IBCChannelUpgradeInvalidUpgradeFields();

    /// @notice proposed upgrade must be non-empty
    error IBCChannelUpgradeTryProposedConnectionHopsEmpty();

    /// @notice proposal's connection hops mismatch with the existing proposal
    error IBCChannelUpgradeTryProposedConnectionHopsMismatch();

    /// @param upgrader address of the upgrader
    error IBCChannelUpgradeUnauthorizedChannelUpgrader(address upgrader);

    error IBCChannelUpgradeIncompatibleProposal();

    error IBCChannelUpgradeErrorReceiptEmpty();

    /// @param latestSequence latest upgrade sequence
    /// @param sequence upgrade sequence
    error IBCChannelUpgradeWriteOldErrorReceiptSequence(uint64 latestSequence, uint64 sequence);

    error IBCChannelUpgradeNoExistingUpgrade();

    /// @param state channel state
    error IBCChannelUpgradeNotFlushing(Channel.State state);

    /// @param state channel state
    error IBCChannelUpgradeNotOpenOrFlushing(Channel.State state);

    /// @param state channel state
    error IBCChannelUpgradeCounterpartyNotOpenOrFlushcomplete(Channel.State state);

    /// @notice counterparty channel not flushing or flushcomplete
    /// @param state channel state
    error IBCChannelUpgradeCounterpartyNotFlushingOrFlushcomplete(Channel.State state);

    /// @param state channel state
    error IBCChannelUpgradeNotFlushcomplete(Channel.State state);

    /// @param clientId client identifier
    /// @param path key path
    /// @param value key value
    /// @param proof proof of membership
    /// @param height proof height
    error IBCChannelUpgradeFailedVerifyMembership(
        string clientId, string path, bytes value, bytes proof, Height.Data height
    );

    error IBCChannelUpgradeTimeoutHeightNotReached();

    error IBCChannelUpgradeTimeoutTimestampNotReached();

    error IBCChannelUpgradeInvalidTimeout();

    error IBCChannelUpgradeCounterpartyAlreadyFlushCompleted();

    error IBCChannelUpgradeCounterpartyAlreadyUpgraded();

    error IBCChannelUpgradeTimeoutUnallowedState();

    error IBCChannelUpgradeOldErrorReceiptSequence();

    error IBCChannelUpgradeInvalidErrorReceiptSequence();

    error IBCChannelUpgradeOldCounterpartyUpgradeSequence();

    error IBCChannelUpgradeUnsupportedOrdering(Channel.Order ordering);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library IBCCommitment {
    // Commitment paths comply with https://github.com/cosmos/ibc/tree/main/spec/core/ics-024-host-requirements#path-space

    function clientStatePath(string memory clientId) internal pure returns (bytes memory) {
        return abi.encodePacked("clients/", clientId, "/clientState");
    }

    function consensusStatePath(string memory clientId, uint64 revisionNumber, uint64 revisionHeight)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            "clients/",
            clientId,
            "/consensusStates/",
            Strings.toString(revisionNumber),
            "-",
            Strings.toString(revisionHeight)
        );
    }

    function connectionPath(string memory connectionId) internal pure returns (bytes memory) {
        return abi.encodePacked("connections/", connectionId);
    }

    function channelPath(string memory portId, string memory channelId) internal pure returns (bytes memory) {
        return abi.encodePacked("channelEnds/ports/", portId, "/channels/", channelId);
    }

    function packetCommitmentPathCalldata(string calldata portId, string calldata channelId, uint64 sequence)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            "commitments/ports/", portId, "/channels/", channelId, "/sequences/", Strings.toString(sequence)
        );
    }

    function packetAcknowledgementCommitmentPathCalldata(
        string calldata portId,
        string calldata channelId,
        uint64 sequence
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked("acks/ports/", portId, "/channels/", channelId, "/sequences/", Strings.toString(sequence));
    }

    function packetReceiptCommitmentPathCalldata(string calldata portId, string calldata channelId, uint64 sequence)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            "receipts/ports/", portId, "/channels/", channelId, "/sequences/", Strings.toString(sequence)
        );
    }

    function nextSequenceRecvCommitmentPath(string memory portId, string memory channelId)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked("nextSequenceRecv/ports/", portId, "/channels/", channelId);
    }

    function nextSequenceRecvCommitmentPathCalldata(string calldata portId, string calldata channelId)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked("nextSequenceRecv/ports/", portId, "/channels/", channelId);
    }

    function channelUpgradePath(string memory portId, string memory channelId) internal pure returns (bytes memory) {
        return abi.encodePacked("channelUpgrades/upgrades/ports/", portId, "/channels/", channelId);
    }

    function channelUpgradeErrorPath(string memory portId, string memory channelId)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked("channelUpgrades/upgradeError/ports/", portId, "/channels/", channelId);
    }

    // Key generators for Commitment mapping

    function clientStateCommitmentKey(string memory clientId) internal pure returns (bytes32) {
        return keccak256(clientStatePath(clientId));
    }

    function consensusStateCommitmentKey(string memory clientId, uint64 revisionNumber, uint64 revisionHeight)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(consensusStatePath(clientId, revisionNumber, revisionHeight));
    }

    function connectionCommitmentKey(string memory connectionId) internal pure returns (bytes32) {
        return keccak256(connectionPath(connectionId));
    }

    function channelCommitmentKey(string memory portId, string memory channelId) internal pure returns (bytes32) {
        return keccak256(channelPath(portId, channelId));
    }

    function nextSequenceRecvCommitmentKey(string memory portId, string memory channelId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(nextSequenceRecvCommitmentPath(portId, channelId));
    }

    function packetCommitmentKeyCalldata(string calldata portId, string calldata channelId, uint64 sequence)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(packetCommitmentPathCalldata(portId, channelId, sequence));
    }

    function packetAcknowledgementCommitmentKeyCalldata(
        string calldata portId,
        string calldata channelId,
        uint64 sequence
    ) internal pure returns (bytes32) {
        return keccak256(packetAcknowledgementCommitmentPathCalldata(portId, channelId, sequence));
    }

    function packetReceiptCommitmentKeyCalldata(string calldata portId, string calldata channelId, uint64 sequence)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(packetReceiptCommitmentPathCalldata(portId, channelId, sequence));
    }

    function nextSequenceRecvCommitmentKeyCalldata(string calldata portId, string calldata channelId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(nextSequenceRecvCommitmentPathCalldata(portId, channelId));
    }

    function channelUpgradeCommitmentKey(string memory portId, string memory channelId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(channelUpgradePath(portId, channelId));
    }

    function channelUpgradeErrorCommitmentKey(string memory portId, string memory channelId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(channelUpgradeErrorPath(portId, channelId));
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ILightClient} from "../02-client/ILightClient.sol";
import {IIBCClientErrors} from "../02-client/IIBCClientErrors.sol";
import {IBCStore} from "./IBCStore.sol";
import {IIBCHostErrors} from "./IIBCHostErrors.sol";

contract IBCHost is IBCStore, IIBCHostErrors {
    // It represents the prefix of the commitment proof(https://github.com/cosmos/ibc/tree/main/spec/core/ics-023-vector-commitments#prefix).
    // In ibc-solidity, the prefix is not required, but for compatibility with ibc-go this must be a non-empty value.
    bytes internal constant DEFAULT_COMMITMENT_PREFIX = bytes("ibc");

    /**
     * @dev hostTimestamp returns the current timestamp(Unix time in nanoseconds) of the host chain.
     */
    function hostTimestamp() internal view virtual returns (uint64) {
        return uint64(block.timestamp) * 1e9;
    }

    /**
     * @dev checkAndGetClient returns the client implementation for the given client ID.
     */
    function checkAndGetClient(string memory clientId) internal view returns (ILightClient) {
        address clientImpl = getClientStorage()[clientId].clientImpl;
        if (clientImpl == address(0)) {
            revert IIBCClientErrors.IBCClientClientNotFound(clientId);
        }
        return ILightClient(clientImpl);
    }

    /**
     * @dev _getCommitmentPrefix returns the prefix of the commitment proof.
     */
    function _getCommitmentPrefix() internal view virtual returns (bytes memory) {
        return DEFAULT_COMMITMENT_PREFIX;
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IBCClientLib} from "../02-client/IBCClientLib.sol";
import {ILightClient} from "../02-client/ILightClient.sol";
import {IBCHostLib} from "./IBCHostLib.sol";
import {IBCModuleManager} from "../26-router/IBCModuleManager.sol";
import {IIBCModule, IIBCModuleInitializer} from "../26-router/IIBCModule.sol";
import {IIBCHostConfigurator} from "./IIBCHostConfigurator.sol";

/**
 * @dev IBCHostConfigurator is a contract that provides the host configuration.
 */
abstract contract IBCHostConfigurator is IIBCHostConfigurator, IBCModuleManager {
    function _setExpectedTimePerBlock(uint64 expectedTimePerBlock_) internal virtual {
        getHostStorage().expectedTimePerBlock = expectedTimePerBlock_;
    }

    function _registerClient(string calldata clientType, ILightClient client) internal virtual {
        HostStorage storage hostStorage = getHostStorage();
        if (!IBCClientLib.validateClientType(bytes(clientType))) {
            revert IBCHostInvalidClientType(clientType);
        } else if (address(hostStorage.clientRegistry[clientType]) != address(0)) {
            revert IBCHostClientTypeAlreadyExists(clientType);
        }
        if (address(client) == address(0) || address(client) == address(this)) {
            revert IBCHostInvalidLightClientAddress(address(client));
        }
        hostStorage.clientRegistry[clientType] = address(client);
    }

    function _bindPort(string calldata portId, IIBCModuleInitializer module) internal virtual {
        address moduleAddress = address(module);
        if (!IBCHostLib.validatePortIdentifier(bytes(portId))) {
            revert IBCHostInvalidPortIdentifier(portId);
        }
        if (moduleAddress == address(0) || moduleAddress == address(this)) {
            revert IBCHostInvalidModuleAddress(moduleAddress);
        }
        if (!ERC165Checker.supportsERC165(moduleAddress)) {
            revert IBCHostModuleDoesNotSupportERC165();
        }
        if (
            !(
                ERC165Checker.supportsERC165InterfaceUnchecked(moduleAddress, type(IIBCModule).interfaceId)
                    || ERC165Checker.supportsERC165InterfaceUnchecked(
                        moduleAddress, type(IIBCModuleInitializer).interfaceId
                    )
            )
        ) {
            revert IBCHostModuleDoesNotSupportIIBCModuleInitializer(
                moduleAddress, type(IIBCModuleInitializer).interfaceId
            );
        }
        claimPortCapability(portId, moduleAddress);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

library IBCHostLib {
    /**
     * @dev validatePortIdentifier validates a port identifier string
     * check if the string consist of characters in one of the following categories only:
     * - Alphanumeric
     * - `.`, `_`, `+`, `-`, `#`
     * - `[`, `]`, `<`, `>`
     *
     * The validation is based on the ibc-go implementation:
     * https://github.com/cosmos/ibc-go/blob/b0ed0b412ea75e66091cc02746c95f9e6cf4445d/modules/core/24-host/validate.go#L86
     */
    function validatePortIdentifier(bytes memory portId) internal pure returns (bool) {
        uint256 portIdLength = portId.length;
        if (portIdLength < 2 || portIdLength > 128) {
            return false;
        }
        for (uint256 i = 0; i < portIdLength; i++) {
            uint256 c = uint256(uint8(portId[i]));
            // return false if the character is not in one of the following categories:
            // a-z
            // 0-9
            // A-Z
            // ".", "_", "+", "-"
            // "#", "[", "]", "<", ">"
            if (
                !(c >= 0x61 && c <= 0x7A) && !(c >= 0x30 && c <= 0x39) && !(c >= 0x41 && c <= 0x5A)
                    && !(c == 0x2E || c == 0x5F || c == 0x2B || c == 0x2D)
                    && !(c == 0x23 || c == 0x5B || c == 0x5D || c == 0x3C || c == 0x3E)
            ) {
                return false;
            }
        }
        return true;
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ConnectionEnd} from "../../proto/Connection.sol";
import {Channel, Upgrade} from "../../proto/Channel.sol";

abstract contract IBCStore {
    // keccak256(abi.encode(uint256(keccak256("ibc.commitment")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant COMMITMENT_STORAGE_LOCATION =
        0x1ee222554989dda120e26ecacf756fe1235cd8d726706b57517715dde4f0c900;

    // keccak256(abi.encode(uint256(keccak256("ibc.host")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant HOST_STORAGE_LOCATION = 0x74277c96171a830beeb656543654929b9b37cec88976b4c31924799951550500;

    // keccak256(abi.encode(uint256(keccak256("ibc.client")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant CLIENT_STORAGE_LOCATION =
        0x521e6acb905d37b69880078e1a941104ad5d8bcb8c5cf52f1d5f47d31739d500;

    // keccak256(abi.encode(uint256(keccak256("ibc.connection")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant CONNECTION_STORAGE_LOCATION =
        0x9ef02a9acd7179d999aa130fa65a34ac06dd2f1bae667ae0fb55000408793800;

    // keccak256(abi.encode(uint256(keccak256("ibc.channel")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant CHANNEL_STORAGE_LOCATION =
        0x1952ed347963c5b7b1856335782fc9c26716d4219254baf3dfc6b26981b2dc00;

    /// @custom:storage-location erc7201:ibc.commitment
    struct CommitmentStorage {
        mapping(bytes32 => bytes32) commitments;
    }

    /// @custom:storage-location erc7201:ibc.host
    struct HostStorage {
        mapping(string => address) clientRegistry;
        mapping(string => address) portCapabilities;
        mapping(string => mapping(string => address)) channelCapabilities;
        uint64 nextClientSequence;
        uint64 nextConnectionSequence;
        uint64 nextChannelSequence;
        uint64 expectedTimePerBlock;
    }

    /// @custom:storage-location erc7201:ibc.client
    struct ClientStorage {
        string clientType;
        address clientImpl;
    }

    /// @custom:storage-location erc7201:ibc.connection
    struct ConnectionStorage {
        ConnectionEnd.Data connection;
    }

    struct RecvStartSequence {
        uint64 sequence;
        uint64 prevSequence;
    }

    /// @custom:storage-location erc7201:ibc.channel
    struct ChannelStorage {
        Channel.Data channel;
        uint64 nextSequenceSend;
        uint64 nextSequenceRecv;
        uint64 nextSequenceAck;
        Upgrade.Data upgrade;
        uint64 latestErrorReceiptSequence;
        RecvStartSequence recvStartSequence;
        uint64 ackStartSequence;
    }

    /**
     * @dev getCommitments returns the commitment storage
     */
    function getCommitments() internal pure returns (mapping(bytes32 => bytes32) storage $) {
        assembly {
            // this is safe because first field of CommitmentStorage is a commitments mapping
            $.slot := COMMITMENT_STORAGE_LOCATION
        }
    }

    /**
     * @dev getHostStorage returns the host storage
     */
    function getHostStorage() internal pure returns (HostStorage storage $) {
        assembly {
            $.slot := HOST_STORAGE_LOCATION
        }
    }

    /**
     * @dev getClientStorage returns the client storage
     */
    function getClientStorage() internal pure returns (mapping(string => ClientStorage) storage $) {
        assembly {
            $.slot := CLIENT_STORAGE_LOCATION
        }
    }

    /**
     * @dev getConnectionStorage returns the connection storage
     */
    function getConnectionStorage() internal pure returns (mapping(string => ConnectionStorage) storage $) {
        assembly {
            $.slot := CONNECTION_STORAGE_LOCATION
        }
    }

    /**
     * @dev getChannelStorage returns the channel storage
     */
    function getChannelStorage()
        internal
        pure
        returns (mapping(string => mapping(string => ChannelStorage)) storage $)
    {
        assembly {
            $.slot := CHANNEL_STORAGE_LOCATION
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ILightClient} from "../02-client/ILightClient.sol";
import {IIBCModuleInitializer} from "../26-router/IIBCModule.sol";

interface IIBCHostConfigurator {
    /**
     * @dev setExpectedTimePerBlock sets expected time per block.
     * Typically this function should be called by an authority like an IBC contract owner or govenance.
     */
    function setExpectedTimePerBlock(uint64 expectedTimePerBlock_) external;

    /**
     * @dev registerClient registers a new client type into the client registry
     * Typically this function should be called by an authority like an IBC contract owner or govenance.
     * The authority should verify the light client contract is a valid implementation as follows:
     * - The contract implements ILightClient
     * - To avoid reentrancy attack, the contract never performs `call` to the IBC contract directly or indirectly in the `verifyMembership` and the `verifyNonMembership`
     */
    function registerClient(string calldata clientType, ILightClient client) external;

    /**
     * @dev bindPort binds to an unallocated port, failing if the port has already been allocated.
     * Typically this function should be called by an authority like an IBC contract owner or govenance.
     * The authority should verify the light client contract is a valid implementation as follows:
     * - The contract implements IIBCModuleInitializer
     */
    function bindPort(string calldata portId, IIBCModuleInitializer moduleAddress) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

interface IIBCHostErrors {
    /// @param clientType client type
    error IBCHostInvalidClientType(string clientType);

    /// @param clientType client type
    error IBCHostClientTypeAlreadyExists(string clientType);

    /// @param portId port identifier
    error IBCHostInvalidPortIdentifier(string portId);

    /// @param lcAddress light client contract address
    error IBCHostInvalidLightClientAddress(address lcAddress);

    /// @param moduleAddress module contract address
    error IBCHostInvalidModuleAddress(address moduleAddress);

    /// @param portId port identifier
    error IBCHostModulePortNotFound(string portId);

    /// @param portId port identifier
    /// @param channelId channel identifier
    error IBCHostModuleChannelNotFound(string portId, string channelId);

    error IBCHostModuleDoesNotSupportERC165();

    /// @param module module contract address
    /// @param interfaceId expected interface identifier
    error IBCHostModuleDoesNotSupportIIBCModule(address module, bytes4 interfaceId);

    /// @param module module contract address
    /// @param interfaceId expected interface identifier
    error IBCHostModuleDoesNotSupportIIBCModuleInitializer(address module, bytes4 interfaceId);

    /// @param module module contract address
    error IBCHostModuleDoesNotSupportIIBCModuleUpgrade(address module);

    /// @param portId port identifier
    error IBCHostPortCapabilityAlreadyClaimed(string portId);

    /// @param portId port identifier
    /// @param channelId channel identifier
    error IBCHostChannelCapabilityAlreadyClaimed(string portId, string channelId);

    /// @param portId port identifier
    /// @param channelId channel identifier
    /// @param caller caller address
    error IBCHostFailedAuthenticateChannelCapability(string portId, string channelId, address caller);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {IIBCClient} from "../02-client/IIBCClient.sol";
import {IIBCConnection} from "../03-connection/IIBCConnection.sol";
import {
    IIBCChannelHandshake, IIBCChannelPacketSendRecv, IIBCChannelPacketTimeout
} from "../04-channel/IIBCChannel.sol";
import {
    IIBCChannelUpgrade,
    IIBCChannelUpgradeInitTryAck,
    IIBCChannelUpgradeConfirmOpenTimeoutCancel
} from "../04-channel/IIBCChannelUpgrade.sol";

interface IBCHandlerViewFunctionWrapper {
    function wrappedRouteUpdateClient(IIBCClient.MsgUpdateClient calldata msg_)
        external
        view
        returns (address, bytes4, bytes memory);
}

/**
 * @dev IBCClientConnectionChannelHandler is a handler implements ICS-02, ICS-03, and ICS-04
 */
abstract contract IBCClientConnectionChannelHandler is
    IIBCClient,
    IIBCConnection,
    IIBCChannelHandshake,
    IIBCChannelPacketSendRecv,
    IIBCChannelPacketTimeout,
    IIBCChannelUpgrade
{
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcClient;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcConnection;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcChannelHandshake;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcChannelPacketSendRecv;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcChannelPacketTimeout;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcChannelUpgradeInitTryAck;
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address internal immutable ibcChannelUpgradeConfirmOpenTimeoutCancel;

    /**
     * @dev The arguments of constructor must satisfy the followings:
     * @param ibcClient_ is the address of a contract that implements `IIBCClient`.
     * @param ibcConnection_ is the address of a contract that implements `IIBCConnection`.
     * @param ibcChannelHandshake_ is the address of a contract that implements `IIBCChannelHandshake`.
     * @param ibcChannelPacketSendRecv_ is the address of a contract that implements `IICS04Wrapper + IIBCChannelPacketReceiver`.
     * @param ibcChannelPacketTimeout_ is the address of a contract that implements `IIBCChannelPacketTimeout`.
     * @param ibcChannelUpgradeInitTryAck_ is the address of a contract that implements `IIBCChannelUpgradeInitTryAck`.
     * @param ibcChannelUpgradeConfirmOpenTimeoutCancel_ is the address of a contract that implements `IIBCChannelUpgradeConfirmOpenTimeoutCancel`.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor(
        IIBCClient ibcClient_,
        IIBCConnection ibcConnection_,
        IIBCChannelHandshake ibcChannelHandshake_,
        IIBCChannelPacketSendRecv ibcChannelPacketSendRecv_,
        IIBCChannelPacketTimeout ibcChannelPacketTimeout_,
        IIBCChannelUpgradeInitTryAck ibcChannelUpgradeInitTryAck_,
        IIBCChannelUpgradeConfirmOpenTimeoutCancel ibcChannelUpgradeConfirmOpenTimeoutCancel_
    ) {
        ibcClient = address(ibcClient_);
        ibcConnection = address(ibcConnection_);
        ibcChannelHandshake = address(ibcChannelHandshake_);
        ibcChannelPacketSendRecv = address(ibcChannelPacketSendRecv_);
        ibcChannelPacketTimeout = address(ibcChannelPacketTimeout_);
        ibcChannelUpgradeInitTryAck = address(ibcChannelUpgradeInitTryAck_);
        ibcChannelUpgradeConfirmOpenTimeoutCancel = address(ibcChannelUpgradeConfirmOpenTimeoutCancel_);
    }

    function createClient(MsgCreateClient calldata) external returns (string memory) {
        doFallback(ibcClient);
    }

    function updateClient(MsgUpdateClient calldata) external {
        doFallback(ibcClient);
    }

    function updateClientCommitments(string calldata, Height.Data[] calldata) external {
        doFallback(ibcClient);
    }

    function routeUpdateClient(MsgUpdateClient calldata msg_) external view returns (address, bytes4, bytes memory) {
        return IBCHandlerViewFunctionWrapper(address(this)).wrappedRouteUpdateClient(msg_);
    }

    function wrappedRouteUpdateClient(MsgUpdateClient calldata msg_) public returns (address, bytes4, bytes memory) {
        /// @custom:oz-upgrades-unsafe-allow delegatecall
        (bool success, bytes memory returndata) =
            address(ibcClient).delegatecall(abi.encodeWithSelector(IIBCClient.routeUpdateClient.selector, msg_));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("routeUpdateClient failed");
            }
        }
        return abi.decode(returndata, (address, bytes4, bytes));
    }

    function connectionOpenInit(IIBCConnection.MsgConnectionOpenInit calldata) external returns (string memory) {
        doFallback(ibcConnection);
    }

    function connectionOpenTry(IIBCConnection.MsgConnectionOpenTry calldata) external returns (string memory) {
        doFallback(ibcConnection);
    }

    function connectionOpenAck(IIBCConnection.MsgConnectionOpenAck calldata) external {
        doFallback(ibcConnection);
    }

    function connectionOpenConfirm(IIBCConnection.MsgConnectionOpenConfirm calldata) external {
        doFallback(ibcConnection);
    }

    function channelOpenInit(IIBCChannelHandshake.MsgChannelOpenInit calldata)
        external
        returns (string memory, string memory)
    {
        doFallback(ibcChannelHandshake);
    }

    function channelOpenTry(IIBCChannelHandshake.MsgChannelOpenTry calldata)
        external
        returns (string memory, string memory)
    {
        doFallback(ibcChannelHandshake);
    }

    function channelOpenAck(IIBCChannelHandshake.MsgChannelOpenAck calldata) external {
        doFallback(ibcChannelHandshake);
    }

    function channelOpenConfirm(IIBCChannelHandshake.MsgChannelOpenConfirm calldata) external {
        doFallback(ibcChannelHandshake);
    }

    function channelCloseInit(IIBCChannelHandshake.MsgChannelCloseInit calldata) external {
        doFallback(ibcChannelHandshake);
    }

    function channelCloseConfirm(IIBCChannelHandshake.MsgChannelCloseConfirm calldata) external {
        doFallback(ibcChannelHandshake);
    }

    function sendPacket(string calldata, string calldata, Height.Data calldata, uint64, bytes calldata)
        external
        returns (uint64)
    {
        doFallback(ibcChannelPacketSendRecv);
    }

    function writeAcknowledgement(string calldata, string calldata, uint64, bytes calldata) external {
        doFallback(ibcChannelPacketSendRecv);
    }

    function recvPacket(MsgPacketRecv calldata) external {
        doFallback(ibcChannelPacketSendRecv);
    }

    function acknowledgePacket(MsgPacketAcknowledgement calldata) external {
        doFallback(ibcChannelPacketSendRecv);
    }

    function timeoutPacket(MsgTimeoutPacket calldata) external {
        doFallback(ibcChannelPacketTimeout);
    }

    function timeoutOnClose(MsgTimeoutOnClose calldata) external {
        doFallback(ibcChannelPacketTimeout);
    }

    function channelUpgradeInit(MsgChannelUpgradeInit calldata) external returns (uint64) {
        doFallback(ibcChannelUpgradeInitTryAck);
    }

    function channelUpgradeTry(MsgChannelUpgradeTry calldata) external returns (bool, uint64) {
        doFallback(ibcChannelUpgradeInitTryAck);
    }

    function channelUpgradeAck(MsgChannelUpgradeAck calldata) external returns (bool) {
        doFallback(ibcChannelUpgradeInitTryAck);
    }

    function channelUpgradeConfirm(MsgChannelUpgradeConfirm calldata) external returns (bool) {
        doFallback(ibcChannelUpgradeConfirmOpenTimeoutCancel);
    }

    function channelUpgradeOpen(MsgChannelUpgradeOpen calldata) external {
        doFallback(ibcChannelUpgradeConfirmOpenTimeoutCancel);
    }

    function cancelChannelUpgrade(MsgCancelChannelUpgrade calldata) external {
        doFallback(ibcChannelUpgradeConfirmOpenTimeoutCancel);
    }

    function timeoutChannelUpgrade(MsgTimeoutChannelUpgrade calldata) external {
        doFallback(ibcChannelUpgradeConfirmOpenTimeoutCancel);
    }

    function doFallback(address impl) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IIBCClient} from "../02-client/IIBCClient.sol";
import {IIBCConnection} from "../03-connection/IIBCConnection.sol";
import {
    IIBCChannelHandshake, IIBCChannelPacketSendRecv, IIBCChannelPacketTimeout
} from "../04-channel/IIBCChannel.sol";
import {
    IIBCChannelUpgradeInitTryAck,
    IIBCChannelUpgradeConfirmOpenTimeoutCancel
} from "../04-channel/IIBCChannelUpgrade.sol";
import {IBCHostConfigurator} from "../24-host/IBCHostConfigurator.sol";
import {IBCClientConnectionChannelHandler} from "./IBCClientConnectionChannelHandler.sol";
import {IBCQuerier} from "./IBCQuerier.sol";
import {IIBCHandler} from "./IIBCHandler.sol";

abstract contract IBCHandler is IBCHostConfigurator, IBCClientConnectionChannelHandler, IBCQuerier, IIBCHandler {
    /**
     * @dev The arguments of constructor must satisfy the followings:
     * @param ibcClient_ is the address of a contract that implements `IIBCClient`.
     * @param ibcConnection_ is the address of a contract that implements `IIBCConnection`.
     * @param ibcChannelHandshake_ is the address of a contract that implements `IIBCChannelHandshake`.
     * @param ibcChannelPacketSendRecv_ is the address of a contract that implements `IIBCChannelPacketSendRecv`.
     * @param ibcChannelPacketTimeout_ is the address of a contract that implements `IIBCChannelPacketTimeout`.
     * @param ibcChannelUpgradeInitTryAck_ is the address of a contract that implements `IIBCChannelUpgrade`.
     * @param ibcChannelUpgradeConfirmOpenTimeoutCancel_ is the address of a contract that implements `IIBCChannelUpgrade`.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor(
        IIBCClient ibcClient_,
        IIBCConnection ibcConnection_,
        IIBCChannelHandshake ibcChannelHandshake_,
        IIBCChannelPacketSendRecv ibcChannelPacketSendRecv_,
        IIBCChannelPacketTimeout ibcChannelPacketTimeout_,
        IIBCChannelUpgradeInitTryAck ibcChannelUpgradeInitTryAck_,
        IIBCChannelUpgradeConfirmOpenTimeoutCancel ibcChannelUpgradeConfirmOpenTimeoutCancel_
    )
        IBCClientConnectionChannelHandler(
            ibcClient_,
            ibcConnection_,
            ibcChannelHandshake_,
            ibcChannelPacketSendRecv_,
            ibcChannelPacketTimeout_,
            ibcChannelUpgradeInitTryAck_,
            ibcChannelUpgradeConfirmOpenTimeoutCancel_
        )
    {}
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {ConnectionEnd} from "../../proto/Connection.sol";
import {Channel, Upgrade} from "../../proto/Channel.sol";
import {IBCChannelLib} from "../04-channel/IBCChannelLib.sol";
import {IBCCommitment} from "../24-host/IBCCommitment.sol";
import {IIBCModule, IIBCModuleInitializer} from "../26-router/IIBCModule.sol";
import {IBCModuleManager} from "../26-router/IBCModuleManager.sol";
import {IIBCQuerier} from "./IIBCQuerier.sol";

contract IBCQuerier is IBCModuleManager, IIBCQuerier {
    function getCommitmentPrefix() public view override returns (bytes memory) {
        return _getCommitmentPrefix();
    }

    function getCommitmentsSlot() public pure override returns (bytes32) {
        return COMMITMENT_STORAGE_LOCATION;
    }

    function getCommitment(bytes32 hashedPath) public view override returns (bytes32) {
        return getCommitments()[hashedPath];
    }

    function getExpectedTimePerBlock() public view override returns (uint64) {
        return getHostStorage().expectedTimePerBlock;
    }

    function getIBCModuleByPort(string calldata portId) public view override returns (IIBCModuleInitializer) {
        return lookupModuleByPort(portId);
    }

    function getIBCModuleByChannel(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (IIBCModule)
    {
        return lookupModuleByChannel(portId, channelId);
    }

    function getClientByType(string calldata clientType) public view override returns (address) {
        return getHostStorage().clientRegistry[clientType];
    }

    function getClientType(string calldata clientId) public view override returns (string memory) {
        return getClientStorage()[clientId].clientType;
    }

    function getClient(string calldata clientId) public view override returns (address) {
        return getClientStorage()[clientId].clientImpl;
    }

    function getClientState(string calldata clientId) public view override returns (bytes memory, bool) {
        return checkAndGetClient(clientId).getClientState(clientId);
    }

    function getConsensusState(string calldata clientId, Height.Data calldata height)
        public
        view
        override
        returns (bytes memory consensusStateBytes, bool)
    {
        return checkAndGetClient(clientId).getConsensusState(clientId, height);
    }

    function getConnection(string calldata connectionId)
        public
        view
        override
        returns (ConnectionEnd.Data memory, bool)
    {
        ConnectionEnd.Data storage connection = getConnectionStorage()[connectionId].connection;
        return (connection, connection.state != ConnectionEnd.State.STATE_UNINITIALIZED_UNSPECIFIED);
    }

    function getChannel(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (Channel.Data memory, bool)
    {
        Channel.Data storage channel = getChannelStorage()[portId][channelId].channel;
        return (channel, channel.state != Channel.State.STATE_UNINITIALIZED_UNSPECIFIED);
    }

    function getNextSequenceSend(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (uint64)
    {
        return getChannelStorage()[portId][channelId].nextSequenceSend;
    }

    function getNextSequenceRecv(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (uint64)
    {
        return getChannelStorage()[portId][channelId].nextSequenceRecv;
    }

    function getNextSequenceAck(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (uint64)
    {
        return getChannelStorage()[portId][channelId].nextSequenceAck;
    }

    function getPacketReceipt(string calldata portId, string calldata channelId, uint64 sequence)
        public
        view
        override
        returns (IBCChannelLib.PacketReceipt)
    {
        return IBCChannelLib.receiptCommitmentToReceipt(
            getCommitments()[IBCCommitment.packetReceiptCommitmentKeyCalldata(portId, channelId, sequence)]
        );
    }

    function getChannelUpgrade(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (Upgrade.Data memory, bool)
    {
        Upgrade.Data storage upgrade = getChannelStorage()[portId][channelId].upgrade;
        return (upgrade, upgrade.fields.connection_hops.length != 0);
    }

    function getCanTransitionToFlushComplete(string calldata portId, string calldata channelId)
        public
        view
        override
        returns (bool)
    {
        Channel.Data storage channel = getChannelStorage()[portId][channelId].channel;
        if (channel.state != Channel.State.STATE_FLUSHING) {
            return false;
        }
        return canTransitionToFlushComplete(channel.ordering, portId, channelId, channel.upgrade_sequence);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IIBCClient} from "../02-client/IIBCClient.sol";
import {IIBCClientErrors} from "../02-client/IIBCClientErrors.sol";
import {IIBCConnection} from "../03-connection/IIBCConnection.sol";
import {IIBCConnectionErrors} from "../03-connection/IIBCConnectionErrors.sol";
import {IIBCChannelHandshake, IIBCChannelPacket} from "../04-channel/IIBCChannel.sol";
import {IIBCChannelErrors} from "../04-channel/IIBCChannelErrors.sol";
import {IIBCChannelUpgrade} from "../04-channel/IIBCChannelUpgrade.sol";
import {IIBCChannelUpgradeErrors} from "../04-channel/IIBCChannelUpgradeErrors.sol";
import {IIBCHostConfigurator} from "../24-host/IIBCHostConfigurator.sol";
import {IIBCHostErrors} from "../24-host/IIBCHostErrors.sol";
import {IIBCModuleManager} from "../26-router/IIBCModuleManager.sol";
import {IIBCQuerier} from "./IIBCQuerier.sol";

/**
 * @dev IIBCHandler is a handler interface supports [ICS-25](https://github.com/cosmos/ibc/tree/main/spec/core/ics-025-handler-interface),
 */
interface IIBCHandler is
    IIBCClient,
    IIBCClientErrors,
    IIBCConnection,
    IIBCConnectionErrors,
    IIBCChannelHandshake,
    IIBCChannelPacket,
    IIBCChannelErrors,
    IIBCChannelUpgrade,
    IIBCChannelUpgradeErrors,
    IIBCHostConfigurator,
    IIBCHostErrors,
    IIBCModuleManager,
    IIBCQuerier
{}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Height} from "../../proto/Client.sol";
import {ConnectionEnd} from "../../proto/Connection.sol";
import {Channel, Upgrade} from "../../proto/Channel.sol";
import {IBCChannelLib} from "../04-channel/IBCChannelLib.sol";
import {IIBCModule, IIBCModuleInitializer} from "../26-router/IIBCModule.sol";

interface IIBCQuerier {
    function getCommitmentPrefix() external view returns (bytes memory);

    function getCommitmentsSlot() external pure returns (bytes32);

    function getCommitment(bytes32 hashedPath) external view returns (bytes32);

    function getExpectedTimePerBlock() external view returns (uint64);

    function getIBCModuleByPort(string calldata portId) external view returns (IIBCModuleInitializer);

    function getIBCModuleByChannel(string calldata portId, string calldata channelId)
        external
        view
        returns (IIBCModule);

    function getClientByType(string calldata clientType) external view returns (address);

    function getClientType(string calldata clientId) external view returns (string memory);

    function getClient(string calldata clientId) external view returns (address);

    function getClientState(string calldata clientId) external view returns (bytes memory, bool);

    function getConsensusState(string calldata clientId, Height.Data calldata height)
        external
        view
        returns (bytes memory, bool);

    function getConnection(string calldata connectionId) external view returns (ConnectionEnd.Data memory, bool);

    function getChannel(string calldata portId, string calldata channelId)
        external
        view
        returns (Channel.Data memory, bool);

    function getNextSequenceSend(string calldata portId, string calldata channelId) external view returns (uint64);

    function getNextSequenceRecv(string calldata portId, string calldata channelId) external view returns (uint64);

    function getNextSequenceAck(string calldata portId, string calldata channelId) external view returns (uint64);

    function getPacketReceipt(string calldata portId, string calldata channelId, uint64 sequence)
        external
        view
        returns (IBCChannelLib.PacketReceipt);

    function getChannelUpgrade(string calldata portId, string calldata channelId)
        external
        view
        returns (Upgrade.Data memory, bool);

    function getCanTransitionToFlushComplete(string calldata portId, string calldata channelId)
        external
        view
        returns (bool);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ILightClient} from "../02-client/ILightClient.sol";
import {IIBCClient} from "../02-client/IIBCClient.sol";
import {IIBCConnection} from "../03-connection/IIBCConnection.sol";
import {
    IIBCChannelHandshake, IIBCChannelPacketSendRecv, IIBCChannelPacketTimeout
} from "../04-channel/IIBCChannel.sol";
import {
    IIBCChannelUpgradeInitTryAck,
    IIBCChannelUpgradeConfirmOpenTimeoutCancel
} from "../04-channel/IIBCChannelUpgrade.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IIBCModuleInitializer} from "../26-router/IIBCModule.sol";
import {IBCHandler} from "./IBCHandler.sol";

/**
 * @dev OwnableIBCHandler is a contract that implements [ICS-25](https://github.com/cosmos/ibc/tree/main/spec/core/ics-025-handler-interface) and Ownable for host configuration.
 */
contract OwnableIBCHandler is IBCHandler, Ownable {
    /**
     * @dev The arguments of constructor must satisfy the followings:
     * @param ibcClient_ is the address of a contract that implements `IIBCClient`.
     * @param ibcConnection_ is the address of a contract that implements `IIBCConnection`.
     * @param ibcChannelHandshake_ is the address of a contract that implements `IIBCChannelHandshake`.
     * @param ibcChannelPacketSendRecv_ is the address of a contract that implements `IIBCChannelPacketSendRecv`.
     * @param ibcChannelPacketTimeout_ is the address of a contract that implements `IIBCChannelPacketTimeout`.
     * @param ibcChannelUpgradeInitTryAck_ is the address of a contract that implements `IIBCChannelUpgrade`.
     * @param ibcChannelUpgradeConfirmOpenTimeoutCancel_ is the address of a contract that implements `IIBCChannelUpgrade`.
     */
    constructor(
        IIBCClient ibcClient_,
        IIBCConnection ibcConnection_,
        IIBCChannelHandshake ibcChannelHandshake_,
        IIBCChannelPacketSendRecv ibcChannelPacketSendRecv_,
        IIBCChannelPacketTimeout ibcChannelPacketTimeout_,
        IIBCChannelUpgradeInitTryAck ibcChannelUpgradeInitTryAck_,
        IIBCChannelUpgradeConfirmOpenTimeoutCancel ibcChannelUpgradeConfirmOpenTimeoutCancel_
    )
        IBCHandler(
            ibcClient_,
            ibcConnection_,
            ibcChannelHandshake_,
            ibcChannelPacketSendRecv_,
            ibcChannelPacketTimeout_,
            ibcChannelUpgradeInitTryAck_,
            ibcChannelUpgradeConfirmOpenTimeoutCancel_
        )
        Ownable(msg.sender)
    {}

    function registerClient(string calldata clientType, ILightClient client) public onlyOwner {
        super._registerClient(clientType, client);
    }

    function bindPort(string calldata portId, IIBCModuleInitializer moduleAddress) public onlyOwner {
        super._bindPort(portId, moduleAddress);
    }

    function setExpectedTimePerBlock(uint64 expectedTimePerBlock_) public onlyOwner {
        super._setExpectedTimePerBlock(expectedTimePerBlock_);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IBCHost} from "../24-host/IBCHost.sol";
import {Channel} from "../../proto/Channel.sol";
import {IIBCModule, IIBCModuleInitializer} from "./IIBCModule.sol";
import {IIBCModuleUpgrade} from "./IIBCModuleUpgrade.sol";
import {IIBCModuleManager} from "./IIBCModuleManager.sol";

/**
 * @dev IBCModuleManager is a contract that provides the functions defined in [ICS 5](https://github.com/cosmos/ibc/tree/main/spec/core/ics-005-port-allocation) and [ICS 26](https://github.com/cosmos/ibc/tree/main/spec/core/ics-026-routing-module).
 */
contract IBCModuleManager is Context, IBCHost, IIBCModuleManager {
    /**
     * @dev claimPortCapability allows the IBC app module to claim a capability that core IBC passes to it
     */
    function claimPortCapability(string calldata portId, address module) internal {
        HostStorage storage hostStorage = getHostStorage();
        if (hostStorage.portCapabilities[portId] != address(0)) {
            revert IBCHostPortCapabilityAlreadyClaimed(portId);
        }
        if (module == address(0)) {
            revert IBCHostInvalidModuleAddress(module);
        }
        if (!ERC165Checker.supportsERC165(module)) {
            revert IBCHostModuleDoesNotSupportERC165();
        }
        if (
            !(
                ERC165Checker.supportsERC165InterfaceUnchecked(module, type(IIBCModule).interfaceId)
                    || ERC165Checker.supportsERC165InterfaceUnchecked(module, type(IIBCModuleInitializer).interfaceId)
            )
        ) {
            revert IBCHostModuleDoesNotSupportIIBCModuleInitializer(module, type(IIBCModuleInitializer).interfaceId);
        }
        hostStorage.portCapabilities[portId] = module;
        emit IBCModuleManagerPortCapabilityClaimed(portId, module);
    }

    /**
     * @dev claimChannelCapability allows the IBC app module to claim a capability that core IBC passes to it
     */
    function claimChannelCapability(string calldata portId, string memory channelId, address module) internal {
        HostStorage storage hostStorage = getHostStorage();
        if (hostStorage.channelCapabilities[portId][channelId] != address(0)) {
            revert IBCHostChannelCapabilityAlreadyClaimed(portId, channelId);
        }
        if (module == address(0)) {
            revert IBCHostInvalidModuleAddress(module);
        }
        if (!ERC165Checker.supportsERC165(module)) {
            revert IBCHostModuleDoesNotSupportERC165();
        }
        if (!ERC165Checker.supportsERC165InterfaceUnchecked(module, type(IIBCModule).interfaceId)) {
            revert IBCHostModuleDoesNotSupportIIBCModule(module, type(IIBCModule).interfaceId);
        }
        hostStorage.channelCapabilities[portId][channelId] = module;
        emit IBCModuleManagerChannelCapabilityClaimed(portId, channelId, module);
    }

    /**
     * @dev authenticateChannelCapability attempts to authenticate a given name from a caller.
     * It allows for a caller to check that a capability does in fact correspond to a particular name.
     */
    function authenticateChannelCapability(string calldata portId, string calldata channelId) internal view {
        address msgSender = _msgSender();
        if (getHostStorage().channelCapabilities[portId][channelId] != msgSender) {
            revert IBCHostFailedAuthenticateChannelCapability(portId, channelId, msgSender);
        }
    }

    /**
     * @dev lookupModuleByPort will return the IBCModule along with the capability associated with a given portID
     * If the module is not found, it will revert
     */
    function lookupModuleByPort(string calldata portId) internal view virtual returns (IIBCModuleInitializer) {
        address module = getHostStorage().portCapabilities[portId];
        if (module == address(0)) {
            revert IBCHostModulePortNotFound(portId);
        }
        return IIBCModuleInitializer(module);
    }

    /**
     * @dev lookupModuleByChannel will return the IBCModule along with the capability associated with a given channel defined by its portID and channelID
     * If the module is not found, it will revert
     */
    function lookupModuleByChannel(string calldata portId, string calldata channelId)
        internal
        view
        virtual
        returns (IIBCModule)
    {
        address module = getHostStorage().channelCapabilities[portId][channelId];
        if (module == address(0)) {
            revert IBCHostModuleChannelNotFound(portId, channelId);
        }
        return IIBCModule(module);
    }

    /**
     * @dev lookupUpgradableModuleByPortUnchecked will return the IBCModule corresponding to the portID
     * It will revert if the module is not found
     *
     * Since the function does not check if the module supports the `IIBCModuleUpgrade` interface via ERC-165, it is unsafe but cheaper in gas cost than `lookupUpgradableModuleByPort`
     */
    function lookupUpgradableModuleUnchecked(string calldata portId, string calldata channelId)
        internal
        view
        returns (IIBCModuleUpgrade)
    {
        return IIBCModuleUpgrade(address(lookupModuleByChannel(portId, channelId)));
    }

    /**
     * @dev lookupUpgradableModule will return the IBCModule corresponding to the portID and channelID
     * It will revert if the module does not support the `IIBCModuleUpgrade` interface or the module is not found
     */
    function lookupUpgradableModule(string calldata portId, string calldata channelId)
        internal
        view
        returns (IIBCModuleUpgrade)
    {
        IIBCModule module = lookupModuleByChannel(portId, channelId);
        if (!module.supportsInterface(type(IIBCModuleUpgrade).interfaceId)) {
            revert IBCHostModuleDoesNotSupportIIBCModuleUpgrade(address(module));
        }
        return IIBCModuleUpgrade(address(module));
    }

    /**
     * @dev canTransitionToFlushComplete checks if the module can transition to flush complete at the given upgrade sequence
     * If the module is not found, it will revert
     */
    function canTransitionToFlushComplete(
        Channel.Order ordering,
        string calldata portId,
        string calldata channelId,
        uint64 upgradeSequence
    ) internal view virtual returns (bool) {
        if (ordering == Channel.Order.ORDER_ORDERED) {
            ChannelStorage storage channelStorage = getChannelStorage()[portId][channelId];
            if (channelStorage.nextSequenceSend == channelStorage.nextSequenceAck) {
                return true;
            }
        }
        return lookupUpgradableModuleUnchecked(portId, channelId).canTransitionToFlushComplete(
            portId, channelId, upgradeSequence, _msgSender()
        );
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Channel, ChannelCounterparty} from "../../proto/Channel.sol";
import {Packet} from "../04-channel/IIBCChannel.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @notice IIBCModuleInitializer is an interface that defines the callbacks that modules must define as specified in ICS-26
 * @dev IBCModules registered with IBCModuleManager via `bindPort` must implement this interface.
 * IERC165's `supportsInterface` must return true for the interface ID of this interface
 */
interface IIBCModuleInitializer is IERC165 {
    struct MsgOnChanOpenInit {
        Channel.Order order;
        string[] connectionHops;
        string portId;
        string channelId;
        ChannelCounterparty.Data counterparty;
        string version;
    }

    struct MsgOnChanOpenTry {
        Channel.Order order;
        string[] connectionHops;
        string portId;
        string channelId;
        ChannelCounterparty.Data counterparty;
        string counterpartyVersion;
    }

    /**
     * @dev onChanOpenInit will verify that the relayer-chosen parameters
     * are valid and perform any custom INIT logic.
     * It may return an error if the chosen parameters are invalid
     * in which case the handshake is aborted.
     * If the provided version string is non-empty, OnChanOpenInit should return
     * the version string if valid or an error if the provided version is invalid.
     * If the version string is empty, OnChanOpenInit is expected to
     * return a default version string representing the version(s) it supports.
     * If there is no default version string for the application,
     * it should return an error if provided version is empty string.
     * onChanOpenInit can also create a new contract instance corresponding to the channel and return the address.
     * Otherwise, it should return the address of this contract.
     */
    function onChanOpenInit(MsgOnChanOpenInit calldata msg_) external returns (address, string memory);

    /**
     * @dev onChanOpenTry will verify the relayer-chosen parameters along with the
     * counterparty-chosen version string and perform custom TRY logic.
     * If the relayer-chosen parameters are invalid, the callback must return
     * an error to abort the handshake. If the counterparty-chosen version is not
     * compatible with this modules supported versions, the callback must return
     * an error to abort the handshake. If the versions are compatible, the try callback
     * must select the final version string and return it to core IBC.
     * onChanOpenTry may also perform custom initialization logic.
     * onChanOpenTry can also create a new contract instance corresponding to the channel and return the address.
     * Otherwise, it should return the address of this contract.
     */
    function onChanOpenTry(MsgOnChanOpenTry calldata msg_) external returns (address, string memory);
}

/**
 * @notice IIBCModule is an interface that defines all the callbacks that modules must define as specified in ICS-26
 * @dev IBC Modules returned by `onChanOpenInit` and `onChanOpenTry` must implement this interface.
 * IERC165's `supportsInterface` must return true for the interface ID of this interface, and the interface ID of IIBCModuleUpgrade if the module supports the channel upgrade
 */
interface IIBCModule is IIBCModuleInitializer {
    struct MsgOnChanOpenAck {
        string portId;
        string channelId;
        string counterpartyVersion;
    }

    struct MsgOnChanOpenConfirm {
        string portId;
        string channelId;
    }

    struct MsgOnChanCloseInit {
        string portId;
        string channelId;
    }

    struct MsgOnChanCloseConfirm {
        string portId;
        string channelId;
    }

    /**
     * @dev OnChanOpenAck will error if the counterparty selected version string
     * is invalid to abort the handshake. It may also perform custom ACK logic.
     */
    function onChanOpenAck(MsgOnChanOpenAck calldata msd_) external;

    /**
     * @dev OnChanOpenConfirm will perform custom CONFIRM logic and may error to abort the handshake.
     */
    function onChanOpenConfirm(MsgOnChanOpenConfirm calldata msg_) external;

    /**
     * @dev OnChanCloseInit will perform custom CLOSE_INIT logic and may error to abort the handshake.
     * NOTE: If the application does not allow the channel to be closed, this function must revert.
     */
    function onChanCloseInit(MsgOnChanCloseInit calldata msg_) external;

    /**
     * @dev OnChanCloseConfirm will perform custom CLOSE_CONFIRM logic and may error to abort the handshake.
     */
    function onChanCloseConfirm(MsgOnChanCloseConfirm calldata msg_) external;

    /**
     * @dev OnRecvPacket must return an acknowledgement that implements the Acknowledgement interface.
     * In the case of an asynchronous acknowledgement, nil should be returned.
     * If the acknowledgement returned is successful, the state changes on callback are written,
     * otherwise the application state changes are discarded. In either case the packet is received
     * and the acknowledgement is written (in synchronous cases).
     */
    function onRecvPacket(Packet calldata, address relayer) external returns (bytes memory);

    /**
     * @dev onAcknowledgementPacket is called when a packet sent by this module has been acknowledged.
     */
    function onAcknowledgementPacket(Packet calldata, bytes calldata acknowledgement, address relayer) external;

    /**
     * @dev onTimeoutPacket is called when a packet sent by this module has timed-out (such that it will not be received on the destination chain).
     */
    function onTimeoutPacket(Packet calldata, address relayer) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

interface IIBCModuleManager {
    /// @notice Claim a capability for a port
    /// @param portId the port identifier
    /// @param module the module claiming the capability
    event IBCModuleManagerPortCapabilityClaimed(string portId, address module);
    /// @notice Emitted when a module claims a capability for a channel
    /// @param portId the port identifier
    /// @param channelId the channel identifier
    /// @param module the module claiming the capability
    event IBCModuleManagerChannelCapabilityClaimed(string portId, string channelId, address module);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import {UpgradeFields, Timeout} from "../../proto/Channel.sol";

interface IIBCModuleUpgrade {
    /**
     * @dev Returns the absolute timeout for the upgrade
     * @param portId Port identifier
     * @param channelId Channel identifier
     */
    function getUpgradeTimeout(string calldata portId, string calldata channelId)
        external
        view
        returns (Timeout.Data memory);

    /**
     * @dev Returns whether the `msgSender` is an authorized upgrader for the given channel
     * @param portId Port identifier
     * @param channelId Channel identifier
     * @param msgSender sender of the upgrade message
     */
    function isAuthorizedUpgrader(string calldata portId, string calldata channelId, address msgSender)
        external
        view
        returns (bool);

    /**
     * @dev Returns whether the given channel can transition to flush complete at the given upgrade sequence
     * NOTE: this function is never called in some cases where the core contract can guarantee all inflight packets are already acknolwedged
     * @param portId Port identifier
     * @param channelId Channel identifier
     * @param upgradeSequence Upgrade sequence
     * @param msgSender sender of the upgrade message
     */
    function canTransitionToFlushComplete(
        string calldata portId,
        string calldata channelId,
        uint64 upgradeSequence,
        address msgSender
    ) external view returns (bool);

    /**
     * @dev OnChanUpgradeInit enables additional custom logic to be executed when the channel upgrade is initialized.
     * It must validate the proposed version, order, and connection hops.
     * NOTE: in the case of crossing hellos, this callback may be executed on both chains.
     * @param portId Port identifier
     * @param channelId Channel identifier
     * @param upgradeSequence Upgrade sequence
     * @param proposedUpgradeFields Proposed upgrade fields
     */
    function onChanUpgradeInit(
        string calldata portId,
        string calldata channelId,
        uint64 upgradeSequence,
        UpgradeFields.Data calldata proposedUpgradeFields
    ) external view returns (string memory version);

    /**
     * @dev OnChanUpgradeTry enables additional custom logic to be executed in the ChannelUpgradeTry step of the
     * channel upgrade handshake. It must validate the proposed version (provided by the counterparty), order,
     * and connection hops.
     * @param portId Port identifier
     * @param channelId Channel identifier
     * @param upgradeSequence Upgrade sequence
     * @param proposedUpgradeFields Proposed upgrade fields
     */
    function onChanUpgradeTry(
        string calldata portId,
        string calldata channelId,
        uint64 upgradeSequence,
        UpgradeFields.Data calldata proposedUpgradeFields
    ) external view returns (string memory version);

    /**
     * @dev OnChanUpgradeAck enables additional custom logic to be executed in the ChannelUpgradeAck step of the
     * channel upgrade handshake. It must validate the version proposed by the counterparty.
     * @param portId Port identifier
     * @param channelId Channel identifier
     * @param upgradeSequence Upgrade sequence
     * @param counterpartyVersion Counterparty version
     */
    function onChanUpgradeAck(
        string calldata portId,
        string calldata channelId,
        uint64 upgradeSequence,
        string calldata counterpartyVersion
    ) external view;

    /**
     * @dev OnChanUpgradeOpen enables additional custom logic to be executed when the channel upgrade has successfully completed, and the channel
     * has returned to the OPEN state. Any logic associated with changing of the channel fields should be performed
     * in this callback.
     *  @param portId Port identifier
     * @param channelId Channel identifier
     * @param upgradeSequence Upgrade sequence
     */
    function onChanUpgradeOpen(string calldata portId, string calldata channelId, uint64 upgradeSequence) external;
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";
import "./GoogleProtobufAny.sol";
import "./Client.sol";

library Channel {

  //enum definition
  // Solidity enum definitions
  enum State {
    STATE_UNINITIALIZED_UNSPECIFIED,
    STATE_INIT,
    STATE_TRYOPEN,
    STATE_OPEN,
    STATE_CLOSED,
    STATE_FLUSHING,
    STATE_FLUSHCOMPLETE
  }


  // Solidity enum encoder
  function encode_State(State x) internal pure returns (int32) {
    
    if (x == State.STATE_UNINITIALIZED_UNSPECIFIED) {
      return 0;
    }

    if (x == State.STATE_INIT) {
      return 1;
    }

    if (x == State.STATE_TRYOPEN) {
      return 2;
    }

    if (x == State.STATE_OPEN) {
      return 3;
    }

    if (x == State.STATE_CLOSED) {
      return 4;
    }

    if (x == State.STATE_FLUSHING) {
      return 5;
    }

    if (x == State.STATE_FLUSHCOMPLETE) {
      return 6;
    }
    revert();
  }


  // Solidity enum decoder
  function decode_State(int64 x) internal pure returns (State) {
    
    if (x == 0) {
      return State.STATE_UNINITIALIZED_UNSPECIFIED;
    }

    if (x == 1) {
      return State.STATE_INIT;
    }

    if (x == 2) {
      return State.STATE_TRYOPEN;
    }

    if (x == 3) {
      return State.STATE_OPEN;
    }

    if (x == 4) {
      return State.STATE_CLOSED;
    }

    if (x == 5) {
      return State.STATE_FLUSHING;
    }

    if (x == 6) {
      return State.STATE_FLUSHCOMPLETE;
    }
    revert();
  }


  /**
   * @dev The estimator for an packed enum array
   * @return The number of bytes encoded
   */
  function estimate_packed_repeated_State(
    State[] memory a
  ) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += ProtoBufRuntime._sz_enum(encode_State(a[i]));
    }
    return e;
  }

  // Solidity enum definitions
  enum Order {
    ORDER_NONE_UNSPECIFIED,
    ORDER_UNORDERED,
    ORDER_ORDERED
  }


  // Solidity enum encoder
  function encode_Order(Order x) internal pure returns (int32) {
    
    if (x == Order.ORDER_NONE_UNSPECIFIED) {
      return 0;
    }

    if (x == Order.ORDER_UNORDERED) {
      return 1;
    }

    if (x == Order.ORDER_ORDERED) {
      return 2;
    }
    revert();
  }


  // Solidity enum decoder
  function decode_Order(int64 x) internal pure returns (Order) {
    
    if (x == 0) {
      return Order.ORDER_NONE_UNSPECIFIED;
    }

    if (x == 1) {
      return Order.ORDER_UNORDERED;
    }

    if (x == 2) {
      return Order.ORDER_ORDERED;
    }
    revert();
  }


  /**
   * @dev The estimator for an packed enum array
   * @return The number of bytes encoded
   */
  function estimate_packed_repeated_Order(
    Order[] memory a
  ) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += ProtoBufRuntime._sz_enum(encode_Order(a[i]));
    }
    return e;
  }

  //struct definition
  struct Data {
    Channel.State state;
    Channel.Order ordering;
    ChannelCounterparty.Data counterparty;
    string[] connection_hops;
    string version;
    uint64 upgrade_sequence;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[7] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_state(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_ordering(pointer, bs, r);
      } else
      if (fieldId == 3) {
        pointer += _read_counterparty(pointer, bs, r);
      } else
      if (fieldId == 4) {
        pointer += _read_unpacked_repeated_connection_hops(pointer, bs, nil(), counters);
      } else
      if (fieldId == 5) {
        pointer += _read_version(pointer, bs, r);
      } else
      if (fieldId == 6) {
        pointer += _read_upgrade_sequence(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[4] > 0) {
      require(r.connection_hops.length == 0);
      r.connection_hops = new string[](counters[4]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 4) {
        pointer += _read_unpacked_repeated_connection_hops(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_state(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (int64 tmp, uint256 sz) = ProtoBufRuntime._decode_enum(p, bs);
    Channel.State x = decode_State(tmp);
    r.state = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_ordering(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (int64 tmp, uint256 sz) = ProtoBufRuntime._decode_enum(p, bs);
    Channel.Order x = decode_Order(tmp);
    r.ordering = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_counterparty(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (ChannelCounterparty.Data memory x, uint256 sz) = _decode_ChannelCounterparty(p, bs);
    r.counterparty = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_connection_hops(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[7] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[4] += 1;
    } else {
      r.connection_hops[r.connection_hops.length - counters[4]] = x;
      counters[4] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_version(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.version = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_upgrade_sequence(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.upgrade_sequence = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_ChannelCounterparty(uint256 p, bytes memory bs)
    internal
    pure
    returns (ChannelCounterparty.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (ChannelCounterparty.Data memory r, ) = ChannelCounterparty._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (uint(r.state) != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    int32 _enum_state = encode_State(r.state);
    pointer += ProtoBufRuntime._encode_enum(_enum_state, pointer, bs);
    }
    if (uint(r.ordering) != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    int32 _enum_ordering = encode_Order(r.ordering);
    pointer += ProtoBufRuntime._encode_enum(_enum_ordering, pointer, bs);
    }
    
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ChannelCounterparty._encode_nested(r.counterparty, pointer, bs);
    
    if (r.connection_hops.length != 0) {
    for(i = 0; i < r.connection_hops.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        4,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_string(r.connection_hops[i], pointer, bs);
    }
    }
    if (bytes(r.version).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      5,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.version, pointer, bs);
    }
    if (r.upgrade_sequence != 0) {
    pointer += ProtoBufRuntime._encode_key(
      6,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.upgrade_sequence, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_enum(encode_State(r.state));
    e += 1 + ProtoBufRuntime._sz_enum(encode_Order(r.ordering));
    e += 1 + ProtoBufRuntime._sz_lendelim(ChannelCounterparty._estimate(r.counterparty));
    for(i = 0; i < r.connection_hops.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.connection_hops[i]).length);
    }
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.version).length);
    e += 1 + ProtoBufRuntime._sz_uint64(r.upgrade_sequence);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (uint(r.state) != 0) {
    return false;
  }

  if (uint(r.ordering) != 0) {
    return false;
  }

  if (r.connection_hops.length != 0) {
    return false;
  }

  if (bytes(r.version).length != 0) {
    return false;
  }

  if (r.upgrade_sequence != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.state = input.state;
    output.ordering = input.ordering;
    ChannelCounterparty.store(input.counterparty, output.counterparty);
    output.connection_hops = input.connection_hops;
    output.version = input.version;
    output.upgrade_sequence = input.upgrade_sequence;

  }


  //array helpers for ConnectionHops
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addConnectionHops(Data memory self, string memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    string[] memory tmp = new string[](self.connection_hops.length + 1);
    for (uint256 i = 0; i < self.connection_hops.length; i++) {
      tmp[i] = self.connection_hops[i];
    }
    tmp[self.connection_hops.length] = value;
    self.connection_hops = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Channel

library ChannelCounterparty {


  //struct definition
  struct Data {
    string port_id;
    string channel_id;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_port_id(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_channel_id(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_port_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.port_id = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_channel_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.channel_id = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (bytes(r.port_id).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.port_id, pointer, bs);
    }
    if (bytes(r.channel_id).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.channel_id, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.port_id).length);
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.channel_id).length);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (bytes(r.port_id).length != 0) {
    return false;
  }

  if (bytes(r.channel_id).length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.port_id = input.port_id;
    output.channel_id = input.channel_id;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library ChannelCounterparty

library Timeout {


  //struct definition
  struct Data {
    Height.Data height;
    uint64 timestamp;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_height(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_timestamp(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_height(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (Height.Data memory x, uint256 sz) = _decode_Height(p, bs);
    r.height = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_timestamp(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.timestamp = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_Height(uint256 p, bytes memory bs)
    internal
    pure
    returns (Height.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Height.Data memory r, ) = Height._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += Height._encode_nested(r.height, pointer, bs);
    
    if (r.timestamp != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.timestamp, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(Height._estimate(r.height));
    e += 1 + ProtoBufRuntime._sz_uint64(r.timestamp);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.timestamp != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    Height.store(input.height, output.height);
    output.timestamp = input.timestamp;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Timeout

library Upgrade {


  //struct definition
  struct Data {
    UpgradeFields.Data fields;
    Timeout.Data timeout;
    uint64 next_sequence_send;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_fields(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_timeout(pointer, bs, r);
      } else
      if (fieldId == 3) {
        pointer += _read_next_sequence_send(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_fields(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (UpgradeFields.Data memory x, uint256 sz) = _decode_UpgradeFields(p, bs);
    r.fields = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_timeout(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (Timeout.Data memory x, uint256 sz) = _decode_Timeout(p, bs);
    r.timeout = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_next_sequence_send(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.next_sequence_send = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_UpgradeFields(uint256 p, bytes memory bs)
    internal
    pure
    returns (UpgradeFields.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (UpgradeFields.Data memory r, ) = UpgradeFields._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }

  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_Timeout(uint256 p, bytes memory bs)
    internal
    pure
    returns (Timeout.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Timeout.Data memory r, ) = Timeout._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += UpgradeFields._encode_nested(r.fields, pointer, bs);
    
    
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += Timeout._encode_nested(r.timeout, pointer, bs);
    
    if (r.next_sequence_send != 0) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.next_sequence_send, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(UpgradeFields._estimate(r.fields));
    e += 1 + ProtoBufRuntime._sz_lendelim(Timeout._estimate(r.timeout));
    e += 1 + ProtoBufRuntime._sz_uint64(r.next_sequence_send);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.next_sequence_send != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    UpgradeFields.store(input.fields, output.fields);
    Timeout.store(input.timeout, output.timeout);
    output.next_sequence_send = input.next_sequence_send;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Upgrade

library UpgradeFields {


  //struct definition
  struct Data {
    Channel.Order ordering;
    string[] connection_hops;
    string version;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[4] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_ordering(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_connection_hops(pointer, bs, nil(), counters);
      } else
      if (fieldId == 3) {
        pointer += _read_version(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[2] > 0) {
      require(r.connection_hops.length == 0);
      r.connection_hops = new string[](counters[2]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_connection_hops(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_ordering(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (int64 tmp, uint256 sz) = ProtoBufRuntime._decode_enum(p, bs);
    Channel.Order x = Channel.decode_Order(tmp);
    r.ordering = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_connection_hops(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[4] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.connection_hops[r.connection_hops.length - counters[2]] = x;
      counters[2] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_version(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.version = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (uint(r.ordering) != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    int32 _enum_ordering = Channel.encode_Order(r.ordering);
    pointer += ProtoBufRuntime._encode_enum(_enum_ordering, pointer, bs);
    }
    if (r.connection_hops.length != 0) {
    for(i = 0; i < r.connection_hops.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        2,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_string(r.connection_hops[i], pointer, bs);
    }
    }
    if (bytes(r.version).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.version, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_enum(Channel.encode_Order(r.ordering));
    for(i = 0; i < r.connection_hops.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.connection_hops[i]).length);
    }
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.version).length);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (uint(r.ordering) != 0) {
    return false;
  }

  if (r.connection_hops.length != 0) {
    return false;
  }

  if (bytes(r.version).length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.ordering = input.ordering;
    output.connection_hops = input.connection_hops;
    output.version = input.version;

  }


  //array helpers for ConnectionHops
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addConnectionHops(Data memory self, string memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    string[] memory tmp = new string[](self.connection_hops.length + 1);
    for (uint256 i = 0; i < self.connection_hops.length; i++) {
      tmp[i] = self.connection_hops[i];
    }
    tmp[self.connection_hops.length] = value;
    self.connection_hops = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library UpgradeFields

library ErrorReceipt {


  //struct definition
  struct Data {
    uint64 sequence;
    string message;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_sequence(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_message(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_sequence(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.sequence = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_message(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.message = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.sequence != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.sequence, pointer, bs);
    }
    if (bytes(r.message).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.message, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_uint64(r.sequence);
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.message).length);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.sequence != 0) {
    return false;
  }

  if (bytes(r.message).length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.sequence = input.sequence;
    output.message = input.message;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library ErrorReceipt
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";
import "./GoogleProtobufAny.sol";

library Height {


  //struct definition
  struct Data {
    uint64 revision_number;
    uint64 revision_height;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_revision_number(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_revision_height(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_revision_number(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.revision_number = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_revision_height(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.revision_height = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.revision_number != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.revision_number, pointer, bs);
    }
    if (r.revision_height != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.revision_height, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_uint64(r.revision_number);
    e += 1 + ProtoBufRuntime._sz_uint64(r.revision_height);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.revision_number != 0) {
    return false;
  }

  if (r.revision_height != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.revision_number = input.revision_number;
    output.revision_height = input.revision_height;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Height
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";
import "./GoogleProtobufAny.sol";

library MerklePrefix {


  //struct definition
  struct Data {
    bytes key_prefix;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_key_prefix(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_key_prefix(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    r.key_prefix = x;
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (r.key_prefix.length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.key_prefix, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(r.key_prefix.length);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (r.key_prefix.length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.key_prefix = input.key_prefix;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library MerklePrefix
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";
import "./GoogleProtobufAny.sol";
import "./Commitment.sol";

library ConnectionEnd {

  //enum definition
  // Solidity enum definitions
  enum State {
    STATE_UNINITIALIZED_UNSPECIFIED,
    STATE_INIT,
    STATE_TRYOPEN,
    STATE_OPEN
  }


  // Solidity enum encoder
  function encode_State(State x) internal pure returns (int32) {
    
    if (x == State.STATE_UNINITIALIZED_UNSPECIFIED) {
      return 0;
    }

    if (x == State.STATE_INIT) {
      return 1;
    }

    if (x == State.STATE_TRYOPEN) {
      return 2;
    }

    if (x == State.STATE_OPEN) {
      return 3;
    }
    revert();
  }


  // Solidity enum decoder
  function decode_State(int64 x) internal pure returns (State) {
    
    if (x == 0) {
      return State.STATE_UNINITIALIZED_UNSPECIFIED;
    }

    if (x == 1) {
      return State.STATE_INIT;
    }

    if (x == 2) {
      return State.STATE_TRYOPEN;
    }

    if (x == 3) {
      return State.STATE_OPEN;
    }
    revert();
  }


  /**
   * @dev The estimator for an packed enum array
   * @return The number of bytes encoded
   */
  function estimate_packed_repeated_State(
    State[] memory a
  ) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += ProtoBufRuntime._sz_enum(encode_State(a[i]));
    }
    return e;
  }

  //struct definition
  struct Data {
    string client_id;
    Version.Data[] versions;
    ConnectionEnd.State state;
    Counterparty.Data counterparty;
    uint64 delay_period;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[6] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_client_id(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_versions(pointer, bs, nil(), counters);
      } else
      if (fieldId == 3) {
        pointer += _read_state(pointer, bs, r);
      } else
      if (fieldId == 4) {
        pointer += _read_counterparty(pointer, bs, r);
      } else
      if (fieldId == 5) {
        pointer += _read_delay_period(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[2] > 0) {
      require(r.versions.length == 0);
      r.versions = new Version.Data[](counters[2]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_versions(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_client_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.client_id = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_versions(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[6] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (Version.Data memory x, uint256 sz) = _decode_Version(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.versions[r.versions.length - counters[2]] = x;
      counters[2] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_state(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (int64 tmp, uint256 sz) = ProtoBufRuntime._decode_enum(p, bs);
    ConnectionEnd.State x = decode_State(tmp);
    r.state = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_counterparty(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (Counterparty.Data memory x, uint256 sz) = _decode_Counterparty(p, bs);
    r.counterparty = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_delay_period(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (uint64 x, uint256 sz) = ProtoBufRuntime._decode_uint64(p, bs);
    r.delay_period = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_Version(uint256 p, bytes memory bs)
    internal
    pure
    returns (Version.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Version.Data memory r, ) = Version._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }

  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_Counterparty(uint256 p, bytes memory bs)
    internal
    pure
    returns (Counterparty.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Counterparty.Data memory r, ) = Counterparty._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (bytes(r.client_id).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.client_id, pointer, bs);
    }
    if (r.versions.length != 0) {
    for(i = 0; i < r.versions.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        2,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += Version._encode_nested(r.versions[i], pointer, bs);
    }
    }
    if (uint(r.state) != 0) {
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    int32 _enum_state = encode_State(r.state);
    pointer += ProtoBufRuntime._encode_enum(_enum_state, pointer, bs);
    }
    
    pointer += ProtoBufRuntime._encode_key(
      4,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += Counterparty._encode_nested(r.counterparty, pointer, bs);
    
    if (r.delay_period != 0) {
    pointer += ProtoBufRuntime._encode_key(
      5,
      ProtoBufRuntime.WireType.Varint,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_uint64(r.delay_period, pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.client_id).length);
    for(i = 0; i < r.versions.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(Version._estimate(r.versions[i]));
    }
    e += 1 + ProtoBufRuntime._sz_enum(encode_State(r.state));
    e += 1 + ProtoBufRuntime._sz_lendelim(Counterparty._estimate(r.counterparty));
    e += 1 + ProtoBufRuntime._sz_uint64(r.delay_period);
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (bytes(r.client_id).length != 0) {
    return false;
  }

  if (r.versions.length != 0) {
    return false;
  }

  if (uint(r.state) != 0) {
    return false;
  }

  if (r.delay_period != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.client_id = input.client_id;

    for(uint256 i2 = 0; i2 < input.versions.length; i2++) {
      output.versions.push(input.versions[i2]);
    }
    
    output.state = input.state;
    Counterparty.store(input.counterparty, output.counterparty);
    output.delay_period = input.delay_period;

  }


  //array helpers for Versions
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addVersions(Data memory self, Version.Data memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    Version.Data[] memory tmp = new Version.Data[](self.versions.length + 1);
    for (uint256 i = 0; i < self.versions.length; i++) {
      tmp[i] = self.versions[i];
    }
    tmp[self.versions.length] = value;
    self.versions = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library ConnectionEnd

library Counterparty {


  //struct definition
  struct Data {
    string client_id;
    string connection_id;
    MerklePrefix.Data prefix;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_client_id(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_connection_id(pointer, bs, r);
      } else
      if (fieldId == 3) {
        pointer += _read_prefix(pointer, bs, r);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_client_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.client_id = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_connection_id(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.connection_id = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_prefix(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (MerklePrefix.Data memory x, uint256 sz) = _decode_MerklePrefix(p, bs);
    r.prefix = x;
    return sz;
  }

  // struct decoder
  /**
   * @dev The decoder for reading a inner struct field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The decoded inner-struct
   * @return The number of bytes used to decode
   */
  function _decode_MerklePrefix(uint256 p, bytes memory bs)
    internal
    pure
    returns (MerklePrefix.Data memory, uint)
  {
    uint256 pointer = p;
    (uint256 sz, uint256 bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (MerklePrefix.Data memory r, ) = MerklePrefix._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    
    if (bytes(r.client_id).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.client_id, pointer, bs);
    }
    if (bytes(r.connection_id).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.connection_id, pointer, bs);
    }
    
    pointer += ProtoBufRuntime._encode_key(
      3,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += MerklePrefix._encode_nested(r.prefix, pointer, bs);
    
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.client_id).length);
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.connection_id).length);
    e += 1 + ProtoBufRuntime._sz_lendelim(MerklePrefix._estimate(r.prefix));
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (bytes(r.client_id).length != 0) {
    return false;
  }

  if (bytes(r.connection_id).length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.client_id = input.client_id;
    output.connection_id = input.connection_id;
    MerklePrefix.store(input.prefix, output.prefix);

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Counterparty

library Version {


  //struct definition
  struct Data {
    string identifier;
    string[] features;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[3] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_identifier(pointer, bs, r);
      } else
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_features(pointer, bs, nil(), counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }

    }
    pointer = offset;
    if (counters[2] > 0) {
      require(r.features.length == 0);
      r.features = new string[](counters[2]);
    }

    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 2) {
        pointer += _read_unpacked_repeated_features(pointer, bs, r, counters);
      } else
      {
        pointer += ProtoBufRuntime._skip_field_decode(wireType, pointer, bs);
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @return The number of bytes decoded
   */
  function _read_identifier(
    uint256 p,
    bytes memory bs,
    Data memory r
  ) internal pure returns (uint) {
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    r.identifier = x;
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_unpacked_repeated_features(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.features[r.features.length - counters[2]] = x;
      counters[2] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;
    uint256 i;
    if (bytes(r.identifier).length != 0) {
    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.identifier, pointer, bs);
    }
    if (r.features.length != 0) {
    for(i = 0; i < r.features.length; i++) {
      pointer += ProtoBufRuntime._encode_key(
        2,
        ProtoBufRuntime.WireType.LengthDelim,
        pointer,
        bs)
      ;
      pointer += ProtoBufRuntime._encode_string(r.features[i], pointer, bs);
    }
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;uint256 i;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.identifier).length);
    for(i = 0; i < r.features.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.features[i]).length);
    }
    return e;
  }
  // empty checker

  function _empty(
    Data memory r
  ) internal pure returns (bool) {
    
  if (bytes(r.identifier).length != 0) {
    return false;
  }

  if (r.features.length != 0) {
    return false;
  }

    return true;
  }


  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.identifier = input.identifier;
    output.features = input.features;

  }


  //array helpers for Features
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addFeatures(Data memory self, string memory value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    string[] memory tmp = new string[](self.features.length + 1);
    for (uint256 i = 0; i < self.features.length; i++) {
      tmp[i] = self.features[i];
    }
    tmp[self.features.length] = value;
    self.features = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Version
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "./ProtoBufRuntime.sol";

library GoogleProtobufAny {


  //struct definition
  struct Data {
    string type_url;
    bytes value;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x, ) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x, ) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (Data memory, uint)
  {
    Data memory r;
    uint[3] memory counters;
    uint256 fieldId;
    ProtoBufRuntime.WireType wireType;
    uint256 bytesRead;
    uint256 offset = p;
    uint256 pointer = p;
    while (pointer < offset + sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if (fieldId == 1) {
        pointer += _read_type_url(pointer, bs, r, counters);
      }
      else if (fieldId == 2) {
        pointer += _read_value(pointer, bs, r, counters);
      }

      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint256 size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }

    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_type_url(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (string memory x, uint256 sz) = ProtoBufRuntime._decode_string(p, bs);
    if (isNil(r)) {
      counters[1] += 1;
    } else {
      r.type_url = x;
      if (counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_value(
    uint256 p,
    bytes memory bs,
    Data memory r,
    uint[3] memory counters
  ) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bytes memory x, uint256 sz) = ProtoBufRuntime._decode_bytes(p, bs);
    if (isNil(r)) {
      counters[2] += 1;
    } else {
      r.value = x;
      if (counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint256 sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    uint256 offset = p;
    uint256 pointer = p;

    pointer += ProtoBufRuntime._encode_key(
      1,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_string(r.type_url, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(
      2,
      ProtoBufRuntime.WireType.LengthDelim,
      pointer,
      bs
    );
    pointer += ProtoBufRuntime._encode_bytes(r.value, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint)
  {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint256 offset = p;
    uint256 pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint256 tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint256 bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint256 size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(
    Data memory r
  ) internal pure returns (uint) {
    uint256 e;
    e += 1 + ProtoBufRuntime._sz_lendelim(bytes(r.type_url).length);
    e += 1 + ProtoBufRuntime._sz_lendelim(r.value.length);
    return e;
  }

  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.type_url = input.type_url;
    output.value = input.value;

  }



  //utility functions
  /**
   * @dev Return an empty struct
   * @return r The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return r True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Any
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;


/**
 * @title Runtime library for ProtoBuf serialization and/or deserialization.
 * All ProtoBuf generated code will use this library.
 */
library ProtoBufRuntime {
  // Types defined in ProtoBuf
  enum WireType { Varint, Fixed64, LengthDelim, StartGroup, EndGroup, Fixed32 }
  // Constants for bytes calculation
  uint256 constant WORD_LENGTH = 32;
  uint256 constant HEADER_SIZE_LENGTH_IN_BYTES = 4;
  uint256 constant BYTE_SIZE = 8;
  uint256 constant REMAINING_LENGTH = WORD_LENGTH - HEADER_SIZE_LENGTH_IN_BYTES;
  string constant OVERFLOW_MESSAGE = "length overflow";

  //Storages
  /**
   * @dev Encode to storage location using assembly to save storage space.
   * @param location The location of storage
   * @param encoded The encoded ProtoBuf bytes
   */
  function encodeStorage(bytes storage location, bytes memory encoded)
    internal
  {
    /**
     * This code use the first four bytes as size,
     * and then put the rest of `encoded` bytes.
     */
    uint256 length = encoded.length;
    uint256 firstWord;
    uint256 wordLength = WORD_LENGTH;
    uint256 remainingLength = REMAINING_LENGTH;

    assembly {
      firstWord := mload(add(encoded, wordLength))
    }
    firstWord =
      (firstWord >> (BYTE_SIZE * HEADER_SIZE_LENGTH_IN_BYTES)) |
      (length << (BYTE_SIZE * REMAINING_LENGTH));

    assembly {
      sstore(location.slot, firstWord)
    }

    if (length > REMAINING_LENGTH) {
      length -= REMAINING_LENGTH;
      for (uint256 i = 0; i < ceil(length, WORD_LENGTH); i++) {
        assembly {
          let offset := add(mul(i, wordLength), remainingLength)
          let slotIndex := add(i, 1)
          sstore(
            add(location.slot, slotIndex),
            mload(add(add(encoded, wordLength), offset))
          )
        }
      }
    }
  }

  /**
   * @dev Decode storage location using assembly using the format in `encodeStorage`.
   * @param location The location of storage
   * @return The encoded bytes
   */
  function decodeStorage(bytes storage location)
    internal
    view
    returns (bytes memory)
  {
    /**
     * This code is to decode the first four bytes as size,
     * and then decode the rest using the decoded size.
     */
    uint256 firstWord;
    uint256 remainingLength = REMAINING_LENGTH;
    uint256 wordLength = WORD_LENGTH;

    assembly {
      firstWord := sload(location.slot)
    }

    uint256 length = firstWord >> (BYTE_SIZE * REMAINING_LENGTH);
    bytes memory encoded = new bytes(length);

    assembly {
      mstore(add(encoded, remainingLength), firstWord)
    }

    if (length > REMAINING_LENGTH) {
      length -= REMAINING_LENGTH;
      for (uint256 i = 0; i < ceil(length, WORD_LENGTH); i++) {
        assembly {
          let offset := add(mul(i, wordLength), remainingLength)
          let slotIndex := add(i, 1)
          mstore(
            add(add(encoded, wordLength), offset),
            sload(add(location.slot, slotIndex))
          )
        }
      }
    }
    return encoded;
  }

  /**
   * @dev Fast memory copy of bytes using assembly.
   * @param src The source memory address
   * @param dest The destination memory address
   * @param len The length of bytes to copy
   */
  function copyBytes(uint256 src, uint256 dest, uint256 len) internal pure {
    if (len == 0) {
      return;
    }

    // Copy word-length chunks while possible
    for (; len > WORD_LENGTH; len -= WORD_LENGTH) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += WORD_LENGTH;
      src += WORD_LENGTH;
    }

    // Copy remaining bytes
    uint256 mask = 256**(WORD_LENGTH - len) - 1;
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }
  }

  /**
   * @dev Use assembly to get memory address.
   * @param r The in-memory bytes array
   * @return The memory address of `r`
   */
  function getMemoryAddress(bytes memory r) internal pure returns (uint256) {
    uint256 addr;
    assembly {
      addr := r
    }
    return addr;
  }

  /**
   * @dev Implement Math function of ceil
   * @param a The denominator
   * @param m The numerator
   * @return r The result of ceil(a/m)
   */
  function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {
    return (a + m - 1) / m;
  }

  // Decoders
  /**
   * This section of code `_decode_(u)int(32|64)`, `_decode_enum` and `_decode_bool`
   * is to decode ProtoBuf native integers,
   * using the `varint` encoding.
   */

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    return (uint32(varint), sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    return (uint64(varint), sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_int32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    int32 r;
    assembly {
      r := varint
    }
    return (r, sz);
  }

  /**
   * @dev Decode integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_int64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    int64 r;
    assembly {
      r := varint
    }
    return (r, sz);
  }

  /**
   * @dev Decode enum
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded enum's integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_enum(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    return _decode_int64(p, bs);
  }

  /**
   * @dev Decode enum
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded boolean
   * @return The length of `bs` used to get decoded
   */
  function _decode_bool(uint256 p, bytes memory bs)
    internal
    pure
    returns (bool, uint256)
  {
    (uint256 varint, uint256 sz) = _decode_varint(p, bs);
    if (varint == 0) {
      return (false, sz);
    }
    return (true, sz);
  }

  /**
   * This section of code `_decode_sint(32|64)`
   * is to decode ProtoBuf native signed integers,
   * using the `zig-zag` encoding.
   */

  /**
   * @dev Decode signed integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_sint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (int256 varint, uint256 sz) = _decode_varints(p, bs);
    return (int32(varint), sz);
  }

  /**
   * @dev Decode signed integers
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_sint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (int256 varint, uint256 sz) = _decode_varints(p, bs);
    return (int64(varint), sz);
  }

  /**
   * @dev Decode string
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded string
   * @return The length of `bs` used to get decoded
   */
  function _decode_string(uint256 p, bytes memory bs)
    internal
    pure
    returns (string memory, uint256)
  {
    (bytes memory x, uint256 sz) = _decode_lendelim(p, bs);
    return (string(x), sz);
  }

  /**
   * @dev Decode bytes array
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded bytes array
   * @return The length of `bs` used to get decoded
   */
  function _decode_bytes(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes memory, uint256)
  {
    return _decode_lendelim(p, bs);
  }

  /**
   * @dev Decode ProtoBuf key
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded field ID
   * @return The decoded WireType specified in ProtoBuf
   * @return The length of `bs` used to get decoded
   */
  function _decode_key(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, WireType, uint256)
  {
    (uint256 x, uint256 n) = _decode_varint(p, bs);
    WireType typeId = WireType(x & 7);
    uint256 fieldId = x / 8;
    return (fieldId, typeId, n);
  }

  /**
   * @dev Decode ProtoBuf varint
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded unsigned integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_varint(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    /**
     * Read a byte.
     * Use the lower 7 bits and shift it to the left,
     * until the most significant bit is 0.
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 x = 0;
    uint256 sz = 0;
    uint256 length = bs.length + WORD_LENGTH;
    assembly {
      let b := 0x80
      p := add(bs, p)
      for {

      } eq(0x80, and(b, 0x80)) {

      } {
        if eq(lt(sub(p, bs), length), 0) {
          mstore(
            0,
            0x08c379a000000000000000000000000000000000000000000000000000000000
          ) //error function selector
          mstore(4, 32)
          mstore(36, 15)
          mstore(
            68,
            0x6c656e677468206f766572666c6f770000000000000000000000000000000000
          ) // length overflow in hex
          revert(0, 83)
        }
        let tmp := mload(p)
        let pos := 0
        for {

        } and(eq(0x80, and(b, 0x80)), lt(pos, 32)) {

        } {
          if eq(lt(sub(p, bs), length), 0) {
            mstore(
              0,
              0x08c379a000000000000000000000000000000000000000000000000000000000
            ) //error function selector
            mstore(4, 32)
            mstore(36, 15)
            mstore(
              68,
              0x6c656e677468206f766572666c6f770000000000000000000000000000000000
            ) // length overflow in hex
            revert(0, 83)
          }
          b := byte(pos, tmp)
          x := or(x, shl(mul(7, sz), and(0x7f, b)))
          sz := add(sz, 1)
          pos := add(pos, 1)
          p := add(p, 0x01)
        }
      }
    }
    return (x, sz);
  }

  /**
   * @dev Decode ProtoBuf zig-zag encoding
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded signed integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_varints(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    (uint256 u, uint256 sz) = _decode_varint(p, bs);
    int256 s;
    assembly {
      s := xor(shr(1, u), add(not(and(u, 1)), 1))
    }
    return (s, sz);
  }

  /**
   * @dev Decode ProtoBuf fixed-length encoding
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded unsigned integer
   * @return The length of `bs` used to get decoded
   */
  function _decode_uintf(uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (uint256, uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 x = 0;
    uint256 length = bs.length + WORD_LENGTH;
    assert(p + sz <= length);
    assembly {
      let i := 0
      p := add(bs, p)
      let tmp := mload(p)
      for {

      } lt(i, sz) {

      } {
        x := or(x, shl(mul(8, i), byte(i, tmp)))
        p := add(p, 0x01)
        i := add(i, 1)
      }
    }
    return (x, sz);
  }

  /**
   * `_decode_(s)fixed(32|64)` is the concrete implementation of `_decode_uintf`
   */
  function _decode_fixed32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 4);
    return (uint32(x), sz);
  }

  function _decode_fixed64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 8);
    return (uint64(x), sz);
  }

  function _decode_sfixed32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 4);
    int256 r;
    assembly {
      r := x
    }
    return (int32(r), sz);
  }

  function _decode_sfixed64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (uint256 x, uint256 sz) = _decode_uintf(p, bs, 8);
    int256 r;
    assembly {
      r := x
    }
    return (int64(r), sz);
  }

  /**
   * @dev Decode bytes array
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The decoded bytes array
   * @return The length of `bs` used to get decoded
   */
  function _decode_lendelim(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes memory, uint256)
  {
    /**
     * First read the size encoded in `varint`, then use the size to read bytes.
     */
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    bytes memory b = new bytes(len);
    uint256 length = bs.length + WORD_LENGTH;
    assert(p + sz + len <= length);
    uint256 sourcePtr;
    uint256 destPtr;
    assembly {
      destPtr := add(b, 32)
      sourcePtr := add(add(bs, p), sz)
    }
    copyBytes(sourcePtr, destPtr, len);
    return (b, sz + len);
  }

  /**
   * @dev Skip the decoding of a single field
   * @param wt The WireType of the field
   * @param p The memory offset of `bs`
   * @param bs The bytes array to be decoded
   * @return The length of `bs` to skipped
   */
  function _skip_field_decode(WireType wt, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    if (wt == ProtoBufRuntime.WireType.Fixed64) {
      return 8;
    } else if (wt == ProtoBufRuntime.WireType.Fixed32) {
      return 4;
    } else if (wt == ProtoBufRuntime.WireType.Varint) {
      (, uint256 size) = ProtoBufRuntime._decode_varint(p, bs);
      return size;
    } else {
      require(wt == ProtoBufRuntime.WireType.LengthDelim);
      (uint256 len, uint256 size) = ProtoBufRuntime._decode_varint(p, bs);
      return size + len;
    }
  }

  // Encoders
  /**
   * @dev Encode ProtoBuf key
   * @param x The field ID
   * @param wt The WireType specified in ProtoBuf
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_key(uint256 x, WireType wt, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 i;
    assembly {
      i := or(mul(x, 8), mod(wt, 8))
    }
    return _encode_varint(i, p, bs);
  }

  /**
   * @dev Encode ProtoBuf varint
   * @param x The unsigned integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_varint(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 sz = 0;
    assembly {
      let bsptr := add(bs, p)
      let byt := and(x, 0x7f)
      for {

      } gt(shr(7, x), 0) {

      } {
        mstore8(bsptr, or(0x80, byt))
        bsptr := add(bsptr, 1)
        sz := add(sz, 1)
        x := shr(7, x)
        byt := and(x, 0x7f)
      }
      mstore8(bsptr, byt)
      sz := add(sz, 1)
    }
    return sz;
  }

  /**
   * @dev Encode ProtoBuf zig-zag encoding
   * @param x The signed integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_varints(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    /**
     * Refer to https://developers.google.com/protocol-buffers/docs/encoding
     */
    uint256 encodedInt = _encode_zigzag(x);
    return _encode_varint(encodedInt, p, bs);
  }

  /**
   * @dev Encode ProtoBuf bytes
   * @param xs The bytes array to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_bytes(bytes memory xs, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 xsLength = xs.length;
    uint256 sz = _encode_varint(xsLength, p, bs);
    uint256 count = 0;
    assembly {
      let bsptr := add(bs, add(p, sz))
      let xsptr := add(xs, 32)
      for {

      } lt(count, xsLength) {

      } {
        mstore8(bsptr, byte(0, mload(xsptr)))
        bsptr := add(bsptr, 1)
        xsptr := add(xsptr, 1)
        count := add(count, 1)
      }
    }
    return sz + count;
  }

  /**
   * @dev Encode ProtoBuf string
   * @param xs The string to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_string(string memory xs, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_bytes(bytes(xs), p, bs);
  }

  /**
   * `_encode_(u)int(32|64)`, `_encode_enum` and `_encode_bool`
   * are concrete implementation of `_encode_varint`
   */
  function _encode_uint32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varint(x, p, bs);
  }

  function _encode_uint64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varint(x, p, bs);
  }

  function _encode_int32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_varint(twosComplement, p, bs);
  }

  function _encode_int64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_varint(twosComplement, p, bs);
  }

  function _encode_enum(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_int32(x, p, bs);
  }

  function _encode_bool(bool x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    if (x) {
      return _encode_varint(1, p, bs);
    } else return _encode_varint(0, p, bs);
  }

  /**
   * `_encode_sint(32|64)`, `_encode_enum` and `_encode_bool`
   * are the concrete implementation of `_encode_varints`
   */
  function _encode_sint32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varints(x, p, bs);
  }

  function _encode_sint64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_varints(x, p, bs);
  }

  /**
   * `_encode_(s)fixed(32|64)` is the concrete implementation of `_encode_uintf`
   */
  function _encode_fixed32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_uintf(x, p, bs, 4);
  }

  function _encode_fixed64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_uintf(x, p, bs, 8);
  }

  function _encode_sfixed32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint32 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_uintf(twosComplement, p, bs, 4);
  }

  function _encode_sfixed64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint64 twosComplement;
    assembly {
      twosComplement := x
    }
    return _encode_uintf(twosComplement, p, bs, 8);
  }

  /**
   * @dev Encode ProtoBuf fixed-length integer
   * @param x The unsigned integer to be encoded
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The length of encoded bytes
   */
  function _encode_uintf(uint256 x, uint256 p, bytes memory bs, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    assembly {
      let bsptr := add(sz, add(bs, p))
      let count := sz
      for {

      } gt(count, 0) {

      } {
        bsptr := sub(bsptr, 1)
        mstore8(bsptr, byte(sub(32, count), x))
        count := sub(count, 1)
      }
    }
    return sz;
  }

  /**
   * @dev Encode ProtoBuf zig-zag signed integer
   * @param i The unsigned integer to be encoded
   * @return The encoded unsigned integer
   */
  function _encode_zigzag(int256 i) internal pure returns (uint256) {
    if (i >= 0) {
      return uint256(i) * 2;
    } else return uint256(i * -2) - 1;
  }

  // Estimators
  /**
   * @dev Estimate the length of encoded LengthDelim
   * @param i The length of LengthDelim
   * @return The estimated encoded length
   */
  function _sz_lendelim(uint256 i) internal pure returns (uint256) {
    return i + _sz_varint(i);
  }

  /**
   * @dev Estimate the length of encoded ProtoBuf field ID
   * @param i The field ID
   * @return The estimated encoded length
   */
  function _sz_key(uint256 i) internal pure returns (uint256) {
    if (i < 16) {
      return 1;
    } else if (i < 2048) {
      return 2;
    } else if (i < 262144) {
      return 3;
    } else {
      revert("not supported");
    }
  }

  /**
   * @dev Estimate the length of encoded ProtoBuf varint
   * @param i The unsigned integer
   * @return The estimated encoded length
   */
  function _sz_varint(uint256 i) internal pure returns (uint256) {
    uint256 count = 1;
    assembly {
      i := shr(7, i)
      for {

      } gt(i, 0) {

      } {
        i := shr(7, i)
        count := add(count, 1)
      }
    }
    return count;
  }

  /**
   * `_sz_(u)int(32|64)` and `_sz_enum` are the concrete implementation of `_sz_varint`
   */
  function _sz_uint32(uint32 i) internal pure returns (uint256) {
    return _sz_varint(i);
  }

  function _sz_uint64(uint64 i) internal pure returns (uint256) {
    return _sz_varint(i);
  }

  function _sz_int32(int32 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint32(i));
  }

  function _sz_int64(int64 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint64(i));
  }

  function _sz_enum(int64 i) internal pure returns (uint256) {
    if (i < 0) {
      return 10;
    } else return _sz_varint(uint64(i));
  }

  /**
   * `_sz_sint(32|64)` and `_sz_enum` are the concrete implementation of zig-zag encoding
   */
  function _sz_sint32(int32 i) internal pure returns (uint256) {
    return _sz_varint(_encode_zigzag(i));
  }

  function _sz_sint64(int64 i) internal pure returns (uint256) {
    return _sz_varint(_encode_zigzag(i));
  }

  /**
   * `_estimate_packed_repeated_(uint32|uint64|int32|int64|sint32|sint64)`
   */
  function _estimate_packed_repeated_uint32(uint32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_uint32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_uint64(uint64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_uint64(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_int32(int32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_int32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_int64(int64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_int64(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_sint32(int32[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_sint32(a[i]);
    }
    return e;
  }

  function _estimate_packed_repeated_sint64(int64[] memory a) internal pure returns (uint256) {
    uint256 e = 0;
    for (uint i = 0; i < a.length; i++) {
      e += _sz_sint64(a[i]);
    }
    return e;
  }

  // Element counters for packed repeated fields
  function _count_packed_repeated_varint(uint256 p, uint256 len, bytes memory bs) internal pure returns (uint256) {
    uint256 count = 0;
    uint256 end = p + len;
    while (p < end) {
      uint256 sz;
      (, sz) = _decode_varint(p, bs);
      p += sz;
      count += 1;
    }
    return count;
  }

  // Soltype extensions
  /**
   * @dev Decode Solidity integer and/or fixed-size bytes array, filling from lowest bit.
   * @param n The maximum number of bytes to read
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The bytes32 representation
   * @return The number of bytes used to decode
   */
  function _decode_sol_bytesN_lower(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    uint256 r;
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    if (len + sz > n + 3) {
      revert(OVERFLOW_MESSAGE);
    }
    p += 3;
    assert(p < bs.length + WORD_LENGTH);
    assembly {
      r := mload(add(p, bs))
    }
    for (uint256 i = len - 2; i < WORD_LENGTH; i++) {
      r /= 256;
    }
    return (bytes32(r), len + sz);
  }

  /**
   * @dev Decode Solidity integer and/or fixed-size bytes array, filling from highest bit.
   * @param n The maximum number of bytes to read
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The bytes32 representation
   * @return The number of bytes used to decode
   */
  function _decode_sol_bytesN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    (uint256 len, uint256 sz) = _decode_varint(p, bs);
    uint256 wordLength = WORD_LENGTH;
    uint256 byteSize = BYTE_SIZE;
    if (len + sz > n + 3) {
      revert(OVERFLOW_MESSAGE);
    }
    p += 3;
    bytes32 acc;
    assert(p < bs.length + WORD_LENGTH);
    assembly {
      acc := mload(add(p, bs))
      let difference := sub(wordLength, sub(len, 2))
      let bits := mul(byteSize, difference)
      acc := shl(bits, shr(bits, acc))
    }
    return (acc, len + sz);
  }

  /*
   * `_decode_sol*` are the concrete implementation of decoding Solidity types
   */
  function _decode_sol_address(uint256 p, bytes memory bs)
    internal
    pure
    returns (address, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytesN(20, p, bs);
    return (address(bytes20(r)), sz);
  }

  function _decode_sol_bool(uint256 p, bytes memory bs)
    internal
    pure
    returns (bool, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(1, p, bs);
    if (r == 0) {
      return (false, sz);
    }
    return (true, sz);
  }

  function _decode_sol_uint(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    return _decode_sol_uint256(p, bs);
  }

  function _decode_sol_uintN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN_lower(n, p, bs);
    uint256 r;
    assembly {
      r := u
    }
    return (r, sz);
  }

  function _decode_sol_uint8(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint8, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(1, p, bs);
    return (uint8(r), sz);
  }

  function _decode_sol_uint16(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint16, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(2, p, bs);
    return (uint16(r), sz);
  }

  function _decode_sol_uint24(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint24, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(3, p, bs);
    return (uint24(r), sz);
  }

  function _decode_sol_uint32(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint32, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(4, p, bs);
    return (uint32(r), sz);
  }

  function _decode_sol_uint40(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint40, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(5, p, bs);
    return (uint40(r), sz);
  }

  function _decode_sol_uint48(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint48, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(6, p, bs);
    return (uint48(r), sz);
  }

  function _decode_sol_uint56(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint56, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(7, p, bs);
    return (uint56(r), sz);
  }

  function _decode_sol_uint64(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint64, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(8, p, bs);
    return (uint64(r), sz);
  }

  function _decode_sol_uint72(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint72, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(9, p, bs);
    return (uint72(r), sz);
  }

  function _decode_sol_uint80(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint80, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(10, p, bs);
    return (uint80(r), sz);
  }

  function _decode_sol_uint88(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint88, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(11, p, bs);
    return (uint88(r), sz);
  }

  function _decode_sol_uint96(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint96, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(12, p, bs);
    return (uint96(r), sz);
  }

  function _decode_sol_uint104(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint104, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(13, p, bs);
    return (uint104(r), sz);
  }

  function _decode_sol_uint112(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint112, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(14, p, bs);
    return (uint112(r), sz);
  }

  function _decode_sol_uint120(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint120, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(15, p, bs);
    return (uint120(r), sz);
  }

  function _decode_sol_uint128(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint128, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(16, p, bs);
    return (uint128(r), sz);
  }

  function _decode_sol_uint136(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint136, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(17, p, bs);
    return (uint136(r), sz);
  }

  function _decode_sol_uint144(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint144, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(18, p, bs);
    return (uint144(r), sz);
  }

  function _decode_sol_uint152(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint152, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(19, p, bs);
    return (uint152(r), sz);
  }

  function _decode_sol_uint160(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint160, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(20, p, bs);
    return (uint160(r), sz);
  }

  function _decode_sol_uint168(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint168, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(21, p, bs);
    return (uint168(r), sz);
  }

  function _decode_sol_uint176(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint176, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(22, p, bs);
    return (uint176(r), sz);
  }

  function _decode_sol_uint184(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint184, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(23, p, bs);
    return (uint184(r), sz);
  }

  function _decode_sol_uint192(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint192, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(24, p, bs);
    return (uint192(r), sz);
  }

  function _decode_sol_uint200(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint200, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(25, p, bs);
    return (uint200(r), sz);
  }

  function _decode_sol_uint208(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint208, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(26, p, bs);
    return (uint208(r), sz);
  }

  function _decode_sol_uint216(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint216, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(27, p, bs);
    return (uint216(r), sz);
  }

  function _decode_sol_uint224(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint224, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(28, p, bs);
    return (uint224(r), sz);
  }

  function _decode_sol_uint232(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint232, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(29, p, bs);
    return (uint232(r), sz);
  }

  function _decode_sol_uint240(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint240, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(30, p, bs);
    return (uint240(r), sz);
  }

  function _decode_sol_uint248(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint248, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(31, p, bs);
    return (uint248(r), sz);
  }

  function _decode_sol_uint256(uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256, uint256)
  {
    (uint256 r, uint256 sz) = _decode_sol_uintN(32, p, bs);
    return (uint256(r), sz);
  }

  function _decode_sol_int(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    return _decode_sol_int256(p, bs);
  }

  function _decode_sol_intN(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN_lower(n, p, bs);
    int256 r;
    assembly {
      r := u
      r := signextend(sub(sz, 4), r)
    }
    return (r, sz);
  }

  function _decode_sol_bytes(uint8 n, uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    (bytes32 u, uint256 sz) = _decode_sol_bytesN(n, p, bs);
    return (u, sz);
  }

  function _decode_sol_int8(uint256 p, bytes memory bs)
    internal
    pure
    returns (int8, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(1, p, bs);
    return (int8(r), sz);
  }

  function _decode_sol_int16(uint256 p, bytes memory bs)
    internal
    pure
    returns (int16, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(2, p, bs);
    return (int16(r), sz);
  }

  function _decode_sol_int24(uint256 p, bytes memory bs)
    internal
    pure
    returns (int24, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(3, p, bs);
    return (int24(r), sz);
  }

  function _decode_sol_int32(uint256 p, bytes memory bs)
    internal
    pure
    returns (int32, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(4, p, bs);
    return (int32(r), sz);
  }

  function _decode_sol_int40(uint256 p, bytes memory bs)
    internal
    pure
    returns (int40, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(5, p, bs);
    return (int40(r), sz);
  }

  function _decode_sol_int48(uint256 p, bytes memory bs)
    internal
    pure
    returns (int48, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(6, p, bs);
    return (int48(r), sz);
  }

  function _decode_sol_int56(uint256 p, bytes memory bs)
    internal
    pure
    returns (int56, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(7, p, bs);
    return (int56(r), sz);
  }

  function _decode_sol_int64(uint256 p, bytes memory bs)
    internal
    pure
    returns (int64, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(8, p, bs);
    return (int64(r), sz);
  }

  function _decode_sol_int72(uint256 p, bytes memory bs)
    internal
    pure
    returns (int72, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(9, p, bs);
    return (int72(r), sz);
  }

  function _decode_sol_int80(uint256 p, bytes memory bs)
    internal
    pure
    returns (int80, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(10, p, bs);
    return (int80(r), sz);
  }

  function _decode_sol_int88(uint256 p, bytes memory bs)
    internal
    pure
    returns (int88, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(11, p, bs);
    return (int88(r), sz);
  }

  function _decode_sol_int96(uint256 p, bytes memory bs)
    internal
    pure
    returns (int96, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(12, p, bs);
    return (int96(r), sz);
  }

  function _decode_sol_int104(uint256 p, bytes memory bs)
    internal
    pure
    returns (int104, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(13, p, bs);
    return (int104(r), sz);
  }

  function _decode_sol_int112(uint256 p, bytes memory bs)
    internal
    pure
    returns (int112, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(14, p, bs);
    return (int112(r), sz);
  }

  function _decode_sol_int120(uint256 p, bytes memory bs)
    internal
    pure
    returns (int120, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(15, p, bs);
    return (int120(r), sz);
  }

  function _decode_sol_int128(uint256 p, bytes memory bs)
    internal
    pure
    returns (int128, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(16, p, bs);
    return (int128(r), sz);
  }

  function _decode_sol_int136(uint256 p, bytes memory bs)
    internal
    pure
    returns (int136, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(17, p, bs);
    return (int136(r), sz);
  }

  function _decode_sol_int144(uint256 p, bytes memory bs)
    internal
    pure
    returns (int144, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(18, p, bs);
    return (int144(r), sz);
  }

  function _decode_sol_int152(uint256 p, bytes memory bs)
    internal
    pure
    returns (int152, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(19, p, bs);
    return (int152(r), sz);
  }

  function _decode_sol_int160(uint256 p, bytes memory bs)
    internal
    pure
    returns (int160, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(20, p, bs);
    return (int160(r), sz);
  }

  function _decode_sol_int168(uint256 p, bytes memory bs)
    internal
    pure
    returns (int168, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(21, p, bs);
    return (int168(r), sz);
  }

  function _decode_sol_int176(uint256 p, bytes memory bs)
    internal
    pure
    returns (int176, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(22, p, bs);
    return (int176(r), sz);
  }

  function _decode_sol_int184(uint256 p, bytes memory bs)
    internal
    pure
    returns (int184, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(23, p, bs);
    return (int184(r), sz);
  }

  function _decode_sol_int192(uint256 p, bytes memory bs)
    internal
    pure
    returns (int192, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(24, p, bs);
    return (int192(r), sz);
  }

  function _decode_sol_int200(uint256 p, bytes memory bs)
    internal
    pure
    returns (int200, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(25, p, bs);
    return (int200(r), sz);
  }

  function _decode_sol_int208(uint256 p, bytes memory bs)
    internal
    pure
    returns (int208, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(26, p, bs);
    return (int208(r), sz);
  }

  function _decode_sol_int216(uint256 p, bytes memory bs)
    internal
    pure
    returns (int216, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(27, p, bs);
    return (int216(r), sz);
  }

  function _decode_sol_int224(uint256 p, bytes memory bs)
    internal
    pure
    returns (int224, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(28, p, bs);
    return (int224(r), sz);
  }

  function _decode_sol_int232(uint256 p, bytes memory bs)
    internal
    pure
    returns (int232, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(29, p, bs);
    return (int232(r), sz);
  }

  function _decode_sol_int240(uint256 p, bytes memory bs)
    internal
    pure
    returns (int240, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(30, p, bs);
    return (int240(r), sz);
  }

  function _decode_sol_int248(uint256 p, bytes memory bs)
    internal
    pure
    returns (int248, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(31, p, bs);
    return (int248(r), sz);
  }

  function _decode_sol_int256(uint256 p, bytes memory bs)
    internal
    pure
    returns (int256, uint256)
  {
    (int256 r, uint256 sz) = _decode_sol_intN(32, p, bs);
    return (int256(r), sz);
  }

  function _decode_sol_bytes1(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes1, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(1, p, bs);
    return (bytes1(r), sz);
  }

  function _decode_sol_bytes2(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes2, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(2, p, bs);
    return (bytes2(r), sz);
  }

  function _decode_sol_bytes3(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes3, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(3, p, bs);
    return (bytes3(r), sz);
  }

  function _decode_sol_bytes4(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes4, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(4, p, bs);
    return (bytes4(r), sz);
  }

  function _decode_sol_bytes5(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes5, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(5, p, bs);
    return (bytes5(r), sz);
  }

  function _decode_sol_bytes6(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes6, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(6, p, bs);
    return (bytes6(r), sz);
  }

  function _decode_sol_bytes7(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes7, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(7, p, bs);
    return (bytes7(r), sz);
  }

  function _decode_sol_bytes8(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes8, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(8, p, bs);
    return (bytes8(r), sz);
  }

  function _decode_sol_bytes9(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes9, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(9, p, bs);
    return (bytes9(r), sz);
  }

  function _decode_sol_bytes10(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes10, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(10, p, bs);
    return (bytes10(r), sz);
  }

  function _decode_sol_bytes11(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes11, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(11, p, bs);
    return (bytes11(r), sz);
  }

  function _decode_sol_bytes12(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes12, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(12, p, bs);
    return (bytes12(r), sz);
  }

  function _decode_sol_bytes13(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes13, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(13, p, bs);
    return (bytes13(r), sz);
  }

  function _decode_sol_bytes14(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes14, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(14, p, bs);
    return (bytes14(r), sz);
  }

  function _decode_sol_bytes15(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes15, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(15, p, bs);
    return (bytes15(r), sz);
  }

  function _decode_sol_bytes16(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes16, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(16, p, bs);
    return (bytes16(r), sz);
  }

  function _decode_sol_bytes17(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes17, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(17, p, bs);
    return (bytes17(r), sz);
  }

  function _decode_sol_bytes18(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes18, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(18, p, bs);
    return (bytes18(r), sz);
  }

  function _decode_sol_bytes19(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes19, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(19, p, bs);
    return (bytes19(r), sz);
  }

  function _decode_sol_bytes20(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes20, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(20, p, bs);
    return (bytes20(r), sz);
  }

  function _decode_sol_bytes21(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes21, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(21, p, bs);
    return (bytes21(r), sz);
  }

  function _decode_sol_bytes22(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes22, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(22, p, bs);
    return (bytes22(r), sz);
  }

  function _decode_sol_bytes23(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes23, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(23, p, bs);
    return (bytes23(r), sz);
  }

  function _decode_sol_bytes24(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes24, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(24, p, bs);
    return (bytes24(r), sz);
  }

  function _decode_sol_bytes25(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes25, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(25, p, bs);
    return (bytes25(r), sz);
  }

  function _decode_sol_bytes26(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes26, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(26, p, bs);
    return (bytes26(r), sz);
  }

  function _decode_sol_bytes27(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes27, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(27, p, bs);
    return (bytes27(r), sz);
  }

  function _decode_sol_bytes28(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes28, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(28, p, bs);
    return (bytes28(r), sz);
  }

  function _decode_sol_bytes29(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes29, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(29, p, bs);
    return (bytes29(r), sz);
  }

  function _decode_sol_bytes30(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes30, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(30, p, bs);
    return (bytes30(r), sz);
  }

  function _decode_sol_bytes31(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes31, uint256)
  {
    (bytes32 r, uint256 sz) = _decode_sol_bytes(31, p, bs);
    return (bytes31(r), sz);
  }

  function _decode_sol_bytes32(uint256 p, bytes memory bs)
    internal
    pure
    returns (bytes32, uint256)
  {
    return _decode_sol_bytes(32, p, bs);
  }

  /*
   * `_encode_sol*` are the concrete implementation of encoding Solidity types
   */
  function _encode_sol_address(address x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(uint160(x)), 20, p, bs);
  }

  function _encode_sol_uint(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 32, p, bs);
  }

  function _encode_sol_uint8(uint8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 1, p, bs);
  }

  function _encode_sol_uint16(uint16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 2, p, bs);
  }

  function _encode_sol_uint24(uint24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 3, p, bs);
  }

  function _encode_sol_uint32(uint32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 4, p, bs);
  }

  function _encode_sol_uint40(uint40 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 5, p, bs);
  }

  function _encode_sol_uint48(uint48 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 6, p, bs);
  }

  function _encode_sol_uint56(uint56 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 7, p, bs);
  }

  function _encode_sol_uint64(uint64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 8, p, bs);
  }

  function _encode_sol_uint72(uint72 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 9, p, bs);
  }

  function _encode_sol_uint80(uint80 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 10, p, bs);
  }

  function _encode_sol_uint88(uint88 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 11, p, bs);
  }

  function _encode_sol_uint96(uint96 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 12, p, bs);
  }

  function _encode_sol_uint104(uint104 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 13, p, bs);
  }

  function _encode_sol_uint112(uint112 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 14, p, bs);
  }

  function _encode_sol_uint120(uint120 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 15, p, bs);
  }

  function _encode_sol_uint128(uint128 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 16, p, bs);
  }

  function _encode_sol_uint136(uint136 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 17, p, bs);
  }

  function _encode_sol_uint144(uint144 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 18, p, bs);
  }

  function _encode_sol_uint152(uint152 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 19, p, bs);
  }

  function _encode_sol_uint160(uint160 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 20, p, bs);
  }

  function _encode_sol_uint168(uint168 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 21, p, bs);
  }

  function _encode_sol_uint176(uint176 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 22, p, bs);
  }

  function _encode_sol_uint184(uint184 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 23, p, bs);
  }

  function _encode_sol_uint192(uint192 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 24, p, bs);
  }

  function _encode_sol_uint200(uint200 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 25, p, bs);
  }

  function _encode_sol_uint208(uint208 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 26, p, bs);
  }

  function _encode_sol_uint216(uint216 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 27, p, bs);
  }

  function _encode_sol_uint224(uint224 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 28, p, bs);
  }

  function _encode_sol_uint232(uint232 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 29, p, bs);
  }

  function _encode_sol_uint240(uint240 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 30, p, bs);
  }

  function _encode_sol_uint248(uint248 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 31, p, bs);
  }

  function _encode_sol_uint256(uint256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(uint256(x), 32, p, bs);
  }

  function _encode_sol_int(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(x, 32, p, bs);
  }

  function _encode_sol_int8(int8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 1, p, bs);
  }

  function _encode_sol_int16(int16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 2, p, bs);
  }

  function _encode_sol_int24(int24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 3, p, bs);
  }

  function _encode_sol_int32(int32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 4, p, bs);
  }

  function _encode_sol_int40(int40 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 5, p, bs);
  }

  function _encode_sol_int48(int48 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 6, p, bs);
  }

  function _encode_sol_int56(int56 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 7, p, bs);
  }

  function _encode_sol_int64(int64 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 8, p, bs);
  }

  function _encode_sol_int72(int72 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 9, p, bs);
  }

  function _encode_sol_int80(int80 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 10, p, bs);
  }

  function _encode_sol_int88(int88 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 11, p, bs);
  }

  function _encode_sol_int96(int96 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 12, p, bs);
  }

  function _encode_sol_int104(int104 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 13, p, bs);
  }

  function _encode_sol_int112(int112 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 14, p, bs);
  }

  function _encode_sol_int120(int120 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 15, p, bs);
  }

  function _encode_sol_int128(int128 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 16, p, bs);
  }

  function _encode_sol_int136(int136 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 17, p, bs);
  }

  function _encode_sol_int144(int144 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 18, p, bs);
  }

  function _encode_sol_int152(int152 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 19, p, bs);
  }

  function _encode_sol_int160(int160 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 20, p, bs);
  }

  function _encode_sol_int168(int168 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 21, p, bs);
  }

  function _encode_sol_int176(int176 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 22, p, bs);
  }

  function _encode_sol_int184(int184 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 23, p, bs);
  }

  function _encode_sol_int192(int192 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 24, p, bs);
  }

  function _encode_sol_int200(int200 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 25, p, bs);
  }

  function _encode_sol_int208(int208 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 26, p, bs);
  }

  function _encode_sol_int216(int216 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 27, p, bs);
  }

  function _encode_sol_int224(int224 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 28, p, bs);
  }

  function _encode_sol_int232(int232 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 29, p, bs);
  }

  function _encode_sol_int240(int240 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 30, p, bs);
  }

  function _encode_sol_int248(int248 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(int256(x), 31, p, bs);
  }

  function _encode_sol_int256(int256 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol(x, 32, p, bs);
  }

  function _encode_sol_bytes1(bytes1 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 1, p, bs);
  }

  function _encode_sol_bytes2(bytes2 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 2, p, bs);
  }

  function _encode_sol_bytes3(bytes3 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 3, p, bs);
  }

  function _encode_sol_bytes4(bytes4 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 4, p, bs);
  }

  function _encode_sol_bytes5(bytes5 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 5, p, bs);
  }

  function _encode_sol_bytes6(bytes6 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 6, p, bs);
  }

  function _encode_sol_bytes7(bytes7 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 7, p, bs);
  }

  function _encode_sol_bytes8(bytes8 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 8, p, bs);
  }

  function _encode_sol_bytes9(bytes9 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 9, p, bs);
  }

  function _encode_sol_bytes10(bytes10 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 10, p, bs);
  }

  function _encode_sol_bytes11(bytes11 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 11, p, bs);
  }

  function _encode_sol_bytes12(bytes12 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 12, p, bs);
  }

  function _encode_sol_bytes13(bytes13 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 13, p, bs);
  }

  function _encode_sol_bytes14(bytes14 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 14, p, bs);
  }

  function _encode_sol_bytes15(bytes15 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 15, p, bs);
  }

  function _encode_sol_bytes16(bytes16 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 16, p, bs);
  }

  function _encode_sol_bytes17(bytes17 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 17, p, bs);
  }

  function _encode_sol_bytes18(bytes18 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 18, p, bs);
  }

  function _encode_sol_bytes19(bytes19 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 19, p, bs);
  }

  function _encode_sol_bytes20(bytes20 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 20, p, bs);
  }

  function _encode_sol_bytes21(bytes21 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 21, p, bs);
  }

  function _encode_sol_bytes22(bytes22 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 22, p, bs);
  }

  function _encode_sol_bytes23(bytes23 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 23, p, bs);
  }

  function _encode_sol_bytes24(bytes24 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 24, p, bs);
  }

  function _encode_sol_bytes25(bytes25 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 25, p, bs);
  }

  function _encode_sol_bytes26(bytes26 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 26, p, bs);
  }

  function _encode_sol_bytes27(bytes27 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 27, p, bs);
  }

  function _encode_sol_bytes28(bytes28 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 28, p, bs);
  }

  function _encode_sol_bytes29(bytes29 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 29, p, bs);
  }

  function _encode_sol_bytes30(bytes30 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 30, p, bs);
  }

  function _encode_sol_bytes31(bytes31 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(bytes32(x), 31, p, bs);
  }

  function _encode_sol_bytes32(bytes32 x, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    return _encode_sol_bytes(x, 32, p, bs);
  }

  /**
   * @dev Encode the key of Solidity integer and/or fixed-size bytes array.
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol_header(uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    p += _encode_varint(sz + 2, p, bs);
    p += _encode_key(1, WireType.LengthDelim, p, bs);
    p += _encode_varint(sz, p, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The unsinged integer to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol(uint256 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_other(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The signed integer to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol(int256 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_other(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Encode Solidity type
   * @param x The fixed-size byte array to be encoded
   * @param sz The number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes used to encode
   */
  function _encode_sol_bytes(bytes32 x, uint256 sz, uint256 p, bytes memory bs)
    internal
    pure
    returns (uint256)
  {
    uint256 offset = p;
    uint256 size;
    p += 3;
    size = _encode_sol_raw_bytes_array(x, p, bs, sz);
    p += size;
    _encode_sol_header(size, offset, bs);
    return p - offset;
  }

  /**
   * @dev Get the actual size needed to encoding an unsigned integer
   * @param x The unsigned integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @return The number of bytes needed for encoding `x`
   */
  function _get_real_size(uint256 x, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    uint256 base = 0xff;
    uint256 realSize = sz;
    while (
      x & (base << (realSize * BYTE_SIZE - BYTE_SIZE)) == 0 && realSize > 0
    ) {
      realSize -= 1;
    }
    if (realSize == 0) {
      realSize = 1;
    }
    return realSize;
  }

  /**
   * @dev Get the actual size needed to encoding an signed integer
   * @param x The signed integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @return The number of bytes needed for encoding `x`
   */
  function _get_real_size(int256 x, uint256 sz)
    internal
    pure
    returns (uint256)
  {
    int256 base = 0xff;
    if (x >= 0) {
      uint256 tmp = _get_real_size(uint256(x), sz);
      int256 remainder = (x & (base << (tmp * BYTE_SIZE - BYTE_SIZE))) >>
        (tmp * BYTE_SIZE - BYTE_SIZE);
      if (remainder >= 128) {
        tmp += 1;
      }
      return tmp;
    }

    uint256 realSize = sz;
    while (
      x & (base << (realSize * BYTE_SIZE - BYTE_SIZE)) ==
      (base << (realSize * BYTE_SIZE - BYTE_SIZE)) &&
      realSize > 0
    ) {
      realSize -= 1;
    }
    {
      int256 remainder = (x & (base << (realSize * BYTE_SIZE - BYTE_SIZE))) >>
        (realSize * BYTE_SIZE - BYTE_SIZE);
      if (remainder < 128) {
        realSize += 1;
      }
    }
    return realSize;
  }

  /**
   * @dev Encode the fixed-bytes array
   * @param x The fixed-size byte array to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_bytes_array(
    bytes32 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    /**
     * The idea is to not encode the leading bytes of zero.
     */
    uint256 actualSize = sz;
    for (uint256 i = 0; i < sz; i++) {
      uint8 current = uint8(x[sz - 1 - i]);
      if (current == 0 && actualSize > 1) {
        actualSize--;
      } else {
        break;
      }
    }
    assembly {
      let bsptr := add(bs, p)
      let count := actualSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(actualSize, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return actualSize;
  }

  /**
   * @dev Encode the signed integer
   * @param x The signed integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_other(
    int256 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    /**
     * The idea is to not encode the leading bytes of zero.or one,
     * depending on whether it is positive.
     */
    uint256 realSize = _get_real_size(x, sz);
    assembly {
      let bsptr := add(bs, p)
      let count := realSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(32, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return realSize;
  }

  /**
   * @dev Encode the unsigned integer
   * @param x The unsigned integer to be encoded
   * @param sz The maximum number of bytes used to encode Solidity types
   * @param p The offset of bytes array `bs`
   * @param bs The bytes array to encode
   * @return The number of bytes needed for encoding `x`
   */
  function _encode_sol_raw_other(
    uint256 x,
    uint256 p,
    bytes memory bs,
    uint256 sz
  ) internal pure returns (uint256) {
    uint256 realSize = _get_real_size(x, sz);
    assembly {
      let bsptr := add(bs, p)
      let count := realSize
      for {

      } gt(count, 0) {

      } {
        mstore8(bsptr, byte(sub(32, count), x))
        bsptr := add(bsptr, 1)
        count := sub(count, 1)
      }
    }
    return realSize;
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Panic.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Strings.sol)

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
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
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
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the ERC-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC-165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC-165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     */
    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC-165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC-165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC-165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC-165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     *
     * Some precompiled contracts will falsely indicate support for a given interface, so caution
     * should be exercised when using this function.
     *
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeCall(IERC165.supportsInterface, (interfaceId));

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

import {Panic} from "../Panic.sol";
import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
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
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
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
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
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

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
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

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += SafeCast.toUint(value > 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
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
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
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

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
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
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
    }
}