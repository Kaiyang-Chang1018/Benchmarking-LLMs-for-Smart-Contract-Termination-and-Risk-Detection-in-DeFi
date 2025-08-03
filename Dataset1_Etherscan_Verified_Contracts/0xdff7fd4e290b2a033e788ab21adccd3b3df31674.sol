// Sources flattened with hardhat v2.22.15 https://hardhat.org

// SPDX-License-Identifier: MIT AND Unlicense

// File @openzeppelin/contracts/utils/math/Math.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/math/SignedMath.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/utils/Strings.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;


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


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

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


// File contracts/StateChannel.sol

// Original license: SPDX_License_Identifier: Unlicense
pragma solidity ^0.8.20;
function min(uint128 a, uint128 b) pure returns (uint128) {
    return a >= b ? b : a;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external;
}

contract StateChannel {

    using ECDSA for bytes32;
	 
	enum SessionStatus { OPEN, SERVER_CLOSING, PLAYER_CLOSING, SERVER_PAYMENT_DUE, CLOSED }
	
	uint32 MAX_FEE = 10000;

	//OPEN = state after initial deposit, when session is created
	//CLOSING = state to manage arbitrage
	//CLOSED = all payments have been made and contract is closed (staying on the blockchain until it expires)
	//SERVER_PAYMENT_DUE = state when final balance > deposit, in this case after CLOSING the deposit is sent
							//to the server and player waits for the server to pay full balance 
							//after full balance is paid state goes to CLOSED

    struct Session {
	    //these are set at session creation time
		uint128 initialDepositAmount;
		uint128 depositAmount; //16
		
		uint128 serverDueAmount;
		uint128 win;
		uint128 bet;
		uint128 seq; //16
		uint128[][] privilegedFees;
		uint128 minBalance;

		uint32 serverCanCloseAt;
		uint32 created; //4 uint		
		uint32 lastUpdated; //4 

		bytes32 id;
		address tokenAddr;
		address serverPublicKey; //20 byte
		address playerAddr;

		SessionStatus status; //1 byte
    } 

	uint128[][] privilegedFees;

	struct ProviderConfig { 
		address[] serverPublicKeys;
		uint128[][] privilegedFees;
	}



	mapping(
		address => ProviderConfig
	) providerConfigs;

	mapping(
		address => address 
	) serverPublicKeysToServerAddress;

	mapping(
		address => address 
	) serverPublicKeysToTokenAddress;

	mapping (
		address => address
	) playerPublicKeyToPlayerAddress;
 
    struct Call {
        uint256 value;
        bytes data;
    }

	mapping (
		address => mapping ( 
			address => mapping(
				address => bytes32[]
			)
		)
	) sessionsIds;

	mapping (
		bytes32 => Session
	) sessions;

	mapping (
		address => address[] 
	) playerPublicKeys; //20 byte

	mapping (
		address => uint128
	) minBalances;

	mapping (
		address => uint128
	) minDepositAmounts;

	struct ServerMetrics {
		uint256 payAmount;
		uint256 paidAmount;
		
		uint256 paymentIntervalAmount; //sum of payAmount
		uint256 paymentIntervalCount; //sum of payAmount * time
	}
   
	mapping (
		address => ServerMetrics
	) serverMetrics;

	mapping (
		address => uint128
	) serverBalances;

	//events matching txn types used by the apps	
	event onSessionCreated(Session session);
	event onAddPlayerKey(address playerAddr, address playerKey);	
	event onPlayerClose(Session session);	
	event onPlayerCloseAfterTimeout(Session session);	
	event onServerClose(Session session);	
	event onServerCloseAfterTimeout(Session session);	
	event onServerPayDueAmount(Session session, uint256 amount);	
	event onDepositAmountAdded(Session session, uint256 amount);	
	
	//additional events
	event onSessionUpdated(Session session);
	event onTransferToPlayer(Session session, uint256 amount);	
	event onTransferToServer(Session session, uint256 amount);	

	event onDepositServerBalance( address serverPublicKey, address serverAddr, address tokenAddr, uint256 amonut );
	event onWithdrawServerBalance( address serverPublicKey, address serverAddr, address tokenAddr, uint256 amount );

	//server address events
	event onServerPublicKeyRegistered(address serverPublicKey, address serverAddr);

	event onBatchCallError( bytes data );

	uint32 COUNTER_CLOSE_TIMEOUT;  //timeout for each party to counter close a session closed by the other party 
	uint32 MIN_SESSION_DURATION; //minimum duration of a session before it can be closed by the server 
	uint32 FEE;

	address PRIVILEGED_TOKEN_ADDR;
	address RECEIVER;

	address owner;

	modifier onlyOwner {	
		require(msg.sender == owner, "not owner");
		_;
	}

	modifier isAccountOrIsThisContract {
		uint32 size;
		address c = msg.sender;
		assembly {
			size := extcodesize(c)
		}
		require(size == 0 || c == address(this), "is contract");
		_;
	}

	constructor( address r, address[] memory tokenAddrs, uint128[] memory tokenMinBalances, uint128[] memory tokenMinDepositAmounts) {
		require(tokenAddrs.length == tokenMinBalances.length && tokenMinBalances.length == tokenMinDepositAmounts.length);
		COUNTER_CLOSE_TIMEOUT = 7* 24 * 3600;
		MIN_SESSION_DURATION = 7 * 24 * 3600;   
		FEE = 100;
		RECEIVER = r;
		owner = msg.sender;

		for (uint i = 0; i < tokenAddrs.length; i++) {
			minBalances[tokenAddrs[i]] = tokenMinBalances[i];
			minDepositAmounts[tokenAddrs[i]] = tokenMinDepositAmounts[i];
		}
	}

    function createSession(uint128 amount, address playerPublicKey,  address serverPublicKey, address tokenAddr) external payable isAccountOrIsThisContract { /* tested */
		bytes32 sessionId = keccak256(abi.encodePacked(msg.sender, address(this), block.timestamp));

		uint256 minDepositAmount = getMinDepositAmount(tokenAddr);	
		require(amount >= minDepositAmount && amount > 0, "invalid amount");
		require(serverPublicKeysToServerAddress[serverPublicKey] != address(0), "unknown serverPublicKey");
		require(serverPublicKeysToTokenAddress[serverPublicKey] == tokenAddr, "Invalid tokenAddr");

		//transfer tokens to contract...
		if( isWeth(tokenAddr) ){
			require(msg.value == amount, "invalid msg.value");	
		} else {
			IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount);
		}

		address serverAddr = serverPublicKeysToServerAddress[serverPublicKey];
		Session memory s;
		s.id = sessionId;

		bool playerKeyFound = hasPlayerKey(playerPublicKey);
		if( !playerKeyFound ) addPlayerKey(playerPublicKey);

		s.tokenAddr = tokenAddr;
		s.initialDepositAmount = s.depositAmount = amount; 
		s.created = uint32(block.timestamp);
		s.lastUpdated = uint32(block.timestamp);
		s.serverPublicKey = serverPublicKey;
		s.playerAddr = msg.sender;
		s.serverCanCloseAt = uint32(block.timestamp) + getMinSessionDuration();
		s.minBalance = getMinBalance(tokenAddr);

		if (isPrivilegedToken(tokenAddr)) {
			s.privilegedFees = providerConfigs[serverAddr].privilegedFees.length == 0 ? privilegedFees : providerConfigs[serverAddr].privilegedFees;
		}

		sessionsIds[msg.sender][serverPublicKey][tokenAddr].push(s.id);
		sessions[s.id] = s;

		emit onSessionCreated(s);	
	}

	function addDepositAmount(bytes32 sessionId, address playerPublicKey, uint128 amount) external payable isAccountOrIsThisContract {

		Session storage session = sessions[sessionId];
		require(session.status ==  SessionStatus.OPEN);
		require(session.playerAddr == msg.sender);

		bool playerKeyFound = hasPlayerKey(playerPublicKey);
		if( !playerKeyFound ) addPlayerKey(playerPublicKey);

		uint256 sessionDurationIncrement = MIN_SESSION_DURATION * amount;
		sessionDurationIncrement /= session.initialDepositAmount;
		if(sessionDurationIncrement > MIN_SESSION_DURATION) sessionDurationIncrement = MIN_SESSION_DURATION;
		if( session.serverCanCloseAt > block.timestamp ) {
			session.serverCanCloseAt += uint32(sessionDurationIncrement);
		} else {
			session.serverCanCloseAt = uint32(block.timestamp) + uint32(sessionDurationIncrement);
		}
 
		session.depositAmount += amount;
		session.lastUpdated = uint32(block.timestamp);

		if( isWeth(session.tokenAddr) ){
			require(msg.value == amount, "invalid msg.value");	
		} else {
			IERC20(session.tokenAddr).transferFrom(msg.sender, address(this), amount);
		}

		emit onDepositAmountAdded(session, amount);
		emit onSessionUpdated(session);
	}

	
    function batch(Call[] memory calls) external onlyOwner {
        for (uint i = 0; i < calls.length; i++) {
			bytes memory data = calls[i].data;
			uint256 value = calls[i].value;
			address to = address(this);
			uint gasLeft = gasleft();
			bool success;
			
            assembly {
				//let ptr := mload(0x40)
                success := call(
                    gasLeft,
                    to,
                	value,
                    add(data, 0x20),
                    mload(data),
                    0,//ptr, //output pointer ( pass 'ptr' defined above )
                    0//0x20 //output size
                )
            }
			if (!success) {
				//fire event...
				emit onBatchCallError(data);
			}
        }
    }

	function registerServerPublicKey(address serverAddr, address serverPublicKey, address tokenAddr) external {
		checkAuthority(address(0));
		require(serverPublicKeysToServerAddress[serverPublicKey] == address(0), "already exists");
		serverPublicKeysToServerAddress[serverPublicKey] = serverAddr;
		providerConfigs[serverAddr].serverPublicKeys.push(serverPublicKey); 
		serverPublicKeysToTokenAddress[serverPublicKey] = tokenAddr; 
		emit onServerPublicKeyRegistered(serverPublicKey, serverAddr);
	}

	function getPublicKeys(address serverAddr) external view returns (address[] memory) {
		return providerConfigs[serverAddr].serverPublicKeys;
	}

	function setPrivilegedToken(address tokenAddr) external onlyOwner {
		PRIVILEGED_TOKEN_ADDR = tokenAddr;
	}	

	function isPrivilegedToken( address token ) public view returns( bool ){
		return !isWeth(token) && token == PRIVILEGED_TOKEN_ADDR;
	}

	function isWeth( address token ) public pure returns( bool ){
		return token == address(0);
	}

	function getCounterCloseTimeout() public view returns ( uint32 ){
		return COUNTER_CLOSE_TIMEOUT;
	}

	function getMinSessionDuration() public view returns ( uint32 ){
		return MIN_SESSION_DURATION;
	}

	function getFee() public view returns ( uint32 ){
		return FEE;
	}

	function setFee( uint32 fee ) external onlyOwner {
		FEE = fee;
	}

	function setCounterCloseTimeout( uint32 timeout ) external onlyOwner {
		COUNTER_CLOSE_TIMEOUT = timeout;
	}

	function setMinBalance( address tokenAddr, uint128 amount ) external {
		checkAuthority(address(0));
		minBalances[tokenAddr] = amount;
	}

	function getMinBalance( address tokenAddr ) public view returns ( uint128 ){
		return minBalances[tokenAddr];
	}

	function setMinDepositAmount( address tokenAddr, uint128 amount ) external {
		checkAuthority(address(0));
		minDepositAmounts[tokenAddr] = amount;
	}

	function getMinDepositAmount( address tokenAddr ) public view returns ( uint128 ){
		return minDepositAmounts[tokenAddr];
	}

	function transferAmount( address receiver, uint amount, address tokenAddr ) private returns( bool ) {
		bool hasTransfered;
		if( isWeth(tokenAddr) ){
			payable(receiver).transfer(amount);
			hasTransfered = true;
		} else {
			IERC20(tokenAddr).transfer(receiver, amount);
			hasTransfered = true; 
		}
		return hasTransfered;
	}

	function getSessions(
		address playerAddr, address serverPublicKey, address tokenAddr,
		uint256 page, uint256 perPage, bool rev
	) public view returns (Session[] memory) {
		require(perPage > 0, "perPage > 0");

		uint256 addedCount = 0;
		uint256 start = page * perPage;
		uint256 end = start + perPage;
		Session[] memory toReturn = new Session[](perPage);

		//uint256 length = sessionsIds[playerAddr][serverPublicKey][tokenAddr].length; UNUSED DUE TO STACK TO DEEP ERROR.
		
		if (start >= sessionsIds[playerAddr][serverPublicKey][tokenAddr].length) return toReturn; // if required a too high page return empty list
		
		if (rev) {
			// If reversing, adjust start and end to count from the end of the array
			start = sessionsIds[playerAddr][serverPublicKey][tokenAddr].length - start;
			end = start < perPage ? 0 : start - perPage;
			
			for (uint256 i = start; i > end && addedCount < perPage; i--) {
				toReturn[addedCount++] = sessions[sessionsIds[playerAddr][serverPublicKey][tokenAddr][i - 1]];
			}
		} else {
			for (uint256 i = start; i < sessionsIds[playerAddr][serverPublicKey][tokenAddr].length && i < end; i++) {
				toReturn[addedCount++] = sessions[sessionsIds[playerAddr][serverPublicKey][tokenAddr][i]];
			}
		}

	 	assembly {
            mstore(toReturn, addedCount)
        }
		return toReturn;
	}

	function getSessionsByStatus(
		address playerAddr, address serverPublicKey, address tokenAddr, SessionStatus status, 
		uint256 page, uint256 perPage, bool rev
	) public view returns (Session[] memory) {
		require(page >= 0, "page must be >= 0");
		require(perPage > 0, "perPage must be > 0");

		uint256 addedCount = 0;
		uint256 toSkipCount = page * perPage;
		Session[] memory toReturn = new Session[](perPage);
		bytes32[] memory sessionIdsList = sessionsIds[playerAddr][serverPublicKey][tokenAddr];
		uint256 length = sessionIdsList.length;
		
		
		if (rev) {
			// If reversing, iterate from the end of the array
			for (uint256 i = length; i > 0 && addedCount < perPage; i--) {
				bytes32 sessionId = sessionIdsList[i - 1];
				Session memory s = sessions[sessionId];
				if (s.status == status) {
					if (toSkipCount > 0) {
						toSkipCount--;
					} else {
						toReturn[addedCount++] = s;
					}
				}
			}
		} else {
			// Iterate from the beginning of the array
			for (uint256 i = 0; i < length && addedCount < perPage; i++) {
				bytes32 sessionId = sessionIdsList[i];
				Session memory s = sessions[sessionId];
				if (s.status == status) {
					if (toSkipCount > 0) {
						toSkipCount--;
					} else {
						toReturn[addedCount++] = s;
					}
				}
				
			}
		}

		// Adjust the length of the array to the actual number of sessions added
	 	assembly {
            mstore(toReturn, addedCount)
        }
		return toReturn;
	}

	function getSessionsLength( address playerAddr, address serverPublicKey, address tokenAddr ) public view returns (uint){
		return sessionsIds[playerAddr][serverPublicKey][tokenAddr].length;
	}

	function getPlayerSession(bytes32 sessionId) public view returns (Session memory) { 
		return sessions[sessionId];
	}	
	
	function hasPlayerKey(address playerPublicKey) public view returns (bool){
		return playerPublicKeyToPlayerAddress[playerPublicKey] == msg.sender;
	}

	function getPlayerKeys(address playerAddr) public view returns ( address[] memory ){
		address[] memory keys = playerPublicKeys[playerAddr];
		return keys;
	}
	function addPlayerKey(address playerPublicKey) public isAccountOrIsThisContract {
		bool playerKeyFound = hasPlayerKey(playerPublicKey);
		require(!playerKeyFound, "already added");
		require(playerPublicKeyToPlayerAddress[playerPublicKey] == address(0), "key already registered");

		playerPublicKeys[msg.sender].push(playerPublicKey);
		playerPublicKeyToPlayerAddress[playerPublicKey] = msg.sender;

		emit onAddPlayerKey(msg.sender, playerPublicKey);
	}
	function _checkPrivilegedFee(uint128[][] memory pfs) pure internal {
		uint128 previousFee = 0;
		for (uint i=0; i < pfs.length; i++) {
			require(i == pfs.length-1 || pfs[i].length == 2, "others (fee, stake)");
			require(i != pfs.length-1 || pfs[i].length == 1, "last (fee)");
			uint128 currentFee = pfs[i][0];
			require(currentFee >= 0 && currentFee <= 10000, "invalid fee"); 
			require(i == 0 || currentFee >= previousFee, "invalid order");
			previousFee = currentFee;
		}	
	}

	function setPrivilegedFees(uint128[][] memory pfs) external onlyOwner {
		_checkPrivilegedFee(pfs);
		privilegedFees = pfs;
	}

	function setPrivilegedProviderFees(address serverAddr, uint128[][] memory pfs) external {
		checkAuthority(address(0));
		_checkPrivilegedFee(pfs);
		providerConfigs[serverAddr].privilegedFees = pfs;
	}

	function getSessionFee(Session memory session) private view returns (uint128) {
		
		if (isPrivilegedToken(session.tokenAddr)) {
			for (uint i=0; i < session.privilegedFees.length; i++) {
				if (i == session.privilegedFees.length -1 || serverBalances[session.serverPublicKey] < session.privilegedFees[i][1]) {
					return session.privilegedFees[i][0];
				} 
			}
		} else {
			return FEE;
		}
		return FEE;
	}
	
    function _verifyPlayerSignature(address playerAddr, bytes32 _msgHash, bytes memory _signature) private view returns (bool)
    {
        address addr = _msgHash.recover(_signature);  
		return playerPublicKeyToPlayerAddress[addr] == playerAddr;
    }
		
    function _verifyMessage(bytes32 _msgHash, bytes32 sessionId, uint seq, uint balance) private pure returns (bool)
    {
        bytes32 proof = keccak256(abi.encodePacked(sessionId, balance, seq));
        return (proof == _msgHash);
    }
	
    function _verifySignature(bytes32 _msgHash, bytes memory _signature, address _signer) private pure returns (bool)
    {
        address addr = _msgHash.recover(_signature);
        return (addr == _signer);
    }

	function _getBalance(Session memory session, uint128 bet, uint128 win) private pure returns (uint128) {
		return session.depositAmount + win - bet;
	}

	function playerClosesSession(bytes32 sessionId, uint32 seq, uint128 bet, uint128 win, bytes32 _msgHash, bytes memory playerSig, bytes memory serverSig) external isAccountOrIsThisContract {
		
		Session storage session = sessions[sessionId];

		require(session.playerAddr == msg.sender, "invalid sender");

		if (bet > win) require((bet - win) <= session.depositAmount);

		if (seq == 0) {
			require(bet == 0);
			require(win == 0);
		} else {
			require(_verifyMessage(_msgHash, sessionId, seq, _getBalance(session, bet, win)), "invalid hash");
			require(_verifySignature(_msgHash, serverSig, session.serverPublicKey), "invalid server signature");
			require(_verifyPlayerSignature(msg.sender, _msgHash, playerSig), "invalid player signature");  
		}
		require(session.status ==  SessionStatus.OPEN || session.status == SessionStatus.SERVER_CLOSING, "invalid state");
		

		if (session.status == SessionStatus.SERVER_CLOSING) {
			//chose best seq 
			if (seq > session.seq) {
				//choose player balance...
				session.win = win;
				session.bet = bet;
				session.seq = seq;
			}			
			_endSession(session);
			

		} else if (session.status == SessionStatus.OPEN) {
			//player closes first..
			session.lastUpdated = uint32(block.timestamp);
			session.win = win;
			session.bet = bet;
			session.seq = seq;
			session.status = SessionStatus.PLAYER_CLOSING;
			emit onSessionUpdated(session);	

		} else {
			revert("player cannot close session");
		}
		
		emit onPlayerClose(session);				
	}

	function playerClosesSessionAfterTimeout(bytes32 sessionId) external isAccountOrIsThisContract {	
		Session storage session = sessions[sessionId];
		require(session.playerAddr == msg.sender, "invalid sender");
		require(session.status == SessionStatus.PLAYER_CLOSING);		
		uint gap = block.timestamp - session.lastUpdated;
		require(gap > getCounterCloseTimeout(), "cannot close");
		_endSession(session);
		emit onPlayerCloseAfterTimeout(session);	
	}
	
	function checkAuthority(address serverPublicKey) view private {
		require(
			owner == msg.sender || 
			(address(this) == msg.sender && tx.origin == owner)/* from batch */ || 
			(serverPublicKey!=address(0) && serverPublicKeysToServerAddress[serverPublicKey] == msg.sender),
			"unauth"
		);
	}
	

	function serverClosesSessionAfterTimeout(bytes32 sessionId) external isAccountOrIsThisContract {		
		Session storage session = sessions[sessionId];

		checkAuthority(session.serverPublicKey);

		require(session.status == SessionStatus.SERVER_CLOSING);		
		uint gap = block.timestamp - session.lastUpdated;
		require(gap >= getCounterCloseTimeout(), "cannot close");
		_endSession(session);
		emit onServerCloseAfterTimeout(session);	
	}	
	function serverClosesSession( bytes32 sessionId, uint32 seq, uint128 bet, uint128 win, bytes32 _msgHash, bytes memory playerSig, bytes memory serverSig) external isAccountOrIsThisContract { 		
		Session storage session = sessions[sessionId];
		
		if (bet > win) require((bet - win) <= session.depositAmount);
		checkAuthority(session.serverPublicKey);
		uint256 balance = _getBalance(session, bet, win);

		if (seq == 0) { 
			require( session.status == SessionStatus.PLAYER_CLOSING, "cannot close before player" );
			require(bet == 0);
			require(win == 0);
		} else {
			require(session.status == SessionStatus.OPEN || session.status == SessionStatus.PLAYER_CLOSING);
			require(_verifyMessage(_msgHash, sessionId, seq, balance), "invalid hash");
			require(_verifyPlayerSignature(session.playerAddr, _msgHash, playerSig), "invalid player signature");
			require(_verifySignature(_msgHash, serverSig, session.serverPublicKey), "invalid server signature");
			require( session.status == SessionStatus.PLAYER_CLOSING || balance < session.minBalance || block.timestamp > session.serverCanCloseAt, "too early" );
		}
		
		if (session.status == SessionStatus.PLAYER_CLOSING) {
			//chose best seq 
			if (seq > session.seq) {
				//choose server balance...
				session.win = win;
				session.bet = bet;
				session.seq = seq;
			}			
			_endSession(session);

		} else if (session.status == SessionStatus.OPEN) {
			
			//server can only close if player has lost some money
			require(balance < session.depositAmount, "not in loss");


			//server closes first..
			session.lastUpdated = uint32(block.timestamp);
			session.win = win;
			session.bet = bet;
			session.seq = seq;
			session.status = SessionStatus.SERVER_CLOSING;
			emit onSessionUpdated(session);	

		} else {
			revert("cannot close");
		}

		emit onServerClose(session);	
	}
	
	function serverPaysDueAmount(bytes32 sessionId, uint128 amount) external payable isAccountOrIsThisContract {
		//session.serverDueAmount
		Session storage session = sessions[sessionId];
		require(session.status == SessionStatus.SERVER_PAYMENT_DUE);
		checkAuthority(session.serverPublicKey);
		require(amount == session.serverDueAmount, "invalid amount");	
		require(serverBalances[session.serverPublicKey] >= amount);

		uint32 serverPayDuration = uint32(block.timestamp) - session.lastUpdated;
		serverMetrics[session.serverPublicKey].paymentIntervalCount += serverPayDuration * amount;
		serverMetrics[session.serverPublicKey].paymentIntervalAmount += amount;

		//send money to player addr
		session.status = SessionStatus.CLOSED;
		session.lastUpdated = uint32(block.timestamp);
		serverBalances[session.serverPublicKey] -= amount;

		serverMetrics[session.serverPublicKey].paidAmount += amount;
		require(transferAmount(session.playerAddr, amount, session.tokenAddr));
		emit onTransferToPlayer(session, amount);
		emit onServerPayDueAmount(session, amount);	
		emit onSessionUpdated(session);	
	}
	
	function _endSession(Session storage session)  private {
		
		uint256 balance = session.depositAmount + session.win - session.bet;
		if (balance > session.depositAmount) {
			//server needs to pay!
			//conctract sends depositAmount to server, 
			//server pays for balance			
			
			session.lastUpdated = uint32(block.timestamp);
			serverMetrics[session.serverPublicKey].payAmount += (session.win - session.bet);

			uint128 payAmount = min(serverBalances[session.serverPublicKey], session.win - session.bet);
			
			uint128 serverDueAmount = (session.win - session.bet) - payAmount;
			if (serverDueAmount > 0) {
				session.serverDueAmount = serverDueAmount;
				session.status = SessionStatus.SERVER_PAYMENT_DUE;
				
			} else {
				session.status = SessionStatus.CLOSED;
			}
			
			if (payAmount > 0) {
				serverMetrics[session.serverPublicKey].paidAmount += payAmount;
				serverBalances[session.serverPublicKey] -= payAmount;
				serverMetrics[session.serverPublicKey].paymentIntervalAmount += payAmount;
			}

			require(transferAmount(session.playerAddr, session.depositAmount + payAmount, session.tokenAddr));

			emit onTransferToPlayer(session, session.depositAmount + payAmount);

		} else if (balance > 0) {
			//player has some money left to withdraw...
			//conctract sends balance to player
			session.status = SessionStatus.CLOSED;
			session.lastUpdated = uint32(block.timestamp);			
			require(transferAmount( session.playerAddr, balance, session.tokenAddr ));
			if (session.bet - session.win > 0) {
				transferAmountToServer( session, session.bet - session.win );
			}
			emit onTransferToPlayer(session, balance);
			
		} else {
			//player lost all the money 
			//contract depositAmount money to server....
			session.status = SessionStatus.CLOSED;
			session.lastUpdated = uint32(block.timestamp);
			transferAmountToServer(session, session.depositAmount);
		}		

		emit onSessionUpdated(session);	
	}

	function transferAmountToServer(Session storage session, uint128 amount) private {
		uint128 fee = getSessionFee(session);
		uint128 amountToServer = (amount * (MAX_FEE-fee) ) / MAX_FEE;
		serverBalances[session.serverPublicKey] += amountToServer;
		require(transferAmount(RECEIVER, (amount * fee) / MAX_FEE, session.tokenAddr));
		emit onTransferToServer(session, amountToServer);
	}
	
	function getServerBalance( address serverPublicKey) public view returns ( uint256 ){
		return serverBalances[serverPublicKey];
	}
	
	function getServerMetrics( address serverPublicKey) public view returns ( uint256[] memory){
		uint256[] memory res = new uint256[](4);
		res[0] = serverMetrics[serverPublicKey].paidAmount;
		res[1] = serverMetrics[serverPublicKey].payAmount;
		res[2] = serverMetrics[serverPublicKey].paymentIntervalAmount;
		res[3] = serverMetrics[serverPublicKey].paymentIntervalCount;
		return res;
	}

	function withdrawServerBalance( address serverPublicKey, address tokenAddr, uint128 amount) external payable isAccountOrIsThisContract {
		address serverAddr = serverPublicKeysToServerAddress[serverPublicKey];
		
		require(msg.sender == serverAddr, "not authorized");
		require(serverPublicKeysToTokenAddress[serverPublicKey] == tokenAddr, "Invalid tokenAddr");
		require(serverBalances[serverPublicKey] >= amount, "Insufficient Balance");
		
		serverBalances[serverPublicKey] -= amount;
		require(transferAmount(serverAddr, amount, tokenAddr));
		emit onWithdrawServerBalance( serverPublicKey, serverAddr, tokenAddr, amount );
	}	
	
	function depositServerBalance( address serverPublicKey, address tokenAddr, uint128 amount ) external payable isAccountOrIsThisContract {
		require(amount > 0, "invalid amount");
		require(serverPublicKeysToTokenAddress[serverPublicKey] == tokenAddr, "Invalid tokenAddr");

		address serverAddr = serverPublicKeysToServerAddress[serverPublicKey];
		if( isWeth(tokenAddr) ){
			require(amount == msg.value, "invalid msg.value");	
		} else {
			IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount);
		}
		serverBalances[serverPublicKey] += amount;
		emit onDepositServerBalance( serverPublicKey, serverAddr, tokenAddr, amount );
	}
	
}