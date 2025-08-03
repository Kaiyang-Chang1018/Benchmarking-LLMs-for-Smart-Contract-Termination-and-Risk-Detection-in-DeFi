// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
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
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

/**
 * @title Code Jar
 * @notice Deploys contract code to deterministic addresses
 * @author Compound Labs, Inc.
 */
contract CodeJar {
    /**
     * @notice Deploys the code via Code Jar, no-op if it already exists
     * @dev This call is meant to be idemponent and fairly inexpensive on a second call
     * @param code The creation bytecode of the code to save
     * @return The address of the contract that matches the input code's contructor output
     */
    function saveCode(bytes memory code) external returns (address) {
        address codeAddress = getCodeAddress(code);

        if (codeAddress.code.length > 0) {
            // Code is already deployed
            return codeAddress;
        } else {
            // The code has not been deployed here (or it was deployed and destructed).
            address script;
            assembly {
                script := create2(0, add(code, 0x20), mload(code), 0)
            }

            // Posit: these cannot fail and are purely defense-in-depth
            require(script == codeAddress);

            uint256 scriptSz;
            assembly {
                scriptSz := extcodesize(script)
            }

            // Disallow the empty code and self-destructing constructors
            // Note: Script can still self-destruct after being deployed until Dencun
            require(scriptSz > 0);

            return codeAddress;
        }
    }

    /**
     * @notice Checks if code was already deployed by CodeJar
     * @param code The runtime bytecode of the code to check
     * @return True if code already exists in Code Jar
     */
    function codeExists(bytes calldata code) external view returns (bool) {
        address codeAddress = getCodeAddress(code);

        return codeAddress.code.length > 0;
    }

    /**
     * @dev Returns the create2 address based on the creation code
     * @return The create2 address to deploy this code (via init code)
     */
    function getCodeAddress(bytes memory code) public view returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), uint256(0), keccak256(code)))))
        );
    }
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

import {IQuarkWallet} from "quark-core/src/interfaces/IQuarkWallet.sol";

/**
 * @title Quark State Manager
 * @notice Contract for managing nonces and storage for Quark wallets, guaranteeing storage isolation across wallets
 *         and Quark operations
 * @author Compound Labs, Inc.
 */
