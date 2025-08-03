// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

import "./IShields.sol";
import "./IFrameGenerator.sol";
import "./IFieldGenerator.sol";
import "./IHardwareGenerator.sol";
import "./IShieldBadgeSVGs.sol";

interface IEmblemWeaver {
    function fieldGenerator() external returns (IFieldGenerator);

    function hardwareGenerator() external returns (IHardwareGenerator);

    function frameGenerator() external returns (IFrameGenerator);

    function shieldBadgeSVGGenerator() external returns (IShieldBadgeSVGs);

    function generateShieldURI(IShields.Shield memory shield)
        external
        view
        returns (string memory);

    function generateShieldBadgeURI(IShields.ShieldBadge shieldBadge)
        external
        view
        returns (string memory);
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

interface IFieldGenerator {
    enum FieldCategories {
        MYTHIC,
        HERALDIC
    }
    struct FieldData {
        string title;
        FieldCategories fieldType;
        string svgString;
    }

    function generateField(uint16 field, uint24[4] memory colors)
        external
        view
        returns (FieldData memory);
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

interface IFrameGenerator {
    struct FrameData {
        string title;
        uint256 fee;
        string svgString;
    }

    function generateFrame(uint16 Frame)
        external
        view
        returns (FrameData memory);
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

interface IHardwareGenerator {
    enum HardwareCategories {
        STANDARD,
        SPECIAL
    }
    struct HardwareData {
        string title;
        HardwareCategories hardwareType;
        string svgString;
    }

    function generateHardware(uint16 hardware)
        external
        view
        returns (HardwareData memory);
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

import "./IShields.sol";

interface IShieldBadgeSVGs {
    function generateShieldBadgeSVG(IShields.ShieldBadge shieldBadge)
        external
        view
        returns (string memory);
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

import "./IEmblemWeaver.sol";

interface IShields {
    enum ShieldBadge {
        MAKER,
        STANDARD
    }

    struct Shield {
        bool built;
        uint16 field;
        uint16 hardware;
        uint16 frame;
        ShieldBadge shieldBadge;
        uint24[4] colors;
    }

    function emblemWeaver() external view returns (IEmblemWeaver);

    function shields(uint256 tokenId)
        external
        view
        returns (
            uint16 field,
            uint16 hardware,
            uint16 frame,
            uint24 color1,
            uint24 color2,
            uint24 color3,
            uint24 color4,
            ShieldBadge shieldBadge
        );
}
// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.9;

import "./IShields.sol";
import "./IFieldGenerator.sol";
import "./IHardwareGenerator.sol";
import "./IFrameGenerator.sol";

interface IShieldsAPI {
    function getShield(uint256 shieldId)
        external
        view
        returns (IShields.Shield memory);

    function getShieldSVG(uint256 shieldId)
        external
        view
        returns (string memory);

    function getShieldSVG(
        uint16 field,
        uint24[4] memory colors,
        uint16 hardware,
        uint16 frame
    ) external view returns (string memory);

    function isShieldBuilt(uint256 shieldId) external view returns (bool);

    function getField(uint16 field, uint24[4] memory colors)
        external
        view
        returns (IFieldGenerator.FieldData memory);

    function getFieldTitle(uint16 field, uint24[4] memory colors)
        external
        view
        returns (string memory);

    function getFieldSVG(uint16 field, uint24[4] memory colors)
        external
        view
        returns (string memory);

    function getHardware(uint16 hardware)
        external
        view
        returns (IHardwareGenerator.HardwareData memory);

    function getHardwareTitle(uint16 hardware)
        external
        view
        returns (string memory);

    function getHardwareSVG(uint16 hardware)
        external
        view
        returns (string memory);

    function getFrame(uint16 frame)
        external
        view
        returns (IFrameGenerator.FrameData memory);

    function getFrameTitle(uint16 frame) external view returns (string memory);

    function getFrameSVG(uint16 frame) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The `length` of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

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
            // Update the free memory pointer to allocate.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                str := add(str, w) // `sub(str, 1)`.
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        unchecked {
            str = toString(uint256(-value));
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
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
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
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
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
                // Store the function selector of `HexLengthInsufficient()`.
                mstore(0x00, 0x2194895a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
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
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
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
            // Allocate the memory.
            mstore(0x40, add(str, 0x20))
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end to calculate the length later.
            let end := str
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

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

            // Compute the string's length.
            let strLength := sub(end, str)
            // Move the pointer and write the length.
            str := sub(str, 0x20)
            mstore(str, strLength)
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksumed(address value) internal pure returns (string memory str) {
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
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
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

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            str := add(str, 2)
            mstore(str, 40)

            let o := add(str, 0x20)
            mstore(add(o, 40), 0)

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
            mstore(str, 0x3078) // Write the "0x" prefix.
            str := sub(str, 2) // Move the pointer.
            mstore(str, strLength) // Write the length.
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

            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let o := add(str, 0x20)
            let end := add(raw, length)

            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, and(add(o, 31), not(31))) // Allocate the memory.
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

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, all indices of the following operations
    // are byte (ASCII) offsets, not UTF character offsets.

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
                if iszero(lt(searchLength, 32)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(32, and(searchLength, 31)))
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
            // Zeroize the slot after the string.
            let last := add(add(result, 0x20), k)
            mstore(last, 0)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 31), not(31)))
            // Store the length of the result.
            mstore(result, k)
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

                let m := shl(3, sub(32, and(searchLength, 31)))
                let s := mload(add(search, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }

                if iszero(lt(searchLength, 32)) {
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
                // Zeroize the slot after the string.
                mstore(output, 0)
                // Store the length.
                let resultLength := sub(output, add(result, 0x20))
                mstore(result, resultLength)
                // Allocate memory for the length and the bytes,
                // rounded up to a multiple of 32.
                mstore(0x40, add(result, and(add(resultLength, 63), not(31))))
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
                let w := not(31)
                // Copy the `subject` one word at a time, backwards.
                for { let o := and(add(resultLength, 31), w) } 1 {} {
                    mstore(add(result, o), mload(add(subject, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
                }
                // Zeroize the slot after the string.
                mstore(add(add(result, 0x20), resultLength), 0)
                // Allocate memory for the length and the bytes,
                // rounded up to a multiple of 32.
                mstore(0x40, add(result, and(add(resultLength, 63), w)))
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
                if iszero(lt(searchLength, 32)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(32, and(searchLength, 31)))
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
            let w := not(31)
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
                    for { let o := and(add(elementLength, 31), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    // Zeroize the slot after the string.
                    mstore(add(add(element, 0x20), elementLength), 0)
                    // Allocate memory for the length and the bytes,
                    // rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(elementLength, 63), w)))
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
            let w := not(31)
            result := mload(0x40)
            let aLength := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(mload(a), 32), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLength := mload(b)
            let output := add(result, mload(a))
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLength, 32), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLength := add(aLength, bLength)
            let last := add(add(result, 0x20), totalLength)
            // Zeroize the slot after the string.
            mstore(last, 0)
            // Stores the length.
            mstore(result, totalLength)
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 31), w))
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
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
                let flags := shl(add(70, shl(5, toUpper)), 67108863)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(subject, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
                }
                // Restore the result.
                result := mload(0x40)
                // Stores the string length.
                mstore(result, length)
                // Zeroize the slot after the string.
                let last := add(add(result, 0x20), length)
                mstore(last, 0)
                // Allocate memory for the length and the bytes,
                // rounded up to a multiple of 32.
                mstore(0x40, and(add(last, 31), not(31)))
            }
        }
    }

    /// @dev Returns a lowercased copy of the string.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let end := add(s, mload(s))
                result := add(mload(0x40), 0x20)
                // Store the bytes of the packed offsets and strides into the scratch space.
                // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
                mstore(0x1f, 0x900094)
                mstore(0x08, 0xc0000000a6ab)
                // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
                mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(result, c)
                    result := add(result, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(result, mload(and(t, 31)))
                result := add(result, shr(5, t))
            }
            let last := result
            // Zeroize the slot after the string.
            mstore(last, 0)
            // Restore the result to the start of the free memory.
            result := mload(0x40)
            // Store the length of the result.
            mstore(result, sub(last, add(result, 0x20)))
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 31), not(31)))
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let end := add(s, mload(s))
                result := add(mload(0x40), 0x20)
                // Store "\\u0000" in scratch space.
                // Store "0123456789abcdef" in scratch space.
                // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
                // into the scratch space.
                mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
                // Bitmask for detecting `["\"","\\"]`.
                let e := or(shl(0x22, 1), shl(0x5c, 1))
            } iszero(eq(s, end)) {} {
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
            let last := result
            // Zeroize the slot after the string.
            mstore(last, 0)
            // Restore the result to the start of the free memory.
            result := mload(0x40)
            // Store the length of the result.
            mstore(result, sub(last, add(result, 0x20)))
            // Allocate memory for the length and the bytes,
            // rounded up to a multiple of 32.
            mstore(0x40, and(add(last, 31), not(31)))
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
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
    /// If `packed` is not an output of {packOne}, the output behaviour is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            result := mload(0x40)
            // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(0x40, add(result, 0x40))
            // Zeroize the length slot.
            mstore(result, 0)
            // Store the length and bytes.
            mstore(add(result, 0x1f), packed)
            // Right pad with zeroes.
            mstore(add(add(result, 0x20), mload(result)), 0)
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
                    // Load the length and the bytes of `a` and `b`.
                    or(
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
    /// If `packed` is not an output of {packTwo}, the output behaviour is undefined.
    function unpackTwo(bytes32 packed)
        internal
        pure
        returns (string memory resultA, string memory resultB)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Grab the free memory pointer.
            resultA := mload(0x40)
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
            let retSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retSize), 0)
            // Store the return offset.
            mstore(retStart, 0x20)
            // End the transaction, returning the string.
            return(retStart, retSize)
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
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
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
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

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 id) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender]
                || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data)
        public
        virtual
    {
        transferFrom(from, to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0x80ac58cd // ERC165 Interface ID for ERC721
            || interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata)
        external
        virtual
        returns (bytes4)
    {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Efficient library for creating string representations of integers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/LibString.sol)
library LibString {
    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but we allocate 160 bytes
            // to keep the free memory pointer word aligned. We'll need 1 word for the length, 1 word for the
            // trailing zeros padding, and 3 other words for a max of 78 digits. In total: 5 * 32 = 160 bytes.
            let newFreeMemoryPointer := add(mload(0x40), 160)

            // Update the free memory pointer to avoid overriding our string.
            mstore(0x40, newFreeMemoryPointer)

            // Assign str to the end of the zone of newly allocated memory.
            str := sub(newFreeMemoryPointer, 32)

            // Clean the last word of memory it may not be overwritten.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 { } {
                // Move the pointer 1 byte to the left.
                str := sub(str, 1)

                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))

                // Keep dividing temp until zero.
                temp := div(temp, 10)

                // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute and cache the final total length of the string.
            let length := sub(end, str)

            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 32)

            // Store the string's length at the start of memory allocated for our string.
            mstore(str, length)
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import { ERC20 } from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(ERC20 token, address from, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
                )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
                )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success :=
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                    // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                    // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                    // Counterintuitively, this call must be positioned second to the or() call in the
                    // surrounding and() call or else returndatasize() will be zero during the computation.
                    call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
                )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IShieldsAPI } from "shields-api/interfaces/IShieldsAPI.sol";
import { Owned } from "solmate/auth/Owned.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { LibString } from "solmate/utils/LibString.sol";

import { ICurta } from "@/contracts/interfaces/ICurta.sol";
import { Base64 } from "@/contracts/utils/Base64.sol";

