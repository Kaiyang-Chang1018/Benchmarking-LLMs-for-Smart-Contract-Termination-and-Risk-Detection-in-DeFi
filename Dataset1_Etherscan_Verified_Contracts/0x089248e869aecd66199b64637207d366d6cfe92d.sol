// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {StateMachineHeight} from "./Message.sol";

// The state commiment identifies a commiment to some intermediate state in the state machine.
// This contains some metadata about the state machine like it's own timestamp at the time of this commitment.
struct StateCommitment {
	// This timestamp is useful for handling request timeouts.
	uint256 timestamp;
	// Overlay trie commitment to all ismp requests & response.
	bytes32 overlayRoot;
	// State trie commitment at the given block height
	bytes32 stateRoot;
}

// An intermediate state in the series of state transitions undergone by a given state machine.
struct IntermediateState {
	// the state machine identifier
	uint256 stateMachineId;
	// height of this state machine
	uint256 height;
	// state commitment
	StateCommitment commitment;
}

/**
 * @title The Ismp ConsensusClient
 * @author Polytope Labs (hello@polytope.technology)
 *
 * @notice The consensus client interface responsible for the verification of consensus datagrams.
 * It's internals are opaque to the ISMP framework allowing it to evolve as needed.
 */
interface IConsensusClient {
	// @dev Given some opaque consensus proof, produce the new consensus state and newly finalized intermediate states.
	function verifyConsensus(
		bytes memory trustedState,
		bytes memory proof
	) external returns (bytes memory, IntermediateState[] memory);
}
// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {PostRequest, StateMachineHeight} from "./Message.sol";

// @notice An object for dispatching post requests to the Hyperbridge
struct DispatchPost {
	// bytes representation of the destination state machine
	bytes dest;
	// the destination module
	bytes to;
	// the request body
	bytes body;
	// timeout for this request in seconds
	uint64 timeout;
	// the amount put up to be paid to the relayer,
	// this is charged in `IIsmpHost.feeToken` to `msg.sender`
	uint256 fee;
	// who pays for this request?
	address payer;
}

// @notice An object for dispatching get requests to the Hyperbridge
struct DispatchGet {
	// bytes representation of the destination state machine
	bytes dest;
	// height at which to read the state machine
	uint64 height;
	// storage keys to read
	bytes[] keys;
	// timeout for this request in seconds
	uint64 timeout;
	// Hyperbridge protocol fees for processing this request.
	uint256 fee;
	// Some application-specific metadata relating to this request
	bytes context;
}

struct DispatchPostResponse {
	// The request that initiated this response
	PostRequest request;
	// bytes for post response
	bytes response;
	// timeout for this response in seconds
	uint64 timeout;
	// the amount put up to be paid to the relayer,
	// this is charged in `IIsmpHost.feeToken` to `msg.sender`
	uint256 fee;
	// who pays for this request?
	address payer;
}

/*
 * @title The Ismp Dispatcher
 * @author Polytope Labs (hello@polytope.technology)
 *
 * @notice The IDispatcher serves as the interface requests & response messages.
 */
interface IDispatcher {
	/**
	 * @dev Returns the address for the Uniswap V2 Router implementation used for swaps
	 * @return routerAddress - The address to the in-use RouterV02 implementation
	 */
	function uniswapV2Router() external view returns (address);

	/**
	 * @dev Returns the nonce immediately available for requests
	 * @return the `nonce`
	 */
	function nonce() external view returns (uint256);

	/**
	 * @dev Returns the address of the ERC-20 fee token contract configured for this state machine.
	 *
	 * @notice Hyperbridge collects it's dispatch fees in the provided token denomination. This will typically be in stablecoins.
	 *
	 * @return feeToken - The ERC20 contract address for fees.
	 */
	function feeToken() external view returns (address);

	/**
	 * @dev Returns the address of the per byte fee configured for the destination state machine.
	 *
	 * @notice Hyperbridge collects it's dispatch fees per every byte of the outgoing message.
	 *
	 * @param dest - The destination chain for the per byte fee.
	 * @return perByteFee - The per byte fee for outgoing messages.
	 */
	function perByteFee(bytes memory dest) external view returns (uint256);

	/**
	 * @dev Dispatch a POST request to Hyperbridge
	 *
	 * @notice Payment for the request can be made with either the native token or the IIsmpHost.feeToken.
	 * If native tokens are supplied, it will perform a swap under the hood using the local uniswap router.
	 * Will revert if enough native tokens are not provided.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * @param request - post request
	 * @return commitment - the request commitment
	 */
	function dispatch(DispatchPost memory request) external payable returns (bytes32 commitment);

	/**
	 * @dev Dispatch a GET request to Hyperbridge
	 *
	 * @notice Payment for the request can be made with either the native token or the IIsmpHost.feeToken.
	 * If native tokens are supplied, it will perform a swap under the hood using the local uniswap router.
	 * Will revert if enough native tokens are not provided.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * @param request - get request
	 * @return commitment - the request commitment
	 */
	function dispatch(DispatchGet memory request) external payable returns (bytes32 commitment);

	/**
	 * @dev Dispatch a POST response to Hyperbridge
	 *
	 * @notice Payment for the request can be made with either the native token or the IIsmpHost.feeToken.
	 * If native tokens are supplied, it will perform a swap under the hood using the local uniswap router.
	 * Will revert if enough native tokens are not provided.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * @param response - post response
	 * @return commitment - the request commitment
	 */
	function dispatch(DispatchPostResponse memory response) external payable returns (bytes32 commitment);

	/**
	 * @dev Increase the relayer fee for a previously dispatched request.
	 * This is provided for use only on pending requests, such that when they timeout,
	 * the user can recover the entire relayer fee.
	 *
	 * @notice Payment can be made with either the native token or the IIsmpHost.feeToken.
	 * If native tokens are supplied, it will perform a swap under the hood using the local uniswap router.
	 * Will revert if enough native tokens are not provided.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * If called on an already delivered request, these funds will be seen as a donation to the hyperbridge protocol.
	 * @param commitment - The request commitment
	 * @param amount - The amount provided in `IIsmpHost.feeToken()`
	 */
	function fundRequest(bytes32 commitment, uint256 amount) external payable;

	/**
	 * @dev Increase the relayer fee for a previously dispatched response.
	 * This is provided for use only on pending responses, such that when they timeout,
	 * the user can recover the entire relayer fee.
	 *
	 * @notice Payment can be made with either the native token or the IIsmpHost.feeToken.
	 * If native tokens are supplied, it will perform a swap under the hood using the local uniswap router.
	 * Will revert if enough native tokens are not provided.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * If called on an already delivered response, these funds will be seen as a donation to the hyperbridge protocol.
	 * @param commitment - The response commitment
	 * @param amount - The amount to be provided in `IIsmpHost.feeToken()`
	 */
	function fundResponse(bytes32 commitment, uint256 amount) external payable;
}
// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {IIsmpHost} from "./IIsmpHost.sol";
import {PostRequestMessage, PostResponseMessage, GetResponseMessage, PostRequestTimeoutMessage, PostResponseTimeoutMessage, GetTimeoutMessage} from "./Message.sol";

/*
 * @title The Ismp Handler
 * @author Polytope Labs (hello@polytope.technology)
 *
 * @notice The IHandler interface serves as the entry point for ISMP datagrams, i.e consensus, requests & response messages.
 */
interface IHandler {
	/**
	 * @dev Handle an incoming consensus message. This uses the IConsensusClient contract registered on the host to perform the consensus message verification.
	 * @param host - Ismp host
	 * @param proof - consensus proof
	 */
	function handleConsensus(IIsmpHost host, bytes memory proof) external;

	/**
	 * @dev Handles incoming POST requests, check request proofs, message delay and timeouts, then dispatch POST requests to the apropriate contracts.
	 * @param host - Ismp host
	 * @param request - batch post requests
	 */
	function handlePostRequests(IIsmpHost host, PostRequestMessage memory request) external;

	/**
	 * @dev Handles incoming POST responses, check response proofs, message delay and timeouts, then dispatch POST responses to the apropriate contracts.
	 * @param host - Ismp host
	 * @param response - batch post responses
	 */
	function handlePostResponses(IIsmpHost host, PostResponseMessage memory response) external;

	/**
	 * @dev check response proofs, message delay and timeouts, then dispatch get responses to modules
	 * @param host - Ismp host
	 * @param message - batch get responses
	 */
	function handleGetResponses(IIsmpHost host, GetResponseMessage memory message) external;

	/**
	 * @dev check timeout proofs then dispatch to modules
	 * @param host - Ismp host
	 * @param message - batch post request timeouts
	 */
	function handlePostRequestTimeouts(IIsmpHost host, PostRequestTimeoutMessage memory message) external;

	/**
	 * @dev check timeout proofs then dispatch to modules
	 * @param host - Ismp host
	 * @param message - batch post response timeouts
	 */
	function handlePostResponseTimeouts(IIsmpHost host, PostResponseTimeoutMessage memory message) external;

	/**
	 * @dev dispatch to modules
	 * @param host - Ismp host
	 * @param message - batch get request timeouts
	 */
	function handleGetRequestTimeouts(IIsmpHost host, GetTimeoutMessage memory message) external;
}
// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {StateCommitment, StateMachineHeight} from "./IConsensusClient.sol";
import {IDispatcher} from "./IDispatcher.sol";
import {PostRequest, PostResponse, GetResponse, GetRequest} from "./Message.sol";

// Some metadata about the request fee
struct FeeMetadata {
	// the relayer fee
	uint256 fee;
	// user who initiated the request
	address sender;
}

struct ResponseReceipt {
	// commitment of the response object
	bytes32 responseCommitment;
	// address of the relayer responsible for this response delivery
	address relayer;
}

// Various frozen states of the IIsmpHost
enum FrozenStatus {
	// Host is operating normally
	None,
	// Host is currently disallowing incoming datagrams
	Incoming,
	// Host is currently disallowing outgoing messages
	Outgoing,
	// All actions have been frozen
	All
}

/**
 * @title The Ismp Host Interface
 * @author Polytope Labs (hello@polytope.technology)
 *
 * @notice The Ismp Host interface sits at the core of the interoperable state machine protocol,
 * It which encapsulates the interfaces required for ISMP datagram handlers and modules.
 *
 * @dev The IsmpHost provides the necessary storage interface for the ISMP handlers to process
 * ISMP messages, the IsmpDispatcher provides the interfaces applications use for dispatching requests
 * and responses. This host implementation delegates all verification logic to the IHandler contract.
 * It is only responsible for dispatching incoming & outgoing messages as well as managing
 * the state of the ISMP protocol.
 */
interface IIsmpHost is IDispatcher {
	/**
	 * @return the host admin
	 */
	function admin() external returns (address);

	/**
	 * @return the host state machine id
	 */
	function host() external view returns (bytes memory);

	/**
	 * @return the state machine identifier for the connected hyperbridge instance
	 */
	function hyperbridge() external view returns (bytes memory);

	/**
	 * @return the host timestamp
	 */
	function timestamp() external view returns (uint256);

	/**
	 * @dev Returns the fisherman responsible for vetoing the given state machine height.
	 * @return the `fisherman` address
	 */
	function vetoes(uint256 paraId, uint256 height) external view returns (address);

	/**
	 * @return the `frozen` status
	 */
	function frozen() external view returns (FrozenStatus);

	/**
	 * @dev Returns the fee required for 3rd party applications to access hyperbridge state commitments.
	 * @return the `stateCommitmentFee`
	 */
	function stateCommitmentFee() external view returns (uint256);

	/**
	 * @notice Charges the stateCommitmentFee to 3rd party applications.
	 * If native tokens are provided, will attempt to swap them for the stateCommitmentFee.
	 * If not enough native tokens are supplied, will revert.
	 *
	 * If no native tokens are provided then it will try to collect payment from the calling contract in
	 * the IIsmpHost.feeToken.
	 *
	 * @param height - state machine height
	 * @return the state commitment at `height`
	 */
	function stateMachineCommitment(StateMachineHeight memory height) external payable returns (StateCommitment memory);

	/**
	 * @param height - state machine height
	 * @return the state machine commitment update time at `height`
	 */
	function stateMachineCommitmentUpdateTime(StateMachineHeight memory height) external returns (uint256);

	/**
	 * @return the consensus client contract
	 */
	function consensusClient() external view returns (address);

