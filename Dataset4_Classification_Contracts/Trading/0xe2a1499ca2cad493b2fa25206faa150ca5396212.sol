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
  // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
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
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
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

import {VRFV2PlusClient} from "../libraries/VRFV2PlusClient.sol";
import {IVRFSubscriptionV2Plus} from "./IVRFSubscriptionV2Plus.sol";

// Interface that enables consumers of VRFCoordinatorV2Plus to be future-proof for upgrades
// This interface is supported by subsequent versions of VRFCoordinatorV2Plus
interface IVRFCoordinatorV2Plus is IVRFSubscriptionV2Plus {
  /**
   * @notice Request a set of random words.
   * @param req - a struct containing following fields for randomness request:
   * keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * requestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * extraArgs - abi-encoded extra args
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(VRFV2PlusClient.RandomWordsRequest calldata req) external returns (uint256 requestId);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice The IVRFSubscriptionV2Plus interface defines the subscription
/// @notice related methods implemented by the V2Plus coordinator.
interface IVRFSubscriptionV2Plus {
  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint256 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint256 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint256 subId, address to) external;

  /**
   * @notice Accept subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint256 subId) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint256 subId, address newOwner) external;

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription with LINK, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   * @dev Note to fund the subscription with Native, use fundSubscriptionWithNative. Be sure
   * @dev  to send Native with the call, for example:
   * @dev COORDINATOR.fundSubscriptionWithNative{value: amount}(subId);
   */
  function createSubscription() external returns (uint256 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return nativeBalance - native balance of the subscription in wei.
   * @return reqCount - Requests count of subscription.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(
    uint256 subId
  )
    external
    view
    returns (uint96 balance, uint96 nativeBalance, uint64 reqCount, address owner, address[] memory consumers);

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint256 subId) external view returns (bool);

  /**
   * @notice Paginate through all active VRF subscriptions.
   * @param startIndex index of the subscription to start from
   * @param maxCount maximum number of subscriptions to return, 0 to return all
   * @dev the order of IDs in the list is **not guaranteed**, therefore, if making successive calls, one
   * @dev should consider keeping the blockheight constant to ensure a holistic picture of the contract state
   */
  function getActiveSubscriptionIds(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);