/// @title The Authorship Token ERC-721 token contract
/// @author fiveoutofnine
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// @notice ``Authorship Tokens'' are ERC-721 tokens that are required to add
/// puzzles to Curta. Each Authorship Token may be used like a ticket once.
/// After an Authorship Token has been used to add a puzzle, it can never be
/// used again to add another puzzle. As soon as a puzzle has been deployed and
/// added to Curta, anyone may attempt to solve it.
/// @dev Other than the initial distribution, the only way to obtain an
/// Authorship Token will be to be the first solver to any puzzle on Curta.
contract AuthorshipToken is ERC721, Owned {
    using LibString for uint256;

    // -------------------------------------------------------------------------
    // Constants
    // -------------------------------------------------------------------------

    /// @notice The shields API contract.
    /// @dev This is the mainnet address.
    IShieldsAPI constant shieldsAPI = IShieldsAPI(0x740CBbF0116a82F64e83E1AE68c92544870B0C0F);

    /// @notice Salt used to compute the seed in {AuthorshipToken.tokenURI}.
    bytes32 constant SALT = bytes32("Curta.AuthorshipToken");

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Emitted when there are no tokens available to claim.
    error NoTokensAvailable();

    /// @notice Emitted when `msg.sender` is not authorized.
    error Unauthorized();

    // -------------------------------------------------------------------------
    // Immutable Storage
    // -------------------------------------------------------------------------

    /// @notice The Curta / Flags contract.
    address public immutable curta;

    /// @notice The number of seconds until an additional token is made
    /// available for minting by the author.
    uint256 public immutable issueLength;

    /// @notice The timestamp of when the contract was deployed.
    uint256 public immutable deployTimestamp;

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    /// @notice The number of tokens that have been claimed by the owner.
    uint256 public numClaimedByOwner;

    /// @notice The total supply of tokens.
    uint256 public totalSupply;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _curta The Curta / Flags contract.
    /// @param _issueLength The number of seconds until an additional token is
    /// made available for minting by the author.
    /// @param _authors The list of authors in the initial batch.
    constructor(address _curta, uint256 _issueLength, address[] memory _authors)
        ERC721("Authorship Token", "AUTH")
        Owned(msg.sender)
    {
        curta = _curta;
        issueLength = _issueLength;
        deployTimestamp = block.timestamp;

        // Mint tokens to the initial batch of authors.
        uint256 length = _authors.length;
        for (uint256 i; i < length;) {
            _mint(_authors[i], i + 1);
            unchecked {
                ++i;
            }
        }

        // [MIGRATION] Mint 1 token to `sampriti.eth`
        _mint(0x58593392d72A9D90b133e1C8ecEec581C354687f, length + 1);
        totalSupply = length + 1;
    }

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /// @notice Mints a token to `_to`.
    /// @dev Only the Curta contract can call this function.
    /// @param _to The address to mint the token to.
    function curtaMint(address _to) external {
        // Revert if the sender is not the Curta contract.
        if (msg.sender != curta) revert Unauthorized();

        unchecked {
            uint256 tokenId = ++totalSupply;

            _mint(_to, tokenId);
        }
    }

    /// @notice Mints a token to `_to`.
    /// @dev Only the owner can call this function. The owner may claim a token
    /// every `issueLength` seconds.
    /// @param _to The address to mint the token to.
    function ownerMint(address _to) external onlyOwner {
        unchecked {
            uint256 numIssued = (block.timestamp - deployTimestamp) / issueLength;
            uint256 numMintable = numIssued - numClaimedByOwner++;

            // Revert if no tokens are available to mint.
            if (numMintable == 0) revert NoTokensAvailable();

            // Mint token
            uint256 tokenId = ++totalSupply;

            _mint(_to, tokenId);
        }
    }

    // -------------------------------------------------------------------------
    // ERC721Metadata
    // -------------------------------------------------------------------------

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @param _tokenId The token ID.
    /// @return URI for the token.
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_ownerOf[_tokenId] != address(0), "NOT_MINTED");

        // Generate seed.
        uint256 seed = uint256(keccak256(abi.encodePacked(_tokenId, SALT)));

        // Bitpacked colors.
        uint256 colors = 0x6351CEFF00FFB300FF6B00B5000A007FFF78503C323232FE7FFF6C28A2FF007A;

        // Shuffle `colors` by performing 4 iterations of Fisher-Yates shuffle.
        // We do this to pick 4 unique colors from `colors`.
        unchecked {
            uint256 shift = 24 * (seed % 11);
            colors = (colors & ((type(uint256).max ^ (0xFFFFFF << shift)) ^ 0xFFFFFF))
                | ((colors & 0xFFFFFF) << shift) | ((colors >> shift) & 0xFFFFFF);
            seed >>= 4;

            shift = 24 * (seed % 10);
            colors = (colors & ((type(uint256).max ^ (0xFFFFFF << shift)) ^ (0xFFFFFF << 24)))
                | (((colors >> 24) & 0xFFFFFF) << shift) | (((colors >> shift) & 0xFFFFFF) << 24);
            seed >>= 4;

            shift = 24 * (seed % 9);
            colors = (colors & ((type(uint256).max ^ (0xFFFFFF << shift)) ^ (0xFFFFFF << 48)))
                | (((colors >> 48) & 0xFFFFFF) << shift) | (((colors >> shift) & 0xFFFFFF) << 48);
            seed >>= 4;

            shift = 24 * (seed & 7);
            colors = (colors & ((type(uint256).max ^ (0xFFFFFF << shift)) ^ (0xFFFFFF << 72)))
                | (((colors >> 72) & 0xFFFFFF) << shift) | (((colors >> shift) & 0xFFFFFF) << 72);
            seed >>= 3;
        }

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                abi.encodePacked(
                    '{"name":"Authorship Token #',
                    _tokenId.toString(),
                    '","description":"This token allows 1 puzzle to be added to Curta. Once it has '
                    'been used, it can never be used again.","image_data":"data:image/svg+xml;base6'
                    "4,",
                    Base64.encode(
                        abi.encodePacked(
                            '<svg width="750" height="750" xmlns="http://www.w3.org/2000/svg" fill='
                            '"none" viewBox="0 0 750 750"><style>.a{filter:url(#c)drop-shadow(0 0 2'
                            "px #007fff);fill:#fff;width:4px}.b{filter:drop-shadow(0 0 .5px #007fff"
                            ");fill:#000;width:3px}.c{height:13px}.d{height:6px}.e{height:4px}.f{he"
                            "ight:12px}.g{height:5px}.h{height:3px}.i{width:320px;height:620px}.j{c"
                            "x:375px;r:20px}.k{stroke:#27303d}.l{fill:#000}.n{fill:#0d1017}.o{strok"
                            'e-width:2px}@font-face{font-family:"A";src:url(data:font/woff2;charset'
                            "=utf-8;base64,d09GMgABAAAAABFIAA8AAAAAIkwAABDvAAEAAAAAAAAAAAAAAAAAAAAA"
                            "AAAAAAAAHIFYBmAAPAiBCgmXYhEICp9Am3cLQgABNgIkA0IEIAWDTAcgDIExGzcfE24MPW"
                            "wcDIypV8n+6wPbWHpYvwUfDDXpJJFBslTuUGiwURSfehX/e+bvN6mwulNEycH87rF0PSHI"
                            "FQ6frhshySw8/9Scf9/MJISZENRCTVFJ1cErnlKV3fCVijl22lBTW3X3ffk7sF1tDOFpz3"
                            "ulSlfAabKmnF0P4oO2fq29SR7sfaASK3SVZcuSrsSqs2ba0noIACigkR+0RR3auT4I9sP0"
                            "SVMG/h9t36wowdPc8MB/BrGVwfJtxfAEzawVNUU9XXUyuP84V72fJk1TzgBQZhYxC9gekU"
                            "Nhz5h1atzZDSj//9es7H0/lQGuGT4e6XiUalRBoP6vADYkPQw1aeL0ALMknWQQFKMiVrss"
                            "zLp1cq3f5XA2MbxTH7ZlmG9qAh5RGLTi3/buX4sAOtmYKD17DyzGNX3c/JkkoAFYFiqgoL"
                            "lcoKwN+8SZs2bQJpy/039f0IT07mYumDGX3OkeQKhtalzAJiHFqmDHRepg85j2HtMhYXoI"
                            "Qja+acMcHkFiWRYc64dhBHE74RiyoF9YUybKGmygLFPKgQE3mWU0qdIeFGz+mufSyI0eTo"
                            "/ebjdXaEmONvbHdNDGSrUbWQ8gfyoXADcUpJDKwxZTQlmjHdljgkI92rIAkHysWd+tiwiI"
                            "D5Xor0lTmjPIn2Bl2xlLdc/6xALygxzlIHIGSp5aRIVlzTcyxsJaE5QLskMtpMy7JpvuPj"
                            "Uo2MWFiwACT2mape1/WBm2jfvwKbF3yOytnKr/kmDe/ffSHOMjO3TegzdAmwwQWGKAQK+c"
                            "Bhh0LF7h+dMwkwVOj6a4TfI4nt98Vtdg3vXfxfuD5LHZiSN72tFbVsUc3R0zeztLSohtiS"
                            "0svM6iU/Uv3Qmfl4/otQv/jh3g4A0oOWcHRc4GbtNJzgEHmgru3bEQPEgIi7gWnfcZKgEO"
                            "8+Z1XMUoKtO09Tjp2lUOvJjROEPveThU3/tfL0bd6jo8v07lwHVvcrLss7BvExTOLIdsVZ"
                            "QXQPLOgBZIcA2J124CFjvY6BQaQwUxDEhIzTQBj/7xNBKgmC25O1wmzuk8DHIxcRpve9ih"
                            "ai6Dx+eQS2Guk8G9aNoPq46hCuEQzpn0DrEA5cNx6ybsFycgDTIqICT1EGrGPKQhWGg3yT"
                            "vz+bYPRKis1fC3mwRiQEUi5Jar7lMsZqIS3VOUGEgg0ul47PrH07gfVmIW9T9FbNECKbbf"
                            "pconk3yVaGo/Ahrbr9P224ag88ZW7LKAitUe741kKQXVSBLZmCnMYw0TiopBOyYcr0WduE"
                            "S4x/5FIgsNvUH1weP6wNRJz2bNhJwTgeqoZZ7qMnvnrUhnbAIRXAwkkj7vIhYqrV7vEolF"
                            "TQks4hu8RBWo/k7XFtMKN7H/WQszwb877koOlFCxeSdgNLsxYo4J88ywwByLLLDEEsusYI"
                            "U1WGWdETtghEGeEbdsv0umBvraHesHFh31K9LvwKb+RPo7pjtYICDGRl1S6pFSn5QGpDQk"
                            "pREpjUlpQkpTUpqRjl1C7RrFylpIi8Z2N8fzOIYKy236t9kAq2A1DGxCmmsBx1i3Ys+Gde"
                            "8VbuTYckbHpx02h1XI9jTdy8b5t0FJ3jV2B3qsK99NWYU0AuJQCE7aNgY7v4D+PpPntlJ3"
                            "ZPt2YA9qNdc1B5B+QYF9NBfawMGwAORUY4sforK0c02NigE7EJM2+5e5DbfaKR06nyGLw4"
                            "HI9tnbgSOAHbjDvTs1indO+g2T2v7IN9BxRA39GLhFjJj4+TxR3L5OP9np8qlbpuTlgxyf"
                            "O6d6VD/EzLFZoYVyD4ry/OV4qUjBWI4Nh90xqbdg54Qoz1214l9VZxI826xbcYbHGcxXXc"
                            "IqizxhNjenKLAfXHiH4BiD59GYroC6eA6eHavJMXIrTsbfkyREzrF25c922geeRUkzTZC2"
                            "UOKsTVfeCebp8JgateYdrGE9IaY76Ppjgc0XcccsJd28zkURtobF+UkH2pkp9UZ75dR3ze"
                            "OUC5gawFLO3iS1uakbsnXnr/7lIAcLsZjJ+w99NeIoGM56PeI4+t5HWymr6o9cC5wNG3H+"
                            "m82F7F5/o0ytyLvC6ti+HVWv43Ed/ifmG09TXXtu2b+1FeeXOuqzfuJuIlxjZ/dRb/5KbM"
                            "VcevBs78zQgCNonHE12BsOzeOkp1GF3ILsi9HPIw5XZKfCztTUaNYPK0ShfLQWg2Sn5c1o"
                            "yAroqWgwEwxpJNBQJhgmQy8azgQjGglUzAQlMnSjUiYoayRQORNUyNCDKpmgqpFAI5lglA"
                            "y9aTQTjGkk0FgmGCdDdxrPBBMaCTSRycRJnXy5UywmPwr6CrXNS0WYEiLCJg+q/XmYmCrl"
                            "YZqUZ053yIMZ/vwCM6V8zJLyMVvKx5z6BZgrFWCeVID5UkGhBZ2O+2vKmy6je13YMcmnth"
                            "q6+PUkQ2cEsSwCQY3cNPAwuRWoToMjDRmK4jL2YEBFAq9ic5UWqbQsykJncsHOgA6dDFtq"
                            "+4iQ5CAXnilOc7mczhZuw5YU5wxKOBW47qqa18byl2C+0Je9kpLlr0VqXl27py+7c+UFmC"
                            "9DuGxcFLhwtksTbHq5LlWGZuCUWZNSNub56z6vhzc8dklVXP+K19zMp2Gw+AWepkrKxCkB"
                            "FNMmnkhS+mIiBmbzxbsYu3/5uNB70qcZioGOLk4pwVD1KjUAJ8b2o+fvE7IX0jP+UvmvC/"
                            "9zTtTVhXlrXunL7lzwgXH0NT5eVVdNlAt0UumDdTUSxgQwsa7JiHLbdx+N9YpznKAMNccv"
                            "n28rh84dOcYAj1WJhyfD9DWdacXBsxebjfKUwmfoQg8iRlXZ6fEy4xAa0pv0GejZgi9HNl"
                            "+VPZ+h5aQJoqNPjcVobNAYnVcai9d8oi97lmY8z5j8lOLljWQ0fIrVgVlfWtNoRtVj1tWJ"
                            "DV7Ri/UyugbiLSQ1l7NObx9m6qcSJ+t3Yl5J34KxaVImS1+88EXY68CjXjQW5jQmulLBDC"
                            "g8RvQxjvrMq5i5pxp2kde0xy/bEDZNyghjc2O/U2E8VH9dXPONMSjesGUhiseWie5ddqqh"
                            "QfPLSl3F46EWs64VBy/C8LoTXXhrtPOXPXi8rEaJvqHu5b0Giy5whUeCM2teY23Nxvnzp8"
                            "m1O1bUrN2vYO2K/54OGzrbuyY5dHDt43aqy7UiJ3mN9zPjCpMFbBf7/IwolBQHNYAMMEi2"
                            "eOax5Af+SYKk5Ftty4uNXpQhSvBSk+NwwKH6VqiSnNnJWieKCDxBEZkKR5BPuicuUQmnFt"
                            "ZVM3IDfJHhfP2bzKbHE6ExyVcGyDdWqYxjDWwRi8A6SdIPtzB7tiQsWOxEcCciH3XnqlQ0"
                            "dFMTH4SkRDvCZLv3v6pKrhriHBLZFMOC/hyD9ElxDduSi35Bk7+sFiGpgpnuNBRGBd6gSL"
                            "mfVrbkv9wY10nPyEpPUJ4ZQA2VAEFUTLSAppnkp+575H1YSnKMePiKalkZ1NtrNCNp/NVu"
                            "Jw4FSl2hQV5RYKBXFOqQOrH/T2W+sGC3CEVdvBviVPTZZumyrT4JJOk5c5lYPL2+VUgVec"
                            "/vOTZm95Ve8r1Dspn8dClc+6DoO3+tc4xQSTC5uJeEkSpI6rG+HgaV9H5K5kFKQfj6VDYK"
                            "jGns9YnhSohHfjraDQ17bfVIIZUw8pKLa+qQEOmMsoBgd0QUiHJHBAOLMyqyc0ZIUhgKsM"
                            "Tg0NDEYAygSWEx804b0aBKnqbSZbQa03i73BmsmMQdGuwVm0xT8dAgiQv7Y5F6X6M9IgxD"
                            "m6j98u1+cbdtM6ZKxNMOn803a3lsaXGvql6xvWpia6pQPWqUcmJ0Vf2N9J35T2/D0Aq9X9"
                            "/LiNn0JZMYcyJK6HMiGXvW697jX0wUEYjticR2LoIQlZ6+1I2WZRL0qvgQc+804puiH+Rh"
                            "XP3n178mUvxMxuoYGIfVlRgzue0ARYr9NLcGAD2Vl5jGAROR3cVwvUD6Q6Ep0iFtCjJOZI"
                            "yKZAwPYx6mbEjYPWGXElHi/Vs3qPtvkD4H6C+zF15Ahg0FHXTyC1qDA+f1H7kBBjiGM+fF"
                            "M4pJhNeMcH8p7KHTfHQ5SBjIUlxTGYZ01BVqq3QFGm2KOieINiqSMSr86jn1ur37gDd/Si"
                            "+6sw1nXmDQnebqnfZNiSkbw3IOuCISSLdrnxIkfdu379sy4ZNmTychwnWgX9ewkKsoE/pz"
                            "6N6QkL2hztbp5fhDpt8flVD9cML/Ozd7gN1lD7QH2YPtIfZQexgLv0pQLe5ZGLcxhqeWlf"
                            "uo4AGTtzAGmPqke7wB+CPw7rP5phD/4Jp/h+u0/7/3F55NOEIenxjDI5A4wKXER8gNypPh"
                            "7mw0qFXibtIdD6ScM3YFwUCrAKVFNJ+5ITNvUV/gOcCJ/kQXtJZy0VgDo1NeIe0RY+uZoD"
                            "taIIocaM+8dXFDu3LB2AuHFF3gBZqRHhUpTFe+A6SFnM+wwSW04ZCm7MiidXk+1EVPLlEL"
                            "Y/hGQkhQYo5RJS0u0QDUeCwoUVz3d51KuWyyNeO73UI02URWpMMm1LxDOuEvYoylo8WlV6"
                            "lv8Lzp2XAOb1Bk5ZOsenamH1YDUthuPyzPR7q/Nl+uGHvnMSCEKixZKLwsClU+AW6h9Uwx"
                            "c5zXtGgPZKTNLxYXmDFrPx+UBz64p2oHMlG8QFT8ZHKB8lpE6sh5Y29HLcPAzXnh0WFy+8"
                            "QGHyHXM0kJj3YCbvJudjuZcNbbvrl6c5y5dbl9Ua9gUzaUnDH2DmZJluoxBAUqD0XRp4LT"
                            "1zOAwXVS9SFma9Z3Ow4MZH0JNLw7mOOIMfkcd+UerSqKWJpkvnQbocRNTTvtzMLfyfKSbV"
                            "zo+oftgP9JojCaNGPqtd8m9mu0oWybrQ62kidABygizeao16mU4mbSZFD5szXxu+2seN+f"
                            "N/C+ONDR3z0QSXu1xac4z0BPi0WqXTHQiS23iyR6LYtzKOO/CNG8c2Tr7t/tAoYM/Z0syB"
                            "80Rt//4bDt0xNOjWYyQczsMZTVX4lnibna/u9fw48fNgFIpNOyOCrpgaeOILkARCV5DiXe"
                            "8EXPWQ4OdEcIGO720kah2SLjqQvJDI/8QxCp+ISkGFe3R3nHBbjptZqOhlrLslxLBpmZyk"
                            "E4K2xIxAgAq+1G6J+KTlnejgNaJrWm7SmaNFuPJgOlFoxtKbSLWA4OaExq19dlBwsGPkHR"
                            "rXTs0O0Q9rou9s3+eNiZd+dpjFVpKzWjZGOGhaCjqkKgBz9VUzEKPhhjXewSzahn/t/pS9"
                            "uHUpZUqS1MbX6NCCB0X3Go/OuYwPz/mlj1O8Dz6R9eAbxMJbdG+3Ffma11B/xRABD44auE"
                            "MhHN+jezsRbExZke8snDQxEpdF/kvhRZe3OPpzwY5Hs8Eh/s5PWHI4CbKdiZgw2FLhSyCG"
                            "gwvqEigB+Vd+U1f2A0EHYUwhjdUcHF3I4q2ZgdNVpxpqON+XxIb6eFDKUHs5jNkqLJ1XiZ"
                            "EkrvJpVkUsjETR/FZ7nk6Uzquh8zmUAX3u1D0/3DKcx5JT5pmzyJuSxUfGJS4ghmM44JlL"
                            "mDmEViFoaazhcgH5fEU7iZLKtkHiUMoIzBh5vGHSyks52c68LcoVmqR3we1X0LuuWsP5QR"
                            "NUrjU+r4fCbg+ReG8S5kh4kzGMc0JvXzyQ7rdKoZTypQxuRM0khPXNJMrcMqaFitk6QCwo"
                            "kHnOHO8PJmkVUVPvmKMvPsZvy6nwRaaHR4OKlH7ymZ9va2cIfmqPTXi0I1WUm0n83ofjHY"
                            "E3BFN20mGv4SgQMAJiae1Co9m1tJ7bByn6e2vMVE1maWcw4T0arYhOLybl7RX6FH70WOrZ"
                            'MW6dCcHc6I9atPW9msuGc/bptop2dPAAA=)}</style><defs><radialGradient id="'
                            'b"><stop stop-color="#007FFF"/><stop offset="100%" stop-opacity="0"/><'
                            '/radialGradient><filter id="c"><feGaussianBlur stdDeviation="8" in="So'
                            'urceGraphic" result="offset-blur"/><feComposite operator="out" in="Sou'
                            'rceGraphic" in2="offset-blur" result="inverse"/><feFlood flood-color="'
                            '#007FFF" flood-opacity=".95" result="color"/><feComposite operator="in'
                            '" in="color" in2="inverse" result="shadow"/><feComposite in="shadow" i'
                            'n2="SourceGraphic"/><feComposite operator="atop" in="shadow" in2="Sour'
                            'ceGraphic"/></filter><mask id="a"><path fill="#000" d="M0 0h750v750H0z'
                            '"/><rect class="i" x="215" y="65" rx="20" fill="#FFF"/><circle class="'
                            'j l" cy="65"/><circle class="j l" cy="685"/></mask></defs><path fill="'
                            '#10131C" d="M0 0h750v750H0z"/><rect class="i n" x="215" y="65" mask="u'
                            'rl(#a)" rx="20"/><circle mask="url(#a)" fill="url(#b)" cx="375" cy="38'
                            '1" r="180"/><circle class="j k n" cy="125"/><g transform="translate(35'
                            '9 110)"><circle class="n" cy="16" cx="16" r="16"/><rect class="a c" x='
                            '"8" y="7" rx="2"/><rect class="b f" x="8.5" y="7.5" rx="1.5"/><rect cl'
                            'ass="a e" x="8" y="21" rx="2"/><rect class="b h" x="8.5" y="21.5" rx="'
                            '1.5"/><rect class="a d" x="14" y="7" rx="2"/><rect class="b g" x="14.5'
                            '" y="7.5" rx="1.5"/><rect class="a e" x="14" y="14" rx="2"/><rect clas'
                            's="b h" x="14.5" y="14.5" rx="1.5"/><rect class="a d" x="14" y="19" rx'
                            '="2"/><rect class="b g" x="14.5" y="19.5" rx="1.5"/><rect class="a c" '
                            'x="20" y="12" rx="2"/><rect class="b f" x="20.5" y="12.5" rx="1.5"/><r'
                            'ect class="a e" x="20" y="7" rx="2"/><rect class="b h" x="20.5" y="7.5'
                            '" rx="1.5"/></g><path d="M338.814 168.856c-.373 0-.718-.063-1.037-.191'
                            "a2.829 2.829 0 0 1-.878-.606 2.828 2.828 0 0 1-.606-.878 2.767 2.767 0"
                            " 0 1-.193-1.037v-.336c0-.372.064-.723.192-1.053.138-.319.34-.611.606-."
                            "877a2.59 2.59 0 0 1 .878-.59 2.58 2.58 0 0 1 1.038-.208h4.26c.245 0 .4"
                            "8.032.703.096.212.053.425.143.638.27.223.118.415.256.574.416.16.16.304"
                            ".345.431.558.043.064.07.133.08.208a.301.301 0 0 1-.016.095.346.346 0 0"
                            " 1-.175.256.42.42 0 0 1-.32.032.333.333 0 0 1-.239-.192 3.016 3.016 0 "
                            "0 0-.303-.399 2.614 2.614 0 0 0-.415-.303 1.935 1.935 0 0 0-.463-.191 "
                            "1.536 1.536 0 0 0-.495-.048c-.712 0-1.42-.006-2.122-.016-.713 0-1.425."
                            "005-2.138.016-.266 0-.51.042-.734.127-.234.096-.442.24-.623.431a1.988 "
                            "1.988 0 0 0-.43.623 1.961 1.961 0 0 0-.144.75v.335a1.844 1.844 0 0 0 ."
                            "574 1.356 1.844 1.844 0 0 0 1.356.574h4.261c.17 0 .33-.015.48-.047a2.0"
                            "2 2.02 0 0 0 .446-.192c.149-.074.282-.165.399-.271.106-.107.207-.229.3"
                            "03-.367a.438.438 0 0 1 .255-.144c.096-.01.187.01.272.064a.35.35 0 0 1 "
                            ".16.24.306.306 0 0 1-.033.27 2.653 2.653 0 0 1-.43.527c-.16.139-.346.2"
                            "66-.559.383-.213.117-.42.197-.622.24-.213.053-.436.08-.67.08h-4.262Zm1"
                            "7.553 0c-.713 0-1.324-.266-1.835-.797a2.69 2.69 0 0 1-.766-1.931v-2.66"
                            "5c0-.117.037-.213.112-.287a.37.37 0 0 1 .27-.112c.118 0 .214.037.288.1"
                            "12a.39.39 0 0 1 .112.287v2.664c0 .533.18.99.542 1.373a1.71 1.71 0 0 0 "
                            "1.293.559h3.878c.51 0 .941-.187 1.292-.559a1.93 1.93 0 0 0 .543-1.372v"
                            "-2.665a.39.39 0 0 1 .111-.287.389.389 0 0 1 .288-.112.37.37 0 0 1 .271"
                            ".112.39.39 0 0 1 .112.287v2.664c0 .756-.256 1.4-.766 1.932-.51.531-1.1"
                            "28.797-1.851.797h-3.894Zm23.824-.718a.456.456 0 0 1 .16.192c.01.042.01"
                            "6.09.016.143a.47.47 0 0 1-.016.112.355.355 0 0 1-.143.208.423.423 0 0 "
                            "1-.24.063h-.048a.141.141 0 0 1-.064-.016c-.02 0-.037-.005-.047-.016a10"
                            "4.86 104.86 0 0 1-1.18-.83c-.374-.265-.746-.531-1.118-.797-.011 0-.016"
                            "-.006-.016-.016-.01 0-.016-.005-.016-.016-.01 0-.016-.005-.016-.016h-5"
                            ".553v1.324a.39.39 0 0 1-.112.288.425.425 0 0 1-.287.111.37.37 0 0 1-.2"
                            "72-.111.389.389 0 0 1-.111-.288v-4.946c0-.054.005-.107.016-.16a.502.50"
                            "2 0 0 1 .095-.128.374.374 0 0 1 .128-.08.316.316 0 0 1 .144-.031h6.893"
                            "c.256 0 .49.048.702.143.224.085.42.218.59.4.182.18.32.377.416.59.085.2"
                            "23.127.457.127.702v.335c0 .223-.032.43-.095.622a2.107 2.107 0 0 1-.32."
                            "527c-.138.18-.292.319-.462.415-.17.106-.362.186-.575.24l.702.51c.234.1"
                            "7.469.345.703.526Zm-8.281-4.228v2.425h6.494a.954.954 0 0 0 .4-.08.776."
                            "776 0 0 0 .334-.223c.107-.106.186-.218.24-.335.053-.128.08-.266.08-.41"
                            "5v-.32a.954.954 0 0 0-.08-.398 1.232 1.232 0 0 0-.224-.351 1.228 1.228"
                            " 0 0 0-.35-.224.954.954 0 0 0-.4-.08h-6.494Zm24.67-.782c.106 0 .202.03"
                            "7.287.111a.37.37 0 0 1 .112.272.39.39 0 0 1-.112.287.425.425 0 0 1-.28"
                            "7.112h-3.64v4.579a.37.37 0 0 1-.111.272.348.348 0 0 1-.271.127.397.397"
                            " 0 0 1-.288-.127.37.37 0 0 1-.111-.272v-4.579h-3.639a.37.37 0 0 1-.271"
                            "-.111.39.39 0 0 1-.112-.287.37.37 0 0 1 .112-.272.37.37 0 0 1 .271-.11"
                            "1h8.058Zm15.782-.048c.723 0 1.34.266 1.85.798.511.532.767 1.17.767 1.9"
                            "15v2.68a.37.37 0 0 1-.112.272.397.397 0 0 1-.287.127.348.348 0 0 1-.27"
                            "2-.127.348.348 0 0 1-.127-.272v-1.196h-7.532v1.196a.348.348 0 0 1-.128"
                            ".272.348.348 0 0 1-.271.127.348.348 0 0 1-.271-.127.348.348 0 0 1-.128"
                            "-.272v-2.68c0-.745.255-1.383.766-1.915.51-.532 1.128-.798 1.851-.798h3"
                            ".894Zm-5.697 3.415h7.548v-.702c0-.532-.176-.984-.527-1.357-.362-.383-."
                            "792-.574-1.292-.574H408.5c-.51 0-.942.191-1.293.574a1.875 1.875 0 0 0-"
                            ".542 1.357v.702ZM297.898 204.5h4.16l1.792-5.152h9.408l1.824 5.152h4.44"
                            "8l-8.704-23.2h-4.288l-8.64 23.2Zm10.624-18.496 3.52 9.952h-7.008l3.488"
                            "-9.952Zm22.81 18.496h3.807v-17.216h-3.808v9.184c0 3.104-1.024 5.344-3."
                            "872 5.344s-3.168-2.272-3.168-4.608v-9.92h-3.808v10.848c0 4.096 1.664 6"
                            ".784 5.76 6.784 2.336 0 4.096-.992 5.088-2.784v2.368Zm7.678-17.216h-2."
                            "56v2.752h2.56v9.952c0 3.52.736 4.512 4.416 4.512h2.816v-2.912h-1.376c-"
                            "1.632 0-2.048-.416-2.048-2.176v-9.376h3.456v-2.752h-3.456v-4.544h-3.80"
                            "8v4.544Zm13.179-5.984h-3.809v23.2h3.808v-9.152c0-3.104 1.088-5.344 4-5"
                            ".344s3.264 2.272 3.264 4.608v9.888h3.808v-10.816c0-4.096-1.696-6.784-5"
                            ".856-6.784-2.4 0-4.224.992-5.216 2.784V181.3Zm16.86 14.624c0-3.968 2.1"
                            "44-5.92 4.544-5.92 2.4 0 4.544 1.952 4.544 5.92s-2.144 5.888-4.544 5.8"
                            "88c-2.4 0-4.544-1.92-4.544-5.888Zm4.544-9.024c-4.192 0-8.48 2.816-8.48"
                            " 9.024 0 6.208 4.288 8.992 8.48 8.992s8.48-2.784 8.48-8.992c0-6.208-4."
                            "288-9.024-8.48-9.024Zm20.057.416a10.32 10.32 0 0 0-.992-.064c-2.08.032"
                            "-3.744 1.184-4.672 3.104v-3.072h-3.744V204.5h3.808v-9.024c0-3.456 1.37"
                            "6-4.416 3.776-4.416.576 0 1.184.032 1.824.096v-3.84Zm14.665 4.672c-.70"
                            "4-3.456-3.776-5.088-7.136-5.088-3.744 0-7.008 1.952-7.008 4.992 0 3.13"
                            "6 2.272 4.448 5.184 5.024l2.592.512c1.696.32 2.976.96 2.976 2.368s-1.4"
                            "72 2.24-3.456 2.24c-2.24 0-3.52-1.024-3.872-2.784h-3.712c.416 3.264 3."
                            "232 5.664 7.456 5.664 3.904 0 7.296-1.984 7.296-5.568 0-3.36-2.656-4.4"
                            "48-6.144-5.12l-2.432-.48c-1.472-.288-2.304-.896-2.304-2.048 0-1.152 1."
                            "536-1.888 3.2-1.888 1.92 0 3.36.608 3.776 2.176h3.584Zm6.284-10.688h-3"
                            ".808v23.2h3.808v-9.152c0-3.104 1.088-5.344 4-5.344s3.264 2.272 3.264 4"
                            ".608v9.888h3.808v-10.816c0-4.096-1.696-6.784-5.856-6.784-2.4 0-4.224.9"
                            "92-5.216 2.784V181.3Zm14.076 0v3.84h3.808v-3.84h-3.808Zm0 5.984V204.5h"
                            "3.808v-17.216h-3.808Zm10.781 8.608c0-3.968 1.952-5.888 4.448-5.888 2.6"
                            "56 0 4.256 2.272 4.256 5.888 0 3.648-1.6 5.92-4.256 5.92-2.496 0-4.448"
                            "-1.952-4.448-5.92Zm-3.648-8.608V210.1h3.808v-7.872c1.024 1.696 2.816 2"
                            ".688 5.12 2.688 4.192 0 7.392-3.488 7.392-9.024 0-5.504-3.2-8.992-7.39"
                            '2-8.992-2.304 0-4.096.992-5.12 2.688v-2.304h-3.808Z" fill="#F0F6FC"/><'
                            'path class="k" stroke-dashoffset="5" stroke-dasharray="10" d="M215 545'
                            'h320"/><g transform="translate(231 237) scale(0.384)">',
                            shieldsAPI.getShieldSVG({
                                field: uint16(seed % 300),
                                colors: [
                                    uint24(colors & 0xFFFFFF),
                                    uint24((colors >> 24) & 0xFFFFFF),
                                    uint24((colors >> 48) & 0xFFFFFF),
                                    uint24((colors >> 72) & 0xFFFFFF)
                                ],
                                hardware: uint16((seed >> 9) % 120),
                                frame: uint16((seed >> 17) % 5)
                            }),
                            '</g><text font-family="A" x="50%" y="605" fill="#F0F6FC" font-size="40'
                            '" dominant-baseline="central" text-anchor="middle">#',
                            _zfill(_tokenId),
                            '</text><rect class="i k o" x="215" y="65" mask="url(#a)" rx="20"/><cir'
                            'cle class="j k o" cy="65" mask="url(#a)"/><circle class="j k o" cy="68'
                            '5" mask="url(#a)"/></svg>'
                        )
                    ),
                    '","attributes":[{"trait_type":"Used","value":',
                    ICurta(curta).hasUsedAuthorshipToken(_tokenId) ? "true" : "false",
                    "}]}"
                )
            )
        );
    }

    // -------------------------------------------------------------------------
    // Helper Functions
    // -------------------------------------------------------------------------

    /// @notice Converts `_value` to a string with leading zeros to reach a
    /// minimum of 7 characters.
    /// @param _value Number to convert.
    /// @return string memory The string representation of `_value` with leading
    /// zeros.
    function _zfill(uint256 _value) internal pure returns (string memory) {
        string memory result = _value.toString();

        if (_value < 10) return string.concat("000000", result);
        else if (_value < 100) return string.concat("00000", result);
        else if (_value < 1000) return string.concat("0000", result);
        else if (_value < 10_000) return string.concat("000", result);
        else if (_value < 100_000) return string.concat("00", result);
        else if (_value < 1_000_000) return string.concat("0", result);

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// .===========================================================================.
// | The Curta is a hand-held mechanical calculator designed by Curt           |
// | Herzstark. It is known for its extremely compact design: a small cylinder |
// | that fits in the palm of the hand.                                        |
// |---------------------------------------------------------------------------|
// | The nines' complement math breakthrough eliminated the significant        |
// | mechanical complexity created when ``borrowing'' during subtraction. This |
// | drum was the key to miniaturizing the Curta.                              |
// '==========================================================================='

import { Owned } from "solmate/auth/Owned.sol";
import { LibString } from "solmate/utils/LibString.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";

import { FlagRenderer } from "./FlagRenderer.sol";
import { FlagsERC721 } from "./FlagsERC721.sol";
import { AuthorshipToken } from "@/contracts/AuthorshipToken.sol";
import { ICurta } from "@/contracts/interfaces/ICurta.sol";
import { IPuzzle } from "@/contracts/interfaces/IPuzzle.sol";
import { Base64 } from "@/contracts/utils/Base64.sol";

/// @title Curta
/// @author fiveoutofnine
/// @notice A CTF protocol, where players create and solve EVM puzzles to earn
/// NFTs (``Flag'').
contract Curta is ICurta, FlagsERC721, Owned {
    using LibString for uint256;

    // -------------------------------------------------------------------------
    // Constants
    // -------------------------------------------------------------------------

    /// @notice The length of Phase 1 in seconds.
    uint256 constant PHASE_ONE_LENGTH = 2 days;

    /// @notice The length of Phase 1 and Phase 2 combined (i.e. the solving
    /// period) in seconds.
    uint256 constant SUBMISSION_LENGTH = 5 days;

    /// @notice The minimum fee required to submit a solution during Phase 2.
    /// @dev This fee is transferred to the author of the relevant puzzle. Any
    /// excess fees will also be transferred to the author. Note that the author
    /// will receive at least 0.01 ether per Phase 2 solve.
    uint256 constant PHASE_TWO_MINIMUM_FEE = 0.02 ether;

    /// @notice The protocol fee required to submit a solution during Phase 2.
    /// @dev This fee is transferred to the address returned by `owner`.
    uint256 constant PHASE_TWO_PROTOCOL_FEE = 0.01 ether;

    /// @notice The default Flag colors.
    uint120 constant DEFAULT_FLAG_COLORS = 0x181E28181E2827303DF0F6FC94A3B3;

    // -------------------------------------------------------------------------
    // Immutable Storage
    // -------------------------------------------------------------------------

    /// @inheritdoc ICurta
    AuthorshipToken public immutable override authorshipToken;

    /// @inheritdoc ICurta
    FlagRenderer public immutable override flagRenderer;

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    /// @inheritdoc ICurta
    uint32 public override puzzleId = 0;

    /// @inheritdoc ICurta
    Fermat public override fermat;

    /// @inheritdoc ICurta
    mapping(uint32 => PuzzleColorsAndSolves) public override getPuzzleColorsAndSolves;

    /// @inheritdoc ICurta
    mapping(uint32 => PuzzleData) public override getPuzzle;

    /// @inheritdoc ICurta
    mapping(uint32 => address) public override getPuzzleAuthor;

    /// @inheritdoc ICurta
    mapping(address => mapping(uint32 => bool)) public override hasSolvedPuzzle;

    /// @inheritdoc ICurta
    mapping(uint256 => bool) public override hasUsedAuthorshipToken;

    // -------------------------------------------------------------------------
    // Constructor + Functions
    // -------------------------------------------------------------------------

    /// @param _authorshipToken The address of the Authorship Token contract.
    /// @param _flagRenderer The address of the Flag metadata and art renderer
    /// contract.
    constructor(AuthorshipToken _authorshipToken, FlagRenderer _flagRenderer)
        FlagsERC721("Curta", "CTF")
        Owned(msg.sender)
    {
        authorshipToken = _authorshipToken;
        flagRenderer = _flagRenderer;

        // [MIGRATION] Set puzzle ID.
        puzzleId = 1;
        // [MIGRATION] Set `getPuzzleColorsAndSolves`
        getPuzzleColorsAndSolves[1] = PuzzleColorsAndSolves({
            colors: DEFAULT_FLAG_COLORS,
            phase0Solves: 1,
            phase1Solves: 1,
            phase2Solves: 0,
            solves: 2
        });
        // [MIGRATION] Set `getPuzzle`
        getPuzzle[1] = PuzzleData({
            puzzle: IPuzzle(0xc220AE2Ac78e9Fa4B8b0BBA87bdB0Bca23F368c2),
            addedTimestamp: uint40(1677715079),
            firstSolveTimestamp: uint40(1677719903)
        });
        // [MIGRATION] Set `getPuzzleAuthor` to fiveoutofnine.eth
        getPuzzleAuthor[1] = 0xA85572Cd96f1643458f17340b6f0D6549Af482F5;
        // [MIGRATION] Set `hasSolvedPuzzle`
        hasSolvedPuzzle[0x58593392d72A9D90b133e1C8ecEec581C354687f][1] = true; // sampriti.eth
        hasSolvedPuzzle[0x03433830468d771A921314D75b9A1DeA53C165d7][1] = true; // karmacoma.eth
        // [MIGRATION] Set `hasUsedAuthorshipToken` true for AUTH #1
        hasUsedAuthorshipToken[1] = true;
    }

    /// @inheritdoc ICurta
    function solve(uint32 _puzzleId, uint256 _solution) external payable {
        // Revert if `msg.sender` has already solved the puzzle.
        if (hasSolvedPuzzle[msg.sender][_puzzleId]) {
            revert PuzzleAlreadySolved(_puzzleId);
        }

        PuzzleData memory puzzleData = getPuzzle[_puzzleId];
        IPuzzle puzzle = puzzleData.puzzle;

        // Revert if the puzzle does not exist.
        if (address(puzzle) == address(0)) revert PuzzleDoesNotExist(_puzzleId);

        // Revert if submissions are closed.
        uint40 firstSolveTimestamp = puzzleData.firstSolveTimestamp;
        uint40 solveTimestamp = uint40(block.timestamp);
        uint8 phase = _computePhase(firstSolveTimestamp, solveTimestamp);
        if (phase == 3) revert SubmissionClosed(_puzzleId);

        // Revert if the solution is incorrect.
        if (!puzzle.verify(puzzle.generate(msg.sender), _solution)) {
            revert IncorrectSolution();
        }

        // Update the puzzle's first solve timestamp if it was previously unset.
        if (firstSolveTimestamp == 0) {
            getPuzzle[_puzzleId].firstSolveTimestamp = solveTimestamp;
            ++getPuzzleColorsAndSolves[_puzzleId].phase0Solves;

            // Give first solver an Authorship Token
            authorshipToken.curtaMint(msg.sender);
        }

        // Mark the puzzle as solved.
        hasSolvedPuzzle[msg.sender][_puzzleId] = true;

        uint256 ethRemaining = msg.value;
        unchecked {
            // Mint NFT.
            _mint({
                _to: msg.sender,
                _id: (uint256(_puzzleId) << 128) | getPuzzleColorsAndSolves[_puzzleId].solves++,
                _solveMetadata: uint56(((uint160(msg.sender) >> 132) << 28) | (_solution & 0xFFFFFFF)),
                _phase: phase
            });

            if (phase == 1) {
                ++getPuzzleColorsAndSolves[_puzzleId].phase1Solves;
            } else if (phase == 2) {
                // Revert if the puzzle is in Phase 2, and insufficient funds
                // were sent.
                if (ethRemaining < PHASE_TWO_MINIMUM_FEE) revert InsufficientFunds();
                ++getPuzzleColorsAndSolves[_puzzleId].phase2Solves;

                // Transfer protocol fee to `owner`.
                SafeTransferLib.safeTransferETH(owner, PHASE_TWO_PROTOCOL_FEE);

                // Subtract protocol fee from total value.
                ethRemaining -= PHASE_TWO_PROTOCOL_FEE;
            }
        }

        // Transfer untransferred funds to the puzzle author. Refunds are not
        // checked, in case someone wants to ``tip'' the author.
        SafeTransferLib.safeTransferETH(getPuzzleAuthor[_puzzleId], ethRemaining);

        // Emit event
        emit SolvePuzzle({ id: _puzzleId, solver: msg.sender, solution: _solution, phase: phase });
    }

    /// @inheritdoc ICurta
    function addPuzzle(IPuzzle _puzzle, uint256 _tokenId) external {
        // Revert if the Authorship Token doesn't belong to sender.
        if (msg.sender != authorshipToken.ownerOf(_tokenId)) revert Unauthorized();

        // Revert if the puzzle has already been used.
        if (hasUsedAuthorshipToken[_tokenId]) revert AuthorshipTokenAlreadyUsed(_tokenId);

        // Mark token as used.
        hasUsedAuthorshipToken[_tokenId] = true;

        unchecked {
            uint32 curPuzzleId = ++puzzleId;

            // Add puzzle.
            getPuzzle[curPuzzleId] = PuzzleData({
                puzzle: _puzzle,
                addedTimestamp: uint40(block.timestamp),
                firstSolveTimestamp: 0
            });

            // Add puzzle author.
            getPuzzleAuthor[curPuzzleId] = msg.sender;

            // Add puzzle Flag colors with default colors.
            getPuzzleColorsAndSolves[curPuzzleId].colors = DEFAULT_FLAG_COLORS;

            // Emit events.
            emit AddPuzzle(curPuzzleId, msg.sender, _puzzle);
        }
    }

    /// @inheritdoc ICurta
    function setPuzzleColors(uint32 _puzzleId, uint120 _colors) external {
        // Revert if `msg.sender` is not the author of the puzzle.
        if (getPuzzleAuthor[_puzzleId] != msg.sender) revert Unauthorized();

        // Set puzzle colors.
        getPuzzleColorsAndSolves[_puzzleId].colors = _colors;

        // Emit events.
        emit UpdatePuzzleColors(_puzzleId, _colors);
    }

    /// @inheritdoc ICurta
    function setFermat(uint32 _puzzleId) external {
        // Revert if the puzzle has never been solved.
        PuzzleData memory puzzleData = getPuzzle[_puzzleId];
        if (puzzleData.firstSolveTimestamp == 0) revert PuzzleNotSolved(_puzzleId);

        // Revert if the puzzle is already Fermat.
        if (fermat.puzzleId == _puzzleId) revert PuzzleAlreadyFermat(_puzzleId);

        unchecked {
            uint40 timeTaken = puzzleData.firstSolveTimestamp - puzzleData.addedTimestamp;

            // Revert if the puzzle is not Fermat.
            if (timeTaken < fermat.timeTaken) revert PuzzleNotFermat(_puzzleId);

            // Set Fermat.
            fermat.puzzleId = _puzzleId;
            fermat.timeTaken = timeTaken;
        }

        // Transfer Fermat to puzzle author.
        address puzzleAuthor = getPuzzleAuthor[_puzzleId];
        address currentOwner = getTokenData[0].owner;

        unchecked {
            // Delete ownership information about Fermat, if the owner is not
            // `address(0)`.
            if (currentOwner != address(0)) {
                getUserBalances[currentOwner].balance--;

                delete getApproved[0];

                // Emit burn event.
                emit Transfer(currentOwner, address(0), 0);
            }

            // Increment new Fermat author's balance.
            getUserBalances[puzzleAuthor].balance++;
        }

        // Set new Fermat owner.
        getTokenData[0].owner = puzzleAuthor;

        // Emit mint event.
        emit Transfer(address(0), puzzleAuthor, 0);
    }

    // -------------------------------------------------------------------------
    // ERC721Metadata
    // -------------------------------------------------------------------------

    /// @inheritdoc FlagsERC721
    function tokenURI(uint256 _tokenId) external view override returns (string memory) {
        TokenData memory tokenData = getTokenData[_tokenId];
        require(tokenData.owner != address(0), "NOT_MINTED");

        // Puzzle is Fermat.
        if (_tokenId == 0) {
            return "data:application/json;base64,eyJuYW1lIjoiRmVybWF0IiwiZGVzY3JpcHRpb24iOiJMb25nZX"
            "N0IHVuc29sdmVkIHB1enpsZS4iLCJpbWFnZV9kYXRhIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4y"
            "WnlCM2FXUjBhRDBpTlRVd0lpQm9aV2xuYUhROUlqVTFNQ0lnZG1sbGQwSnZlRDBpTUNBd0lEVTFNQ0ExTlRBaU"
            "lHWnBiR3c5SW01dmJtVWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SStQ"
            "SEJoZEdnZ1ptbHNiRDBpSXpFNE1VVXlPQ0lnWkQwaVRUQWdNR2czTlRCMk56VXdTREI2SWk4K1BISmxZM1FnZU"
            "QwaU1UUXpJaUI1UFNJMk9TSWdkMmxrZEdnOUlqSTJOQ0lnYUdWcFoyaDBQU0kwTVRJaUlISjRQU0k0SWlCbWFX"
            "eHNQU0lqTWpjek1ETkVJaTgrUEhKbFkzUWdlRDBpTVRRM0lpQjVQU0kzTXlJZ2MzUnliMnRsUFNJak1UQXhNek"
            "ZESWlCM2FXUjBhRDBpTWpVMklpQm9aV2xuYUhROUlqUXdOQ0lnY25nOUlqUWlJR1pwYkd3OUlpTXdaREV3TVRj"
            "aUx6NDhMM04yWno0PSJ9";
        }

        // Retrieve information about the puzzle.
        uint32 _puzzleId = uint32(_tokenId >> 128);
        PuzzleData memory puzzleData = getPuzzle[_puzzleId];
        address author = getPuzzleAuthor[_puzzleId];
        uint32 solves = getPuzzleColorsAndSolves[_puzzleId].solves;
        uint120 colors = getPuzzleColorsAndSolves[_puzzleId].colors;

        // Phase 0 if
        // `tokenData.solveTimestamp == puzzleData.firstSolveTimestamp`
        // Phase 1 if
        // `tokenData.solveTimestamp == puzzleData.firstSolveTimestamp + PHASE_ONE_LENGTH`
        // Phase 2 if
        // `tokenData.solveTimestamp == puzzleData.firstSolveTimestamp + SUBMISSION_LENGTH`
        uint8 phase = tokenData.solveTimestamp == puzzleData.firstSolveTimestamp
            ? 0
            : tokenData.solveTimestamp < puzzleData.firstSolveTimestamp + PHASE_ONE_LENGTH
            ? 1
            : 2;

        return flagRenderer.render({
            _puzzleData: puzzleData,
            _tokenId: _tokenId + 1, // [MIGRATION] Increment to get rank.
            _author: author,
            _solveTime: tokenData.solveTimestamp - puzzleData.addedTimestamp,
            _solveMetadata: tokenData.solveMetadata,
            _phase: phase,
            _solves: solves,
            _colors: colors
        });
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    /// @notice Computes the phase the puzzle was at at some timestamp.
    /// @param _firstSolveTimestamp The timestamp of the first solve.
    /// @param _solveTimestamp The timestamp of the solve.
    /// @return phase The phase of the puzzle: ``Phase 0'' refers to the period
    /// before the puzzle has been solved, ``Phase 1'' refers to the period 2
    /// days after the first solve, ``Phase 2'' refers to the period 3 days
    /// after the end of ``Phase 1,'' and ``Phase 3'' is when submissions are
    /// closed.
    function _computePhase(uint40 _firstSolveTimestamp, uint40 _solveTimestamp)
        internal
        pure
        returns (uint8 phase)
    {
        // Equivalent to:
        // ```sol
        // if (_firstSolveTimestamp == 0) {
        //     phase = 0;
        // } else {
        //     if (_solveTimestamp > _firstSolveTimestamp + SUBMISSION_LENGTH) {
        //         phase = 3;
        //     } else if (_solveTimestamp > _firstSolveTimestamp + PHASE_ONE_LENGTH) {
        //         phase = 2;
        //     } else {
        //         phase = 1;
        //     }
        // }
        // ```
        assembly {
            phase :=
                mul(
                    iszero(iszero(_firstSolveTimestamp)),
                    add(
                        1,
                        add(
                            gt(_solveTimestamp, add(_firstSolveTimestamp, PHASE_ONE_LENGTH)),
                            gt(_solveTimestamp, add(_firstSolveTimestamp, SUBMISSION_LENGTH))
                        )
                    )
                )
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { LibString } from "solady/utils/LibString.sol";

import { ICurta } from "@/contracts/interfaces/ICurta.sol";
import { IColormapRegistry } from "@/contracts/interfaces/IColormapRegistry.sol";
import { Base64 } from "@/contracts/utils/Base64.sol";

/// @title Curta Flag Renderer
/// @author fiveoutofnine
/// @notice A contract that renders the JSON and SVG for a Flag token.
contract FlagRenderer {
    using LibString for uint256;
    using LibString for address;
    using LibString for string;

    // -------------------------------------------------------------------------
    // Constants
    // -------------------------------------------------------------------------

    /// @notice The colormap registry.
    IColormapRegistry constant colormapRegistry =
        IColormapRegistry(0x0000000012883D1da628e31c0FE52e35DcF95D50);

    /// @notice Render the JSON and SVG for a Flag token.
    /// @param _puzzleData The puzzle data.
    /// @param _tokenId The token ID.
    /// @param _author The author of the puzzle.
    /// @param _solveTime The time it took to solve the puzzle.
    /// @param _solveMetadata The metadata associated with the solve.
    /// @param _phase The phase of the puzzle.
    /// @param _solves The number of solves the puzzle has.
    /// @param _colors The colors of the Flag.
    /// @return string memory The JSON and SVG for the Flag token.
    function render(
        ICurta.PuzzleData memory _puzzleData,
        uint256 _tokenId,
        address _author,
        uint40 _solveTime,
        uint56 _solveMetadata,
        uint8 _phase,
        uint32 _solves,
        uint120 _colors
    ) external view returns (string memory) {
        // Generate the puzzle's attributes.
        string memory attributes;
        {
            attributes = string.concat(
                '[{"trait_type":"Puzzle","value":"',
                _puzzleData.puzzle.name(),
                '"},{"trait_type":"Puzzle ID","value":',
                uint256(_tokenId >> 128).toString(),
                '},{"trait_type":"Author","value":"',
                _author.toHexStringChecksumed(),
                '"},{"trait_type":"Phase","value":"',
                uint256(_phase).toString(),
                '"},{"trait_type":"Solver","value":"',
                _formatValueAsAddress(uint256(_solveMetadata & 0xFFFFFFF)),
                '"},{"trait_type":"Solve time","value":',
                uint256(_solveTime).toString(),
                '},{"trait_type":"Rank","value":',
                uint256(uint128(_tokenId)).toString(),
                "}]"
            );
        }

        // Generate the puzzle's SVG.
        string memory image;
        {
            image = string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="550" height="550" viewBox="0 0 550 '
                '550"><style>@font-face{font-family:A;src:url(data:font/woff2;charset-utf-8;base64,'
                "d09GMgABAAAAABIoABAAAAAAKLAAABHJAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGjobkE4ci2AGYD9TVE"
                "FURACBHBEICqccoBELgRYAATYCJAOCKAQgBYNuByAMBxt3I6OimvUVZH+VwJOd1yhF0zgE5TExCEqYGJii"
                "xbbnwP4dZ3ojLIOo9nusZ/fRJ8AQgAICFZmKIpSpqJRPjvUpssca0NE7gG12KCpiscLIQJvXhQltNGlMwA"
                "rs/BmdK5fVh2tlJjmcJIfyqegIjKaFAkL2xmzu3G5f+LKucK0RgScgqNbInt05eA7IdyHLQlJ5ILKkAI2L"
                "smRUYiTh5D8sgBvNUikgepThvv9/7Vt9l9274oNYWrFooc1GREOjlHln5tu8NRvMZ1WEJN6I4hZFQyGaVu"
                "tEQvmh0iqJSMiE1ggNX4fm60G4VBK+hVS6yPZZNHETOvYf/6wI8AMAxSaiREKCqKkRPT1iaEjMNZdYzh2C"
                "AK+6KbX/oC8NZO9cTOaDLAPg/gNAbl9N5AMKCBAGxaF4IxHCbAZIOiZOprfyvA2svxHYCN8xFXIgBO2JgJ"
                "BkCIqIycqraOuabY655plvgYUWWWyJFXbwhFCsukQ59cgGY8Uaah88kjL5fx5QlZdkxUNbkDHIMQ++qS7D"
                "1nnyFUqhHlNMvSuZK1fXqRhUhap69aRhnUyKyxTMwBwswBKswBpswPbkEbJ1HEqlntKpR3SrK716R994N1"
                "DVqeeMDo7QrrukpSqSHZgDmAvzvM+v2ZzAQlgEi2EJWZsN0avrRGpFo5UcJiIGx7eiGrZDwnw0YhSkHLvi"
                "Hr+vWx0joCfCKSOyA4H7P0c+r0GXbANfz4GrrMyyqmP3wDWW4+y7l4S762X1ZcwjQBoOINXvM01OAf7nvs"
                "RQg0/rE+A09OW8FQJ4+UuJqyqznjiGunWqiav0+BQcegIjR2e5j2Vobwwvcie5j95yFcPCdxXG3bniECmQ"
                "lY+G0onLqnE5DS6v7b2gZ4mitQ7WhOJHTYxPgMEWFybAIUDx8NO8gqIS0iKSADIiogBiACALcgDyAFIs+B"
                "XiIyikKF4YBJxNgexM0bwcHj5yCokJx0MQ4KIC6SEOEmq18Mvyy89HgP8PidnpugQNSdmjaFy+GJcMSlf4"
                "Ah5oXEtksEDvXgovEdwBIgtEBviBYrA4vPyCwqLikkCkVaxstBbdr7aCAF2wB26Tv5ZdCzwhHtqe5nGikN"
                "jUSech2B6UOBAO1bDSwsivQJsoFjJWicmn36MiJaFvvWhFeqy57HUgEUphEVsjMGJDGFXREWOxEofjPCli"
                "XRRB3WS0H+AVlcX3GTyC0n0fwWGX5vsENrNk3wewWCX5XsFkFPe9gDFa1PcIekTnewLVK/nqaBW9bsWjLI"
                "Gg4ttD1jEkDgYSuSage1OPEAnn2F7zmWoV0dA4MSPis2P5kCECJk18nngCMT+BvSY+X6IJy2dgJ4kvsDYK"
                "bK/AhogntE0/QbkGlkd8kfV9QNJmsEDii63/HrQ62JBY4kVwmW0dqNorftedTLNI/9Jwq8E8SEnWrpgFdt"
                "eqYDJ9XG2eJUNcTB6su+JX1LfQZqHilGkzYd1Vb4kSByBCFgA0FcB2iABI0X4/xbtD+J1UEN+ZoPFO+YJI"
                "CNIy8z4j+rLM2wgNzLklWiwtez2+AHI+9gGEcy3MK7eJBBZKWFDOEMW8OJ6ExdjdkHZ7ZkVYil/MtBgsS0"
                "5lip5noyTbtpWVRQrGxJ5JiTGZtUBisHeMbYCvo5P+ZL0/k2J2AMUAAhxw+2E/KqzTdmtx5F8ggD9MGwHy"
                "BoDFoYHzk9QOBeIg9R3dvx6djJADLt/h1ykwhAHpAVlvgYXzrkIe4H5liJiWz9Mk3l7DHUBRmBZUMzLPfK"
                "uRMHBEiyOQJEVm/cPGYGyyDNmQSDI+F/Xbu3pUT2q9lg0b1K9Hlw7tWkI4CnCR+qdvsh4enfkaYG6Gcxjw"
                "BeAbAIBal+6LTXcrxeKEiunCi8zS+1uXOjYHoSy4EXNuXkTrLUlJoxV2bJDH6MsjMRs2G8tvlsasojT2oc"
                "V1t2yIQlPwMtICCfpWK9WZO4Gtw0u6s9hTS71G58ThjlakCzVBM+YjScM6npVwCfM87HwHH+taYCugEo46"
                "imBSKa2zVdcKK2dXdqkxv+fATPp118TM+6zLjl8d9qi/nFU+7Z33ur7XwZ49VJKIDxrDoLtnrVnJqjCtyB"
                "zUORSvqlCwuWmQ4ZFzVkjuR+3LenE5OgrwP9z1ydHwC0fDuRDNSl4Su2swM0M9LZu6qPGvbFWLJtQXztSm"
                "XWVsBMMwICeOrkmssuxQS5FuyYRyhEp4ENa2fggVisSS8hKz6+VFpnzeUf7nKpa16O6PwSSpY3rPB6lkYd"
                "mD2eiFl5fdD5UH7cvlUFsXSqADVrUGbd0qFemfJZd24YZXzPOJLiRp4+AkEPTEmBlDDhuxbsWnSyzsqWL6"
                "qhuvebv4UDyR4ktUGqSewgqsJA8zzM+034SQLE6JQnFH2WMSFWX/Vjm3ScreuSFIcjRszN+KnHQh11XZAy"
                "7epzEf3CyIdsPSF2HD2o3ZYuelKqikg6KzSHyV649Jnd4fc2iCgSBucqfLg2IO5RLfutpKusgmDxapq5HS"
                "pD5+la82KwhVyt5s5uwS6/1rNoBtgOCIzT8kbSY36KqJKcgoulfNLFTbYPoNbvKgbg96Pb2qPjH70758+m"
                "S13tbHYiV1G+/CA9mR8CT2hKIViO9KwYVq9oFYkOnvb5WViCClYQewYAHcAHH6YXP4Ijk+ZH12N/Km7AiJ"
                "1FHBY9mdPusl8p9IdsP6MMCsMwx/zB8l45BuqXt1846SoAdDZt6noTlcl7wAOl3rhrKSN9YaTvXLRN/eui"
                "WJb3YpB0vZ4tbnW4qlSBranIajAtSTVhxAq/hdmN+FKlMFOGlqAFVadqEYTaqDvZE9nAQUYO7qVTS8a8mO"
                "mOnlseQ3x4kdT8+91dHd+tu2/tUJ29qTc22ZIUENg7SkVilBZOv2wILgtKHWgTTItPVLlQuh1+Sy+qzChx"
                "FD9fhnrxrw0DcU2mORFxFYiQlKQWyur/h376Bx3LLs8I9P17x9vlyNd1J6XDfiycouNOQtAQoOWy59fnXC"
                "Df/61J4vmXjLq6odtfavXtXaKbSdd4aTgAIqHnAHTIQ4ofkJXMOCAqkmTag4Knf3pw2v8dMDVoeODFp6TL"
                "35Y3mqYjqCNszj0QZnQitpIH4SktQankeXnGkuiBgd5Jy3EUiVyAxjfS1sxBOKs3KK25KUCGRz/crlPZLh"
                "vYJb1oup/FOtyNBL0nKp/Dl3RUlet79/LX1RhiTP2sCQsSGhcy29Arez6znwSWlRdXWQ8QdGItUXZksngz"
                "k5y3J/dwIK2B+xyzHCyQA1g6ReIfVeYyPlVk9GSkZvNvlObR3lfl8e2GmoPSOszzM/vFngbjt+u+Z38MG9"
                "Ap2Tglef6yAqoK8jLFowHBs6AdwrJYx90+xUYq5JWIA8nqyrXjx3dEscaHkUFcUCCphiG23zHzbN9LwpLk"
                "CsXYxta++aqI1sotDaQcsTAAWxgAKwzVN74HVkgfX27QLHyA/ugUNYB76rmdlfQnpUVU163F+amT1QiuDq"
                "qvRvrYESWANxiACMYdHpuiI1b2SRXxRT2ozVQQtqZJZCQFGsl/aFrQFJtrSEFgb4gTubmqwkhrthdvkUDE"
                "Dd0G39rHWlgNcalyI15aPaY7LzO2II7mx6DFbM7rbppZswDNUd5xUSV2TtnoDnxZLMWBCHiA0Y67zX/ZPN"
                "T0vyRVYuxrY1dI8XkBr9Itugzc1biCVQFQnYLES4t4a/GkXrqkYeVqcMg7Upy9dLXTPKqJ46HQpDTy0LH8"
                "j8NVn9Zq59XkbaBBxn9L/d/bnnJhEIe65Gfvv6lfFtzzUCac/NyB9f7dfvZiZ85visjuTuv5MJPPjM9lsd"
                "Abd0ABQkgXiz9F1L2u/tsCR9dIXDLe32aKQzAipafZicZgqlOYZxaFbdvvPUWVzrhNREUsCd2zJH90dyZY"
                "V24EBSuU74/4CE2EQ6ksLKHPSI4o/6RpRDEIQyqleIBYtqizt7vEJKIBD8CXk1OyLDuz0YQhE6R3R8H9Kt"
                "4dgZs5ZBRAdMnH4xqI25pvpUBPZPHJSltUJdlr4dPezrQJPO/92YvZZRWVdFC0FsKBxQALj7KsedmlYkxE"
                "ajJbOPdFXyRlmMWUiAJNb8JDchBGa32RPsxBc0BuwSHNWk7d3PBQrXtKeGLY+cWnP2XgBHvEoDyLPvPS4U"
                "gqKEoP2CikHjygGj5mXxLQM85ZSJqqIrjxPAXdYioD378Fb+gtr4sAkcgBOreJ/luya88RjWPAiAFzk7Gs"
                "UjV7pExTnWAAliGfPjOwFhl7pH9pNdgAW42HEPgf19lXuBjQeRMAh5CdcO1qVtku3UOvgbBqFz9pttzbEj"
                "NjVz37qGDv9u05JN27Rel3gtf+gQ0r/xjmrSKCGsFsKAwWwao/P443RmEzAgLKxmjCjhMRhe50MthUAIIB"
                "fVe0YwGjxJRRAAgZSSBl/AXVdpACz73sPCLAWQiO+6oKrfuHrQqHlZYvMoTzljoqboypMEr5WNzDnscSJD"
                "xrB+fMXVZ+WuadxENHOOD3E7k5EdRPMdq4EQw5wdq9R9W1CgELL4WGHM5Jl54BbQL2LaE7GHr5sKyAZuzy"
                "MNvXa52B1Ay5aQ/FwIgaD6ACGBBbkQJO3MYjqKLnh2cXkQDHkkD6T0Tkz2BSVi0vPfdvSf/DNxIxk0SvfJ"
                "07AjtBzK4MmFncKZxcnwP9DO2Jyp6fnsOYj2REmMvlFa+IiHpJXFUIJbENNlK9+XTI2l+Hwa/HzwwOHnR+"
                "v8XAuK86K95grRX8+DsVzFef+URghHYhPdacGpXo5OGV4xKXtSAuJ3OOAiPSl+CVux3yA8tf4oJTtnLyW2"
                "MiAkN50rgy6WqSphR2Q0XKIAafEk7J/ayPXok7hxtnbxk2jwx3d40JHLP0JPaBSJ+OGTuMMnOJXhR0jnhN"
                "tEGcw9NnLa9vq8gvqflnKBnR9/OoTTGy1ImjzDAAe50ClcpZB8tnmPEHm/tHn+zd6N5X8/MXEe6fnjDWiD"
                "HSNEBm88mNXNjU+aOMuqOBaUxfX1TmcHOYabOvipI3ak8aBJ/RIXTT4fekn9EQ9M5SqukjKrgjjNjQI5FA"
                "eTVOZPExQd8BVmrfvyi2j+KWVsDCpxw65GVlBG1WVS2W63EG0rvOF/qfQAx3BdnIepazwx4rYf28vRgeVD"
                "IEX6ODgyvOIGraSdncJVZpPPNu0WIu+/bl55sW9j2d9PDNy2jNyJekmjQ/1ENn88mNnNTUiYPMsoP+YYYY"
                "4jWnsmc0PwEda2RAnE9gd82HsCBf8EooDkc3jWBlnrw/vnY4C1Dr8vfDfJK8qWTXyCCv6fjFjFGtaxgU1s"
                "YRs72CUVSwPWsIEt7GCXci3124AqsIZ1bGATW9jGzohuTgCE/o9XfeCd/xvTsv2BwP+TjdPeYCCk30jV4P"
                "+dKQI9GSFp3qePQUh/awUI1lFcFAHLLXuXTAHlGOgG0Dvf2Z+n5UzCSNAfIyGPN3bOeF/9PVIcRUPhSOh6"
                "tKVcGMmKsbevN84MEsu+Lhh1f59JkajfBk9pPgMnx/e3M9A+R3HUZsstexfbDgVjFwB99wTovLN9/Cs5Qs"
                "75W0d5CQC++bx7HYBvj5Kufrv/W6gSKw2ARQEQ/C8luPB4xOLz5x4A4Xiy65cCY8v0FbZNTj6fzTyZvsPJ"
                "cTqQhJBpczx5isTxnayxWPq4z1q7a22ckZ5h0QkN18ZZL/7wo5k3086aBm+t41Vjk3F6MlT14xfYPWl6PK"
                "ZImZQ9vN/1i2mTWhoZdCsfhZPOYrSub29aOZjBgjMdOd3FwDu5v+WeQSibhd5F/nrwjIrzgiDAertIu0Ci"
                "hGdoEuBzlyhJSYB7AOsm8u65KUFv3bSpD6oa426m2X52teRDKx1CDvzhCjcMb3hXkc93mQhl4aDxIBAvQ6"
                "IYUaIl0zA1DkrZzhZwsq/Dl4wj0e5uq0QCsThYTGWZlMii/6MVm0RDO4Ngdx8viaORkeNiRnefgsnMYQI8"
                "5lB4khB0MnN1w1mUHTjm247hTiAOGwVHlBRxGBJZGxqbmGeB7aj8UDlJ+U2JvzjjtmMI8GmQpO9TbmrsIF"
                "sTY7MdZeFQNhKgK5lM1STySmSEiTrO6X8Ln0n5Lv4Vj6wGAA==)}@font-face{font-family:B;src:u"
                "rl(data:font/woff2;charset-utf-8;base64,d09GMgABAAAAAAhQABAAAAAAD4gAAAf2AAEAAAAAAA"
                "AAAAAAAAAAAAAAAAAAAAAAGhYbhCocUAZgP1NUQVRIAHQRCAqPQIx0Cy4AATYCJANYBCAFg1YHIAwHG/YM"
                "UZRR0hhkPxNMlbEboUgq+fBI0pEkVMwtRsc8kTqPvob/GX6NoH7st/e+aHLMEyXSaHjI5tU7oVEJRaw0mk"
                "2nBHj/P27694UIJFCoHdq50ok6paJURELVmdGOUTWmxtTDXPn9zPxom4glMvErMJW4alpRu79ZXw6UtFRH"
                "/wP4wv6/tVZ3013cAY9nCTwkHhFCIlPKnxP7J3PoDKpJxLtGOqGIyGnDsiZIBUIhtMhTmqVhJtyMGedU9E"
                "0+RQBNABIEsYYgoG6AMbCFBeszo257Y86ocMBvxbAtP8gZBbBEOEyDoQ1DoYwEq3ZEjMdbW2SsoQwLL9Uh"
                "NpGWBcwcl5DPdS1HrnGR9VrcRDbPruGaAV4JWAbmEqeVSq7ZMHXB1nex0hbQ7QIMGoIBRSRh5+0YDIXAw8"
                "cnIpISHHITgyjoEDy8B/JkgkRVMjPzT0ne3bgMTGT5pDwUY8MWguETwiujkBoBKnOkFvhQmsKnmteaEAWY"
                "WD5Z4+HCpeXNialh5VNv+btjzhGmFhB3gDI+YIIQClkOOkqaOegsIERWDHC0nRNKUiu0EeCAkCI1SO+AE4"
                "ipIPIVYOpAkCGiaJwXSj7pfs51YvNESuDpkwVAc2RxpYRAv9NtV69OtSqVdLQhmCmgnBPDnjp9HpgAaRGY"
                "wgN4i0LEjm6MCA/yIm5l/dGcHT5ukKVUUrUMxoUUjvZBN7psscGtpPxTq/D4bFn6FhxEFz65g2XefcoU3U"
                "ZFwXAXP6GLn93jZd1/Lip6ajQyrPgy8C6k33lCWyDxCB/K0OgsTGKThMmsLuw4pBuRzJcbjRKoJz675Shy"
                "M8IaR8dbz4jdf85bnhrlYYVT2BnD0GMZQhnGvnWOjwKmaDOIpBG9neMc9Tiq4LBwHGe9E8MyOLNNYIlkcO"
                "GtW6No8Ey/60O677y3abuTVPjsnh9qqYNxJEMwSXO5Y3y/A8ZPGNPzLoAVsszIg05NKXOFnMNODMskJRfG"
                "SkdB50AuxIVJEMXSiYsB4nhFEptEs/2FwESO8kv7S4xPCzIqBnJLp3Z2bpOwu7B2Ua3WGKwZTRqj011j8o"
                "xzIpPHha8aCJpgXUCCXJmkQtrOSuUNnBlHLLWvo3k0x9g9NCkk0zPtzybSyaIkhg2a8EEKIy9UKCZclMjh"
                "OlbA8MtvYnFa4MsODySK8Cs+J/27bXBorTb80ET/gyMObQ+j6SMQO+jPoelfaJ1t0Pfuuo3f7ndInLeS5f"
                "/e3p43DwAYuRUA/r8bv0JDgd3msXUbu+/Zs1HqUNUlezKk4Zyny3aWdd133rdpN1ADRpys6J1V0ac3rwLk"
                "uWBZ/q/5YP4FReQW5ZoVseyyPFnp1YkrbU4t3p0ad1rd1MEsqTQ9mFWy9w/TDIKYfM2NRcmlT92ymiL9o9"
                "IOrAzp+Wvh//Ok/652HIRppafOjC3e/QnXwtb+G/4LL7qhyQ5o6HS/MSpYVGSpt1o1cjJ/U019feuxjYPW"
                "Pl45teicrmtG7BJDv90hCXf3fTZdE0ZFRB1Y6X2z2BCm7PS689S3R6ZNssU6V6ZqnFegC7tXBd8pYPpsU+"
                "6m0is1JwYfb/T5+LnRd+AJw6YdSs/ULT1MvH96P/7JTaWbzuh86YY6JX6mQqM+qfbBwMHQxzAKRrLPHzVA"
                "6+ITGr3STVVu89kEfHhh6rHFsGWHMuZm6QLWTN8xFsYztQYA+tU1+NJndDB+9s0ezTrVoTSZOgInXLiW+H"
                "blsZ1RA2/71lzanul/8XBcesmlwrCHafn6RPNtVZm7ZlxYcM+Vz2f2j2nV//CCO0CCCUigFsJ8pfucOUr3"
                "+RQC7BrN6y+rbh9w8aZNr5MjgA+pnKb41lw/8qQOeiyCusn8nV6YbUYnG/M1FRfyJyVLpsS/L268QoAYN+"
                "FtB9an1u04sfmNuUdWa02uW5W3V0eUAXrM1elMWi8yPvZ+qV73NjUDTl0zGfYcutAQtd3b7xCMS+9zbdJp"
                "vU+XWe9HzmsP7mfu4kAXXb1ZdbHWm9JqvQUX66uqjkD0YaeaOwW3ZwJ/1ovPPd6CDdmMgPmzpqYsXvmNZG"
                "jU/ZLCbsuRg3nnOuHoSL2bb13gJZi4AM71OPc6wgTEft8pSrc+4wbbPRt9M1FuNcf3qFy1LReWYLHF+Sgm"
                "XJL0eZ1e/Tg17fKWw2c3Ou11Vh0ANxL654L5qIFu2eck/kDEzGnuVnZTr8ptsxj/wGGxwxMGVHy/h5x5Mj"
                "w+Q9e2FPjZMIubRWZfGrtooUym+FjZQvrqYxfOA9vclhZu1qXt/P6O9b6hupPn9Ry3PTSR9fFJTycGEECh"
                "+PB3s7bZUzztizLMAOD746FhAH7kq37/J79VI7EQgDIMIMA/MRs9B/Xnz5P/q/nfq5t9V8A9xYfvchFqyH"
                "GgJjnNkZI9UA3AdFqI3+6QckegVpOREqmoyd0+3E61AmyUfZtlfcBL/bB44l2MhC8goGcTCEWSQ2KJ31aX"
                "ioeKAgC3AA8DQlMbMBa0Bh6ZFgOumzsGwgQf9aRuMSQFEoMw5hgkQMcKlLoLda5C6QNEAiFEjCE7ij7WNW"
                "Rv4GI55AEQq4C8PeZxhGK2B7FQUwAKOMSBQCUTC6OrsgDRIJW02jp85uWZrlBkKHiDHM/Xg/zFI0/gIWUB"
                "Q6PIOJhsqjVONk6WsEh7Pr4zO4JXtRkVKeSIU0uSok0mEmMOtIMT+OlRClJ9471uzlPTJCrkYX7/PQbo/I"
                "z+3axYAg==)}text,tspan{dominant-baseline:central}.a{font-family:A;letter-spacing:-"
                ".05em}.b{font-family:B}.c{font-size:16px}.d{font-size:12px}.f{fill:#",
                uint256((_colors >> 72) & 0xFFFFFF).toHexStringNoPrefix(3), // Fill
                "}.h{fill:#",
                uint256((_colors >> 24) & 0xFFFFFF).toHexStringNoPrefix(3), // Primary text
                "}.i{fill:#",
                uint256(_colors & 0xFFFFFF).toHexStringNoPrefix(3), // Secondary text
                "}.j{fill:none;stroke-linejoin:round;stroke-linecap:round;stroke:#",
                uint256(_colors & 0xFFFFFF).toHexStringNoPrefix(3) // Secondary text
            );
        }
        {
            image = string.concat(
                image,
                '}.x{width:1px;height:1px}</style><mask id="m"><rect width="20" height="20" rx="0.3'
                '70370" fill="#FFF"/></mask><path d="M0 0h550v550H0z" style="fill:#',
                uint256((_colors >> 96) & 0xFFFFFF).toHexStringNoPrefix(3), // Background
                '"/><rect x="143" y="69" width="264" height="412" rx="8" fill="#',
                uint256((_colors >> 48) & 0xFFFFFF).toHexStringNoPrefix(3), // Border
                '"/><rect class="f" x="147" y="73" width="256" height="404" rx="4"/>',
                _drawStars(_phase)
            );
        }
        {
            image = string.concat(
                image,
                '<text class="a h" x="163" y="101" font-size="20">Puzzle #',
                (_tokenId >> 128).toString(),
                '</text><text x="163" y="121"><tspan class="b d i">Created by </tspan><tspan class='
                '"a d h">'
            );
        }
        {
            uint256 luma =
                ((_colors >> 88) & 0xFF) + ((_colors >> 80) & 0xFF) + ((_colors >> 72) & 0xFF);
            image = string.concat(
                image,
                _formatValueAsAddress(uint160(_author) >> 132), // Authors
                '</tspan></text><rect x="163" y="137" width="224" height="224" fill="rgba(',
                luma < ((255 * 3) >> 1) ? "255,255,255" : "0,0,0", // Background behind the heatmap
                ',0.2)" rx="8"/>',
                _drawDrunkenBishop(_solveMetadata, _tokenId),
                '<path class="j" d="M176.988 387.483A4.992 4.992 0 0 0 173 385.5a4.992 4.992 0 0 0-'
                "3.988 1.983m7.975 0a6 6 0 1 0-7.975 0m7.975 0A5.977 5.977 0 0 1 173 389a5.977 5.97"
                '7 0 0 1-3.988-1.517M175 381.5a2 2 0 1 1-4 0 2 2 0 0 1 4 0z"/><text class="a c h" x'
                '="187" y="383">',
                _formatValueAsAddress(_solveMetadata >> 28), // Captured by
                '</text><text class="b d i" x="187" y="403">Captured by</text><path class="j" d="m2'
                "85.5 380 2 1.5-2 1.5m3 0h2m-6 5.5h9a1.5 1.5 0 0 0 1.5-1.5v-8a1.5 1.5 0 0 0-1.5-1.5"
                'h-9a1.5 1.5 0 0 0-1.5 1.5v8a1.5 1.5 0 0 0 1.5 1.5z"/><text class="a c h" x="303" y'
                '="383">',
                _formatValueAsAddress(_solveMetadata & 0xFFFFFFF), // Solution
                '</text><text class="b d i" x="303" y="403">Solution</text><path class="j" d="M176 '
                "437.5h-6m6 0a2 2 0 0 1 2 2h-10a2 2 0 0 1 2-2m6 0v-2.25a.75.75 0 0 0-.75-.75h-.58m-"
                "4.67 3v-2.25a.75.75 0 0 1 .75-.75h.581m3.338 0h-3.338m3.338 0a4.97 4.97 0 0 1-.654"
                "-2.115m-2.684 2.115a4.97 4.97 0 0 0 .654-2.115m-3.485-4.561c-.655.095-1.303.211-1."
                "944.347a4.002 4.002 0 0 0 3.597 3.314m-1.653-3.661V428a4.49 4.49 0 0 0 1.653 3.485"
                "m-1.653-3.661v-1.01a32.226 32.226 0 0 1 4.5-.314c1.527 0 3.03.107 4.5.313v1.011m-7"
                ".347 3.661a4.484 4.484 0 0 0 1.832.9m5.515-4.561V428a4.49 4.49 0 0 1-1.653 3.485m1"
                ".653-3.661a30.88 30.88 0 0 1 1.944.347 4.002 4.002 0 0 1-3.597 3.314m0 0a4.484 4.4"
                '84 0 0 1-1.832.9m0 0a4.515 4.515 0 0 1-2.03 0"/><text><tspan class="a c h" x="187"'
                ' y="433">'
            );
        }
        {
            image = string.concat(
                image,
                uint256(uint128(_tokenId)).toString(), // Rank
                ' </tspan><tspan class="a d i" y="435">/ ',
                uint256(_solves).toString(), // Solvers
                '</tspan></text><text class="b d i" x="187" y="453">Rank</text><path class="j" d="M'
                '289 429v4h3m3 0a6 6 0 1 1-12 0 6 6 0 0 1 12 0z"/><text class="a c h" x="303" y="43'
                '3">',
                _formatTime(_solveTime), // Solve time
                '</text><text class="b d i" x="303" y="453">Solve time</text></svg>'
            );
        }

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                abi.encodePacked(
                    '{"name":"',
                    _puzzleData.puzzle.name(),
                    ": Flag #",
                    uint256(uint128(_tokenId)).toString(),
                    '","description":"This token represents solve #',
                    uint256(uint128(_tokenId)).toString(),
                    " in puzzle #",
                    uint256(_tokenId >> 128).toString(),
                    '.","image_data": "data:image/svg+xml;base64,',
                    Base64.encode(abi.encodePacked(image)),
                    '","attributes":',
                    attributes,
                    "}"
                )
            )
        );
    }

    /// @notice Returns the SVG component for the ``heatmap'' generated by
    /// applying the Drunken Bishop algorithm.
    /// @param _solveMetadata A bitpacked `uint56` containing metadata of the
    /// solver and solution.
    /// @param _tokenId The token ID of the Flag.
    /// @return string memory The SVG for the heatmap.
    function _drawDrunkenBishop(uint56 _solveMetadata, uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(_tokenId, _solveMetadata)));
        // Select the colormap.
        bytes32 colormapHash = [
            bytes32(0xfd29b65966772202ffdb08f653439b30c849f91409915665d99dbfa5e5dab938),
            bytes32(0x850ce48e7291439b1e41d21fc3f75dddd97580a4ff94aa9ebdd2bcbd423ea1e8),
            bytes32(0x4f5e8ea8862eff315c110b682ee070b459ba8983a7575c9a9c4c25007039109d),
            bytes32(0xf2e92189cb6903b98d854cd74ece6c3fafdb2d3472828a950633fdaa52e05032),
            bytes32(0xa33e6c7c5627ecabfd54c4d85f9bf04815fe89a91379fcf56ccd8177e086db21),
            bytes32(0xaa84b30df806b46f859a413cb036bc91466307aec5903fc4635c00a421f25d5c),
            bytes32(0x864a6ee98b9b21ac0291523750d637250405c24a6575e1f75cfbd7209a810ce6),
            bytes32(0xfd60cd3811f002814944a7d36167b7c9436187a389f2ee476dc883e37dc76bd2),
            bytes32(0xa8309447f8bd3b5e5e88a0abc05080b7682e4456c388b8636d45f5abb2ad2587),
            bytes32(0x3be719b0c342797212c4cb33fde865ed9cbe486eb67176265bc0869b54dee925),
            bytes32(0xca0da6b6309ed2117508207d68a59a18ccaf54ba9aa329f4f60a77481fcf2027),
            bytes32(0x5ccb29670bb9de0e3911d8e47bde627b0e3640e49c3d6a88d51ff699160dfbe1),
            bytes32(0x3de8f27f386dab3dbab473f3cc16870a717fe5692b4f6a45003d175c559dfcba),
            bytes32(0x026736ef8439ebcf8e7b8006bf8cb7482ced84d71b900407a9ed63e1b7bfe234),
            bytes32(0xc1806ea961848ac00c1f20aa0611529da522a7bd125a3036fe4641b07ee5c61c),
            bytes32(0x87970b686eb726750ec792d49da173387a567764d691294d764e53439359c436),
            bytes32(0xaa6277ab923279cf59d78b9b5b7fb5089c90802c353489571fca3c138056fb1b),
            bytes32(0xdc1cecffc00e2f3196daaf53c27e53e6052a86dc875adb91607824d62469b2bf)
        ][seed % 18];

        // We start at the middle of the board.
        uint256 index = 210;
        uint256 max = 1;
        uint8[] memory counts = new uint8[](400);
        counts[index] = 1;

        // Apply Drunken Bishop algorithm.
        unchecked {
            while (seed != 0) {
                (uint256 x, uint256 y) = (index % 20, index / 20);

                assembly {
                    // Read down/up
                    switch and(shr(1, seed), 1)
                    // Up case
                    case 0 { index := add(index, mul(20, iszero(eq(y, 19)))) }
                    // Down case
                    default { index := sub(index, mul(20, iszero(eq(y, 0)))) }

                    // Read left/right
                    switch and(seed, 1)
                    // Left case
                    case 0 { index := add(index, iszero(eq(x, 19))) }
                    // Right case
                    default { index := sub(index, iszero(eq(y, 0))) }
                }
                if (++counts[index] > max) max = counts[index];
                seed >>= 2;
            }
        }

        // Draw heatmap from counts.
        string memory image = '<g transform="translate(167 141) scale(10.8)" mask="url(#m)">';
        unchecked {
            for (uint256 i; i < 400; ++i) {
                image = string.concat(
                    image,
                    '<rect class="x" x="',
                    (i % 20).toString(),
                    '" y="',
                    (i / 20).toString(),
                    '" fill="#',
                    colormapRegistry.getValueAsHexString(
                        colormapHash, uint8((uint256(counts[i]) * 255) / max)
                    ),
                    '"/>'
                );
            }
        }

        return string.concat(image, "</g>");
    }

    /// @notice Returns the SVG component for the stars corresponding to the
    /// phase, including the background pill.
    /// @dev Phase 0 = 3 stars; Phase 1 = 2 stars; Phase 2 = 1 star. Also, note
    /// that the SVGs are returned positioned relative to the whole SVG for the
    /// Flag.
    /// @param _phase The phase of the solve.
    /// @return string memory The SVG for the stars.
    function _drawStars(uint8 _phase) internal pure returns (string memory) {
        // This will never underflow because `_phase` is always in the range
        // [0, 4].
        unchecked {
            uint256 width = ((4 - _phase) << 4);

            return string.concat(
                '<rect class="h" x="',
                (383 - width).toString(),
                '" y="97" width="',
                width.toString(),
                '" height="24" rx="12"/><path id="s" d="M366.192 103.14c.299-.718 1.317-.718 1.616 '
                "0l1.388 3.338 3.603.289c.776.062 1.09 1.03.499 1.536l-2.745 2.352.838 3.515c.181.7"
                "57-.642 1.355-1.306.95L367 113.236l-3.085 1.884c-.664.405-1.487-.193-1.306-.95l.83"
                '8-3.515-2.745-2.352c-.591-.506-.277-1.474.5-1.536l3.602-.289 1.388-3.337z"/>',
                _phase < 2 ? '<use href="#s" x="-16" />' : "",
                _phase < 1 ? '<use href="#s" x="-32" />' : ""
            );
        }
    }

    /// @notice Helper function to format the last 28 bits of a value as a
    /// hexstring of length 7. If the value is less than 24 bits, it is padded
    /// with leading zeros.
    /// @param _value The value to format.
    /// @return string memory The formatted string.
    function _formatValueAsAddress(uint256 _value) internal pure returns (string memory) {
        return string.concat(
            string(abi.encodePacked(bytes32("0123456789ABCDEF")[(_value >> 24) & 0xF])),
            (_value & 0xFFFFFF).toHexStringNoPrefix(3).toCase(true)
        );
    }

    /// @notice Helper function to format seconds into a length string. In order
    /// to fit the solve time in the card, we format it as follows:
    ///     * 0:00:00 to 95:59:59
    ///     * 96 hours to 983 hours
    ///     * 41 days to 729 days
    ///     * 2 years onwards
    /// @param _solveTime The solve time in seconds.
    /// @return string memory The formatted string.
    function _formatTime(uint40 _solveTime) internal pure returns (string memory) {
        if (_solveTime < 96 hours) {
            uint256 numHours = _solveTime / (1 hours);
            uint256 numMinutes = (_solveTime % (1 hours)) / (1 minutes);
            uint256 numSeconds = _solveTime % (1 minutes);

            return string.concat(
                _zeroPadOne(numHours), ":", _zeroPadOne(numMinutes), ":", _zeroPadOne(numSeconds)
            );
        } else if (_solveTime < 41 days) {
            return string.concat(uint256(_solveTime / (1 hours)).toString(), " hours");
        } else if (_solveTime < 730 days) {
            return string.concat(uint256(_solveTime / (1 days)).toString(), " days");
        }
        return string.concat(uint256(_solveTime / (365 days)).toString(), " years");
    }

    /// @notice Helper function to zero pad a number by 1 if it is less than 10.
    /// @param _value The number to zero pad.
    /// @return string memory The zero padded string.
    function _zeroPadOne(uint256 _value) internal pure returns (string memory) {
        if (_value < 10) {
            return string.concat("0", _value.toString());
        }
        return _value.toString();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { ERC721TokenReceiver } from "solmate/tokens/ERC721.sol";

/// @title The Flags ERC-721 token contract
/// @author fiveoutofnine
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// @notice A ``Flag'' is an NFT minted to a player when they successfuly solve
/// a puzzle.
/// @dev The NFT with token ID 0 is reserved to denote ``Fermat''—the author's
/// whose puzzle went the longest unsolved.
abstract contract FlagsERC721 {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    // -------------------------------------------------------------------------
    // Structs
    // -------------------------------------------------------------------------

    /// @param owner The owner of the token.
    /// @param solveTimestamp The timestamp of when the token was solved/minted.
    /// @param solveMetadata A bitpacked `uint56` containing the following
    /// information:
    ///     * The first 28 bits are the first 28 bits of the solver.
    ///     * The last 28 bits are the last 28 bits of the solution.
    struct TokenData {
        address owner;
        uint40 solveTimestamp;
        uint56 solveMetadata;
    }

    /// @param phase0Solves The number of puzzles someone solved during Phase 0.
    /// @param phase1Solves The number of puzzles someone solved during Phase 1.
    /// @param phase2Solves The number of puzzles someone solved during Phase 2.
    /// @param solves The total number of solves someone has.
    /// @param balance The number of tokens someone owns.
    struct UserBalance {
        uint32 phase0Solves;
        uint32 phase1Solves;
        uint32 phase2Solves;
        uint32 solves;
        uint32 balance;
    }

    // -------------------------------------------------------------------------
    // ERC721Metadata Storage
    // -------------------------------------------------------------------------

    /// @notice The name of the contract.
    string public name;

    /// @notice An abbreviated name for the contract.
    string public symbol;

    // -------------------------------------------------------------------------
    // ERC721 Storage (+ Custom)
    // -------------------------------------------------------------------------

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    mapping(uint256 => TokenData) public getTokenData;

    mapping(address => UserBalance) public getUserBalances;

    // -------------------------------------------------------------------------
    // Constructor + Functions
    // -------------------------------------------------------------------------

    /// @param _name The name of the contract.
    /// @param _symbol An abbreviated name for the contract.
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;

        // [MIGRATION] Set `getTokenData` for sampriti.eth
        getTokenData[(1 << 128)] = TokenData({
            owner: address(0x58593392d72A9D90b133e1C8ecEec581C354687f), // sampriti.eth
            solveTimestamp: uint40(1677719903),
            solveMetadata: uint56(24867875967088679)
        });
        // [MIGRATION] Set `getTokenData` for karmacoma.eth
        getTokenData[(1 << 128) | 1] = TokenData({
            owner: address(0x03433830468d771A921314D75b9A1DeA53C165d7), // karmacoma.eth
            solveTimestamp: uint40(1677724451),
            solveMetadata: uint56(918333653799954)
        });
        // [MIGRATION] Set `getUserBalances` for sampriti.eth
        getUserBalances[0x58593392d72A9D90b133e1C8ecEec581C354687f] = UserBalance({
            phase0Solves: 1,
            phase1Solves: 0,
            phase2Solves: 0,
            solves: 1,
            balance: 1
        });
        // [MIGRATION] Set `getUserBalances` for karmacoma.eth
        getUserBalances[0x03433830468d771A921314D75b9A1DeA53C165d7] = UserBalance({
            phase0Solves: 0,
            phase1Solves: 1,
            phase2Solves: 0,
            solves: 1,
            balance: 1
        });
    }

    /// @notice Mints a Flag token to `_to`.
    /// @dev This function is only called by {Curta}, so it makes a few
    /// assumptions. For example, the ID of the token is always in the form
    /// `(puzzleId << 128) + zeroIndexedSolveRanking`.
    /// @param _to The address to mint the token to.
    /// @param _id The ID of the token.
    /// @param _solveMetadata The metadata for the solve (see
    /// {FlagsERC721.TokenData}).
    /// @param _phase The phase the token was solved in.
    function _mint(address _to, uint256 _id, uint56 _solveMetadata, uint8 _phase) internal {
        // We do not check whether the `_to` is `address(0)` or that the token
        // was previously minted because {Curta} ensures these conditions are
        // never true.

        unchecked {
            ++getUserBalances[_to].balance;

            // `_mint` is only called when a puzzle is solved, so we can safely
            // increment the solve count.
            ++getUserBalances[_to].solves;

            // Same logic as the previous comment here.
            if (_phase == 0) ++getUserBalances[_to].phase0Solves;
            else if (_phase == 1) ++getUserBalances[_to].phase1Solves;
            else ++getUserBalances[_to].phase2Solves;
        }

        getTokenData[_id] = TokenData({
            owner: _to,
            solveMetadata: _solveMetadata,
            solveTimestamp: uint40(block.timestamp)
        });

        // Emit event.
        emit Transfer(address(0), _to, _id);
    }

    // -------------------------------------------------------------------------
    // ERC721
    // -------------------------------------------------------------------------

    function ownerOf(uint256 _id) public view returns (address owner) {
        require((owner = getTokenData[_id].owner) != address(0), "NOT_MINTED");
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "ZERO_ADDRESS");

        return getUserBalances[_owner].balance;
    }

    function approve(address _spender, uint256 _id) external {
        address owner = getTokenData[_id].owner;

        // Revert if the sender is not the owner, or the owner has not approved
        // the sender to operate the token.
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        // Set the spender as approved for the token.
        getApproved[_id] = _spender;

        // Emit event.
        emit Approval(owner, _spender, _id);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        // Set the operator as approved for the sender.
        isApprovedForAll[msg.sender][_operator] = _approved;

        // Emit event.
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _id) public virtual {
        // Revert if the token is not being transferred from the current owner.
        require(_from == getTokenData[_id].owner, "WRONG_FROM");

        // Revert if the recipient is the zero address.
        require(_to != address(0), "INVALID_RECIPIENT");

        // Revert if the sender is not the owner, or the owner has not approved
        // the sender to operate the token.
        require(
            msg.sender == _from || isApprovedForAll[_from][msg.sender]
                || msg.sender == getApproved[_id],
            "NOT_AUTHORIZED"
        );

        // Update balances.
        unchecked {
            // Will never underflow because of the token ownership check above.
            getUserBalances[_from].balance--;

            getUserBalances[_to].balance++;
        }

        // Set new owner.
        getTokenData[_id].owner = _to;

        // Clear previous approval data for the token.
        delete getApproved[_id];

        // Emit event.
        emit Transfer(_from, _to, _id);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id) external {
        transferFrom(_from, _to, _id);

        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _id, "")
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, bytes calldata _data)
        external
    {
        transferFrom(_from, _to, _id);

        require(
            _to.code.length == 0
                || ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _id, _data)
                    == ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    // -------------------------------------------------------------------------
    // ERC721Metadata
    // -------------------------------------------------------------------------

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @param _tokenId The token ID.
    /// @return URI for the token.
    function tokenURI(uint256 _tokenId) external view virtual returns (string memory);

    // -------------------------------------------------------------------------
    // ERC165
    // -------------------------------------------------------------------------

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == 0x01FFC9A7 // ERC165 Interface ID for ERC165
            || _interfaceId == 0x80AC58CD // ERC165 Interface ID for ERC721
            || _interfaceId == 0x5B5E139F; // ERC165 Interface ID for ERC721Metadata
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IPaletteGenerator } from "@/contracts/interfaces/IPaletteGenerator.sol";