	/**
	 * @return the last updated time of the consensus client
	 */
	function consensusUpdateTime() external view returns (uint256);

	/**
	 * @return the latest state machine height for the given stateMachineId. If it returns 0, the state machine is unsupported.
	 */
	function latestStateMachineHeight(uint256 stateMachineId) external view returns (uint256);

	/**
	 * @return the state of the consensus client
	 */
	function consensusState() external view returns (bytes memory);

	/**
	 * @dev Check the response status for a given request.
	 * @return `response` status
	 */
	function responded(bytes32 commitment) external view returns (bool);

	/**
	 * @param commitment - commitment to the request
	 * @return relayer address
	 */
	function requestReceipts(bytes32 commitment) external view returns (address);

	/**
	 * @param commitment - commitment to the request of the response
	 * @return response receipt
	 */
	function responseReceipts(bytes32 commitment) external view returns (ResponseReceipt memory);

	/**
	 * @param commitment - commitment to the request
	 * @return existence status of an outgoing request commitment
	 */
	function requestCommitments(bytes32 commitment) external view returns (FeeMetadata memory);

	/**
	 * @param commitment - commitment to the response
	 * @return existence status of an outgoing response commitment
	 */
	function responseCommitments(bytes32 commitment) external view returns (FeeMetadata memory);

	/**
	 * @return the challenge period
	 */
	function challengePeriod() external view returns (uint256);

	/**
	 * @return the unstaking period
	 */
	function unStakingPeriod() external view returns (uint256);

	/**
	 * @dev set the new frozen state of the host, only the admin or handler can call this.
	 * @param newState - the new frozen state
	 */
	function setFrozenState(FrozenStatus newState) external;

	/**
	 * @dev Store an encoded consensus state
	 * @param state new consensus state
	 */
	function storeConsensusState(bytes memory state) external;

	/**
	 * @dev Store the commitment at `state height`
	 * @param height state machine height
	 * @param commitment state commitment
	 */
	function storeStateMachineCommitment(StateMachineHeight memory height, StateCommitment memory commitment) external;

	/**
	 * @dev Delete the state commitment at given state height.
	 */
	function deleteStateMachineCommitment(StateMachineHeight memory height, address fisherman) external;

	/**
	 * @dev Dispatch an incoming request to destination module
	 * @param request - post request
	 */
	function dispatchIncoming(PostRequest memory request, address relayer) external;

	/**
	 * @dev Dispatch an incoming post response to source module
	 * @param response - post response
	 */
	function dispatchIncoming(PostResponse memory response, address relayer) external;

	/**
	 * @dev Dispatch an incoming get response to source module
	 * @param response - get response
	 */
	function dispatchIncoming(GetResponse memory response, address relayer) external;

	/**
	 * @dev Dispatch an incoming get timeout to source module
	 * @param timeout - timed-out get request
	 */
	function dispatchTimeOut(GetRequest memory timeout, FeeMetadata memory meta, bytes32 commitment) external;

	/**
	 * @dev Dispatch an incoming post timeout to source module
	 * @param timeout - timed-out post request
	 */
	function dispatchTimeOut(PostRequest memory timeout, FeeMetadata memory meta, bytes32 commitment) external;

	/**
	 * @dev Dispatch an incoming post response timeout to source module
	 * @param timeout - timed-out post response
	 */
	function dispatchTimeOut(PostResponse memory timeout, FeeMetadata memory meta, bytes32 commitment) external;
}
// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {StorageValue} from "@polytope-labs/solidity-merkle-trees/src/Types.sol";

// Identifies some state machine height. We allow for a state machine identifier here
// as some consensus clients may track multiple, concurrent state machines.
struct StateMachineHeight {
	// the state machine identifier
	uint256 stateMachineId;
	// height of this state machine
	uint256 height;
}

struct PostRequest {
	// the source state machine of this request
	bytes source;
	// the destination state machine of this request
	bytes dest;
	// request nonce
	uint64 nonce;
	// Module Id of this request origin
	bytes from;
	// destination module id
	bytes to;
	// timestamp by which this request times out.
	uint64 timeoutTimestamp;
	// request body
	bytes body;
}

struct GetRequest {
	// the source state machine of this request
	bytes source;
	// the destination state machine of this request
	bytes dest;
	// request nonce
	uint64 nonce;
	// Module Id of this request origin
	address from;
	// timestamp by which this request times out.
	uint64 timeoutTimestamp;
	// Storage keys to read.
	bytes[] keys;
	// height at which to read destination state machine
	uint64 height;
	// Some application-specific metadata relating to this request
	bytes context;
}

struct GetResponse {
	// The request that initiated this response
	GetRequest request;
	// storage values for get response
	StorageValue[] values;
}

struct PostResponse {
	// The request that initiated this response
	PostRequest request;
	// bytes for post response
	bytes response;
	// timestamp by which this response times out.
	uint64 timeoutTimestamp;
}

// A post request as a leaf in a merkle tree
struct PostRequestLeaf {
	// The request
	PostRequest request;
	// It's index in the mmr leaves
	uint256 index;
	// it's k-index
	uint256 kIndex;
}

// A post response as a leaf in a merkle tree
struct PostResponseLeaf {
	// The response
	PostResponse response;
	// It's index in the mmr leaves
	uint256 index;
	// it's k-index
	uint256 kIndex;
}

// A get response as a leaf in a merkle mountain range tree
struct GetResponseLeaf {
	// The response
	GetResponse response;
	// It's index in the mmr leaves
	uint256 index;
	// it's k-index
	uint256 kIndex;
}

// A merkle mountain range proof.
struct Proof {
	// height of the state machine
	StateMachineHeight height;
	// the multi-proof
	bytes32[] multiproof;
	// The total number of leaves in the mmr for this proof.
	uint256 leafCount;
}

// A message for handling incoming requests
struct PostRequestMessage {
	// proof for the requests
	Proof proof;
	// The requests, contained in the merkle mountain range tree
	PostRequestLeaf[] requests;
}

// A message for handling incoming GET responses
struct GetResponseMessage {
	// proof for the responses
	Proof proof;
	// The responses, contained in the merkle mountain range tree
	GetResponseLeaf[] responses;
}

struct GetTimeoutMessage {
	// requests which have timed-out
	GetRequest[] timeouts;
	// the height of the state machine proof
	StateMachineHeight height;
	// non-membership proof of the requests
	bytes[] proof;
}

struct PostRequestTimeoutMessage {
	// requests which have timed-out
	PostRequest[] timeouts;
	// the height of the state machine proof
	StateMachineHeight height;
	// non-membership proof of the requests
	bytes[] proof;
}

struct PostResponseTimeoutMessage {
	// responses which have timed-out
	PostResponse[] timeouts;
	// the height of the state machine proof
	StateMachineHeight height;
	// non-membership proof of the requests
	bytes[] proof;
}

// A message for handling incoming responses
struct PostResponseMessage {
	// proof for the responses
	Proof proof;
	// the responses, contained in a merkle tree leaf
	PostResponseLeaf[] responses;
}

library Message {
	/**
	 * @dev Calculates the absolute timeout value for a PostRequest
	 */
	function timeout(PostRequest memory req) internal pure returns (uint64) {
		if (req.timeoutTimestamp == 0) {
			return type(uint64).max;
		} else {
			return req.timeoutTimestamp;
		}
	}

	/**
	 * @dev Calculates the absolute timeout value for a GetRequest
	 */
	function timeout(GetRequest memory req) internal pure returns (uint64) {
		if (req.timeoutTimestamp == 0) {
			return type(uint64).max;
		} else {
			return req.timeoutTimestamp;
		}
	}

	/**
	 * @dev Calculates the absolute timeout value for a PostResponse
	 */
	function timeout(PostResponse memory res) internal pure returns (uint64) {
		if (res.timeoutTimestamp == 0) {
			return type(uint64).max;
		} else {
			return res.timeoutTimestamp;
		}
	}

	/**
	 * @dev Encode the given post request for commitment
	 */
	function encode(PostRequest memory req) internal pure returns (bytes memory) {
		return abi.encodePacked(req.source, req.dest, req.nonce, req.timeoutTimestamp, req.from, req.to, req.body);
	}

	/**
	 * @dev Encode the given get request for commitment
	 */
	function encode(GetRequest memory req) internal pure returns (bytes memory) {
		bytes memory keysEncoding = bytes("");
		uint256 len = req.keys.length;
		for (uint256 i = 0; i < len; i++) {
			keysEncoding = bytes.concat(keysEncoding, req.keys[i]);
		}

		return
			abi.encodePacked(
				req.source,
				req.dest,
				req.nonce,
				req.height,
				req.timeoutTimestamp,
				abi.encodePacked(req.from),
				keysEncoding,
				req.context
			);
	}

	/**
	 * @dev Returns the commitment for the given post response
	 */
	function hash(PostResponse memory res) internal pure returns (bytes32) {
		return keccak256(bytes.concat(encode(res.request), abi.encodePacked(res.response, res.timeoutTimestamp)));
	}

	/**
	 * @dev Returns the commitment for the given post request
	 */
	function hash(PostRequest memory req) internal pure returns (bytes32) {
		return keccak256(encode(req));
	}

	/**
	 * @dev Returns the commitment for the given get request
	 */
	function hash(GetRequest memory req) internal pure returns (bytes32) {
		return keccak256(encode(req));
	}

	/**
	 * @dev Returns the commitment for the given get response
	 */
	function hash(GetResponse memory res) internal pure returns (bytes32) {
		bytes memory response = bytes("");
		uint256 len = res.values.length;
		for (uint256 i = 0; i < len; i++) {
			response = bytes.concat(response, bytes.concat(res.values[i].key, res.values[i].value));
		}
		return keccak256(bytes.concat(encode(res.request), response));
	}
}
// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/Math.sol";

import "./Types.sol";
import "./MerkleMultiProof.sol";

/**
 * @title A Merkle Mountain Range proof library
 * @author Polytope Labs
 * @notice Use this library to verify the leaves of a merkle mountain range tree
 * @dev refer to research for more info. https://research.polytope.technology/merkle-mountain-range-multi-proofs
 */
