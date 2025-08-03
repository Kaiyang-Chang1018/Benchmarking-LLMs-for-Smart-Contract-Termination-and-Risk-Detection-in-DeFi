// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

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
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
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
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

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
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
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
//SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

interface EnE {
    //events
    event SwapThresholdChange(uint threshold);
    event OverLiquifiedThresholdChange(uint threshold);
    event OnSetTaxes(
        uint buy, 
        uint sell, 
        uint transfer_
    );
    event ManualSwapChange(bool status);
    event MaxWalletBalanceUpdated(uint256 percent);
    event MaxTransactionAmountUpdated(uint256 percent);
    event ExcludeAccount(address indexed account, bool indexed exclude);
    event ExcludeFromWalletLimits(address indexed account, bool indexed exclude);
    event ExcludeFromTransactionLimits(address indexed account, bool indexed exclude);
    event OwnerSwap();
    event OnEnableTrading();
    event OnProlongLPLock(uint UnlockTimestamp);
    event OnReleaseLP();
    event RecoverETH();
    event NewPairSet(address Pair, bool Add);
    event LimitTo20PercentLP();
    event NewRouterSet(address _newdex);
    event NewFeeWalletSet(address indexed NewTaxWallet);
    event RecoverTokens(uint256 amount);
    event TokensAirdroped(address indexed sender, uint256 total, uint256 amount);
    //errors
    error ZeroAddress();
    error SameAddress();
    error ContractAddress(); 
    error PairAddress();
}
//SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

interface IdexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
//SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