/// @title The interface for the colormap registry.
/// @author fiveoutofnine
/// @dev A colormap may be defined in 2 ways: (1) via segment data and (2) via a
/// ``palette generator.''
///     1. via segment data
///     2. or via a palette generator ({IPaletteGenerator}).
/// Segment data contains 1 `uint256` each for red, green, and blue describing
/// their intensity values along the colormap. Each `uint256` contains 24-bit
/// words bitpacked together with the following structure (bits are
/// right-indexed):
///     | Bits      | Meaning                                              |
///     | --------- | ---------------------------------------------------- |
///     | `23 - 16` | Position in the colormap the segment begins from     |
///     | `15 - 08` | Intensity of R, G, or B the previous segment ends at |
///     | `07 - 00` | Intensity of R, G, or B the next segment starts at   |
/// Given some position, the output will be computed via linear interpolations
/// on the segment data for R, G, and B. A maximum of 10 of these segments fit
/// within 256 bits, so up to 9 segments can be defined. If you need more
/// granularity or a nonlinear palette function, you may implement
/// {IPaletteGenerator} and define a colormap with that.
interface IColormapRegistry {
    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Emitted when a colormap already exists.
    /// @param _colormapHash Hash of the colormap's definition.
    error ColormapAlreadyExists(bytes32 _colormapHash);

