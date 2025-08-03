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
pragma solidity >=0.8.0;

interface ILiteTicker {
  error NotWrappedNFT();
  error NotDeposited();
  error AlreadyDeposited();

  event Deposited(address indexed wrappedNFT, uint256 indexed nftId);
  event Withdrawn(address indexed wrappedNFT, uint256 indexed nftId);

  /**
   * @dev Virtual deposit and withdraw functions for the wrapped NFTs.
   * @param _tokenId The ID of the NFT to deposit or withdraw.
   */
  function virtualDeposit(bytes32 _identity, uint256 _tokenId, address _receiver)
    external;

  /**
   * @dev Virtual withdraw function for the wrapped NFTs.
   * @param _tokenId The ID of the NFT to withdraw.
   * @param _ignoreRewards Whether to ignore the rewards and withdraw the NFT.
   * @dev The `_ignoreRewards` parameter is primarily used for Hashmasks. When
   * transferring or renaming their NFTs, any
   * claims made will result in the rewards being canceled and returned to the pool. This
   * mechanism is in place to
   * prevent exploitative farming.
   */
  function virtualWithdraw(
    bytes32 _identity,
    uint256 _tokenId,
    address _receiver,
    bool _ignoreRewards
  ) external;

  /**
   * @dev Claim function for the wrapped NFTs.
   * @param _tokenId The ID of the NFT to claim.
   */
  function claim(
    bytes32 _identity,
    uint256 _tokenId,
    address _receiver,
    bool _ignoreRewards
  ) external;