interface IdexRouter {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./EnE.sol";
import "./IERC20.sol";
import "./IdexRouter.sol";
import "./IdexFactory.sol";

contract bAIcon is IERC20, AccessControl, EnE {
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping(address => bool) private excludedFromWalletLimits;
    mapping(address => bool) private excludedFromTransactionLimits;
    mapping(address => bool) public excludedFromFees;
    mapping(address=>bool) public isPair;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    //strings
    string private constant _name = 'bAIcon';
    string private constant _symbol = 'bAIcon';

    //uints
    uint private constant InitialSupply= 916_000_000 * 10**_decimals;

    //Tax by divisor of MAXTAXDENOMINATOR
    uint public buyTax = 175;
    uint public sellTax = 175;
    uint public transferTax = 175;

    //taxPct must equal TAX_DENOMINATOR
    uint constant taxPct=10000;
    uint constant TAX_DENOMINATOR=10000;
    uint constant MAXBUYTAXDENOMINATOR=1000;
    uint constant MAXTRANSFERTAXDENOMINATOR=1000;
    uint constant MAXSELLTAXDENOMINATOR=1000;
    //swapTreshold dynamic by LP pair balance
    uint public swapTreshold=6;
    uint private LaunchBlock;
    uint8 private constant _decimals = 18;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletBalance;

    IdexRouter private  _dexRouter;

    //addresses
    address private dexRouter;
    address private _dexPairAddress;
    address constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    address private taxWallet;
    address[] private path;

    //bools
    bool public tokenrcvr;
    bool private _isSwappingContractModifier;
    bool public manualSwap;

    //modifiers
    modifier lockTheSwap {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    modifier onlyManager() {
        require(hasRole(MANAGER_ROLE, msg.sender), "Not a manager");
        _;
    }

    constructor () {
        _setupRole(MANAGER_ROLE, msg.sender);  // Setting up the manager role
        
        taxWallet = msg.sender;
        dexRouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        _balances[address(this)] = InitialSupply;

        path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        // Setting exclusions
        SetExclusions(
            [msg.sender, dexRouter, address(this)],
            [msg.sender, deadWallet, address(this)],
            [msg.sender, deadWallet, address(this)]
        );
    }

    /**
    * @notice Set tax to receive tokens vs ETH
    * @dev This function is for set tax to receive tokens vs ETH.
    * @param yesNo The status of tax to receive tokens vs ETH.
     */
    function TokenTaxRCVRBool (
        bool yesNo
    ) external onlyManager {
        tokenrcvr = yesNo;
    }

    /** 
    * @notice Set Exclusions
    * @dev This function is for set exclusions.
    * @param feeExclusions The array of address to be excluded from fees.
    * @param walletLimitExclusions The array of address to be excluded from wallet limits.
    * @param transactionLimitExclusions The array of address to be excluded from transaction limits.
     */
    function SetExclusions(
        address[3] memory feeExclusions, 
        address[3] memory walletLimitExclusions, 
        address[3] memory transactionLimitExclusions
    ) internal {
        for (uint256 i = 0; i < feeExclusions.length; ++i) {
            excludedFromFees[feeExclusions[i]] = true;
        }
        for (uint256 i = 0; i < walletLimitExclusions.length; ++i) {
            excludedFromWalletLimits[walletLimitExclusions[i]] = true;
        }
        for (uint256 i = 0; i < transactionLimitExclusions.length; ++i) {
            excludedFromTransactionLimits[transactionLimitExclusions[i]] = true;
        }
    }

    /**
    * @notice Internal function to transfer tokens from one address to another.
     */
    function _transfer(
        address sender, 
        address recipient, 
        uint amount
    ) internal {
        if(sender == address(0)) revert ZeroAddress();
        if(recipient == address(0)) revert ZeroAddress();

        if(excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else {
            require(LaunchBlock>0,"trading not yet enabled");
            _taxedTransfer(sender,recipient,amount);
        }
    }

    /**
    * @notice Transfer amount of tokens with fees.
    * @param sender The address of user to send tokens.
    * @param recipient The address of user to be recieved tokens.
    * @param amount The token amount to transfer.
    */
    function _taxedTransfer(
        address sender, 
        address recipient, 
        uint amount
    ) internal {
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        bool excludedFromWalletLimitsAccount = excludedFromWalletLimits[sender] || excludedFromWalletLimits[recipient];
        bool excludedFromTXNLimitsAccount = excludedFromTransactionLimits[sender] || excludedFromTransactionLimits[recipient];
        if (
            isPair[sender] &&
            !excludedFromWalletLimitsAccount
        ) {
            if(!excludedFromTXNLimitsAccount){
                require(
                amount <= maxTransactionAmount,
                "Transfer amount exceeds the maxTxAmount."
                );
            }
            uint256 contractBalanceRecepient = balanceOf(recipient);
            require(
                contractBalanceRecepient + amount <= maxWalletBalance,
                "Exceeds maximum wallet token amount."
            );
        } else if (
            isPair[recipient] &&
            !excludedFromTXNLimitsAccount
        ) {
            require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        bool isBuy=isPair[sender];
        bool isSell=isPair[recipient];
        uint tax;

        if(isSell) {  // in case that sender is dex token pair.
            uint SellTaxDuration=10;
            if(block.number<LaunchBlock+SellTaxDuration){
                tax=_getStartTax();
            } else tax=sellTax;
        }
        else if(isBuy) {    // in case that recieve is dex token pair.
            uint BuyTaxDuration=10;
            if(block.number<LaunchBlock+BuyTaxDuration){
                tax=_getStartTax();
            } else tax=buyTax;
        } else { 
            uint256 contractBalanceRecepient = balanceOf(recipient);
            if(!excludedFromWalletLimitsAccount){
            require(
                contractBalanceRecepient + amount <= maxWalletBalance,
                "Exceeds maximum wallet token amount."
                );
            }
            uint TransferTaxDuration=10;
            if(block.number<LaunchBlock+TransferTaxDuration){
                tax=_getStartTax();
            } else tax=transferTax;
        }

        if((sender!=_dexPairAddress)&&(!manualSwap)&&(!_isSwappingContractModifier))
        _swapContractToken(false);
        uint contractToken=_calculateFee(amount, tax, taxPct);
        uint taxedAmount=amount-contractToken;

        _balances[sender]-=amount;
        _balances[address(this)] += contractToken;
        _balances[recipient]+=taxedAmount;
        
        emit Transfer(sender,recipient,taxedAmount);
    }

    /**
    * @notice Provides start tax to transfer function.
    * @return The tax to calculate fee with.
    */
    function _getStartTax(
    ) internal pure returns (uint){
        uint startTax=3333;
        return startTax;
    }

    /**
    * @notice Calculates fee based of set amounts
    * @param amount The amount to calculate fee on
    * @param tax The tax to calculate fee with
    * @param taxPercent The tax percent to calculate fee with
    */
    function _calculateFee(
        uint amount, 
        uint tax, 
        uint taxPercent
    ) internal pure returns (uint) {
        return (amount*tax*taxPercent) / (TAX_DENOMINATOR*TAX_DENOMINATOR);
    }

    /**
    * @notice Transfer amount of tokens without fees.
    * @dev In feelessTransfer, there isn't limit as well.
    * @param sender The address of user to send tokens.
    * @param recipient The address of user to be recieveid tokens.
    * @param amount The token amount to transfer.
    */
    function _feelessTransfer(
        address sender, 
        address recipient, 
        uint amount
    ) internal {
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _balances[sender]-=amount;
        _balances[recipient]+=amount;
        emit Transfer(sender,recipient,amount);
    }

    /**
    * @notice Swap tokens for eth.
    * @dev This function is for swap tokens for eth.
    * @param newSwapTresholdImpact Set the swap % of LP pair holdings.
     */
    function setSwapTreshold(
        uint newSwapTresholdImpact
    ) external onlyManager{
        require(newSwapTresholdImpact<=15);//Max Impact= 1.5%
        swapTreshold=newSwapTresholdImpact;
        emit SwapThresholdChange(newSwapTresholdImpact);
    }

    /**
    * @notice Set the current taxes. tax must equal TAX_DENOMINATOR. 
    * @notice buy must be less than MAXBUYTAXDENOMINATOR.
    * @notice sell must be less than MAXSELLTAXDENOMINATOR.
    * @notice transfer_ must be less than MAXTRANSFERTAXDENOMINATOR.
    * @dev This function is for set the current taxes.
    * @param buy The buy tax.
    * @param sell The sell tax.
    * @param transfer_ The transfer tax.
     */
    function SetTaxes(
        uint buy, 
        uint sell, 
        uint transfer_
    ) external onlyManager {
        require(
            buy<=MAXBUYTAXDENOMINATOR &&
            sell<=MAXSELLTAXDENOMINATOR &&
            transfer_<=MAXTRANSFERTAXDENOMINATOR,
            "Tax exceeds maxTax"
        );

        buyTax=buy;
        sellTax=sell;
        transferTax=transfer_;
        emit OnSetTaxes(buy, sell, transfer_);
    }

    /**
     * @dev Swaps contract tokens based on various parameters.
     * @param ignoreLimits Whether to ignore the token swap limits.
     */
    function _swapContractToken(
        bool ignoreLimits
    ) internal lockTheSwap {
        uint contractBalance = _balances[address(this)];
        uint totalTax = taxPct;
        uint tokensToSwap = (_balances[_dexPairAddress] * swapTreshold) / 1000;

        if (totalTax == 0) return;

        if (ignoreLimits) {
            tokensToSwap = _balances[address(this)];
        } else if (contractBalance < tokensToSwap) {
            return;
        }

        if (tokensToSwap != 0) {
            if (tokenrcvr) {
                _balances[taxWallet] += tokensToSwap;
                emit Transfer(address(this), taxWallet, tokensToSwap);
            } else {
                _swapTokenForETH(tokensToSwap);
            }
        }
    }

    /**
    * @notice Swap tokens for eth.
    * @dev This function is for swap tokens for eth.
    * @param amount The token amount to swap.
    */
    function _swapTokenForETH(
        uint amount
    ) private {
        _approve(address(this), address(_dexRouter), amount);

        try _dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            taxWallet,
            block.timestamp
        ){}
        catch{}
    }

    /**
    * @notice Add initial liquidity to dex.
    * @dev This function is for add liquidity to dex.
     */
    function _addInitLiquidity(
    ) private {
        uint tokenAmount = balanceOf(address(this));
        _approve(address(this), address(_dexRouter), tokenAmount);
        _dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenAmount,
            0,
            0,
            taxWallet,
            block.timestamp
        );
    }

    /**
    * @notice Get Burned tokens.
    * @dev This function is for get burned tokens.
    */
    function getBurnedTokens(
    ) public view returns(uint) {
        return _balances[address(0xdead)];
    }

    /**
    * @notice Get circulating supply.
    * @dev This function is for get circulating supply.
     */
    function getCirculatingSupply(
    ) public view returns(uint) {
        return InitialSupply-_balances[address(0xdead)];
    }

    /**
    * @notice Set the current Pair.
    * @dev This function is for set the current Pair.
    * @param Pair The pair address.
    * @param Add The status of add or remove.
     */
    function SetPair(
        address Pair, 
        bool Add
    ) internal {
        if(Pair == address(0)) revert ZeroAddress();
        if(Pair == address(_dexPairAddress)) revert PairAddress();    
        require(Pair!=_dexPairAddress,"can't readd pair");
        require(Pair != address(0),"Address should not be 0");
        isPair[Pair]=Add;
        emit NewPairSet(Pair,Add);
    }

    /**
    * @notice Add a pair.
    * @dev This function is for add a pair.
    * @param Pair The pair address.
     */
    function AddPair(
        address Pair
    ) external onlyManager {
        SetPair(Pair,true);
    }

    /**
    * @notice Add a pair.
    * @dev This function is for add a pair.
    * @param Pair The pair address.
     */
    function RemovePair(
        address Pair
    ) external onlyManager {
        SetPair(Pair,false);
    }

    /**
    * @notice Set Manual Swap Mode
    * @dev This function is for set manual swap mode.
    * @param manual The status of manual swap mode.
     */
    function SwitchManualSwap(
        bool manual
    ) external onlyManager {
        manualSwap=manual;
        emit ManualSwapChange(manual);
    }

    /**
    * @notice Swap contract tokens.
    * @dev This function is for swap contract tokens.
    * @param all The status of swap all tokens in contract.
     */
    function SwapContractToken(
        bool all
    ) external onlyManager {
        _swapContractToken(all);
        emit OwnerSwap();
    }

    /**
    * @notice Set a new router address
    * @dev This function is for set a new router address.
    * @param _newdex The new router address.
     */
    function SetNewRouter(
        address _newdex
    ) external onlyManager {
        if(_newdex == address(0)) revert ZeroAddress();
        if(_newdex == address(_dexRouter)) revert SameAddress();
        dexRouter = _newdex;
        emit NewRouterSet(_newdex);
    }

    /**
    * @notice Set new tax receiver wallets.
    * @dev This function is for set new tax receiver wallets.
    * @param NewTaxWallet The new tax wallet address.
     */
    function SetFeeWallets(
        address NewTaxWallet
    ) external onlyManager {
        if (NewTaxWallet == address(0)) revert ZeroAddress();
        taxWallet = NewTaxWallet;
        emit NewFeeWalletSet(
            NewTaxWallet
        );
    }

    /**
    * @notice Set Wallet Limits
    * @dev This function is for set wallet limits.
    * @param walPct The max wallet balance percent.
    * @param txnPct The max transaction amount percent.
     */
    function SetLimits(
        uint256 walPct, 
        uint256 txnPct
    ) external onlyManager {
        require(walPct >= 100, "min 1%");
        require(walPct <= 10000, "max 100%");
        maxWalletBalance = InitialSupply * walPct / 10000;
        emit MaxWalletBalanceUpdated(walPct);

        require(txnPct >= 100, "min 1%");
        require(txnPct <= 10000, "max 100%");
        maxTransactionAmount = InitialSupply * txnPct / 10000;
        emit MaxTransactionAmountUpdated(txnPct);
    }

    /**
    * @notice Set to exclude an address from fees.
    * @dev This function is for set to exclude an address from fees.
    * @param account The address of user to be excluded from fees.
    * @param exclude The status of exclude.
    */
    function ExcludeAccountFromFees(
        address account, 
        bool exclude
    ) external onlyManager {
        if(account == address(0)) revert ZeroAddress();
        if(account == address(this)) revert ContractAddress();
        excludedFromFees[account]=exclude;
        emit ExcludeAccount(account,exclude);
    }

    /**
    * @notice Set to exclude an address from transaction limits.
    * @dev This function is for set to exclude an address from transaction limits.
    * @param account The address of user to be excluded from transaction limits.
    * @param exclude The status of exclude.
    */
    function ExcludedAccountFromTxnLimits(
        address account, 
        bool exclude
    ) external onlyManager {
        if(account == address(0)) revert ZeroAddress();
        excludedFromTransactionLimits[account]=exclude;
        emit ExcludeFromTransactionLimits(account,exclude);
    }

    /** 
    * @notice Set to exclude an address from wallet limits.
    * @dev This function is for set to exclude an address from wallet limits.
    * @param account The address of user to be excluded from wallet limits.
    * @param exclude The status of exclude.
    */
    function ExcludeAccountFromWltLimits(
        address account, 
        bool exclude
    ) external onlyManager {
        if(account == address(0)) revert ZeroAddress();
        excludedFromWalletLimits[account]=exclude;
        emit ExcludeFromWalletLimits(account,exclude);
    }

    /**
    * @notice Used to start trading.
    * @dev This function is for used to start trading.
    */
    function SetupEnableTrading(
    ) external onlyManager{
        require(LaunchBlock==0,"AlreadyLaunched");

        _dexRouter = IdexRouter(dexRouter);
        _dexPairAddress = IdexFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        isPair[_dexPairAddress]=true;

        _addInitLiquidity();

        LaunchBlock=block.number;

        maxWalletBalance = InitialSupply * 100 / 10000; // 0.12%
        maxTransactionAmount = InitialSupply * 100 / 10000; // 0.12%
        emit OnEnableTrading();
    }

    receive() external payable {}
    function name() external pure override returns (string memory) {return _name;}
    function symbol() external pure override returns (string memory) {return _symbol;}
    function decimals() external pure override returns (uint8) {return _decimals;}
    function totalSupply() external pure override returns (uint) {return InitialSupply;}
    function balanceOf(address account) public view override returns (uint) {return _balances[account];}
    function isExcludedFromWalletLimits(address account) public view returns(bool) {return excludedFromWalletLimits[account];}
    function isExcludedFromTransferLimits(address account) public view returns(bool) {return excludedFromTransactionLimits[account];}
    
    function transfer(
        address recipient, 
        uint amount
    ) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(
        address _owner, 
        address spender
    ) external view override returns (uint) {
        return _allowances[_owner][spender];
    }
    function approve(
        address spender, 
        uint amount
    ) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(
        address _owner, 
        address spender, 
        uint amount
    ) private {
        if(_owner == address(0)) revert ZeroAddress();
        if(spender == address(0)) revert ZeroAddress();
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    function transferFrom(
        address sender, 
        address recipient, 
        uint amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }
    function increaseAllowance(
        address spender, 
        uint addedValue
    ) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(
        address spender, 
        uint subtractedValue
    ) external returns (bool) {
        uint currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    /**
    * @notice Used to remove excess ETH from contract
    * @dev This function is for used to remove excess ETH from contract.
    * @param amountPercentage The amount percentage to recover.
     */
    function emergencyETHrecovery(
        uint256 amountPercentage
    ) external onlyManager {
        uint256 amountETH = address(this).balance;
        (bool sent,)=msg.sender.call{value:amountETH * amountPercentage / 100}("");
            sent=true;
        emit RecoverETH();
    }
    
    /**
    * @notice Used to remove excess Tokens from contract
    * @dev This function is for used to remove excess Tokens from contract.
    * @param tokenAddress The token address to recover.
    * @param amountPercentage The amount percentage to recover.
     */
    function emergencyTokenrecovery(
        address tokenAddress, 
        uint256 amountPercentage
    ) external onlyManager {
        if(tokenAddress == address(0)) revert ZeroAddress();
        if(tokenAddress == address(_dexPairAddress)) {
            revert PairAddress();
        }
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenAmount = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenAmount * amountPercentage / 100);

        emit RecoverTokens(tokenAmount);
    }

}