library MerkleMountainRange {
    /// @notice Verify that merkle proof is accurate
    /// @notice This calls CalculateRoot(...) under the hood
    /// @param root hash of the Merkle's root node
    /// @param proof a list of nodes required for the proof to be verified
    /// @param leaves a list of mmr leaves to prove
    /// @return boolean if the calculated root matches the provided root node
    function VerifyProof(
        bytes32 root,
        bytes32[] memory proof,
        MmrLeaf[] memory leaves,
        uint256 mmrSize
    ) internal pure returns (bool) {
        return root == CalculateRoot(proof, leaves, mmrSize);
    }

    /// @notice Calculate merkle root
    /// @notice this method allows computing the root hash of a merkle tree using Merkle Mountain Range
    /// @param proof A list of the merkle nodes that are needed to re-calculate root node.
    /// @param leaves a list of mmr leaves to prove
    /// @param leafCount the size of the merkle tree
    /// @return bytes32 hash of the computed root node
    function CalculateRoot(
        bytes32[] memory proof,
        MmrLeaf[] memory leaves,
        uint256 leafCount
    ) internal pure returns (bytes32) {
        // special handle the only 1 leaf MMR
        if (leafCount == 1 && leaves.length == 1 && leaves[0].leaf_index == 0) {
            return leaves[0].hash;
        }

        uint256[] memory subtrees = subtreeHeights(leafCount);
        uint256 length = subtrees.length;
        Iterator memory peakRoots = Iterator(0, new bytes32[](length));
        Iterator memory proofIter = Iterator(0, proof);

        uint256 current_subtree;
        for (uint256 p; p < length; ) {
            uint256 height = subtrees[p];
            current_subtree += 2 ** height;

            MmrLeaf[] memory subtreeLeaves = new MmrLeaf[](0);
            if (leaves.length > 0) {
                (subtreeLeaves, leaves) = leavesForSubtree(
                    leaves,
                    current_subtree
                );
            }

            if (subtreeLeaves.length == 0) {
                if (proofIter.data.length == proofIter.offset) {
                    break;
                } else {
                    push(peakRoots, next(proofIter));
                }
            } else if (subtreeLeaves.length == 1 && height == 0) {
                push(peakRoots, subtreeLeaves[0].hash);
            } else {
                push(
                    peakRoots,
                    CalculateSubtreeRoot(subtreeLeaves, proofIter, height)
                );
            }

            unchecked {
                ++p;
            }
        }

        unchecked {
            peakRoots.offset--;
        }

        while (peakRoots.offset != 0) {
            bytes32 right = previous(peakRoots);
            bytes32 left = previous(peakRoots);
            unchecked {
                ++peakRoots.offset;
            }
            peakRoots.data[peakRoots.offset] = keccak256(
                abi.encodePacked(right, left)
            );
        }

        return peakRoots.data[0];
    }

    function subtreeHeights(
        uint256 leavesLength
    ) internal pure returns (uint256[] memory) {
        uint256 maxSubtrees = 64;
        uint256[] memory indices = new uint256[](maxSubtrees);
        uint256 i;
        uint256 current = leavesLength;
        for (; i < maxSubtrees; ) {
            if (current == 0) {
                break;
            }
            uint256 log = Math.log2(current);
            indices[i] = log;
            current = current - 2 ** log;

            unchecked {
                ++i;
            }
        }

        // resize array?, sigh solidity.
        uint256 excess = maxSubtrees - i;
        assembly {
            mstore(indices, sub(mload(indices), excess))
        }

        return indices;
    }

    /// @notice calculate root hash of a subtree of the merkle mountain
    /// @param peakLeaves  a list of nodes to provide proof for
    /// @param proofIter   a list of node hashes to traverse to compute the peak root hash
    /// @param height    Height of the subtree
    /// @return peakRoot a tuple containing the peak root hash, and the peak root position in the merkle
    function CalculateSubtreeRoot(
        MmrLeaf[] memory peakLeaves,
        Iterator memory proofIter,
        uint256 height
    ) internal pure returns (bytes32) {
        uint256[] memory current_layer;
        Node[] memory leaves;
        (leaves, current_layer) = mmrLeafToNode(peakLeaves);

        Node[][] memory layers = new Node[][](height);
        for (uint256 i; i < height; ) {
            uint256 nodelength = 2 ** (height - i);
            if (current_layer.length == nodelength) {
                break;
            }

            uint256[] memory siblings = siblingIndices(current_layer);
            uint256[] memory diff = difference(siblings, current_layer);

            uint256 length = diff.length;
            layers[i] = new Node[](length);
            for (uint256 j; j < length; ) {
                layers[i][j] = Node(diff[j], next(proofIter));

                unchecked {
                    ++j;
                }
            }

            current_layer = parentIndices(siblings);

            unchecked {
                ++i;
            }
        }

        return MerkleMultiProof.CalculateRoot(layers, leaves);
    }

    /**
     * @notice difference ensures all nodes have a sibling.
     * @dev left and right are designed to be equal length array
     * @param left a list of hashes
     * @param right a list of hashes to compare
     * @return uint256[] a new array with difference
     */
    function difference(
        uint256[] memory left,
        uint256[] memory right
    ) internal pure returns (uint256[] memory) {
        uint256 length = left.length;
        uint256 rightLength = right.length;

        uint256[] memory diff = new uint256[](length);
        uint256 d;
        for (uint256 i; i < length; ) {
            bool found;
            for (uint256 j; j < rightLength; ) {
                if (left[i] == right[j]) {
                    found = true;
                    break;
                }

                unchecked {
                    ++j;
                }
            }

            if (!found) {
                diff[d] = left[i];
                d++;
            }

            unchecked {
                ++i;
            }
        }

        // resize array?, sigh solidity.
        uint256 excess = length - d;
        assembly {
            mstore(diff, sub(mload(diff), excess))
        }

        return diff;
    }

    /**
     * @dev calculates the index of each sibling index of the proof nodes
     * @dev proof nodes are the nodes that will be traversed to estimate the root hash
     * @param indices a list of proof nodes indices
     * @return uint256[] a list of sibling indices
     */
    function siblingIndices(
        uint256[] memory indices
    ) internal pure returns (uint256[] memory) {
        uint256 length = indices.length;
        uint256[] memory siblings = new uint256[](length);

        for (uint256 i; i < length; ) {
            uint256 index = indices[i];
            if (index == 0) {
                siblings[i] = index + 1;
            } else if (index % 2 == 0) {
                siblings[i] = index + 1;
            } else {
                siblings[i] = index - 1;
            }

            unchecked {
                ++i;
            }
        }

        return siblings;
    }

    /**
     * @notice Compute Parent Indices
     * @dev Used internally to calculate the indices of the parent nodes of the provided proof nodes
     * @param indices a list of indices of proof nodes in a merkle mountain
     * @return uint256[] a list of parent indices for each index provided
     */
    function parentIndices(
        uint256[] memory indices
    ) internal pure returns (uint256[] memory) {
        uint256 length = indices.length;
        uint256[] memory parents = new uint256[](length);
        uint256 k;

        for (uint256 i; i < length; i++) {
            uint256 index = indices[i] / 2;
            if (k > 0 && parents[k - 1] == index) {
                continue;
            }
            parents[k] = index;
            unchecked {
                ++k;
            }
        }

        // resize array?, sigh solidity.
        uint256 excess = length - k;

        assembly {
            mstore(parents, sub(mload(parents), excess))
        }

        return parents;
    }

    /**
     * @notice Convert Merkle mountain Leaf to a Merkle Node
     * @param leaves list of merkle mountain range leaf
     * @return A tuple with the list of merkle nodes and the list of nodes at 0 and 1 respectively
     */
    function mmrLeafToNode(
        MmrLeaf[] memory leaves
    ) internal pure returns (Node[] memory, uint256[] memory) {
        uint256 i;
        uint256 length = leaves.length;
        Node[] memory nodes = new Node[](length);
        uint256[] memory indices = new uint256[](length);
        while (i < length) {
            nodes[i] = Node(leaves[i].k_index, leaves[i].hash);
            indices[i] = leaves[i].k_index;
            ++i;
        }

        return (nodes, indices);
    }

    /**
     * @notice Get a mountain peak's leaves
     * @notice this splits the leaves into either side of the peak [left & right]
     * @param leaves a list of mountain merkle leaves, for a subtree
     * @param leafIndex the index of the leaf of the next subtree
     * @return A tuple of 2 arrays of mountain merkle leaves. Index 1 and 2 represent left and right of the peak respectively
     */
    function leavesForSubtree(
        MmrLeaf[] memory leaves,
        uint256 leafIndex
    ) internal pure returns (MmrLeaf[] memory, MmrLeaf[] memory) {
        uint256 p;
        uint256 length = leaves.length;
        for (; p < length; p++) {
            if (leafIndex <= leaves[p].leaf_index) {
                break;
            }
        }

        uint256 len = p == 0 ? 0 : p;
        MmrLeaf[] memory left = new MmrLeaf[](len);
        MmrLeaf[] memory right = new MmrLeaf[](length - len);

        uint256 i;
        uint256 leftLength = left.length;
        while (i < leftLength) {
            left[i] = leaves[i];
            ++i;
        }

        uint256 j;
        while (i < length) {
            right[j] = leaves[i];
            ++i;
            ++j;
        }

        return (left, right);
    }

    function push(Iterator memory iterator, bytes32 data) internal pure {
        iterator.data[iterator.offset] = data;
        unchecked {
            ++iterator.offset;
        }
    }

    function next(Iterator memory iterator) internal pure returns (bytes32) {
        bytes32 data = iterator.data[iterator.offset];
        unchecked {
            ++iterator.offset;
        }

        return data;
    }

    function previous(
        Iterator memory iterator
    ) internal pure returns (bytes32) {
        bytes32 data = iterator.data[iterator.offset];
        unchecked {
            --iterator.offset;
        }

        return data;
    }
}
// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "./Types.sol";

/**
 * @title A Merkle Multi proof library
 * @author Polytope Labs
 * @dev Use this library to verify merkle tree leaves using merkle multi proofs
 * @dev refer to research for more info. https://research.polytope.technology/merkle-multi-proofs
 */
library MerkleMultiProof {
    /**
     * @notice Verify a Merkle Multi Proof
     * @param root hash of the root node of the merkle tree
     * @param proof A list of the merkle nodes along with their k-indices that are needed to re-calculate root node.
     * @param leaves A list of the leaves along with their k-indices to prove
     * @return boolean if the calculated root matches the provides root node
     */
    function VerifyProof(
        bytes32 root,
        Node[][] memory proof,
        Node[] memory leaves
    ) internal pure returns (bool) {
        return root == CalculateRoot(proof, leaves);
    }

    /**
     * @notice Verify a Merkle Multi Proof whose internal nodes are sorted
     * @param root hash of the root node of the merkle tree
     * @param proof A list of the merkle nodes along with their k-indices that are needed to re-calculate root node.
     * @param leaves A list of the leaves along with their k-indices to prove
     * @return boolean if the calculated root matches the provides root node
     */
    function VerifyProofSorted(
        bytes32 root,
        Node[][] memory proof,
        Node[] memory leaves
    ) internal pure returns (bool) {
        return root == CalculateRootSorted(proof, leaves);
    }

    /// @notice Calculate the hash of the root node
    /// @dev Use this function to calculate the hash of the root node
    /// @param proof A list of the merkle nodes along with their k-indices that are needed to re-calculate root node.
    /// @param leaves A list of the leaves along with their k-indices to prove
    /// @return Hash of root node, value is a bytes32 type
    function CalculateRoot(
        Node[][] memory proof,
        Node[] memory leaves
    ) internal pure returns (bytes32) {
        // holds the output from hashing a previous layer
        Node[] memory next_layer = new Node[](0);

        // merge leaves
        proof[0] = mergeSort(leaves, proof[0]);

        uint256 proof_length = proof.length;
        for (uint256 height = 0; height < proof_length; height++) {
            Node[] memory current_layer = new Node[](0);

            if (next_layer.length == 0) {
                current_layer = proof[height];
            } else {
                current_layer = mergeSort(proof[height], next_layer);
            }

            next_layer = new Node[](div_ceil(current_layer.length, 2));

            uint256 p = 0;
            uint256 current_layer_length = current_layer.length;
            for (uint256 index = 0; index < current_layer_length; index += 2) {
                if (index + 1 >= current_layer_length) {
                    Node memory node = current_layer[index];
                    node.k_index = div_floor(current_layer[index].k_index, 2);
                    next_layer[p] = node;
                } else {
                    Node memory node;
                    node.k_index = div_floor(current_layer[index].k_index, 2);
                    node.node = _optimizedHash(
                        current_layer[index].node,
                        current_layer[index + 1].node
                    );
                    next_layer[p] = node;
                    unchecked {
                        p++;
                    }
                }
            }
        }

        // we should have arrived at the root node
        require(next_layer.length == 1);

        return next_layer[0].node;
    }

    /// @notice Calculate the hash of the root node using a sorted node approach.
    /// @dev Use this function to calculate the hash of the root node
    /// @param proof A list of the merkle nodes that are needed to re-calculate root node.
    /// @param leaves A list of the leaves to prove
    /// @return Hash of root node, value is a bytes32 type
    function CalculateRootSorted(
        Node[][] memory proof,
        Node[] memory leaves
    ) internal pure returns (bytes32) {
        // holds the output from hashing a previous layer
        Node[] memory next_layer = new Node[](0);

        // merge leaves
        proof[0] = mergeSort(leaves, proof[0]);

        uint256 proof_length = proof.length;
        for (uint256 height = 0; height < proof_length; height++) {
            Node[] memory current_layer = new Node[](0);

            if (next_layer.length == 0) {
                current_layer = proof[height];
            } else {
                current_layer = mergeSort(proof[height], next_layer);
            }
            uint256 current_layer_length = current_layer.length;
            uint256 p = 0;

            next_layer = new Node[](div_ceil(current_layer_length, 2));
            for (uint256 index = 0; index < current_layer_length; index += 2) {
                if (index + 1 >= current_layer_length) {
                    Node memory node = current_layer[index];
                    node.k_index = div_floor(current_layer[index].k_index, 2);
                    next_layer[p] = node;
                } else {
                    Node memory node;
                    bytes32 a = current_layer[index].node;
                    bytes32 b = current_layer[index + 1].node;
                    if (a < b) {
                        node.node = _optimizedHash(a, b);
                    } else {
                        node.node = _optimizedHash(b, a);
                    }
                    node.k_index = div_floor(current_layer[index].k_index, 2);
                    next_layer[p] = node;
                    unchecked {
                        p++;
                    }
                }
            }
        }

        // we should have arrived at the root node
        require(next_layer.length == 1);

        return next_layer[0].node;
    }

    function div_floor(uint256 x, uint256 y) internal pure returns (uint256) {
        return x / y;
    }

    function div_ceil(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 result = x / y;
        if (x % y != 0) {
            unchecked {
                result += 1;
            }
        }

        return result;
    }

    /// @notice an internal function to merge two arrays and sort them at the same time.
    /// @dev compares the k-index of each node and sort in increasing order
    /// @param arr1 leftmost index in arr
    /// @param arr2 highest index in arr
    function mergeSort(
        Node[] memory arr1,
        Node[] memory arr2
    ) internal pure returns (Node[] memory) {
        // merge the two arrays
        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;
        uint256 arr1_length = arr1.length;
        uint256 arr2_length = arr2.length;
        uint256 out_len = arr1_length + arr2_length;
        Node[] memory out = new Node[](out_len);

        while (i < arr1_length && j < arr2_length) {
            if (arr1[i].k_index < arr2[j].k_index) {
                out[k] = arr1[i];
                unchecked {
                    i++;
                    k++;
                }
            } else {
                out[k] = arr2[j];
                unchecked {
                    j++;
                    k++;
                }
            }
        }

        while (i < arr1_length) {
            out[k] = arr1[i];
            unchecked {
                i++;
                k++;
            }
        }

        while (j < arr2_length) {
            out[k] = arr2[j];
            unchecked {
                j++;
                k++;
            }
        }

        return out;
    }

    /// @notice compute the keccak256 hash of two nodes
    /// @param node1 hash of one of the two nodes
    /// @param node2 hash of the other of the two nodes
    function _optimizedHash(
        bytes32 node1,
        bytes32 node2
    ) internal pure returns (bytes32 hash) {
        assembly {
            // use EVM scratch space, its memory safe
            mstore(0x0, node1)
            mstore(0x20, node2)
            hash := keccak256(0x0, 0x40)
        }
    }

    /// @notice compute the height of the tree whose total number of leaves is given, it accounts for unbalanced trees.
    /// @param leavesCount number of leaves in the tree
    /// @return height of the tree
    function TreeHeight(uint256 leavesCount) internal pure returns (uint256) {
        uint256 height = Math.log2(leavesCount, Math.Rounding.Up);
        if (!isPowerOfTwo(leavesCount)) {
            unchecked {
                height++;
            }
        }

        return height;
    }

    function isPowerOfTwo(uint256 x) internal pure returns (bool) {
        if (x == 0) {
            return false;
        }

        return (x & (x - 1)) == 0;
    }
}
pragma solidity ^0.8.17;

