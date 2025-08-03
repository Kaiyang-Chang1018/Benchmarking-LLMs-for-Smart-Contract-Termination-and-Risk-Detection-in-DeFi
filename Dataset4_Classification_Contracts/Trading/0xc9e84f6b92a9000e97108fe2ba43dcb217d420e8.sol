// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.16;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "./interfaces/IAmplifi.sol";
import "./interfaces/IAmplifiNode.sol";
import "./interfaces/IUniswap.sol";
import {IAmplifierV2} from "./interfaces/IAmplifierV2.sol";
import "./FusePoolV2.sol";
import "./Types.sol";
import "./Events.sol";

/**
 * Amplifi
 * Website: https://perpetualyield.io/
 * Telegram: https://t.me/Amplifi_ERC
 * Twitter: https://twitter.com/amplifidefi
 */
contract AmplifiAmplifierV2 is Ownable, ReentrancyGuard, IAmplifierV2 {
    uint16 public maxMonths = 6;
    uint16 public maxAmplifiersPerMinter = 96;
    uint256 public gracePeriod = 30 days;
    uint256 public gammaPeriod = 72 days;
    uint256 public fuseWaitPeriod = 90 days;

    uint256 public totalAmplifiers = 0;
    mapping(uint256 => Types.AmplifierV2) private _amplifiers;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(uint256 => uint256)) public ownedAmplifiers;
    mapping(uint256 => uint256) public ownedAmplifiersIndex;
    mapping(uint256 => bool) public migratedAmplifiers;

    mapping(Types.FuseProduct => uint256) public fuseLockDurations;
    mapping(Types.FuseProduct => FusePoolV2) public fusePools;
    mapping(Types.FuseProduct => uint256) public boosts;

    uint256 public creationFee = 0.008 ether;
    uint256 public renewalFee = 0.008 ether;
    uint256 public fuseFee = 0.008 ether;
    uint256 public mintPrice = 20e18;

    uint256[20] public rates = [
        1009000000000,
        857650000000,
        729002500000,
        619652125000,
        526704306250,
        447698660313,
        380543861266,
        323462282076,
        274942939764,
        233701498800,
        198646273980,
        168849332883,
        143521932950,
        121993643008,
        103694596557,
        88140407073,
        74919346012,
        63681444110,
        54129227494,
        46009843370
    ];

    IAmplifi public immutable amplifi;
    IAmplifiNode public immutable oldAmplifiNode;
    IUniswapV2Router02 public immutable router;
    IERC20 public immutable USDC;

    Types.AmplifierFeeRecipients public feeRecipients;

    uint16 public claimFee = 750;
    // Basis for above fee values
    uint16 public constant bps = 10_000;

    constructor(IAmplifi _amplifi, IAmplifiNode _oldAmplifiNode, IUniswapV2Router02 _router, IERC20 _usdc) {
        amplifi = _amplifi;
        oldAmplifiNode = _oldAmplifiNode;
        router = _router;
        USDC = _usdc;

        feeRecipients = Types.AmplifierFeeRecipients(
            0xc766B8c9741BC804FCc378FdE75560229CA3AB1E,
            0x58c5a97c717cA3A7969F82D670A9b9FF16545C6F,
            0x454cD1e89df17cDB61D868C6D3dBC02bC2c38a17
        );

        fuseLockDurations[Types.FuseProduct.OneYear] = 365 days;
        fuseLockDurations[Types.FuseProduct.ThreeYears] = 365 days * 3;
        fuseLockDurations[Types.FuseProduct.FiveYears] = 365 days * 5;

        fusePools[Types.FuseProduct.OneYear] = new FusePoolV2(msg.sender, this, 365 days);
        fusePools[Types.FuseProduct.ThreeYears] = new FusePoolV2(msg.sender, this, 365 days * 3);
        fusePools[Types.FuseProduct.FiveYears] = new FusePoolV2(msg.sender, this, 365 days * 5);

        boosts[Types.FuseProduct.OneYear] = 2e18;
        boosts[Types.FuseProduct.ThreeYears] = 12e18;
        boosts[Types.FuseProduct.FiveYears] = 36e18;
    }

    function createAmplifier(uint256 _months) external payable nonReentrant returns (uint256) {
        uint256 payment = getRenewalFeeForMonths(_months) + creationFee;
        require(msg.value == payment, "Invalid Ether value provided");
        require(balanceOf[msg.sender] < maxAmplifiersPerMinter, "Too many amplifiers");
        require(amplifi.burnForAmplifier(msg.sender, mintPrice), "Not able to burn");

        uint256 id = _createAmplifier(_months);

        (bool success,) = feeRecipients.validatorAcquisition.call{value: payment}("");
        require(success, "Could not send ETH");

        return id;
    }

    function createAmplifierBatch(uint256 _amount, uint256 _months)
        external
        payable
        nonReentrant
        returns (uint256[] memory ids)
    {
        uint256 payment = (getRenewalFeeForMonths(_months) + creationFee) * _amount;
        require(msg.value == payment, "Invalid Ether value provided");
        require(balanceOf[msg.sender] + _amount <= maxAmplifiersPerMinter, "Too many amplifiers");
        require(amplifi.burnForAmplifier(msg.sender, mintPrice * _amount), "Not able to burn");

        ids = new uint256[](_amount);
        for (uint256 i = 0; i < _amount;) {
            ids[i] = _createAmplifier(_months);
            unchecked {
                ++i;
            }
        }

        (bool success,) = feeRecipients.validatorAcquisition.call{value: payment}("");
        require(success, "Could not send ETH");

        return ids;
    }

    function _createAmplifier(uint256 _months) internal returns (uint256) {
        require(_months > 0 && _months <= maxMonths, "Must be 1-6 months");

        uint256 id;
        unchecked {
            id = totalAmplifiers++;
        }

        _amplifiers[id] = Types.AmplifierV2({
            fuseProduct: Types.FuseProduct.None,
            minter: msg.sender,
            numClaims: 0,
            created: uint48(block.timestamp),
            expires: uint48(block.timestamp + 30 days * _months),
            lastClaimed: 0,
            fused: 0,
            unlocks: 0
        });

        uint256 length;
        unchecked {
            length = balanceOf[msg.sender]++;
        }
        ownedAmplifiers[msg.sender][length] = id;
        ownedAmplifiersIndex[id] = length;

        emit Events.AmplifierCreated(id, msg.sender, _months);

        return id;
    }

    function renewAmplifier(uint256 _id, uint256 _months) external payable nonReentrant {
        uint256 payment = getRenewalFeeForMonths(_months);
        require(msg.value == payment, "Invalid Ether value provided");

        _renewAmplifier(_id, _months);

        (bool success,) = feeRecipients.validatorAcquisition.call{value: payment}("");
        require(success, "Could not send ETH");
    }

    function renewAmplifierBatch(uint256[] calldata _ids, uint256 _months) external payable nonReentrant {
        uint256 length = _ids.length;
        uint256 payment = (getRenewalFeeForMonths(_months)) * length;
        require(msg.value == payment, "Invalid Ether value provided");

        for (uint256 i = 0; i < length;) {
            _renewAmplifier(_ids[i], _months);
            unchecked {
                ++i;
            }
        }

        (bool success,) = feeRecipients.validatorAcquisition.call{value: payment}("");
        require(success, "Could not send ETH");
    }

    function _renewAmplifier(uint256 _id, uint256 _months) internal {
        Types.AmplifierV2 storage amplifier = _amplifiers[_id];

        require(amplifier.minter == msg.sender, "Invalid ownership");
        require(amplifier.expires + gracePeriod >= block.timestamp, "Grace period expired");

        amplifier.expires += uint48(30 days * _months);

        require(amplifier.expires < block.timestamp + (30 days * maxMonths), "Too many months");

        emit Events.AmplifierRenewed(_id, msg.sender, _months);
    }

    function fuseAmplifier(uint256 _id, Types.FuseProduct fuseProduct) external payable nonReentrant {
        Types.AmplifierV2 storage amplifier = _amplifiers[_id];

        require(amplifier.minter == msg.sender, "Invalid ownership");
        require(amplifier.fuseProduct == Types.FuseProduct.None, "Already fused");
        require(amplifier.expires > block.timestamp, "Amplifier expired");

        require(msg.value == fuseFee, "Invalid Ether value provided");

        uint48 unlocks = fusePools[fuseProduct].enter(_id);

        amplifier.fuseProduct = fuseProduct;
        amplifier.fused = uint48(block.timestamp);
        amplifier.unlocks = unlocks;

        emit Events.AmplifierFused(_id, msg.sender, fuseProduct);

        (bool success,) = feeRecipients.validatorAcquisition.call{value: msg.value}("");
        require(success, "Could not send ETH");
    }

    function claimAMPLIFI(uint256 _id) external nonReentrant {
        uint256 amount = _claimAMPLIFI(_id);

        amount = takeClaimFee(amount);
        require(amplifi.transfer(msg.sender, amount));

        emit Events.AMPLIFIClaimed(msg.sender, amount);
    }

    function claimAMPLIFIBatch(uint256[] calldata _ids) external nonReentrant {
        uint256 amount;
        uint256 length = _ids.length;
        for (uint256 i = 0; i < length;) {
            amount += _claimAMPLIFI(_ids[i]);
            unchecked {
                ++i;
            }
        }

        amount = takeClaimFee(amount);
        require(amplifi.transfer(msg.sender, amount));

        emit Events.AMPLIFIClaimed(msg.sender, amount);
    }

    function _claimAMPLIFI(uint256 _id) internal returns (uint256 amount) {
        Types.AmplifierV2 storage amplifier = _amplifiers[_id];
        require(amplifier.minter == msg.sender, "Invalid ownership");
        require(amplifier.fuseProduct == Types.FuseProduct.None, "Must be unfused");
        require(amplifier.expires > block.timestamp, "Amplifier expired");

        amount = getPendingAMPLIFI(_id);

        amplifier.numClaims++;
        amplifier.lastClaimed = uint48(block.timestamp);
    }

    function claimETH(uint256 _id, uint256[] calldata _blockNumbers) external nonReentrant {
        _claimETH(_id, _blockNumbers);
    }

    function claimETHBatch(uint256[] calldata _ids, uint256[] calldata _blockNumbers) external nonReentrant {
        uint256 length = _ids.length;
        for (uint256 i = 0; i < length;) {
            _claimETH(_ids[i], _blockNumbers);
            unchecked {
                ++i;
            }
        }
    }

    function _claimETH(uint256 _id, uint256[] calldata _blockNumbers) internal {
        Types.AmplifierV2 storage amplifier = _amplifiers[_id];
        require(amplifier.fuseProduct != Types.FuseProduct.None, "Must be fused");
        require(block.timestamp - amplifier.fused > fuseWaitPeriod, "Cannot claim ETH yet");

        if (_blockNumbers.length != 0) {
            require(amplifier.expires > block.timestamp, "Amplifier expired");
            uint256 amount = fusePools[amplifier.fuseProduct].claim(_id, _blockNumbers);

            emit Events.ETHClaimed(_id, amplifier.minter, msg.sender, amount);
        }

        if (amplifier.unlocks <= block.timestamp) {
            if (amplifier.expires > block.timestamp) {
                require(amplifi.transfer(amplifier.minter, boosts[amplifier.fuseProduct]));
            }
            fusePools[amplifier.fuseProduct].exit(_id);
            amplifier.fuseProduct = Types.FuseProduct.None;
            amplifier.fused = 0;
            amplifier.unlocks = 0;
        }
    }

    function getPendingAMPLIFI(uint256 _id) public view returns (uint256) {
        Types.AmplifierV2 memory amplifier = _amplifiers[_id];

        uint256 rate = amplifier.numClaims >= rates.length ? rates[rates.length - 1] : rates[amplifier.numClaims];
        uint256 amount =
            (block.timestamp - (amplifier.numClaims > 0 ? amplifier.lastClaimed : amplifier.created)) * (rate);
        if (amplifier.created < block.timestamp + gammaPeriod) {
            uint256 _seconds = (block.timestamp + gammaPeriod) - amplifier.created;
            uint256 _percent = 100;
            if (_seconds >= 4838400) {
                _percent = 900;
            } else if (_seconds >= 4233600) {
                _percent = 800;
            } else if (_seconds >= 3628800) {
                _percent = 700;
            } else if (_seconds >= 3024000) {
                _percent = 600;
            } else if (_seconds >= 2419200) {
                _percent = 500;
            } else if (_seconds >= 1814400) {
                _percent = 400;
            } else if (_seconds >= 1209600) {
                _percent = 300;
            } else if (_seconds >= 604800) {
                _percent = 200;
            }
            uint256 _divisor = amount * _percent;
            (, uint256 result) = tryDiv(_divisor, 10000);
            amount -= result;
        }

        return amount;
    }

    function takeClaimFee(uint256 amount) internal returns (uint256) {
        uint256 fee = (amount * claimFee) / bps;

        address[] memory path = new address[](2);
        path[0] = address(amplifi);
        path[1] = address(USDC);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(fee, 0, path, address(this), block.timestamp);

        uint256 usdcToSend = USDC.balanceOf(address(this)) / 2;

        USDC.transfer(feeRecipients.operations, usdcToSend);
        USDC.transfer(feeRecipients.developers, usdcToSend);

        return amount - fee;
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) {
                return (false, 0);
            }
            return (true, a / b);
        }
    }

    function getRenewalFeeForMonths(uint256 _months) public view returns (uint256) {
        return renewalFee * _months;
    }

    function amplifiers(uint256 _id) public view override returns (Types.AmplifierV2 memory) {
        return _amplifiers[_id];
    }

    function airdropAmplifiers(
        address[] calldata _users,
        uint256[] calldata _months,
        Types.FuseProduct[] calldata _fuseProducts
    ) external onlyOwner returns (uint256[] memory ids) {
        require(_users.length == _months.length && _months.length == _fuseProducts.length, "Lengths not aligned");

        uint256 length = _users.length;
        ids = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            ids[i] = _airdropAmplifier(_users[i], _months[i], _fuseProducts[i]);
            unchecked {
                ++i;
            }
        }
        return ids;
    }

    function _airdropAmplifier(address _user, uint256 _months, Types.FuseProduct _fuseProduct)
        internal
        returns (uint256)
    {
        require(_months <= maxMonths, "Too many months");

        uint256 id;
        uint256 length;
        unchecked {
            id = totalAmplifiers++;
            length = balanceOf[_user]++;
        }

        uint48 fused;
        uint48 unlocks;

        if (_fuseProduct != Types.FuseProduct.None) {
            fused = uint48(block.timestamp);

            unlocks = fusePools[_fuseProduct].enter(id);
        }

        _amplifiers[id] = Types.AmplifierV2({
            fuseProduct: _fuseProduct,
            minter: _user,
            numClaims: 0,
            created: uint48(block.timestamp),
            expires: uint48(block.timestamp + 30 days * _months),
            lastClaimed: 0,
            fused: fused,
            unlocks: unlocks
        });

        ownedAmplifiers[_user][length] = id;
        ownedAmplifiersIndex[id] = length;

        return id;
    }

    function removeAmplifier(uint256 _id) external onlyOwner {
        uint256 lastAmplifierIndex = balanceOf[_amplifiers[_id].minter];
        uint256 amplifierIndex = ownedAmplifiersIndex[_id];

        if (amplifierIndex != lastAmplifierIndex) {
            uint256 lastAmplifierId = ownedAmplifiers[_amplifiers[_id].minter][lastAmplifierIndex];

            ownedAmplifiers[_amplifiers[_id].minter][amplifierIndex] = lastAmplifierId; // Move the last amplifier to the slot of the to-delete token
            ownedAmplifiersIndex[lastAmplifierId] = amplifierIndex; // Update the moved amplifier's index
        }

        // This also deletes the contents at the last position of the array
        delete ownedAmplifiersIndex[_id];
        delete ownedAmplifiers[_amplifiers[_id].minter][lastAmplifierIndex];

        balanceOf[_amplifiers[_id].minter]--;
        totalAmplifiers--;

        delete _amplifiers[_id];
    }

    function setRates(uint256[] calldata _rates) external onlyOwner {
        require(_rates.length == rates.length, "Invalid length");

        uint256 length = _rates.length;
        for (uint256 i = 0; i < length;) {
            rates[i] = _rates[i];
            unchecked {
                ++i;
            }
        }
    }

    function migrateV1Amplifiers(uint256[] calldata _ids) external returns (uint256[] memory) {
        uint256 length = _ids.length;
        uint256[] memory migratedIds = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            uint256 id = _ids[i];
            require(!migratedAmplifiers[id], "Amplifier already migrated");

            Types.Amplifier memory v1Amplifier = oldAmplifiNode.amplifiers(id);
            require(v1Amplifier.created != 0, "Amplifier doesn't exist");
            require(v1Amplifier.expires + gracePeriod >= block.timestamp, "Grace period expired");
            require(msg.sender == v1Amplifier.minter, "Amplifier can only be migrated by the minter");

            migratedAmplifiers[id] = true;
            migratedIds[i] = _createMigratedAmplifier(v1Amplifier, id);

            unchecked {
                ++i;
            }
        }
        return migratedIds;
    }

    function _createMigratedAmplifier(Types.Amplifier memory _v1Amplifier, uint256 _v1AmplifierId)
        internal
        returns (uint256)
    {
        uint256 id;
        unchecked {
            id = totalAmplifiers++;
        }

        _amplifiers[id] = Types.AmplifierV2({
            fuseProduct: _v1Amplifier.fuseProduct,
            minter: _v1Amplifier.minter,
            numClaims: uint16(_v1Amplifier.numClaims),
            created: uint48(_v1Amplifier.created),
            expires: uint48(_v1Amplifier.expires),
            lastClaimed: uint48(_v1Amplifier.lastClaimed),
            fused: uint48(_v1Amplifier.fused),
            unlocks: uint48(_v1Amplifier.unlocks)
        });

        if (_v1Amplifier.fuseProduct != Types.FuseProduct.None) {
            fusePools[_v1Amplifier.fuseProduct].migrateShare(id, uint48(_v1Amplifier.unlocks), false);
        }

        uint256 length;
        unchecked {
            length = balanceOf[_v1Amplifier.minter]++;
        }
        ownedAmplifiers[_v1Amplifier.minter][length] = id;
        ownedAmplifiersIndex[id] = length;

        emit Events.AmplifierMigrated(_v1AmplifierId, id, _v1Amplifier.minter);

        return id;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setMaxMonths(uint16 _maxMonths) external onlyOwner {
        maxMonths = _maxMonths;
    }

    function setFees(uint256 _creationFee, uint256 _renewalFee, uint256 _fuseFee, uint16 _claimFee)
        external
        onlyOwner
    {
        creationFee = _creationFee;
        renewalFee = _renewalFee;
        fuseFee = _fuseFee;
        claimFee = _claimFee;
    }

    function setFuseLockDurations(Types.FuseProduct _fuseProduct, uint256 _duration) external onlyOwner {
        fuseLockDurations[_fuseProduct] = _duration;
    }

    function setFusePool(Types.FuseProduct _fuseProduct, FusePoolV2 _fusePool) external onlyOwner {
        fusePools[_fuseProduct] = _fusePool;
    }

    function setBoosts(Types.FuseProduct _fuseProduct, uint256 _boost) external onlyOwner {
        boosts[_fuseProduct] = _boost;
    }

    function setFeeRecipients(Types.AmplifierFeeRecipients calldata _feeRecipients) external onlyOwner {
        feeRecipients = _feeRecipients;
    }

    function setPeriods(uint256 _gracePeriod, uint256 _gammaPeriod, uint256 _fuseWaitPeriod) external onlyOwner {
        gracePeriod = _gracePeriod;
        gammaPeriod = _gammaPeriod;
        fuseWaitPeriod = _fuseWaitPeriod;
    }

    function approveRouter() external onlyOwner {
        amplifi.approve(address(router), type(uint256).max);
    }

    function withdrawETH(address _recipient) external onlyOwner {
        (bool success,) = _recipient.call{value: address(this).balance}("");
        require(success, "Could not send ETH");
    }

    function withdrawToken(IERC20 _token, address _recipient) external onlyOwner {
        _token.transfer(_recipient, _token.balanceOf(address(this)));
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Types.sol";

library Events {
    event AmplifierCreated(uint256 indexed id, address indexed owner, uint256 months);

    event AmplifierRenewed(uint256 indexed id, address indexed owner, uint256 months);

    event AmplifierFused(uint256 indexed id, address indexed owner, Types.FuseProduct indexed fuseProduct);

    event AmplifierMigrated(uint256 indexed v1AmplifierId, uint256 indexed v2AmplifierId, address indexed owner);

    event AMPLIFIClaimed(address indexed owner, uint256 amount);

    event ETHClaimed(uint256 indexed id, address indexed owner, address indexed claimer, uint256 amount);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/utils/math/Math.sol";
import "openzeppelin-contracts/utils/math/SafeCast.sol";
import "./interfaces/IUniswap.sol";
import "./interfaces/INetworkV2.sol";
import {IAmplifierV2} from "./interfaces/IAmplifierV2.sol";
import "./Types.sol";

/**
 * Amplifi
 * Website: https://perpetualyield.io/
 * Telegram: https://t.me/Amplifi_ERC
 * Twitter: https://twitter.com/amplifidefi
 */
contract FusePoolV2 is INetworkV2, Ownable {
    uint256 immutable duration;

    IAmplifierV2 public amplifierContract;

    mapping(uint256 => mapping(uint256 => bool)) public hasClaimedPeriod;
    mapping(uint256 => Types.Pot) public potPerPeriod;
    mapping(uint256 => uint256) public fuseUnlocks;
    uint256 public totalSupply;

    mapping(uint256 => Types.Checkpoint[]) private _checkpoints;
    Types.Checkpoint[] private _totalSupplyCheckpoints;

    event PotAccrued(uint256 potAmount);
    event Claimed(uint256 indexed id, uint256 indexed potBlock, uint256 amount);

    modifier onlyAmplifier() {
        require(msg.sender == address(amplifierContract), "Only Amplifier");
        _;
    }

    constructor(address _owner, IAmplifierV2 _amplifierContract, uint256 _duration) {
        _transferOwnership(_owner);

        amplifierContract = _amplifierContract;
        duration = _duration;
    }

    function enter(uint256 _id) external onlyAmplifier returns (uint48) {
        require(fuseUnlocks[_id] == 0, "Share already exists");

        _checkpoints[_id].push(Types.Checkpoint({fromBlock: uint32(block.number), shares: 1}));
        _writeCheckpoint(_totalSupplyCheckpoints, _add, 1);
        totalSupply++;

        uint256 unlocks = duration + block.timestamp;
        fuseUnlocks[_id] = unlocks;

        return uint48(unlocks);
    }

    function exit(uint256 _id) external onlyAmplifier {
        require(fuseUnlocks[_id] <= block.timestamp, "Cannot exit yet");

        _checkpoints[_id].push(Types.Checkpoint({fromBlock: uint32(block.number), shares: 0}));
        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, 1);
        totalSupply--;
        fuseUnlocks[_id] = 0;
    }

    function migrateShare(uint256 _id, uint48 _unlocks, bool _allowOverwrite) external override onlyAmplifier {
        require(fuseUnlocks[_id] == 0 || _allowOverwrite, "Share already exists");

        _checkpoints[_id].push(Types.Checkpoint({fromBlock: uint32(block.number), shares: 1}));

        fuseUnlocks[_id] = _unlocks;

        unchecked {
            totalSupply++;
        }

        _writeCheckpoint(_totalSupplyCheckpoints, _add, 1);
    }

    function pot() external payable onlyOwner {
        potPerPeriod[block.number] =
            Types.Pot({timestamp: uint48(block.timestamp), value: SafeCast.toUint208(msg.value)});
        emit PotAccrued(msg.value);
    }

    function claim(uint256 _id, uint256[] calldata _blockNumbers) external onlyAmplifier returns (uint256) {
        uint256 owed;

        uint256 length = _blockNumbers.length;
        for (uint256 i = 0; i < length;) {
            uint256 claimAmount = _claim(_blockNumbers[i], _id);
            emit Claimed(_id, _blockNumbers[i], claimAmount);
            owed += claimAmount;
            unchecked {
                ++i;
            }
        }

        _claimPayments(owed, _id);

        return owed;
    }

    function _claim(uint256 _blockNumber, uint256 _id) internal returns (uint256) {
        require(!hasClaimedPeriod[_id][_blockNumber], "Already claimied this period");
        require(fuseUnlocks[_id] > potPerPeriod[_blockNumber].timestamp, "Period after unlock time");
        hasClaimedPeriod[_id][_blockNumber] = true;
        return getClaimAmount(_blockNumber, _id);
    }

    function _claimPayments(uint256 owed, uint256 _id) internal {
        require(owed > 0, "No ETH claimable");

        Types.AmplifierV2 memory amplifier = amplifierContract.amplifiers(_id);

        (bool success,) = amplifier.minter.call{value: owed}("");
        require(success, "Could not send ETH");
    }

    function _writeCheckpoint(
        Types.Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) internal returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].shares;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].shares = SafeCast.toUint224(newWeight);
        } else {
            ckpts.push(
                Types.Checkpoint({fromBlock: uint32(block.number), shares: SafeCast.toUint224(newWeight)})
            );
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    function getClaimAmount(uint256 _blockNumber, uint256 _id) public view returns (uint256) {
        return
            (getPastShares(_id, _blockNumber) * potPerPeriod[_blockNumber].value) / (getPastTotalSupply(_blockNumber));
    }

    function ETHOwed(uint256[] memory _blockNumbers, uint256 _id) public view returns (uint256) {
        uint256 owed = 0;
        for (uint256 i = 0; i < _blockNumbers.length;) {
            uint256 blockNumber = _blockNumbers[i];
            if (!hasClaimedPeriod[_id][blockNumber]) {
                owed += (getPastShares(_id, blockNumber) * potPerPeriod[blockNumber].value)
                    / (getPastTotalSupply(blockNumber));
            }

            unchecked {
                ++i;
            }
        }
        return owed;
    }

    function getPastShares(uint256 id, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "block not yet mined");
        return _checkpointsLookup(_checkpoints[id], blockNumber);
    }

    function getPastTotalSupply(uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    function _checkpointsLookup(Types.Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `blockNumber`.
        //
        // During the loop, the index of the wanted checkpoint remains in the range [low-1, high).
        // With each iteration, either `low` or `high` is moved towards the middle of the range to maintain the invariant.
        // - If the middle checkpoint is after `blockNumber`, we look in [low, mid)
        // - If the middle checkpoint is before or equal to `blockNumber`, we look in [mid+1, high)
        // Once we reach a single value (when low == high), we've found the right checkpoint at the index high-1, if not
        // out of bounds (in which case we're looking too far in the past and the result is 0).
        // Note that if the latest checkpoint available is exactly for `blockNumber`, we end up with an index that is
        // past the end of the array, so we technically don't find a checkpoint after `blockNumber`, but it works out
        // the same.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].shares;
    }

    function withdrawETH(address _recipient) external onlyOwner {
        (bool success,) = _recipient.call{value: address(this).balance}("");
        require(success, "Could not send ETH");
    }

    function withdrawToken(IERC20 _token, address _recipient) external onlyOwner {
        _token.transfer(_recipient, _token.balanceOf(address(this)));
    }

    function emergencyDeposit() external payable onlyOwner {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Types {
    struct FeeRecipients {
        address operations;
        address validatorAcquisition;
        address PCR;
        address yield;
        address xChainValidatorAcquisition;
        address indexFundPools;
        address gAMPRewardsPool;
        address OTCSwap;
        address rescueFund;
        address protocolImprovement;
        address developers;
    }

    struct Fees {
        uint16 operations;
        uint16 validatorAcquisition;
        uint16 PCR;
        uint16 yield;
        uint16 xChainValidatorAcquisition;
        uint16 indexFundPools;
        uint16 gAMPRewardsPool;
        uint16 OTCSwap;
        uint16 rescueFund;
        uint16 protocolImprovement;
        uint16 developers;
    }

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 started;
        uint256 unlocks;
    }

    enum FuseProduct {
        None,
        OneYear,
        ThreeYears,
        FiveYears
    }

    struct Amplifier {
        FuseProduct fuseProduct;
        address minter;
        uint256 created;
        uint256 expires;
        uint256 numClaims;
        uint256 lastClaimed;
        uint256 fused;
        uint256 unlocks;
        uint256 lastFuseClaimed;
    }

    struct AmplifierV2 {
        FuseProduct fuseProduct;
        address minter;
        uint16 numClaims;
        uint48 lastClaimed;
        uint48 created;
        uint48 expires;
        uint48 fused;
        uint48 unlocks;
    }

    struct AmplifierFeeRecipients {
        address operations;
        address validatorAcquisition;
        address developers;
    }

    struct Transistor {
        address minter;
        uint256 created;
        uint256 expires;
        uint256 numClaims;
        uint256 lastClaimed;
    }

    struct TransistorFeeRecipients {
        address creationFee;
        address creationTax;
        address renewalFee;
        address reverseFee;
        address claimFeeOperations;
        address claimFeeDevelopers;
    }

    struct Checkpoint {
        uint32 fromBlock;
        uint224 shares;
    }

    struct Pot {
        uint48 timestamp;
        uint208 value;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IAmplifi is IERC20 {
    function burnForAmplifier(address _burnee, uint256 _amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types} from "../Types.sol";

interface IAmplifiNode {
    function amplifiers(uint256) external view returns (Types.Amplifier memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Types} from "../Types.sol";

interface IAmplifierV2 {
    function amplifiers(uint256) external view returns (Types.AmplifierV2 memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface INetworkV2 {
    function enter(uint256 _id) external returns (uint48);

    function exit(uint256 _id) external;

    function migrateShare(uint256 _id, uint48 _unlocks, bool _allowOverwrite) external;

    function pot() external payable;

    function claim(uint256 _id, uint256[] calldata _blockNumbers) external returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}