  /**
   * @notice Fund a subscription with native.
   * @param subId - ID of the subscription
   * @notice This method expects msg.value to be greater than or equal to 0.
   */
  function fundSubscriptionWithNative(uint256 subId) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// End consumer library.
library VRFV2PlusClient {
  // extraArgs will evolve to support new features
  bytes4 public constant EXTRA_ARGS_V1_TAG = bytes4(keccak256("VRF ExtraArgsV1"));
  struct ExtraArgsV1 {
    bool nativePayment;
  }

  struct RandomWordsRequest {
    bytes32 keyHash;
    uint256 subId;
    uint16 requestConfirmations;
    uint32 callbackGasLimit;
    uint32 numWords;
    bytes extraArgs;
  }

  function _argsToBytes(ExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EXTRA_ARGS_V1_TAG, extraArgs);
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

import './interfaces/IDelegateRegistry.sol';
import './interfaces/IDelegationRegistry.sol';

contract Presale is VRFConsumerBaseV2, Ownable {

    // Maintains various token balances for users
    struct userInfo {
        uint256 KOLPurchased;
        uint256 superKOLPurchased;
        uint256 totalPurchased;
        uint256 rafflesWon;
        uint256 rafflesPurchased;
        uint256 amountClaimed;
    }

    // Each user's info 
    mapping(address => userInfo) public usersInfo;

    // Purchased per NFT ID
    mapping(uint256 => uint256) public phaseOnePurchased; 

    // Phase 2 whitelists 
    mapping(address => bool) public KOLWhitelist; 
    mapping(address => bool) public superKOLWhitelist;

    // List of users who have entered the raffle - one entry per ticket purchased
    address[] public raffleEntries;

    // Total tokens that can be purchased in phase 1
    uint256 public phaseOneSupply = 33000000 * 10**18;
    uint256 public phaseOnePurchasedTotal;
    
    // Total tokens that can be purchased in phase 2 - rolls over from phase 1
    uint256 public phaseTwoSupply = 132000000 * 10**18;
    uint256 public KOLPurchasedTotal;
    uint256 public superKOLPurchasedTotal;

    // Total tokens that can be purchased in phase 3 - rolls over from phase 1 and 2
    uint256 public phaseThreeSupply;
    uint256 public phaseThreePurchasedTotal;

    // Tokens purchased across all phases 
    uint256 public totalTokensPurchased;
    // ETH collected in phase 1 and 2 - allows for withdrawing during phase 3
    uint256 public phaseOneTwoETH;

    // Used to maintain the contract's current phase
    uint256 public launchTime;
    bool public claimEnabled;
    uint256 public claimTime;

    // Limit of number of tokens that can be purchased by each user in each phase
    uint256 public phaseOneCap;
    uint256 public KOLCap;
    uint256 public superKOLCap;

    // Cost per entry and winning token amount for raffles
    uint256 public rafflePrice;
    uint256 public raffleAmount;
    uint256 public raffleLimit = 20;

    // Tokens per ETH for each phase
    uint256 public phaseOneRatio;
    uint256 public phaseTwoRatio;

    // Used to calculate each user's vested amount when claiming
    uint256 public vestingPeriod = 14 days;
    uint256 public cliffDuration = 12 hours;
    uint256 public initialUnlockPercent = 75;

    // Used to rollover tokens between phases
    bool public phaseOneEnded;
    bool public phaseTwoEnded;

    // Used to enable users to refund losing tickets
    bool public refundsEnabled;

    // Vars required for Chainlink VRF
    uint256 public subscriptionId;
    IVRFCoordinatorV2Plus public coordinator;
    bytes32 public keyHash = 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b;
    uint32 public callbackGasLimit = 15000000;
    uint16 public requestConfirmations = 3;

    // NFTs required for phase one purchase
    IERC721 public nftAddress;
    // Tokens being bought in each phase
    IERC20 public tokenAddress;
    // Delegate registries to support delegating NFTs
    IDelegateRegistry public immutable delegateRegistryV2 =
        IDelegateRegistry(0x00000000000000447e69651d841bD8D104Bed493);
    IDelegationRegistry public immutable delegateRegistryV1 =
        IDelegationRegistry(0x00000000000076A84feF008CDAbe6409d2FE638B);

    error OutsideTimeWindow();
    error ExceedsPurchaseCap();
    error NFTOwner();
    error Whitelist();
    error IncorrectPrice();
    error NotEnabled();
    error AlreadyLaunched();

    // Creates the presale and sets the required values
    constructor(address _nftAddress, address _tokenAddress, address _vrfCoordinator, uint256 _subscriptionId) VRFConsumerBaseV2(_vrfCoordinator) Ownable(msg.sender) {
        coordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        nftAddress = IERC721(_nftAddress);
        tokenAddress = IERC20(_tokenAddress);
    }

    // Begins the presale process and sets prices and caps
    function launch(uint256 _phaseOneRatio, uint256 _phaseTwoRatio, uint256 _phaseOneCap, uint256 _KOLCap, uint256 _superKOLCap, uint256 _rafflePrice, uint256 _raffleAmount) external onlyOwner {
        if(launchTime != 0) { // 2 hours phase one + 2 hours phase 2 + 24 hours phase 3
            revert AlreadyLaunched();
        }
        launchTime = block.timestamp;
        phaseOneRatio = _phaseOneRatio;
        phaseTwoRatio = _phaseTwoRatio;
        phaseOneCap = _phaseOneCap;
        KOLCap = _KOLCap;
        superKOLCap = _superKOLCap;
        rafflePrice = _rafflePrice;
        raffleAmount = _raffleAmount;
    }

    // Allows users to refund their losing tickets - no draws must happen after 
    function enableRefunds() external onlyOwner {
        refundsEnabled = true;
    }

    // Allows users to claim 
    function enableClaims() external onlyOwner {
        // Ensures phase three has ended 
        if(block.timestamp < launchTime + 100800) { // 2 hours phase one + 2 hours phase 2 + 24 hours phase 3
            revert OutsideTimeWindow();
        }
        claimEnabled = true;
        claimTime = block.timestamp;
        // Transfers the total required tokens to the contract 
        tokenAddress.transferFrom(msg.sender, address(this), totalTokensPurchased);
    }

    // Allows an NFT holder to purchase tokens 
    function phaseOnePurchase(uint256[] calldata nftIds, uint256[] calldata amounts) external payable {
        if(block.timestamp > launchTime + 7200) { 
            // Two hours from launch to purchase in phase one 
            revert OutsideTimeWindow();
        }

        uint256 totalAmount;
        for(uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        if(msg.value != totalAmount) {
            revert IncorrectPrice();
        }

        for(uint256 i = 0; i < nftIds.length; i++) {
            _phaseOnePurchase(nftIds[i], amounts[i]);
        }

        phaseOneTwoETH += msg.value;

    }

    function _phaseOnePurchase(uint256 nftId, uint256 amount) internal {
        // User must own the specified NFT or be a delegate
        if(!_verifyTokenOwner(nftId)) {
            revert NFTOwner();
        }

        // Convert ETH to tokens 
        uint256 purchasedAmount = amount * phaseOneRatio;
        if(phaseOnePurchased[nftId] + purchasedAmount > phaseOneCap) {
            revert ExceedsPurchaseCap();
        }

        // Check we dont exceed the phase one supply
        if(phaseOnePurchasedTotal + purchasedAmount > phaseOneSupply) {
            revert ExceedsPurchaseCap();
        }

        // Increment all associated values
        usersInfo[msg.sender].totalPurchased += purchasedAmount;
        phaseOnePurchased[nftId] += purchasedAmount;
        phaseOnePurchasedTotal += purchasedAmount;
        totalTokensPurchased += purchasedAmount;
    }

    // Allows whitelisted users to purchase tokens after phase one ends
    function phaseTwoKOLPurchase() external payable {
        if(block.timestamp < launchTime + 7200 || block.timestamp > launchTime + 14400) {
            // Phase two starts two hours after launch and lasts another two hours 
            revert OutsideTimeWindow();
        }

        // Carries over any not purchased phase one tokens - should only trigger after phase one due to above time constraints
        if(!phaseOneEnded) {
            phaseTwoSupply += (phaseOneSupply - phaseOnePurchasedTotal);
            phaseOneEnded = true;
        }

        // User must be whitelisted
        if(KOLWhitelist[msg.sender] == false) {
            revert Whitelist();
        }

        // Convert ETH to tokens 
        uint256 purchasedAmount = msg.value * phaseTwoRatio;
        if(usersInfo[msg.sender].KOLPurchased + purchasedAmount > KOLCap) {
            revert ExceedsPurchaseCap();
        }

        // Check total phase two purchased tokens dont exceed phase two supply
        if(KOLPurchasedTotal + superKOLPurchasedTotal + purchasedAmount > phaseTwoSupply) {
            revert ExceedsPurchaseCap();
        }

        // Increment all associated values
        usersInfo[msg.sender].KOLPurchased += purchasedAmount;
        usersInfo[msg.sender].totalPurchased += purchasedAmount;
        KOLPurchasedTotal += purchasedAmount;
        totalTokensPurchased += purchasedAmount;
        phaseOneTwoETH += msg.value;
    }

    // Allows whitelisted users to purchase tokens after phase one ends
    function phaseTwoSuperKOLPurchase() external payable {
        if(block.timestamp < launchTime + 7200 || block.timestamp > launchTime + 14400) {
            // Phase two starts two hours after launch and lasts another two hours
            revert OutsideTimeWindow();
        }

        // Carries over any not purchased phase one tokens - should only trigger after phase one due to above time constraints
        if(!phaseOneEnded) {
            phaseTwoSupply += (phaseOneSupply - phaseOnePurchasedTotal);
            phaseOneEnded = true;
        }

        // User must be whitelisted
        if(superKOLWhitelist[msg.sender] == false) {
            revert Whitelist();
        }

        // Convert ETH to tokens 
        uint256 purchasedAmount = msg.value * phaseTwoRatio;
        if(usersInfo[msg.sender].superKOLPurchased + purchasedAmount > superKOLCap) {
            revert ExceedsPurchaseCap();
        }

        // Check total phase two purchased tokens dont exceed phase two supply
        if(KOLPurchasedTotal + superKOLPurchasedTotal + purchasedAmount > phaseTwoSupply) {
            revert ExceedsPurchaseCap();
        }

        // Increment all associated values
        usersInfo[msg.sender].superKOLPurchased += purchasedAmount;
        usersInfo[msg.sender].totalPurchased += purchasedAmount;
        superKOLPurchasedTotal += purchasedAmount;
        totalTokensPurchased += purchasedAmount;
        phaseOneTwoETH += msg.value;
    }

    // Allows any users to purchase a raffle ticket after phase two ends
    function phaseThreePurchase(uint256 numTickets) external payable {
        if(block.timestamp < launchTime + 14400 || block.timestamp > launchTime + 100800) {
            // Phase three starts four hours after launch and lasts another 24 hours
            revert OutsideTimeWindow();
        }

        // Carries over any not purchased phase two tokens - should only trigger after phase one due to above time constraints
        if(!phaseTwoEnded) {
            phaseThreeSupply += (phaseTwoSupply - (KOLPurchasedTotal + superKOLPurchasedTotal));
            phaseTwoEnded = true;
        }

        // Ensure user provided correct amount of ETH 
        if(msg.value != rafflePrice * numTickets) {
            revert IncorrectPrice();
        }

        if(usersInfo[msg.sender].rafflesPurchased + numTickets > raffleLimit) {
            revert ExceedsPurchaseCap();
        }
        
        // Credit the user with the number of tickets
        usersInfo[msg.sender].rafflesPurchased += numTickets;
        for(uint256 i = 0; i < numTickets; i++) {
            // Add user to the actual entries
            raffleEntries.push(msg.sender);
        }
    }

    // Allows the owner to draw the specified number of winners
    function draw(uint256 numDraws) external onlyOwner() {
        if(block.timestamp < launchTime + 100800) {
            // Raffle can be drawn after phase three ends
            revert OutsideTimeWindow();
        }

        // Check total phase three purchased tokens dont exceed phase three supply
        if((numDraws * raffleAmount) + phaseThreePurchasedTotal > phaseThreeSupply) {
            revert ExceedsPurchaseCap();
        }

        // Request random values from Chainlink VRF provider
        requestRandomWords(callbackGasLimit, requestConfirmations, uint32(numDraws));
    }

    // Sends the request for random values to Chainlink VRF provider
    function requestRandomWords(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) internal {
        bytes memory args = VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
        );

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: _requestConfirmations,
                callbackGasLimit: _callbackGasLimit,
                numWords: _numWords,
                extraArgs: args
            });

        coordinator.requestRandomWords(request);
    }

