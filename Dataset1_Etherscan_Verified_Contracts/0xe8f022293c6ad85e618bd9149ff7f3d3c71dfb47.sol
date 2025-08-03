/*

██████╗ ██╗███╗   ██╗ ██████╗     ███╗   ██╗ ██████╗ ████████╗    ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
██╔══██╗██║████╗  ██║██╔═══██╗    ████╗  ██║██╔═══██╗╚══██╔══╝    ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
██║  ██║██║██╔██╗ ██║██║   ██║    ██╔██╗ ██║██║   ██║   ██║       █████╗  ██║   ██║██║   ██║██╔██╗ ██║██║  ██║
██║  ██║██║██║╚██╗██║██║   ██║    ██║╚██╗██║██║   ██║   ██║       ██╔══╝  ██║   ██║██║   ██║██║╚██╗██║██║  ██║
██████╔╝██║██║ ╚████║╚██████╔╝    ██║ ╚████║╚██████╔╝   ██║       ██║     ╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═══╝ ╚═════╝    ╚═╝       ╚═╝      ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
                                                                                                              
Website: https://dinonotfound.com
Twitter: https://twitter.com/dinonotfound404
*/

//SPDX-License-Identifier: MIT
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

abstract contract Ownable {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    error Unauthorized();
    error InvalidOwner();

    address public owner;

    modifier onlyOwner() virtual {
        if (msg.sender != owner) revert Unauthorized();

        _;
    }

    constructor(address _owner) {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address _owner) public virtual onlyOwner {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(msg.sender, _owner);
    }

    function revokeOwnership() public virtual onlyOwner {
        owner = address(0);

        emit OwnershipTransferred(msg.sender, address(0));
    }
}

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