    /// @notice Emitted when a colormap does not exist.
    /// @param _colormapHash Hash of the colormap's definition.
    error ColormapDoesNotExist(bytes32 _colormapHash);

    /// @notice Emitted when a segment data used to define a colormap does not
    /// follow the representation outlined in {IColormapRegistry}.
    /// @param _segmentData Segment data for 1 of R, G, or B. See
    /// {IColormapRegistry} for its representation.
    error SegmentDataInvalid(uint256 _segmentData);

    // -------------------------------------------------------------------------
    // Structs
    // -------------------------------------------------------------------------

    /// @notice Segment data that defines a colormap when read via piece-wise
    /// linear interpolation.
    /// @dev Each param contains 24-bit words, so each one may contain at most
    /// 9 (24*10 - 1) segments. See {IColormapRegistry} for how the segment data
    /// should be structured.
    /// @param r Segment data for red's color value along the colormap.
    /// @param g Segment data for green's color value along the colormap.
    /// @param b Segment data for blue's color value along the colormap.
    struct SegmentData {
        uint256 r;
        uint256 g;
        uint256 b;
    }

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when a colormap is registered via a palette generator
    /// function.
    /// @param _hash Hash of `_paletteGenerator`.
    /// @param _paletteGenerator Instance of {IPaletteGenerator} for the
    /// colormap.
    event RegisterColormap(bytes32 _hash, IPaletteGenerator _paletteGenerator);