    // Called by Chainklink VRF provider to provide requested random values
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory randomWords
    ) internal override {
        selectWinners(randomWords);
    }

    // Used to select winners based on provided random values
    function selectWinners(uint256[] memory randomness) internal {
        // Selects the correct number of winners
        for (uint256 i; i < randomness.length; i++) {
            // Find the right winner from the entries
            uint256 winnerIndex = randomness[i] % raffleEntries.length;
            address winner = raffleEntries[winnerIndex];
            // Credit the user with the amount and the win
            usersInfo[winner].totalPurchased += raffleAmount;
            totalTokensPurchased += raffleAmount;
            phaseThreePurchasedTotal += raffleAmount;
            usersInfo[winner].rafflesWon += 1;
            // Remove the user from the entries 
            raffleEntries[winnerIndex] = raffleEntries[raffleEntries.length-1];
            raffleEntries.pop();
        }
    }

    // Allows the users to claim tokens once enabled
    function claim() external {
        if(!claimEnabled) {
            revert NotEnabled();
        }
        // Claimable tokens vest over time 
        uint256 vested = vestedAmount(usersInfo[msg.sender].totalPurchased);
        // Calculate claimable, update claimed amount, send user their tokens
        uint256 claimable = vested - usersInfo[msg.sender].amountClaimed;
        usersInfo[msg.sender].amountClaimed = vested;
        tokenAddress.transfer(msg.sender, claimable);
    }

    // Calculates the amount of vested tokens from the time claiming was enabled
    function vestedAmount(uint256 totalPurchased) public view returns (uint256) {
        if(claimTime == 0) {
            return 0;
        }
        uint256 elapsedTime = block.timestamp - claimTime;
        uint256 initalUnlockAmount = (totalPurchased * initialUnlockPercent) / 100;
        if (elapsedTime < cliffDuration) {
            // Before 12 hours, only the initial 75% is available
            return initalUnlockAmount;
        } else if (elapsedTime >= cliffDuration + vestingPeriod) {
            // After the vesting period, 100% is vested
            return totalPurchased;
        } else { // calculate vested amount 
            elapsedTime = block.timestamp - (claimTime + cliffDuration); // vesting starts from cliff duration
            uint256 nonInitialAmount = (totalPurchased * (100 - initialUnlockPercent)) / 100; // amount that vests after initial unlock
            uint256 vestedAmount = (nonInitialAmount * elapsedTime) / vestingPeriod; // amount of non-initial that has vested
            return initalUnlockAmount + vestedAmount; // initial unlock + vested amount 
        }
    }

    // Allows users to refund raffle entries that were not selected
    function refundRaffle() external { 
        if(!refundsEnabled) {
            // Cannot claim until team is done drawing winners
            revert NotEnabled();
        }
        uint256 ticketsRefunded =  usersInfo[msg.sender].rafflesPurchased -  usersInfo[msg.sender].rafflesWon;
        // Users receive a 97.5% refund
        uint256 refundAmount = (ticketsRefunded * rafflePrice * 975) / 1000;
        usersInfo[msg.sender].rafflesPurchased = 0; // will cause revert if they call this again 
        msg.sender.call{value: refundAmount}("");
    }

    // Allows owner to add users to the KOL Whitelist
    function setKOLWhitelist(address[] memory users, bool value) external onlyOwner {
        for(uint256 i = 0; i < users.length; i++) {
            KOLWhitelist[users[i]] = value;
        }
    }

    // Allows owner to add users to the Super KOL Whitelist
    function setSuperKOLWhitelist(address[] memory users, bool value) external onlyOwner {
        for(uint256 i = 0; i < users.length; i++) {
            superKOLWhitelist[users[i]] = value;
        }
    }

    // Allows the owner to set the number of tokens won per raffle
    function setRaffleAmount(uint256 amount) external onlyOwner {
        raffleAmount = amount;
    }

    // Allows the owner to set the price of each raffle entry
    function setRafflePrice(uint256 amount) external onlyOwner {
        if(block.timestamp > launchTime + 14400) {
            // Can only change the price before raffles are purchased
            revert OutsideTimeWindow();
        }

        rafflePrice = amount;
    }

    // Sets the Chainlink VRF gas callback limit
    function setGasLimit(uint256 limit) external onlyOwner {
        callbackGasLimit = uint32(limit);
    }

    // Sets the Chainlink VRF gas callback limit
    function setSubId(uint256 id) external onlyOwner {
        subscriptionId = id;
    }

    // Sets the Chainlink keyhash
    function setKeyHash(bytes32 newHash) external onlyOwner {
        keyHash = newHash;
    }

    // Withdraws all ETH from the contract - should not be used until users are given sufficient time to refund their tickets
    function withdrawETH() external onlyOwner {
        msg.sender.call{value: address(this).balance}(""); // This will withdraw all ETH including potential ETH for refunds
    }

    // Withdraws the ETH collected in phases one and two - should only be called after phase 2 and before calling withdrawETHNoRefunds
    function withdrawETHNoRaffle() external onlyOwner {
        uint256 amount = phaseOneTwoETH;
        phaseOneTwoETH = 0;
        msg.sender.call{value: amount}(""); 
    }

    // Withdraws all ETH not allocated to refunds 
    function withdrawETHNoRefunds() external onlyOwner {
        if(block.timestamp < launchTime + 100800 ) {
            revert OutsideTimeWindow();
        }
        uint256 totalRefunds = raffleEntries.length; // all winners should be popped from the array by now 
        uint256 refundAmount = (totalRefunds * rafflePrice * 975) / 1000;
        msg.sender.call{value: address(this).balance - refundAmount}(""); 
    }

    // Withdraws all of a specified token to a contract - should only be used on the presale token in case of emergency
    function emergencyWithdrawTokens(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}

    function _verifyTokenOwner(uint256 NFTId) internal view returns(bool) {
        address NFTOwner = nftAddress.ownerOf(NFTId);

        // check sender is owner
        if (NFTOwner == msg.sender) return true;

        // check with delegate registry v2
        if (
            delegateRegistryV2.checkDelegateForERC721(
                msg.sender,
                NFTOwner,
                address(nftAddress),
                NFTId,
                ''
            )
        ) return true;

        // check with delegate registry v1
        if (
            delegateRegistryV1.checkDelegateForToken(
                msg.sender,
                NFTOwner,
                address(nftAddress),
                NFTId
            )
        ) return true;

        // false if not owner or delegate
        return false;
    }
}
// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.13;