  /**
   * @dev Get the claimable rewards for a given identity.
   * @param _identity The identity of the NFT.
   * @param _extraRewards The extra rewards to add to the total for simulation purposes.
   * @return rewards_ The amount of rewards.
   * @return rewardsToken_ The address of the rewards token.
   */
  function getClaimableRewards(bytes32 _identity, uint256 _extraRewards)
    external
    view
    returns (uint256 rewards_, address rewardsToken_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INFTPass {
  error NoNeedToPay();
  error InvalidBPS();
  error MsgValueTooLow();
  error AlreadyClaimed();
  error InvalidProof();
  error NameTooLong();
  error ClaimingEnded();

  event NFTPassCreated(
    uint256 indexed nftId, string indexed name, address indexed receiver, uint256 cost
  );
  event NFTPassUpdated(
    uint256 indexed nftId, string indexed name, address indexed receiver
  );
  event MaxIdentityPerDayAtInitialPriceUpdated(uint32 newMaxIdentityPerDayAtInitialPrice);
  event PriceIncreaseThresholdUpdated(uint32 newPriceIncreaseThreshold);
  event PriceDecayBPSUpdated(uint32 newPriceDecayBPS);

  struct Metadata {
    string name;
    address walletReceiver;
    uint8 imageIndex;
  }

  /**
   * @param _name The name of the NFT Pass
   * @param _receiverWallet The wallet address that will receive the NFT Pass
   * @param merkleProof The Merkle proof for the NFT Pass
   */
  function claimPass(
    string calldata _name,
    address _receiverWallet,
    bytes32[] calldata merkleProof
  ) external;

  /**
   * @param _name The name of the NFT Pass
   * @param _receiverWallet The wallet address that will receive the NFT Pass
   */
  function create(string calldata _name, address _receiverWallet) external payable;

  /**
   * @param _nftId The ID of the NFT Pass
   * @param _name The name of the NFT Pass
   * @param _receiver The wallet address that will receive the NFT Pass
   * @dev It's nftId or Name, if nftId is 0, it will use the name to find the nftId
   */
  function updateReceiverAddress(uint256 _nftId, string calldata _name, address _receiver)
    external;

  /**
   * @return The cost of the NFT Pass
   */
  function getCost() external view returns (uint256);

  /**
   * @param _nftId The ID of the NFT Pass
   * @param _name The name of the NFT Pass
   */
  function getMetadata(uint256 _nftId, string calldata _name)
    external
    view
    returns (Metadata memory);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IObeliskHashmask {
  error NotLinkedToHolder();
  error NotHashmaskHolder();
  error InsufficientActivationPrice();
  error TransferFailed();
  error ZeroAddress();

  event ActivationPriceSet(uint256 price);
  event HashmaskLinked(
    uint256 indexed hashmaskId, address indexed from, address indexed to
  );
  event TreasurySet(address treasury);

  /**
   * @notice Links a hashmask to the user's account.
   * @param _hashmaskId The ID of the hashmask to link.
   */
  function link(uint256 _hashmaskId) external payable;

  /**
   * @notice Transfers the link of a hashmask to another user without requiring an
   * additional linking fee if the
   * transfer is to another wallet owned by the same user.
   * @param _hashmaskId The ID of the hashmask to transfer.
   * @dev The hashmask.ownerOf() will be set as linker.
   */
  function transferLink(uint256 _hashmaskId) external;

  /**
   * @notice Updates their virtual name to copy the name of the hashmask.
   * @param _hashmaskId The ID of the hashmask to update.
   */
  function updateName(uint256 _hashmaskId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IObeliskNFT {
  event TickerDeactivated(uint256 indexed tokenId, address indexed stakedPool);
  event TickerActivated(uint256 indexed tokenId, address indexed stakedPool);
  event TickerClaimed(uint256 indexed tokenId, address indexed stakedPool);
  event NameUpdated(uint256 indexed tokenId, string name);

  /**
   * @notice Claims the rewards for a given token ID.
   * @param _tokenId The ID of the token to claim rewards for.
   */
  function claim(uint256 _tokenId) external;

  /**
   * @notice Returns the identity information for a given token ID.
   * @param _tokenId The ID of the token to get identity information for.
   * @return identityInTicker_ The identity id in the ticker pools.
   * @return rewardReceiver_ The address that will receive the rewards.
   */
  function getIdentityInformation(uint256 _tokenId)
    external
    view
    returns (bytes32 identityInTicker_, address rewardReceiver_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IObeliskRegistry {
  error TooManyEth();
  error GoalReached();
  error AmountExceedsDeposit();
  error TransferFailed();
  error FailedDeployment();
  error TickerAlreadyExists();
  error NotSupporterDepositor();
  error AlreadyRemoved();
  error SupportNotFinished();
  error NothingToClaim();
  error NotWrappedNFT();
  error CollectionNotAllowed();
  error NotAuthorized();
  error OnlyOneValue();
  error AmountTooLow();
  error ContributionBalanceTooLow();
  error ZeroAddress();
  error CollectionAlreadyAllowed();
  error NoAccess();

  event WrappedNFTCreated(address indexed collection, address indexed wrappedNFT);
  event WrappedNFTEnabled(address indexed collection, address indexed wrappedNFT);
  event WrappedNFTDisabled(address indexed collection, address indexed wrappedNFT);
  event MegapoolFactorySet(address indexed megapoolFactory);
  event TickerCreationAccessSet(address indexed to, bool status);
  event TickerLogicSet(string indexed ticker, address indexed pool, string readableName);
  event NewGenesisTickerCreated(string indexed ticker, address pool);
  event Supported(uint32 indexed supportId, address indexed supporter, uint256 amount);
  event SupportRetrieved(
    uint32 indexed supportId, address indexed supporter, uint256 amount
  );
  event CollectionContributed(
    address indexed collection, address indexed contributor, uint256 amount
  );
  event CollectionContributionWithdrawn(
    address indexed collection, address indexed contributor, uint256 amount
  );
  event Claimed(address indexed collection, address indexed contributor, uint256 amount);
  event SlotBought(address indexed wrappedNFT, uint256 toCollection, uint256 toTreasury);
  event CollectionAllowed(
    address indexed collection,
    uint256 totalSupply,
    uint32 collectionStartedUnixTime,
    bool premium
  );
  event TreasurySet(address indexed treasury);
  event MaxRewardPerCollectionSet(uint256 maxRewardPerCollection);
  event CollectionImageIPFSUpdated(uint256 indexed id, string ipfsImage);

  struct Collection {
    uint256 totalSupply;
    uint256 contributionBalance;
    address wrappedVersion;
    uint32 collectionStartedUnixTime;
    bool allowed;
    bool premium;
  }

  struct Supporter {
    address depositor;
    address token;
    uint128 amount;
    uint32 lockUntil;
    bool removed;
  }

  struct CollectionRewards {
    uint128 totalRewards;
    uint128 claimedRewards;
  }

  struct ContributionInfo {
    uint128 deposit;
    uint128 claimed;
  }

  function isWrappedNFT(address _collection) external view returns (bool);

  /**
   * @notice Contribute to collection
   * @param _collection NFT Collection address
   * @dev Warning: once the collection goal is reached, it cannot be removed
   */
  function addToCollection(address _collection) external payable;

  /**
   * @notice Remove from collection
   * @param _collection Collection address
   * @dev Warning: once the collection goal is reached, it cannot be removed
   */
  function removeFromCollection(address _collection, uint256 _amount) external;

  /**
   * @notice Support the yield pool
   * @param _amount The amount to support with
   * @dev The amount is locked for 30 days
   * @dev if msg.value is 0, the amount is expected to be sent in DAI
   */
  function supportYieldPool(uint256 _amount) external payable;

  /**
   * @notice Retrieve support to yield pool
   * @param _id Support ID
   */
  function retrieveSupportToYieldPool(uint32 _id) external;

  /**
   * @notice Set ticker logic
   * @param _ticker Ticker
   * @param _pool Pool address
   * @param _override Override existing ticker logic. Only owner can override.
   */
  function setTickerLogic(string memory _ticker, address _pool, bool _override) external;

  /**
   * @notice When a slot is bought from the wrapped NFT
   */
  function onSlotBought() external payable;

  /**
   * @notice Get ticker logic
   * @param _ticker Ticker
   */
  function getTickerLogic(string memory _ticker) external view returns (address);

  /**
   * @notice Get supporter
   * @param _id Support ID
   */
  function getSupporter(uint32 _id) external view returns (Supporter memory);

  /**
   * @notice Get user contribution
   * @param _user User address
   * @param _collection Collection address
   */
  function getUserContribution(address _user, address _collection)
    external
    view
    returns (ContributionInfo memory);

  /**
   * @notice Get collection rewards
   * @param _collection Collection address
   */
  function getCollectionRewards(address _collection)
    external
    view
    returns (CollectionRewards memory);

  /**
   * @notice Get collection
   * @param _collection Collection address
   */
  function getCollection(address _collection) external view returns (Collection memory);

  function getCollectionImageIPFS(uint256 _id) external view returns (string memory);
}
/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <arachnid@notdot.net>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */

pragma solidity ^0.8.0;

library strings {
  struct slice {
    uint256 _len;
    uint256 _ptr;
  }

  function memcpy(uint256 dest, uint256 src, uint256 _len) private pure {
    // Copy word-length chunks while possible
    for (; _len >= 32; _len -= 32) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += 32;
      src += 32;
    }

    // Copy remaining bytes
    uint256 mask = type(uint256).max;
    if (_len > 0) {
      mask = 256 ** (32 - _len) - 1;
    }
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }
  }

  /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
  function toSlice(string memory self) internal pure returns (slice memory) {
    uint256 ptr;
    assembly {
      ptr := add(self, 0x20)
    }
    return slice(bytes(self).length, ptr);
  }

  /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
  function len(bytes32 self) internal pure returns (uint256) {
    uint256 ret;
    if (self == 0) {
      return 0;
    }
    if (uint256(self) & type(uint128).max == 0) {
      ret += 16;
      self = bytes32(uint256(self) / 0x100000000000000000000000000000000);
    }
    if (uint256(self) & type(uint64).max == 0) {
      ret += 8;
      self = bytes32(uint256(self) / 0x10000000000000000);
    }
    if (uint256(self) & type(uint32).max == 0) {
      ret += 4;
      self = bytes32(uint256(self) / 0x100000000);
    }
    if (uint256(self) & type(uint16).max == 0) {
      ret += 2;
      self = bytes32(uint256(self) / 0x10000);
    }
    if (uint256(self) & type(uint8).max == 0) {
      ret += 1;
    }
    return 32 - ret;
  }

  /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
  function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {
    // Allocate space for `self` in memory, copy it there, and point ret at it
    assembly {
      let ptr := mload(0x40)
      mstore(0x40, add(ptr, 0x20))
      mstore(ptr, self)
      mstore(add(ret, 0x20), ptr)
    }
    ret._len = len(self);
  }

  /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
  function copy(slice memory self) internal pure returns (slice memory) {
    return slice(self._len, self._ptr);
  }

  /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
  function toString(slice memory self) internal pure returns (string memory) {
    string memory ret = new string(self._len);
    uint256 retptr;
    assembly {
      retptr := add(ret, 32)
    }

    memcpy(retptr, self._ptr, self._len);
    return ret;
  }

  /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
  function len(slice memory self) internal pure returns (uint256 l) {
    // Starting at ptr-31 means the LSB will be the byte we care about
    uint256 ptr = self._ptr - 31;
    uint256 end = ptr + self._len;
    for (l = 0; ptr < end; l++) {
      uint8 b;
      assembly {
        b := and(mload(ptr), 0xFF)
      }
      if (b < 0x80) {
        ptr += 1;
      } else if (b < 0xE0) {
        ptr += 2;
      } else if (b < 0xF0) {
        ptr += 3;
      } else if (b < 0xF8) {
        ptr += 4;
      } else if (b < 0xFC) {
        ptr += 5;
      } else {
        ptr += 6;
      }
    }
  }

  /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
  function empty(slice memory self) internal pure returns (bool) {
    return self._len == 0;
  }

  /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
  function compare(slice memory self, slice memory other) internal pure returns (int256) {
    uint256 shortest = self._len;
    if (other._len < self._len) {
      shortest = other._len;
    }

    uint256 selfptr = self._ptr;
    uint256 otherptr = other._ptr;
    for (uint256 idx = 0; idx < shortest; idx += 32) {
      uint256 a;
      uint256 b;
      assembly {
        a := mload(selfptr)
        b := mload(otherptr)
      }
      if (a != b) {
        // Mask out irrelevant bytes and check again
        uint256 mask = type(uint256).max; // 0xffff...
        if (shortest < 32) {
          mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
        }
        unchecked {
          uint256 diff = (a & mask) - (b & mask);
          if (diff != 0) {
            return int256(diff);
          }
        }
      }
      selfptr += 32;
      otherptr += 32;
    }
    return int256(self._len) - int256(other._len);
  }

  /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
  function equals(slice memory self, slice memory other) internal pure returns (bool) {
    return compare(self, other) == 0;
  }

  /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
  function nextRune(slice memory self, slice memory rune)
    internal
    pure
    returns (slice memory)
  {
    rune._ptr = self._ptr;

    if (self._len == 0) {
      rune._len = 0;
      return rune;
    }

    uint256 l;
    uint256 b;
    // Load the first byte of the rune into the LSBs of b
    assembly {
      b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF)
    }
    if (b < 0x80) {
      l = 1;
    } else if (b < 0xE0) {
      l = 2;
    } else if (b < 0xF0) {
      l = 3;
    } else {
      l = 4;
    }

    // Check for truncated codepoints
    if (l > self._len) {
      rune._len = self._len;
      self._ptr += self._len;
      self._len = 0;
      return rune;
    }

    self._ptr += l;
    self._len -= l;
    rune._len = l;
    return rune;
  }

  /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
  function nextRune(slice memory self) internal pure returns (slice memory ret) {
    nextRune(self, ret);
  }

  /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
  function ord(slice memory self) internal pure returns (uint256 ret) {
    if (self._len == 0) {
      return 0;
    }

    uint256 word;
    uint256 length;
    uint256 divisor = 2 ** 248;

    // Load the rune into the MSBs of b
    assembly {
      word := mload(mload(add(self, 32)))
    }
    uint256 b = word / divisor;
    if (b < 0x80) {
      ret = b;
      length = 1;
    } else if (b < 0xE0) {
      ret = b & 0x1F;
      length = 2;
    } else if (b < 0xF0) {
      ret = b & 0x0F;
      length = 3;
    } else {
      ret = b & 0x07;
      length = 4;
    }

    // Check for truncated codepoints
    if (length > self._len) {
      return 0;
    }

    for (uint256 i = 1; i < length; i++) {
      divisor = divisor / 256;
      b = (word / divisor) & 0xFF;
      if (b & 0xC0 != 0x80) {
        // Invalid UTF-8 sequence
        return 0;
      }
      ret = (ret * 64) | (b & 0x3F);
    }

    return ret;
  }

  /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
  function keccak(slice memory self) internal pure returns (bytes32 ret) {
    assembly {
      ret := keccak256(mload(add(self, 32)), mload(self))
    }
  }

  /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
  function startsWith(slice memory self, slice memory needle)
    internal
    pure
    returns (bool)
  {
    if (self._len < needle._len) {
      return false;
    }

    if (self._ptr == needle._ptr) {
      return true;
    }

    bool equal;
    assembly {
      let length := mload(needle)
      let selfptr := mload(add(self, 0x20))
      let needleptr := mload(add(needle, 0x20))
      equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
    }
    return equal;
  }

  /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
  function beyond(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory)
  {
    if (self._len < needle._len) {
      return self;
    }

    bool equal = true;
    if (self._ptr != needle._ptr) {
      assembly {
        let length := mload(needle)
        let selfptr := mload(add(self, 0x20))
        let needleptr := mload(add(needle, 0x20))
        equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
      }
    }

    if (equal) {
      self._len -= needle._len;
      self._ptr += needle._len;
    }

    return self;
  }

  /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
  function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {
    if (self._len < needle._len) {
      return false;
    }

    uint256 selfptr = self._ptr + self._len - needle._len;

    if (selfptr == needle._ptr) {
      return true;
    }

    bool equal;
    assembly {
      let length := mload(needle)
      let needleptr := mload(add(needle, 0x20))
      equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
    }

    return equal;
  }

  /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
  function until(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory)
  {
    if (self._len < needle._len) {
      return self;
    }

    uint256 selfptr = self._ptr + self._len - needle._len;
    bool equal = true;
    if (selfptr != needle._ptr) {
      assembly {
        let length := mload(needle)
        let needleptr := mload(add(needle, 0x20))
        equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
      }
    }

    if (equal) {
      self._len -= needle._len;
    }

    return self;
  }

  // Returns the memory address of the first byte of the first occurrence of
  // `needle` in `self`, or the first byte after `self` if not found.
  function findPtr(uint256 selflen, uint256 selfptr, uint256 needlelen, uint256 needleptr)
    private
    pure
    returns (uint256)
  {
    uint256 ptr = selfptr;
    uint256 idx;

    if (needlelen <= selflen) {
      if (needlelen <= 32) {
        bytes32 mask;
        if (needlelen > 0) {
          mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
        }

        bytes32 needledata;
        assembly {
          needledata := and(mload(needleptr), mask)
        }

        uint256 end = selfptr + selflen - needlelen;
        bytes32 ptrdata;
        assembly {
          ptrdata := and(mload(ptr), mask)
        }

        while (ptrdata != needledata) {
          if (ptr >= end) {
            return selfptr + selflen;
          }
          ptr++;
          assembly {
            ptrdata := and(mload(ptr), mask)
          }
        }
        return ptr;
      } else {
        // For long needles, use hashing
        bytes32 hash;
        assembly {
          hash := keccak256(needleptr, needlelen)
        }

        for (idx = 0; idx <= selflen - needlelen; idx++) {
          bytes32 testHash;
          assembly {
            testHash := keccak256(ptr, needlelen)
          }
          if (hash == testHash) {
            return ptr;
          }
          ptr += 1;
        }
      }
    }
    return selfptr + selflen;
  }

  // Returns the memory address of the first byte after the last occurrence of
  // `needle` in `self`, or the address of `self` if not found.
  function rfindPtr(
    uint256 selflen,
    uint256 selfptr,
    uint256 needlelen,
    uint256 needleptr
  ) private pure returns (uint256) {
    uint256 ptr;

    if (needlelen <= selflen) {
      if (needlelen <= 32) {
        bytes32 mask;
        if (needlelen > 0) {
          mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
        }

        bytes32 needledata;
        assembly {
          needledata := and(mload(needleptr), mask)
        }

        ptr = selfptr + selflen - needlelen;
        bytes32 ptrdata;
        assembly {
          ptrdata := and(mload(ptr), mask)
        }

        while (ptrdata != needledata) {
          if (ptr <= selfptr) {
            return selfptr;
          }
          ptr--;
          assembly {
            ptrdata := and(mload(ptr), mask)
          }
        }
        return ptr + needlelen;
      } else {
        // For long needles, use hashing
        bytes32 hash;
        assembly {
          hash := keccak256(needleptr, needlelen)
        }
        ptr = selfptr + (selflen - needlelen);
        while (ptr >= selfptr) {
          bytes32 testHash;
          assembly {
            testHash := keccak256(ptr, needlelen)
          }
          if (hash == testHash) {
            return ptr + needlelen;
          }
          ptr -= 1;
        }
      }
    }
    return selfptr;
  }

  /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
  function find(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory)
  {
    uint256 ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
    self._len -= ptr - self._ptr;
    self._ptr = ptr;
    return self;
  }

  /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
  function rfind(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory)
  {
    uint256 ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
    self._len = ptr - self._ptr;
    return self;
  }

  /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
  function split(slice memory self, slice memory needle, slice memory token)
    internal
    pure
    returns (slice memory)
  {
    uint256 ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
    token._ptr = self._ptr;
    token._len = ptr - self._ptr;
    if (ptr == self._ptr + self._len) {
      // Not found
      self._len = 0;
    } else {
      self._len -= token._len + needle._len;
      self._ptr = ptr + needle._len;
    }
    return token;
  }

  /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
  function split(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory token)
  {
    split(self, needle, token);
  }

  /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
  function rsplit(slice memory self, slice memory needle, slice memory token)
    internal
    pure
    returns (slice memory)
  {
    uint256 ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
    token._ptr = ptr;
    token._len = self._len - (ptr - self._ptr);
    if (ptr == self._ptr) {
      // Not found
      self._len = 0;
    } else {
      self._len -= token._len + needle._len;
    }
    return token;
  }

  /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
  function rsplit(slice memory self, slice memory needle)
    internal
    pure
    returns (slice memory token)
  {
    rsplit(self, needle, token);
  }

  /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
  function count(slice memory self, slice memory needle)
    internal
    pure
    returns (uint256 cnt)
  {
    uint256 ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
    while (ptr <= self._ptr + self._len) {
      cnt++;
      ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr)
        + needle._len;
    }
  }

  /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
  function contains(slice memory self, slice memory needle) internal pure returns (bool) {
    return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
  }

  /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
  function concat(slice memory self, slice memory other)
    internal
    pure
    returns (string memory)
  {
    string memory ret = new string(self._len + other._len);
    uint256 retptr;
    assembly {
      retptr := add(ret, 32)
    }
    memcpy(retptr, self._ptr, self._len);
    memcpy(retptr + self._len, other._ptr, other._len);
    return ret;
  }

  /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
  function join(slice memory self, slice[] memory parts)
    internal
    pure
    returns (string memory)
  {
    if (parts.length == 0) {
      return "";
    }

    uint256 length = self._len * (parts.length - 1);
    for (uint256 i = 0; i < parts.length; i++) {
      length += parts[i]._len;
    }

    string memory ret = new string(length);
    uint256 retptr;
    assembly {
      retptr := add(ret, 32)
    }

    for (uint256 i = 0; i < parts.length; i++) {
      memcpy(retptr, parts[i]._ptr, parts[i]._len);
      retptr += parts[i]._len;
      if (i < parts.length - 1) {
        memcpy(retptr, self._ptr, self._len);
        retptr += self._len;
      }
    }

    return ret;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IObeliskHashmask } from "src/interfaces/IObeliskHashmask.sol";

import { ObeliskNFT, ILiteTicker } from "src/services/nft/ObeliskNFT.sol";

import { IHashmask } from "src/vendor/IHashmask.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { strings } from "src/lib/strings.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ObeliskHashmask
 * @notice A contract that allows users to link their Hashmasks to their Obelisk
 * identities. It uses the Hashmask's name
 * instead of HCT & Wrapped NFT Hero.
 * @custom:export abi
 * @dev Users need to link their Hashmask first, which might contain cost.
 * @dev IMPORTANT:
 *
 * Due of the fact we are not holding their NFT, claiming has a different behaviour that
 * might cause the lost of reward for a user if badly interacted with.
 *
 * User WON’T be able to claim if:
 * They are no longer the owner of the hashmask
 * Their hashmask’s name is not the same as the one saved on Obelisk
 *
 * User WILL LOSE their reward if:
 * They transfer their hashmask then a link (or transfer-link) happens
 * They rename their Hashmask then calls updateName
 *
 * RECOMMENDATION
 * User NEEDS to CLAIM before TRANSFERRING or RENAMING their hashmask.
 */
contract ObeliskHashmask is IObeliskHashmask, ObeliskNFT, Ownable {
  using strings for string;
  using strings for strings.slice;

  string public constant TICKER_SPLIT_HASHMASK = " ";
  string public constant TICKER_HASHMASK_START_INCIDE = "O";

  // To make sure nobody can steal an hashmask identity with an nft pass, the prefix goes
  // beyond the bytes limit of an NFT Pass.
  string public constant HASHMASK_IDENTITY_PREFIX = "IDENTITY_HASH_MASK_OBELISK_";

  IHashmask public immutable hashmask;
  address public treasury;
  uint256 public activationPrice;

  mapping(uint256 => address) public linkers;

  constructor(
    address _hashmask,
    address _owner,
    address _obeliskRegistry,
    address _treasury
  ) ObeliskNFT(_obeliskRegistry, address(0)) Ownable(_owner) {
    hashmask = IHashmask(_hashmask);
    treasury = _treasury;
    activationPrice = 0.1 ether;
  }

  /// @inheritdoc IObeliskHashmask
  function link(uint256 _hashmaskId) external payable override {
    if (hashmask.ownerOf(_hashmaskId) != msg.sender) revert NotHashmaskHolder();
    if (msg.value != activationPrice) revert InsufficientActivationPrice();

    string memory identityName = nftPassAttached[_hashmaskId];

    if (bytes(identityName).length == 0) {
      identityName =
        string.concat(HASHMASK_IDENTITY_PREFIX, Strings.toString(_hashmaskId));

      nftPassAttached[_hashmaskId] = identityName;
    }

    address oldLinker = linkers[_hashmaskId];

    linkers[_hashmaskId] = msg.sender;

    _updateName(keccak256(abi.encode(identityName)), _hashmaskId, oldLinker, msg.sender);

    (bool success,) = treasury.call{ value: msg.value }("");
    if (!success) revert TransferFailed();

    //Since it's an override, the from is address(0);
    emit HashmaskLinked(_hashmaskId, address(0), msg.sender);
  }

  /// @inheritdoc IObeliskHashmask
  function transferLink(uint256 _hashmaskId) external override {
    if (linkers[_hashmaskId] != msg.sender) revert NotLinkedToHolder();

    address newOwner = hashmask.ownerOf(_hashmaskId);
    linkers[_hashmaskId] = newOwner;

    _updateName(
      keccak256(abi.encode(nftPassAttached[_hashmaskId])),
      _hashmaskId,
      msg.sender,
      newOwner
    );

    emit HashmaskLinked(_hashmaskId, msg.sender, newOwner);
  }

  /// @inheritdoc IObeliskHashmask
  function updateName(uint256 _hashmaskId) external override {
    if (hashmask.ownerOf(_hashmaskId) != msg.sender) revert NotHashmaskHolder();
    if (linkers[_hashmaskId] != msg.sender) revert NotLinkedToHolder();

    _updateName(
      keccak256(abi.encode(nftPassAttached[_hashmaskId])),
      _hashmaskId,
      msg.sender,
      msg.sender
    );
  }

  function _updateName(
    bytes32 _identity,
    uint256 _hashmaskId,
    address _oldReceiver,
    address _newReceiver
  ) internal {
    _removeOldTickers(_identity, _oldReceiver, _hashmaskId, true);

    string memory name = hashmask.tokenNameByIndex(_hashmaskId);
    names[_hashmaskId] = name;

    _addNewTickers(_identity, _newReceiver, _hashmaskId, name);

    emit NameUpdated(_hashmaskId, name);
  }

  function _addNewTickers(
    bytes32 _identity,
    address _receiver,
    uint256 _tokenId,
    string memory _name
  ) internal override {
    strings.slice memory nameSlice = _name.toSlice();
    strings.slice memory delim = TICKER_SPLIT_HASHMASK.toSlice();
    uint256 potentialTickers = nameSlice.count(delim) + 1;

    address[] storage poolTargets = linkedTickers[_tokenId];
    strings.slice memory potentialTicker;
    address poolTarget;

    for (uint256 i = 0; i < potentialTickers; ++i) {
      potentialTicker = nameSlice.split(delim);

      if (!potentialTicker.copy().startsWith(TICKER_HASHMASK_START_INCIDE.toSlice())) {
        continue;
      }

      poolTarget = obeliskRegistry.getTickerLogic(
        potentialTicker.beyond(TICKER_HASHMASK_START_INCIDE.toSlice()).toString()
      );
      if (poolTarget == address(0)) continue;

      poolTargets.push(poolTarget);

      ILiteTicker(poolTarget).virtualDeposit(_identity, _tokenId, _receiver);
      emit TickerActivated(_tokenId, poolTarget);
    }
  }

  function _getIdentityInformation(uint256 _tokenId)
    internal
    view
    override
    returns (bytes32, address)
  {
    return (keccak256(abi.encode(nftPassAttached[_tokenId])), linkers[_tokenId]);
  }

  function _claimRequirements(uint256 _tokenId) internal view override returns (bool) {
    address owner = hashmask.ownerOf(_tokenId);
    if (owner != msg.sender) revert NotHashmaskHolder();

    bool sameName = keccak256(bytes(hashmask.tokenNameByIndex(_tokenId)))
      == keccak256(bytes(names[_tokenId]));
    return owner == linkers[_tokenId] && sameName;
  }

  /**
   * @notice Sets the activation price for linking a Hashmask to an Obelisk.
   * @param _price The new activation price.
   */
  function setActivationPrice(uint256 _price) external onlyOwner {
    activationPrice = _price;
    emit ActivationPriceSet(_price);
  }

  /**
   * @notice Sets the treasury address.
   * @param _treasury The new treasury address.
   */
  function setTreasury(address _treasury) external onlyOwner {
    if (_treasury == address(0)) revert ZeroAddress();
    treasury = _treasury;

    emit TreasurySet(_treasury);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IObeliskNFT } from "src/interfaces/IObeliskNFT.sol";
import { ILiteTicker } from "src/interfaces/ILiteTicker.sol";
import { IObeliskRegistry } from "src/interfaces/IObeliskRegistry.sol";
import { INFTPass } from "src/interfaces/INFTPass.sol";

import { strings } from "src/lib/strings.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ObeliskNFT
 * @notice Base contract for Obelisk NFTs. It contains the staking logic via name.
 */
abstract contract ObeliskNFT is IObeliskNFT, ReentrancyGuard {
  using strings for string;
  using strings for strings.slice;

  string public constant TICKER_START_INDICE = "#";
  string public constant TICKER_SPLIT_STRING = ",";
  string public constant TICKER_START_IDENTITY = "@";
  uint32 public constant MAX_NAME_BYTES_LENGTH = 29;
  IObeliskRegistry public immutable obeliskRegistry;
  INFTPass public immutable NFT_PASS;

  mapping(uint256 => string) public nftPassAttached;
  mapping(uint256 => address[]) internal linkedTickers;
  mapping(uint256 => string) public names;

  constructor(address _obeliskRegistry, address _nftPass) {
    obeliskRegistry = IObeliskRegistry(_obeliskRegistry);
    NFT_PASS = INFTPass(_nftPass);
  }

  function _removeOldTickers(
    bytes32 _identity,
    address _receiver,
    uint256 _tokenId,
    bool _ignoreRewards
  ) internal nonReentrant {
    address[] memory activePools = linkedTickers[_tokenId];
    delete linkedTickers[_tokenId];

    address currentPool;

    for (uint256 i = 0; i < activePools.length; ++i) {
      currentPool = activePools[i];

      ILiteTicker(currentPool).virtualWithdraw(
        _identity, _tokenId, _receiver, _ignoreRewards
      );

      emit TickerDeactivated(_tokenId, currentPool);
    }
  }

  function _addNewTickers(
    bytes32 _identity,
    address _receiver,
    uint256 _tokenId,
    string memory _name
  ) internal virtual nonReentrant {
    strings.slice memory nameSlice = _name.toSlice();
    strings.slice memory needle = TICKER_START_INDICE.toSlice();
    strings.slice memory substring =
      nameSlice.find(needle).beyond(needle).split(string(" ").toSlice());
    strings.slice memory delim = TICKER_SPLIT_STRING.toSlice();

    address[] memory poolTargets = new address[](substring.count(delim) + 1);

    address poolTarget;
    string memory tickerName;
    for (uint256 i = 0; i < poolTargets.length; ++i) {
      tickerName = substring.split(delim).toString();
      if (bytes(tickerName).length == 0) continue;

      poolTarget = obeliskRegistry.getTickerLogic(tickerName);
      if (poolTarget == address(0)) continue;

      poolTargets[i] = poolTarget;

      ILiteTicker(poolTarget).virtualDeposit(_identity, _tokenId, _receiver);
      emit TickerActivated(_tokenId, poolTarget);
    }

    linkedTickers[_tokenId] = poolTargets;
  }

  /// @inheritdoc IObeliskNFT
  function claim(uint256 _tokenId) external nonReentrant {
    address[] memory activePools = linkedTickers[_tokenId];
    assert(_claimRequirements(_tokenId));

    (bytes32 identity, address identityReceiver) = _getIdentityInformation(_tokenId);

    for (uint256 i = 0; i < activePools.length; i++) {
      ILiteTicker(activePools[i]).claim(identity, _tokenId, identityReceiver, false);
      emit TickerClaimed(_tokenId, activePools[i]);
    }
  }

  function _claimRequirements(uint256 _tokenId) internal view virtual returns (bool);

  function getIdentityInformation(uint256 _tokenId)
    external
    view
    override
    returns (bytes32 identityInTicker_, address rewardReceiver_)
  {
    return _getIdentityInformation(_tokenId);
  }

  function _getIdentityInformation(uint256 _tokenId)
    internal
    view
    virtual
    returns (bytes32, address);

  function getLinkedTickers(uint256 _tokenId) external view returns (address[] memory) {
    return linkedTickers[_tokenId];
  }

  function getPendingRewards(uint256 _tokenId)
    external
    view
    returns (uint256[] memory pendingRewards_, address[] memory pendingRewardsTokens_)
  {
    address[] memory activePools = linkedTickers[_tokenId];
    (bytes32 identity,) = _getIdentityInformation(_tokenId);

    pendingRewards_ = new uint256[](activePools.length);
    pendingRewardsTokens_ = new address[](activePools.length);

    uint256 pendingRewards;
    address pendingRewardsToken;

    for (uint256 i = 0; i < activePools.length; ++i) {
      (pendingRewards, pendingRewardsToken) =
        ILiteTicker(activePools[i]).getClaimableRewards(identity, 0);

      pendingRewards_[i] = pendingRewards;
      pendingRewardsTokens_[i] = pendingRewardsToken;
    }

    return (pendingRewards_, pendingRewardsTokens_);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHashmask is IERC721 {
  function tokenNameByIndex(uint256 _tokenId) external view returns (string memory);
}