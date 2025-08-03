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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.20;

import {IERC721} from "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "../ERC404/ERC404.sol";
import {ERC5169} from "stl-contracts/ERC/ERC5169.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import {PoolAddress} from "../utils/PoolAddress.sol";
import {TickMath} from "../utils/TickMath.sol";
import {PoolData} from "../structs/PoolData.sol";
import {MintParams, IncreaseLiquidityParams, DecreaseLiquidityParams, CollectParams} from "../structs/PositionParams.sol";
import {ExactInputSingleParams} from "../structs/RouterParams.sol";

abstract contract ERC333 is Ownable, ERC404, ERC5169 {
    event Initialize(PoolData poolData);
    event ReceiveTax(uint256 value);
    event ERC20Burn(uint256 value);
    event RefundETH(address sender, uint256 value);
    // event IncreaseLiquidity(uint256 amount);

    using Strings for uint256;

    string constant _JSON_FILE = ".json";

    // default settings
    uint256 public mintSupply = 10000; // max NFT count
    uint24 public taxPercent = 80000;
    address public initialMintRecipient; // the first token owner

    bool public initialized;
    PoolData public currentPoolData;

    /// @dev for the tick bar of ERC333
    int24 public tickThreshold;
    int24 public currentTick;
    uint256 public mintTimestamp;

    /// @dev Total tax in ERC-20 token representation
    uint256 public totalTax;

    address public positionManagerAddress;
    address public swapRouterAddress;

    /// @dev for compute arithmetic mean tick by observation
    uint32 constant TWAP_INTERVAL = 30 minutes;

    event BaseUriUpdate(string uri);

    string public baseURI;

    constructor(
        address initialOwner_,
        address initialMintRecipient_,
        uint256 mintSupply_,
        uint24 taxPercent_,
        string memory name_,
        string memory sym_,
        uint8 decimals_,
        uint8 ratio_
    ) ERC404(name_, sym_, decimals_, ratio_) Ownable(initialOwner_) {
        // init settings
        mintSupply = mintSupply_;
        taxPercent = taxPercent_;
        initialMintRecipient = initialMintRecipient_;

        // Do not mint the ERC721s to the initial owner, as it's a waste of gas.
        _setERC721TransferExempt(initialMintRecipient_, true);
        _mintERC20(initialMintRecipient_, mintSupply * units, false);
    }

    // Treat as ERC721 type, provide ERC20 interface in TokenScript
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC5169, ERC404) returns (bool) {
        return
            ERC5169.supportsInterface(interfaceId) ||
            ERC404.supportsInterface(interfaceId);
    }

    // ERC-5169
    function _authorizeSetScripts(
        string[] memory
    ) internal view override(ERC5169) onlyOwner {}

    // ======================================================================================================
    //
    // ERC333 overrides
    //
    // ======================================================================================================

    function initialize() external payable virtual;

    function _initialize(
        uint160 sqrtPriceX96,
        uint24 fee,
        address quoteToken,
        uint256 quoteTokenAmount,
        uint16 observationCardinalityNext,
        address positionManagerAddress_,
        address swapRouterAddress_
    ) internal virtual onlyOwner {
        require(!initialized, "has initialized");
        positionManagerAddress = positionManagerAddress_;
        swapRouterAddress = swapRouterAddress_;

        currentPoolData.quoteToken = quoteToken;
        currentPoolData.fee = fee;
        currentPoolData.sqrtPriceX96 = sqrtPriceX96;

        (address token0, address token1) = (address(this), quoteToken);
        (uint256 amount0, uint256 amount1) = (
            balanceOf[address(this)],
            quoteTokenAmount
        );
        if (token0 > token1) {
            (token0, token1) = (token1, token0);
            (amount0, amount1) = (amount1, amount0);
        }
        _approveUniswap(token0, type(uint256).max);
        _approveUniswap(token1, type(uint256).max);

        // step1 create pool
        int24 tickSpacing;
        (
            currentPoolData.poolAddress,
            currentTick,
            tickSpacing
        ) = _initializePool(token0, token1, fee, sqrtPriceX96);
        require(
            currentPoolData.poolAddress != address(0) && tickSpacing != 0,
            "initialize pool failed"
        );
        tickThreshold = currentTick;

        if (_thisIsToken0()) {
            currentPoolData.tickLower = (tickThreshold / tickSpacing) * tickSpacing;
            if (tickThreshold < 0) {
                currentPoolData.tickLower -= tickSpacing;
            }
            // currentPoolData.tickLower =
            //     (TickMath.MIN_TICK / tickSpacing) *
            //     tickSpacing;
            currentPoolData.tickUpper =
                (TickMath.MAX_TICK / tickSpacing) *
                tickSpacing;
        } else {
            currentPoolData.tickUpper = (tickThreshold / tickSpacing) * tickSpacing;
            if (tickThreshold > 0) {
                currentPoolData.tickUpper += tickSpacing;
            }
            currentPoolData.tickLower =
                (TickMath.MIN_TICK / tickSpacing) *
                tickSpacing;
        }

        // step2 increase observation cardinality
        if (observationCardinalityNext > 0) {
            bool success = _initializeObservations(
                currentPoolData.poolAddress,
                observationCardinalityNext
            );
            require(success, "initialize observations failed");
        }

        // step3 create liquidity
        (
            currentPoolData.positionId,
            currentPoolData.liquidity,
            ,

        ) = _initializeLiquidity(
            token0,
            token1,
            fee,
            amount0,
            amount1,
            currentPoolData.tickLower,
            currentPoolData.tickUpper,
            address(this)
        );
        require(currentPoolData.positionId != 0, "initialize liquidity failed");
        mintTimestamp = block.timestamp;

        initialized = true;
        emit Initialize(currentPoolData);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function _getCurrentTokenTick() internal virtual returns (int24) {
        if (!initialized) {
            return tickThreshold;
        }

        // Call uniswapV3Pool.slot0
        // 0x3850c7bd: keccak256(slot0())
        (bool success0, bytes memory data0) = currentPoolData
            .poolAddress
            .staticcall(abi.encodeWithSelector(0x3850c7bd));
        if (!success0) {
            return tickThreshold;
        }

        // Decode `Slot` from returned data
        (, int24 tick, uint16 index, uint16 cardinality, , , ) = abi.decode(
            data0,
            (uint160, int24, uint16, uint16, uint16, uint8, bool)
        );

        uint32 delta = TWAP_INTERVAL;
        if (uint32(block.timestamp - mintTimestamp) < delta) {
            return tick;
        }

        uint32[] memory secondsTwapIntervals = new uint32[](2);
        secondsTwapIntervals[0] = delta;
        secondsTwapIntervals[1] = 0;

        // Call uniswapV3Pool.observe
        // 0x883bdbfd: keccak256(observe(uint32[]))
        // require(pools[poolFee] != address(0), "Pool must init");
        (bool success, bytes memory data) = currentPoolData
            .poolAddress
            .staticcall(
                abi.encodeWithSelector(0x883bdbfd, secondsTwapIntervals)
            );

        if (!success) {
            return tick;
        }

        // Decode `tickCumulatives` from returned data
        (int56[] memory tickCumulatives, ) = abi.decode(
            data,
            (int56[], uint160[])
        );

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        tick = int24(tickCumulativesDelta / int56(uint56(delta)));
        // Always round to negative infinity
        if (
            tickCumulativesDelta < 0 &&
            (tickCumulativesDelta % int56(uint56(delta)) != 0)
        ) tick--;

        return tick;
    }

    function _approveUniswap(
        address token,
        uint256 amount
    ) internal virtual returns (bool) {
        if (amount == 0) {
            return true;
        }
        if (token == address(this)) {
            allowance[address(this)][positionManagerAddress] = amount;
            allowance[address(this)][swapRouterAddress] = amount;
            return true;
        }

        // Approve the position manager
        // Call approve
        // 0x095ea7b3: keccak256(approve(address,uint256))
        (bool success0, ) = token.call(
            abi.encodeWithSelector(0x095ea7b3, positionManagerAddress, amount)
        );

        (bool success1, ) = token.call(
            abi.encodeWithSelector(0x095ea7b3, swapRouterAddress, amount)
        );
        return success0 && success1;
    }

    function _initializePool(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    )
        internal
        virtual
        returns (address poolAddress, int24 tick, int24 tickSpacing)
    {
        // Call position manager createAndInitializePoolIfNecessary
        // 0x13ead562: keccak256(createAndInitializePoolIfNecessary(address,address,uint24,uint160))
        (bool success0, bytes memory data0) = positionManagerAddress.call(
            abi.encodeWithSelector(
                0x13ead562,
                token0,
                token1,
                fee,
                sqrtPriceX96
            )
        );
        // If createAndInitializePoolIfNecessary hasn't reverted
        if (!success0) {
            return (address(0), 0, 0);
        }
        // Decode `address` from returned data
        poolAddress = abi.decode(data0, (address));

        // Call uniswapV3Pool.slot0
        // 0x3850c7bd: keccak256(slot0())
        (bool success1, bytes memory data1) = poolAddress.staticcall(
            abi.encodeWithSelector(0x3850c7bd)
        );
        if (!success1) {
            return (address(0), 0, 0);
        }
        // Decode `Slot` from returned data
        (, tick, , , , , ) = abi.decode(
            data1,
            (uint160, int24, uint16, uint16, uint16, uint8, bool)
        );

        // Call uniswapV3Pool.tickSpacing
        // 0xd0c93a7c: keccak256(tickSpacing())
        (bool success2, bytes memory data2) = poolAddress.staticcall(
            abi.encodeWithSelector(0xd0c93a7c)
        );
        if (!success2) {
            return (address(0), 0, 0);
        }
        tickSpacing = abi.decode(data2, (int24));
    }

    function _initializeObservations(
        address poolAddress,
        uint16 observationCardinalityNext
    ) internal virtual returns (bool) {
        // Call pool increaseObservationCardinalityNext
        // 0x32148f67: keccak256(increaseObservationCardinalityNext(uint16))
        (bool success, ) = poolAddress.call(
            abi.encodeWithSelector(0x32148f67, observationCardinalityNext)
        );
        return success;
    }

    function _initializeLiquidity(
        address token0,
        address token1,
        uint24 fee,
        uint256 amount0,
        uint256 amount1,
        int24 tickLower,
        int24 tickUpper,
        address recipient
    )
        internal
        virtual
        returns (
            uint256 positionId,
            uint128 liquidity,
            uint256 amount0Used,
            uint256 amount1Used
        )
    {
        MintParams memory params = MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: recipient,
            deadline: block.timestamp
        });
        // Call position manager mint
        // 0x88316456: keccak256(mint((address,address,uint24,int24,int24,uint256,
        // uint256,uint256,uint256,address,uint256)))
        (bool success, bytes memory data) = positionManagerAddress.call(
            abi.encodeWithSelector(0x88316456, params)
        );

        // If mint hasn't reverted
        if (success) {
            // Decode `(uint256, uint128, uint256, uint256)` from returned data
            (positionId, liquidity, amount0Used, amount1Used) = abi.decode(
                data,
                (uint256, uint128, uint256, uint256)
            );
        }
    }

    function _exactInputSingle(
        address tokenIn,
        address tokenOut,
        address recipient,
        uint256 amountIn
    ) internal virtual returns (uint256 amountOut) {
        ExactInputSingleParams memory params = ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: currentPoolData.fee,
            recipient: recipient,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0,
            deadline: block.timestamp
        });
        // Call position manager increaseLiquidity
        // 0x414bf389: keccak256(exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160)))
        (bool success, bytes memory data) = swapRouterAddress.call(
            abi.encodeWithSelector(0x414bf389, params)
        );

        // If exactInputSingle hasn't reverted
        if (success) {
            // Decode `(uint128, uint256, uint256)` from returned data
            amountOut = abi.decode(data, (uint256));
        }
    }

    function _increaseLiquidity(
        uint256 positionId,
        uint256 amount0,
        uint256 amount1
    )
        internal
        virtual
        returns (uint128 liquidity, uint256 amount0Used, uint256 amount1Used)
    {
        IncreaseLiquidityParams memory params = IncreaseLiquidityParams({
            tokenId: positionId,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });
        // Call position manager increaseLiquidity
        // 0x219f5d17: keccak256(increaseLiquidity((uint256,uint256,uint256,uint256,uint256,uint256)))
        (bool success, bytes memory data) = positionManagerAddress.call(
            abi.encodeWithSelector(0x219f5d17, params)
        );

        // If increaseLiquidity hasn't reverted
        if (success) {
            // Decode `(uint128, uint256, uint256)` from returned data
            (liquidity, amount0Used, amount1Used) = abi.decode(
                data,
                (uint128, uint256, uint256)
            );
        }
    }

    function _decreaseLiquidity(
        uint256 positionId,
        uint128 liquidity
    ) internal virtual returns (uint256 amount0, uint256 amount1) {
        DecreaseLiquidityParams memory params = DecreaseLiquidityParams({
            tokenId: positionId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });
        // Call position manager increaseLiquidity
        // 0x0c49ccbe: keccak256(decreaseLiquidity((uint256,uint128,uint256,uint256,uint256)))
        (bool success, bytes memory data) = positionManagerAddress.call(
            abi.encodeWithSelector(0x0c49ccbe, params)
        );

        // If decreaseLiquidity hasn't reverted
        if (success) {
            // Decode `(uint128, uint256, uint256)` from returned data
            (amount0, amount1) = abi.decode(data, (uint256, uint256));
        }
    }

    function _collect(
        uint256 positionId,
        address recipient
    ) internal virtual returns (uint256 amount0, uint256 amount1) {
        CollectParams memory params = CollectParams({
            tokenId: positionId,
            recipient: recipient,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });
        // Call position manager increaseLiquidity
        // 0xfc6f7865: keccak256(collect((uint256,address,uint128,uint128)))
        (bool success, bytes memory data) = positionManagerAddress.call(
            abi.encodeWithSelector(0xfc6f7865, params)
        );

        // If decreaseLiquidity hasn't reverted
        if (success) {
            // Decode `(uint128, uint256, uint256)` from returned data
            (amount0, amount1) = abi.decode(data, (uint256, uint256));
        }
    }

    function _thisIsToken0() internal view returns(bool) {
        return (address(this) < currentPoolData.quoteToken);
    }

    function _getTaxOrBurned(
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (uint256 tax, bool burned) {
        if (
            msg.sender == initialMintRecipient ||
            msg.sender == swapRouterAddress ||
            from_ == address(this) ||
            to_ == address(currentPoolData.poolAddress)
        ) {
            return (0, false);
        }

        // get token tick
        currentTick = _getCurrentTokenTick();
        if (_thisIsToken0()) {
            if (currentTick > tickThreshold) {
                tax = (value_ * taxPercent) / 1000000;
            } else if (currentTick < tickThreshold) {
                burned = true;
            } else {
                // do someting if getCurrentTokenTick failed
            }
        } else {
            if (currentTick < tickThreshold) {
                tax = (value_ * taxPercent) / 1000000;
            } else if (currentTick > tickThreshold) {
                burned = true;
            } else {
                // do someting if getCurrentTokenTick failed
            }
        }
    }

    function _transferWithTax(
        address from_,
        address to_,
        uint256 value_
    ) public virtual returns (bool) {
        (uint256 tax, bool burned) = _getTaxOrBurned(from_, to_, value_);
        if (burned) {
            // burn from_ token,
            _transferERC20WithERC721(from_, address(0), value_);
            // refund the ETH value to the to_ address
            _refundETH(to_, value_);
            totalSupply -= value_;
            emit ERC20Burn(value_);
        } else if (tax > 0) {
            _transferERC20WithERC721(from_, to_, value_ - tax);
            _transferERC20WithERC721(from_, address(this), tax);
            totalTax += tax;
            emit ReceiveTax(tax);
        } else {
            // Transferring ERC-20s directly requires the _transfer function.
            _transferERC20WithERC721(from_, to_, value_);
        }

        return true;
    }

    function swapAndLiquify(uint256 amount) external virtual onlyOwner {
        require(
            amount <= ((balanceOf[address(this)] * 2) / 3),
            "amount is too large"
        );

        // swap tokens for ETH
        uint256 quoteAmount = swapTokensForQuote(amount);

        if (quoteAmount > 0) {
            // add liquidity to uniswap
            addLiquidity(balanceOf[address(this)], quoteAmount / 2);
        }
    }

    function liquifyAndCollect(uint128 liquidity) external virtual onlyOwner {
        require(
            liquidity <= (currentPoolData.liquidity),
            "liquidity is too large"
        );
        if (liquidity > 0) {
            subLiquidity(liquidity);
        }
        _collect(currentPoolData.positionId, initialMintRecipient);
    }

    function swapTokensForQuote(uint256 tokenAmount) private returns (uint256) {
        return
            _exactInputSingle(
                address(this),
                currentPoolData.quoteToken,
                address(this),
                tokenAmount
            );
    }

    function addLiquidity(uint256 thisAmount, uint256 quoteAmount) private {
        (address token0, address token1) = (
            address(this),
            currentPoolData.quoteToken
        );

        (uint256 amount0, uint256 amount1) = (thisAmount, quoteAmount);

        if (token0 > token1) {
            (token0, token1) = (token1, token0);
            (amount0, amount1) = (amount1, amount0);
        }

        uint128 liquidity;
        (liquidity, amount0, amount1) = _increaseLiquidity(
            currentPoolData.positionId,
            amount0,
            amount1
        );
        if (liquidity > 0) {
            currentPoolData.liquidity += liquidity;
        }
    }

    function subLiquidity(uint128 liquidity) private {
        (uint256 amount0, uint256 amount1) = _decreaseLiquidity(
            currentPoolData.positionId,
            liquidity
        );
        if (amount0 > 0 || amount1 > 0) {
            currentPoolData.liquidity -= liquidity;
        }
    }

    /// @notice Function for ERC-20 transfers.
    /// @dev This function assumes the operator is attempting to transfer as ERC-20
    ///      given this function is only supported on the ERC-20 interface
    function transfer(
        address to_,
        uint256 value_
    ) public override returns (bool) {
        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        return _transferWithTax(msg.sender, to_, value_);
    }

    /// @notice Function for mixed transfers from an operator that may be different than 'from'.
    /// @dev This function assumes the operator is attempting to transfer an ERC-721
    ///      if valueOrId is less than or equal to current max id.
    function transferFrom(
        address from_,
        address to_,
        uint256 valueOrId_
    ) public override returns (bool) {
        // Prevent transferring tokens from 0x0.
        if (from_ == address(0)) {
            revert InvalidSender();
        }

        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        if (valueOrId_ <= _minted) {
            // Intention is to transfer as ERC-721 token (id).
            uint256 id = valueOrId_;

            if (from_ != _getOwnerOf(id)) {
                revert Unauthorized();
            }

            // Check that the operator is either the sender or approved for the transfer.
            if (
                msg.sender != from_ &&
                !isApprovedForAll[from_][msg.sender] &&
                msg.sender != getApproved[id]
            ) {
                revert Unauthorized();
            }

            // Transfer 1 * units ERC-20 and 1 ERC-721 token.
            _transferERC20(from_, to_, units);
            _transferERC721(from_, to_, id);
        } else {
            // Intention is to transfer as ERC-20 token (value).
            uint256 value = valueOrId_;
            uint256 allowed = allowance[from_][msg.sender];

            // Check that the operator has sufficient allowance.
            if (allowed != type(uint256).max) {
                allowance[from_][msg.sender] = allowed - value;
            }

            return _transferWithTax(from_, to_, value);
        }

        return true;
    }

    function _refundETH(address account, uint256 value) internal virtual {
        if (account == address(0)) {
            revert InvalidSender();
        }

        // Call balanceOf
        // 0x70a08231: keccak256(balanceOf(address))
        (bool success0, bytes memory data0) = currentPoolData
            .quoteToken
            .staticcall(abi.encodeWithSelector(0x70a08231, address(this)));
        if (!success0) {
            return;
        }
        // Decode `uint256` from returned data
        uint256 totalWETHAmount = abi.decode(data0, (uint256));

        uint256 wethAmount = (value * totalWETHAmount) / totalSupply;

        // Call WETH transfer
        // 0xa9059cbb: keccak256(transfer(address,uint256))
        (bool success, ) = currentPoolData.quoteToken.call(
            abi.encodeWithSelector(0xa9059cbb, account, wethAmount)
        );

        // If transfer hasn't reverted
        if (success) {
            emit RefundETH(account, wethAmount);
        }
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC404} from "./interfaces/IERC404.sol";
import {ERC721Receiver} from "./lib/ERC721Receiver.sol";
import {DoubleEndedQueue} from "./lib/DoubleEndedQueue.sol";
import {IERC165} from "./lib/interfaces/IERC165.sol";
import {ERC721Events} from "./lib/ERC721Events.sol";
import {ERC20Events} from "./lib/ERC20Events.sol";

abstract contract ERC404 is IERC404 {
    using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;

    /// @dev The queue of ERC-721 tokens stored in the contract.
    DoubleEndedQueue.Uint256Deque private _storedERC721Ids;

    /// @dev Token name
    string public name;

    /// @dev Token symbol
    string public symbol;

    /// @dev Decimals for ERC-20 representation
    uint8 public immutable decimals;

    /// @dev Units for ERC-20 representation
    uint256 public immutable units;

    /// @dev Total supply in ERC-20 representation
    uint256 public totalSupply;

    /// @dev Current mint counter which also represents the highest
    ///      minted id, monotonically increasing to ensure accurate ownership
    uint256 internal _minted;

    /// @dev Initial chain id for EIP-2612 support
    uint256 internal immutable INITIAL_CHAIN_ID;

    /// @dev Initial domain separator for EIP-2612 support
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

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
    mapping(address => bool) public erc721TransferExempt;

    /// @dev EIP-2612 nonces
    mapping(address => uint256) public nonces;

    /// @dev Address bitmask for packed ownership data
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    /// @dev Owned index bitmask for packed ownership data
    uint256 private constant _BITMASK_OWNED_INDEX = ((1 << 96) - 1) << 160;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint8 ratio_
    ) {
        name = name_;
        symbol = symbol_;

        if (decimals_ < 18) {
            revert DecimalsTooLow();
        }

        decimals = decimals_;
        units = 10 ** decimals * ratio_;

        // EIP-2612 initialization
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    /// @notice Function to find owner of a given ERC-721 token
    function ownerOf(
        uint256 id_
    ) public view virtual returns (address erc721Owner) {
        erc721Owner = _getOwnerOf(id_);

        // If the id_ is beyond the range of minted tokens, is 0, or the token is not owned by anyone, revert.
        if (id_ > _minted || id_ == 0 || erc721Owner == address(0)) {
            revert NotFound();
        }
    }

    function owned(
        address owner_
    ) public view virtual returns (uint256[] memory) {
        return _owned[owner_];
    }

    function erc721BalanceOf(
        address owner_
    ) public view virtual returns (uint256) {
        return _owned[owner_].length;
    }

    function erc20BalanceOf(
        address owner_
    ) public view virtual returns (uint256) {
        return balanceOf[owner_];
    }

    function erc20TotalSupply() public view virtual returns (uint256) {
        return totalSupply;
    }

    function erc721TotalSupply() public view virtual returns (uint256) {
        return _minted;
    }

    function erc721TokensBankedInQueue() public view virtual returns (uint256) {
        return _storedERC721Ids.length();
    }

    /// @notice tokenURI must be implemented by child contract
    function tokenURI(uint256 id_) public view virtual returns (string memory);

    /// @notice Function for token approvals
    /// @dev This function assumes the operator is attempting to approve an ERC-721
    ///      if valueOrId is less than the minted count. Note: Unlike setApprovalForAll,
    ///      spender_ must be allowed to be 0x0 so that approval can be revoked.
    function approve(
        address spender_,
        uint256 valueOrId_
    ) public virtual returns (bool) {
        // The ERC-721 tokens are 1-indexed, so 0 is not a valid id and indicates that
        // operator is attempting to set the ERC-20 allowance to 0.
        if (valueOrId_ <= _minted && valueOrId_ > 0) {
            // Intention is to approve as ERC-721 token (id).
            uint256 id = valueOrId_;
            address erc721Owner = _getOwnerOf(id);

            if (
                msg.sender != erc721Owner &&
                !isApprovedForAll[erc721Owner][msg.sender]
            ) {
                revert Unauthorized();
            }

            getApproved[id] = spender_;

            emit ERC721Events.Approval(erc721Owner, spender_, id);
        } else {
            // Prevent granting 0x0 an ERC-20 allowance.
            if (spender_ == address(0)) {
                revert InvalidSpender();
            }

            // Intention is to approve as ERC-20 token (value).
            uint256 value = valueOrId_;
            allowance[msg.sender][spender_] = value;

            emit ERC20Events.Approval(msg.sender, spender_, value);
        }

        return true;
    }

    /// @notice Function for ERC-721 approvals
    function setApprovalForAll(
        address operator_,
        bool approved_
    ) public virtual {
        // Prevent approvals to 0x0.
        if (operator_ == address(0)) {
            revert InvalidOperator();
        }
        isApprovedForAll[msg.sender][operator_] = approved_;
        emit ApprovalForAll(msg.sender, operator_, approved_);
    }

    /// @notice Function for mixed transfers from an operator that may be different than 'from'.
    /// @dev This function assumes the operator is attempting to transfer an ERC-721
    ///      if valueOrId is less than or equal to current max id.
    function transferFrom(
        address from_,
        address to_,
        uint256 valueOrId_
    ) public virtual returns (bool) {
        // Prevent transferring tokens from 0x0.
        if (from_ == address(0)) {
            revert InvalidSender();
        }

        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        if (valueOrId_ <= _minted) {
            // Intention is to transfer as ERC-721 token (id).
            uint256 id = valueOrId_;

            if (from_ != _getOwnerOf(id)) {
                revert Unauthorized();
            }

            // Check that the operator is either the sender or approved for the transfer.
            if (
                msg.sender != from_ &&
                !isApprovedForAll[from_][msg.sender] &&
                msg.sender != getApproved[id]
            ) {
                revert Unauthorized();
            }

            // Transfer 1 * units ERC-20 and 1 ERC-721 token.
            _transferERC20(from_, to_, units);
            _transferERC721(from_, to_, id);
        } else {
            // Intention is to transfer as ERC-20 token (value).
            uint256 value = valueOrId_;
            uint256 allowed = allowance[from_][msg.sender];

            // Check that the operator has sufficient allowance.
            if (allowed != type(uint256).max) {
                allowance[from_][msg.sender] = allowed - value;
            }

            // Transferring ERC-20s directly requires the _transfer function.
            _transferERC20WithERC721(from_, to_, value);
        }

        return true;
    }

    /// @notice Function for ERC-20 transfers.
    /// @dev This function assumes the operator is attempting to transfer as ERC-20
    ///      given this function is only supported on the ERC-20 interface
    function transfer(
        address to_,
        uint256 value_
    ) public virtual returns (bool) {
        // Prevent burning tokens to 0x0.
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        // Transferring ERC-20s directly requires the _transfer function.
        return _transferERC20WithERC721(msg.sender, to_, value_);
    }

    /// @notice Function for ERC-721 transfers with contract support.
    function safeTransferFrom(
        address from_,
        address to_,
        uint256 id_
    ) public virtual {
        transferFrom(from_, to_, id_);

        if (
            to_.code.length != 0 &&
            ERC721Receiver(to_).onERC721Received(msg.sender, from_, id_, "") !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Function for ERC-721 transfers with contract support and callback data.
    function safeTransferFrom(
        address from_,
        address to_,
        uint256 id_,
        bytes calldata data_
    ) public virtual {
        transferFrom(from_, to_, id_);

        if (
            to_.code.length != 0 &&
            ERC721Receiver(to_).onERC721Received(
                msg.sender,
                from_,
                id_,
                data_
            ) !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Function for EIP-2612 permits
    function permit(
        address owner_,
        address spender_,
        uint256 value_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) public virtual {
        if (deadline_ < block.timestamp) {
            revert PermitDeadlineExpired();
        }

        if (value_ <= _minted && value_ > 0) {
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
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : _computeDomainSeparator();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
            interfaceId == type(IERC404).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
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

    function calculateERC721Transfers(
        address from_,
        uint256 value_
    ) public view returns (uint256[] memory tokenIds) {
        //first check it's possible to send this value
        uint256 erc20BalanceOfSenderBefore = erc20BalanceOf(from_);

        if (!erc721TransferExempt[from_]) {
            uint256 nftsToTransfer = value_ / units;
            uint256 fractionalAmount = value_ % units;

            //account for fractional NFT removal
            if (
                (erc20BalanceOfSenderBefore - fractionalAmount) / units <
                (erc20BalanceOfSenderBefore / units)
            ) {
                nftsToTransfer++;
            }

            if (nftsToTransfer > 0) {
                tokenIds = new uint256[](nftsToTransfer);

                for (uint256 i = 0; i < nftsToTransfer; i++) {
                    // Pop from sender's ERC-721 stack and transfer them (LIFO)
                    uint256 indexOfLastToken = _owned[from_].length - (1 + i);
                    tokenIds[i] = _owned[from_][indexOfLastToken];
                }
            }
        }
    }

    /// @notice This is the lowest level ERC-20 transfer function, which
    ///         should be used for both normal ERC-20 transfers as well as minting.
    /// Note that this function allows transfers to and from 0x0.
    function _transferERC20(
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        // Minting is a special case for which we should not check the balance of
        // the sender, and we should increase the total supply.
        if (from_ == address(0)) {
            totalSupply += value_;
        } else {
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
    function _transferERC721(
        address from_,
        address to_,
        uint256 id_
    ) internal virtual {
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

        if (to_ != address(0)) {
            // Update owner of the token to the new owner.
            _setOwnerOf(id_, to_);
            // Push token onto the new owner's stack.
            _owned[to_].push(id_);
            // Update index for new owner's stack.
            _setOwnedIndex(id_, _owned[to_].length - 1);
        } else {
            delete _ownedData[id_];
        }

        emit ERC721Events.Transfer(from_, to_, id_);
    }

    /// @notice Internal function for ERC-20 transfers. Also handles any ERC-721 transfers that may be required.
    function _transferERC20WithERC721(
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool) {
        uint256 erc20BalanceOfSenderBefore = erc20BalanceOf(from_);
        uint256 erc20BalanceOfReceiverBefore = erc20BalanceOf(to_);

        _transferERC20(from_, to_, value_);

        // Preload for gas savings on branches
        bool isFromERC721TransferExempt = erc721TransferExempt[from_];
        bool isToERC721TransferExempt = erc721TransferExempt[to_];

        // Skip _withdrawAndStoreERC721 and/or _retrieveOrMintERC721 for ERC-721 transfer exempt addresses
        // 1) to save gas
        // 2) because ERC-721 transfer exempt addresses won't always have/need ERC-721s corresponding to their ERC20s.
        if (isFromERC721TransferExempt && isToERC721TransferExempt) {
            // Case 1) Both sender and recipient are ERC-721 transfer exempt. No ERC-721s need to be transferred.
            // NOOP.
        } else if (isFromERC721TransferExempt) {
            // Case 2) The sender is ERC-721 transfer exempt, but the recipient is not. Contract should not attempt
            //         to transfer ERC-721s from the sender, but the recipient should receive ERC-721s
            //         from the bank/minted for any whole number increase in their balance.
            // Only cares about whole number increments.
            uint256 tokensToRetrieveOrMint = (balanceOf[to_] / units) -
                (erc20BalanceOfReceiverBefore / units);
            for (uint256 i = 0; i < tokensToRetrieveOrMint; i++) {
                _retrieveOrMintERC721(to_);
            }
        } else if (isToERC721TransferExempt) {
            // Case 3) The sender is not ERC-721 transfer exempt, but the recipient is. Contract should attempt
            //         to withdraw and store ERC-721s from the sender, but the recipient should not
            //         receive ERC-721s from the bank/minted.
            // Only cares about whole number increments.
            uint256 tokensToWithdrawAndStore = (erc20BalanceOfSenderBefore /
                units) - (balanceOf[from_] / units);
            for (uint256 i = 0; i < tokensToWithdrawAndStore; i++) {
                _withdrawAndStoreERC721(from_);
            }
        } else {
            // Case 4) Neither the sender nor the recipient are ERC-721 transfer exempt.
            // Strategy:
            // 1. First deal with the whole tokens. These are easy and will just be transferred.
            // 2. Look at the fractional part of the value:
            //   a) If it causes the sender to lose a whole token that was represented by an NFT due to a
            //      fractional part being transferred, withdraw and store an additional NFT from the sender.
            //   b) If it causes the receiver to gain a whole new token that should be represented by an NFT
            //      due to receiving a fractional part that completes a whole token, retrieve or mint an NFT to the recevier.

            // Whole tokens worth of ERC-20s get transferred as ERC-721s without any burning/minting.
            uint256 nftsToTransfer = value_ / units;
            for (uint256 i = 0; i < nftsToTransfer; i++) {
                // Pop from sender's ERC-721 stack and transfer them (LIFO)
                uint256 indexOfLastToken = _owned[from_].length - 1;
                uint256 tokenId = _owned[from_][indexOfLastToken];
                _transferERC721(from_, to_, tokenId);
            }

            // If the sender's transaction changes their holding from a fractional to a non-fractional
            // amount (or vice versa), adjust ERC-721s.
            //
            // Check if the send causes the sender to lose a whole token that was represented by an ERC-721
            // due to a fractional part being transferred.
            //
            // To check this, look if subtracting the fractional amount from the balance causes the balance to
            // drop below the original balance % units, which represents the number of whole tokens they started with.
            uint256 fractionalAmount = value_ % units;

            if (
                (erc20BalanceOfSenderBefore - fractionalAmount) / units <
                (erc20BalanceOfSenderBefore / units)
            ) {
                _withdrawAndStoreERC721(from_);
            }

            // Check if the receive causes the receiver to gain a whole new token that should be represented
            // by an NFT due to receiving a fractional part that completes a whole token.
            if (
                (erc20BalanceOfReceiverBefore + fractionalAmount) / units >
                (erc20BalanceOfReceiverBefore / units)
            ) {
                _retrieveOrMintERC721(to_);
            }
        }

        return true;
    }

    /// @notice Internal function for ERC20 minting
    /// @dev This function will allow minting of new ERC20s.
    ///      If mintCorrespondingERC721s_ is true, it will also mint the corresponding ERC721s.
    function _mintERC20(
        address to_,
        uint256 value_,
        bool mintCorrespondingERC721s_
    ) internal virtual {
        /// You cannot mint to the zero address (you can't mint and immediately burn in the same transfer).
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        _transferERC20(address(0), to_, value_);

        // If mintCorrespondingERC721s_ is true, mint the corresponding ERC721s.
        if (mintCorrespondingERC721s_) {
            uint256 nftsToRetrieveOrMint = value_ / units;
            for (uint256 i = 0; i < nftsToRetrieveOrMint; i++) {
                _retrieveOrMintERC721(to_);
            }
        }
    }

    /// @notice Internal function for ERC-721 minting and retrieval from the bank.
    /// @dev This function will allow minting of new ERC-721s up to the total fractional supply. It will
    ///      first try to pull from the bank, and if the bank is empty, it will mint a new token.
    function _retrieveOrMintERC721(address to_) internal virtual {
        if (to_ == address(0)) {
            revert InvalidRecipient();
        }

        uint256 id;

        if (!DoubleEndedQueue.empty(_storedERC721Ids)) {
            // If there are any tokens in the bank, use those first.
            // Pop off the end of the queue (FIFO).
            id = _storedERC721Ids.popBack();
        } else {
            // Otherwise, mint a new token, should not be able to go over the total fractional supply.
            _minted++;
            id = _minted;
        }

        address erc721Owner = _getOwnerOf(id);

        // The token should not already belong to anyone besides 0x0 or this contract.
        // If it does, something is wrong, as this should never happen.
        if (erc721Owner != address(0)) {
            revert AlreadyExists();
        }

        // Transfer the token to the recipient, either transferring from the contract's bank or minting.
        _transferERC721(erc721Owner, to_, id);
    }

    /// @notice Internal function for ERC-721 deposits to bank (this contract).
    /// @dev This function will allow depositing of ERC-721s to the bank, which can be retrieved by future minters.
    function _withdrawAndStoreERC721(address from_) internal virtual {
        if (from_ == address(0)) {
            revert InvalidSender();
        }

        // Retrieve the latest token added to the owner's stack (LIFO).
        uint256 id = _owned[from_][_owned[from_].length - 1];

        // Transfer the token to the contract.
        _transferERC721(from_, address(0), id);

        // Record the token in the contract's bank queue.
        _storedERC721Ids.pushFront(id);
    }

    /// @notice Initialization function to set pairs / etc, saving gas by avoiding mint / burn on unnecessary targets
    function _setERC721TransferExempt(
        address target_,
        bool state_
    ) internal virtual {
        // If the target has at least 1 full ERC-20 token, they should not be removed from the exempt list
        // because if they were and then they attempted to transfer, it would revert as they would not
        // necessarily have ehough ERC-721s to bank.
        if (erc20BalanceOf(target_) >= units && !state_) {
            revert CannotRemoveFromERC721TransferExempt();
        }
        erc721TransferExempt[target_] = state_;
    }

    function _getOwnerOf(
        uint256 id_
    ) internal view virtual returns (address ownerOf_) {
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

    function _getOwnedIndex(
        uint256 id_
    ) internal view virtual returns (uint256 ownedIndex_) {
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
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "../lib/interfaces/IERC165.sol";

interface IERC404 is IERC165 {
    // event Approval(address owner, address spender, uint256 value);

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);
    // event ERC721Transfer(
    //     address indexed from,
    //     address indexed to,
    //     uint256 indexed id
    // );

    error NotFound();
    error InvalidId();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error InvalidSpender();
    error InvalidOperator();
    error UnsafeRecipient();
    error NotERC721TransferExempt();
    error Unauthorized();
    error InsufficientAllowance();
    error DecimalsTooLow();
    error CannotRemoveFromERC721TransferExempt();
    error PermitDeadlineExpired();
    error InvalidSigner();
    error InvalidApproval();
    error OwnedIndexOverflow();

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function erc20TotalSupply() external view returns (uint256);

    function erc721TotalSupply() external view returns (uint256);

    function balanceOf(address owner_) external view returns (uint256);

    function erc721BalanceOf(address owner_) external view returns (uint256);

    function erc20BalanceOf(address owner_) external view returns (uint256);

    function erc721TransferExempt(
        address account_
    ) external view returns (bool);

    function isApprovedForAll(
        address owner_,
        address operator_
    ) external view returns (bool);

    function allowance(
        address owner_,
        address spender_
    ) external view returns (uint256);

    function owned(address owner_) external view returns (uint256[] memory);

    function ownerOf(uint256 id_) external view returns (address erc721Owner);

    function tokenURI(uint256 id_) external view returns (string memory);

    function approve(
        address spender_,
        uint256 valueOrId_
    ) external returns (bool);

    function setApprovalForAll(address operator_, bool approved_) external;

    function transferFrom(
        address from_,
        address to_,
        uint256 valueOrId_
    ) external returns (bool);

    function transfer(address to_, uint256 amount_) external returns (bool);

    function erc721TokensBankedInQueue() external view returns (uint256);

    function safeTransferFrom(address from_, address to_, uint256 id_) external;

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 id_,
        bytes calldata data_
    ) external;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/DoubleEndedQueue.sol)
// Modified by Pandora Labs to support native uint256 operations
pragma solidity ^0.8.20;

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Bytes32Deque`. Other types can be cast to and from `bytes32`. This data structure can only be
 * used in storage, and not in memory.
 * ```solidity
 * DoubleEndedQueue.Bytes32Deque queue;
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
  function popBack(
    Uint256Deque storage deque
  ) internal returns (uint256 value) {
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
  function popFront(
    Uint256Deque storage deque
  ) internal returns (uint256 value) {
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
  function front(
    Uint256Deque storage deque
  ) internal view returns (uint256 value) {
    if (empty(deque)) revert QueueEmpty();
    return deque._data[deque._begin];
  }

  /**
   * @dev Returns the item at the end of the queue.
   *
   * Reverts with `QueueEmpty` if the queue is empty.
   */
  function back(
    Uint256Deque storage deque
  ) internal view returns (uint256 value) {
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
  function at(
    Uint256Deque storage deque,
    uint256 index
  ) internal view returns (uint256 value) {
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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ERC20Events {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ERC721Events {
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external virtual returns (bytes4) {
    return ERC721Receiver.onERC721Received.selector;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

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
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC333} from "./ERC333/ERC333.sol";
import {FullMath} from "./utils/FullMath.sol";

contract WHO404 is ERC333 {
    using Strings for uint256;

    string private constant __NAME = "WHO404";
    string private constant __SYM = "WHO";
    uint256 private constant __MINT_SUPPLY = 1000;
    uint24 private constant __TAX_PERCENT = 80000;
    uint8 private constant __DECIMALS = 18;
    uint8 private constant __RATIO = 100;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    mapping(address => bool) public operators;
    bool marketLimit = false;

    constructor(
        address initialOwner_,
        address initialMintRecipient_
    )
        ERC333(
            initialOwner_,
            initialMintRecipient_,
            __MINT_SUPPLY,
            __TAX_PERCENT,
            __NAME,
            __SYM,
            __DECIMALS,
            __RATIO
        )
    {
        baseURI = "https://who404.wtf/assets/";
    }

    function initialize() external payable override onlyOwner {
        address positionManagerAddress = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
        address swapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        if (msg.value > 0) {
            depositETH(msg.value);
        }

        uint160 sqrtPriceX96 = (address(this) < WETH)
            ? 1372272028650297984479657984 // 0.0003
            : 4574240095500993129133247561728; // 3333.333333333333

        uint256 quoteTokenAmount = _getWETHAtSqrtPriceX96(sqrtPriceX96);
        // require(quoteTokenAmount > 14e17, "quoteTokenAmount");

        uint256 wethAmount = balanceOfWETH();
        require(wethAmount >= quoteTokenAmount, "weth amount is too low");

        _initialize(
            sqrtPriceX96,
            3000,
            WETH,
            quoteTokenAmount,
            60,
            positionManagerAddress,
            swapRouterAddress
        );
    }

    function register(address operator_, bool value) external onlyOwner {
        operators[operator_] = value;
    }

    function registerAll() external onlyOwner {
        operators[0xa7FD99748cE527eAdC0bDAc60cba8a4eF4090f7c] = true; // 聚合器
        operators[0x82C0fDFA607d9aFbe82Db5cBD103D1a4D5a43B77] = true; // 强制版税市场
        operators[0x5B93A825829f4B7B5177c259Edc22b63d6E4e380] = true; // 批量转移工具
        marketLimit = true;
    }

    function _transferERC721(
        address from_,
        address to_,
        uint256 id_
    ) internal override {
        if (marketLimit == true) {
            require(
                msg.sender == owner() ||
                    msg.sender == initialMintRecipient ||
                    operators[msg.sender],
                "not allowed"
            );
        }
        super._transferERC721(from_, to_, id_);
    }

    function balanceOfWETH() internal returns (uint256 amount) {
        // Call balanceOf
        // 0x70a08231: keccak256(balanceOf(address))
        (bool success, bytes memory data) = WETH.staticcall(
            abi.encodeWithSelector(0x70a08231, address(this))
        );
        if (success) {
            // Decode `uint256` from returned data
            amount = abi.decode(data, (uint256));
        }
    }

    function depositETH(uint256 amount) internal returns (bool) {
        // Deposit the eth
        // Call deposit
        // 0xd0e30db0: keccak256(deposit())
        (bool success, ) = WETH.call{value: amount}(
            abi.encodeWithSelector(0xd0e30db0)
        );
        return success;
    }

    function _getWETHAtSqrtPriceX96(
        uint160 sqrtPriceX96
    ) private view returns (uint256 quoteAmount) {
        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        uint256 thisAmount = balanceOf[address(this)];
        if (sqrtPriceX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtPriceX96) * sqrtPriceX96;
            quoteAmount = address(this) < WETH
                ? FullMath.mulDiv(ratioX192, thisAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, thisAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(
                sqrtPriceX96,
                sqrtPriceX96,
                1 << 64
            );
            quoteAmount = address(this) < WETH
                ? FullMath.mulDiv(ratioX128, thisAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, thisAmount, ratioX128);
        }
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(id))));
        string memory image;
        string memory color;

        if (seed <= 64) {
            image = "0.png";
            color = "Red";
        } else if (seed <= 128) {
            image = "1.png";
            color = "Blue";
        } else if (seed <= 192) {
            image = "2.png";
            color = "Green";
        } else {
            image = "3.png";
            color = "Purple";
        }

        return
            string(
                abi.encodePacked(
                    '{"name": "WHO404 NFT#',
                    Strings.toString(id),
                    '","description":"A collection of ',
                    Strings.toString(mintSupply),
                    " pots of liquidity that tokenizes decentralized reserve currency idea for the IQ50, #ERC333.",
                    '","external_url":"https://who404.wtf/","image":"',
                    baseURI,
                    image,
                    '","attributes":[{"trait_type":"Color","value":"',
                    color,
                    '"}]}'
                )
            );
    }

    receive() external payable {
        depositETH(msg.value);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct PoolData {
  address poolAddress;
  address quoteToken;
  uint24 fee;
  uint256 positionId;
  uint160 sqrtPriceX96;
  int24 tickLower;
  int24 tickUpper;
  uint128 liquidity;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
}

struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
}

struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
}

struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            // EDIT for 0.8 compatibility:
            // see: https://ethereum.stackexchange.com/questions/96642/unary-operator-cannot-be-applied-to-type-uint256
            uint256 twos = denominator & (~denominator + 1);

            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title PoolAddress modified to have <0.8 POOL_INIT_CODE_HASH
library PoolAddress {
  bytes32 internal constant POOL_INIT_CODE_HASH =
    0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

  /// @notice The identifying key of the pool
  struct PoolKey {
    address token0;
    address token1;
    uint24 fee;
  }

  /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
  /// @param tokenA The first token of a pool, unsorted
  /// @param tokenB The second token of a pool, unsorted
  /// @param fee The fee level of the pool
  /// @return Poolkey The pool details with ordered token0 and token1 assignments
  function getPoolKey(
    address tokenA,
    address tokenB,
    uint24 fee
  ) internal pure returns (PoolKey memory) {
    if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
    return PoolKey({ token0: tokenA, token1: tokenB, fee: fee });
  }

  /// @notice Deterministically computes the pool address given the factory and PoolKey
  /// @param factory The Uniswap V3 factory contract address
  /// @param key The PoolKey
  /// @return pool The contract address of the V3 pool
  function computeAddress(address factory, PoolKey memory key)
    internal
    pure
    returns (address pool)
  {
    require(key.token0 < key.token1);
    pool = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encode(key.token0, key.token1, key.fee)),
              POOL_INIT_CODE_HASH
            )
          )
        )
      )
    );
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));

        // EDIT: 0.8 compatibility
        require(absTick <= uint256(int256(MAX_TICK)), "T");

        uint256 ratio = absTick & 0x1 != 0
            ? 0xfffcb933bd6fad37aa2d162d1a594001
            : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
            ? tickHi
            : tickLow;
    }
}
/* Attestation decode and validation */
/* AlphaWallet 2021 - 2022 */
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./IERC5169.sol";

abstract contract ERC5169 is IERC5169 {
    string[] private _scriptURI;

    function scriptURI() external view override returns (string[] memory) {
        return _scriptURI;
    }

    function setScriptURI(string[] memory newScriptURI) external override {
        _authorizeSetScripts(newScriptURI);

        _scriptURI = newScriptURI;

        emit ScriptUpdate(newScriptURI);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC5169).interfaceId;
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to set script URI. Called by
     * {setScriptURI}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeSetScripts(string[] memory) internal override onlyOwner {}
     * ```
     */
    function _authorizeSetScripts(string[] memory newScriptURI) internal virtual;
}
/* Attestation decode and validation */
/* AlphaWallet 2021 - 2022 */
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC5169 {
    /// @dev This event emits when the scriptURI is updated,
    /// so wallets implementing this interface can update a cached script
    event ScriptUpdate(string[]);

    /// @notice Get the scriptURI for the contract
    /// @return The scriptURI
    function scriptURI() external view returns (string[] memory);

    /// @notice Update the scriptURI
    /// emits event ScriptUpdate(string[])
    function setScriptURI(string[] memory) external;
}