    /// @notice Emitted when a colormap is registered via segment data.
    /// @param _hash Hash of `_segmentData`.
    /// @param _segmentData Segment data defining the colormap.
    event RegisterColormap(bytes32 _hash, SegmentData _segmentData);

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    /// @param _colormapHash Hash of the colormap's definition (segment data).
    /// @return uint256 Segment data for red's color value along the colormap.
    /// @return uint256 Segment data for green's color value along the colormap.
    /// @return uint256 Segment data for blue's color value along the colormap.
    function segments(bytes32 _colormapHash) external view returns (uint256, uint256, uint256);

    /// @param _colormapHash Hash of the colormap's definition (palette
    /// generator).
    /// @return IPaletteGenerator Instance of {IPaletteGenerator} for the
    /// colormap.
    function paletteGenerators(bytes32 _colormapHash) external view returns (IPaletteGenerator);

    // -------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------

    /// @notice Register a colormap with a palette generator.
    /// @param _paletteGenerator Instance of {IPaletteGenerator} for the
    /// colormap.
    function register(IPaletteGenerator _paletteGenerator) external;

    /// @notice Register a colormap with segment data that will be read via
    /// piece-wise linear interpolation.
    /// @dev See {IColormapRegistry} for how the segment data should be
    /// structured.
    /// @param _segmentData Segment data defining the colormap.
    function register(SegmentData memory _segmentData) external;

