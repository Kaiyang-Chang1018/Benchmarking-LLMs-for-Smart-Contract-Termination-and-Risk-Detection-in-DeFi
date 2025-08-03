// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

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
        return a >= b ? a : b;
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

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
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

interface IAdminACLV0 {
    /**
     * @notice Token ID `_tokenId` minted to `_to`.
     * @param previousSuperAdmin The previous superAdmin address.
     * @param newSuperAdmin The new superAdmin address.
     * @param genArt721CoreAddressesToUpdate Array of genArt721Core
     * addresses to update to the new superAdmin, for indexing purposes only.
     */
    event SuperAdminTransferred(
        address indexed previousSuperAdmin,
        address indexed newSuperAdmin,
        address[] genArt721CoreAddressesToUpdate
    );

    /// Type of the Admin ACL contract, e.g. "AdminACLV0"
    function AdminACLType() external view returns (string memory);

    /// super admin address
    function superAdmin() external view returns (address);

    /**
     * @notice Calls transferOwnership on other contract from this contract.
     * This is useful for updating to a new AdminACL contract.
     * @dev this function should be gated to only superAdmin-like addresses.
     */
    function transferOwnershipOn(
        address _contract,
        address _newAdminACL
    ) external;

    /**
     * @notice Calls renounceOwnership on other contract from this contract.
     * @dev this function should be gated to only superAdmin-like addresses.
     */
    function renounceOwnershipOn(address _contract) external;

    /**
     * @notice Checks if sender `_sender` is allowed to call function with selector
     * `_selector` on contract `_contract`.
     */
    function allowed(
        address _sender,
        address _contract,
        bytes4 _selector
    ) external returns (bool);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.
pragma solidity ^0.8.0;

import "./IEngineRegistryV0.sol";

interface ICoreRegistryV1 is IEngineRegistryV0 {
    function registerContracts(
        address[] calldata contractAddresses,
        bytes32[] calldata coreVersions,
        bytes32[] calldata coreTypes
    ) external;

    function unregisterContracts(address[] calldata contractAddresses) external;

    function getNumRegisteredContracts() external view returns (uint256);

    function getRegisteredContractAt(
        uint256 index
    ) external view returns (address);

    function isRegisteredContract(
        address contractAddress
    ) external view returns (bool isRegistered);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.
pragma solidity ^0.8.0;

interface IEngineRegistryV0 {
    /// ADDRESS
    /**
     * @notice contract has been registered as a contract that is powered by the Art Blocks Engine.
     */
    event ContractRegistered(
        address indexed _contractAddress,
        bytes32 _coreVersion,
        bytes32 _coreType
    );

    /// ADDRESS
    /**
     * @notice contract has been unregistered as a contract that is powered by the Art Blocks Engine.
     */
    event ContractUnregistered(address indexed _contractAddress);

    /**
     * @notice Emits a `ContractRegistered` event with the provided information.
     * @dev this function should be gated to only deployer addresses.
     */
    function registerContract(
        address _contractAddress,
        bytes32 _coreVersion,
        bytes32 _coreType
    ) external;

    /**
     * @notice Emits a `ContractUnregistered` event with the provided information, validating that the provided
     *         address was indeed previously registered.
     * @dev this function should be gated to only deployer addresses.
     */
    function unregisterContract(address _contractAddress) external;
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

interface IFilteredMinterV0 {
    /**
     * @notice Price per token in wei updated for project `_projectId` to
     * `_pricePerTokenInWei`.
     */
    event PricePerTokenInWeiUpdated(
        uint256 indexed _projectId,
        uint256 indexed _pricePerTokenInWei
    );

    /**
     * @notice Currency updated for project `_projectId` to symbol
     * `_currencySymbol` and address `_currencyAddress`.
     */
    event ProjectCurrencyInfoUpdated(
        uint256 indexed _projectId,
        address indexed _currencyAddress,
        string _currencySymbol
    );

    /// togglePurchaseToDisabled updated
    event PurchaseToDisabledUpdated(
        uint256 indexed _projectId,
        bool _purchaseToDisabled
    );

    // getter function of public variable
    function minterType() external view returns (string memory);

    function genArt721CoreAddress() external returns (address);

    function minterFilterAddress() external returns (address);

    // Triggers a purchase of a token from the desired project, to the
    // TX-sending address.
    function purchase(
        uint256 _projectId
    ) external payable returns (uint256 tokenId);

    // Triggers a purchase of a token from the desired project, to the specified
    // receiving address.
    function purchaseTo(
        address _to,
        uint256 _projectId
    ) external payable returns (uint256 tokenId);

    // Toggles the ability for `purchaseTo` to be called directly with a
    // specified receiving address that differs from the TX-sending address.
    function togglePurchaseToDisabled(uint256 _projectId) external;

    // Called to make the minter contract aware of the max invocations for a
    // given project.
    function setProjectMaxInvocations(uint256 _projectId) external;

    // Gets if token price is configured, token price in wei, currency symbol,
    // and currency address, assuming this is project's minter.
    // Supersedes any defined core price.
    function getPriceInfo(
        uint256 _projectId
    )
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            string memory currencySymbol,
            address currencyAddress
        );
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

import "./IFilteredMinterV0.sol";

pragma solidity ^0.8.0;

/**
 * @title This interface extends the IFilteredMinterV0 interface in order to
 * add support for generic project minter configuration updates.
 * @dev keys represent strings of finite length encoded in bytes32 to minimize
 * gas.
 * @author Art Blocks Inc.
 */
interface IFilteredMinterV1 is IFilteredMinterV0 {
    /// ANY
    /**
     * @notice Generic project minter configuration event. Removes key `_key`
     * for project `_projectId`.
     */
    event ConfigKeyRemoved(uint256 indexed _projectId, bytes32 _key);

    /// BOOL
    /**
     * @notice Generic project minter configuration event. Sets value of key
     * `_key` to `_value` for project `_projectId`.
     */
    event ConfigValueSet(uint256 indexed _projectId, bytes32 _key, bool _value);

    /// UINT256
    /**
     * @notice Generic project minter configuration event. Sets value of key
     * `_key` to `_value` for project `_projectId`.
     */
    event ConfigValueSet(
        uint256 indexed _projectId,
        bytes32 _key,
        uint256 _value
    );

    /**
     * @notice Generic project minter configuration event. Adds value `_value`
     * to the set of uint256 at key `_key` for project `_projectId`.
     */
    event ConfigValueAddedToSet(
        uint256 indexed _projectId,
        bytes32 _key,
        uint256 _value
    );

    /**
     * @notice Generic project minter configuration event. Removes value
     * `_value` to the set of uint256 at key `_key` for project `_projectId`.
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed _projectId,
        bytes32 _key,
        uint256 _value
    );

    /// ADDRESS
    /**
     * @notice Generic project minter configuration event. Sets value of key
     * `_key` to `_value` for project `_projectId`.
     */
    event ConfigValueSet(
        uint256 indexed _projectId,
        bytes32 _key,
        address _value
    );

    /**
     * @notice Generic project minter configuration event. Adds value `_value`
     * to the set of addresses at key `_key` for project `_projectId`.
     */
    event ConfigValueAddedToSet(
        uint256 indexed _projectId,
        bytes32 _key,
        address _value
    );

    /**
     * @notice Generic project minter configuration event. Removes value
     * `_value` to the set of addresses at key `_key` for project `_projectId`.
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed _projectId,
        bytes32 _key,
        address _value
    );

    /// BYTES32
    /**
     * @notice Generic project minter configuration event. Sets value of key
     * `_key` to `_value` for project `_projectId`.
     */
    event ConfigValueSet(
        uint256 indexed _projectId,
        bytes32 _key,
        bytes32 _value
    );

    /**
     * @notice Generic project minter configuration event. Adds value `_value`
     * to the set of bytes32 at key `_key` for project `_projectId`.
     */
    event ConfigValueAddedToSet(
        uint256 indexed _projectId,
        bytes32 _key,
        bytes32 _value
    );

    /**
     * @notice Generic project minter configuration event. Removes value
     * `_value` to the set of bytes32 at key `_key` for project `_projectId`.
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed _projectId,
        bytes32 _key,
        bytes32 _value
    );

    /**
     * @dev Strings not supported. Recommend conversion of (short) strings to
     * bytes32 to remain gas-efficient.
     */
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

import "./IFilteredMinterV1.sol";

pragma solidity ^0.8.0;

/**
 * @title This interface extends the IFilteredMinterV1 interface in order to
 * add support for manually setting project max invocations.
 * @author Art Blocks Inc.
 */
interface IFilteredMinterV2 is IFilteredMinterV1 {
    /**
     * @notice Local max invocations for project `_projectId`, tied to core contract `_coreContractAddress`,
     * updated to `_maxInvocations`.
     */
    event ProjectMaxInvocationsLimitUpdated(
        uint256 indexed _projectId,
        uint256 _maxInvocations
    );

    // Sets the local max invocations for a given project, checking that the provided max invocations is
    // less than or equal to the global max invocations for the project set on the core contract.
    // This does not impact the max invocations value defined on the core contract.
    function manuallyLimitProjectMaxInvocations(
        uint256 _projectId,
        uint256 _maxInvocations
    ) external;
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import "./IAdminACLV0.sol";
import "./IGenArt721CoreContractV3_Base.sol";

/**
 * @title This interface extends IGenArt721CoreContractV3_Base with functions
 * that are part of the Art Blocks Flagship core contract.
 * @author Art Blocks Inc.
 */
// This interface extends IGenArt721CoreContractV3_Base with functions that are
// in part of the Art Blocks Flagship core contract.
interface IGenArt721CoreContractV3 is IGenArt721CoreContractV3_Base {
    // @dev new function in V3
    function getPrimaryRevenueSplits(
        uint256 _projectId,
        uint256 _price
    )
        external
        view
        returns (
            uint256 artblocksRevenue_,
            address payable artblocksAddress_,
            uint256 artistRevenue_,
            address payable artistAddress_,
            uint256 additionalPayeePrimaryRevenue_,
            address payable additionalPayeePrimaryAddress_
        );

    // @dev Art Blocks primary sales payment address
    function artblocksPrimarySalesAddress()
        external
        view
        returns (address payable);

    /**
     * @notice Backwards-compatible (pre-V3) function returning Art Blocks
     * primary sales payment address (now called artblocksPrimarySalesAddress).
     */
    function artblocksAddress() external view returns (address payable);

    // @dev Percentage of primary sales allocated to Art Blocks
    function artblocksPrimarySalesPercentage() external view returns (uint256);

    /**
     * @notice Backwards-compatible (pre-V3) function returning Art Blocks
     * primary sales percentage (now called artblocksPrimarySalesPercentage).
     */
    function artblocksPercentage() external view returns (uint256);

    // @dev Art Blocks secondary sales royalties payment address
    function artblocksSecondarySalesAddress()
        external
        view
        returns (address payable);

    // @dev Basis points of secondary sales allocated to Art Blocks
    function artblocksSecondarySalesBPS() external view returns (uint256);

    /**
     * @notice Backwards-compatible (pre-V3) function  that gets artist +
     * artist's additional payee royalty data for token ID `_tokenId`.
     * WARNING: Does not include Art Blocks portion of royalties.
     */
    function getRoyaltyData(
        uint256 _tokenId
    )
        external
        view
        returns (
            address artistAddress,
            address additionalPayee,
            uint256 additionalPayeePercentage,
            uint256 royaltyFeeByID
        );
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import "./IAdminACLV0.sol";

/**
 * @title This interface is intended to house interface items that are common
 * across all GenArt721CoreContractV3 flagship and derivative implementations.
 * This interface extends the IManifold royalty interface in order to
 * add support the Royalty Registry by default.
 * @author Art Blocks Inc.
 */
interface IGenArt721CoreContractV3_Base {
    // This interface emits generic events that contain fields that indicate
    // which parameter has been updated. This is sufficient for application
    // state management, while also simplifying the contract and indexing code.
    // This was done as an alternative to having custom events that emit what
    // field-values have changed for each event, given that changed values can
    // be introspected by indexers due to the design of this smart contract
    // exposing these state changes via publicly viewable fields.

    /**
     * @notice Event emitted when the Art Blocks Curation Registry contract is updated.
     * @dev only utilized by subset of V3 core contracts (Art Blocks Curated contracts)
     * @param artblocksCurationRegistryAddress Address of Art Blocks Curation Registry contract.
     */
    event ArtBlocksCurationRegistryContractUpdated(
        address indexed artblocksCurationRegistryAddress
    );

    /**
     * @notice Project's royalty splitter was updated to `_splitter`.
     * @dev New event in v3.2
     * @param projectId The project ID.
     * @param royaltySplitter The new splitter address to receive royalties.
     */
    event ProjectRoyaltySplitterUpdated(
        uint256 indexed projectId,
        address indexed royaltySplitter
    );

    // The following fields are used to indicate which contract-level parameter
    // has been updated in the `PlatformUpdated` event:
    // @dev only append to the end of this enum in the case of future updates
    enum PlatformUpdatedFields {
        FIELD_NEXT_PROJECT_ID, // 0
        FIELD_NEW_PROJECTS_FORBIDDEN, // 1
        FIELD_DEFAULT_BASE_URI, // 2
        FIELD_RANDOMIZER_ADDRESS, // 3
        FIELD_NEXT_CORE_CONTRACT, // 4
        FIELD_ARTBLOCKS_DEPENDENCY_REGISTRY_ADDRESS, // 5
        FIELD_ARTBLOCKS_ON_CHAIN_GENERATOR_ADDRESS, // 6
        FIELD_PROVIDER_SALES_ADDRESSES, // 7
        FIELD_PROVIDER_PRIMARY_SALES_PERCENTAGES, // 8
        FIELD_PROVIDER_SECONDARY_SALES_BPS, // 9
        FIELD_SPLIT_PROVIDER, // 10
        FIELD_BYTECODE_STORAGE_READER // 11
    }

    // The following fields are used to indicate which project-level parameter
    // has been updated in the `ProjectUpdated` event:
    // @dev only append to the end of this enum in the case of future updates
    enum ProjectUpdatedFields {
        FIELD_PROJECT_COMPLETED, // 0
        FIELD_PROJECT_ACTIVE, // 1
        FIELD_PROJECT_ARTIST_ADDRESS, // 2
        FIELD_PROJECT_PAUSED, // 3
        FIELD_PROJECT_CREATED, // 4
        FIELD_PROJECT_NAME, // 5
        FIELD_PROJECT_ARTIST_NAME, // 6
        FIELD_PROJECT_SECONDARY_MARKET_ROYALTY_PERCENTAGE, // 7
        FIELD_PROJECT_DESCRIPTION, // 8
        FIELD_PROJECT_WEBSITE, // 9
        FIELD_PROJECT_LICENSE, // 10
        FIELD_PROJECT_MAX_INVOCATIONS, // 11
        FIELD_PROJECT_SCRIPT, // 12
        FIELD_PROJECT_SCRIPT_TYPE, // 13
        FIELD_PROJECT_ASPECT_RATIO, // 14
        FIELD_PROJECT_BASE_URI, // 15
        FIELD_PROJECT_PROVIDER_SECONDARY_FINANCIALS // 16
    }

    /**
     * @notice Error codes for the GenArt721 contract. Used by the GenArt721Error
     * custom error.
     * @dev only append to the end of this enum in the case of future updates
     */
    enum ErrorCodes {
        OnlyNonZeroAddress, // 0
        OnlyNonEmptyString, // 1
        OnlyNonEmptyBytes, // 2
        TokenDoesNotExist, // 3
        ProjectDoesNotExist, // 4
        OnlyUnlockedProjects, // 5
        OnlyAdminACL, // 6
        OnlyArtist, // 7
        OnlyArtistOrAdminACL, // 8
        OnlyAdminACLOrRenouncedArtist, // 9
        OnlyMinterContract, // 10
        MaxInvocationsReached, // 11
        ProjectMustExistAndBeActive, // 12
        PurchasesPaused, // 13
        OnlyRandomizer, // 14
        TokenHashAlreadySet, // 15
        NoZeroHashSeed, // 16
        OverMaxSumOfPercentages, // 17
        IndexOutOfBounds, // 18
        OverMaxSumOfBPS, // 19
        MaxOf100Percent, // 20
        PrimaryPayeeIsZeroAddress, // 21
        SecondaryPayeeIsZeroAddress, // 22
        MustMatchArtistProposal, // 23
        NewProjectsForbidden, // 24
        NewProjectsAlreadyForbidden, // 25
        OnlyArtistOrAdminIfLocked, // 26
        OverMaxSecondaryRoyaltyPercentage, // 27
        OnlyMaxInvocationsDecrease, // 28
        OnlyGteInvocations, // 29
        ScriptIdOutOfRange, // 30
        NoScriptsToRemove, // 31
        ScriptTypeAndVersionFormat, // 32
        AspectRatioTooLong, // 33
        AspectRatioNoNumbers, // 34
        AspectRatioImproperFormat, // 35
        OnlyNullPlatformProvider, // 36
        ContractInitialized // 37
    }

    /**
     * @notice Emits an error code `_errorCode` in the GenArt721Error event.
     * @dev Emitting error codes instead of error strings saves significant
     * contract bytecode size, allowing for more contract functionality within
     * the 24KB contract size limit.
     * @param _errorCode The error code to emit. See ErrorCodes enum.
     */
    error GenArt721Error(ErrorCodes _errorCode);

    /**
     * @notice Token ID `_tokenId` minted to `_to`.
     */
    event Mint(address indexed _to, uint256 indexed _tokenId);

    /**
     * @notice currentMinter updated to `_currentMinter`.
     * @dev Implemented starting with V3 core
     */
    event MinterUpdated(address indexed _currentMinter);

    /**
     * @notice Platform updated on bytes32-encoded field `_field`.
     */
    event PlatformUpdated(bytes32 indexed _field);

    /**
     * @notice Project ID `_projectId` updated on bytes32-encoded field
     * `_update`.
     */
    event ProjectUpdated(uint256 indexed _projectId, bytes32 indexed _update);

    event ProposedArtistAddressesAndSplits(
        uint256 indexed _projectId,
        address _artistAddress,
        address _additionalPayeePrimarySales,
        uint256 _additionalPayeePrimarySalesPercentage,
        address _additionalPayeeSecondarySales,
        uint256 _additionalPayeeSecondarySalesPercentage
    );

    event AcceptedArtistAddressesAndSplits(uint256 indexed _projectId);

    // version and type of the core contract
    // coreVersion is a string of the form "0.x.y"
    function coreVersion() external view returns (string memory);

    // coreType is a string of the form "GenArt721CoreV3"
    function coreType() external view returns (string memory);

    // owner (pre-V3 was named admin) of contract
    // this is expected to be an Admin ACL contract for V3
    function owner() external view returns (address);

    // Admin ACL contract for V3, will be at the address owner()
    function adminACLContract() external returns (IAdminACLV0);

    // backwards-compatible (pre-V3) admin - equal to owner()
    function admin() external view returns (address);

    /**
     * Function determining if _sender is allowed to call function with
     * selector _selector on contract `_contract`. Intended to be used with
     * peripheral contracts such as minters, as well as internally by the
     * core contract itself.
     */
    function adminACLAllowed(
        address _sender,
        address _contract,
        bytes4 _selector
    ) external returns (bool);

    /// getter function of public variable
    function startingProjectId() external view returns (uint256);

    // getter function of public variable
    function nextProjectId() external view returns (uint256);

    // getter function of public mapping
    function tokenIdToProjectId(
        uint256 tokenId
    ) external view returns (uint256 projectId);

    // @dev this is not available in V0
    function isMintWhitelisted(address minter) external view returns (bool);

    function projectIdToArtistAddress(
        uint256 _projectId
    ) external view returns (address payable);

    function projectIdToSecondaryMarketRoyaltyPercentage(
        uint256 _projectId
    ) external view returns (uint256);

    function projectURIInfo(
        uint256 _projectId
    ) external view returns (string memory projectBaseURI);

    // @dev new function in V3
    function projectStateData(
        uint256 _projectId
    )
        external
        view
        returns (
            uint256 invocations,
            uint256 maxInvocations,
            bool active,
            bool paused,
            uint256 completedTimestamp,
            bool locked
        );

    function projectDetails(
        uint256 _projectId
    )
        external
        view
        returns (
            string memory projectName,
            string memory artist,
            string memory description,
            string memory website,
            string memory license
        );

    function projectScriptDetails(
        uint256 _projectId
    )
        external
        view
        returns (
            string memory scriptTypeAndVersion,
            string memory aspectRatio,
            uint256 scriptCount
        );

    function projectScriptByIndex(
        uint256 _projectId,
        uint256 _index
    ) external view returns (string memory);

    function tokenIdToHash(uint256 _tokenId) external view returns (bytes32);

    // function to set a token's hash (must be guarded)
    function setTokenHash_8PT(uint256 _tokenId, bytes32 _hash) external;

    // @dev gas-optimized signature in V3 for `mint`
    function mint_Ecf(
        address _to,
        uint256 _projectId,
        address _by
    ) external returns (uint256 tokenId);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import "./IAdminACLV0.sol";
import "./IGenArt721CoreContractV3_Base.sol";
import "./ISplitProviderV0.sol";

/**
 * @notice Struct representing Engine contract configuration.
 * @param tokenName Name of token.
 * @param tokenSymbol Token symbol.
 * @param renderProviderAddress address to send render provider revenue to
 * @param randomizerContract Randomizer contract.
 * @param splitProviderAddress Address to use as royalty splitter provider for the contract.
 * @param minterFilterAddress Address of the Minter Filter to set as the Minter
 * on the contract.
 * @param startingProjectId The initial next project ID.
 * @param autoApproveArtistSplitProposals Whether or not to always
 * auto-approve proposed artist split updates.
 * @param nullPlatformProvider Enforce always setting zero platform provider fees and addresses.
 * @param allowArtistProjectActivation Allow artist to activate their own projects.
 * @dev _startingProjectId should be set to a value much, much less than
 * max(uint248), but an explicit input type of `uint248` is used as it is
 * safer to cast up to `uint256` than it is to cast down for the purposes
 * of setting `_nextProjectId`.
 */
struct EngineConfiguration {
    string tokenName;
    string tokenSymbol;
    address renderProviderAddress;
    address platformProviderAddress;
    address newSuperAdminAddress;
    address randomizerContract;
    address splitProviderAddress;
    address minterFilterAddress;
    uint248 startingProjectId;
    bool autoApproveArtistSplitProposals;
    bool nullPlatformProvider;
    bool allowArtistProjectActivation;
}

interface IGenArt721CoreContractV3_Engine is IGenArt721CoreContractV3_Base {
    // @dev new function in V3.2
    /**
     * @notice Initializes the contract with the provided `engineConfiguration`.
     * This function should be called atomically, immediately after deployment.
     * Only callable once. Validation on `engineConfiguration` is performed by caller.
     * @param engineConfiguration EngineConfiguration to configure the contract with.
     * @param adminACLContract_ Address of admin access control contract, to be
     * set as contract owner.
     * @param defaultBaseURIHost Base URI prefix to initialize default base URI with.
     * @param bytecodeStorageReaderContract_ Address of the bytecode storage reader contract.
     */
    function initialize(
        EngineConfiguration calldata engineConfiguration,
        address adminACLContract_,
        string memory defaultBaseURIHost,
        address bytecodeStorageReaderContract_
    ) external;

    // @dev new function in V3
    function getPrimaryRevenueSplits(
        uint256 _projectId,
        uint256 _price
    )
        external
        view
        returns (
            uint256 renderProviderRevenue_,
            address payable renderProviderAddress_,
            uint256 platformProviderRevenue_,
            address payable platformProviderAddress_,
            uint256 artistRevenue_,
            address payable artistAddress_,
            uint256 additionalPayeePrimaryRevenue_,
            address payable additionalPayeePrimaryAddress_
        );

    // @dev The render provider primary sales payment address
    function renderProviderPrimarySalesAddress()
        external
        view
        returns (address payable);

    // @dev The platform provider primary sales payment address
    function platformProviderPrimarySalesAddress()
        external
        view
        returns (address payable);

    // @dev Percentage of primary sales allocated to the render provider
    function renderProviderPrimarySalesPercentage()
        external
        view
        returns (uint256);

    // @dev Percentage of primary sales allocated to the platform provider
    function platformProviderPrimarySalesPercentage()
        external
        view
        returns (uint256);

    /** @notice The default render provider payment address for all secondary sales royalty
     * revenues, for all new projects. Individual project payment info is defined
     * in each project's ProjectFinance struct.
     * @return The default render provider payment address for secondary sales royalties.
     */
    function defaultRenderProviderSecondarySalesAddress()
        external
        view
        returns (address payable);

    /** @notice The default platform provider payment address for all secondary sales royalty
     * revenues, for all new projects. Individual project payment info is defined
     * in each project's ProjectFinance struct.
     * @return The default platform provider payment address for secondary sales royalties.
     */
    function defaultPlatformProviderSecondarySalesAddress()
        external
        view
        returns (address payable);

    /** @notice The default render provider payment basis points for all secondary sales royalty
     * revenues, for all new projects. Individual project payment info is defined
     * in each project's ProjectFinance struct.
     * @return The default render provider payment basis points for secondary sales royalties.
     */
    function defaultRenderProviderSecondarySalesBPS()
        external
        view
        returns (uint256);

    /** @notice The default platform provider payment basis points for all secondary sales royalty
     * revenues, for all new projects. Individual project payment info is defined
     * in each project's ProjectFinance struct.
     * @return The default platform provider payment basis points for secondary sales royalties.
     */
    function defaultPlatformProviderSecondarySalesBPS()
        external
        view
        returns (uint256);

    /**
     * @notice The address of the current split provider being used by the contract.
     * @return The address of the current split provider.
     */
    function splitProvider() external view returns (ISplitProviderV0);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

import "./IFilteredMinterV2.sol";

pragma solidity ^0.8.0;

/**
 * @title This interface defines any events or functions required for a minter
 * to conform to the MinterBase contract.
 * @dev The MinterBase contract was not implemented from the beginning of the
 * MinterSuite contract suite, therefore early versions of some minters may not
 * conform to this interface.
 * @author Art Blocks Inc.
 */
interface IMinterBaseV0 {
    // Function that returns if a minter is configured to integrate with a V3 flagship or V3 engine contract.
    // Returns true only if the minter is configured to integrate with an engine contract.
    function isEngine() external returns (bool isEngine);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import "./ICoreRegistryV1.sol";
import "./IAdminACLV0.sol";

/**
 * @title IMinterFilterV1
 * @author Art Blocks Inc.
 * @notice Interface for a new minter filter contract.
 * This interface does not extend the previous version of the minter filter
 * interface, as the previous version is not compatible with the new
 * minter filter architecture.
 * @dev This interface is for a minter filter that supports multiple core
 * contracts, and allows for a minter to be set on a per-project basis.
 */
interface IMinterFilterV1 {
    /**
     * @notice Emitted when contract is deployed to notify indexing services
     * of the new contract deployment.
     */
    event Deployed();

    /**
     * @notice Globally approved minter `minter`.
     */
    event MinterApprovedGlobally(address indexed minter, string minterType);

    /**
     * @notice Globally revoked minter `minter`.
     * @dev contract owner may still approve this minter on a per-contract
     * basis.
     */
    event MinterRevokedGlobally(address indexed minter);

    /**
     * @notice Approved minter `minter` on core contract
     * `coreContract`.
     */
    event MinterApprovedForContract(
        address indexed coreContract,
        address indexed minter,
        string minterType
    );

    /**
     * @notice Revoked minter `minter` on core contract `coreContract`.
     * @dev minter filter owner may still globally approve this minter for all
     * contracts.
     */
    event MinterRevokedForContract(
        address indexed coreContract,
        address indexed minter
    );

    /**
     * @notice Minter at address `minter` set as minter for project
     * `projectId` on core contract `coreContract`.
     */
    event ProjectMinterRegistered(
        uint256 indexed projectId,
        address indexed coreContract,
        address indexed minter,
        string minterType
    );

    /**
     * @notice Minter removed for project `projectId` on core contract
     * `coreContract`.
     */
    event ProjectMinterRemoved(
        uint256 indexed projectId,
        address indexed coreContract
    );

    /**
     * @notice Admin ACL contract updated to `adminACLContract`.
     */
    event AdminACLUpdated(address indexed adminACLContract);

    /**
     * @notice Core Registry contract updated to `coreRegistry`.
     */
    event CoreRegistryUpdated(address indexed coreRegistry);

    // struct used to return minter info
    // @dev this is not used for storage of data
    struct MinterWithType {
        address minterAddress;
        string minterType;
    }

    function setMinterForProject(
        uint256 projectId,
        address coreContract,
        address minter
    ) external;

    function removeMinterForProject(
        uint256 projectId,
        address coreContract
    ) external;

    // @dev function name is optimized for gas
    function mint_joo(
        address to,
        uint256 projectId,
        address coreContract,
        address sender
    ) external returns (uint256);

