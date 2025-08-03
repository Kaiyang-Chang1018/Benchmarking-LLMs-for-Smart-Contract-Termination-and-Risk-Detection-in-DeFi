// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// @dev Note:
/// For performance and bytecode compactness, most of the string operations are restricted to
/// byte strings (7-bit ASCII), except where otherwise specified.
/// Usage of byte string operations on charsets with runes spanning two or more bytes
/// can lead to undefined behavior.
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The length of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /// @dev The length of the string is more than 32 bytes.
    error TooBigForSmallString();

    /// @dev The input string must be a 7-bit ASCII.
    error StringNot7BitASCII();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant ALPHANUMERIC_7_BIT_ASCII = 0x7fffffe07fffffe03ff000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant LETTERS_7_BIT_ASCII = 0x7fffffe07fffffe0000000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyz'.
    uint128 internal constant LOWERCASE_7_BIT_ASCII = 0x7fffffe000000000000000000000000;

    /// @dev Lookup for 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant UPPERCASE_7_BIT_ASCII = 0x7fffffe0000000000000000;

    /// @dev Lookup for '0123456789'.
    uint128 internal constant DIGITS_7_BIT_ASCII = 0x3ff000000000000;

    /// @dev Lookup for '0123456789abcdefABCDEF'.
    uint128 internal constant HEXDIGITS_7_BIT_ASCII = 0x7e0000007e03ff000000000000;

    /// @dev Lookup for '01234567'.
    uint128 internal constant OCTDIGITS_7_BIT_ASCII = 0xff000000000000;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c'.
    uint128 internal constant PRINTABLE_7_BIT_ASCII = 0x7fffffffffffffffffffffff00003e00;

    /// @dev Lookup for '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'.
    uint128 internal constant PUNCTUATION_7_BIT_ASCII = 0x78000001f8000001fc00fffe00000000;

    /// @dev Lookup for ' \t\n\r\x0b\x0c'.
    uint128 internal constant WHITESPACE_7_BIT_ASCII = 0x100003e00;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            str := add(mload(0x40), 0x80)
            mstore(0x40, add(str, 0x20)) // Allocate the memory.
            mstore(str, 0) // Zeroize the slot after the string.

            let end := str // Cache the end of the memory to calculate the length later.
            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 1)`.
                // Store the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                temp := div(temp, 10) // Keep dividing `temp` until zero.
                if iszero(temp) { break }
            }
            let length := sub(end, str)
            str := sub(str, 0x20) // Move the pointer 32 bytes back to make room for the length.
            mstore(str, length) // Store the length.
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) return toString(uint256(value));
        unchecked {
            str = toString(~uint256(value) + 1);
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let length := mload(str) // Load the string length.
            mstore(str, 0x2d) // Store the '-' character.
            str := sub(str, 1) // Move back the string pointer by a byte.
            mstore(str, add(length, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2 + 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value, length);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Store the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `length` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `length * 2` bytes.
    /// Reverts if `length` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 length)
        internal
        pure
        returns (string memory str)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            str := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))
            mstore(0x40, add(str, 0x20)) // Allocate the memory.
            mstore(str, 0) // Zeroize the slot after the string.

            let end := str // Cache the end to calculate the length later.
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(str, add(length, length))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(str, start)) { break }
            }
            if temp {
                mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
                revert(0x1c, 0x04)
            }
            let strLength := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Store the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x".
    /// The output excludes leading "0" from the `toHexString` output.
    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
    function toMinimalHexString(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(add(str, o), 0x3078) // Store the "0x" prefix, accounting for leading zero.
            str := sub(add(str, o), 2) // Move the pointer, accounting for leading zero.
            mstore(str, sub(strLength, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.
    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.
    function toMinimalHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.
            let strLength := mload(str) // Get the length.
            str := add(str, o) // Move the pointer, accounting for leading zero.
            mstore(str, sub(strLength, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            str := add(mload(0x40), 0x80)
            mstore(0x40, add(str, 0x20)) // Allocate the memory.
            mstore(str, 0) // Zeroize the slot after the string.

            let end := str // Cache the end to calculate the length later.
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 2)`.
                mstore8(add(str, 1), mload(and(temp, 15)))
                mstore8(str, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }
            let strLength := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory str) {
        str = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(str, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for { let i := 0 } 1 {} {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Store the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            str := mload(0x40)
            // Allocate the memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(str, 0x80))
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            str := add(str, 2)
            mstore(str, 40) // Store the length.
            let o := add(str, 0x20)
            mstore(add(o, 40), 0) // Zeroize the slot after the string.
            value := shl(96, value)
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let i := 0 } 1 {} {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory str) {
        str = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let strLength := add(mload(str), 2) // Compute the length.
            mstore(str, 0x3078) // Store the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Store the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(raw)
            str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(str, add(length, length)) // Store the length of the output.

            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.
            let o := add(str, 0x20)
            let end := add(raw, length)
            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RUNE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the number of UTF characters in the string.
    function runeCount(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                mstore(0x00, div(not(0), 255))
                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
                }
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string.
    /// (i.e. all characters codes are in [0..127])
    function is7BitASCII(string memory s) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(7, div(not(0), 255))
            result := 1
            let n := mload(s)
            if n {
                let o := add(s, 0x20)
                let end := add(o, n)
                let last := mload(end)
                mstore(end, 0)
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
                }
                mstore(end, last)
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string,
    /// AND all characters are in the `allowed` lookup.
    /// Note: If `s` is empty, returns true regardless of `allowed`.
    function is7BitASCII(string memory s, uint128 allowed) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if mload(s) {
                let allowed_ := shr(128, shl(128, allowed))
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for {} 1 {} {
                    result := and(result, shr(byte(0, mload(o)), allowed_))
                    o := add(o, 1)
                    if iszero(and(result, lt(o, end))) { break }
                }
            }
        }
    }

    /// @dev Converts the bytes in the 7-bit ASCII string `s` to
    /// an allowed lookup for use in `is7BitASCII(s, allowed)`.
    /// To save runtime gas, you can cache the result in an immutable variable.
    function to7BitASCIIAllowedLookup(string memory s) internal pure returns (uint128 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for {} 1 {} {
                    result := or(result, shl(byte(0, mload(o)), 1))
                    o := add(o, 1)
                    if iszero(lt(o, end)) { break }
                }
                if shr(128, result) {
                    mstore(0x00, 0xc9807e0d) // `StringNot7BitASCII()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, byte string operations are restricted
    // to 7-bit ASCII strings. All offsets are byte offsets, not UTF character offsets.
    // Usage of byte string operations on charsets with runes spanning two or more bytes
    // can lead to undefined behavior.

    /// @dev Returns `subject` all occurrences of `search` replaced with `replacement`.
    function replace(string memory subject, string memory search, string memory replacement)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)
            let replacementLength := mload(replacement)

            subject := add(subject, 0x20)
            search := add(search, 0x20)
            replacement := add(replacement, 0x20)
            result := add(mload(0x40), 0x20)

            let subjectEnd := add(subject, subjectLength)
            if iszero(gt(searchLength, subjectLength)) {
                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                mstore(result, t)
                                result := add(result, 1)
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let o := 0 } 1 {} {
                            mstore(add(result, o), mload(add(replacement, o)))
                            o := add(o, 0x20)
                            if iszero(lt(o, replacementLength)) { break }
                        }
                        result := add(result, replacementLength)
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(result, t)
                    result := add(result, 1)
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
            }

            let resultRemainder := result
            result := add(mload(0x40), 0x20)
            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
            // Copy the rest of the string one word at a time.
            for {} lt(subject, subjectEnd) {} {
                mstore(resultRemainder, mload(subject))
                resultRemainder := add(resultRemainder, 0x20)
                subject := add(subject, 0x20)
            }
            result := sub(result, 0x20)
            let last := add(add(result, 0x20), k) // Zeroize the slot after the string.
            mstore(last, 0)
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
            mstore(result, k) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for { let subjectLength := mload(subject) } 1 {} {
                if iszero(mload(search)) {
                    if iszero(gt(from, subjectLength)) {
                        result := from
                        break
                    }
                    result := subjectLength
                    break
                }
                let searchLength := mload(search)
                let subjectStart := add(subject, 0x20)

                result := not(0) // Initialize to `NOT_FOUND`.
                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLength), searchLength), 1)

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(add(search, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }

                if iszero(lt(searchLength, 0x20)) {
                    for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, searchLength), h) {
                                result := sub(subject, subjectStart)
                                break
                            }
                        }
                        subject := add(subject, 1)
                        if iszero(lt(subject, end)) { break }
                    }
                    break
                }
                for {} 1 {} {
                    if iszero(shr(m, xor(mload(subject), s))) {
                        result := sub(subject, subjectStart)
                        break
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function indexOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256 result)
    {
        result = indexOf(subject, search, 0);
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let searchLength := mload(search)
                if gt(searchLength, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), searchLength)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {
                    if eq(keccak256(subject, searchLength), h) {
                        result := sub(subject, add(end, 1))
                        break
                    }
                    subject := add(subject, w) // `sub(subject, 1)`.
                    if iszero(gt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `search` in `subject`,
    /// searching from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
    function lastIndexOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256 result)
    {
        result = lastIndexOf(subject, search, uint256(int256(-1)));
    }

    /// @dev Returns true if `search` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory search) internal pure returns (bool) {
        return indexOf(subject, search) != NOT_FOUND;
    }

    /// @dev Returns whether `subject` starts with `search`.
    function startsWith(string memory subject, string memory search)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                iszero(gt(searchLength, mload(subject))),
                eq(
                    keccak256(add(subject, 0x20), searchLength),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns whether `subject` ends with `search`.
    function endsWith(string memory subject, string memory search)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLength := mload(search)
            let subjectLength := mload(subject)
            // Whether `search` is not longer than `subject`.
            let withinRange := iszero(gt(searchLength, subjectLength))
            // Just using keccak256 directly is actually cheaper.
            // forgefmt: disable-next-item
            result := and(
                withinRange,
                eq(
                    keccak256(
                        // `subject + 0x20 + max(subjectLength - searchLength, 0)`.
                        add(add(subject, 0x20), mul(withinRange, sub(subjectLength, searchLength))),
                        searchLength
                    ),
                    keccak256(add(search, 0x20), searchLength)
                )
            )
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(or(iszero(times), iszero(subjectLength))) {
                subject := add(subject, 0x20)
                result := mload(0x40)
                let output := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let o := 0 } 1 {} {
                        mstore(add(output, o), mload(add(subject, o)))
                        o := add(o, 0x20)
                        if iszero(lt(o, subjectLength)) { break }
                    }
                    output := add(output, subjectLength)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(output, 0) // Zeroize the slot after the string.
                let resultLength := sub(output, add(result, 0x20))
                mstore(result, resultLength) // Store the length.
                mstore(0x40, add(result, add(resultLength, 0x40))) // Allocate the memory.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            if iszero(gt(subjectLength, end)) { end := subjectLength }
            if iszero(gt(subjectLength, start)) { start := subjectLength }
            if lt(start, end) {
                result := mload(0x40)
                let resultLength := sub(end, start)
                mstore(result, resultLength)
                subject := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let o := and(add(resultLength, 0x1f), w) } 1 {} {
                    mstore(add(result, o), mload(add(subject, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
                }
                // Zeroize the slot after the string.
                mstore(add(add(result, 0x20), resultLength), 0)
                mstore(0x40, add(result, add(resultLength, 0x40))) // Allocate the memory.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start)
        internal
        pure
        returns (string memory result)
    {
        result = slice(subject, start, uint256(int256(-1)));
    }

    /// @dev Returns all the indices of `search` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory search)
        internal
        pure
        returns (uint256[] memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let subjectLength := mload(subject)
            let searchLength := mload(search)

            if iszero(gt(searchLength, subjectLength)) {
                subject := add(subject, 0x20)
                search := add(search, 0x20)
                result := add(mload(0x40), 0x20)

                let subjectStart := subject
                let subjectSearchEnd := add(sub(add(subject, subjectLength), searchLength), 1)
                let h := 0
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(search)
                for {} 1 {} {
                    let t := mload(subject)
                    // Whether the first `searchLength % 32` bytes of
                    // `subject` and `search` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(subject, searchLength), h)) {
                                subject := add(subject, 1)
                                if iszero(lt(subject, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Append to `result`.
                        mstore(result, sub(subject, subjectStart))
                        result := add(result, 0x20)
                        // Advance `subject` by `searchLength`.
                        subject := add(subject, searchLength)
                        if searchLength {
                            if iszero(lt(subject, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, subjectSearchEnd)) { break }
                }
                let resultEnd := result
                // Assign `result` to the free memory pointer.
                result := mload(0x40)
                // Store the length of `result`.
                mstore(result, shr(5, sub(resultEnd, add(result, 0x20))))
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(resultEnd, 0x20))
            }
        }
    }

    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter)
        internal
        pure
        returns (string[] memory result)
    {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            let prevIndex := 0
            for {} 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let elementLength := sub(index, prevIndex)
                    mstore(element, elementLength)
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(elementLength, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    // Zeroize the slot after the string.
                    mstore(add(add(element, 0x20), elementLength), 0)
                    // Allocate memory for the length and the bytes,
                    // rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(elementLength, 0x3f), w)))
                    // Store the `element` into the array.
                    mstore(indexPtr, element)
                }
                prevIndex := add(index, mload(delimiter))
                indexPtr := add(indexPtr, 0x20)
                if iszero(lt(indexPtr, indicesEnd)) { break }
            }
            result := indices
            if iszero(mload(delimiter)) {
                result := add(indices, 0x20)
                mstore(result, sub(mload(indices), 2))
            }
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            result := mload(0x40)
            let aLength := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLength, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLength := mload(b)
            let output := add(result, aLength)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLength, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLength := add(aLength, bLength)
            let last := add(add(result, 0x20), totalLength)
            mstore(last, 0) // Zeroize the slot after the string.
            mstore(result, totalLength) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function toCase(string memory subject, bool toUpper)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(subject)
            if length {
                result := add(mload(0x40), 0x20)
                subject := add(subject, 1)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(subject, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
                }
                result := mload(0x40)
                mstore(result, length) // Store the length.
                let last := add(add(result, 0x20), length)
                mstore(last, 0) // Zeroize the slot after the string.
                mstore(0x40, add(last, 0x20)) // Allocate the memory.
            }
        }
    }

    /// @dev Returns a string from a small bytes32 string.
    /// `s` must be null-terminated, or behavior will be undefined.
    function fromSmallString(bytes32 s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let n := 0
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
            mstore(result, n) // Store the length.
            let o := add(result, 0x20)
            mstore(o, s) // Store the bytes of the string.
            mstore(add(o, n), 0) // Zeroize the slot after the string.
            mstore(0x40, add(result, 0x40)) // Allocate the memory.
        }
    }

    /// @dev Returns the small string, with all bytes after the first null byte zeroized.
    function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
            mstore(0x00, s)
            mstore(result, 0x00)
            result := mload(0x00)
        }
    }

    /// @dev Returns the string as a normalized null-terminated small string.
    function toSmallString(string memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(s)
            if iszero(lt(result, 33)) {
                mstore(0x00, 0xec92f9a3) // `TooBigForSmallString()`.
                revert(0x1c, 0x04)
            }
            result := shl(shl(3, sub(32, result)), mload(add(s, result)))
        }
    }

    /// @dev Returns a lowercased copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let end := add(s, mload(s))
            result := add(mload(0x40), 0x20)
            // Store the bytes of the packed offsets and strides into the scratch space.
            // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
            mstore(0x1f, 0x900094)
            mstore(0x08, 0xc0000000a6ab)
            // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
            mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(result, c)
                    result := add(result, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(result, mload(and(t, 0x1f)))
                result := add(result, shr(5, t))
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    /// If `addDoubleQuotes` is true, the result will be enclosed in double-quotes.
    function escapeJSON(string memory s, bool addDoubleQuotes)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let end := add(s, mload(s))
            result := add(mload(0x40), 0x20)
            if addDoubleQuotes {
                mstore8(result, 34)
                result := add(1, result)
            }
            // Store "\\u0000" in scratch space.
            // Store "0123456789abcdef" in scratch space.
            // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
            // into the scratch space.
            mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
            // Bitmask for detecting `["\"","\\"]`.
            let e := or(shl(0x22, 1), shl(0x5c, 1))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(result, c)
                        result := add(result, 1)
                        continue
                    }
                    mstore8(result, 0x5c) // "\\".
                    mstore8(add(result, 1), c)
                    result := add(result, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(result, mload(0x19)) // "\\u00XX".
                    result := add(result, 6)
                    continue
                }
                mstore8(result, 0x5c) // "\\".
                mstore8(add(result, 1), mload(add(c, 8)))
                result := add(result, 2)
            }
            if addDoubleQuotes {
                mstore8(result, 34)
                result := add(1, result)
            }
            let last := result
            mstore(last, 0) // Zeroize the slot after the string.
            result := mload(0x40)
            mstore(result, sub(last, add(result, 0x20))) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        result = escapeJSON(s, false);
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small string.
    function eqs(string memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Packs a single string with its length into a single word.
    /// Returns `bytes32(0)` if the length is zero or greater than 31.
    function packOne(string memory a) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We don't need to zero right pad the string,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes.
                    mload(add(a, 0x1f)),
                    // `length != 0 && length < 32`. Abuses underflow.
                    // Assumes that the length is valid and within the block gas limit.
                    lt(sub(mload(a), 1), 0x1f)
                )
        }
    }

    /// @dev Unpacks a string packed using {packOne}.
    /// Returns the empty string if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packOne}, the output behavior is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40) // Grab the free memory pointer.
            mstore(0x40, add(result, 0x40)) // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(result, 0) // Zeroize the length slot.
            mstore(add(result, 0x1f), packed) // Store the length and bytes.
            mstore(add(add(result, 0x20), mload(result)), 0) // Right pad with zeroes.
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLength := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    or( // Load the length and the bytes of `a` and `b`.
                        shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))),
                        mload(sub(add(b, 0x1e), aLength))
                    ),
                    // `totalLength != 0 && totalLength < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLength, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
    function unpackTwo(bytes32 packed)
        internal
        pure
        returns (string memory resultA, string memory resultB)
    {
        /// @solidity memory-safe-assembly
        assembly {
            resultA := mload(0x40) // Grab the free memory pointer.
            resultB := add(resultA, 0x40)
            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
            mstore(0x40, add(resultB, 0x40))
            // Zeroize the length slots.
            mstore(resultA, 0)
            mstore(resultB, 0)
            // Store the lengths and bytes.
            mstore(add(resultA, 0x1f), packed)
            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
            // Right pad with zeroes.
            mstore(add(add(resultA, 0x20), mload(resultA)), 0)
            mstore(add(add(resultB, 0x20), mload(resultB)), 0)
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(string memory a) internal pure {
        assembly {
            // Assumes that the string does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the string.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SSTORE2.sol)
/// @author Saw-mon-and-Natalie (https://github.com/Saw-mon-and-Natalie)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SSTORE2.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/sstore2/blob/master/contracts/SSTORE2.sol)
/// @author Modified from SSTORE3 (https://github.com/Philogy/sstore3)
library SSTORE2 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The proxy initialization code.
    uint256 private constant _CREATE3_PROXY_INITCODE = 0x67363d3d37363d34f03d5260086018f3;

    /// @dev Hash of the `_CREATE3_PROXY_INITCODE`.
    /// Equivalent to `keccak256(abi.encodePacked(hex"67363d3d37363d34f03d5260086018f3"))`.
    bytes32 internal constant CREATE3_PROXY_INITCODE_HASH =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the storage contract.
    error DeploymentFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         WRITE LOGIC                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Writes `data` into the bytecode of a storage contract and returns its address.
    function write(bytes memory data) internal returns (address pointer) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(data) // Let `l` be `n + 1`. +1 as we prefix a STOP opcode.
            /**
             * ---------------------------------------------------+
             * Opcode | Mnemonic       | Stack     | Memory       |
             * ---------------------------------------------------|
             * 61 l   | PUSH2 l        | l         |              |
             * 80     | DUP1           | l l       |              |
             * 60 0xa | PUSH1 0xa      | 0xa l l   |              |
             * 3D     | RETURNDATASIZE | 0 0xa l l |              |
             * 39     | CODECOPY       | l         | [0..l): code |
             * 3D     | RETURNDATASIZE | 0 l       | [0..l): code |
             * F3     | RETURN         |           | [0..l): code |
             * 00     | STOP           |           |              |
             * ---------------------------------------------------+
             * @dev Prefix the bytecode with a STOP opcode to ensure it cannot be called.
             * Also PUSH2 is used since max contract size cap is 24,576 bytes which is less than 2 ** 16.
             */
            // Do a out-of-gas revert if `n + 1` is more than 2 bytes.
            mstore(add(data, gt(n, 0xfffe)), add(0xfe61000180600a3d393df300, shl(0x40, n)))
            // Deploy a new contract with the generated creation code.
            pointer := create(0, add(data, 0x15), add(n, 0xb))
            if iszero(pointer) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(data, n) // Restore the length of `data`.
        }
    }

    /// @dev Writes `data` into the bytecode of a storage contract with `salt`
    /// and returns its normal CREATE2 deterministic address.
    function writeCounterfactual(bytes memory data, bytes32 salt)
        internal
        returns (address pointer)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(data)
            // Do a out-of-gas revert if `n + 1` is more than 2 bytes.
            mstore(add(data, gt(n, 0xfffe)), add(0xfe61000180600a3d393df300, shl(0x40, n)))
            // Deploy a new contract with the generated creation code.
            pointer := create2(0, add(data, 0x15), add(n, 0xb), salt)
            if iszero(pointer) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(data, n) // Restore the length of `data`.
        }
    }

    /// @dev Writes `data` into the bytecode of a storage contract and returns its address.
    /// This uses the so-called "CREATE3" workflow,
    /// which means that `pointer` is agnostic to `data, and only depends on `salt`.
    function writeDeterministic(bytes memory data, bytes32 salt)
        internal
        returns (address pointer)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(data)
            mstore(0x00, _CREATE3_PROXY_INITCODE) // Store the `_PROXY_INITCODE`.
            let proxy := create2(0, 0x10, 0x10, salt)
            if iszero(proxy) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, proxy) // Store the proxy's address.
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01) // Nonce of the proxy contract (1).
            pointer := keccak256(0x1e, 0x17)

            // Do a out-of-gas revert if `n + 1` is more than 2 bytes.
            mstore(add(data, gt(n, 0xfffe)), add(0xfe61000180600a3d393df300, shl(0x40, n)))
            if iszero(
                mul( // The arguments of `mul` are evaluated last to first.
                    extcodesize(pointer),
                    call(gas(), proxy, 0, add(data, 0x15), add(n, 0xb), codesize(), 0x00)
                )
            ) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(data, n) // Restore the length of `data`.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    ADDRESS CALCULATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the initialization code hash of the storage contract for `data`.
    /// Used for mining vanity addresses with create2crunch.
    function initCodeHash(bytes memory data) internal pure returns (bytes32 hash) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(data)
            // Do a out-of-gas revert if `n + 1` is more than 2 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0xfffe))
            mstore(data, add(0x61000180600a3d393df300, shl(0x40, n)))
            hash := keccak256(add(data, 0x15), add(n, 0xb))
            mstore(data, n) // Restore the length of `data`.
        }
    }

    /// @dev Equivalent to `predictCounterfactualAddress(data, salt, address(this))`
    function predictCounterfactualAddress(bytes memory data, bytes32 salt)
        internal
        view
        returns (address pointer)
    {
        pointer = predictCounterfactualAddress(data, salt, address(this));
    }

    /// @dev Returns the CREATE2 address of the storage contract for `data`
    /// deployed with `salt` by `deployer`.
    /// Note: The returned result has dirty upper 96 bits. Please clean if used in assembly.
    function predictCounterfactualAddress(bytes memory data, bytes32 salt, address deployer)
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

    /// @dev Equivalent to `predictDeterministicAddress(salt, address(this))`.
    function predictDeterministicAddress(bytes32 salt) internal view returns (address pointer) {
        pointer = predictDeterministicAddress(salt, address(this));
    }

    /// @dev Returns the "CREATE3" deterministic address for `salt` with `deployer`.
    function predictDeterministicAddress(bytes32 salt, address deployer)
        internal
        pure
        returns (address pointer)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x00, deployer) // Store `deployer`.
            mstore8(0x0b, 0xff) // Store the prefix.
            mstore(0x20, salt) // Store the salt.
            mstore(0x40, CREATE3_PROXY_INITCODE_HASH) // Store the bytecode hash.

            mstore(0x14, keccak256(0x0b, 0x55)) // Store the proxy's address.
            mstore(0x40, m) // Restore the free memory pointer.
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01) // Nonce of the proxy contract (1).
            pointer := keccak256(0x1e, 0x17)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         READ LOGIC                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `read(pointer, 0, 2 ** 256 - 1)`.
    function read(address pointer) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            data := mload(0x40)
            let n := and(sub(extcodesize(pointer), 0x01), 0xffffffffff)
            extcodecopy(pointer, add(data, 0x1f), 0x00, add(n, 0x21))
            mstore(data, n) // Store the length.
            mstore(0x40, add(n, add(data, 0x40))) // Allocate memory.
        }
    }

    /// @dev Equivalent to `read(pointer, start, 2 ** 256 - 1)`.
    function read(address pointer, uint256 start) internal view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            data := mload(0x40)
            let n := and(sub(extcodesize(pointer), 0x01), 0xffffffffff)
            extcodecopy(pointer, add(data, 0x1f), start, add(n, 0x21))
            mstore(data, mul(sub(n, start), lt(start, n))) // Store the length.
            mstore(0x40, add(data, add(0x40, mload(data)))) // Allocate memory.
        }
    }

    /// @dev Returns a slice of the data on `pointer` from `start` to `end`.
    /// `start` and `end` will be clamped to the range `[0, args.length]`.
    /// The `pointer` MUST be deployed via the SSTORE2 write functions.
    /// Otherwise, the behavior is undefined.
    /// Out-of-gas reverts if `pointer` does not have any code.
    function read(address pointer, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory data)
    {
        /// @solidity memory-safe-assembly
        assembly {
            data := mload(0x40)
            if iszero(lt(end, 0xffff)) { end := 0xffff }
            let d := mul(sub(end, start), lt(start, end))
            extcodecopy(pointer, add(data, 0x1f), start, add(d, 0x01))
            if iszero(and(0xff, mload(add(data, d)))) {
                let n := sub(extcodesize(pointer), 0x01)
                returndatacopy(returndatasize(), returndatasize(), shr(64, n))
                d := mul(gt(n, start), sub(d, mul(gt(end, n), sub(end, n))))
            }
            mstore(data, d) // Store the length.
            mstore(add(add(data, 0x20), d), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(data, 0x40), d)) // Allocate memory.
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.0;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

address constant ZERO_ADDRESS = address(0);

uint256 constant MAX_UINT256 = type(uint256).max;

uint256 constant DECIMAL_PRECISION = 1e18;
uint256 constant _100pct = DECIMAL_PRECISION;
uint256 constant _1pct = DECIMAL_PRECISION / 100;

// Amount of ETH to be locked in gas pool on opening troves
uint256 constant ETH_GAS_COMPENSATION = 0.0375 ether;

// Liquidation
uint256 constant MIN_LIQUIDATION_PENALTY_SP = 5e16; // 5%
uint256 constant MAX_LIQUIDATION_PENALTY_REDISTRIBUTION = 20e16; // 20%

// Fraction of collateral awarded to liquidator
uint256 constant COLL_GAS_COMPENSATION_DIVISOR = 200; // dividing by 200 yields 0.5%
uint256 constant COLL_GAS_COMPENSATION_CAP = 2 ether; // Max coll gas compensation capped at 2 ETH

// Minimum amount of net Bold debt a trove must have
uint256 constant MIN_DEBT = 2000e18;

uint256 constant MIN_ANNUAL_INTEREST_RATE = _1pct / 2; // 0.5%
uint256 constant MAX_ANNUAL_INTEREST_RATE = 250 * _1pct;

// Batch management params
uint128 constant MAX_ANNUAL_BATCH_MANAGEMENT_FEE = uint128(_100pct / 10); // 10%
uint128 constant MIN_INTEREST_RATE_CHANGE_PERIOD = 1 hours; // only applies to batch managers / batched Troves

uint256 constant REDEMPTION_FEE_FLOOR = _1pct / 2; // 0.5%

// For the debt / shares ratio to increase by a factor 1e9
// at a average annual debt increase (compounded interest + fees) of 10%, it would take more than 217 years (log(1e9)/log(1.1))
// at a average annual debt increase (compounded interest + fees) of 50%, it would take more than 51 years (log(1e9)/log(1.5))
// The increase pace could be forced to be higher through an inflation attack,
// but precisely the fact that we have this max value now prevents the attack
uint256 constant MAX_BATCH_SHARES_RATIO = 1e9;

// Half-life of 6h. 6h = 360 min
// (1/2) = d^360 => d = (1/2)^(1/360)
uint256 constant REDEMPTION_MINUTE_DECAY_FACTOR = 998076443575628800;

// BETA: 18 digit decimal. Parameter by which to divide the redeemed fraction, in order to calc the new base rate from a redemption.
// Corresponds to (1 / ALPHA) in the white paper.
uint256 constant REDEMPTION_BETA = 1;

// To prevent redemptions unless Bold depegs below 0.95 and allow the system to take off
uint256 constant INITIAL_BASE_RATE = _100pct; // 100% initial redemption rate

// Discount to be used once the shutdown thas been triggered
uint256 constant URGENT_REDEMPTION_BONUS = 2e16; // 2%

uint256 constant ONE_MINUTE = 1 minutes;
uint256 constant ONE_YEAR = 365 days;
uint256 constant UPFRONT_INTEREST_PERIOD = 7 days;
uint256 constant INTEREST_RATE_ADJ_COOLDOWN = 7 days;

uint256 constant SP_YIELD_SPLIT = 75 * _1pct; // 75%

// Dummy contract that lets legacy Hardhat tests query some of the constants
contract Constants {
    uint256 public constant _ETH_GAS_COMPENSATION = ETH_GAS_COMPENSATION;
    uint256 public constant _MIN_DEBT = MIN_DEBT;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "./Constants.sol";
import "./LiquityMath.sol";
import "../Interfaces/IAddressesRegistry.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/ILiquityBase.sol";

/*
* Base contract for TroveManager, BorrowerOperations and StabilityPool. Contains global system constants and
* common functions.
*/
contract LiquityBase is ILiquityBase {
    IActivePool public activePool;
    IDefaultPool internal defaultPool;
    IPriceFeed internal priceFeed;

    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);

    constructor(IAddressesRegistry _addressesRegistry) {
        activePool = _addressesRegistry.activePool();
        defaultPool = _addressesRegistry.defaultPool();
        priceFeed = _addressesRegistry.priceFeed();

        emit ActivePoolAddressChanged(address(activePool));
        emit DefaultPoolAddressChanged(address(defaultPool));
        emit PriceFeedAddressChanged(address(priceFeed));
    }
    // --- Gas compensation functions ---

    function getEntireSystemColl() public view returns (uint256 entireSystemColl) {
        uint256 activeColl = activePool.getCollBalance();
        uint256 liquidatedColl = defaultPool.getCollBalance();

        return activeColl + liquidatedColl;
    }

    function getEntireSystemDebt() public view returns (uint256 entireSystemDebt) {
        uint256 activeDebt = activePool.getBoldDebt();
        uint256 closedDebt = defaultPool.getBoldDebt();

        return activeDebt + closedDebt;
    }

    function _getTCR(uint256 _price) internal view returns (uint256 TCR) {
        uint256 entireSystemColl = getEntireSystemColl();
        uint256 entireSystemDebt = getEntireSystemDebt();

        TCR = LiquityMath._computeCR(entireSystemColl, entireSystemDebt, _price);

        return TCR;
    }

    function _checkBelowCriticalThreshold(uint256 _price, uint256 _CCR) internal view returns (bool) {
        uint256 TCR = _getTCR(_price);

        return TCR < _CCR;
    }

    function _calcInterest(uint256 _weightedDebt, uint256 _period) internal pure returns (uint256) {
        return _weightedDebt * _period / ONE_YEAR / DECIMAL_PRECISION;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {DECIMAL_PRECISION} from "./Constants.sol";

library LiquityMath {
    function _min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return (_a >= _b) ? _a : _b;
    }

    function _sub_min_0(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return (_a > _b) ? _a - _b : 0;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint256 x, uint256 y) internal pure returns (uint256 decProd) {
        uint256 prod_xy = x * y;

        decProd = (prod_xy + DECIMAL_PRECISION / 2) / DECIMAL_PRECISION;
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by function CollateralRegistry._calcDecayedBaseRate, that represent time in units of minutes
    *
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint256 _base, uint256 _minutes) internal pure returns (uint256) {
        if (_minutes > 525600000) _minutes = 525600000; // cap to avoid overflow

        if (_minutes == 0) return DECIMAL_PRECISION;

        uint256 y = DECIMAL_PRECISION;
        uint256 x = _base;
        uint256 n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n / 2;
            } else {
                // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n - 1) / 2;
            }
        }

        return decMul(x, y);
    }

    function _getAbsoluteDifference(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return (_a >= _b) ? _a - _b : _b - _a;
    }

    function _computeCR(uint256 _coll, uint256 _debt, uint256 _price) internal pure returns (uint256) {
        if (_debt > 0) {
            uint256 newCollRatio = _coll * _price / _debt;

            return newCollRatio;
        }
        // Return the maximal value for uint256 if the debt is 0. Represents "infinite" CR.
        else {
            // if (_debt == 0)
            return 2 ** 256 - 1;
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IInterestRouter.sol";
import "./IBoldRewardsReceiver.sol";
import "../Types/TroveChange.sol";

interface IActivePool {
    function defaultPoolAddress() external view returns (address);
    function borrowerOperationsAddress() external view returns (address);
    function troveManagerAddress() external view returns (address);
    function interestRouter() external view returns (IInterestRouter);
    // We avoid IStabilityPool here in order to prevent creating a dependency cycle that would break flattening
    function stabilityPool() external view returns (IBoldRewardsReceiver);

    function getCollBalance() external view returns (uint256);
    function getBoldDebt() external view returns (uint256);
    function lastAggUpdateTime() external view returns (uint256);
    function aggRecordedDebt() external view returns (uint256);
    function aggWeightedDebtSum() external view returns (uint256);
    function aggBatchManagementFees() external view returns (uint256);
    function aggWeightedBatchManagementFeeSum() external view returns (uint256);
    function calcPendingAggInterest() external view returns (uint256);
    function calcPendingSPYield() external view returns (uint256);
    function calcPendingAggBatchManagementFee() external view returns (uint256);
    function getNewApproxAvgInterestRateFromTroveChange(TroveChange calldata _troveChange)
        external
        view
        returns (uint256);

    function mintAggInterest() external;
    function mintAggInterestAndAccountForTroveChange(TroveChange calldata _troveChange, address _batchManager)
        external;
    function mintBatchManagementFeeAndAccountForChange(TroveChange calldata _troveChange, address _batchAddress)
        external;

    function setShutdownFlag() external;
    function hasBeenShutDown() external view returns (bool);
    function shutdownTime() external view returns (uint256);

    function sendColl(address _account, uint256 _amount) external;
    function sendCollToDefaultPool(uint256 _amount) external;
    function receiveColl(uint256 _amount) external;
    function accountForReceivedColl(uint256 _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAddRemoveManagers {
    function setAddManager(uint256 _troveId, address _manager) external;
    function setRemoveManager(uint256 _troveId, address _manager) external;
    function setRemoveManagerWithReceiver(uint256 _troveId, address _manager, address _receiver) external;
    function addManagerOf(uint256 _troveId) external view returns (address);
    function removeManagerReceiverOf(uint256 _troveId) external view returns (address, address);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IActivePool.sol";
import "./IBoldToken.sol";
import "./IBorrowerOperations.sol";
import "./ICollSurplusPool.sol";
import "./IDefaultPool.sol";
import "./IHintHelpers.sol";
import "./IMultiTroveGetter.sol";
import "./ISortedTroves.sol";
import "./IStabilityPool.sol";
import "./ITroveManager.sol";
import "./ITroveNFT.sol";
import {IMetadataNFT} from "../NFTMetadata/MetadataNFT.sol";
import "./ICollateralRegistry.sol";
import "./IInterestRouter.sol";
import "./IPriceFeed.sol";

interface IAddressesRegistry {
    struct AddressVars {
        IERC20Metadata collToken;
        IBorrowerOperations borrowerOperations;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        IMetadataNFT metadataNFT;
        IStabilityPool stabilityPool;
        IPriceFeed priceFeed;
        IActivePool activePool;
        IDefaultPool defaultPool;
        address gasPoolAddress;
        ICollSurplusPool collSurplusPool;
        ISortedTroves sortedTroves;
        IInterestRouter interestRouter;
        IHintHelpers hintHelpers;
        IMultiTroveGetter multiTroveGetter;
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        IWETH WETH;
    }

    function CCR() external returns (uint256);
    function SCR() external returns (uint256);
    function MCR() external returns (uint256);
    function LIQUIDATION_PENALTY_SP() external returns (uint256);
    function LIQUIDATION_PENALTY_REDISTRIBUTION() external returns (uint256);

    function collToken() external view returns (IERC20Metadata);
    function borrowerOperations() external view returns (IBorrowerOperations);
    function troveManager() external view returns (ITroveManager);
    function troveNFT() external view returns (ITroveNFT);
    function metadataNFT() external view returns (IMetadataNFT);
    function stabilityPool() external view returns (IStabilityPool);
    function priceFeed() external view returns (IPriceFeed);
    function activePool() external view returns (IActivePool);
    function defaultPool() external view returns (IDefaultPool);
    function gasPoolAddress() external view returns (address);
    function collSurplusPool() external view returns (ICollSurplusPool);
    function sortedTroves() external view returns (ISortedTroves);
    function interestRouter() external view returns (IInterestRouter);
    function hintHelpers() external view returns (IHintHelpers);
    function multiTroveGetter() external view returns (IMultiTroveGetter);
    function collateralRegistry() external view returns (ICollateralRegistry);
    function boldToken() external view returns (IBoldToken);
    function WETH() external returns (IWETH);

    function setAddresses(AddressVars memory _vars) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBoldRewardsReceiver {
    function triggerBoldRewards(uint256 _boldYield) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC5267.sol";

interface IBoldToken is IERC20Metadata, IERC20Permit, IERC5267 {
    function setBranchAddresses(
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) external;

    function setCollateralRegistry(address _collateralRegistryAddress) external;

    function mint(address _account, uint256 _amount) external;

    function burn(address _account, uint256 _amount) external;

    function sendToPool(address _sender, address poolAddress, uint256 _amount) external;

    function returnFromPool(address poolAddress, address user, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ILiquityBase.sol";
import "./IAddRemoveManagers.sol";
import "./IBoldToken.sol";
import "./IPriceFeed.sol";
import "./ISortedTroves.sol";
import "./ITroveManager.sol";
import "./IWETH.sol";

// Common interface for the Borrower Operations.
interface IBorrowerOperations is ILiquityBase, IAddRemoveManagers {
    function CCR() external view returns (uint256);
    function MCR() external view returns (uint256);
    function SCR() external view returns (uint256);

    function openTrove(
        address _owner,
        uint256 _ownerIndex,
        uint256 _ETHAmount,
        uint256 _boldAmount,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _annualInterestRate,
        uint256 _maxUpfrontFee,
        address _addManager,
        address _removeManager,
        address _receiver
    ) external returns (uint256);

    struct OpenTroveAndJoinInterestBatchManagerParams {
        address owner;
        uint256 ownerIndex;
        uint256 collAmount;
        uint256 boldAmount;
        uint256 upperHint;
        uint256 lowerHint;
        address interestBatchManager;
        uint256 maxUpfrontFee;
        address addManager;
        address removeManager;
        address receiver;
    }

    function openTroveAndJoinInterestBatchManager(OpenTroveAndJoinInterestBatchManagerParams calldata _params)
        external
        returns (uint256);

    function addColl(uint256 _troveId, uint256 _ETHAmount) external;

    function withdrawColl(uint256 _troveId, uint256 _amount) external;

    function withdrawBold(uint256 _troveId, uint256 _amount, uint256 _maxUpfrontFee) external;

    function repayBold(uint256 _troveId, uint256 _amount) external;

    function closeTrove(uint256 _troveId) external;

    function adjustTrove(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _debtChange,
        bool isDebtIncrease,
        uint256 _maxUpfrontFee
    ) external;

    function adjustZombieTrove(
        uint256 _troveId,
        uint256 _collChange,
        bool _isCollIncrease,
        uint256 _boldChange,
        bool _isDebtIncrease,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external;

    function adjustTroveInterestRate(
        uint256 _troveId,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external;

    function applyPendingDebt(uint256 _troveId, uint256 _lowerHint, uint256 _upperHint) external;

    function onLiquidateTrove(uint256 _troveId) external;

    function claimCollateral() external;

    function hasBeenShutDown() external view returns (bool);
    function shutdown() external;
    function shutdownFromOracleFailure() external;

    function checkBatchManagerExists(address _batchMananger) external view returns (bool);

    // -- individual delegation --
    struct InterestIndividualDelegate {
        address account;
        uint128 minInterestRate;
        uint128 maxInterestRate;
        uint256 minInterestRateChangePeriod;
    }

    function getInterestIndividualDelegateOf(uint256 _troveId)
        external
        view
        returns (InterestIndividualDelegate memory);
    function setInterestIndividualDelegate(
        uint256 _troveId,
        address _delegate,
        uint128 _minInterestRate,
        uint128 _maxInterestRate,
        // only needed if trove was previously in a batch:
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee,
        uint256 _minInterestRateChangePeriod
    ) external;
    function removeInterestIndividualDelegate(uint256 _troveId) external;

    // -- batches --
    struct InterestBatchManager {
        uint128 minInterestRate;
        uint128 maxInterestRate;
        uint256 minInterestRateChangePeriod;
    }

    function registerBatchManager(
        uint128 minInterestRate,
        uint128 maxInterestRate,
        uint128 currentInterestRate,
        uint128 fee,
        uint128 minInterestRateChangePeriod
    ) external;
    function lowerBatchManagementFee(uint256 _newAnnualFee) external;
    function setBatchManagerAnnualInterestRate(
        uint128 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external;
    function interestBatchManagerOf(uint256 _troveId) external view returns (address);
    function getInterestBatchManager(address _account) external view returns (InterestBatchManager memory);
    function setInterestBatchManager(
        uint256 _troveId,
        address _newBatchManager,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external;
    function removeFromBatch(
        uint256 _troveId,
        uint256 _newAnnualInterestRate,
        uint256 _upperHint,
        uint256 _lowerHint,
        uint256 _maxUpfrontFee
    ) external;
    function switchBatchManager(
        uint256 _troveId,
        uint256 _removeUpperHint,
        uint256 _removeLowerHint,
        address _newBatchManager,
        uint256 _addUpperHint,
        uint256 _addLowerHint,
        uint256 _maxUpfrontFee
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICollSurplusPool {
    function getCollBalance() external view returns (uint256);

    function getCollateral(address _account) external view returns (uint256);

    function accountSurplus(address _account, uint256 _amount) external;

    function claimColl(address _account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IBoldToken.sol";
import "./ITroveManager.sol";

interface ICollateralRegistry {
    function baseRate() external view returns (uint256);
    function lastFeeOperationTime() external view returns (uint256);

    function redeemCollateral(uint256 _boldamount, uint256 _maxIterations, uint256 _maxFeePercentage) external;
    // getters
    function totalCollaterals() external view returns (uint256);
    function getToken(uint256 _index) external view returns (IERC20Metadata);
    function getTroveManager(uint256 _index) external view returns (ITroveManager);
    function boldToken() external view returns (IBoldToken);

    function getRedemptionRate() external view returns (uint256);
    function getRedemptionRateWithDecay() external view returns (uint256);
    function getRedemptionRateForRedeemedAmount(uint256 _redeemAmount) external view returns (uint256);

    function getRedemptionFeeWithDecay(uint256 _ETHDrawn) external view returns (uint256);
    function getEffectiveRedemptionFeeInBold(uint256 _redeemAmount) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDefaultPool {
    function troveManagerAddress() external view returns (address);
    function activePoolAddress() external view returns (address);
    // --- Functions ---
    function getCollBalance() external view returns (uint256);
    function getBoldDebt() external view returns (uint256);
    function sendCollToActivePool(uint256 _amount) external;
    function receiveColl(uint256 _amount) external;

    function increaseBoldDebt(uint256 _amount) external;
    function decreaseBoldDebt(uint256 _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IHintHelpers {
    function getApproxHint(uint256 _collIndex, uint256 _interestRate, uint256 _numTrials, uint256 _inputRandomSeed)
        external
        view
        returns (uint256 hintId, uint256 diff, uint256 latestRandomSeed);

    function predictOpenTroveUpfrontFee(uint256 _collIndex, uint256 _borrowedAmount, uint256 _interestRate)
        external
        view
        returns (uint256);

    function predictAdjustInterestRateUpfrontFee(uint256 _collIndex, uint256 _troveId, uint256 _newInterestRate)
        external
        view
        returns (uint256);

    function forcePredictAdjustInterestRateUpfrontFee(uint256 _collIndex, uint256 _troveId, uint256 _newInterestRate)
        external
        view
        returns (uint256);

    function predictAdjustTroveUpfrontFee(uint256 _collIndex, uint256 _troveId, uint256 _debtIncrease)
        external
        view
        returns (uint256);

    function predictAdjustBatchInterestRateUpfrontFee(
        uint256 _collIndex,
        address _batchAddress,
        uint256 _newInterestRate
    ) external view returns (uint256);

    function predictJoinBatchInterestRateUpfrontFee(uint256 _collIndex, uint256 _troveId, address _batchAddress)
        external
        view
        returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IInterestRouter {
// Currently the Interest Router doesn’t need any specific function
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IActivePool.sol";
import "./IDefaultPool.sol";
import "./IPriceFeed.sol";

interface ILiquityBase {
    function activePool() external view returns (IActivePool);
    function getEntireSystemDebt() external view returns (uint256);
    function getEntireSystemColl() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMultiTroveGetter {
    struct CombinedTroveData {
        uint256 id;
        uint256 debt;
        uint256 coll;
        uint256 stake;
        uint256 annualInterestRate;
        uint256 lastDebtUpdateTime;
        uint256 lastInterestRateAdjTime;
        address interestBatchManager;
        uint256 batchDebtShares;
        uint256 batchCollShares;
        uint256 snapshotETH;
        uint256 snapshotBoldDebt;
    }

    struct DebtPerInterestRate {
        address interestBatchManager;
        uint256 interestRate;
        uint256 debt;
    }

    function getMultipleSortedTroves(uint256 _collIndex, int256 _startIdx, uint256 _count)
        external
        view
        returns (CombinedTroveData[] memory _troves);

    function getDebtPerInterestRateAscending(uint256 _collIndex, uint256 _startId, uint256 _maxIterations)
        external
        view
        returns (DebtPerInterestRate[] memory, uint256 currId);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPriceFeed {
    function fetchPrice() external returns (uint256, bool);
    function fetchRedemptionPrice() external returns (uint256, bool);
    function lastGoodPrice() external view returns (uint256);
    function setAddresses(address _borrowerOperationsAddress) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ITroveManager.sol";
import {BatchId, BATCH_ID_ZERO} from "../Types/BatchId.sol";

interface ISortedTroves {
    // -- Mutating functions (permissioned) --
    function insert(uint256 _id, uint256 _annualInterestRate, uint256 _prevId, uint256 _nextId) external;
    function insertIntoBatch(
        uint256 _troveId,
        BatchId _batchId,
        uint256 _annualInterestRate,
        uint256 _prevId,
        uint256 _nextId
    ) external;

    function remove(uint256 _id) external;
    function removeFromBatch(uint256 _id) external;

    function reInsert(uint256 _id, uint256 _newAnnualInterestRate, uint256 _prevId, uint256 _nextId) external;
    function reInsertBatch(BatchId _id, uint256 _newAnnualInterestRate, uint256 _prevId, uint256 _nextId) external;

    // -- View functions --

    function contains(uint256 _id) external view returns (bool);
    function isBatchedNode(uint256 _id) external view returns (bool);
    function isEmptyBatch(BatchId _id) external view returns (bool);

    function isEmpty() external view returns (bool);
    function getSize() external view returns (uint256);

    function getFirst() external view returns (uint256);
    function getLast() external view returns (uint256);
    function getNext(uint256 _id) external view returns (uint256);
    function getPrev(uint256 _id) external view returns (uint256);

    function validInsertPosition(uint256 _annualInterestRate, uint256 _prevId, uint256 _nextId)
        external
        view
        returns (bool);
    function findInsertPosition(uint256 _annualInterestRate, uint256 _prevId, uint256 _nextId)
        external
        view
        returns (uint256, uint256);

    // Public state variable getters
    function borrowerOperationsAddress() external view returns (address);
    function troveManager() external view returns (ITroveManager);
    function size() external view returns (uint256);
    function nodes(uint256 _id) external view returns (uint256 nextId, uint256 prevId, BatchId batchId, bool exists);
    function batches(BatchId _id) external view returns (uint256 head, uint256 tail);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IActivePool.sol";
import "./ILiquityBase.sol";
import "./IBoldToken.sol";
import "./ITroveManager.sol";
import "./IBoldRewardsReceiver.sol";

/*
 * The Stability Pool holds Bold tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its Bold debt gets offset with
 * Bold in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of Bold tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a Bold loss, in proportion to their deposit as a share of total deposits.
 * They also receive an Coll gain, as the collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total Bold in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / Coll gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
*/
interface IStabilityPool is ILiquityBase, IBoldRewardsReceiver {
    function boldToken() external view returns (IBoldToken);
    function troveManager() external view returns (ITroveManager);

    /*  provideToSP():
    * - Calculates depositor's Coll gain
    * - Calculates the compounded deposit
    * - Increases deposit, and takes new snapshots of accumulators P and S
    * - Sends depositor's accumulated Coll gains to depositor
    */
    function provideToSP(uint256 _amount, bool _doClaim) external;

    /*  withdrawFromSP():
    * - Calculates depositor's Coll gain
    * - Calculates the compounded deposit
    * - Sends the requested BOLD withdrawal to depositor
    * - (If _amount > userDeposit, the user withdraws all of their compounded deposit)
    * - Decreases deposit by withdrawn amount and takes new snapshots of accumulators P and S
    */
    function withdrawFromSP(uint256 _amount, bool doClaim) external;

    function claimAllCollGains() external;

    /*
     * Initial checks:
     * - Caller is TroveManager
     * ---
     * Cancels out the specified debt against the Bold contained in the Stability Pool (as far as possible)
     * and transfers the Trove's collateral from ActivePool to StabilityPool.
     * Only called by liquidation functions in the TroveManager.
     */
    function offset(uint256 _debt, uint256 _coll) external;

    function deposits(address _depositor) external view returns (uint256 initialValue);
    function stashedColl(address _depositor) external view returns (uint256);

    /*
     * Returns the total amount of Coll held by the pool, accounted in an internal variable instead of `balance`,
     * to exclude edge cases like Coll received from a self-destruct.
     */
    function getCollBalance() external view returns (uint256);

    /*
     * Returns Bold held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
     */
    function getTotalBoldDeposits() external view returns (uint256);

    function getYieldGainsOwed() external view returns (uint256);
    function getYieldGainsPending() external view returns (uint256);

    /*
     * Calculates the Coll gain earned by the deposit since its last snapshots were taken.
     */
    function getDepositorCollGain(address _depositor) external view returns (uint256);

    /*
     * Calculates the BOLD yield gain earned by the deposit since its last snapshots were taken.
     */
    function getDepositorYieldGain(address _depositor) external view returns (uint256);

    /*
     * Calculates what `getDepositorYieldGain` will be if interest is minted now.
     */
    function getDepositorYieldGainWithPending(address _depositor) external view returns (uint256);

    /*
     * Return the user's compounded deposit.
     */
    function getCompoundedBoldDeposit(address _depositor) external view returns (uint256);

    function epochToScaleToS(uint128 _epoch, uint128 _scale) external view returns (uint256);

    function epochToScaleToB(uint128 _epoch, uint128 _scale) external view returns (uint256);

    function P() external view returns (uint256);
    function currentScale() external view returns (uint128);
    function currentEpoch() external view returns (uint128);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStabilityPoolEvents {
    enum Operation {
        provideToSP,
        withdrawFromSP,
        claimAllCollGains
    }

    event StabilityPoolCollBalanceUpdated(uint256 _newBalance);
    event StabilityPoolBoldBalanceUpdated(uint256 _newBalance);

    event P_Updated(uint256 _P);
    event S_Updated(uint256 _S, uint128 _epoch, uint128 _scale);
    event B_Updated(uint256 _B, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event DepositUpdated(
        address indexed _depositor,
        uint256 _newDeposit,
        uint256 _stashedColl,
        uint256 _snapshotP,
        uint256 _snapshotS,
        uint256 _snapshotB,
        uint256 _snapshotScale,
        uint256 _snapshotEpoch
    );

    event DepositOperation(
        address indexed _depositor,
        Operation _operation,
        uint256 _depositLossSinceLastOperation,
        int256 _depositChange,
        uint256 _yieldGainSinceLastOperation,
        uint256 _yieldGainClaimed,
        uint256 _ethGainSinceLastOperation,
        uint256 _ethGainClaimed
    );
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ILiquityBase.sol";
import "./ITroveNFT.sol";
import "./IBorrowerOperations.sol";
import "./IStabilityPool.sol";
import "./IBoldToken.sol";
import "./ISortedTroves.sol";
import "../Types/LatestTroveData.sol";
import "../Types/LatestBatchData.sol";

// Common interface for the Trove Manager.
interface ITroveManager is ILiquityBase {
    enum Status {
        nonExistent,
        active,
        closedByOwner,
        closedByLiquidation,
        zombie
    }

    function shutdownTime() external view returns (uint256);

    function troveNFT() external view returns (ITroveNFT);
    function stabilityPool() external view returns (IStabilityPool);
    //function boldToken() external view returns (IBoldToken);
    function sortedTroves() external view returns (ISortedTroves);
    function borrowerOperations() external view returns (IBorrowerOperations);

    function Troves(uint256 _id)
        external
        view
        returns (
            uint256 debt,
            uint256 coll,
            uint256 stake,
            Status status,
            uint64 arrayIndex,
            uint64 lastDebtUpdateTime,
            uint64 lastInterestRateAdjTime,
            uint256 annualInterestRate,
            address interestBatchManager,
            uint256 batchDebtShares
        );

    function rewardSnapshots(uint256 _id) external view returns (uint256 coll, uint256 boldDebt);

    function getTroveIdsCount() external view returns (uint256);

    function getTroveFromTroveIdsArray(uint256 _index) external view returns (uint256);

    function getCurrentICR(uint256 _troveId, uint256 _price) external view returns (uint256);

    function lastZombieTroveId() external view returns (uint256);

    function batchLiquidateTroves(uint256[] calldata _troveArray) external;

    function redeemCollateral(
        address _sender,
        uint256 _boldAmount,
        uint256 _price,
        uint256 _redemptionRate,
        uint256 _maxIterations
    ) external returns (uint256 _redemeedAmount);

    function shutdown() external;
    function urgentRedemption(uint256 _boldAmount, uint256[] calldata _troveIds, uint256 _minCollateral) external;

    function getUnbackedPortionPriceAndRedeemability() external returns (uint256, uint256, bool);

    function getLatestTroveData(uint256 _troveId) external view returns (LatestTroveData memory);
    function getTroveAnnualInterestRate(uint256 _troveId) external view returns (uint256);

    function getTroveStatus(uint256 _troveId) external view returns (Status);

    function getLatestBatchData(address _batchAddress) external view returns (LatestBatchData memory);

    // -- permissioned functions called by BorrowerOperations

    function onOpenTrove(address _owner, uint256 _troveId, TroveChange memory _troveChange, uint256 _annualInterestRate)
        external;
    function onOpenTroveAndJoinBatch(
        address _owner,
        uint256 _troveId,
        TroveChange memory _troveChange,
        address _batchAddress,
        uint256 _batchColl,
        uint256 _batchDebt
    ) external;

    // Called from `adjustZombieTrove()`
    function setTroveStatusToActive(uint256 _troveId) external;

    function onAdjustTroveInterestRate(
        uint256 _troveId,
        uint256 _newColl,
        uint256 _newDebt,
        uint256 _newAnnualInterestRate,
        TroveChange calldata _troveChange
    ) external;

    function onAdjustTrove(uint256 _troveId, uint256 _newColl, uint256 _newDebt, TroveChange calldata _troveChange)
        external;

    function onAdjustTroveInsideBatch(
        uint256 _troveId,
        uint256 _newTroveColl,
        uint256 _newTroveDebt,
        TroveChange memory _troveChange,
        address _batchAddress,
        uint256 _newBatchColl,
        uint256 _newBatchDebt
    ) external;

    function onApplyTroveInterest(
        uint256 _troveId,
        uint256 _newTroveColl,
        uint256 _newTroveDebt,
        address _batchAddress,
        uint256 _newBatchColl,
        uint256 _newBatchDebt,
        TroveChange calldata _troveChange
    ) external;

    function onCloseTrove(
        uint256 _troveId,
        TroveChange memory _troveChange, // decrease vars: entire, with interest, batch fee and redistribution
        address _batchAddress,
        uint256 _newBatchColl,
        uint256 _newBatchDebt // entire, with interest and batch fee
    ) external;

    // -- batches --
    function onRegisterBatchManager(address _batchAddress, uint256 _annualInterestRate, uint256 _annualFee) external;
    function onLowerBatchManagerAnnualFee(
        address _batchAddress,
        uint256 _newColl,
        uint256 _newDebt,
        uint256 _newAnnualManagementFee
    ) external;
    function onSetBatchManagerAnnualInterestRate(
        address _batchAddress,
        uint256 _newColl,
        uint256 _newDebt,
        uint256 _newAnnualInterestRate,
        uint256 _upfrontFee // needed by BatchUpdated event
    ) external;

    struct OnSetInterestBatchManagerParams {
        uint256 troveId;
        uint256 troveColl; // entire, with redistribution
        uint256 troveDebt; // entire, with interest, batch fee and redistribution
        TroveChange troveChange;
        address newBatchAddress;
        uint256 newBatchColl; // updated collateral for new batch manager
        uint256 newBatchDebt; // updated debt for new batch manager
    }

    function onSetInterestBatchManager(OnSetInterestBatchManagerParams calldata _params) external;
    function onRemoveFromBatch(
        uint256 _troveId,
        uint256 _newTroveColl, // entire, with redistribution
        uint256 _newTroveDebt, // entire, with interest, batch fee and redistribution
        TroveChange memory _troveChange,
        address _batchAddress,
        uint256 _newBatchColl,
        uint256 _newBatchDebt, // entire, with interest and batch fee
        uint256 _newAnnualInterestRate
    ) external;

    // -- end of permissioned functions --
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "./ITroveManager.sol";

interface ITroveNFT is IERC721Metadata {
    function mint(address _owner, uint256 _troveId) external;
    function burn(uint256 _troveId) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IWETH is IERC20Metadata {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/Solady/src/utils/SSTORE2.sol";
import "./utils/JSON.sol";

import "./utils/baseSVG.sol";
import "./utils/bauhaus.sol";

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {ITroveManager} from "src/Interfaces/ITroveManager.sol";

interface IMetadataNFT {
    struct TroveData {
        uint256 _tokenId;
        address _owner;
        address _collToken;
        address _boldToken;
        uint256 _collAmount;
        uint256 _debtAmount;
        uint256 _interestRate;
        ITroveManager.Status _status;
    }

    function uri(TroveData memory _troveData) external view returns (string memory);
}

contract MetadataNFT is IMetadataNFT {
    FixedAssetReader public immutable assetReader;

    string public constant name = "Liquity V2 Trove";
    string public constant description = "Liquity V2 Trove position";

    constructor(FixedAssetReader _assetReader) {
        assetReader = _assetReader;
    }

    function uri(TroveData memory _troveData) public view returns (string memory) {
        string memory attr = attributes(_troveData);
        return json.formattedMetadata(name, description, renderSVGImage(_troveData), attr);
    }

    function renderSVGImage(TroveData memory _troveData) internal view returns (string memory) {
        return svg._svg(
            baseSVG._svgProps(),
            string.concat(
                baseSVG._baseElements(assetReader),
                bauhaus._bauhaus(IERC20Metadata(_troveData._collToken).symbol(), _troveData._tokenId),
                dynamicTextComponents(_troveData)
            )
        );
    }

    function attributes(TroveData memory _troveData) public pure returns (string memory) {
        //include: collateral token address, collateral amount, debt token address, debt amount, interest rate, status
        return string.concat(
            '[{"trait_type": "Collateral Token", "value": "',
            LibString.toHexString(_troveData._collToken),
            '"}, {"trait_type": "Collateral Amount", "value": "',
            LibString.toString(_troveData._collAmount),
            '"}, {"trait_type": "Debt Token", "value": "',
            LibString.toHexString(_troveData._boldToken),
            '"}, {"trait_type": "Debt Amount", "value": "',
            LibString.toString(_troveData._debtAmount),
            '"}, {"trait_type": "Interest Rate", "value": "',
            LibString.toString(_troveData._interestRate),
            '"}, {"trait_type": "Status", "value": "',
            _status2Str(_troveData._status),
            '"} ]'
        );
    }

    function dynamicTextComponents(TroveData memory _troveData) public view returns (string memory) {
        string memory id = LibString.toHexString(_troveData._tokenId);
        id = string.concat(LibString.slice(id, 0, 6), "...", LibString.slice(id, 38, 42));

        return string.concat(
            baseSVG._formattedIdEl(id),
            baseSVG._formattedAddressEl(_troveData._owner),
            baseSVG._collLogo(IERC20Metadata(_troveData._collToken).symbol(), assetReader),
            baseSVG._statusEl(_status2Str(_troveData._status)),
            baseSVG._dynamicTextEls(_troveData._debtAmount, _troveData._collAmount, _troveData._interestRate)
        );
    }

    function _status2Str(ITroveManager.Status status) internal pure returns (string memory) {
        if (status == ITroveManager.Status.active) return "Active";
        if (status == ITroveManager.Status.closedByOwner) return "Closed";
        if (status == ITroveManager.Status.closedByLiquidation) return "Liquidated";
        if (status == ITroveManager.Status.zombie) return "Below Min Debt";
        return "";
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/Solady/src/utils/SSTORE2.sol";

contract FixedAssetReader {
    struct Asset {
        uint128 start;
        uint128 end;
    }

    address public immutable pointer;

    mapping(bytes4 => Asset) public assets;

    function readAsset(bytes4 _sig) public view returns (string memory) {
        return string(SSTORE2.read(pointer, uint256(assets[_sig].start), uint256(assets[_sig].end)));
    }

    constructor(address _pointer, bytes4[] memory _sigs, Asset[] memory _assets) {
        pointer = _pointer;
        require(_sigs.length == _assets.length, "FixedAssetReader: Invalid input");
        for (uint256 i = 0; i < _sigs.length; i++) {
            assets[_sigs[i]] = _assets[i];
        }
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// JSON utilities for base64 encoded ERC721 JSON metadata scheme
library json {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// @dev JSON requires that double quotes be escaped or JSONs will not build correctly
    /// string.concat also requires an escape, use \\" or the constant DOUBLE_QUOTES to represent " in JSON
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    string constant DOUBLE_QUOTES = '\\"';

    function formattedMetadata(
        string memory name,
        string memory description,
        string memory svgImg,
        string memory attributes
    ) internal pure returns (string memory) {
        return string.concat(
            "data:application/json;base64,",
            encode(
                bytes(
                    string.concat(
                        "{",
                        _prop("name", name),
                        _prop("description", description),
                        _xmlImage(svgImg),
                        ',"attributes":',
                        attributes,
                        "}"
                    )
                )
            )
        );
    }

    function _xmlImage(string memory _svgImg) internal pure returns (string memory) {
        return _prop("image", string.concat("data:image/svg+xml;base64,", encode(bytes(_svgImg))), true);
    }

    function _prop(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat('"', _key, '": ', '"', _val, '", ');
    }

    function _prop(string memory _key, string memory _val, bool last) internal pure returns (string memory) {
        if (last) {
            return string.concat('"', _key, '": ', '"', _val, '"');
        } else {
            return string.concat('"', _key, '": ', '"', _val, '", ');
        }
    }

    function _object(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat('"', _key, '": ', "{", _val, "}");
    }

    /**
     * taken from Openzeppelin
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {} {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 { mstore8(sub(resultPtr, 1), 0x3d) }
        }

        return result;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {utils, LibString} from "./Utils.sol";

/// @notice Core SVG utility library which helps us construct onchain SVG's with a simple, web-like API.
/// @author Modified from (https://github.com/w1nt3r-eth/hot-chain-svg/blob/main/contracts/SVG.sol) by w1nt3r-eth.

library svg {
    /* GLOBAL CONSTANTS */
    string internal constant _SVG = 'xmlns="http://www.w3.org/2000/svg"';
    string internal constant _HTML = 'xmlns="http://www.w3.org/1999/xhtml"';
    string internal constant _XMLNS = "http://www.w3.org/2000/xmlns/ ";
    string internal constant _XLINK = "http://www.w3.org/1999/xlink ";

    /* MAIN ELEMENTS */
    function g(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("g", _props, _children);
    }

    function _svg(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("svg", string.concat(_SVG, " ", _props), _children);
    }

    function style(string memory _title, string memory _props) internal pure returns (string memory) {
        return el("style", string.concat(".", _title, " ", _props));
    }

    function path(string memory _d) internal pure returns (string memory) {
        return el("path", prop("d", _d, true));
    }

    function path(string memory _d, string memory _props) internal pure returns (string memory) {
        return el("path", string.concat(prop("d", _d), _props));
    }

    function path(string memory _d, string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("path", string.concat(prop("d", _d), _props), _children);
    }

    function text(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("text", _props, _children);
    }

    function line(string memory _props) internal pure returns (string memory) {
        return el("line", _props);
    }

    function line(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("line", _props, _children);
    }

    function circle(string memory _props) internal pure returns (string memory) {
        return el("circle", _props);
    }

    function circle(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("circle", _props, _children);
    }

    function circle(string memory cx, string memory cy, string memory r) internal pure returns (string memory) {
        return el("circle", string.concat(prop("cx", cx), prop("cy", cy), prop("r", r, true)));
    }

    function circle(string memory cx, string memory cy, string memory r, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("circle", string.concat(prop("cx", cx), prop("cy", cy), prop("r", r, true)), _children);
    }

    function circle(string memory cx, string memory cy, string memory r, string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("circle", string.concat(prop("cx", cx), prop("cy", cy), prop("r", r), _props), _children);
    }

    function ellipse(string memory _props) internal pure returns (string memory) {
        return el("ellipse", _props);
    }

    function ellipse(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("ellipse", _props, _children);
    }

    function polygon(string memory _props) internal pure returns (string memory) {
        return el("polygon", _props);
    }

    function polygon(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("polygon", _props, _children);
    }

    function polyline(string memory _props) internal pure returns (string memory) {
        return el("polyline", _props);
    }

    function polyline(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("polyline", _props, _children);
    }

    function rect(string memory _props) internal pure returns (string memory) {
        return el("rect", _props);
    }

    function rect(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("rect", _props, _children);
    }

    function filter(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("filter", _props, _children);
    }

    function cdata(string memory _content) internal pure returns (string memory) {
        return string.concat("<![CDATA[", _content, "]]>");
    }

    /* GRADIENTS */
    function radialGradient(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("radialGradient", _props, _children);
    }

    function linearGradient(string memory _props, string memory _children) internal pure returns (string memory) {
        return el("linearGradient", _props, _children);
    }

    function gradientStop(uint256 offset, string memory stopColor, string memory _props)
        internal
        pure
        returns (string memory)
    {
        return el(
            "stop",
            string.concat(
                prop("stop-color", stopColor),
                " ",
                prop("offset", string.concat(LibString.toString(offset), "%")),
                " ",
                _props
            ),
            utils.NULL
        );
    }

    /* ANIMATION */
    function animateTransform(string memory _props) internal pure returns (string memory) {
        return el("animateTransform", _props);
    }

    function animate(string memory _props) internal pure returns (string memory) {
        return el("animate", _props);
    }

    /* COMMON */
    // A generic element, can be used to construct any SVG (or HTML) element
    function el(string memory _tag, string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return string.concat("<", _tag, " ", _props, ">", _children, "</", _tag, ">");
    }

    // A generic element, can be used to construct SVG (or HTML) elements without children
    function el(string memory _tag, string memory _props) internal pure returns (string memory) {
        return string.concat("<", _tag, " ", _props, "/>");
    }

    // an SVG attribute
    function prop(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat(_key, "=", '"', _val, '" ');
    }

    function prop(string memory _key, string memory _val, bool last) internal pure returns (string memory) {
        if (last) {
            return string.concat(_key, "=", '"', _val, '"');
        } else {
            return string.concat(_key, "=", '"', _val, '" ');
        }
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "lib/Solady/src/utils/LibString.sol";

library numUtils {
    function toLocale(string memory _wholeNumber) internal pure returns (string memory) {
        bytes memory b = bytes(_wholeNumber);
        uint256 len = b.length;
        if (len < 4) return _wholeNumber;

        uint256 numCommas = (len - 1) / 3;

        bytes memory result = new bytes(len + numCommas);

        uint256 j = result.length - 1;
        uint256 k = len;
        for (uint256 i = 0; i < len; i++) {
            result[j] = b[k - 1];
            j = j > 1 ? j - 1 : 0;
            k--;
            if (k > 0 && (len - k) % 3 == 0) {
                result[j] = ",";
                j = j > 1 ? j - 1 : 0;
            }
        }

        return string(result);
    }

    // returns a string representation of a number with commas, where result = _value / 10 ** _divisor
    function toLocaleString(uint256 _value, uint8 _divisor, uint8 _precision) internal pure returns (string memory) {
        uint256 whole;
        uint256 fraction;

        if (_divisor > 0) {
            whole = _value / 10 ** _divisor;
            // check if the divisor is less than the precision
            if (_divisor <= _precision) {
                fraction = (_value % 10 ** _divisor);
                // adjust fraction to be the same as the precision
                fraction = fraction * 10 ** (_precision - _divisor);

                // if whole is zero, then add another zero to the fraction, special case if the value is 1
                fraction = (whole == 0 && _value != 1) ? fraction * 10 : fraction;
            } else {
                fraction = (_value % 10 ** _divisor) / 10 ** (_divisor - _precision - 1);
            }
        } else {
            whole = _value;
        }

        string memory wholeStr = toLocale(LibString.toString(whole));

        if (fraction == 0) {
            if (whole > 0 && _precision > 0) wholeStr = string.concat(wholeStr, ".");
            for (uint8 i = 0; i < _precision; i++) {
                wholeStr = string.concat(wholeStr, "0");
            }

            return wholeStr;
        }

        string memory fractionStr = LibString.slice(LibString.toString(fraction), 0, _precision);

        // pad with leading zeros
        if (_precision > bytes(fractionStr).length) {
            uint256 len = _precision - bytes(fractionStr).length;
            string memory zeroStr = "";

            for (uint8 i = 0; i < len; i++) {
                zeroStr = string.concat(zeroStr, "0");
            }

            fractionStr = string.concat(zeroStr, fractionStr);
        }

        return string.concat(wholeStr, _precision > 0 ? "." : "", fractionStr);
    }
}

/// @notice Core utils used extensively to format CSS and numbers.
/// @author Modified from (https://github.com/w1nt3r-eth/hot-chain-svg/blob/main/contracts/Utils.sol) by w1nt3r-eth.

library utils {
    // used to simulate empty strings
    string internal constant NULL = "";

    // formats a CSS variable line. includes a semicolon for formatting.
    function setCssVar(string memory _key, string memory _val) internal pure returns (string memory) {
        return string.concat("--", _key, ":", _val, ";");
    }

    // formats getting a css variable
    function getCssVar(string memory _key) internal pure returns (string memory) {
        return string.concat("var(--", _key, ")");
    }

    // formats getting a def URL
    function getDefURL(string memory _id) internal pure returns (string memory) {
        return string.concat("url(#", _id, ")");
    }

    // formats rgba white with a specified opacity / alpha
    function white_a(uint256 _a) internal pure returns (string memory) {
        return rgba(255, 255, 255, _a);
    }

    // formats rgba black with a specified opacity / alpha
    function black_a(uint256 _a) internal pure returns (string memory) {
        return rgba(0, 0, 0, _a);
    }

    // formats generic rgba color in css
    function rgba(uint256 _r, uint256 _g, uint256 _b, uint256 _a) internal pure returns (string memory) {
        string memory formattedA = _a < 100 ? string.concat("0.", LibString.toString(_a)) : "1";
        return string.concat(
            "rgba(",
            LibString.toString(_r),
            ",",
            LibString.toString(_g),
            ",",
            LibString.toString(_b),
            ",",
            formattedA,
            ")"
        );
    }

    function cssBraces(string memory _attribute, string memory _value) internal pure returns (string memory) {
        return string.concat(" {", _attribute, ": ", _value, "}");
    }

    function cssBraces(string[] memory _attributes, string[] memory _values) internal pure returns (string memory) {
        require(_attributes.length == _values.length, "Utils: Unbalanced Arrays");

        uint256 len = _attributes.length;

        string memory results = " {";

        for (uint256 i = 0; i < len; i++) {
            results = string.concat(results, _attributes[i], ": ", _values[i], "; ");
        }

        return string.concat(results, "}");
    }

    //deals with integers (i.e. no decimals)
    function points(uint256[2][] memory pointsArray) internal pure returns (string memory) {
        require(pointsArray.length >= 3, "Utils: Array too short");

        uint256 len = pointsArray.length - 1;

        string memory results = 'points="';

        for (uint256 i = 0; i < len; i++) {
            results = string.concat(
                results, LibString.toString(pointsArray[i][0]), ",", LibString.toString(pointsArray[i][1]), " "
            );
        }

        return string.concat(
            results, LibString.toString(pointsArray[len][0]), ",", LibString.toString(pointsArray[len][1]), '"'
        );
    }

    // allows for a uniform precision to be applied to all points
    function points(uint256[2][] memory pointsArray, uint256 decimalPrecision) internal pure returns (string memory) {
        require(pointsArray.length >= 3, "Utils: Array too short");

        uint256 len = pointsArray.length - 1;

        string memory results = 'points="';

        for (uint256 i = 0; i < len; i++) {
            results = string.concat(
                results,
                toString(pointsArray[i][0], decimalPrecision),
                ",",
                toString(pointsArray[i][1], decimalPrecision),
                " "
            );
        }

        return string.concat(
            results,
            toString(pointsArray[len][0], decimalPrecision),
            ",",
            toString(pointsArray[len][1], decimalPrecision),
            '"'
        );
    }

    // checks if two strings are equal
    function stringsEqual(string memory _a, string memory _b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    // returns the length of a string in characters
    function utfStringLength(string memory _str) internal pure returns (uint256 length) {
        uint256 i = 0;
        bytes memory string_rep = bytes(_str);

        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) {
                i += 1;
            } else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) {
                i += 2;
            } else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) {
                i += 3;
            } else if (string_rep[i] >> 3 == bytes1(uint8(0x1E))) {
                i += 4;
            }
            //For safety
            else {
                i += 1;
            }

            length++;
        }
    }

    // allows the insertion of a decimal point in the returned string at precision
    function toString(uint256 value, uint256 precision) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        require(precision <= digits && precision > 0, "Utils: precision invalid");
        precision == digits ? digits += 2 : digits++; //adds a space for the decimal point, 2 if it is the whole uint

        uint256 decimalPlacement = digits - precision - 1;
        bytes memory buffer = new bytes(digits);

        buffer[decimalPlacement] = 0x2E; // add the decimal point, ASCII 46/hex 2E
        if (decimalPlacement == 1) {
            buffer[0] = 0x30;
        }

        while (value != 0) {
            digits -= 1;
            if (digits != decimalPlacement) {
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
        }

        return string(buffer);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {svg} from "./SVG.sol";
import {utils, LibString, numUtils} from "./Utils.sol";
import "./FixedAssets.sol";

library baseSVG {
    string constant GEIST = 'style="font-family: Geist" ';
    string constant DARK_BLUE = "#121B44";
    string constant STOIC_WHITE = "#DEE4FB";

    function _svgProps() internal pure returns (string memory) {
        return string.concat(
            svg.prop("width", "300"),
            svg.prop("height", "484"),
            svg.prop("viewBox", "0 0 300 484"),
            svg.prop("style", "background:none")
        );
    }

    function _baseElements(FixedAssetReader _assetReader) internal view returns (string memory) {
        return string.concat(
            svg.rect(
                string.concat(
                    svg.prop("fill", DARK_BLUE),
                    svg.prop("rx", "8"),
                    svg.prop("width", "300"),
                    svg.prop("height", "484")
                )
            ),
            _styles(_assetReader),
            _leverageLogo(),
            _boldLogo(_assetReader),
            _staticTextEls()
        );
    }

    function _styles(FixedAssetReader _assetReader) private view returns (string memory) {
        return svg.el(
            "style",
            utils.NULL,
            string.concat(
                '@font-face { font-family: "Geist"; src: url("data:font/woff2;utf-8;base64,',
                _assetReader.readAsset(bytes4(keccak256("geist"))),
                '"); }'
            )
        );
    }

    function _leverageLogo() internal pure returns (string memory) {
        return string.concat(
            svg.path(
                "M20.2 31.2C19.1 32.4 17.6 33 16 33L16 21C17.6 21 19.1 21.6 20.2 22.7C21.4 23.9 22 25.4 22 27C22 28.6 21.4 30.1 20.2 31.2Z",
                svg.prop("fill", STOIC_WHITE)
            ),
            svg.path(
                "M22 27C22 25.4 22.6 23.9 23.8 22.7C25 21.6 26.4 21 28 21V33C26.4 33 25 32.4 24 31.2C22.6 30.1 22 28.6 22 27Z",
                svg.prop("fill", STOIC_WHITE)
            )
        );
    }

    function _boldLogo(FixedAssetReader _assetReader) internal view returns (string memory) {
        return svg.el(
            "image",
            string.concat(
                svg.prop("x", "264"),
                svg.prop("y", "373.5"),
                svg.prop("width", "20"),
                svg.prop("height", "20"),
                svg.prop(
                    "href",
                    string.concat("data:image/svg+xml;base64,", _assetReader.readAsset(bytes4(keccak256("BOLD"))))
                )
            )
        );
    }

    function _staticTextEls() internal pure returns (string memory) {
        return string.concat(
            svg.text(
                string.concat(
                    GEIST,
                    svg.prop("x", "16"),
                    svg.prop("y", "358"),
                    svg.prop("font-size", "14"),
                    svg.prop("fill", "white")
                ),
                "Collateral"
            ),
            svg.text(
                string.concat(
                    GEIST,
                    svg.prop("x", "16"),
                    svg.prop("y", "389"),
                    svg.prop("font-size", "14"),
                    svg.prop("fill", "white")
                ),
                "Debt"
            ),
            svg.text(
                string.concat(
                    GEIST,
                    svg.prop("x", "16"),
                    svg.prop("y", "420"),
                    svg.prop("font-size", "14"),
                    svg.prop("fill", "white")
                ),
                "Interest Rate"
            ),
            svg.text(
                string.concat(
                    GEIST,
                    svg.prop("x", "265"),
                    svg.prop("y", "422"),
                    svg.prop("font-size", "20"),
                    svg.prop("fill", "white")
                ),
                "%"
            ),
            svg.text(
                string.concat(
                    GEIST,
                    svg.prop("x", "16"),
                    svg.prop("y", "462"),
                    svg.prop("font-size", "14"),
                    svg.prop("fill", "white")
                ),
                "Owner"
            )
        );
    }

    function _formattedDynamicEl(string memory _value, uint256 _x, uint256 _y) internal pure returns (string memory) {
        return svg.text(
            string.concat(
                GEIST,
                svg.prop("text-anchor", "end"),
                svg.prop("x", LibString.toString(_x)),
                svg.prop("y", LibString.toString(_y)),
                svg.prop("font-size", "20"),
                svg.prop("fill", "white")
            ),
            _value
        );
    }

    function _formattedIdEl(string memory _id) internal pure returns (string memory) {
        return svg.text(
            string.concat(
                GEIST,
                svg.prop("text-anchor", "end"),
                svg.prop("x", "284"),
                svg.prop("y", "33"),
                svg.prop("font-size", "14"),
                svg.prop("fill", "white")
            ),
            _id
        );
    }

    function _formattedAddressEl(address _address) internal pure returns (string memory) {
        return svg.text(
            string.concat(
                GEIST,
                svg.prop("text-anchor", "end"),
                svg.prop("x", "284"),
                svg.prop("y", "462"),
                svg.prop("font-size", "14"),
                svg.prop("fill", "white")
            ),
            string.concat(
                LibString.slice(LibString.toHexStringChecksummed(_address), 0, 6),
                "...",
                LibString.slice(LibString.toHexStringChecksummed(_address), 38, 42)
            )
        );
    }

    function _collLogo(string memory _collName, FixedAssetReader _assetReader) internal view returns (string memory) {
        return svg.el(
            "image",
            string.concat(
                svg.prop("x", "264"),
                svg.prop("y", "342.5"),
                svg.prop("width", "20"),
                svg.prop("height", "20"),
                svg.prop(
                    "href",
                    string.concat(
                        "data:image/svg+xml;base64,", _assetReader.readAsset(bytes4(keccak256(bytes(_collName))))
                    )
                )
            )
        );
    }

    function _statusEl(string memory _status) internal pure returns (string memory) {
        return svg.text(
            string.concat(
                GEIST, svg.prop("x", "40"), svg.prop("y", "33"), svg.prop("font-size", "14"), svg.prop("fill", "white")
            ),
            _status
        );
    }

    function _dynamicTextEls(uint256 _debt, uint256 _coll, uint256 _annualInterestRate)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            _formattedDynamicEl(numUtils.toLocaleString(_coll, 18, 4), 256, 360),
            _formattedDynamicEl(numUtils.toLocaleString(_debt, 18, 2), 256, 391),
            _formattedDynamicEl(numUtils.toLocaleString(_annualInterestRate, 16, 2), 256, 422)
        );
    }
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./SVG.sol";

library bauhaus {
    string constant GOLDEN = "#F5D93A";
    string constant CORAL = "#FB7C59";
    string constant GREEN = "#63D77D";
    string constant CYAN = "#95CBF3";
    string constant BLUE = "#405AE5";
    string constant DARK_BLUE = "#121B44";
    string constant BROWN = "#D99664";

    enum colorCode {
        GOLDEN,
        CORAL,
        GREEN,
        CYAN,
        BLUE,
        DARK_BLUE,
        BROWN
    }

    function _bauhaus(string memory _collName, uint256 _troveId) internal pure returns (string memory) {
        bytes32 collSig = keccak256(bytes(_collName));
        uint256 variant = _troveId % 4;

        if (collSig == keccak256("WETH")) {
            return _img1(variant);
        } else if (collSig == keccak256("wstETH")) {
            return _img2(variant);
        } else {
            // assume rETH
            return _img3(variant);
        }
    }

    function _colorCode2Hex(colorCode _color) private pure returns (string memory) {
        if (_color == colorCode.GOLDEN) {
            return GOLDEN;
        } else if (_color == colorCode.CORAL) {
            return CORAL;
        } else if (_color == colorCode.GREEN) {
            return GREEN;
        } else if (_color == colorCode.CYAN) {
            return CYAN;
        } else if (_color == colorCode.BLUE) {
            return BLUE;
        } else if (_color == colorCode.DARK_BLUE) {
            return DARK_BLUE;
        } else {
            return BROWN;
        }
    }

    struct COLORS {
        colorCode rect1;
        colorCode rect2;
        colorCode rect3;
        colorCode rect4;
        colorCode rect5;
        colorCode poly;
        colorCode circle1;
        colorCode circle2;
        colorCode circle3;
    }

    function _colors1(uint256 _variant) internal pure returns (COLORS memory) {
        if (_variant == 0) {
            return COLORS(
                colorCode.BLUE, // rect1
                colorCode.GOLDEN, // rect2
                colorCode.GOLDEN, // rect3
                colorCode.BROWN, // rect4
                colorCode.CORAL, // rect5
                colorCode.CYAN, // poly
                colorCode.GREEN, // circle1
                colorCode.DARK_BLUE, // circle2
                colorCode.GOLDEN // circle3
            );
        } else if (_variant == 1) {
            return COLORS(
                colorCode.GREEN, // rect1
                colorCode.BLUE, // rect2
                colorCode.GOLDEN, // rect3
                colorCode.BROWN, // rect4
                colorCode.GOLDEN, // rect5
                colorCode.CORAL, // poly
                colorCode.BLUE, // circle1
                colorCode.DARK_BLUE, // circle2
                colorCode.BLUE // circle3
            );
        } else if (_variant == 2) {
            return COLORS(
                colorCode.BLUE, // rect1
                colorCode.GOLDEN, // rect2
                colorCode.CYAN, // rect3
                colorCode.GOLDEN, // rect4
                colorCode.BROWN, // rect5
                colorCode.GREEN, // poly
                colorCode.CORAL, // circle1
                colorCode.DARK_BLUE, // circle2
                colorCode.BROWN // circle3
            );
        } else {
            return COLORS(
                colorCode.CYAN, // rect1
                colorCode.BLUE, // rect2
                colorCode.BLUE, // rect3
                colorCode.BROWN, // rect4
                colorCode.BLUE, // rect5
                colorCode.GREEN, // poly
                colorCode.GOLDEN, // circle1
                colorCode.DARK_BLUE, // circle2
                colorCode.BLUE // circle3
            );
        }
    }

    function _img1(uint256 _variant) internal pure returns (string memory) {
        COLORS memory colors = _colors1(_variant);
        return string.concat(_rects1(colors), _polygons1(colors), _circles1(colors));
    }

    function _rects1(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //background
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "55"),
                    svg.prop("width", "268"),
                    svg.prop("height", "268"),
                    svg.prop("fill", DARK_BLUE)
                )
            ),
            // large right rect | rect1
            svg.rect(
                string.concat(
                    svg.prop("x", "128"),
                    svg.prop("y", "55"),
                    svg.prop("width", "156"),
                    svg.prop("height", "268"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect1))
                )
            ),
            // small upper right rect | rect2
            svg.rect(
                string.concat(
                    svg.prop("x", "228"),
                    svg.prop("y", "55"),
                    svg.prop("width", "56"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect2))
                )
            ),
            // large central left rect | rect3
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "111"),
                    svg.prop("width", "134"),
                    svg.prop("height", "156"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect3))
                )
            ),
            // small lower left rect | rect4
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "267"),
                    svg.prop("width", "112"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect4))
                )
            ),
            // small lower right rect | rect5
            svg.rect(
                string.concat(
                    svg.prop("x", "228"),
                    svg.prop("y", "267"),
                    svg.prop("width", "56"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect5))
                )
            )
        );
    }

    function _polygons1(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            // left triangle | poly1
            svg.polygon(
                string.concat(svg.prop("points", "16,55 72,55 16,111"), svg.prop("fill", _colorCode2Hex(_colors.poly)))
            ),
            // right triangle | poly2
            svg.polygon(
                string.concat(svg.prop("points", "72,55 128,55 72,111"), svg.prop("fill", _colorCode2Hex(_colors.poly)))
            )
        );
    }

    function _circles1(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //large central circle | circle1
            svg.circle(
                string.concat(
                    svg.prop("cx", "150"),
                    svg.prop("cy", "189"),
                    svg.prop("r", "78"),
                    svg.prop("fill", _colorCode2Hex(_colors.circle1))
                )
            ),
            //small right circle | circle2
            svg.circle(
                string.concat(
                    svg.prop("cx", "228"),
                    svg.prop("cy", "295"),
                    svg.prop("r", "28"),
                    svg.prop("fill", _colorCode2Hex(_colors.circle2))
                )
            ),
            //small right half circle | circle3
            svg.path(
                "M228 267C220.574 267 213.452 269.95 208.201 275.201C202.95 280.452 200 287.574 200 295C200 302.426 202.95 309.548 208.201 314.799C213.452 320.05 220.574 323 228 323L228 267Z",
                svg.prop("fill", _colorCode2Hex(_colors.circle3))
            )
        );
    }

    function _colors2(uint256 _variant) internal pure returns (COLORS memory) {
        if (_variant == 0) {
            return COLORS(
                colorCode.BROWN, // rect1
                colorCode.GOLDEN, // rect2
                colorCode.BLUE, // rect3
                colorCode.GREEN, // rect4
                colorCode.CORAL, // rect5
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // circle1
                colorCode.CYAN, // circle2
                colorCode.GREEN // circle3
            );
        } else if (_variant == 1) {
            return COLORS(
                colorCode.GREEN, // rect1
                colorCode.BROWN, // rect2
                colorCode.GOLDEN, // rect3
                colorCode.BLUE, // rect4
                colorCode.CYAN, // rect5
                colorCode.GOLDEN, // unused
                colorCode.GREEN, // circle1
                colorCode.CORAL, // circle2
                colorCode.BLUE // circle3
            );
        } else if (_variant == 2) {
            return COLORS(
                colorCode.BLUE, // rect1
                colorCode.GOLDEN, // rect2
                colorCode.GREEN, // rect3
                colorCode.BLUE, // rect4
                colorCode.CORAL, // rect5
                colorCode.GOLDEN, // unused
                colorCode.CYAN, // circle1
                colorCode.BROWN, // circle2
                colorCode.BROWN // circle3
            );
        } else {
            return COLORS(
                colorCode.GOLDEN, // rect1
                colorCode.GREEN, // rect2
                colorCode.BLUE, // rect3
                colorCode.GOLDEN, // rect4
                colorCode.BROWN, // rect5
                colorCode.GOLDEN, // unused
                colorCode.BROWN, // circle1
                colorCode.CYAN, // circle2
                colorCode.CORAL // circle3
            );
        }
    }

    function _img2(uint256 _variant) internal pure returns (string memory) {
        COLORS memory colors = _colors2(_variant);
        return string.concat(_rects2(colors), _circles2(colors));
    }

    function _rects2(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //background
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "55"),
                    svg.prop("width", "268"),
                    svg.prop("height", "268"),
                    svg.prop("fill", DARK_BLUE)
                )
            ),
            // large upper right rect | rect1
            svg.rect(
                string.concat(
                    svg.prop("x", "128"),
                    svg.prop("y", "55"),
                    svg.prop("width", "156"),
                    svg.prop("height", "156"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect1))
                )
            ),
            // large central left rect | rect2
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "111"),
                    svg.prop("width", "134"),
                    svg.prop("height", "100"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect2))
                )
            ),
            // large lower left rect | rect3
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "211"),
                    svg.prop("width", "212"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect3))
                )
            ),
            // small lower central rect | rect4
            svg.rect(
                string.concat(
                    svg.prop("x", "72"),
                    svg.prop("y", "267"),
                    svg.prop("width", "78"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect4))
                )
            ),
            // small lower right rect | rect5
            svg.rect(
                string.concat(
                    svg.prop("x", "150"),
                    svg.prop("y", "267"),
                    svg.prop("width", "134"),
                    svg.prop("height", "56"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect5))
                )
            )
        );
    }

    function _circles2(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //lower left circle | circle1
            svg.circle(
                string.concat(
                    svg.prop("cx", "44"),
                    svg.prop("cy", "295"),
                    svg.prop("r", "28"),
                    svg.prop("fill", _colorCode2Hex(_colors.circle1))
                )
            ),
            //upper left half circle | circle2
            svg.path(
                "M16 55C16 62.4 17.4 69.6 20.3 76.4C23.1 83.2 27.2 89.4 32.4 94.6C37.6 99.8 43.8 103.9 50.6 106.7C57.4 109.6 64.6 111 72 111C79.4 111 86.6 109.6 93.4 106.7C100.2 103.9 106.4 99.8 111.6 94.6C116.8 89.4 120.9 83.2 123.7 76.4C126.6 69.6 128 62.4 128 55L16 55Z",
                svg.prop("fill", _colorCode2Hex(_colors.circle2))
            ),
            //central right half circle | circle3
            svg.path(
                "M284 211C284 190.3 275.8 170.5 261.2 155.8C246.5 141.2 226.7 133 206 133C185.3 133 165.5 141.2 150.9 155.86C136.2 170.5 128 190.3 128 211L284 211Z",
                svg.prop("fill", _colorCode2Hex(_colors.circle3))
            )
        );
    }

    function _colors3(uint256 _variant) internal pure returns (COLORS memory) {
        if (_variant == 0) {
            return COLORS(
                colorCode.BLUE, // rect1
                colorCode.CORAL, // rect2
                colorCode.BLUE, // rect3
                colorCode.GREEN, // rect4
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // circle1
                colorCode.CYAN, // circle2
                colorCode.GOLDEN // circle3
            );
        } else if (_variant == 1) {
            return COLORS(
                colorCode.CORAL, // rect1
                colorCode.GREEN, // rect2
                colorCode.BROWN, // rect3
                colorCode.GOLDEN, // rect4
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // unused
                colorCode.BLUE, // circle1
                colorCode.BLUE, // circle2
                colorCode.CYAN // circle3
            );
        } else if (_variant == 2) {
            return COLORS(
                colorCode.CORAL, // rect1
                colorCode.CYAN, // rect2
                colorCode.CORAL, // rect3
                colorCode.GOLDEN, // rect4
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // unused
                colorCode.GREEN, // circle1
                colorCode.BLUE, // circle2
                colorCode.GREEN // circle3
            );
        } else {
            return COLORS(
                colorCode.GOLDEN, // rect1
                colorCode.CORAL, // rect2
                colorCode.GREEN, // rect3
                colorCode.BLUE, // rect4
                colorCode.GOLDEN, // unused
                colorCode.GOLDEN, // unused
                colorCode.BROWN, // circle1
                colorCode.BLUE, // circle2
                colorCode.GREEN // circle3
            );
        }
    }

    function _img3(uint256 _variant) internal pure returns (string memory) {
        COLORS memory colors = _colors3(_variant);
        return string.concat(_rects3(colors), _circles3(colors));
    }

    function _rects3(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //background
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "55"),
                    svg.prop("width", "268"),
                    svg.prop("height", "268"),
                    svg.prop("fill", DARK_BLUE)
                )
            ),
            // lower left rect | rect1
            svg.rect(
                string.concat(
                    svg.prop("x", "16"),
                    svg.prop("y", "205"),
                    svg.prop("width", "75"),
                    svg.prop("height", "118"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect1))
                )
            ),
            // central rect | rect2
            svg.rect(
                string.concat(
                    svg.prop("x", "91"),
                    svg.prop("y", "205"),
                    svg.prop("width", "136"),
                    svg.prop("height", "59"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect2))
                )
            ),
            // central right rect | rect3
            svg.rect(
                string.concat(
                    svg.prop("x", "166"),
                    svg.prop("y", "180"),
                    svg.prop("width", "118"),
                    svg.prop("height", "25"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect3))
                )
            ),
            // upper right rect | rect4
            svg.rect(
                string.concat(
                    svg.prop("x", "166"),
                    svg.prop("y", "55"),
                    svg.prop("width", "118"),
                    svg.prop("height", "126"),
                    svg.prop("fill", _colorCode2Hex(_colors.rect4))
                )
            )
        );
    }

    function _circles3(COLORS memory _colors) internal pure returns (string memory) {
        return string.concat(
            //upper left circle | circle1
            svg.circle(
                string.concat(
                    svg.prop("cx", "91"),
                    svg.prop("cy", "130"),
                    svg.prop("r", "75"),
                    svg.prop("fill", _colorCode2Hex(_colors.circle1))
                )
            ),
            //upper right half circle | circle2
            svg.path(
                "M284 264 166 264 166 263C166 232 193 206 225 205C258 206 284 232 284 264C284 264 284 264 284 264Z",
                svg.prop("fill", _colorCode2Hex(_colors.circle2))
            ),
            //lower right half circle | circle3
            svg.path(
                "M284 323 166 323 166 323C166 290 193 265 225 264C258 265 284 290 284 323C284 323 284 323 284 323Z",
                svg.prop("fill", _colorCode2Hex(_colors.circle3))
            )
        );
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Interfaces/IStabilityPool.sol";
import "./Interfaces/IAddressesRegistry.sol";
import "./Interfaces/IStabilityPoolEvents.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IBoldToken.sol";
import "./Dependencies/LiquityBase.sol";

/*
 * The Stability Pool holds Bold tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its Bold debt gets offset with
 * Bold in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of Bold tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a Bold loss, in proportion to their deposit as a share of total deposits.
 * They also receive an Coll gain, as the collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total Bold in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 *
 * --- IMPLEMENTATION ---
 *
 * We use a highly scalable method of tracking deposits and Coll gains that has O(1) complexity.
 *
 * When a liquidation occurs, rather than updating each depositor's deposit and Coll gain, we simply update two state variables:
 * a product P, and a sum S.
 *
 * A mathematical manipulation allows us to factor out the initial deposit, and accurately track all depositors' compounded deposits
 * and accumulated Coll gains over time, as liquidations occur, using just these two variables P and S. When depositors join the
 * Stability Pool, they get a snapshot of the latest P and S: P_t and S_t, respectively.
 *
 * The formula for a depositor's accumulated Coll gain is derived here:
 * https://github.com/liquity/dev/blob/main/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 * For a given deposit d_t, the ratio P/P_t tells us the factor by which a deposit has decreased since it joined the Stability Pool,
 * and the term d_t * (S - S_t)/P_t gives us the deposit's total accumulated Coll gain.
 *
 * Each liquidation updates the product P and sum S. After a series of liquidations, a compounded deposit and corresponding Coll gain
 * can be calculated using the initial deposit, the depositor’s snapshots of P and S, and the latest values of P and S.
 *
 * Any time a depositor updates their deposit (withdrawal, top-up) their accumulated Coll gain is paid out, their new deposit is recorded
 * (based on their latest compounded deposit and modified by the withdrawal/top-up), and they receive new snapshots of the latest P and S.
 * Essentially, they make a fresh deposit that overwrites the old one.
 *
 *
 * --- SCALE FACTOR ---
 *
 * Since P is a running product in range ]0,1] that is always-decreasing, it should never reach 0 when multiplied by a number in range ]0,1[.
 * Unfortunately, Solidity floor division always reaches 0, sooner or later.
 *
 * A series of liquidations that nearly empty the Pool (and thus each multiply P by a very small number in range ]0,1[ ) may push P
 * to its 18 digit decimal limit, and round it to 0, when in fact the Pool hasn't been emptied: this would break deposit tracking.
 *
 * So, to track P accurately, we use a scale factor: if a liquidation would cause P to decrease to <1e-9 (and be rounded to 0 by Solidity),
 * we first multiply P by 1e9, and increment a currentScale factor by 1.
 *
 * The added benefit of using 1e9 for the scale factor (rather than 1e18) is that it ensures negligible precision loss close to the
 * scale boundary: when P is at its minimum value of 1e9, the relative precision loss in P due to floor division is only on the
 * order of 1e-9.
 *
 * --- EPOCHS ---
 *
 * Whenever a liquidation fully empties the Stability Pool, all deposits should become 0. However, setting P to 0 would make P be 0
 * forever, and break all future reward calculations.
 *
 * So, every time the Stability Pool is emptied by a liquidation, we reset P = 1 and currentScale = 0, and increment the currentEpoch by 1.
 *
 * --- TRACKING DEPOSIT OVER SCALE CHANGES AND EPOCHS ---
 *
 * When a deposit is made, it gets snapshots of the currentEpoch and the currentScale.
 *
 * When calculating a compounded deposit, we compare the current epoch to the deposit's epoch snapshot. If the current epoch is newer,
 * then the deposit was present during a pool-emptying liquidation, and necessarily has been depleted to 0.
 *
 * Otherwise, we then compare the current scale to the deposit's scale snapshot. If they're equal, the compounded deposit is given by d_t * P/P_t.
 * If it spans one scale change, it is given by d_t * P/(P_t * 1e9). If it spans more than one scale change, we define the compounded deposit
 * as 0, since it is now less than 1e-9'th of its initial value (e.g. a deposit of 1 billion Bold has depleted to < 1 Bold).
 *
 *
 *  --- TRACKING DEPOSITOR'S Coll GAIN OVER SCALE CHANGES AND EPOCHS ---
 *
 * In the current epoch, the latest value of S is stored upon each scale change, and the mapping (scale -> S) is stored for each epoch.
 *
 * This allows us to calculate a deposit's accumulated Coll gain, during the epoch in which the deposit was non-zero and earned Coll.
 *
 * We calculate the depositor's accumulated Coll gain for the scale at which they made the deposit, using the Coll gain formula:
 * e_1 = d_t * (S - S_t) / P_t
 *
 * and also for scale after, taking care to divide the latter by a factor of 1e9:
 * e_2 = d_t * S / (P_t * 1e9)
 *
 * The gain in the second scale will be full, as the starting point was in the previous scale, thus no need to subtract anything.
 * The deposit therefore was present for reward events from the beginning of that second scale.
 *
 *        S_i-S_t + S_{i+1}
 *      .<--------.------------>
 *      .         .
 *      . S_i     .   S_{i+1}
 *   <--.-------->.<----------->
 *   S_t.         .
 *   <->.         .
 *      t         .
 *  |---+---------|-------------|-----...
 *         i            i+1
 *
 * The sum of (e_1 + e_2) captures the depositor's total accumulated Coll gain, handling the case where their
 * deposit spanned one scale change. We only care about gains across one scale change, since the compounded
 * deposit is defined as being 0 once it has spanned more than one scale change.
 *
 *
 * --- UPDATING P WHEN A LIQUIDATION OCCURS ---
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / Coll gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 *
 */
contract StabilityPool is LiquityBase, IStabilityPool, IStabilityPoolEvents {
    using SafeERC20 for IERC20;

    string public constant NAME = "StabilityPool";

    IERC20 public immutable collToken;
    ITroveManager public immutable troveManager;
    IBoldToken public immutable boldToken;

    uint256 internal collBalance; // deposited coll tracker

    // Tracker for Bold held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
    uint256 internal totalBoldDeposits;

    // Total remaining Bold yield gains (from Trove interest mints) held by SP, and not yet paid out to depositors
    // From the contract's perspective, this is a write-only variable.
    uint256 internal yieldGainsOwed;
    // Total remaining Bold yield gains (from Trove interest mints) held by SP, not yet paid out to depositors,
    // and not accounted for because they were received when the total deposits were too small
    uint256 internal yieldGainsPending;

    // --- Data structures ---

    struct Deposit {
        uint256 initialValue;
    }

    struct Snapshots {
        uint256 S; // Coll reward sum liqs
        uint256 P;
        uint256 B; // Bold reward sum from minted interest
        uint128 scale;
        uint128 epoch;
    }

    mapping(address => Deposit) public deposits; // depositor address -> Deposit struct
    mapping(address => Snapshots) public depositSnapshots; // depositor address -> snapshots struct
    mapping(address => uint256) public stashedColl;

    /*  Product 'P': Running product by which to multiply an initial deposit, in order to find the current compounded deposit,
    * after a series of liquidations have occurred, each of which cancel some Bold debt with the deposit.
    *
    * During its lifetime, a deposit's value evolves from d_t to d_t * P / P_t , where P_t
    * is the snapshot of P taken at the instant the deposit was made. 18-digit decimal.
    */
    uint256 public P = DECIMAL_PRECISION;

    uint256 public constant SCALE_FACTOR = 1e9;

    // Each time the scale of P shifts by SCALE_FACTOR, the scale is incremented by 1
    uint128 public currentScale;

    // With each offset that fully empties the Pool, the epoch is incremented by 1
    uint128 public currentEpoch;

    /* Coll Gain sum 'S': During its lifetime, each deposit d_t earns an Coll gain of ( d_t * [S - S_t] )/P_t, where S_t
    * is the depositor's snapshot of S taken at the time t when the deposit was made.
    *
    * The 'S' sums are stored in a nested mapping (epoch => scale => sum):
    *
    * - The inner mapping records the sum S at different scales
    * - The outer mapping records the (scale => sum) mappings, for different epochs.
    */
    mapping(uint128 => mapping(uint128 => uint256)) public epochToScaleToS;
    mapping(uint128 => mapping(uint128 => uint256)) public epochToScaleToB;

    // Error trackers for the error correction in the offset calculation
    uint256 public lastCollError_Offset;
    uint256 public lastBoldLossErrorByP_Offset;
    uint256 public lastBoldLossError_TotalDeposits;

    // Error tracker fror the error correction in the BOLD reward calculation
    uint256 public lastYieldError;

    // --- Events ---

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event BoldTokenAddressChanged(address _newBoldTokenAddress);

    constructor(IAddressesRegistry _addressesRegistry) LiquityBase(_addressesRegistry) {
        collToken = _addressesRegistry.collToken();
        troveManager = _addressesRegistry.troveManager();
        boldToken = _addressesRegistry.boldToken();

        emit TroveManagerAddressChanged(address(troveManager));
        emit BoldTokenAddressChanged(address(boldToken));
    }

    // --- Getters for public variables. Required by IPool interface ---

    function getCollBalance() external view override returns (uint256) {
        return collBalance;
    }

    function getTotalBoldDeposits() external view override returns (uint256) {
        return totalBoldDeposits;
    }

    function getYieldGainsOwed() external view override returns (uint256) {
        return yieldGainsOwed;
    }

    function getYieldGainsPending() external view override returns (uint256) {
        return yieldGainsPending;
    }

    // --- External Depositor Functions ---

    /*  provideToSP():
    * - Calculates depositor's Coll gain
    * - Calculates the compounded deposit
    * - Increases deposit, and takes new snapshots of accumulators P and S
    * - Sends depositor's accumulated Coll gains to depositor
    */
    function provideToSP(uint256 _topUp, bool _doClaim) external override {
        _requireNonZeroAmount(_topUp);

        activePool.mintAggInterest();

        uint256 initialDeposit = deposits[msg.sender].initialValue;

        uint256 currentCollGain = getDepositorCollGain(msg.sender);
        uint256 currentYieldGain = getDepositorYieldGain(msg.sender);
        uint256 compoundedBoldDeposit = getCompoundedBoldDeposit(msg.sender);
        (uint256 keptYieldGain, uint256 yieldGainToSend) = _getYieldToKeepOrSend(currentYieldGain, _doClaim);
        uint256 newDeposit = compoundedBoldDeposit + _topUp + keptYieldGain;
        (uint256 newStashedColl, uint256 collToSend) =
            _getNewStashedCollAndCollToSend(msg.sender, currentCollGain, _doClaim);

        emit DepositOperation(
            msg.sender,
            Operation.provideToSP,
            initialDeposit - compoundedBoldDeposit,
            int256(_topUp),
            currentYieldGain,
            yieldGainToSend,
            currentCollGain,
            collToSend
        );

        _updateDepositAndSnapshots(msg.sender, newDeposit, newStashedColl);
        boldToken.sendToPool(msg.sender, address(this), _topUp);
        _updateTotalBoldDeposits(_topUp + keptYieldGain, 0);
        _decreaseYieldGainsOwed(currentYieldGain);
        _sendBoldtoDepositor(msg.sender, yieldGainToSend);
        _sendCollGainToDepositor(collToSend);

        // If there were pending yields and with the new deposit we are reaching the threshold, let’s move the yield to owed
        _updateYieldRewardsSum(0);
    }

    function _getYieldToKeepOrSend(uint256 _currentYieldGain, bool _doClaim) internal pure returns (uint256, uint256) {
        uint256 yieldToKeep;
        uint256 yieldToSend;

        if (_doClaim) {
            yieldToKeep = 0;
            yieldToSend = _currentYieldGain;
        } else {
            yieldToKeep = _currentYieldGain;
            yieldToSend = 0;
        }

        return (yieldToKeep, yieldToSend);
    }

    /*  withdrawFromSP():
    * - Calculates depositor's Coll gain
    * - Calculates the compounded deposit
    * - Sends the requested BOLD withdrawal to depositor
    * - (If _amount > userDeposit, the user withdraws all of their compounded deposit)
    * - Decreases deposit by withdrawn amount and takes new snapshots of accumulators P and S
    */
    function withdrawFromSP(uint256 _amount, bool _doClaim) external override {
        uint256 initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);

        activePool.mintAggInterest();

        uint256 currentCollGain = getDepositorCollGain(msg.sender);
        uint256 currentYieldGain = getDepositorYieldGain(msg.sender);
        uint256 compoundedBoldDeposit = getCompoundedBoldDeposit(msg.sender);
        uint256 boldToWithdraw = LiquityMath._min(_amount, compoundedBoldDeposit);
        (uint256 keptYieldGain, uint256 yieldGainToSend) = _getYieldToKeepOrSend(currentYieldGain, _doClaim);
        uint256 newDeposit = compoundedBoldDeposit - boldToWithdraw + keptYieldGain;
        (uint256 newStashedColl, uint256 collToSend) =
            _getNewStashedCollAndCollToSend(msg.sender, currentCollGain, _doClaim);

        emit DepositOperation(
            msg.sender,
            Operation.withdrawFromSP,
            initialDeposit - compoundedBoldDeposit,
            -int256(boldToWithdraw),
            currentYieldGain,
            yieldGainToSend,
            currentCollGain,
            collToSend
        );

        _updateDepositAndSnapshots(msg.sender, newDeposit, newStashedColl);
        _decreaseYieldGainsOwed(currentYieldGain);
        _updateTotalBoldDeposits(keptYieldGain, boldToWithdraw);
        _sendBoldtoDepositor(msg.sender, boldToWithdraw + yieldGainToSend);
        _sendCollGainToDepositor(collToSend);

        // If there were pending yields and with the new deposit we are reaching the threshold, let’s move the yield to owed
        // (it may happen if the user is not claiming)
        _updateYieldRewardsSum(0);
    }

    function _getNewStashedCollAndCollToSend(address _depositor, uint256 _currentCollGain, bool _doClaim)
        internal
        view
        returns (uint256 newStashedColl, uint256 collToSend)
    {
        if (_doClaim) {
            newStashedColl = 0;
            collToSend = stashedColl[_depositor] + _currentCollGain;
        } else {
            newStashedColl = stashedColl[_depositor] + _currentCollGain;
            collToSend = 0;
        }
    }

    // This function is only needed in the case a user has no deposit but still has remaining stashed Coll gains.
    function claimAllCollGains() external {
        _requireUserHasNoDeposit(msg.sender);

        activePool.mintAggInterest();

        uint256 collToSend = stashedColl[msg.sender];
        _requireNonZeroAmount(collToSend);
        stashedColl[msg.sender] = 0;

        emit DepositOperation(msg.sender, Operation.claimAllCollGains, 0, 0, 0, 0, 0, collToSend);
        emit DepositUpdated(msg.sender, 0, 0, 0, 0, 0, 0, 0);

        _sendCollGainToDepositor(collToSend);
    }

    // --- BOLD reward functions ---

    function triggerBoldRewards(uint256 _boldYield) external {
        _requireCallerIsActivePool();
        assert(_boldYield > 0); // TODO: remove before deploying

        _updateYieldRewardsSum(_boldYield);
    }

    function _updateYieldRewardsSum(uint256 _newYield) internal {
        uint256 accumulatedYieldGains = yieldGainsPending + _newYield;
        if (accumulatedYieldGains == 0) return;

        // When total deposits is very small, B is not updated. In this case, the BOLD issued is hold
        // until the total deposits reach 1 BOLD (remains in the balance of the SP).
        uint256 totalBoldDepositsCached = totalBoldDeposits; // cached to save an SLOAD
        if (totalBoldDepositsCached < DECIMAL_PRECISION) {
            yieldGainsPending = accumulatedYieldGains;
            return;
        }

        yieldGainsOwed += accumulatedYieldGains;
        yieldGainsPending = 0;

        /*
         * Calculate the BOLD-per-unit staked.  Division uses a "feedback" error correction, to keep the
         * cumulative error low in the running total B:
         *
         * 1) Form a numerator which compensates for the floor division error that occurred the last time this
         * function was called.
         * 2) Calculate "per-unit-staked" ratio.
         * 3) Multiply the ratio back by its denominator, to reveal the current floor division error.
         * 4) Store this error for use in the next correction when this function is called.
         * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
         */
        uint256 yieldNumerator = accumulatedYieldGains * DECIMAL_PRECISION + lastYieldError;

        uint256 yieldPerUnitStaked = yieldNumerator / totalBoldDepositsCached;
        lastYieldError = yieldNumerator - yieldPerUnitStaked * totalBoldDepositsCached;

        uint256 marginalYieldGain = yieldPerUnitStaked * (P - 1);
        epochToScaleToB[currentEpoch][currentScale] = epochToScaleToB[currentEpoch][currentScale] + marginalYieldGain;

        emit B_Updated(epochToScaleToB[currentEpoch][currentScale], currentEpoch, currentScale);
    }

    // --- Liquidation functions ---

    /*
    * Cancels out the specified debt against the Bold contained in the Stability Pool (as far as possible)
    * and transfers the Trove's Coll collateral from ActivePool to StabilityPool.
    * Only called by liquidation functions in the TroveManager.
    */
    function offset(uint256 _debtToOffset, uint256 _collToAdd) external override {
        _requireCallerIsTroveManager();
        uint256 totalBold = totalBoldDeposits; // cached to save an SLOAD
        if (totalBold == 0 || _debtToOffset == 0) return;

        _updateCollRewardSumAndProduct(_collToAdd, _debtToOffset, totalBold); // updates S and P

        _moveOffsetCollAndDebt(_collToAdd, _debtToOffset);
    }

    // --- Offset helper functions ---

    function _computeCollRewardsPerUnitStaked(uint256 _collToAdd, uint256 _debtToOffset, uint256 _totalBoldDeposits)
        internal
        returns (uint256 collGainPerUnitStaked, uint256 boldLossPerUnitStaked, uint256 newLastBoldLossErrorOffset)
    {
        /*
        * Compute the Bold and Coll rewards. Uses a "feedback" error correction, to keep
        * the cumulative error in the P and S state variables low:
        *
        * 1) Form numerators which compensate for the floor division errors that occurred the last time this
        * function was called.
        * 2) Calculate "per-unit-staked" ratios.
        * 3) Multiply each ratio back by its denominator, to reveal the current floor division error.
        * 4) Store these errors for use in the next correction when this function is called.
        * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
        */
        uint256 collNumerator = _collToAdd * DECIMAL_PRECISION + lastCollError_Offset;

        assert(_debtToOffset <= _totalBoldDeposits);
        if (_debtToOffset == _totalBoldDeposits) {
            boldLossPerUnitStaked = DECIMAL_PRECISION; // When the Pool depletes to 0, so does each deposit
            newLastBoldLossErrorOffset = 0;
        } else {
            uint256 boldLossNumerator = _debtToOffset * DECIMAL_PRECISION;
            /*
            * Add 1 to make error in quotient positive. We want "slightly too much" Bold loss,
            * which ensures the error in any given compoundedBoldDeposit favors the Stability Pool.
            */
            boldLossPerUnitStaked = boldLossNumerator / _totalBoldDeposits + 1;
            newLastBoldLossErrorOffset = boldLossPerUnitStaked * _totalBoldDeposits - boldLossNumerator;
        }

        collGainPerUnitStaked = collNumerator / _totalBoldDeposits;
        lastCollError_Offset = collNumerator - collGainPerUnitStaked * _totalBoldDeposits;

        return (collGainPerUnitStaked, boldLossPerUnitStaked, newLastBoldLossErrorOffset);
    }

    // Update the Stability Pool reward sum S and product P
    function _updateCollRewardSumAndProduct(uint256 _collToAdd, uint256 _debtToOffset, uint256 _totalBoldDeposits)
        internal
    {
        (uint256 collGainPerUnitStaked, uint256 boldLossPerUnitStaked, uint256 newLastBoldLossErrorOffset) =
            _computeCollRewardsPerUnitStaked(_collToAdd, _debtToOffset, _totalBoldDeposits);

        uint256 currentP = P;
        uint256 newP;

        assert(boldLossPerUnitStaked <= DECIMAL_PRECISION);
        /*
        * The newProductFactor is the factor by which to change all deposits, due to the depletion of Stability Pool Bold in the liquidation.
        * We make the product factor 0 if there was a pool-emptying. Otherwise, it is (1 - boldLossPerUnitStaked)
        */
        uint256 newProductFactor = uint256(DECIMAL_PRECISION) - boldLossPerUnitStaked;

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint256 currentS = epochToScaleToS[currentEpochCached][currentScaleCached];

        /*
        * Calculate the new S first, before we update P.
        * The Coll gain for any given depositor from a liquidation depends on the value of their deposit
        * (and the value of totalDeposits) prior to the Stability being depleted by the debt in the liquidation.
        *
        * Since S corresponds to Coll gain, and P to deposit loss, we update S first.
        */
        uint256 marginalCollGain = collGainPerUnitStaked * (currentP - 1);
        uint256 newS = currentS + marginalCollGain;
        epochToScaleToS[currentEpochCached][currentScaleCached] = newS;
        emit S_Updated(newS, currentEpochCached, currentScaleCached);

        // If the Stability Pool was emptied, increment the epoch, and reset the scale and product P
        if (newProductFactor == 0) {
            currentEpoch = currentEpochCached + 1;
            emit EpochUpdated(currentEpoch);
            currentScale = 0;
            emit ScaleUpdated(currentScale);
            newP = DECIMAL_PRECISION;
        } else {
            uint256 lastBoldLossErrorByP_Offset_Cached = lastBoldLossErrorByP_Offset;
            uint256 lastBoldLossError_TotalDeposits_Cached = lastBoldLossError_TotalDeposits;
            newP = _getNewPByScale(
                currentP,
                newProductFactor,
                lastBoldLossErrorByP_Offset_Cached,
                lastBoldLossError_TotalDeposits_Cached,
                1
            );

            // If multiplying P by a non-zero product factor would reduce P below the scale boundary, increment the scale
            if (newP < SCALE_FACTOR) {
                newP = _getNewPByScale(
                    currentP,
                    newProductFactor,
                    lastBoldLossErrorByP_Offset_Cached,
                    lastBoldLossError_TotalDeposits_Cached,
                    SCALE_FACTOR
                );
                currentScale = currentScaleCached + 1;

                // Increment the scale again if it's still below the boundary. This ensures the invariant P >= 1e9 holds and
                // addresses this issue from Liquity v1: https://github.com/liquity/dev/security/advisories/GHSA-m9f3-hrx8-x2g3
                if (newP < SCALE_FACTOR) {
                    newP = _getNewPByScale(
                        currentP,
                        newProductFactor,
                        lastBoldLossErrorByP_Offset_Cached,
                        lastBoldLossError_TotalDeposits_Cached,
                        SCALE_FACTOR * SCALE_FACTOR
                    );
                    currentScale = currentScaleCached + 2;
                }
            }
            emit ScaleUpdated(currentScale);
            // If there's no scale change and no pool-emptying, just do a standard multiplication
        }
        lastBoldLossErrorByP_Offset = currentP * newLastBoldLossErrorOffset;
        lastBoldLossError_TotalDeposits = _totalBoldDeposits;

        assert(newP > 0);
        P = newP;

        emit P_Updated(newP);
    }

    function _getNewPByScale(
        uint256 _currentP,
        uint256 _newProductFactor,
        uint256 _lastBoldLossErrorByP_Offset,
        uint256 _lastBoldLossError_TotalDeposits,
        uint256 _scale
    ) internal pure returns (uint256) {
        uint256 errorFactor;
        if (_lastBoldLossErrorByP_Offset > 0) {
            errorFactor = _lastBoldLossErrorByP_Offset * _newProductFactor * _scale / _lastBoldLossError_TotalDeposits
                / DECIMAL_PRECISION;
        }
        return (_currentP * _newProductFactor * _scale + errorFactor) / DECIMAL_PRECISION;
    }

    function _moveOffsetCollAndDebt(uint256 _collToAdd, uint256 _debtToOffset) internal {
        // Cancel the liquidated Bold debt with the Bold in the stability pool
        _updateTotalBoldDeposits(0, _debtToOffset);

        // Burn the debt that was successfully offset
        boldToken.burn(address(this), _debtToOffset);

        // Update internal Coll balance tracker
        uint256 newCollBalance = collBalance + _collToAdd;
        collBalance = newCollBalance;

        // Pull Coll from Active Pool
        activePool.sendColl(address(this), _collToAdd);

        emit StabilityPoolCollBalanceUpdated(newCollBalance);
    }

    function _updateTotalBoldDeposits(uint256 _depositIncrease, uint256 _depositDecrease) internal {
        if (_depositIncrease == 0 && _depositDecrease == 0) return;
        uint256 newTotalBoldDeposits = totalBoldDeposits + _depositIncrease - _depositDecrease;
        totalBoldDeposits = newTotalBoldDeposits;
        emit StabilityPoolBoldBalanceUpdated(newTotalBoldDeposits);
    }

    function _decreaseYieldGainsOwed(uint256 _amount) internal {
        if (_amount == 0) return;
        uint256 newYieldGainsOwed = yieldGainsOwed - _amount;
        yieldGainsOwed = newYieldGainsOwed;
    }

    // --- Reward calculator functions for depositor ---

    /* Calculates the Coll gain earned by the deposit since its last snapshots were taken.
    * Given by the formula:  E = d0 * (S - S(0))/P(0)
    * where S(0) and P(0) are the depositor's snapshots of the sum S and product P, respectively.
    * d0 is the last recorded deposit value.
    */
    function getDepositorCollGain(address _depositor) public view override returns (uint256) {
        uint256 initialDeposit = deposits[_depositor].initialValue;

        if (initialDeposit == 0) return 0;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        /*
         * Grab the sum 'S' from the epoch at which the stake was made. The Coll gain may span up to one scale change.
         * If it does, the second portion of the Coll gain is scaled by 1e9.
         * If the gain spans no scale change, the second portion will be 0.
         */
        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint256 S_Snapshot = snapshots.S;
        uint256 P_Snapshot = snapshots.P;

        uint256 firstPortion = epochToScaleToS[epochSnapshot][scaleSnapshot] - S_Snapshot;
        uint256 secondPortion = epochToScaleToS[epochSnapshot][scaleSnapshot + 1] / SCALE_FACTOR;

        uint256 collGain = initialDeposit * (firstPortion + secondPortion) / P_Snapshot / DECIMAL_PRECISION;

        return LiquityMath._min(collGain, collBalance);
    }

    function getDepositorYieldGain(address _depositor) public view override returns (uint256) {
        uint256 initialDeposit = deposits[_depositor].initialValue;

        if (initialDeposit == 0) return 0;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        /*
         * Grab the sum 'B' from the epoch at which the stake was made. The Bold gain may span up to one scale change.
         * If it does, the second portion of the Bold gain is scaled by 1e9.
         * If the gain spans no scale change, the second portion will be 0.
         */
        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint256 B_Snapshot = snapshots.B;
        uint256 P_Snapshot = snapshots.P;

        uint256 firstPortion = epochToScaleToB[epochSnapshot][scaleSnapshot] - B_Snapshot;
        uint256 secondPortion = epochToScaleToB[epochSnapshot][scaleSnapshot + 1] / SCALE_FACTOR;

        uint256 yieldGain = initialDeposit * (firstPortion + secondPortion) / P_Snapshot / DECIMAL_PRECISION;

        return LiquityMath._min(yieldGain, yieldGainsOwed);
    }

    function getDepositorYieldGainWithPending(address _depositor) external view override returns (uint256) {
        uint256 initialDeposit = deposits[_depositor].initialValue;

        if (initialDeposit == 0) return 0;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint256 pendingSPYield = activePool.calcPendingSPYield() + yieldGainsPending;
        uint256 newYieldGainsOwed = yieldGainsOwed + (totalBoldDeposits >= DECIMAL_PRECISION ? pendingSPYield : 0);
        uint256 firstPortionPending;
        uint256 secondPortionPending;

        if (pendingSPYield > 0 && snapshots.epoch == currentEpoch && totalBoldDeposits >= DECIMAL_PRECISION) {
            uint256 yieldNumerator = pendingSPYield * DECIMAL_PRECISION + lastYieldError;
            uint256 yieldPerUnitStaked = yieldNumerator / totalBoldDeposits;
            uint256 marginalYieldGain = yieldPerUnitStaked * (P - 1);

            if (currentScale == snapshots.scale) firstPortionPending = marginalYieldGain;
            else if (currentScale == snapshots.scale + 1) secondPortionPending = marginalYieldGain;
        }

        uint256 firstPortion = epochToScaleToB[snapshots.epoch][snapshots.scale] + firstPortionPending - snapshots.B;
        uint256 secondPortion =
            (epochToScaleToB[snapshots.epoch][snapshots.scale + 1] + secondPortionPending) / SCALE_FACTOR;

        uint256 yieldGain = initialDeposit * (firstPortion + secondPortion) / snapshots.P / DECIMAL_PRECISION;

        return LiquityMath._min(yieldGain, newYieldGainsOwed);
    }

    // --- Compounded deposit ---

    /*
    * Return the user's compounded deposit. Given by the formula:  d = d0 * P/P(0)
    * where P(0) is the depositor's snapshot of the product P, taken when they last updated their deposit.
    */
    function getCompoundedBoldDeposit(address _depositor) public view override returns (uint256) {
        uint256 initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) return 0;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint256 compoundedDeposit = _getCompoundedStakeFromSnapshots(initialDeposit, snapshots);
        return compoundedDeposit;
    }

    // Internal function, used to calculcate compounded deposits and compounded front end stakes.
    function _getCompoundedStakeFromSnapshots(uint256 initialStake, Snapshots memory snapshots)
        internal
        view
        returns (uint256)
    {
        uint256 snapshot_P = snapshots.P;
        uint128 scaleSnapshot = snapshots.scale;
        uint128 epochSnapshot = snapshots.epoch;

        // If stake was made before a pool-emptying event, then it has been fully cancelled with debt -- so, return 0
        if (epochSnapshot < currentEpoch) return 0;

        uint256 compoundedStake;
        uint128 scaleDiff = currentScale - scaleSnapshot;

        // To make sure rouning errors favour the system, we use P - 1 if P decreased
        uint256 cachedP = P;
        uint256 currentPToUse = cachedP != snapshot_P ? cachedP - 1 : cachedP;

        /* Compute the compounded stake. If a scale change in P was made during the stake's lifetime,
        * account for it. If more than one scale change was made, then the stake has decreased by a factor of
        * at least 1e-9 -- so return 0.
        */
        if (scaleDiff == 0) {
            compoundedStake = initialStake * currentPToUse / snapshot_P;
        } else if (scaleDiff == 1) {
            compoundedStake = initialStake * currentPToUse / snapshot_P / SCALE_FACTOR;
        } else {
            // if scaleDiff >= 2
            compoundedStake = 0;
        }

        /*
        * If compounded deposit is less than a billionth of the initial deposit, return 0.
        *
        * NOTE: originally, this line was in place to stop rounding errors making the deposit too large. However, the error
        * corrections should ensure the error in P "favors the Pool", i.e. any given compounded deposit should slightly less
        * than it's theoretical value.
        *
        * Thus it's unclear whether this line is still really needed.
        */
        if (compoundedStake < initialStake / 1e9) return 0;

        return compoundedStake;
    }

    // --- Sender functions for Bold deposit and Coll gains ---

    function _sendCollGainToDepositor(uint256 _collAmount) internal {
        if (_collAmount == 0) return;

        uint256 newCollBalance = collBalance - _collAmount;
        collBalance = newCollBalance;
        emit StabilityPoolCollBalanceUpdated(newCollBalance);
        collToken.safeTransfer(msg.sender, _collAmount);
    }

    // Send Bold to user and decrease Bold in Pool
    function _sendBoldtoDepositor(address _depositor, uint256 _boldToSend) internal {
        if (_boldToSend == 0) return;
        boldToken.returnFromPool(address(this), _depositor, _boldToSend);
    }

    // --- Stability Pool Deposit Functionality ---

    function _updateDepositAndSnapshots(address _depositor, uint256 _newDeposit, uint256 _newStashedColl) internal {
        deposits[_depositor].initialValue = _newDeposit;
        stashedColl[_depositor] = _newStashedColl;

        if (_newDeposit == 0) {
            delete depositSnapshots[_depositor];
            emit DepositUpdated(_depositor, 0, _newStashedColl, 0, 0, 0, 0, 0);
            return;
        }

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint256 currentP = P;

        // Get S for the current epoch and current scale
        uint256 currentS = epochToScaleToS[currentEpochCached][currentScaleCached];
        uint256 currentB = epochToScaleToB[currentEpochCached][currentScaleCached];

        // Record new snapshots of the latest running product P and sum S for the depositor
        depositSnapshots[_depositor].P = currentP;
        depositSnapshots[_depositor].S = currentS;
        depositSnapshots[_depositor].B = currentB;
        depositSnapshots[_depositor].scale = currentScaleCached;
        depositSnapshots[_depositor].epoch = currentEpochCached;

        emit DepositUpdated(
            _depositor,
            _newDeposit,
            _newStashedColl,
            currentP,
            currentS,
            currentB,
            currentScaleCached,
            currentEpochCached
        );
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == address(activePool), "StabilityPool: Caller is not ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == address(troveManager), "StabilityPool: Caller is not TroveManager");
    }

    function _requireUserHasDeposit(uint256 _initialDeposit) internal pure {
        require(_initialDeposit > 0, "StabilityPool: User must have a non-zero deposit");
    }

    function _requireUserHasNoDeposit(address _address) internal view {
        uint256 initialDeposit = deposits[_address].initialValue;
        require(initialDeposit == 0, "StabilityPool: User must have no deposit");
    }

    function _requireNonZeroAmount(uint256 _amount) internal pure {
        require(_amount > 0, "StabilityPool: Amount must be non-zero");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

type BatchId is address;

using {equals as ==, notEquals as !=, isZero, isNotZero} for BatchId global;

function equals(BatchId a, BatchId b) pure returns (bool) {
    return BatchId.unwrap(a) == BatchId.unwrap(b);
}

function notEquals(BatchId a, BatchId b) pure returns (bool) {
    return !(a == b);
}

function isZero(BatchId x) pure returns (bool) {
    return x == BATCH_ID_ZERO;
}

function isNotZero(BatchId x) pure returns (bool) {
    return !x.isZero();
}

BatchId constant BATCH_ID_ZERO = BatchId.wrap(address(0));
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

struct LatestBatchData {
    uint256 entireDebtWithoutRedistribution;
    uint256 entireCollWithoutRedistribution;
    uint256 accruedInterest;
    uint256 recordedDebt;
    uint256 annualInterestRate;
    uint256 weightedRecordedDebt;
    uint256 annualManagementFee;
    uint256 accruedManagementFee;
    uint256 weightedRecordedBatchManagementFee;
    uint256 lastDebtUpdateTime;
    uint256 lastInterestRateAdjTime;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

struct LatestTroveData {
    uint256 entireDebt;
    uint256 entireColl;
    uint256 redistBoldDebtGain;
    uint256 redistCollGain;
    uint256 accruedInterest;
    uint256 recordedDebt;
    uint256 annualInterestRate;
    uint256 weightedRecordedDebt;
    uint256 accruedBatchManagementFee;
    uint256 lastInterestRateAdjTime;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

struct TroveChange {
    uint256 appliedRedistBoldDebtGain;
    uint256 appliedRedistCollGain;
    uint256 collIncrease;
    uint256 collDecrease;
    uint256 debtIncrease;
    uint256 debtDecrease;
    uint256 newWeightedRecordedDebt;
    uint256 oldWeightedRecordedDebt;
    uint256 upfrontFee;
    uint256 batchAccruedManagementFee;
    uint256 newWeightedRecordedBatchManagementFee;
    uint256 oldWeightedRecordedBatchManagementFee;
}