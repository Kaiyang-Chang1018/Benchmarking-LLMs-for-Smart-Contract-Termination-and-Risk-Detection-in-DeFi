//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
*
* Pepe's DaVinci. 
* >>> Experimental ERC standard.
* "Art is never finished, only abandoned."
* 
* t.me/pepesdavinci
*/

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

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

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

// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/DoubleEndedQueue.sol)
// Modified by Pandora Labs to support native uint256 operations

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Uint256Deque`. This data structure can only be used in storage, and not in memory.
 *
 * ```solidity
 * DoubleEndedQueue.Uint256Deque queue;
 * ```
 */
library DoubleEndedQueue {
    /**
    * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
    */
    error QueueEmpty();

    /**
    * @dev A push operation couldn't be completed due to the queue being full.
    */
    error QueueFull();

    /**
    * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
    */
    error QueueOutOfBounds();

    /**
    * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access.
    *
    * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
    * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
    * lead to unexpected behavior.
    *
    * The first item is at data[begin] and the last item is at data[end - 1]. This range can wrap around.
    */
    struct Uint256Deque {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 index => uint256) _data;
    }

    /**
    * @dev Inserts an item at the end of the queue.
    *
    * Reverts with {QueueFull} if the queue is full.
    */
    function pushBack(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex + 1 == deque._begin) revert QueueFull();
            deque._data[backIndex] = value;
            deque._end = backIndex + 1;
        }
    }

    /**
    * @dev Removes the item at the end of the queue and returns it.
    *
    * Reverts with {QueueEmpty} if the queue is empty.
    */
    function popBack(Uint256Deque storage deque) internal returns (uint256 value) {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex == deque._begin) revert QueueEmpty();
            --backIndex;
            value = deque._data[backIndex];
            delete deque._data[backIndex];
            deque._end = backIndex;
        }
    }

    /**
    * @dev Inserts an item at the beginning of the queue.
    *
    * Reverts with {QueueFull} if the queue is full.
    */
    function pushFront(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 frontIndex = deque._begin - 1;
            if (frontIndex == deque._end) revert QueueFull();
            deque._data[frontIndex] = value;
            deque._begin = frontIndex;
        }
    }

    /**
    * @dev Removes the item at the beginning of the queue and returns it.
    *
    * Reverts with `QueueEmpty` if the queue is empty.
    */
    function popFront(Uint256Deque storage deque) internal returns (uint256 value) {
        unchecked {
            uint128 frontIndex = deque._begin;
            if (frontIndex == deque._end) revert QueueEmpty();
            value = deque._data[frontIndex];
            delete deque._data[frontIndex];
            deque._begin = frontIndex + 1;
        }
    }

    /**
    * @dev Returns the item at the beginning of the queue.
    *
    * Reverts with `QueueEmpty` if the queue is empty.
    */
    function front(Uint256Deque storage deque) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        return deque._data[deque._begin];
    }

    /**
    * @dev Returns the item at the end of the queue.
    *
    * Reverts with `QueueEmpty` if the queue is empty.
    */
    function back(Uint256Deque storage deque) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        unchecked {
            return deque._data[deque._end - 1];
        }
    }

    /**
    * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
    * `length(deque) - 1`.
    *
    * Reverts with `QueueOutOfBounds` if the index is out of bounds.
    */
    function at(Uint256Deque storage deque, uint256 index) internal view returns (uint256 value) {
        if (index >= length(deque)) revert QueueOutOfBounds();
        // By construction, length is a uint128, so the check above ensures that index can be safely downcast to uint128
        unchecked {
            return deque._data[deque._begin + uint128(index)];
        }
    }

    /**
    * @dev Resets the queue back to being empty.
    *
    * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
    * out on potential gas refunds.
    */
    function clear(Uint256Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
    * @dev Returns the number of items in the queue.
    */
    function length(Uint256Deque storage deque) internal view returns (uint256) {
        unchecked {
            return uint256(deque._end - deque._begin);
        }
    }

    /**
    * @dev Returns true if the queue is empty.
    */
    function empty(Uint256Deque storage deque) internal view returns (bool) {
        return deque._end == deque._begin;
    }
}

library ERC721Events {
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
}

library ERC20Events {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 amount);
}

// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

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

interface IERC404 is IERC165 {
    error NotFound();
    error InvalidTokenId();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error InvalidSpender();
    error InvalidOperator();
    error UnsafeRecipient();
    error RecipientIsERC721TransferExempt();
    error Unauthorized();
    error InsufficientAllowance();
    error DecimalsTooLow();
    error PermitDeadlineExpired();
    error InvalidSigner();
    error InvalidApproval();
    error OwnedIndexOverflow();
    error MintLimitReached();
    error InvalidExemption();

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function erc20TotalSupply() external view returns (uint256);
    function erc721TotalSupply() external view returns (uint256);
    function balanceOf(address owner_) external view returns (uint256);
    function erc721BalanceOf(address owner_) external view returns (uint256);
    function erc20BalanceOf(address owner_) external view returns (uint256);
    function erc721TransferExempt(address account_) external view returns (bool);
    function isApprovedForAll(address owner_, address operator_) external view returns (bool);
    function allowance(address owner_, address spender_) external view returns (uint256);
    function owned(address owner_) external view returns (uint256[] memory);
    function ownerOf(uint256 id_) external view returns (address erc721Owner);
    function tokenURI(uint256 id_) external view returns (string memory);
    function approve(address spender_, uint256 valueOrId_) external returns (bool);
    function erc20Approve(address spender_, uint256 value_) external returns (bool);
    function erc721Approve(address spender_, uint256 id_) external;
    function setApprovalForAll(address operator_, bool approved_) external;
    function transferFrom(address from_, address to_, uint256 valueOrId_) external returns (bool);
    function erc20TransferFrom(address from_, address to_, uint256 value_) external returns (bool);
    function erc721TransferFrom(address from_, address to_, uint256 id_) external;
    function transfer(address to_, uint256 amount_) external returns (bool);
    function getERC721QueueLength() external view returns (uint256);
    function getERC721TokensInQueue(uint256 start_, uint256 count_) external view returns (uint256[] memory);
    function setSelfERC721TransferExempt(bool state_) external;
    function safeTransferFrom(address from_, address to_, uint256 id_) external;
    function safeTransferFrom(address from_, address to_, uint256 id_, bytes calldata data_) external;
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function permit(
        address owner_,
        address spender_,
        uint256 value_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external;
}

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

abstract contract ERC404 is IERC404 {
    using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;

    /// @dev The queue of ERC-721 tokens stored in the contract.
    DoubleEndedQueue.Uint256Deque internal _storedERC721Ids;
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    /// @dev Units for ERC-20 representation
    uint256 public immutable units; 
    uint256 public totalSupply;
    /// @dev Current mint counter which also represents the highest minted id, monotonically increasing to ensure accurate ownership
    uint256 public minted;
    /// @dev Initial chain id for EIP-2612 support
    uint256 internal immutable _INITIAL_CHAIN_ID;
    /// @dev Initial domain separator for EIP-2612 support
    bytes32 internal immutable _INITIAL_DOMAIN_SEPARATOR;
    /// @dev Balance of user in ERC-20 representation
    mapping(address => uint256) public balanceOf;
    /// @dev Allowance of user in ERC-20 representation
    mapping(address => mapping(address => uint256)) public allowance;
    /// @dev Approval in ERC-721 representaion
    mapping(uint256 => address) public getApproved;
    /// @dev Approval for all in ERC-721 representation
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    /// @dev Packed representation of ownerOf and owned indices
    mapping(uint256 => uint256) internal _ownedData;
    /// @dev Array of owned ids in ERC-721 representation
    mapping(address => uint256[]) internal _owned;
    /// @dev Addresses that are exempt from ERC-721 transfer, typically for gas savings (pairs, routers, etc)
    mapping(address => bool) internal _erc721TransferExempt;
    /// @dev EIP-2612 nonces
    mapping(address => uint256) public nonces;
    /// @dev Address bitmask for packed ownership data
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
    /// @dev Owned index bitmask for packed ownership data
    uint256 private constant _BITMASK_OWNED_INDEX = ((1 << 96) - 1) << 160;
    /// @dev Constant for token id encoding
    //uint256 public constant ID_ENCODING_PREFIX = 1 << 255;
    /// @dev Tracks last batch transfer for each address
    mapping(address => uint256) private _lastTransferBatch; 
    /// @dev Tracks index of each token in _owned array
    mapping(uint256 => uint256) private _tokenIndexes; 


    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        name = name_;
        symbol = symbol_;

        if (decimals_ < 18) {
            revert DecimalsTooLow();
        }

        decimals = decimals_;
        units = 10 ** decimals;

        // EIP-2612 initialization
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    /// @notice Function to find owner of a given ERC-721 token
    function ownerOf(uint256 id_) public view virtual returns (address erc721Owner) {
        erc721Owner = _getOwnerOf(id_);

        if (!_isValidTokenId(id_)) {
            revert InvalidTokenId();
        }

        if (erc721Owner == address(0)) {
            revert NotFound();
        }
    }

    function owned(address owner_) public view virtual returns (uint256[] memory) {
        return _owned[owner_];
    }

    function erc721BalanceOf(address owner_) public view virtual returns (uint256) {
        return _owned[owner_].length;
    }

    function erc20BalanceOf(address owner_) public view virtual returns (uint256) {
        return balanceOf[owner_];
    }

    function erc20TotalSupply() public view virtual returns (uint256) {
        return totalSupply;
    }

    function erc721TotalSupply() public view virtual returns (uint256) {
        return minted;
    }

    function getERC721QueueLength() public view virtual returns (uint256) {
        return _storedERC721Ids.length();
    }

    function getERC721TokensInQueue(uint256 start_, uint256 count_ ) public view virtual returns (uint256[] memory) {
        uint256[] memory tokensInQueue = new uint256[](count_);

        for (uint256 i = start_; i < start_ + count_; ) {
            tokensInQueue[i - start_] = _storedERC721Ids.at(i);

            unchecked {
                ++i;
            }
        }

        return tokensInQueue;
    }

    /// @notice tokenURI must be implemented by child contract
    function tokenURI(uint256 id_) public view virtual returns (string memory);

    /// @notice Function for token approvals
    /// @dev This function assumes the operator is attempting to approve
    ///      an ERC-721 if valueOrId_ is a possibly valid ERC-721 token id.
    ///      Unlike setApprovalForAll, spender_ must be allowed to be 0x0 so
    ///      that approval can be revoked.
    function approve(address spender_, uint256 valueOrId_) public virtual returns (bool) {
        if (_isValidTokenId(valueOrId_)) {
            erc721Approve(spender_, valueOrId_);
        } else {
            return erc20Approve(spender_, valueOrId_);
        }

        return true;
    }

    function erc721Approve(address spender_, uint256 id_) public virtual {
        // Intention is to approve as ERC-721 token (id).
        address erc721Owner = _getOwnerOf(id_);

        if (msg.sender != erc721Owner && !isApprovedForAll[erc721Owner][msg.sender]) {
            revert Unauthorized();
        }

        getApproved[id_] = spender_;

        emit ERC721Events.Approval(erc721Owner, spender_, id_);
    }

    /// @dev Providing type(uint256).max for approval value results in an
    ///      unlimited approval that is not deducted from on transfers.
    function erc20Approve(address spender_, uint256 value_) public virtual returns (bool) {
        // Prevent granting 0x0 an ERC-20 allowance.
        if (spender_ == address(0)) {
            revert InvalidSpender();
        }

        allowance[msg.sender][spender_] = value_;

        emit ERC20Events.Approval(msg.sender, spender_, value_);

        return true;
    }

    /// @notice Function for ERC-721 approvals
    function setApprovalForAll(address operator_, bool approved_) public virtual {
        // Prevent approvals to 0x0.
        if (operator_ == address(0)) {
            revert InvalidOperator();
        }
        isApprovedForAll[msg.sender][operator_] = approved_;
        emit ERC721Events.ApprovalForAll(msg.sender, operator_, approved_);
    }

    /// @notice Function for mixed transfers from an operator that may be different than 'from'.
    /// @dev This function assumes the operator is attempting to transfer an ERC-721
    ///      if valueOrId is a possible valid token id.
    function transferFrom(address from_, address to_, uint256 valueOrId_) public virtual returns (bool) {
        if (_isValidTokenId(valueOrId_)) {
            erc721TransferFrom(from_, to_, valueOrId_);
        } else {
            // Intention is to transfer as ERC-20 token (value).
            return erc20TransferFrom(from_, to_, valueOrId_);
        }

        return true;
    }

    /// @notice Function for ERC-721 transfers from.
    /// @dev This function is recommended for ERC721 transfers.
    function erc721TransferFrom(address from_, address to_, uint256 id_) public virtual {
        // Prevent minting tokens from 0x0.
        if (from_ == address(0)) {
            revert InvalidSender();
        }

        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        if (from_ != _getOwnerOf(id_)) {
            revert Unauthorized();
        }

        // Check that the operator is either the sender or approved for the transfer.
        if (msg.sender != from_ && !isApprovedForAll[from_][msg.sender] && msg.sender != getApproved[id_]) {
            revert Unauthorized();
        }

        // We only need to check ERC-721 transfer exempt status for the recipient
        // since the sender being ERC-721 transfer exempt means they have already
        // had their ERC-721s stripped away during the rebalancing process.
        if (erc721TransferExempt(to_)) {
            revert RecipientIsERC721TransferExempt();
        }

        // Transfer 1 * units ERC-20 and 1 ERC-721 token.
        // ERC-721 transfer exemptions handled above. Can't make it to this point if either is transfer exempt.
        _transferERC20(from_, to_, units);
        _transferERC721(from_, to_, id_);
    }

    /// @notice Function for ERC-20 transfers from.
    /// @dev This function is recommended for ERC20 transfers
    function erc20TransferFrom(address from_, address to_, uint256 value_) public virtual returns (bool) {
        // Prevent minting tokens from 0x0.
        if (from_ == address(0)) {
            revert InvalidSender();
        }

        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        uint256 allowed = allowance[from_][msg.sender];

        // Check that the operator has sufficient allowance.
        if (allowed != type(uint256).max) {
            allowance[from_][msg.sender] = allowed - value_;
        }

        // Transferring ERC-20s directly requires the _transferERC20WithERC721 function.
        // Handles ERC-721 exemptions internally.
        return _transferERC20WithERC721(from_, to_, value_);
    }

    /// @notice Function for ERC-20 transfers.
    /// @dev This function assumes the operator is attempting to transfer as ERC-20
    ///      given this function is only supported on the ERC-20 interface.
    ///      Treats even large amounts that are valid ERC-721 ids as ERC-20s.
    function transfer(address to_, uint256 value_) public virtual returns (bool) {
        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        // Transferring ERC-20s directly requires the _transferERC20WithERC721 function.
        // Handles ERC-721 exemptions internally.
        return _transferERC20WithERC721(msg.sender, to_, value_);
    }

    /**
    * @dev Transfers `tokenIds` in batch from `from` to `to`, aligned with ERC404 and ERC721A batch logic.
    * - Optimized for batch processing and gas efficiency with `unchecked` blocks where safe.
    * - Tracks `from` and `to` ownership via _owned and _tokenIndexes mappings.
    *
    * Requirements:
    * - `from` and `to` cannot be zero addresses.
    * - `tokenIds` must belong to `from`.
    * - If `by` is not `from`, `by` must be an approved operator to transfer these tokens.
    */
    function _batchErc721TransferFrom(
        address by,
        address from,
        address to,
        uint256[] memory tokenIds
    ) internal virtual {
        require(from != address(0) && to != address(0), "Invalid address");
        
        bool isApproved = (by == from || isApprovedForAll[from][by]);

        uint256 numTokens = tokenIds.length;

        // Loop through each token ID for transfer
        unchecked {
            for (uint256 i = 0; i < numTokens; ++i) {
                uint256 tokenId = tokenIds[i];

                if (_getOwnerOf(tokenId) != from) revert("Token not owned by from address");
                if (!isApproved && getApproved[tokenId] != by) revert("Not authorized");

                // On transfer of an NFT, any previous approval is reset.
                delete getApproved[tokenId];

                // SWAP-AND-POP for the sender
                uint256 updatedId = _owned[from][_owned[from].length - 1];
                if (updatedId != tokenId) {
                    uint256 updatedIndex = _getOwnedIndex(tokenId);
                    _owned[from][updatedIndex] = updatedId;
                    _setOwnedIndex(updatedId, updatedIndex);
                }
                // pop the last
                _owned[from].pop();

                // Set new owner
                _setOwnerOf(tokenId, to);

                // Push token into recipient’s array
                _owned[to].push(tokenId);
                _setOwnedIndex(tokenId, _owned[to].length - 1);

                emit ERC721Events.Transfer(from, to, tokenId);
            }
        }

        // Track batch transfer for gas savings and potential future references
        _lastTransferBatch[to] = numTokens;
    }

    /// @notice Function for ERC-721 transfers with contract support.
    /// This function only supports moving valid ERC-721 ids, as it does not exist on the ERC-20
    /// spec and will revert otherwise.
    function safeTransferFrom(address from_, address to_, uint256 id_) public virtual {
        safeTransferFrom(from_, to_, id_, "");
    }

    /// @notice Function for ERC-721 transfers with contract support and callback data.
    /// This function only supports moving valid ERC-721 ids, as it does not exist on the
    /// ERC-20 spec and will revert otherwise.
    function safeTransferFrom(address from_, address to_, uint256 id_, bytes memory data_) public virtual {
        if (!_isValidTokenId(id_)) {
            revert InvalidTokenId();
        }

        transferFrom(from_, to_, id_);

        if (
            to_.code.length != 0 &&
            ERC721A__IERC721Receiver(to_).onERC721Received(msg.sender, from_, id_, data_) !=
            ERC721A__IERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Function for EIP-2612 permits (ERC-20 only).
    /// @dev Providing type(uint256).max for permit value results in an
    ///      unlimited approval that is not deducted from on transfers.
    function permit(address owner_, address spender_, uint256 value_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) public virtual {
        if (deadline_ < block.timestamp) {
            revert PermitDeadlineExpired();
        }

        // permit cannot be used for ERC-721 token approvals, so ensure
        // the value does not fall within the valid range of ERC-721 token ids.
        if (_isValidTokenId(value_)) {
            revert InvalidApproval();
        }

        if (spender_ == address(0)) {
            revert InvalidSpender();
        }

        unchecked {
        address recoveredAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner_,
                            spender_,
                            value_,
                            nonces[owner_]++,
                            deadline_
                        )
                    )
                )
            ),
            v_,
            r_,
            s_
        );

        if (recoveredAddress == address(0) || recoveredAddress != owner_) {
            revert InvalidSigner();
        }

        allowance[recoveredAddress][spender_] = value_;
        }

        emit ERC20Events.Approval(owner_, spender_, value_);
    }

    /// @notice Returns domain initial domain separator, or recomputes if chain id is not equal to initial chain id
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == _INITIAL_CHAIN_ID ? _INITIAL_DOMAIN_SEPARATOR : _computeDomainSeparator();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC404).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @notice Function for self-exemption
    function setSelfERC721TransferExempt(bool state_) public virtual {
        _setERC721TransferExempt(msg.sender, state_);
    }

    /// @notice Function to check if address is transfer exempt
    function erc721TransferExempt(address target_) public view virtual returns (bool) {
        return target_ == address(0) || _erc721TransferExempt[target_];
    }

    /// @notice For a token token id to be considered valid, it just needs
    ///         to fall within the range of possible token ids, it does not
    ///         necessarily have to be minted yet.
    function _isValidTokenId(uint256 id_) internal pure returns (bool) {
        return id_ != type(uint256).max;
    }

    /// @notice Internal function to compute domain separator for EIP-2612 permits
    function _computeDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice This is the lowest level ERC-20 transfer function, which
    ///         should be used for both normal ERC-20 transfers as well as minting.
    /// Note that this function allows transfers to and from 0x0.
    function _transferERC20(address from_, address to_, uint256 value_) internal virtual {
        // Minting is a special case for which we should not check the balance of
        // the sender, and we should increase the total supply.
        if (from_ == address(0)) {
            totalSupply += value_;
        } 
        else {
            // Deduct value from sender's balance.
            balanceOf[from_] -= value_;
        }

        // Update the recipient's balance.
        // Can be unchecked because on mint, adding to totalSupply is checked, and on transfer balance deduction is checked.
        unchecked {
            balanceOf[to_] += value_;
        }

        emit ERC20Events.Transfer(from_, to_, value_);
    }

    /// @notice Consolidated record keeping function for transferring ERC-721s.
    /// @dev Assign the token to the new owner, and remove from the old owner.
    /// Note that this function allows transfers to and from 0x0.
    /// Does not handle ERC-721 exemptions.
    function _transferERC721(address from_, address to_, uint256 id_) internal virtual {
        // If this is not a mint, handle record keeping for transfer from previous owner.
        if (from_ != address(0)) {
            // On transfer of an NFT, any previous approval is reset.
            delete getApproved[id_];

            uint256 updatedId = _owned[from_][_owned[from_].length - 1];
            if (updatedId != id_) {
                uint256 updatedIndex = _getOwnedIndex(id_);
                // update _owned for sender
                _owned[from_][updatedIndex] = updatedId;
                // update index for the moved id
                _setOwnedIndex(updatedId, updatedIndex);
            }

            // pop
            _owned[from_].pop();
        }

        // Check if this is a burn.
        if (to_ != address(0)) {
            // If not a burn, update the owner of the token to the new owner.
            // Update owner of the token to the new owner.
            _setOwnerOf(id_, to_);
            // Push token onto the new owner's stack.
            _owned[to_].push(id_);
            // Update index for new owner's stack.
            _setOwnedIndex(id_, _owned[to_].length - 1);
        } else {
            // If this is a burn, reset the owner of the token to 0x0 by deleting the token from _ownedData.
            delete _ownedData[id_];
        }

        emit ERC721Events.Transfer(from_, to_, id_);
    }

    /// @notice Internal function for ERC-20 transfers. Also handles any ERC-721 transfers that may be required.
    // Handles ERC-721 exemptions.
    function _transferERC20WithERC721(address from_, address to_, uint256 value_) internal virtual returns (bool) {
        uint256 erc20BalanceOfSenderBefore = erc20BalanceOf(from_);
        uint256 erc20BalanceOfReceiverBefore = erc20BalanceOf(to_);

        _transferERC20(from_, to_, value_);

        // Preload for gas savings on branches
        bool isFromERC721TransferExempt = erc721TransferExempt(from_);
        bool isToERC721TransferExempt = erc721TransferExempt(to_);

        // Case 1: Both sender and recipient are ERC-721 transfer exempt. No ERC-721s need to be transferred.
        if (isFromERC721TransferExempt && isToERC721TransferExempt) { } 

        else if (isFromERC721TransferExempt) {
            // Case 2: Sender is exempt, recipient isn’t; send ERC-721 tokens to recipient from contract.
            uint256 tokensToRetrieveOrMint = (balanceOf[to_] / units) - (erc20BalanceOfReceiverBefore / units);
            if (tokensToRetrieveOrMint > 0) {
                _retrieveERC721(to_, tokensToRetrieveOrMint);
            }
        } 

        else if (isToERC721TransferExempt) {
            // Case 3: Recipient is exempt, sender isn’t; withdraw sender’s ERC-721 tokens to the bank.
            uint256 tokensToWithdrawAndStore = (erc20BalanceOfSenderBefore / units) - (balanceOf[from_] / units);
            if (tokensToWithdrawAndStore > 0) {
                _withdrawAndStoreERC721(from_, tokensToWithdrawAndStore);
            }
        } 

        else {
            // Case 4: Neither are exempt; handle batch ERC721 transfers and adjust fractional balances.
            uint256 nftsToTransfer = value_ / units;
            if (nftsToTransfer > 0) {
                // Collect all token IDs to transfer in batch
                uint256[] memory tokenIds = new uint256[](nftsToTransfer);
                // LIFO 
                uint256 lengthBefore = _owned[from_].length;
                for (uint256 i = 0; i < nftsToTransfer; i++) {
                    uint256 idx = lengthBefore - 1 - i;
                    tokenIds[i] = _owned[from_][idx];
                }
                // Batch transfer all collected tokens
                _batchErc721TransferFrom(from_, from_, to_, tokenIds);
            }
            // Fractional adjustments for sender and recipient:
            uint256 lostWholeTokens = (erc20BalanceOfSenderBefore / units) - (erc20BalanceOf(from_) / units);
            if (lostWholeTokens > nftsToTransfer) {
                _withdrawAndStoreERC721(from_, lostWholeTokens - nftsToTransfer);
            }

            uint256 gainedWholeTokens = (erc20BalanceOf(to_) / units) - (erc20BalanceOfReceiverBefore / units);
            if (gainedWholeTokens > nftsToTransfer) {
                _retrieveERC721(to_, gainedWholeTokens - nftsToTransfer);
            }
        }

        return true;
    }

    // ========================
    // Minting Functions
    // ========================

    /**
     * @dev Internal function to mint `quantity` ERC721 tokens to `to`.
     *
     * ERC721A is an improvement and extension of ERC721 that allows for
     * gas-efficient minting (and batch transfer) of multiple ERC721 (NFT)
     * tokens in a single transaction.
     */
    function _mint(address to, uint256 quantity) internal virtual {
        if (to == address(0)) revert("Invalid recipient");
        if (quantity == 0) revert("Mint quantity must be non-zero");

        uint256 startTokenId = minted;

        unchecked {
            // Update balance and track ownership for each minted token
            balanceOf[to] += quantity;
            minted += quantity;

            // Packed ownership data for start token ID (combining address and timestamp)
            _setOwnerOf(startTokenId, to);

            uint256 end = startTokenId + quantity;
            for (uint256 tokenId = startTokenId; tokenId < end; tokenId++) {
                // Track ownership in the _owned array
                _owned[to].push(tokenId);
                // Emit Transfer event for each token minted
                emit ERC721Events.Transfer(address(0), to, tokenId);
            }
        }
        // Sync ERC20 balances with the newly minted ERC721 tokens
        _transferERC20WithERC721(address(0), to, quantity * units);
    }

    /// @notice Internal function for ERC20 minting
    /// @dev This function will allow minting of new ERC20s.
    ///      If mintCorrespondingERC721s_ is true, and the recipient is not ERC-721 exempt, it will
    ///      also mint the corresponding ERC721s.
    /// Handles ERC-721 exemptions.
    function _mintERC20(address to_, uint256 value_) internal virtual {
        /// You cannot mint to the zero address (you can't mint and immediately burn in the same transfer).
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        if (totalSupply + value_ > 400 * units) {
            revert MintLimitReached();
        }

        _transferERC20WithERC721(address(0), to_, value_);
    }


    /// @notice Internal function for ERC-721 retrieval from the bank.
    // EDIT: All tokens pre-minted so we don't need to check for mint scenarios, only retrieve and transfer from internal 'bank' store.
    ///      Does not handle ERC-721 exemptions.
    function _retrieveERC721(address to_, uint256 quantity) internal virtual {
        if (to_ == address(0)) revert("Invalid recipient");
        if (quantity == 0) revert("Quantity must be non-zero");

        // Check that the bank has enough tokens
        uint256 tokensAvailableInBank = _storedERC721Ids.length();
        if (tokensAvailableInBank < quantity) {
            revert("Not enough tokens in bank");
        }

        // Prepare an array to hold the token IDs we're retrieving
        uint256[] memory tokenIds = new uint256[](quantity);

        // Retrieve tokens from the bank 
        for (uint256 i = 0; i < quantity; i++) {
            uint256 id = _storedERC721Ids.popFront(); 
            address erc721Owner = _getOwnerOf(id);
            if (erc721Owner != address(this)) revert("Token already claimed");

            tokenIds[i] = id;
        }

        // Perform a batch transfer from the contract (bank) to `to_`
        if (quantity == 1) {
            _transferERC721(address(this), to_, tokenIds[0]);
        } else {
            _batchErc721TransferFrom(address(this), address(this), to_, tokenIds);
        }
    }


    /// @notice Internal function for ERC-721 deposits to the bank (this contract).
    /// @dev This function deposits specified quantities of ERC-721s to the bank for future retrieval by minters.
    ///      Does not handle ERC-721 exemptions.
    function _withdrawAndStoreERC721(address from_, uint256 quantity) internal virtual {
        if (from_ == address(0)) {
            revert InvalidSender();
        }
        if (quantity == 0) {
            revert("Quantity must be non-zero");
        }

        uint256[] memory tokenIds = new uint256[](quantity);

        // Retrieve tokens from the owner's stack in LIFO order
        uint256 lengthBefore = _owned[from_].length;
        for (uint256 i = 0; i < quantity; i++) {
            // index from top downward
            uint256 idx = lengthBefore - 1 - i;
            uint256 id = _owned[from_][idx];              
            // Store token ID in the batch array
            tokenIds[i] = id;
            // Record in the contract bank queue
            _storedERC721Ids.pushFront(id);
        }

        // Use batch transfer if quantity > 1; otherwise, use single transfer
        if (quantity > 1) {
            _batchErc721TransferFrom(from_, from_, address(this), tokenIds);  // Transfer tokens in batch to the bank
        } 
        else {
            _transferERC721(from_, address(this), tokenIds[0]);  // Single token transfer
        }
    }


    /// @notice Initialization function to set pairs / etc, saving gas by avoiding mint / burn on unnecessary targets
    function _setERC721TransferExempt(address target_, bool state_) internal virtual {
        if (target_ == address(0)) {
            revert InvalidExemption();
        }

        // Adjust the ERC721 balances of the target to respect exemption rules.
        // Despite this logic, it is still recommended practice to exempt prior to the target
        // having an active balance.
        if (state_) {
            _clearERC721Balance(target_);
        } else {
            _reinstateERC721Balance(target_);
        }

        _erc721TransferExempt[target_] = state_;
    }

    /// @notice Function to reinstate balance on exemption removal
    function _reinstateERC721Balance(address target_) private {
        uint256 expectedERC721Balance = erc20BalanceOf(target_) / units;
        uint256 actualERC721Balance = erc721BalanceOf(target_);
        uint256 quantity = expectedERC721Balance - actualERC721Balance;

        if (quantity > 0) {
            // Transfer ERC721 balance in from pool in a single batch
            _retrieveERC721(target_, quantity);
        }
    }

    /// @notice Function to clear balance on exemption inclusion
    function _clearERC721Balance(address target_) private {
        uint256 erc721Balance = erc721BalanceOf(target_);

        if (erc721Balance > 0) {
            // Transfer out ERC721 balance in a single batch
            _withdrawAndStoreERC721(target_, erc721Balance);
        }
    }

    function _getOwnerOf(uint256 id_) internal view virtual returns (address ownerOf_) {
        uint256 data = _ownedData[id_];

        assembly {
            ownerOf_ := and(data, _BITMASK_ADDRESS)
        }
    }

    function _setOwnerOf(uint256 id_, address owner_) internal virtual {
        uint256 data = _ownedData[id_];

        assembly {
            data := add(
                and(data, _BITMASK_OWNED_INDEX),
                and(owner_, _BITMASK_ADDRESS)
            )
        }

        _ownedData[id_] = data;
    }

    function _getOwnedIndex(uint256 id_) internal view virtual returns (uint256 ownedIndex_) {
        uint256 data = _ownedData[id_];

        assembly {
            ownedIndex_ := shr(160, data)
        }
    }

    function _setOwnedIndex(uint256 id_, uint256 index_) internal virtual {
        uint256 data = _ownedData[id_];

        if (index_ > _BITMASK_OWNED_INDEX >> 160) {
            revert OwnedIndexOverflow();
        }

        assembly {
            data := add(
                and(data, _BITMASK_ADDRESS),
                and(shl(160, index_), _BITMASK_OWNED_INDEX)
            )
        }

        _ownedData[id_] = data;
    }

    /**
    * @dev Optimized internal helper to remove a token ID from an owner's `_owned` list.
    * Uses `_tokenIndexes` mapping to find the token's index directly, saving gas.
    */
    function _removeTokenFromOwned(address from, uint256 tokenId) internal {
        uint256 index = _tokenIndexes[tokenId];
        uint256 lastIndex = _owned[from].length - 1;

        if (index != lastIndex) {
            uint256 lastTokenId = _owned[from][lastIndex];
            _owned[from][index] = lastTokenId;
            _tokenIndexes[lastTokenId] = index;
        }

        _owned[from].pop();
        delete _tokenIndexes[tokenId];
    }

}

contract MyERC404Experiment is Ownable, ERC404 {

    address public uniswapV3PoolAddress;
    bool public tradingActive = false;
    bool private poolSet = false;
    using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;

    uint256 constant GRID_WIDTH = 94; // cols
    uint256 constant GRID_HEIGHT = 50; // rows

    string public constant baseCID = "ipfs://bafybeicwpqh3btbk232ua7stvyioyexjnmxdzhzcahfipjz6tlyi2et3hi/";

    struct CoordinateRange {
        uint256 chunkID;
        uint256 startRow;
        uint256 startColumn;
        uint256 endRow;
        uint256 endColumn;
    }

    struct TokenInfo {
        uint256 chunkID;
        uint256 row;
        uint256 column;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxTotalSupplyERC721_
    ) ERC404(name_, symbol_, decimals_) Ownable(msg.sender) {
        _setERC721TransferExempt(msg.sender, true);
        _mintERC20(msg.sender, maxTotalSupplyERC721_ * units);
    }

    function ownerMintBatch(uint256 count) public onlyOwner {
        require(minted + count <= 400, "Token limit exceeded.");
        uint256 nextTokenId = minted + 1;

        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = nextTokenId + i;
            _setOwnerOf(tokenId, address(this));
            _owned[address(this)].push(tokenId);
            _setOwnedIndex(tokenId, _owned[address(this)].length - 1);
            _storedERC721Ids.pushBack(tokenId);
            emit ERC721Events.Transfer(address(0), address(this), tokenId);
        }

        minted += count;
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }
    
    // One-time only
    function setUniswapV3PoolAddress(address _uniswapV3PoolAddress) external onlyOwner {
        require(!poolSet, "Pool already set.");
        uniswapV3PoolAddress = _uniswapV3PoolAddress;
    }

    function openTrading() external onlyOwner {
        require(!tradingActive, "Trading open.");
        tradingActive = true;
    }

    function _transferERC20WithERC721(address from_, address to_, uint256 value_) internal override returns (bool) {

        if (!tradingActive && from_ != owner() && to_ != owner()) {
            require(from_ != uniswapV3PoolAddress && to_ != uniswapV3PoolAddress, "Trading not open.");
        }

        return super._transferERC20WithERC721(from_, to_, value_);
    }

    function transfer(address to_, uint256 value_) public override returns (bool) {
        return _transferERC20WithERC721(msg.sender, to_, value_);
    }

    function transferFrom(address from_, address to_, uint256 value_) public override returns (bool) {
        return _transferERC20WithERC721(from_, to_, value_);
    }

    // Retrieve coordinate ranges for ERC721 tokens owned by an address
    // for visual representation of fractionalized NFT ownership off-chain.
    // An address may hold multiple ranges of tokenIDs across multiple rows or columns,
    // consecutively or non-consecutively. 
    // Visualized REAL ownership representation is achieved with complete accuracy and integrity regardless. 

    function getTokenCoordinateRanges(address owner) public view returns (CoordinateRange[] memory) {
        uint256[] memory ownedTokens = _owned[owner];
        uint256 ownedTokenCount = ownedTokens.length;

        // We'll create a range for every contiguous run of token IDs *in the same row*.
        CoordinateRange[] memory coordinateRanges = new CoordinateRange[](ownedTokenCount);
        uint256 rangeIndex = 0;
        uint256 i = 0;

        while (i < ownedTokenCount) {
            // Start a new range with the current token
            uint256 tokenId = ownedTokens[i];
            
            // Since "1 token = 1 chunk," you can set chunkID = tokenId
            uint256 chunkID = tokenId; 

            // Calculate the row/col for the starting token
            uint256 position = tokenId - 1;
            uint256 startRow = position / GRID_WIDTH;
            uint256 startColumn = position % GRID_WIDTH;

            // Initialize end coordinates to the start coords
            uint256 endRow = startRow;
            uint256 endColumn = startColumn;

            // Expand the range while:
            // 1) Next token is consecutive (ownedTokens[i + 1] == ownedTokens[i] + 1)
            // 2) Next token is in the *same row* (avoid "wrap-around" across row boundaries)
            while (i + 1 < ownedTokenCount && ownedTokens[i + 1] == ownedTokens[i] + 1) {
                uint256 nextTokenId = ownedTokens[i + 1];
                uint256 nextRow = (nextTokenId - 1) / GRID_WIDTH;
                
                // If next token is in a different row, break to start a new range
                if (nextRow != endRow) {
                    break;
                }

                // Accept this next token into the current range
                i++;

                uint256 nextPosition = nextTokenId - 1;
                endRow = nextPosition / GRID_WIDTH;
                endColumn = nextPosition % GRID_WIDTH;
            }

            // Record the current range of tokens (start..end in the same row)
            coordinateRanges[rangeIndex] = CoordinateRange({
                chunkID: chunkID,
                startRow: startRow,
                startColumn: startColumn,
                endRow: endRow,
                endColumn: endColumn
            });
            rangeIndex++;

            // Move forward past this range
            i++;
        }

        // Resize the array to fit the number of actual ranges
        assembly {
            mstore(coordinateRanges, rangeIndex)
        }

        return coordinateRanges;
    }

    // Retrieve the 'image position' of a tokenID.
    // This allows for precise off-chain fractional ownership visualization 
    // even if the IPFS resource is for whatever reason unavailable.
    //
    // Image position (or tokenID coordinates) is on-chain NFT metadata; we are fractionalizing
    // a single photograph into distributed on-chain ownership.
    //
    // Ownership of image positions/coordinates has the potential to create speculation of value on 
    // fractional ownership whereby a certain fraction of an image is deemed more valuable than another...

    function getTokenIDCoordinates(uint256 tokenId) public view returns (TokenInfo memory) {
        require(tokenId > 0 && tokenId <= minted, "Token does not exist");

        // "1 token = 1 image chunk" so chunkID = tokenId.
        // Map tokenId to a row/column in a 94×50 grid.
        uint256 chunkID = tokenId;

        // position = zero-based index
        uint256 position = tokenId - 1;

        // Calculate row & column based on the grid
        uint256 row = position / GRID_WIDTH;
        uint256 column = position % GRID_WIDTH;

        return TokenInfo(chunkID, row, column);
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId > 0 && tokenId <= minted, "Token does not exist");

        // Retrieve token coordinates and generate the image URI
        TokenInfo memory tokenInfo = getTokenIDCoordinates(tokenId);
        string memory chunkImageURI = string.concat(baseCID, Strings.toString(tokenInfo.chunkID), ".jpg");

        // Construct JSON metadata
        string memory jsonPreImage = string.concat(
            "{",
                '"name": "Token Image - Chunk # ', Strings.toString(tokenInfo.chunkID), '",',
                '"description": "Description Text will be here.",',
                '"image": "', chunkImageURI, '",',
                '"attributes": [',
                    '{ "trait_type": "Chunk ID", "value": "', Strings.toString(tokenInfo.chunkID), '"},',
                    '{ "trait_type": "Row", "value": "', Strings.toString(tokenInfo.row), '"},',
                    '{ "trait_type": "Column", "value": "', Strings.toString(tokenInfo.column), '"}',
                ']',
            "}"
        );

        // Return the full JSON metadata in the URI
        return string.concat("data:application/json;utf8,", jsonPreImage);
    }

}