/// @notice ERC404
///         A gas-efficient, mixed ERC20 / ERC721 implementation
///         with native liquidity and fractionalization.
///
///         This is an experimental standard designed to integrate
///         with pre-existing ERC20 / ERC721 support as smoothly as
///         possible.
///
/// @dev    In order to support full functionality of ERC20 and ERC721
///         supply assumptions are made that slightly constraint usage.
///         Ensure decimals are sufficiently large (standard 18 recommended)
///         as ids are effectively encoded in the lowest range of amounts.
///
///         NFTs are spent on ERC20 functions in a FILO queue, this is by
///         design.
///
abstract contract ERC404 is Ownable {
    // Events
    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event ERC721Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Errors
    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeRecipient();

    // Metadata
    /// @dev Token name
    string public name;

    /// @dev Token symbol
    string public symbol;

    /// @dev Decimals for fractional representation
    uint8 public immutable decimals;

    /// @dev Total supply in fractionalized representation
    uint256 public immutable totalSupply;

    /// @dev Current mint counter, monotonically increasing to ensure accurate ownership
    uint256 public minted;

    // Mappings
    /// @dev Balance of user in fractional representation
    mapping(address => uint256) public balanceOf;

    /// @dev Allowance of user in fractional representation
    mapping(address => mapping(address => uint256)) public allowance;

    /// @dev Approval in native representaion
    mapping(uint256 => address) public getApproved;

    /// @dev Approval for all in native representation
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /// @dev Owner of id in native representation
    mapping(uint256 => address) internal _ownerOf;

    /// @dev Array of owned ids in native representation
    mapping(address => uint256[]) internal _owned;

    /// @dev Tracks indices for the _owned mapping
    mapping(uint256 => uint256) internal _ownedIndex;

    /// @dev Addresses whitelisted from minting / burning for gas savings (pairs, routers, etc)
    mapping(address => bool) public whitelist;

    // Constructor
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalNativeSupply,
        address _owner
    ) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalNativeSupply * (10 ** decimals);
    }

    /// @notice Initialization function to set pairs / etc
    ///         saving gas by avoiding mint / burn on unnecessary targets
    function setWhitelist(address target, bool state) public onlyOwner {
        whitelist[target] = state;
    }

    /// @notice Function to find owner of a given native token
    function ownerOf(uint256 id) public view virtual returns (address owner) {
        owner = _ownerOf[id];

        if (owner == address(0)) {
            revert NotFound();
        }
    }

    /// @notice tokenURI must be implemented by child contract
    function tokenURI(uint256 id) public view virtual returns (string memory);

    /// @notice Function for token approvals
    /// @dev This function assumes id / native if amount less than or equal to current max id
    function approve(
        address spender,
        uint256 amountOrId
    ) public virtual returns (bool) {
        if (amountOrId <= minted && amountOrId > 0) {
            address owner = _ownerOf[amountOrId];

            if (msg.sender != owner && !isApprovedForAll[owner][msg.sender]) {
                revert Unauthorized();
            }

            getApproved[amountOrId] = spender;

            emit Approval(owner, spender, amountOrId);
        } else {
            allowance[msg.sender][spender] = amountOrId;

            emit Approval(msg.sender, spender, amountOrId);
        }

        return true;
    }

    /// @notice Function native approvals
    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Function for mixed transfers
    /// @dev This function assumes id / native if amount less than or equal to current max id
    function transferFrom(
        address from,
        address to,
        uint256 amountOrId
    ) public virtual {
        if (amountOrId <= minted) {
            if (from != _ownerOf[amountOrId]) {
                revert InvalidSender();
            }

            if (to == address(0)) {
                revert InvalidRecipient();
            }

            if (
                msg.sender != from &&
                !isApprovedForAll[from][msg.sender] &&
                msg.sender != getApproved[amountOrId]
            ) {
                revert Unauthorized();
            }

            balanceOf[from] -= _getUnit();

            unchecked {
                balanceOf[to] += _getUnit();
            }

            _ownerOf[amountOrId] = to;
            delete getApproved[amountOrId];

            // update _owned for sender
            uint256 updatedId = _owned[from][_owned[from].length - 1];
            _owned[from][_ownedIndex[amountOrId]] = updatedId;
            // pop
            _owned[from].pop();
            // update index for the moved id
            _ownedIndex[updatedId] = _ownedIndex[amountOrId];
            // push token to to owned
            _owned[to].push(amountOrId);
            // update index for to owned
            _ownedIndex[amountOrId] = _owned[to].length - 1;

            emit Transfer(from, to, amountOrId);
            emit ERC20Transfer(from, to, _getUnit());
        } else {
            uint256 allowed = allowance[from][msg.sender];

            if (allowed != type(uint256).max)
                allowance[from][msg.sender] = allowed - amountOrId;

            _transfer(from, to, amountOrId);
        }
    }

    /// @notice Function for fractional transfers
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    /// @notice Function for native transfers with contract support
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, "") !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Function for native transfers with contract support and callback data
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, data) !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Internal function for fractional transfers
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 unit = _getUnit();
        uint256 balanceBeforeSender = balanceOf[from];
        uint256 balanceBeforeReceiver = balanceOf[to];

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        // Skip burn for certain addresses to save gas
        if (!whitelist[from]) {
            uint256 tokens_to_burn = (balanceBeforeSender / unit) -
                (balanceOf[from] / unit);
            for (uint256 i = 0; i < tokens_to_burn; i++) {
                _burn(from);
            }
        }

        // Skip minting for certain addresses to save gas
        if (!whitelist[to]) {
            uint256 tokens_to_mint = (balanceOf[to] / unit) -
                (balanceBeforeReceiver / unit);
            for (uint256 i = 0; i < tokens_to_mint; i++) {
                _mint(to);
            }
        }

        emit ERC20Transfer(from, to, amount);
        return true;
    }

    // Internal utility logic
    function _getUnit() internal view returns (uint256) {
        return 10 ** decimals;
    }

    function _mint(address to) internal virtual {
        if (to == address(0)) {
            revert InvalidRecipient();
        }

        unchecked {
            minted++;
        }

        uint256 id = minted;

        if (_ownerOf[id] != address(0)) {
            revert AlreadyExists();
        }

        _ownerOf[id] = to;
        _owned[to].push(id);
        _ownedIndex[id] = _owned[to].length - 1;

        emit Transfer(address(0), to, id);
    }

    function _burn(address from) internal virtual {
        if (from == address(0)) {
            revert InvalidSender();
        }

        uint256 id = _owned[from][_owned[from].length - 1];
        _owned[from].pop();
        delete _ownedIndex[id];
        delete _ownerOf[id];
        delete getApproved[id];

        emit Transfer(from, address(0), id);
    }

    function _setNameSymbol(
        string memory _name,
        string memory _symbol
    ) internal {
        name = _name;
        symbol = _symbol;
    }
}

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