contract QuarkStateManager {
    event ClearNonce(address indexed wallet, uint96 nonce);

    error NoActiveNonce();
    error NoUnusedNonces();
    error NonceAlreadySet();
    error NonceScriptMismatch();

    /// @notice Bit-packed structure of a nonce-script pair
    struct NonceScript {
        uint96 nonce;
        address scriptAddress;
    }

    /// @notice Bit-packed nonce values
    mapping(address wallet => mapping(uint256 bucket => uint256 bitset)) public nonces;

    /// @notice Per-wallet-nonce address for preventing replays with changed script address
    mapping(address wallet => mapping(uint96 nonce => address scriptAddress)) public nonceScriptAddress;

    /// @notice Per-wallet-nonce storage space that can be utilized while a nonce is active
    mapping(address wallet => mapping(uint96 nonce => mapping(bytes32 key => bytes32 value))) public walletStorage;

    /// @notice Currently active nonce-script pair for a wallet, if any, for which storage is accessible
    mapping(address wallet => NonceScript) internal activeNonceScript;

    /**
     * @notice Return whether a nonce has been exhausted; note that if a nonce is not set, that does not mean it has not been used before
     * @param wallet Address of the wallet owning the nonce
     * @param nonce Nonce to check
     * @return Whether the nonce has been exhausted
     */
    function isNonceSet(address wallet, uint96 nonce) public view returns (bool) {
        (uint256 bucket, uint256 mask) = getBucket(nonce);
        return isNonceSetInternal(wallet, bucket, mask);
    }

    /// @dev Returns if a given nonce is set for a wallet, using the nonce's bucket and mask
    function isNonceSetInternal(address wallet, uint256 bucket, uint256 mask) internal view returns (bool) {
        return (nonces[wallet][bucket] & mask) != 0;
    }

    /**
     * @notice Returns the next valid unset nonce for a given wallet
     * @dev Any unset nonce is valid to use, but using this method
     * increases the likelihood that the nonce you use will be in a bucket that
     * has already been written to, which costs less gas
     * @param wallet Address of the wallet to find the next nonce for
     * @return The next unused nonce
     */
    function nextNonce(address wallet) external view returns (uint96) {
        // Any bucket larger than `type(uint88).max` will result in unsafe undercast when converting to nonce
        for (uint256 bucket = 0; bucket <= type(uint88).max; ++bucket) {
            uint96 bucketValue = uint96(bucket << 8);
            uint256 bucketNonces = nonces[wallet][bucket];
            // Move on to the next bucket if all bits in this bucket are already set
            if (bucketNonces == type(uint256).max) continue;
            for (uint256 maskOffset = 0; maskOffset < 256; ++maskOffset) {
                uint256 mask = 1 << maskOffset;
                if ((bucketNonces & mask) == 0) {
                    uint96 nonce = uint96(bucketValue + maskOffset);
                    // The next available nonce should not be reserved for a replayable transaction
                    if (nonceScriptAddress[wallet][nonce] == address(0)) {
                        return nonce;
                    }
                }
            }
        }

        revert NoUnusedNonces();
    }

    /**
     * @notice Return the script address associated with the currently active nonce; revert if none
     * @return Currently active script address
     */
    function getActiveScript() external view returns (address) {
        address scriptAddress = activeNonceScript[msg.sender].scriptAddress;
        if (scriptAddress == address(0)) {
            revert NoActiveNonce();
        }
        return scriptAddress;
    }

    /// @dev Locate a nonce at a (bucket, mask) bitset position in the nonces mapping
    function getBucket(uint96 nonce) internal pure returns (uint256, /* bucket */ uint256 /* mask */ ) {
        uint256 bucket = nonce >> 8;
        uint256 setMask = 1 << (nonce & 0xff);
        return (bucket, setMask);
    }

    /// @notice Clears (un-sets) the active nonce to allow its reuse; allows a script to be replayed
    function clearNonce() external {
        if (activeNonceScript[msg.sender].scriptAddress == address(0)) {
            revert NoActiveNonce();
        }

        uint96 nonce = activeNonceScript[msg.sender].nonce;
        (uint256 bucket, uint256 setMask) = getBucket(nonce);
        nonces[msg.sender][bucket] &= ~setMask;
        emit ClearNonce(msg.sender, nonce);
    }

    /**
     * @notice Set a given nonce for the calling wallet; effectively cancels any replayable script using that nonce
     * @param nonce Nonce to set for the calling wallet
     */
    function setNonce(uint96 nonce) external {
        // TODO: should we check whether there exists a nonceScriptAddress?
        (uint256 bucket, uint256 setMask) = getBucket(nonce);
        setNonceInternal(bucket, setMask);
    }

    /// @dev Set a nonce for the msg.sender, using the nonce's bucket and mask
    function setNonceInternal(uint256 bucket, uint256 setMask) internal {
        nonces[msg.sender][bucket] |= setMask;
    }

    /**
     * @notice Set a wallet nonce as the active nonce and yield control back to the wallet by calling into callback
     * @param nonce Nonce to activate for the transaction
     * @param scriptAddress Address of script to invoke with nonce lock
     * @param scriptCalldata Calldata for script call to invoke with nonce lock
     * @return Return value from the executed operation
     * @dev The script is expected to clearNonce() if it wishes to be replayable
     */
    function setActiveNonceAndCallback(uint96 nonce, address scriptAddress, bytes calldata scriptCalldata)
        external
        returns (bytes memory)
    {
        // retrieve the (bucket, mask) pair that addresses the nonce in memory
        (uint256 bucket, uint256 setMask) = getBucket(nonce);

        // ensure nonce is not already set
        if (isNonceSetInternal(msg.sender, bucket, setMask)) {
            revert NonceAlreadySet();
        }

        address cachedScriptAddress = nonceScriptAddress[msg.sender][nonce];
        // if the nonce has been used before, check if the script address matches, and revert if not
        if ((cachedScriptAddress != address(0)) && (cachedScriptAddress != scriptAddress)) {
            revert NonceScriptMismatch();
        }

        // spend the nonce; only if the callee chooses to clear it will it get un-set and become replayable
        setNonceInternal(bucket, setMask);

        // set the nonce-script pair active and yield to the wallet callback
        NonceScript memory previousNonceScript = activeNonceScript[msg.sender];
        activeNonceScript[msg.sender] = NonceScript({nonce: nonce, scriptAddress: scriptAddress});

        bytes memory result = IQuarkWallet(msg.sender).executeScriptWithNonceLock(scriptAddress, scriptCalldata);

        // if a nonce was cleared, set the nonceScriptAddress to lock nonce re-use to the same script address
        if (cachedScriptAddress == address(0) && !isNonceSetInternal(msg.sender, bucket, setMask)) {
            nonceScriptAddress[msg.sender][nonce] = scriptAddress;
        }

        // release the nonce when the wallet finishes executing callback
        activeNonceScript[msg.sender] = previousNonceScript;

        return result;
    }

    /// @notice Write arbitrary bytes to storage namespaced by the currently active nonce; reverts if no nonce is currently active
    function write(bytes32 key, bytes32 value) external {
        if (activeNonceScript[msg.sender].scriptAddress == address(0)) {
            revert NoActiveNonce();
        }
        walletStorage[msg.sender][activeNonceScript[msg.sender].nonce][key] = value;
    }

    /**
     * @notice Read from storage namespaced by the currently active nonce; reverts if no nonce is currently active
     * @return Value at the nonce storage location, as bytes
     */
    function read(bytes32 key) external view returns (bytes32) {
        if (activeNonceScript[msg.sender].scriptAddress == address(0)) {
            revert NoActiveNonce();
        }
        return walletStorage[msg.sender][activeNonceScript[msg.sender].nonce][key];
    }
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";
import {IERC1271} from "openzeppelin/interfaces/IERC1271.sol";

import {CodeJar} from "codejar/src/CodeJar.sol";

import {QuarkStateManager} from "quark-core/src/QuarkStateManager.sol";
import {IHasSignerExecutor} from "quark-core/src/interfaces/IHasSignerExecutor.sol";

/**
 * @title Quark Wallet Metadata
 * @notice A library of metadata specific to this implementation of the Quark Wallet
 * @author Compound Labs, Inc.
 */
library QuarkWalletMetadata {
    /// @notice QuarkWallet contract name
    string internal constant NAME = "Quark Wallet";

    /// @notice QuarkWallet contract major version
    string internal constant VERSION = "1";

    /// @notice The EIP-712 typehash for authorizing an operation for this version of QuarkWallet
    bytes32 internal constant QUARK_OPERATION_TYPEHASH = keccak256(
        "QuarkOperation(uint96 nonce,address scriptAddress,bytes[] scriptSources,bytes scriptCalldata,uint256 expiry)"
    );

    /// @notice The EIP-712 typehash for authorizing a MultiQuarkOperation for this version of QuarkWallet
    bytes32 internal constant MULTI_QUARK_OPERATION_TYPEHASH = keccak256("MultiQuarkOperation(bytes32[] opDigests)");

    /// @notice The EIP-712 typehash for authorizing an EIP-1271 signature for this version of QuarkWallet
    bytes32 internal constant QUARK_MSG_TYPEHASH = keccak256("QuarkMessage(bytes message)");

    /// @notice The EIP-712 domain typehash for this version of QuarkWallet
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 domain typehash used for MultiQuarkOperations for this version of QuarkWallet
    bytes32 internal constant MULTI_QUARK_OPERATION_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version)");
}

