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

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

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
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RafldexPVP_V1 is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;
    address constant vrfCoordinator =
        0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
    address constant link_token_contract =
        0x514910771AF9Ca656af840dff83E8264EcF986CA;
    bytes32 private keyHash =
        0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;

    uint16 private requestConfirmations = 3;
    uint32 private callbackGasLimit = 2500000;
    uint32 private numWords = 1;
    uint64 private subscriptionId = 810;

    struct RandomResult {
        uint256 randomNumber;
        uint256 nomalizedRandomNumber;
    }
    struct RaffleInfo {
        uint256 id;
        uint256 size;
    }

    mapping(uint256 => RandomResult) public requests;
    mapping(uint256 => RaffleInfo) public chainlinkRaffleInfo;

    event TokenAdded(address _address);
    event RequestFulfilled(
        uint256 requestId,
        uint256 randomNumber,
        uint256 indexed raffleId
    );
    event RequestSent(uint256 requestId, uint32 numWords);
    event RaffleCreated(
        uint256 indexed raffleId,
        address coinAddress,
        uint256 amount
    );
    event RaffleDrawn(
        uint256 indexed raffleId,
        address indexed winner,
        uint256 amountRaised,
        uint256 randomNumber
    );
    event EntryBought(
        uint256 indexed raffleId,
        address indexed buyer,
        uint256 currentSize,
        uint256 numberEntries
    );

    event RaffleCancelled(uint256 indexed raffleId, uint256 amountRaised);
    event SetWinnerTriggered(uint256 indexed raffleId, uint256 amountRaised);

    struct EntriesBought {
        address player;
        uint256 currentEntriesLength;
        uint256 entries;
    }
    mapping(uint256 => EntriesBought[]) public entriesList;

    enum STATUS {
        CREATED,
        PENDING_DRAW,
        DRAWING,
        DRAWN,
        CANCELLED
    }

    struct RaffleStruct {
        STATUS status;
        address collateralAddress;
        uint256 collateralAmount;
        address tokenPayment;
        uint256 entriesSupply;
        uint256 pricePerEntry;
        address winner;
        uint256 randomNumber;
        uint256 maxEntriesUser;
        address creator;
        uint256 platformPercentage;
        uint256 entriesSold;
    }

    RaffleStruct[] public raffles;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address payable private platformWallet =
        payable(0x2300Ae69d7D1Ea0457aD79e822422888e3Ee3e87);

    uint256 public COMMISSION = 1000; //10%

    mapping(address => bool) public TokenAddresses; //token addresses that can be in raffle
    mapping(address => uint256) public minimumAmountToken; //minimum amount depending in token

    bool public createEnabled = true;

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link_token_contract);
        _setupRole(OPERATOR_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        minimumAmountToken[address(0)] = 30000000000000000; //0.03 eth ~ 50$
    }

    modifier onlyRole(bytes32 role, address account) {
        _checkRole(role, account);
        _;
    }

    function createRaffle(address _collateralAddress, uint256 _collateralAmount)
        external
        payable
        nonReentrant
        returns (uint256)
    {
        require(createEnabled, "Create raffle not enabled.");
        uint256 totalEth;
        require(
            _collateralAmount > 0 &&
                _collateralAmount >= minimumAmountToken[_collateralAddress],
            "Amount can't be null / minimum amount"
        );
        if (_collateralAddress == address(0)) {
            totalEth += _collateralAmount;
        } else {
            require(
                TokenAddresses[_collateralAddress],
                "Token Address not added "
            );
            safeTransferFrom(
                msg.sender,
                address(this),
                _collateralAddress,
                _collateralAmount
            );
        }
        require(msg.value >= totalEth, "Total mismatched");

        uint256 _commissionInBasicPoints;
        if (hasRole(OPERATOR_ROLE, msg.sender)) {
            _commissionInBasicPoints = 0;
        } else {
            _commissionInBasicPoints = COMMISSION;
        }

        uint256 _numberEntries = 1;

        RaffleStruct memory raffle = RaffleStruct({
            status: STATUS.CREATED,
            collateralAddress: _collateralAddress,
            collateralAmount: _collateralAmount,
            tokenPayment: _collateralAddress,
            pricePerEntry: _collateralAmount,
            entriesSupply: 2,
            maxEntriesUser: 1,
            winner: address(0),
            randomNumber: 0,
            creator: msg.sender,
            platformPercentage: _commissionInBasicPoints,
            entriesSold: _numberEntries
        });

        raffles.push(raffle);
        uint256 idRaffle = raffles.length - 1;
        emit RaffleCreated(idRaffle, _collateralAddress, _collateralAmount);

        EntriesBought memory entryBought = EntriesBought({
            player: address(0),
            currentEntriesLength: 0,
            entries: 0
        });
        entriesList[idRaffle].push(entryBought);
        delete entriesList[idRaffle][0];

        EntriesBought memory entryBoughtCreator = EntriesBought({
            player: msg.sender,
            currentEntriesLength: _numberEntries,
            entries: _numberEntries
        });
        entriesList[idRaffle].push(entryBoughtCreator);

        emit EntryBought(idRaffle, msg.sender, _numberEntries, _numberEntries);

        return idRaffle;
    }

    function buyEntry(uint256 _raffleId) external nonReentrant payable {
        uint256 _numberEntries = 1;
        RaffleStruct storage raffle = raffles[_raffleId];
        require(raffle.status == STATUS.CREATED, "Raffle is not in CREATED");
        require(msg.sender != raffle.creator, "Buyer can't be raffle creator.");

        require(
            raffle.entriesSold + _numberEntries <=
                raffles[_raffleId].entriesSupply,
            "Raffle has reached max entries"
        );

        if (raffle.tokenPayment == address(0)) {
            require(
                msg.value == raffle.pricePerEntry * _numberEntries,
                "msg.value must be equal to the price"
            );
        } else {
            IERC20(raffle.tokenPayment).transferFrom(
                msg.sender,
                address(this),
                raffle.pricePerEntry * _numberEntries
            );
        }

        EntriesBought memory entryBought = EntriesBought({
            player: msg.sender,
            currentEntriesLength: uint256(raffle.entriesSold + _numberEntries),
            entries: _numberEntries
        });
        entriesList[_raffleId].push(entryBought);
        raffle.entriesSold += _numberEntries;

        emit EntryBought(
            _raffleId,
            msg.sender,
            raffle.entriesSold,
            _numberEntries
        );
    }

    function addorRemoveTokens(address[] memory _addresses, bool _isAdded)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            TokenAddresses[_addresses[i]] = _isAdded;
            if (_isAdded == true) {
                emit TokenAdded(_addresses[i]);
            }
        }
    }

    function ChangeSubscriptionId(uint64 _id)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        subscriptionId = _id;
    }

    function ChangecallbackGasLimit(uint32 _number)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        callbackGasLimit = _number;
    }

    function ChangeKeyHash(bytes32 _hash)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        keyHash = _hash;
    }

    function changePlatformWalletAddress(address payable _address)
        external
        onlyOwner
    {
        platformWallet = _address;
    }

    function getEntriesBought(uint256 _raffleId)
        public
        view
        returns (EntriesBought[] memory)
    {
        return entriesList[_raffleId];
    }

    function toggleCreateRaffles()
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        createEnabled = !createEnabled;
    }

    function setMinimumAmountTokenRaffle(address _token, uint256 _amount)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        minimumAmountToken[_token] = _amount;
    }

    function getWinnerAddressFromRandom(
        uint256 _raffleId,
        uint256 _normalizedRandomNumber
    ) public view returns (address) {
        address winner;
        EntriesBought[] storage entries = entriesList[_raffleId];
        for (uint256 i = 0; i < entries.length; i++) {
            uint256 entriesIndex = entries[i].currentEntriesLength;
            if (entriesIndex >= _normalizedRandomNumber) {
                winner = entries[i].player;
                break;
            }
        }
        require(winner != address(0), "Winner not found");
        return winner;
    }

    function requestRandomWords(uint256 _id, uint256 _entriesSold)
        internal
        returns (uint256 requestId)
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        chainlinkRaffleInfo[requestId] = RaffleInfo({
            id: _id,
            size: _entriesSold
        });
        RaffleStruct storage raffle = raffles[_id];
        raffle.status = STATUS.DRAWING;

        emit RequestSent(requestId, numWords);

        return requestId;
    }

    function requestRandomWordsRetry(uint256 _id)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
        returns (uint256 requestId)
    {
        RaffleStruct storage raffle = raffles[_id];

        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        chainlinkRaffleInfo[requestId] = RaffleInfo({
            id: _id,
            size: raffle.entriesSold
        });
        raffle.status = STATUS.DRAWING;

        emit RequestSent(requestId, numWords);

        return requestId;
    }

    function transferNFTsAndFunds(
        uint256 _raffleId,
        uint256 _normalizedRandomNumber
    ) internal nonReentrant {
        RaffleStruct storage raffle = raffles[_raffleId];
        raffle.randomNumber = _normalizedRandomNumber;
        raffle.winner = getWinnerAddressFromRandom(
            _raffleId,
            _normalizedRandomNumber
        );

        uint256 amountBet = raffle.collateralAmount;
        uint256 amountForPlatform = ((amountBet * 2) *
            raffle.platformPercentage) / 10000;
        uint256 amountForWinner = (amountBet * 2) - amountForPlatform;

        if (raffle.tokenPayment == address(0)) {
            (bool sent, ) = raffle.winner.call{value: amountForWinner}("");
            require(sent, "Failed to send Eth");

            (bool sent2, ) = platformWallet.call{value: amountForPlatform}("");
            require(sent2, "Failed send Eth to Platform");
        } else {
            IERC20(raffle.tokenPayment).approve(address(this), amountBet * 2);
            bool sent = IERC20(raffle.tokenPayment).transferFrom(
                address(this),
                raffle.winner,
                amountForWinner
            );
            require(sent, "Failed to send ERC20 Token");
            bool sent2 = IERC20(raffle.tokenPayment).transferFrom(
                address(this),
                platformWallet,
                amountForPlatform
            );
            require(sent2, "Failed to send ERC20 Token to platform");
        }
        raffle.status = STATUS.DRAWN;

        emit RaffleDrawn(
            _raffleId,
            raffle.winner,
            amountBet * 2,
            raffle.randomNumber
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 normalizedRandomNumber = (_randomWords[0] %
            chainlinkRaffleInfo[_requestId].size) + 1;
        RaffleStruct storage raffle = raffles[
            chainlinkRaffleInfo[_requestId].id
        ];

        raffle.randomNumber = normalizedRandomNumber;

        RandomResult memory result = RandomResult({
            randomNumber: _randomWords[0],
            nomalizedRandomNumber: normalizedRandomNumber
        });

        requests[chainlinkRaffleInfo[_requestId].id] = result;

        emit RequestFulfilled(
            _requestId,
            normalizedRandomNumber,
            chainlinkRaffleInfo[_requestId].id
        );
        transferNFTsAndFunds(
            chainlinkRaffleInfo[_requestId].id,
            normalizedRandomNumber
        );
    }

    function setWinnerRaffle(uint256 _raffleId)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
        nonReentrant
    {
        RaffleStruct storage raffle = raffles[_raffleId];
        require(raffle.status == STATUS.CREATED, "Raffle in wrong status");
        require(
            raffle.entriesSold == raffle.entriesSupply,
            "Raffle still not sold out"
        );
        raffle.status = STATUS.PENDING_DRAW;
        uint256 entriesSold = raffle.entriesSold;
        uint256 amountRaised = raffle.collateralAmount * 2;
        requestRandomWords(_raffleId, entriesSold);
        emit SetWinnerTriggered(_raffleId, amountRaised);
    }

    function setWinnerRaffleEmergency(uint256 _raffleId)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        //function in case that chainlink vrf2 doesnt work
        RaffleStruct storage raffle = raffles[_raffleId];
        require(
            raffle.entriesSold == raffle.entriesSupply,
            "Raffle still opened or not sold out"
        );

        uint256 entriesSold = raffle.entriesSold;

        bytes32 baseHash = keccak256(
            abi.encodePacked(
                block.number,
                block.timestamp,
                block.gaslimit,
                block.coinbase
            )
        );
        uint256 normalizedRandomNumber = (uint256(baseHash) % entriesSold) + 1;

        raffle.randomNumber = normalizedRandomNumber;
        transferNFTsAndFunds(_raffleId, normalizedRandomNumber);
        uint256 amountRaised = raffle.collateralAmount * 2;
        emit SetWinnerTriggered(_raffleId, amountRaised);
    }

    function cancelRaffle(uint256 _raffleId) external payable nonReentrant {
        RaffleStruct storage raffle = raffles[_raffleId];

        require(
            raffle.creator == msg.sender || hasRole(OPERATOR_ROLE, msg.sender),
            "Not raffle creator or Operator."
        );
        require(raffle.status == STATUS.CREATED, "Wrong status");
 require(
            raffle.entriesSold < raffle.entriesSupply,
            "Raffle has sold out"
        );
        uint256 amountBet = raffle.collateralAmount;
        uint256 txLength = entriesList[_raffleId].length;

        if (raffle.tokenPayment == address(0)) {
            for (uint256 i = 0; i < txLength; i++) {
                address user = entriesList[_raffleId][i].player;
                if (user != address(0)) {
                    payable(user).transfer(amountBet);
                }
            }
        } else {
            IERC20(raffle.tokenPayment).approve(address(this), amountBet * 2);
            for (uint256 i = 0; i < txLength; i++) {
                address user = entriesList[_raffleId][i].player;
                if (user != address(0)) {
                    IERC20(raffle.tokenPayment).transferFrom(
                        address(this),
                        user,
                        amountBet
                    );
                }
            }
        }

        raffle.status = STATUS.CANCELLED;
        emit RaffleCancelled(_raffleId, amountBet);
    }

    function ChangeCommissionPlatform(uint256 _fee)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        COMMISSION = _fee;
    }

    function cancelRaffleEmergency(uint256 _raffleId)
        external
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        RaffleStruct storage raffle = raffles[_raffleId];
        uint256 amountBet = raffle.collateralAmount;

        uint256 txLength = entriesList[_raffleId].length;
        if (raffle.tokenPayment == address(0)) {
            for (uint256 i = 0; i < txLength; i++) {
                address user = entriesList[_raffleId][i].player;
                if (user != address(0)) {
                    payable(user).transfer(amountBet);
                }
            }
        } else {
            IERC20(raffle.tokenPayment).approve(address(this), amountBet * 2);
            for (uint256 i = 0; i < txLength; i++) {
                address user = entriesList[_raffleId][i].player;
                if (user != address(0)) {
                    IERC20(raffle.tokenPayment).transferFrom(
                        address(this),
                        user,
                        amountBet
                    );
                }
            }
        }

        raffle.status = STATUS.CANCELLED;
        emit RaffleCancelled(_raffleId, amountBet);
    }

    function safeTransferFrom(
        address from,
        address to,
        address tokenAddress,
        uint256 tokenAmount
    ) internal virtual {
        if (tokenAddress == address(0)) {
            payable(to).transfer(tokenAmount);
        } else {
            if (from == address(this)) {
                IERC20(tokenAddress).approve(address(this), tokenAmount);
            }
            IERC20(tokenAddress).transferFrom(from, to, tokenAmount);
        }
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function hasRole(bytes32 role, address account)
        public
        view
        virtual
        returns (bool)
    {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function grantRole(bytes32 role, address account)
        public
        virtual
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account)
        public
        virtual
        onlyRole(OPERATOR_ROLE, msg.sender)
    {
        _revokeRole(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
        }
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
        }
    }
}