    function updateCoreRegistry(address coreRegistry) external;

    /**
     * @notice Returns if `sender` is allowed to call function on `contract`
     * with `selector` selector, according to the MinterFilter's Admin ACL.
     */
    function adminACLAllowed(
        address sender,
        address contract_,
        bytes4 selector
    ) external returns (bool);

    function minterFilterType() external pure returns (string memory);

    function getMinterForProject(
        uint256 projectId,
        address coreContract
    ) external view returns (address);

    function projectHasMinter(
        uint256 projectId,
        address coreContract
    ) external view returns (bool);

    /**
     * @notice View that returns if a core contract is registered with the
     * core registry, allowing this minter filter to service it.
     * @param coreContract core contract address to be checked
     */
    function isRegisteredCoreContract(
        address coreContract
    ) external view returns (bool);

    /// Address of current core registry contract
    function coreRegistry() external view returns (ICoreRegistryV1);

    /// The current admin ACL contract
    function adminACLContract() external view returns (IAdminACLV0);

    /// The quantity of projects on a core contract that have assigned minters
    function getNumProjectsOnContractWithMinters(
        address coreContract
    ) external view returns (uint256);

    function getProjectAndMinterInfoOnContractAt(
        address coreContract,
        uint256 index
    )
        external
        view
        returns (
            uint256 projectId,
            address minterAddress,
            string memory minterType
        );

    function getAllGloballyApprovedMinters()
        external
        view
        returns (MinterWithType[] memory mintersWithTypes);

    function getAllContractApprovedMinters(
        address coreContract
    ) external view returns (MinterWithType[] memory mintersWithTypes);

    /**
     * Owner of contract.
     * @dev This returns the address of the Admin ACL contract.
     */
    function owner() external view returns (address);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @title This interface adds support for ranked auction minting.
 * @author Art Blocks Inc.
 */
interface ISharedMinterRAMV0 {
    function createBid(
        uint256 projectId,
        address coreContract,
        uint16 slotIndex
    ) external payable;

    function topUpBid(
        uint256 projectId,
        address coreContract,
        uint32 bidId,
        uint16 newSlotIndex
    ) external payable;
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @title ISharedMinterRequired
 * @notice This interface contains the minimum required interface for a shared
 * minter contract. All custom, one-off minter contracts should implement this
 * interface.
 */
interface ISharedMinterRequired {
    /**
     * @notice Returns the minter's type, used by the minter filter for metadata
     * purposes.
     * @return The minter type.
     */
    function minterType() external view returns (string memory);

    /**
     * @notice Returns the minter's associated shared minter filter address.
     * @dev used by subgraph indexing service for entity relation purposes.
     * @return The minter filter address.
     */
    function minterFilterAddress() external returns (address);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {ISharedMinterRequired} from "./ISharedMinterRequired.sol";

/**
 * @title ISharedMinterV0
 * @notice This interface extends the minimum required interface for a shared
 * minter contract to add additional functionality that is generally available
 * for all shared minter contracts on the shared minter filter.
 * @dev Custom, one-off minter contracts that are not globally approved may
 * choose to not implement this interface, but should still implement the
 * ISharedMinterRequired interface.
 */
interface ISharedMinterV0 is ISharedMinterRequired {
    // Sets the local max invocations for a given project, checking that the provided max invocations is
    // less than or equal to the global max invocations for the project set on the core contract.
    // This does not impact the max invocations value defined on the core contract.
    function manuallyLimitProjectMaxInvocations(
        uint256 projectId,
        address coreContract,
        uint24 maxInvocations
    ) external;

    // Called to make the minter contract aware of the max invocations for a
    // given project.
    function syncProjectMaxInvocationsToCore(
        uint256 projectId,
        address coreContract
    ) external;

    // Gets if token price is configured, token price in wei, currency symbol,
    // and currency address, assuming this is project's minter.
    // Supersedes any defined core price.
    function getPriceInfo(
        uint256 projectId,
        address coreContract
    )
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            string memory currencySymbol,
            address currencyAddress
        );
}
// SPDX-License-Identifier: LGPL-3.0-only
// Creatd By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {ISplitFactoryV2} from "./integration-refs/splits-0x-v2/ISplitFactoryV2.sol";

interface ISplitProviderV0 {
    /**
     * @notice SplitInputs struct defines the inputs for requested splitters.
     * It is defined in a way easily communicated from the Art Blocks GenArt721V3 contract,
     * to allow for easy integration and minimal additional bytecode in the GenArt721V3 contract.
     */
    struct SplitInputs {
        address platformProviderSecondarySalesAddress;
        uint16 platformProviderSecondarySalesBPS;
        address renderProviderSecondarySalesAddress;
        uint16 renderProviderSecondarySalesBPS;
        uint8 artistTotalRoyaltyPercentage;
        address artist;
        address additionalPayee;
        uint8 additionalPayeePercentage;
    }

    /**
     * @notice Emitted when a new splitter contract is created.
     * @param splitter address of the splitter contract
     */
    event SplitterCreated(address indexed splitter);

    /**
     * @notice Gets or creates an immutable splitter contract at a deterministic address.
     * Splits in the splitter contract are determined by the input split parameters,
     * so we can safely create the splitter contract at a deterministic address (or use
     * the existing splitter contract if it already exists at that address).
     * @dev Uses the 0xSplits v2 implementation to create a splitter contract
     * @param splitInputs The split input parameters.
     * @return splitter The newly created splitter contract address.
     */
    function getOrCreateSplitter(
        SplitInputs calldata splitInputs
    ) external returns (address);

    /**
     * @notice Indicates the type of the contract, e.g. `SplitProviderV0`.
     * @return type_ The type of the contract.
     */
    function type_() external pure returns (bytes32);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc. to support the 0xSplits V2 integration
// Sourced from:
//  - https://github.com/0xSplits/splits-contracts-monorepo/blob/main/packages/splits-v2/src/libraries/SplitV2.sol
//  - https://github.com/0xSplits/splits-contracts-monorepo/blob/main/packages/splits-v2/src/splitters/SplitFactoryV2.sol

pragma solidity ^0.8.0;

interface ISplitFactoryV2 {
    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Split struct
     * @dev This struct is used to store the split information.
     * @dev There are no hard caps on the number of recipients/totalAllocation/allocation unit. Thus the chain and its
     * gas limits will dictate these hard caps. Please double check if the split you are creating can be distributed on
     * the chain.
     * @param recipients The recipients of the split.
     * @param allocations The allocations of the split.
     * @param totalAllocation The total allocation of the split.
     * @param distributionIncentive The incentive for distribution. Limits max incentive to 6.5%.
     */
    struct Split {
        address[] recipients;
        uint256[] allocations;
        uint256 totalAllocation;
        uint16 distributionIncentive;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 FUNCTIONS                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Create a new split with params and owner.
     * @param _splitParams Params to create split with.
     * @param _owner Owner of created split.
     * @param _creator Creator of created split.
     * @param _salt Salt for create2.
     * @return split Address of the created split.
     */
    function createSplitDeterministic(
        Split calldata _splitParams,
        address _owner,
        address _creator,
        bytes32 _salt
    ) external returns (address split);

