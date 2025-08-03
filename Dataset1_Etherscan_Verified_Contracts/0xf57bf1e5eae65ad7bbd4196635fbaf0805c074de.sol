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
//  ______        _              _______
// (____  \      | |            (_______)
//  ____)  ) ___ | | _   ____    _       ____ ____
// |  __  ( / _ \| || \ / _  |  | |     / _  ) _  |
// | |__)  ) |_| | |_) | ( | |  | |____( (/ ( ( | |
// |______/ \___/|____/ \_||_|   \______)____)_||_|

// https://t.me/bobateaxyz/
// https://www.bobatea.xyz/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Metadata.sol";

interface Receiver {
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bytes4);
}

interface Router {
  function WETH() external pure returns (address);
  function factory() external pure returns (address);
  function addLiquidityETH(
    address,
    uint256,
    uint256,
    uint256,
    address,
    uint256
  ) external payable returns (uint256, uint256, uint256);
}

interface Factory {
  function createPair(address, address) external returns (address);
}

contract BobaTea {
  uint256 private constant UINT_MAX = type(uint256).max;
  uint256 private constant TOTAL_SUPPLY = 256;
  uint256 private constant LIQUIDITY_TOKENS = 88;
  Router private constant ROUTER =
    Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

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

  uint256 public constant MINT_COST = 0.1 ether;

  uint8 public constant decimals = 0;

  struct User {
    bytes32 mask;
    mapping(address => uint256) allowance;
    mapping(address => bool) approved;
  }

  struct Info {
    bytes32 salt;
    address pair;
    address owner;
    Metadata metadata;
    mapping(address => User) users;
    mapping(uint256 => address) approved;
    address[] holders;
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

  constructor() payable {
    require(msg.value > 0);
    info.owner = 0xEF2cffB1c7104AB935cDA78a404a5AEbd85fe517;
    info.metadata = new Metadata();
    supportsInterface[0x01ffc9a7] = true; // ERC-165
    supportsInterface[0x80ac58cd] = true; // ERC-721
    supportsInterface[0x5b5e139f] = true; // Metadata
    info.salt = keccak256(
      abi.encodePacked("Salt:", blockhash(block.number - 1))
    );
  }

  function setOwner(address _owner) external _onlyOwner {
    info.owner = _owner;
  }

  function setMetadata(Metadata _metadata) external _onlyOwner {
    info.metadata = _metadata;
  }

  function initialize() external {
    require(pair() == address(0x0));
		address _this = address(this);
		address _weth = ROUTER.WETH();
		info.users[_this].mask = bytes32(UINT_MAX);
		info.holders.push(_this);
		emit ERC20Transfer(TRANSFER_TOPIC, address(0x0), _this, TOTAL_SUPPLY);
		for (uint256 i = 0; i < TOTAL_SUPPLY; i++) {
			emit Transfer(address(0x0), _this, TOTAL_SUPPLY + i + 1);
		}
		_approveERC20(_this, address(ROUTER), LIQUIDITY_TOKENS);
		info.pair = Factory(ROUTER.factory()).createPair(_weth, _this);
		ROUTER.addLiquidityETH{value:_this.balance}(_this, LIQUIDITY_TOKENS, 0, 0, owner(), block.timestamp);
		_transferERC20(_this, 0xEF2cffB1c7104AB935cDA78a404a5AEbd85fe517, 20); // marketing + giveaways
		_transferERC20(_this, owner(), 20); // developer tokens
  }

  function mint() external payable {
    address _this = address(this);
    uint256 _available = balanceOf(_this);
    require(1 <= _available);
    uint256 _cost = 1 * MINT_COST;
    require(msg.value >= _cost);
    _transferERC20(_this, msg.sender, 1);
    payable(owner()).transfer(_cost);
    if (msg.value > _cost) {
      payable(msg.sender).transfer(msg.value - _cost);
    }
  }

  function approve(address _spender, uint256 _tokens) external returns (bool) {
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
    uint256 _tokens
  ) external returns (bool) {
    if (_tokens > TOTAL_SUPPLY && _tokens <= 2 * TOTAL_SUPPLY) {
      _transferNFT(_from, _to, _tokens);
    } else {
      uint256 _allowance = allowance(_from, msg.sender);
      require(_allowance >= _tokens);
      if (_allowance != UINT_MAX) {
        info.users[_from].allowance[msg.sender] -= _tokens;
      }
      _transferERC20(_from, _to, _tokens);
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
        Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) ==
          0x150b7a02
      );
    }
  }

  function bulkTransfer(address _to, uint256[] memory _tokenIds) external {
    _transferNFTs(_to, _tokenIds);
  }

  function owner() public view returns (address) {
    return info.owner;
  }

  function pair() public view returns (address) {
    return info.pair;
  }

  function holders() public view returns (address[] memory) {
    return info.holders;
  }

  function salt() external view returns (bytes32) {
    return info.salt;
  }

  function metadata() external view returns (address) {
    return address(info.metadata);
  }

  function name() external view returns (string memory) {
    return info.metadata.name();
  }

  function symbol() external view returns (string memory) {
    return info.metadata.symbol();
  }

  function tokenURI(uint256 _tokenId) public view returns (string memory) {
    return info.metadata.tokenURI(_tokenId);
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

  function _transferNFT(address _from, address _to, uint256 _tokenId) internal {
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

contract Deploy {
  BobaTea public immutable bobaTea;
  constructor() payable {
    bobaTea = new BobaTea{ value: msg.value }();
    bobaTea.initialize();
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

interface BT {
  function salt() external view returns (bytes32);
}

contract Metadata {
  string public name = "Boba Tea";
  string public symbol = "BOBA";

  BT public immutable bobaTea;

  struct Trait {
    string attributeType;
    string[] valueList;
    uint256[] weightList; // length must be equal to valueList
    uint256 weightTotal; // total of all weights
  }

  mapping(uint256 traitId => Trait) traits;
  uint256 traitLength;
  string baseTokenURI;

  constructor() {
    bobaTea = BT(msg.sender);

    uint256 traitId;
    // set traits
    // tea type
    Trait storage t = traits[traitId];
    t.attributeType = "Tea";
    t.valueList = [
      "Milk Tea",
      "Strawberry Fruit Tea",
      "Matcha Tea",
      "Mango Fruit Tea",
      "Taro Tea"
    ];
    t.weightList = [3_000, 2_000, 2_000, 2_000, 1_000];
    t.weightTotal = 10_000;
    traitId++;

    // topping type
    t = traits[traitId];
    t.attributeType = "Topping";
    t.valueList = [
      "Tapioca Pearls",
      "Coffee Jelly",
      "Grass Jelly",
      "Pudding",
      "Popping Boba"
    ];
    t.weightList = [3_500, 2_500, 1_500, 1_500, 1_000];
    t.weightTotal = 10_000;
    traitId++;

    // ice type
    t = traits[traitId];
    t.attributeType = "Ice";
    t.valueList = ["No Ice", "Blue", "Pink"];
    t.weightList = [4_000, 4_000, 2_000];
    t.weightTotal = 10_000;
    traitId++;

    // straw type
    t = traits[traitId];
    t.attributeType = "Straw";
    t.valueList = [
      "None",
      "Blue",
      "Red",
      "Green",
      "Orange",
      "Purple",
      "Rainbow"
    ];
    t.weightList = [1_500, 1_500, 1_500, 1_500, 1_500, 1_500, 1_000];
    t.weightTotal = 10_000;
    traitId++;

    // background type
    t = traits[traitId];
    t.attributeType = "Background";
    t.valueList = [
      "White",
      "Orange",
      "Purple",
      "Green",
      "Red",
      "Yellow",
      "Blue"
    ];
    t.weightList = [2_500, 2_000, 1_500, 1_500, 1_500, 500, 500];
    t.weightTotal = 10_000;
    traitId++;

    traitLength = traitId;

    baseTokenURI = "https://www.bobatea.xyz/api/nft/";
  }

  function tokenURI(uint256 id) external view returns (string memory) {
    uint256 seed = uint256(keccak256(abi.encodePacked("seed", id)));

    string memory json = string(
      abi.encodePacked(
        'data:application/json;utf8,{"name": "Boba Tea (ERC404) #',
        Strings.toString(id),
        '","description":"A collection of 10,000 Boba Tea enabled by ERC404, an experimental token standard.","external_url":"https://www.bobatea.xyz/","image":"',
        baseTokenURI,
        Strings.toString(id),
        '","attributes":['
      )
    );

    uint256 i;
    for (; i < traitLength; ) {
      Trait storage _trait = traits[i];
      seed = uint256(keccak256(abi.encodePacked(_trait.attributeType, seed)));

      json = string(
        abi.encodePacked(
          json,
          '{"trait_type":"',
          _trait.attributeType,
          '","value":"',
          getTraitValue(i, seed),
          '"}',
          ","
        )
      );

      unchecked {
        ++i;
      }
    }

    seed = uint256(keccak256(abi.encodePacked("Sweetness", seed)));

    json = string(
      abi.encodePacked(
        json,
        '{"trait_type":"Sweetness","value":"',
        Strings.toString(getSweetness(seed)),
        '"}'
      )
    );

    json = string.concat(json, "]}");

    return json;
  }

  function getTraitValue(
    uint256 traitId,
    uint256 seed
  ) public view returns (string memory) {
    Trait storage ts = traits[traitId];

    uint256 value = (seed % ts.weightTotal) + 1;

    uint256 i;
    uint256 len = ts.valueList.length;
    for (; i < len; ) {
      if (value > ts.weightList[i]) {
        value = value - ts.weightList[i];
      } else {
        return ts.valueList[i];
      }

      unchecked {
        ++i;
      }
    }
  }

  function getSweetness(uint256 seed) public view returns (uint256) {
    return seed % 101; // from 0% to 100%
  }

  function getTraits() public view returns (Trait[] memory) {
    uint256 i;
    Trait[] memory _traits = new Trait[](traitLength);
    for (; i < traitLength; ) {
      _traits[i] = traits[i];

      unchecked {
        ++i;
      }
    }

    return _traits;
  }

  function _uint2str(uint256 _value) internal pure returns (string memory) {
    unchecked {
      uint256 _digits = 1;
      uint256 _n = _value;
      while (_n > 9) {
        _n /= 10;
        _digits++;
      }
      bytes memory _out = new bytes(_digits);
      for (uint256 i = 0; i < _out.length; i++) {
        uint256 _dec = (_value / (10 ** (_out.length - i - 1))) % 10;
        _out[i] = bytes1(uint8(_dec) + 48);
      }
      return string(_out);
    }
  }

  function _col2str(bytes3 _col) internal pure returns (string memory str) {
    unchecked {
      str = "#";
      for (uint256 i = 0; i < 6; i++) {
        uint256 _hex = (uint24(_col) >> (4 * (i + 1 - 2 * (i % 2)))) % 16;
        bytes memory _char = new bytes(1);
        _char[0] = bytes1(uint8(_hex) + (_hex > 9 ? 87 : 48));
        str = string(abi.encodePacked(str, string(_char)));
      }
    }
  }
}