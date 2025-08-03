// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsSubscriptions} from "./interfaces/IFunctionsSubscriptions.sol";
import {AggregatorV3Interface} from "../../../shared/interfaces/AggregatorV3Interface.sol";
import {IFunctionsBilling, FunctionsBillingConfig} from "./interfaces/IFunctionsBilling.sol";

import {Routable} from "./Routable.sol";
import {FunctionsResponse} from "./libraries/FunctionsResponse.sol";

import {SafeCast} from "../../../vendor/openzeppelin-solidity/v4.8.3/contracts/utils/math/SafeCast.sol";

import {ChainSpecificUtil} from "./libraries/ChainSpecificUtil.sol";

/// @title Functions Billing contract
/// @notice Contract that calculates payment from users to the nodes of the Decentralized Oracle Network (DON).
abstract contract FunctionsBilling is Routable, IFunctionsBilling {
  using FunctionsResponse for FunctionsResponse.RequestMeta;
  using FunctionsResponse for FunctionsResponse.Commitment;
  using FunctionsResponse for FunctionsResponse.FulfillResult;

  uint256 private constant REASONABLE_GAS_PRICE_CEILING = 1_000_000_000_000_000; // 1 million gwei

  event RequestBilled(
    bytes32 indexed requestId,
    uint96 juelsPerGas,
    uint256 l1FeeShareWei,
    uint96 callbackCostJuels,
    uint72 donFeeJuels,
    uint72 adminFeeJuels,
    uint72 operationFeeJuels
  );

  // ================================================================
  // |                  Request Commitment state                    |
  // ================================================================

  mapping(bytes32 requestId => bytes32 commitmentHash) private s_requestCommitments;

  event CommitmentDeleted(bytes32 requestId);

  FunctionsBillingConfig private s_config;

  event ConfigUpdated(FunctionsBillingConfig config);

  error UnsupportedRequestDataVersion();
  error InsufficientBalance();
  error InvalidSubscription();
  error UnauthorizedSender();
  error MustBeSubOwner(address owner);
  error InvalidLinkWeiPrice(int256 linkWei);
  error InvalidUsdLinkPrice(int256 usdLink);
  error PaymentTooLarge();
  error NoTransmittersSet();
  error InvalidCalldata();

  // ================================================================
  // |                        Balance state                         |
  // ================================================================

  mapping(address transmitter => uint96 balanceJuelsLink) private s_withdrawableTokens;
  // Pool together collected DON fees
  // Disperse them on withdrawal or change in OCR configuration
  uint96 internal s_feePool;

  AggregatorV3Interface private s_linkToNativeFeed;
  AggregatorV3Interface private s_linkToUsdFeed;

  // ================================================================
  // |                       Initialization                         |
  // ================================================================
  constructor(
    address router,
    FunctionsBillingConfig memory config,
    address linkToNativeFeed,
    address linkToUsdFeed
  ) Routable(router) {
    s_linkToNativeFeed = AggregatorV3Interface(linkToNativeFeed);
    s_linkToUsdFeed = AggregatorV3Interface(linkToUsdFeed);

    updateConfig(config);
  }

  // ================================================================
  // |                        Configuration                         |
  // ================================================================

  /// @notice Gets the Chainlink Coordinator's billing configuration
  /// @return config
  function getConfig() external view returns (FunctionsBillingConfig memory) {
    return s_config;
  }

  /// @notice Sets the Chainlink Coordinator's billing configuration
  /// @param config - See the contents of the FunctionsBillingConfig struct in IFunctionsBilling.sol for more information
  function updateConfig(FunctionsBillingConfig memory config) public {
    _onlyOwner();

    s_config = config;
    emit ConfigUpdated(config);
  }

  // ================================================================
  // |                       Fee Calculation                        |
  // ================================================================

  /// @inheritdoc IFunctionsBilling
  function getDONFeeJuels(bytes memory /* requestData */) public view override returns (uint72) {
    // s_config.donFee is in cents of USD. Convert to dollars amount then get amount of Juels.
    return SafeCast.toUint72(_getJuelsFromUsd(s_config.donFeeCentsUsd) / 100);
  }

  /// @inheritdoc IFunctionsBilling
  function getOperationFeeJuels() public view override returns (uint72) {
    // s_config.donFee is in cents of USD. Convert to dollars then get amount of Juels.
    return SafeCast.toUint72(_getJuelsFromUsd(s_config.operationFeeCentsUsd) / 100);
  }

  /// @inheritdoc IFunctionsBilling
  function getAdminFeeJuels() public view override returns (uint72) {
    return _getRouter().getAdminFee();
  }

  /// @inheritdoc IFunctionsBilling
  function getWeiPerUnitLink() public view returns (uint256) {
    (, int256 weiPerUnitLink, , uint256 timestamp, ) = s_linkToNativeFeed.latestRoundData();
    // Only fallback if feedStalenessSeconds is set
    // solhint-disable-next-line not-rely-on-time
    if (s_config.feedStalenessSeconds < block.timestamp - timestamp && s_config.feedStalenessSeconds > 0) {
      return s_config.fallbackNativePerUnitLink;
    }
    if (weiPerUnitLink <= 0) {
      revert InvalidLinkWeiPrice(weiPerUnitLink);
    }
    return uint256(weiPerUnitLink);
  }

  function _getJuelsFromWei(uint256 amountWei) private view returns (uint96) {
    // (1e18 juels/link) * wei / (wei/link) = juels
    // There are only 1e9*1e18 = 1e27 juels in existence, should not exceed uint96 (2^96 ~ 7e28)
    return SafeCast.toUint96((1e18 * amountWei) / getWeiPerUnitLink());
  }

  /// @inheritdoc IFunctionsBilling
  function getUsdPerUnitLink() public view returns (uint256, uint8) {
    (, int256 usdPerUnitLink, , uint256 timestamp, ) = s_linkToUsdFeed.latestRoundData();
    // Only fallback if feedStalenessSeconds is set
    // solhint-disable-next-line not-rely-on-time
    if (s_config.feedStalenessSeconds < block.timestamp - timestamp && s_config.feedStalenessSeconds > 0) {
      return (s_config.fallbackUsdPerUnitLink, s_config.fallbackUsdPerUnitLinkDecimals);
    }
    if (usdPerUnitLink <= 0) {
      revert InvalidUsdLinkPrice(usdPerUnitLink);
    }
    return (uint256(usdPerUnitLink), s_linkToUsdFeed.decimals());
  }

  function _getJuelsFromUsd(uint256 amountUsd) private view returns (uint96) {
    (uint256 usdPerLink, uint8 decimals) = getUsdPerUnitLink();
    // (usd) * (10**18 juels/link) * (10**decimals) / (link / usd) = juels
    // There are only 1e9*1e18 = 1e27 juels in existence, should not exceed uint96 (2^96 ~ 7e28)
    return SafeCast.toUint96((amountUsd * 10 ** (18 + decimals)) / usdPerLink);
  }

  // ================================================================
  // |                       Cost Estimation                        |
  // ================================================================

  /// @inheritdoc IFunctionsBilling
  function estimateCost(
    uint64 subscriptionId,
    bytes calldata data,
    uint32 callbackGasLimit,
    uint256 gasPriceWei
  ) external view override returns (uint96) {
    _getRouter().isValidCallbackGasLimit(subscriptionId, callbackGasLimit);
    // Reasonable ceilings to prevent integer overflows
    if (gasPriceWei > REASONABLE_GAS_PRICE_CEILING) {
      revert InvalidCalldata();
    }
    uint72 adminFee = getAdminFeeJuels();
    uint72 donFee = getDONFeeJuels(data);
    uint72 operationFee = getOperationFeeJuels();
    return _calculateCostEstimate(callbackGasLimit, gasPriceWei, donFee, adminFee, operationFee);
  }

  /// @notice Estimate the cost in Juels of LINK
  // that will be charged to a subscription to fulfill a Functions request
  // Gas Price can be overestimated to account for flucuations between request and response time
  function _calculateCostEstimate(
    uint32 callbackGasLimit,
    uint256 gasPriceWei,
    uint72 donFeeJuels,
    uint72 adminFeeJuels,
    uint72 operationFeeJuels
  ) internal view returns (uint96) {
    // If gas price is less than the minimum fulfillment gas price, override to using the minimum
    if (gasPriceWei < s_config.minimumEstimateGasPriceWei) {
      gasPriceWei = s_config.minimumEstimateGasPriceWei;
    }

    uint256 executionGas = s_config.gasOverheadBeforeCallback + s_config.gasOverheadAfterCallback + callbackGasLimit;
    uint256 l1FeeWei = ChainSpecificUtil._getL1FeeUpperLimit(s_config.transmitTxSizeBytes);
    uint256 totalFeeWei = (gasPriceWei * executionGas) + l1FeeWei;

    // Basis Points are 1/100th of 1%, divide by 10_000 to bring back to original units
    uint256 totalFeeWeiWithOverestimate = totalFeeWei +
      ((totalFeeWei * s_config.fulfillmentGasPriceOverEstimationBP) / 10_000);

    uint96 estimatedGasReimbursementJuels = _getJuelsFromWei(totalFeeWeiWithOverestimate);

    uint96 feesJuels = uint96(donFeeJuels) + uint96(adminFeeJuels) + uint96(operationFeeJuels);

    return estimatedGasReimbursementJuels + feesJuels;
  }

  // ================================================================
  // |                           Billing                            |
  // ================================================================

  /// @notice Initiate the billing process for an Functions request
  /// @dev Only callable by the Functions Router
  /// @param request - Chainlink Functions request data, see FunctionsResponse.RequestMeta for the structure
  /// @return commitment - The parameters of the request that must be held consistent at response time
  function _startBilling(
    FunctionsResponse.RequestMeta memory request
  ) internal returns (FunctionsResponse.Commitment memory commitment, uint72 operationFee) {
    // Nodes should support all past versions of the structure
    if (request.dataVersion > s_config.maxSupportedRequestDataVersion) {
      revert UnsupportedRequestDataVersion();
    }

    uint72 donFee = getDONFeeJuels(request.data);
    operationFee = getOperationFeeJuels();
    uint96 estimatedTotalCostJuels = _calculateCostEstimate(
      request.callbackGasLimit,
      tx.gasprice,
      donFee,
      request.adminFee,
      operationFee
    );

    // Check that subscription can afford the estimated cost
    if ((request.availableBalance) < estimatedTotalCostJuels) {
      revert InsufficientBalance();
    }

    uint32 timeoutTimestamp = uint32(block.timestamp + s_config.requestTimeoutSeconds);
    bytes32 requestId = keccak256(
      abi.encode(
        address(this),
        request.requestingContract,
        request.subscriptionId,
        request.initiatedRequests + 1,
        keccak256(request.data),
        request.dataVersion,
        request.callbackGasLimit,
        estimatedTotalCostJuels,
        timeoutTimestamp,
        // solhint-disable-next-line avoid-tx-origin
        tx.origin
      )
    );

    commitment = FunctionsResponse.Commitment({
      adminFee: request.adminFee,
      coordinator: address(this),
      client: request.requestingContract,
      subscriptionId: request.subscriptionId,
      callbackGasLimit: request.callbackGasLimit,
      estimatedTotalCostJuels: estimatedTotalCostJuels,
      timeoutTimestamp: timeoutTimestamp,
      requestId: requestId,
      donFee: donFee,
      gasOverheadBeforeCallback: s_config.gasOverheadBeforeCallback,
      gasOverheadAfterCallback: s_config.gasOverheadAfterCallback
    });

    s_requestCommitments[requestId] = keccak256(abi.encode(commitment));

    return (commitment, operationFee);
  }

  /// @notice Finalize billing process for an Functions request by sending a callback to the Client contract and then charging the subscription
  /// @param requestId identifier for the request that was generated by the Registry in the beginBilling commitment
  /// @param response response data from DON consensus
  /// @param err error from DON consensus
  /// @param reportBatchSize the number of fulfillments in the transmitter's report
  /// @return result fulfillment result
  /// @dev Only callable by a node that has been approved on the Coordinator
  /// @dev simulated offchain to determine if sufficient balance is present to fulfill the request
  function _fulfillAndBill(
    bytes32 requestId,
    bytes memory response,
    bytes memory err,
    bytes memory onchainMetadata,
    bytes memory /* offchainMetadata TODO: use in getDonFee() for dynamic billing */,
    uint8 reportBatchSize
  ) internal returns (FunctionsResponse.FulfillResult) {
    FunctionsResponse.Commitment memory commitment = abi.decode(onchainMetadata, (FunctionsResponse.Commitment));

    uint256 gasOverheadWei = (commitment.gasOverheadBeforeCallback + commitment.gasOverheadAfterCallback) * tx.gasprice;
    uint256 l1FeeShareWei = ChainSpecificUtil._getL1FeeUpperLimit(msg.data.length) / reportBatchSize;
    // Gas overhead without callback
    uint96 gasOverheadJuels = _getJuelsFromWei(gasOverheadWei + l1FeeShareWei);
    uint96 juelsPerGas = _getJuelsFromWei(tx.gasprice);

    // The Functions Router will perform the callback to the client contract
    (FunctionsResponse.FulfillResult resultCode, uint96 callbackCostJuels) = _getRouter().fulfill(
      response,
      err,
      juelsPerGas,
      // The following line represents: "cost without callback or admin fee, those will be added by the Router"
      // But because the _offchain_ Commitment is using operation fee in the place of the admin fee, this now adds admin fee (actually operation fee)
      // Admin fee is configured to 0 in the Router
      gasOverheadJuels + commitment.donFee + commitment.adminFee,
      msg.sender,
      FunctionsResponse.Commitment({
        adminFee: 0, // The Router should have adminFee set to 0. If it does not this will cause fulfillments to fail with INVALID_COMMITMENT instead of carrying out incorrect bookkeeping.
        coordinator: commitment.coordinator,
        client: commitment.client,
        subscriptionId: commitment.subscriptionId,
        callbackGasLimit: commitment.callbackGasLimit,
        estimatedTotalCostJuels: commitment.estimatedTotalCostJuels,
        timeoutTimestamp: commitment.timeoutTimestamp,
        requestId: commitment.requestId,
        donFee: commitment.donFee,
        gasOverheadBeforeCallback: commitment.gasOverheadBeforeCallback,
        gasOverheadAfterCallback: commitment.gasOverheadAfterCallback
      })
    );

    // The router will only pay the DON on successfully processing the fulfillment
    // In these two fulfillment results the user has been charged
    // Otherwise, the Coordinator should hold on to the request commitment
    if (
      resultCode == FunctionsResponse.FulfillResult.FULFILLED ||
      resultCode == FunctionsResponse.FulfillResult.USER_CALLBACK_ERROR
    ) {
      delete s_requestCommitments[requestId];
      // Reimburse the transmitter for the fulfillment gas cost
      s_withdrawableTokens[msg.sender] += gasOverheadJuels + callbackCostJuels;
      // Put donFee into the pool of fees, to be split later
      // Saves on storage writes that would otherwise be charged to the user
      s_feePool += commitment.donFee;
      // Pay the operation fee to the Coordinator owner
      s_withdrawableTokens[_owner()] += commitment.adminFee; // OperationFee is used in the slot for Admin Fee in the Offchain Commitment. Admin Fee is set to 0 in the Router (enforced by line 316 in FunctionsBilling.sol).
      emit RequestBilled({
        requestId: requestId,
        juelsPerGas: juelsPerGas,
        l1FeeShareWei: l1FeeShareWei,
        callbackCostJuels: callbackCostJuels,
        donFeeJuels: commitment.donFee,
        // The following two lines are because of OperationFee being used in the Offchain Commitment
        adminFeeJuels: 0,
        operationFeeJuels: commitment.adminFee
      });
    }
    return resultCode;
  }

  // ================================================================
  // |                       Request Timeout                        |
  // ================================================================

  /// @inheritdoc IFunctionsBilling
  /// @dev Only callable by the Router
  /// @dev Used by FunctionsRouter.sol during timeout of a request
  function deleteCommitment(bytes32 requestId) external override onlyRouter {
    // Delete commitment
    delete s_requestCommitments[requestId];
    emit CommitmentDeleted(requestId);
  }

  // ================================================================
  // |                    Fund withdrawal                           |
  // ================================================================

  /// @inheritdoc IFunctionsBilling
  function oracleWithdraw(address recipient, uint96 amount) external {
    _disperseFeePool();

    if (amount == 0) {
      amount = s_withdrawableTokens[msg.sender];
    } else if (s_withdrawableTokens[msg.sender] < amount) {
      revert InsufficientBalance();
    }
    s_withdrawableTokens[msg.sender] -= amount;
    IFunctionsSubscriptions(address(_getRouter())).oracleWithdraw(recipient, amount);
  }

  /// @inheritdoc IFunctionsBilling
  /// @dev Only callable by the Coordinator owner
  function oracleWithdrawAll() external {
    _onlyOwner();
    _disperseFeePool();

    address[] memory transmitters = _getTransmitters();

    // Bounded by "maxNumOracles" on OCR2Abstract.sol
    for (uint256 i = 0; i < transmitters.length; ++i) {
      uint96 balance = s_withdrawableTokens[transmitters[i]];
      if (balance > 0) {
        s_withdrawableTokens[transmitters[i]] = 0;
        IFunctionsSubscriptions(address(_getRouter())).oracleWithdraw(transmitters[i], balance);
      }
    }
  }

  // Overriden in FunctionsCoordinator, which has visibility into transmitters
  function _getTransmitters() internal view virtual returns (address[] memory);

  // DON fees are collected into a pool s_feePool
  // When OCR configuration changes, or any oracle withdraws, this must be dispersed
  function _disperseFeePool() internal {
    if (s_feePool == 0) {
      return;
    }
    // All transmitters are assumed to also be observers
    // Pay out the DON fee to all transmitters
    address[] memory transmitters = _getTransmitters();
    uint256 numberOfTransmitters = transmitters.length;
    if (numberOfTransmitters == 0) {
      revert NoTransmittersSet();
    }
    uint96 feePoolShare = s_feePool / uint96(numberOfTransmitters);
    if (feePoolShare == 0) {
      // Dust cannot be evenly distributed to all transmitters
      return;
    }
    // Bounded by "maxNumOracles" on OCR2Abstract.sol
    for (uint256 i = 0; i < numberOfTransmitters; ++i) {
      s_withdrawableTokens[transmitters[i]] += feePoolShare;
    }
    s_feePool -= feePoolShare * uint96(numberOfTransmitters);
  }

  // Overriden in FunctionsCoordinator.sol
  function _onlyOwner() internal view virtual;

  // Used in FunctionsCoordinator.sol
  function _isExistingRequest(bytes32 requestId) internal view returns (bool) {
    return s_requestCommitments[requestId] != bytes32(0);
  }

  // Overriden in FunctionsCoordinator.sol
  function _owner() internal view virtual returns (address owner);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsRouter} from "./interfaces/IFunctionsRouter.sol";
import {IFunctionsClient} from "./interfaces/IFunctionsClient.sol";

import {FunctionsRequest} from "./libraries/FunctionsRequest.sol";

/// @title The Chainlink Functions client contract
/// @notice Contract developers can inherit this contract in order to make Chainlink Functions requests
abstract contract FunctionsClient is IFunctionsClient {
  using FunctionsRequest for FunctionsRequest.Request;

  IFunctionsRouter internal immutable i_functionsRouter;

  event RequestSent(bytes32 indexed id);
  event RequestFulfilled(bytes32 indexed id);

  error OnlyRouterCanFulfill();

  constructor(address router) {
    i_functionsRouter = IFunctionsRouter(router);
  }

  /// @notice Sends a Chainlink Functions request
  /// @param data The CBOR encoded bytes data for a Functions request
  /// @param subscriptionId The subscription ID that will be charged to service the request
  /// @param callbackGasLimit - The amount of gas that will be available for the fulfillment callback
  /// @param donId - An identifier used to determine which route to send the request along
  /// @return requestId The generated request ID for this request
  function _sendRequest(
    bytes memory data,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    bytes32 donId
  ) internal returns (bytes32) {
    bytes32 requestId = i_functionsRouter.sendRequest(
      subscriptionId,
      data,
      FunctionsRequest.REQUEST_DATA_VERSION,
      callbackGasLimit,
      donId
    );
    emit RequestSent(requestId);
    return requestId;
  }

  /// @notice User defined function to handle a response from the DON
  /// @param requestId The request ID, returned by sendRequest()
  /// @param response Aggregated response from the execution of the user's source code
  /// @param err Aggregated error from the execution of the user code or from the execution pipeline
  /// @dev Either response or error parameter will be set, but never both
  function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal virtual;

  /// @inheritdoc IFunctionsClient
  function handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err) external override {
    if (msg.sender != address(i_functionsRouter)) {
      revert OnlyRouterCanFulfill();
    }
    _fulfillRequest(requestId, response, err);
    emit RequestFulfilled(requestId);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsCoordinator} from "./interfaces/IFunctionsCoordinator.sol";
import {ITypeAndVersion} from "../../../shared/interfaces/ITypeAndVersion.sol";

import {FunctionsBilling, FunctionsBillingConfig} from "./FunctionsBilling.sol";
import {OCR2Base} from "./ocr/OCR2Base.sol";
import {FunctionsResponse} from "./libraries/FunctionsResponse.sol";