    /**
     * @notice Predict the address of a new split and check if it is deployed.
     * @param _splitParams Params to create split with.
     * @param _owner Owner of created split.
     * @param _salt Salt for create2.
     */
    function isDeployed(
        Split calldata _splitParams,
        address _owner,
        bytes32 _salt
    ) external view returns (address split, bool exists);
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @title Art Blocks Helpers Library
 * @notice This library contains helper functions for common operations in the
 * Art Blocks ecosystem of smart contracts.
 * @author Art Blocks Inc.
 */

library ABHelpers {
    uint256 constant ONE_MILLION = 1_000_000;

    /**
     * @notice Function to convert token id to project id.
     * @param tokenId The id of the token.
     */
    function tokenIdToProjectId(
        uint256 tokenId
    ) internal pure returns (uint256) {
        // int division properly rounds down
        // @dev no way to disable division by zero check in solidity v0.8.24, so not unchecked
        return tokenId / ONE_MILLION;
    }

    /**
     * @notice Function to convert token id to token number.
     * @param tokenId The id of the token.
     */
    function tokenIdToTokenNumber(
        uint256 tokenId
    ) internal pure returns (uint256) {
        // mod returns remainder, which is the token number
        // @dev no way to disable mod zero check in solidity, so not unchecked
        return tokenId % ONE_MILLION;
    }

    /**
     * @notice Function to convert token id to token invocation.
     * @dev token invocation is the token number plus one, because token #0 is
     * invocation 1.
     * @param tokenId The id of the token.
     */
    function tokenIdToTokenInvocation(
        uint256 tokenId
    ) internal pure returns (uint256) {
        unchecked {
            // mod returns remainder, which is the token number
            // @dev no way to disable mod zero check in solidity, unchecked to optimize gas for addition
            return (tokenId % ONE_MILLION) + 1;
        }
    }

    /**
     * @notice Function to convert project id and token number to token id.
     * @param projectId The id of the project.
     * @param tokenNumber The token number.
     */
    function tokenIdFromProjectIdAndTokenNumber(
        uint256 projectId,
        uint256 tokenNumber
    ) internal pure returns (uint256) {
        // @dev intentionally not unchecked to ensure overflow detection, which
        // would likley only occur in a malicious call
        return (projectId * ONE_MILLION) + tokenNumber;
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {IGenArt721CoreContractV3_Base} from "../../interfaces/v0.8.x/IGenArt721CoreContractV3_Base.sol";
import {IMinterFilterV1} from "../../interfaces/v0.8.x/IMinterFilterV1.sol";

/**
 * @title Art Blocks Authorization Minter Library
 * @notice This library contains helper functions that may be used contracts to
 * check authorization for performing operations in the Art Blocks V3 core
 * contract ecosystem.
 * @author Art Blocks Inc.
 */

library AuthLib {
    /**
     * @notice Function to restrict access to only AdminACL allowed calls, where
     * AdminACL is the admin of an IMinterFilterV1.
     * Reverts if not allowed.
     * @param minterFilterAddress address of the minter filter to be checked,
     * should implement IMinterFilterV1
     * @param sender address of the caller
     * @param contract_ address of the contract being called
     * @param selector selector of the function being called
     */
    function onlyMinterFilterAdminACL(
        address minterFilterAddress,
        address sender,
        address contract_,
        bytes4 selector
    ) internal {
        require(
            _minterFilterAdminACLAllowed({
                minterFilterAddress: minterFilterAddress,
                sender: sender,
                contract_: contract_,
                selector: selector
            }),
            "Only MinterFilter AdminACL"
        );
    }

    /**
     * @notice Function to restrict access to only AdminACL allowed calls, where
     * AdminACL is the admin of a core contract at `coreContract`.
     * Reverts if not allowed.
     * @param coreContract address of the core contract to be checked
     * @param sender address of the caller
     * @param contract_ address of the contract being called
     * @param selector selector of the function being called
     */
    function onlyCoreAdminACL(
        address coreContract,
        address sender,
        address contract_,
        bytes4 selector
    ) internal {
        require(
            _coreAdminACLAllowed({
                coreContract: coreContract,
                sender: sender,
                contract_: contract_,
                selector: selector
            }),
            "Only Core AdminACL allowed"
        );
    }

    /**
     * @notice Throws if `sender` is any account other than the artist of the
     * specified project `projectId` on core contract `coreContract`.
     * @param projectId The ID of the project being checked.
     * @param coreContract The address of the GenArt721CoreContractV3_Base
     * contract.
     * @param sender Wallet to check. Typically, the address of the caller.
     * @dev `sender` must be the artist associated with `projectId` on `coreContract`.
     */
    function onlyArtist(
        uint256 projectId,
        address coreContract,
        address sender
    ) internal view {
        require(
            _senderIsArtist({
                projectId: projectId,
                coreContract: coreContract,
                sender: sender
            }),
            "Only Artist"
        );
    }

    /**
     * @notice Function to restrict access to only the artist of a project, or AdminACL
     * allowed calls, where AdminACL is the admin of a core contract at
     * `coreContract`.
     * @param projectId id of the project
     * @param coreContract address of the core contract to be checked
     * @param sender address of the caller
     * @param contract_ address of the contract being called
     * @param selector selector of the function being called
     */
    function onlyCoreAdminACLOrArtist(
        uint256 projectId,
        address coreContract,
        address sender,
        address contract_,
        bytes4 selector
    ) internal {
        require(
            _senderIsArtist({
                projectId: projectId,
                coreContract: coreContract,
                sender: sender
            }) ||
                _coreAdminACLAllowed({
                    coreContract: coreContract,
                    sender: sender,
                    contract_: contract_,
                    selector: selector
                }),
            "Only Artist or Core Admin ACL"
        );
    }

    // ------------------------------------------------------------------------
    // Private functions used internally by this library
    // ------------------------------------------------------------------------

    /**
     * @notice Private function that returns if minter filter contract's AdminACL
     * allows `sender` to call function with selector `selector` on contract
     * `contract`.
     * @param minterFilterAddress address of the minter filter to be checked.
     * Should implement IMinterFilterV1.
     * @param sender address of the caller
     * @param contract_ address of the contract being called
     * @param selector selector of the function being called
     */
    function _minterFilterAdminACLAllowed(
        address minterFilterAddress,
        address sender,
        address contract_,
        bytes4 selector
    ) private returns (bool) {
        return
            IMinterFilterV1(minterFilterAddress).adminACLAllowed({
                sender: sender,
                contract_: contract_,
                selector: selector
            });
    }

    /**
     * @notice Private function that returns if core contract's AdminACL allows
     * `sender` to call function with selector `selector` on contract
     * `contract`.
     * @param coreContract address of the core contract to be checked
     * @param sender address of the caller
     * @param contract_ address of the contract being called
     * @param selector selector of the function being called
     */
    function _coreAdminACLAllowed(
        address coreContract,
        address sender,
        address contract_,
        bytes4 selector
    ) private returns (bool) {
        return
            IGenArt721CoreContractV3_Base(coreContract).adminACLAllowed({
                _sender: sender,
                _contract: contract_,
                _selector: selector
            });
    }

    /**
     * @notice Private function that returns if `sender` is the artist of `projectId`
     * on `coreContract`.
     * @param projectId project ID to check
     * @param coreContract core contract to check
     * @param sender wallet to check
     */
    function _senderIsArtist(
        uint256 projectId,
        address coreContract,
        address sender
    ) private view returns (bool senderIsArtist) {
        return
            sender ==
            IGenArt721CoreContractV3_Base(coreContract)
                .projectIdToArtistAddress(projectId);
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @dev Library for using uint256 as a mapping to 256 bool values via a bit map.
 * This is useful for storing a large number of bool values in a compact way.
 * @dev This implementation is similar to OpenZeppelin's BitMaps library, but a
 * single uint256 is used directly in memory instead of operating within a
 * a mapping within a storage struct.
 * This design limits the number of indices to 256, but is more gas efficient
 * for use cases that fit within that limit. This is especially true for
 * operations that require many reads/writes, since SLOAD/SSTORE can be managed
 * outside of the library.
 */
library BitMaps256 {
    /**
     * @notice Checks if the bit at a specific index in the bit map is set.
     * A bit is considered set if it is 1, and unset if it is 0.
     * @param bitMap BitMap to check.
     * @param index The index of the bit to check.
     * @return Indicating if the bit at the specified index is set, false otherwise.
     */
    function get(uint256 bitMap, uint8 index) internal pure returns (bool) {
        uint256 mask = 1 << index;
        return bitMap & mask != 0;
    }

    /**
     * @notice Sets the bit at a specific index in the bit map to 1.
     * This function creates a new bit map where the bit at the specified index is set,
     * leaving other bits unchanged.
     * @param bitMap The original BitMap.
     * @param index The index of the bit to set.
     * @return newBitMap The new bit map after setting the bit at the specified index.
     */
    function set(
        uint256 bitMap,
        uint8 index
    ) internal pure returns (uint256 newBitMap) {
        uint256 mask = 1 << index;
        return bitMap | mask;
    }

    /**
     * @notice Unsets the bit at a specific index in the bit map, setting it to 0.
     * This function creates a new bit map where the bit at the specified index is unset,
     * leaving other bits unchanged.
     * @param bitMap The original BitMap.
     * @param index The index of the bit to unset.
     * @return newBitMap The new bit map after unsetting the bit at the specified index.
     */
    function unset(
        uint256 bitMap,
        uint8 index
    ) internal pure returns (uint256 newBitMap) {
        uint256 mask = 1 << index;
        return bitMap & ~mask;
    }

    /**
     * @notice Finds the index of the first bit that is set in the bit map
     * starting from a given index.
     * Returns (255, false) if no set bits were found.
     * @param bitMap BitMap to search
     * @param startIndex Index to start searching from, inclusive
     * @return minIndex Index of first set bit, or 255 if no bits were found
     * @return foundSetBit True if a set bit was found, false otherwise
     */
    function minBitSet(
        uint256 bitMap,
        uint8 startIndex
    ) internal pure returns (uint256 minIndex, bool foundSetBit) {
        // check if there's any set bit at or above startIndex
        if ((bitMap >> startIndex) == 0) {
            return (255, false);
        }
        minIndex = startIndex;
        // @dev this is a linear search, optimized to start only if there's a set bit at or above startIndex
        // worst case 255 iterations in memory
        while (minIndex < 255 && !get(bitMap, uint8(minIndex))) {
            minIndex++;
        }
        foundSetBit = get(bitMap, uint8(minIndex));
    }

    /**
     * @notice Finds the index of the highest bit that is set in the bit map
     * starting from a given index and counting down.
     * Returns (0, false) if no set bits were found.
     * @param bitMap BitMap to search
     * @param startIndex Index to start searching from, inclusive
     * @return maxIndex Index of last set bit, or 0 if no bits were found
     * @return foundSetBit True if a set bit was found, false otherwise
     */
    function maxBitSet(
        uint256 bitMap,
        uint8 startIndex
    ) internal pure returns (uint256 maxIndex, bool foundSetBit) {
        if ((bitMap << (255 - startIndex)) == 0) {
            return (0, false);
        }

        maxIndex = startIndex;
        // @dev this is a linear search, worst case 255 iterations in memory
        while (maxIndex > 0 && !get(bitMap, uint8(maxIndex))) {
            maxIndex--;
        }
        foundSetBit = get(bitMap, uint8(maxIndex));
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @dev Library for packing multiple boolean values into a single uint256.
 * This is useful for storing a large number of bool values in a more compact
 * way than solidify's native bool type, which uses 8 bytes per bool.
 *
 * The implementation is similar to a BitMap, but function names are more
 * descriptive for packing and unpacking multiple bools.
 *
 * Note that the library may still be used in cases where less than 256 bools
 * are needed to be packed. For example, if <= 8 bools are needed, casting may
 * be used outside of the library for compatibility with any size uint.
 */
library PackedBools {
    function getBool(
        uint256 packedBool,
        uint8 index
    ) internal pure returns (bool) {
        uint256 mask = 1 << index;
        return packedBool & mask != 0;
    }

    function setBoolTrue(
        uint256 bitMap,
        uint8 index
    ) internal pure returns (uint256 newBitMap) {
        uint256 mask = 1 << index;
        return bitMap | mask;
    }

    function setBoolFalse(
        uint256 bitMap,
        uint8 index
    ) internal pure returns (uint256 newBitMap) {
        uint256 mask = 1 << index;
        return bitMap & ~mask;
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

/**
 * @title Art Blocks Generic Events Library
 * @notice This library is designed to define a set of generic events that all
 * shared minter libraries may utilize to populate indexed extra minter details
 * @dev Strings not supported. Recommend conversion of (short) strings to
 * bytes32 to remain gas-efficient.
 * @author Art Blocks Inc.
 */
library GenericMinterEventsLib {
    /**
     * @notice Generic project minter configuration event. Removed key `key`
     * for project `projectId`.
     * @param projectId Project ID key was removed for
     * @param coreContract Core contract address that projectId is on
     * @param key Key removed
     */
    event ConfigKeyRemoved(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key
    );
    /// BOOL
    /**
     * @notice Generic project minter configuration event. Value of key
     * `key` was set to `value` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key set
     * @param value Value key was set to
     */
    event ConfigValueSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        bool value
    );
    /// UINT256
    /**
     * @notice Generic project minter configuration event. Value of key
     * `key` was set to `value` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key set
     * @param value Value key was set to
     */
    event ConfigValueSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        uint256 value
    );
    /**
     * @notice Generic project minter configuration event. Added value `value`
     * to the set of uint256 at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value added to the key's set
     */
    event ConfigValueAddedToSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        uint256 value
    );
    /**
     * @notice Generic project minter configuration event. Removed value
     * `value` to the set of uint256 at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value removed from the key's set
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        uint256 value
    );
    /// ADDRESS
    /**
     * @notice Generic project minter configuration event. Value of key
     * `key` was set to `value` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key set
     * @param value Value key was set to
     */
    event ConfigValueSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        address value
    );
    /**
     * @notice Generic project minter configuration event. Added value `value`
     * to the set of addresses at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value added to the key's set
     */
    event ConfigValueAddedToSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        address value
    );
    /**
     * @notice Generic project minter configuration event. Removed value
     * `value` to the set of addresses at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value removed from the key's set
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        address value
    );
    /// BYTES32
    /**
     * @notice Generic project minter configuration event. Value of key
     * `key` was set to `value` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key set
     * @param value Value key was set to
     */
    event ConfigValueSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        bytes32 value
    );
    /**
     * @notice Generic project minter configuration event. Added value `value`
     * to the set of bytes32 at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value added to the key's set
     */
    event ConfigValueAddedToSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        bytes32 value
    );
    /**
     * @notice Generic project minter configuration event. Removed value
     * `value` to the set of bytes32 at key `key` for project `projectId`.
     * @param projectId Project ID key was set for
     * @param coreContract Core contract address that projectId is on
     * @param key Key modified
     * @param value Value removed from the key's set
     */
    event ConfigValueRemovedFromSet(
        uint256 indexed projectId,
        address indexed coreContract,
        bytes32 key,
        bytes32 value
    );
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {IGenArt721CoreContractV3_Base} from "../../../interfaces/v0.8.x/IGenArt721CoreContractV3_Base.sol";

import {ABHelpers} from "../ABHelpers.sol";

import {Math} from "@openzeppelin-4.7/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin-4.7/contracts/utils/math/SafeCast.sol";

/**
 * @title Art Blocks Max Invocations Library
 * @notice This library manages the maximum invocation limits for Art Blocks
 * projects. It provides functionality for synchronizing, manually limiting, and
 * updating these limits, ensuring the integrity in relation to the core Art
 * Blocks contract, and managing updates upon token minting.
 * @dev Functions include `syncProjectMaxInvocationsToCore`,
 * `manuallyLimitProjectMaxInvocations`, and `purchaseEffectsInvocations`.
 * @author Art Blocks Inc.
 */

library MaxInvocationsLib {
    using SafeCast for uint256;

    /**
     * @notice Local max invocations for project `projectId`, tied to core contract `coreContractAddress`,
     * updated to `maxInvocations`.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * @param maxInvocations The new max invocations limit.
     */
    event ProjectMaxInvocationsLimitUpdated(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 maxInvocations
    );

    // position of Max Invocations Lib storage, using a diamond storage pattern
    // for this library
    bytes32 constant MAX_INVOCATIONS_LIB_STORAGE_POSITION =
        keccak256("maxinvocationslib.storage");

    uint256 internal constant ONE_MILLION = 1_000_000;

    /**
     * @notice Data structure that holds max invocations project configuration.
     */
    struct MaxInvocationsProjectConfig {
        bool maxHasBeenInvoked;
        uint24 maxInvocations;
    }

    // Diamond storage pattern is used in this library
    struct MaxInvocationsLibStorage {
        mapping(address coreContract => mapping(uint256 projectId => MaxInvocationsProjectConfig)) maxInvocationsProjectConfigs;
    }

    /**
     * @notice Syncs project's max invocations to core contract value.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     */
    function syncProjectMaxInvocationsToCore(
        uint256 projectId,
        address coreContract
    ) internal {
        (
            uint256 coreInvocations,
            uint256 coreMaxInvocations
        ) = coreContractInvocationData({
                projectId: projectId,
                coreContract: coreContract
            });
        // update storage with results
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        // @dev only bugged core would return > 1e6 invocations, but safe-cast
        // for additional overflow safety
        maxInvocationsProjectConfig.maxInvocations = coreMaxInvocations
            .toUint24();

        // We need to ensure maxHasBeenInvoked is correctly set after manually syncing the
        // local maxInvocations value with the core contract's maxInvocations value.
        maxInvocationsProjectConfig.maxHasBeenInvoked =
            coreInvocations == coreMaxInvocations;

        emit ProjectMaxInvocationsLimitUpdated({
            projectId: projectId,
            coreContract: coreContract,
            maxInvocations: coreMaxInvocations
        });
    }

    /**
     * @notice Manually limits project's max invocations.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * @param maxInvocations The new max invocations limit.
     */
    function manuallyLimitProjectMaxInvocations(
        uint256 projectId,
        address coreContract,
        uint24 maxInvocations
    ) internal {
        // CHECKS
        (
            uint256 coreInvocations,
            uint256 coreMaxInvocations
        ) = coreContractInvocationData({
                projectId: projectId,
                coreContract: coreContract
            });
        require(
            maxInvocations <= coreMaxInvocations,
            "Invalid max invocations"
        );
        require(maxInvocations >= coreInvocations, "Invalid max invocations");

        // EFFECTS
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        // update storage with results
        maxInvocationsProjectConfig.maxInvocations = uint24(maxInvocations);
        // We need to ensure maxHasBeenInvoked is correctly set after manually setting the
        // local maxInvocations value.
        maxInvocationsProjectConfig.maxHasBeenInvoked =
            coreInvocations == maxInvocations;

        emit ProjectMaxInvocationsLimitUpdated({
            projectId: projectId,
            coreContract: coreContract,
            maxInvocations: maxInvocations
        });
    }

    /**
     * @notice Validate effects on invocations after purchase. This ensures
     * that the token invocation is less than or equal to the local max
     * invocations, and also updates the local maxHasBeenInvoked value.
     * @dev This function checks that the token invocation is less than or
     * equal to the local max invocations, and also updates the local
     * maxHasBeenInvoked value.
     * @param tokenId The id of the token.
     * @param coreContract The address of the core contract.
     */
    function validateMintEffectsInvocations(
        uint256 tokenId,
        address coreContract
    ) internal {
        uint256 projectId = ABHelpers.tokenIdToProjectId(tokenId);
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        // invocation is token number plus one, and will never overflow due to
        // limit of 1e6 invocations per project.
        uint256 tokenInvocation = ABHelpers.tokenIdToTokenInvocation(tokenId);
        uint256 localMaxInvocations = maxInvocationsProjectConfig
            .maxInvocations;
        // handle the case where the token invocation == minter local max
        // invocations occurred on a different minter, and we have a stale
        // local maxHasBeenInvoked value returning a false negative.
        // @dev this is a CHECK after EFFECTS, so security was considered
        // in detail here.
        require(
            tokenInvocation <= localMaxInvocations,
            "Max invocations reached"
        );
        // in typical case, update the local maxHasBeenInvoked value
        // to true if the token invocation == minter local max invocations
        // (enables gas efficient reverts after sellout)
        if (tokenInvocation == localMaxInvocations) {
            maxInvocationsProjectConfig.maxHasBeenInvoked = true;
        }
    }

    /**
     * @notice Checks that the max invocations have not been reached for a
     * given project. This only checks the minter's local max invocations, and
     * does not consider the core contract's max invocations.
     * The function reverts if the max invocations have been reached.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     */
    function preMintChecks(
        uint256 projectId,
        address coreContract
    ) internal view {
        // check that max invocations have not been reached
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        require(
            !maxInvocationsProjectConfig.maxHasBeenInvoked,
            "Max invocations reached"
        );
    }

    /**
     * @notice Helper function to check if max invocations has not been initialized.
     * Returns true if not initialized, false if initialized.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * @dev We know a project's max invocations have never been initialized if
     * both max invocations and maxHasBeenInvoked are still initial values.
     * This is because if maxInvocations were ever set to zero,
     * maxHasBeenInvoked would be set to true.
     */
    function maxInvocationsIsUnconfigured(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool) {
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        return
            maxInvocationsProjectConfig.maxInvocations == 0 &&
            !maxInvocationsProjectConfig.maxHasBeenInvoked;
    }

    /**
     * @notice Function returns if invocations remain available for a given project.
     * This function calls the core contract to get the most up-to-date
     * invocation data (which may be useful to avoid reverts during mint).
     * This function considers core contract max invocations, and minter local
     * max invocations, and returns a response based on the most limiting
     * max invocations value.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     */
    function invocationsRemainOnCore(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool) {
        return
            getInvocationsAvailable({
                projectId: projectId,
                coreContract: coreContract
            }) != 0;
    }

    /**
     * @notice Pulls core contract invocation data for a given project.
     * @dev This function calls the core contract to get the invocation data
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * @return coreInvocations The number of invocations for the project.
     * @return coreMaxInvocations The max invocations for the project, as
     * defined on the core contract.
     */
    function coreContractInvocationData(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (uint256 coreInvocations, uint256 coreMaxInvocations)
    {
        (
            coreInvocations,
            coreMaxInvocations,
            ,
            ,
            ,

        ) = IGenArt721CoreContractV3_Base(coreContract).projectStateData(
            projectId
        );
    }

    /**
     * @notice Function returns the max invocations for a given project.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * to be queried.
     */
    function getMaxInvocations(
        uint256 projectId,
        address coreContract
    ) internal view returns (uint256) {
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        return maxInvocationsProjectConfig.maxInvocations;
    }

    /**
     * @notice Function returns if max has been invoked for a given project.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * to be queried.
     */
    function getMaxHasBeenInvoked(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool) {
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        return maxInvocationsProjectConfig.maxHasBeenInvoked;
    }

    /**
     * @notice Function returns if a project has reached its max invocations.
     * Function is labelled as "safe" because it checks the core contract's
     * invocations and max invocations. If the local max invocations is greater
     * than the core contract's max invocations, it will defer to the core
     * contract's max invocations (since those are the limiting factor).
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     */
    function projectMaxHasBeenInvokedSafe(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool) {
        return
            getInvocationsAvailable({
                projectId: projectId,
                coreContract: coreContract
            }) == 0;
    }

    /**
     * @notice Function returns the number of invocations available for a given
     * project. Function checks the core contract's invocations and minter's max
     * invocations, ensuring that the most limiting value is used, even if the
     * local minter max invocations is stale.
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     * @return Number of invocations available for the project.
     */
    function getInvocationsAvailable(
        uint256 projectId,
        address coreContract
    ) internal view returns (uint256) {
        // get max invocations from core contract
        (
            uint256 coreInvocations,
            uint256 coreMaxInvocations
        ) = coreContractInvocationData({
                projectId: projectId,
                coreContract: coreContract
            });
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        uint256 limitingMaxInvocations = Math.min(
            coreMaxInvocations,
            maxInvocationsProjectConfig.maxInvocations // local max invocations
        );
        // if core invocations are greater than the limiting max invocations,
        // return 0 since no invocations remain
        if (coreInvocations >= limitingMaxInvocations) {
            return 0;
        }
        // otherwise, return the number of invocations remaining
        // @dev will not undeflow due to previous check
        return limitingMaxInvocations - coreInvocations;
    }

    /**
     * @notice Refreshes max invocations to account for core contract max
     * invocations state, without imposing any additional restrictions on the
     * minter's max invocations state.
     * If minter max invocations have never been populated, this function will
     * populate them to equal the core contract's max invocations state (which
     * is the least restrictive state).
     * If minter max invocations have been populated, this function will ensure
     * the minter's max invocations are not greater than the core contract's
     * max invocations (which would be stale and illogical), and update the
     * minter's max invocations and maxHasBeenInvoked state to be consistent
     * with the core contract's max invocations.
     * If the minter max invocations have been populated and are not greater
     * than the core contract's max invocations, this function will do nothing,
     * since that is a valid state in which the minter has been configured to
     * be more restrictive than the core contract.
     * @dev assumes core contract's max invocations may only be reduced, which
     * is the case for all V3 core contracts
     * @param projectId The id of the project.
     * @param coreContract The address of the core contract.
     */
    function refreshMaxInvocations(
        uint256 projectId,
        address coreContract
    ) internal {
        MaxInvocationsProjectConfig
            storage maxInvocationsProjectConfig = getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        if (maxInvocationsIsUnconfigured(projectId, coreContract)) {
            // populate the minter max invocation state to equal the values on
            // the core contract (least restrictive state)
            syncProjectMaxInvocationsToCore({
                projectId: projectId,
                coreContract: coreContract
            });
        } else {
            // if local max invocations were already populated, validate the local state
            (
                uint256 coreInvocations,
                uint256 coreMaxInvocations
            ) = coreContractInvocationData({
                    projectId: projectId,
                    coreContract: coreContract
                });

            uint256 localMaxInvocations = maxInvocationsProjectConfig
                .maxInvocations;
            if (localMaxInvocations > coreMaxInvocations) {
                // if local max invocations are greater than core max invocations, make
                // them equal since that is the least restrictive logical state
                // @dev this is only possible if the core contract's max invocations
                // have been reduced since the minter's max invocations were last
                // updated
                // set local max invocations to core contract's max invocations
                maxInvocationsProjectConfig.maxInvocations = uint24(
                    coreMaxInvocations
                );
                // update the minter's `maxHasBeenInvoked` state
                maxInvocationsProjectConfig
                    .maxHasBeenInvoked = (coreMaxInvocations ==
                    coreInvocations);
                emit ProjectMaxInvocationsLimitUpdated({
                    projectId: projectId,
                    coreContract: coreContract,
                    maxInvocations: coreMaxInvocations
                });
            } else if (coreInvocations >= localMaxInvocations) {
                // core invocations are greater than this minter's max
                // invocations, indicating that minting must have occurred on
                // another minter. update the minter's `maxHasBeenInvoked` to
                // true to prevent any false negatives on
                // `getMaxHasBeenInvoked'
                maxInvocationsProjectConfig.maxHasBeenInvoked = true;
                // @dev do not emit event, because we did not change the value
                // of minter-local max invocations
            }
        }
    }

    /**
     * @notice Loads the MaxInvocationsProjectConfig for a given project and core
     * contract.
     * @param projectId Project Id to get config for
     * @param coreContract Core contract address to get config for
     */
    function getMaxInvocationsProjectConfig(
        uint256 projectId,
        address coreContract
    ) internal view returns (MaxInvocationsProjectConfig storage) {
        return s().maxInvocationsProjectConfigs[coreContract][projectId];
    }

    /**
     * @notice Return the storage struct for reading and writing. This library
     * uses a diamond storage pattern when managing storage.
     * @return storageStruct The MaxInvocationsLibStorage struct.
     */
    function s()
        internal
        pure
        returns (MaxInvocationsLibStorage storage storageStruct)
    {
        bytes32 position = MAX_INVOCATIONS_LIB_STORAGE_POSITION;
        assembly ("memory-safe") {
            storageStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {IMinterFilterV1} from "../../../interfaces/v0.8.x/IMinterFilterV1.sol";

import {BitMaps256} from "../BitMap.sol";
import {PackedBools} from "../PackedBools.sol";
import {ABHelpers} from "../ABHelpers.sol";
import {SplitFundsLib} from "./SplitFundsLib.sol";
import {MaxInvocationsLib} from "./MaxInvocationsLib.sol";
import {GenericMinterEventsLib} from "./GenericMinterEventsLib.sol";

import {IERC721} from "@openzeppelin-5.0/contracts/token/ERC721/IERC721.sol";
import {SafeCast} from "@openzeppelin-5.0/contracts/utils/math/SafeCast.sol";
import {Math} from "@openzeppelin-5.0/contracts/utils/math/Math.sol";

/**
 * @title Art Blocks Ranked Auction Minter (RAM) Library
 * @notice This library is designed for the Art Blocks platform. It includes
 * Structs and functions that help with ranked auction minters.
 * @author Art Blocks Inc.
 */
library RAMLib {
    using SafeCast for uint256;
    using BitMaps256 for uint256;
    using PackedBools for uint256;
    /**
     * @notice Minimum auction length, in seconds, was updated to be the
     * provided value.
     * @param minAuctionDurationSeconds Minimum auction length, in seconds
     */
    event MinAuctionDurationSecondsUpdated(uint256 minAuctionDurationSeconds);

    /**
     * @notice Admin-controlled refund gas limit updated
     * @param refundGasLimit Gas limit to use when refunding the previous
     * highest bidder, prior to using fallback force-send to refund
     */
    event MinterRefundGasLimitUpdated(uint24 refundGasLimit);

    /**
     * @notice Number of slots used by this RAM minter
     * @param numSlots Number of slots used by this RAM minter
     */
    event NumSlotsUpdated(uint256 numSlots);

    /**
     * @notice RAM auction buffer time parameters updated
     * @param auctionBufferSeconds time period at end of auction when new bids
     * can affect auction end time, updated to be this many seconds after the
     * bid is placed.
     * @param maxAuctionExtraSeconds maximum amount of time that can be added
     * to the auction end time due to new bids.
     */
    event AuctionBufferTimeParamsUpdated(
        uint256 auctionBufferSeconds,
        uint256 maxAuctionExtraSeconds
    );

    /**
     * @notice Admin minting constraint configuration updated
     * @param coreContract Core contract address to update
     * @param adminMintingConstraint enum representing admin minting constraint imposed on this contract
     */
    event ContractConfigUpdated(
        address indexed coreContract,
        AdminMintingConstraint adminMintingConstraint
    );

    /**
     * @notice Auction parameters updated
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param timestampStart Auction start timestamp
     * @param timestampEnd Auction end timestamp
     * @param basePrice Auction base price
     * @param allowExtraTime Auction allows extra time
     * @param adminArtistOnlyMintPeriodIfSellout Auction admin-artist-only mint period if
     * sellout
     * @param numTokensInAuction Number of tokens in auction
     */
    event AuctionConfigUpdated(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 timestampStart,
        uint256 timestampEnd,
        uint256 basePrice,
        bool allowExtraTime,
        bool adminArtistOnlyMintPeriodIfSellout,
        uint256 numTokensInAuction
    );

    /**
     * @notice Number of tokens in auction updated
     * @dev okay to not index this event if prior to AuctionConfigUpdated, as
     * the state value will be emitted in another future event
     * @dev generic event not used due to additional indexing logic desired
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param numTokensInAuction Number of tokens in auction
     */
    event NumTokensInAuctionUpdated(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 numTokensInAuction
    );

    /**
     * @notice Auction timestamp end updated. Occurs when auction is extended
     * due to new bids near the end of an auction, when the auction is
     * configured to allow extra time.
     * Also may occur when an admin extends the auction within the emergency
     * extension time limit.
     * @dev generic event not used due to additional indexing logic desired
     * when event is encountered (want to understand what caused time
     * extension)
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param timestampEnd Auction end timestamp
     */
    event AuctionTimestampEndUpdated(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 timestampEnd
    );

    /**
     * @notice Bid created in auction
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param slotIndex Slot index of bid that was created
     * @param bidId Bid Id that was created
     * @param bidder Address of bidder
     */
    event BidCreated(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 slotIndex,
        uint256 bidId,
        address bidder
    );

    /**
     * @notice Bid removed from auction because it was outbid.
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param bidId Bid Id that was removed
     */
    event BidRemoved(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 bidId
    );

    /**
     * @notice Bid topped up in auction
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param bidId Bid Id that was topped up
     * @param newSlotIndex New slot index of bid that was topped up
     */
    event BidToppedUp(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 bidId,
        uint256 newSlotIndex
    );

    /**
     * @notice Bid was settled, and any payment above the lowest winning bid,
     * or base price if not a sellout, was refunded to the bidder.
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param bidId ID of bid that was settled
     */
    event BidSettled(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 bidId
    );

    /**
     * @notice A token was minted to the bidder for bid `bidId`. The tokenId is
     * the token that was minted.
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param bidId ID of bid that was settled
     * @param tokenId Token Id that was minted
     *
     */
    event BidMinted(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 bidId,
        uint256 tokenId
    );

    /**
     * @notice Bid was refunded, and the entire bid value was sent to the
     * bidder.
     * This only occurs if the minter encountered an unexpected error state
     * due to operational issues, and the minter was unable to mint a token to
     * the bidder.
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param bidId ID of bid that was settled
     */
    event BidRefunded(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 bidId
    );

    /**
     * @notice Token was directly purchased after an auction ended, and the
     * token was minted to the buyer.
     * @param projectId Project Id to update
     * @param coreContract Core contract address to update
     * @param tokenId Token Id that was minted
     * @param to Address that the token was minted to
     */
    event TokenPurchased(
        uint256 indexed projectId,
        address indexed coreContract,
        uint256 tokenId,
        address to
    );

    // position of RAM Lib storage, using a diamond storage pattern
    // for this library
    bytes32 constant RAM_LIB_STORAGE_POSITION = keccak256("ramlib.storage");

    // generic event key constants
    bytes32 internal constant CONFIG_AUCTION_REVENUES_COLLECTED =
        "auctionRevenuesCollected";
    bytes32 internal constant CONFIG_TIMESTAMP_END = "timestampEnd";

    uint256 constant NUM_SLOTS = 512;

    // pricing assumes maxPrice = minPrice * 2^8, pseudo-exponential curve
    uint256 constant SLOTS_PER_PRICE_DOUBLE = NUM_SLOTS / 8; // 64 slots per double

    // auction extension time constants
    uint256 constant AUCTION_BUFFER_SECONDS = 5 minutes;
    uint256 constant MAX_AUCTION_EXTRA_SECONDS = 1 hours;
    // @dev store value in hours to improve storage packing
    uint256 constant MAX_AUCTION_ADMIN_EMERGENCY_EXTENSION_HOURS = 72; // 72 hours

    uint256 constant ADMIN_ARTIST_ONLY_MINT_TIME_SECONDS = 72 hours;

    // packed bools constants for Bid struct
    uint8 constant INDEX_IS_SETTLED = 0;
    uint8 constant INDEX_IS_MINTED = 1;
    uint8 constant INDEX_IS_REFUNDED = 2;

    enum ProjectMinterStates {
        PreAuction, // Pre-Auction, State A
        LiveAuction, // Live-Auction, State B
        PostAuctionSellOutAdminArtistMint, // Post-Auction, sell out, not all bids handled, admin-artist-only mint period, State C
        PostAuctionOpenMint, // Post-Auction, not all bids handled, post-admin-artist-only mint period, State D
        PostAuctionAllBidsHandled // Post-Auction, all bids handled, State E
    }

    // project-specific parameters
    struct RAMProjectConfig {
        // mapping of all bids by Bid ID
        mapping(uint256 bidId => Bid) bids;
        // doubly linked list of bids for each slot
        mapping(uint256 slot => uint256 headBidId) headBidIdBySlot;
        mapping(uint256 slot => uint256 tailBidId) tailBidIdBySlot;
        // --- slot metadata for efficiency ---
        // two bitmaps with index set only if one or more active bids exist for
        // the corresponding slot. The first bitmap (A) is for slots 0-255, the
        // second bitmap (B) is for slots 256-511.
        uint256 slotsBitmapA;
        uint256 slotsBitmapB;
        // minimum bitmap index with an active bid
        // @dev set to 512 if no active bids
        // @dev max uint16 >> max possible value of 512
        uint16 minBidSlotIndex;
        // maximum bitmap index with an active bid
        // @dev set to 0 if no active bids
        uint16 maxBidSlotIndex;
        // --- bid auto-minting tracking ---
        uint32 latestMintedBidId;
        // --- error state bid auto-refund tracking ---
        uint32 latestRefundedBidId;
        // --- next bid ID ---
        // nonce for generating new bid IDs on this project
        // @dev allows for gt 4 billion bids, and max possible bids for a
        // 1M token project is 1M * 512 slots = 512M bids < 4B max uint32
        uint32 nextBidId;
        // --- auction parameters ---
        // number of tokens and related values
        // @dev max uint24 is 16,777,215 > 1_000_000 max project size
        uint24 numTokensInAuction;
        uint24 numBids;
        uint24 numBidsMintedTokens;
        uint24 numBidsErrorRefunded;
        // timing
        // @dev max uint40 ~= 1.1e12 sec ~= 34 thousand years
        uint40 timestampStart;
        // @dev timestampOriginalEnd & timestampEnd are the same if not in extra time
        uint40 timestampOriginalEnd;
        uint40 timestampEnd;
        // @dev max uint8 ~= 256 hours, which is gt max auction extension time of 72 hours
        uint8 adminEmergencyExtensionHoursApplied;
        bool allowExtraTime;
        bool adminArtistOnlyMintPeriodIfSellout;
        // pricing
        // @dev max uint88 ~= 3e26 Wei = ~300 million ETH, which is well above
        // the expected prices of any NFT mint in the foreseeable future.
        uint88 basePrice;
        // -- redundant backstops --
        // Track per-project fund balance, in wei. This is used as a redundant
        // backstop to prevent one project from draining the minter's balance
        // of ETH from other projects, which is a worthwhile failsafe on this
        // shared minter.
        // @dev max uint120 > max basPrice * 256 * 1_000_000
        // @dev while uint88 is gt max ETH supply, use uin120 to prevent reliance on
        // max token supply
        uint120 projectBalance;
        // --- revenue collection state ---
        bool revenuesCollected;
    }

    struct Bid {
        uint32 prevBidId;
        uint32 nextBidId;
        uint16 slotIndex;
        address bidder;
        // three bool values packed into a single uint8
        // index 0 - isSettled (INDEX_IS_SETTLED)
        // index 1 - isMinted (INDEX_IS_MINTED)
        // index 2 - isRefunded (INDEX_IS_REFUNDED)
        uint8 packedBools;
    }

    // contract-specific parameters
    enum AdminMintingConstraint {
        None,
        AdminArtistOnlyMintPeriod,
        NoAdminArtistOnlyMintPeriod
    }

    // Diamond storage pattern is used in this library
    struct RAMLibStorage {
        mapping(address coreContract => mapping(uint256 projectId => RAMProjectConfig)) RAMProjectConfigs;
        mapping(address => AdminMintingConstraint) RAMAdminMintingConstraint;
    }

    /**
     * @notice Update a contract's requirements on if a post-auction
     * admin-artist-only mint period is required or not, for and-on
     * configured projects.
     * @param coreContract The address of the core contract being configured
     * @param adminMintingConstraint The AdminMintingConstraint setting for the contract
     */
    function setContractConfig(
        address coreContract,
        AdminMintingConstraint adminMintingConstraint
    ) internal {
        // set the contract admin minting constraint with the new constraint enum value
        s().RAMAdminMintingConstraint[coreContract] = adminMintingConstraint;
        // emit event
        emit ContractConfigUpdated({
            coreContract: coreContract,
            adminMintingConstraint: adminMintingConstraint
        });
    }

    /**
     * @notice Function to add emergency auction hours to auction of
     * project `projectId` on core contract `coreContract`.
     * Protects against unexpected frontend downtime, etc.
     * Reverts if called by anyone other than a contract admin.
     * Reverts if project is not in a Live Auction.
     * Reverts if auction is already in extra time.
     * Reverts if adding more than the maximum number of emergency hours.
     * @param projectId Project ID to add emergency auction hours to.
     * @param coreContract Core contract address for the given project.
     * @param emergencyHoursToAdd Number of emergency hours to add to the
     * project's auction.
     */
    function adminAddEmergencyAuctionHours(
        uint256 projectId,
        address coreContract,
        uint8 emergencyHoursToAdd
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // CHECKS
        // require auction in state B (Live Auction)
        require(
            getProjectMinterState(projectId, coreContract) ==
                ProjectMinterStates.LiveAuction,
            "Only live auction"
        );
        // require auction has not reached extra time
        require(
            RAMProjectConfig_.timestampOriginalEnd ==
                RAMProjectConfig_.timestampEnd,
            "Not allowed in extra time"
        );
        // require auction is not being extended beyond limit
        uint8 newAdminEmergencyExtensionHours = RAMProjectConfig_
            .adminEmergencyExtensionHoursApplied + emergencyHoursToAdd;

        require(
            newAdminEmergencyExtensionHours <=
                MAX_AUCTION_ADMIN_EMERGENCY_EXTENSION_HOURS,
            "Only emergency hours lt max"
        );
        // calculate auction end time
        // @dev overflow automatically checked in solidity 0.8
        uint40 newTimestampEnd = RAMProjectConfig_.timestampEnd +
            emergencyHoursToAdd *
            1 hours;

        // EFFECTS
        // update emergency hours applied
        // @dev overflow automatically checked in solidity 0.8
        RAMProjectConfig_
            .adminEmergencyExtensionHoursApplied = newAdminEmergencyExtensionHours;

        // update auction end time
        // @dev update both original end timestamp and current end timestamp
        // because this is not extra time, but rather an emergency extension
        RAMProjectConfig_.timestampEnd = newTimestampEnd;
        RAMProjectConfig_.timestampOriginalEnd = newTimestampEnd;

        // emit event
        emit AuctionTimestampEndUpdated({
            projectId: projectId,
            coreContract: coreContract,
            timestampEnd: newTimestampEnd
        });
    }

    /**
     * @notice Function to set auction details on project `projectId` on core contract `coreContract`.
     * Reverts if not currently in ProjectMinterState A.
     * Reverts if base price does not meet the minimum.
     * Reverts if not for future auction.
     * Reverts if end time not greater than start time.
     * Reverts if adminArtistOnlyMintPeriodIfSellout disagrees with the admin configured constraint.
     * @param projectId Project ID to add emergency auction hours to.
     * @param coreContract Core contract address for the given project.
     * @param auctionTimestampStart New timestamp at which to start the auction.
     * @param auctionTimestampEnd New timestamp at which to end the auction.
     * @param basePrice Base price (or reserve price) of the auction, in Wei
     * @param allowExtraTime Auction allows extra time
     * @param adminArtistOnlyMintPeriodIfSellout Auction admin-artist-only mint period if
     * sellout
     */
    function setAuctionDetails(
        uint256 projectId,
        address coreContract,
        uint40 auctionTimestampStart,
        uint40 auctionTimestampEnd,
        uint88 basePrice,
        bool allowExtraTime,
        bool adminArtistOnlyMintPeriodIfSellout
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // CHECKS
        // require ProjectMinterState Pre-auction (State A)
        require(
            getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            }) == ProjectMinterStates.PreAuction,
            "Only pre-auction"
        );
        // require base price >= 0.05 ETH
        require(basePrice >= 0.05 ether, "Only base price gte 0.05 ETH");
        // only future start time
        require(
            auctionTimestampStart > block.timestamp,
            "Only future auctions"
        );

        // enforce contract-level constraints set by contract admin
        AdminMintingConstraint RAMAdminMintingConstraint_ = getRAMAdminMintingConstraintValue({
                coreContract: coreContract
            });

        if (
            RAMAdminMintingConstraint_ ==
            AdminMintingConstraint.AdminArtistOnlyMintPeriod
        ) {
            require(
                adminArtistOnlyMintPeriodIfSellout,
                "Only admin-artist mint period"
            );
        } else if (
            RAMAdminMintingConstraint_ ==
            AdminMintingConstraint.NoAdminArtistOnlyMintPeriod
        ) {
            require(
                !adminArtistOnlyMintPeriodIfSellout,
                "Only no admin-artist mint period"
            );
        }

        // refresh max invocations to eliminate any stale state
        MaxInvocationsLib.refreshMaxInvocations({
            projectId: projectId,
            coreContract: coreContract
        });

        // set auction details
        RAMProjectConfig_.timestampStart = auctionTimestampStart;
        RAMProjectConfig_.timestampEnd = auctionTimestampEnd;
        RAMProjectConfig_.timestampOriginalEnd = auctionTimestampEnd;
        RAMProjectConfig_.basePrice = basePrice;
        RAMProjectConfig_.allowExtraTime = allowExtraTime;
        RAMProjectConfig_
            .adminArtistOnlyMintPeriodIfSellout = adminArtistOnlyMintPeriodIfSellout;
        // refresh numTokensInAuction
        uint256 numTokensInAuction = refreshNumTokensInAuction({
            projectId: projectId,
            coreContract: coreContract
        });

        // initialize min slot metadata to NUM_SLOTS (an invalid index) to represent NULL value
        RAMProjectConfig_.minBidSlotIndex = uint16(NUM_SLOTS);

        // emit state change event
        emit AuctionConfigUpdated({
            projectId: projectId,
            coreContract: coreContract,
            timestampStart: auctionTimestampStart,
            timestampEnd: auctionTimestampEnd,
            basePrice: basePrice,
            allowExtraTime: allowExtraTime,
            adminArtistOnlyMintPeriodIfSellout: adminArtistOnlyMintPeriodIfSellout,
            numTokensInAuction: numTokensInAuction
        });
    }

    /**
     * @notice Reduces the auction length for project `projectId` on core
     * contract `coreContract` to `auctionTimestampEnd`.
     * Only allowed to be called during a live auction, and protects against
     * the case of an accidental excessively long auction, which locks funds.
     * Reverts if called by anyone other than the project's artist.
     * Reverts if project is not in a Live Auction.
     * Reverts if auction is not being reduced in length.
     * Reverts if in extra time.
     * Reverts if `auctionTimestampEnd` results in auction that is not at least
     * `minimumAuctionDurationSeconds` in duration.
     * Reverts if admin previously applied a time extension.
     * @param projectId Project ID to reduce the auction length for.
     * @param coreContract Core contract address for the given project.
     * @param auctionTimestampEnd New timestamp at which to end the auction.
     * @param minimumAuctionDurationSeconds Minimum auction duration, in seconds
     */
    function reduceAuctionLength(
        uint256 projectId,
        address coreContract,
        uint40 auctionTimestampEnd,
        uint256 minimumAuctionDurationSeconds
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // CHECKS
        // require auction state B, live auction
        require(
            getProjectMinterState(projectId, coreContract) ==
                ProjectMinterStates.LiveAuction,
            "Only live auction"
        );
        // require no previous admin extension time
        require(
            RAMProjectConfig_.adminEmergencyExtensionHoursApplied == 0,
            "No previous admin extension"
        );
        // require not in extra time
        require(
            RAMProjectConfig_.timestampOriginalEnd ==
                RAMProjectConfig_.timestampEnd,
            "Not allowed in extra time"
        );
        // require reduction in auction length
        require(
            auctionTimestampEnd < RAMProjectConfig_.timestampEnd,
            "Only reduce auction length"
        );
        // require meet minimum auction length requirement
        require(
            auctionTimestampEnd >
                RAMProjectConfig_.timestampStart +
                    minimumAuctionDurationSeconds,
            "Auction too short"
        );
        // require new end time in future
        require(auctionTimestampEnd > block.timestamp, "Only future end time");

        // set auction details
        RAMProjectConfig_.timestampEnd = auctionTimestampEnd;
        // also update original end for accurate extra time calculation
        RAMProjectConfig_.timestampOriginalEnd = auctionTimestampEnd;

        // emit state change event
        emit AuctionTimestampEndUpdated({
            projectId: projectId,
            coreContract: coreContract,
            timestampEnd: auctionTimestampEnd
        });
    }

    /**
     * @notice Update the number of tokens in the auction, based on the state
     * of the core contract and the minter-local max invocations.
     * @param projectId Project ID to update
     * @param coreContract Core contract address to update
     */
    function refreshNumTokensInAuction(
        uint256 projectId,
        address coreContract
    ) internal returns (uint256 numTokensInAuction) {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // @dev safe to cast - max uint24 is 16_777_215 > 1_000_000 max project size
        numTokensInAuction = MaxInvocationsLib.getInvocationsAvailable({
            projectId: projectId,
            coreContract: coreContract
        });
        RAMProjectConfig_.numTokensInAuction = uint24(numTokensInAuction);

        // emit event for state change
        emit NumTokensInAuctionUpdated({
            projectId: projectId,
            coreContract: coreContract,
            numTokensInAuction: numTokensInAuction
        });
    }

    /**
     * @notice Collects settlement for project `projectId` on core contract
     * `coreContract` for all bids in `bidIds`.
     * Reverts if project is not in a post-auction state.
     * Reverts if bidder is not the bidder for all bids.
     * Reverts if one or more bids has already been settled.
     * Reverts if invalid bid is found.
     * @param projectId Project ID of bid to collect settlement for
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to collect settlements for
     * @param bidder Bidder address of bid to collect settlements for
     * @param minterRefundGasLimit Gas limit to use when refunding the bidder.
     */
    function collectSettlements(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds,
        address bidder,
        uint256 minterRefundGasLimit
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // CHECKS
        // @dev block scope to avoid stack too deep error
        {
            // require project minter state C or D (Post-Auction, Open Mint or Admin-Artist Mint Period)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState ==
                    ProjectMinterStates.PostAuctionSellOutAdminArtistMint ||
                    projectMinterState ==
                    ProjectMinterStates.PostAuctionOpenMint,
                "Only state C or D"
            );
        }

        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });

        // settle each input bid
        // @dev already verified that input lengths match
        uint256 inputBidsLength = bidIds.length;
        // @dev overflow check optimization as of 0.8.22
        for (uint256 i = 0; i < inputBidsLength; ++i) {
            // settle the bid
            _settleBidWithChecks({
                RAMProjectConfig_: RAMProjectConfig_,
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                bidId: bidIds[i],
                bidder: bidder,
                minterRefundGasLimit: minterRefundGasLimit
            });
        }
    }

    /**
     * @notice Directly mint tokens to winners of project `projectId` on core
     * contract `coreContract`.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `adminArtistAutoMintTokensToWinners` does while in State C.
     * Skips over bids that have already been minted or refunded (front-running
     * protection)
     * Reverts if project is not in a post-auction state,
     * post-admin-artist-only mint period (i.e. State D), with tokens available
     * Reverts if bid does not exist at bidId.
     * Reverts if msg.sender is not the bidder for all bids if
     * requireSenderIsBidder is true.
     * @param projectId Project ID to mint tokens on.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to mint tokens for
     * @param requireSenderIsBidder bool representing if the sender must be the
     * bidder for all bids
     * @param minterFilter Minter filter to use when minting tokens
     * @param minterRefundGasLimit Gas limit to use when refunding the bidder.
     */
    function directMintTokensToWinners(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds,
        bool requireSenderIsBidder,
        IMinterFilterV1 minterFilter,
        uint256 minterRefundGasLimit
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });

        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });

        // CHECKS
        // @dev memoize length for gas efficiency
        uint256 bidIdsLength = bidIds.length;
        // @dev block scope to limit stack depth
        {
            // require project minter state D (Post-Auction,
            // post-admin-artist-only, not all bids handled)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState == ProjectMinterStates.PostAuctionOpenMint,
                "Only post-auction open mint"
            );
            // require numTokensToMint does not exceed number of tokens
            // owed.
            // @dev must check this here to avoid minting more tokens than max
            // invocations, which could potentially not revert if minter
            // max invocations was limiting (+other unexpected conditions)
            require(
                bidIdsLength <=
                    _getNumTokensOwed({RAMProjectConfig_: RAMProjectConfig_}),
                "tokens to mint gt tokens owed"
            );
        }

        // main loop to mint tokens
        for (uint256 i; i < bidIdsLength; ++i) {
            // @dev current slot index and bid index in slot not memoized due
            // to stack depth limitations
            // get bid
            uint256 currentBidId = bidIds[i];
            Bid storage bid = RAMProjectConfig_.bids[currentBidId];
            address bidderAddress = bid.bidder;
            // CHECKS
            // require bid exists
            require(bidderAddress != address(0), "invalid Bid ID");
            // if bid is already minted or refunded, skip to next bid
            // @dev do not revert, since this could be due to front-running
            if (
                _getBidPackedBool(bid, INDEX_IS_MINTED) ||
                _getBidPackedBool(bid, INDEX_IS_REFUNDED)
            ) {
                continue;
            }
            // require sender is bidder if requireSenderIsBidder is true
            if (requireSenderIsBidder) {
                require(msg.sender == bidderAddress, "Only sender is bidder");
            }
            // EFFECTS
            // @dev num bids minted tokens not memoized due to stack depth
            // limitations
            RAMProjectConfig_.numBidsMintedTokens++;
            // Mint bid and settle if not already settled
            _mintAndSettle({
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                slotIndex: bid.slotIndex,
                bidId: currentBidId,
                minterFilter: minterFilter,
                minterRefundGasLimit: minterRefundGasLimit
            });
        }
    }

    /**
     * @notice Function that enables a contract admin or artist (checked by
     * external function) to mint tokens to winners of project `projectId` on
     * core contract `coreContract`.
     * Automatically mints tokens to most-winning bids, in order from highest
     * and earliest bid to lowest and latest bid.
     * Settles bids as tokens are minted, if not already settled.
     * Reverts if project is not in a post-auction state, admin-artist-only mint
     * period (i.e. State C), with tokens available.
     * to be minted.
     * Reverts if number of tokens to mint is greater than the number of
     * tokens available to be minted.
     * @param projectId Project ID to mint tokens on.
     * @param coreContract Core contract address for the given project.
     * @param numTokensToMint Number of tokens to mint in this transaction.
     * @param minterFilter Minter filter contract address
     * @param minterRefundGasLimit Gas limit to use when settling bid if not already settled
     */
    function adminArtistAutoMintTokensToWinners(
        uint256 projectId,
        address coreContract,
        uint24 numTokensToMint,
        IMinterFilterV1 minterFilter,
        uint256 minterRefundGasLimit
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });

        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });

        // CHECKS
        // @dev block scope to limit stack depth
        {
            // require project minter state C (Post-Auction, sell out, admin-artist-only,
            // not all bids handled)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState ==
                    ProjectMinterStates.PostAuctionSellOutAdminArtistMint,
                "Only state C"
            );
            // require numTokensToMint does not exceed number of tokens
            // owed
            // @dev must check this here to avoid minting more tokens than max
            // invocations, which could potentially not revert if minter
            // max invocations was limiting (+other unexpected conditions)
            require(
                numTokensToMint <=
                    _getNumTokensOwed({RAMProjectConfig_: RAMProjectConfig_}),
                "tokens to mint gt tokens owed"
            );
        }

        // EFFECTS
        // load values to memory for gas efficiency
        uint256 currentLatestMintedBidId = RAMProjectConfig_.latestMintedBidId;
        // @dev will be zero if no bids minted yet
        uint256 currentLatestMintedBidSlotIndex = RAMProjectConfig_
            .bids[currentLatestMintedBidId]
            .slotIndex;

        uint256 numNewTokensMinted; // = 0

        // main loop to mint tokens
        while (numNewTokensMinted < numTokensToMint) {
            // EFFECTS
            // STEP 1: scroll to next bid to be minted a token
            // set latest minted bid indices to the bid to be minted a token
            if (currentLatestMintedBidId == 0) {
                // first mint, so need to initialize cursor values
                // set bid to highest bid in the project, head of max bid slot
                currentLatestMintedBidSlotIndex = RAMProjectConfig_
                    .maxBidSlotIndex;
                currentLatestMintedBidId = RAMProjectConfig_.headBidIdBySlot[
                    currentLatestMintedBidSlotIndex
                ];
            } else {
                // scroll to next bid in current slot
                // @dev scrolling to null is okay and handled below
                currentLatestMintedBidId = RAMProjectConfig_
                    .bids[currentLatestMintedBidId]
                    .nextBidId;
                // if scrolled off end of list, then find next slot with bids
                if (currentLatestMintedBidId == 0) {
                    // past tail of current slot's linked list, so need to find next
                    // bid slot with bids
                    currentLatestMintedBidSlotIndex = _getMaxSlotWithBid({
                        RAMProjectConfig_: RAMProjectConfig_,
                        startSlotIndex: uint16(
                            currentLatestMintedBidSlotIndex - 1
                        )
                    });
                    // @dev no coverage on else branch because it is unreachable as used
                    require(
                        currentLatestMintedBidSlotIndex < NUM_SLOTS,
                        "slot with bid not found"
                    );
                    // current bid is now the head of the linked list
                    currentLatestMintedBidId = RAMProjectConfig_
                        .headBidIdBySlot[currentLatestMintedBidSlotIndex];
                }
            }

            // @dev minter is in State C, so bid must not have been minted or
            // refunded due to scrolling logic of admin mint and refund
            // functions available for use while in State C. The bid may have
            // been previously settled, however.

            // Mint bid and settle if not already settled
            // @dev scrolling logic in State C ensures bid **exists** is not yet minted
            _mintAndSettle({
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                slotIndex: currentLatestMintedBidSlotIndex,
                bidId: currentLatestMintedBidId,
                minterFilter: minterFilter,
                minterRefundGasLimit: minterRefundGasLimit
            });

            // increment num new tokens minted
            unchecked {
                ++numNewTokensMinted;
            }
        }

        // finally, update auction metadata storage state from memoized values
        // @dev safe to cast numNewTokensMinted to uint24
        RAMProjectConfig_.numBidsMintedTokens += uint24(numNewTokensMinted);
        // @dev safe to cast to uint32 because directly derived from bid ID
        RAMProjectConfig_.latestMintedBidId = uint32(currentLatestMintedBidId);
    }

    /**
     * @notice Directly refund bids for project `projectId` on core contract
     * `coreContract` to resolve error state E1.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `autoRefundBidsToResolveE1` does while in State C.
     * Skips over bids that have already been minted or refunded (front-running
     * protection)
     * Reverts if project is not in post-auction state,
     * post-admin-artist-only mint period (i.e. State D).
     * Reverts if project is not in error state E1.
     * Reverts if length of bids to refund exceeds the number of bids that need
     * to be refunded to resolve the error state E1.
     * Reverts if bid does not exist at bidId.
     * Reverts if msg.sender is not the bidder for all bids if
     * requireSenderIsBidder is true.
     * @param projectId Project ID to refunds bids for.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to refund bid values for
     * @param requireSenderIsBidder Require sender is bidder for all bids
     * @param minterRefundGasLimit Gas limit to use when refunding the bidder.
     */
    function directRefundBidsToResolveE1(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds,
        bool requireSenderIsBidder,
        uint256 minterRefundGasLimit
    ) internal {
        // CHECKS
        // @dev memoize length for gas efficiency
        uint256 bidIdsLength = bidIds.length;
        // @dev block scope to limit stack depth
        {
            // require project minter state D (Post-Auction, post-admin-artist-only,
            // not all bids handled)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState == ProjectMinterStates.PostAuctionOpenMint,
                "Only post-auction open mint"
            );
            // require is in state E1
            (bool isErrorE1_, uint256 numBidsToResolveE1, ) = isErrorE1FlagF1({
                projectId: projectId,
                coreContract: coreContract
            });
            require(isErrorE1_, "Only in state E1");
            // require numBidsToRefund does not exceed max number of bids
            // to resolve E1 error state
            require(
                bidIdsLength <= numBidsToResolveE1,
                "bids to refund gt available qty"
            );
        }

        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });

        // @dev memoize for gas efficiency
        uint24 numRefundsIssued = 0;
        // main loop to refund tokens
        for (uint256 i; i < bidIdsLength; ++i) {
            // @dev current slot index and bid index in slot not memoized due
            // to stack depth limitations
            // get bid
            uint256 currentBidId = bidIds[i];
            Bid storage bid = RAMProjectConfig_.bids[currentBidId];
            // CHECKS
            // require bidder is non-zero address (i.e. bid exists)
            address bidderAddress = bid.bidder;
            require(bidderAddress != address(0), "invalid Bid ID");
            // if bid is already minted or refunded, skip to next bid
            // @dev do not revert, since this could be due to front-running
            if (
                _getBidPackedBool(bid, INDEX_IS_MINTED) ||
                _getBidPackedBool(bid, INDEX_IS_REFUNDED)
            ) {
                continue;
            }
            // require sender is bidder if requireSenderIsBidder is true
            if (requireSenderIsBidder) {
                require(msg.sender == bidderAddress, "Only sender is bidder");
            }
            // EFFECTS
            // Settle and Refund the Bid
            _settleAndRefundBid({
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                slotIndex: bid.slotIndex,
                bidId: currentBidId,
                minterRefundGasLimit: minterRefundGasLimit
            });
            numRefundsIssued++;
        }
        // update number of bids refunded
        RAMProjectConfig_.numBidsErrorRefunded += numRefundsIssued;
    }

    /**
     * @notice Function to automatically refund the lowest winning bids for
     * project `projectId` on core contract `coreContract` to resolve error
     * state E1.
     * Reverts if project is not in post-auction state C.
     * Reverts if project is not in error state E1.
     * Reverts if numBidsToRefund exceeds the number of bids that need to be
     * refunded to resolve the error state E1.
     * @dev Recommend admin-only not for security, but rather to enable Admin
     * to be aware that an error state has been encountered while in post-
     * auction state C.
     * @param projectId Project ID to refunds bids for.
     * @param coreContract Core contract address for the given project.
     * @param numBidsToRefund Number of bids to refund in this call.
     * @param minterRefundGasLimit Gas limit to use when refunding the bidder.
     */
    function autoRefundBidsToResolveE1(
        uint256 projectId,
        address coreContract,
        uint24 numBidsToRefund,
        uint256 minterRefundGasLimit
    ) internal {
        // CHECKS
        // @dev block scope to limit stack depth
        {
            // require project minter state C (Post-Auction, admin-artist-only,
            //  not all bids handled)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState ==
                    ProjectMinterStates.PostAuctionSellOutAdminArtistMint,
                "Only state C"
            );
            // require is in state E1
            (bool isErrorE1_, uint256 numBidsToResolveE1, ) = isErrorE1FlagF1({
                projectId: projectId,
                coreContract: coreContract
            });
            require(isErrorE1_, "Only in state E1");
            // require numBidsToRefund does not exceed max number of bids
            // to resolve E1 error state
            require(
                numBidsToRefund <= numBidsToResolveE1,
                "bids to refund gt available qty"
            );
        }
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });

        // EFFECTS
        // load values to memory for gas efficiency
        uint256 currentLatestRefundedBidId = RAMProjectConfig_
            .latestRefundedBidId;
        uint256 currentLatestRefundedBidSlotIndex = RAMProjectConfig_
            .bids[currentLatestRefundedBidId]
            .slotIndex;
        // settlement values
        uint256 numRefundsIssued; // = 0

        // main loop to refund bids
        while (numRefundsIssued < numBidsToRefund) {
            // EFFECTS
            // STEP 1: Get next bid to be refunded
            // set latest refunded bid indices to the bid to be refunded
            if (currentLatestRefundedBidId == 0) {
                // first refund, so need to initialize cursor values
                // set bid to lowest bid in the project, tail of min bid slot
                currentLatestRefundedBidSlotIndex = RAMProjectConfig_
                    .minBidSlotIndex;
                currentLatestRefundedBidId = RAMProjectConfig_.tailBidIdBySlot[
                    currentLatestRefundedBidSlotIndex
                ];
            } else {
                // scroll to previous bid in current slot
                // @dev scrolling to null is okay and handled below
                currentLatestRefundedBidId = RAMProjectConfig_
                    .bids[currentLatestRefundedBidId]
                    .prevBidId;
            }

            // if scrolled off end of list, then find next slot with bids
            if (currentLatestRefundedBidId == 0) {
                // past head of current slot's linked list, so need to find next
                // bid slot with bids
                // @dev not possible to not find next slot during auto-refund,
                // so no need to handle case where slot not found
                currentLatestRefundedBidSlotIndex = _getMinSlotWithBid({
                    RAMProjectConfig_: RAMProjectConfig_,
                    startSlotIndex: uint16(
                        currentLatestRefundedBidSlotIndex + 1
                    )
                });
                // current bid is now the tail of the linked list
                currentLatestRefundedBidId = RAMProjectConfig_.tailBidIdBySlot[
                    currentLatestRefundedBidSlotIndex
                ];
            }

            // @dev minter is in State C, so bid must not have been minted or
            // refunded due to scrolling logic of admin mint and refund
            // functions available for use while in State C. The bid may have
            // been previously settled, however.

            // Settle & Refund the Bid
            _settleAndRefundBid({
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                slotIndex: uint16(currentLatestRefundedBidSlotIndex),
                bidId: currentLatestRefundedBidId,
                minterRefundGasLimit: minterRefundGasLimit
            });
            // increment loop counter and current num bids refunded
            unchecked {
                ++numRefundsIssued;
            }
        }

