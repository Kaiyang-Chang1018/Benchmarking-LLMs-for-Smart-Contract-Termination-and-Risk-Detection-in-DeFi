// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "src/interfaces/IOracle.sol";
import "src/utils/AddressUtils.sol";

contract XOracle is AccessControl, IOracle {
    bytes32 public constant FEEDER_ROLE = keccak256("FEEDER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /// @inheritdoc IOracle
    uint32 public constant STALENESS_DEFAULT_THRESHOLD = 86400;

    /// @inheritdoc IOracle
    address public immutable baseToken;

    mapping (address => IOracle.Price) public prices;
    /**
     * @notice Maps the token address to to the staleness threshold in seconds.
     *          When the value equals to the max value of uint32, it indicates unrestricted.
     */
    mapping(address quoteToken => uint32) internal _stalenessThreshold;
    mapping(address quoteToken => uint256) internal _maxPriceTolerance;
    mapping(address quoteToken => uint256) internal _minPriceTolerance;

    constructor(address baseToken_) {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setRoleAdmin(GUARDIAN_ROLE, GUARDIAN_ROLE);
        _setRoleAdmin(FEEDER_ROLE, GUARDIAN_ROLE);

        _grantRole(GUARDIAN_ROLE, msg.sender);
        _grantRole(FEEDER_ROLE, msg.sender);

        AddressUtils.checkContract(baseToken_);
        baseToken = baseToken_;
    }

    // ========================= FEEDER FUNCTIONS ====================================

    /// @inheritdoc IOracle
    function putPrice(address asset, uint64 timestamp, uint256 price) public onlyRole(FEEDER_ROLE) {
        uint64 prev_timestamp = prices[asset].timestamp;
        if (timestamp <= prev_timestamp || timestamp > block.timestamp) revert TimestampInvalid();
        _checkPriceInTolerance(asset, price);
        uint256 prev_price = prices[asset].price;
        prices[asset] = IOracle.Price(asset, timestamp, prev_timestamp, price, prev_price);
        emit newPrice(asset, timestamp, price);
    }

    /// @inheritdoc IOracle
    function updatePrices(IOracle.NewPrice[] calldata _array) external onlyRole(FEEDER_ROLE) {
        uint256 arrLength = _array.length;
        for(uint256 i=0; i<arrLength; ){
            address asset = _array[i].asset;
            uint64 timestamp = _array[i].timestamp;
            uint256 price = _array[i].price;
            putPrice(asset, timestamp, price);
            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IOracle
    function setStalenessThresholds(address[] calldata quoteTokens, uint32[] calldata thresholds) external onlyRole(GUARDIAN_ROLE) {
        uint256 tokenCount = quoteTokens.length;
        if (tokenCount != thresholds.length) revert LengthMismatched();

        for (uint256 i; i < tokenCount; i++) {
            _stalenessThreshold[quoteTokens[i]] = thresholds[i];
            emit StalenessThresholdUpdated(quoteTokens[i], thresholds[i]);
        }
    }

    /// @inheritdoc IOracle
    function setPriceTolerance(address quoteToken, uint256 minPrice, uint256 maxPrice) external onlyRole(GUARDIAN_ROLE) {
        _setPriceTolerance(quoteToken, minPrice, maxPrice);
    }

    // ========================= VIEW FUNCTIONS ====================================

    /// @inheritdoc IOracle
    function getPrice(address asset) public view returns (uint64, uint64, uint256, uint256) {
        return (
            prices[asset].timestamp,
            prices[asset].prev_timestamp,
            prices[asset].price,
            prices[asset].prev_price
        );
    }

    /// @inheritdoc IOracle
    function getLatestPrice(address quoteToken) public view returns (uint256 price) {
        _checkPriceNotStale(quoteToken);

        price = prices[quoteToken].price;

        if (price == 0) revert PriceZero();
    }

    /// @inheritdoc IOracle
    function getPrices(address[] calldata assets) public view returns (IOracle.Price[] memory) {
        uint256 assetCount = assets.length;
        IOracle.Price[] memory _prices = new IOracle.Price[](assetCount);

        for (uint256 i; i < assetCount; i++) {
            _prices[i] = prices[assets[i]];
        }

        return _prices;
    }

    /// @inheritdoc IOracle
    function getStalenessThreshold(address quoteToken) public view returns (uint32) {
        uint32 threshold = _stalenessThreshold[quoteToken];

        return threshold == 0 ? STALENESS_DEFAULT_THRESHOLD : threshold;
    }

    /// @inheritdoc IOracle
    function getPriceTolerance(address quoteToken) public view returns (uint256 minPrice, uint256 maxPrice) {
        minPrice = _minPriceTolerance[quoteToken];
        maxPrice = _maxPriceTolerance[quoteToken];
    }

    /// @inheritdoc IOracle
    function getQuoteToken(address tokenX, address tokenY) public view returns (address quoteToken) {
        if (tokenX == tokenY) revert TokensInvalid();

        bool isXBase = tokenX == baseToken;
        if (!isXBase && tokenY != baseToken) revert TokensInvalid();

        quoteToken = isXBase ? tokenY : tokenX;
    }

    /// @inheritdoc IOracle
    function getQuoteTokenAndPrice(address tokenX, address tokenY) public view returns (address quoteToken, uint256 price) {
        quoteToken = getQuoteToken(tokenX, tokenY);
        price = getLatestPrice(quoteToken);
    }

    // ========================= PURE FUNCTIONS ====================================

    function decimals() public pure returns (uint8) {
        return 18;
    }

    // ========================= INTERNAL FUNCTIONS ================================

    function _setPriceTolerance(address quoteToken, uint256 minPrice, uint256 maxPrice) internal {
        if (maxPrice == 0 || minPrice == 0 || minPrice > maxPrice) revert PriceToleranceInvalid();
        _maxPriceTolerance[quoteToken] = maxPrice;
        _minPriceTolerance[quoteToken] = minPrice;
        emit PriceToleranceUpdated(quoteToken, minPrice, maxPrice);
    }

    /**
     * @notice Reverts if the price tolerance is invalid or if the price is outside the acceptable tolerance range
     * @param quoteToken Address of quote token
     * @param price The price of `baseToken`/`quoteToken`
     */
    function _checkPriceInTolerance(address quoteToken, uint256 price) internal view {
        (uint256 minPrice, uint256 maxPrice) = getPriceTolerance(quoteToken);

        if (minPrice == 0 || maxPrice == 0) revert PriceToleranceInvalid();
        if (price < minPrice || price > maxPrice) revert PriceNotInTolerance();
    }

    /**
     * @notice Reverts if the price is stale
     * @param quoteToken Address of the quote token
     */
    function _checkPriceNotStale(address quoteToken) internal view {
        uint32 threshold = getStalenessThreshold(quoteToken);

        if (threshold < type(uint32).max) {
            uint64 priceTimestamp = prices[quoteToken].timestamp;
            if (priceTimestamp <= block.timestamp && block.timestamp - priceTimestamp > threshold) {
                revert PriceStale();
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.19;

interface IOracle{
    event newPrice(address indexed _asset, uint64 _timestamp, uint256 _price);
    event StalenessThresholdUpdated(address indexed quoteToken, uint32 threshold);
    event PriceToleranceUpdated(address indexed quoteToken, uint256 minPrice, uint256 maxPrice);

    error LengthMismatched();
    error PriceStale();
    error PriceToleranceInvalid();
    error PriceNotInTolerance();
    error TokensInvalid();
    error PriceZero();
    error TimestampInvalid();

    /**
     * @notice Updates the price of `baseToken`/`asset` to the specified `price` at the given timestamp.
     *         Reverts if the price tolerance is invalid or if the new price is outside the acceptable tolerance range.
     */
    function putPrice(address asset, uint64 timestamp, uint256 price) external;

    /**
     * @notice Updates the prices
     * @param _array An array of `NewPrice` structs containing information about the new prices.
     */
    function updatePrices(NewPrice[] calldata _array) external;

    /**
     * @notice Updates staleness thresholds, reverts if the array lengths mismatched.
     * @param quoteTokens The array of quote currency addresses
     * @param thresholds The array of the staleness thresholds in seconds
     */
    function setStalenessThresholds(address[] calldata quoteTokens, uint32[] calldata thresholds) external;

    /**
     * @notice Updates the price tolerance range of USD1/`token`
     * @param quoteToken Address of the quote currency
     * @param minPrice Min price tolerance
     * @param maxPrice Max price tolerance
     */
    function setPriceTolerance(address quoteToken, uint256 minPrice, uint256 maxPrice) external;

    /**
     * @notice Returns the base token for all oracle prices, which is USD1.
     */
    function baseToken() external view returns (address);

    /**
     * @notice Gets the price info of `asset`
     */
    function getPrice(address asset) external view returns (uint64 timestamp, uint64 prevTimestamp, uint256 price, uint256 prevPrice);

    /**
     * @notice Gets a list of prices.
     * @param assets The token addresses
     * @return The prices of assets
     */
    function getPrices(address[] calldata assets) external view returns (IOracle.Price[] memory);

    /**
     * @notice Gets the latest price.
     *         Reverts if the timestamp of the price exceeds the staleness limit, or the price is zero.
     * @param quoteToken Address of the quote currency
     * @return price The price of `baseToken`/`quoteToken`
     */
    function getLatestPrice(address quoteToken) external view returns (uint256 price);

    /**
     * @notice Gets the price staleness threshold, returns `STALENESS_DEFAULT_THRESHOLD` if it is zero.
     * @param quoteToken Address of the quote token
     * @return The staleness threshold in seconds
     */
    function getStalenessThreshold(address quoteToken) external view returns (uint32);

    /**
     * @notice Gets the price tolerance of `baseToken`/`quoteToken`
     */
    function getPriceTolerance(address quoteToken) external view returns (uint256 minPrice, uint256 maxPrice);

    /**
     * @notice Gets the quote token of oracle price by two token addresses.
     *          Because of the base currencies of all oracle prices are always USD1 (e.g., USD1/USDT and USD1/USD91),
     *          one of `tokenX` or `tokenY` must be USD1, and the other must not be USD1.
     * @param tokenX Address of base currency or quote currency
     * @param tokenY Address of base currency or quote currency
     * @return quoteToken The quote currency of oracle price
     */
    function getQuoteToken(address tokenX, address tokenY) external view returns (address quoteToken);

    /**
     * @notice Gets the quote token of oracle and the latest price.
     *         Reverts if the two token addresses are invalid, the timestamp of the price exceeds the staleness limit, or the price is zero.
     * @param tokenX Address of base currency or quote currency
     * @param tokenY Address of base currency or quote currency
     */
    function getQuoteTokenAndPrice(address tokenX, address tokenY) external view returns (address quoteToken, uint256 price);

    function FEEDER_ROLE() external pure returns (bytes32);

    function GUARDIAN_ROLE() external pure returns (bytes32);

    /**
     * @notice Default threshold for staleness in seconds.
     *          When the value of `_stalenessThreshold` is zero, this default value is used.
     */
    function STALENESS_DEFAULT_THRESHOLD() external pure returns (uint32);

    function decimals() external pure returns (uint8);

    // Struct of main contract XOracle
    struct Price{
        address asset;
        uint64 timestamp;
        uint64 prev_timestamp;
        uint256 price;
        uint256 prev_price;
    }

    struct NewPrice{
        address asset;
        uint64 timestamp;
        uint256 price;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

library AddressUtils {
    error AddressZero();
    error AddressCodeSizeZero();

    /**
     * @notice Reverts if `account` is zero or the code size is zero
     */
    function checkContract(address account) internal view {
        checkNotZero(account);

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        if (size == 0) revert AddressCodeSizeZero();
    }

    /**
     * @notice Reverts if `account` is zero
     */
    function checkNotZero(address account) internal pure {
        if (account == address(0)) revert AddressZero();
    }
}