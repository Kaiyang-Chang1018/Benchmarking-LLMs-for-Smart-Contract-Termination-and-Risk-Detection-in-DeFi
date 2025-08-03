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
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
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
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
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
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
     * {Errors.FailedCall} error.
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
            revert Errors.InsufficientBalance(address(this).balance, value);
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
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
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
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
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
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./interfaces/IERC721A.sol";
import "./interfaces/ITeamFinanceLocker.sol";
import "./interfaces/IToken.sol";
import "./PrizePoolV2.sol";

/// This token was incubated and launched by PROOF: https://proofplatform.io/projects. The smart contract is audited by SourceHat: https://sourcehat.com/

contract Token is IToken, ERC20, Ownable {

    struct UserInfo {
        bool isFeeExempt;
        bool isTxLimitExempt;
        uint256 lastTxBlock;
        bool isPrizePoolExcluded;
        bool isWhitelisted;
    }

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable pair;

    PrizePool public prizePool;

    address payable public secondaryWallet;

    address payable public immutable proofWallet;
    address payable public immutable proofStaking;

    IERC721A public proofPassNFT;

    uint256 public launchedAt;

    uint256 public maxWallet;
    uint256 public initMaxWallet;
    bool public checkMaxHoldings = true;
    bool public maxWalletChanged;

    uint256 public swapping;
    bool public swapEnabled = true;
    uint256 public swapTokensAtAmount;
    mapping (uint256 => uint256) public swapThrottle;
    uint256 public maxSwapsPerBlock = 4;
    
    FeeInfo public feeTokens;
    FeeInfo public buyFees;
    FeeInfo public sellFees;

    uint256 public restingBuyTotal;
    uint256 public restingSellTotal;
    uint256 public whitelistDuration;
    uint256 public whitelistEndTime;

    bool public isWhitelistActive;
    bool public buyTaxesSettled;
    bool public sellTaxesSettled;

    bool public proofFeeReduced;
    bool public proofFeeRemoved;
    bool public cancelled;

    uint256 public lockID;
    uint256 public immutable lpLockDuration;
    address public immutable lockerAddress;

    mapping (address => UserInfo) public userInfo;

    event SwapAndLiquify(uint256 tokensAutoLiq, uint256 ethAutoLiq);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    error InsufficientLiq();
    error NotWhitelisted();

    constructor(
        uint256 _totalSupply,
        FeeInfo memory _buyFees,
        FeeInfo memory _sellFees,
        uint256 _percentToLP,
        uint256 _lpLockDuration,
        address _secondaryWallet,
        address _proofPassNFT,
        address[] memory _whitelist,
        ProofInfo memory _addresses,
        PrizePoolInfo memory prizePoolArgs
    ) ERC20("Hyperpool", "HYPER") Ownable(msg.sender) payable {
        if (_lpLockDuration < 30 days ||  _percentToLP < 70) {
            revert InvalidConfiguration();
        }
        if (msg.value < 1 ether) {
            revert InsufficientLiq();
        }

        (_buyFees.proof, _sellFees.proof) = (2,2);
        _validateFees(_buyFees, _sellFees);
        restingBuyTotal = _buyFees.total;
        restingSellTotal = _sellFees.total;
        _buyFees.secondary = 15 - _buyFees.proof - _buyFees.main - _buyFees.liquidity;
        _buyFees.total = 15;
        _sellFees.secondary = 20 - _sellFees.proof - _sellFees.main - _sellFees.liquidity;
        _sellFees.total = 20;

        buyFees = _buyFees;
        sellFees = _sellFees;
        // set addresses
        secondaryWallet = payable(_secondaryWallet);
        prizePool = new PrizePool(prizePoolArgs.vrfCoordinator, prizePoolArgs.subscriptionId,  [50, 25, 25], prizePoolArgs.timerStart, prizePoolArgs.drawTimeHours, prizePoolArgs.entriesPerTicket);
        lockerAddress = _addresses.locker;
        proofWallet = payable(_addresses.proofWallet);
        proofStaking = payable(_addresses.proofStaking);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_addresses.router);
        uniswapV2Router = _uniswapV2Router;

        pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uint256 amountToPair = _totalSupply * _percentToLP / 100;
        super._update(address(0), address(this), amountToPair); // mint to contract for liquidity

        // set basic data

        lpLockDuration = _lpLockDuration;
        swapTokensAtAmount = _totalSupply * 5 / 4000;
        initMaxWallet = 250;
        maxWallet = _totalSupply * 250 / 100000; // 100 = .1%
        
        userInfo[address(this)] = UserInfo(true, true, 0, true, true);
        userInfo[pair].isTxLimitExempt = true;
        userInfo[pair].isPrizePoolExcluded = true;
        userInfo[pair].isWhitelisted = true;
        userInfo[owner()].isPrizePoolExcluded = true;
        userInfo[_addresses.router].isPrizePoolExcluded = true;
        userInfo[address(prizePool)].isPrizePoolExcluded = true;

        proofPassNFT = IERC721A(_proofPassNFT);
        whitelistDuration = 120;
        _setWhitelisted(_whitelist);

        _updateAndSetBalance(address(0), owner(), _totalSupply - amountToPair); // mint to owner
    }

    function launch() external payable onlyOwner lockTheSwap {
        if (launchedAt != 0 || cancelled) {
            revert InvalidConfiguration();
        }

        // enable trading
        launchedAt = block.timestamp;
        whitelistEndTime = block.timestamp + whitelistDuration;
        isWhitelistActive = true;

        // add liquidity
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        addLiquidity(balanceOf(address(this)), address(this).balance - msg.value, address(this));

        // add NFT snapshot
        uint256 len = proofPassNFT.totalSupply() + 1;
        for (uint256 i = 1; i < len; ) {
            userInfo[proofPassNFT.ownerOf(i)].isWhitelisted = true;
            unchecked { ++i; }
        }

        // lock liquidity
        uint256 lpBalance = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(lockerAddress, lpBalance);
        
        lockID = ITeamFinanceLocker(lockerAddress).lockToken{value: msg.value}(pair, msg.sender, lpBalance, block.timestamp + lpLockDuration, false, address(0));
    }

    function cancel() external onlyOwner {
        if (launchedAt != 0) {
            revert InvalidConfiguration();
        }
        cancelled = true;

        // send the tokens and eth back to the owner
        _updateAndSetBalance(address(this), owner(), balanceOf(address(this)));
        address(owner()).call{value: address(this).balance}("");
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (swapping == 2 || from == owner() || to == owner() || 
          from == address(this) || to == address(this) || amount == 0) {
            _updateAndSetBalance(from, to, amount);
            return;
        }

        if (launchedAt == 0) {
            revert TradingNotEnabled();
        }

        UserInfo storage sender = userInfo[from];
        UserInfo storage recipient = userInfo[to];

        if (isWhitelistActive) {
            if (block.timestamp < whitelistEndTime) {
                if (!sender.isWhitelisted || !recipient.isWhitelisted)
                {
                    revert NotWhitelisted();
                }
            } else {
                isWhitelistActive = false;
            }
        }

        //start at anywhere from 0.1% to 0.5%, increase by 0.1%, every 10 blocks, until it reaches 1%
        if (!maxWalletChanged) {
            uint256 secondsPassed = block.timestamp - launchedAt;
            uint256 percentage = initMaxWallet + (100 * (secondsPassed / 120));
            if (percentage > 950) {
                percentage = 1000;
                maxWalletChanged = true;
            }
            uint256 newMax = totalSupply() * percentage / 100000;
            if (newMax != maxWallet) {
                maxWallet = newMax;
            }
        }

        if (checkMaxHoldings) {
            if (!recipient.isTxLimitExempt && amount + balanceOf(to) > maxWallet) {
                revert ExceedsMaxWalletAmount();
            }
        }

        uint256 total = feeTokens.total;
        bool canSwap = total >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&
            from != pair &&
            swapThrottle[block.number] < maxSwapsPerBlock
        ) {
            ++swapThrottle[block.number];
            processFees(total, swapTokensAtAmount);
        }
        
        if (!sender.isFeeExempt && !recipient.isFeeExempt) {

            FeeInfo storage _buyFees = buyFees;
            FeeInfo storage _sellFees = sellFees;

            if (!proofFeeRemoved) {
                uint256 secondsPassed = block.timestamp - launchedAt;
                if (!proofFeeReduced && secondsPassed > 1 days) {
                    uint256 totalBuy = _buyFees.total - _buyFees.proof;
                    if (totalBuy == 0) {
                        _buyFees.total = 0;
                        _buyFees.proof = 0;
                    } else {
                        _buyFees.main = _buyFees.main + 1;
                        _buyFees.proof = 1;
                    }
                    uint256 totalSell = _sellFees.total - _sellFees.proof;
                    if (totalSell == 0) {
                        _sellFees.total = 0;
                        _sellFees.proof = 0;
                    } else {
                        _sellFees.main = _sellFees.main + 1;
                        _sellFees.proof = 1;
                    }
                    proofFeeReduced = true;
                } else if (secondsPassed > 31 days) {
                    _buyFees.main += _buyFees.proof;
                    _sellFees.main += _sellFees.proof;
                    _buyFees.proof = 0;
                    _sellFees.proof = 0;
                    proofFeeRemoved = true;
                } else {
                    if (!buyTaxesSettled) {
                        uint256 restingTotal = restingBuyTotal;
                        uint256 feeTotal = restingTotal;
                        if (secondsPassed < 1801) {
                            feeTotal = 15 - (secondsPassed / 120);
                        }
                        if (feeTotal <= restingTotal) {
                            _buyFees.total = restingTotal;
                            _buyFees.secondary = restingTotal - _buyFees.liquidity - _buyFees.main - _buyFees.proof;
                            buyTaxesSettled = true;
                        } else if (feeTotal != _buyFees.total) {
                            _buyFees.total = feeTotal;
                            _buyFees.secondary = feeTotal - _buyFees.liquidity - _buyFees.main - _buyFees.proof;
                        }
                    }
                    if (!sellTaxesSettled) {
                        uint256 restingTotal = restingSellTotal;
                        uint256 feeTotal = restingTotal;
                        if (secondsPassed < 2401) {
                            feeTotal = 20 - (secondsPassed / 120);
                        }
                        if (feeTotal <= restingTotal) {
                            _sellFees.total = restingTotal;
                            _sellFees.secondary = restingTotal - _sellFees.liquidity - _sellFees.main - _sellFees.proof;
                            sellTaxesSettled = true;
                        } else if (feeTotal != _sellFees.total) {
                            _sellFees.total = feeTotal;
                            _sellFees.secondary = feeTotal - _sellFees.liquidity - _sellFees.main - _sellFees.proof;
                        }
                    }
                }
            }

            uint256 fees;
            if (to == pair) { //sell
                fees = _calculateFees(_sellFees, amount);
            } else if (from == pair) { //buy
                fees = _calculateFees(_buyFees, amount);
            }
            if (fees > 0) {
                amount -= fees;
                super._update(from, address(this), fees);
            }
        }

        super._update(from, to, amount);

        if (!sender.isPrizePoolExcluded) {
            try prizePool.setBalance(from, balanceOf(from)) {} catch {}
        }

        if (!recipient.isPrizePoolExcluded) {
            try prizePool.setBalance(to, balanceOf(to)) {} catch {}
        }

    }

    function _calculateFees(FeeInfo memory feeRate, uint256 amount) internal returns (uint256 fees) {
        if (feeRate.total != 0) {
            fees = amount * feeRate.total / 100;
            
            FeeInfo storage _feeTokens = feeTokens;
            _feeTokens.main += fees * feeRate.main / feeRate.total;
            _feeTokens.secondary += fees * feeRate.secondary / feeRate.total;
            _feeTokens.liquidity += fees * feeRate.liquidity / feeRate.total;
            _feeTokens.proof += fees * feeRate.proof / feeRate.total;
            _feeTokens.total += fees;
        }
    }

    function processFees(uint256 total, uint256 amountToSwap) internal lockTheSwap {
        FeeInfo storage _feeTokens = feeTokens;

        FeeInfo memory swapTokens;
        swapTokens.main = amountToSwap * _feeTokens.main / total;
        swapTokens.secondary = amountToSwap * _feeTokens.secondary / total;
        swapTokens.liquidity = amountToSwap * _feeTokens.liquidity / total;
        swapTokens.proof = amountToSwap * _feeTokens.proof / total;

        uint256 amountToPair = swapTokens.liquidity / 2;

        swapTokens.total = amountToSwap - amountToPair;

        uint256 ethBalance = swapTokensForETH(swapTokens.total);

        FeeInfo memory ethSplit;

        ethSplit.main = ethBalance * swapTokens.main / swapTokens.total;
        if (ethSplit.main > 0) {
            address(prizePool).call{value: ethSplit.main}("");
        }

        ethSplit.secondary = ethBalance * swapTokens.secondary / swapTokens.total;
        if (ethSplit.secondary > 0) {
            address(secondaryWallet).call{value: ethSplit.secondary}("");
        }
        
        ethSplit.proof = ethBalance * swapTokens.proof / swapTokens.total;
        if (ethSplit.proof > 0) {
            uint256 revenueSplit = ethSplit.proof / 2;
            address(proofStaking).call{value: revenueSplit}("");
            address(proofWallet).call{value: ethSplit.proof - revenueSplit}("");
        }

        uint256 amountPaired;
        ethSplit.liquidity = address(this).balance;
        if (amountToPair > 0 && ethSplit.liquidity > 0) {
            amountPaired = addLiquidity(amountToPair, ethSplit.liquidity, address(0xdead));
            emit SwapAndLiquify(amountToPair, ethSplit.liquidity);
        }

        uint256 liquidityAdjustment = swapTokens.liquidity - (amountToPair - amountPaired);

        _feeTokens.main -= swapTokens.main;
        _feeTokens.secondary -= swapTokens.secondary;
        _feeTokens.liquidity -= liquidityAdjustment;
        _feeTokens.proof -= swapTokens.proof;
        _feeTokens.total -= swapTokens.main + swapTokens.secondary + swapTokens.proof + liquidityAdjustment;
    }

    function swapTokensForETH(uint256 tokenAmount) internal returns (uint256 ethBalance) {
        uint256 ethBalBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        ethBalance = address(this).balance - ethBalBefore;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address recipient) private returns (uint256) {
        (uint256 amountA,,) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            recipient,
            block.timestamp
        );
        return amountA;
    }

    function burn(uint256 amount) external {
        super._burn(msg.sender, amount);
        if (!userInfo[msg.sender].isPrizePoolExcluded) {
            try prizePool.burn(msg.sender, amount) {} catch {}
            try prizePool.setBalance(msg.sender, balanceOf(msg.sender)) {} catch {}
        }
    }

    function changeFees(
        uint256 liquidityBuy,
        uint256 mainBuy,
        uint256 secondaryBuy,
        uint256 liquiditySell,
        uint256 mainSell,
        uint256 secondarySell
    ) external onlyOwner {
        if (!buyTaxesSettled || !sellTaxesSettled) {
            revert InvalidConfiguration();
        }
        FeeInfo memory _buyFees;
        _buyFees.liquidity = liquidityBuy;
        _buyFees.main = mainBuy;
        _buyFees.secondary = secondaryBuy;

        FeeInfo memory _sellFees;
        _sellFees.liquidity = liquiditySell;
        _sellFees.main = mainSell;
        _sellFees.secondary = secondarySell;

        (_buyFees.proof, _sellFees.proof) = launchedAt != 0 ? _calculateProofFee() : (2,2);
        _validateFees(_buyFees, _sellFees);
        buyFees = _buyFees;
        sellFees = _sellFees;
    }

    function _calculateProofFee() internal returns (uint256, uint256) {
        uint256 secondsPassed = block.timestamp - launchedAt;
        if (secondsPassed > 31 days) {
            proofFeeRemoved = true;
            return (0,0);
        } else if (secondsPassed > 1 days) {
            proofFeeReduced = true;
            return (1,1);
        } else {
            return (2,2);
        }
    }

    function _validateFees(FeeInfo memory _buyFees, FeeInfo memory _sellFees) internal pure {
        _buyFees.total = _buyFees.liquidity + _buyFees.main + _buyFees.secondary;
        if (_buyFees.total == 0) {
            _buyFees.proof = 0;
        } else {
             _buyFees.total += _buyFees.proof;
        }

        _sellFees.total = _sellFees.liquidity + _sellFees.main + _sellFees.secondary;
        if (_sellFees.total == 0) {
            _sellFees.proof = 0;
        } else {
            _sellFees.total += _sellFees.proof;
        }

        if (_buyFees.total > 7 || _sellFees.total > 7) {
            revert InvalidConfiguration();
        }

    }

    function setCheckMaxHoldingsEnabled(bool _enabled) external onlyOwner{
        checkMaxHoldings = _enabled;
    }

    function setFeeExempt(address account, bool value) public onlyOwner {
        userInfo[account].isFeeExempt = value;
    }

    function setFeeExempt(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i; i < len; i++) {
            userInfo[accounts[i]].isFeeExempt = true;
        }
    }

    function setSecondaryWallet(address newWallet) external onlyOwner {
        secondaryWallet = payable(newWallet);
    }

    function updatePrizePool(address newAddress) public onlyOwner {
        require(newAddress != address(prizePool));

        PrizePool newPrizePool = PrizePool(payable(newAddress));

        require(newPrizePool.owner() == address(this));

        prizePool = newPrizePool;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setMaxSwapsPerBlock(uint256 _maxSwaps) external onlyOwner {
        maxSwapsPerBlock = _maxSwaps;
    }

    function setAllocationPercentages(uint256 _dailyAllocation, uint256 _weeklyAllocation, uint256 _monthlyAllocation) external onlyOwner {
        prizePool.setAllocationPercentages(_dailyAllocation, _weeklyAllocation, _monthlyAllocation);
    }

    function updatePoolIntervals(
        uint256[] calldata newIntervals
    ) external onlyOwner {
        prizePool.updatePoolIntervals(newIntervals);
    }

    function updateEntriesPerTicket(uint256 _entriesPerTicket) external onlyOwner {
        prizePool.updateEntriesPerTicket(_entriesPerTicket);
    }

    function updateBurnMultiplier(uint256 newMultiplier) external onlyOwner {
        prizePool.updateBurnMultiplier(newMultiplier);
    }

    function updateGasLimit(uint32 newLimit) external onlyOwner {
        prizePool.updateGasLimit(newLimit);
    }

    function setPrizeExcluded(address account, bool value) public onlyOwner {
        userInfo[account].isPrizePoolExcluded = value;
        try prizePool.setExcluded(account, value, balanceOf(account)) {} catch {}
    }

    function setPrizeExcludedMany(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i; i < len; i++) {
            try prizePool.setExcluded(accounts[i], true, balanceOf(accounts[i])) {} catch {}
        }
    }

    function setWhitelisted(address[] memory accounts) external onlyOwner {
        if (launchedAt != 0) {
            revert InvalidConfiguration();
        }
        _setWhitelisted(accounts);
    }

    function _setWhitelisted(address[] memory accounts) internal {
        uint256 len = accounts.length;
        for (uint256 i; i < len; i++) {
            userInfo[accounts[i]].isWhitelisted = true;
        }
    }

    function pausePrizeDraws(bool value) external onlyOwner {
        prizePool.pausePrizeDraws(value);
    }

    function updateDrawTime(uint256 timeInHours) external onlyOwner {
        prizePool.updateDrawTime(timeInHours);
    }

    function updateCoordinator(address _coordinator) external onlyOwner {
        prizePool.updateCoordinator(_coordinator);
    }

    function updateKeyHash(bytes32 _keyhash) external onlyOwner {
        prizePool.updateKeyHash(_keyhash);
    }

    function updateSubscriptionID(uint256 _subID) external onlyOwner {
        prizePool.updateSubscriptionID(_subID);
    }

    function withdrawStuckTokens() external onlyOwner {
        _updateAndSetBalance(address(this), _msgSender(), balanceOf(address(this)) - feeTokens.total);
    }

    function _updateAndSetBalance(address from, address to, uint256 amount) internal {
        super._update(from, to, amount);
        if (!userInfo[from].isPrizePoolExcluded) {
            try prizePool.setBalance(from, balanceOf(from)) {} catch {}
        }

        if (!userInfo[to].isPrizePoolExcluded) {
            try prizePool.setBalance(to, balanceOf(to)) {} catch {}
        }
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(address(0xdead));
    }

    modifier lockTheSwap() {
        swapping = 2;
        _;
        swapping = 1;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function version() public pure returns (uint8) {
        return 1;
    }

    receive() external payable {}
 
}
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