        // finally, update auction metadata storage state from memoized values
        // @dev safe to cast currentNumBidsErrorRefunded to uint24
        RAMProjectConfig_.numBidsErrorRefunded += uint24(numRefundsIssued);
        // @dev safe to cast to uint32 because directly derived from bid ID
        RAMProjectConfig_.latestRefundedBidId = uint32(
            currentLatestRefundedBidId
        );
    }

    /**
     * @notice This withdraws project revenues for project `projectId` on core
     * contract `coreContract` to the artist and admin, only after all bids
     * have been minted+settled or refunded.
     * Note that the conditions described are the equivalent of project minter
     * State E.
     * @param projectId Project ID to withdraw revenues for.
     * @param coreContract Core contract address for the given project.
     */
    function withdrawArtistAndAdminRevenues(
        uint256 projectId,
        address coreContract
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });

        // CHECKS
        // require project minter state E (Post-Auction, all bids handled)
        ProjectMinterStates projectMinterState = getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        require(
            projectMinterState == ProjectMinterStates.PostAuctionAllBidsHandled,
            "Only state E"
        );
        // require revenues not already withdrawn
        require(
            !(RAMProjectConfig_.revenuesCollected),
            "Revenues already withdrawn"
        );

        // EFFECTS
        // update state to indicate revenues withdrawn
        RAMProjectConfig_.revenuesCollected = true;

        // get project price
        uint256 projectPrice = _getProjectPrice({
            RAMProjectConfig_: RAMProjectConfig_
        });
        // get netRevenues
        // @dev refunded bids do not count towards amount due because they
        // did not generate revenue
        uint256 netRevenues = projectPrice *
            RAMProjectConfig_.numBidsMintedTokens;

        // update project balance
        // @dev reverts on underflow
        RAMProjectConfig_.projectBalance -= uint120(netRevenues);

        // INTERACTIONS
        SplitFundsLib.splitRevenuesETHNoRefund({
            projectId: projectId,
            valueInWei: netRevenues,
            coreContract: coreContract
        });

        emit GenericMinterEventsLib.ConfigValueSet({
            projectId: projectId,
            coreContract: coreContract,
            key: CONFIG_AUCTION_REVENUES_COLLECTED,
            value: true
        });
    }

    /**
     * @notice Function to mint tokens if an auction is over, but did not sell
     * out and tokens are still available to be minted.
     * @dev must be called within non-reentrant context
     * @param to Address to be the new token's owner.
     * @param projectId Project ID to mint a token on.
     * @param coreContract Core contract address for the given project.
     * @param minterFilter Minter filter to use when minting token.
     * @return tokenId Token ID of minted token
     */
    function purchaseTo(
        address to,
        uint256 projectId,
        address coreContract,
        IMinterFilterV1 minterFilter
    ) internal returns (uint256 tokenId) {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });

        // CHECKS
        // @dev block scope to limit stack depth
        {
            // require project minter state D, or E (Post-Auction)
            ProjectMinterStates projectMinterState = getProjectMinterState({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                projectMinterState == ProjectMinterStates.PostAuctionOpenMint ||
                    projectMinterState ==
                    ProjectMinterStates.PostAuctionAllBidsHandled,
                "Only state D or E"
            );
            // require Flag F1, i.e. at least one excess token available to be
            // minted
            // @dev this ensures minter and core contract max-invocations
            // constraints are not violated, as well as confirms that one
            // additional mint will not send the minter into an E1 state
            (, , uint256 numExcessInvocationsAvailable) = isErrorE1FlagF1({
                projectId: projectId,
                coreContract: coreContract
            });
            require(
                numExcessInvocationsAvailable > 0,
                "Reached max invocations"
            );
        }
        // require sufficient payment
        // since excess invocations are available, know not a sellout, so
        // project price is base price
        uint256 pricePerTokenInWei = RAMProjectConfig_.basePrice;
        require(
            msg.value == pricePerTokenInWei,
            "Only send auction reserve price"
        );

        // EFFECTS
        // mint token
        tokenId = minterFilter.mint_joo({
            to: to,
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender
        });

        // @dev this minter specifically does not update max invocations has
        // been reached, since it must consider unminted bids when determining
        // if max invocations has been reached

        // INTERACTIONS
        // split revenue from sale
        // @dev no refund because previously verified msg.value == pricePerTokenInWei
        // @dev no effect on project balance, splitting same amount received
        SplitFundsLib.splitRevenuesETHNoRefund({
            projectId: projectId,
            valueInWei: pricePerTokenInWei,
            coreContract: coreContract
        });

        // emit event for state change
        emit TokenPurchased({
            projectId: projectId,
            coreContract: coreContract,
            tokenId: tokenId,
            to: to
        });
    }

    /**
     * @notice Place a new bid for a project.
     * Assumes check that minter is set for project on minter filter has
     * already been performed.
     * Reverts if project is not in state B (Live Auction).
     * Reverts if bid value is not equal to the slot value.
     * @param projectId Project Id to place bid for
     * @param coreContract Core contract address to place bid for
     * @param slotIndex Slot index to place bid at
     * @param bidder Bidder address
     * @param bidValue Bid value, in Wei (verified to align with slotIndex)
     * @param minterRefundGasLimit Gas limit to use when refunding the previous
     * highest bidder, prior to using fallback force-send to refund
     */
    function placeBid(
        uint256 projectId,
        address coreContract,
        uint16 slotIndex,
        address bidder,
        uint256 bidValue,
        uint256 minterRefundGasLimit
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // CHECKS
        // require project minter state B (Live Auction)
        require(
            getProjectMinterState(projectId, coreContract) ==
                ProjectMinterStates.LiveAuction,
            "Only live auction"
        );
        // require slot index not out of range
        // @dev slot index out of range is checked in slotIndexToBidValue
        // require bid value must equal slot value
        uint256 newBidRequiredValue = slotIndexToBidValue({
            basePrice: RAMProjectConfig_.basePrice,
            slotIndex: slotIndex
        });
        require(
            bidValue == newBidRequiredValue,
            "msg.value must equal slot value"
        );

        // EFFECTS
        // add bid value to project balance
        RAMProjectConfig_.projectBalance += uint120(bidValue);
        // if first bid, refresh max invocations in case artist has reduced
        // the core contract's max invocations after the auction was configured
        // @dev this helps prevent E1 error state
        if (RAMProjectConfig_.numBids == 0) {
            // refresh max invocations
            MaxInvocationsLib.refreshMaxInvocations({
                projectId: projectId,
                coreContract: coreContract
            });
            // also refresh numTokensInAuction for RAM project config
            refreshNumTokensInAuction({
                projectId: projectId,
                coreContract: coreContract
            });
        }
        // require at least one token allowed in auction
        // @dev this case would revert in _removeMinBid, but prefer clean error
        // message here
        uint256 numTokensInAuction = RAMProjectConfig_.numTokensInAuction;
        require(numTokensInAuction > 0, "No tokens in auction");
        // determine if have reached max bids
        bool reachedMaxBids = RAMProjectConfig_.numBids >= numTokensInAuction;
        if (reachedMaxBids) {
            // remove + refund the minimum Bid
            uint256 removedBidValue = _removeMinBid({
                RAMProjectConfig_: RAMProjectConfig_,
                projectId: projectId,
                coreContract: coreContract,
                minterRefundGasLimit: minterRefundGasLimit
            });
            // require new bid is sufficiently greater than removed minimum bid
            require(
                _isSufficientOutbid({
                    oldBidValue: removedBidValue,
                    newBidValue: bidValue
                }),
                "Insufficient bid value"
            );

            // apply auction extension time if needed
            bool timeExtensionNeeded = RAMProjectConfig_.allowExtraTime &&
                block.timestamp >
                RAMProjectConfig_.timestampEnd - AUCTION_BUFFER_SECONDS;
            if (timeExtensionNeeded) {
                // extend auction end time to no longer than
                // MAX_AUCTION_EXTRA_SECONDS after original end time
                RAMProjectConfig_.timestampEnd = uint40(
                    Math.min(
                        RAMProjectConfig_.timestampOriginalEnd +
                            MAX_AUCTION_EXTRA_SECONDS,
                        block.timestamp + AUCTION_BUFFER_SECONDS
                    )
                );
                emit AuctionTimestampEndUpdated({
                    projectId: projectId,
                    coreContract: coreContract,
                    timestampEnd: RAMProjectConfig_.timestampEnd
                });
            }
        }
        // insert the new Bid
        _insertBid({
            RAMProjectConfig_: RAMProjectConfig_,
            projectId: projectId,
            coreContract: coreContract,
            slotIndex: slotIndex,
            bidder: bidder,
            bidId: 0 // zero triggers new bid ID to be assigned
        });
    }

    /**
     * @notice Top up bid for project `projectId` on core contract
     * `coreContract` for bid `bidId` to new slot index `newSlotIndex`.
     * Reverts if Bid ID has been kicked out of the auction or does not exist.
     * Reverts if bidder is not the bidder of the bid.
     * Reverts if project is not in a Live Auction.
     * Reverts if addedValue is not equal to difference in bid values between
     * new and old slots.
     * Reverts if new slot index is not greater than or equal to the current
     * slot index.
     * @param projectId Project ID to top up bid for.
     * @param coreContract Core contract address for the given project.
     * @param bidId ID of bid to top up.
     * @param newSlotIndex New slot index to move bid to.
     * @param bidder Bidder address
     * @param addedValue Value to add to the bid, in Wei
     */
    function topUpBid(
        uint256 projectId,
        address coreContract,
        uint32 bidId,
        uint16 newSlotIndex,
        address bidder,
        uint256 addedValue
    ) internal {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        Bid storage bid = RAMProjectConfig_.bids[bidId];
        // memoize for gas efficiency
        uint16 oldSlotIndex = bid.slotIndex;
        // CHECKS
        {
            // require project minter state B (Live Auction)
            require(
                getProjectMinterState(projectId, coreContract) ==
                    ProjectMinterStates.LiveAuction,
                "Only live auction"
            );
            // require new slot index not out of range
            // @dev slot index out of range is checked in slotIndexToBidValue
            // @dev give clean error message if bid is null or deleted
            require(bid.bidder != address(0), "Bid dne - were you outbid?");
            // require bidder owns referenced bid
            require(bid.bidder == bidder, "Only bidder of existing bid");
            // require correct added bid value
            uint256 oldBidValue = slotIndexToBidValue({
                basePrice: RAMProjectConfig_.basePrice,
                slotIndex: oldSlotIndex
            });
            uint256 newBidValue = slotIndexToBidValue({
                basePrice: RAMProjectConfig_.basePrice,
                slotIndex: newSlotIndex
            });
            // implicitly checks that newSlotIndex > oldSlotIndex, since
            // addedValue must be positive
            require(
                oldBidValue + addedValue == newBidValue,
                "incorrect added value"
            );
        }

        // EFFECTS
        // add the added value to project balance
        RAMProjectConfig_.projectBalance += uint120(addedValue);
        // eject bid from the linked list at oldSlotIndex
        _ejectBidFromSlot({
            RAMProjectConfig_: RAMProjectConfig_,
            slotIndex: oldSlotIndex,
            bidId: bidId
        });
        // insert the existing bid into newSlotIndex's linked list
        _insertBid({
            RAMProjectConfig_: RAMProjectConfig_,
            projectId: projectId,
            coreContract: coreContract,
            slotIndex: newSlotIndex,
            bidder: bidder,
            bidId: bidId
        });

        // emit top-up event
        emit BidToppedUp({
            projectId: projectId,
            coreContract: coreContract,
            bidId: bidId,
            newSlotIndex: newSlotIndex
        });
    }

    /**
     * @notice Returns a storage pointer to the Bid struct and slot index of the lowest bid in the
     * project's auction, in Wei.
     * Reverts if no bids exist in the auction.
     * @param projectId Project ID to get the lowest bid value for
     * @param coreContract Core contract address for the given project
     * @return minBid Storage pointer to Bid struct of the lowest bid in
     * the auction
     * @return minSlotIndex Slot index of the lowest bid in the auction
     */
    function getLowestBid(
        uint256 projectId,
        address coreContract
    ) internal view returns (Bid storage minBid, uint16 minSlotIndex) {
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // revert if no bids in auction
        require(RAMProjectConfig_.numBids > 0, "No bids in auction");
        // get min slot with a bid
        minSlotIndex = RAMProjectConfig_.minBidSlotIndex;
        // get the tail bid ID for the min slot
        uint256 tailBidId = RAMProjectConfig_.tailBidIdBySlot[minSlotIndex];
        minBid = RAMProjectConfig_.bids[tailBidId];
    }

    /**
     * @notice Returns the auction details for project `projectId` on core
     * contract `coreContract`.
     * @param projectId is an existing project ID.
     * @param coreContract is an existing core contract address.
     * @return auctionTimestampStart is the timestamp at which the auction
     * starts.
     * @return auctionTimestampEnd is the timestamp at which the auction ends.
     * @return basePrice is the resting price of the auction, in Wei.
     * @return numTokensInAuction is the number of tokens in the auction.
     * @return numBids is the number of bids in the auction.
     * @return numBidsMintedTokens is the number of bids that have been minted
     * into tokens.
     * @return numBidsErrorRefunded is the number of bids that have been
     * refunded due to an error state.
     * @return minBidSlotIndex is the index of the slot with the minimum bid
     * value.
     * @return allowExtraTime is a bool indicating if the auction is allowed to
     * have extra time.
     * @return adminArtistOnlyMintPeriodIfSellout is a bool indicating if an
     * admin-artist-only mint period is required if the auction sells out.
     * @return revenuesCollected is a bool indicating if the auction revenues
     * have been collected.
     * @return projectMinterState is the current state of the project minter.
     * @dev projectMinterState is a RAMLib.ProjectMinterStates enum value.
     */
    function getAuctionDetails(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (
            uint256 auctionTimestampStart,
            uint256 auctionTimestampEnd,
            uint256 basePrice,
            uint256 numTokensInAuction,
            uint256 numBids,
            uint256 numBidsMintedTokens,
            uint256 numBidsErrorRefunded,
            uint256 minBidSlotIndex,
            bool allowExtraTime,
            bool adminArtistOnlyMintPeriodIfSellout,
            bool revenuesCollected,
            RAMLib.ProjectMinterStates projectMinterState
        )
    {
        // asign project minter state
        projectMinterState = getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        // get project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // get auction details
        auctionTimestampStart = RAMProjectConfig_.timestampStart;
        auctionTimestampEnd = RAMProjectConfig_.timestampEnd;
        basePrice = RAMProjectConfig_.basePrice;
        numTokensInAuction = RAMProjectConfig_.numTokensInAuction;
        numBids = RAMProjectConfig_.numBids;
        numBidsMintedTokens = RAMProjectConfig_.numBidsMintedTokens;
        numBidsErrorRefunded = RAMProjectConfig_.numBidsErrorRefunded;
        minBidSlotIndex = RAMProjectConfig_.minBidSlotIndex;
        allowExtraTime = RAMProjectConfig_.allowExtraTime;
        adminArtistOnlyMintPeriodIfSellout = RAMProjectConfig_
            .adminArtistOnlyMintPeriodIfSellout;
        revenuesCollected = RAMProjectConfig_.revenuesCollected;
    }

    /**
     * @notice Returns the price information for a given project.
     * If an auction is not configured, `isConfigured` will be false, and a
     * dummy price of zero is assigned to `tokenPriceInWei`.
     * If an auction is configured but still in a pre-auction state,
     * `isConfigured` will be true, and `tokenPriceInWei` will be the minimum
     * initial bid price for the next token auction.
     * If there is an active auction, `isConfigured` will be true, and
     * `tokenPriceInWei` will be the current minimum bid's value + min bid
     * increment due to the minter's increment percentage, rounded up to next
     * slot's bid value.
     * If there is an auction that has ended (no longer accepting bids), but
     * the project is configured, `isConfigured` will be true, and
     * `tokenPriceInWei` will be either the sellout price or the reserve price
     * of the auction if it did not sell out during its auction.
     * @param projectId Project ID to get price information for
     * @param coreContract Core contract address for the given project
     * @return isConfigured True if the project is configured, false otherwise
     * @return tokenPriceInWei Price of a token in Wei, if configured
     */
    function getPriceInfo(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool isConfigured, uint256 tokenPriceInWei) {
        // get minter state
        RAMLib.ProjectMinterStates projectMinterState = getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // handle pre-auction State A
        if (projectMinterState == RAMLib.ProjectMinterStates.PreAuction) {
            isConfigured = RAMProjectConfig_.timestampStart > 0;
            // if not configured, leave tokenPriceInWei as 0
            if (isConfigured) {
                tokenPriceInWei = RAMProjectConfig_.basePrice;
            }
        } else {
            // values that apply to all live-auction and post-auction states
            isConfigured = true;
            bool isSellout = RAMProjectConfig_.numBids >=
                RAMProjectConfig_.numTokensInAuction;

            // handle live-auction State B
            if (projectMinterState == RAMLib.ProjectMinterStates.LiveAuction) {
                if (isSellout) {
                    // find next valid bid value
                    // @dev okay if we extend past the maximum slot index value
                    // for this view function
                    (, tokenPriceInWei) = _findNextValidBidSlotIndexAndValue({
                        projectId: projectId,
                        coreContract: coreContract,
                        startSlotIndex: RAMProjectConfig_.minBidSlotIndex
                    });
                } else {
                    // not sellout, so min bid is base price
                    tokenPriceInWei = RAMProjectConfig_.basePrice;
                }
            } else {
                // handle post-auction States C, D, E
                if (isSellout) {
                    // if sellout, return min bid price
                    tokenPriceInWei = slotIndexToBidValue({
                        basePrice: RAMProjectConfig_.basePrice,
                        slotIndex: RAMProjectConfig_.minBidSlotIndex
                    });
                } else {
                    // not sellout, so return base price
                    tokenPriceInWei = RAMProjectConfig_.basePrice;
                }
            }
        }
    }

    /**
     * @notice Gets minimum next bid value in Wei and slot index for project `projectId`
     * on core contract `coreContract`.
     * If in a pre-auction state, reverts if unconfigured, otherwise returns
     * the minimum initial bid price for the upcoming auction.
     * If in an active auction, returns the minimum next bid's value and slot
     * index.
     * If in a post-auction state, reverts if auction was a sellout, otherwise
     * returns the auction's reserve price and slot index 0 (because tokens may
     * still be purchasable at the reserve price).
     * @param projectId Project ID to get the minimum next bid value for
     * @param coreContract Core contract address for the given project
     * @return minNextBidValueInWei minimum next bid value in Wei
     * @return minNextBidSlotIndex slot index of the minimum next bid
     */
    function getMinimumNextBid(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (uint256 minNextBidValueInWei, uint256 minNextBidSlotIndex)
    {
        // get minter state
        RAMLib.ProjectMinterStates projectMinterState = getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // handle pre-auction State A
        if (projectMinterState == RAMLib.ProjectMinterStates.PreAuction) {
            bool isConfigured = RAMProjectConfig_.timestampStart > 0;
            if (!isConfigured) {
                // if not configured, revert
                revert("auction not configured");
            }
            // if configured, min next bid is base price at slot 0
            minNextBidValueInWei = RAMProjectConfig_.basePrice;
            minNextBidSlotIndex = 0;
        } else {
            // values that apply to all live-auction and post-auction states
            bool isSellout = RAMProjectConfig_.numBids >=
                RAMProjectConfig_.numTokensInAuction;

            // handle live-auction State B
            if (projectMinterState == RAMLib.ProjectMinterStates.LiveAuction) {
                if (isSellout) {
                    // find next valid bid slot index and value
                    // @dev okay if we extend past the maximum slot index and value
                    // for this view function
                    (
                        minNextBidSlotIndex,
                        minNextBidValueInWei
                    ) = _findNextValidBidSlotIndexAndValue({
                        projectId: projectId,
                        coreContract: coreContract,
                        startSlotIndex: RAMProjectConfig_.minBidSlotIndex
                    });
                } else {
                    // not sellout, so min bid is base price
                    minNextBidValueInWei = RAMProjectConfig_.basePrice;
                    minNextBidSlotIndex = 0;
                }
            } else {
                // handle post-auction States C, D, E
                if (isSellout) {
                    // if sellout, revert
                    revert("auction ended, sellout");
                } else {
                    // not sellout, so return base price
                    minNextBidValueInWei = RAMProjectConfig_.basePrice;
                    minNextBidSlotIndex = 0;
                }
            }
        }
    }

    /**
     * @notice Gets the project minter state of project `projectId` on core
     * contract `coreContract`.
     * @param projectId Project ID to get the minimum next bid value for
     * @param coreContract Core contract address for the given project
     * @return ProjectMinterStates enum representing the minter state.
     */
    function getProjectMinterState(
        uint256 projectId,
        address coreContract
    ) internal view returns (ProjectMinterStates) {
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // State A: Pre-Auction
        // @dev load to memory for gas efficiency
        uint256 timestampStart = RAMProjectConfig_.timestampStart;
        // helper value(s) for readability
        bool auctionIsConfigured = timestampStart > 0;
        bool isPreAuction = block.timestamp < timestampStart;
        // confirm that auction is either not configured or is pre-auction
        if ((!auctionIsConfigured) || isPreAuction) {
            return ProjectMinterStates.PreAuction;
        }
        // State B: Live-Auction
        // @dev auction is configured due to previous State A return
        // helper value(s) for readability
        // @dev load to memory for gas efficiency
        uint256 timestampEnd = RAMProjectConfig_.timestampEnd;
        bool isPostAuction = block.timestamp > timestampEnd;
        // pre-auction is checked above
        if (!isPostAuction) {
            return ProjectMinterStates.LiveAuction;
        }
        // States C, D, E: Post-Auction
        // @dev auction is configured and post auction due to previous States A, B returns
        // all winners sent tokens means all bids have either been minted tokens or refunded if error state occurred
        bool allBidsHandled = RAMProjectConfig_.numBidsMintedTokens +
            RAMProjectConfig_.numBidsErrorRefunded ==
            RAMProjectConfig_.numBids;
        if (allBidsHandled) {
            // State E: Post-Auction, all bids handled
            return ProjectMinterStates.PostAuctionAllBidsHandled;
        }
        // @dev all bids are not handled due to previous State E return
        bool adminOnlyMintPeriod = RAMProjectConfig_
        // @dev if project is configured to have an admin-artist-only mint period
            .adminArtistOnlyMintPeriodIfSellout &&
            // @dev sellout if numBids >= numTokensInAuction
            RAMProjectConfig_.numBids >= RAMProjectConfig_.numTokensInAuction &&
            // @dev still in admin-artist-only mint period if current time < end time + admin-artist-only mint period
            block.timestamp <
            timestampEnd + ADMIN_ARTIST_ONLY_MINT_TIME_SECONDS;
        if (adminOnlyMintPeriod) {
            // State C: Post-Auction, sell out, not all bids handled, admin-artist-only mint period
            return ProjectMinterStates.PostAuctionSellOutAdminArtistMint;
        }
        // State D: Post-Auction, not all bids handled, post-admin-artist-only mint period
        // @dev states are mutually exclusive, so must be in final remaining state
        return ProjectMinterStates.PostAuctionOpenMint;
    }

    /**
     * @notice Returns if project minter is in ERROR state E1, and the number
     * of bids that need to be refunded to resolve the error. Also returns the
     * number of excess invocations available, if any, indicating Flag F1.
     * E1: Tokens owed > invocations available
     * Occurs when: tokens are minted on different minter after auction begins,
     * or when core contract max invocations are reduced after auction begins.
     * Resolution: Admin must refund the lowest bids after auction ends.
     * @param projectId Project Id to query
     * @param coreContract Core contract address to query
     * @return isError True if in error state, false otherwise
     * @return numBidsToRefund Number of bids to refund to resolve error, 0 if
     * not in error state
     * @return numExcessInvocationsAvailable Number of excess invocations
     * available. Value above 0 indicates Flag F1.
     */
    function isErrorE1FlagF1(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (
            bool isError,
            uint256 numBidsToRefund,
            uint256 numExcessInvocationsAvailable
        )
    {
        // get project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // E1: Tokens owed > invocations available
        uint256 tokensOwed = _getNumTokensOwed({
            RAMProjectConfig_: RAMProjectConfig_
        });
        uint256 invocationsAvailable = MaxInvocationsLib
            .getInvocationsAvailable({
                projectId: projectId,
                coreContract: coreContract
            });
        // populate return values
        isError = tokensOwed > invocationsAvailable;
        numBidsToRefund = isError ? tokensOwed - invocationsAvailable : 0;
        // no excess invocations available if in error state, otherwise is the
        // difference between invocations available and tokens owed
        numExcessInvocationsAvailable = isError
            ? 0
            : invocationsAvailable - tokensOwed;
    }

    /**
     * @notice Returns the MaxInvocationsProjectConfig for a given project and
     * core contract, properly accounting for the auction state, unminted bids,
     * core contract invocations, and minter max invocations when determining
     * maxHasBeenInvoked
     * @param projectId Project Id to get config for
     * @param coreContract Core contract address to get config for
     * @return maxInvocationsProjectConfig max invocations project configuration
     */
    function getMaxInvocationsProjectConfig(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (
            MaxInvocationsLib.MaxInvocationsProjectConfig
                memory maxInvocationsProjectConfig
        )
    {
        // get max invocations project config from MaxInvocationsLib
        maxInvocationsProjectConfig.maxInvocations = uint24(
            MaxInvocationsLib.getMaxInvocations({
                projectId: projectId,
                coreContract: coreContract
            })
        );
        maxInvocationsProjectConfig.maxHasBeenInvoked = getMaxHasBeenInvoked({
            projectId: projectId,
            coreContract: coreContract
        });
    }

    /**
     * @notice Returns if project has reached maximum number of invocations for
     * a given project and core contract, properly accounting for the auction
     * state, unminted bids, core contract invocations, and minter max
     * invocations when determining maxHasBeenInvoked
     * @param projectId Project Id to get config for
     * @param coreContract Core contract address to get config for
     * @return maxHasBeenInvoked bool indicating if max invocations have been invoked
     */
    function getMaxHasBeenInvoked(
        uint256 projectId,
        address coreContract
    ) internal view returns (bool maxHasBeenInvoked) {
        // calculate if max has been invoked based on auction state
        ProjectMinterStates projectMinterState = getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        if (projectMinterState == ProjectMinterStates.PreAuction) {
            // pre-auction, true if numTokensInAuction == 0
            RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
            if (RAMProjectConfig_.timestampStart > 0) {
                // if auction configured, look at num tokens in auction
                maxHasBeenInvoked = RAMProjectConfig_.numTokensInAuction == 0;
            } else {
                // if auction not configured, defer to max invocation lib
                maxHasBeenInvoked = MaxInvocationsLib.getMaxHasBeenInvoked({
                    projectId: projectId,
                    coreContract: coreContract
                });
            }
        } else if (projectMinterState == ProjectMinterStates.LiveAuction) {
            // live auction, set to true if num bids >= num tokens in auction
            RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
            maxHasBeenInvoked =
                RAMProjectConfig_.numBids >=
                RAMProjectConfig_.numTokensInAuction;
        } else {
            // post auction, set to true if remaining excess invocations is zero
            (, , uint256 numExcessInvocationsAvailable) = isErrorE1FlagF1({
                projectId: projectId,
                coreContract: coreContract
            });
            maxHasBeenInvoked = numExcessInvocationsAvailable == 0;
        }
    }

    /**
     * Returns balance of project `projectId` on core contract `coreContract`
     * on this minter contract.
     * @param projectId Project ID to get the balance for
     * @param coreContract Core contract address for the given project
     */
    function getProjectBalance(
        uint256 projectId,
        address coreContract
    ) internal view returns (uint256) {
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        return RAMProjectConfig_.projectBalance;
    }

    /**
     * Loads the RAMProjectConfig for a given project and core
     * contract.
     * @param projectId Project Id to get config for
     * @param coreContract Core contract address to get config for
     */
    function getRAMProjectConfig(
        uint256 projectId,
        address coreContract
    ) internal view returns (RAMProjectConfig storage) {
        return s().RAMProjectConfigs[coreContract][projectId];
    }

    /**
     * Loads the RAMAdminMintingConstraint for a given core contract.
     * @param coreContract Core contract address to get config for
     */
    function getRAMAdminMintingConstraintValue(
        address coreContract
    ) internal view returns (AdminMintingConstraint) {
        return s().RAMAdminMintingConstraint[coreContract];
    }

    /**
     * @notice private helper function to mint a token.
     * @dev assumes all checks have been performed
     * @param projectId project ID to mint token for
     * @param coreContract core contract address for the given project
     * @param bidId bid ID of bid to mint token for
     * @param bidder bidder address of bid to mint token for
     * @param minterFilter minter filter contract address
     */
    function _mintTokenForBid(
        uint256 projectId,
        address coreContract,
        uint32 bidId,
        address bidder,
        IMinterFilterV1 minterFilter
    ) private {
        // mint token
        uint256 tokenId = minterFilter.mint_joo({
            to: bidder,
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender
        });
        // emit event for state change
        emit BidMinted({
            projectId: projectId,
            coreContract: coreContract,
            bidId: bidId,
            tokenId: tokenId
        });
    }

    /**
     * @notice private helper function to mint and settle bid if not already settled.
     * Assumes check that bidder for bid `bidId` is not null
     * @param projectId Project ID to mint token on.
     * @param coreContract Core contract address for the given project.
     * @param projectPrice Price of a token for the given project.
     * @param slotIndex Slot index of bid.
     * @param bidId ID of bid to settle.
     * @param minterFilter Minter filter contract address
     * @param minterRefundGasLimit Gas limit to use when settling bid, prior to using fallback force-send to refund
     */
    function _mintAndSettle(
        uint256 projectId,
        address coreContract,
        uint256 projectPrice,
        uint256 slotIndex,
        uint256 bidId,
        IMinterFilterV1 minterFilter,
        uint256 minterRefundGasLimit
    ) private {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        Bid storage bid = RAMProjectConfig_.bids[bidId];
        // Mark bid as minted
        _setBidPackedBool({bid: bid, index: INDEX_IS_MINTED, value: true});

        // Mint token for bid
        _mintTokenForBid({
            projectId: projectId,
            coreContract: coreContract,
            bidId: uint32(bidId),
            bidder: bid.bidder,
            minterFilter: minterFilter
        });

        // Settle if not already settled
        // @dev collector could have previously settled bid, so need to
        // settle only if not already settled
        if (!(_getBidPackedBool(bid, INDEX_IS_SETTLED))) {
            _settleBid({
                RAMProjectConfig_: RAMProjectConfig_,
                projectId: projectId,
                coreContract: coreContract,
                projectPrice: projectPrice,
                slotIndex: slotIndex,
                bidId: uint32(bidId),
                minterRefundGasLimit: minterRefundGasLimit
            });
        }
    }

    /**
     * @notice Helper function to handle settling a bid.
     * Reverts if bidder is not the bid's bidder.
     * Reverts if bid has already been settled.
     * @param RAMProjectConfig_ RAMProjectConfig to update
     * @param projectId Project ID of bid to settle
     * @param coreContract Core contract address for the given project.
     * @param projectPrice Price of token on the project
     * @param bidId ID of bid to settle
     * @param bidder Bidder address of bid to settle
     * @param minterRefundGasLimit Gas limit to use when refunding the bidder.
     */
    function _settleBidWithChecks(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 projectId,
        address coreContract,
        uint256 projectPrice,
        uint32 bidId,
        address bidder,
        uint256 minterRefundGasLimit
    ) private {
        // CHECKS
        Bid storage bid = RAMProjectConfig_.bids[bidId];
        // require bidder is the bid's bidder
        require(bid.bidder == bidder, "Only bidder");
        // require bid is not yet settled
        require(
            !(_getBidPackedBool(bid, INDEX_IS_SETTLED)),
            "Only un-settled bid"
        );

        _settleBid({
            RAMProjectConfig_: RAMProjectConfig_,
            projectId: projectId,
            coreContract: coreContract,
            slotIndex: bid.slotIndex,
            bidId: bidId,
            projectPrice: projectPrice,
            minterRefundGasLimit: minterRefundGasLimit
        });
    }

    /**
     * @notice private helper function to handle settling a bid.
     * @dev assumes bid has not been previously settled, and that all other
     * checks have been performed.
     * @param RAMProjectConfig_ RAMProjectConfig to update
     * @param projectId Project ID of bid to settle
     * @param coreContract Core contract address for the given project.
     * @param slotIndex Slot index of bid to settle
     * @param bidId ID of bid to settle
     * @param projectPrice Price of token on the project
     * @param minterRefundGasLimit Gas limit to use when refunding the previous
     * highest bidder, prior to using fallback force-send to refund
     */
    function _settleBid(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 projectId,
        address coreContract,
        uint256 slotIndex,
        uint32 bidId,
        uint256 projectPrice,
        uint256 minterRefundGasLimit
    ) private {
        // @dev bid not passed as parameter to avoid stack too deep error in
        // functions that utilize this helper function
        Bid storage bid = RAMProjectConfig_.bids[bidId];
        // EFFECTS
        // update state
        _setBidPackedBool({bid: bid, index: INDEX_IS_SETTLED, value: true});
        // amount due = bid amount - project price
        uint256 amountDue = slotIndexToBidValue({
            basePrice: RAMProjectConfig_.basePrice,
            // @dev safe to cast to uint16
            slotIndex: uint16(slotIndex)
        }) - projectPrice;
        if (amountDue > 0) {
            // force-send settlement to bidder
            // @dev reverts on underflow
            RAMProjectConfig_.projectBalance -= uint120(amountDue);
            SplitFundsLib.forceSafeTransferETH({
                to: bid.bidder,
                amount: amountDue,
                minterRefundGasLimit: minterRefundGasLimit
            });
        }
        // emit event for state change
        emit BidSettled({
            projectId: projectId,
            coreContract: coreContract,
            bidId: bidId
        });
    }

    /**
     * @notice private helper function to settle and refund bids to resolve E1 error state.
     * Assumes check that bidder for bid `bidId` is not null
     * @param projectId Project ID to refund bid for.
     * @param coreContract Core contract address for the given project.
     * @param projectPrice Price of a token for the given project.
     * @param slotIndex Slot index of bid.
     * @param bidId ID of bid to settle.
     * @param minterRefundGasLimit Gas limit to use when refunding bidder
     */
    function _settleAndRefundBid(
        uint256 projectId,
        address coreContract,
        uint256 projectPrice,
        uint256 slotIndex,
        uint256 bidId,
        uint256 minterRefundGasLimit
    ) private {
        // load project config
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        // load bid
        Bid storage bid = RAMProjectConfig_.bids[bidId];
        // @dev bidderAddress previously checked not null
        address bidderAddress = bid.bidder;
        // Settle and refund the Bid
        // Minimum value to send is the project price
        uint256 valueToSend = projectPrice;
        bool didSettleBid = false;

        // if not isSettled, then settle the bid
        if (!_getBidPackedBool(bid, INDEX_IS_SETTLED)) {
            // mark bid as settled
            _setBidPackedBool({bid: bid, index: INDEX_IS_SETTLED, value: true});
            didSettleBid = true;
            // send entire bid value if not previously settled
            valueToSend = slotIndexToBidValue({
                basePrice: RAMProjectConfig_.basePrice,
                slotIndex: uint16(slotIndex)
            });
        }
        // mark bid as refunded
        _setBidPackedBool({bid: bid, index: INDEX_IS_REFUNDED, value: true});
        // INTERACTIONS
        // force-send refund to bidder
        // @dev reverts on underflow
        RAMProjectConfig_.projectBalance -= uint120(valueToSend);
        SplitFundsLib.forceSafeTransferETH({
            to: bidderAddress,
            amount: valueToSend,
            minterRefundGasLimit: minterRefundGasLimit
        });
        // emit event for state changes
        if (didSettleBid) {
            emit BidSettled({
                projectId: projectId,
                coreContract: coreContract,
                bidId: bidId
            });
        }
        emit BidRefunded({
            projectId: projectId,
            coreContract: coreContract,
            bidId: bidId
        });
    }

    /**
     * @notice Helper function to get the price of a token on a project.
     * @dev Assumes project is configured, has a base price, and generally
     * makes sense to get a price for.
     * @param RAMProjectConfig_ RAMProjectConfig to query
     */
    function _getProjectPrice(
        RAMProjectConfig storage RAMProjectConfig_
    ) private view returns (uint256 projectPrice) {
        bool wasSellout = RAMProjectConfig_.numBids >=
            RAMProjectConfig_.numTokensInAuction;
        // price is lowest bid if sellout, otherwise base price
        projectPrice = wasSellout
            ? slotIndexToBidValue({
                basePrice: RAMProjectConfig_.basePrice,
                slotIndex: RAMProjectConfig_.minBidSlotIndex
            })
            : RAMProjectConfig_.basePrice;
    }

    /**
     * @notice Helper function to get the number of tokens owed for a given
     * project.
     * @param RAMProjectConfig_ RAMProjectConfig to query
     * @return tokensOwed The number of bids in a project minus the sum of tokens already
     * minted and bids that have been refunded due to an error state.
     */
    function _getNumTokensOwed(
        RAMProjectConfig storage RAMProjectConfig_
    ) private view returns (uint256 tokensOwed) {
        tokensOwed =
            RAMProjectConfig_.numBids -
            (RAMProjectConfig_.numBidsMintedTokens +
                RAMProjectConfig_.numBidsErrorRefunded);
    }

    /**
     * @notice Inserts a bid into the project's RAMProjectConfig.
     * Assumes the bid is valid and may be inserted into the bucket-sort data
     * structure.
     * Creates a new bid if bidId is zero, otherwise moves an existing bid,
     * which is assumed to exist and be valid.
     * Emits BidCreated event if a new bid is created.
     * @dev assumes slot index is valid and < NUM_SLOTS
     * @param RAMProjectConfig_ RAM project config to insert bid into
     * @param projectId Project ID to insert bid for
     * @param coreContract Core contract address to insert bid for
     * @param slotIndex Slot index to insert bid at
     * @param bidder Bidder address
     * @param bidId Bid ID to insert, or zero if a new bid should be created
     */
    function _insertBid(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 projectId,
        address coreContract,
        uint16 slotIndex,
        address bidder,
        uint32 bidId
    ) private {
        // add the new Bid to tail of the slot's doubly linked list
        bool createNewBid = bidId == 0;
        if (createNewBid) {
            // prefix ++ to skip initial bid ID of zero (indicates null value)
            bidId = ++RAMProjectConfig_.nextBidId;
        }
        uint256 prevTailBidId = RAMProjectConfig_.tailBidIdBySlot[slotIndex];
        RAMProjectConfig_.bids[bidId] = Bid({
            prevBidId: uint32(prevTailBidId),
            nextBidId: 0, // null value at end of tail
            slotIndex: slotIndex,
            bidder: bidder,
            packedBools: 0 // all packed bools false
        });
        // update tail pointer to new bid
        RAMProjectConfig_.tailBidIdBySlot[slotIndex] = bidId;
        // update head pointer or next pointer of previous bid
        if (prevTailBidId == 0) {
            // first bid in slot, update head pointer
            RAMProjectConfig_.headBidIdBySlot[slotIndex] = bidId;
        } else {
            // update previous bid's next pointer
            RAMProjectConfig_.bids[prevTailBidId].nextBidId = bidId;
        }

        // update number of active bids
        RAMProjectConfig_.numBids++;
        // update metadata if first bid for this slot
        // @dev assumes minting has not yet started
        if (prevTailBidId == 0) {
            // set the slot in the bitmap
            _setBitmapSlot({
                RAMProjectConfig_: RAMProjectConfig_,
                slotIndex: slotIndex
            });
            // update bitmap metadata - reduce min bid index if necessary
            if (slotIndex < RAMProjectConfig_.minBidSlotIndex) {
                RAMProjectConfig_.minBidSlotIndex = slotIndex;
            }
            // update bitmap metadata - increase max bid index if necessary
            if (slotIndex > RAMProjectConfig_.maxBidSlotIndex) {
                RAMProjectConfig_.maxBidSlotIndex = slotIndex;
            }
        }

        if (createNewBid) {
            // emit state change event
            emit BidCreated({
                projectId: projectId,
                coreContract: coreContract,
                slotIndex: slotIndex,
                bidId: bidId,
                bidder: bidder
            });
        }
    }

    /**
     * @notice Remove minimum bid from the project's RAMProjectConfig.
     * Reverts if no bids exist in slot RAMProjectConfig_.minBidSlotIndex.
     * @param RAMProjectConfig_ RAM project config to remove bid from
     * @param projectId Project ID to remove bid from
     * @param coreContract Core contract address for the given project
     * @param minterRefundGasLimit Gas limit to use when refunding the previous
     * highest bidder, prior to using fallback force-send to refund
     * @return removedBidAmount The value of the removed bid, in Wei
     */
    function _removeMinBid(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 projectId,
        address coreContract,
        uint256 minterRefundGasLimit
    ) private returns (uint256 removedBidAmount) {
        // get the minimum bid slot and bid id
        uint16 removedSlotIndex = RAMProjectConfig_.minBidSlotIndex;
        uint256 removedBidId = RAMProjectConfig_.tailBidIdBySlot[
            removedSlotIndex
        ];
        // @dev no coverage on else branch because it is unreachable as used
        require(removedBidId > 0, "No bids");
        // record the previous min bidder
        Bid storage removedBid = RAMProjectConfig_.bids[removedBidId];
        address removedBidder = removedBid.bidder;
        // update the tail pointer of the slot's doubly linked list
        uint32 newTailBidId = removedBid.prevBidId;
        RAMProjectConfig_.tailBidIdBySlot[removedSlotIndex] = newTailBidId;

        RAMProjectConfig_.numBids--;
        // update metadata if no more active bids for this slot
        if (newTailBidId == 0) {
            // update the head pointer of the slot's doubly linked list
            RAMProjectConfig_.headBidIdBySlot[removedSlotIndex] = 0;

            // unset the slot in the bitmap
            // update minBidIndex, efficiently starting at minBidSlotIndex + 1
            _unsetBitmapSlot({
                RAMProjectConfig_: RAMProjectConfig_,
                slotIndex: removedSlotIndex
            });
            // @dev reverts if removedSlotIndex was the maximum slot 511,
            // preventing bids from being removed entirely from the last slot,
            // which is acceptable and non-impacting for this minter
            // @dev sets minBidSlotIndex to 512 if no more active bids, which
            // is desired behavior for this minter
            RAMProjectConfig_.minBidSlotIndex = _getMinSlotWithBid({
                RAMProjectConfig_: RAMProjectConfig_,
                startSlotIndex: removedSlotIndex + 1
            });
        } else {
            // if the removed bid was not the head, then unset the nextBidId pointer of the bid
            Bid storage newTailBid = RAMProjectConfig_.bids[newTailBidId];
            newTailBid.nextBidId = 0;
        }
        // refund the removed bidder
        removedBidAmount = slotIndexToBidValue({
            basePrice: RAMProjectConfig_.basePrice,
            slotIndex: removedSlotIndex
        });
        // @dev reverts on underflow
        RAMProjectConfig_.projectBalance -= uint120(removedBidAmount);

        // delete the removed bid to prevent future claiming
        // @dev performed last to avoid pointing to deleted bid struct
        delete RAMProjectConfig_.bids[removedBidId];

        SplitFundsLib.forceSafeTransferETH({
            to: removedBidder,
            amount: removedBidAmount,
            minterRefundGasLimit: minterRefundGasLimit
        });
        // emit state change event
        emit BidRemoved({
            projectId: projectId,
            coreContract: coreContract,
            bidId: removedBidId
        });
    }

    /**
     * @notice Ejects a bid from the project's RAMProjectConfig.
     * Assumes the bid is valid (i.e. bid ID is a valid, active bid).
     * Does not refund the bidder, does not emit events, does not delete Bid.
     * @param RAMProjectConfig_ RAM project config to eject bid from
     * @param slotIndex Slot index to eject bid from
     * @param bidId ID of bid to eject
     */
    function _ejectBidFromSlot(
        RAMProjectConfig storage RAMProjectConfig_,
        uint16 slotIndex,
        uint256 bidId
    ) private {
        // get the bid to remove
        Bid storage removedBid = RAMProjectConfig_.bids[bidId];
        uint32 prevBidId = removedBid.prevBidId;
        uint32 nextBidId = removedBid.nextBidId;
        // update previous bid's next pointer
        if (prevBidId == 0) {
            // removed bid was the head bid
            RAMProjectConfig_.headBidIdBySlot[slotIndex] = nextBidId;
        } else {
            // removed bid was not the head bid
            RAMProjectConfig_.bids[prevBidId].nextBidId = nextBidId;
        }
        // update next bid's previous pointer
        if (nextBidId == 0) {
            // removed bid was the tail bid
            RAMProjectConfig_.tailBidIdBySlot[slotIndex] = prevBidId;
        } else {
            // removed bid was not the tail bid
            RAMProjectConfig_.bids[nextBidId].prevBidId = prevBidId;
        }

        // decrement the number of active bids
        RAMProjectConfig_.numBids--;

        // update metadata if no more active bids for this slot
        if (prevBidId == 0 && nextBidId == 0) {
            // unset the slot in the bitmap
            // update minBidIndex, efficiently starting at minBidSlotIndex + 1
            _unsetBitmapSlot({
                RAMProjectConfig_: RAMProjectConfig_,
                slotIndex: slotIndex
            });
            // @dev reverts if removedSlotIndex was the maximum slot 511,
            // preventing bids from being removed entirely from the last slot,
            // which is acceptable and non-impacting for this minter
            // @dev sets minBidSlotIndex to 512 if no more active bids, which
            // is desired behavior for this minter
            if (RAMProjectConfig_.minBidSlotIndex == slotIndex) {
                RAMProjectConfig_.minBidSlotIndex = _getMinSlotWithBid({
                    RAMProjectConfig_: RAMProjectConfig_,
                    startSlotIndex: slotIndex + 1
                });
            }
        }

        // @dev do not refund, do not emit event, do not delete bid
    }

    /**
     * @notice Helper function to handle setting slot in 512-bit bitmap
     * Reverts if slotIndex > 511
     * @param slotIndex Index of slot to set (between 0 and 511)
     * @param RAMProjectConfig_ RAMProjectConfig to update
     */
    function _setBitmapSlot(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 slotIndex
    ) private {
        // revert if slotIndex >= NUM_SLOTS, since this is an invalid input
        // @dev no coverage as slot index out of range checked in placeBid and implicitly in topUpBid
        require(slotIndex < NUM_SLOTS, "Only slot index lt NUM_SLOTS");
        // set the slot in the bitmap
        if (slotIndex < 256) {
            // @dev <256 conditional ensures no overflow when casting to uint8
            RAMProjectConfig_.slotsBitmapA = RAMProjectConfig_.slotsBitmapA.set(
                uint8(slotIndex)
            );
        } else {
            // @dev <512 results in no overflow when casting to uint8
            RAMProjectConfig_.slotsBitmapB = RAMProjectConfig_.slotsBitmapB.set(
                // @dev casting to uint8 intentional overflow instead of
                // subtracting 256 from slotIndex
                uint8(slotIndex)
            );
        }
    }

    /**
     * @notice Helper function to handle unsetting slot in 512-bit bitmap
     * Reverts if slotIndex > 511
     * @param slotIndex Index of slot to set (between 0 and 511)
     * @param RAMProjectConfig_ RAMProjectConfig to update
     */
    function _unsetBitmapSlot(
        RAMProjectConfig storage RAMProjectConfig_,
        uint256 slotIndex
    ) private {
        // revert if slotIndex >= NUM_SLOTS, since this is an invalid input
        // @dev no coverage as slot index out of range checked in placeBid and implicitly in topUpBid
        require(slotIndex < NUM_SLOTS, "Only slot index lt NUM_SLOTS");
        // unset the slot in the bitmap
        if (slotIndex < 256) {
            // @dev <256 conditional ensures no overflow when casting to uint8
            RAMProjectConfig_.slotsBitmapA = RAMProjectConfig_
                .slotsBitmapA
                .unset(uint8(slotIndex));
        } else {
            // @dev <512 results in no overflow when casting to uint8
            RAMProjectConfig_.slotsBitmapB = RAMProjectConfig_
                .slotsBitmapB
                .unset(
                    // @dev casting to uint8 intentional overflow instead of
                    // subtracting 256 from slotIndex
                    uint8(slotIndex)
                );
        }
    }

    /**
     * @notice Helper function to set a packed boolean in a Bid struct.
     * @param bid Bid to update
     * @param index Index of packed boolean to update
     * @param value Value to set packed boolean to
     */
    function _setBidPackedBool(
        Bid storage bid,
        uint8 index,
        bool value
    ) private {
        // @dev no coverage on else branch because it is unreachable as used
        if (value) {
            bid.packedBools = uint8(
                uint256(bid.packedBools).setBoolTrue(index)
            );
        } else {
            bid.packedBools = uint8(
                uint256(bid.packedBools).setBoolFalse(index)
            );
        }
    }

    /**
     * @notice Helper function to get a packed boolean from a Bid struct.
     * @param bid Bid to query
     * @param index Index of packed boolean to query
     * @return Value of packed boolean
     */
    function _getBidPackedBool(
        Bid storage bid,
        uint8 index
    ) private view returns (bool) {
        return uint256(bid.packedBools).getBool(index);
    }

    /**
     * @notice Helper function to get minimum slot index with an active bid,
     * starting at a given slot index and searching upwards.
     * Returns 512, (invalid slot index) if no slots with bids were found.
     * Reverts if startSlotIndex > 511, since this library only supports 512
     * slots.
     * @param RAMProjectConfig_ RAM project config to query
     * @param startSlotIndex Slot index to start search at
     * @return minSlotWithBid Minimum slot index with an active bid, or 512 (invalid index) if
     * no slots with bids were found.
     */
    function _getMinSlotWithBid(
        RAMProjectConfig storage RAMProjectConfig_,
        uint16 startSlotIndex
    ) private view returns (uint16 minSlotWithBid) {
        bool foundSlotWithBid;
        // revert if startSlotIndex > 511, since this is an invalid input
        // @dev no coverage on if branch because unreachable as used
        if (startSlotIndex > 511) {
            revert("Only start slot index lt 512");
        }
        // temporary uint256 in working memory
        uint256 minSlotWithBid_;
        // start at startSlotIndex
        if (startSlotIndex > 255) {
            // @dev <512 check results in no overflow when casting to uint8
            (minSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                .slotsBitmapB
                .minBitSet(
                    // @dev casting to uint8 intentional overflow instead of
                    // subtracting 256 from slotIndex
                    uint8(startSlotIndex)
                );
            // add 256 to account for slotsBitmapB offset
            minSlotWithBid_ += 256;
        } else {
            // @dev <256 conditional ensures no overflow when casting to uint8
            (minSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                .slotsBitmapA
                .minBitSet(uint8(startSlotIndex));

            // if no bids in first bitmap, check second bitmap
            // @dev behavior of library's minBitSet is to return 256 if no bits
            // were set
            if (!foundSlotWithBid) {
                // @dev <512 check results in no overflow when casting to uint8
                (minSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                    .slotsBitmapB
                    .minBitSet(
                        // start at beginning of second bitmap
                        uint8(0)
                    );
                // add 256 to account for slotsBitmapB offset
                minSlotWithBid_ += 256;
            }
        }
        // populate return value
        if (!foundSlotWithBid) {
            return uint16(NUM_SLOTS);
        } else {
            minSlotWithBid = uint16(minSlotWithBid_);
            return minSlotWithBid;
        }
    }

    /**
     * @notice Helper function to get maximum slot index with an active bid,
     * starting at a given slot index and searching downwards.
     * Returns 512, (invalid slot index) if no slots with bids were found.
     * Reverts if startSlotIndex > 511, since this library only supports 512
     * slots.
     * @param RAMProjectConfig_ RAM project config to query
     * @param startSlotIndex Slot index to start search at
     * @return maxSlotWithBid Maximum slot index with an active bid, and 512 (invalid index) if
     * no slots with bids were found.
     */
    function _getMaxSlotWithBid(
        RAMProjectConfig storage RAMProjectConfig_,
        uint16 startSlotIndex
    ) private view returns (uint16 maxSlotWithBid) {
        bool foundSlotWithBid;
        // revert if startSlotIndex > 511, since this is an invalid input
        // @dev no coverage on if branch because unreachable as used
        if (startSlotIndex > 511) {
            revert("Only start slot index lt 512");
        }
        // temporary uint256 in working memory
        uint256 maxSlotWithBid_;
        // start at startSlotIndex
        if (startSlotIndex < 256) {
            // @dev <256 conditional ensures no overflow when casting to uint8
            (maxSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                .slotsBitmapA
                .maxBitSet(uint8(startSlotIndex));
        } else {
            // need to potentially check both bitmaps
            (maxSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                .slotsBitmapB
                .maxBitSet(
                    // @dev casting to uint8 intentional overflow instead of
                    // subtracting 256 from slotIndex
                    uint8(startSlotIndex)
                );
            // add 256 to account for slotsBitmapB offset
            maxSlotWithBid_ += 256;
            if (!foundSlotWithBid) {
                // no bids in first bitmap B, so check second bitmap A
                (maxSlotWithBid_, foundSlotWithBid) = RAMProjectConfig_
                    .slotsBitmapA
                    .maxBitSet(
                        // start at the end of the first bitmap
                        uint8(255)
                    );
            }
        }
        // populate return value
        // @dev no coverage on if branch because it is unreachable as used
        if (!foundSlotWithBid) {
            return uint16(NUM_SLOTS);
        } else {
            maxSlotWithBid = uint16(maxSlotWithBid_);
            return maxSlotWithBid;
        }
    }

    /**
     * @notice Returns the next valid bid slot index and value for a given project.
     * @dev this may return slot index and value higher than the maximum slot index and value
     * allowed by the minter, in which case a bid cannot actually be placed
     * to outbid a bid at `startSlotIndex`.
     * @param projectId Project ID to find next valid bid slot index for
     * @param coreContract Core contract address for the given project
     * @param startSlotIndex Slot index to start search from
     * @return nextValidBidSlotIndex Next valid bid slot index
     * @return nextValidBidValue Next valid bid value at nextValidBidSlotIndex slot index, in Wei
     */
    function _findNextValidBidSlotIndexAndValue(
        uint256 projectId,
        address coreContract,
        uint16 startSlotIndex
    )
        private
        view
        returns (uint16 nextValidBidSlotIndex, uint256 nextValidBidValue)
    {
        RAMProjectConfig storage RAMProjectConfig_ = getRAMProjectConfig({
            projectId: projectId,
            coreContract: coreContract
        });
        uint88 basePrice = RAMProjectConfig_.basePrice;
        uint256 startBidValue = slotIndexToBidValue({
            basePrice: basePrice,
            slotIndex: startSlotIndex
        });
        // start search at next slot, incremented in while loop
        uint16 currentSlotIndex = startSlotIndex;
        while (true) {
            // increment slot index and re-calc current slot bid value
            unchecked {
                currentSlotIndex++;
            }
            nextValidBidValue = slotIndexToBidValue({
                basePrice: basePrice,
                slotIndex: currentSlotIndex
            });
            // break if current slot's bid value is sufficiently greater than
            // the starting slot's bid value
            if (
                _isSufficientOutbid({
                    oldBidValue: startBidValue,
                    newBidValue: nextValidBidValue
                })
            ) {
                break;
            }
            // otherwise continue to next iteration
        }
        // return the found valid slot index
        nextValidBidSlotIndex = currentSlotIndex;
    }

    /**
     * @notice Returns a bool indicating if a new bid value is sufficiently
     * greater than an old bid value, to replace the old bid value.
     * @param oldBidValue Old bid value to compare
     * @param newBidValue New bid value to compare
     * @return isSufficientOutbid True if new bid is sufficiently greater than
     * old bid, false otherwise
     */
    function _isSufficientOutbid(
        uint256 oldBidValue,
        uint256 newBidValue
    ) private pure returns (bool) {
        if (oldBidValue > 0.5 ether) {
            // require new bid is at least 2.5% greater than removed minimum bid
            return newBidValue > (oldBidValue * 10250) / 10000;
        }
        // require new bid is at least 5% greater than removed minimum bid
        return newBidValue > (oldBidValue * 10500) / 10000;
    }

    /**
     * @notice Returns the value of a bid in a given slot, in Wei.
     * @dev returns 0 if base price is zero
     * @param basePrice Base price (or reserve price) of the auction, in Wei
     * @param slotIndex Slot index to query
     * @return slotBidValue Value of a bid in the slot, in Wei
     */
    function slotIndexToBidValue(
        uint88 basePrice,
        uint16 slotIndex
    ) internal pure returns (uint256 slotBidValue) {
        // @dev for overflow safety, always revert if slotIndex >= NUM_SLOTS
        require(slotIndex < NUM_SLOTS, "Only slot index lt NUM_SLOTS");
        // use pseud-exponential pricing curve
        // multiply by two (via bit-shifting) for the number of entire
        // slots-per-price-double associated with the slot index
        // @dev overflow not possible due to typing, constants, and check above
        // (max(uint88) << (512 / 64)) < max(uint256)
        slotBidValue =
            uint256(basePrice) <<
            (slotIndex / SLOTS_PER_PRICE_DOUBLE);
        // perform a linear interpolation between partial half-life points, to
        // approximate the current place on a perfect exponential curve.
        // @dev overflow automatically checked in solidity 0.8, not expected
        slotBidValue +=
            (slotBidValue * (slotIndex % SLOTS_PER_PRICE_DOUBLE)) /
            SLOTS_PER_PRICE_DOUBLE;
    }

    /**
     * @notice Return the storage struct for reading and writing. This library
     * uses a diamond storage pattern when managing storage.
     * @return storageStruct The RAMLibStorage struct.
     */
    function s() private pure returns (RAMLibStorage storage storageStruct) {
        bytes32 position = RAM_LIB_STORAGE_POSITION;
        assembly ("memory-safe") {
            storageStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

pragma solidity ^0.8.0;

import {IMinterBaseV0} from "../../../interfaces/v0.8.x/IMinterBaseV0.sol";
import {IGenArt721CoreContractV3_Base} from "../../../interfaces/v0.8.x/IGenArt721CoreContractV3_Base.sol";
import {IGenArt721CoreContractV3} from "../../../interfaces/v0.8.x/IGenArt721CoreContractV3.sol";
import {IGenArt721CoreContractV3_Engine} from "../../../interfaces/v0.8.x/IGenArt721CoreContractV3_Engine.sol";

import {IERC20} from "@openzeppelin-4.7/contracts/token/ERC20/IERC20.sol";

/**
 * @title Art Blocks Split Funds Library
 * @notice This library is designed for the Art Blocks platform. It splits
 * Ether (ETH) and ERC20 token funds among stakeholders, such as sender
 * (if refund is applicable), providers, artists, and artists' additional
 * payees.
 * @author Art Blocks Inc.
 */

library SplitFundsLib {
    /**
     * @notice Currency updated for project `projectId` to symbol
     * `currencySymbol` and address `currencyAddress`.
     * @param projectId Project ID currency was updated for
     * @param coreContract Core contract address currency was updated for
     * @param currencyAddress Currency address
     * @param currencySymbol Currency symbol
     */
    event ProjectCurrencyInfoUpdated(
        uint256 indexed projectId,
        address indexed coreContract,
        address indexed currencyAddress,
        string currencySymbol
    );

    // position of Split Funds Lib storage, using a diamond storage pattern
    // for this library
    bytes32 constant SPLIT_FUNDS_LIB_STORAGE_POSITION =
        keccak256("splitfundslib.storage");

    // contract-level variables
    struct IsEngineCache {
        bool isEngine;
        bool isCached;
    }

    // project-level variables
    struct SplitFundsProjectConfig {
        address currencyAddress; // address(0) if ETH
        string currencySymbol; // Assumed to be ETH if null
    }

    // Diamond storage pattern is used in this library
    struct SplitFundsLibStorage {
        mapping(address coreContract => mapping(uint256 projectId => SplitFundsProjectConfig)) splitFundsProjectConfigs;
        mapping(address coreContract => IsEngineCache) isEngineCacheConfigs;
    }

    /**
     * @notice splits ETH funds between sender (if refund), providers,
     * artist, and artist's additional payee for a token purchased on
     * project `projectId`.
     * WARNING: This function uses msg.value and msg.sender to determine
     * refund amounts, and therefore may not be applicable to all use cases
     * (e.g. do not use with Dutch Auctions with on-chain settlement).
     * @dev This function relies on msg.sender and msg.value, so it must be
     * called directly from the contract that is receiving the payment.
     * @dev possible DoS during splits is acknowledged, and mitigated by
     * business practices, including end-to-end testing on mainnet, and
     * admin-accepted artist payment addresses.
     * @param projectId Project ID for which funds shall be split.
     * @param pricePerTokenInWei Current price of token, in Wei.
     * @param coreContract Address of the GenArt721CoreContract associated
     * with the project.
     */
    function splitFundsETHRefundSender(
        uint256 projectId,
        uint256 pricePerTokenInWei,
        address coreContract
    ) internal {
        if (msg.value > 0) {
            // send refund to sender
            uint256 refund = msg.value - pricePerTokenInWei;
            if (refund > 0) {
                (bool success_, ) = msg.sender.call{value: refund}("");
                require(success_, "Refund failed");
            }
            // split revenues
            splitRevenuesETHNoRefund({
                projectId: projectId,
                valueInWei: pricePerTokenInWei,
                coreContract: coreContract
            });
        }
    }

    /**
     * @notice pays ETH funds to sender (if refund), with all of token price
     * being sent to the render provider for a token purchased on project
     * `projectId`.
     * WARNING: This function uses msg.value and msg.sender to determine
     * refund amounts, and therefore may not be applicable to all use cases
     * (e.g. do not use with Dutch Auctions with on-chain settlement).
     * @dev This function relies on msg.sender and msg.value, so it must be
     * called directly from the contract that is receiving the payment.
     * @dev possible DoS during splits is acknowledged, and mitigated by
     * business practices, including end-to-end testing on mainnet, and
     * admin-accepted artist payment addresses.
     * @param projectId Project ID for which funds shall be split.
     * @param pricePerTokenInWei Current price of token, in Wei.
     * @param coreContract Address of the GenArt721CoreContract associated
     * with the project.
     */
    function sendAllToRenderProviderETHRefundSender(
        uint256 projectId,
        uint256 pricePerTokenInWei,
        address coreContract
    ) internal {
        if (msg.value > 0) {
            // send refund to sender
            uint256 refund = msg.value - pricePerTokenInWei;
            if (refund > 0) {
                (bool success_, ) = msg.sender.call{value: refund}("");
                require(success_, "Refund failed");
            }
            // send remaining to render provider
            sendAllToRenderProviderETHNoRefund({
                projectId: projectId,
                valueInWei: pricePerTokenInWei,
                coreContract: coreContract
            });
        }
    }

    /**
     * @notice Splits ETH revenues between providers, artist, and artist's
     * additional payee for revenue generated by project `projectId`.
     * This function does NOT refund msg.sender, and does NOT use msg.value
     * when determining the value to be split.
     * @dev possible DoS during splits is acknowledged, and mitigated by
     * business practices, including end-to-end testing on mainnet, and
     * admin-accepted artist payment addresses.
     * @param projectId Project ID for which funds shall be split.
     * @param valueInWei Value to be split, in Wei.
     * @param coreContract Address of the GenArt721CoreContract
     * associated with the project.
     */
    function splitRevenuesETHNoRefund(
        uint256 projectId,
        uint256 valueInWei,
        address coreContract
    ) internal {
        if (valueInWei == 0) {
            return; // return early
        }
        // split funds between platforms, artist, and artist's
        // additional payee
        bool isEngine_ = isEngine(coreContract);
        uint256 renderProviderRevenue;
        address payable renderProviderAddress;
        uint256 platformProviderRevenue;
        address payable platformProviderAddress;
        uint256 artistRevenue;
        address payable artistAddress;
        uint256 additionalPayeePrimaryRevenue;
        address payable additionalPayeePrimaryAddress;
        if (isEngine_) {
            // get engine splits
            (
                renderProviderRevenue,
                renderProviderAddress,
                platformProviderRevenue,
                platformProviderAddress,
                artistRevenue,
                artistAddress,
                additionalPayeePrimaryRevenue,
                additionalPayeePrimaryAddress
            ) = IGenArt721CoreContractV3_Engine(coreContract)
                .getPrimaryRevenueSplits({
                    _projectId: projectId,
                    _price: valueInWei
                });
        } else {
            // get flagship splits
            // @dev note that platformProviderAddress and
            // platformProviderRevenue remain 0 for flagship
            (
                renderProviderRevenue, // artblocks revenue
                renderProviderAddress, // artblocks address
                artistRevenue,
                artistAddress,
                additionalPayeePrimaryRevenue,
                additionalPayeePrimaryAddress
            ) = IGenArt721CoreContractV3(coreContract).getPrimaryRevenueSplits({
                _projectId: projectId,
                _price: valueInWei
            });
        }
        // require total revenue split is 100%
        // @dev note that platformProviderRevenue remains 0 for flagship
        require(
            renderProviderRevenue +
                platformProviderRevenue +
                artistRevenue +
                additionalPayeePrimaryRevenue ==
                valueInWei,
            "Invalid revenue split totals"
        );
        // distribute revenues
        // @dev note that platformProviderAddress and platformProviderRevenue
        // remain 0 for flagship
        _sendPaymentsETH({
            platformProviderRevenue: platformProviderRevenue,
            platformProviderAddress: platformProviderAddress,
            renderProviderRevenue: renderProviderRevenue,
            renderProviderAddress: renderProviderAddress,
            artistRevenue: artistRevenue,
            artistAddress: artistAddress,
            additionalPayeePrimaryRevenue: additionalPayeePrimaryRevenue,
            additionalPayeePrimaryAddress: additionalPayeePrimaryAddress
        });
    }

    /**
     * @notice Sends all revenue generated by project `projectId` to render
     * provider.
     * This function does NOT refund msg.sender, and does NOT use msg.value
     * when determining the value to be split.
     * @dev possible DoS during splits is acknowledged, and mitigated by
     * business practices, including end-to-end testing on mainnet, and
     * admin-accepted payment addresses.
     * @param projectId Project ID for which funds shall be sent.
     * @param valueInWei Value to be sent, in Wei.
     * @param coreContract Address of the GenArt721CoreContract
     * associated with the project.
     */
    function sendAllToRenderProviderETHNoRefund(
        uint256 projectId,
        uint256 valueInWei,
        address coreContract
    ) internal {
        if (valueInWei == 0) {
            return; // return early
        }
        // split funds between platforms, artist, and artist's
        // additional payee
        bool isEngine_ = isEngine(coreContract);
        address payable renderProviderAddress;
        if (isEngine_) {
            // get engine splits
            (
                ,
                renderProviderAddress,
                ,
                ,
                ,
                ,
                ,

            ) = IGenArt721CoreContractV3_Engine(coreContract)
                .getPrimaryRevenueSplits({
                    _projectId: projectId,
                    _price: valueInWei
                });
        } else {
            // get flagship splits
            // @dev note that platformProviderAddress and
            // platformProviderRevenue remain 0 for flagship
            (
                ,
                // artblocks revenue
                renderProviderAddress, // artblocks address
                ,
                ,
                ,

            ) = IGenArt721CoreContractV3(coreContract).getPrimaryRevenueSplits({
                _projectId: projectId,
                _price: valueInWei
            });
        }
        require(
            renderProviderAddress != address(0),
            "Render Provider address not set"
        );
        // distribute revenue
        // Render Provider / Art Blocks payment
        // @dev previous conditional ensures valueInWei is non-zero
        (bool success, ) = renderProviderAddress.call{value: valueInWei}("");
        require(success, "Render Provider payment failed");
    }

    /**
     * @notice Splits ERC20 funds between providers, artist, and artist's
     * additional payee, for a token purchased on project `projectId`.
     * The function performs checks to ensure that the ERC20 token is
     * approved for transfer, and that a non-zero ERC20 token address is
     * configured.
     * @dev This function relies on msg.sender, so it must be
     * called directly from the contract that is receiving the payment.
     * @dev possible DoS during splits is acknowledged, and mitigated by
     * business practices, including end-to-end testing on mainnet, and
     * admin-accepted artist payment addresses.
     * @param projectId Project ID for which funds shall be split.
     * @param pricePerToken Current price of token, in base units. For example,
     * if the ERC20 token has 6 decimals, an input value of `1_000_000` would
     * represent a price of `1.000000` tokens.
     * @param coreContract Core contract address.
     */
    function splitFundsERC20(
        uint256 projectId,
        uint256 pricePerToken,
        address coreContract
    ) internal {
        if (pricePerToken == 0) {
            return; // nothing to split, return early
        }
        IERC20 projectCurrency;
        // block scope to avoid stack too deep error
        {
            SplitFundsProjectConfig
                storage splitFundsProjectConfig = getSplitFundsProjectConfig({
                    projectId: projectId,
                    coreContract: coreContract
                });
            address currencyAddress = splitFundsProjectConfig.currencyAddress;
            require(
                currencyAddress != address(0),
                "ERC20: payment not configured"
            );
            // ERC20 token is used for payment
            validateERC20Approvals({
                msgSender: msg.sender,
                currencyAddress: currencyAddress,
                pricePerToken: pricePerToken
            });
            projectCurrency = IERC20(currencyAddress);
        }
        // split remaining funds between foundation, artist, and artist's additional payee
        bool isEngine_ = isEngine(coreContract);
        uint256 renderProviderRevenue;
        address payable renderProviderAddress;
        uint256 platformProviderRevenue;
        address payable platformProviderAddress;
        uint256 artistRevenue;
        address payable artistAddress;
        uint256 additionalPayeePrimaryRevenue;
        address payable additionalPayeePrimaryAddress;
        if (isEngine_) {
            // get engine splits
            (
                renderProviderRevenue,
                renderProviderAddress,
                platformProviderRevenue,
                platformProviderAddress,
                artistRevenue,
                artistAddress,
                additionalPayeePrimaryRevenue,
                additionalPayeePrimaryAddress
            ) = IGenArt721CoreContractV3_Engine(coreContract)
                .getPrimaryRevenueSplits({
                    _projectId: projectId,
                    _price: pricePerToken
                });
        } else {
            // get flagship splits
            // @dev note that platformProviderAddress and
            // platformProviderRevenue remain 0 for flagship
            (
                renderProviderRevenue, // artblocks revenue
                renderProviderAddress, // artblocks address
                artistRevenue,
                artistAddress,
                additionalPayeePrimaryRevenue,
                additionalPayeePrimaryAddress
            ) = IGenArt721CoreContractV3(coreContract).getPrimaryRevenueSplits({
                _projectId: projectId,
                _price: pricePerToken
            });
        }
        // require total revenue split is 100%
        // @dev note that platformProviderRevenue remains 0 for flagship
        require(
            renderProviderRevenue +
                platformProviderRevenue +
                artistRevenue +
                additionalPayeePrimaryRevenue ==
                pricePerToken,
            "Invalid revenue split totals"
        );
        // distribute revenues
        // @dev note that platformProviderAddress and platformProviderRevenue
        // remain 0 for flagship
        _sendPaymentsERC20({
            projectCurrency: projectCurrency,
            platformProviderRevenue: platformProviderRevenue,
            platformProviderAddress: platformProviderAddress,
            renderProviderRevenue: renderProviderRevenue,
            renderProviderAddress: renderProviderAddress,
            artistRevenue: artistRevenue,
            artistAddress: artistAddress,
            additionalPayeePrimaryRevenue: additionalPayeePrimaryRevenue,
            additionalPayeePrimaryAddress: additionalPayeePrimaryAddress
        });
    }

    /**
     * @notice Updates payment currency of the referenced
     * SplitFundsProjectConfig to be `currencySymbol` at address
     * `currencyAddress`.
     * Only supports setting currency info of ERC20 tokens.
     * Returns bool that is true if the price should be reset after this
     * update. Price is recommended to be reset if the currency address was
     * previously configured, but is now being updated to a different currency
     * address. This is to protect accidental price reductions when changing
     * currency if an artist is changing currencies in an unpaused state.
     * @dev artist-defined currency symbol is used instead of any on-chain
     * currency symbol.
     * @param projectId Project ID to update.
     * @param coreContract Core contract address.
     * @param currencySymbol Currency symbol.
     * @param currencyAddress Currency address.
     * @return recommendPriceReset True if the price should be reset after this
     * update.
     */
    function updateProjectCurrencyInfoERC20(
        uint256 projectId,
        address coreContract,
        string memory currencySymbol,
        address currencyAddress
    ) internal returns (bool recommendPriceReset) {
        // CHECKS
        require(currencyAddress != address(0), "null address, only ERC20");
        require(bytes(currencySymbol).length > 0, "only non-null symbol");
        // EFFECTS
        SplitFundsProjectConfig
            storage splitFundsProjectConfig = getSplitFundsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        // recommend price reset if currency address was previously configured
        recommendPriceReset = (splitFundsProjectConfig.currencyAddress !=
            address(0));
        splitFundsProjectConfig.currencySymbol = currencySymbol;
        splitFundsProjectConfig.currencyAddress = currencyAddress;

        emit ProjectCurrencyInfoUpdated({
            projectId: projectId,
            coreContract: coreContract,
            currencyAddress: currencyAddress,
            currencySymbol: currencySymbol
        });
    }

    /**
     * @notice Force sends `amount` (in wei) ETH to `to`, with a gas stipend
     * equal to `minterRefundGasLimit`.
     * If sending via the normal procedure fails, force sends the ETH by
     * creating a temporary contract which uses `SELFDESTRUCT` to force send
     * the ETH.
     * Reverts if the current contract has insufficient balance.
     * @param to The address to send ETH to.
     * @param amount The amount of ETH to send.
     * @param minterRefundGasLimit The gas limit to use when sending ETH, prior
     * to fallback.
     * @dev This function is adapted from the `forceSafeTransferETH` function
     * in the `https://github.com/Vectorized/solady` repository, with
     * modifications to not check if the current contract has sufficient
     * balance. Therefore, the contract should be checked for sufficient
     * balance before calling this function in the minter itself, if
     * applicable.
     */
    function forceSafeTransferETH(
        address to,
        uint256 amount,
        uint256 minterRefundGasLimit
    ) internal {
        // Manually inlined because the compiler doesn't inline functions with
        // branches.
        /// @solidity memory-safe-assembly
        assembly {
            // @dev intentionally do not check if this contract has sufficient
            // balance, because that is not intended to be a valid state.

            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(minterRefundGasLimit, to, amount, 0, 0, 0, 0)) {
                // if the transfer failed, we create a temporary contract with
                // initialization code that uses `SELFDESTRUCT` to force send
                // the ETH.
                // note: Compatible with `SENDALL`:
                // https://eips.ethereum.org/EIPS/eip-4758

                //---------------------------------------------------------------------------------------------------------------//
                // Opcode  | Opcode + Arguments  | Description        | Stack View                                               //
                //---------------------------------------------------------------------------------------------------------------//
                // Contract creation code that uses `SELFDESTRUCT` to force send ETH to a specified address.                     //
                // Creation code summary: 0x73<20-byte toAddress>0xff                                                            //
                //---------------------------------------------------------------------------------------------------------------//
                // 0x73    |  0x73_toAddress     | PUSH20 toAddress   | toAddress                                                //
                // 0xFF    |  0xFF               | SELFDESTRUCT       |                                                          //
                //---------------------------------------------------------------------------------------------------------------//
                // Store the address in scratch space, starting at 0x00, which begins the 20-byte address at 32-20=12 in memory
                // @dev use scratch space because we have enough space for simple creation code (less than 0x40 bytes)
                mstore(0x00, to)
                // store opcode PUSH20 immediately before the address, starting at 0x0b (11) in memory
                mstore8(0x0b, 0x73)
                // store opcode SELFDESTRUCT immediately after the address, starting at 0x20 (32) in memory
                mstore8(0x20, 0xff)
                // this will always succeed because the contract creation code is
                // valid, and the address is valid because it is a 20-byte value
                if iszero(create(amount, 0x0b, 0x16)) {
                    // @dev For better gas estimation.
                    if iszero(gt(gas(), 1000000)) {
                        revert(0, 0)
                    }
                }
            }
        }
    }

    /**
     * @notice Returns whether or not the provided address `coreContract`
     * is an Art Blocks Engine core contract. Caches the result for future access.
     * @param coreContract Address of the core contract to check.
     */
    function isEngine(address coreContract) internal returns (bool) {
        IsEngineCache storage isEngineCache = getIsEngineCacheConfig(
            coreContract
        );
        // check cache, return early if cached
        if (isEngineCache.isCached) {
            return isEngineCache.isEngine;
        }
        // populate cache and return result
        bool isEngine_ = getV3CoreIsEngineView(coreContract);
        isEngineCache.isCached = true;
        isEngineCache.isEngine = isEngine_;
        return isEngine_;
    }

    /**
     * @notice Returns whether a V3 core contract is an Art Blocks Engine
     * contract or not. Return value of false indicates that the core is a
     * flagship contract. This function does not update the cache state for the
     * given V3 core contract.
     * @dev this function reverts if a core contract does not return the
     * expected number of return values from getPrimaryRevenueSplits() for
     * either a flagship or engine core contract.
     * @dev this function uses the length of the return data (in bytes) to
     * determine whether the core is an engine or not.
     * @param coreContract The address of the deployed core contract.
     */
    function getV3CoreIsEngineView(
        address coreContract
    ) internal view returns (bool) {
        // call getPrimaryRevenueSplits() on core contract
        bytes memory payload = abi.encodeWithSignature(
            "getPrimaryRevenueSplits(uint256,uint256)",
            0,
            0
        );
        (bool success, bytes memory returnData) = coreContract.staticcall(
            payload
        );
        require(success, "getPrimaryRevenueSplits() call failed");
        // determine whether core is engine or not, based on return data length
        uint256 returnDataLength = returnData.length;
        if (returnDataLength == 6 * 32) {
            // 6 32-byte words returned if flagship (not engine)
            // @dev 6 32-byte words are expected because the non-engine core
            // contracts return a payout address and uint256 payment value for
            // the artist, and artist's additional payee, and Art Blocks.
            // also note that per Solidity ABI encoding, the address return
            // values are padded to 32 bytes.

            return false;
        } else if (returnDataLength == 8 * 32) {
            // 8 32-byte words returned if engine
            // @dev 8 32-byte words are expected because the engine core
            // contracts return a payout address and uint256 payment value for
            // the artist, artist's additional payee, render provider
            // typically Art Blocks, and platform provider (partner).
            // also note that per Solidity ABI encoding, the address return
            // values are padded to 32 bytes.
            return true;
        }
        // unexpected return value length
        revert("Unexpected revenue split bytes");
    }

    /**
     * @notice Gets the currency address and symbol for the referenced
     * SplitFundsProjectConfig.
     * Only supports ERC20 tokens - returns currencySymbol of `UNCONFIG` if
     * `currencyAddress` is zero.
     * @param projectId Project ID to get config for
     * @param coreContract Core contract address to get config for
     * @return currencyAddress currency address for the referenced SplitFundsProjectConfig.
     * @return currencySymbol currency symbol for the referenced SplitFundsProjectConfig.
     */
    function getCurrencyInfoERC20(
        uint256 projectId,
        address coreContract
    )
        internal
        view
        returns (address currencyAddress, string memory currencySymbol)
    {
        SplitFundsProjectConfig
            storage splitFundsProjectConfig = getSplitFundsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
        currencyAddress = splitFundsProjectConfig.currencyAddress;
        // default to "UNCONFIG" if project currency address is initial value
        currencySymbol = currencyAddress == address(0)
            ? "UNCONFIG"
            : splitFundsProjectConfig.currencySymbol;
    }

    /**
     * @notice Gets the balance of `currencyAddress` ERC20 tokens for `walletAddress`.
     * @param currencyAddress ERC20 token address.
     * @param walletAddress wallet address.
     * @return balance Balance of ERC-20
     */
    function getERC20Balance(
        address currencyAddress,
        address walletAddress
    ) internal view returns (uint256) {
        return IERC20(currencyAddress).balanceOf(walletAddress);
    }

    /**
     * @notice Gets the allowance of `spenderAddress` to spend `walletAddress`'s
     * `currencyAddress` ERC20 tokens.
     * @param currencyAddress ERC20 token address.
     * @param walletAddress wallet address.
     * @param spenderAddress spender address.
     * @return allowance Allowance of ERC-20
     */
    function getERC20Allowance(
        address currencyAddress,
        address walletAddress,
        address spenderAddress
    ) internal view returns (uint256 allowance) {
        allowance = IERC20(currencyAddress).allowance({
            owner: walletAddress,
            spender: spenderAddress
        });
        return allowance;
    }

    /**
     * @notice Function validates that `msgSender` has approved the contract to spend at least
     * `pricePerToken` of `currencyAddress` ERC20 tokens, and that
     * `msgSender` has a balance of at least `pricePerToken` of
     * `currencyAddress` ERC20 tokens.
     * Reverts if insufficient allowance or balance.
     * @param msgSender Address of the message sender to validate.
     * @param currencyAddress Address of the ERC20 token to validate.
     * @param pricePerToken Price of token, in base units. For example,
     * if the ERC20 token has 6 decimals, an input value of `1_000_000` would
     * represent a price of `1.000000` tokens.
     */
    function validateERC20Approvals(
        address msgSender,
        address currencyAddress,
        uint256 pricePerToken
    ) private view {
        require(
            IERC20(currencyAddress).allowance({
                owner: msgSender,
                spender: address(this)
            }) >= pricePerToken,
            "Insufficient ERC20 allowance"
        );
        require(
            IERC20(currencyAddress).balanceOf(msgSender) >= pricePerToken,
            "Insufficient ERC20 balance"
        );
    }

    /**
     * @notice Sends ETH revenues between providers, artist, and artist's
     * additional payee. Reverts if any payment fails.
     * @dev This function pays priviliged addresses. DoS is acknowledged, and
     * mitigated by business practices, including end-to-end testing on
     * mainnet, and admin-accepted artist payment addresses.
     * @param platformProviderRevenue Platform Provider revenue.
     * @param platformProviderAddress Platform Provider address.
     * @param renderProviderRevenue Render Provider revenue.
     * @param renderProviderAddress Render Provider address.
     * @param artistRevenue Artist revenue.
     * @param artistAddress Artist address.
     * @param additionalPayeePrimaryRevenue Additional Payee revenue.
     * @param additionalPayeePrimaryAddress Additional Payee address.
     */
    function _sendPaymentsETH(
        uint256 platformProviderRevenue,
        address payable platformProviderAddress,
        uint256 renderProviderRevenue,
        address payable renderProviderAddress,
        uint256 artistRevenue,
        address payable artistAddress,
        uint256 additionalPayeePrimaryRevenue,
        address payable additionalPayeePrimaryAddress
    ) private {
        // Platform Provider payment (only possible if engine)
        if (platformProviderRevenue > 0) {
            (bool success, ) = platformProviderAddress.call{
                value: platformProviderRevenue
            }("");
            require(success, "Platform Provider payment failed");
        }
        // Render Provider / Art Blocks payment
        if (renderProviderRevenue > 0) {
            (bool success, ) = renderProviderAddress.call{
                value: renderProviderRevenue
            }("");
            require(success, "Render Provider payment failed");
        }
        // artist payment
        if (artistRevenue > 0) {
            (bool success, ) = artistAddress.call{value: artistRevenue}("");
            require(success, "Artist payment failed");
        }
        // additional payee payment
        if (additionalPayeePrimaryRevenue > 0) {
            (bool success, ) = additionalPayeePrimaryAddress.call{
                value: additionalPayeePrimaryRevenue
            }("");
            require(success, "Additional Payee payment failed");
        }
    }

    /**
     * @notice Sends ERC20 revenues between providers, artist, and artist's
     * additional payee. Reverts if any payment fails. All revenue values
     * should use base units. For example, if the ERC20 token has 6 decimals,
     * an input value of `1_000_000` would represent an amount of `1.000000`
     * tokens.
     * @dev This function relies on msg.sender, so it must be called from
     * the contract that is receiving the payment.
     * @param projectCurrency IERC20 payment token.
     * @param platformProviderRevenue Platform Provider revenue.
     * @param platformProviderAddress Platform Provider address.
     * @param renderProviderRevenue Render Provider revenue.
     * @param renderProviderAddress Render Provider address.
     * @param artistRevenue Artist revenue.
     * @param artistAddress Artist address.
     * @param additionalPayeePrimaryRevenue Additional Payee revenue.
     * @param additionalPayeePrimaryAddress Additional Payee address.
     */
    function _sendPaymentsERC20(
        IERC20 projectCurrency,
        uint256 platformProviderRevenue,
        address payable platformProviderAddress,
        uint256 renderProviderRevenue,
        address payable renderProviderAddress,
        uint256 artistRevenue,
        address payable artistAddress,
        uint256 additionalPayeePrimaryRevenue,
        address payable additionalPayeePrimaryAddress
    ) private {
        // Platform Provider payment (only possible if engine)
        if (platformProviderRevenue > 0) {
            require(
                projectCurrency.transferFrom({
                    from: msg.sender,
                    to: platformProviderAddress,
                    amount: platformProviderRevenue
                }),
                "Platform Provider payment failed"
            );
        }
        // Art Blocks payment
        if (renderProviderRevenue > 0) {
            require(
                projectCurrency.transferFrom({
                    from: msg.sender,
                    to: renderProviderAddress,
                    amount: renderProviderRevenue
                }),
                "Render Provider payment failed"
            );
        }
        // artist payment
        if (artistRevenue > 0) {
            require(
                projectCurrency.transferFrom({
                    from: msg.sender,
                    to: artistAddress,
                    amount: artistRevenue
                }),
                "Artist payment failed"
            );
        }
        // additional payee payment
        if (additionalPayeePrimaryRevenue > 0) {
            // @dev some ERC20 may not revert on transfer failure, so we
            // check the return value
            require(
                projectCurrency.transferFrom({
                    from: msg.sender,
                    to: additionalPayeePrimaryAddress,
                    amount: additionalPayeePrimaryRevenue
                }),
                "Additional Payee payment failed"
            );
        }
    }

    /**
     * @notice Loads the SplitFundsProjectConfig for a given project and core
     * contract.
     * @param projectId Project Id to get config for
     * @param coreContract Core contract address to get config for
     */
    function getSplitFundsProjectConfig(
        uint256 projectId,
        address coreContract
    ) internal view returns (SplitFundsProjectConfig storage) {
        return s().splitFundsProjectConfigs[coreContract][projectId];
    }

    /**
     * @notice Loads the IsEngineCache for a given core contract.
     * @param coreContract Core contract address to get config for
     */
    function getIsEngineCacheConfig(
        address coreContract
    ) internal view returns (IsEngineCache storage) {
        return s().isEngineCacheConfigs[coreContract];
    }

    /**
     * @notice Return the storage struct for reading and writing. This library
     * uses a diamond storage pattern when managing storage.
     * @return storageStruct The SetPriceLibStorage struct.
     */
    function s()
        internal
        pure
        returns (SplitFundsLibStorage storage storageStruct)
    {
        bytes32 position = SPLIT_FUNDS_LIB_STORAGE_POSITION;
        assembly ("memory-safe") {
            storageStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: LGPL-3.0-only
// Created By: Art Blocks Inc.

// @dev fixed to specific solidity version for clarity and for more clear
// source code verification purposes.
pragma solidity 0.8.22;

import {ISharedMinterV0} from "../../interfaces/v0.8.x/ISharedMinterV0.sol";
import {ISharedMinterRAMV0} from "../../interfaces/v0.8.x/ISharedMinterRAMV0.sol";
import {IMinterFilterV1} from "../../interfaces/v0.8.x/IMinterFilterV1.sol";

import {ABHelpers} from "../../libs/v0.8.x/ABHelpers.sol";
import {AuthLib} from "../../libs/v0.8.x/AuthLib.sol";
import {RAMLib} from "../../libs/v0.8.x/minter-libs/RAMLib.sol";
import {SplitFundsLib} from "../../libs/v0.8.x/minter-libs/SplitFundsLib.sol";
import {MaxInvocationsLib} from "../../libs/v0.8.x/minter-libs/MaxInvocationsLib.sol";

import {ReentrancyGuard} from "@openzeppelin-4.7/contracts/security/ReentrancyGuard.sol";
import {SafeCast} from "@openzeppelin-4.7/contracts/utils/math/SafeCast.sol";

/**
 * @title Filtered Minter contract that allows tokens to be minted with ETH.
 * Pricing is achieved using a fully on-chain ranked auction mechanism.
 * This is designed to be used with GenArt721CoreContractV3 flagship or
 * engine contracts.
 * @author Art Blocks Inc.
 * @notice Bid Front-Running:
 * Collectors can front-run bids, potentially causing bid transactions to
 * revert. The minter attempts to handle this in a simple and transparent
 * manner, but some transactions reverting, especially during highly
 * competitive auctions, is unavoidable, and best remedied by resubmitting a
 * new bid transaction with a higher value.
 * @notice Privileged Roles and Ownership:
 * This contract is designed to be managed, with limited powers.
 * Privileged roles and abilities are controlled by the core contract's Admin
 * ACL contract a project's artist, and auction winners. The Admin ACL and
 * project's artist roles hold extensive power and can modify minter details.
 * Care must be taken to ensure that the admin ACL contract and artist
 * addresses are secure behind a multi-sig or other access control mechanism.
 *
 * Additional admin and artist privileged roles may be described on other
 * contracts that this minter integrates with.
 * @notice Fallback and Error States:
 * This minter implements protections for collectors and artists and admin with
 * the intention of preventing any single party from being able to deny
 * revenue or minting rights to another party, for any time longer than
 * 72 hours. All funds are held non-custodially by the smart contract until
 * all tokens are minted or bids are refunded, after which they may be
 * distributed to the artist and admin. All settlements are non-custodial and
 * may be claimed by the winning bidder at any time after an auction ends.
 * ----------------------------------------------------------------------------
 * @notice Project-Minter STATE, FLAG, and ERROR Summary
 * Note: STATEs are mutually exclusive and are in-order, State C potentially skipped
 * -------------
 * STATE A: Pre-Auction
 * abilities:
 *  - (artist) configure project max invocations
 *  - (artist) configure project auction
 * -------------
 * STATE B: Live-Auction
 * abilities:
 *  - (minter active) create bid
 *  - (minter active) top-up bid
 *  - (admin) emergency increase auction end time by up to 72 hr (in cases of frontend downtime, etc.)
 *  - (artist)(not in extra time)(no previous admin extension) reduce auction length
 * -------------
 * STATE C: Post-Auction, Admin-Artist Mint Period (if applicable)
 * abilities:
 *  - (admin | artist) auto-mint tokens to winners
 *  - (winner) collect settlement
 *  - (ERROR E1)(admin) auto-refund winning bids that cannot receive tokens due to max invocations error
 *  note: State C is skipped if auction was not a sellout
 * -------------
 * STATE D: Post-Auction, Open Mint Period
 * abilities:
 *  - (winner | admin | artist) directly mint tokens to winners, any order
 *  - (winner) collect settlement
 *  - (FLAG F1) purchase remaining tokens for auction min price (base price), like fixed price minter
 *  - (ERROR E1)(winner | admin | artist) directly refund bids due to max invocations error state, any order
 * -------------
 * STATE E: Post-Auction, all bids handled
 * note: "all bids handled" guarantees not in ERROR E1
 *  - (artist | admin) collect revenues
 *  - (FLAG F1) purchase remaining tokens for auction min price (base price), like fixed price minter
 * -------------
 * FLAGS
 * F1: tokens owed < invocations available
 *     occurs when an auction ends before selling out, so tokens are available to be purchased
 *     note: also occurs during Pre and Live auction, so FLAG F1 can occur with STATE A, B, but should not enable purchases
 * -------------
 * ERRORS
 * E1: tokens owed > invocations available
 *     occurs when tokens minted on different minter or core max invocations were reduced after auction bidding began.
 *     indicates operational error occurred.
 *     resolution: when winning bids have refunded to sufficiently reduce tokens owed == invocations available.
 *     note: error state does not affect minimum winning bid price, and therefore does not affect settlement amount due to any
 *     winning bids.
 * ----------------------------------------------------------------------------
 * @notice Caution: While Engine projects must be registered on the Art Blocks
 * Core Registry to assign this minter, this minter does not enforce that a
 * project is registered when configured or queried. This is primarily for gas
 * optimization purposes. It is, therefore, possible that fake projects may be
 * configured on this minter, but bids will not be able to be placed due to
 * checks performed by this minter's Minter Filter.
 *
 * @dev Note that while this minter makes use of `block.timestamp` and it is
 * technically possible that this value is manipulated by block producers, such
 * manipulation will not have material impact on the ability for collectors to
 * place a bid before auction end time. Minimum limits are set on time
 * intervals such that this manipulation would not have a material impact on
 * the auction process.
 */
contract MinterRAMV0 is ReentrancyGuard, ISharedMinterV0, ISharedMinterRAMV0 {
    using SafeCast for uint256;

    /// @notice Minter filter address this minter interacts with
    address public immutable minterFilterAddress;

    /// @notice Minter filter this minter may interact with.
    IMinterFilterV1 private immutable _minterFilter;

    /// @notice minterType for this minter
    string public constant minterType = "MinterRAMV0";

    /// @notice minter version for this minter
    string public constant minterVersion = "v0.0.0";

    /// @notice Minimum auction duration
    uint256 public constant MIN_AUCTION_DURATION_SECONDS = 60 * 10; // 10 minutes

    /** @notice Gas limit for refunding ETH to bidders
     * configurable by admin, default to 30,000
     * max uint24 ~= 16 million gas, more than enough for a refund
     * @dev SENDALL fallback is used to refund ETH if this limit is exceeded
     */
    uint24 internal _minterRefundGasLimit = 30_000;

    /**
     * @notice Initializes contract to be a shared, filtered minter for
     * minter filter `minterFilter`
     * @param minterFilter Minter filter for which this will be a minter
     */
    constructor(address minterFilter) ReentrancyGuard() {
        minterFilterAddress = minterFilter;
        _minterFilter = IMinterFilterV1(minterFilter);
        // emit events indicating default minter configuration values
        emit RAMLib.MinAuctionDurationSecondsUpdated({
            minAuctionDurationSeconds: MIN_AUCTION_DURATION_SECONDS
        });
        emit RAMLib.MinterRefundGasLimitUpdated({
            refundGasLimit: _minterRefundGasLimit
        });
        emit RAMLib.AuctionBufferTimeParamsUpdated({
            auctionBufferSeconds: RAMLib.AUCTION_BUFFER_SECONDS,
            maxAuctionExtraSeconds: RAMLib.MAX_AUCTION_EXTRA_SECONDS
        });
        emit RAMLib.NumSlotsUpdated({numSlots: RAMLib.NUM_SLOTS});
    }

    /**
     * @notice Sets the gas limit during ETH refunds when a collector is
     * outbid. This value should be set to a value that is high enough to
     * ensure that refunds are successful for commonly used wallets, but low
     * enough to avoid excessive abuse of refund gas allowance during a new
     * bid.
     * @dev max gas limit is ~16M, which is considered well over a future-safe
     * upper bound.
     * @param minterRefundGasLimit Gas limit to set for refunds. Must be
     * between 7,000 and max uint24 (~16M).
     */
    function updateRefundGasLimit(uint24 minterRefundGasLimit) external {
        // CHECKS
        AuthLib.onlyMinterFilterAdminACL({
            minterFilterAddress: minterFilterAddress,
            sender: msg.sender,
            contract_: address(this),
            selector: this.updateRefundGasLimit.selector
        });
        // @dev max gas limit implicitly checked by using uint24 input arg
        // @dev min gas limit is based on rounding up current cost to send ETH
        // to a Gnosis Safe wallet, which accesses cold address and emits event
        require(minterRefundGasLimit >= 7_000, "Only gte 7_000");
        // EFFECTS
        _minterRefundGasLimit = minterRefundGasLimit;
        emit RAMLib.MinterRefundGasLimitUpdated(minterRefundGasLimit);
    }

    /**
     * @notice Contract-Admin only function to update the requirements on if a
     * post-auction admin-artist-only mint period is required or banned, for
     * and-on configured projects.
     * @param coreContract core contract to set the configuration for.
     * @param adminMintingConstraint enum indicating if the minter should
     * require an admin-artist-only mint period after the auction ends or not.
     */
    function setContractConfig(
        address coreContract,
        RAMLib.AdminMintingConstraint adminMintingConstraint
    ) external {
        // CHECKS
        AuthLib.onlyCoreAdminACL({
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.setContractConfig.selector
        });
        // EFFECTS
        RAMLib.setContractConfig({
            coreContract: coreContract,
            adminMintingConstraint: adminMintingConstraint
        });
    }

    /**
     * @notice Contract-Admin only function to add emergency auction hours to
     * auction of project `projectId` on core contract `coreContract`.
     * Protects against unexpected frontend downtime, etc.
     * Reverts if called by anyone other than a contract admin.
     * Reverts if project is not in a Live Auction.
     * Reverts if auction is already in extra time.
     * Reverts if adding more than the maximum number of emergency hours.
     * @param projectId Project ID to add emergency auction hours to.
     * @param coreContract Core contract address for the given project.
     * @param emergencyHoursToAdd Number of emergency hours to add to the
     * project's auction.
     */
    function adminAddEmergencyAuctionHours(
        uint256 projectId,
        address coreContract,
        uint8 emergencyHoursToAdd
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACL({
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.adminAddEmergencyAuctionHours.selector
        });
        // EFFECTS
        RAMLib.adminAddEmergencyAuctionHours({
            projectId: projectId,
            coreContract: coreContract,
            emergencyHoursToAdd: emergencyHoursToAdd
        });
    }

    /**
     * @notice Manually sets the local maximum invocations of project `projectId`
     * with the provided `maxInvocations`, checking that `maxInvocations` is less
     * than or equal to the value of project `project_id`'s maximum invocations that is
     * set on the core contract.
     * @dev Note that a `maxInvocations` of 0 can only be set if the current `invocations`
     * value is also 0 and this would also set `maxHasBeenInvoked` to true, correctly short-circuiting
     * this minter's purchase function, avoiding extra gas costs from the core contract's maxInvocations check.
     * @param projectId Project ID to set the maximum invocations for.
     * @param coreContract Core contract address for the given project.
     * @param maxInvocations Maximum invocations to set for the project.
     */
    function manuallyLimitProjectMaxInvocations(
        uint256 projectId,
        address coreContract,
        uint24 maxInvocations
    ) external {
        // CHECKS
        AuthLib.onlyArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender
        });
        // only project minter state A (Pre-Auction)
        RAMLib.ProjectMinterStates currentState = RAMLib.getProjectMinterState({
            projectId: projectId,
            coreContract: coreContract
        });
        require(
            currentState == RAMLib.ProjectMinterStates.PreAuction,
            "Only pre-auction"
        );
        // EFFECTS
        MaxInvocationsLib.manuallyLimitProjectMaxInvocations({
            projectId: projectId,
            coreContract: coreContract,
            maxInvocations: maxInvocations
        });
        // also update number of tokens in auction
        RAMLib.refreshNumTokensInAuction({
            projectId: projectId,
            coreContract: coreContract
        });
    }

    /**
     * @notice Sets auction details for project `projectId`.
     * @param projectId Project ID to set auction details for.
     * @param coreContract Core contract address for the given project.
     * @param auctionTimestampStart Timestamp at which to start the auction.
     * @param basePrice Resting price of the auction, in Wei.
     * @param allowExtraTime Boolean indicating if extra time is allowed for
     * the auction, when valid bids are placed near the end of the auction.
     * @param adminArtistOnlyMintPeriodIfSellout Boolean indicating if an
     * admin-artist-only mint period should be enforced if the auction sells
     * out.
     * @dev Note that a basePrice of `0` will cause the transaction to revert.
     */
    function setAuctionDetails(
        uint256 projectId,
        address coreContract,
        uint40 auctionTimestampStart,
        uint40 auctionTimestampEnd,
        uint256 basePrice,
        bool allowExtraTime,
        bool adminArtistOnlyMintPeriodIfSellout
    ) external nonReentrant {
        AuthLib.onlyArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender
        });
        // CHECKS
        // check min auction duration
        // @dev underflow checked automatically in solidity 0.8
        require(
            auctionTimestampEnd - auctionTimestampStart >=
                MIN_AUCTION_DURATION_SECONDS,
            "Auction too short"
        );
        // EFFECTS
        // @dev project minter state checked in setAuctionDetails
        RAMLib.setAuctionDetails({
            projectId: projectId,
            coreContract: coreContract,
            auctionTimestampStart: auctionTimestampStart,
            auctionTimestampEnd: auctionTimestampEnd,
            basePrice: basePrice.toUint88(),
            allowExtraTime: allowExtraTime,
            adminArtistOnlyMintPeriodIfSellout: adminArtistOnlyMintPeriodIfSellout
        });
    }

    /**
     * @notice Reduces the auction length for project `projectId` on core
     * contract `coreContract` to `auctionTimestampEnd`.
     * Only allowed to be called during a live auction, and protects against
     * the case of an accidental excessively long auction, which locks funds.
     * Reverts if called by anyone other than the project's artist.
     * Reverts if project is not in a Live Auction.
     * Reverts if auction is not being reduced in length.
     * Reverts if in extra time.
     * Reverts if `auctionTimestampEnd` results in auction that is not at least
     * `MIN_AUCTION_DURATION_SECONDS` in duration.
     * Reverts if admin previously applied a time extension.
     * @param projectId Project ID to reduce the auction length for.
     * @param coreContract Core contract address for the given project.
     * @param auctionTimestampEnd New timestamp at which to end the auction.
     */
    function reduceAuctionLength(
        uint256 projectId,
        address coreContract,
        uint40 auctionTimestampEnd
    ) external nonReentrant {
        AuthLib.onlyArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender
        });
        RAMLib.reduceAuctionLength({
            projectId: projectId,
            coreContract: coreContract,
            auctionTimestampEnd: auctionTimestampEnd,
            minimumAuctionDurationSeconds: MIN_AUCTION_DURATION_SECONDS
        });
    }

    /**
     * @notice Places a bid for project `projectId` on core contract
     * `coreContract`.
     * Reverts if minter is not the active minter for projectId on minter
     * filter.
     * Reverts if project is not in a Live Auction.
     * Reverts if msg.value is not equal to slot value.
     * In order to successfully place the bid, the token bid must be:
     * - greater than or equal to a project's minimum bid price if maximum
     *   number of bids has not been reached
     * - sufficiently greater than the current minimum bid if maximum number
     *   of bids has been reached
     * If the bid is unsuccessful, the transaction will revert.
     * If the bid is successful, but outbid by another bid before the auction
     * ends, the funds will be noncustodially returned to the bidder's address,
     * `msg.sender`. A fallback method of sending funds back to the bidder via
     * SELFDESTRUCT (SENDALL) prevents denial of service attacks, even if the
     * original bidder reverts or runs out of gas during receive or fallback.
     * ------------------------------------------------------------------------
     * WARNING: bidders must be prepared to handle the case where their bid is
     * outbid and their funds are returned to the original `msg.sender` address
     * via SELFDESTRUCT (SENDALL).
     * ------------------------------------------------------------------------
     * @param projectId projectId being bid on.
     * @param coreContract Core contract address for the given project.
     * @param slotIndex Slot index to create the bid for.
     * @dev nonReentrant modifier is used to prevent reentrancy attacks, e.g.
     * an an auto-bidder that would be able to automically outbid a user's
     * new bid via a reentrant call to createBid.
     */
    function createBid(
        uint256 projectId,
        address coreContract,
        uint16 slotIndex
    ) external payable nonReentrant {
        // CHECKS
        // minter must be set for project on MinterFilter
        require(
            _minterFilter.getMinterForProject({
                projectId: projectId,
                coreContract: coreContract
            }) == address(this),
            "Minter not active"
        );
        // @dev bid value is checked against slot value in placeBid
        // @dev project state is checked in placeBid

        // EFFECTS
        RAMLib.placeBid({
            projectId: projectId,
            coreContract: coreContract,
            slotIndex: slotIndex,
            bidder: msg.sender,
            bidValue: msg.value,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Top up bid for project `projectId` on core contract
     * `coreContract` for bid `bidId` to new slot index `newSlotIndex`.
     * Reverts if Bid ID has been kicked out of the auction or does not exist.
     * Reverts if msg.sender is not the bidder of the bid.
     * Reverts if minter is not the active minter for projectId on minter
     * filter.
     * Reverts if project is not in a Live Auction.
     * Reverts if msg.value is not equal to difference in bid values between
     * new and old slots.
     * Reverts if new slot index is not greater than or equal to the current
     * slot index.
     * @param projectId Project ID to top up bid for.
     * @param coreContract Core contract address for the given project.
     * @param bidId ID of bid to top up.
     * @param newSlotIndex New slot index to move bid to.
     */
    function topUpBid(
        uint256 projectId,
        address coreContract,
        uint32 bidId,
        uint16 newSlotIndex
    ) external payable nonReentrant {
        // CHECKS
        // minter must be set for project on MinterFilter
        require(
            _minterFilter.getMinterForProject({
                projectId: projectId,
                coreContract: coreContract
            }) == address(this),
            "Minter not active"
        );
        // @dev additional bid value is checked against slot value in topUpBid
        // @dev project state is checked in topUpBid

        // EFFECTS
        RAMLib.topUpBid({
            projectId: projectId,
            coreContract: coreContract,
            bidId: bidId,
            newSlotIndex: newSlotIndex,
            bidder: msg.sender,
            addedValue: msg.value
        });
    }

    /**
     * @notice Purchases token for project `projectId` on core contract
     * `coreContract` for auction that has ended, but not yet been sold out.
     * @param projectId Project ID to purchase token for.
     * @param coreContract Core contract address for the given project.
     * @return tokenId Token ID of minted token
     */
    function purchase(
        uint256 projectId,
        address coreContract
    ) external payable nonReentrant returns (uint256 tokenId) {
        // @dev checks performed in RAMLib purchaseTo function
        tokenId = RAMLib.purchaseTo({
            to: msg.sender,
            projectId: projectId,
            coreContract: coreContract,
            minterFilter: _minterFilter
        });
    }

    /**
     * @notice Purchases token for project `projectId` on core contract
     * `coreContract` for auction that has ended, but not yet been sold out,
     * and sets the token's owner to `to`.
     * @param to Address to be the new token's owner.
     * @param projectId Project ID to purchase token for.
     * @param coreContract Core contract address for the given project.
     * @return tokenId Token ID of minted token
     */
    function purchaseTo(
        address to,
        uint256 projectId,
        address coreContract
    ) external payable nonReentrant returns (uint256 tokenId) {
        // @dev checks performed in RAMLib purchaseTo function
        tokenId = RAMLib.purchaseTo({
            to: to,
            projectId: projectId,
            coreContract: coreContract,
            minterFilter: _minterFilter
        });
    }

    /**
     * @notice Collects settlement for project `projectId` on core contract
     * `coreContract` for all bids in `bidIds`,
     * which must be aligned by index.
     * Reverts if msg.sender is not the bidder for all bids.
     * Reverts if project is not in a post-auction state.
     * Reverts if one or more bids has already been settled.
     * Reverts if invalid bid is found.
     * @param projectId Project ID of bid to collect settlement for
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to collect settlements for
     */
    function collectSettlements(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds
    ) external nonReentrant {
        // CHECKS
        // @dev project state is checked in collectSettlements
        // @dev length of slotIndices and bidIndicesInSlot must be equal is
        // checked in collectSettlements
        // EFFECTS
        RAMLib.collectSettlements({
            projectId: projectId,
            coreContract: coreContract,
            bidIds: bidIds,
            bidder: msg.sender,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Contract-Admin or Artist only function to mint tokens to winners
     * of project `projectId` on core contract `coreContract`.
     * Automatically mints tokens to most-winning bids, in order from highest
     * and earliest bid to lowest and latest bid.
     * Settles bids as tokens are minted, if not already settled.
     * Reverts if project is not in a post-auction state, admin-artist-only
     * mint period (i.e. State C), with tokens available.
     * Reverts if msg.sender is not a contract admin or artist.
     * Reverts if number of tokens to mint is greater than the number of
     * tokens available to be minted.
     * @param projectId Project ID to mint tokens on.
     * @param coreContract Core contract address for the given project.
     * @param numTokensToMint Number of tokens to mint in this transaction.
     */
    function adminArtistAutoMintTokensToWinners(
        uint256 projectId,
        address coreContract,
        uint24 numTokensToMint
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACLOrArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.adminArtistAutoMintTokensToWinners.selector
        });
        // EFFECTS/INTERACTIONS
        RAMLib.adminArtistAutoMintTokensToWinners({
            projectId: projectId,
            coreContract: coreContract,
            numTokensToMint: numTokensToMint,
            minterFilter: _minterFilter,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Directly mint tokens to winners of project `projectId` on core
     * contract `coreContract`.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `adminAutoRefundWinners` does while in State C.
     * Admin or Artist may mint to any winning bids.
     * Provides protection for Admin and Artist because they may mint tokens
     * to winners to prevent denial of revenue claiming.
     * Skips over bids that have already been minted or refunded (front-running
     * protection).
     * Reverts if project is not in a post-auction state,
     * post-admin-artist-only mint period (i.e. State D), with tokens available
     * Reverts if msg.sender is not a contract admin or artist.
     * @param projectId Project ID to mint tokens on.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to mint tokens for
     */
    function adminArtistDirectMintTokensToWinners(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACLOrArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.adminArtistDirectMintTokensToWinners.selector
        });
        // EFFECTS/INTERACTIONS
        RAMLib.directMintTokensToWinners({
            projectId: projectId,
            coreContract: coreContract,
            bidIds: bidIds,
            requireSenderIsBidder: false, // not required when called by admin or artist
            minterFilter: _minterFilter,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Directly mint tokens of winner of project `projectId` on core
     * contract `coreContract`.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `adminAutoRefundWinners` does while in State C.
     * Only winning collector may call and mint tokens to themselves.
     * Provides protection for collectors because they may mint their tokens
     * directly.
     * Skips over bids that have already been minted or refunded (front-running
     * protection)
     * Reverts if project is not in a post-auction state,
     * post-admin-artist-only mint period (i.e. State D), with tokens available
     * Reverts if msg.sender is not the winning bidder for all specified bids.
     * @param projectId Project ID to mint tokens on.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to mint tokens for
     */
    function winnerDirectMintTokens(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds
    ) external nonReentrant {
        // CHECKS
        // @dev all checks performed in library function
        // EFFECTS/INTERACTIONS
        RAMLib.directMintTokensToWinners({
            projectId: projectId,
            coreContract: coreContract,
            bidIds: bidIds,
            requireSenderIsBidder: true, // only allow winning bidder to call
            minterFilter: _minterFilter,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Directly refund bids for project `projectId` on core
     * contract `coreContract` to resolve error state E1.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `adminAutoMintTokensToWinners` does while in State C.
     * Admin or Artist may refund to any bids.
     * Provides protection for Admin and Artist because they may refund to
     * resolve E1 state to prevent denial of revenue claiming.
     * Skips over bids that have already been minted or refunded (front-running
     * protection).
     * Reverts if project is not in a post-auction state,
     * post-admin-artist-only mint period (i.e. State D).
     * Reverts if project is not in error state E1.
     * Reverts if length of bids to refund exceeds the number of bids that need
     * to be refunded to resolve the error state E1.
     * Reverts if bid does not exist at bidId.
     * Reverts if msg.sender is not a contract admin or artist.
     * @param projectId Project ID to refund bid values on.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to refund bid values for
     */
    function adminArtistDirectRefundWinners(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACLOrArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.adminArtistDirectRefundWinners.selector
        });
        // EFFECTS/INTERACTIONS
        RAMLib.directRefundBidsToResolveE1({
            projectId: projectId,
            coreContract: coreContract,
            bidIds: bidIds,
            requireSenderIsBidder: false, // not required when called by admin or artist
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Directly refund bids for project `projectId` on core
     * contract `coreContract` to resolve error state E1.
     * Does not guarantee an optimal ordering or handling of E1 state like
     * `adminAutoMintTokensToWinners` does while in State C.
     * Only winning collector may call and refund to themselves.
     * Provides protection for collectors because they may refund their tokens
     * directly if in E1 state and they are no longer able to mint their
     * token(s) (prevent holding of funds).
     * Skips over bids that have already been minted or refunded (front-running
     * protection).
     * Reverts if project is not in a post-auction state,
     * post-admin-artist-only mint period (i.e. State D).
     * Reverts if project is not in error state E1.
     * Reverts if length of bids to refund exceeds the number of bids that need
     * to be refunded to resolve the error state E1.
     * Reverts if msg.sender is not the winning bidder for all specified bids.
     * @param projectId Project ID to refund bid values on.
     * @param coreContract Core contract address for the given project.
     * @param bidIds IDs of bids to refund bid values for
     */
    function winnerDirectRefund(
        uint256 projectId,
        address coreContract,
        uint32[] calldata bidIds
    ) external nonReentrant {
        // CHECKS
        // @dev all checks performed in library function
        // EFFECTS/INTERACTIONS
        RAMLib.directRefundBidsToResolveE1({
            projectId: projectId,
            coreContract: coreContract,
            bidIds: bidIds,
            requireSenderIsBidder: true, // only allow winning bidder to call
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice Function to automatically refund the lowest winning bids for
     * project `projectId` on core contract `coreContract` to resolve error
     * state E1.
     * Reverts if not called by a contract admin.
     * Reverts if project is not in post-auction state C.
     * Reverts if project is not in error state E1.
     * Reverts if numBidsToRefund exceeds the number of bids that need to be
     * refunded to resolve the error state E1.
     * @dev Admin-only requirement is not for security, but is to enable Admin
     * to be aware that an error state has been encountered while in post-
     * auction state C.
     * @param projectId Project ID to refunds bids for.
     * @param coreContract Core contract address for the given project.
     * @param numBidsToRefund Number of bids to refund in this call.
     */
    function adminAutoRefundWinners(
        uint256 projectId,
        address coreContract,
        uint24 numBidsToRefund
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACL({
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.adminAutoRefundWinners.selector
        });
        // EFFECTS/INTERACTIONS
        RAMLib.autoRefundBidsToResolveE1({
            projectId: projectId,
            coreContract: coreContract,
            numBidsToRefund: numBidsToRefund,
            minterRefundGasLimit: _minterRefundGasLimit
        });
    }

    /**
     * @notice This withdraws project revenues for project `projectId` on core
     * contract `coreContract` to the artist and admin, only after all bids
     * have been minted+settled or refunded.
     * Note that the conditions described are the equivalent of project minter
     * State E.
     * @param projectId Project ID to withdraw revenues for.
     * @param coreContract Core contract address for the given project.
     */
    function withdrawArtistAndAdminRevenues(
        uint256 projectId,
        address coreContract
    ) external nonReentrant {
        // CHECKS
        AuthLib.onlyCoreAdminACLOrArtist({
            projectId: projectId,
            coreContract: coreContract,
            sender: msg.sender,
            contract_: address(this),
            selector: this.withdrawArtistAndAdminRevenues.selector
        });
        // EFFECTS/INTERACTIONS
        RAMLib.withdrawArtistAndAdminRevenues({
            projectId: projectId,
            coreContract: coreContract
        });
    }

    /**
     * @notice Returns if project minter is in ERROR state E1, and the number
     * of bids that need to be refunded to resolve the error.
     * E1: Tokens owed > invocations available
     * Occurs when: tokens are minted on different minter after auction begins,
     * or when core contract max invocations are reduced after auction begins.
     * Resolution: Admin must refund the lowest bids after auction ends.
     * @param projectId Project Id to query
     * @param coreContract Core contract address to query
     * @return isError True if in error state, false otherwise
     * @return numBidsToRefund Number of bids to refund to resolve error, 0 if
     * not in error state
     */
    function getIsErrorE1(
        uint256 projectId,
        address coreContract
    ) external view returns (bool isError, uint256 numBidsToRefund) {
        (isError, numBidsToRefund, ) = RAMLib.isErrorE1FlagF1({
            projectId: projectId,
            coreContract: coreContract
        });
    }

    /**
     * @notice View function to return the current minter-level configuration
     * details. Some or all of these values may be defined as constants for
     * this minter.
     * @return minAuctionDurationSeconds Minimum auction duration in seconds
     * @return auctionBufferSeconds Auction buffer time in seconds
     * @return maxAuctionExtraSeconds Maximum extra time in seconds
     * @return maxAuctionAdminEmergencyExtensionHours Maximum emergency
     * extension hours for admin
     * @return adminArtistOnlyMintTimeSeconds Admin-artist-only mint time in
     * seconds
     * @return minterRefundGasLimit Gas limit for refunding ETH
     */
    function minterConfigurationDetails()
        external
        view
        returns (
            uint256 minAuctionDurationSeconds,
            uint256 auctionBufferSeconds,
            uint256 maxAuctionExtraSeconds,
            uint256 maxAuctionAdminEmergencyExtensionHours,
            uint256 adminArtistOnlyMintTimeSeconds,
            uint24 minterRefundGasLimit
        )
    {
        minAuctionDurationSeconds = MIN_AUCTION_DURATION_SECONDS;
        auctionBufferSeconds = RAMLib.AUCTION_BUFFER_SECONDS;
        maxAuctionExtraSeconds = RAMLib.MAX_AUCTION_EXTRA_SECONDS;
        maxAuctionAdminEmergencyExtensionHours = RAMLib
            .MAX_AUCTION_ADMIN_EMERGENCY_EXTENSION_HOURS;
        adminArtistOnlyMintTimeSeconds = RAMLib
            .ADMIN_ARTIST_ONLY_MINT_TIME_SECONDS;
        minterRefundGasLimit = _minterRefundGasLimit;
    }

    /**
     * @notice Gets the admin minting constraint configuration details for a core contract as configured by a
     * contract admin, for this minter.
     * @param coreContract The address of the core contract.
     * @return RAMLib.AdminMintingConstraint enum value.
     */
    function contractConfigurationDetails(
        address coreContract
    ) external view returns (RAMLib.AdminMintingConstraint) {
        return RAMLib.getRAMAdminMintingConstraintValue(coreContract);
    }

    /**
     * @notice Gets the maximum invocations project configuration.
     * @dev RAMLib shims in logic to properly return maxHasBeenInvoked based
     * on project state, bid state, and core contract state.
     * @param projectId The ID of the project whose data needs to be fetched.
     * @param coreContract The address of the core contract.
     * @return MaxInvocationsLib.MaxInvocationsProjectConfig instance with the
     * configuration data.
     */
    function maxInvocationsProjectConfig(
        uint256 projectId,
        address coreContract
    )
        external
        view
        returns (MaxInvocationsLib.MaxInvocationsProjectConfig memory)
    {
        // RAM minter does not update maxHasBeenInvoked, so we ask the RAMLib
        // for this state, and it shims in an appropriate maxHasBeenInvoked
        // value based on the state of the auction, unminted bids, core
        // contract invocations, and minter max invocations
        return
            RAMLib.getMaxInvocationsProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            });
    }

    /**
     * @notice Returns the auction details for project `projectId` on core
     * contract `coreContract`.
     * @param projectId is an existing project ID.
     * @param coreContract is an existing core contract address.
     * @return auctionTimestampStart is the timestamp at which the auction
     * starts.
     * @return auctionTimestampEnd is the timestamp at which the auction ends.
     * @return basePrice is the resting price of the auction, in Wei.
     * @return numTokensInAuction is the number of tokens in the auction.
     * @return numBids is the number of bids in the auction.
     * @return numBidsMintedTokens is the number of bids that have been minted
     * into tokens.
     * @return numBidsErrorRefunded is the number of bids that have been
     * refunded due to an error state.
     * @return minBidSlotIndex is the index of the slot with the minimum bid
     * value.
     * @return allowExtraTime is a bool indicating if the auction is allowed to
     * have extra time.
     * @return adminArtistOnlyMintPeriodIfSellout is a bool indicating if an
     * admin-artist-only mint period is required if the auction sells out.
     * @return revenuesCollected is a bool indicating if the auction revenues
     * have been collected.
     * @return projectMinterState is the current state of the project minter.
     * @dev projectMinterState is a RAMLib.ProjectMinterStates enum value.
     */
    function getAuctionDetails(
        uint256 projectId,
        address coreContract
    )
        external
        view
        returns (
            uint256 auctionTimestampStart,
            uint256 auctionTimestampEnd,
            uint256 basePrice,
            uint256 numTokensInAuction,
            uint256 numBids,
            uint256 numBidsMintedTokens,
            uint256 numBidsErrorRefunded,
            uint256 minBidSlotIndex,
            bool allowExtraTime,
            bool adminArtistOnlyMintPeriodIfSellout,
            bool revenuesCollected,
            RAMLib.ProjectMinterStates projectMinterState
        )
    {
        return
            RAMLib.getAuctionDetails({
                projectId: projectId,
                coreContract: coreContract
            });
    }

    /**
     * @notice Returns if project has reached maximum number of invocations for
     * a given project and core contract, properly accounting for the auction
     * state, unminted bids, core contract invocations, and minter max
     * invocations when determining maxHasBeenInvoked
     * @param projectId is an existing project ID.
     * @param coreContract is an existing core contract address.
     */
    function projectMaxHasBeenInvoked(
        uint256 projectId,
        address coreContract
    ) external view returns (bool) {
        return
            RAMLib.getMaxHasBeenInvoked({
                projectId: projectId,
                coreContract: coreContract
            });
    }

    /**
     * @notice projectId => project's maximum number of invocations.
     * Optionally synced with core contract value, for gas optimization.
     * Note that this returns a local cache of the core contract's
     * state, and may be out of sync with the core contract. This is
     * intentional, as it only enables gas optimization of mints after a
     * project's maximum invocations has been reached.
     * @dev A number greater than the core contract's project max invocations
     * will only result in a gas cost increase, since the core contract will
     * still enforce a maxInvocation check during minting. A number less than
     * the core contract's project max invocations is only possible when the
     * project's max invocations have not been synced on this minter, since the
     * V3 core contract only allows maximum invocations to be reduced, not
     * increased. When this happens, the minter will enable minting, allowing
     * the core contract to enforce the max invocations check. Based on this
     * rationale, we intentionally do not do input validation in this method as
     * to whether or not the input `projectId` is an existing project ID.
     * @param projectId is an existing project ID.
     * @param coreContract is an existing core contract address.
     */
    function projectMaxInvocations(
        uint256 projectId,
        address coreContract
    ) external view returns (uint256) {
        return
            MaxInvocationsLib.getMaxInvocations({
                projectId: projectId,
                coreContract: coreContract
            });
    }

    /**
     * @notice Checks if the specified `coreContract` is a valid engine contract.
     * @dev This function retrieves the cached value of `isEngine` from
     * the `isEngineCache` mapping. If the cached value is already set, it
     * returns the cached value. Otherwise, it calls the `getV3CoreIsEngineView`
     * function from the `SplitFundsLib` library to check if `coreContract`
     * is a valid engine contract.
     * @dev This function will revert if the provided `coreContract` is not
     * a valid Engine or V3 Flagship contract.
     * @param coreContract The address of the contract to check.
     * @return True if `coreContract` is a valid engine contract.
     */
    function isEngineView(address coreContract) external view returns (bool) {
        SplitFundsLib.IsEngineCache storage isEngineCache = SplitFundsLib
            .getIsEngineCacheConfig(coreContract);
        if (isEngineCache.isCached) {
            return isEngineCache.isEngine;
        } else {
            // @dev this calls the non-state-modifying variant of isEngine
            return SplitFundsLib.getV3CoreIsEngineView(coreContract);
        }
    }

    /**
     * @notice Gets minimum bid value to participate in an
     * auction for project `projectId` on core contract `coreContract`.
     * If an auction is not configured, `isConfigured` will be false, and a
     * dummy price of zero is assigned to `tokenPriceInWei`.
     * If an auction is configured but still in a pre-auction state,
     * `isConfigured` will be true, and `tokenPriceInWei` will be the minimum
     * initial bid price for the next token auction.
     * If there is an active auction, `isConfigured` will be true, and
     * `tokenPriceInWei` will be the current minimum bid's value + min bid
     * increment due to the minter's increment percentage, rounded up to next
     * slot's bid value.
     * If there is an auction that has ended (no longer accepting bids), but
     * the project is configured, `isConfigured` will be true, and
     * `tokenPriceInWei` will be either the sellout price or the reserve price
     * of the auction if it did not sell out during its auction.
     * Also returns currency symbol and address to be being used as payment,
     * which for this minter is ETH only.
     * @param projectId Project ID to get price information for.
     * @param coreContract Core contract to get price information for.
     * @return isConfigured true only if project auctions are configured.
     * @return tokenPriceInWei price in wei to become a bidder on a
     * token auction.
     * @return currencySymbol currency symbol for purchases of project on this
     * minter. This minter always returns "ETH"
     * @return currencyAddress currency address for purchases of project on
     * this minter. This minter always returns null address, reserved for ether
     */
    function getPriceInfo(
        uint256 projectId,
        address coreContract
    )
        external
        view
        returns (
            bool isConfigured,
            uint256 tokenPriceInWei,
            string memory currencySymbol,
            address currencyAddress
        )
    {
        (isConfigured, tokenPriceInWei) = RAMLib.getPriceInfo({
            projectId: projectId,
            coreContract: coreContract
        });
        // currency is always ETH
        currencySymbol = "ETH";
        currencyAddress = address(0);
    }

    /**
     * @notice Gets minimum next bid value in Wei and slot index for project `projectId`
     * on core contract `coreContract`.
     * If in a pre-auction state, reverts if unconfigured, otherwise returns
     * the minimum initial bid price for the upcoming auction.
     * If in an active auction, returns the minimum next bid's value and slot
     * index.
     * If in a post-auction state, reverts if auction was a sellout, otherwise
     * returns the auction's reserve price and slot index 0 (because tokens may
     * still be purchasable at the reserve price).
     * @param projectId Project ID to get the minimum next bid value for
     * @param coreContract Core contract address for the given project
     * @return minNextBidValueInWei minimum next bid value in Wei
     * @return minNextBidSlotIndex slot index of the minimum next bid
     */
    function getMinimumNextBid(
        uint256 projectId,
        address coreContract
    )
        external
        view
        returns (uint256 minNextBidValueInWei, uint256 minNextBidSlotIndex)
    {
        (minNextBidValueInWei, minNextBidSlotIndex) = RAMLib.getMinimumNextBid({
            projectId: projectId,
            coreContract: coreContract
        });
    }

    /**
     * @notice Returns the value of the lowest bid in the project's auction,
     * in Wei.
     * Reverts if no bids exist in the auction.
     * @param projectId Project ID to get the lowest bid value for
     * @param coreContract Core contract address for the given project
     * @return minBidValue Value of the lowest bid in the auction, in Wei
     */
    function getLowestBidValue(
        uint256 projectId,
        address coreContract
    ) external view returns (uint256) {
        (, uint16 minBidSlotIndex) = RAMLib.getLowestBid({
            projectId: projectId,
            coreContract: coreContract
        });
        // translate slot index to bid value
        uint88 projectBasePrice = RAMLib
            .getRAMProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            })
            .basePrice;
        return
            RAMLib.slotIndexToBidValue({
                basePrice: projectBasePrice,
                slotIndex: minBidSlotIndex
            });
    }

    /**
     * @notice Convenience view function that returns the bid value associated
     * with a given slot index for the specified project's auction, in Wei.
     * Reverts if the slot index is out of range (greater than 511).
     * @param projectId Project ID to get the bid value for
     * @param coreContract Core contract address for the given project
     * @param slotIndex Slot index to get the bid value for
     */
    function slotIndexToBidValue(
        uint256 projectId,
        address coreContract,
        uint16 slotIndex
    ) external view returns (uint256) {
        uint88 projectBasePrice = RAMLib
            .getRAMProjectConfig({
                projectId: projectId,
                coreContract: coreContract
            })
            .basePrice;
        // @dev does not check if project configured to reduce bytecode size
        return
            RAMLib.slotIndexToBidValue({
                basePrice: projectBasePrice,
                slotIndex: slotIndex
            });
    }

    /**
     * @notice Returns balance of project `projectId` on core contract
     * `coreContract` on this minter contract.
     * @dev project balance is a failsafe backstop used to ensure that funds
     * from one project may never affect funds from another project on this
     * shared minter contract.
     * @param projectId Project ID to get the balance for
     * @param coreContract Core contract address for the given project
     */
    function getProjectBalance(
        uint256 projectId,
        address coreContract
    ) external view returns (uint256) {
        return
            RAMLib.getProjectBalance({
                projectId: projectId,
                coreContract: coreContract
            });
    }

    /**
     * @notice Exists for interface conformance only.
     * Use manuallyLimitProjectMaxInvocations to set the maximum invocations
     * for a project instead.
     */
    function syncProjectMaxInvocationsToCore(
        uint256 /*projectId*/,
        address /*coreContract*/
    ) public pure {
        revert("Action not supported");
    }
}