// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.4;

/**
 * @dev Interface of ERC721A.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The `quantity` minted with ERC2309 exceeds the safety limit.
     */
    error MintERC2309QuantityExceedsLimit();

    /**
     * The `extraData` cannot be set on an unintialized ownership slot.
     */
    error OwnershipNotInitializedForExtraData();

    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================================
    //                           IERC2309
    // =============================================================

    /**
     * @dev Emitted when tokens in `fromTokenId` to `toTokenId`
     * (inclusive) is transferred from `from` to `to`, as defined in the
     * [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard.
     *
     * See {_mintERC2309} for more details.
     */
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
/// @dev While the ownable portion follows [EIP-173](https://eips.ethereum.org/EIPS/eip-173)
/// for compatibility, the nomenclature for the 2-step ownership handover
/// may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /// @dev `bytes4(keccak256(bytes("Unauthorized()")))`.
    uint256 private constant _UNAUTHORIZED_ERROR_SELECTOR = 0x82b42900;

    /// @dev `bytes4(keccak256(bytes("NewOwnerIsZeroAddress()")))`.
    uint256 private constant _NEW_OWNER_IS_ZERO_ADDRESS_ERROR_SELECTOR = 0x7448fbae;

    /// @dev `bytes4(keccak256(bytes("NoHandoverRequest()")))`.
    uint256 private constant _NO_HANDOVER_REQUEST_ERROR_SELECTOR = 0x6f5e8818;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by: `not(_OWNER_SLOT_NOT)`.
    /// It is intentionally choosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            // Store the new value.
            sstore(ownerSlot, newOwner)
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, _UNAUTHORIZED_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, _NEW_OWNER_IS_ZERO_ADDRESS_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will be automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, _NO_HANDOVER_REQUEST_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solady (https://github.com/vectorized/solmady/blob/main/src/utils/SSTORE2.sol)
/// @author Saw-mon-and-Natalie (https://github.com/Saw-mon-and-Natalie)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
library SSTORE2 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev We skip the first byte as it's a STOP opcode,
    /// which ensures the contract can't be called.
    uint256 internal constant DATA_OFFSET = 1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the storage contract.
    error DeploymentFailed();

    /// @dev The storage contract address is invalid.
    error InvalidPointer();

    /// @dev Attempt to read outside of the storage contract's bytecode bounds.
    error ReadOutOfBounds();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         WRITE LOGIC                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Writes `data` into the bytecode of a storage contract and returns its address.
    function write(bytes memory data) internal returns (address pointer) {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)

            // Add 1 to data size since we are prefixing it with a STOP opcode.
            let dataSize := add(originalDataLength, DATA_OFFSET)

            /**
             * ------------------------------------------------------------------------------+
             * Opcode      | Mnemonic        | Stack                   | Memory              |
             * ------------------------------------------------------------------------------|
             * 61 codeSize | PUSH2 codeSize  | codeSize                |                     |
             * 80          | DUP1            | codeSize codeSize       |                     |
             * 60 0xa      | PUSH1 0xa       | 0xa codeSize codeSize   |                     |
             * 3D          | RETURNDATASIZE  | 0 0xa codeSize codeSize |                     |
             * 39          | CODECOPY        | codeSize                | [0..codeSize): code |
             * 3D          | RETURNDATASIZE  | 0 codeSize              | [0..codeSize): code |
             * F3          | RETURN          |                         | [0..codeSize): code |
             * 00          | STOP            |                         |                     |
             * ------------------------------------------------------------------------------+
             * @dev Prefix the bytecode with a STOP opcode to ensure it cannot be called.
             * Also PUSH2 is used since max contract size cap is 24,576 bytes which is less than 2 ** 16.
             */
            mstore(
                data,
                or(
                    0x61000080600a3d393df300,
                    // Left shift `dataSize` by 64 so that it lines up with the 0000 after PUSH2.
                    shl(0x40, dataSize)
                )
            )

            // Deploy a new contract with the generated creation code.
            pointer := create(0, add(data, 0x15), add(dataSize, 0xa))

            // If `pointer` is zero, revert.
            if iszero(pointer) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Writes `data` into the bytecode of a storage contract with `salt`
    /// and returns its deterministic address.
    function writeDeterministic(bytes memory data, bytes32 salt)
        internal
        returns (address pointer)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)
            let dataSize := add(originalDataLength, DATA_OFFSET)

            mstore(data, or(0x61000080600a3d393df300, shl(0x40, dataSize)))

            // Deploy a new contract with the generated creation code.
            pointer := create2(0, add(data, 0x15), add(dataSize, 0xa), salt)

            // If `pointer` is zero, revert.
            if iszero(pointer) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Returns the initialization code hash of the storage contract for `data`.
    /// Used for mining vanity addresses with create2crunch.
    function initCodeHash(bytes memory data) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let originalDataLength := mload(data)
            let dataSize := add(originalDataLength, DATA_OFFSET)

            mstore(data, or(0x61000080600a3d393df300, shl(0x40, dataSize)))

            hash := keccak256(add(data, 0x15), add(dataSize, 0xa))

            // Restore original length of the variable size `data`.
            mstore(data, originalDataLength)
        }
    }

    /// @dev Returns the address of the storage contract for `data`
    /// deployed with `salt` by `deployer`.
    function predictDeterministicAddress(bytes memory data, bytes32 salt, address deployer)
        internal
        pure
        returns (address predicted)
    {
        bytes32 hash = initCodeHash(data);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, hash)
            mstore(0x01, shl(96, deployer))
            mstore(0x15, salt)
            predicted := keccak256(0x00, 0x55)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x35, 0)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         READ LOGIC                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns all the `data` from the bytecode of the storage contract at `pointer`.
    function read(address pointer) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Offset all indices by 1 to skip the STOP opcode.
            let size := sub(pointerCodesize, DATA_OFFSET)

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), DATA_OFFSET, size)
        }
    }

    /// @dev Returns the `data` from the bytecode of the storage contract at `pointer`,
    /// from the byte at `start`, to the end of the data stored.
    function read(address pointer, uint256 start) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // If `!(pointer.code.size > start)`, reverts.
            // This also handles the case where `start + DATA_OFFSET` overflows.
            if iszero(gt(pointerCodesize, start)) {
                // Store the function selector of `ReadOutOfBounds()`.
                mstore(0x00, 0x84eb0dd1)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            let size := sub(pointerCodesize, add(start, DATA_OFFSET))

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), add(start, DATA_OFFSET), size)
        }
    }

    /// @dev Returns the `data` from the bytecode of the storage contract at `pointer`,
    /// from the byte at `start`, to the byte at `end` (exclusive) of the data stored.
    function read(address pointer, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory data)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let pointerCodesize := extcodesize(pointer)
            if iszero(pointerCodesize) {
                // Store the function selector of `InvalidPointer()`.
                mstore(0x00, 0x11052bb4)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // If `!(pointer.code.size > end) || (start > end)`, revert.
            // This also handles the cases where
            // `end + DATA_OFFSET` or `start + DATA_OFFSET` overflows.
            if iszero(
                and(
                    gt(pointerCodesize, end), // Within bounds.
                    iszero(gt(start, end)) // Valid range.
                )
            ) {
                // Store the function selector of `ReadOutOfBounds()`.
                mstore(0x00, 0x84eb0dd1)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            let size := sub(end, start)

            // Get the pointer to the free memory and allocate
            // enough 32-byte words for the data and the length of the data,
            // then copy the code to the allocated memory.
            // Masking with 0xffe0 will suffice, since contract size is less than 16 bits.
            data := mload(0x40)
            mstore(0x40, add(data, and(add(size, 0x3f), 0xffe0)))
            mstore(data, size)
            mstore(add(add(data, 0x20), size), 0) // Zeroize the last slot.
            extcodecopy(pointer, add(data, 0x20), add(start, DATA_OFFSET), size)
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { IShuffle } from "./interfaces/IShuffle.sol";
import { Ownable } from "solady/auth/Ownable.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";
import { IERC721A } from "erc721a/contracts/IERC721A.sol";
import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IShards {
    function burn(address account, uint256 id, uint256 amount) external;
}

contract Shuffle is IShuffle, Ownable, VRFConsumerBaseV2 {
    using EnumerableSet for EnumerableSet.UintSet;
    using SSTORE2 for address;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       BIT OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Bit mask used to parse out the pool value.
    uint256 private constant _BITMASK_POOL = (1 << 4) - 1;

    // Bit mask used to parse out the token ID value.
    uint256 private constant _BITMASK_TOKEN_ID = (1 << 16) - 1;

    // Bit mask used to parse out the address value.
    uint256 private constant _BITMASK_USER = (1 << 160) - 1;

    // Bit mask used to parse out each weight value.
    uint256 private constant _BITMASK_WEIGHT = (1 << 14) - 1;

    // Bit mask used to zeroise the non-weight related upper bits.
    uint256 private constant _BITMASK_WEIGHTS = (1 << 70) - 1;
    
    // Bit position of `fulfilled` boolean value.
    uint256 private constant _BITPOS_FULFILLED = 255;

    // Bit position of `exists` boolean value.
    uint256 private constant _BITPOS_EXISTS = 254;

    // Bit position of `TokenPools` enum value.
    uint256 private constant _BITPOS_POOL = 246;

    // Bit position of `tokenId` value.
    uint256 private constant _BITPOS_TOKEN_ID = 230;

    // Bit position of `user` address.
    uint256 private constant _BITPOS_USER = 70;
    
    // Bit position of the first weight.
    uint256 private constant _BITPOS_WEIGHT = 14;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      RANK THRESHOLDS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Ranks between 7777 and 3889 are categorised as common.
    uint256 private constant _THRESHOLD_COMMON = 3889;

    // Ranks between 3888 and 2333 are categorised as uncommon.
    uint256 private constant _THRESHOLD_UNCOMMON = 2333;

    // Ranks between 2332 and 1167 are categorised as rare.
    uint256 private constant _THRESHOLD_RARE = 1167;

    // Ranks between 1166 and 312 are categorised as epic.
    uint256 private constant _THRESHOLD_EPIC = 312;

    // NOTE: Tokens that exceed rank 312 are considered as grail tokens.

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      OTHER CONSTANTS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 private constant _EXPECTED_WEIGHT = 10000;

    uint256 private constant _EXPECTED_SIZE = 15554;

    uint256 private constant _SHARD_ID = 0;

    /**
     * `requestData` bit layout.
     * [255..255] fulfilled: Boolean value indicating whether the request has been successfully fulfilled.
     * [254..254] exists: Boolean value indicating whether a request exists.
     * [246..253] pool: Respective pool that `id` will be placed into upon fulfillment.
     * [230..245] tokenId: Isekai Meta token identifier associated with the request.
     * [70...229] user: Address of the caller that invoked the request.
     * [0.....69] weights: Packed weightings associated with each token pool, 14 bits per weight.
     */
    mapping(uint256 requestId => uint256 requestData) private _requests;
    
    // Mapping of pool type to the token IDs that reside within it.
    mapping(TokenPools pool => EnumerableSet.UintSet tokenIds) private _pools;

    // Mapping of pool type to a packed `uint256[5]` weights array.
    mapping(TokenPools pool => uint256 weights) private _weights;

    // Interface of Isekai Meta contract.
    IERC721A public immutable ISEKAI = IERC721A(0x684E4ED51D350b4d76A3a07864dF572D24e6dC4c);
    
    // Interface of Isekai Shards contract.
    IShards public immutable SHARDS = IShards(0xb842b4605F7D3340329122faeA90954CbD15a849);
    
    // Interface for Chainlink VRFCoordinatorV2.
    VRFCoordinatorV2Interface public immutable COORDINATOR;

    // There is no intention to support gwei key hashes above 200 so this variable
    // has been defined as immutable.
    bytes32 public immutable KEY_HASH;

    // Address of the SSTORE2'd ranking data.
    address public immutable rankings;

    // Tracks the current state of the contract.
    ShuffleState public shuffleState;

    // Chainlink stuff.
    uint64 public subscriptionId;
    uint32 public callbackGasLimit = 500_000;
    uint16 public requestConfirmations = 3;

    // Tracks the current number of pending requests. This value been casted to a uint16
    // to prevent a zero to non-zero SSTORE by packing it into the storage slot with the
    // values defined above.
    uint16 public pendingRequests = 0;

    /**
     * Modifier that checks if `shuffleState` matches `desiredState`.
     */
    modifier checkState(ShuffleState desiredState) {
        _checkState(desiredState);
        _;
    }
    
    constructor(
        address coordinator,
        bytes32 keyHash,
        uint64 subId,
        bytes memory data,
        uint256[5][5] memory weightings
    ) VRFConsumerBaseV2(coordinator) {
        _initializeOwner(msg.sender);

        COORDINATOR = VRFCoordinatorV2Interface(coordinator);
        KEY_HASH = keyHash;
        subscriptionId = subId;

        // Expected bytes length of constructor argument `data`. Since each ranking
        // is consolidated into 2 bytes of information and there is 7,777 tokens
        // in the Isekai Meta collection, 2 * 7777 (15554) is the desired length.
        if (data.length != _EXPECTED_SIZE) revert InvalidDataSize();
        rankings = SSTORE2.write(data);

        _setPoolWeights(weightings);
    }

    /**
     * @notice Function used to shuffle an Isekai Meta token.
     * @param tokenId Isekai Meta token Identifier.
     */
    function shuffle(uint256 tokenId) external checkState(ShuffleState.ACTIVE) {
        // Ensure that the request can be fulfilled, this line updates `pendingRequests`
        // then checks its value against the return value of `_minPoolSize()`.
        if (++pendingRequests > _minPoolSize()) revert InvalidPoolSize();

        SHARDS.burn(msg.sender, _SHARD_ID, 1);
        ISEKAI.transferFrom(msg.sender, address(this), tokenId);

        TokenPools pool = _poolFromId(tokenId);
        uint256 weightings = _weights[pool];

        uint256 requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );

        _requests[requestId] = _packData(pool, tokenId, msg.sender, weightings);
    }

    /**
     * @notice Function used to add reward tokens to the shuffler.
     * @param tokenIds Array of Isekai Meta token identifiers.
     */
    function addRewardTokens(uint256[] calldata tokenIds)
        external
        onlyOwner
        checkState(ShuffleState.INACTIVE)
    {
        if (tokenIds.length == 0) revert ZeroLengthArray();

        for (uint256 i = 0; i < tokenIds.length; ) {
            uint256 tokenId = tokenIds[i];
            ISEKAI.transferFrom(msg.sender, address(this), tokenId);

            if (!_pools[_poolFromId(tokenId)].add(tokenId)) revert AddFailed();

            unchecked { ++i; }
        }
    }

    /**
     * @notice Function used to remove reward tokens from the shuffler.
     * @param tokenIds Array of Isekai Meta token identifiers.
     */
    function removeRewardTokens(uint256[] calldata tokenIds)
        external
        onlyOwner
        checkState(ShuffleState.INACTIVE)
    {
        if (tokenIds.length == 0) revert ZeroLengthArray();

        for (uint256 i = 0; i < tokenIds.length; ) {
            uint256 tokenId = tokenIds[i];
            if (!_pools[_poolFromId(tokenId)].remove(tokenId)) revert RemoveFailed();

            ISEKAI.transferFrom(address(this), msg.sender, tokenId);
            unchecked { ++i; }
        }
    }

    /**
     * @notice Function used to withdraw tokens from the contract. This function
     * is here to ensure tokens NEVER become stuck due to unforseen circumstances.
     * @param tokenIds Array of Isekai Meta token identifiers.
     * @dev If this function is ever called, the contract itself will require
     * redeployment. Use with EXTREME caution.
     */
    function emergencyWithdraw(uint256[] calldata tokenIds) external onlyOwner {
        if (tokenIds.length == 0) revert ZeroLengthArray();
        for (uint256 i = 0; i < tokenIds.length; ) {
            ISEKAI.transferFrom(address(this), msg.sender, tokenIds[i]);
            unchecked { ++i; }
        }
    }

    /**
     * @notice Function used to set a new `shuffleState` value.
     * @param newShuffleState Newly desired `shuffleState` value.
     */
    function setShuffleState(ShuffleState newShuffleState) external onlyOwner {
        shuffleState = newShuffleState;
    }

    /**
     * @notice Function used to view all tokens in `pool`.
     * @param pool Desired token pool to check.
     * @return Returns an array of all token IDs within `pool`.
     */
    function getTokensInPool(TokenPools pool) external view returns (uint256[] memory) {
        return _pools[pool].values();
    }

    /**
     * @notice Function used to view all tokens in every pool.
     * @return tokenIds A multi-dimensional array that contains all token IDs within each token pool.
     */
    function getTokensInAllPools() external view returns (uint256[][] memory tokenIds) {
        uint256 maxPools = uint256(type(TokenPools).max);
        tokenIds = new uint256[][](maxPools + 1);

        for (uint256 i = 0; i <= maxPools; i++) {
            tokenIds[i] = _pools[TokenPools(i)].values();
        }

        return tokenIds;
    }

    /**
     * @notice Function used to view the number of tokens in `pool`.
     * @param pool Desired token pool to check.
     */
    function getAmountOfTokensInPool(TokenPools pool) external view returns (uint256) {
        return _pools[pool].length();
    }

    /**
     * @notice Function used to check if `tokenId` is in `pool`.
     * @param pool Desired token pool to check.
     * @param tokenId Isekai Meta token identifier.
     * @return Returns `true` if `tokenId` exists within `pool`, `false` otherwise.
     */
    function isTokenInPool(TokenPools pool, uint256 tokenId) external view returns (bool) {
        return _pools[pool].contains(tokenId);
    }

    /**
     * @notice Function used to check the weights associated with `pool`.
     * @param pool Desired token pool to check.
     * @return Returns the weights of each token pool for `pool`.
     */
    function weights(TokenPools pool) external view returns (uint256[5] memory) {
        return _unpackWeights(_weights[pool]);
    }

    /**
     * @notice Function used to view the token pool associated with `tokenId`.
     * @param tokenId Isekai Meta token identifier.
     * @return Returns the token pool associated with `tokenId`.
     */
    function poolFromId(uint256 tokenId) external view returns (TokenPools) {
        return _poolFromId(tokenId);
    }

    /**
     * @notice Function used to view the rank of a given `tokenId`.
     * @param tokenId Isekai Meta token identifier.
     * @return Returns the rank associated with the provided `tokenId`.
     */
    function getRank(uint256 tokenId) external view returns (uint256) {
        return _getRank(tokenId);
    }

    /**
     * @notice Function used to view the request data for a given `requestId` value.
     * @param requestId A Chainlink request identifier.
     * @return Returns Human readable request data derived from `PackedRequest.data[requestId]`.
     */
    function requests(uint256 requestId) external view returns (Request memory) {
        uint256 data = _requests[requestId];
        return Request({
            fulfilled: data >> _BITPOS_FULFILLED & 1 == 1,
            exists: data >> _BITPOS_EXISTS & 1 == 1,
            pool: TokenPools(data >> _BITPOS_POOL & _BITMASK_POOL),
            tokenId: data >> _BITPOS_TOKEN_ID & _BITMASK_TOKEN_ID,
            user: address(uint160(data >> _BITPOS_USER & _BITMASK_USER)),
            weights: _unpackWeights(data)
        });
    }

    /**
     * @notice Function used to handle random number fulfillment.
     * @dev It is critical that this function NEVER reverts.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // Access the packed data associated with `requestId`.
        uint256 data = _requests[requestId];
        
        // Confirm that the randomness request exists.
        if (data >> _BITPOS_EXISTS & 1 != 1) revert RequestNotFound();

        // Acknowledge the request is being fulfilled and update the respective value.
        _requests[requestId] |= 1 << _BITPOS_FULFILLED;

        // Update pending requests.
        --pendingRequests;

        // Assign random number from `randomWords`.
        uint256 randomNumber = randomWords[0];

        // Run weighted random number algorithm to determine which pool a token will be selected from. The
        // second parameter zeroises the non-weight related bits of `data` to ensure cleanliness.
        TokenPools chosenPool = _chosePool(randomNumber, data & _BITMASK_WEIGHTS);

        // Select a token from the chosen pool, the operation defined within `.at()` mods `randomNumber`
        // by the length of `_pools[chosenPool]` to derive a pseudorandom index between 0 and `length - 1`.
        uint256 tokenOut = _pools[chosenPool].at(randomNumber % _pools[chosenPool].length());

        // Remove the token ID from the pool.
        _pools[chosenPool].remove(tokenOut);

        // Assign original token value.
        uint256 tokenIn = data >> _BITPOS_TOKEN_ID & _BITMASK_TOKEN_ID;

        // Update the pool with the original Isekai that was provided in the initial invocation of `shuffle()`.
        _pools[TokenPools(data >> _BITPOS_POOL & _BITMASK_POOL)].add(tokenIn);

        // Assign receiver.
        address receiver = address(uint160(data >> _BITPOS_USER & _BITMASK_USER));

        // Transfer the chosen Isekai to the owner.
        ISEKAI.transferFrom(address(this), receiver, tokenOut);
        
        // Event emission.
        emit Shuffled(receiver, tokenIn, tokenOut);
    }

    /** 
     * Helper function used to set the weights of each pool. This function is only
     * called within the constructor and pool weightings cannot be modified once set.
     */
    function _setPoolWeights(uint256[5][5] memory weightings) internal {
        for (uint256 i = 0; i < weightings.length; i++) {
            if (_sumWeights(weightings[i]) != _EXPECTED_WEIGHT) revert WeightMismatch();   
            _weights[TokenPools(i)] = _packWeights(weightings[i]);
        }
    }

    /**
     * Helper function that implements a weighted random number algorithim to derive
     * a chosen token pool from the seeded random number and the packed weights.
     */
    function _chosePool(
        uint256 randomNumber,
        uint256 packedWeights
    ) internal pure returns (TokenPools pool) {
        assembly ("memory-safe") {
            // Derive a value within the range of 1 - 10,000.
            let roll := add(mod(randomNumber, _EXPECTED_WEIGHT), 1)

            // Define iterator value.
            let i := 0
            for { let cumulativeWeight := 0 } 1 {} {
                // Assign the current value of `weights[i]`.
                let poolWeight := and(shr(mul(_BITPOS_WEIGHT, i), packedWeights), _BITMASK_WEIGHT)
                
                // Update our `cumulativeWeight` by adding the previous value with `poolWeight`.
                cumulativeWeight := add(cumulativeWeight, poolWeight)

                // If the condition is satifised, break.
                if iszero(gt(roll, cumulativeWeight)) { break }

                // Update iterator value.
                i := add(i, 1)
            }

            // Set the associated `pool` value.
            pool := i
        }
    }

    /**
     * Helper function used to efficiently calculate the sum of the `weightings` array. Since
     * `weightings` is bounded to 5 indices, we can safely unroll the operations.
     */
    function _sumWeights(uint256[5] memory weightings) internal pure returns (uint256 sum) {
        assembly ("memory-safe") {
            sum := mload(weightings)
            sum := add(sum, mload(add(weightings, 0x20)))
            sum := add(sum, mload(add(weightings, 0x40)))
            sum := add(sum, mload(add(weightings, 0x60)))
            sum := add(sum, mload(add(weightings, 0x80)))
        }
    }

    /**
     * Helper function used to efficiently pack the `weightings` array into 70 bits. Since
     * the sum of `weightings` is bounded 10,000, each weight fits snugly into 14 bits.
     */
    function _packWeights(uint256[5] memory weightings) internal pure returns (uint256 packed) {
        assembly ("memory-safe") {
            packed := mload(weightings)
            packed := or(packed, shl(_BITPOS_WEIGHT, mload(add(weightings, 0x20))))
            packed := or(packed, shl(mul(_BITPOS_WEIGHT, 2), mload(add(weightings, 0x40))))
            packed := or(packed, shl(mul(_BITPOS_WEIGHT, 3), mload(add(weightings, 0x60))))
            packed := or(packed, shl(mul(_BITPOS_WEIGHT, 4), mload(add(weightings, 0x80))))
        }
    }

    /**
     * Helper function used to efficiently unpack the `weights_` array from `packedWeights`.
     */
    function _unpackWeights(uint256 packedWeights) internal pure returns (uint256[5] memory weights_) {
        assembly ("memory-safe") {
            mstore(weights_, and(packedWeights, _BITMASK_WEIGHT))
            mstore(add(weights_, 0x20), and(shr(_BITPOS_WEIGHT, packedWeights), _BITMASK_WEIGHT))
            mstore(add(weights_, 0x40), and(shr(mul(_BITPOS_WEIGHT, 2), packedWeights), _BITMASK_WEIGHT))
            mstore(add(weights_, 0x60), and(shr(mul(_BITPOS_WEIGHT, 3), packedWeights), _BITMASK_WEIGHT))
            mstore(add(weights_, 0x80), and(shr(mul(_BITPOS_WEIGHT, 4), packedWeights), _BITMASK_WEIGHT))
        }
    }

    /**
     * Helper function used to efficiently pack the provided data into a single word.
     * Refer to `PackedRequest` comment for bit layout.
     */
    function _packData(
        TokenPools pool,
        uint256 tokenId,
        address account,
        uint256 weightings
    ) internal pure returns (uint256 packed) {
        assembly ("memory-safe") {
            packed := or(packed, shl(_BITPOS_EXISTS, 1))
            packed := or(packed, shl(_BITPOS_POOL, pool))
            packed := or(packed, shl(_BITPOS_TOKEN_ID, tokenId))
            packed := or(packed, shl(_BITPOS_USER, account))
            packed := or(packed, weightings)
        }
    }

    /**
     * Helper function that returns the number of tokens in the lowest supplied token pool.
     */
    function _minPoolSize() internal view returns (uint256 min) {
        min = _pools[TokenPools.COMMON].length();

        for (uint256 i = 1; i <= uint256(type(TokenPools).max); ) {
            uint256 n = _pools[TokenPools(i)].length();
            if (min > n) min = n;
            unchecked { ++i; }
        }
    }

    /**
     * Helper function used to get the pool associated with `tokenId`.
     */
    function _poolFromId(uint256 tokenId) internal view returns (TokenPools pool) {
        uint256 rank = _getRank(tokenId);

        assembly ("memory-safe") {
            pool := add(
                add(gt(_THRESHOLD_EPIC, rank), gt(_THRESHOLD_RARE, rank)),
                add(gt(_THRESHOLD_UNCOMMON, rank), gt(_THRESHOLD_COMMON, rank))
            )
        }
    }

    /**
     * Helper function used to get the rank of a given token identifier.
     */
    function _getRank(uint256 id) internal view returns (uint256 rank) {
        uint256 start = (id - 1) * 2;
        uint256 end = start + 2;
        
        bytes memory data = rankings.read(start, end);

        assembly ("memory-safe") {
            rank := shr(240, mload(add(data, 0x20)))
        }
    }

    /**
     * Helper function used to reduce bytecode size.
     */
    function _checkState(ShuffleState desiredState) private view {
        if (shuffleState != desiredState) revert InvalidState();
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IShuffle {

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           ERRORS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * The expected state value does not match the current state.
     */
    error InvalidState();

    /**
     * The provided array has no length.
     */
    error ZeroLengthArray();

    /**
     * The sum of the provided array does not match the expected value.
     */
    error WeightMismatch();

    /**
     * A non-existing request is attempting to be fulfilled by the Oracle.
     */
    error RequestNotFound();

    /**
     * The new number of pending requests will outsize the lowest supplied token pool.
     */
    error InvalidPoolSize();

    /**
     * The data size provided does not match the expected data size.
     */
    error InvalidDataSize();

    /**
     * Failed to add a token to the EnumerableSet.
     */
    error AddFailed();

    /**
     * Failed to remove a token from the EnumerableSet.
     */
    error RemoveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           ENUMS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * Used to track the shuffling state of the contract.
     */
    enum ShuffleState {
        INACTIVE,
        ACTIVE
    }

    /**
     * Used to reference a token pool that a token should be deposited
     * or withdrawn from.
     */
    enum TokenPools {
        COMMON,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * This struct imitates the unpacked values from `PackedRequest.data`.
     */
    struct Request {
        bool fulfilled;
        bool exists;
        TokenPools pool;
        uint256 tokenId;
        address user;
        uint256[5] weights;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event Shuffled(address indexed user, uint256 tokenIn, uint256 tokenOut);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         FUNCTIONS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * Function used to shuffle an Isekai Meta token.
     */
    function shuffle(uint256 tokenId) external;

    /**
     * Function used to add reward tokens to the shuffler.
     */
    function addRewardTokens(uint256[] calldata tokenIds) external;

    /**
     * Function used to remove reward tokens from the shuffler.
     */
    function removeRewardTokens(uint256[] calldata tokenIds) external;

    /** 
     * Function used to withdraw reward tokens from the shuffler without pool updates.
     */
    function emergencyWithdraw(uint256[] calldata tokenIds) external;

    /**
     * Function used to set a new `shuffleState` value.
     */
    function setShuffleState(ShuffleState newShuffleState) external;

    /**
     * Function used to view all tokens in `pool`. 
     */
    function getTokensInPool(TokenPools pool) external view returns (uint256[] memory);

    /**
     * Function used to view the number of tokens in `pool`.
     */
    function getAmountOfTokensInPool(TokenPools pool) external view returns (uint256);

    /**
     * Function used to check if `tokenId` is in `pool`.
     */
    function isTokenInPool(TokenPools pool, uint256 tokenId) external view returns (bool);

    /**
     * Function used to check the weights associated with `pool`.
     */
    function weights(TokenPools pool) external view returns (uint256[5] memory);

    /**
     * Function used to view the token pool associated with `tokenId`.
     */
    function poolFromId(uint256 tokenId) external view returns (TokenPools);

    /**
     * Function used to view the rank associated with `tokenId`.
     */
    function getRank(uint256 tokenId) external view returns (uint256);

    /**
     * Function used to view an unpacked request for `requestId`.
     */
    function requests(uint256 requestId) external view returns (Request memory);

}