contract DinoData {

//// Bodys of Dinos
        bytes[] internal body_data = [
                bytes(hex'0605B76C3A0705B76C3A0805B76C3A0905B76D3B0606B76C3A0706B76C3A0806B76C3A0906B76C3A0a06B76D3B0607B76C3A0707B76C3A0807B76C3A0907B76C3A0a07B76D3B0608B76C3A0708B76C3A0808B76C3A0409B76C3A0609B76C3A0709B76C3A0809B76C3A0909B76D3B050aB76C3A060aB76C3A070aB76C3A080aB76C3A060bB76D3B080bB76D3B'),
                bytes(hex'06053B352007053B352008053B352009053B3520060655471C070655471C080655471C090655471C0a0654471C06076A571B07076A571B08076A571B09076A571B0a076A571B06087E661B07087E661B08087E661B04098D721906098D721907098E711908098E711909098D7219050aA1811D060aA1811D070aA1811D080aA0811D060bAD8A1D080bAD8A1D'),
                bytes(hex'0605745B2A0705745B2A0805745B2A0905735D2D0606745B2A0706745B2A0806745B2A0906745B2A0a06735D2D0607745B2A0707745B2A0807745B2A0907745B2A0a07735D2D0608745B2A0708745B2A0808745B2A0409745B2A0609745B2A0709745B2A0809745B2A0909735D2D050a745B2A060a745B2A070a745B2A080a745B2A060b735D2D080b735D2D'),
                bytes(hex'060553535307055353530805535353090553555606065353530706535353080653535309065353530a0653555606075353530707535353080753535309075353530a0753555606085353530708535353080853535304095454540609535353070953535308095353530909535556050a545454060a535353070a535353080a535353060b535556080b535556'),
                bytes(hex'06050F0F0F07050F0F0F08050F0F0F09050F0F0F06062525250706252525080625252509062525250a0625252506073C3C3C07073C3C3C08073C3C3C09073C3C3C0a073D3D3D06084E4E4E07084E4E4E08084E4E4E04096464640609646464070964646408096464640909656464050a7D7D7D060a7D7D7D070a7D7D7D080a7D7D7C060b929292080b929292'),
                bytes(hex'06053E263407053E263408053E263409053E26340606532B420706532B420806532B420906532B420a06532B420607712F560707712F560807712F560907712F560a07712F56060895316B070895316B080895316B0409B82B7E0609A72E750709A72E750809A72E750909A72E75050aB82B7E060aB82B7E070aB82B7E080aB82B7E060bCF2D8C080bCF2D8C'),
                bytes(hex'0605954C780705954C780805954C780905944E7A0606954C780706954C780806954C780906954C780a06944E7A0607954C780707954C780807954C780907954C780a07944E7A0608954C780708954C780808954C780409954D780609954C780709954C780809954C780909944E7A050a954D78060a954C78070a954C78080a954C78060b944E7A080b944E7A'),
                bytes(hex'060538235B070538235B080538235B090538245D060638235B070638235B080638235B090638235B0a0638245D060738235B070738235B080738235B090738235B0a0738245D060838235B070838235B080838235B040938255D060938235B070938235B080938235B090938245D050a38255D060a38235B070a38235B080a38235B060b38245D080b38245D'),
                bytes(hex'06051E272E07051E272E08051E272E09051E272E0606203D510706203D510806203D510906203D510a06203D5106071E4F7107071E4F7108071E4F7109071E4F710a071E4F7106081A5A8507081A5A8508081B5A8504091B6AA006091A6AA107091A6AA108091A6AA109091B6AA0050a1B7BBD060a1B7BBD070a1B7BBD080a1B7BBD060b1C86CE080b1C86CE'),
                bytes(hex'0605244235070524423608052442360905244235060621523D070621523D080621523D090621523D0a0621523E06072162470707216247080721624709072162470a072162470608226F4F0708226F4F0808226F4F040923875E060923875E070923875D080923875D090923875E050a239364060a239364070a239364080a239365060b229F6B080b229F6B'),
                bytes(hex'06050D524107050D524108050D524109050E534306060D524107060D524108060D524109060D52410a060E534306070D524107070D524108070D524109070D52410a070E534306080D524107080D524108080D524104090F544406090D524107090D524108090D524109090E5343050a0F5444060a0D5241070a0D5241080a0D5241060b0E5343080b0E5343'),
                bytes(hex'0605409EA80705409EA80805409EA80905409DA806063477BB07063477BB08063477BB09063477BB0a063477BB0607334EBB0707334EBB0807334EBB0907334EBB0a07344EBB0608943EA90708943EA90808943EA804099C6E3A06099C6E3A07099C6E3A08099C6E3A09099C6E3B050a86A939060a86A939070a86A939080a86A83A060b41983B080b41983B'),
                bytes(hex'060545B1B9070545B1B9080545B1B9090547B1B9060645B1B9070645B1B9080645B1B9090645B1B90a0647B1B9060745B1B9070745B1B9080745B1B9090745B1B90a0747B1B9060845B1B9070845B1B9080845B1B9040947B1B9060945B1B9070945B1B9080945B1B9090947B1B9050a47B1B9060a45B1B9070a45B1B9080a45B1B9060b47B1B9080b47B1B9'),
                bytes(hex'060591362B070591362B080591362B090591352B060691352B070691362B080691362B090691362B0a0691352B060791352B070791362B080791362B090791362B0a0791352B060891352B070891362B080891362B040991352B060991362B070991362B080991362B090991352B050a91362B060a91362B070a91362B080a91352B060b91352B080b91352B'),
                bytes(hex'0605282D550705282D550805282D550905282D550606252E6E0706252E6E0806252E6E0906252E6E0a06252E6E06072530810707253081080725308109072530810a072630810608212E900708212E900808222E8F0409202EA506091F2FA507091F2FA508091F2EA50909202EA5050a2133B8060a2133B8070a2133B8080a2233B7060b1E32D3080b1E32D3'),
                bytes(hex'060525398707052539870805253987090525398706062539870706253987080625398709062539870a0625398706072539870707253987080725398709072539870a0725398706082539870708253987080825398704092739860609253987070925398708092539870909253987050a273986060a253987070a253987080a253987060b253987080b253987')
        ];

	string[] internal body_traits = [
        'orange',
        'croc gradient',
        'brown',
        'gray',
        'grayspace gradient',
        'magenta gradient',
        'magenta',
        'dark purple',
        'blue gradient',
        'green gradient',
        'green',
        'rainbow',
        'aqua',
        'orange red',
        'royal gradient',
        'royal'
    ];

        uint[] internal  body_probability = [8, 11, 18, 27, 30, 33, 43, 53, 56, 59, 65, 67, 77, 87, 90, 100];

//// Chest of Dinos
        bytes[] internal chest_data = [
                bytes(hex'0708CB462D0808CB462D0809CB462D070aCB462D080aCB462D'),
                bytes(hex'070885853008088585300809858530070a858530080a858530'),
                bytes(hex'070887878708088787870809878787070a878787080a878787'),
                bytes(hex'070885428908088542890809854289070a854289080a854289'),
                bytes(hex'070823232308082323230809232323070a232323080a232323'),
                bytes(hex'07083670A608083670A608093670A6070a3670A6080a3670A6'),
                bytes(hex'07082988AA08082988AA08092988AA070a2988AA080a2988AA'),
                bytes(hex'07083FA19508083FA19508093FA195070a3FA195080a3FA195'),
                bytes(hex'0708262A8B0808262A8B0809262A8B070a262A8B080a262A8B')
        ];

	string[] internal chest_traits = [
        'red orange',       
        'croc green',
        'gray',       
        'purple',
        'charcoal',
        'blue',     
        'aqua',
        'teal',       
        'royal'
	];

        uint[] internal  chest_probability = [10, 18, 29, 42, 57, 68, 77, 89, 100];

//// Eyes of Dinos
        bytes[] internal eye_data = [
                bytes(hex'0706B8B23B0906395BD3'),
                bytes(hex'0706A1763B0906A1763B'),
                bytes(hex'0706D7D7D70906D7D7D7'),
                bytes(hex'070685EBFE090685EBFE'),
                bytes(hex'0706B73BB8090627BDC9'),
                bytes(hex'0706A03A8F0906A03A8F'),
                bytes(hex'07061FDBFE08061FDBFE09061FDBFE0a061FDBFE0b061FDBFE0c061FDBFE0d061FDBFE0e061FDBFE0f061FDBFE'),
                bytes(hex'07066D6D6E09066D6D6E'),
                bytes(hex'07062B7FB609062B7FB6'),
                bytes(hex'070642ABBE090642ABBE'),
                bytes(hex'07060B0B0B09060B0B0B'),
                bytes(hex'0706213ECF0906213ECF')
        ];

	string[] internal eye_traits = [
        'yellow blue', 
        'sand',
        'light gray',   
        'blue',
        'purple turquoise',   
        'purple',
        'lazer',       
        'dark gray',
        'denim',      
        'turquoise',
        'black',       
        'royal'
	];

        uint[] internal  eye_probability = [4, 19, 30, 36, 40, 48, 50, 58, 64, 70, 90, 100];


//// Face of Dinos
        bytes[] internal face_data = [
                bytes(hex''),
                bytes(hex'0605C5C5C50705C5C5C50805C5C5C50905C5C5C50606C5C5C50806C5C5C50a06C5C5C5'),
                bytes(hex'0606B5B5B50806B5B5B50a06B5B5B5'),
                bytes(hex'06051049e107051049e108051049e109051049e10a051049e104061049e105061049e106061049e108061049e10a061049e104071049e106071049e107071049e108071049e109071049e10a071049e1'),
                bytes(hex'0704b7b7b70804b7b7b70605b7b7b70705b7b7b70805b7b7b70905b7b7b70606b7b7b70806b7b7b70a06b7b7b70707b6b7b70907b6b7b70b07b6b7b7'),
                bytes(hex'070600000008060000000906000000')
        ];

	string[] internal face_traits = [
        'normal',
        'mask',
        'ninja',
        'based noun glasses',
        'dark skull',
        'vizor'
	];

        uint[] internal  face_probability = [65, 75, 85, 90, 95, 100];

//// Feet of Dinos
        bytes[] internal feet_data = [
                bytes(hex''),
                bytes(hex'0009222222000a222222010a222222000b222222020b222222000c222222010c222222020c222222030c222222010d222222030d222222050d3A9940060d3A9940070d3A9940080d3A993F'),
                bytes(hex'010821212201092121220209212121020a212122030a212121010b212122030b212122040b212121020c212122040c212122050c212121060cE7E7E8070c212121080cE7E7E8'),
                bytes(hex'040b84B3C60a0b84B3C6050c85B4C7060c85B5C7070c85B5C7080c85B4C7090c85B4C7060d464F53080d464F53')
        ];

	string[] internal feet_traits = [
        'normal', 
        'hoverboard', 
        'rocket boots', 
        'skateboard'
	];

        uint[] internal  feet_probability = [76, 84, 92, 100];

//// Heads of Dinos
        bytes[] internal head_data = [
                bytes(hex''),
                bytes(hex'060566A836070566A836080566A836090566A835050666A835040766A835'),
                bytes(hex'0703CE71390803CD713A0903CE71390504CE71390604CE71390704CD713A0804CD713A0904CD713A'),
                bytes(hex'06036CA93407036CA93408036CA93406046CA93407046AA83508046AA83509046AA8350a046BA835'),
                bytes(hex'0602eaeaea0702eaeaea0802e9e9e90603eaeaea0703eaeaea0803e9e9e90604eaeaea0704eaeaea0804e9e9e9'),
                bytes(hex'0503f0a92a0703f1a9290903f0a92a0504f1a9290604f0a82b0704f0a82a0804f1a92a0904f0a92a'),
                bytes(hex'0504C2C2C20604C2C2C20704C2C2C20804C2C2C20505C2C2C20506C2C2C20606C2C2C20507C2C2C20607C2C2C2'),
                bytes(hex'060340A235070340A235080341A235050440A235060440A235070440A235080440A235090440A2350a0441A235'),
                bytes(hex'05046060600604606060080460606009046060600505606060'),
                bytes(hex'0703194CD10803194DD20604194CD10704194CD10804194CD10904194DD2'),
                bytes(hex'07032424240803242424090325252405043DBAC906043DBAC907043DBAC908043DBAC909043DBAC9')
        ];

	string[] internal head_traits = [
        'none',
        'bandana',
        'cap backwards',
        'cap forwards',
        'chef',
        'crown',
        'headphones',
        'long peak cap forwards',
        'mouse ears',
        'silly blue bucket hat',
        'two tone cap backwards'
	];

        uint[] internal  head_probability = [45, 48, 57, 67, 71, 74, 78, 86, 88, 92, 100];

/////////////////// Spikes of Dinos
        bytes[] internal spike_data = [
                bytes(hex''),
                bytes(hex'0604BE96560804BE96560505BE96560507BE96560509BE9656'),
                bytes(hex'06043E91B708043E91B705053E91B705073E91B705093E91B7'),
                bytes(hex'0604BEBFBF0804BEBFBF0505BEBFBF0507BEBFBF0509BEBFBF'),
                bytes(hex'0604944C8C0804944C8C0505944C8C0507944C8C0509944C8C'),
                bytes(hex'06044C4C4C08044C4C4C05054C4C4C05074C4C4C05094C4C4C'),
                bytes(hex'06045C2789080459852D05052B66A10507895827050923A69B'),
                bytes(hex'06042970C708042970C705052970C705072970C705092970C7'),
                bytes(hex'06043B993B08043B993B05053B993B05073B993B05093B993B'),
                bytes(hex'06043A979908043A979905053A979905073A979905093A9799'),
                bytes(hex'0604A1514E0804A1514E0505A1514E0507A1514E0509A1514E'),
                bytes(hex'06041111110804111111050511111105071111110509111111'),
                bytes(hex'06043351AD08043351AD05053351AD05073351AD05093351AD')
        ];

	string[] internal spike_traits = [
        'none',     
        'gold',       
        'burnt blue',
        'light gray',  
        'purple',
        'dark gray', 
        'multicolor',
        'blue',
        'green',       
        'teal',
        'maroon',       
        'black',
        'royal'
	];

        uint[] internal  spike_probability = [4, 12, 20, 30, 38, 49, 52, 60, 68, 76, 84, 92, 100];

}