error InvalidConfiguration();
error StakeLocked();
error DrawNotReady();
error RegistrationError();
error LotteryPaused();
error InsufficientStakeBalance();

event WinnerSelected(uint256 poolDraw, address winner, uint256 amount, uint256 winningNumber);

contract PrizePool is VRFConsumerBaseV2, Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 staked;
        uint256 burnBonus;
        mapping(uint256 => uint256[]) indexes;
        uint256 lastStakedTime;
    }

    struct Pool {
        uint256 lastDrawTime;
        uint256 interval;
        uint256 allocPercent;
        uint256 currentRewards;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => Pool) public prizePools;

    IERC20 public hype;
    uint256 public DRAW_TIME_OF_DAY = 0; //used to determine what time we want the next draw to be available
    //Seconds from midnight, for example if we want 3pm DRAW_TIME_OF_DAY should be 15 hours

    uint256[] private currentPoolDraws;
    uint256 public burnMultiplier = 4;
    uint256 remainder; //for leftover wei after distributions to pools

    uint256 subscriptionId;
    IVRFCoordinatorV2Plus coordinator;
    address vrfCoordinator;
    bytes32 keyHash = 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef; //mainnet
    uint32 callbackGasLimit = 15000000;
    uint16 requestConfirmations = 3;
    bool paused = false;

    uint256 public entriesPerTicket;
    uint256 public totalTickets;
    mapping(uint256 => uint256) public totalToUserIndexes;
    mapping(uint256 => address[]) ticketList;
    uint256 currListID;

    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        uint8[3] memory poolAllocations,
        uint256 drawTimerStart,
        uint256 drawTimeHours,
        uint256 _entriesPerTicket
    ) VRFConsumerBaseV2(_vrfCoordinator) Ownable(msg.sender) {
        hype = IERC20(msg.sender);
        if (poolAllocations[0] + poolAllocations[1] + poolAllocations[2] != 100) {
            revert InvalidConfiguration();
        }
        prizePools[0] = Pool(
            drawTimerStart,
            1 days,
            poolAllocations[0],
            0
        );
        prizePools[1] = Pool(
            drawTimerStart,
            7 days,
            poolAllocations[1],
            0
        );
        prizePools[2] = Pool(
            drawTimerStart,
            30 days,
            poolAllocations[2],
            0
        );

        entriesPerTicket = _entriesPerTicket;
        coordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        DRAW_TIME_OF_DAY = drawTimeHours * 3600;
    }

    function setBalance(address account, uint256 newBalance) external onlyOwner {
    	_setBalance(account, newBalance);
    }

    function _setBalance(address account, uint256 newBalance) internal {
    	UserInfo storage user = userInfo[account];
        uint256 id = currListID;
        uint256 numTickets = (newBalance + (user.staked * 2) + (user.burnBonus)) / entriesPerTicket;
        if(numTickets > user.indexes[id].length) {
    		addUser(account, numTickets);
    	} else if (numTickets < user.indexes[id].length) {
    		removeUser(account, numTickets);
    	}
    }

    function addUser(address account, uint256 numTickets) internal {
        UserInfo storage user = userInfo[account];
        uint256 id = currListID;
        uint256 toAdd = numTickets - user.indexes[id].length;
        address[] storage list = ticketList[id];
        uint256 startingIndex = list.length;
        for (uint256 i; i < toAdd; i++) {
            user.indexes[id].push(startingIndex + i);
            list.push(account);
            totalToUserIndexes[startingIndex + i] = user.indexes[id].length - 1;
        }
        totalTickets += toAdd;
    }


    function removeUser(address account, uint256 numTickets) internal {
        UserInfo storage user = userInfo[account];
        uint256 id = currListID;
        uint256 toRemove = user.indexes[id].length - numTickets;
        address[] storage _ticketList = ticketList[id];
        for (uint256 i; i < toRemove; i++) {
            uint256 lastTicket = _ticketList.length - 1;
            uint256[] memory userIndexes = user.indexes[id];
            UserInfo storage movedUser = userInfo[_ticketList[lastTicket]];
            _ticketList[userIndexes[userIndexes.length - 1]] = _ticketList[lastTicket]; //replace last user entry in list with last overall entry
            movedUser.indexes[id][totalToUserIndexes[lastTicket]] = userIndexes[userIndexes.length - 1]; //update moved users index array
            totalToUserIndexes[userIndexes[userIndexes.length - 1]] = totalToUserIndexes[lastTicket]; //update index tracker
            user.indexes[id].pop();
            _ticketList.pop();
        }
        totalTickets -= toRemove;
    }


    receive() external payable {
        uint256 toDistribute = msg.value + remainder;

        Pool storage pool0 = prizePools[0];
        Pool storage pool1 = prizePools[1];
        Pool storage pool2 = prizePools[2];

        uint256 pool0Reward = (toDistribute * pool0.allocPercent) / 100;
        uint256 pool1Reward = (toDistribute * pool1.allocPercent) / 100;
        uint256 pool2Reward = (toDistribute * pool2.allocPercent) / 100;

        pool0.currentRewards += pool0Reward;
        pool1.currentRewards += pool1Reward;
        pool2.currentRewards += pool2Reward;

        remainder = toDistribute - pool0Reward - pool1Reward - pool2Reward;
    }

    function stake(uint256 amount) external {
        userInfo[msg.sender].staked += amount;
        userInfo[msg.sender].lastStakedTime = block.timestamp;
        hype.safeTransferFrom(address(msg.sender), address(this), amount);
    }

    function unstake(uint256 amount) external {
        if (block.timestamp < userInfo[msg.sender].lastStakedTime + 7 days) {
            revert StakeLocked();
        }
        if (userInfo[msg.sender].staked < amount) {
            revert InsufficientStakeBalance();
        }
        userInfo[msg.sender].staked -= amount;
        hype.safeTransfer(address(msg.sender), amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        userInfo[account].burnBonus += amount * burnMultiplier;
    }

    function draw() external {
        if (paused) {
            revert LotteryPaused();
        }
        delete currentPoolDraws;
        uint256 available;
        uint256 currTime = block.timestamp;
        uint256 timeOfDay = DRAW_TIME_OF_DAY;
        for (uint256 i = 0; i < 3; i++) {
            Pool storage pool = prizePools[i];
            if (pool.lastDrawTime + pool.interval <= block.timestamp && pool.currentRewards != 0) {
                prizePools[i].lastDrawTime = currTime - (currTime % 86400) + timeOfDay;
                currentPoolDraws.push(i);
                available++;
            }
        }
        if (available == 0 || totalTickets == 0) {
            revert DrawNotReady();
        }
        requestRandomWords(callbackGasLimit, requestConfirmations, 1);
    }

    function selectWinner(uint256 randomness) internal {
        uint256[] memory poolIDs = currentPoolDraws;
        uint256 numberOfDraws = poolIDs.length;
        uint256 randNonce;
        bool success;
        for (uint256 i; i < numberOfDraws; i++) {
            uint256 winningNumber = (uint256(keccak256(abi.encodePacked(randomness, randNonce))) % totalTickets);
            randNonce++;
            uint256 poolReward = prizePools[poolIDs[i]].currentRewards;
            (success, ) = ticketList[currListID][winningNumber].call{value: poolReward}("");
            if (success) prizePools[poolIDs[i]].currentRewards = 0;
            emit WinnerSelected(poolIDs[i], ticketList[currListID][winningNumber], poolReward, winningNumber);
        }
    }

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

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory randomWords
    ) internal override {
        selectWinner(randomWords[0]);
    }

    function register() external {
        _setBalance(msg.sender, hype.balanceOf(msg.sender));
    }

    /****************** OWNER CONTROL ******************/

    function setAllocationPercentages(
        uint256 pool1Allocation,
        uint256 pool2Allocation,
        uint256 pool3Allocation
    ) external onlyOwner {
        _setAllocationPercentages(
            pool1Allocation,
            pool2Allocation,
            pool3Allocation
        );
    }

    function _setAllocationPercentages(
        uint256 _pool1Allocation,
        uint256 _pool2Allocation,
        uint256 _pool3Allocation
    ) internal {
        if (_pool1Allocation + _pool2Allocation + _pool3Allocation != 100) {
            revert InvalidConfiguration();
        }

        prizePools[0].allocPercent = _pool1Allocation;
        prizePools[1].allocPercent = _pool2Allocation;
        prizePools[2].allocPercent = _pool3Allocation;
    }

    function updatePoolIntervals(
        uint256[] calldata newIntervals
    ) external onlyOwner {
        if (newIntervals.length != 3 ||
            newIntervals[0] % 86400 != 0 ||
            newIntervals[1] % 86400 != 0 ||
            newIntervals[2] % 86400 != 0
        ) { revert InvalidConfiguration(); }
        prizePools[0].interval = newIntervals[0];
        prizePools[1].interval = newIntervals[1];
        prizePools[2].interval = newIntervals[2];
    }

    function updateEntriesPerTicket(uint256 _entriesPerTicket) external onlyOwner {
        if (_entriesPerTicket < 10**9) {
            revert InvalidConfiguration();
        }
        entriesPerTicket = _entriesPerTicket;
        currListID++;
        totalTickets = 0;
    }

    function updateBurnMultiplier(uint256 newMultiplier) external onlyOwner {
        burnMultiplier = newMultiplier;
    }

    function updateGasLimit(uint32 newLimit) external onlyOwner {
        callbackGasLimit = newLimit;
    }

    function setExcluded(address account, bool value, uint256 balance) external onlyOwner {
        if (value) {
            removeUser(account, 0);
        } else {
            _setBalance(account, balance);
        }
    }
    
    function pausePrizeDraws(bool value) external onlyOwner {
        paused = value;
    }

    function updateDrawTime(uint256 timeInHours) external onlyOwner {
        DRAW_TIME_OF_DAY = timeInHours * 3600;
    }

    function updateCoordinator(address _coordinator) external onlyOwner {
        coordinator = IVRFCoordinatorV2Plus(_coordinator);
    }

    function updateKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }

    function updateSubscriptionID(uint256 _subId) external onlyOwner {
        subscriptionId = _subId;
    }

    function getUserPoints(address user) external view returns (uint256) {
        UserInfo storage _user = userInfo[user];
        return (hype.balanceOf(user) + (_user.staked * 2) + (_user.burnBonus));
    }

    function getUserTickets(address user) external view returns (uint256) {
        return userInfo[user].indexes[currListID].length;
    }

}
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

interface IERC721A {
    function totalSupply() external returns (uint256);
    function ownerOf(uint256) external returns (address);
}
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

interface ITeamFinanceLocker {
    function lockToken(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256 _amount,
        uint256 _unlockTime,
        bool _mintNFT, 
        address referrer
    ) external payable returns (uint256 _id);
}
// SPDX-License-Identifier: None

pragma solidity ^0.8.24;

interface IToken {
    struct FeeInfo {
        uint256 main;
        uint256 secondary;
        uint256 liquidity;
        uint256 proof;
        uint256 total;
    }

    struct ProofInfo {
        address locker;
        address router;
        address proofWallet;
        address proofStaking;
    }

    struct PrizePoolInfo {
        address vrfCoordinator;
        uint256 subscriptionId;
        uint256 timerStart;
        uint256 drawTimeHours;
        uint256 entriesPerTicket;
    }

    error ExceedsMaxTxAmount();
    error ExceedsMaxWalletAmount();
    error InvalidConfiguration();
    error TradingNotEnabled();
    error TransferDelayEnabled(uint256 currentBlock, uint256 delayedUntil);
}