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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './MitoBlobs.sol';
import './wBLOBS.sol';

contract Deployer {
	MitoBlobs immutable public mitoblobs;
    wBLOBS immutable public wblobs;

	constructor() {
		mitoblobs = new MitoBlobs();
        wblobs = new wBLOBS(address(mitoblobs));
	}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*

MitoBlobs (BLOBS)
First PFP collection on ERC20721

- 256 total supply
- 102 BLOBS for initial liquidity
- 0.1 ETH mint from contract price
- tradable on both Uniswap and Opensea

@MitoBlobs
https://mitoblobs.xyz

*/

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface Receiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ICellMates {
	function balanceOf(address owner) external view returns (uint256);
}

contract MitoBlobs {
    uint256 private constant UINT_MAX = type(uint256).max;
    uint256 private constant TOTAL_SUPPLY = 256;

	address private constant CELLMATES = 0xf953f75c50Eb45A6044179EB57f76317093b367F;
	address private constant WCELL = 0x6828c4C136e5670c4Fd5fA907a0fcb41A99a9D59;

    uint256 private constant M1 =
        0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 private constant M2 =
        0x3333333333333333333333333333333333333333333333333333333333333333;
    uint256 private constant M4 =
        0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
    uint256 private constant H01 =
        0x0101010101010101010101010101010101010101010101010101010101010101;
    bytes32 private constant TRANSFER_TOPIC =
        keccak256(bytes("Transfer(address,address,uint256)"));
    bytes32 private constant APPROVAL_TOPIC =
        keccak256(bytes("Approval(address,address,uint256)"));

    struct User {
        bytes32 mask;
        mapping(address => uint256) allowance;
        mapping(address => bool) approved;
    }

    struct Info {
        address owner;
        address wBlobs;
        mapping(address => User) users;
        mapping(uint256 => address) approved;
        address[] holders;
        string name;
        string symbol;
        string baseURI;
        uint256 mintPrice;
    }
    Info private info;

    mapping(bytes4 => bool) public supportsInterface;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event ERC20Transfer(
        bytes32 indexed topic0,
        address indexed from,
        address indexed to,
        uint256 tokens
    ) anonymous;
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed tokenId
    );
    event ERC20Approval(
        bytes32 indexed topic0,
        address indexed owner,
        address indexed spender,
        uint256 tokens
    ) anonymous;
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    modifier _onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    constructor() {
        info.owner = 0xCd4cdfB4294eF2699E39eE2D20F25bAA0E58ef79;
        info.name = "MitoBlobs";
        info.symbol = "BLOBS";
        info.baseURI = "https://nftstorage.link/ipfs/bafybeiah76j63cycugvnf6bplybcsr3qbyqkyxsn4tyeki5dxlcau7tdmu/";
        info.mintPrice = 0.1 ether;
        supportsInterface[0x01ffc9a7] = true; // ERC-165
        supportsInterface[0x80ac58cd] = true; // ERC-721
        supportsInterface[0x5b5e139f] = true; // Metadata

        address _this = address(this);
        info.users[_this].mask = bytes32(UINT_MAX);
        info.holders.push(_this);
        emit ERC20Transfer(TRANSFER_TOPIC, address(0x0), _this, TOTAL_SUPPLY);
        for (uint256 i = 0; i < TOTAL_SUPPLY; i++) {
            emit Transfer(address(0x0), _this, TOTAL_SUPPLY + i + 1);
        }

        _transferERC20(
            _this,
            owner(),
            102 + // 40% of supply for $BLOB & $wBLOB liquidity pools
            23 + // 4.5% for marketing + 4.5% for team
            28 // CellMates $wCELL holders airdrop
        );
    }

    function setOwner(address _owner) external _onlyOwner {
        info.owner = _owner;
    }

    function setBaseURI(string memory uri) external _onlyOwner {
        info.baseURI = uri;
    }

    function setWBlobs(address d) external _onlyOwner {
        info.wBlobs = d;
    }

    function setMintPrice(uint256 price) external _onlyOwner {
        info.mintPrice = price;
    }

    function mint(uint256 _tokens) external payable {
        address _this = address(this);
        uint256 _available = balanceOf(_this);
        require(_tokens <= _available);
        uint256 _cost = _tokens * info.mintPrice;
        require(msg.value >= _cost);
        _transferERC20(_this, msg.sender, _tokens);
        payable(owner()).transfer(_cost);
        if (msg.value > _cost) {
            payable(msg.sender).transfer(msg.value - _cost);
        }
    }

    function approve(
        address _spender,
        uint256 _tokens
    ) external returns (bool) {
        if (_tokens > TOTAL_SUPPLY && _tokens <= 2 * TOTAL_SUPPLY) {
            _approveNFT(_spender, _tokens);
        } else {
            _approveERC20(msg.sender, _spender, _tokens);
        }
        return true;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        info.users[msg.sender].approved[_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transfer(address _to, uint256 _tokens) external returns (bool) {
        _transferERC20(msg.sender, _to, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external returns (bool) {
        if (_tokenId > TOTAL_SUPPLY && _tokenId <= 2 * TOTAL_SUPPLY) {
            _transferNFT(_from, _to, _tokenId);
        } else {
            uint256 _allowance = allowance(_from, msg.sender);
            require(_allowance >= _tokenId);
            if (_allowance != UINT_MAX) {
                info.users[_from].allowance[msg.sender] -= _tokenId;
            }
            _transferERC20(_from, _to, _tokenId);
        }
        return true;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public {
        _transferNFT(_from, _to, _tokenId);
        uint32 _size;
        assembly {
            _size := extcodesize(_to)
        }
        if (_size > 0) {
            require(
                Receiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                ) == 0x150b7a02
            );
        }
    }

    function bulkTransfer(address _to, uint256[] memory _tokenIds) external {
        _transferNFTs(_to, _tokenIds);
    }

    function owner() public view returns (address) {
        return info.owner;
    }

    function holders() public view returns (address[] memory) {
        return info.holders;
    }

    function name() external view returns (string memory) {
        return info.name;
    }

    function symbol() external view returns (string memory) {
        return info.symbol;
    }

    function tokenURI(uint256 id) public view returns (string memory) {
		address _owner = ownerOf(id);
        uint256 balance =
            ICellMates(CELLMATES).balanceOf(_owner) * 1e18 +
            ICellMates(WCELL).balanceOf(_owner);

        uint8 progress;
        if (balance > 1e17) { // 0.1 $CELL or $wCELL equiv.
            if (balance < 2e17) { // 0.2 $CELL or $wCELL equiv.
                progress = 1;
            } else if (balance < 3e17) { // 0.3 $CELL or $wCELL equiv.
                progress = 2;
            } else if (balance < 5e17) { // 0.5 $CELL or $wCELL equiv.
                progress = 3;
            } else if (balance < 7e17 + 5e16) { // 0.75 $CELL or $wCELL equiv.
                progress = 4;
            } else if (balance < 1e18) { // 1 $CELL or $wCELL equiv.
                progress = 5;
            } else if (balance < 2e18) { // 2 $CELL or $wCELL equiv.
                progress = 6;
            } else if (balance < 3e18) {
                progress = 7; // 3 $CELL or $wCELL equiv.
            } else if (balance >= 3e18) {
                progress = 8;
            } else {
                progress = 1;
            }
        }

        return
            string(
                abi.encodePacked(
                    info.baseURI,
                    Strings.toString(id),
                    "-",
                    Strings.toString(progress),
                    ".json"
                )
            );
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function maskOf(address _user) public view returns (bytes32) {
        return info.users[_user].mask;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return _popcount(maskOf(_user));
    }

    function allowance(
        address _user,
        address _spender
    ) public view returns (uint256) {
        return info.users[_user].allowance[_spender];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        unchecked {
            require(_tokenId > TOTAL_SUPPLY && _tokenId <= 2 * TOTAL_SUPPLY);
            bytes32 _mask = bytes32(1 << (_tokenId - TOTAL_SUPPLY - 1));
            address[] memory _holders = holders();
            for (uint256 i = 0; i < _holders.length; i++) {
                if (maskOf(_holders[i]) & _mask == _mask) {
                    return _holders[i];
                }
            }
            return address(0x0);
        }
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_tokenId > TOTAL_SUPPLY && _tokenId <= 2 * TOTAL_SUPPLY);
        return info.approved[_tokenId];
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool) {
        return info.users[_owner].approved[_operator];
    }

    function getToken(
        uint256 _tokenId
    )
        public
		view
        returns (address tokenOwner, address approved, string memory uri)
    {
        return (ownerOf(_tokenId), getApproved(_tokenId), tokenURI(_tokenId));
    }

    function getTokens(
        uint256[] memory _tokenIds
    )
        external
		view
        returns (
            address[] memory owners,
            address[] memory approveds,
            string[] memory uris
        )
    {
        uint256 _length = _tokenIds.length;
        owners = new address[](_length);
        approveds = new address[](_length);
        uris = new string[](_length);
        for (uint256 i = 0; i < _length; i++) {
            (owners[i], approveds[i], uris[i]) = getToken(_tokenIds[i]);
        }
    }

    function _approveERC20(
        address _owner,
        address _spender,
        uint256 _tokens
    ) internal {
        info.users[_owner].allowance[_spender] = _tokens;
        emit ERC20Approval(APPROVAL_TOPIC, _owner, _spender, _tokens);
    }

    function _approveNFT(address _spender, uint256 _tokenId) internal {
        bytes32 _mask = bytes32(1 << (_tokenId - TOTAL_SUPPLY - 1));
        require(maskOf(msg.sender) & _mask == _mask);
        info.approved[_tokenId] = _spender;
        emit Approval(msg.sender, _spender, _tokenId);
    }

    function _transferERC20(
        address _from,
        address _to,
        uint256 _tokens
    ) internal {
        unchecked {
            bytes32 _mask;
            uint256 _pos = 0;
            uint256 _count = 0;
            uint256 _n = uint256(maskOf(_from));
            uint256[] memory _tokenIds = new uint256[](_tokens);
            while (_n > 0 && _count < _tokens) {
                if (_n & 1 == 1) {
                    _mask |= bytes32(1 << _pos);
                    _tokenIds[_count++] = TOTAL_SUPPLY + _pos + 1;
                }
                _pos++;
                _n >>= 1;
            }
            require(_count == _tokens);
            require(maskOf(_from) & _mask == _mask);
            _transfer(_from, _to, _mask, _tokenIds);
        }
    }

    function _transferNFT(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        unchecked {
            require(_tokenId > TOTAL_SUPPLY && _tokenId <= 2 * TOTAL_SUPPLY);
            bytes32 _mask = bytes32(1 << (_tokenId - TOTAL_SUPPLY - 1));
            require(maskOf(_from) & _mask == _mask);
            require(
                msg.sender == _from ||
                    msg.sender == getApproved(_tokenId) ||
                    isApprovedForAll(_from, msg.sender)
            );
            uint256[] memory _tokenIds = new uint256[](1);
            _tokenIds[0] = _tokenId;
            _transfer(_from, _to, _mask, _tokenIds);
        }
    }

    function _transferNFTs(address _to, uint256[] memory _tokenIds) internal {
        unchecked {
            bytes32 _mask;
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                _mask |= bytes32(1 << (_tokenIds[i] - TOTAL_SUPPLY - 1));
            }
            require(_popcount(_mask) == _tokenIds.length);
            require(maskOf(msg.sender) & _mask == _mask);
            _transfer(msg.sender, _to, _mask, _tokenIds);
        }
    }

    function _transfer(
        address _from,
        address _to,
        bytes32 _mask,
        uint256[] memory _tokenIds
    ) internal {
        unchecked {
            require(_tokenIds.length > 0);
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                if (getApproved(_tokenIds[i]) != address(0x0)) {
                    info.approved[_tokenIds[i]] = address(0x0);
                    emit Approval(address(0x0), address(0x0), _tokenIds[i]);
                }
                emit Transfer(_from, _to, _tokenIds[i]);
            }
            info.users[_from].mask ^= _mask;
            bool _from0 = maskOf(_from) == 0x0;
            bool _to0 = maskOf(_to) == 0x0;
            info.users[_to].mask |= _mask;
            if (_from0) {
                uint256 _index;
                address[] memory _holders = holders();
                for (uint256 i = 0; i < _holders.length; i++) {
                    if (_holders[i] == _from) {
                        _index = i;
                        break;
                    }
                }
                if (_to0) {
                    info.holders[_index] = _to;
                } else {
                    info.holders[_index] = _holders[_holders.length - 1];
                    info.holders.pop();
                }
            } else if (_to0) {
                info.holders.push(_to);
            }
            require(maskOf(_from) & maskOf(_to) == 0x0);
            emit ERC20Transfer(TRANSFER_TOPIC, _from, _to, _tokenIds.length);
        }
    }

    function _popcount(bytes32 _b) internal pure returns (uint256) {
        uint256 _n = uint256(_b);
        if (_n == UINT_MAX) {
            return 256;
        }
        unchecked {
            _n -= (_n >> 1) & M1;
            _n = (_n & M2) + ((_n >> 2) & M2);
            _n = (_n + (_n >> 4)) & M4;
            _n = (_n * H01) >> 248;
        }
        return _n;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*

Wrapped MitoBlobs (wBLOBS)
Turn your BLOBs into wBLOBS that can be fractionally traded on Uniswap.

@MitoBlobs
https://mitoblobs.xyz

*/

interface Callable {
    function tokenCallback(
        address _from,
        uint256 _tokens,
        bytes calldata _data
    ) external returns (bool);
}

interface MB {
    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function isApprovedForAll(address, address) external view returns (bool);

    function transfer(address _to, uint256 _tokens) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool);
}

contract wBLOBS {
    uint256 private constant UINT_MAX = type(uint256).max;

    MB public mitoblobs;

    string public constant name = "Wrapped Blobs";
    string public constant symbol = "wBLOBS";
    uint8 public constant decimals = 18;

    struct User {
        uint256 balance;
        mapping(address => uint256) allowance;
    }

    struct Info {
        mapping(address => User) users;
    }
    Info private info;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 tokens
    );
    event Wrap(address indexed owner, uint256 tokens);
    event Unwrap(address indexed owner, uint256 tokens);
    
    constructor(address _mitoblobs) {
        mitoblobs = MB(_mitoblobs);
    }

    function wrap(uint256 tokenId) public {
        uint256 _balanceBefore = mitoblobs.balanceOf(address(this));
        mitoblobs.transferFrom(msg.sender, address(this), tokenId);
        uint256 _wrapped = mitoblobs.balanceOf(address(this)) - _balanceBefore;
        require(_wrapped > 0);
        info.users[msg.sender].balance += _wrapped * 1e18;
        emit Transfer(address(0x0), msg.sender, _wrapped * 1e18);
        emit Wrap(msg.sender, _wrapped);
    }

    function wrapMultiple(uint256[] memory tokenIds) external {
        for (uint256 i; i < tokenIds.length; i++) {
            wrap(tokenIds[i]);
        }
    }

    function unwrap(uint256 _tokens) external {
        require(_tokens > 0);
        require(balanceOf(msg.sender) >= _tokens * 1e18);
        info.users[msg.sender].balance -= _tokens * 1e18;
        mitoblobs.transfer(msg.sender, _tokens);
        emit Transfer(msg.sender, address(0x0), _tokens * 1e18);
        emit Unwrap(msg.sender, _tokens);
    }

    function multisend(address[] memory recipients, uint256 amount) external {
        require(balanceOf(msg.sender) >= recipients.length * amount, "Your balance is too low");
        for (uint256 i; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amount);
        }
    }

    function transfer(address _to, uint256 _tokens) external returns (bool) {
        return _transfer(msg.sender, _to, _tokens);
    }

    function approve(
        address _spender,
        uint256 _tokens
    ) external returns (bool) {
        info.users[msg.sender].allowance[_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool) {
        uint256 _allowance = allowance(_from, msg.sender);
        require(_allowance >= _tokens);
        if (_allowance != UINT_MAX) {
            info.users[_from].allowance[msg.sender] -= _tokens;
        }
        return _transfer(_from, _to, _tokens);
    }

    function transferAndCall(
        address _to,
        uint256 _tokens,
        bytes calldata _data
    ) external returns (bool) {
        _transfer(msg.sender, _to, _tokens);
        uint32 _size;
        assembly {
            _size := extcodesize(_to)
        }
        if (_size > 0) {
            require(Callable(_to).tokenCallback(msg.sender, _tokens, _data));
        }
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return mitoblobs.balanceOf(address(this)) * 1e18;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return info.users[_user].balance;
    }

    function allowance(
        address _user,
        address _spender
    ) public view returns (uint256) {
        return info.users[_user].allowance[_spender];
    }

    function allInfoFor(
        address _user
    )
        external
        view
        returns (
            uint256 totalTokens,
            uint256 userBLOBs,
            uint256 userAllowance,
            bool userApprovedForAll,
            uint256 userBalance
        )
    {
        totalTokens = totalSupply();
        userBLOBs = mitoblobs.balanceOf(_user);
        userAllowance = mitoblobs.allowance(_user, address(this));
        userApprovedForAll = mitoblobs.isApprovedForAll(_user, address(this));
        userBalance = balanceOf(_user);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokens
    ) internal returns (bool) {
        unchecked {
            require(balanceOf(_from) >= _tokens);
            info.users[_from].balance -= _tokens;
            info.users[_to].balance += _tokens;
            emit Transfer(_from, _to, _tokens);
            return true;
        }
    }
}