/// @title Functions Coordinator contract
/// @notice Contract that nodes of a Decentralized Oracle Network (DON) interact with
contract FunctionsCoordinator is OCR2Base, IFunctionsCoordinator, FunctionsBilling {
  using FunctionsResponse for FunctionsResponse.RequestMeta;
  using FunctionsResponse for FunctionsResponse.Commitment;
  using FunctionsResponse for FunctionsResponse.FulfillResult;

  /// @inheritdoc ITypeAndVersion
  string public constant override typeAndVersion = "Functions Coordinator v1.3.1";

  event OracleRequest(
    bytes32 indexed requestId,
    address indexed requestingContract,
    address requestInitiator,
    uint64 subscriptionId,
    address subscriptionOwner,
    bytes data,
    uint16 dataVersion,
    bytes32 flags,
    uint64 callbackGasLimit,
    FunctionsResponse.Commitment commitment
  );
  event OracleResponse(bytes32 indexed requestId, address transmitter);

  error InconsistentReportData();
  error EmptyPublicKey();
  error UnauthorizedPublicKeyChange();

  bytes private s_donPublicKey;
  bytes private s_thresholdPublicKey;

  constructor(
    address router,
    FunctionsBillingConfig memory config,
    address linkToNativeFeed,
    address linkToUsdFeed
  ) OCR2Base() FunctionsBilling(router, config, linkToNativeFeed, linkToUsdFeed) {}

  /// @inheritdoc IFunctionsCoordinator
  function getThresholdPublicKey() external view override returns (bytes memory) {
    if (s_thresholdPublicKey.length == 0) {
      revert EmptyPublicKey();
    }
    return s_thresholdPublicKey;
  }

  /// @inheritdoc IFunctionsCoordinator
  function setThresholdPublicKey(bytes calldata thresholdPublicKey) external override onlyOwner {
    if (thresholdPublicKey.length == 0) {
      revert EmptyPublicKey();
    }
    s_thresholdPublicKey = thresholdPublicKey;
  }

  /// @inheritdoc IFunctionsCoordinator
  function getDONPublicKey() external view override returns (bytes memory) {
    if (s_donPublicKey.length == 0) {
      revert EmptyPublicKey();
    }
    return s_donPublicKey;
  }

  /// @inheritdoc IFunctionsCoordinator
  function setDONPublicKey(bytes calldata donPublicKey) external override onlyOwner {
    if (donPublicKey.length == 0) {
      revert EmptyPublicKey();
    }
    s_donPublicKey = donPublicKey;
  }

  /// @dev check if node is in current transmitter list
  function _isTransmitter(address node) internal view returns (bool) {
    // Bounded by "maxNumOracles" on OCR2Abstract.sol
    for (uint256 i = 0; i < s_transmitters.length; ++i) {
      if (s_transmitters[i] == node) {
        return true;
      }
    }
    return false;
  }

  /// @inheritdoc IFunctionsCoordinator
  function startRequest(
    FunctionsResponse.RequestMeta calldata request
  ) external override onlyRouter returns (FunctionsResponse.Commitment memory commitment) {
    uint72 operationFee;
    (commitment, operationFee) = _startBilling(request);

    emit OracleRequest(
      commitment.requestId,
      request.requestingContract,
      // solhint-disable-next-line avoid-tx-origin
      tx.origin,
      request.subscriptionId,
      request.subscriptionOwner,
      request.data,
      request.dataVersion,
      request.flags,
      request.callbackGasLimit,
      FunctionsResponse.Commitment({
        coordinator: commitment.coordinator,
        client: commitment.client,
        subscriptionId: commitment.subscriptionId,
        callbackGasLimit: commitment.callbackGasLimit,
        estimatedTotalCostJuels: commitment.estimatedTotalCostJuels,
        timeoutTimestamp: commitment.timeoutTimestamp,
        requestId: commitment.requestId,
        donFee: commitment.donFee,
        gasOverheadBeforeCallback: commitment.gasOverheadBeforeCallback,
        gasOverheadAfterCallback: commitment.gasOverheadAfterCallback,
        // The following line is done to use the Coordinator's operationFee in place of the Router's operation fee
        // With this in place the Router.adminFee must be set to 0 in the Router.
        adminFee: operationFee
      })
    );

    return commitment;
  }

  /// @dev DON fees are pooled together. If the OCR configuration is going to change, these need to be distributed.
  function _beforeSetConfig(uint8 /* _f */, bytes memory /* _onchainConfig */) internal override {
    if (_getTransmitters().length > 0) {
      _disperseFeePool();
    }
  }

  /// @dev Used by FunctionsBilling.sol
  function _getTransmitters() internal view override returns (address[] memory) {
    return s_transmitters;
  }

  function _beforeTransmit(
    bytes calldata report
  ) internal view override returns (bool shouldStop, DecodedReport memory decodedReport) {
    (
      bytes32[] memory requestIds,
      bytes[] memory results,
      bytes[] memory errors,
      bytes[] memory onchainMetadata,
      bytes[] memory offchainMetadata
    ) = abi.decode(report, (bytes32[], bytes[], bytes[], bytes[], bytes[]));
    uint256 numberOfFulfillments = uint8(requestIds.length);

    if (
      numberOfFulfillments == 0 ||
      numberOfFulfillments != results.length ||
      numberOfFulfillments != errors.length ||
      numberOfFulfillments != onchainMetadata.length ||
      numberOfFulfillments != offchainMetadata.length
    ) {
      revert ReportInvalid("Fields must be equal length");
    }

    for (uint256 i = 0; i < numberOfFulfillments; ++i) {
      if (_isExistingRequest(requestIds[i])) {
        // If there is an existing request, validate report
        // Leave shouldStop to default, false
        break;
      }
      if (i == numberOfFulfillments - 1) {
        // If the last fulfillment on the report does not exist, then all are duplicates
        // Indicate that it's safe to stop to save on the gas of validating the report
        shouldStop = true;
      }
    }

    return (
      shouldStop,
      DecodedReport({
        requestIds: requestIds,
        results: results,
        errors: errors,
        onchainMetadata: onchainMetadata,
        offchainMetadata: offchainMetadata
      })
    );
  }

  /// @dev Report hook called within OCR2Base.sol
  function _report(DecodedReport memory decodedReport) internal override {
    uint256 numberOfFulfillments = uint8(decodedReport.requestIds.length);

    // Bounded by "MaxRequestBatchSize" on the Job's ReportingPluginConfig
    for (uint256 i = 0; i < numberOfFulfillments; ++i) {
      FunctionsResponse.FulfillResult result = FunctionsResponse.FulfillResult(
        _fulfillAndBill(
          decodedReport.requestIds[i],
          decodedReport.results[i],
          decodedReport.errors[i],
          decodedReport.onchainMetadata[i],
          decodedReport.offchainMetadata[i],
          uint8(numberOfFulfillments) // will not exceed "MaxRequestBatchSize" on the Job's ReportingPluginConfig
        )
      );

      // Emit on successfully processing the fulfillment
      // In these two fulfillment results the user has been charged
      // Otherwise, the DON will re-try
      if (
        result == FunctionsResponse.FulfillResult.FULFILLED ||
        result == FunctionsResponse.FulfillResult.USER_CALLBACK_ERROR
      ) {
        emit OracleResponse(decodedReport.requestIds[i], msg.sender);
      }
    }
  }

  /// @dev Used in FunctionsBilling.sol
  function _onlyOwner() internal view override {
    _validateOwnership();
  }

  /// @dev Used in FunctionsBilling.sol
  function _owner() internal view override returns (address owner) {
    return this.owner();
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITypeAndVersion} from "../../../shared/interfaces/ITypeAndVersion.sol";
import {IFunctionsRouter} from "./interfaces/IFunctionsRouter.sol";
import {IFunctionsCoordinator} from "./interfaces/IFunctionsCoordinator.sol";
import {IAccessController} from "../../../shared/interfaces/IAccessController.sol";

import {FunctionsSubscriptions} from "./FunctionsSubscriptions.sol";
import {FunctionsResponse} from "./libraries/FunctionsResponse.sol";
import {ConfirmedOwner} from "../../../shared/access/ConfirmedOwner.sol";

import {SafeCast} from "../../../vendor/openzeppelin-solidity/v4.8.3/contracts/utils/math/SafeCast.sol";
import {Pausable} from "../../../vendor/openzeppelin-solidity/v4.8.3/contracts/security/Pausable.sol";

contract FunctionsRouter is IFunctionsRouter, FunctionsSubscriptions, Pausable, ITypeAndVersion, ConfirmedOwner {
  using FunctionsResponse for FunctionsResponse.RequestMeta;
  using FunctionsResponse for FunctionsResponse.Commitment;
  using FunctionsResponse for FunctionsResponse.FulfillResult;

  string public constant override typeAndVersion = "Functions Router v2.0.0";

  // We limit return data to a selector plus 4 words. This is to avoid
  // malicious contracts from returning large amounts of data and causing
  // repeated out-of-gas scenarios.
  uint16 public constant MAX_CALLBACK_RETURN_BYTES = 4 + 4 * 32;
  uint8 private constant MAX_CALLBACK_GAS_LIMIT_FLAGS_INDEX = 0;

  event RequestStart(
    bytes32 indexed requestId,
    bytes32 indexed donId,
    uint64 indexed subscriptionId,
    address subscriptionOwner,
    address requestingContract,
    address requestInitiator,
    bytes data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    uint96 estimatedTotalCostJuels
  );

  event RequestProcessed(
    bytes32 indexed requestId,
    uint64 indexed subscriptionId,
    uint96 totalCostJuels,
    address transmitter,
    FunctionsResponse.FulfillResult resultCode,
    bytes response,
    bytes err,
    bytes callbackReturnData
  );

  event RequestNotProcessed(
    bytes32 indexed requestId,
    address coordinator,
    address transmitter,
    FunctionsResponse.FulfillResult resultCode
  );

  error EmptyRequestData();
  error OnlyCallableFromCoordinator();
  error SenderMustAcceptTermsOfService(address sender);
  error InvalidGasFlagValue(uint8 value);
  error GasLimitTooBig(uint32 limit);
  error DuplicateRequestId(bytes32 requestId);

  struct CallbackResult {
    bool success; // ══════╸ Whether the callback succeeded or not
    uint256 gasUsed; // ═══╸ The amount of gas consumed during the callback
    bytes returnData; // ══╸ The return of the callback function
  }

  // ================================================================
  // |                    Route state                       |
  // ================================================================

  mapping(bytes32 id => address routableContract) private s_route;

  error RouteNotFound(bytes32 id);

  // Identifier for the route to the Terms of Service Allow List
  bytes32 private s_allowListId;

  // ================================================================
  // |                    Configuration state                       |
  // ================================================================
  // solhint-disable-next-line gas-struct-packing
  struct Config {
    uint16 maxConsumersPerSubscription; // ═════════╗ Maximum number of consumers which can be added to a single subscription. This bound ensures we are able to loop over all subscription consumers as needed, without exceeding gas limits. Should a user require more consumers, they can use multiple subscriptions.
    uint72 adminFee; //                             ║ Flat fee (in Juels of LINK) that will be paid to the Router owner for operation of the network
    bytes4 handleOracleFulfillmentSelector; //      ║ The function selector that is used when calling back to the Client contract
    uint16 gasForCallExactCheck; // ════════════════╝ Used during calling back to the client. Ensures we have at least enough gas to be able to revert if gasAmount >  63//64*gas available.
    uint32[] maxCallbackGasLimits; // ══════════════╸ List of max callback gas limits used by flag with MAX_CALLBACK_GAS_LIMIT_FLAGS_INDEX
    uint16 subscriptionDepositMinimumRequests; //═══╗ Amount of requests that must be completed before the full subscription balance will be released when closing a subscription account.
    uint72 subscriptionDepositJuels; // ════════════╝ Amount of subscription funds that are held as a deposit until Config.subscriptionDepositMinimumRequests are made using the subscription.
  }

  Config private s_config;

  event ConfigUpdated(Config);

  // ================================================================
  // |                         Proposal state                       |
  // ================================================================

  uint8 private constant MAX_PROPOSAL_SET_LENGTH = 8;

  struct ContractProposalSet {
    bytes32[] ids; // ══╸ The IDs that key into the routes that will be modified if the update is applied
    address[] to; // ═══╸ The address of the contracts that the route will point to if the updated is applied
  }
  ContractProposalSet private s_proposedContractSet;

  event ContractProposed(
    bytes32 proposedContractSetId,
    address proposedContractSetFromAddress,
    address proposedContractSetToAddress
  );

  event ContractUpdated(bytes32 id, address from, address to);

  error InvalidProposal();
  error IdentifierIsReserved(bytes32 id);

  // ================================================================
  // |                       Initialization                         |
  // ================================================================

  constructor(
    address linkToken,
    Config memory config
  ) FunctionsSubscriptions(linkToken) ConfirmedOwner(msg.sender) Pausable() {
    // Set the intial configuration
    updateConfig(config);
  }

  // ================================================================
  // |                        Configuration                         |
  // ================================================================

  /// @notice The identifier of the route to retrieve the address of the access control contract
  // The access control contract controls which accounts can manage subscriptions
  /// @return id - bytes32 id that can be passed to the "getContractById" of the Router
  function getConfig() external view returns (Config memory) {
    return s_config;
  }

  /// @notice The router configuration
  function updateConfig(Config memory config) public onlyOwner {
    s_config = config;
    emit ConfigUpdated(config);
  }

  /// @inheritdoc IFunctionsRouter
  function isValidCallbackGasLimit(uint64 subscriptionId, uint32 callbackGasLimit) public view {
    uint8 callbackGasLimitsIndexSelector = uint8(getFlags(subscriptionId)[MAX_CALLBACK_GAS_LIMIT_FLAGS_INDEX]);
    if (callbackGasLimitsIndexSelector >= s_config.maxCallbackGasLimits.length) {
      revert InvalidGasFlagValue(callbackGasLimitsIndexSelector);
    }
    uint32 maxCallbackGasLimit = s_config.maxCallbackGasLimits[callbackGasLimitsIndexSelector];
    if (callbackGasLimit > maxCallbackGasLimit) {
      revert GasLimitTooBig(maxCallbackGasLimit);
    }
  }

  /// @inheritdoc IFunctionsRouter
  function getAdminFee() external view override returns (uint72) {
    return s_config.adminFee;
  }

  /// @inheritdoc IFunctionsRouter
  function getAllowListId() external view override returns (bytes32) {
    return s_allowListId;
  }

  /// @inheritdoc IFunctionsRouter
  function setAllowListId(bytes32 allowListId) external override onlyOwner {
    s_allowListId = allowListId;
  }

  /// @dev Used within FunctionsSubscriptions.sol
  function _getMaxConsumers() internal view override returns (uint16) {
    return s_config.maxConsumersPerSubscription;
  }

  /// @dev Used within FunctionsSubscriptions.sol
  function _getSubscriptionDepositDetails() internal view override returns (uint16, uint72) {
    return (s_config.subscriptionDepositMinimumRequests, s_config.subscriptionDepositJuels);
  }

  // ================================================================
  // |                           Requests                           |
  // ================================================================

  /// @inheritdoc IFunctionsRouter
  function sendRequest(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external override returns (bytes32) {
    IFunctionsCoordinator coordinator = IFunctionsCoordinator(getContractById(donId));
    return _sendRequest(donId, coordinator, subscriptionId, data, dataVersion, callbackGasLimit);
  }

  /// @inheritdoc IFunctionsRouter
  function sendRequestToProposed(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external override returns (bytes32) {
    IFunctionsCoordinator coordinator = IFunctionsCoordinator(getProposedContractById(donId));
    return _sendRequest(donId, coordinator, subscriptionId, data, dataVersion, callbackGasLimit);
  }

  function _sendRequest(
    bytes32 donId,
    IFunctionsCoordinator coordinator,
    uint64 subscriptionId,
    bytes memory data,
    uint16 dataVersion,
    uint32 callbackGasLimit
  ) private returns (bytes32) {
    _whenNotPaused();
    _isExistingSubscription(subscriptionId);
    _isAllowedConsumer(msg.sender, subscriptionId);
    isValidCallbackGasLimit(subscriptionId, callbackGasLimit);

    if (data.length == 0) {
      revert EmptyRequestData();
    }

    Subscription memory subscription = getSubscription(subscriptionId);
    Consumer memory consumer = getConsumer(msg.sender, subscriptionId);
    uint72 adminFee = s_config.adminFee;

    // Forward request to DON
    FunctionsResponse.Commitment memory commitment = coordinator.startRequest(
      FunctionsResponse.RequestMeta({
        requestingContract: msg.sender,
        data: data,
        subscriptionId: subscriptionId,
        dataVersion: dataVersion,
        flags: getFlags(subscriptionId),
        callbackGasLimit: callbackGasLimit,
        adminFee: adminFee,
        initiatedRequests: consumer.initiatedRequests,
        completedRequests: consumer.completedRequests,
        availableBalance: subscription.balance - subscription.blockedBalance,
        subscriptionOwner: subscription.owner
      })
    );

    // Do not allow setting a comittment for a requestId that already exists
    if (s_requestCommitments[commitment.requestId] != bytes32(0)) {
      revert DuplicateRequestId(commitment.requestId);
    }

    // Store a commitment about the request
    s_requestCommitments[commitment.requestId] = keccak256(
      abi.encode(
        FunctionsResponse.Commitment({
          adminFee: adminFee,
          coordinator: address(coordinator),
          client: msg.sender,
          subscriptionId: subscriptionId,
          callbackGasLimit: callbackGasLimit,
          estimatedTotalCostJuels: commitment.estimatedTotalCostJuels,
          timeoutTimestamp: commitment.timeoutTimestamp,
          requestId: commitment.requestId,
          donFee: commitment.donFee,
          gasOverheadBeforeCallback: commitment.gasOverheadBeforeCallback,
          gasOverheadAfterCallback: commitment.gasOverheadAfterCallback
        })
      )
    );

    _markRequestInFlight(msg.sender, subscriptionId, commitment.estimatedTotalCostJuels);

    emit RequestStart({
      requestId: commitment.requestId,
      donId: donId,
      subscriptionId: subscriptionId,
      subscriptionOwner: subscription.owner,
      requestingContract: msg.sender,
      // solhint-disable-next-line avoid-tx-origin
      requestInitiator: tx.origin,
      data: data,
      dataVersion: dataVersion,
      callbackGasLimit: callbackGasLimit,
      estimatedTotalCostJuels: commitment.estimatedTotalCostJuels
    });

    return commitment.requestId;
  }

  // ================================================================
  // |                           Responses                          |
  // ================================================================

  /// @inheritdoc IFunctionsRouter
  function fulfill(
    bytes memory response,
    bytes memory err,
    uint96 juelsPerGas,
    uint96 costWithoutFulfillment,
    address transmitter,
    FunctionsResponse.Commitment memory commitment
  ) external override returns (FunctionsResponse.FulfillResult resultCode, uint96) {
    _whenNotPaused();

    if (msg.sender != commitment.coordinator) {
      revert OnlyCallableFromCoordinator();
    }

    {
      bytes32 commitmentHash = s_requestCommitments[commitment.requestId];

      if (commitmentHash == bytes32(0)) {
        resultCode = FunctionsResponse.FulfillResult.INVALID_REQUEST_ID;
        emit RequestNotProcessed(commitment.requestId, commitment.coordinator, transmitter, resultCode);
        return (resultCode, 0);
      }

      if (keccak256(abi.encode(commitment)) != commitmentHash) {
        resultCode = FunctionsResponse.FulfillResult.INVALID_COMMITMENT;
        emit RequestNotProcessed(commitment.requestId, commitment.coordinator, transmitter, resultCode);
        return (resultCode, 0);
      }

      // Check that the transmitter has supplied enough gas for the callback to succeed
      if (gasleft() < commitment.callbackGasLimit + commitment.gasOverheadAfterCallback) {
        resultCode = FunctionsResponse.FulfillResult.INSUFFICIENT_GAS_PROVIDED;
        emit RequestNotProcessed(commitment.requestId, commitment.coordinator, transmitter, resultCode);
        return (resultCode, 0);
      }
    }

    {
      uint96 callbackCost = juelsPerGas * SafeCast.toUint96(commitment.callbackGasLimit);
      uint96 totalCostJuels = commitment.adminFee + costWithoutFulfillment + callbackCost;

      // Check that the subscription can still afford to fulfill the request
      if (totalCostJuels > getSubscription(commitment.subscriptionId).balance) {
        resultCode = FunctionsResponse.FulfillResult.SUBSCRIPTION_BALANCE_INVARIANT_VIOLATION;
        emit RequestNotProcessed(commitment.requestId, commitment.coordinator, transmitter, resultCode);
        return (resultCode, 0);
      }

      // Check that the cost has not exceeded the quoted cost
      if (totalCostJuels > commitment.estimatedTotalCostJuels) {
        resultCode = FunctionsResponse.FulfillResult.COST_EXCEEDS_COMMITMENT;
        emit RequestNotProcessed(commitment.requestId, commitment.coordinator, transmitter, resultCode);
        return (resultCode, 0);
      }
    }

    delete s_requestCommitments[commitment.requestId];

    CallbackResult memory result = _callback(
      commitment.requestId,
      response,
      err,
      commitment.callbackGasLimit,
      commitment.client
    );

    resultCode = result.success
      ? FunctionsResponse.FulfillResult.FULFILLED
      : FunctionsResponse.FulfillResult.USER_CALLBACK_ERROR;

    Receipt memory receipt = _pay(
      commitment.subscriptionId,
      commitment.estimatedTotalCostJuels,
      commitment.client,
      commitment.adminFee,
      juelsPerGas,
      SafeCast.toUint96(result.gasUsed),
      costWithoutFulfillment
    );

    emit RequestProcessed({
      requestId: commitment.requestId,
      subscriptionId: commitment.subscriptionId,
      totalCostJuels: receipt.totalCostJuels,
      transmitter: transmitter,
      resultCode: resultCode,
      response: response,
      err: err,
      callbackReturnData: result.returnData
    });

    return (resultCode, receipt.callbackGasCostJuels);
  }

  function _callback(
    bytes32 requestId,
    bytes memory response,
    bytes memory err,
    uint32 callbackGasLimit,
    address client
  ) private returns (CallbackResult memory) {
    bool destinationNoLongerExists;
    assembly {
      // solidity calls check that a contract actually exists at the destination, so we do the same
      destinationNoLongerExists := iszero(extcodesize(client))
    }
    if (destinationNoLongerExists) {
      // Return without attempting callback
      // The subscription will still be charged to reimburse transmitter's gas overhead
      return CallbackResult({success: false, gasUsed: 0, returnData: new bytes(0)});
    }

    bytes memory encodedCallback = abi.encodeWithSelector(
      s_config.handleOracleFulfillmentSelector,
      requestId,
      response,
      err
    );

    uint16 gasForCallExactCheck = s_config.gasForCallExactCheck;

    // Call with explicitly the amount of callback gas requested
    // Important to not let them exhaust the gas budget and avoid payment.
    // NOTE: that callWithExactGas will revert if we do not have sufficient gas
    // to give the callee their requested amount.

    bool success;
    uint256 gasUsed;
    // allocate return data memory ahead of time
    bytes memory returnData = new bytes(MAX_CALLBACK_RETURN_BYTES);

    assembly {
      let g := gas()
      // Compute g -= gasForCallExactCheck and check for underflow
      // The gas actually passed to the callee is _min(gasAmount, 63//64*gas available).
      // We want to ensure that we revert if gasAmount >  63//64*gas available
      // as we do not want to provide them with less, however that check itself costs
      // gas. gasForCallExactCheck ensures we have at least enough gas to be able
      // to revert if gasAmount >  63//64*gas available.
      if lt(g, gasForCallExactCheck) {
        revert(0, 0)
      }
      g := sub(g, gasForCallExactCheck)
      // if g - g//64 <= gasAmount, revert
      // (we subtract g//64 because of EIP-150)
      if iszero(gt(sub(g, div(g, 64)), callbackGasLimit)) {
        revert(0, 0)
      }
      // call and report whether we succeeded
      // call(gas,addr,value,argsOffset,argsLength,retOffset,retLength)
      let gasBeforeCall := gas()
      success := call(callbackGasLimit, client, 0, add(encodedCallback, 0x20), mload(encodedCallback), 0, 0)
      gasUsed := sub(gasBeforeCall, gas())

      // limit our copy to MAX_CALLBACK_RETURN_BYTES bytes
      let toCopy := returndatasize()
      if gt(toCopy, MAX_CALLBACK_RETURN_BYTES) {
        toCopy := MAX_CALLBACK_RETURN_BYTES
      }
      // Store the length of the copied bytes
      mstore(returnData, toCopy)
      // copy the bytes from returnData[0:_toCopy]
      returndatacopy(add(returnData, 0x20), 0, toCopy)
    }

    return CallbackResult({success: success, gasUsed: gasUsed, returnData: returnData});
  }

  // ================================================================
  // |                        Route methods                         |
  // ================================================================

  /// @inheritdoc IFunctionsRouter
  function getContractById(bytes32 id) public view override returns (address) {
    address currentImplementation = s_route[id];
    if (currentImplementation == address(0)) {
      revert RouteNotFound(id);
    }
    return currentImplementation;
  }

  /// @inheritdoc IFunctionsRouter
  function getProposedContractById(bytes32 id) public view override returns (address) {
    // Iterations will not exceed MAX_PROPOSAL_SET_LENGTH
    for (uint8 i = 0; i < s_proposedContractSet.ids.length; ++i) {
      if (id == s_proposedContractSet.ids[i]) {
        return s_proposedContractSet.to[i];
      }
    }
    revert RouteNotFound(id);
  }

  // ================================================================
  // |                 Contract Proposal methods                    |
  // ================================================================

  /// @inheritdoc IFunctionsRouter
  function getProposedContractSet() external view override returns (bytes32[] memory, address[] memory) {
    return (s_proposedContractSet.ids, s_proposedContractSet.to);
  }

  /// @inheritdoc IFunctionsRouter
  function proposeContractsUpdate(
    bytes32[] memory proposedContractSetIds,
    address[] memory proposedContractSetAddresses
  ) external override onlyOwner {
    // IDs and addresses arrays must be of equal length and must not exceed the max proposal length
    uint256 idsArrayLength = proposedContractSetIds.length;
    if (idsArrayLength != proposedContractSetAddresses.length || idsArrayLength > MAX_PROPOSAL_SET_LENGTH) {
      revert InvalidProposal();
    }

    // NOTE: iterations of this loop will not exceed MAX_PROPOSAL_SET_LENGTH
    for (uint256 i = 0; i < idsArrayLength; ++i) {
      bytes32 id = proposedContractSetIds[i];
      address proposedContract = proposedContractSetAddresses[i];
      if (
        proposedContract == address(0) || // The Proposed address must be a valid address
        s_route[id] == proposedContract // The Proposed address must point to a different address than what is currently set
      ) {
        revert InvalidProposal();
      }

      emit ContractProposed({
        proposedContractSetId: id,
        proposedContractSetFromAddress: s_route[id],
        proposedContractSetToAddress: proposedContract
      });
    }

    s_proposedContractSet = ContractProposalSet({ids: proposedContractSetIds, to: proposedContractSetAddresses});
  }

  /// @inheritdoc IFunctionsRouter
  function updateContracts() external override onlyOwner {
    // Iterations will not exceed MAX_PROPOSAL_SET_LENGTH
    for (uint256 i = 0; i < s_proposedContractSet.ids.length; ++i) {
      bytes32 id = s_proposedContractSet.ids[i];
      address to = s_proposedContractSet.to[i];
      emit ContractUpdated({id: id, from: s_route[id], to: to});
      s_route[id] = to;
    }

    delete s_proposedContractSet;
  }

  // ================================================================
  // |                           Modifiers                          |
  // ================================================================
  // Favoring internal functions over actual modifiers to reduce contract size

  /// @dev Used within FunctionsSubscriptions.sol
  function _whenNotPaused() internal view override {
    _requireNotPaused();
  }

  /// @dev Used within FunctionsSubscriptions.sol
  function _onlyRouterOwner() internal view override {
    _validateOwnership();
  }

  /// @dev Used within FunctionsSubscriptions.sol
  function _onlySenderThatAcceptedToS() internal view override {
    address currentImplementation = s_route[s_allowListId];
    if (currentImplementation == address(0)) {
      // If not set, ignore this check, allow all access
      return;
    }
    if (!IAccessController(currentImplementation).hasAccess(msg.sender, new bytes(0))) {
      revert SenderMustAcceptTermsOfService(msg.sender);
    }
  }

  /// @inheritdoc IFunctionsRouter
  function pause() external override onlyOwner {
    _pause();
  }

  /// @inheritdoc IFunctionsRouter
  function unpause() external override onlyOwner {
    _unpause();
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsSubscriptions} from "./interfaces/IFunctionsSubscriptions.sol";
import {IERC677Receiver} from "../../../shared/interfaces/IERC677Receiver.sol";
import {IFunctionsBilling} from "./interfaces/IFunctionsBilling.sol";

import {FunctionsResponse} from "./libraries/FunctionsResponse.sol";

import {IERC20} from "../../../vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../../vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Functions Subscriptions contract
/// @notice Contract that coordinates payment from users to the nodes of the Decentralized Oracle Network (DON).
abstract contract FunctionsSubscriptions is IFunctionsSubscriptions, IERC677Receiver {
  using SafeERC20 for IERC20;
  using FunctionsResponse for FunctionsResponse.Commitment;

  // ================================================================
  // |                         Balance state                        |
  // ================================================================
  // link token address
  IERC20 internal immutable i_linkToken;

  // s_totalLinkBalance tracks the total LINK sent to/from
  // this contract through onTokenTransfer, cancelSubscription and oracleWithdraw.
  // A discrepancy with this contract's LINK balance indicates that someone
  // sent tokens using transfer and so we may need to use recoverFunds.
  uint96 private s_totalLinkBalance;

  /// @dev NOP balances are held as a single amount. The breakdown is held by the Coordinator.
  mapping(address coordinator => uint96 balanceJuelsLink) private s_withdrawableTokens;

  // ================================================================
  // |                      Subscription state                      |
  // ================================================================
  // Keep a count of the number of subscriptions so that its possible to
  // loop through all the current subscriptions via .getSubscription().
  uint64 private s_currentSubscriptionId;

  mapping(uint64 subscriptionId => Subscription) private s_subscriptions;

  // Maintains the list of keys in s_consumers.
  // We do this for 2 reasons:
  // 1. To be able to clean up all keys from s_consumers when canceling a subscription.
  // 2. To be able to return the list of all consumers in getSubscription.
  // Note that we need the s_consumers map to be able to directly check if a
  // consumer is valid without reading all the consumers from storage.
  mapping(address consumer => mapping(uint64 subscriptionId => Consumer)) private s_consumers;

  event SubscriptionCreated(uint64 indexed subscriptionId, address owner);
  event SubscriptionFunded(uint64 indexed subscriptionId, uint256 oldBalance, uint256 newBalance);
  event SubscriptionConsumerAdded(uint64 indexed subscriptionId, address consumer);
  event SubscriptionConsumerRemoved(uint64 indexed subscriptionId, address consumer);
  event SubscriptionCanceled(uint64 indexed subscriptionId, address fundsRecipient, uint256 fundsAmount);
  event SubscriptionOwnerTransferRequested(uint64 indexed subscriptionId, address from, address to);
  event SubscriptionOwnerTransferred(uint64 indexed subscriptionId, address from, address to);

  error TooManyConsumers(uint16 maximumConsumers);
  error InsufficientBalance(uint96 currentBalanceJuels);
  error InvalidConsumer();
  error CannotRemoveWithPendingRequests();
  error InvalidSubscription();
  error OnlyCallableFromLink();
  error InvalidCalldata();
  error MustBeSubscriptionOwner();
  error TimeoutNotExceeded();
  error MustBeProposedOwner(address proposedOwner);
  event FundsRecovered(address to, uint256 amount);

  // ================================================================
  // |                       Request state                          |
  // ================================================================

  mapping(bytes32 requestId => bytes32 commitmentHash) internal s_requestCommitments;

  struct Receipt {
    uint96 callbackGasCostJuels;
    uint96 totalCostJuels;
  }

  event RequestTimedOut(bytes32 indexed requestId);

  // ================================================================
  // |                       Initialization                         |
  // ================================================================
  constructor(address link) {
    i_linkToken = IERC20(link);
  }

  // ================================================================
  // |                      Request/Response                        |
  // ================================================================

  /// @notice Sets a request as in-flight
  /// @dev Only callable within the Router
  function _markRequestInFlight(address client, uint64 subscriptionId, uint96 estimatedTotalCostJuels) internal {
    // Earmark subscription funds
    s_subscriptions[subscriptionId].blockedBalance += estimatedTotalCostJuels;

    // Increment sent requests
    s_consumers[client][subscriptionId].initiatedRequests += 1;
  }

  /// @notice Moves funds from one subscription account to another.
  /// @dev Only callable by the Coordinator contract that is saved in the request commitment
  function _pay(
    uint64 subscriptionId,
    uint96 estimatedTotalCostJuels,
    address client,
    uint96 adminFee,
    uint96 juelsPerGas,
    uint96 gasUsed,
    uint96 costWithoutCallbackJuels
  ) internal returns (Receipt memory) {
    uint96 callbackGasCostJuels = juelsPerGas * gasUsed;
    uint96 totalCostJuels = costWithoutCallbackJuels + adminFee + callbackGasCostJuels;

    if (
      s_subscriptions[subscriptionId].balance < totalCostJuels ||
      s_subscriptions[subscriptionId].blockedBalance < estimatedTotalCostJuels
    ) {
      revert InsufficientBalance(s_subscriptions[subscriptionId].balance);
    }

    // Charge the subscription
    s_subscriptions[subscriptionId].balance -= totalCostJuels;

    // Unblock earmarked funds
    s_subscriptions[subscriptionId].blockedBalance -= estimatedTotalCostJuels;

    // Pay the DON's fees and gas reimbursement
    s_withdrawableTokens[msg.sender] += costWithoutCallbackJuels + callbackGasCostJuels;

    // Pay out the administration fee
    s_withdrawableTokens[address(this)] += adminFee;

    // Increment finished requests
    s_consumers[client][subscriptionId].completedRequests += 1;

    return Receipt({callbackGasCostJuels: callbackGasCostJuels, totalCostJuels: totalCostJuels});
  }

  // ================================================================
  // |                      Owner methods                           |
  // ================================================================

  /// @inheritdoc IFunctionsSubscriptions
  function ownerCancelSubscription(uint64 subscriptionId) external override {
    _onlyRouterOwner();
    _isExistingSubscription(subscriptionId);
    _cancelSubscriptionHelper(subscriptionId, s_subscriptions[subscriptionId].owner, false);
  }

  /// @inheritdoc IFunctionsSubscriptions
  function recoverFunds(address to) external override {
    _onlyRouterOwner();
    uint256 externalBalance = i_linkToken.balanceOf(address(this));
    uint256 internalBalance = uint256(s_totalLinkBalance);
    if (internalBalance < externalBalance) {
      uint256 amount = externalBalance - internalBalance;
      i_linkToken.safeTransfer(to, amount);
      emit FundsRecovered(to, amount);
    }
    // If the balances are equal, nothing to be done.
  }

  // ================================================================
  // |                      Fund withdrawal                         |
  // ================================================================

  /// @inheritdoc IFunctionsSubscriptions
  function oracleWithdraw(address recipient, uint96 amount) external override {
    _whenNotPaused();

    if (amount == 0) {
      revert InvalidCalldata();
    }
    uint96 currentBalance = s_withdrawableTokens[msg.sender];
    if (currentBalance < amount) {
      revert InsufficientBalance(currentBalance);
    }
    s_withdrawableTokens[msg.sender] -= amount;
    s_totalLinkBalance -= amount;
    i_linkToken.safeTransfer(recipient, amount);
  }

  /// @notice Owner withdraw LINK earned through admin fees
  /// @notice If amount is 0 the full balance will be withdrawn
  /// @param recipient where to send the funds
  /// @param amount amount to withdraw
  function ownerWithdraw(address recipient, uint96 amount) external {
    _onlyRouterOwner();
    if (amount == 0) {
      amount = s_withdrawableTokens[address(this)];
    }
    uint96 currentBalance = s_withdrawableTokens[address(this)];
    if (currentBalance < amount) {
      revert InsufficientBalance(currentBalance);
    }
    s_withdrawableTokens[address(this)] -= amount;
    s_totalLinkBalance -= amount;

    i_linkToken.safeTransfer(recipient, amount);
  }

  // ================================================================
  // |                TransferAndCall Deposit helper                |
  // ================================================================

  // This function is to be invoked when using LINK.transferAndCall
  /// @dev Note to fund the subscription, use transferAndCall. For example
  /// @dev  LINKTOKEN.transferAndCall(
  /// @dev    address(ROUTER),
  /// @dev    amount,
  /// @dev    abi.encode(subscriptionId));
  function onTokenTransfer(address /* sender */, uint256 amount, bytes calldata data) external override {
    _whenNotPaused();
    if (msg.sender != address(i_linkToken)) {
      revert OnlyCallableFromLink();
    }
    if (data.length != 32) {
      revert InvalidCalldata();
    }
    uint64 subscriptionId = abi.decode(data, (uint64));
    if (s_subscriptions[subscriptionId].owner == address(0)) {
      revert InvalidSubscription();
    }
    // We do not check that the msg.sender is the subscription owner,
    // anyone can fund a subscription.
    uint256 oldBalance = s_subscriptions[subscriptionId].balance;
    s_subscriptions[subscriptionId].balance += uint96(amount);
    s_totalLinkBalance += uint96(amount);
    emit SubscriptionFunded(subscriptionId, oldBalance, oldBalance + amount);
  }

  // ================================================================
  // |                   Subscription management                   |
  // ================================================================

  /// @inheritdoc IFunctionsSubscriptions
  function getTotalBalance() external view override returns (uint96) {
    return s_totalLinkBalance;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function getSubscriptionCount() external view override returns (uint64) {
    return s_currentSubscriptionId;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function getSubscription(uint64 subscriptionId) public view override returns (Subscription memory) {
    _isExistingSubscription(subscriptionId);
    return s_subscriptions[subscriptionId];
  }

  /// @inheritdoc IFunctionsSubscriptions
  function getSubscriptionsInRange(
    uint64 subscriptionIdStart,
    uint64 subscriptionIdEnd
  ) external view override returns (Subscription[] memory subscriptions) {
    if (
      subscriptionIdStart > subscriptionIdEnd ||
      subscriptionIdEnd > s_currentSubscriptionId ||
      s_currentSubscriptionId == 0
    ) {
      revert InvalidCalldata();
    }

    subscriptions = new Subscription[]((subscriptionIdEnd - subscriptionIdStart) + 1);
    for (uint256 i = 0; i <= subscriptionIdEnd - subscriptionIdStart; ++i) {
      subscriptions[i] = s_subscriptions[uint64(subscriptionIdStart + i)];
    }

    return subscriptions;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function getConsumer(address client, uint64 subscriptionId) public view override returns (Consumer memory) {
    return s_consumers[client][subscriptionId];
  }

  /// @dev Used within this file & FunctionsRouter.sol
  function _isExistingSubscription(uint64 subscriptionId) internal view {
    if (s_subscriptions[subscriptionId].owner == address(0)) {
      revert InvalidSubscription();
    }
  }

  /// @dev Used within FunctionsRouter.sol
  function _isAllowedConsumer(address client, uint64 subscriptionId) internal view {
    if (!s_consumers[client][subscriptionId].allowed) {
      revert InvalidConsumer();
    }
  }

  /// @inheritdoc IFunctionsSubscriptions
  function createSubscription() external override returns (uint64 subscriptionId) {
    _whenNotPaused();
    _onlySenderThatAcceptedToS();

    subscriptionId = ++s_currentSubscriptionId;
    s_subscriptions[subscriptionId] = Subscription({
      balance: 0,
      blockedBalance: 0,
      owner: msg.sender,
      proposedOwner: address(0),
      consumers: new address[](0),
      flags: bytes32(0)
    });

    emit SubscriptionCreated(subscriptionId, msg.sender);

    return subscriptionId;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function createSubscriptionWithConsumer(address consumer) external override returns (uint64 subscriptionId) {
    _whenNotPaused();
    _onlySenderThatAcceptedToS();

    subscriptionId = ++s_currentSubscriptionId;
    s_subscriptions[subscriptionId] = Subscription({
      balance: 0,
      blockedBalance: 0,
      owner: msg.sender,
      proposedOwner: address(0),
      consumers: new address[](0),
      flags: bytes32(0)
    });

    s_subscriptions[subscriptionId].consumers.push(consumer);
    s_consumers[consumer][subscriptionId].allowed = true;

    emit SubscriptionCreated(subscriptionId, msg.sender);
    emit SubscriptionConsumerAdded(subscriptionId, consumer);

    return subscriptionId;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function proposeSubscriptionOwnerTransfer(uint64 subscriptionId, address newOwner) external override {
    _whenNotPaused();
    _onlySubscriptionOwner(subscriptionId);
    _onlySenderThatAcceptedToS();

    if (newOwner == address(0) || s_subscriptions[subscriptionId].proposedOwner == newOwner) {
      revert InvalidCalldata();
    }

    s_subscriptions[subscriptionId].proposedOwner = newOwner;
    emit SubscriptionOwnerTransferRequested(subscriptionId, msg.sender, newOwner);
  }

  /// @inheritdoc IFunctionsSubscriptions
  function acceptSubscriptionOwnerTransfer(uint64 subscriptionId) external override {
    _whenNotPaused();
    _onlySenderThatAcceptedToS();

    address previousOwner = s_subscriptions[subscriptionId].owner;
    address proposedOwner = s_subscriptions[subscriptionId].proposedOwner;
    if (proposedOwner != msg.sender) {
      revert MustBeProposedOwner(proposedOwner);
    }
    s_subscriptions[subscriptionId].owner = msg.sender;
    s_subscriptions[subscriptionId].proposedOwner = address(0);
    emit SubscriptionOwnerTransferred(subscriptionId, previousOwner, msg.sender);
  }

  /// @inheritdoc IFunctionsSubscriptions
  function removeConsumer(uint64 subscriptionId, address consumer) external override {
    _whenNotPaused();
    _onlySubscriptionOwner(subscriptionId);
    _onlySenderThatAcceptedToS();

    Consumer memory consumerData = s_consumers[consumer][subscriptionId];
    _isAllowedConsumer(consumer, subscriptionId);
    if (consumerData.initiatedRequests != consumerData.completedRequests) {
      revert CannotRemoveWithPendingRequests();
    }
    // Note bounded by config.maxConsumers
    address[] memory consumers = s_subscriptions[subscriptionId].consumers;
    for (uint256 i = 0; i < consumers.length; ++i) {
      if (consumers[i] == consumer) {
        // Storage write to preserve last element
        s_subscriptions[subscriptionId].consumers[i] = consumers[consumers.length - 1];
        // Storage remove last element
        s_subscriptions[subscriptionId].consumers.pop();
        break;
      }
    }
    delete s_consumers[consumer][subscriptionId];
    emit SubscriptionConsumerRemoved(subscriptionId, consumer);
  }

  /// @dev Overriden in FunctionsRouter.sol
  function _getMaxConsumers() internal view virtual returns (uint16);

  /// @inheritdoc IFunctionsSubscriptions
  function addConsumer(uint64 subscriptionId, address consumer) external override {
    _whenNotPaused();
    _onlySubscriptionOwner(subscriptionId);
    _onlySenderThatAcceptedToS();

    // Already maxed, cannot add any more consumers.
    uint16 maximumConsumers = _getMaxConsumers();
    if (s_subscriptions[subscriptionId].consumers.length >= maximumConsumers) {
      revert TooManyConsumers(maximumConsumers);
    }
    if (s_consumers[consumer][subscriptionId].allowed) {
      // Idempotence - do nothing if already added.
      // Ensures uniqueness in s_subscriptions[subscriptionId].consumers.
      return;
    }

    s_consumers[consumer][subscriptionId].allowed = true;
    s_subscriptions[subscriptionId].consumers.push(consumer);

    emit SubscriptionConsumerAdded(subscriptionId, consumer);
  }

  /// @dev Overriden in FunctionsRouter.sol
  function _getSubscriptionDepositDetails() internal virtual returns (uint16, uint72);

  function _cancelSubscriptionHelper(uint64 subscriptionId, address toAddress, bool checkDepositRefundability) private {
    Subscription memory subscription = s_subscriptions[subscriptionId];
    uint96 balance = subscription.balance;
    uint64 completedRequests = 0;

    // NOTE: loop iterations are bounded by config.maxConsumers
    // If no consumers, does nothing.
    for (uint256 i = 0; i < subscription.consumers.length; ++i) {
      address consumer = subscription.consumers[i];
      completedRequests += s_consumers[consumer][subscriptionId].completedRequests;
      delete s_consumers[consumer][subscriptionId];
    }
    delete s_subscriptions[subscriptionId];

    (uint16 subscriptionDepositMinimumRequests, uint72 subscriptionDepositJuels) = _getSubscriptionDepositDetails();

    // If subscription has not made enough requests, deposit will be forfeited
    if (checkDepositRefundability && completedRequests < subscriptionDepositMinimumRequests) {
      uint96 deposit = subscriptionDepositJuels > balance ? balance : subscriptionDepositJuels;
      if (deposit > 0) {
        s_withdrawableTokens[address(this)] += deposit;
        balance -= deposit;
      }
    }

    if (balance > 0) {
      s_totalLinkBalance -= balance;
      i_linkToken.safeTransfer(toAddress, uint256(balance));
    }
    emit SubscriptionCanceled(subscriptionId, toAddress, balance);
  }

  /// @inheritdoc IFunctionsSubscriptions
  function cancelSubscription(uint64 subscriptionId, address to) external override {
    _whenNotPaused();
    _onlySubscriptionOwner(subscriptionId);
    _onlySenderThatAcceptedToS();

    if (pendingRequestExists(subscriptionId)) {
      revert CannotRemoveWithPendingRequests();
    }

    _cancelSubscriptionHelper(subscriptionId, to, true);
  }

  /// @inheritdoc IFunctionsSubscriptions
  function pendingRequestExists(uint64 subscriptionId) public view override returns (bool) {
    address[] memory consumers = s_subscriptions[subscriptionId].consumers;
    // NOTE: loop iterations are bounded by config.maxConsumers
    for (uint256 i = 0; i < consumers.length; ++i) {
      Consumer memory consumer = s_consumers[consumers[i]][subscriptionId];
      if (consumer.initiatedRequests != consumer.completedRequests) {
        return true;
      }
    }
    return false;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function setFlags(uint64 subscriptionId, bytes32 flags) external override {
    _onlyRouterOwner();
    _isExistingSubscription(subscriptionId);
    s_subscriptions[subscriptionId].flags = flags;
  }

  /// @inheritdoc IFunctionsSubscriptions
  function getFlags(uint64 subscriptionId) public view returns (bytes32) {
    return s_subscriptions[subscriptionId].flags;
  }

  // ================================================================
  // |                        Request Timeout                       |
  // ================================================================

  /// @inheritdoc IFunctionsSubscriptions
  function timeoutRequests(FunctionsResponse.Commitment[] calldata requestsToTimeoutByCommitment) external override {
    _whenNotPaused();

    for (uint256 i = 0; i < requestsToTimeoutByCommitment.length; ++i) {
      FunctionsResponse.Commitment memory request = requestsToTimeoutByCommitment[i];
      bytes32 requestId = request.requestId;
      uint64 subscriptionId = request.subscriptionId;

      // Check that request ID is valid
      if (keccak256(abi.encode(request)) != s_requestCommitments[requestId]) {
        revert InvalidCalldata();
      }

      // Check that request has exceeded allowed request time
      if (block.timestamp < request.timeoutTimestamp) {
        revert TimeoutNotExceeded();
      }

      // Notify the Coordinator that the request should no longer be fulfilled
      IFunctionsBilling(request.coordinator).deleteCommitment(requestId);
      // Release the subscription's balance that had been earmarked for the request
      s_subscriptions[subscriptionId].blockedBalance -= request.estimatedTotalCostJuels;
      s_consumers[request.client][subscriptionId].completedRequests += 1;
      // Delete commitment within Router state
      delete s_requestCommitments[requestId];

      emit RequestTimedOut(requestId);
    }
  }

  // ================================================================
  // |                         Modifiers                            |
  // ================================================================

  function _onlySubscriptionOwner(uint64 subscriptionId) internal view {
    address owner = s_subscriptions[subscriptionId].owner;
    if (owner == address(0)) {
      revert InvalidSubscription();
    }
    if (msg.sender != owner) {
      revert MustBeSubscriptionOwner();
    }
  }

  /// @dev Overriden in FunctionsRouter.sol
  function _onlySenderThatAcceptedToS() internal virtual;

  /// @dev Overriden in FunctionsRouter.sol
  function _onlyRouterOwner() internal virtual;

  /// @dev Overriden in FunctionsRouter.sol
  function _whenNotPaused() internal virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITypeAndVersion} from "../../../shared/interfaces/ITypeAndVersion.sol";
import {IOwnableFunctionsRouter} from "./interfaces/IOwnableFunctionsRouter.sol";

/// @title This abstract should be inherited by contracts that will be used
/// as the destinations to a route (id=>contract) on the Router.
/// It provides a Router getter and modifiers.
abstract contract Routable is ITypeAndVersion {
  IOwnableFunctionsRouter private immutable i_functionsRouter;

  error RouterMustBeSet();
  error OnlyCallableByRouter();
  error OnlyCallableByRouterOwner();

  /// @dev Initializes the contract.
  constructor(address router) {
    if (router == address(0)) {
      revert RouterMustBeSet();
    }
    i_functionsRouter = IOwnableFunctionsRouter(router);
  }

  /// @notice Return the Router
  function _getRouter() internal view returns (IOwnableFunctionsRouter router) {
    return i_functionsRouter;
  }

  /// @notice Reverts if called by anyone other than the router.
  modifier onlyRouter() {
    if (msg.sender != address(i_functionsRouter)) {
      revert OnlyCallableByRouter();
    }
    _;
  }

  /// @notice Reverts if called by anyone other than the router owner.
  modifier onlyRouterOwner() {
    if (msg.sender != i_functionsRouter.owner()) {
      revert OnlyCallableByRouterOwner();
    }
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITermsOfServiceAllowList, TermsOfServiceAllowListConfig} from "./interfaces/ITermsOfServiceAllowList.sol";
import {IAccessController} from "../../../../shared/interfaces/IAccessController.sol";
import {ITypeAndVersion} from "../../../../shared/interfaces/ITypeAndVersion.sol";

import {ConfirmedOwner} from "../../../../shared/access/ConfirmedOwner.sol";

import {Address} from "../../../../vendor/openzeppelin-solidity/v4.8.3/contracts/utils/Address.sol";
import {EnumerableSet} from "../../../../vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableSet.sol";

/// @notice A contract to handle access control of subscription management dependent on signing a Terms of Service
contract TermsOfServiceAllowList is ITermsOfServiceAllowList, IAccessController, ITypeAndVersion, ConfirmedOwner {
  using Address for address;
  using EnumerableSet for EnumerableSet.AddressSet;

  /// @inheritdoc ITypeAndVersion
  string public constant override typeAndVersion = "Functions Terms of Service Allow List v1.1.0";

  EnumerableSet.AddressSet private s_allowedSenders;
  EnumerableSet.AddressSet private s_blockedSenders;

  event AddedAccess(address user);
  event BlockedAccess(address user);
  event UnblockedAccess(address user);

  error InvalidSignature();
  error InvalidUsage();
  error RecipientIsBlocked();
  error InvalidCalldata();

  TermsOfServiceAllowListConfig private s_config;

  event ConfigUpdated(TermsOfServiceAllowListConfig config);

  // ================================================================
  // |                       Initialization                         |
  // ================================================================

  constructor(
    TermsOfServiceAllowListConfig memory config,
    address[] memory initialAllowedSenders,
    address[] memory initialBlockedSenders
  ) ConfirmedOwner(msg.sender) {
    updateConfig(config);

    for (uint256 i = 0; i < initialAllowedSenders.length; ++i) {
      s_allowedSenders.add(initialAllowedSenders[i]);
    }

    for (uint256 j = 0; j < initialBlockedSenders.length; ++j) {
      if (s_allowedSenders.contains(initialBlockedSenders[j])) {
        // Allowed senders cannot also be blocked
        revert InvalidCalldata();
      }
      s_blockedSenders.add(initialBlockedSenders[j]);
    }
  }

  // ================================================================
  // |                        Configuration                         |
  // ================================================================

  /// @notice Gets the contracts's configuration
  /// @return config
  function getConfig() external view returns (TermsOfServiceAllowListConfig memory) {
    return s_config;
  }

  /// @notice Sets the contracts's configuration
  /// @param config - See the contents of the TermsOfServiceAllowListConfig struct in ITermsOfServiceAllowList.sol for more information
  function updateConfig(TermsOfServiceAllowListConfig memory config) public onlyOwner {
    s_config = config;
    emit ConfigUpdated(config);
  }

  // ================================================================
  // |                      Allow methods                           |
  // ================================================================

  /// @inheritdoc ITermsOfServiceAllowList
  function getMessage(address acceptor, address recipient) public pure override returns (bytes32) {
    return keccak256(abi.encodePacked(acceptor, recipient));
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function acceptTermsOfService(address acceptor, address recipient, bytes32 r, bytes32 s, uint8 v) external override {
    if (s_blockedSenders.contains(recipient)) {
      revert RecipientIsBlocked();
    }

    // Validate that the signature is correct and the correct data has been signed
    bytes32 prefixedMessage = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", getMessage(acceptor, recipient))
    );
    if (ecrecover(prefixedMessage, v, r, s) != s_config.signerPublicKey) {
      revert InvalidSignature();
    }

    // If contract, validate that msg.sender == recipient
    // This is to prevent EoAs from claiming contracts that they are not in control of
    // If EoA, validate that msg.sender == acceptor == recipient
    // This is to prevent EoAs from accepting for other EoAs
    if (msg.sender != recipient || (msg.sender != acceptor && !msg.sender.isContract())) {
      revert InvalidUsage();
    }

    // Add recipient to the allow list
    if (s_allowedSenders.add(recipient)) {
      emit AddedAccess(recipient);
    }
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function getAllAllowedSenders() external view override returns (address[] memory) {
    return s_allowedSenders.values();
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function getAllowedSendersCount() external view override returns (uint64) {
    return uint64(s_allowedSenders.length());
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function getAllowedSendersInRange(
    uint64 allowedSenderIdxStart,
    uint64 allowedSenderIdxEnd
  ) external view override returns (address[] memory allowedSenders) {
    if (allowedSenderIdxStart > allowedSenderIdxEnd || allowedSenderIdxEnd >= s_allowedSenders.length()) {
      revert InvalidCalldata();
    }

    allowedSenders = new address[]((allowedSenderIdxEnd - allowedSenderIdxStart) + 1);
    for (uint256 i = 0; i <= allowedSenderIdxEnd - allowedSenderIdxStart; ++i) {
      allowedSenders[i] = s_allowedSenders.at(uint256(allowedSenderIdxStart + i));
    }

    return allowedSenders;
  }

  /// @inheritdoc IAccessController
  function hasAccess(address user, bytes calldata /* data */) external view override returns (bool) {
    if (!s_config.enabled) {
      return true;
    }
    return s_allowedSenders.contains(user);
  }

  // ================================================================
  // |                         Block methods                        |
  // ================================================================

  /// @inheritdoc ITermsOfServiceAllowList
  function isBlockedSender(address sender) external view override returns (bool) {
    if (!s_config.enabled) {
      return false;
    }
    return s_blockedSenders.contains(sender);
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function blockSender(address sender) external override onlyOwner {
    s_allowedSenders.remove(sender);
    s_blockedSenders.add(sender);
    emit BlockedAccess(sender);
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function unblockSender(address sender) external override onlyOwner {
    s_blockedSenders.remove(sender);
    emit UnblockedAccess(sender);
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function getBlockedSendersCount() external view override returns (uint64) {
    return uint64(s_blockedSenders.length());
  }

  /// @inheritdoc ITermsOfServiceAllowList
  function getBlockedSendersInRange(
    uint64 blockedSenderIdxStart,
    uint64 blockedSenderIdxEnd
  ) external view override returns (address[] memory blockedSenders) {
    if (
      blockedSenderIdxStart > blockedSenderIdxEnd ||
      blockedSenderIdxEnd >= s_blockedSenders.length() ||
      s_blockedSenders.length() == 0
    ) {
      revert InvalidCalldata();
    }

    blockedSenders = new address[]((blockedSenderIdxEnd - blockedSenderIdxStart) + 1);
    for (uint256 i = 0; i <= blockedSenderIdxEnd - blockedSenderIdxStart; ++i) {
      blockedSenders[i] = s_blockedSenders.at(uint256(blockedSenderIdxStart + i));
    }

    return blockedSenders;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @notice A contract to handle access control of subscription management dependent on signing a Terms of Service
interface ITermsOfServiceAllowList {
  /// @notice Return the message data for the proof given to accept the Terms of Service
  /// @param acceptor - The wallet address that has accepted the Terms of Service on the UI
  /// @param recipient - The recipient address that the acceptor is taking responsibility for
  /// @return Hash of the message data
  function getMessage(address acceptor, address recipient) external pure returns (bytes32);

  /// @notice Check if the address is blocked for usage
  /// @param sender The transaction sender's address
  /// @return True or false
  function isBlockedSender(address sender) external returns (bool);

  /// @notice Get a list of all allowed senders
  /// @dev WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
  /// to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
  /// this function has an unbounded cost, and using it as part of a state-changing function may render the function
  /// uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
  /// @return addresses - all allowed addresses
  function getAllAllowedSenders() external view returns (address[] memory);

  /// @notice Get details about the total number of allowed senders
  /// @return count - total number of allowed senders in the system
  function getAllowedSendersCount() external view returns (uint64);

  /// @notice Retrieve a list of allowed senders using an inclusive range
  /// @dev WARNING: getAllowedSendersInRange uses EnumerableSet .length() and .at() methods to iterate over the list
  /// without the need for an extra mapping. These method can not guarantee the ordering when new elements are added.
  /// Evaluate if eventual consistency will satisfy your usecase before using it.
  /// @param allowedSenderIdxStart - index of the allowed sender to start the range at
  /// @param allowedSenderIdxEnd - index of the allowed sender to end the range at
  /// @return allowedSenders - allowed addresses in the range provided
  function getAllowedSendersInRange(
    uint64 allowedSenderIdxStart,
    uint64 allowedSenderIdxEnd
  ) external view returns (address[] memory allowedSenders);

  /// @notice Allows access to the sender based on acceptance of the Terms of Service
  /// @param acceptor - The wallet address that has accepted the Terms of Service on the UI
  /// @param recipient - The recipient address that the acceptor is taking responsibility for
  /// @param r - ECDSA signature r data produced by the Chainlink Functions Subscription UI
  /// @param s - ECDSA signature s produced by the Chainlink Functions Subscription UI
  /// @param v - ECDSA signature v produced by the Chainlink Functions Subscription UI
  function acceptTermsOfService(address acceptor, address recipient, bytes32 r, bytes32 s, uint8 v) external;

  /// @notice Removes a sender's access if already authorized, and disallows re-accepting the Terms of Service
  /// @param sender - Address of the sender to block
  function blockSender(address sender) external;

  /// @notice Re-allows a previously blocked sender to accept the Terms of Service
  /// @param sender - Address of the sender to unblock
  function unblockSender(address sender) external;

  /// @notice Get details about the total number of blocked senders
  /// @return count - total number of blocked senders in the system
  function getBlockedSendersCount() external view returns (uint64);

  /// @notice Retrieve a list of blocked senders using an inclusive range
  /// @dev WARNING: getBlockedSendersInRange uses EnumerableSet .length() and .at() methods to iterate over the list
  /// without the need for an extra mapping. These method can not guarantee the ordering when new elements are added.
  /// Evaluate if eventual consistency will satisfy your usecase before using it.
  /// @param blockedSenderIdxStart - index of the blocked sender to start the range at
  /// @param blockedSenderIdxEnd - index of the blocked sender to end the range at
  /// @return blockedSenders - blocked addresses in the range provided
  function getBlockedSendersInRange(
    uint64 blockedSenderIdxStart,
    uint64 blockedSenderIdxEnd
  ) external view returns (address[] memory blockedSenders);
}

// ================================================================
// |                     Configuration state                      |
// ================================================================
struct TermsOfServiceAllowListConfig {
  bool enabled; // ═════════════╗ When enabled, access will be checked against s_allowedSenders. When disabled, all access will be allowed.
  address signerPublicKey; // ══╝ The key pair that needs to sign the acceptance data
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "../FunctionsClient.sol";
import {ConfirmedOwner} from "../../../../shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "../libraries/FunctionsRequest.sol";

/// @title Chainlink Functions example Client contract implementation
contract FunctionsClientExample is FunctionsClient, ConfirmedOwner {
  using FunctionsRequest for FunctionsRequest.Request;

  uint32 public constant MAX_CALLBACK_GAS = 70_000;

  bytes32 public s_lastRequestId;
  bytes32 public s_lastResponse;
  bytes32 public s_lastError;
  uint32 public s_lastResponseLength;
  uint32 public s_lastErrorLength;

  error UnexpectedRequestID(bytes32 requestId);

  constructor(address router) FunctionsClient(router) ConfirmedOwner(msg.sender) {}

  /// @notice Send a simple request
  /// @param source JavaScript source code
  /// @param encryptedSecretsReferences Encrypted secrets payload
  /// @param args List of arguments accessible from within the source code
  /// @param subscriptionId Billing ID
  function sendRequest(
    string calldata source,
    bytes calldata encryptedSecretsReferences,
    string[] calldata args,
    uint64 subscriptionId,
    bytes32 jobId
  ) external onlyOwner {
    FunctionsRequest.Request memory req;
    req._initializeRequestForInlineJavaScript(source);
    if (encryptedSecretsReferences.length > 0) req._addSecretsReference(encryptedSecretsReferences);
    if (args.length > 0) req._setArgs(args);
    s_lastRequestId = _sendRequest(req._encodeCBOR(), subscriptionId, MAX_CALLBACK_GAS, jobId);
  }

  /// @notice Store latest result/error
  /// @param requestId The request ID, returned by sendRequest()
  /// @param response Aggregated response from the user code
  /// @param err Aggregated error from the user code or from the execution pipeline
  /// @dev Either response or error parameter will be set, but never both
  function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    if (s_lastRequestId != requestId) {
      revert UnexpectedRequestID(requestId);
    }
    // Save only the first 32 bytes of response/error to always fit within MAX_CALLBACK_GAS
    s_lastResponse = _bytesToBytes32(response);
    s_lastResponseLength = uint32(response.length);
    s_lastError = _bytesToBytes32(err);
    s_lastErrorLength = uint32(err.length);
  }

  function _bytesToBytes32(bytes memory b) private pure returns (bytes32 out) {
    uint256 maxLen = 32;
    if (b.length < 32) {
      maxLen = b.length;
    }
    for (uint256 i = 0; i < maxLen; ++i) {
      out |= bytes32(b[i]) >> (i * 8);
    }
    return out;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Chainlink Functions DON billing interface.
interface IFunctionsBilling {
  /// @notice Return the current conversion from WEI of ETH to LINK from the configured Chainlink data feed
  /// @return weiPerUnitLink - The amount of WEI in one LINK
  function getWeiPerUnitLink() external view returns (uint256);

  /// @notice Return the current conversion from LINK to USD from the configured Chainlink data feed
  /// @return weiPerUnitLink - The amount of USD that one LINK is worth
  /// @return decimals - The number of decimals that should be represented in the price feed's response
  function getUsdPerUnitLink() external view returns (uint256, uint8);

  /// @notice Determine the fee that will be split between Node Operators for servicing a request
  /// @param requestCBOR - CBOR encoded Chainlink Functions request data, use FunctionsRequest library to encode a request
  /// @return fee - Cost in Juels (1e18) of LINK
  function getDONFeeJuels(bytes memory requestCBOR) external view returns (uint72);

  /// @notice Determine the fee that will be paid to the Coordinator owner for operating the network
  /// @return fee - Cost in Juels (1e18) of LINK
  function getOperationFeeJuels() external view returns (uint72);

  /// @notice Determine the fee that will be paid to the Router owner for operating the network
  /// @return fee - Cost in Juels (1e18) of LINK
  function getAdminFeeJuels() external view returns (uint72);

  /// @notice Estimate the total cost that will be charged to a subscription to make a request: transmitter gas re-reimbursement, plus DON fee, plus Registry fee
  /// @param - subscriptionId An identifier of the billing account
  /// @param - data Encoded Chainlink Functions request data, use FunctionsClient API to encode a request
  /// @param - callbackGasLimit Gas limit for the fulfillment callback
  /// @param - gasPriceWei The blockchain's gas price to estimate with
  /// @return - billedCost Cost in Juels (1e18) of LINK
  function estimateCost(
    uint64 subscriptionId,
    bytes calldata data,
    uint32 callbackGasLimit,
    uint256 gasPriceWei
  ) external view returns (uint96);

  /// @notice Remove a request commitment that the Router has determined to be stale
  /// @param requestId - The request ID to remove
  function deleteCommitment(bytes32 requestId) external;

  /// @notice Oracle withdraw LINK earned through fulfilling requests
  /// @notice If amount is 0 the full balance will be withdrawn
  /// @param recipient where to send the funds
  /// @param amount amount to withdraw
  function oracleWithdraw(address recipient, uint96 amount) external;

  /// @notice Withdraw all LINK earned by Oracles through fulfilling requests
  /// @dev transmitter addresses must support LINK tokens to avoid tokens from getting stuck as oracleWithdrawAll() calls will forward tokens directly to transmitters
  function oracleWithdrawAll() external;
}

// ================================================================
// |                     Configuration state                      |
// ================================================================

struct FunctionsBillingConfig {
  uint32 fulfillmentGasPriceOverEstimationBP; // ══╗ Percentage of gas price overestimation to account for changes in gas price between request and response. Held as basis points (one hundredth of 1 percentage point)
  uint32 feedStalenessSeconds; //                  ║ How long before we consider the feed price to be stale and fallback to fallbackNativePerUnitLink. Default of 0 means no fallback.
  uint32 gasOverheadBeforeCallback; //             ║ Represents the average gas execution cost before the fulfillment callback. This amount is always billed for every request.
  uint32 gasOverheadAfterCallback; //              ║ Represents the average gas execution cost after the fulfillment callback. This amount is always billed for every request.
  uint40 minimumEstimateGasPriceWei; //            ║ The lowest amount of wei that will be used as the tx.gasprice when estimating the cost to fulfill the request
  uint16 maxSupportedRequestDataVersion; //        ║ The highest support request data version supported by the node. All lower versions should also be supported.
  uint64 fallbackUsdPerUnitLink; //                ║ Fallback LINK / USD conversion rate if the data feed is stale
  uint8 fallbackUsdPerUnitLinkDecimals; // ════════╝ Fallback LINK / USD conversion rate decimal places if the data feed is stale
  uint224 fallbackNativePerUnitLink; // ═══════════╗ Fallback NATIVE CURRENCY / LINK conversion rate if the data feed is stale
  uint32 requestTimeoutSeconds; // ════════════════╝ How many seconds it takes before we consider a request to be timed out
  uint16 donFeeCentsUsd; // ═══════════════════════════════╗ Additional flat fee (denominated in cents of USD, paid as LINK) that will be split between Node Operators.
  uint16 operationFeeCentsUsd; //                          ║ Additional flat fee (denominated in cents of USD, paid as LINK) that will be paid to the owner of the Coordinator contract.
  uint16 transmitTxSizeBytes; // ══════════════════════════╝ The size of the calldata for the transmit transaction in bytes assuming a single 256 byte response payload. Used to estimate L1 cost for fulfillments on L2 chains.
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Chainlink Functions client interface.
interface IFunctionsClient {
  /// @notice Chainlink Functions response handler called by the Functions Router
  /// during fullilment from the designated transmitter node in an OCR round.
  /// @param requestId The requestId returned by FunctionsClient.sendRequest().
  /// @param response Aggregated response from the request's source code.
  /// @param err Aggregated error either from the request's source code or from the execution pipeline.
  /// @dev Either response or error parameter will be set, but never both.
  function handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsResponse} from "../libraries/FunctionsResponse.sol";

/// @title Chainlink Functions DON Coordinator interface.
interface IFunctionsCoordinator {
  /// @notice Returns the DON's threshold encryption public key used to encrypt secrets
  /// @dev All nodes on the DON have separate key shares of the threshold decryption key
  /// and nodes must participate in a threshold decryption OCR round to decrypt secrets
  /// @return thresholdPublicKey the DON's threshold encryption public key
  function getThresholdPublicKey() external view returns (bytes memory);

  /// @notice Sets the DON's threshold encryption public key used to encrypt secrets
  /// @dev Used to rotate the key
  /// @param thresholdPublicKey The new public key
  function setThresholdPublicKey(bytes calldata thresholdPublicKey) external;

  /// @notice Returns the DON's secp256k1 public key that is used to encrypt secrets
  /// @dev All nodes on the DON have the corresponding private key
  /// needed to decrypt the secrets encrypted with the public key
  /// @return publicKey the DON's public key
  function getDONPublicKey() external view returns (bytes memory);

  /// @notice Sets DON's secp256k1 public key used to encrypt secrets
  /// @dev Used to rotate the key
  /// @param donPublicKey The new public key
  function setDONPublicKey(bytes calldata donPublicKey) external;

  /// @notice Receives a request to be emitted to the DON for processing
  /// @param request The request metadata
  /// @dev see the struct for field descriptions
  /// @return commitment - The parameters of the request that must be held consistent at response time
  function startRequest(
    FunctionsResponse.RequestMeta calldata request
  ) external returns (FunctionsResponse.Commitment memory commitment);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsResponse} from "../libraries/FunctionsResponse.sol";

/// @title Chainlink Functions Router interface.
interface IFunctionsRouter {
  /// @notice The identifier of the route to retrieve the address of the access control contract
  /// The access control contract controls which accounts can manage subscriptions
  /// @return id - bytes32 id that can be passed to the "getContractById" of the Router
  function getAllowListId() external view returns (bytes32);

  /// @notice Set the identifier of the route to retrieve the address of the access control contract
  /// The access control contract controls which accounts can manage subscriptions
  function setAllowListId(bytes32 allowListId) external;

  /// @notice Get the flat fee (in Juels of LINK) that will be paid to the Router owner for operation of the network
  /// @return adminFee
  function getAdminFee() external view returns (uint72 adminFee);

  /// @notice Sends a request using the provided subscriptionId
  /// @param subscriptionId - A unique subscription ID allocated by billing system,
  /// a client can make requests from different contracts referencing the same subscription
  /// @param data - CBOR encoded Chainlink Functions request data, use FunctionsClient API to encode a request
  /// @param dataVersion - Gas limit for the fulfillment callback
  /// @param callbackGasLimit - Gas limit for the fulfillment callback
  /// @param donId - An identifier used to determine which route to send the request along
  /// @return requestId - A unique request identifier
  function sendRequest(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external returns (bytes32);

  /// @notice Sends a request to the proposed contracts
  /// @param subscriptionId - A unique subscription ID allocated by billing system,
  /// a client can make requests from different contracts referencing the same subscription
  /// @param data - CBOR encoded Chainlink Functions request data, use FunctionsClient API to encode a request
  /// @param dataVersion - Gas limit for the fulfillment callback
  /// @param callbackGasLimit - Gas limit for the fulfillment callback
  /// @param donId - An identifier used to determine which route to send the request along
  /// @return requestId - A unique request identifier
  function sendRequestToProposed(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external returns (bytes32);

  /// @notice Fulfill the request by:
  /// - calling back the data that the Oracle returned to the client contract
  /// - pay the DON for processing the request
  /// @dev Only callable by the Coordinator contract that is saved in the commitment
  /// @param response response data from DON consensus
  /// @param err error from DON consensus
  /// @param juelsPerGas - current rate of juels/gas
  /// @param costWithoutFulfillment - The cost of processing the request (in Juels of LINK ), without fulfillment
  /// @param transmitter - The Node that transmitted the OCR report
  /// @param commitment - The parameters of the request that must be held consistent between request and response time
  /// @return fulfillResult -
  /// @return callbackGasCostJuels -
  function fulfill(
    bytes memory response,
    bytes memory err,
    uint96 juelsPerGas,
    uint96 costWithoutFulfillment,
    address transmitter,
    FunctionsResponse.Commitment memory commitment
  ) external returns (FunctionsResponse.FulfillResult, uint96);

  /// @notice Validate requested gas limit is below the subscription max.
  /// @param subscriptionId subscription ID
  /// @param callbackGasLimit desired callback gas limit
  function isValidCallbackGasLimit(uint64 subscriptionId, uint32 callbackGasLimit) external view;

  /// @notice Get the current contract given an ID
  /// @param id A bytes32 identifier for the route
  /// @return contract The current contract address
  function getContractById(bytes32 id) external view returns (address);

  /// @notice Get the proposed next contract given an ID
  /// @param id A bytes32 identifier for the route
  /// @return contract The current or proposed contract address
  function getProposedContractById(bytes32 id) external view returns (address);

  /// @notice Return the latest proprosal set
  /// @return ids The identifiers of the contracts to update
  /// @return to The addresses of the contracts that will be updated to
  function getProposedContractSet() external view returns (bytes32[] memory, address[] memory);

  /// @notice Proposes one or more updates to the contract routes
  /// @dev Only callable by owner
  function proposeContractsUpdate(bytes32[] memory proposalSetIds, address[] memory proposalSetAddresses) external;

  /// @notice Updates the current contract routes to the proposed contracts
  /// @dev Only callable by owner
  function updateContracts() external;

  /// @dev Puts the system into an emergency stopped state.
  /// @dev Only callable by owner
  function pause() external;

  /// @dev Takes the system out of an emergency stopped state.
  /// @dev Only callable by owner
  function unpause() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsResponse} from "../libraries/FunctionsResponse.sol";

/// @title Chainlink Functions Subscription interface.
interface IFunctionsSubscriptions {
  struct Subscription {
    uint96 balance; // ═════════╗ Common LINK balance that is controlled by the Router to be used for all consumer requests.
    address owner; // ══════════╝ The owner can fund/withdraw/cancel the subscription.
    uint96 blockedBalance; // ══╗ LINK balance that is reserved to pay for pending consumer requests.
    address proposedOwner; // ══╝ For safely transferring sub ownership.
    address[] consumers; // ════╸ Client contracts that can use the subscription
    bytes32 flags; // ══════════╸ Per-subscription flags
  }

  struct Consumer {
    bool allowed; // ══════════════╗ Owner can fund/withdraw/cancel the sub.
    uint64 initiatedRequests; //   ║ The number of requests that have been started
    uint64 completedRequests; // ══╝ The number of requests that have successfully completed or timed out
  }

  /// @notice Get details about a subscription.
  /// @param subscriptionId - the ID of the subscription
  /// @return subscription - see IFunctionsSubscriptions.Subscription for more information on the structure
  function getSubscription(uint64 subscriptionId) external view returns (Subscription memory);

  /// @notice Retrieve details about multiple subscriptions using an inclusive range
  /// @param subscriptionIdStart - the ID of the subscription to start the range at
  /// @param subscriptionIdEnd - the ID of the subscription to end the range at
  /// @return subscriptions - see IFunctionsSubscriptions.Subscription for more information on the structure
  function getSubscriptionsInRange(
    uint64 subscriptionIdStart,
    uint64 subscriptionIdEnd
  ) external view returns (Subscription[] memory);

  /// @notice Get details about a consumer of a subscription.
  /// @param client - the consumer contract address
  /// @param subscriptionId - the ID of the subscription
  /// @return consumer - see IFunctionsSubscriptions.Consumer for more information on the structure
  function getConsumer(address client, uint64 subscriptionId) external view returns (Consumer memory);

  /// @notice Get details about the total amount of LINK within the system
  /// @return totalBalance - total Juels of LINK held by the contract
  function getTotalBalance() external view returns (uint96);

  /// @notice Get details about the total number of subscription accounts
  /// @return count - total number of subscriptions in the system
  function getSubscriptionCount() external view returns (uint64);

  /// @notice Time out all expired requests: unlocks funds and removes the ability for the request to be fulfilled
  /// @param requestsToTimeoutByCommitment - A list of request commitments to time out
  /// @dev The commitment can be found on the "OracleRequest" event created when sending the request.
  function timeoutRequests(FunctionsResponse.Commitment[] calldata requestsToTimeoutByCommitment) external;

  /// @notice Oracle withdraw LINK earned through fulfilling requests
  /// @notice If amount is 0 the full balance will be withdrawn
  /// @notice Both signing and transmitting wallets will have a balance to withdraw
  /// @param recipient where to send the funds
  /// @param amount amount to withdraw
  function oracleWithdraw(address recipient, uint96 amount) external;

  /// @notice Owner cancel subscription, sends remaining link directly to the subscription owner.
  /// @dev Only callable by the Router Owner
  /// @param subscriptionId subscription id
  /// @dev notably can be called even if there are pending requests, outstanding ones may fail onchain
  function ownerCancelSubscription(uint64 subscriptionId) external;

  /// @notice Recover link sent with transfer instead of transferAndCall.
  /// @dev Only callable by the Router Owner
  /// @param to address to send link to
  function recoverFunds(address to) external;

  /// @notice Create a new subscription.
  /// @return subscriptionId - A unique subscription id.
  /// @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
  /// @dev Note to fund the subscription, use transferAndCall. For example
  /// @dev  LINKTOKEN.transferAndCall(
  /// @dev    address(ROUTER),
  /// @dev    amount,
  /// @dev    abi.encode(subscriptionId));
  function createSubscription() external returns (uint64);

  /// @notice Create a new subscription and add a consumer.
  /// @return subscriptionId - A unique subscription id.
  /// @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
  /// @dev Note to fund the subscription, use transferAndCall. For example
  /// @dev  LINKTOKEN.transferAndCall(
  /// @dev    address(ROUTER),
  /// @dev    amount,
  /// @dev    abi.encode(subscriptionId));
  function createSubscriptionWithConsumer(address consumer) external returns (uint64 subscriptionId);

  /// @notice Propose a new owner for a subscription.
  /// @dev Only callable by the Subscription's owner
  /// @param subscriptionId - ID of the subscription
  /// @param newOwner - proposed new owner of the subscription
  function proposeSubscriptionOwnerTransfer(uint64 subscriptionId, address newOwner) external;

  /// @notice Accept an ownership transfer.
  /// @param subscriptionId - ID of the subscription
  /// @dev will revert if original owner of subscriptionId has not requested that msg.sender become the new owner.
  function acceptSubscriptionOwnerTransfer(uint64 subscriptionId) external;

  /// @notice Remove a consumer from a Chainlink Functions subscription.
  /// @dev Only callable by the Subscription's owner
  /// @param subscriptionId - ID of the subscription
  /// @param consumer - Consumer to remove from the subscription
  function removeConsumer(uint64 subscriptionId, address consumer) external;

  /// @notice Add a consumer to a Chainlink Functions subscription.
  /// @dev Only callable by the Subscription's owner
  /// @param subscriptionId - ID of the subscription
  /// @param consumer - New consumer which can use the subscription
  function addConsumer(uint64 subscriptionId, address consumer) external;

  /// @notice Cancel a subscription
  /// @dev Only callable by the Subscription's owner
  /// @param subscriptionId - ID of the subscription
  /// @param to - Where to send the remaining LINK to
  function cancelSubscription(uint64 subscriptionId, address to) external;

  /// @notice Check to see if there exists a request commitment for all consumers for a given sub.
  /// @param subscriptionId - ID of the subscription
  /// @return true if there exists at least one unfulfilled request for the subscription, false otherwise.
  /// @dev Looping is bounded to MAX_CONSUMERS*(number of DONs).
  /// @dev Used to disable subscription canceling while outstanding request are present.
  function pendingRequestExists(uint64 subscriptionId) external view returns (bool);

  /// @notice Set subscription specific flags for a subscription.
  /// Each byte of the flag is used to represent a resource tier that the subscription can utilize.
  /// @param subscriptionId - ID of the subscription
  /// @param flags - desired flag values
  function setFlags(uint64 subscriptionId, bytes32 flags) external;

  /// @notice Get flags for a given subscription.
  /// @param subscriptionId - ID of the subscription
  /// @return flags - current flag values
  function getFlags(uint64 subscriptionId) external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFunctionsRouter} from "./IFunctionsRouter.sol";
import {IOwnable} from "../../../../shared/interfaces/IOwnable.sol";

/// @title Chainlink Functions Router interface with Ownability.
interface IOwnableFunctionsRouter is IOwnable, IFunctionsRouter {}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ArbGasInfo} from "../../../../vendor/@arbitrum/nitro-contracts/src/precompiles/ArbGasInfo.sol";
import {GasPriceOracle} from "../../../../vendor/@eth-optimism/contracts-bedrock/v0.17.3/src/L2/GasPriceOracle.sol";

/// @dev A library that abstracts out opcodes that behave differently across chains.
/// @dev The methods below return values that are pertinent to the given chain.
library ChainSpecificUtil {
  // ------------ Start Arbitrum Constants ------------
  /// @dev ARBGAS_ADDR is the address of the ArbGasInfo precompile on Arbitrum.
  /// @dev reference: https://github.com/OffchainLabs/nitro/blob/v2.0.14/contracts/src/precompiles/ArbGasInfo.sol#L10
  address private constant ARBGAS_ADDR = address(0x000000000000000000000000000000000000006C);
  ArbGasInfo private constant ARBGAS = ArbGasInfo(ARBGAS_ADDR);
  /// @dev ARB_DATA_PADDING_SIZE is the max size of the "static" data on Arbitrum for the transaction which refers to the tx data that is not the calldata (signature, etc.)
  /// @dev reference: https://docs.arbitrum.io/build-decentralized-apps/how-to-estimate-gas#where-do-we-get-all-this-information-from
  uint256 private constant ARB_DATA_PADDING_SIZE = 140;

  uint256 private constant ARB_MAINNET_CHAIN_ID = 42161;
  uint256 private constant ARB_GOERLI_TESTNET_CHAIN_ID = 421613;
  uint256 private constant ARB_SEPOLIA_TESTNET_CHAIN_ID = 421614;

  // ------------ End Arbitrum Constants ------------

  // ------------ Start Optimism Constants ------------
  /// @dev GAS_PRICE_ORACLE_ADDR is the address of the GasPriceOracle precompile on Optimism.
  address private constant GAS_PRICE_ORACLE_ADDR = address(0x420000000000000000000000000000000000000F);
  GasPriceOracle private constant GAS_PRICE_ORACLE = GasPriceOracle(GAS_PRICE_ORACLE_ADDR);

  uint256 private constant OP_MAINNET_CHAIN_ID = 10;
  uint256 private constant OP_GOERLI_CHAIN_ID = 420;
  uint256 private constant OP_SEPOLIA_CHAIN_ID = 11155420;

  /// @dev Base is a OP stack based rollup and follows the same L1 pricing logic as Optimism.
  uint256 private constant BASE_MAINNET_CHAIN_ID = 8453;
  uint256 private constant BASE_GOERLI_CHAIN_ID = 84531;
  uint256 private constant BASE_SEPOLIA_CHAIN_ID = 84532;

  // ------------ End Optimism Constants ------------

  /// @notice Returns the upper limit estimate of the L1 fees in wei that will be paid for L2 chains
  /// @notice based on the size of the transaction data and the current gas conditions.
  /// @notice This is an "upper limit" as it assumes the transaction data is uncompressed when posted on L1.
  function _getL1FeeUpperLimit(uint256 calldataSizeBytes) internal view returns (uint256 l1FeeWei) {
    uint256 chainid = block.chainid;
    if (_isArbitrumChainId(chainid)) {
      // https://docs.arbitrum.io/build-decentralized-apps/how-to-estimate-gas#where-do-we-get-all-this-information-from
      (, uint256 l1PricePerByte, , , , ) = ARBGAS.getPricesInWei();
      return l1PricePerByte * (calldataSizeBytes + ARB_DATA_PADDING_SIZE);
    } else if (_isOptimismChainId(chainid)) {
      return GAS_PRICE_ORACLE.getL1FeeUpperBound(calldataSizeBytes);
    }
    return 0;
  }

  /// @notice Return true if and only if the provided chain ID is an Arbitrum chain ID.
  function _isArbitrumChainId(uint256 chainId) internal pure returns (bool) {
    return
      chainId == ARB_MAINNET_CHAIN_ID ||
      chainId == ARB_GOERLI_TESTNET_CHAIN_ID ||
      chainId == ARB_SEPOLIA_TESTNET_CHAIN_ID;
  }

  /// @notice Return true if and only if the provided chain ID is an Optimism (or Base) chain ID.
  /// @notice Note that optimism chain id's are also OP stack chain id's.
  function _isOptimismChainId(uint256 chainId) internal pure returns (bool) {
    return
      chainId == OP_MAINNET_CHAIN_ID ||
      chainId == OP_GOERLI_CHAIN_ID ||
      chainId == OP_SEPOLIA_CHAIN_ID ||
      chainId == BASE_MAINNET_CHAIN_ID ||
      chainId == BASE_GOERLI_CHAIN_ID ||
      chainId == BASE_SEPOLIA_CHAIN_ID;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CBOR} from "../../../../vendor/solidity-cborutils/v2.0.0/CBOR.sol";

/// @title Library for encoding the input data of a Functions request into CBOR
library FunctionsRequest {
  using CBOR for CBOR.CBORBuffer;

  uint16 public constant REQUEST_DATA_VERSION = 1;
  uint256 internal constant DEFAULT_BUFFER_SIZE = 256;

  enum Location {
    Inline, // Provided within the Request
    Remote, // Hosted through remote location that can be accessed through a provided URL
    DONHosted // Hosted on the DON's storage
  }

  enum CodeLanguage {
    JavaScript
    // In future version we may add other languages
  }

  struct Request {
    Location codeLocation; // ════════════╸ The location of the source code that will be executed on each node in the DON
    Location secretsLocation; // ═════════╸ The location of secrets that will be passed into the source code. *Only Remote secrets are supported
    CodeLanguage language; // ════════════╸ The coding language that the source code is written in
    string source; // ════════════════════╸ Raw source code for Request.codeLocation of Location.Inline, URL for Request.codeLocation of Location.Remote, or slot decimal number for Request.codeLocation of Location.DONHosted
    bytes encryptedSecretsReference; // ══╸ Encrypted URLs for Request.secretsLocation of Location.Remote (use addSecretsReference()), or CBOR encoded slotid+version for Request.secretsLocation of Location.DONHosted (use addDONHostedSecrets())
    string[] args; // ════════════════════╸ String arguments that will be passed into the source code
    bytes[] bytesArgs; // ════════════════╸ Bytes arguments that will be passed into the source code
  }

  error EmptySource();
  error EmptySecrets();
  error EmptyArgs();
  error NoInlineSecrets();

  /// @notice Encodes a Request to CBOR encoded bytes
  /// @param self The request to encode
  /// @return CBOR encoded bytes
  function _encodeCBOR(Request memory self) internal pure returns (bytes memory) {
    CBOR.CBORBuffer memory buffer = CBOR.create(DEFAULT_BUFFER_SIZE);

    buffer.writeString("codeLocation");
    buffer.writeUInt256(uint256(self.codeLocation));

    buffer.writeString("language");
    buffer.writeUInt256(uint256(self.language));

    buffer.writeString("source");
    buffer.writeString(self.source);

    if (self.args.length > 0) {
      buffer.writeString("args");
      buffer.startArray();
      for (uint256 i = 0; i < self.args.length; ++i) {
        buffer.writeString(self.args[i]);
      }
      buffer.endSequence();
    }

    if (self.encryptedSecretsReference.length > 0) {
      if (self.secretsLocation == Location.Inline) {
        revert NoInlineSecrets();
      }
      buffer.writeString("secretsLocation");
      buffer.writeUInt256(uint256(self.secretsLocation));
      buffer.writeString("secrets");
      buffer.writeBytes(self.encryptedSecretsReference);
    }

    if (self.bytesArgs.length > 0) {
      buffer.writeString("bytesArgs");
      buffer.startArray();
      for (uint256 i = 0; i < self.bytesArgs.length; ++i) {
        buffer.writeBytes(self.bytesArgs[i]);
      }
      buffer.endSequence();
    }

    return buffer.buf.buf;
  }

  /// @notice Initializes a Chainlink Functions Request
  /// @dev Sets the codeLocation and code on the request
  /// @param self The uninitialized request
  /// @param codeLocation The user provided source code location
  /// @param language The programming language of the user code
  /// @param source The user provided source code or a url
  function _initializeRequest(
    Request memory self,
    Location codeLocation,
    CodeLanguage language,
    string memory source
  ) internal pure {
    if (bytes(source).length == 0) revert EmptySource();

    self.codeLocation = codeLocation;
    self.language = language;
    self.source = source;
  }

  /// @notice Initializes a Chainlink Functions Request
  /// @dev Simplified version of initializeRequest for PoC
  /// @param self The uninitialized request
  /// @param javaScriptSource The user provided JS code (must not be empty)
  function _initializeRequestForInlineJavaScript(Request memory self, string memory javaScriptSource) internal pure {
    _initializeRequest(self, Location.Inline, CodeLanguage.JavaScript, javaScriptSource);
  }

  /// @notice Adds Remote user encrypted secrets to a Request
  /// @param self The initialized request
  /// @param encryptedSecretsReference Encrypted comma-separated string of URLs pointing to off-chain secrets
  function _addSecretsReference(Request memory self, bytes memory encryptedSecretsReference) internal pure {
    if (encryptedSecretsReference.length == 0) revert EmptySecrets();

    self.secretsLocation = Location.Remote;
    self.encryptedSecretsReference = encryptedSecretsReference;
  }

  /// @notice Adds DON-hosted secrets reference to a Request
  /// @param self The initialized request
  /// @param slotID Slot ID of the user's secrets hosted on DON
  /// @param version User data version (for the slotID)
  function _addDONHostedSecrets(Request memory self, uint8 slotID, uint64 version) internal pure {
    CBOR.CBORBuffer memory buffer = CBOR.create(DEFAULT_BUFFER_SIZE);

    buffer.writeString("slotID");
    buffer.writeUInt64(slotID);
    buffer.writeString("version");
    buffer.writeUInt64(version);

    self.secretsLocation = Location.DONHosted;
    self.encryptedSecretsReference = buffer.buf.buf;
  }

  /// @notice Sets args for the user run function
  /// @param self The initialized request
  /// @param args The array of string args (must not be empty)
  function _setArgs(Request memory self, string[] memory args) internal pure {
    if (args.length == 0) revert EmptyArgs();

    self.args = args;
  }

  /// @notice Sets bytes args for the user run function
  /// @param self The initialized request
  /// @param args The array of bytes args (must not be empty)
  function _setBytesArgs(Request memory self, bytes[] memory args) internal pure {
    if (args.length == 0) revert EmptyArgs();

    self.bytesArgs = args;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Library of types that are used for fulfillment of a Functions request
library FunctionsResponse {
  // Used to send request information from the Router to the Coordinator
  struct RequestMeta {
    bytes data; // ══════════════════╸ CBOR encoded Chainlink Functions request data, use FunctionsRequest library to encode a request
    bytes32 flags; // ═══════════════╸ Per-subscription flags
    address requestingContract; // ══╗ The client contract that is sending the request
    uint96 availableBalance; // ═════╝ Common LINK balance of the subscription that is controlled by the Router to be used for all consumer requests.
    uint72 adminFee; // ═════════════╗ Flat fee (in Juels of LINK) that will be paid to the Router Owner for operation of the network
    uint64 subscriptionId; //        ║ Identifier of the billing subscription that will be charged for the request
    uint64 initiatedRequests; //     ║ The number of requests that have been started
    uint32 callbackGasLimit; //      ║ The amount of gas that the callback to the consuming contract will be given
    uint16 dataVersion; // ══════════╝ The version of the structure of the CBOR encoded request data
    uint64 completedRequests; // ════╗ The number of requests that have successfully completed or timed out
    address subscriptionOwner; // ═══╝ The owner of the billing subscription
  }

  enum FulfillResult {
    FULFILLED, // 0
    USER_CALLBACK_ERROR, // 1
    INVALID_REQUEST_ID, // 2
    COST_EXCEEDS_COMMITMENT, // 3
    INSUFFICIENT_GAS_PROVIDED, // 4
    SUBSCRIPTION_BALANCE_INVARIANT_VIOLATION, // 5
    INVALID_COMMITMENT // 6
  }

  struct Commitment {
    bytes32 requestId; // ═════════════════╸ A unique identifier for a Chainlink Functions request
    address coordinator; // ═══════════════╗ The Coordinator contract that manages the DON that is servicing a request
    uint96 estimatedTotalCostJuels; // ════╝ The maximum cost in Juels (1e18) of LINK that will be charged to fulfill a request
    address client; // ════════════════════╗ The client contract that sent the request
    uint64 subscriptionId; //              ║ Identifier of the billing subscription that will be charged for the request
    uint32 callbackGasLimit; // ═══════════╝ The amount of gas that the callback to the consuming contract will be given
    uint72 adminFee; // ═══════════════════╗ Flat fee (in Juels of LINK) that will be paid to the Router Owner for operation of the network
    uint72 donFee; //                      ║ Fee (in Juels of LINK) that will be split between Node Operators for servicing a request
    uint40 gasOverheadBeforeCallback; //   ║ Represents the average gas execution cost before the fulfillment callback.
    uint40 gasOverheadAfterCallback; //    ║ Represents the average gas execution cost after the fulfillment callback.
    uint32 timeoutTimestamp; // ═══════════╝ The timestamp at which a request will be eligible to be timed out
  }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract FunctionsV1EventsMock {
  // solhint-disable-next-line gas-struct-packing
  struct Config {
    uint16 maxConsumersPerSubscription;
    uint72 adminFee;
    bytes4 handleOracleFulfillmentSelector;
    uint16 gasForCallExactCheck;
    uint32[] maxCallbackGasLimits;
  }

  event ConfigUpdated(Config param1);
  event ContractProposed(
    bytes32 proposedContractSetId,
    address proposedContractSetFromAddress,
    address proposedContractSetToAddress
  );
  event ContractUpdated(bytes32 id, address from, address to);
  event FundsRecovered(address to, uint256 amount);
  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);
  event Paused(address account);
  event RequestNotProcessed(bytes32 indexed requestId, address coordinator, address transmitter, uint8 resultCode);
  event RequestProcessed(
    bytes32 indexed requestId,
    uint64 indexed subscriptionId,
    uint96 totalCostJuels,
    address transmitter,
    uint8 resultCode,
    bytes response,
    bytes err,
    bytes callbackReturnData
  );
  event RequestStart(
    bytes32 indexed requestId,
    bytes32 indexed donId,
    uint64 indexed subscriptionId,
    address subscriptionOwner,
    address requestingContract,
    address requestInitiator,
    bytes data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    uint96 estimatedTotalCostJuels
  );
  event RequestTimedOut(bytes32 indexed requestId);
  event SubscriptionCanceled(uint64 indexed subscriptionId, address fundsRecipient, uint256 fundsAmount);
  event SubscriptionConsumerAdded(uint64 indexed subscriptionId, address consumer);
  event SubscriptionConsumerRemoved(uint64 indexed subscriptionId, address consumer);
  event SubscriptionCreated(uint64 indexed subscriptionId, address owner);
  event SubscriptionFunded(uint64 indexed subscriptionId, uint256 oldBalance, uint256 newBalance);
  event SubscriptionOwnerTransferRequested(uint64 indexed subscriptionId, address from, address to);
  event SubscriptionOwnerTransferred(uint64 indexed subscriptionId, address from, address to);
  event Unpaused(address account);

  function emitConfigUpdated(Config memory param1) public {
    emit ConfigUpdated(param1);
  }

  function emitContractProposed(
    bytes32 proposedContractSetId,
    address proposedContractSetFromAddress,
    address proposedContractSetToAddress
  ) public {
    emit ContractProposed(proposedContractSetId, proposedContractSetFromAddress, proposedContractSetToAddress);
  }

  function emitContractUpdated(bytes32 id, address from, address to) public {
    emit ContractUpdated(id, from, to);
  }

  function emitFundsRecovered(address to, uint256 amount) public {
    emit FundsRecovered(to, amount);
  }

  function emitOwnershipTransferRequested(address from, address to) public {
    emit OwnershipTransferRequested(from, to);
  }

  function emitOwnershipTransferred(address from, address to) public {
    emit OwnershipTransferred(from, to);
  }

  function emitPaused(address account) public {
    emit Paused(account);
  }

  function emitRequestNotProcessed(
    bytes32 requestId,
    address coordinator,
    address transmitter,
    uint8 resultCode
  ) public {
    emit RequestNotProcessed(requestId, coordinator, transmitter, resultCode);
  }

  function emitRequestProcessed(
    bytes32 requestId,
    uint64 subscriptionId,
    uint96 totalCostJuels,
    address transmitter,
    uint8 resultCode,
    bytes memory response,
    bytes memory err,
    bytes memory callbackReturnData
  ) public {
    emit RequestProcessed(
      requestId,
      subscriptionId,
      totalCostJuels,
      transmitter,
      resultCode,
      response,
      err,
      callbackReturnData
    );
  }

  function emitRequestStart(
    bytes32 requestId,
    bytes32 donId,
    uint64 subscriptionId,
    address subscriptionOwner,
    address requestingContract,
    address requestInitiator,
    bytes memory data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    uint96 estimatedTotalCostJuels
  ) public {
    emit RequestStart(
      requestId,
      donId,
      subscriptionId,
      subscriptionOwner,
      requestingContract,
      requestInitiator,
      data,
      dataVersion,
      callbackGasLimit,
      estimatedTotalCostJuels
    );
  }

  function emitRequestTimedOut(bytes32 requestId) public {
    emit RequestTimedOut(requestId);
  }

  function emitSubscriptionCanceled(uint64 subscriptionId, address fundsRecipient, uint256 fundsAmount) public {
    emit SubscriptionCanceled(subscriptionId, fundsRecipient, fundsAmount);
  }

  function emitSubscriptionConsumerAdded(uint64 subscriptionId, address consumer) public {
    emit SubscriptionConsumerAdded(subscriptionId, consumer);
  }

  function emitSubscriptionConsumerRemoved(uint64 subscriptionId, address consumer) public {
    emit SubscriptionConsumerRemoved(subscriptionId, consumer);
  }

  function emitSubscriptionCreated(uint64 subscriptionId, address owner) public {
    emit SubscriptionCreated(subscriptionId, owner);
  }

  function emitSubscriptionFunded(uint64 subscriptionId, uint256 oldBalance, uint256 newBalance) public {
    emit SubscriptionFunded(subscriptionId, oldBalance, newBalance);
  }

  function emitSubscriptionOwnerTransferRequested(uint64 subscriptionId, address from, address to) public {
    emit SubscriptionOwnerTransferRequested(subscriptionId, from, to);
  }

  function emitSubscriptionOwnerTransferred(uint64 subscriptionId, address from, address to) public {
    emit SubscriptionOwnerTransferred(subscriptionId, from, to);
  }

  function emitUnpaused(address account) public {
    emit Unpaused(account);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITypeAndVersion} from "../../../../shared/interfaces/ITypeAndVersion.sol";

abstract contract OCR2Abstract is ITypeAndVersion {
  // Maximum number of oracles the offchain reporting protocol is designed for
  uint256 internal constant MAX_NUM_ORACLES = 31;

  /**
   * @notice triggers a new run of the offchain reporting protocol
   * @param previousConfigBlockNumber block in which the previous config was set, to simplify historic analysis
   * @param configDigest configDigest of this configuration
   * @param configCount ordinal number of this config setting among all config settings over the life of this contract
   * @param signers ith element is address ith oracle uses to sign a report
   * @param transmitters ith element is address ith oracle uses to transmit a report via the transmit method
   * @param f maximum number of faulty/dishonest oracles the protocol can tolerate while still working correctly
   * @param onchainConfig serialized configuration used by the contract (and possibly oracles)
   * @param offchainConfigVersion version of the serialization format used for "offchainConfig" parameter
   * @param offchainConfig serialized configuration used by the oracles exclusively and only passed through the contract
   */
  event ConfigSet(
    uint32 previousConfigBlockNumber,
    bytes32 configDigest,
    uint64 configCount,
    address[] signers,
    address[] transmitters,
    uint8 f,
    bytes onchainConfig,
    uint64 offchainConfigVersion,
    bytes offchainConfig
  );

  /**
   * @notice sets offchain reporting protocol configuration incl. participating oracles
   * @param signers addresses with which oracles sign the reports
   * @param transmitters addresses oracles use to transmit the reports
   * @param f number of faulty oracles the system can tolerate
   * @param onchainConfig serialized configuration used by the contract (and possibly oracles)
   * @param offchainConfigVersion version number for offchainEncoding schema
   * @param offchainConfig serialized configuration used by the oracles exclusively and only passed through the contract
   */
  function setConfig(
    address[] memory signers,
    address[] memory transmitters,
    uint8 f,
    bytes memory onchainConfig,
    uint64 offchainConfigVersion,
    bytes memory offchainConfig
  ) external virtual;

  /**
   * @notice information about current offchain reporting protocol configuration
   * @return configCount ordinal number of current config, out of all configs applied to this contract so far
   * @return blockNumber block at which this config was set
   * @return configDigest domain-separation tag for current config (see _configDigestFromConfigData)
   */
  function latestConfigDetails()
    external
    view
    virtual
    returns (uint32 configCount, uint32 blockNumber, bytes32 configDigest);

  /**
    * @notice optionally emited to indicate the latest configDigest and epoch for
     which a report was successfully transmited. Alternatively, the contract may
     use latestConfigDigestAndEpoch with scanLogs set to false.
  */
  event Transmitted(bytes32 configDigest, uint32 epoch);

  /**
     * @notice optionally returns the latest configDigest and epoch for which a
     report was successfully transmitted. Alternatively, the contract may return
     scanLogs set to true and use Transmitted events to provide this information
     to offchain watchers.
   * @return scanLogs indicates whether to rely on the configDigest and epoch
     returned or whether to scan logs for the Transmitted event instead.
   * @return configDigest
   * @return epoch
   */
  function latestConfigDigestAndEpoch()
    external
    view
    virtual
    returns (bool scanLogs, bytes32 configDigest, uint32 epoch);

  /**
   * @notice transmit is called to post a new report to the contract
   * @param report serialized report, which the signatures are signing.
   * @param rs ith element is the R components of the ith signature on report. Must have at most maxNumOracles entries
   * @param ss ith element is the S components of the ith signature on report. Must have at most maxNumOracles entries
   * @param rawVs ith element is the the V component of the ith signature
   */
  function transmit(
    // NOTE: If these parameters are changed, expectedMsgDataLength and/or
    // TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT need to be changed accordingly
    bytes32[3] calldata reportContext,
    bytes calldata report,
    bytes32[] calldata rs,
    bytes32[] calldata ss,
    bytes32 rawVs // signatures
  ) external virtual;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwner} from "../../../../shared/access/ConfirmedOwner.sol";
import {OCR2Abstract} from "./OCR2Abstract.sol";

/**
 * @notice Onchain verification of reports from the offchain reporting protocol
 * @dev For details on its operation, see the offchain reporting protocol design
 * doc, which refers to this contract as simply the "contract".
 */
abstract contract OCR2Base is ConfirmedOwner, OCR2Abstract {
  error ReportInvalid(string message);
  error InvalidConfig(string message);

  constructor() ConfirmedOwner(msg.sender) {}

  // incremented each time a new config is posted. This count is incorporated
  // into the config digest, to prevent replay attacks.
  uint32 internal s_configCount;
  uint32 internal s_latestConfigBlockNumber; // makes it easier for offchain systems
  // to extract config from logs.

  // Storing these fields used on the hot path in a ConfigInfo variable reduces the
  // retrieval of all of them into two SLOADs. If any further fields are
  // added, make sure that storage of the struct still takes at most 64 bytes.
  struct ConfigInfo {
    bytes32 latestConfigDigest;
    uint8 f; // ───╮
    uint8 n; // ───╯
  }
  ConfigInfo internal s_configInfo;

  // Used for s_oracles[a].role, where a is an address, to track the purpose
  // of the address, or to indicate that the address is unset.
  enum Role {
    // No oracle role has been set for address a
    Unset,
    // Signing address for the s_oracles[a].index'th oracle. I.e., report
    // signatures from this oracle should ecrecover back to address a.
    Signer,
    // Transmission address for the s_oracles[a].index'th oracle. I.e., if a
    // report is received by OCR2Aggregator.transmit in which msg.sender is
    // a, it is attributed to the s_oracles[a].index'th oracle.
    Transmitter
  }

  struct Oracle {
    uint8 index; // Index of oracle in s_signers/s_transmitters
    Role role; // Role of the address which mapped to this struct
  }

  mapping(address signerOrTransmitter => Oracle) internal s_oracles;

  // s_signers contains the signing address of each oracle
  address[] internal s_signers;

  // s_transmitters contains the transmission address of each oracle,
  // i.e. the address the oracle actually sends transactions to the contract from
  address[] internal s_transmitters;

  struct DecodedReport {
    bytes32[] requestIds;
    bytes[] results;
    bytes[] errors;
    bytes[] onchainMetadata;
    bytes[] offchainMetadata;
  }

  /*
   * Config logic
   */

  // Reverts transaction if config args are invalid
  modifier checkConfigValid(
    uint256 numSigners,
    uint256 numTransmitters,
    uint256 f
  ) {
    if (numSigners > MAX_NUM_ORACLES) revert InvalidConfig("too many signers");
    if (f == 0) revert InvalidConfig("f must be positive");
    if (numSigners != numTransmitters) revert InvalidConfig("oracle addresses out of registration");
    if (numSigners <= 3 * f) revert InvalidConfig("faulty-oracle f too high");
    _;
  }

  // solhint-disable-next-line gas-struct-packing
  struct SetConfigArgs {
    address[] signers;
    address[] transmitters;
    uint8 f;
    bytes onchainConfig;
    uint64 offchainConfigVersion;
    bytes offchainConfig;
  }

  /// @inheritdoc OCR2Abstract
  function latestConfigDigestAndEpoch()
    external
    view
    virtual
    override
    returns (bool scanLogs, bytes32 configDigest, uint32 epoch)
  {
    return (true, bytes32(0), uint32(0));
  }

  /**
   * @notice sets offchain reporting protocol configuration incl. participating oracles
   * @param _signers addresses with which oracles sign the reports
   * @param _transmitters addresses oracles use to transmit the reports
   * @param _f number of faulty oracles the system can tolerate
   * @param _onchainConfig encoded on-chain contract configuration
   * @param _offchainConfigVersion version number for offchainEncoding schema
   * @param _offchainConfig encoded off-chain oracle configuration
   */
  function setConfig(
    address[] memory _signers,
    address[] memory _transmitters,
    uint8 _f,
    bytes memory _onchainConfig,
    uint64 _offchainConfigVersion,
    bytes memory _offchainConfig
  ) external override checkConfigValid(_signers.length, _transmitters.length, _f) onlyOwner {
    SetConfigArgs memory args = SetConfigArgs({
      signers: _signers,
      transmitters: _transmitters,
      f: _f,
      onchainConfig: _onchainConfig,
      offchainConfigVersion: _offchainConfigVersion,
      offchainConfig: _offchainConfig
    });

    _beforeSetConfig(args.f, args.onchainConfig);

    while (s_signers.length != 0) {
      // remove any old signer/transmitter addresses
      uint256 lastIdx = s_signers.length - 1;
      address signer = s_signers[lastIdx];
      address transmitter = s_transmitters[lastIdx];
      delete s_oracles[signer];
      delete s_oracles[transmitter];
      s_signers.pop();
      s_transmitters.pop();
    }

    // Bounded by MAX_NUM_ORACLES in OCR2Abstract.sol
    for (uint256 i = 0; i < args.signers.length; i++) {
      if (args.signers[i] == address(0)) revert InvalidConfig("signer must not be empty");
      if (args.transmitters[i] == address(0)) revert InvalidConfig("transmitter must not be empty");
      // add new signer/transmitter addresses
      if (s_oracles[args.signers[i]].role != Role.Unset) revert InvalidConfig("repeated signer address");
      s_oracles[args.signers[i]] = Oracle(uint8(i), Role.Signer);
      if (s_oracles[args.transmitters[i]].role != Role.Unset) revert InvalidConfig("repeated transmitter address");
      s_oracles[args.transmitters[i]] = Oracle(uint8(i), Role.Transmitter);
      s_signers.push(args.signers[i]);
      s_transmitters.push(args.transmitters[i]);
    }
    s_configInfo.f = args.f;
    uint32 previousConfigBlockNumber = s_latestConfigBlockNumber;
    s_latestConfigBlockNumber = uint32(block.number);
    s_configCount += 1;
    {
      s_configInfo.latestConfigDigest = _configDigestFromConfigData(
        block.chainid,
        address(this),
        s_configCount,
        args.signers,
        args.transmitters,
        args.f,
        args.onchainConfig,
        args.offchainConfigVersion,
        args.offchainConfig
      );
    }
    s_configInfo.n = uint8(args.signers.length);

    emit ConfigSet(
      previousConfigBlockNumber,
      s_configInfo.latestConfigDigest,
      s_configCount,
      args.signers,
      args.transmitters,
      args.f,
      args.onchainConfig,
      args.offchainConfigVersion,
      args.offchainConfig
    );
  }

  function _configDigestFromConfigData(
    uint256 _chainId,
    address _contractAddress,
    uint64 _configCount,
    address[] memory _signers,
    address[] memory _transmitters,
    uint8 _f,
    bytes memory _onchainConfig,
    uint64 _encodedConfigVersion,
    bytes memory _encodedConfig
  ) internal pure returns (bytes32) {
    uint256 h = uint256(
      keccak256(
        abi.encode(
          _chainId,
          _contractAddress,
          _configCount,
          _signers,
          _transmitters,
          _f,
          _onchainConfig,
          _encodedConfigVersion,
          _encodedConfig
        )
      )
    );
    uint256 prefixMask = type(uint256).max << (256 - 16); // 0xFFFF00..00
    uint256 prefix = 0x0001 << (256 - 16); // 0x000100..00
    return bytes32(prefix | (h & ~prefixMask));
  }

  /**
   * @notice information about current offchain reporting protocol configuration
   * @return configCount ordinal number of current config, out of all configs applied to this contract so far
   * @return blockNumber block at which this config was set
   * @return configDigest domain-separation tag for current config (see __configDigestFromConfigData)
   */
  function latestConfigDetails()
    external
    view
    override
    returns (uint32 configCount, uint32 blockNumber, bytes32 configDigest)
  {
    return (s_configCount, s_latestConfigBlockNumber, s_configInfo.latestConfigDigest);
  }

  /**
   * @return list of addresses permitted to transmit reports to this contract
   * @dev The list will match the order used to specify the transmitter during setConfig
   */
  function transmitters() external view returns (address[] memory) {
    return s_transmitters;
  }

  function _beforeSetConfig(uint8 _f, bytes memory _onchainConfig) internal virtual;

  /**
   * @dev hook called after the report has been fully validated
   * for the extending contract to handle additional logic, such as oracle payment
   * @param decodedReport decodedReport
   */
  function _report(DecodedReport memory decodedReport) internal virtual;

  // The constant-length components of the msg.data sent to transmit.
  // See the "If we wanted to call sam" example on for example reasoning
  // https://solidity.readthedocs.io/en/v0.7.2/abi-spec.html
  uint16 private constant TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT =
    4 + // function selector
      32 *
      3 + // 3 words containing reportContext
      32 + // word containing start location of abiencoded report value
      32 + // word containing location start of abiencoded rs value
      32 + // word containing start location of abiencoded ss value
      32 + // rawVs value
      32 + // word containing length of report
      32 + // word containing length rs
      32 + // word containing length of ss
      0; // placeholder

  function _requireExpectedMsgDataLength(
    bytes calldata report,
    bytes32[] calldata rs,
    bytes32[] calldata ss
  ) private pure {
    // calldata will never be big enough to make this overflow
    uint256 expected = uint256(TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT) +
      report.length + // one byte pure entry in _report
      rs.length *
      32 + // 32 bytes per entry in _rs
      ss.length *
      32 + // 32 bytes per entry in _ss
      0; // placeholder
    if (msg.data.length != expected) revert ReportInvalid("calldata length mismatch");
  }

  function _beforeTransmit(
    bytes calldata report
  ) internal virtual returns (bool shouldStop, DecodedReport memory decodedReport);

  /**
   * @notice transmit is called to post a new report to the contract
   * @param report serialized report, which the signatures are signing.
   * @param rs ith element is the R components of the ith signature on report. Must have at most maxNumOracles entries
   * @param ss ith element is the S components of the ith signature on report. Must have at most maxNumOracles entries
   * @param rawVs ith element is the the V component of the ith signature
   */
  function transmit(
    // NOTE: If these parameters are changed, expectedMsgDataLength and/or
    // TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT need to be changed accordingly
    bytes32[3] calldata reportContext,
    bytes calldata report,
    bytes32[] calldata rs,
    bytes32[] calldata ss,
    bytes32 rawVs // signatures
  ) external override {
    (bool shouldStop, DecodedReport memory decodedReport) = _beforeTransmit(report);

    if (shouldStop) {
      return;
    }

    {
      // reportContext consists of:
      // reportContext[0]: ConfigDigest
      // reportContext[1]: 27 byte padding, 4-byte epoch and 1-byte round
      // reportContext[2]: ExtraHash
      bytes32 configDigest = reportContext[0];
      uint32 epochAndRound = uint32(uint256(reportContext[1]));

      emit Transmitted(configDigest, uint32(epochAndRound >> 8));

      // The following check is disabled to allow both current and proposed routes to submit reports using the same OCR config digest
      // Chainlink Functions uses globally unique request IDs. Metadata about the request is stored and checked in the Coordinator and Router
      // require(configInfo.latestConfigDigest == configDigest, "configDigest mismatch");

      _requireExpectedMsgDataLength(report, rs, ss);

      uint256 expectedNumSignatures = (s_configInfo.n + s_configInfo.f) / 2 + 1;

      if (rs.length != expectedNumSignatures) revert ReportInvalid("wrong number of signatures");
      if (rs.length != ss.length) revert ReportInvalid("report rs and ss must be of equal length");

      Oracle memory transmitter = s_oracles[msg.sender];
      if (transmitter.role != Role.Transmitter && msg.sender != s_transmitters[transmitter.index])
        revert ReportInvalid("unauthorized transmitter");
    }

    address[MAX_NUM_ORACLES] memory signed;

    {
      // Verify signatures attached to report
      bytes32 h = keccak256(abi.encodePacked(keccak256(report), reportContext));

      Oracle memory o;
      // Bounded by MAX_NUM_ORACLES in OCR2Abstract.sol
      for (uint256 i = 0; i < rs.length; ++i) {
        address signer = ecrecover(h, uint8(rawVs[i]) + 27, rs[i], ss[i]);
        o = s_oracles[signer];
        if (o.role != Role.Signer) revert ReportInvalid("address not authorized to sign");
        if (signed[o.index] != address(0)) revert ReportInvalid("non-unique signature");
        signed[o.index] = signer;
      }
    }

    _report(decodedReport);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsRequest} from "../../../dev/v1_X/libraries/FunctionsRequest.sol";
import {FunctionsClient} from "../../../dev/v1_X/FunctionsClient.sol";
import {ConfirmedOwner} from "../../../../shared/access/ConfirmedOwner.sol";

contract FunctionsClientUpgradeHelper is FunctionsClient, ConfirmedOwner {
  using FunctionsRequest for FunctionsRequest.Request;

  constructor(address router) FunctionsClient(router) ConfirmedOwner(msg.sender) {}

  event ResponseReceived(bytes32 indexed requestId, bytes result, bytes err);

  /**
   * @notice Send a simple request
   *
   * @param donId DON ID
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param callbackGasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function sendRequest(
    bytes32 donId,
    string calldata source,
    bytes calldata secrets,
    string[] calldata args,
    bytes[] memory bytesArgs,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) public onlyOwner returns (bytes32) {
    FunctionsRequest.Request memory req;
    req._initializeRequestForInlineJavaScript(source);
    if (secrets.length > 0) req._addSecretsReference(secrets);
    if (args.length > 0) req._setArgs(args);
    if (bytesArgs.length > 0) req._setBytesArgs(bytesArgs);

    return _sendRequest(FunctionsRequest._encodeCBOR(req), subscriptionId, callbackGasLimit, donId);
  }

  function sendRequestBytes(
    bytes memory data,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    bytes32 donId
  ) public returns (bytes32 requestId) {
    return _sendRequest(data, subscriptionId, callbackGasLimit, donId);
  }

  /**
   * @notice Same as sendRequest but for DONHosted secrets
   */
  function sendRequestWithDONHostedSecrets(
    bytes32 donId,
    string calldata source,
    uint8 slotId,
    uint64 slotVersion,
    string[] calldata args,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) public onlyOwner returns (bytes32) {
    FunctionsRequest.Request memory req;
    req._initializeRequestForInlineJavaScript(source);
    req._addDONHostedSecrets(slotId, slotVersion);

    if (args.length > 0) req._setArgs(args);

    return _sendRequest(FunctionsRequest._encodeCBOR(req), subscriptionId, callbackGasLimit, donId);
  }

  // @notice Sends a Chainlink Functions request
  // @param data The CBOR encoded bytes data for a Functions request
  // @param subscriptionId The subscription ID that will be charged to service the request
  // @param callbackGasLimit the amount of gas that will be available for the fulfillment callback
  // @return requestId The generated request ID for this request
  function _sendRequestToProposed(
    bytes memory data,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    bytes32 donId
  ) internal returns (bytes32) {
    bytes32 requestId = i_functionsRouter.sendRequestToProposed(
      subscriptionId,
      data,
      FunctionsRequest.REQUEST_DATA_VERSION,
      callbackGasLimit,
      donId
    );
    emit RequestSent(requestId);
    return requestId;
  }

  /**
   * @notice Send a simple request to the proposed contract
   *
   * @param donId DON ID
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param callbackGasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function sendRequestToProposed(
    bytes32 donId,
    string calldata source,
    bytes calldata secrets,
    string[] calldata args,
    bytes[] memory bytesArgs,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) public onlyOwner returns (bytes32) {
    FunctionsRequest.Request memory req;
    req._initializeRequestForInlineJavaScript(source);
    if (secrets.length > 0) req._addSecretsReference(secrets);
    if (args.length > 0) req._setArgs(args);
    if (bytesArgs.length > 0) req._setBytesArgs(bytesArgs);

    return _sendRequestToProposed(FunctionsRequest._encodeCBOR(req), subscriptionId, callbackGasLimit, donId);
  }

  /**
   * @notice Same as sendRequestToProposed but for DONHosted secrets
   */
  function sendRequestToProposedWithDONHostedSecrets(
    bytes32 donId,
    string calldata source,
    uint8 slotId,
    uint64 slotVersion,
    string[] calldata args,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) public onlyOwner returns (bytes32) {
    FunctionsRequest.Request memory req;
    req._initializeRequestForInlineJavaScript(source);
    req._addDONHostedSecrets(slotId, slotVersion);

    if (args.length > 0) req._setArgs(args);

    return _sendRequestToProposed(FunctionsRequest._encodeCBOR(req), subscriptionId, callbackGasLimit, donId);
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    emit ResponseReceived(requestId, response, err);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfirmedOwnerWithProposal} from "./ConfirmedOwnerWithProposal.sol";

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IOwnable} from "../interfaces/IOwnable.sol";

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccessController {
  function hasAccess(address user, bytes calldata data) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC677Receiver {
  function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITypeAndVersion {
  function typeAndVersion() external pure returns (string memory);
}
// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/OffchainLabs/nitro-contracts/blob/main/LICENSE
// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.4.21 <0.9.0;

/// @title Provides insight into the cost of using the chain.
/// @notice These methods have been adjusted to account for Nitro's heavy use of calldata compression.
/// Of note to end-users, we no longer make a distinction between non-zero and zero-valued calldata bytes.
/// Precompiled contract that exists in every Arbitrum chain at 0x000000000000000000000000000000000000006c.
interface ArbGasInfo {
    /// @notice Get gas prices for a provided aggregator
    /// @return return gas prices in wei
    ///        (
    ///            per L2 tx,
    ///            per L1 calldata byte
    ///            per storage allocation,
    ///            per ArbGas base,
    ///            per ArbGas congestion,
    ///            per ArbGas total
    ///        )
    function getPricesInWeiWithAggregator(address aggregator)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );

    /// @notice Get gas prices. Uses the caller's preferred aggregator, or the default if the caller doesn't have a preferred one.
    /// @return return gas prices in wei
    ///        (
    ///            per L2 tx,
    ///            per L1 calldata byte
    ///            per storage allocation,
    ///            per ArbGas base,
    ///            per ArbGas congestion,
    ///            per ArbGas total
    ///        )
    function getPricesInWei()
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    );

    /// @notice Get prices in ArbGas for the supplied aggregator
    /// @return (per L2 tx, per L1 calldata byte, per storage allocation)
    function getPricesInArbGasWithAggregator(address aggregator)
    external
    view
    returns (
        uint256,
        uint256,
        uint256
    );

    /// @notice Get prices in ArbGas. Assumes the callers preferred validator, or the default if caller doesn't have a preferred one.
    /// @return (per L2 tx, per L1 calldata byte, per storage allocation)
    function getPricesInArbGas()
    external
    view
    returns (
        uint256,
        uint256,
        uint256
    );

    /// @notice Get the gas accounting parameters. `gasPoolMax` is always zero, as the exponential pricing model has no such notion.
    /// @return (speedLimitPerSecond, gasPoolMax, maxTxGasLimit)
    function getGasAccountingParams()
    external
    view
    returns (
        uint256,
        uint256,
        uint256
    );

    /// @notice Get the minimum gas price needed for a tx to succeed
    function getMinimumGasPrice() external view returns (uint256);

    /// @notice Get ArbOS's estimate of the L1 basefee in wei
    function getL1BaseFeeEstimate() external view returns (uint256);

    /// @notice Get how slowly ArbOS updates its estimate of the L1 basefee
    function getL1BaseFeeEstimateInertia() external view returns (uint64);

    /// @notice Get the L1 pricer reward rate, in wei per unit
    /// Available in ArbOS version 11
    function getL1RewardRate() external view returns (uint64);

    /// @notice Get the L1 pricer reward recipient
    /// Available in ArbOS version 11
    function getL1RewardRecipient() external view returns (address);

    /// @notice Deprecated -- Same as getL1BaseFeeEstimate()
    function getL1GasPriceEstimate() external view returns (uint256);

    /// @notice Get L1 gas fees paid by the current transaction
    function getCurrentTxL1GasFees() external view returns (uint256);

    /// @notice Get the backlogged amount of gas burnt in excess of the speed limit
    function getGasBacklog() external view returns (uint64);

    /// @notice Get how slowly ArbOS updates the L2 basefee in response to backlogged gas
    function getPricingInertia() external view returns (uint64);

    /// @notice Get the forgivable amount of backlogged gas ArbOS will ignore when raising the basefee
    function getGasBacklogTolerance() external view returns (uint64);

    /// @notice Returns the surplus of funds for L1 batch posting payments (may be negative).
    function getL1PricingSurplus() external view returns (int256);

    /// @notice Returns the base charge (in L1 gas) attributed to each data batch in the calldata pricer
    function getPerBatchGasCharge() external view returns (int64);

    /// @notice Returns the cost amortization cap in basis points
    function getAmortizedCostCapBips() external view returns (uint64);

    /// @notice Returns the available funds from L1 fees
    function getL1FeesAvailable() external view returns (uint256);

    /// @notice Returns the equilibration units parameter for L1 price adjustment algorithm
    /// Available in ArbOS version 20
    function getL1PricingEquilibrationUnits() external view returns (uint256);

    /// @notice Returns the last time the L1 calldata pricer was updated.
    /// Available in ArbOS version 20
    function getLastL1PricingUpdateTime() external view returns (uint64);

    /// @notice Returns the amount of L1 calldata payments due for rewards (per the L1 reward rate)
    /// Available in ArbOS version 20
    function getL1PricingFundsDueForRewards() external view returns (uint256);

    /// @notice Returns the amount of L1 calldata posted since the last update.
    /// Available in ArbOS version 20
    function getL1PricingUnitsSinceUpdate() external view returns (uint64);

    /// @notice Returns the L1 pricing surplus as of the last update (may be negative).
    /// Available in ArbOS version 20
    function getLastL1PricingSurplus() external view returns (int256);
}
// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.4;

/**
* @dev A library for working with mutable byte buffers in Solidity.
*
* Byte buffers are mutable and expandable, and provide a variety of primitives
* for appending to them. At any time you can fetch a bytes object containing the
* current contents of the buffer. The bytes object should not be stored between
* operations, as it may change due to resizing of the buffer.
*/
library Buffer {
    /**
    * @dev Represents a mutable buffer. Buffers have a current value (buf) and
    *      a capacity. The capacity may be longer than the current value, in
    *      which case it can be extended without the need to allocate more memory.
    */
    struct buffer {
        bytes buf;
        uint capacity;
    }

    /**
    * @dev Initializes a buffer with an initial capacity.
    * @param buf The buffer to initialize.
    * @param capacity The number of bytes of space to allocate the buffer.
    * @return The buffer, for chaining.
    */
    function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            let fpm := add(32, add(ptr, capacity))
            if lt(fpm, ptr) {
                revert(0, 0)
            }
            mstore(0x40, fpm)
        }
        return buf;
    }

    /**
    * @dev Initializes a new buffer from an existing bytes object.
    *      Changes to the buffer may mutate the original value.
    * @param b The bytes object to initialize the buffer with.
    * @return A new buffer.
    */
    function fromBytes(bytes memory b) internal pure returns(buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    /**
    * @dev Sets buffer length to 0.
    * @param buf The buffer to truncate.
    * @return The original buffer, for chaining..
    */
    function truncate(buffer memory buf) internal pure returns (buffer memory) {
        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }

    /**
    * @dev Appends len bytes of a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to copy.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data, uint len) internal pure returns(buffer memory) {
        require(len <= data.length);

        uint off = buf.buf.length;
        uint newCapacity = off + len;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint dest;
        uint src;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + offset + sizeof(buffer length)
            dest := add(add(bufptr, 32), off)
            // Update buffer length if we're extending it
            if gt(newCapacity, buflen) {
                mstore(bufptr, newCapacity)
            }
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        unchecked {
            uint mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }

        return buf;
    }

    /**
    * @dev Appends a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
        return append(buf, data, data.length);
    }

    /**
    * @dev Appends a byte to the buffer. Resizes if doing so would exceed the
    *      capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint offPlusOne = off + 1;
        if (off >= buf.capacity) {
            resize(buf, offPlusOne * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + off
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            // Update buffer length if we extended it
            if gt(offPlusOne, mload(bufptr)) {
                mstore(bufptr, offPlusOne)
            }
        }

        return buf;
    }

    /**
    * @dev Appends len bytes of bytes32 to a buffer. Resizes if doing so would
    *      exceed the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to write (left-aligned).
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes32 data, uint len) private pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        unchecked {
            uint mask = (256 ** len) - 1;
            // Right-align data
            data = data >> (8 * (32 - len));
            assembly {
                // Memory address of the buffer data
                let bufptr := mload(buf)
                // Address = buffer address + sizeof(buffer length) + newCapacity
                let dest := add(bufptr, newCapacity)
                mstore(dest, or(and(mload(dest), not(mask)), data))
                // Update buffer length if we extended it
                if gt(newCapacity, mload(bufptr)) {
                    mstore(bufptr, newCapacity)
                }
            }
        }
        return buf;
    }

    /**
    * @dev Appends a bytes20 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chhaining.
    */
    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
        return append(buf, bytes32(data), 20);
    }

    /**
    * @dev Appends a bytes32 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
        return append(buf, data, 32);
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     *      exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @param len The number of bytes to write (right-aligned).
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint mask = (256 ** len) - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + newCapacity
            let dest := add(bufptr, newCapacity)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length if we extended it
            if gt(newCapacity, mload(bufptr)) {
                mstore(bufptr, newCapacity)
            }
        }
        return buf;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Burn} from "../libraries/Burn.sol";
import {Arithmetic} from "../libraries/Arithmetic.sol";

/// @custom:upgradeable
/// @title ResourceMetering
/// @notice ResourceMetering implements an EIP-1559 style resource metering system where pricing
///         updates automatically based on current demand.
abstract contract ResourceMetering is Initializable {
  /// @notice Error returned when too much gas resource is consumed.
  error OutOfGas();

  /// @notice Represents the various parameters that control the way in which resources are
  ///         metered. Corresponds to the EIP-1559 resource metering system.
  /// @custom:field prevBaseFee   Base fee from the previous block(s).
  /// @custom:field prevBoughtGas Amount of gas bought so far in the current block.
  /// @custom:field prevBlockNum  Last block number that the base fee was updated.
  struct ResourceParams {
    uint128 prevBaseFee;
    uint64 prevBoughtGas;
    uint64 prevBlockNum;
  }

  /// @notice Represents the configuration for the EIP-1559 based curve for the deposit gas
  ///         market. These values should be set with care as it is possible to set them in
  ///         a way that breaks the deposit gas market. The target resource limit is defined as
  ///         maxResourceLimit / elasticityMultiplier. This struct was designed to fit within a
  ///         single word. There is additional space for additions in the future.
  /// @custom:field maxResourceLimit             Represents the maximum amount of deposit gas that
  ///                                            can be purchased per block.
  /// @custom:field elasticityMultiplier         Determines the target resource limit along with
  ///                                            the resource limit.
  /// @custom:field baseFeeMaxChangeDenominator  Determines max change on fee per block.
  /// @custom:field minimumBaseFee               The min deposit base fee, it is clamped to this
  ///                                            value.
  /// @custom:field systemTxMaxGas               The amount of gas supplied to the system
  ///                                            transaction. This should be set to the same
  ///                                            number that the op-node sets as the gas limit
  ///                                            for the system transaction.
  /// @custom:field maximumBaseFee               The max deposit base fee, it is clamped to this
  ///                                            value.
  struct ResourceConfig {
    uint32 maxResourceLimit;
    uint8 elasticityMultiplier;
    uint8 baseFeeMaxChangeDenominator;
    uint32 minimumBaseFee;
    uint32 systemTxMaxGas;
    uint128 maximumBaseFee;
  }

  /// @notice EIP-1559 style gas parameters.
  ResourceParams public params;

  /// @notice Reserve extra slots (to a total of 50) in the storage layout for future upgrades.
  uint256[48] private __gap;

  /// @notice Meters access to a function based an amount of a requested resource.
  /// @param _amount Amount of the resource requested.
  modifier metered(uint64 _amount) {
    // Record initial gas amount so we can refund for it later.
    uint256 initialGas = gasleft();

    // Run the underlying function.
    _;

    // Run the metering function.
    _metered(_amount, initialGas);
  }

  /// @notice An internal function that holds all of the logic for metering a resource.
  /// @param _amount     Amount of the resource requested.
  /// @param _initialGas The amount of gas before any modifier execution.
  function _metered(uint64 _amount, uint256 _initialGas) internal {
    // Update block number and base fee if necessary.
    uint256 blockDiff = block.number - params.prevBlockNum;

    ResourceConfig memory config = _resourceConfig();
    int256 targetResourceLimit = int256(uint256(config.maxResourceLimit)) /
      int256(uint256(config.elasticityMultiplier));

    if (blockDiff > 0) {
      // Handle updating EIP-1559 style gas parameters. We use EIP-1559 to restrict the rate
      // at which deposits can be created and therefore limit the potential for deposits to
      // spam the L2 system. Fee scheme is very similar to EIP-1559 with minor changes.
      int256 gasUsedDelta = int256(uint256(params.prevBoughtGas)) - targetResourceLimit;
      int256 baseFeeDelta = (int256(uint256(params.prevBaseFee)) * gasUsedDelta) /
        (targetResourceLimit * int256(uint256(config.baseFeeMaxChangeDenominator)));

      // Update base fee by adding the base fee delta and clamp the resulting value between
      // min and max.
      int256 newBaseFee = Arithmetic.clamp({
        _value: int256(uint256(params.prevBaseFee)) + baseFeeDelta,
        _min: int256(uint256(config.minimumBaseFee)),
        _max: int256(uint256(config.maximumBaseFee))
      });

      // If we skipped more than one block, we also need to account for every empty block.
      // Empty block means there was no demand for deposits in that block, so we should
      // reflect this lack of demand in the fee.
      if (blockDiff > 1) {
        // Update the base fee by repeatedly applying the exponent 1-(1/change_denominator)
        // blockDiff - 1 times. Simulates multiple empty blocks. Clamp the resulting value
        // between min and max.
        newBaseFee = Arithmetic.clamp({
          _value: Arithmetic.cdexp({
            _coefficient: newBaseFee,
            _denominator: int256(uint256(config.baseFeeMaxChangeDenominator)),
            _exponent: int256(blockDiff - 1)
          }),
          _min: int256(uint256(config.minimumBaseFee)),
          _max: int256(uint256(config.maximumBaseFee))
        });
      }

      // Update new base fee, reset bought gas, and update block number.
      params.prevBaseFee = uint128(uint256(newBaseFee));
      params.prevBoughtGas = 0;
      params.prevBlockNum = uint64(block.number);
    }

    // Make sure we can actually buy the resource amount requested by the user.
    params.prevBoughtGas += _amount;
    if (int256(uint256(params.prevBoughtGas)) > int256(uint256(config.maxResourceLimit))) {
      revert OutOfGas();
    }

    // Determine the amount of ETH to be paid.
    uint256 resourceCost = uint256(_amount) * uint256(params.prevBaseFee);

    // We currently charge for this ETH amount as an L1 gas burn, so we convert the ETH amount
    // into gas by dividing by the L1 base fee. We assume a minimum base fee of 1 gwei to avoid
    // division by zero for L1s that don't support 1559 or to avoid excessive gas burns during
    // periods of extremely low L1 demand. One-day average gas fee hasn't dipped below 1 gwei
    // during any 1 day period in the last 5 years, so should be fine.
    uint256 gasCost = resourceCost / Math.max(block.basefee, 1 gwei);

    // Give the user a refund based on the amount of gas they used to do all of the work up to
    // this point. Since we're at the end of the modifier, this should be pretty accurate. Acts
    // effectively like a dynamic stipend (with a minimum value).
    uint256 usedGas = _initialGas - gasleft();
    if (gasCost > usedGas) {
      Burn.gas(gasCost - usedGas);
    }
  }

  /// @notice Adds an amount of L2 gas consumed to the prev bought gas params. This is meant to be used
  ///         when L2 system transactions are generated from L1.
  /// @param _amount Amount of the L2 gas resource requested.
  function useGas(uint32 _amount) internal {
    params.prevBoughtGas += uint64(_amount);
  }

  /// @notice Virtual function that returns the resource config.
  ///         Contracts that inherit this contract must implement this function.
  /// @return ResourceConfig
  function _resourceConfig() internal virtual returns (ResourceConfig memory);

  /// @notice Sets initial resource parameter values.
  ///         This function must either be called by the initializer function of an upgradeable
  ///         child contract.
  function __ResourceMetering_init() internal onlyInitializing {
    if (params.prevBlockNum == 0) {
      params = ResourceParams({prevBaseFee: 1 gwei, prevBoughtGas: 0, prevBlockNum: uint64(block.number)});
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ISemver} from "../universal/ISemver.sol";
import {Predeploys} from "../libraries/Predeploys.sol";
import {L1Block} from "../L2/L1Block.sol";
import {Constants} from "../libraries/Constants.sol";
import {LibZip} from "../../../../../solady/src/utils/LibZip.sol";

/// @custom:proxied
/// @custom:predeploy 0x420000000000000000000000000000000000000F
/// @title GasPriceOracle
/// @notice This contract maintains the variables responsible for computing the L1 portion of the
///         total fee charged on L2. Before Bedrock, this contract held variables in state that were
///         read during the state transition function to compute the L1 portion of the transaction
///         fee. After Bedrock, this contract now simply proxies the L1Block contract, which has
///         the values used to compute the L1 portion of the fee in its state.
///
///         The contract exposes an API that is useful for knowing how large the L1 portion of the
///         transaction fee will be. The following events were deprecated with Bedrock:
///         - event OverheadUpdated(uint256 overhead);
///         - event ScalarUpdated(uint256 scalar);
///         - event DecimalsUpdated(uint256 decimals);
contract GasPriceOracle is ISemver {
  /// @notice Number of decimals used in the scalar.
  uint256 public constant DECIMALS = 6;

  /// @notice Semantic version.
  /// @custom:semver 1.3.0
  string public constant version = "1.3.0";

  /// @notice This is the intercept value for the linear regression used to estimate the final size of the
  ///         compressed transaction.
  int32 private constant COST_INTERCEPT = -42_585_600;

  /// @notice This is the coefficient value for the linear regression used to estimate the final size of the
  ///         compressed transaction.
  uint32 private constant COST_FASTLZ_COEF = 836_500;

  /// @notice This is the minimum bound for the fastlz to brotli size estimation. Any estimations below this
  ///         are set to this value.
  uint256 private constant MIN_TRANSACTION_SIZE = 100;

  /// @notice Indicates whether the network has gone through the Ecotone upgrade.
  bool public isEcotone;

  /// @notice Indicates whether the network has gone through the Fjord upgrade.
  bool public isFjord;

  /// @notice Computes the L1 portion of the fee based on the size of the rlp encoded input
  ///         transaction, the current L1 base fee, and the various dynamic parameters.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 fee for.
  /// @return L1 fee that should be paid for the tx
  function getL1Fee(bytes memory _data) external view returns (uint256) {
    if (isFjord) {
      return _getL1FeeFjord(_data);
    } else if (isEcotone) {
      return _getL1FeeEcotone(_data);
    }
    return _getL1FeeBedrock(_data);
  }

  /// @notice returns an upper bound for the L1 fee for a given transaction size.
  /// It is provided for callers who wish to estimate L1 transaction costs in the
  /// write path, and is much more gas efficient than `getL1Fee`.
  /// It assumes the worst case of fastlz upper-bound which covers %99.99 txs.
  /// @param _unsignedTxSize Unsigned fully RLP-encoded transaction size to get the L1 fee for.
  /// @return L1 estimated upper-bound fee that should be paid for the tx
  function getL1FeeUpperBound(uint256 _unsignedTxSize) external view returns (uint256) {
    require(isFjord, "GasPriceOracle: getL1FeeUpperBound only supports Fjord");

    // Add 68 to the size to account for unsigned tx:
    uint256 txSize = _unsignedTxSize + 68;
    // txSize / 255 + 16 is the pratical fastlz upper-bound covers %99.99 txs.
    uint256 flzUpperBound = txSize + txSize / 255 + 16;

    return _fjordL1Cost(flzUpperBound);
  }

  /// @notice Set chain to be Ecotone chain (callable by depositor account)
  function setEcotone() external {
    require(
      msg.sender == Constants.DEPOSITOR_ACCOUNT,
      "GasPriceOracle: only the depositor account can set isEcotone flag"
    );
    require(isEcotone == false, "GasPriceOracle: Ecotone already active");
    isEcotone = true;
  }

  /// @notice Set chain to be Fjord chain (callable by depositor account)
  function setFjord() external {
    require(
      msg.sender == Constants.DEPOSITOR_ACCOUNT,
      "GasPriceOracle: only the depositor account can set isFjord flag"
    );
    require(isEcotone, "GasPriceOracle: Fjord can only be activated after Ecotone");
    require(isFjord == false, "GasPriceOracle: Fjord already active");
    isFjord = true;
  }

  /// @notice Retrieves the current gas price (base fee).
  /// @return Current L2 gas price (base fee).
  function gasPrice() public view returns (uint256) {
    return block.basefee;
  }

  /// @notice Retrieves the current base fee.
  /// @return Current L2 base fee.
  function baseFee() public view returns (uint256) {
    return block.basefee;
  }

  /// @custom:legacy
  /// @notice Retrieves the current fee overhead.
  /// @return Current fee overhead.
  function overhead() public view returns (uint256) {
    require(!isEcotone, "GasPriceOracle: overhead() is deprecated");
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).l1FeeOverhead();
  }

  /// @custom:legacy
  /// @notice Retrieves the current fee scalar.
  /// @return Current fee scalar.
  function scalar() public view returns (uint256) {
    require(!isEcotone, "GasPriceOracle: scalar() is deprecated");
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).l1FeeScalar();
  }

  /// @notice Retrieves the latest known L1 base fee.
  /// @return Latest known L1 base fee.
  function l1BaseFee() public view returns (uint256) {
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).basefee();
  }

  /// @notice Retrieves the current blob base fee.
  /// @return Current blob base fee.
  function blobBaseFee() public view returns (uint256) {
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).blobBaseFee();
  }

  /// @notice Retrieves the current base fee scalar.
  /// @return Current base fee scalar.
  function baseFeeScalar() public view returns (uint32) {
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).baseFeeScalar();
  }

  /// @notice Retrieves the current blob base fee scalar.
  /// @return Current blob base fee scalar.
  function blobBaseFeeScalar() public view returns (uint32) {
    return L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).blobBaseFeeScalar();
  }

  /// @custom:legacy
  /// @notice Retrieves the number of decimals used in the scalar.
  /// @return Number of decimals used in the scalar.
  function decimals() public pure returns (uint256) {
    return DECIMALS;
  }

  /// @notice Computes the amount of L1 gas used for a transaction. Adds 68 bytes
  ///         of padding to account for the fact that the input does not have a signature.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 gas for.
  /// @return Amount of L1 gas used to publish the transaction.
  /// @custom:deprecated This method does not accurately estimate the gas used for a transaction.
  ///                    If you are calculating fees use getL1Fee or getL1FeeUpperBound.
  function getL1GasUsed(bytes memory _data) public view returns (uint256) {
    if (isFjord) {
      // Add 68 to the size to account for unsigned tx
      // Assume the compressed data is mostly non-zero, and would pay 16 gas per calldata byte
      // Divide by 1e6 due to the scaling factor of the linear regression
      return (_fjordLinearRegression(LibZip.flzCompress(_data).length + 68) * 16) / 1e6;
    }
    uint256 l1GasUsed = _getCalldataGas(_data);
    if (isEcotone) {
      return l1GasUsed;
    }
    return l1GasUsed + L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).l1FeeOverhead();
  }

  /// @notice Computation of the L1 portion of the fee for Bedrock.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 fee for.
  /// @return L1 fee that should be paid for the tx
  function _getL1FeeBedrock(bytes memory _data) internal view returns (uint256) {
    uint256 l1GasUsed = _getCalldataGas(_data);
    uint256 fee = (l1GasUsed + L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).l1FeeOverhead()) *
      l1BaseFee() *
      L1Block(Predeploys.L1_BLOCK_ATTRIBUTES).l1FeeScalar();
    return fee / (10 ** DECIMALS);
  }

  /// @notice L1 portion of the fee after Ecotone.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 fee for.
  /// @return L1 fee that should be paid for the tx
  function _getL1FeeEcotone(bytes memory _data) internal view returns (uint256) {
    uint256 l1GasUsed = _getCalldataGas(_data);
    uint256 scaledBaseFee = baseFeeScalar() * 16 * l1BaseFee();
    uint256 scaledBlobBaseFee = blobBaseFeeScalar() * blobBaseFee();
    uint256 fee = l1GasUsed * (scaledBaseFee + scaledBlobBaseFee);
    return fee / (16 * 10 ** DECIMALS);
  }

  /// @notice L1 portion of the fee after Fjord.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 fee for.
  /// @return L1 fee that should be paid for the tx
  function _getL1FeeFjord(bytes memory _data) internal view returns (uint256) {
    return _fjordL1Cost(LibZip.flzCompress(_data).length + 68);
  }

  /// @notice L1 gas estimation calculation.
  /// @param _data Unsigned fully RLP-encoded transaction to get the L1 gas for.
  /// @return Amount of L1 gas used to publish the transaction.
  function _getCalldataGas(bytes memory _data) internal pure returns (uint256) {
    uint256 total = 0;
    uint256 length = _data.length;
    for (uint256 i = 0; i < length; i++) {
      if (_data[i] == 0) {
        total += 4;
      } else {
        total += 16;
      }
    }
    return total + (68 * 16);
  }

  /// @notice Fjord L1 cost based on the compressed and original tx size.
  /// @param _fastLzSize estimated compressed tx size.
  /// @return Fjord L1 fee that should be paid for the tx
  function _fjordL1Cost(uint256 _fastLzSize) internal view returns (uint256) {
    // Apply the linear regression to estimate the Brotli 10 size
    uint256 estimatedSize = _fjordLinearRegression(_fastLzSize);
    uint256 feeScaled = baseFeeScalar() * 16 * l1BaseFee() + blobBaseFeeScalar() * blobBaseFee();
    return (estimatedSize * feeScaled) / (10 ** (DECIMALS * 2));
  }

  /// @notice Takes the fastLz size compression and returns the estimated Brotli
  /// @param _fastLzSize fastlz compressed tx size.
  /// @return Number of bytes in the compressed transaction
  function _fjordLinearRegression(uint256 _fastLzSize) internal pure returns (uint256) {
    int256 estimatedSize = COST_INTERCEPT + int256(COST_FASTLZ_COEF * _fastLzSize);
    if (estimatedSize < int256(MIN_TRANSACTION_SIZE) * 1e6) {
      estimatedSize = int256(MIN_TRANSACTION_SIZE) * 1e6;
    }
    return uint256(estimatedSize);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ISemver} from "../universal/ISemver.sol";
import {Constants} from "../libraries/Constants.sol";
import {GasPayingToken, IGasToken} from "../libraries/GasPayingToken.sol";
import "../libraries/L1BlockErrors.sol";

/// @custom:proxied
/// @custom:predeploy 0x4200000000000000000000000000000000000015
/// @title L1Block
/// @notice The L1Block predeploy gives users access to information about the last known L1 block.
///         Values within this contract are updated once per epoch (every L1 block) and can only be
///         set by the "depositor" account, a special system address. Depositor account transactions
///         are created by the protocol whenever we move to a new epoch.
contract L1Block is ISemver, IGasToken {
  /// @notice Event emitted when the gas paying token is set.
  event GasPayingTokenSet(address indexed token, uint8 indexed decimals, bytes32 name, bytes32 symbol);

  /// @notice Address of the special depositor account.
  function DEPOSITOR_ACCOUNT() public pure returns (address addr_) {
    addr_ = Constants.DEPOSITOR_ACCOUNT;
  }

  /// @notice The latest L1 block number known by the L2 system.
  uint64 public number;

  /// @notice The latest L1 timestamp known by the L2 system.
  uint64 public timestamp;

  /// @notice The latest L1 base fee.
  uint256 public basefee;

  /// @notice The latest L1 blockhash.
  bytes32 public hash;

  /// @notice The number of L2 blocks in the same epoch.
  uint64 public sequenceNumber;

  /// @notice The scalar value applied to the L1 blob base fee portion of the blob-capable L1 cost func.
  uint32 public blobBaseFeeScalar;

  /// @notice The scalar value applied to the L1 base fee portion of the blob-capable L1 cost func.
  uint32 public baseFeeScalar;

  /// @notice The versioned hash to authenticate the batcher by.
  bytes32 public batcherHash;

  /// @notice The overhead value applied to the L1 portion of the transaction fee.
  /// @custom:legacy
  uint256 public l1FeeOverhead;

  /// @notice The scalar value applied to the L1 portion of the transaction fee.
  /// @custom:legacy
  uint256 public l1FeeScalar;

  /// @notice The latest L1 blob base fee.
  uint256 public blobBaseFee;

  /// @custom:semver 1.4.1-beta.1
  function version() public pure virtual returns (string memory) {
    return "1.4.1-beta.1";
  }

  /// @notice Returns the gas paying token, its decimals, name and symbol.
  ///         If nothing is set in state, then it means ether is used.
  function gasPayingToken() public view returns (address addr_, uint8 decimals_) {
    (addr_, decimals_) = GasPayingToken.getToken();
  }

  /// @notice Returns the gas paying token name.
  ///         If nothing is set in state, then it means ether is used.
  function gasPayingTokenName() public view returns (string memory name_) {
    name_ = GasPayingToken.getName();
  }

  /// @notice Returns the gas paying token symbol.
  ///         If nothing is set in state, then it means ether is used.
  function gasPayingTokenSymbol() public view returns (string memory symbol_) {
    symbol_ = GasPayingToken.getSymbol();
  }

  /// @notice Getter for custom gas token paying networks. Returns true if the
  ///         network uses a custom gas token.
  function isCustomGasToken() public view returns (bool) {
    (address token, ) = gasPayingToken();
    return token != Constants.ETHER;
  }

  /// @custom:legacy
  /// @notice Updates the L1 block values.
  /// @param _number         L1 blocknumber.
  /// @param _timestamp      L1 timestamp.
  /// @param _basefee        L1 basefee.
  /// @param _hash           L1 blockhash.
  /// @param _sequenceNumber Number of L2 blocks since epoch start.
  /// @param _batcherHash    Versioned hash to authenticate batcher by.
  /// @param _l1FeeOverhead  L1 fee overhead.
  /// @param _l1FeeScalar    L1 fee scalar.
  function setL1BlockValues(
    uint64 _number,
    uint64 _timestamp,
    uint256 _basefee,
    bytes32 _hash,
    uint64 _sequenceNumber,
    bytes32 _batcherHash,
    uint256 _l1FeeOverhead,
    uint256 _l1FeeScalar
  ) external {
    require(msg.sender == DEPOSITOR_ACCOUNT(), "L1Block: only the depositor account can set L1 block values");

    number = _number;
    timestamp = _timestamp;
    basefee = _basefee;
    hash = _hash;
    sequenceNumber = _sequenceNumber;
    batcherHash = _batcherHash;
    l1FeeOverhead = _l1FeeOverhead;
    l1FeeScalar = _l1FeeScalar;
  }

  /// @notice Updates the L1 block values for an Ecotone upgraded chain.
  /// Params are packed and passed in as raw msg.data instead of ABI to reduce calldata size.
  /// Params are expected to be in the following order:
  ///   1. _baseFeeScalar      L1 base fee scalar
  ///   2. _blobBaseFeeScalar  L1 blob base fee scalar
  ///   3. _sequenceNumber     Number of L2 blocks since epoch start.
  ///   4. _timestamp          L1 timestamp.
  ///   5. _number             L1 blocknumber.
  ///   6. _basefee            L1 base fee.
  ///   7. _blobBaseFee        L1 blob base fee.
  ///   8. _hash               L1 blockhash.
  ///   9. _batcherHash        Versioned hash to authenticate batcher by.
  function setL1BlockValuesEcotone() external {
    address depositor = DEPOSITOR_ACCOUNT();
    assembly {
      // Revert if the caller is not the depositor account.
      if xor(caller(), depositor) {
        mstore(0x00, 0x3cc50b45) // 0x3cc50b45 is the 4-byte selector of "NotDepositor()"
        revert(0x1C, 0x04) // returns the stored 4-byte selector from above
      }
      // sequencenum (uint64), blobBaseFeeScalar (uint32), baseFeeScalar (uint32)
      sstore(sequenceNumber.slot, shr(128, calldataload(4)))
      // number (uint64) and timestamp (uint64)
      sstore(number.slot, shr(128, calldataload(20)))
      sstore(basefee.slot, calldataload(36)) // uint256
      sstore(blobBaseFee.slot, calldataload(68)) // uint256
      sstore(hash.slot, calldataload(100)) // bytes32
      sstore(batcherHash.slot, calldataload(132)) // bytes32
    }
  }

  /// @notice Sets the gas paying token for the L2 system. Can only be called by the special
  ///         depositor account. This function is not called on every L2 block but instead
  ///         only called by specially crafted L1 deposit transactions.
  function setGasPayingToken(address _token, uint8 _decimals, bytes32 _name, bytes32 _symbol) external {
    if (msg.sender != DEPOSITOR_ACCOUNT()) revert NotDepositor();

    GasPayingToken.set({_token: _token, _decimals: _decimals, _name: _name, _symbol: _symbol});

    emit GasPayingTokenSet({token: _token, decimals: _decimals, name: _name, symbol: _symbol});
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {FixedPointMathLib} from "../../../../../@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

/// @title Arithmetic
/// @notice Even more math than before.
library Arithmetic {
  /// @notice Clamps a value between a minimum and maximum.
  /// @param _value The value to clamp.
  /// @param _min   The minimum value.
  /// @param _max   The maximum value.
  /// @return The clamped value.
  function clamp(int256 _value, int256 _min, int256 _max) internal pure returns (int256) {
    return SignedMath.min(SignedMath.max(_value, _min), _max);
  }

  /// @notice (c)oefficient (d)enominator (exp)onentiation function.
  ///         Returns the result of: c * (1 - 1/d)^exp.
  /// @param _coefficient Coefficient of the function.
  /// @param _denominator Fractional denominator.
  /// @param _exponent    Power function exponent.
  /// @return Result of c * (1 - 1/d)^exp.
  function cdexp(int256 _coefficient, int256 _denominator, int256 _exponent) internal pure returns (int256) {
    return (_coefficient * (FixedPointMathLib.powWad(1e18 - (1e18 / _denominator), _exponent * 1e18))) / 1e18;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Burn
/// @notice Utilities for burning stuff.
library Burn {
  /// @notice Burns a given amount of ETH.
  /// @param _amount Amount of ETH to burn.
  function eth(uint256 _amount) internal {
    new Burner{value: _amount}();
  }

  /// @notice Burns a given amount of gas.
  /// @param _amount Amount of gas to burn.
  function gas(uint256 _amount) internal view {
    uint256 i = 0;
    uint256 initialGas = gasleft();
    while (initialGas - gasleft() < _amount) {
      ++i;
    }
  }
}

/// @title Burner
/// @notice Burner self-destructs on creation and sends all ETH to itself, removing all ETH given to
///         the contract from the circulating supply. Self-destructing is the only way to remove ETH
///         from the circulating supply.
contract Burner {
  constructor() payable {
    // solhint-disable-next-line avoid-low-level-calls
    selfdestruct(payable(address(this)));
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ResourceMetering} from "../L1/ResourceMetering.sol";

/// @title Constants
/// @notice Constants is a library for storing constants. Simple! Don't put everything in here, just
///         the stuff used in multiple contracts. Constants that only apply to a single contract
///         should be defined in that contract instead.
library Constants {
  /// @notice Special address to be used as the tx origin for gas estimation calls in the
  ///         OptimismPortal and CrossDomainMessenger calls. You only need to use this address if
  ///         the minimum gas limit specified by the user is not actually enough to execute the
  ///         given message and you're attempting to estimate the actual necessary gas limit. We
  ///         use address(1) because it's the ecrecover precompile and therefore guaranteed to
  ///         never have any code on any EVM chain.
  address internal constant ESTIMATION_ADDRESS = address(1);

  /// @notice Value used for the L2 sender storage slot in both the OptimismPortal and the
  ///         CrossDomainMessenger contracts before an actual sender is set. This value is
  ///         non-zero to reduce the gas cost of message passing transactions.
  address internal constant DEFAULT_L2_SENDER = 0x000000000000000000000000000000000000dEaD;

  /// @notice The storage slot that holds the address of a proxy implementation.
  /// @dev `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
  bytes32 internal constant PROXY_IMPLEMENTATION_ADDRESS =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /// @notice The storage slot that holds the address of the owner.
  /// @dev `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`
  bytes32 internal constant PROXY_OWNER_ADDRESS = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /// @notice The address that represents ether when dealing with ERC20 token addresses.
  address internal constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /// @notice The address that represents the system caller responsible for L1 attributes
  ///         transactions.
  address internal constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

  /// @notice Returns the default values for the ResourceConfig. These are the recommended values
  ///         for a production network.
  function DEFAULT_RESOURCE_CONFIG() internal pure returns (ResourceMetering.ResourceConfig memory) {
    ResourceMetering.ResourceConfig memory config = ResourceMetering.ResourceConfig({
      maxResourceLimit: 20_000_000,
      elasticityMultiplier: 10,
      baseFeeMaxChangeDenominator: 8,
      minimumBaseFee: 1 gwei,
      systemTxMaxGas: 1_000_000,
      maximumBaseFee: type(uint128).max
    });
    return config;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Storage} from "./Storage.sol";
import {Constants} from "./Constants.sol";
import {LibString} from "../../../../../solady/src/utils/LibString.sol";

/// @title IGasToken
/// @notice Implemented by contracts that are aware of the custom gas token used
///         by the L2 network.
interface IGasToken {
  /// @notice Getter for the ERC20 token address that is used to pay for gas and its decimals.
  function gasPayingToken() external view returns (address, uint8);
  /// @notice Returns the gas token name.
  function gasPayingTokenName() external view returns (string memory);
  /// @notice Returns the gas token symbol.
  function gasPayingTokenSymbol() external view returns (string memory);
  /// @notice Returns true if the network uses a custom gas token.
  function isCustomGasToken() external view returns (bool);
}

/// @title GasPayingToken
/// @notice Handles reading and writing the custom gas token to storage.
///         To be used in any place where gas token information is read or
///         written to state. If multiple contracts use this library, the
///         values in storage should be kept in sync between them.
library GasPayingToken {
  /// @notice The storage slot that contains the address and decimals of the gas paying token
  bytes32 internal constant GAS_PAYING_TOKEN_SLOT = bytes32(uint256(keccak256("opstack.gaspayingtoken")) - 1);

  /// @notice The storage slot that contains the ERC20 `name()` of the gas paying token
  bytes32 internal constant GAS_PAYING_TOKEN_NAME_SLOT = bytes32(uint256(keccak256("opstack.gaspayingtokenname")) - 1);

  /// @notice the storage slot that contains the ERC20 `symbol()` of the gas paying token
  bytes32 internal constant GAS_PAYING_TOKEN_SYMBOL_SLOT =
    bytes32(uint256(keccak256("opstack.gaspayingtokensymbol")) - 1);

  /// @notice Reads the gas paying token and its decimals from the magic
  ///         storage slot. If nothing is set in storage, then the ether
  ///         address is returned instead.
  function getToken() internal view returns (address addr_, uint8 decimals_) {
    bytes32 slot = Storage.getBytes32(GAS_PAYING_TOKEN_SLOT);
    addr_ = address(uint160(uint256(slot) & uint256(type(uint160).max)));
    if (addr_ == address(0)) {
      addr_ = Constants.ETHER;
      decimals_ = 18;
    } else {
      decimals_ = uint8(uint256(slot) >> 160);
    }
  }

  /// @notice Reads the gas paying token's name from the magic storage slot.
  ///         If nothing is set in storage, then the ether name, 'Ether', is returned instead.
  function getName() internal view returns (string memory name_) {
    (address addr, ) = getToken();
    if (addr == Constants.ETHER) {
      name_ = "Ether";
    } else {
      name_ = LibString.fromSmallString(Storage.getBytes32(GAS_PAYING_TOKEN_NAME_SLOT));
    }
  }

  /// @notice Reads the gas paying token's symbol from the magic storage slot.
  ///         If nothing is set in storage, then the ether symbol, 'ETH', is returned instead.
  function getSymbol() internal view returns (string memory symbol_) {
    (address addr, ) = getToken();
    if (addr == Constants.ETHER) {
      symbol_ = "ETH";
    } else {
      symbol_ = LibString.fromSmallString(Storage.getBytes32(GAS_PAYING_TOKEN_SYMBOL_SLOT));
    }
  }

  /// @notice Writes the gas paying token, its decimals, name and symbol to the magic storage slot.
  function set(address _token, uint8 _decimals, bytes32 _name, bytes32 _symbol) internal {
    Storage.setBytes32(GAS_PAYING_TOKEN_SLOT, bytes32((uint256(_decimals) << 160) | uint256(uint160(_token))));
    Storage.setBytes32(GAS_PAYING_TOKEN_NAME_SLOT, _name);
    Storage.setBytes32(GAS_PAYING_TOKEN_SYMBOL_SLOT, _symbol);
  }

  /// @notice Maps a string to a normalized null-terminated small string.
  function sanitize(string memory _str) internal pure returns (bytes32) {
    require(bytes(_str).length <= 32, "GasPayingToken: string cannot be greater than 32 bytes");

    return LibString.toSmallString(_str);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Error returns when a non-depositor account tries to set L1 block values.
error NotDepositor();

/// @notice Error when a chain ID is not in the interop dependency set.
error NotDependency();

/// @notice Error when the interop dependency set size is too large.
error DependencySetSizeTooLarge();

/// @notice Error when a chain ID already in the interop dependency set is attempted to be added.
error AlreadyDependency();

/// @notice Error when the chain's chain ID is attempted to be removed from the interop dependency set.
error CantRemovedDependency();
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Predeploys
/// @notice Contains constant addresses for protocol contracts that are pre-deployed to the L2 system.
//          This excludes the preinstalls (non-protocol contracts).
library Predeploys {
  /// @notice Number of predeploy-namespace addresses reserved for protocol usage.
  uint256 internal constant PREDEPLOY_COUNT = 2048;

  /// @custom:legacy
  /// @notice Address of the LegacyMessagePasser predeploy. Deprecate. Use the updated
  ///         L2ToL1MessagePasser contract instead.
  address internal constant LEGACY_MESSAGE_PASSER = 0x4200000000000000000000000000000000000000;

  /// @custom:legacy
  /// @notice Address of the L1MessageSender predeploy. Deprecated. Use L2CrossDomainMessenger
  ///         or access tx.origin (or msg.sender) in a L1 to L2 transaction instead.
  ///         Not embedded into new OP-Stack chains.
  address internal constant L1_MESSAGE_SENDER = 0x4200000000000000000000000000000000000001;

  /// @custom:legacy
  /// @notice Address of the DeployerWhitelist predeploy. No longer active.
  address internal constant DEPLOYER_WHITELIST = 0x4200000000000000000000000000000000000002;

  /// @notice Address of the canonical WETH contract.
  address internal constant WETH = 0x4200000000000000000000000000000000000006;

  /// @notice Address of the L2CrossDomainMessenger predeploy.
  address internal constant L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000007;

  /// @notice Address of the GasPriceOracle predeploy. Includes fee information
  ///         and helpers for computing the L1 portion of the transaction fee.
  address internal constant GAS_PRICE_ORACLE = 0x420000000000000000000000000000000000000F;

  /// @notice Address of the L2StandardBridge predeploy.
  address internal constant L2_STANDARD_BRIDGE = 0x4200000000000000000000000000000000000010;

  //// @notice Address of the SequencerFeeWallet predeploy.
  address internal constant SEQUENCER_FEE_WALLET = 0x4200000000000000000000000000000000000011;

  /// @notice Address of the OptimismMintableERC20Factory predeploy.
  address internal constant OPTIMISM_MINTABLE_ERC20_FACTORY = 0x4200000000000000000000000000000000000012;

  /// @custom:legacy
  /// @notice Address of the L1BlockNumber predeploy. Deprecated. Use the L1Block predeploy
  ///         instead, which exposes more information about the L1 state.
  address internal constant L1_BLOCK_NUMBER = 0x4200000000000000000000000000000000000013;

  /// @notice Address of the L2ERC721Bridge predeploy.
  address internal constant L2_ERC721_BRIDGE = 0x4200000000000000000000000000000000000014;

  /// @notice Address of the L1Block predeploy.
  address internal constant L1_BLOCK_ATTRIBUTES = 0x4200000000000000000000000000000000000015;

  /// @notice Address of the L2ToL1MessagePasser predeploy.
  address internal constant L2_TO_L1_MESSAGE_PASSER = 0x4200000000000000000000000000000000000016;

  /// @notice Address of the OptimismMintableERC721Factory predeploy.
  address internal constant OPTIMISM_MINTABLE_ERC721_FACTORY = 0x4200000000000000000000000000000000000017;

  /// @notice Address of the ProxyAdmin predeploy.
  address internal constant PROXY_ADMIN = 0x4200000000000000000000000000000000000018;

  /// @notice Address of the BaseFeeVault predeploy.
  address internal constant BASE_FEE_VAULT = 0x4200000000000000000000000000000000000019;

  /// @notice Address of the L1FeeVault predeploy.
  address internal constant L1_FEE_VAULT = 0x420000000000000000000000000000000000001A;

  /// @notice Address of the SchemaRegistry predeploy.
  address internal constant SCHEMA_REGISTRY = 0x4200000000000000000000000000000000000020;

  /// @notice Address of the EAS predeploy.
  address internal constant EAS = 0x4200000000000000000000000000000000000021;

  /// @notice Address of the GovernanceToken predeploy.
  address internal constant GOVERNANCE_TOKEN = 0x4200000000000000000000000000000000000042;

  /// @custom:legacy
  /// @notice Address of the LegacyERC20ETH predeploy. Deprecated. Balances are migrated to the
  ///         state trie as of the Bedrock upgrade. Contract has been locked and write functions
  ///         can no longer be accessed.
  address internal constant LEGACY_ERC20_ETH = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;

  /// @notice Address of the CrossL2Inbox predeploy.
  address internal constant CROSS_L2_INBOX = 0x4200000000000000000000000000000000000022;

  /// @notice Address of the L2ToL2CrossDomainMessenger predeploy.
  address internal constant L2_TO_L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000023;

  /// @notice Returns the name of the predeploy at the given address.
  function getName(address _addr) internal pure returns (string memory out_) {
    require(isPredeployNamespace(_addr), "Predeploys: address must be a predeploy");
    if (_addr == LEGACY_MESSAGE_PASSER) return "LegacyMessagePasser";
    if (_addr == L1_MESSAGE_SENDER) return "L1MessageSender";
    if (_addr == DEPLOYER_WHITELIST) return "DeployerWhitelist";
    if (_addr == WETH) return "WETH";
    if (_addr == L2_CROSS_DOMAIN_MESSENGER) return "L2CrossDomainMessenger";
    if (_addr == GAS_PRICE_ORACLE) return "GasPriceOracle";
    if (_addr == L2_STANDARD_BRIDGE) return "L2StandardBridge";
    if (_addr == SEQUENCER_FEE_WALLET) return "SequencerFeeVault";
    if (_addr == OPTIMISM_MINTABLE_ERC20_FACTORY) return "OptimismMintableERC20Factory";
    if (_addr == L1_BLOCK_NUMBER) return "L1BlockNumber";
    if (_addr == L2_ERC721_BRIDGE) return "L2ERC721Bridge";
    if (_addr == L1_BLOCK_ATTRIBUTES) return "L1Block";
    if (_addr == L2_TO_L1_MESSAGE_PASSER) return "L2ToL1MessagePasser";
    if (_addr == OPTIMISM_MINTABLE_ERC721_FACTORY) return "OptimismMintableERC721Factory";
    if (_addr == PROXY_ADMIN) return "ProxyAdmin";
    if (_addr == BASE_FEE_VAULT) return "BaseFeeVault";
    if (_addr == L1_FEE_VAULT) return "L1FeeVault";
    if (_addr == SCHEMA_REGISTRY) return "SchemaRegistry";
    if (_addr == EAS) return "EAS";
    if (_addr == GOVERNANCE_TOKEN) return "GovernanceToken";
    if (_addr == LEGACY_ERC20_ETH) return "LegacyERC20ETH";
    if (_addr == CROSS_L2_INBOX) return "CrossL2Inbox";
    if (_addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER) return "L2ToL2CrossDomainMessenger";
    revert("Predeploys: unnamed predeploy");
  }

  /// @notice Returns true if the predeploy is not proxied.
  function notProxied(address _addr) internal pure returns (bool) {
    return _addr == GOVERNANCE_TOKEN || _addr == WETH;
  }

  /// @notice Returns true if the address is a defined predeploy that is embedded into new OP-Stack chains.
  function isSupportedPredeploy(address _addr, bool _useInterop) internal pure returns (bool) {
    return
      _addr == LEGACY_MESSAGE_PASSER ||
      _addr == DEPLOYER_WHITELIST ||
      _addr == WETH ||
      _addr == L2_CROSS_DOMAIN_MESSENGER ||
      _addr == GAS_PRICE_ORACLE ||
      _addr == L2_STANDARD_BRIDGE ||
      _addr == SEQUENCER_FEE_WALLET ||
      _addr == OPTIMISM_MINTABLE_ERC20_FACTORY ||
      _addr == L1_BLOCK_NUMBER ||
      _addr == L2_ERC721_BRIDGE ||
      _addr == L1_BLOCK_ATTRIBUTES ||
      _addr == L2_TO_L1_MESSAGE_PASSER ||
      _addr == OPTIMISM_MINTABLE_ERC721_FACTORY ||
      _addr == PROXY_ADMIN ||
      _addr == BASE_FEE_VAULT ||
      _addr == L1_FEE_VAULT ||
      _addr == SCHEMA_REGISTRY ||
      _addr == EAS ||
      _addr == GOVERNANCE_TOKEN ||
      (_useInterop && _addr == CROSS_L2_INBOX) ||
      (_useInterop && _addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER);
  }

  function isPredeployNamespace(address _addr) internal pure returns (bool) {
    return uint160(_addr) >> 11 == uint160(0x4200000000000000000000000000000000000000) >> 11;
  }

  /// @notice Function to compute the expected address of the predeploy implementation
  ///         in the genesis state.
  function predeployToCodeNamespace(address _addr) internal pure returns (address) {
    require(isPredeployNamespace(_addr), "Predeploys: can only derive code-namespace address for predeploy addresses");
    return
      address(
        uint160((uint256(uint160(_addr)) & 0xffff) | uint256(uint160(0xc0D3C0d3C0d3C0D3c0d3C0d3c0D3C0d3c0d30000)))
      );
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Storage
/// @notice Storage handles reading and writing to arbitary storage locations
library Storage {
  /// @notice Returns an address stored in an arbitrary storage slot.
  ///         These storage slots decouple the storage layout from
  ///         solc's automation.
  /// @param _slot The storage slot to retrieve the address from.
  function getAddress(bytes32 _slot) internal view returns (address addr_) {
    assembly {
      addr_ := sload(_slot)
    }
  }

  /// @notice Stores an address in an arbitrary storage slot, `_slot`.
  /// @param _slot The storage slot to store the address in.
  /// @param _address The protocol version to store
  /// @dev WARNING! This function must be used cautiously, as it allows for overwriting addresses
  ///      in arbitrary storage slots.
  function setAddress(bytes32 _slot, address _address) internal {
    assembly {
      sstore(_slot, _address)
    }
  }

  /// @notice Returns a uint256 stored in an arbitrary storage slot.
  ///         These storage slots decouple the storage layout from
  ///         solc's automation.
  /// @param _slot The storage slot to retrieve the address from.
  function getUint(bytes32 _slot) internal view returns (uint256 value_) {
    assembly {
      value_ := sload(_slot)
    }
  }

  /// @notice Stores a value in an arbitrary storage slot, `_slot`.
  /// @param _slot The storage slot to store the address in.
  /// @param _value The protocol version to store
  /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
  ///      in arbitrary storage slots.
  function setUint(bytes32 _slot, uint256 _value) internal {
    assembly {
      sstore(_slot, _value)
    }
  }

  /// @notice Returns a bytes32 stored in an arbitrary storage slot.
  ///         These storage slots decouple the storage layout from
  ///         solc's automation.
  /// @param _slot The storage slot to retrieve the address from.
  function getBytes32(bytes32 _slot) internal view returns (bytes32 value_) {
    assembly {
      value_ := sload(_slot)
    }
  }

  /// @notice Stores a bytes32 value in an arbitrary storage slot, `_slot`.
  /// @param _slot The storage slot to store the address in.
  /// @param _value The bytes32 value to store.
  /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
  ///      in arbitrary storage slots.
  function setBytes32(bytes32 _slot, bytes32 _value) internal {
    assembly {
      sstore(_slot, _value)
    }
  }

  /// @notice Stores a bool value in an arbitrary storage slot, `_slot`.
  /// @param _slot The storage slot to store the bool in.
  /// @param _value The bool value to store
  /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
  ///      in arbitrary storage slots.
  function setBool(bytes32 _slot, bool _value) internal {
    assembly {
      sstore(_slot, _value)
    }
  }

  /// @notice Returns a bool stored in an arbitrary storage slot.
  /// @param _slot The storage slot to retrieve the bool from.
  function getBool(bytes32 _slot) internal view returns (bool value_) {
    assembly {
      value_ := sload(_slot)
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ISemver
/// @notice ISemver is a simple contract for ensuring that contracts are
///         versioned using semantic versioning.
interface ISemver {
  /// @notice Getter for the semantic version of the contract. This is not
  ///         meant to be used onchain but instead meant to be used by offchain
  ///         tooling.
  /// @return Semver contract version as a string.
  function version() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Equivalent to x to the power of y because x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)
        return expWad((lnWad(x) * y) / int256(WAD)); // Using ln(x) means x must be greater than 0.
    }

    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is < 0.5 we return zero. This happens when
            // x <= floor(log(0.5e18) * 1e18) ~ -42e18
            if (x <= -42139678854452767551) return 0;

            // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
            // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
            if (x >= 135305999368893231589) revert("EXP_OVERFLOW");

            // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5**18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2**95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // k is in the range [-61, 195].

            // Evaluate using a (6, 7)-term rational approximation.
            // p is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r should be in the range (0.09, 0.25) * 2**96.

            // We now need to multiply r by:
            // * the scale factor s = ~6.031367120.
            // * the 2**k factor from the range reduction.
            // * the 1e18 / 2**96 factor for base conversion.
            // We do this all at once, with an intermediate result in 2**213
            // basis, so the final right shift is always by a positive amount.
            r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
        }
    }

    function lnWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            require(x > 0, "UNDEFINED");

            // We want to convert x from 10**18 fixed point to 2**96 fixed point.
            // We do this by multiplying by 2**96 / 10**18. But since
            // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
            // and add ln(2**96 / 10**18) at the end.

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            int256 k = int256(log2(uint256(x))) - 96;
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);

            // Evaluate using a (8, 8)-term rational approximation.
            // p is made monic, we will multiply by a scale factor later.
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            // q is monic by convention.
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial is known not to have zeros in the domain.
                // No scaling required because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r is in the range (0, 0.125) * 2**96

            // Finalization, we need to:
            // * multiply by the scale factor s = 5.549…
            // * add ln(2**96 / 10**18)
            // * add k * ln(2)
            // * multiply by 10**18 / 2**96 = 5**18 >> 78

            // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
            r *= 1677202110996718588342820967067443963516166;
            // add ln(2) * k * 5e18 * 2**192
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            // add ln(2**96 / 10**18) * 5e18 * 2**192
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            // base conversion: mul 2**18 / 2**192
            r >>= 174;
        }
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // First, divide z - 1 by the denominator and add 1.
            // We allow z - 1 to underflow if z is 0, because we multiply the
            // end result by 0 if z is zero, ensuring we return 0 if z is zero.
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function log2(uint256 x) internal pure returns (uint256 r) {
        require(x > 0, "UNDEFINED");

        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, shl(1, lt(0x3, shr(r, x))))
            r := or(r, lt(0x1, shr(r, x)))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
  /**
   * @dev Emitted when the pause is triggered by `account`.
   */
  event Paused(address account);

  /**
   * @dev Emitted when the pause is lifted by `account`.
   */
  event Unpaused(address account);

  bool private _paused;

  /**
   * @dev Initializes the contract in unpaused state.
   */
  constructor() {
    _paused = false;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  modifier whenNotPaused() {
    _requireNotPaused();
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  modifier whenPaused() {
    _requirePaused();
    _;
  }

  /**
   * @dev Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view virtual returns (bool) {
    return _paused;
  }

  /**
   * @dev Throws if the contract is paused.
   */
  function _requireNotPaused() internal view virtual {
    require(!paused(), "Pausable: paused");
  }

  /**
   * @dev Throws if the contract is not paused.
   */
  function _requirePaused() internal view virtual {
    require(paused(), "Pausable: not paused");
  }

  /**
   * @dev Triggers stopped state.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Returns to normal state.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
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
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

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

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

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
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

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
  function toInt248(int256 value) internal pure returns (int248 downcasted) {
    downcasted = int248(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
  function toInt240(int256 value) internal pure returns (int240 downcasted) {
    downcasted = int240(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
  function toInt232(int256 value) internal pure returns (int232 downcasted) {
    downcasted = int232(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
  function toInt224(int256 value) internal pure returns (int224 downcasted) {
    downcasted = int224(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
  function toInt216(int256 value) internal pure returns (int216 downcasted) {
    downcasted = int216(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
  function toInt208(int256 value) internal pure returns (int208 downcasted) {
    downcasted = int208(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
  function toInt200(int256 value) internal pure returns (int200 downcasted) {
    downcasted = int200(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
  function toInt192(int256 value) internal pure returns (int192 downcasted) {
    downcasted = int192(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
  function toInt184(int256 value) internal pure returns (int184 downcasted) {
    downcasted = int184(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
  function toInt176(int256 value) internal pure returns (int176 downcasted) {
    downcasted = int176(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
  function toInt168(int256 value) internal pure returns (int168 downcasted) {
    downcasted = int168(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
  function toInt160(int256 value) internal pure returns (int160 downcasted) {
    downcasted = int160(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
  function toInt152(int256 value) internal pure returns (int152 downcasted) {
    downcasted = int152(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
  function toInt144(int256 value) internal pure returns (int144 downcasted) {
    downcasted = int144(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
  function toInt136(int256 value) internal pure returns (int136 downcasted) {
    downcasted = int136(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
  function toInt128(int256 value) internal pure returns (int128 downcasted) {
    downcasted = int128(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
  function toInt120(int256 value) internal pure returns (int120 downcasted) {
    downcasted = int120(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
  function toInt112(int256 value) internal pure returns (int112 downcasted) {
    downcasted = int112(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
  function toInt104(int256 value) internal pure returns (int104 downcasted) {
    downcasted = int104(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
  function toInt96(int256 value) internal pure returns (int96 downcasted) {
    downcasted = int96(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
  function toInt88(int256 value) internal pure returns (int88 downcasted) {
    downcasted = int88(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
  function toInt80(int256 value) internal pure returns (int80 downcasted) {
    downcasted = int80(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
  function toInt72(int256 value) internal pure returns (int72 downcasted) {
    downcasted = int72(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
  function toInt64(int256 value) internal pure returns (int64 downcasted) {
    downcasted = int64(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
  function toInt56(int256 value) internal pure returns (int56 downcasted) {
    downcasted = int56(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
  function toInt48(int256 value) internal pure returns (int48 downcasted) {
    downcasted = int48(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
  function toInt40(int256 value) internal pure returns (int40 downcasted) {
    downcasted = int40(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
  function toInt32(int256 value) internal pure returns (int32 downcasted) {
    downcasted = int32(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
  function toInt24(int256 value) internal pure returns (int24 downcasted) {
    downcasted = int24(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
  function toInt16(int256 value) internal pure returns (int16 downcasted) {
    downcasted = int16(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
  function toInt8(int256 value) internal pure returns (int8 downcasted) {
    downcasted = int8(value);
    require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
  // To implement this library for multiple types with as little code
  // repetition as possible, we write it in terms of a generic Set type with
  // bytes32 values.
  // The Set implementation uses private functions, and user-facing
  // implementations (such as AddressSet) are just wrappers around the
  // underlying Set.
  // This means that we can only create new EnumerableSets for types that fit
  // in bytes32.

  struct Set {
    // Storage of set values
    bytes32[] _values;
    // Position of the value in the `values` array, plus 1 because index 0
    // means a value is not in the set.
    mapping(bytes32 => uint256) _indexes;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      // The value is stored at length-1, but we add 1 to all indexes
      // and use 0 as a sentinel value
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    // We read and store the value's index to prevent multiple reads from the same storage slot
    uint256 valueIndex = set._indexes[value];

    if (valueIndex != 0) {
      // Equivalent to contains(set, value)
      // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
      // the array, and then remove the last element (sometimes called as 'swap and pop').
      // This modifies the order of the array, as noted in {at}.

      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;

      if (lastIndex != toDeleteIndex) {
        bytes32 lastValue = set._values[lastIndex];

        // Move the last value to the index where the value to delete is
        set._values[toDeleteIndex] = lastValue;
        // Update the index for the moved value
        set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
      }

      // Delete the slot where the moved value was stored
      set._values.pop();

      // Delete the index for the deleted slot
      delete set._indexes[value];

      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }

  /**
   * @dev Returns the number of values on the set. O(1).
   */
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
  }

  // Bytes32Set

  struct Bytes32Set {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _remove(set._inner, value);
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
    return _contains(set._inner, value);
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
    return _at(set._inner, index);
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
    bytes32[] memory store = _values(set._inner);
    bytes32[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }

  // AddressSet

  struct AddressSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint160(uint256(_at(set._inner, index))));
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(AddressSet storage set) internal view returns (address[] memory) {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }

  // UintSet

  struct UintSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(UintSet storage set) internal view returns (uint256[] memory) {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// Note:
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
      for {
        let temp := value
      } 1 {

      } {
        str := add(str, w) // `sub(str, 1)`.
        // Write the character to the pointer.
        // The ASCII index of the '0' character is 48.
        mstore8(str, add(48, mod(temp, 10)))
        // Keep dividing `temp` until zero.
        temp := div(temp, 10)
        if iszero(temp) {
          break
        }
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
  function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory str) {
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
      for {

      } 1 {

      } {
        str := add(str, w) // `sub(str, 2)`.
        mstore8(add(str, 1), mload(and(temp, 15)))
        mstore8(str, mload(and(shr(4, temp), 15)))
        temp := shr(8, temp)
        if iszero(xor(str, start)) {
          break
        }
      }

      if temp {
        mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
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
  /// The output is prefixed with "0x".
  /// The output excludes leading "0" from the `toHexString` output.
  /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
  function toMinimalHexString(uint256 value) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(value);
    /// @solidity memory-safe-assembly
    assembly {
      let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.
      let strLength := add(mload(str), 2) // Compute the length.
      mstore(add(str, o), 0x3078) // Write the "0x" prefix, accounting for leading zero.
      str := sub(add(str, o), 2) // Move the pointer, accounting for leading zero.
      mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.
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
      mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.
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
      for {
        let temp := value
      } 1 {

      } {
        str := add(str, w) // `sub(str, 2)`.
        mstore8(add(str, 1), mload(and(temp, 15)))
        mstore8(str, mload(and(shr(4, temp), 15)))
        temp := shr(8, temp)
        if iszero(temp) {
          break
        }
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
  function toHexStringChecksummed(address value) internal pure returns (string memory str) {
    str = toHexString(value);
    /// @solidity memory-safe-assembly
    assembly {
      let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
      let o := add(str, 0x22)
      let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
      let t := shl(240, 136) // `0b10001000 << 240`
      for {
        let i := 0
      } 1 {

      } {
        mstore(add(i, i), mul(t, byte(i, hashed)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
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
      for {
        let i := 0
      } 1 {

      } {
        let p := add(o, add(i, i))
        let temp := byte(i, value)
        mstore8(add(p, 1), mload(and(temp, 15)))
        mstore8(p, mload(shr(4, temp)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
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

      for {

      } iszero(eq(raw, end)) {

      } {
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
        for {
          result := 1
        } 1 {
          result := add(result, 1)
        } {
          o := add(o, byte(0, mload(shr(250, mload(o)))))
          if iszero(lt(o, end)) {
            break
          }
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
        for {

        } 1 {

        } {
          if and(mask, mload(o)) {
            result := 0
            break
          }
          o := add(o, 0x20)
          if iszero(lt(o, end)) {
            break
          }
        }
        mstore(end, last)
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
  function replace(
    string memory subject,
    string memory search,
    string memory replacement
  ) internal pure returns (string memory result) {
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
        if iszero(lt(searchLength, 0x20)) {
          h := keccak256(search, searchLength)
        }
        let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
        let s := mload(search)
        for {

        } 1 {

        } {
          let t := mload(subject)
          // Whether the first `searchLength % 32` bytes of
          // `subject` and `search` matches.
          if iszero(shr(m, xor(t, s))) {
            if h {
              if iszero(eq(keccak256(subject, searchLength), h)) {
                mstore(result, t)
                result := add(result, 1)
                subject := add(subject, 1)
                if iszero(lt(subject, subjectSearchEnd)) {
                  break
                }
                continue
              }
            }
            // Copy the `replacement` one word at a time.
            for {
              let o := 0
            } 1 {

            } {
              mstore(add(result, o), mload(add(replacement, o)))
              o := add(o, 0x20)
              if iszero(lt(o, replacementLength)) {
                break
              }
            }
            result := add(result, replacementLength)
            subject := add(subject, searchLength)
            if searchLength {
              if iszero(lt(subject, subjectSearchEnd)) {
                break
              }
              continue
            }
          }
          mstore(result, t)
          result := add(result, 1)
          subject := add(subject, 1)
          if iszero(lt(subject, subjectSearchEnd)) {
            break
          }
        }
      }

      let resultRemainder := result
      result := add(mload(0x40), 0x20)
      let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))
      // Copy the rest of the string one word at a time.
      for {

      } lt(subject, subjectEnd) {

      } {
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
  function indexOf(string memory subject, string memory search, uint256 from) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {
        let subjectLength := mload(subject)
      } 1 {

      } {
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

        if iszero(and(lt(subject, end), lt(from, subjectLength))) {
          break
        }

        if iszero(lt(searchLength, 0x20)) {
          for {
            let h := keccak256(add(search, 0x20), searchLength)
          } 1 {

          } {
            if iszero(shr(m, xor(mload(subject), s))) {
              if eq(keccak256(subject, searchLength), h) {
                result := sub(subject, subjectStart)
                break
              }
            }
            subject := add(subject, 1)
            if iszero(lt(subject, end)) {
              break
            }
          }
          break
        }
        for {

        } 1 {

        } {
          if iszero(shr(m, xor(mload(subject), s))) {
            result := sub(subject, subjectStart)
            break
          }
          subject := add(subject, 1)
          if iszero(lt(subject, end)) {
            break
          }
        }
        break
      }
    }
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from left to right.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function indexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
    result = indexOf(subject, search, 0);
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from right to left, starting from `from`.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function lastIndexOf(
    string memory subject,
    string memory search,
    uint256 from
  ) internal pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {

      } 1 {

      } {
        result := not(0) // Initialize to `NOT_FOUND`.
        let searchLength := mload(search)
        if gt(searchLength, mload(subject)) {
          break
        }
        let w := result

        let fromMax := sub(mload(subject), searchLength)
        if iszero(gt(fromMax, from)) {
          from := fromMax
        }

        let end := add(add(subject, 0x20), w)
        subject := add(add(subject, 0x20), from)
        if iszero(gt(subject, end)) {
          break
        }
        // As this function is not too often used,
        // we shall simply use keccak256 for smaller bytecode size.
        for {
          let h := keccak256(add(search, 0x20), searchLength)
        } 1 {

        } {
          if eq(keccak256(subject, searchLength), h) {
            result := sub(subject, add(end, 1))
            break
          }
          subject := add(subject, w) // `sub(subject, 1)`.
          if iszero(gt(subject, end)) {
            break
          }
        }
        break
      }
    }
  }

  /// @dev Returns the byte index of the first location of `search` in `subject`,
  /// searching from right to left.
  /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.
  function lastIndexOf(string memory subject, string memory search) internal pure returns (uint256 result) {
    result = lastIndexOf(subject, search, uint256(int256(-1)));
  }

  /// @dev Returns true if `search` is found in `subject`, false otherwise.
  function contains(string memory subject, string memory search) internal pure returns (bool) {
    return indexOf(subject, search) != NOT_FOUND;
  }

  /// @dev Returns whether `subject` starts with `search`.
  function startsWith(string memory subject, string memory search) internal pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
      let searchLength := mload(search)
      // Just using keccak256 directly is actually cheaper.
      // forgefmt: disable-next-item
      result := and(
        iszero(gt(searchLength, mload(subject))),
        eq(keccak256(add(subject, 0x20), searchLength), keccak256(add(search, 0x20), searchLength))
      )
    }
  }

  /// @dev Returns whether `subject` ends with `search`.
  function endsWith(string memory subject, string memory search) internal pure returns (bool result) {
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
  function repeat(string memory subject, uint256 times) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      if iszero(or(iszero(times), iszero(subjectLength))) {
        subject := add(subject, 0x20)
        result := mload(0x40)
        let output := add(result, 0x20)
        for {

        } 1 {

        } {
          // Copy the `subject` one word at a time.
          for {
            let o := 0
          } 1 {

          } {
            mstore(add(output, o), mload(add(subject, o)))
            o := add(o, 0x20)
            if iszero(lt(o, subjectLength)) {
              break
            }
          }
          output := add(output, subjectLength)
          times := sub(times, 1)
          if iszero(times) {
            break
          }
        }
        mstore(output, 0) // Zeroize the slot after the string.
        let resultLength := sub(output, add(result, 0x20))
        mstore(result, resultLength) // Store the length.
        // Allocate the memory.
        mstore(0x40, add(result, add(resultLength, 0x20)))
      }
    }
  }

  /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
  /// `start` and `end` are byte offsets.
  function slice(string memory subject, uint256 start, uint256 end) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let subjectLength := mload(subject)
      if iszero(gt(subjectLength, end)) {
        end := subjectLength
      }
      if iszero(gt(subjectLength, start)) {
        start := subjectLength
      }
      if lt(start, end) {
        result := mload(0x40)
        let resultLength := sub(end, start)
        mstore(result, resultLength)
        subject := add(subject, start)
        let w := not(0x1f)
        // Copy the `subject` one word at a time, backwards.
        for {
          let o := and(add(resultLength, 0x1f), w)
        } 1 {

        } {
          mstore(add(result, o), mload(add(subject, o)))
          o := add(o, w) // `sub(o, 0x20)`.
          if iszero(o) {
            break
          }
        }
        // Zeroize the slot after the string.
        mstore(add(add(result, 0x20), resultLength), 0)
        // Allocate memory for the length and the bytes,
        // rounded up to a multiple of 32.
        mstore(0x40, add(result, and(add(resultLength, 0x3f), w)))
      }
    }
  }

  /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
  /// `start` is a byte offset.
  function slice(string memory subject, uint256 start) internal pure returns (string memory result) {
    result = slice(subject, start, uint256(int256(-1)));
  }

  /// @dev Returns all the indices of `search` in `subject`.
  /// The indices are byte offsets.
  function indicesOf(string memory subject, string memory search) internal pure returns (uint256[] memory result) {
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
        if iszero(lt(searchLength, 0x20)) {
          h := keccak256(search, searchLength)
        }
        let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
        let s := mload(search)
        for {

        } 1 {

        } {
          let t := mload(subject)
          // Whether the first `searchLength % 32` bytes of
          // `subject` and `search` matches.
          if iszero(shr(m, xor(t, s))) {
            if h {
              if iszero(eq(keccak256(subject, searchLength), h)) {
                subject := add(subject, 1)
                if iszero(lt(subject, subjectSearchEnd)) {
                  break
                }
                continue
              }
            }
            // Append to `result`.
            mstore(result, sub(subject, subjectStart))
            result := add(result, 0x20)
            // Advance `subject` by `searchLength`.
            subject := add(subject, searchLength)
            if searchLength {
              if iszero(lt(subject, subjectSearchEnd)) {
                break
              }
              continue
            }
          }
          subject := add(subject, 1)
          if iszero(lt(subject, subjectSearchEnd)) {
            break
          }
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
  function split(string memory subject, string memory delimiter) internal pure returns (string[] memory result) {
    uint256[] memory indices = indicesOf(subject, delimiter);
    /// @solidity memory-safe-assembly
    assembly {
      let w := not(0x1f)
      let indexPtr := add(indices, 0x20)
      let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
      mstore(add(indicesEnd, w), mload(subject))
      mstore(indices, add(mload(indices), 1))
      let prevIndex := 0
      for {

      } 1 {

      } {
        let index := mload(indexPtr)
        mstore(indexPtr, 0x60)
        if iszero(eq(index, prevIndex)) {
          let element := mload(0x40)
          let elementLength := sub(index, prevIndex)
          mstore(element, elementLength)
          // Copy the `subject` one word at a time, backwards.
          for {
            let o := and(add(elementLength, 0x1f), w)
          } 1 {

          } {
            mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
            o := add(o, w) // `sub(o, 0x20)`.
            if iszero(o) {
              break
            }
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
        if iszero(lt(indexPtr, indicesEnd)) {
          break
        }
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
  function concat(string memory a, string memory b) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let w := not(0x1f)
      result := mload(0x40)
      let aLength := mload(a)
      // Copy `a` one word at a time, backwards.
      for {
        let o := and(add(aLength, 0x20), w)
      } 1 {

      } {
        mstore(add(result, o), mload(add(a, o)))
        o := add(o, w) // `sub(o, 0x20)`.
        if iszero(o) {
          break
        }
      }
      let bLength := mload(b)
      let output := add(result, aLength)
      // Copy `b` one word at a time, backwards.
      for {
        let o := and(add(bLength, 0x20), w)
      } 1 {

      } {
        mstore(add(output, o), mload(add(b, o)))
        o := add(o, w) // `sub(o, 0x20)`.
        if iszero(o) {
          break
        }
      }
      let totalLength := add(aLength, bLength)
      let last := add(add(result, 0x20), totalLength)
      // Zeroize the slot after the string.
      mstore(last, 0)
      // Stores the length.
      mstore(result, totalLength)
      // Allocate memory for the length and the bytes,
      // rounded up to a multiple of 32.
      mstore(0x40, and(add(last, 0x1f), w))
    }
  }

  /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
  /// WARNING! This function is only compatible with 7-bit ASCII strings.
  function toCase(string memory subject, bool toUpper) internal pure returns (string memory result) {
    /// @solidity memory-safe-assembly
    assembly {
      let length := mload(subject)
      if length {
        result := add(mload(0x40), 0x20)
        subject := add(subject, 1)
        let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
        let w := not(0)
        for {
          let o := length
        } 1 {

        } {
          o := add(o, w)
          let b := and(0xff, mload(add(subject, o)))
          mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
          if iszero(o) {
            break
          }
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
      for {

      } byte(n, s) {
        n := add(n, 1)
      } {

      } // Scan for '\0'.
      mstore(result, n)
      let o := add(result, 0x20)
      mstore(o, s)
      mstore(add(o, n), 0)
      mstore(0x40, add(result, 0x40))
    }
  }

  /// @dev Returns the small string, with all bytes after the first null byte zeroized.
  function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
    /// @solidity memory-safe-assembly
    assembly {
      for {

      } byte(result, s) {
        result := add(result, 1)
      } {

      } // Scan for '\0'.
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
      for {

      } iszero(eq(s, end)) {

      } {
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
  function escapeJSON(string memory s, bool addDoubleQuotes) internal pure returns (string memory result) {
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
      for {

      } iszero(eq(s, end)) {

      } {
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
      result := gt(
        eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
        xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20))))
      )
    }
  }

  /// @dev Packs a single string with its length into a single word.
  /// Returns `bytes32(0)` if the length is zero or greater than 31.
  function packOne(string memory a) internal pure returns (bytes32 result) {
    /// @solidity memory-safe-assembly
    assembly {
      // We don't need to zero right pad the string,
      // since this is our own custom non-standard packing scheme.
      result := mul(
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
      result := mul(
        // Load the length and the bytes of `a` and `b`.
        or(shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))), mload(sub(add(b, 0x1e), aLength))),
        // `totalLength != 0 && totalLength < 31`. Abuses underflow.
        // Assumes that the lengths are valid and within the block gas limit.
        lt(sub(add(aLength, mload(b)), 1), 0x1e)
      )
    }
  }

  /// @dev Unpacks strings packed using {packTwo}.
  /// Returns the empty strings if `packed` is `bytes32(0)`.
  /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
  function unpackTwo(bytes32 packed) internal pure returns (string memory resultA, string memory resultB) {
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for compressing and decompressing bytes.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibZip.sol)
/// @author Calldata compression by clabby (https://github.com/clabby/op-kompressor)
/// @author FastLZ by ariya (https://github.com/ariya/FastLZ)
///
/// @dev Note:
/// The accompanying solady.js library includes implementations of
/// FastLZ and calldata operations for convenience.
library LibZip {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     FAST LZ OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // LZ77 implementation based on FastLZ.
    // Equivalent to level 1 compression and decompression at the following commit:
    // https://github.com/ariya/FastLZ/commit/344eb4025f9ae866ebf7a2ec48850f7113a97a42
    // Decompression is backwards compatible.

    /// @dev Returns the compressed `data`.
    function flzCompress(bytes memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            function ms8(d_, v_) -> _d {
                mstore8(d_, v_)
                _d := add(d_, 1)
            }
            function u24(p_) -> _u {
                let w := mload(p_)
                _u := or(shl(16, byte(2, w)), or(shl(8, byte(1, w)), byte(0, w)))
            }
            function cmp(p_, q_, e_) -> _l {
                for { e_ := sub(e_, q_) } lt(_l, e_) { _l := add(_l, 1) } {
                    e_ := mul(iszero(byte(0, xor(mload(add(p_, _l)), mload(add(q_, _l))))), e_)
                }
            }
            function literals(runs_, src_, dest_) -> _o {
                for { _o := dest_ } iszero(lt(runs_, 0x20)) { runs_ := sub(runs_, 0x20) } {
                    mstore(ms8(_o, 31), mload(src_))
                    _o := add(_o, 0x21)
                    src_ := add(src_, 0x20)
                }
                if iszero(runs_) { leave }
                mstore(ms8(_o, sub(runs_, 1)), mload(src_))
                _o := add(1, add(_o, runs_))
            }
            function match(l_, d_, o_) -> _o {
                for { d_ := sub(d_, 1) } iszero(lt(l_, 263)) { l_ := sub(l_, 262) } {
                    o_ := ms8(ms8(ms8(o_, add(224, shr(8, d_))), 253), and(0xff, d_))
                }
                if iszero(lt(l_, 7)) {
                    _o := ms8(ms8(ms8(o_, add(224, shr(8, d_))), sub(l_, 7)), and(0xff, d_))
                    leave
                }
                _o := ms8(ms8(o_, add(shl(5, l_), shr(8, d_))), and(0xff, d_))
            }
            function setHash(i_, v_) {
                let p := add(mload(0x40), shl(2, i_))
                mstore(p, xor(mload(p), shl(224, xor(shr(224, mload(p)), v_))))
            }
            function getHash(i_) -> _h {
                _h := shr(224, mload(add(mload(0x40), shl(2, i_))))
            }
            function hash(v_) -> _r {
                _r := and(shr(19, mul(2654435769, v_)), 0x1fff)
            }
            function setNextHash(ip_, ipStart_) -> _ip {
                setHash(hash(u24(ip_)), sub(ip_, ipStart_))
                _ip := add(ip_, 1)
            }
            codecopy(mload(0x40), codesize(), 0x8000) // Zeroize the hashmap.
            let op := add(mload(0x40), 0x8000)
            let a := add(data, 0x20)
            let ipStart := a
            let ipLimit := sub(add(ipStart, mload(data)), 13)
            for { let ip := add(2, a) } lt(ip, ipLimit) {} {
                let r := 0
                let d := 0
                for {} 1 {} {
                    let s := u24(ip)
                    let h := hash(s)
                    r := add(ipStart, getHash(h))
                    setHash(h, sub(ip, ipStart))
                    d := sub(ip, r)
                    if iszero(lt(ip, ipLimit)) { break }
                    ip := add(ip, 1)
                    if iszero(gt(d, 0x1fff)) { if eq(s, u24(r)) { break } }
                }
                if iszero(lt(ip, ipLimit)) { break }
                ip := sub(ip, 1)
                if gt(ip, a) { op := literals(sub(ip, a), a, op) }
                let l := cmp(add(r, 3), add(ip, 3), add(ipLimit, 9))
                op := match(l, d, op)
                ip := setNextHash(setNextHash(add(ip, l), ipStart), ipStart)
                a := ip
            }
            op := literals(sub(add(ipStart, mload(data)), a), a, op)
            result := mload(0x40)
            let t := add(result, 0x8000)
            let n := sub(op, t)
            mstore(result, n) // Store the length.
            // Copy the result to compact the memory, overwriting the hashmap.
            let o := add(result, 0x20)
            for { let i } lt(i, n) { i := add(i, 0x20) } { mstore(add(o, i), mload(add(t, i))) }
            mstore(add(o, n), 0) // Zeroize the slot after the string.
            mstore(0x40, add(add(o, n), 0x20)) // Allocate the memory.
        }
    }

    /// @dev Returns the decompressed `data`.
    function flzDecompress(bytes memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let end := add(add(data, 0x20), mload(data))
            result := mload(0x40)
            let op := add(result, 0x20)
            for { data := add(data, 0x20) } lt(data, end) {} {
                let w := mload(data)
                let c := byte(0, w)
                let t := shr(5, c)
                if iszero(t) {
                    mstore(op, mload(add(data, 1)))
                    data := add(data, add(2, c))
                    op := add(op, add(1, c))
                    continue
                }
                let g := eq(t, 7)
                let l := add(2, xor(t, mul(g, xor(t, add(7, byte(1, w)))))) // M
                for {
                    let s := add(add(shl(8, and(0x1f, c)), byte(add(1, g), w)), 1) // R
                    let r := sub(op, s)
                    let f := xor(s, mul(gt(s, 0x20), xor(s, 0x20)))
                    let j := 0
                } 1 {} {
                    mstore(add(op, j), mload(add(r, j)))
                    j := add(j, f)
                    if iszero(lt(j, l)) { break }
                }
                data := add(data, add(2, g))
                op := add(op, l)
            }
            mstore(result, sub(op, add(result, 0x20))) // Store the length.
            mstore(op, 0) // Zeroize the slot after the string.
            mstore(0x40, add(op, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    CALLDATA OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Calldata compression and decompression using selective run length encoding:
    // - Sequences of 0x00 (up to 128 consecutive).
    // - Sequences of 0xff (up to 32 consecutive).
    //
    // A run length encoded block consists of two bytes:
    // (0) 0x00
    // (1) A control byte with the following bit layout:
    //     - [7]     `0: 0x00, 1: 0xff`.
    //     - [0..6]  `runLength - 1`.
    //
    // The first 4 bytes are bitwise negated so that the compressed calldata
    // can be dispatched into the `fallback` and `receive` functions.

    /// @dev Returns the compressed `data`.
    function cdCompress(bytes memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            function rle(v_, o_, d_) -> _o, _d {
                mstore(o_, shl(240, or(and(0xff, add(d_, 0xff)), and(0x80, v_))))
                _o := add(o_, 2)
            }
            result := mload(0x40)
            let o := add(result, 0x20)
            let z := 0 // Number of consecutive 0x00.
            let y := 0 // Number of consecutive 0xff.
            for { let end := add(data, mload(data)) } iszero(eq(data, end)) {} {
                data := add(data, 1)
                let c := byte(31, mload(data))
                if iszero(c) {
                    if y { o, y := rle(0xff, o, y) }
                    z := add(z, 1)
                    if eq(z, 0x80) { o, z := rle(0x00, o, 0x80) }
                    continue
                }
                if eq(c, 0xff) {
                    if z { o, z := rle(0x00, o, z) }
                    y := add(y, 1)
                    if eq(y, 0x20) { o, y := rle(0xff, o, 0x20) }
                    continue
                }
                if y { o, y := rle(0xff, o, y) }
                if z { o, z := rle(0x00, o, z) }
                mstore8(o, c)
                o := add(o, 1)
            }
            if y { o, y := rle(0xff, o, y) }
            if z { o, z := rle(0x00, o, z) }
            // Bitwise negate the first 4 bytes.
            mstore(add(result, 4), not(mload(add(result, 4))))
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Returns the decompressed `data`.
    function cdDecompress(bytes memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(data) {
                result := mload(0x40)
                let o := add(result, 0x20)
                let s := add(data, 4)
                let v := mload(s)
                let end := add(data, mload(data))
                mstore(s, not(v)) // Bitwise negate the first 4 bytes.
                for {} lt(data, end) {} {
                    data := add(data, 1)
                    let c := byte(31, mload(data))
                    if iszero(c) {
                        data := add(data, 1)
                        let d := byte(31, mload(data))
                        // Fill with either 0xff or 0x00.
                        mstore(o, not(0))
                        if iszero(gt(d, 0x7f)) { codecopy(o, codesize(), add(d, 1)) }
                        o := add(o, add(and(d, 0x7f), 1))
                        continue
                    }
                    mstore8(o, c)
                    o := add(o, 1)
                }
                mstore(s, v) // Restore the first 4 bytes.
                mstore(result, sub(o, add(result, 0x20))) // Store the length.
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate the memory.
            }
        }
    }

    /// @dev To be called in the `fallback` function.
    /// ```
    ///     fallback() external payable { LibZip.cdFallback(); }
    ///     receive() external payable {} // Silence compiler warning to add a `receive` function.
    /// ```
    /// For efficiency, this function will directly return the results, terminating the context.
    /// If called internally, it must be called at the end of the function.
    function cdFallback() internal {
        assembly {
            if iszero(calldatasize()) { return(calldatasize(), calldatasize()) }
            let o := 0
            let f := not(3) // For negating the first 4 bytes.
            for { let i := 0 } lt(i, calldatasize()) {} {
                let c := byte(0, xor(add(i, f), calldataload(i)))
                i := add(i, 1)
                if iszero(c) {
                    let d := byte(0, xor(add(i, f), calldataload(i)))
                    i := add(i, 1)
                    // Fill with either 0xff or 0x00.
                    mstore(o, not(0))
                    if iszero(gt(d, 0x7f)) { codecopy(o, codesize(), add(d, 1)) }
                    o := add(o, add(and(d, 0x7f), 1))
                    continue
                }
                mstore8(o, c)
                o := add(o, 1)
            }
            let success := delegatecall(gas(), address(), 0x00, o, codesize(), 0x00)
            returndatacopy(0x00, 0x00, returndatasize())
            if iszero(success) { revert(0x00, returndatasize()) }
            return(0x00, returndatasize())
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../@ensdomains/buffer/v0.1.0/Buffer.sol";

/**
* @dev A library for populating CBOR encoded payload in Solidity.
*
* https://datatracker.ietf.org/doc/html/rfc7049
*
* The library offers various write* and start* methods to encode values of different types.
* The resulted buffer can be obtained with data() method.
* Encoding of primitive types is staightforward, whereas encoding of sequences can result
* in an invalid CBOR if start/write/end flow is violated.
* For the purpose of gas saving, the library does not verify start/write/end flow internally,
* except for nested start/end pairs.
*/

library CBOR {
    using Buffer for Buffer.buffer;

    struct CBORBuffer {
        Buffer.buffer buf;
        uint256 depth;
    }

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    uint8 private constant CBOR_FALSE = 20;
    uint8 private constant CBOR_TRUE = 21;
    uint8 private constant CBOR_NULL = 22;
    uint8 private constant CBOR_UNDEFINED = 23;

    function create(uint256 capacity) internal pure returns(CBORBuffer memory cbor) {
        Buffer.init(cbor.buf, capacity);
        cbor.depth = 0;
        return cbor;
    }

    function data(CBORBuffer memory buf) internal pure returns(bytes memory) {
        require(buf.depth == 0, "Invalid CBOR");
        return buf.buf.buf;
    }

    function writeUInt256(CBORBuffer memory buf, uint256 value) internal pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
        writeBytes(buf, abi.encode(value));
    }

    function writeInt256(CBORBuffer memory buf, int256 value) internal pure {
        if (value < 0) {
            buf.buf.appendUint8(
                uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM)
            );
            writeBytes(buf, abi.encode(uint256(-1 - value)));
        } else {
            writeUInt256(buf, uint256(value));
        }
    }

    function writeUInt64(CBORBuffer memory buf, uint64 value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_INT, value);
    }

    function writeInt64(CBORBuffer memory buf, int64 value) internal pure {
        if(value >= 0) {
            writeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
        } else{
            writeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(-1 - value));
        }
    }

    function writeBytes(CBORBuffer memory buf, bytes memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
        buf.buf.append(value);
    }

    function writeString(CBORBuffer memory buf, string memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
        buf.buf.append(bytes(value));
    }

    function writeBool(CBORBuffer memory buf, bool value) internal pure {
        writeContentFree(buf, value ? CBOR_TRUE : CBOR_FALSE);
    }

    function writeNull(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_NULL);
    }

    function writeUndefined(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_UNDEFINED);
    }

    function startArray(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
        buf.depth += 1;
    }

    function startFixedArray(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_ARRAY, length);
    }

    function startMap(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
        buf.depth += 1;
    }

    function startFixedMap(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_MAP, length);
    }

    function endSequence(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
        buf.depth -= 1;
    }

    function writeKVString(CBORBuffer memory buf, string memory key, string memory value) internal pure {
        writeString(buf, key);
        writeString(buf, value);
    }

    function writeKVBytes(CBORBuffer memory buf, string memory key, bytes memory value) internal pure {
        writeString(buf, key);
        writeBytes(buf, value);
    }

    function writeKVUInt256(CBORBuffer memory buf, string memory key, uint256 value) internal pure {
        writeString(buf, key);
        writeUInt256(buf, value);
    }

    function writeKVInt256(CBORBuffer memory buf, string memory key, int256 value) internal pure {
        writeString(buf, key);
        writeInt256(buf, value);
    }

    function writeKVUInt64(CBORBuffer memory buf, string memory key, uint64 value) internal pure {
        writeString(buf, key);
        writeUInt64(buf, value);
    }

    function writeKVInt64(CBORBuffer memory buf, string memory key, int64 value) internal pure {
        writeString(buf, key);
        writeInt64(buf, value);
    }

    function writeKVBool(CBORBuffer memory buf, string memory key, bool value) internal pure {
        writeString(buf, key);
        writeBool(buf, value);
    }

    function writeKVNull(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeNull(buf);
    }

    function writeKVUndefined(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeUndefined(buf);
    }

    function writeKVMap(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startMap(buf);
    }

    function writeKVArray(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startArray(buf);
    }

    function writeFixedNumeric(
        CBORBuffer memory buf,
        uint8 major,
        uint64 value
    ) private pure {
        if (value <= 23) {
            buf.buf.appendUint8(uint8((major << 5) | value));
        } else if (value <= 0xFF) {
            buf.buf.appendUint8(uint8((major << 5) | 24));
            buf.buf.appendInt(value, 1);
        } else if (value <= 0xFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 25));
            buf.buf.appendInt(value, 2);
        } else if (value <= 0xFFFFFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 26));
            buf.buf.appendInt(value, 4);
        } else {
            buf.buf.appendUint8(uint8((major << 5) | 27));
            buf.buf.appendInt(value, 8);
        }
    }

    function writeIndefiniteLengthType(CBORBuffer memory buf, uint8 major)
        private
        pure
    {
        buf.buf.appendUint8(uint8((major << 5) | 31));
    }

    function writeDefiniteLengthType(CBORBuffer memory buf, uint8 major, uint64 length)
        private
        pure
    {
        writeFixedNumeric(buf, major, length);
    }

    function writeContentFree(CBORBuffer memory buf, uint8 value) private pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_CONTENT_FREE << 5) | value));
    }
}