import "./trie/Node.sol";
import "./trie/Option.sol";
import "./trie/NibbleSlice.sol";
import "./trie/TrieDB.sol";

import "./trie/substrate/SubstrateTrieDB.sol";
import "./trie/ethereum/EthereumTrieDB.sol";
import "./Types.sol";

// SPDX-License-Identifier: Apache2

/**
 * @title A Merkle Patricia library
 * @author Polytope Labs
 * @dev Use this library to verify merkle patricia proofs
 * @dev refer to research for more info. https://research.polytope.technology/state-(machine)-proofs
 */
library MerklePatricia {
    /**
     * @notice Verifies substrate specific merkle patricia proofs.
     * @param root hash of the merkle patricia trie
     * @param proof a list of proof nodes
     * @param keys a list of keys to verify
     * @return bytes[] a list of values corresponding to the supplied keys.
     */
    function VerifySubstrateProof(
        bytes32 root,
        bytes[] memory proof,
        bytes[] memory keys
    ) public pure returns (StorageValue[] memory) {
        StorageValue[] memory values = new StorageValue[](keys.length);
        TrieNode[] memory nodes = new TrieNode[](proof.length);

        for (uint256 i = 0; i < proof.length; i++) {
            nodes[i] = TrieNode(keccak256(proof[i]), proof[i]);
        }

        for (uint256 i = 0; i < keys.length; i++) {
            values[i].key = keys[i];
            NibbleSlice memory keyNibbles = NibbleSlice(keys[i], 0);
            NodeKind memory node = SubstrateTrieDB.decodeNodeKind(
                TrieDB.get(nodes, root)
            );

            // This loop is unbounded so that an adversary cannot insert a deeply nested key in the trie
            // and successfully convince us of it's non-existence, if we consume the block gas limit while
            // traversing the trie, then the transaction should revert.
            for (uint256 j = 1; j > 0; j++) {
                NodeHandle memory nextNode;

                if (TrieDB.isLeaf(node)) {
                    Leaf memory leaf = SubstrateTrieDB.decodeLeaf(node);
                    if (NibbleSliceOps.eq(leaf.key, keyNibbles)) {
                        values[i].value = TrieDB.load(nodes, leaf.value);
                    }
                    break;
                } else if (TrieDB.isNibbledBranch(node)) {
                    NibbledBranch memory nibbled = SubstrateTrieDB
                        .decodeNibbledBranch(node);
                    uint256 nibbledBranchKeyLength = NibbleSliceOps.len(
                        nibbled.key
                    );
                    if (!NibbleSliceOps.startsWith(keyNibbles, nibbled.key)) {
                        break;
                    }

                    if (
                        NibbleSliceOps.len(keyNibbles) == nibbledBranchKeyLength
                    ) {
                        if (Option.isSome(nibbled.value)) {
                            values[i].value = TrieDB.load(
                                nodes,
                                nibbled.value.value
                            );
                        }
                        break;
                    } else {
                        uint256 index = NibbleSliceOps.at(
                            keyNibbles,
                            nibbledBranchKeyLength
                        );
                        NodeHandleOption memory handle = nibbled.children[
                            index
                        ];
                        if (Option.isSome(handle)) {
                            keyNibbles = NibbleSliceOps.mid(
                                keyNibbles,
                                nibbledBranchKeyLength + 1
                            );
                            nextNode = handle.value;
                        } else {
                            break;
                        }
                    }
                } else if (TrieDB.isEmpty(node)) {
                    break;
                }

                node = SubstrateTrieDB.decodeNodeKind(
                    TrieDB.load(nodes, nextNode)
                );
            }
        }

        return values;
    }

    /**
     * @notice Verify child trie keys
     * @dev substrate specific method in order to verify keys in the child trie.
     * @param root hash of the merkle root
     * @param proof a list of proof nodes
     * @param keys a list of keys to verify
     * @param childInfo data that can be used to compute the root of the child trie
     * @return bytes[], a list of values corresponding to the supplied keys.
     */
    function ReadChildProofCheck(
        bytes32 root,
        bytes[] memory proof,
        bytes[] memory keys,
        bytes memory childInfo
    ) public pure returns (StorageValue[] memory) {
        // fetch the child trie root hash;
        bytes memory prefix = bytes(":child_storage:default:");
        bytes memory key = bytes.concat(prefix, childInfo);
        bytes[] memory _keys = new bytes[](1);
        _keys[0] = key;
        StorageValue[] memory values = VerifySubstrateProof(root, proof, _keys);

        bytes32 childRoot = bytes32(values[0].value);
        require(childRoot != bytes32(0), "Invalid child trie proof");

        return VerifySubstrateProof(childRoot, proof, keys);
    }

    /**
     * @notice Verifies ethereum specific merkle patricia proofs as described by EIP-1188.
     * @param root hash of the merkle patricia trie
     * @param proof a list of proof nodes
     * @param keys a list of keys to verify
     * @return bytes[] a list of values corresponding to the supplied keys.
     */
    function VerifyEthereumProof(
        bytes32 root,
        bytes[] memory proof,
        bytes[] memory keys
    ) public pure returns (StorageValue[] memory) {
        StorageValue[] memory values = new StorageValue[](keys.length);
        TrieNode[] memory nodes = new TrieNode[](proof.length);

        for (uint256 i = 0; i < proof.length; i++) {
            nodes[i] = TrieNode(keccak256(proof[i]), proof[i]);
        }

        for (uint256 i = 0; i < keys.length; i++) {
            values[i].key = keys[i];
            NibbleSlice memory keyNibbles = NibbleSlice(keys[i], 0);
            NodeKind memory node = EthereumTrieDB.decodeNodeKind(
                TrieDB.get(nodes, root)
            );

            // This loop is unbounded so that an adversary cannot insert a deeply nested key in the trie
            // and successfully convince us of it's non-existence, if we consume the block gas limit while
            // traversing the trie, then the transaction should revert.
            for (uint256 j = 1; j > 0; j++) {
                NodeHandle memory nextNode;

                if (TrieDB.isLeaf(node)) {
                    Leaf memory leaf = EthereumTrieDB.decodeLeaf(node);
                    // Let's retrieve the offset to be used
                    uint256 offset = keyNibbles.offset % 2 == 0
                        ? keyNibbles.offset / 2
                        : keyNibbles.offset / 2 + 1;
                    // Let's cut the key passed as input
                    keyNibbles = NibbleSlice(
                        NibbleSliceOps.bytesSlice(keyNibbles.data, offset),
                        0
                    );
                    if (NibbleSliceOps.eq(leaf.key, keyNibbles)) {
                        values[i].value = TrieDB.load(nodes, leaf.value);
                    }
                    break;
                } else if (TrieDB.isExtension(node)) {
                    Extension memory extension = EthereumTrieDB.decodeExtension(
                        node
                    );
                    if (NibbleSliceOps.startsWith(keyNibbles, extension.key)) {
                        // Let's cut the key passed as input
                        uint256 cutNibble = keyNibbles.offset +
                            NibbleSliceOps.len(extension.key);
                        keyNibbles = NibbleSlice(
                            NibbleSliceOps.bytesSlice(
                                keyNibbles.data,
                                cutNibble / 2
                            ),
                            cutNibble % 2
                        );
                        nextNode = extension.node;
                    } else {
                        break;
                    }
                } else if (TrieDB.isBranch(node)) {
                    Branch memory branch = EthereumTrieDB.decodeBranch(node);
                    if (NibbleSliceOps.isEmpty(keyNibbles)) {
                        if (Option.isSome(branch.value)) {
                            values[i].value = TrieDB.load(
                                nodes,
                                branch.value.value
                            );
                        }
                        break;
                    } else {
                        NodeHandleOption memory handle = branch.children[
                            NibbleSliceOps.at(keyNibbles, 0)
                        ];
                        if (Option.isSome(handle)) {
                            keyNibbles = NibbleSliceOps.mid(keyNibbles, 1);
                            nextNode = handle.value;
                        } else {
                            break;
                        }
                    }
                } else if (TrieDB.isEmpty(node)) {
                    break;
                }

                node = EthereumTrieDB.decodeNodeKind(
                    TrieDB.load(nodes, nextNode)
                );
            }
        }

        return values;
    }
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

// Outcome of a successfully verified merkle-patricia proof
struct StorageValue {
    // the storage key
    bytes key;
    // the encoded value
    bytes value;
}

/// @title A representation of a Merkle tree node
struct Node {
    // Distance of the node to the leftmost node
    uint256 k_index;
    // A hash of the node itself
    bytes32 node;
}

/// @title A representation of a MerkleMountainRange leaf
struct MmrLeaf {
    // the leftmost index of a node
    uint256 k_index;
    // The position in the tree
    uint256 leaf_index;
    // The hash of the position in the tree
    bytes32 hash;
}

struct Iterator {
    uint256 offset;
    bytes32[] data;
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

import {Memory} from "./Memory.sol";

struct ByteSlice {
    bytes data;
    uint256 offset;
}

library Bytes {
    uint256 internal constant BYTES_HEADER_SIZE = 32;

    // Checks if two `bytes memory` variables are equal. This is done using hashing,
    // which is much more gas efficient then comparing each byte individually.
    // Equality means that:
    //  - 'self.length == other.length'
    //  - For 'n' in '[0, self.length)', 'self[n] == other[n]'
    function equals(
        bytes memory self,
        bytes memory other
    ) internal pure returns (bool equal) {
        if (self.length != other.length) {
            return false;
        }
        uint256 addr;
        uint256 addr2;
        assembly {
            addr := add(self, /*BYTES_HEADER_SIZE*/ 32)
            addr2 := add(other, /*BYTES_HEADER_SIZE*/ 32)
        }
        equal = Memory.equals(addr, addr2, self.length);
    }

    function readByte(ByteSlice memory self) internal pure returns (uint8) {
        if (self.offset + 1 > self.data.length) {
            revert("Out of range");
        }

        uint8 b = uint8(self.data[self.offset]);
        self.offset += 1;

        return b;
    }

    // Copies 'len' bytes from 'self' into a new array, starting at the provided 'startIndex'.
    // Returns the new copy.
    // Requires that:
    //  - 'startIndex + len <= self.length'
    // The length of the substring is: 'len'
    function read(
        ByteSlice memory self,
        uint256 len
    ) internal pure returns (bytes memory) {
        require(self.offset + len <= self.data.length);
        if (len == 0) {
            return "";
        }
        uint256 addr = Memory.dataPtr(self.data);
        bytes memory slice = Memory.toBytes(addr + self.offset, len);
        self.offset += len;
        return slice;
    }

    // Copies a section of 'self' into a new array, starting at the provided 'startIndex'.
    // Returns the new copy.
    // Requires that 'startIndex <= self.length'
    // The length of the substring is: 'self.length - startIndex'
    function substr(
        bytes memory self,
        uint256 startIndex
    ) internal pure returns (bytes memory) {
        require(startIndex <= self.length);
        uint256 len = self.length - startIndex;
        uint256 addr = Memory.dataPtr(self);
        return Memory.toBytes(addr + startIndex, len);
    }

    // Copies 'len' bytes from 'self' into a new array, starting at the provided 'startIndex'.
    // Returns the new copy.
    // Requires that:
    //  - 'startIndex + len <= self.length'
    // The length of the substring is: 'len'
    function substr(
        bytes memory self,
        uint256 startIndex,
        uint256 len
    ) internal pure returns (bytes memory) {
        require(startIndex + len <= self.length);
        if (len == 0) {
            return "";
        }
        uint256 addr = Memory.dataPtr(self);
        return Memory.toBytes(addr + startIndex, len);
    }

    // Combines 'self' and 'other' into a single array.
    // Returns the concatenated arrays:
    //  [self[0], self[1], ... , self[self.length - 1], other[0], other[1], ... , other[other.length - 1]]
    // The length of the new array is 'self.length + other.length'
    function concat(
        bytes memory self,
        bytes memory other
    ) internal pure returns (bytes memory) {
        bytes memory ret = new bytes(self.length + other.length);
        uint256 src;
        uint256 srcLen;
        (src, srcLen) = Memory.fromBytes(self);
        uint256 src2;
        uint256 src2Len;
        (src2, src2Len) = Memory.fromBytes(other);
        uint256 dest;
        (dest, ) = Memory.fromBytes(ret);
        uint256 dest2 = dest + srcLen;
        Memory.copy(src, dest, srcLen);
        Memory.copy(src2, dest2, src2Len);
        return ret;
    }

    function toBytes32(bytes memory self) internal pure returns (bytes32 out) {
        require(self.length >= 32, "Bytes:: toBytes32: data is to short.");
        assembly {
            out := mload(add(self, 32))
        }
    }

    function toBytes16(
        bytes memory self,
        uint256 offset
    ) internal pure returns (bytes16 out) {
        for (uint256 i = 0; i < 16; i++) {
            out |= bytes16(bytes1(self[offset + i]) & 0xFF) >> (i * 8);
        }
    }

    function toBytes8(
        bytes memory self,
        uint256 offset
    ) internal pure returns (bytes8 out) {
        for (uint256 i = 0; i < 8; i++) {
            out |= bytes8(bytes1(self[offset + i]) & 0xFF) >> (i * 8);
        }
    }

    function toBytes4(
        bytes memory self,
        uint256 offset
    ) internal pure returns (bytes4) {
        bytes4 out;

        for (uint256 i = 0; i < 4; i++) {
            out |= bytes4(self[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toBytes2(
        bytes memory self,
        uint256 offset
    ) internal pure returns (bytes2) {
        bytes2 out;

        for (uint256 i = 0; i < 2; i++) {
            out |= bytes2(self[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function removeLeadingZero(
        bytes memory data
    ) internal pure returns (bytes memory) {
        uint256 length = data.length;

        uint256 startIndex = 0;
        for (uint256 i = 0; i < length; i++) {
            if (data[i] != 0) {
                startIndex = i;
                break;
            }
        }

        return substr(data, startIndex);
    }

    function removeEndingZero(
        bytes memory data
    ) internal pure returns (bytes memory) {
        uint256 length = data.length;

        uint256 endIndex = 0;
        for (uint256 i = length - 1; i >= 0; i--) {
            if (data[i] != 0) {
                endIndex = i;
                break;
            }
        }

        return substr(data, 0, endIndex + 1);
    }

    function reverse(
        bytes memory inbytes
    ) internal pure returns (bytes memory) {
        uint256 inlength = inbytes.length;
        bytes memory outbytes = new bytes(inlength);

        for (uint256 i = 0; i <= inlength - 1; i++) {
            outbytes[i] = inbytes[inlength - i - 1];
        }

        return outbytes;
    }
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

library Memory {
    uint256 internal constant WORD_SIZE = 32;

    // Compares the 'len' bytes starting at address 'addr' in memory with the 'len'
    // bytes starting at 'addr2'.
    // Returns 'true' if the bytes are the same, otherwise 'false'.
    function equals(
        uint256 addr,
        uint256 addr2,
        uint256 len
    ) internal pure returns (bool equal) {
        assembly {
            equal := eq(keccak256(addr, len), keccak256(addr2, len))
        }
    }

    // Compares the 'len' bytes starting at address 'addr' in memory with the bytes stored in
    // 'bts'. It is allowed to set 'len' to a lower value then 'bts.length', in which case only
    // the first 'len' bytes will be compared.
    // Requires that 'bts.length >= len'

    function equals(
        uint256 addr,
        uint256 len,
        bytes memory bts
    ) internal pure returns (bool equal) {
        require(bts.length >= len);
        uint256 addr2;
        assembly {
            addr2 := add(bts, /*BYTES_HEADER_SIZE*/ 32)
        }
        return equals(addr, addr2, len);
    }
    // Returns a memory pointer to the data portion of the provided bytes array.

    function dataPtr(bytes memory bts) internal pure returns (uint256 addr) {
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/ 32)
        }
    }

    // Creates a 'bytes memory' variable from the memory address 'addr', with the
    // length 'len'. The function will allocate new memory for the bytes array, and
    // the 'len bytes starting at 'addr' will be copied into that new memory.
    function toBytes(
        uint256 addr,
        uint256 len
    ) internal pure returns (bytes memory bts) {
        bts = new bytes(len);
        uint256 btsptr;
        assembly {
            btsptr := add(bts, /*BYTES_HEADER_SIZE*/ 32)
        }
        copy(addr, btsptr, len);
    }

    // Copies 'self' into a new 'bytes memory'.
    // Returns the newly created 'bytes memory'
    // The returned bytes will be of length '32'.
    function toBytes(bytes32 self) internal pure returns (bytes memory bts) {
        bts = new bytes(32);
        assembly {
            mstore(add(bts, /*BYTES_HEADER_SIZE*/ 32), self)
        }
    }

    // Copy 'len' bytes from memory address 'src', to address 'dest'.
    // This function does not check the or destination, it only copies
    // the bytes.
    function copy(uint256 src, uint256 dest, uint256 len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += WORD_SIZE;
            src += WORD_SIZE;
        }

        // Copy remaining bytes
        uint256 mask = len == 0
            ? 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            : 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    // This function does the same as 'dataPtr(bytes memory)', but will also return the
    // length of the provided bytes array.
    function fromBytes(
        bytes memory bts
    ) internal pure returns (uint256 addr, uint256 len) {
        len = bts.length;
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/ 32)
        }
    }
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

struct NibbleSlice {
    bytes data;
    uint256 offset;
}

library NibbleSliceOps {
    uint256 internal constant NIBBLE_PER_BYTE = 2;
    uint256 internal constant BITS_PER_NIBBLE = 4;

    function len(NibbleSlice memory nibble) internal pure returns (uint256) {
        return nibble.data.length * NIBBLE_PER_BYTE - nibble.offset;
    }

    function mid(
        NibbleSlice memory self,
        uint256 i
    ) internal pure returns (NibbleSlice memory) {
        return NibbleSlice(self.data, self.offset + i);
    }

    function isEmpty(NibbleSlice memory self) internal pure returns (bool) {
        return len(self) == 0;
    }

    function eq(
        NibbleSlice memory self,
        NibbleSlice memory other
    ) internal pure returns (bool) {
        return len(self) == len(other) && startsWith(self, other);
    }

    function at(
        NibbleSlice memory self,
        uint256 i
    ) internal pure returns (uint256) {
        uint256 ix = (self.offset + i) / NIBBLE_PER_BYTE;
        uint256 pad = (self.offset + i) % NIBBLE_PER_BYTE;
        uint8 data = uint8(self.data[ix]);
        return (pad == 1) ? data & 0x0F : data >> BITS_PER_NIBBLE;
    }

    function startsWith(
        NibbleSlice memory self,
        NibbleSlice memory other
    ) internal pure returns (bool) {
        return commonPrefix(self, other) == len(other);
    }

    function commonPrefix(
        NibbleSlice memory self,
        NibbleSlice memory other
    ) internal pure returns (uint256) {
        uint256 self_align = self.offset % NIBBLE_PER_BYTE;
        uint256 other_align = other.offset % NIBBLE_PER_BYTE;

        if (self_align == other_align) {
            uint256 self_start = self.offset / NIBBLE_PER_BYTE;
            uint256 other_start = other.offset / NIBBLE_PER_BYTE;
            uint256 first = 0;

            if (self_align != 0) {
                if (
                    (self.data[self_start] & 0x0F) !=
                    (other.data[other_start] & 0x0F)
                ) {
                    return 0;
                }
                ++self_start;
                ++other_start;
                ++first;
            }
            bytes memory selfSlice = bytesSlice(self.data, self_start);
            bytes memory otherSlice = bytesSlice(other.data, other_start);
            return biggestDepth(selfSlice, otherSlice) + first;
        } else {
            uint256 s = min(len(self), len(other));
            uint256 i = 0;
            while (i < s) {
                if (at(self, i) != at(other, i)) {
                    break;
                }
                ++i;
            }
            return i;
        }
    }

    function biggestDepth(
        bytes memory a,
        bytes memory b
    ) internal pure returns (uint256) {
        uint256 upperBound = min(a.length, b.length);
        uint256 i = 0;
        while (i < upperBound) {
            if (a[i] != b[i]) {
                return i * NIBBLE_PER_BYTE + leftCommon(a[i], b[i]);
            }
            ++i;
        }
        return i * NIBBLE_PER_BYTE;
    }

    function leftCommon(bytes1 a, bytes1 b) internal pure returns (uint256) {
        if (a == b) {
            return 2;
        } else if (uint8(a) & 0xF0 == uint8(b) & 0xF0) {
            return 1;
        } else {
            return 0;
        }
    }

    function bytesSlice(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (bytes memory) {
        uint256 bytesLength = _bytes.length;
        uint256 _length = bytesLength - _start;
        require(bytesLength >= _start, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40) // load free memory pointer
                let lengthmod := and(_length, 31)

                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }
        return tempBytes;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a < b) ? a : b;
    }
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

import "./NibbleSlice.sol";
import "./Bytes.sol";

/// This is an enum for the different node types.
struct NodeKind {
    bool isEmpty;
    bool isLeaf;
    bool isHashedLeaf;
    bool isNibbledValueBranch;
    bool isNibbledHashedValueBranch;
    bool isNibbledBranch;
    bool isExtension;
    bool isBranch;
    uint256 nibbleSize;
    ByteSlice data;
}

struct NodeHandle {
    bool isHash;
    bytes32 hash;
    bool isInline;
    bytes inLine;
}

struct Extension {
    NibbleSlice key;
    NodeHandle node;
}

struct Branch {
    NodeHandleOption value;
    NodeHandleOption[16] children;
}

struct NibbledBranch {
    NibbleSlice key;
    NodeHandleOption value;
    NodeHandleOption[16] children;
}

struct ValueOption {
    bool isSome;
    bytes value;
}

struct NodeHandleOption {
    bool isSome;
    NodeHandle value;
}

struct Leaf {
    NibbleSlice key;
    NodeHandle value;
}

struct TrieNode {
    bytes32 hash;
    bytes node;
}
pragma solidity ^0.8.17;

import "./Node.sol";

// SPDX-License-Identifier: Apache2

library Option {
    function isSome(ValueOption memory val) internal pure returns (bool) {
        return val.isSome == true;
    }

    function isSome(NodeHandleOption memory val) internal pure returns (bool) {
        return val.isSome == true;
    }
}
// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.17;

import "./Node.sol";

library TrieDB {
    function get(
        TrieNode[] memory nodes,
        bytes32 hash
    ) internal pure returns (bytes memory) {
        for (uint256 i = 0; i < nodes.length; i++) {
            if (nodes[i].hash == hash) {
                return nodes[i].node;
            }
        }
        revert("Incomplete Proof!");
    }

    function load(
        TrieNode[] memory nodes,
        NodeHandle memory node
    ) internal pure returns (bytes memory) {
        if (node.isInline) {
            return node.inLine;
        } else if (node.isHash) {
            return get(nodes, node.hash);
        }

        return bytes("");
    }

    function isNibbledBranch(
        NodeKind memory node
    ) internal pure returns (bool) {
        return (node.isNibbledBranch ||
            node.isNibbledHashedValueBranch ||
            node.isNibbledValueBranch);
    }

    function isExtension(NodeKind memory node) internal pure returns (bool) {
        return node.isExtension;
    }

    function isBranch(NodeKind memory node) internal pure returns (bool) {
        return node.isBranch;
    }

    function isLeaf(NodeKind memory node) internal pure returns (bool) {
        return (node.isLeaf || node.isHashedLeaf);
    }

    function isEmpty(NodeKind memory node) internal pure returns (bool) {
        return node.isEmpty;
    }

    function isHash(NodeHandle memory node) internal pure returns (bool) {
        return node.isHash;
    }

    function isInline(NodeHandle memory node) internal pure returns (bool) {
        return node.isInline;
    }
}
pragma solidity ^0.8.17;

import "../Node.sol";
import "../Bytes.sol";
import {NibbleSliceOps} from "../NibbleSlice.sol";
import "./RLPReader.sol";

// SPDX-License-Identifier: Apache2

library EthereumTrieDB {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;

    bytes constant HASHED_NULL_NODE =
        hex"56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421";

    function decodeNodeKind(
        bytes memory encoded
    ) external pure returns (NodeKind memory) {
        NodeKind memory node;
        ByteSlice memory input = ByteSlice(encoded, 0);
        if (Bytes.equals(encoded, HASHED_NULL_NODE)) {
            node.isEmpty = true;
            return node;
        }
        RLPReader.RLPItem[] memory itemList = encoded.toRlpItem().toList();
        uint256 numItems = itemList.length;
        if (numItems == 0) {
            node.isEmpty = true;
            return node;
        } else if (numItems == 2) {
            //It may be a leaf or extension
            bytes memory key = itemList[0].toBytes();
            uint256 prefix;
            assembly {
                let first := shr(248, mload(add(key, 32)))
                prefix := shr(4, first)
            }
            if (prefix == 2 || prefix == 3) {
                node.isLeaf = true;
            } else {
                node.isExtension = true;
            }
        } else if (numItems == 17) {
            node.isBranch = true;
        } else {
            revert("Invalid data");
        }
        node.data = input;
        return node;
    }

    function decodeLeaf(
        NodeKind memory node
    ) external pure returns (Leaf memory) {
        Leaf memory leaf;
        RLPReader.RLPItem[] memory decoded = node
            .data
            .data
            .toRlpItem()
            .toList();
        bytes memory data = decoded[1].toBytes();
        //Remove the first byte, which is the prefix and not present in the user provided key
        leaf.key = NibbleSlice(Bytes.substr(decoded[0].toBytes(), 1), 0);
        leaf.value = NodeHandle(false, bytes32(0), true, data);

        return leaf;
    }

    function decodeExtension(
        NodeKind memory node
    ) external pure returns (Extension memory) {
        Extension memory extension;
        RLPReader.RLPItem[] memory decoded = node
            .data
            .data
            .toRlpItem()
            .toList();
        bytes memory data = decoded[1].toBytes();
        uint8 isOdd = uint8(decoded[0].toBytes()[0] >> 4) & 0x01;
        //Remove the first byte, which is the prefix and not present in the user provided key
        extension.key = NibbleSlice(
            Bytes.substr(decoded[0].toBytes(), (isOdd + 1) % 2),
            isOdd
        );
        extension.node = NodeHandle(
            true,
            Bytes.toBytes32(data),
            false,
            new bytes(0)
        );
        return extension;
    }

    function decodeBranch(
        NodeKind memory node
    ) external pure returns (Branch memory) {
        Branch memory branch;
        RLPReader.RLPItem[] memory decoded = node
            .data
            .data
            .toRlpItem()
            .toList();

        NodeHandleOption[16] memory childrens;

        for (uint256 i = 0; i < 16; i++) {
            bytes memory dataAsBytes = decoded[i].toBytes();
            if (dataAsBytes.length != 32) {
                childrens[i] = NodeHandleOption(
                    false,
                    NodeHandle(false, bytes32(0), false, new bytes(0))
                );
            } else {
                bytes32 data = Bytes.toBytes32(dataAsBytes);
                childrens[i] = NodeHandleOption(
                    true,
                    NodeHandle(true, data, false, new bytes(0))
                );
            }
        }
        if (isEmpty(decoded[16].toBytes())) {
            branch.value = NodeHandleOption(
                false,
                NodeHandle(false, bytes32(0), false, new bytes(0))
            );
        } else {
            branch.value = NodeHandleOption(
                true,
                NodeHandle(false, bytes32(0), true, decoded[16].toBytes())
            );
        }
        branch.children = childrens;

        return branch;
    }

    function isEmpty(bytes memory item) internal pure returns (bool) {
        return item.length > 0 && (item[0] == 0xc0 || item[0] == 0x80);
    }
}
// SPDX-License-Identifier: Apache-2.0

/*
 * @author Hamdi Allam hamdi.allam97@gmail.com
 * Please reach out with any questions or concerns
 */
pragma solidity >=0.5.10 <0.9.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param the RLP item.
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    /*
     * @param the RLP item.
     * @return (memPtr, len) pair: location of the item's payload in memory.
     */
    function payloadLocation(RLPItem memory item) internal pure returns (uint256, uint256) {
        uint256 offset = _payloadOffset(item.memPtr);
        uint256 memPtr = item.memPtr + offset;
        uint256 len = item.len - offset; // data length
        return (memPtr, len);
    }

    /*
     * @param the RLP item.
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        (, uint256 len) = payloadLocation(item);
        return len;
    }

    /*
     * @param the RLP item containing the encoded list.
     */
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /*
     * @dev A cheaper version of keccak256(toRlpBytes(item)) that avoids copying memory.
     * @return keccak256 hash of RLP encoded bytes.
     */
    function rlpBytesKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    /*
     * @dev A cheaper version of keccak256(toBytes(item)) that avoids copying memory.
     * @return keccak256 hash of the item payload.
     */
    function payloadKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }

    /**
     * RLPItem conversions into data types *
     */

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte except "0x80" is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        // SEE Github Issue #5.
        // Summary: Most commonly used RLP libraries (i.e Geth) will encode
        // "0" as "0x80" instead of as "0". We handle this edge case explicitly
        // here.
        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21);

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33);

        (uint256 memPtr, uint256 len) = payloadLocation(item);

        uint256 result;
        assembly {
            result := mload(memPtr)

            // shift to the correct location if neccesary
            if lt(len, 32) { result := div(result, exp(256, sub(32, len))) }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        // one byte prefix
        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(memPtr, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) {
            itemLen = 1;
        } else if (byte0 < STRING_LONG_START) {
            itemLen = byte0 - STRING_SHORT_START + 1;
        } else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) {
            return 0;
        } else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) {
            return 1;
        } else if (byte0 < LIST_SHORT_START) {
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        } else {
            return byte0 - (LIST_LONG_START - 1) + 1;
        }
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(uint256 src, uint256 dest, uint256 len) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        if (len > 0) {
            // left over bytes. Mask is used to remove unwanted bytes from the word
            uint256 mask = 256 ** (WORD_SIZE - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask)) // zero out src
                let destpart := and(mload(dest), mask) // retrieve the bytes
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}
pragma solidity ^0.8.17;

// SPDX-License-Identifier: Apache2

import {Bytes, ByteSlice} from "../Bytes.sol";

library ScaleCodec {
    // Decodes a SCALE encoded uint256 by converting bytes (bid endian) to little endian format
    function decodeUint256(bytes memory data) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = data.length; i > 0; i--) {
            number =
                number +
                uint256(uint8(data[i - 1])) *
                (2 ** (8 * (i - 1)));
        }
        return number;
    }

    // Decodes a SCALE encoded compact unsigned integer
    function decodeUintCompact(
        ByteSlice memory data
    ) internal pure returns (uint256 v) {
        uint8 b = Bytes.readByte(data); // read the first byte
        uint8 mode = b % 4; // bitwise operation

        uint256 value;
        if (mode == 0) {
            // [0, 63]
            value = b >> 2; // right shift to remove mode bits
        } else if (mode == 1) {
            // [64, 16383]
            uint8 bb = Bytes.readByte(data); // read the second byte
            uint64 r = bb; // convert to uint64
            r <<= 6; // multiply by * 2^6
            r += b >> 2; // right shift to remove mode bits
            value = r;
        } else if (mode == 2) {
            // [16384, 1073741823]
            uint8 b2 = Bytes.readByte(data); // read the next 3 bytes
            uint8 b3 = Bytes.readByte(data);
            uint8 b4 = Bytes.readByte(data);

            uint32 x1 = uint32(b) | (uint32(b2) << 8); // convert to little endian
            uint32 x2 = x1 | (uint32(b3) << 16);
            uint32 x3 = x2 | (uint32(b4) << 24);

            x3 >>= 2; // remove the last 2 mode bits
            value = uint256(x3);
        } else if (mode == 3) {
            // [1073741824, 4503599627370496]
            uint8 l = (b >> 2) + 4; // remove mode bits
            require(l <= 8, "unexpected prefix decoding Compact<Uint>");
            return decodeUint256(Bytes.read(data, l));
        } else {
            revert("Code should be unreachable");
        }
        return value;
    }

    // Decodes a SCALE encoded compact unsigned integer
    function decodeUintCompact(
        bytes memory data
    ) internal pure returns (uint256 v, uint8 m) {
        uint8 b = readByteAtIndex(data, 0); // read the first byte
        uint8 mode = b & 3; // bitwise operation

        uint256 value;
        if (mode == 0) {
            // [0, 63]
            value = b >> 2; // right shift to remove mode bits
        } else if (mode == 1) {
            // [64, 16383]
            uint8 bb = readByteAtIndex(data, 1); // read the second byte
            uint64 r = bb; // convert to uint64
            r <<= 6; // multiply by * 2^6
            r += b >> 2; // right shift to remove mode bits
            value = r;
        } else if (mode == 2) {
            // [16384, 1073741823]
            uint8 b2 = readByteAtIndex(data, 1); // read the next 3 bytes
            uint8 b3 = readByteAtIndex(data, 2);
            uint8 b4 = readByteAtIndex(data, 3);

            uint32 x1 = uint32(b) | (uint32(b2) << 8); // convert to little endian
            uint32 x2 = x1 | (uint32(b3) << 16);
            uint32 x3 = x2 | (uint32(b4) << 24);

            x3 >>= 2; // remove the last 2 mode bits
            value = uint256(x3);
        } else if (mode == 3) {
            // [1073741824, 4503599627370496]
            uint8 l = b >> 2; // remove mode bits
            require(
                l > 32,
                "Not supported: number cannot be greater than 32 bytes"
            );
        } else {
            revert("Code should be unreachable");
        }
        return (value, mode);
    }

    // The biggest compact supported uint is 2 ** 536 - 1.
    // But the biggest value supported by this method is 2 ** 256 - 1(max of uint256)
    function encodeUintCompact(uint256 v) internal pure returns (bytes memory) {
        if (v < 64) {
            return abi.encodePacked(uint8(v << 2));
        } else if (v < 2 ** 14) {
            return abi.encodePacked(reverse16(uint16(((v << 2) + 1))));
        } else if (v < 2 ** 30) {
            return abi.encodePacked(reverse32(uint32(((v << 2) + 2))));
        } else {
            bytes memory valueBytes = Bytes.removeEndingZero(
                abi.encodePacked(reverse256(v))
            );

            uint256 length = valueBytes.length;
            uint8 prefix = uint8(((length - 4) << 2) + 3);

            return abi.encodePacked(prefix, valueBytes);
        }
    }

    // Read a byte at a specific index and return it as type uint8
    function readByteAtIndex(
        bytes memory data,
        uint8 index
    ) internal pure returns (uint8) {
        return uint8(data[index]);
    }

    // Sources:
    //   * https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity/50528
    //   * https://graphics.stanford.edu/~seander/bithacks.html#ReverseParallel

    function reverse256(uint256 input) internal pure returns (uint256 v) {
        v = input;

        // swap bytes
        v =
            ((v &
                0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >>
                8) |
            ((v &
                0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) <<
                8);

        // swap 2-byte long pairs
        v =
            ((v &
                0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >>
                16) |
            ((v &
                0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) <<
                16);

        // swap 4-byte long pairs
        v =
            ((v &
                0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >>
                32) |
            ((v &
                0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) <<
                32);

        // swap 8-byte long pairs
        v =
            ((v &
                0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >>
                64) |
            ((v &
                0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) <<
                64);

        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }

    function reverse128(uint128 input) internal pure returns (uint128 v) {
        v = input;

        // swap bytes
        v =
            ((v & 0xFF00FF00FF00FF00FF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v =
            ((v & 0xFFFF0000FFFF0000FFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v =
            ((v & 0xFFFFFFFF00000000FFFFFFFF00000000) >> 32) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF) << 32);

        // swap 8-byte long pairs
        v = (v >> 64) | (v << 64);
    }

    function reverse64(uint64 input) internal pure returns (uint64 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00) >> 8) | ((v & 0x00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000) >> 16) | ((v & 0x0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = (v >> 32) | (v << 32);
    }

    function reverse32(uint32 input) internal pure returns (uint32 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00) >> 8) | ((v & 0x00FF00FF) << 8);

        // swap 2-byte long pairs
        v = (v >> 16) | (v << 16);
    }

    function reverse16(uint16 input) internal pure returns (uint16 v) {
        v = input;

        // swap bytes
        v = (v >> 8) | (v << 8);
    }

    function encode256(uint256 input) internal pure returns (bytes32) {
        return bytes32(reverse256(input));
    }

    function encode128(uint128 input) internal pure returns (bytes16) {
        return bytes16(reverse128(input));
    }

    function encode64(uint64 input) internal pure returns (bytes8) {
        return bytes8(reverse64(input));
    }

    function encode32(uint32 input) internal pure returns (bytes4) {
        return bytes4(reverse32(input));
    }

    function encode16(uint16 input) internal pure returns (bytes2) {
        return bytes2(reverse16(input));
    }

    function encodeBytes(
        bytes memory input
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(encodeUintCompact(input.length), input);
    }
}
pragma solidity ^0.8.17;

import "../Node.sol";
import "../Bytes.sol";
import {NibbleSliceOps} from "../NibbleSlice.sol";

import {ScaleCodec} from "./ScaleCodec.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// SPDX-License-Identifier: Apache2

library SubstrateTrieDB {
    uint8 public constant FIRST_PREFIX = 0x00 << 6;
    uint8 public constant PADDING_BITMASK = 0x0F;
    uint8 public constant EMPTY_TRIE = FIRST_PREFIX | (0x00 << 4);
    uint8 public constant LEAF_PREFIX_MASK = 0x01 << 6;
    uint8 public constant BRANCH_WITH_MASK = 0x03 << 6;
    uint8 public constant BRANCH_WITHOUT_MASK = 0x02 << 6;
    uint8 public constant ALT_HASHING_LEAF_PREFIX_MASK =
        FIRST_PREFIX | (0x01 << 5);
    uint8 public constant ALT_HASHING_BRANCH_WITH_MASK =
        FIRST_PREFIX | (0x01 << 4);
    uint8 public constant NIBBLE_PER_BYTE = 2;
    uint256 public constant NIBBLE_SIZE_BOUND = uint256(type(uint16).max);
    uint256 public constant BITMAP_LENGTH = 2;
    uint256 public constant HASH_lENGTH = 32;

    function decodeNodeKind(
        bytes memory encoded
    ) internal pure returns (NodeKind memory) {
        NodeKind memory node;
        ByteSlice memory input = ByteSlice(encoded, 0);
        uint8 i = Bytes.readByte(input);

        if (i == EMPTY_TRIE) {
            node.isEmpty = true;
            return node;
        }

        uint8 mask = i & (0x03 << 6);

        if (mask == LEAF_PREFIX_MASK) {
            node.nibbleSize = decodeSize(i, input, 2);
            node.isLeaf = true;
        } else if (mask == BRANCH_WITH_MASK) {
            node.nibbleSize = decodeSize(i, input, 2);
            node.isNibbledValueBranch = true;
        } else if (mask == BRANCH_WITHOUT_MASK) {
            node.nibbleSize = decodeSize(i, input, 2);
            node.isNibbledBranch = true;
        } else if (mask == EMPTY_TRIE) {
            if (i & (0x07 << 5) == ALT_HASHING_LEAF_PREFIX_MASK) {
                node.nibbleSize = decodeSize(i, input, 3);
                node.isHashedLeaf = true;
            } else if (i & (0x0F << 4) == ALT_HASHING_BRANCH_WITH_MASK) {
                node.nibbleSize = decodeSize(i, input, 4);
                node.isNibbledHashedValueBranch = true;
            } else {
                // do not allow any special encoding
                revert("Unallowed encoding");
            }
        }
        node.data = input;

        return node;
    }

    function decodeNibbledBranch(
        NodeKind memory node
    ) internal pure returns (NibbledBranch memory) {
        NibbledBranch memory nibbledBranch;
        ByteSlice memory input = node.data;

        bool padding = node.nibbleSize % NIBBLE_PER_BYTE != 0;
        if (padding && (padLeft(uint8(input.data[input.offset])) != 0)) {
            revert("Bad Format!");
        }
        uint256 nibbleLen = ((node.nibbleSize +
            (NibbleSliceOps.NIBBLE_PER_BYTE - 1)) /
            NibbleSliceOps.NIBBLE_PER_BYTE);
        nibbledBranch.key = NibbleSlice(
            Bytes.read(input, nibbleLen),
            node.nibbleSize % NIBBLE_PER_BYTE
        );

        bytes memory bitmapBytes = Bytes.read(input, BITMAP_LENGTH);
        uint16 bitmap = uint16(ScaleCodec.decodeUint256(bitmapBytes));

        NodeHandleOption memory valueHandle;
        if (node.isNibbledHashedValueBranch) {
            valueHandle.isSome = true;
            valueHandle.value.isHash = true;
            valueHandle.value.hash = Bytes.toBytes32(
                Bytes.read(input, HASH_lENGTH)
            );
        } else if (node.isNibbledValueBranch) {
            uint256 len = ScaleCodec.decodeUintCompact(input);
            valueHandle.isSome = true;
            valueHandle.value.isInline = true;
            valueHandle.value.inLine = Bytes.read(input, len);
        }
        nibbledBranch.value = valueHandle;

        for (uint256 i = 0; i < 16; i++) {
            NodeHandleOption memory childHandle;
            if (valueAt(bitmap, i)) {
                childHandle.isSome = true;
                uint256 len = ScaleCodec.decodeUintCompact(input);
                //                revert(string.concat("node index: ", Strings.toString(len)));
                if (len == HASH_lENGTH) {
                    childHandle.value.isHash = true;
                    childHandle.value.hash = Bytes.toBytes32(
                        Bytes.read(input, HASH_lENGTH)
                    );
                } else {
                    childHandle.value.isInline = true;
                    childHandle.value.inLine = Bytes.read(input, len);
                }
            }
            nibbledBranch.children[i] = childHandle;
        }

        return nibbledBranch;
    }

    function decodeLeaf(
        NodeKind memory node
    ) internal pure returns (Leaf memory) {
        Leaf memory leaf;
        ByteSlice memory input = node.data;

        bool padding = node.nibbleSize % NIBBLE_PER_BYTE != 0;
        if (padding && padLeft(uint8(input.data[input.offset])) != 0) {
            revert("Bad Format!");
        }
        uint256 nibbleLen = (node.nibbleSize +
            (NibbleSliceOps.NIBBLE_PER_BYTE - 1)) /
            NibbleSliceOps.NIBBLE_PER_BYTE;
        bytes memory nibbleBytes = Bytes.read(input, nibbleLen);
        leaf.key = NibbleSlice(nibbleBytes, node.nibbleSize % NIBBLE_PER_BYTE);

        NodeHandle memory handle;
        if (node.isHashedLeaf) {
            handle.isHash = true;
            handle.hash = Bytes.toBytes32(Bytes.read(input, HASH_lENGTH));
        } else {
            uint256 len = ScaleCodec.decodeUintCompact(input);
            handle.isInline = true;
            handle.inLine = Bytes.read(input, len);
        }
        leaf.value = handle;

        return leaf;
    }

    function decodeSize(
        uint8 first,
        ByteSlice memory encoded,
        uint8 prefixMask
    ) internal pure returns (uint256) {
        uint8 maxValue = uint8(255 >> prefixMask);
        uint256 result = uint256(first & maxValue);

        if (result < maxValue) {
            return result;
        }

        result -= 1;

        while (result <= NIBBLE_SIZE_BOUND) {
            uint256 n = uint256(Bytes.readByte(encoded));
            if (n < 255) {
                return result + n + 1;
            }
            result += 255;
        }

        return NIBBLE_SIZE_BOUND;
    }

    function padLeft(uint8 b) internal pure returns (uint8) {
        return b & ~PADDING_BITMASK;
    }

    function valueAt(uint16 bitmap, uint256 i) internal pure returns (bool) {
        return bitmap & (uint16(1) << uint16(i)) != 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// Copyright (C) Polytope Labs Ltd.
// SPDX-License-Identifier: Apache-2.0

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
pragma solidity ^0.8.17;

import {MerkleMountainRange, MmrLeaf} from "@polytope-labs/solidity-merkle-trees/src/MerkleMountainRange.sol";
import {MerklePatricia, StorageValue} from "@polytope-labs/solidity-merkle-trees/src/MerklePatricia.sol";
import {Bytes} from "@polytope-labs/solidity-merkle-trees/src/trie/Bytes.sol";

import {IConsensusClient, IntermediateState, StateMachineHeight, StateCommitment} from "@polytope-labs/ismp-solidity/IConsensusClient.sol";
import {IIsmpHost, FeeMetadata, FrozenStatus} from "@polytope-labs/ismp-solidity/IIsmpHost.sol";
import {IHandler} from "@polytope-labs/ismp-solidity/IHandler.sol";
import {
    Message,
    PostResponse,
    PostRequest,
    GetRequest,
    GetResponse,
    PostRequestMessage,
    PostResponseMessage,
    GetResponseMessage,
    PostRequestTimeoutMessage,
    PostResponseTimeoutMessage,
    GetTimeoutMessage,
    PostRequestLeaf,
    PostResponseLeaf,
    GetResponseLeaf
} from "@polytope-labs/ismp-solidity/Message.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// Storage prefix for request receipts in the pallet-ismp child trie
bytes constant REQUEST_RECEIPTS_STORAGE_PREFIX = hex"526571756573745265636569707473";

// Storage prefix for response receipts in the pallet-ismp child trie
bytes constant RESPONSE_RECEIPTS_STORAGE_PREFIX = hex"526573706f6e73655265636569707473";

/**
 * @title The ISMP Message Handler.
 * @author Polytope Labs (hello@polytope.technology)
 *
 * @notice The Handler is responsible for verifying the cryptographic proofs needed
 * to confirm the validity of incoming requests/responses.
 * Refer to the official ISMP specification. https://docs.hyperbridge.network/protocol/ismp
 */
contract HandlerV1 is IHandler, ERC165, Context {
    using Bytes for bytes;
    using Message for PostResponse;
    using Message for PostRequest;
    using Message for GetRequest;
    using Message for GetResponse;

    // The cosensus client has now expired to mitigate
    // long fork attacks, this is unrecoverable.
    error ConsensusClientExpired();

    // The IsmpHost has been frozen by the admin
    error HostFrozen();

    // Challenge period has not yet elapsed
    error ChallengePeriodNotElapsed();

    // The requested state commitment does not exist
    error StateCommitmentNotFound();

    // The message destination is not intended for this host
    error InvalidMessageDestination();

    // The provided message has now timed-out
    error MessageTimedOut();

    // The provided message has not timed-out
    error MessageNotTimedOut();

    // The message has been previously processed
    error DuplicateMessage();

    // The provided message is unknown to the host
    error UnknownMessage();

    // The provided proof is invalid
    error InvalidProof();

    /**
     * @dev Checks if the host permits incoming datagrams
     */
    modifier notFrozen(IIsmpHost host) {
        FrozenStatus state = host.frozen();
        if (state == FrozenStatus.Incoming || state == FrozenStatus.All) revert HostFrozen();
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IHandler).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Handle incoming consensus messages. These message are accompanied with some cryptographic proof.
     * If the Host's internal consensus client verifies this proof successfully,
     * The `StateCommitment` enters the preconfigured challenge period.
     * @param host - `IsmpHost`
     * @param proof - consensus proof
     */
    function handleConsensus(IIsmpHost host, bytes calldata proof) external notFrozen(host) {
        uint256 delay = block.timestamp - host.consensusUpdateTime();

        if (delay >= host.unStakingPeriod()) revert ConsensusClientExpired();

        (bytes memory verifiedState, IntermediateState[] memory intermediates) = IConsensusClient(
            host.consensusClient()
        ).verifyConsensus(host.consensusState(), proof);
        host.storeConsensusState(verifiedState);

        uint256 intermediatesLen = intermediates.length;
        for (uint256 i = 0; i < intermediatesLen; i++) {
            IntermediateState memory intermediate = intermediates[i];
            // check that we know this state machine and it's a new update
            uint256 latestHeight = host.latestStateMachineHeight(intermediate.stateMachineId);
            if (latestHeight != 0 && intermediate.height > latestHeight) {
                StateMachineHeight memory stateMachineHeight = StateMachineHeight({
                    stateMachineId: intermediate.stateMachineId,
                    height: intermediate.height
                });
                host.storeStateMachineCommitment(stateMachineHeight, intermediate.commitment);
            }
        }
    }

    /**
     * @dev Checks the provided requests and their proofs, before dispatching them to their relevant destination modules
     * @param host - `IsmpHost`
     * @param request - batch post requests
     */
    function handlePostRequests(IIsmpHost host, PostRequestMessage calldata request) external notFrozen(host) {
        uint256 timestamp = block.timestamp;
        uint256 delay = timestamp - host.stateMachineCommitmentUpdateTime(request.proof.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        uint256 requestsLen = request.requests.length;
        MmrLeaf[] memory leaves = new MmrLeaf[](requestsLen);

        for (uint256 i = 0; i < requestsLen; ++i) {
            PostRequestLeaf memory leaf = request.requests[i];
            // check destination
            if (!leaf.request.dest.equals(host.host())) revert InvalidMessageDestination();
            // check time-out
            if (timestamp >= leaf.request.timeout()) revert MessageTimedOut();
            // duplicate request?
            bytes32 commitment = leaf.request.hash();
            if (host.requestReceipts(commitment) != address(0)) revert DuplicateMessage();

            leaves[i] = MmrLeaf(leaf.kIndex, leaf.index, commitment);
        }

        bytes32 root = host.stateMachineCommitment(request.proof.height).overlayRoot;
        if (root == bytes32(0)) revert StateCommitmentNotFound();
        bool valid = MerkleMountainRange.VerifyProof(root, request.proof.multiproof, leaves, request.proof.leafCount);
        if (!valid) revert InvalidProof();

        for (uint256 i = 0; i < requestsLen; ++i) {
            PostRequestLeaf memory leaf = request.requests[i];
            host.dispatchIncoming(leaf.request, _msgSender());
        }
    }

    /**
     * @dev Checks the provided responses and their proofs, before dispatching them to their relevant destination modules
     * @param host - `IsmpHost`
     * @param response - batch post responses
     */
    function handlePostResponses(IIsmpHost host, PostResponseMessage calldata response) external notFrozen(host) {
        uint256 timestamp = block.timestamp;
        uint256 delay = timestamp - host.stateMachineCommitmentUpdateTime(response.proof.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        uint256 responsesLength = response.responses.length;
        MmrLeaf[] memory leaves = new MmrLeaf[](responsesLength);

        for (uint256 i = 0; i < responsesLength; ++i) {
            PostResponseLeaf memory leaf = response.responses[i];
            // check time-out
            if (timestamp >= leaf.response.timeout()) revert MessageTimedOut();

            // known request? also serves as a source check
            bytes32 requestCommitment = leaf.response.request.hash();
            FeeMetadata memory meta = host.requestCommitments(requestCommitment);
            if (meta.sender == address(0)) revert InvalidProof();

            // duplicate response?
            if (host.responseReceipts(leaf.response.hash()).relayer != address(0)) revert DuplicateMessage();
            leaves[i] = MmrLeaf(leaf.kIndex, leaf.index, leaf.response.hash());
        }

        bytes32 root = host.stateMachineCommitment(response.proof.height).overlayRoot;
        if (root == bytes32(0)) revert StateCommitmentNotFound();
        bool valid = MerkleMountainRange.VerifyProof(root, response.proof.multiproof, leaves, response.proof.leafCount);
        if (!valid) revert InvalidProof();

        for (uint256 i = 0; i < responsesLength; ++i) {
            PostResponseLeaf memory leaf = response.responses[i];
            host.dispatchIncoming(leaf.response, _msgSender());
        }
    }

    /**
     * @dev check response proofs, message delay and timeouts, then dispatch get responses to modules
     * @param host - Ismp host
     * @param message - batch get responses
     */
    function handleGetResponses(IIsmpHost host, GetResponseMessage calldata message) external notFrozen(host) {
        uint256 timestamp = block.timestamp;
        uint256 delay = timestamp - host.stateMachineCommitmentUpdateTime(message.proof.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        uint256 responsesLength = message.responses.length;
        MmrLeaf[] memory leaves = new MmrLeaf[](responsesLength);

        for (uint256 i = 0; i < responsesLength; ++i) {
            GetResponseLeaf memory leaf = message.responses[i];
            // don't check for timeouts because it's checked on Hyperbridge

            // known request? also serves as source check
            bytes32 requestCommitment = leaf.response.request.hash();
            FeeMetadata memory meta = host.requestCommitments(requestCommitment);
            if (meta.sender == address(0)) revert UnknownMessage();

            // duplicate response?
            if (host.responseReceipts(requestCommitment).relayer != address(0)) revert DuplicateMessage();
            leaves[i] = MmrLeaf(leaf.kIndex, leaf.index, leaf.response.hash());
        }

        bytes32 root = host.stateMachineCommitment(message.proof.height).overlayRoot;
        if (root == bytes32(0)) revert StateCommitmentNotFound();
        bool valid = MerkleMountainRange.VerifyProof(root, message.proof.multiproof, leaves, message.proof.leafCount);
        if (!valid) revert InvalidProof();

        for (uint256 i = 0; i < responsesLength; ++i) {
            GetResponseLeaf memory leaf = message.responses[i];
            host.dispatchIncoming(leaf.response, _msgSender());
        }
    }

    /**
     * @dev Checks the provided timed-out requests and their proofs, before dispatching them to their relevant destination modules
     * @param host - IsmpHost
     * @param message - batch post request timeouts
     */
    function handlePostRequestTimeouts(
        IIsmpHost host,
        PostRequestTimeoutMessage calldata message
    ) external notFrozen(host) {
        uint256 delay = block.timestamp - host.stateMachineCommitmentUpdateTime(message.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        // fetch the state commitment
        StateCommitment memory state = host.stateMachineCommitment(message.height);
        if (state.stateRoot == bytes32(0)) revert StateCommitmentNotFound();
        uint256 timeoutsLength = message.timeouts.length;

        for (uint256 i = 0; i < timeoutsLength; ++i) {
            PostRequest memory request = message.timeouts[i];
            // timed-out?
            if (request.timeout() > state.timestamp) revert MessageNotTimedOut();

            // known request? also serves as source check
            bytes32 requestCommitment = request.hash();
            FeeMetadata memory meta = host.requestCommitments(requestCommitment);
            if (meta.sender == address(0)) revert UnknownMessage();

            bytes[] memory keys = new bytes[](1);
            keys[i] = bytes.concat(REQUEST_RECEIPTS_STORAGE_PREFIX, bytes.concat(requestCommitment));

            // verify state trie non-membership proofs
            StorageValue memory entry = MerklePatricia.VerifySubstrateProof(state.stateRoot, message.proof, keys)[0];
            if (entry.value.length != 0) revert InvalidProof();

            host.dispatchTimeOut(request, meta, requestCommitment);
        }
    }

    /**
     * @dev Check the provided timeouts and their proofs before dispatching them to their relevant modules
     * @param host - Ismp host
     * @param message - batch post response timeouts
     */
    function handlePostResponseTimeouts(
        IIsmpHost host,
        PostResponseTimeoutMessage calldata message
    ) external notFrozen(host) {
        uint256 delay = block.timestamp - host.stateMachineCommitmentUpdateTime(message.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        // fetch the state commitment
        StateCommitment memory state = host.stateMachineCommitment(message.height);
        if (state.stateRoot == bytes32(0)) revert StateCommitmentNotFound();
        uint256 timeoutsLength = message.timeouts.length;

        for (uint256 i = 0; i < timeoutsLength; ++i) {
            PostResponse memory response = message.timeouts[i];
            // timed-out?
            if (response.timeout() > state.timestamp) revert MessageNotTimedOut();

            // known response? also serves as source check
            bytes32 responseCommitment = response.hash();
            FeeMetadata memory meta = host.responseCommitments(responseCommitment);
            if (meta.sender == address(0)) revert UnknownMessage();

            bytes[] memory keys = new bytes[](1);
            keys[i] = bytes.concat(RESPONSE_RECEIPTS_STORAGE_PREFIX, bytes.concat(responseCommitment));

            // verify state trie non-membership proofs
            StorageValue memory entry = MerklePatricia.VerifySubstrateProof(state.stateRoot, message.proof, keys)[0];
            if (entry.value.length != 0) revert InvalidProof();

            host.dispatchTimeOut(response, meta, responseCommitment);
        }
    }

    /**
     * @dev Check the provided Get request timeouts, then dispatch to modules
     * @param host - Ismp host
     * @param message - batch get request timeouts
     */
    function handleGetRequestTimeouts(IIsmpHost host, GetTimeoutMessage calldata message) external notFrozen(host) {
        uint256 delay = block.timestamp - host.stateMachineCommitmentUpdateTime(message.height);
        uint256 challengePeriod = host.challengePeriod();
        if (challengePeriod != 0 && challengePeriod > delay) revert ChallengePeriodNotElapsed();

        // fetch the state commitment
        StateCommitment memory state = host.stateMachineCommitment(message.height);
        if (state.stateRoot == bytes32(0)) revert StateCommitmentNotFound();
        uint256 timeoutsLength = message.timeouts.length;

        for (uint256 i = 0; i < timeoutsLength; ++i) {
            GetRequest memory request = message.timeouts[i];
            // timed-out?
            if (request.timeout() > state.timestamp) revert MessageNotTimedOut();

            bytes32 commitment = request.hash();
            FeeMetadata memory meta = host.requestCommitments(commitment);
            if (meta.sender == address(0)) revert UnknownMessage();

            bytes[] memory keys = new bytes[](1);
            keys[i] = bytes.concat(REQUEST_RECEIPTS_STORAGE_PREFIX, bytes.concat(commitment));

            // verify state trie non-membership proofs
            StorageValue memory entry = MerklePatricia.VerifySubstrateProof(state.stateRoot, message.proof, keys)[0];
            if (entry.value.length != 0) revert InvalidProof();

            host.dispatchTimeOut(request, meta, commitment);
        }
    }
}