/**
 * @title Quark Wallet base class
 * @notice A smart wallet that can run transaction scripts
 * @dev An implementor needs only to provide a public signer and executor: these could be constants, immutables, or address getters of any kind
 * @author Compound Labs, Inc.
 */
contract QuarkWallet is IERC1271 {
    error BadSignatory();
    error EmptyCode();
    error InvalidEIP1271Signature();
    error InvalidMultiQuarkOperation();
    error InvalidSignature();
    error NoActiveCallback();
    error SignatureExpired();
    error Unauthorized();

    /// @notice Enum specifying the method of execution for running a Quark script
    enum ExecutionType {
        Signature,
        Direct
    }

    /// @notice Event emitted when a Quark script is executed by this Quark wallet
    event ExecuteQuarkScript(
        address indexed executor, address indexed scriptAddress, uint96 indexed nonce, ExecutionType executionType
    );

    /// @notice Address of CodeJar contract used to deploy transaction script source code
    CodeJar public immutable codeJar;

    /// @notice Address of QuarkStateManager contract that manages nonces and nonce-namespaced transaction script storage
    QuarkStateManager public immutable stateManager;

    /// @notice Name of contract
    string public constant NAME = QuarkWalletMetadata.NAME;

    /// @notice The major version of this contract
    string public constant VERSION = QuarkWalletMetadata.VERSION;

    /// @dev The EIP-712 domain typehash for this wallet
    bytes32 internal constant DOMAIN_TYPEHASH = QuarkWalletMetadata.DOMAIN_TYPEHASH;

    /// @dev The EIP-712 domain typehash used for MultiQuarkOperations for this wallet
    bytes32 internal constant MULTI_QUARK_OPERATION_DOMAIN_TYPEHASH =
        QuarkWalletMetadata.MULTI_QUARK_OPERATION_DOMAIN_TYPEHASH;

    /// @dev The EIP-712 typehash for authorizing an operation for this wallet
    bytes32 internal constant QUARK_OPERATION_TYPEHASH = QuarkWalletMetadata.QUARK_OPERATION_TYPEHASH;

    /// @dev The EIP-712 typehash for authorizing an operation that is part of a MultiQuarkOperation for this wallet
    bytes32 internal constant MULTI_QUARK_OPERATION_TYPEHASH = QuarkWalletMetadata.MULTI_QUARK_OPERATION_TYPEHASH;

    /// @dev The EIP-712 typehash for authorizing an EIP-1271 signature for this wallet
    bytes32 internal constant QUARK_MSG_TYPEHASH = QuarkWalletMetadata.QUARK_MSG_TYPEHASH;

    /// @dev The EIP-712 domain separator for a MultiQuarkOperation
    /// @dev Note: `chainId` and `verifyingContract` are left out so a single MultiQuarkOperation can be used to
    ///            execute operations on different chains and wallets.
    bytes32 internal constant MULTI_QUARK_OPERATION_DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            QuarkWalletMetadata.MULTI_QUARK_OPERATION_DOMAIN_TYPEHASH,
            keccak256(bytes(QuarkWalletMetadata.NAME)),
            keccak256(bytes(QuarkWalletMetadata.VERSION))
        )
    );

    /// @notice Well-known stateManager key for the currently executing script's callback address (if any)
    bytes32 public constant CALLBACK_KEY = keccak256("callback.v1.quark");

    /// @notice The magic value to return for valid ERC1271 signature
    bytes4 internal constant EIP_1271_MAGIC_VALUE = 0x1626ba7e;

    /// @notice The structure of a signed operation to execute in the context of this wallet
    struct QuarkOperation {
        /// @notice Nonce identifier for the operation
        uint96 nonce;
        /// @notice The address of the transaction script to run
        address scriptAddress;
        /// @notice Creation codes Quark must ensure are deployed before executing this operation
        bytes[] scriptSources;
        /// @notice Encoded function selector + arguments to invoke on the script contract
        bytes scriptCalldata;
        /// @notice Expiration time for the signature corresponding to this operation
        uint256 expiry;
    }

    /**
     * @notice Construct a new QuarkWalletImplementation
     * @param codeJar_ The CodeJar contract used to deploy scripts
     * @param stateManager_ The QuarkStateManager contract used to write/read nonces and storage for this wallet
     */
    constructor(CodeJar codeJar_, QuarkStateManager stateManager_) {
        codeJar = codeJar_;
        stateManager = stateManager_;
    }

    /**
     * @notice Execute a QuarkOperation via signature
     * @dev Can only be called with signatures from the wallet's signer
     * @param op A QuarkOperation struct
     * @param v EIP-712 signature v value
     * @param r EIP-712 signature r value
     * @param s EIP-712 signature s value
     * @return Return value from the executed operation
     */
    function executeQuarkOperation(QuarkOperation calldata op, uint8 v, bytes32 r, bytes32 s)
        external
        returns (bytes memory)
    {
        bytes32 opDigest = getDigestForQuarkOperation(op);

        return verifySigAndExecuteQuarkOperation(op, opDigest, v, r, s);
    }

    /**
     * @notice Execute a QuarkOperation that is part of a MultiQuarkOperation via signature
     * @dev Can only be called with signatures from the wallet's signer
     * @param op A QuarkOperation struct
     * @param opDigests A list of EIP-712 digests for the operations in a MultiQuarkOperation
     * @param v EIP-712 signature v value
     * @param r EIP-712 signature r value
     * @param s EIP-712 signature s value
     * @return Return value from the executed operation
     */
    function executeMultiQuarkOperation(
        QuarkOperation calldata op,
        bytes32[] memory opDigests,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bytes memory) {
        bytes32 opDigest = getDigestForQuarkOperation(op);

        bool isValidOp = false;
        for (uint256 i = 0; i < opDigests.length; ++i) {
            if (opDigest == opDigests[i]) {
                isValidOp = true;
                break;
            }
        }
        if (!isValidOp) {
            revert InvalidMultiQuarkOperation();
        }
        bytes32 multiOpDigest = getDigestForMultiQuarkOperation(opDigests);

        return verifySigAndExecuteQuarkOperation(op, multiOpDigest, v, r, s);
    }

    /**
     * @notice Verify a signature and execute a QuarkOperation
     * @param op A QuarkOperation struct
     * @param digest A EIP-712 digest for either a QuarkOperation or MultiQuarkOperation to verify the signature against
     * @param v EIP-712 signature v value
     * @param r EIP-712 signature r value
     * @param s EIP-712 signature s value
     * @return Return value from the executed operation
     */
    function verifySigAndExecuteQuarkOperation(
        QuarkOperation calldata op,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal returns (bytes memory) {
        if (block.timestamp >= op.expiry) {
            revert SignatureExpired();
        }

        // if the signature check does not revert, the signature is valid
        checkValidSignatureInternal(IHasSignerExecutor(address(this)).signer(), digest, v, r, s);

        // guarantee every script in scriptSources is deployed
        for (uint256 i = 0; i < op.scriptSources.length; ++i) {
            codeJar.saveCode(op.scriptSources[i]);
        }

        emit ExecuteQuarkScript(msg.sender, op.scriptAddress, op.nonce, ExecutionType.Signature);

        return stateManager.setActiveNonceAndCallback(op.nonce, op.scriptAddress, op.scriptCalldata);
    }

    /**
     * @notice Execute a transaction script directly
     * @dev Can only be called by the wallet's executor
     * @param nonce Nonce for the operation; must be unused
     * @param scriptAddress Address for the script to execute
     * @param scriptCalldata Encoded call to invoke on the script
     * @param scriptSources Creation codes Quark must ensure are deployed before executing the script
     * @return Return value from the executed operation
     */
    function executeScript(
        uint96 nonce,
        address scriptAddress,
        bytes calldata scriptCalldata,
        bytes[] calldata scriptSources
    ) external returns (bytes memory) {
        // only allow the executor for the wallet to use unsigned execution
        if (msg.sender != IHasSignerExecutor(address(this)).executor()) {
            revert Unauthorized();
        }

        // guarantee every script in scriptSources is deployed
        for (uint256 i = 0; i < scriptSources.length; ++i) {
            codeJar.saveCode(scriptSources[i]);
        }

        emit ExecuteQuarkScript(msg.sender, scriptAddress, nonce, ExecutionType.Direct);

        return stateManager.setActiveNonceAndCallback(nonce, scriptAddress, scriptCalldata);
    }

    /**
     * @dev Returns the domain separator for this Quark wallet
     * @return Domain separator
     */
    function getDomainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(NAME)), keccak256(bytes(VERSION)), block.chainid, address(this))
        );
    }

    /**
     * @dev Returns the EIP-712 digest for a QuarkOperation
     * @param op A QuarkOperation struct
     * @return EIP-712 digest
     */
    function getDigestForQuarkOperation(QuarkOperation calldata op) public view returns (bytes32) {
        bytes memory encodedScriptSources;
        for (uint256 i = 0; i < op.scriptSources.length; ++i) {
            encodedScriptSources = abi.encodePacked(encodedScriptSources, keccak256(op.scriptSources[i]));
        }

        bytes32 structHash = keccak256(
            abi.encode(
                QUARK_OPERATION_TYPEHASH,
                op.nonce,
                op.scriptAddress,
                keccak256(encodedScriptSources),
                keccak256(op.scriptCalldata),
                op.expiry
            )
        );
        return keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), structHash));
    }

    /**
     * @dev Returns the EIP-712 digest for a MultiQuarkOperation
     * @param opDigests A list of EIP-712 digests for the operations in a MultiQuarkOperation
     * @return EIP-712 digest
     */
    function getDigestForMultiQuarkOperation(bytes32[] memory opDigests) public pure returns (bytes32) {
        bytes memory encodedOpDigests;
        for (uint256 i = 0; i < opDigests.length; ++i) {
            encodedOpDigests = abi.encodePacked(encodedOpDigests, opDigests[i]);
        }

        bytes32 structHash = keccak256(abi.encode(MULTI_QUARK_OPERATION_TYPEHASH, keccak256(encodedOpDigests)));
        return keccak256(abi.encodePacked("\x19\x01", MULTI_QUARK_OPERATION_DOMAIN_SEPARATOR, structHash));
    }

    /**
     * @dev Returns the EIP-712 digest of a QuarkMessage that can be signed by `signer`
     * @param message Message that should be hashed
     * @return Message hash
     */
    function getDigestForQuarkMessage(bytes memory message) public view returns (bytes32) {
        bytes32 quarkMessageHash = keccak256(abi.encode(QUARK_MSG_TYPEHASH, keccak256(message)));
        return keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), quarkMessageHash));
    }

    /**
     * @notice Checks whether an EIP-1271 signature is valid
     * @dev If the QuarkWallet is owned by an EOA, isValidSignature confirms
     * that the signature comes from the signer; if the QuarkWallet is owned by
     * a smart contract, isValidSignature relays the `isValidSignature` to the
     * smart contract
     * @param hash Hash of the signed data
     * @param signature Signature byte array associated with data
     * @return The ERC-1271 "magic value" that indicates the signature is valid
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4) {
        /*
         * Code taken directly from OpenZeppelin ECDSA.tryRecover; see:
         * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/HEAD/contracts/utils/cryptography/ECDSA.sol#L64-L68
         *
         * This is effectively an optimized variant of the Reference Implementation; see:
         * https://eips.ethereum.org/EIPS/eip-1271#reference-implementation
         */
        if (signature.length != 65) {
            revert InvalidSignature();
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        // Note: The following logic further encodes the provided `hash` with the wallet's domain
        // to prevent signature replayability for Quark wallets owned by the same `signer`
        bytes32 digest = getDigestForQuarkMessage(abi.encode(hash));
        // If the signature check does not revert, the signature is valid
        checkValidSignatureInternal(IHasSignerExecutor(address(this)).signer(), digest, v, r, s);
        return EIP_1271_MAGIC_VALUE;
    }

    /**
     * @dev If the QuarkWallet is owned by an EOA, isValidSignature confirms
     * that the signature comes from the signer; if the QuarkWallet is owned by
     * a smart contract, isValidSignature relays the `isValidSignature` check
     * to the smart contract; if the smart contract that owns the wallet has no
     * code, the signature will be treated as an EIP-712 signature and revert
     */
    function checkValidSignatureInternal(address signatory, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        view
    {
        if (signatory.code.length > 0) {
            bytes memory signature = abi.encodePacked(r, s, v);
            (bool success, bytes memory data) =
                signatory.staticcall(abi.encodeWithSelector(EIP_1271_MAGIC_VALUE, digest, signature));
            if (!success) {
                revert InvalidEIP1271Signature();
            }
            bytes4 returnValue = abi.decode(data, (bytes4));
            if (returnValue != EIP_1271_MAGIC_VALUE) {
                revert InvalidEIP1271Signature();
            }
        } else {
            (address recoveredSigner, ECDSA.RecoverError recoverError) = ECDSA.tryRecover(digest, v, r, s);
            if (recoverError != ECDSA.RecoverError.NoError) {
                revert InvalidSignature();
            }
            if (recoveredSigner != signatory) {
                revert BadSignatory();
            }
        }
    }

    /**
     * @notice Execute a QuarkOperation with a lock acquired on nonce-namespaced storage
     * @dev Can only be called by stateManager during setActiveNonceAndCallback()
     * @param scriptAddress Address of script to execute
     * @param scriptCalldata Encoded calldata for the call to execute on the scriptAddress
     * @return Result of executing the script, encoded as bytes
     */
    function executeScriptWithNonceLock(address scriptAddress, bytes memory scriptCalldata)
        external
        returns (bytes memory)
    {
        require(msg.sender == address(stateManager));
        if (scriptAddress.code.length == 0) {
            revert EmptyCode();
        }

        bool success;
        uint256 returnSize;
        uint256 scriptCalldataLen = scriptCalldata.length;
        assembly {
            // Note: CALLCODE is used to set the QuarkWallet as the `msg.sender`
            success :=
                callcode(gas(), scriptAddress, /* value */ 0, add(scriptCalldata, 0x20), scriptCalldataLen, 0x0, 0)
            returnSize := returndatasize()
        }

        bytes memory returnData = new bytes(returnSize);
        assembly {
            returndatacopy(add(returnData, 0x20), 0x00, returnSize)
        }

        if (!success) {
            assembly {
                revert(add(returnData, 0x20), returnSize)
            }
        }

        return returnData;
    }

    /**
     * @notice Fallback function specifically used for scripts that have enabled callbacks
     * @dev Reverts if callback is not enabled by the script
     */
    fallback(bytes calldata data) external payable returns (bytes memory) {
        address callback = address(uint160(uint256(stateManager.read(CALLBACK_KEY))));
        if (callback != address(0)) {
            (bool success, bytes memory result) = callback.delegatecall(data);
            if (!success) {
                assembly {
                    let size := mload(result)
                    revert(add(result, 0x20), size)
                }
            }
            return result;
        } else {
            revert NoActiveCallback();
        }
    }

    /// @notice Fallback for receiving native token
    receive() external payable {}
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

/**
 * @title Has Signer and Executor interface
 * @notice A helper interface that represents a shell for a QuarkWallet providing an executor and signer
 * @author Compound Labs, Inc.
 */
interface IHasSignerExecutor {
    function signer() external view returns (address);
    function executor() external view returns (address);
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

/**
 * @title Quark Wallet interface
 * @notice An interface for interacting with Quark Wallets
 * @author Compound Labs, Inc.
 */
interface IQuarkWallet {
    /// @notice The structure of a signed operation to execute in the context of this wallet
    struct QuarkOperation {
        /// @notice Nonce identifier for the operation
        uint96 nonce;
        /// @notice The address of the transaction script to run
        address scriptAddress;
        /// @notice Creation codes Quark must ensure are deployed before executing this operation
        bytes[] scriptSources;
        /// @notice Encoded function selector + arguments to invoke on the script contract
        bytes scriptCalldata;
        /// @notice Expiration time for the signature corresponding to this operation
        uint256 expiry;
    }

    function executeQuarkOperation(QuarkOperation calldata op, uint8 v, bytes32 r, bytes32 s)
        external
        returns (bytes memory);
    function executeMultiQuarkOperation(
        QuarkOperation calldata op,
        bytes32[] memory opDigests,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bytes memory);
    function executeScript(
        uint96 nonce,
        address scriptAddress,
        bytes calldata scriptCalldata,
        bytes[] calldata scriptSources
    ) external returns (bytes memory);
    function getDigestForQuarkOperation(QuarkOperation calldata op) external view returns (bytes32);
    function getDigestForMultiQuarkOperation(bytes32[] memory opDigests) external pure returns (bytes32);
    function getDigestForQuarkMessage(bytes memory message) external view returns (bytes32);
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4);
    function executeScriptWithNonceLock(address scriptAddress, bytes memory scriptCalldata)
        external
        returns (bytes memory);
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

contract QuarkMinimalProxy {
    /// @notice Address of the EOA signer or the EIP-1271 contract that verifies signed operations for this wallet
    address public immutable signer;

    /// @notice Address of the executor contract, if any, empowered to direct-execute unsigned operations for this wallet
    address public immutable executor;

    /// @notice Address of the QuarkWallet implementation contract
    address internal immutable walletImplementation;

    /**
     * @notice Construct a new QuarkWallet
     * @param implementation_ Address of QuarkWallet implementation contract
     * @param signer_ Address allowed to sign QuarkOperations for this wallet
     * @param executor_ Address allowed to directly execute Quark scripts for this wallet
     */
    constructor(address implementation_, address signer_, address executor_) {
        signer = signer_;
        executor = executor_;
        walletImplementation = implementation_;
    }

    /// @notice Proxy calls to the underlying wallet implementation
    fallback(bytes calldata /* data */ ) external payable returns (bytes memory) {
        address walletImplementation_ = walletImplementation;
        assembly {
            let calldataLen := calldatasize()
            calldatacopy(0, 0, calldataLen)
            let success := delegatecall(gas(), walletImplementation_, 0x00, calldataLen, 0x00, 0)
            let returnSize := returndatasize()
            returndatacopy(0, 0, returnSize)
            if success { return(0, returnSize) }

            revert(0, returnSize)
        }
    }

    /// @notice Fallback for receiving native token
    receive() external payable {}
}
// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.23;

import {QuarkWallet, QuarkWalletMetadata} from "quark-core/src/QuarkWallet.sol";

import {QuarkMinimalProxy} from "quark-proxy/src/QuarkMinimalProxy.sol";

/**
 * @title Quark Wallet Proxy Factory
 * @notice A factory for deploying Quark Wallet Proxy instances at deterministic addresses
 * @author Compound Labs, Inc.
 */
contract QuarkWalletProxyFactory {
    event WalletDeploy(address indexed signer, address indexed executor, address walletAddress, bytes32 salt);

    /// @notice Major version of the contract
    uint256 public constant VERSION = 1;

    /// @notice Default initial salt value
    bytes32 public constant DEFAULT_SALT = bytes32(0);

    /// @notice The EIP-712 domain separator for a MultiQuarkOperation
    bytes32 public constant MULTI_QUARK_OPERATION_DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            QuarkWalletMetadata.MULTI_QUARK_OPERATION_DOMAIN_TYPEHASH,
            keccak256(bytes(QuarkWalletMetadata.NAME)),
            keccak256(bytes(QuarkWalletMetadata.VERSION))
        )
    );

    /// @notice Address of QuarkWallet implementation contract
    address public immutable walletImplementation;

    /// @notice Construct a new QuarkWalletProxyFactory with the provided QuarkWallet implementation address
    constructor(address walletImplementation_) {
        walletImplementation = walletImplementation_;
    }

    /**
     * @notice Returns the EIP-712 domain separator used for signing operations for the wallet belonging
     * to the given (signer, executor, salt) triple
     * @dev Only for use for wallets deployed by this factory, or counterfactual wallets that
     * will be deployed with this factory; only a wallet with the expected QuarkWalletMetadata
     * (NAME, VERSION, DOMAIN_TYPEHASH) will work.
     * @return bytes32 The domain separator for the wallet corresponding to the signer and salt
     */
    function DOMAIN_SEPARATOR(address signer, address executor, bytes32 salt) external view returns (bytes32) {
        return keccak256(
            abi.encode(
                QuarkWalletMetadata.DOMAIN_TYPEHASH,
                keccak256(bytes(QuarkWalletMetadata.NAME)),
                keccak256(bytes(QuarkWalletMetadata.VERSION)),
                block.chainid,
                walletAddressForSalt(signer, executor, salt)
            )
        );
    }

    /**
     * @notice Create new QuarkWallet for (signer, executor) pair (with default salt value)
     * @dev Will revert if wallet already exists for signer
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @return address Address of the newly-created wallet
     */
    function create(address signer, address executor) external returns (address payable) {
        return create(signer, executor, DEFAULT_SALT);
    }

    /**
     * @notice Create new QuarkWallet for (signer, executor, salt) triple
     * @dev Will revert if wallet already exists for (signer, executor, salt) triple
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @param salt Salt value to use during creation of QuarkWallet
     * @return address Address of the newly-created wallet
     */
    function create(address signer, address executor, bytes32 salt) public returns (address payable) {
        address payable proxyAddress =
            payable(address(new QuarkMinimalProxy{salt: salt}(walletImplementation, signer, executor)));
        emit WalletDeploy(signer, executor, proxyAddress, salt);
        return proxyAddress;
    }

    /**
     * @notice Create a wallet for (signer, executor) pair (and default salt) if it does not exist, then execute operation
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @param op The QuarkOperation to execute on the wallet
     * @param v EIP-712 Signature `v` value
     * @param r EIP-712 Signature `r` value
     * @param s EIP-712 Signature `s` value
     * @return bytes Return value of executing the operation
     */
    function createAndExecute(
        address signer,
        address executor,
        QuarkWallet.QuarkOperation memory op,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bytes memory) {
        return createAndExecute(signer, executor, DEFAULT_SALT, op, v, r, s);
    }

    /**
     * @notice Create a wallet for (signer, executor, salt) triple if it does not exist, then execute operation
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @param salt Salt value of QuarkWallet to create and execute operation with
     * @param op The QuarkOperation to execute on the wallet
     * @param v EIP-712 Signature `v` value
     * @param r EIP-712 Signature `r` value
     * @param s EIP-712 Signature `s` value
     * @return bytes Return value of executing the operation
     */
    function createAndExecute(
        address signer,
        address executor,
        bytes32 salt,
        QuarkWallet.QuarkOperation memory op,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bytes memory) {
        address payable walletAddress = walletAddressForSalt(signer, executor, salt);
        if (walletAddress.code.length == 0) {
            create(signer, executor, salt);
        }

        return QuarkWallet(walletAddress).executeQuarkOperation(op, v, r, s);
    }

    /**
     * @notice Create a wallet for (signer, executor) pair (and default salt) if it does not exist, then execute operation that is part of a MultiQuarkOperation
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @param op The QuarkOperation to execute on the wallet
     * @param opDigests A list of EIP-712 digests for the operations in a MultiQuarkOperation
     * @param v EIP-712 Signature `v` value
     * @param r EIP-712 Signature `r` value
     * @param s EIP-712 Signature `s` value
     * @return bytes Return value of executing the operation
     */
    function createAndExecuteMulti(
        address signer,
        address executor,
        QuarkWallet.QuarkOperation calldata op,
        bytes32[] calldata opDigests,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bytes memory) {
        return createAndExecuteMulti(signer, executor, DEFAULT_SALT, op, opDigests, v, r, s);
    }

    /**
     * @notice Create a wallet for (signer, executor, salt) triple if it does not exist, then execute operation that is part of a MultiQuarkOperation
     * @param signer Address to set as the signer of the QuarkWallet
     * @param executor Address to set as the executor of the QuarkWallet
     * @param salt Salt value of QuarkWallet to create and execute operation with
     * @param op The QuarkOperation to execute on the wallet
     * @param opDigests A list of EIP-712 digests for the operations in a MultiQuarkOperation
     * @param v EIP-712 Signature `v` value
     * @param r EIP-712 Signature `r` value
     * @param s EIP-712 Signature `s` value
     * @return bytes Return value of executing the operation
     */
    function createAndExecuteMulti(
        address signer,
        address executor,
        bytes32 salt,
        QuarkWallet.QuarkOperation calldata op,
        bytes32[] calldata opDigests,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bytes memory) {
        address payable walletAddress = walletAddressForSalt(signer, executor, salt);
        if (walletAddress.code.length == 0) {
            create(signer, executor, salt);
        }

        return QuarkWallet(walletAddress).executeMultiQuarkOperation(op, opDigests, v, r, s);
    }

    /**
     * @notice Derive QuarkWallet address for (signer, executor) pair (and default salt value)
     * @dev QuarkWallet at returned address may not yet have been created
     * @param signer Address of the signer for which to derive a QuarkWallet address
     * @param executor Address of the executor for which to derive a QuarkWallet address
     * @return address Address of the derived QuarkWallet for (signer, executor) pair
     */
    function walletAddressFor(address signer, address executor) external view returns (address payable) {
        return walletAddressForSalt(signer, executor, DEFAULT_SALT);
    }

    /**
     * @notice Derive QuarkWallet address for (signer, executor, salt) triple
     * @dev QuarkWallet at returned address may not yet have been created
     * @param signer Address of the signer for which to derive a QuarkWallet address
     * @param executor Address of the executor for which to derive a QuarkWallet address
     * @param salt Salt value for which to derive a QuarkWallet address
     * @return address Address of the derived QuarkWallet for (signer, executor, salt) triple
     */
    function walletAddressForSalt(address signer, address executor, bytes32 salt)
        public
        view
        returns (address payable)
    {
        return walletAddressForInternal(signer, executor, salt);
    }

    /// @dev Get the deterministic address of a QuarkWallet for a given (signer, executor, salt) triple
    function walletAddressForInternal(address signer, address executor, bytes32 salt)
        internal
        view
        returns (address payable)
    {
        return payable(
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                salt,
                                keccak256(
                                    abi.encodePacked(
                                        type(QuarkMinimalProxy).creationCode,
                                        abi.encode(walletImplementation),
                                        abi.encode(signer),
                                        abi.encode(executor)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        );
    }
}