/**
 * @title IDelegateRegistry
 * @custom:version 2.0
 * @custom:author foobar (0xfoobar)
 * @notice A standalone immutable registry storing delegated permissions from one address to another
 */
interface IDelegateRegistry {
    /// @notice Delegation type, NONE is used when a delegation does not exist or is revoked
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }

    /// @notice Struct for returning delegations
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice Emitted when an address delegates or revokes rights for their entire wallet
    event DelegateAll(address indexed from, address indexed to, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for a contract address
    event DelegateContract(address indexed from, address indexed to, address indexed contract_, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an ERC721 tokenId
    event DelegateERC721(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, bool enable);

    /// @notice Emitted when an address delegates or revokes rights for an amount of ERC20 tokens
    event DelegateERC20(address indexed from, address indexed to, address indexed contract_, bytes32 rights, uint256 amount);

    /// @notice Emitted when an address delegates or revokes rights for an amount of an ERC1155 tokenId
    event DelegateERC1155(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, uint256 amount);

    /// @notice Thrown if multicall calldata is malformed
    error MulticallFailed();

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
     * @param data The encoded function data for each of the calls to make to this contract
     * @return results The results from each of the calls passed in via data
     */
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for all contracts
     * @param to The address to act as delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateAll(address to, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific contract
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateContract(address to, address contract_, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific ERC721 token
     * @param to The address to act as delegate
     * @param contract_ The contract whose rights are being delegated
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param enable Whether to enable or disable this delegation, true delegates and false revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC721(address to, address contract_, uint256 tokenId, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC20 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address for the fungible token contract
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC20(address to, address contract_, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * @notice Allow the delegate to act on behalf of `msg.sender` for a specific amount of ERC1155 tokens
     * @dev The actual amount is not encoded in the hash, just the existence of a amount (since it is an upper bound)
     * @param to The address to act as delegate
     * @param contract_ The address of the contract that holds the token
     * @param tokenId The token id to delegate
     * @param rights Specific subdelegation rights granted to the delegate, pass an empty bytestring to encompass all rights
     * @param amount The amount of that token id to delegate, > 0 delegates and 0 revokes
     * @return delegationHash The unique identifier of the delegation
     */
    function delegateERC1155(address to, address contract_, uint256 tokenId, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);

    /**
     * ----------- CHECKS -----------
     */

    /**
     * @notice Check if `to` is a delegate of `from` for the entire wallet
     * @param to The potential delegate address
     * @param from The potential address who delegated rights
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on the from's behalf
     */
    function checkDelegateForAll(address to, address from, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specified `contract_` or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet or that specific contract
     */
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);

    /**
     * @notice Check if `to` is a delegate of `from` for the specific `contract` and `tokenId`, the entire `contract_`, or the entire wallet
     * @param to The delegated address to check
     * @param contract_ The specific contract address being checked
     * @param tokenId The token id for the token to delegating
     * @param from The wallet that issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return valid Whether delegate is granted to act on from's behalf for entire wallet, that contract, or that specific tokenId
     */
    function checkDelegateForERC721(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (bool);

    /**
     * @notice Returns the amount of ERC20 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC20(address to, address from, address contract_, bytes32 rights) external view returns (uint256);

    /**
     * @notice Returns the amount of a ERC1155 tokens the delegate is granted rights to act on the behalf of
     * @param to The delegated address to check
     * @param contract_ The address of the token contract
     * @param tokenId The token id to check the delegated amount of
     * @param from The cold wallet who issued the delegation
     * @param rights Specific rights to check for, pass the zero value to ignore subdelegations and check full delegations only
     * @return balance The delegated balance, which will be 0 if the delegation does not exist
     */
    function checkDelegateForERC1155(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (uint256);

    /**
     * ----------- ENUMERATIONS -----------
     */

    /**
     * @notice Returns all enabled delegations a given delegate has received
     * @param to The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all enabled delegations an address has given out
     * @param from The address to retrieve delegations for
     * @return delegations Array of Delegation structs
     */
    function getOutgoingDelegations(address from) external view returns (Delegation[] memory delegations);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has received
     * @param to The address to retrieve incoming delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getIncomingDelegationHashes(address to) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns all hashes associated with enabled delegations an address has given out
     * @param from The address to retrieve outgoing delegation hashes for
     * @return delegationHashes Array of delegation hashes
     */
    function getOutgoingDelegationHashes(address from) external view returns (bytes32[] memory delegationHashes);

    /**
     * @notice Returns the delegations for a given array of delegation hashes
     * @param delegationHashes is an array of hashes that correspond to delegations
     * @return delegations Array of Delegation structs, return empty structs for nonexistent or revoked delegations
     */
    function getDelegationsFromHashes(bytes32[] calldata delegationHashes) external view returns (Delegation[] memory delegations);

    /**
     * ----------- STORAGE ACCESS -----------
     */

    /**
     * @notice Allows external contracts to read arbitrary storage slots
     */
    function readSlot(bytes32 location) external view returns (bytes32);

    /**
     * @notice Allows external contracts to read an arbitrary array of storage slots
     */
    function readSlots(bytes32[] calldata locations) external view returns (bytes32[] memory);
}
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.17;

/**
 * @title An immutable registry contract to be deployed as a standalone primitive
 * @dev See EIP-5639, new project launches can read previous cold wallet -> hot wallet delegations
 * from here and integrate those permissions into their flow
 */
interface IDelegationRegistry {
    /// @notice Delegation type
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        TOKEN
    }

    /// @notice Info about a single delegation, used for onchain enumeration
    struct DelegationInfo {
        DelegationType type_;
        address vault;
        address delegate;
        address contract_;
        uint256 tokenId;
    }

    /// @notice Info about a single contract-level delegation
    struct ContractDelegation {
        address contract_;
        address delegate;
    }

    /// @notice Info about a single token-level delegation
    struct TokenDelegation {
        address contract_;
        uint256 tokenId;
        address delegate;
    }

    /// @notice Emitted when a user delegates their entire wallet
    event DelegateForAll(address vault, address delegate, bool value);

    /// @notice Emitted when a user delegates a specific contract
    event DelegateForContract(address vault, address delegate, address contract_, bool value);

    /// @notice Emitted when a user delegates a specific token
    event DelegateForToken(address vault, address delegate, address contract_, uint256 tokenId, bool value);

    /// @notice Emitted when a user revokes all delegations
    event RevokeAllDelegates(address vault);

    /// @notice Emitted when a user revoes all delegations for a given delegate
    event RevokeDelegate(address vault, address delegate);

    /**
     * -----------  WRITE -----------
     */

    /**
     * @notice Allow the delegate to act on your behalf for all contracts
     * @param delegate The hotwallet to act on your behalf
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForAll(address delegate, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific contract
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForContract(address delegate, address contract_, bool value) external;

    /**
     * @notice Allow the delegate to act on your behalf for a specific token
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking
     */
    function delegateForToken(address delegate, address contract_, uint256 tokenId, bool value) external;

    /**
     * @notice Revoke all delegates
     */
    function revokeAllDelegates() external;

    /**
     * @notice Revoke a specific delegate for all their permissions
     * @param delegate The hotwallet to revoke
     */
    function revokeDelegate(address delegate) external;

    /**
     * @notice Remove yourself as a delegate for a specific vault
     * @param vault The vault which delegated to the msg.sender, and should be removed
     */
    function revokeSelf(address vault) external;

    /**
     * -----------  READ -----------
     */

    /**
     * @notice Returns all active delegations a given delegate is able to claim on behalf of
     * @param delegate The delegate that you would like to retrieve delegations for
     * @return info Array of DelegationInfo structs
     */
    function getDelegationsByDelegate(address delegate) external view returns (DelegationInfo[] memory);

    /**
     * @notice Returns an array of wallet-level delegates for a given vault
     * @param vault The cold wallet who issued the delegation
     * @return addresses Array of wallet-level delegates for a given vault
     */
    function getDelegatesForAll(address vault) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault and contract
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract you're delegating
     * @return addresses Array of contract-level delegates for a given vault and contract
     */
    function getDelegatesForContract(address vault, address contract_) external view returns (address[] memory);

    /**
     * @notice Returns an array of contract-level delegates for a given vault's token
     * @param vault The cold wallet who issued the delegation
     * @param contract_ The address for the contract holding the token
     * @param tokenId The token id for the token you're delegating
     * @return addresses Array of contract-level delegates for a given vault's token
     */
    function getDelegatesForToken(address vault, address contract_, uint256 tokenId)
        external
        view
        returns (address[] memory);

    /**
     * @notice Returns all contract-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of ContractDelegation structs
     */
    function getContractLevelDelegations(address vault)
        external
        view
        returns (ContractDelegation[] memory delegations);

    /**
     * @notice Returns all token-level delegations for a given vault
     * @param vault The cold wallet who issued the delegations
     * @return delegations Array of TokenDelegation structs
     */
    function getTokenLevelDelegations(address vault) external view returns (TokenDelegation[] memory delegations);

    /**
     * @notice Returns true if the address is delegated to act on the entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForAll(address delegate, address vault) external view returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a token contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForContract(address delegate, address vault, address contract_)
        external
        view
        returns (bool);

    /**
     * @notice Returns true if the address is delegated to act on your behalf for a specific token, the token's contract or an entire vault
     * @param delegate The hotwallet to act on your behalf
     * @param contract_ The address for the contract you're delegating
     * @param tokenId The token id for the token you're delegating
     * @param vault The cold wallet who issued the delegation
     */
    function checkDelegateForToken(address delegate, address vault, address contract_, uint256 tokenId)
        external
        view
        returns (bool);
}