    // -------------------------------------------------------------------------
    // View
    // -------------------------------------------------------------------------

    /// @notice Get the red, green, and blue color values of a color in a
    /// colormap at some position.
    /// @dev Each color value will be returned as a 18 decimal fixed-point
    /// number in [0, 1]. Note that the function *will not* revert if
    /// `_position` is an invalid input (i.e. greater than 1e18). This
    /// responsibility is left to the implementation of {IPaletteGenerator}s.
    /// @param _colormapHash Hash of the colormap's definition.
    /// @param _position 18 decimal fixed-point number in [0, 1] representing
    /// the position in the colormap (i.e. 0 being min, and 1 being max).
    /// @return uint256 Intensity of red in that color at the position
    /// `_position`.
    /// @return uint256 Intensity of green in that color at the position
    /// `_position`.
    /// @return uint256 Intensity of blue in that color at the position
    /// `_position`.
    function getValue(bytes32 _colormapHash, uint256 _position)
        external
        view
        returns (uint256, uint256, uint256);

    /// @notice Get the red, green, and blue color values of a color in a
    /// colormap at some position.
    /// @dev Each color value will be returned as a `uint8` number in [0, 255].
    /// @param _colormapHash Hash of the colormap's definition.
    /// @param _position Position in the colormap (i.e. 0 being min, and 255
    /// being max).
    /// @return uint8 Intensity of red in that color at the position
    /// `_position`.
    /// @return uint8 Intensity of green in that color at the position
    /// `_position`.
    /// @return uint8 Intensity of blue in that color at the position
    /// `_position`.
    function getValueAsUint8(bytes32 _colormapHash, uint8 _position)
        external
        view
        returns (uint8, uint8, uint8);

