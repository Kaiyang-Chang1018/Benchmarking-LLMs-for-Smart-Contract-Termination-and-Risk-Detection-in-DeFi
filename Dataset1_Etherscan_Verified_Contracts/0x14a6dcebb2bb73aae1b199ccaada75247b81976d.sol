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

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
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
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
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

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
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

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
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
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

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

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
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

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
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

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
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
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

interface IUserVault {
    /// @notice Mint a new vault to msg.sender
    /// @return newId The id of the new vault
    function mint() external returns (uint256);

    /// @notice Burn a vault and return all assets to owner.
    function burn(uint256 _vaultId, address _assetRecipient) external;

    /// @notice Burn a vault and return all assets to owner.
    /// @param _vaultId The vault to burn.
    /// @param _collections The NFT collections to burn.
    /// @param _tokenIds The NFT token IDs to burn.
    /// @param _tokens The ERC20 tokens to burn.
    function burnAndWithdraw(
        uint256 _vaultId,
        address[] calldata _collections,
        uint256[] calldata _tokenIds,
        address[] calldata _tokens
    ) external;

    /// @notice Get the vault owner of an NFT. Will return 0 if none.
    /// @param _collection The NFT collection.
    /// @param _tokenId The NFT token ID.
    /// @return vaultId The vault owning the NFT.
    function ERC721OwnerOf(address _collection, uint256 _tokenId) external view returns (uint256);

    /// @notice Get the balance for a given token for a given vault. address(0) = ETH
    /// @param _vaultId The vault to check.
    /// @param _token The token to check.
    /// @return Balance The balance of the token in the vault.
    function ERC20BalanceOf(uint256 _vaultId, address _token) external view returns (uint256);

    /// @notice Deposit an NFT into the vault.
    /// @param _vaultId The vault to deposit into.
    /// @param _collection The NFT collection.
    /// @param _tokenId The NFT token ID.
    function depositERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external;

    /// @notice Deposit multiple NFTs.
    /// @param _vaultId The vault to deposit into.
    /// @param _collection The NFT collection.
    /// @param _tokenIds The NFT token IDs.
    function depositERC721s(uint256 _vaultId, address _collection, uint256[] calldata _tokenIds) external;

    /// @notice Deposit an ERC20 token into the vault.
    /// @param _vaultId The vault to deposit into.
    /// @param _token The ERC20 token.
    /// @param _amount The amount to deposit.
    function depositERC20(uint256 _vaultId, address _token, uint256 _amount) external;

    /// @notice Deposit ETH into the vault.
    /// @param _vaultId The vault to deposit into.
    function depositEth(uint256 _vaultId) external payable;

    /// @notice Withdraw an NFT from the vault.
    /// @param _vaultId The vault to withdraw from.
    /// @param _collection The NFT collection.
    /// @param _tokenId The NFT token ID.
    function withdrawERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external;

    /// @notice Withdraw multiple NFTs.
    /// @param _vaultId The vault to withdraw from.
    /// @param _collections The NFT collections.
    /// @param _tokenIds The NFT token IDs.
    function withdrawERC721s(uint256 _vaultId, address[] calldata _collections, uint256[] calldata _tokenIds)
        external;

    /// @notice Withdraw an ERC20 token from the vault.
    /// @param _vaultId The vault to withdraw from.
    /// @param _token The ERC20 token.
    function withdrawERC20(uint256 _vaultId, address _token) external;

    /// @notice Withdraw ERC20s from the vault.
    /// @param _vaultId The vault to withdraw from.
    /// @param _tokens The ERC20 tokens.
    function withdrawERC20s(uint256 _vaultId, address[] calldata _tokens) external;