///// Based on Pandora and Based OnChain Dinos by Apex777.eth - @Apex_Ether
contract Dino404 is ERC404, DinoData {
    string public dataURI;
    string public baseTokenURI;

    constructor(
        address _owner
    ) ERC404("Dino Not Found", "DINO404", 18, 10000, _owner) {
        balanceOf[_owner] = 10000 * 10 ** 18;
    }

    function setDataURI(string memory _dataURI) public onlyOwner {
        dataURI = _dataURI;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }

    function _getSVGTraitData(bytes memory data) internal pure returns (string memory) {

        require(data.length % 5 == 0, "#");

        /// if empty this is a transparent react
        if (data.length == 0) {
             return "<rect x=\"0\" y=\"0\" width=\"0\" height=\"0\" fill=\"rgb(0,0,0)\"/>"; 
        }

        // Initialize arrays to store values
        uint reactCount = data.length / 5;


        /// react string to return
        string memory rects;

        uint[] memory x = new uint[](reactCount);
        uint[] memory y = new uint[](reactCount);
        uint[] memory r = new uint[](reactCount);
        uint[] memory g = new uint[](reactCount);
        uint[] memory b = new uint[](reactCount);

        // Iterate through each react and get the values we need
        for (uint i = 0; i < reactCount; i++) {

            // Convert and assign values to respective arrays
            x[i] = uint8(data[i * 5]);
            y[i] = uint8(data[i * 5 + 1]);
            r[i] = uint8(data[i * 5 + 2]);
            g[i] = uint8(data[i * 5 + 3]);
            b[i] = uint8(data[i * 5 + 4]);

            // Convert uint values to strings
            string memory xStr = Strings.toString(x[i]);
            string memory yStr = Strings.toString(y[i]);
            string memory rStr = Strings.toString(r[i]);
            string memory gStr = Strings.toString(g[i]);
            string memory bStr = Strings.toString(b[i]);

            rects = string(abi.encodePacked(rects, '<rect x="', xStr, '" y="', yStr, '" width="1" height="1" fill="rgb(', rStr, ',', gStr, ',', bStr, ')" />'));
        }

        return rects;
    }


    function buildSVG(uint256[7] memory localTraits) internal view returns (string memory) {
        string memory svg = string(abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" shape-rendering="crispEdges" width="512" height="512">',
        '<rect width="16" height="16" fill="#f9d3ad"/>',
            _getSVGTraitData(body_data[localTraits[0]]),
            _getSVGTraitData(chest_data[localTraits[1]]),
            _getSVGTraitData(eye_data[localTraits[2]]),
            _getSVGTraitData(spike_data[localTraits[3]]),
            _getSVGTraitData(feet_data[localTraits[4]]),
            _getSVGTraitData(face_data[localTraits[5]]),
            _getSVGTraitData(head_data[localTraits[6]]),
        '</svg>'
        ));
        return svg;
    }

    function _pickTraitByProbability(uint seed, bytes[] memory traitArray, uint[] memory traitProbability) internal pure returns (uint) {
        require(traitArray.length > 0, "e");
        require(traitArray.length == traitProbability.length, "l");
        
        for (uint i = 0; i < traitProbability.length; i++) {
            if(seed < traitProbability[i]) {
                return i;
            }
        }
        // Fallback, return first element as a safe default
        return 0;
    }

    function _getDinoTraits(uint256[7] memory traits) internal view returns (string memory) {
        string memory metadata = string(abi.encodePacked(
        '{"trait_type":"Body", "value":"', body_traits[traits[0]], '"},',
        '{"trait_type":"Chest", "value":"', chest_traits[traits[1]], '"},',
        '{"trait_type":"Eyes", "value":"', eye_traits[traits[2]], '"},',
        '{"trait_type":"Spikes", "value":"', spike_traits[traits[3]], '"},',
        '{"trait_type":"Feet", "value":"', feet_traits[traits[4]], '"},',
        '{"trait_type":"Face", "value":"', face_traits[traits[5]], '"},',
        '{"trait_type":"Head", "value":"', head_traits[traits[6]], '"}'
        ));
        return metadata;
    }

    function seeds(uint256 id) internal view returns (uint256[7] memory) {
        // Picking trait based on rarity
        return [
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "body"))) % 100, body_data, body_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "chest"))) % 100, chest_data, chest_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "eye"))) % 100, eye_data, eye_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "spike"))) % 100, spike_data, spike_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "feet"))) % 100, feet_data, feet_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "face"))) % 100, face_data, face_probability),
            _pickTraitByProbability(uint256(keccak256(abi.encodePacked(id, "head"))) % 100, head_data, head_probability)
        ];
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (bytes(baseTokenURI).length > 0) {
            return string.concat(baseTokenURI, Strings.toString(id));
        } else {
            uint256[7] memory trait_values = seeds(id);

            // Get image
            string memory preimage = buildSVG(trait_values);
            string memory image = Base64.encode(bytes(preimage));
            string memory traits = _getDinoTraits(trait_values);

            string memory jsonPreImage = string.concat(
                string.concat(
                    string.concat('{"name": "Dino Not Found #', Strings.toString(id)),
                    '","description":"A collection of 10,000 Dinos enabled by ERC404, an experimental token standard.","external_url":"https://dinonotfound.com","image":"data:image/svg+xml;base64,'
                ),
                string.concat(image)
            );
            string memory jsonPostImage = string.concat(
                '","attributes":[',traits
            );
            string memory jsonPostTraits = ']}';

            return
                string.concat(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string.concat(
                        string.concat(jsonPreImage, jsonPostImage),
                        jsonPostTraits
                    )))
                );
        }
    }
}