    /// @notice Get the hexstring for a color in a colormap at some position.
    /// @param _colormapHash Hash of the colormap's definition.
    /// @param _position Position in the colormap (i.e. 0 being min, and 255
    /// being max).
    /// @return string Hexstring excluding ``#'' (e.g. `007CFF`) of the color
    /// at the position `_position`.
    function getValueAsHexString(bytes32 _colormapHash, uint8 _position)
        external
        view
        returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IPuzzle } from "./IPuzzle.sol";
import { AuthorshipToken } from "@/contracts/AuthorshipToken.sol";
import { FlagRenderer } from "@/contracts/FlagRenderer.sol";

/// @title The interface for Curta
/// @notice A CTF protocol, where players create and solve EVM puzzles to earn
/// NFTs.
/// @dev Each solve is represented by an NFT. However, the NFT with token ID 0
/// is reserved to denote ``Fermat''—the author's whose puzzle went the longest
/// unsolved.
interface ICurta {
    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Emitted when an Authorship Token has already been used to add a
    /// puzzle to Curta.
    /// @param _tokenId The ID of an Authorship Token.
    error AuthorshipTokenAlreadyUsed(uint256 _tokenId);

    /// @notice Emitted when a puzzle's solution is incorrect.
    error IncorrectSolution();