    /// @notice Withdraw ETH from the vault.
    /// @param _vaultId The vault to withdraw from.
    function withdrawEth(uint256 _vaultId) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "@solmate/auth/Owned.sol";
import "@solmate/utils/ReentrancyGuard.sol";

import "./InputChecker.sol";

/// @title AddressManager
/// @notice A contract that handles a whitelist of addresses and their indexes.
/// @dev We assume no more than 65535 addresses will be added to the directory.
contract AddressManager is InputChecker, Owned, ReentrancyGuard {
    event AddressAdded(address address_added);

    event AddressRemovedFromWhitelist(address address_removed);

    event AddressWhitelisted(address address_whitelisted);

    error AddressAlreadyAddedError(address _address);

    error AddressNotAddedError(address _address);

    mapping(address => uint16) private _directory;

    mapping(uint16 => address) private _inverseDirectory;

    mapping(address => bool) private _whitelist;

    uint16 private _lastAdded;

    constructor(address[] memory _original) Owned(tx.origin) {
        uint256 total = _original.length;
        for (uint256 i; i < total;) {
            _add(_original[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Adds an address to the directory. If it already exists,
    ///        reverts. It assumes it's whitelisted.
    function add(address _entry) external onlyOwner returns (uint16) {
        return _add(_entry);
    }

    /// @notice Whitelist an address that's already part of the directory.
    function addToWhitelist(address _entry) external onlyOwner {
        if (_directory[_entry] == 0) {
            revert AddressNotAddedError(_entry);
        }
        _whitelist[_entry] = true;

        emit AddressWhitelisted(_entry);
    }

    /// @notice Removes an address from the whitelist. We still keep it
    ///         in the directory since this mapping is relevant across time.
    /// @param _entry The address to remove from the whitelist.
    function removeFromWhitelist(address _entry) external onlyOwner {
        _whitelist[_entry] = false;

        emit AddressRemovedFromWhitelist(_entry);
    }

    /// @param _address The address to get the index for.
    /// @return The index for a given address.
    function addressToIndex(address _address) external view returns (uint16) {
        return _directory[_address];
    }

    /// @param _index The index to get the address for.
    /// @return The address for a given index.
    function indexToAddress(uint16 _index) external view returns (address) {
        return _inverseDirectory[_index];
    }

    /// @param _entry The address to check if it's whitelisted.
    /// @return Whether the address is whitelisted or not.
    function isWhitelisted(address _entry) external view returns (bool) {
        return _whitelist[_entry];
    }

    function _add(address _entry) private returns (uint16) {
        _checkAddressNotZero(_entry);
        if (_directory[_entry] != 0) {
            revert AddressAlreadyAddedError(_entry);
        }
        unchecked {
            ++_lastAdded;
        }
        _directory[_entry] = _lastAdded;
        _inverseDirectory[_lastAdded] = _entry;
        _whitelist[_entry] = true;

        emit AddressAdded(_entry);

        return _lastAdded;
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

/// @title InputChecker
/// @author Florida St
/// @notice Some basic input checks.
abstract contract InputChecker {
    error AddressZeroError();

    function _checkAddressNotZero(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressZeroError();
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/utils/Strings.sol";
import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "./AddressManager.sol";
import "../interfaces/IUserVault.sol";

/// @title Auction Loan Liquidator
/// @author Florida St
/// @notice NFTs that represent bundles.
contract UserVault is ERC721, ERC721TokenReceiver, IUserVault, Owned {
    using SafeTransferLib for ERC20;

    string private constant _BASE_URI = "https://gondi.xyz/user_vaults/";
    uint256 private _nextId = 0;

    address public constant ETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @notice IDs that were burnt are pending withdrawal
    mapping(uint256 => address) _readyForWithdrawal;

    /// @notice NFT balances for a given vault: collection => (tokenId => vaultId)
    mapping(address => mapping(uint256 => uint256)) _vaultERC721s;

    /// @notice ERC20 balances for a given vault: token => (vaultId => amount). address(0) = ETH
    mapping(address => mapping(uint256 => uint256)) _vaultERC20s;

    AddressManager private immutable _currencyManager;

    AddressManager private immutable _collectionManager;

    event ERC721Deposited(uint256 vaultId, address collection, uint256 tokenId);

    event ERC20Deposited(uint256 vaultId, address token, uint256 amount);

    event ERC721Withdrawn(uint256 vaultId, address collection, uint256 tokenId);

    event ERC20Withdrawn(uint256 vaultId, address token, uint256 amount);

    error CurrencyNotWhitelistedError();

    error CollectionNotWhitelistedError();

    error LengthMismatchError();

    error NotApprovedError(uint256 vaultId);

    error WithdrawingETHError();

    error WrongMethodError();

    error AssetNotOwnedError();

    error VaultNotExistsError(uint256 vaultId);

    modifier onlyApproved(uint256 _vaultId) {
        if (
            msg.sender != ownerOf(_vaultId) && !isApprovedForAll[ownerOf(_vaultId)][msg.sender]
                && getApproved[_vaultId] != msg.sender
        ) {
            revert NotApprovedError(_vaultId);
        }
        _;
    }

    modifier onlyReadyForWithdrawal(uint256 _vaultId) {
        if (_readyForWithdrawal[_vaultId] != msg.sender) {
            revert NotApprovedError(_vaultId);
        }
        _;
    }

    modifier vaultExists(uint256 _vaultId) {
        if (_ownerOf[_vaultId] == address(0)) {
            revert VaultNotExistsError(_vaultId);
        }
        _;
    }

    /// @param currencyManager Address of the CurrencyManager contract.
    /// @param collectionManager Address of the CollectionManager contract.
    constructor(address currencyManager, address collectionManager)
        ERC721("GONDI_USER_VAULT", "GUV")
        Owned(tx.origin)
    {
        _currencyManager = AddressManager(currencyManager);
        _collectionManager = AddressManager(collectionManager);
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 _vaultId) public pure override returns (string memory) {
        return string.concat(_BASE_URI, Strings.toString(_vaultId));
    }

    /// @inheritdoc IUserVault
    function mint() external returns (uint256) {
        uint256 _vaultId;
        unchecked {
            _vaultId = ++_nextId;
        }
        _mint(msg.sender, _vaultId);
        return _vaultId;
    }

    /// @inheritdoc IUserVault
    function burn(uint256 _vaultId, address _assetRecipient) external {
        _thisBurn(_vaultId, _assetRecipient);
    }

    /// @inheritdoc IUserVault
    function burnAndWithdraw(
        uint256 _vaultId,
        address[] calldata _collections,
        uint256[] calldata _tokenIds,
        address[] calldata _tokens
    ) external {
        _thisBurn(_vaultId, msg.sender);
        for (uint256 i = 0; i < _collections.length;) {
            _withdrawERC721(_vaultId, _collections[i], _tokenIds[i]);
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 0; i < _tokens.length;) {
            _withdrawERC20(_vaultId, _tokens[i]);
            unchecked {
                ++i;
            }
        }
        _withdrawEth(_vaultId);
    }

    function ERC721OwnerOf(address _collection, uint256 _tokenId) external view returns (uint256) {
        return _vaultERC721s[_collection][_tokenId];
    }

    function ERC20BalanceOf(uint256 _vaultId, address _token) external view returns (uint256) {
        return _vaultERC20s[_token][_vaultId];
    }

    /// @inheritdoc IUserVault
    function depositERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external vaultExists(_vaultId) {
        if (!_collectionManager.isWhitelisted(_collection)) {
            revert CollectionNotWhitelistedError();
        }
        _depositERC721(msg.sender, _vaultId, _collection, _tokenId);
    }

    /// @inheritdoc IUserVault
    /// @dev Read `depositERC721`.
    function depositERC721s(uint256 _vaultId, address _collection, uint256[] calldata _tokenIds)
        external
        vaultExists(_vaultId)
    {
        if (!_collectionManager.isWhitelisted(_collection)) {
            revert CollectionNotWhitelistedError();
        }
        for (uint256 i = 0; i < _tokenIds.length;) {
            _depositERC721(msg.sender, _vaultId, _collection, _tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUserVault
    /// @dev Read `depositERC721`.
    function depositERC20(uint256 _vaultId, address _token, uint256 _amount) external vaultExists(_vaultId) {
        if (_token == ETH) {
            revert WrongMethodError();
        }
        _depositERC20(msg.sender, _vaultId, _token, _amount);
    }

    /// @inheritdoc IUserVault
    /// @dev Read `depositERC721`.
    function depositEth(uint256 _vaultId) external payable vaultExists(_vaultId) vaultExists(_vaultId) {
        _vaultERC20s[ETH][_vaultId] += msg.value;

        emit ERC20Deposited(_vaultId, ETH, msg.value);
    }

    /// @inheritdoc IUserVault
    function withdrawERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external {
        _withdrawERC721(_vaultId, _collection, _tokenId);
    }

    /// @inheritdoc IUserVault
    function withdrawERC721s(uint256 _vaultId, address[] calldata _collections, uint256[] calldata _tokenIds)
        external
    {
        if (_collections.length != _tokenIds.length) {
            revert LengthMismatchError();
        }
        for (uint256 i = 0; i < _collections.length;) {
            _withdrawERC721(_vaultId, _collections[i], _tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUserVault
    function withdrawERC20(uint256 _vaultId, address _token) external {
        _withdrawERC20(_vaultId, _token);
    }

    /// @inheritdoc IUserVault
    function withdrawERC20s(uint256 _vaultId, address[] calldata _tokens) external {
        for (uint256 i = 0; i < _tokens.length;) {
            _withdrawERC20(_vaultId, _tokens[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUserVault
    function withdrawEth(uint256 _vaultId) external {
        _withdrawEth(_vaultId);
    }

    function _depositERC721(address _depositor, uint256 _vaultId, address _collection, uint256 _tokenId) private {
        ERC721(_collection).transferFrom(_depositor, address(this), _tokenId);

        _vaultERC721s[_collection][_tokenId] = _vaultId;

        emit ERC721Deposited(_vaultId, _collection, _tokenId);
    }

    function _depositERC20(address _depositor, uint256 _vaultId, address _token, uint256 _amount) private {
        if (!_currencyManager.isWhitelisted(_token)) {
            revert CurrencyNotWhitelistedError();
        }
        ERC20(_token).safeTransferFrom(_depositor, address(this), _amount);

        _vaultERC20s[_token][_vaultId] += _amount;
        emit ERC20Deposited(_vaultId, _token, _amount);
    }

    /// @dev We are allowing anyone to deposit NFTs into a vault (not just the owner). Because of this we call transferFrom
    /// and not safeTransferFrom to avoid someone locking assets by transferring an ERC721 with the hook corrupted (we do
    /// have a whitelist to avoid this but being extra cautious.)
    function _withdrawERC721(uint256 _vaultId, address _collection, uint256 _tokenId)
        private
        onlyReadyForWithdrawal(_vaultId)
    {
        if (_vaultERC721s[_collection][_tokenId] != _vaultId) {
            revert AssetNotOwnedError();
        }
        ERC721(_collection).transferFrom(address(this), msg.sender, _tokenId);

        delete _vaultERC721s[_collection][_tokenId];

        emit ERC721Withdrawn(_vaultId, _collection, _tokenId);
    }

    function _withdrawERC20(uint256 _vaultId, address _token) private onlyReadyForWithdrawal(_vaultId) {
        uint256 amount = _vaultERC20s[_token][_vaultId];
        if (amount == 0) {
            return;
        }
        delete _vaultERC20s[_token][_vaultId];

        ERC20(_token).safeTransfer(msg.sender, amount);

        emit ERC20Withdrawn(_vaultId, _token, amount);
    }

    function _thisBurn(uint256 _vaultId, address _assetRecipient) private onlyApproved(_vaultId) {
        _burn(_vaultId);
        _readyForWithdrawal[_vaultId] = _assetRecipient;
    }

    function _withdrawEth(uint256 _vaultId) private onlyReadyForWithdrawal(_vaultId) {
        uint256 amount = _vaultERC20s[ETH][_vaultId];
        if (amount == 0) {
            return;
        }
        delete _vaultERC20s[ETH][_vaultId];

        (bool sent,) = payable(msg.sender).call{value: amount}("");
        if (!sent) {
            revert WithdrawingETHError();
        }

        emit ERC20Withdrawn(_vaultId, ETH, amount);
    }
}