    /// @notice Emitted when insufficient funds are sent during "Phase 2"
    /// submissions.
    error InsufficientFunds();

    /// @notice Emitted when a puzzle is already marked as Fermat.
    /// @param _puzzleId The ID of a puzzle.
    error PuzzleAlreadyFermat(uint32 _puzzleId);

    /// @notice Emitted when a solver has already solved a puzzle.
    /// @param _puzzleId The ID of a puzzle.
    error PuzzleAlreadySolved(uint32 _puzzleId);

    /// @notice Emitted when a puzzle does not exist.
    /// @param _puzzleId The ID of a puzzle.
    error PuzzleDoesNotExist(uint32 _puzzleId);

    /// @notice Emitted when the puzzle was not the one that went longest
    /// unsolved.
    /// @param _puzzleId The ID of a puzzle.
    error PuzzleNotFermat(uint32 _puzzleId);

    /// @notice Emitted when a puzzle has not been solved yet.
    /// @param _puzzleId The ID of a puzzle.
    error PuzzleNotSolved(uint32 _puzzleId);

    /// @notice Emitted when submissions for a puzzle is closed.
    /// @param _puzzleId The ID of a puzzle.
    error SubmissionClosed(uint32 _puzzleId);

    /// @notice Emitted when `msg.sender` is not authorized.
    error Unauthorized();

    // -------------------------------------------------------------------------
    // Structs
    // -------------------------------------------------------------------------

    /// @notice A struct containing data about the puzzle corresponding to
    /// Fermat (i.e. the puzzle that went the longest unsolved).
    /// @param puzzleId The ID of the puzzle.
    /// @param timeTaken The number of seconds it took to first solve the
    /// puzzle.
    struct Fermat {
        uint32 puzzleId;
        uint40 timeTaken;
    }

    /// @notice A struct containing data about a puzzle.
    /// @param puzzle The address of the puzzle.
    /// @param addedTimestamp The timestamp at which the puzzle was added.
    /// @param firstSolveTimestamp The timestamp at which the first valid
    /// solution was submitted.
    struct PuzzleData {
        IPuzzle puzzle;
        uint40 addedTimestamp;
        uint40 firstSolveTimestamp;
    }

    /// @notice A struct containing the number of solves a puzzle has.
    /// @param colors A bitpacked `uint120` of 5 24-bit colors for the puzzle's
    /// Flags in the following order (left-to-right):
    ///     * Background color
    ///     * Fill color
    ///     * Border color
    ///     * Primary text color
    ///     * Secondary text color
    /// @param phase0Solves The total number of Phase 0 solves a puzzle has.
    /// @param phase1Solves The total number of Phase 1 solves a puzzle has.
    /// @param phase2Solves The total number of Phase 2 solves a puzzle has.
    /// @param solves The total number of solves a puzzle has.
    struct PuzzleColorsAndSolves {
        uint120 colors;
        uint32 phase0Solves;
        uint32 phase1Solves;
        uint32 phase2Solves;
        uint32 solves;
    }

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when a puzzle is added.
    /// @param id The ID of the puzzle.
    /// @param author The address of the puzzle author.
    /// @param puzzle The address of the puzzle.
    event AddPuzzle(uint32 indexed id, address indexed author, IPuzzle puzzle);

    /// @notice Emitted when a puzzle is solved.
    /// @param id The ID of the puzzle.
    /// @param solver The address of the solver.
    /// @param solution The solution.
    /// @param phase The phase in which the puzzle was solved.
    event SolvePuzzle(uint32 indexed id, address indexed solver, uint256 solution, uint8 phase);

    /// @notice Emitted when a puzzle's colors are updated.
    /// @param id The ID of the puzzle.
    /// @param colors A bitpacked `uint120` of 5 24-bit colors for the puzzle's
    /// Flags.
    event UpdatePuzzleColors(uint32 indexed id, uint256 colors);

    // -------------------------------------------------------------------------
    // Immutable Storage
    // -------------------------------------------------------------------------

    /// @notice The Flag metadata and art renderer contract.
    function flagRenderer() external view returns (FlagRenderer);

    /// @return The Authorship Token contract.
    function authorshipToken() external view returns (AuthorshipToken);

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    /// @return The total number of puzzles.
    function puzzleId() external view returns (uint32);

    /// @return puzzleId The ID of the puzzle corresponding to Fermat.
    /// @return timeTaken The number of seconds it took to solve the puzzle.
    function fermat() external view returns (uint32 puzzleId, uint40 timeTaken);

    /// @param _puzzleId The ID of a puzzle.
    /// @return colors A bitpacked `uint120` of 5 24-bit colors for the puzzle's
    /// Flags.
    /// @return phase0Solves The total number of Phase 0 solves a puzzle has.
    /// @return phase1Solves The total number of Phase 1 solves a puzzle has.
    /// @return phase2Solves The total number of Phase 2 solves a puzzle has.
    /// @return solves The total number of solves a puzzle has.
    function getPuzzleColorsAndSolves(uint32 _puzzleId)
        external
        view
        returns (
            uint120 colors,
            uint32 phase0Solves,
            uint32 phase1Solves,
            uint32 phase2Solves,
            uint32 solves
        );

    /// @param _puzzleId The ID of a puzzle.
    /// @return puzzle The address of the puzzle.
    /// @return addedTimestamp The timestamp at which the puzzle was added.
    /// @return firstSolveTimestamp The timestamp at which the first solution
    /// was submitted.
    function getPuzzle(uint32 _puzzleId)
        external
        view
        returns (IPuzzle puzzle, uint40 addedTimestamp, uint40 firstSolveTimestamp);

    /// @param _puzzleId The ID of a puzzle.
    /// @return The address of the puzzle author.
    function getPuzzleAuthor(uint32 _puzzleId) external view returns (address);

    /// @param _solver The address of a solver.
    /// @param _puzzleId The ID of a puzzle.
    /// @return Whether `_solver` has solved the puzzle of ID `_puzzleId`.
    function hasSolvedPuzzle(address _solver, uint32 _puzzleId) external view returns (bool);

    /// @param _tokenId The ID of an Authorship Token.
    /// @return Whether the Authorship Token of ID `_tokenId` has been used to
    /// add a puzzle.
    function hasUsedAuthorshipToken(uint256 _tokenId) external view returns (bool);

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /// @notice Mints a Flag NFT if the provided solution solves the puzzle.
    /// @param _puzzleId The ID of the puzzle.
    /// @param _solution The solution.
    function solve(uint32 _puzzleId, uint256 _solution) external payable;

    /// @notice Adds a puzzle to the contract. Note that an unused Authorship
    /// Token is required to add a puzzle (see {AuthorshipToken}).
    /// @param _puzzle The address of the puzzle.
    /// @param _id The ID of the Authorship Token to burn.
    function addPuzzle(IPuzzle _puzzle, uint256 _id) external;

    /// @notice Set the colors for a puzzle's Flags.
    /// @dev Only the author of the puzzle of ID `_puzzleId` may set its token
    /// renderer.
    /// @param _puzzleId The ID of the puzzle.
    /// @param _colors A bitpacked `uint120` of 5 24-bit colors for the puzzle's
    /// Flags.
    function setPuzzleColors(uint32 _puzzleId, uint120 _colors) external;

    /// @notice Burns and mints NFT #0 to the author of the puzzle of ID
    /// `_puzzleId` if it is the puzzle that went longest unsolved.
    /// @dev The puzzle of ID `_puzzleId` must have been solved at least once.
    /// @param _puzzleId The ID of the puzzle.
    function setFermat(uint32 _puzzleId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title The interface for a palette generator.
/// @author fiveoutofnine
/// @dev `IPaletteGenerator` contains generator functions for a color's red,
/// green, and blue color values. Each of these functions is intended to take in
/// a 18 decimal fixed-point number in [0, 1] representing the position in the
/// colormap and return the corresponding 18 decimal fixed-point number in
/// [0, 1] representing the value of each respective color.
interface IPaletteGenerator {
    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Reverts if the position is not a valid input.
    /// @dev The position is not a valid input if it is greater than 1e18.
    /// @param _position Position in the colormap.
    error InvalidPosition(uint256 _position);

    // -------------------------------------------------------------------------
    // Generators
    // -------------------------------------------------------------------------

    /// @notice Computes the intensity of red of the palette at some position.
    /// @dev The function should revert if `_position` is not a valid input
    /// (i.e. greater than 1e18). Also, the return value for all inputs must be
    /// a 18 decimal.
    /// @param _position Position in the colormap.
    /// @return uint256 Intensity of red in that color at the position
    /// `_position`.
    function r(uint256 _position) external pure returns (uint256);

    /// @notice Computes the intensity of green of the palette at some position.
    /// @dev The function should revert if `_position` is not a valid input
    /// (i.e. greater than 1e18). Also, the return value for all inputs must be
    /// a 18 decimal.
    /// @param _position Position in the colormap.
    /// @return uint256 Intensity of green in that color at the position
    /// `_position`.
    function g(uint256 _position) external pure returns (uint256);

    /// @notice Computes the intensity of blue of the palette at some position.
    /// @dev The function should revert if `_position` is not a valid input
    /// (i.e. greater than 1e18). Also, the return value for all inputs must be
    /// a 18 decimal.
    /// @param _position Position in the colormap.
    /// @return uint256 Intensity of blue in that color at the position
    /// `_position`.
    function b(uint256 _position) external pure returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title The interface for a puzzle on Curta
/// @notice The goal of players is to view the source code of the puzzle (may
/// range from just the bytecode to Solidity—whatever the author wishes to
/// provide), interpret the code, solve it as if it was a regular puzzle, then
/// verify the solution on-chain.
/// @dev Since puzzles are on-chain, everyone can view everyone else's
/// submissions. The generative aspect prevents front-running and allows for
/// multiple winners: even if players view someone else's solution, they still
/// have to figure out what the rules/constraints of the puzzle are and apply
/// the solution to their respective starting position.
interface IPuzzle {
    /// @notice Returns the puzzle's name.
    /// @return The puzzle's name.
    function name() external pure returns (string memory);

    /// @notice Generates the puzzle's starting position based on a seed.
    /// @dev The seed is intended to be `msg.sender` of some wrapper function or
    /// call.
    /// @param _seed The seed to use to generate the puzzle.
    /// @return The puzzle's starting position.
    function generate(address _seed) external returns (uint256);

    /// @notice Verifies that a solution is valid for the puzzle.
    /// @dev `_start` is intended to be an output from {IPuzzle-generate}.
    /// @param _start The puzzle's starting position.
    /// @param _solution The solution to the puzzle.
    /// @return Whether the solution is valid.
    function verify(uint256 _start, uint256 _solution) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides a function for encoding some bytes in base64
library Base64 {
    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345678" "9+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        string memory table = TABLE;
        uint256 encodedLength = ((data.length + 2) / 3) << 2;
        string memory result = new string(encodedLength + 0x20);

        assembly {
            mstore(result, encodedLength)
            let tablePtr := add(table, 1)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            let resultPtr := add(result, 0x20)

            for { } lt(dataPtr, endPtr) { } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore(resultPtr, shl(0xF8, mload(add(tablePtr, and(shr(0x12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(0xF8, mload(add(tablePtr, and(shr(0xC, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(0xF8, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(0xF8, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(0xF0, 0x3D3D)) }
            case 2 { mstore(sub(resultPtr, 1), shl(0xF8, 0x3D)) }
        }

        return result;
    }
}