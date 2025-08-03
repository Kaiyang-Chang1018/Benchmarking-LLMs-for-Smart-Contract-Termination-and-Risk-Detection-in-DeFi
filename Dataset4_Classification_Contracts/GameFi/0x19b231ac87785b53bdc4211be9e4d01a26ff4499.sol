// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "./IAccessControl.sol";
import {Context} from "../utils/Context.sol";
import {ERC165} from "../utils/introspection/ERC165.sol";

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
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
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
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
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
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
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
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` to `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
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
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

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
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

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
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IBinding} from "./interface/IBinding.sol";

contract Binding is IBinding, AccessControl {

    bytes32 public constant CRYPTAR_ROLE = keccak256("CRYPTAR_ROLE");

    constructor() {
        // Assign the default admin role to the contract deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        _checkRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    modifier onlyCryptar() {
        _checkRole(CRYPTAR_ROLE);
        _;
    }

    function bindCryptar(
        address cryptar
    ) external onlyAdmin {
        _grantRole(CRYPTAR_ROLE, cryptar);
    }

    function transferOwnership(
        address owner
    ) external onlyAdmin {
        if(owner == address(0)) revert InvalidTransferOwnership();
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
    }
}
// SPDX-License-Identifier: UNLICENSED

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                    //
//                                                @@@@@@@@@@@@@@@@@@@@                                                //
//                                             @@@@@@@@@@@@@@@@@@@@@@@@@@                                             //
//                                         @@@@@@@@@@              @@@@@@@@@@                                         //
//                                      @@@@@@@@@                     @@@@@@@@@@                                      //
//                                   @@@@@@@@                        @@@@@@@@@@@@@@                                   //
//                                 @@@@@@@                         @@@@@@@@@@ @@@@@@                                  //
//                                  @@@@   @@@                           @@@@ @@@@@@                                  //
//                                  @@@@   @@@@@@@@@@@            @@@@@@@@@@@ @@@@@@                                  //
//                                  @@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@                                  //
//                                   @@@@  @@@@@    @@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@                                   //
//                                   @@@@  @@@@@           @@@     @@@@ @@@@@  @@@@                                   //
//                                   @@@@  @@@@@           @@      @@@@ @@@@@ @@@@@                                   //
//                                   @@@@@  @@@@           @@      @@@@ @@@@@ @@@@@                                   //
//                                  @@@@@@  @@@@           @@     @@@@ @@@@@@ @@@@@@                                  //
//                                  @@@@@@  @@@@@          @@     @@@@ @@@@@  @@@@@@                                  //
//                                 @@@@@@@  @@@@@          @@     @@@@ @@@@@  @@ @@@@                                 //
//                                 @@@@ @@  @@@@@    @@@   @@   @@@@@@ @@@@@  @@ @@@@                                 //
//                      @@@       @@@@@  @  @@@@@@   @@@   @@   @@@@@ @@@@@@  @  @@@@@       @@@                      //
//                     @@@@@      @@@@   @  @@@@@@         @@     @@@ @@@@@@ @@   @@@@      @@@@@                     //
//                   @@@@@@@@@   @@@@@    @ @@@@@@               @@@@ @@@@@@ @    @@@@@   @@@@@@@@@                   //
//                     @@@@      @@@@       @@@@@@@              @@@@@@@@@@@       @@@@      @@@@                     //
//                      @@      @@@@@       @@@@@@@              @@@ @@@@@@@       @@@@@      @@                      //
//              @@               @@@@@       @@@@@@              @@@ @@@@@@       @@@@@               @@              //
//             @@@@    @@         @@@@@@     @@@@@@@@            @@ @@@@@@@     @@@@@@         @@    @@@@             //
//            @@@@@@  @@@@          @@@@@     @@@@@@@@          @ @@@@@@@@     @@@@@          @@@@  @@@@@@            //
//              @@@    @@            @@@@@    @@@@@@@@@          @@@@@@@@     @@@@@            @@    @@@              //
//               @@             @@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@@@@@@             @@               //
//                          @@@@@@@@@@  @@@@    @@@@@@@@@@@@@@@@@@@@@@@@    @@@@   @@@@@@@@@                          //
//                     @@@@@@@@@@        @@@@@   @@@@@@@@@@@@@@@@@@@@@@@  @@@@@        @@@@@@@@@@                     //
//                @@@@@@@@@@         @@   @@@@@  @@@@@@@@@@@@@@@@@@@@@@  @@@@@    @@        @@@@@@@@@@                //
//            @@@@@@@@@               @@    @@@@  @@@@@@@@@@@@@@@@@@@@  @@@@    @@@@             @@@@@@@@@            //
//          @@@@@@@   @@@      @@@@   @@@@   @@@@  @@@@@@@@  @@@@@@@@  @@@@   @@@@@   @@@      @@@   @@@@@@@          //
//        @@@@@@@@@@   @@@      @@@@   @@@@@  @@@@ @@@@@@      @@@@@@ @@@@  @@@@@@@  @@@@     @@@@  @@@@@@@@@@        //
//      @@@@@@@@@@@@@  @@@@     @@@@@  @@@@@@@ @@@@@@@@@        @@@@@@@@  @@@@@@@@  @@@@     @@@@  @@@@@@@@@@@@@      //
//    @@@@@@@@@@@@@@@@@ @@@@     @@@@@  @@@@@@@@@@@@@@@@ @    @ @@@@@@@@@@@@@@@@@  @@@@@    @@@@ @@@@@@@@@@@@@@@@@    //
//     @@@@@@@@@@@@@@@@@ @@@@    @@@@@@ @@@@@@@@@@@@@@@@@  @@  @@@@@@@@@@@@@@@@@@ @@@@@    @@@@ @@@@@@@@@@@@@@@@@     //
//       @@@@@@     @@@@@ @@@     @@@@@@ @@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@ @@@@@     @@@ @@@@@      @@@@@       //
//        @@@@@@@@@@@@@@@@ @@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@ @@@@@@@@@@@@@@@@        //
//         @@@@@@@@@@@@@@@@ @@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@ @@@@@@@@@@@@@@@@         //
//         @@@        @@@@@@@@@@   @@@@@@@@@@@@@@@@#                @@@@@@@@@@@@@@@@@   @@@@@@@@@@        @@@         //
//         @@@@   @@@@@@@@@@@@@@@   @@@@@@@@@@@@           @@@@@@      @@@@@@@@@@@@@   @@@@@@@@@@@@@@@   @@@@         //
//         @@@@   @@@@@@@@@@@@@@@@  @@@@@@@@@@                   @@@@     @@@@@@@@@@  @@@@@@@@@@@@@@@@   @@@@         //
//  @@@   @@@@@@  @@@@@@@@@@@@@@@@@  @@@@@@@                          @@@   @@@@@@@  @@@@@@@@@@@@@@@@@  @@@@@@   @@@  //
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@    @@                      @@@   @@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ //
// @@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    @@@@@@                           @@@@ @@@@@@@@@@@@@@@@@@@@@@@@@ @@@ @@@@ //
//  @@@  @@  @@@@@@@@@@@@@@@   @@@@@@@@@       @@                         @@@  @@@@@@@@@@   @@@@@@@@@@@@@@@  @@  @@@  //
//  @@@  @@@@@   @@@@@@@@@@    @@@@@@@@@                                   @@@  @@@@@@@@@    @@@@@@@@@@   @@@@@ @@@@  //
//   @@@@@ @@@@@@@@@@@@@@@@    @@@@@@@@                                     @@   @@@@@@@@    @@@@@@@@@@@@@@@@ @@@@@   //
//   @@@@    @@@@    @@@@@    @@@@@@@@@                                     @@@  @@@@@@@@@    @@@@@    @@@@    @@@    //
//    @@@@  @@@       @@@@@@@@@@@@@@@@@   @@                                 @@  @@@@@@@@@@@@@@@@@       @@@  @@@@    //
//    @@@@@@@@        @@@@@@@@@@@@@@@@                                       @@   @@@@@@@@@@@@@@@@        @@@@@@@@    //
//   @@@@@@@@@@@     @@@@    @@@@@@@@@@                                      @@  @@@@@@@@@@    @@@      @@@@@@@@@@@   //
//    @@@   @@@@@@   @@@     @@@@@@@@@@                                     @@   @@@@@@@@@@     @@@   @@@@@@   @@@    //
//     @@@   @@@@@   @@      @@@@@@@@@@                                     @@   @@@@@@@@@@      @@   @@@@@   @@@     //
//     @@@@  @@@@@@@ @@@    @@@@@@@@@@@@                                   @@   @@@@@@@@@@@@    @@@ @@@@@@@  @@@@     //
//      @@@@@@@   @@@ @@   @@@@@@@@@@@@@                                  @@   @@@@@@@@@@@@@@  @@@ @@@   @@@@@@@      //
//       @@@@@@@   @@  @@@@@@@@@@@  @@@@@@                                    @@@@@@  @@@@@@@@@@@  @@@  @@@@@@@       //
//        @@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@                                  @@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@         //
//         @@@ @@@@@@@@@@@@@ @@@@@@ @@@@@@@@             @@@@@@@           @@@@@@@@@ @@@@@@@@@@@@@@@@@@@@ @@@         //
//         @@@  @@@@@@@@@@@@@@@@@@@ @@@@@@@@@@      @@@@@@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@         //
//         @@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@         //
//         @@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@         //
//         @@@  @@@@@@@           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           @@@@@@@  @@@         //
//         @@@  @@@@@@   @@@          @@@@@@@@@@                   @@@@@@@@@@@@@@@          @@@   @@@@@@  @@@         //
//         @@@  @@@@@@   @@@       @@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@      @@@   @@@@@@  @@@         //
//         @@@@ @@@      @@@       @@ @@      @@@@                    @@@@      @@ @@       @@@      @@@ @@@@         //
//          @@@@@@@      @@@        @@@@ @@@   @@@@@@@@@@@@@@@@@@@@@@@@@@   @@@ @@@@        @@@      @@@@@@@          //
//            @@@@@       @            @@@     @@@@       @@   @@@@@@@@@@    @@@             @       @@@@@            //
//             @@@@      @@@          @@@    @@@@@         @@@@@@@@@@@@@@@@   @@@           @@@      @@@@             //
//              @@@       @                 @@@@             @@@@@@@@@@@@@@@                 @       @@@              //
//               @@                         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                         @@               //
//                                         @@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@                                          //
//                                         @@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@                                          //
//                                          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                           //
//                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 8""""8   8"""8    8    8   8""""8  ""8""   8""""8   8"""8       8""""8   8""""8   8""""   8""""8   8   8    8""""8 //
// 8    "   8   8    8    8   8    8    8     8    8   8   8       8        8    8   8       8    8   8   8    8      //
// 8e       8eee8e   8eeee8   8eeee8    8e    8eeee8   8eee8e      8eeeee   8eeee8   8eeee   8eeee8   8eee8e   8eeeee //
// 88       88   8     88     88        88    88   8   88   8          88   88       88      88   8   88   8       88 //
// 88   e   88   8     88     88        88    88   8   88   8      e   88   88       88      88   8   88   8   e   88 //
// 88eee8   88   8     88     88        88    88   8   88   8      8eee88   88       88eee   88   8   88   8   8eee88 //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.23;

import {ERC721Psi} from "./external/ERC721Psi/ERC721Psi.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Base64} from "solady/src/utils/Base64.sol";
import {LibPRNG} from "solady/src/utils/LibPRNG.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {FortuneCard, IFortuneCard} from "./FortuneCard.sol";
import {FortuneTeller, IFortuneTeller} from "./FortuneTeller.sol";
import {IFortune} from "./interface/IFortune.sol";
import "./Fortune.sol";

/// VERSION: 1.0
contract Cryptar is
ERC721Psi,
IFortune,
ReentrancyGuard,
Ownable
{
    using LibPRNG for LibPRNG.PRNG;
    using SafeTransferLib for address payable;
    using LibString for uint256;
    using LibString for int256;
    using Base64 for string;
    using Fortune for uint256;
    using Fortune for int256;

    int256 private constant GRADIENT_MAX = 250;
    int256 private constant GRADIENT_MIN = - 250;

    uint256 public totalFortunes = 1;
    uint256 public totalCurses = 1;
    uint256 public mintPrice;
    uint256 public burnPrice;

    mapping(uint256 tokenId => uint256) private _fortunes;
    address payable private _teamAddress;
    IFortuneTeller private _fortuneTeller;
    IFortuneCard   private _fortuneCard;

    error ErrorMintTxPrice();
    error ErrorBurnTxPrice();

    event CryptarSpeaks(address indexed owner, uint256 indexed fortuneId);
    event CryptarCurses(address indexed owner, uint256 indexed curseId);

    constructor(
        uint256 price,
        address payable team,
        address card,
        address teller
    )
    ERC721Psi("Cryptar Speaks", "CRYPT")
    Ownable(msg.sender)
    {
        mintPrice = burnPrice = price;
        _teamAddress = team;
        _fortuneCard = IFortuneCard(card);
        _fortuneTeller = IFortuneTeller(teller);
        uint256 genesis =
            (GENESIS_DATE << FORTUNE_DATE_OFFSET) |
            (FORTUNE_FLAG_LEGEND << FORTUNE_FLAG_OFFSET);
        _fortunes[0] = genesis;
        _fortunes[1] = genesis | (FORTUNE_FLAG_CURSED << FORTUNE_FLAG_OFFSET);
        _mint(msg.sender, 2);
    }

    function setFortuneCard(
        address card
    ) external onlyOwner {
        _fortuneCard = IFortuneCard(card);
    }

    function setFortuneTeller(
        address teller
    ) external onlyOwner {
        _fortuneTeller = IFortuneTeller(teller);
    }

    function setTeamAddress(
        address payable team
    ) external onlyOwner {
        _teamAddress = team;
    }

    function setPrice(
        uint256 price
    ) external onlyOwner {
        mintPrice = burnPrice = price;
    }

    function setBurnPrice(
        uint256 price
    ) external onlyOwner {
        burnPrice = price;
    }

    function mint() external payable nonReentrant {
        if (msg.value < mintPrice) revert ErrorMintTxPrice();
        uint256 tokenId = _nextTokenId();
        _fortunes[tokenId] = _makePrediction(tokenId);
        _mint(msg.sender, 1);
    }

    function burn(
        uint256 tokenId
    ) external payable nonReentrant {
        address owner = msg.sender;
        if (msg.value < burnPrice) revert ErrorBurnTxPrice();
        if (!_isApprovedOrOwner(owner, tokenId)) revert ErrorInvalidOwner();
        uint256 fortune = _fortuneOf(tokenId);
        if (fortune.isCursed()) revert ErrorInvalidBurn();
        fortune = fortune.isInfernal() ? fortune.setLegend() : fortune.clearLegend();
        _fortunes[tokenId] = fortune.setCursed(totalCurses++);
        /// @solidity memory-safe-assembly
        assembly {
            // emit burn Transfer
            log4(codesize(), 0x00, TRANSFER_EVENT, owner, 0, tokenId)
            // emit mint Transfer
            log4(codesize(), 0x00, TRANSFER_EVENT, 0, owner, tokenId)
        }
    }

    function withdraw() external nonReentrant {
        _teamAddress.safeTransferAllETH();
    }

    function fortuneOf(
        uint256 tokenId
    ) external view returns (address, uint256) {
        return (ownerOf(tokenId), _fortuneOf(tokenId));
    }

    function tokenURI(
        uint256 tokenId
    ) override public view returns (string memory) {
        string memory traits;
        string memory imageData;
        string[] memory revealed;
        uint256 fortune = _fortuneOf(tokenId);
        if (fortune.isCursed()) {
            revealed = _fortuneTeller.revealCurse(fortune);
            imageData = _cursedImageData(fortune, revealed);
            traits = _fortuneTeller.cursedTraits(revealed);
        } else {
            revealed = _fortuneTeller.revealFortune(fortune);
            imageData = _fortuneImageData(fortune, revealed);
            traits = _fortuneTeller.fortunateTraits(revealed);
        }
        string memory title = string.concat(revealed[0], ' #', fortune.getId().toString());
        return _formatMetadata(title, revealed[1], imageData, traits);
    }

    function _formatMetadata(
        string memory title,
        string memory description,
        string memory imageData,
        string memory attributes
    ) internal pure returns (string memory) {
        return string.concat('data:application/json;base64,',
            Base64.encode(bytes(string.concat('{',
                _stringTrait("name", title), ',',
                _stringTrait("description", description), ',',
                '"image":"', imageData, '",',
                '"animation_url":"', imageData, '",',
                '"attributes":[', attributes, ']'
            '}')))
        );
    }

    function _makePrediction(
        uint256 tokenId
    ) private returns (uint256) {
        LibPRNG.PRNG memory rng;
        rng.seed(uint256(keccak256(abi.encodePacked(
            block.prevrandao, tokenId, msg.sender, block.timestamp
        ))));
        unchecked {
            uint256[FORTUNE_MAX] memory used;
            uint256 fortune;
            uint256 offset = 0;
            uint256 num;
            for (uint256 i = 0; i < FORTUNE_COUNT; i++) {
                do {
                    num = rng.uniform(FORTUNE_MAX);
                }
                while (used[num] != 0);
                fortune |= used[num] = num << offset;
                offset += 8;
            }
            if (fortune.isCosmic()) {
                fortune = fortune.setLegend();
            }
            return fortune |
                (block.timestamp << FORTUNE_DATE_OFFSET) |
                (totalFortunes++ << FORTUNE_ID_OFFSET);
        }
    }

    function _fortuneOf(
        uint256 tokenId
    ) private view returns (uint256) {
        if (!_exists(tokenId)) revert ErrorInvalidToken();
        return _fortunes[tokenId];
    }

    function _fortuneImageData(
        uint256 data,
        string[] memory fortune
    ) private view returns (string memory) {
        bool cosmic = data.isLegend();
        string[3] memory text = [fortune[2], fortune[1], fortune[3]];
        return _formatImageData(data, text, _fortuneCard.revealFortuneCard(cosmic), cosmic);
    }

    function _cursedImageData(
        uint256 data,
        string[] memory curse
    ) private view returns (string memory) {
        bool infernal = data.isLegend();
        string[3] memory text = [curse[2], curse[3], curse[6]];
        return _formatImageData(data, text, _fortuneCard.revealCursedCard(infernal), infernal);
    }

    function _formatImageData(
        uint256 data,
        string[3] memory text,
        string[] memory card,
        bool legendary
    ) private pure returns (string memory) {
        string memory seed = legendary ? _turbulenceSeed(data) : _gradientPos(data);
        return string.concat('data:image/svg+xml;base64,',
            Base64.encode(bytes(string.concat(
                card[0], seed, card[1], text[0], card[2], text[1], card[3], text[2], card[4]
            )))
        );
    }

    function _stringTrait(
        string memory key,
        string memory value
    ) private pure returns (string memory) {
        return string.concat('"', key, '":"', value, '"');
    }

    function _gradientPos(
        uint256 data
    ) private pure returns (string memory) {
        return string.concat(
            ' ', _scaleGradient(data, 6), ' ', _scaleGradient(data, 3)
        );
    }

    function _turbulenceSeed(
        uint256 data
    ) private pure returns (string memory) {
        return (100 + data.avgValue(6) * 6).toString();
    }

    function _scaleGradient(
        uint256 fortune,
        uint256 index
    ) private pure returns (string memory) {
        unchecked {
            return int256(fortune.avgValue(index)).scaleToRange(
                int256(FORTUNE_MIN), int256(FORTUNE_MAX), GRADIENT_MIN, GRADIENT_MAX
            ).toString();
        }
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

uint256 constant FORTUNE_MIN = 1;
uint256 constant FORTUNE_MAX = 100;
uint256 constant FORTUNE_COUNT = 9;
uint256 constant FORTUNE_ELEMENTS = 9;
uint256 constant FORTUNE_TITLES = 25;
uint256 constant FORTUNE_CARD_ELEMENTS = 5;

uint256 constant FORTUNE_DATE_OFFSET = 72;
uint256 constant FORTUNE_FLAG_OFFSET = 136;
uint256 constant FORTUNE_ID_OFFSET = 144;

uint256 constant FORTUNE_NUM_MASK = 0xFF;
uint256 constant FORTUNE_DATE_MASK = 0xFFFFFFFFFFFFFFFF;
uint256 constant FORTUNE_DATA_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
uint256 constant FORTUNE_ID_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

uint256 constant FORTUNE_FLAG_CURSED = 0x01;
uint256 constant FORTUNE_FLAG_LEGEND = 0x02;
uint256 constant FORTUNE_FLAG_ECHOED = 0x04;

uint256 constant CURSED_ELEMENTS = 8;
uint256 constant CURSED_CARD_ELEMENTS = 5;

uint256 constant GENESIS_DATE = 3100499717;
uint256 constant GENESIS_MASK = 0xFFFFFFFFFFFFFFFFFF;

uint256 constant MIN_DATE = 1;
uint256 constant MAX_DATE = 1_000_000;

// equivalent to `keccak256(bytes("Transfer(address,address,uint256)"))`
uint256 constant TRANSFER_EVENT = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

error ErrorInvalidToken();
error ErrorInvalidMint();
error ErrorInvalidBurn();
error ErrorInvalidOwner();

library Fortune {

    uint256 private constant DEADLY_MAX = 7;
    uint256 private constant COMMANDS_MAX = 50;

    uint256 private constant MASK_UINT8_1 = 0xFF0000000000;
    uint256 private constant MASK_UINT8_2 = 0x00FF00000000;
    uint256 private constant MASK_UINT8_3 = 0x0000FF000000;
    uint256 private constant MASK_UINT8_4 = 0x000000FF0000;
    uint256 private constant MASK_UINT8_5 = 0x00000000FF00;
    uint256 private constant MASK_UINT8_6 = 0x0000000000FF;

    uint256 private constant MASK_UINT16_1 = 0xFFFF00000000;
    uint256 private constant MASK_UINT16_2 = 0x00FFFF000000;
    uint256 private constant MASK_UINT16_3 = 0x0000FFFF0000;
    uint256 private constant MASK_UINT16_4 = 0x000000FFFF00;
    uint256 private constant MASK_UINT16_5 = 0x00000000FFFF;

    function titleIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return ((_at(fortune, 0)) * _at(fortune, 3) * _at(fortune, 6)) % FORTUNE_TITLES; }
    }

    function colorIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return (_at(fortune, 0) + _at(fortune, 1) + _at(fortune, 2)) % FORTUNE_MAX; }
    }

    function animalIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return (_at(fortune, 3) + _at(fortune, 4) + _at(fortune, 5)) % FORTUNE_MAX; }
    }

    function charmIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return (_at(fortune, 6) + _at(fortune, 7) + _at(fortune, 8)) % FORTUNE_MAX; }
    }

    function cursedIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return (_value(fortune, 1) + _value(fortune, 4) + _value(fortune, 7)) % FORTUNE_MAX; }
    }

    function deadlyIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked { return ((_at(fortune, 2)) + _at(fortune, 5) + _at(fortune, 8)) % DEADLY_MAX; }
    }

    function dateIndex(
        uint256 fortune
    ) internal pure returns(uint256) {
        unchecked {
            return ((_value(fortune, 1) * _value(fortune, 4) * _value(fortune, 7) + uint16(fortune)) % MAX_DATE) + MIN_DATE;
        }
    }

    function cmdIndex(
        uint256 fortune,
        uint256 offset
    ) internal pure returns (uint256) {
        return (_value(fortune, offset) + offset) % COMMANDS_MAX;
    }

    function getId(
        uint256 fortune
    ) internal pure returns (uint256) {
        return (fortune >> FORTUNE_ID_OFFSET) & FORTUNE_ID_MASK;
    }

    function setCursed(
        uint256 fortune,
        uint256 id
    ) internal pure returns (uint256) {
        return (fortune & ~(FORTUNE_ID_MASK << FORTUNE_ID_OFFSET)) |
        (FORTUNE_FLAG_CURSED << FORTUNE_FLAG_OFFSET) | (id << FORTUNE_ID_OFFSET);
    }

    function isCursed(
        uint256 fortune
    ) internal pure returns (bool) {
        return ((fortune >> FORTUNE_FLAG_OFFSET) & FORTUNE_FLAG_CURSED) != 0;
    }

    function setLegend(
        uint256 fortune
    ) internal pure returns (uint256){
        return fortune | (FORTUNE_FLAG_LEGEND << FORTUNE_FLAG_OFFSET);
    }

    function clearLegend(
        uint256 fortune
    ) internal pure returns (uint256) {
        return fortune & ~(FORTUNE_FLAG_LEGEND << FORTUNE_FLAG_OFFSET);
    }

    function isLegend(
        uint256 fortune
    ) internal pure returns (bool) {
        return ((fortune >> FORTUNE_FLAG_OFFSET) & FORTUNE_FLAG_LEGEND) != 0;
    }

    function setEchoed(
        uint256 fortune
    ) internal pure returns (uint256){
        return fortune | (FORTUNE_FLAG_ECHOED << FORTUNE_FLAG_OFFSET);
    }

    function isEchoed(
        uint256 fortune
    ) internal pure returns (bool) {
        return ((fortune >> FORTUNE_FLAG_OFFSET) & FORTUNE_FLAG_ECHOED) != 0;
    }

    uint256 private constant CHECK_69_1 = 0x450000000000;
    uint256 private constant CHECK_69_2 = 0x004500000000;
    uint256 private constant CHECK_69_3 = 0x000045000000;
    uint256 private constant CHECK_69_4 = 0x000000450000;
    uint256 private constant CHECK_69_5 = 0x000000004500;
    uint256 private constant CHECK_69_6 = 0x000000000045;

    uint256 private constant CHECK_420_1 = 0x041400000000;
    uint256 private constant CHECK_420_2 = 0x000414000000;
    uint256 private constant CHECK_420_3 = 0x000004140000;
    uint256 private constant CHECK_420_4 = 0x000000041400;
    uint256 private constant CHECK_420_5 = 0x000000000414;

    function isCosmic(
        uint256 fortune
    ) internal pure returns (bool) {
        if ((fortune & GENESIS_MASK) == 0) return true;
        return ((
            // Check for 69 (0x45) at any position
            ((fortune & MASK_UINT8_1) == CHECK_69_1) ||
            ((fortune & MASK_UINT8_2) == CHECK_69_2) ||
            ((fortune & MASK_UINT8_3) == CHECK_69_3) ||
            ((fortune & MASK_UINT8_4) == CHECK_69_4) ||
            ((fortune & MASK_UINT8_5) == CHECK_69_5) ||
            ((fortune & MASK_UINT8_6) == CHECK_69_6)
        ) && (
            // Check for the sequence 4, 20 (0x0414) at any position
            ((fortune & MASK_UINT16_1) == CHECK_420_1) ||
            ((fortune & MASK_UINT16_2) == CHECK_420_2) ||
            ((fortune & MASK_UINT16_3) == CHECK_420_3) ||
            ((fortune & MASK_UINT16_4) == CHECK_420_4) ||
            ((fortune & MASK_UINT16_5) == CHECK_420_5)
        ));
    }

    uint256 private constant CHECK_13_1 = 0x0D0000000000;
    uint256 private constant CHECK_13_2 = 0x000D00000000;
    uint256 private constant CHECK_13_3 = 0x00000D000000;
    uint256 private constant CHECK_13_4 = 0x0000000D0000;
    uint256 private constant CHECK_13_5 = 0x000000000D00;
    uint256 private constant CHECK_13_6 = 0x00000000000D;

    uint256 private constant CHECK_666_1 = 0x064200000000;
    uint256 private constant CHECK_666_2 = 0x000642000000;
    uint256 private constant CHECK_666_3 = 0x000006420000;
    uint256 private constant CHECK_666_4 = 0x000000064200;
    uint256 private constant CHECK_666_5 = 0x000000000642;

    function isInfernal(
        uint256 fortune
    ) internal pure returns (bool) {
        if ((fortune & GENESIS_MASK) == 0) return true;
        return ((
            // Check for 13 (0x0D) at any position
            ((fortune & MASK_UINT8_1) == CHECK_13_1) ||
            ((fortune & MASK_UINT8_2) == CHECK_13_2) ||
            ((fortune & MASK_UINT8_3) == CHECK_13_3) ||
            ((fortune & MASK_UINT8_4) == CHECK_13_4) ||
            ((fortune & MASK_UINT8_5) == CHECK_13_5) ||
            ((fortune & MASK_UINT8_6) == CHECK_13_6)
        ) && (
            // Check for the sequence 6, 66 (0x0642) at any position
            ((fortune & MASK_UINT16_1) == CHECK_666_1) ||
            ((fortune & MASK_UINT16_2) == CHECK_666_2) ||
            ((fortune & MASK_UINT16_3) == CHECK_666_3) ||
            ((fortune & MASK_UINT16_4) == CHECK_666_4) ||
            ((fortune & MASK_UINT16_5) == CHECK_666_5)
        ));
    }

    function scaleToRange(
        int256 number,
        int256 min,
        int256 max,
        int256 newMin,
        int256 newMax
    ) internal pure returns (int256) {
        unchecked {
            return (number - min) * (newMax - newMin) / (max - min) + newMin;
        }
    }

    function scaleToRange(
        uint256 number,
        uint256 min,
        uint256 max,
        uint256 newMin,
        uint256 newMax
    ) internal pure returns (uint256) {
        unchecked {
            return (number - min) * (newMax - newMin) / (max - min) + newMin;
        }
    }

    function avgValue(
        uint256 fortune,
        uint256 index
    ) internal pure returns (uint256) {
       return (_value(fortune, index) + _value(fortune, index + 1) + _value(fortune, index+2))/3;
    }

    function value(
        uint256 fortune,
        uint256 index
    ) internal pure returns(uint256) {
        return _value(fortune, index);
    }

    function at(
        uint256 fortune,
        uint256 index
    ) internal pure returns(uint256) {
        return _at(fortune, index);
    }

    function _value(
        uint256 fortune,
        uint256 index
    ) private pure returns(uint256) {
        unchecked { return _at(fortune, index) + 1; }
    }

    function _at(
        uint256 fortune,
        uint256 index
    ) private pure returns(uint256) {
        return (fortune >> (index * 8) & FORTUNE_NUM_MASK);
    }
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import {JSONParserLib} from "solady/src/utils/JSONParserLib.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {LibZip} from "solady/src/utils/LibZip.sol";
import {Binding} from "./Binding.sol";
import {IFortuneCard} from "./interface/IFortuneCard.sol";
import "./Fortune.sol";

contract FortuneCard is IFortuneCard, Binding {
    using JSONParserLib for JSONParserLib.Item;
    using JSONParserLib for string;
    using LibString for uint256;

    uint256 private constant INDEX_MASK = 0xFF;

    uint256 private constant FORTUNE_START = 0;
    uint256 private constant FORTUNE_FILTER_NORMAL_1 = 1;
    uint256 private constant FORTUNE_FILTER_NORMAL_2 = 2;
    uint256 private constant FORTUNE_FILTER_COSMIC_1 = 3;
    uint256 private constant FORTUNE_FILTER_COSMIC_2 = 4;
    uint256 private constant FORTUNE_STYLE = 5;
    uint256 private constant FORTUNE_BACKGROUND_NORMAL = 6;
    uint256 private constant FORTUNE_BACKGROUND_COSMIC = 7;
    uint256 private constant FORTUNE_COLOR_START = 8;
    uint256 private constant FORTUNE_TEXT_START = 9;
    uint256 private constant FORTUNE_NUMBERS_START = 10;
    uint256 private constant FORTUNE_CLOSE = 11;

    uint256 private constant FORTUNE_INDEXES = (
        FORTUNE_FILTER_NORMAL_1 << 16 |
        FORTUNE_FILTER_NORMAL_2 << 8 |
        FORTUNE_BACKGROUND_NORMAL
    );
    uint256 private constant COSMIC_INDEXES = (
        FORTUNE_FILTER_COSMIC_1 << 16 |
        FORTUNE_FILTER_COSMIC_2 << 8 |
        FORTUNE_BACKGROUND_COSMIC
    );

    function revealFortuneCard(
        bool cosmic
    ) external pure returns (string[] memory) {
        JSONParserLib.Item memory jsonItem = JSONParserLib.parse(string(LibZip.flzDecompress(FORTUNE_CARD_DATA)));
        string[] memory result = new string[](FORTUNE_CARD_ELEMENTS);
        uint256 indexes = cosmic ? COSMIC_INDEXES : FORTUNE_INDEXES;
        result[0] = string.concat(
            _jsonString(jsonItem, FORTUNE_START),
            _jsonString(jsonItem, indexes >> 16 & INDEX_MASK)
        );
        result[1] = string.concat(
            _jsonString(jsonItem, indexes >> 8 & INDEX_MASK),
            _jsonString(jsonItem, FORTUNE_STYLE),
            _jsonString(jsonItem, indexes & INDEX_MASK),
            _jsonString(jsonItem, FORTUNE_COLOR_START)
        );
        result[2] = _jsonString(jsonItem, FORTUNE_TEXT_START);
        result[3] = _jsonString(jsonItem, FORTUNE_NUMBERS_START);
        result[4] = _jsonString(jsonItem, FORTUNE_CLOSE);
        return result;
    }

    uint256 private constant CURSED_START = 0;
    uint256 private constant CURSED_FILTER_NORMAL_START = 1;
    uint256 private constant CURSED_FILTER_NORMAL_CLOSE = 2;
    uint256 private constant CURSED_FILTER_INFERNAL_START = 3;
    uint256 private constant CURSED_FILTER_INFERNAL_CLOSE = 4;
    uint256 private constant CURSED_GRADIENT = 5;
    uint256 private constant CURSED_GRADIENT_NORMAL = 6;
    uint256 private constant CURSED_GRADIENT_INFERNAL = 7;
    uint256 private constant CURSED_STYLE = 8;
    uint256 private constant CURSED_STYLE_NORMAL = 9;
    uint256 private constant CURSED_STYLE_INFERNAL = 10;
    uint256 private constant CURSED_CLIP = 11;
    uint256 private constant CURSED_BACKGROUND_NORMAL = 12;
    uint256 private constant CURSED_BACKGROUND_INFERNAL = 13;
    uint256 private constant CURSED_TEXT = 14;
    uint256 private constant CURSED_NUMBERS = 15;
    uint256 private constant CURSED_DATE  = 16;
    uint256 private constant CURSED_CLOSE = 17;

    uint256 private constant CURSED_INDEXES = (
        CURSED_FILTER_NORMAL_START << 32 |
        CURSED_FILTER_NORMAL_CLOSE << 24 |
        CURSED_GRADIENT_NORMAL << 16 |
        CURSED_STYLE_NORMAL << 8  |
        CURSED_BACKGROUND_NORMAL
    );
    uint256 private constant INFERNAL_INDEXES =(
        CURSED_FILTER_INFERNAL_START << 32 |
        CURSED_FILTER_INFERNAL_CLOSE << 24 |
        CURSED_GRADIENT_INFERNAL << 16 |
        CURSED_STYLE_INFERNAL << 8 |
        CURSED_BACKGROUND_INFERNAL
    );

    function revealCursedCard(
        bool infernal
    ) external pure returns (string[] memory) {
        JSONParserLib.Item memory jsonItem = JSONParserLib.parse(string(LibZip.flzDecompress(CURSED_CARD_DATA)));
        string[] memory result = new string[](CURSED_CARD_ELEMENTS);
        uint256 indexes = infernal ? INFERNAL_INDEXES : CURSED_INDEXES;
        result[0] = string.concat(
            _jsonString(jsonItem, CURSED_START),
            _jsonString(jsonItem, indexes >> 32 & INDEX_MASK) // start
        );
        result[1] = string.concat(
            _jsonString(jsonItem, indexes >> 24 & INDEX_MASK), // close
            _jsonString(jsonItem, CURSED_GRADIENT),
            _jsonString(jsonItem, indexes >> 16 & INDEX_MASK),
            _jsonString(jsonItem, CURSED_STYLE),
            _jsonString(jsonItem, indexes >> 8 & INDEX_MASK),
            _jsonString(jsonItem, CURSED_CLIP),
            _jsonString(jsonItem, indexes & INDEX_MASK),
            _jsonString(jsonItem, CURSED_TEXT)
        );
        result[2] = _jsonString(jsonItem, CURSED_NUMBERS);
        result[3] = _jsonString(jsonItem, CURSED_DATE);
        result[4] = _jsonString(jsonItem, CURSED_CLOSE);
        return result;
    }

    function _jsonString(
        JSONParserLib.Item memory item,
        uint256 index
    ) private pure returns (string memory) {
        return item.at(index).value().decodeString();
    }

    bytes private constant FORTUNE_CARD_DATA = hex"1f5b223c73766720786d6c6e733d5c22687474703a2f2f7777772e77332e6f7267052f323030302f2022095c222076696577426f782026053020302035306003105c223e3c646566733e3c70617468206964201e0061202c4007134d35382e34203133312e34632d322e352e332d34200302322e342007003720030b352d2e322d312e3720302d332014200206352e312d312d3520070032200302372d382023400340260038200502332e3620412025036131392020024089013120405506312e3920372e336003401500302015003820290333632e3620720232203140700320322d36204202352d3120094015408e0232733220380031401d012e36200301356320920332202e38204220170020202f203f2017602302342033201e400b003620070033201900312025003460394025203120f540074027212420b040230032207f401b02362d36201902326139200d400340aa0030608b00352079002d2015208520ce02352038200721240520395a5c222fe103600077c16001323040f2053133362e3163203220a2204801362d206b003340754151208c002d60160039200a4083414a40fb218c202c414c218a21742001200d4042201e218e21302124404d003820af403d0235613720e5400320b120014063013463205c2063202d219901203420390039213b20e620030032211621722126401b0031201160512007003421464025801f0038201100382027415a003320ad200e41b32054209b414521592007400f01352d206420d2414b20fb20e120794057402a42030032e1072c0073c12c20b2006320252095219a20bc003421700033206c20732003409100362011400f20a52064013120210a0235203620790038208781e1625240ce41a820b52073402b0033202440984026003720152032210f0036227f003822bf4025412561ce20310033201b416a4186401b403d40d261b0218f20ef42d042d8219960810334432d35209d003820862025207a0320304830e007ea0052c0ea003960c7003421aa007321d121206005200902762d3120a00163302084412e41ae4159003120b00432483834612006210b003221dc20014014400d017631237600632368207e20334012201a003140070068408fe00435604a201e0432762d33354036203241df606a4032401b01683120e500612176406620cba04d03563332302067216e21d54227210801326c20fc20204268237123f5223421e62060003120df202e21282124414b200506762e315a4d3838406a013133607c40e722354076032d33682d223420af807220e3c0e50176372061404b40ab420360ab20772116003522360038202a200c20cc408c204940ad013133e107810059c18101313224b6022033322262e001e740a620d0203c20fa234e200520562001002dc0d121f8608540cd444c41b460070061200540292044401b04315633333560de22882518215e401602396c2d21ab42a3003620e4205e2003205e6034003321fb22406034212824934003206a201f20648081214020400037e0006d203a20f001326c615021782007210c803280ce208f625600364207a0cf415d2070006822abe004132017007620280036e107350050e1003501353922fd0133322416610641bb416f4254203c042e3148313440d96198209c2001214c600d40b7820de240a4013231e007bd406622b9015a6d22f620fe22a3614e40a6e2026221c540a460b040a2c0a4e21163006840322158462f2064e217650054e1002f0038208d22e924d4c389e009754283614d205721e961b040076098400f6011400901762d202be101b2415b6179c05b616840362250200d4003007624af205d20b10037422a259d6018046831382e39e1033d20fd60282024412d200f403f4005e2070c0041c0dc003227df64c32151003022cee00e7d0032607d0038205821828024400700682562006121a02017c6af224b20e5013263201e25668005602c200d2007200625a1410e2647002d226a01393967542107212520f2400520030076206580c8405120c24172409c6151600f206960072017e004f66015207840196155241c603a20642001601a401e653b003960d860644013404c4007016835e40239409040e201346c2203274201376323c924ca208100352005244e0276382e219f200f4176c07f60ad22c501313020f1003228df269020f202302e34e301f9210520320068245ee10d0525a46057417940574053600321790038e108794898e5082d0053e100ea003940bda1ec2603207b214c24d221744176e0009520ef400f0068407c209f21332074202d6080411d02762d392349a0bc2075003320142018006c45f7002d204821772032205c2001416a201b403423d58519a16e2023201902683136e00379a001803a200d02483238e105bf6330403ae300e9604e2011401560030068277f0038e000bae2052941c2815220ba4035208220222007e307230045c13800332530202100342709413820de6182a0a3203d200323a3278920592055608f20132033601b013168216d241920302319415e2005400d2013642d416e201121d56123e00460e001ee0039e2100b615861cd205621bd204ae102cd414520832922270c206740032057e0025927ae811220916112202340bc0032a202402f209d405a2005204c203d201560bb205e8013e1073e0055e1003e013330203102313230236c211d2336211b003423134978012e38274d432020c30036201e20202a104a90214d4021006c203d29c600302116207a2078207a208222800073204a207b4a3e200f024c333242de01393720442018404822ec205f2a6401346c23e82be90137632087201c29d98017042e384c33352034272ee00d5d20402860284c2084002020840037e007e5004fa0e5026d32364059003720c823e340832337231825182120003920f101336c2269264900632132401d4019430220dc2852258623372099c0e020bc20b721bb2033236b202e42b0208c204a2014015a6d226220f12648400e20034038407120516152215b4720202b2003201a401c20c4401c20100231392e426741e541cd4001201b2071218c407040a12012215e402d203823de22612188e107010075a101014d37409e0134372681016133203280742031217a28ed2d74003721d7404d40ff254f260b20936127400b006c200a201e013161219521b34a0b203e20212d2d006c207f013120401f006340d72145200e204a202f01346c200c2378209b259521af28d62004006c212e264120f02aea469b2231222c400d20f12003013273201321232069209a2063212e209320542058003641784171203f2092217e2027260420052e05604440042e0441152086202521f923a040524a1c20bf601825ec216a201f400480d1406b263f60b72f386093210920042ab6209b01387620f0002d206e2627207100206004603a204e4b9440b041916107213f4068402e4004201020b9202e204d20932022e201d9214e2038228620950076283929e600204003801921a32202e3006320d320ce40c7219e415c2d242006213a20102095200426f4200f223220ce0035e207160072e2001621ad221624632601202b2031216a2088262920bd253180522020201b0032802120d3201c013868208220cf20cd8004201e207b20ba003322b840e520d2225c00392014a027211720200036614741b66037207021bc203a436401382020d24001406d206742992ad5214d20f44004408e2033201424502003412022da20b421ba23dc012e37413c0033297b00206004404c413e213a44e12039218e273b202960eb612b419742e62046201d209020fe20b640f20035208a802430a92034003342bb20652074400e20392c100061267d2eaa4004806f222720a82506600380132232241970c70666696c74657220722a325720100b65476175737369616e426c752018006e32430c536f757263654772617068696321af0a737464446576696174696f401e013136604a002f804b2042e002530062e02e530034e0055204636c697050f200d30068405472e272d920d400683301007620030248307a8038c030e0073a20be2012066972636c652063533e01323533360220637920e602313633200a00722009013738e0064509222c223c72616469616c2105046469656e7481320078203060460131352032804602323535200a4046805b0067a031085472616e73666f726d206008726f7461746528343520580029202dc02303556e697453fb0d7573657253706163654f6e55736520200a7370726561644d6574686f40f3067265666c65637440cc0a73746f70206f6666736574205840cc4011042d636f6c6f408302236665400160cf4018e0012a00314056203ce0012a05656565356432602a002f40b4e001ed6100e103d70066203c04776964746820730331383025200e0468656967684083a00f415d012d34601a415da00a8044e00fe7223c0a6554757262756c656e636581630071205b086261736546726571752016404c40e6086e756d4f63746176654130417202736565411b215220310374797065209b026672612023036c4e6f694146002f405fe204dfe206ca003220582024c2ca204a033c2f64655551057374796c653e357c007b419b022d7365417f093a6e6f6e653b706f696e2344022d657622170073801320e6046c3a2332624001087d2e627b6d69782d6220d410642d6d6f64653a6d756c7469706c793b74421400694348063a31737d2e747b6154063a34313070783b8151003a35f6200c05666f6e743a6920cb01696334640270782f23f61035656d2076657264616e613b746578742d201d15676e3a6a7573746966793b6261636b67726f756e643a2323063b626f72646572809f05726573697a65800b622ae000ac013c2f80ea40fb636340ca21490575726c28237842ac047374726f6b415c0523623561613923e2e30f87e0074306236364633366372030e02143023c672043cc002d408bc08600682086e40401022d31306403025637356402203201617342170062200b20c0219ec03b0066203b2055404ec0b60039603b2f9be01e3b012f6760d900722381e300040135302338e30103800e6302436742b36008208b006c208961f60270617222302035e10a0c8012002d620d202f0031229720d3e10a064051e002dd006220dd012072407745950120724078600961d420498204002d43de0275733a24b4210b00678368006f2030e008630063405020b5e0026300672012e50644013439403b806cc54400384110203940ef00232209606a213a003c2503006522a6024f626ae1034022f2204382f220a721d0200e40c800344008405a0133364009006f22f003666c6f77202303766973692354408d42fd214e0061f9123d304206392f7868746d6c20580063a21f217e61cb002fc04020a2e0049f805a8088003540d140890134384089c1526399003739820331367078e3008f00204051042d616e6368235c002023f9e00369e2037f213c27b20132382cba2c0f288027e7337427cf2bf829992971023661342ce80020600423c928460231362d28904a41284c3030503440032af02829483c0035286600322dcc003636b2401320346a6c202168330038203d04316131312020026053382f2c2700634b1c48a24e6c4892013461209901332060046027012d332938012d352a35401400398004601901203220c9062d38322e3541372e4500206004a0192d3e20420037404c394c400480180036511a0034400400382064c0622cb1209800302d6f5aac48e2003920e8578b20c5202f209020a128f94cfe2118200b2d5449c62a8e317a201f409f2051202d2045600734ed405f00322131016134204420dd2001414b205931a7217d20672d390032291e297b2d512aea2ab2006d2023003929b800612aa338e94004203721a6205c01313521b720134002404e00302008218000372b5620094002401301302d201502312d372069025a6d33204a012031201000374ab72e76404729a1217621fe52ff41bb207f203129da35cc200a00372ee42d93411740a82a3d003720192b9821194100204d2092200d200320be20052dfb40d02dfe4143203d33582dbb21470036613022062033201320a94c6920862a7a20bb2b5d002d20012010215f005a63b6e5012d34df2148202201613640c6600420df4146202d0120332b9e2adb0036209542442e0e205d208b204a205c210721c5206220cf01613622b100206004403f21372021013338630422b620ef22e422a522482190608c212120102b2e210b22cf20232b6a20552320002d20104012003820d00037414c21f1214525db2e6121c232d5211900312361417b20522118222643043a2a200d4c1d211920a9604d01376c212d5cfa6fa320642022003720202b8e40332177201020052014400d228020074177204e5044226320d00036200b20fe2026222820032060200721844206002d23f73c4f20f6006341882142218b202c229f2f16202b4058402200333b0b220401613322d0241c20012320207920e2409d20cd40102146439943c441e34171441c212b4e80237360a2202a2cad200e00324026ad8d0275736564e001353944d644e001313047a40368726566256600235e43007448a825194abd077363616c65282e372607263d403de00229a01145b9022d333749974050012d394706c0265d33e009502151412a0031e001566044013530465160448614e0184542db0032e0054500354bd2604401323245c5e01543012e36e0013de00229e002da003646f040930034e103285cdee009d7e0034d40d1003966e9403c00382d39e00060e00e3c0035e0018a403c00324aa2603c003460d2c09ee01d3d0036c18f013434e1038fe01d3c013334282e607a0131394009e0027a2119ed0354013138411e880f00354120497d207ae00626604560256d84e00d24013431e0004b0132334209e00e266225604c0039e0117100374040602480a2404b8e6ae004be60e8602601323020b660262007e006be3b1a201b802668a4404d21d12026e5012f003625780020f611134436f60f13401b5613f404720231203230af22df24f72428002d60113d18003424eff307e32308200300763655403125b723fe2052200340180031d60f45c040464050600335e8003460328064246d8017860be303ef005260ede003113d7420ffe003113c50e006113b32e006113a67a01142e301313521450020c25ee0096338aae0032d003725e0e0022fe0096f37a1e0122f807be101b1013432295681b2281120f926b425ff616a329a54082c6f25f8214e2163290f212720070068278fff09b4416d00315d0f203521804035262680354007fb0dce6054382a2700e103fd002d2188357281b024e521b627655ea9331f205d2657201226446007362d291100632673401b484b2018272901376c266920d220ae0063260b20ec20563255281b012e31e0026e35d756212987205e2889265b2720328d46c4266e204d6234403e00203a69209946c620bd2019c2693e640039e001534814e2014581eb4344c1ebe105d9022d3239204821da452b2982e0032922670020e5036ab151012d39220ce5053129c72872202e4045013131e00344004f2015e00b44013738e00642003464aa404028682034c0af58bce00b4000313fb8e00786603860424a33e0034522e1e00c450134308086e2009b026d323321100120352a46290221ce42a047c828c9621d425a01386c20182178366321872c464ac42a05200e401c28d7419fa03a4a6521d648c5482d375d003720082be139832018203f601b48ba402a0038423a2c96012e3521ec223341fb217022012858002ef60142891d2015224040b128f880aa4087e003aa2034292728db28e548d9423e201f2aea403720b44255a06820752019606840fb22c2609748e9406b0036e20158c19e21dfe302f885cb6181013337e80304e10e7f0032e806893a9a21a8603f0134354694c06624cfe10bbf2b0be20247c02c22322093e101d2003329d326702119216c24422bad20f820d22011834a218f2178003220203b00e3004b41642194216021012b0fe0011820162df2417b003223e7215e2b912409422523e14181601e23d14016400f2230200f2017006c2cf320153b8821df223a43c5205b22384ad201326c20220120398258244821b42184200a20073b2100344e2701313442590020204e20522056406a4225776ae002a421c96690006c2b9e01322d36d1e000bf244b2051202c6067406520a0204d4283379c40a1249220d2229b428a22be00342c2ce40657242e436261ad00366ad7c180260de10bad0039aa31e1019900342159374a227f607f003525f6219520f04134208f5882209b40e900382f3640e95a914ca500372f742005210138225847203321cc200121b220034f30205c2004216420ce20fe00342bbb0020600481db4c4739100038210b60048015210a4c6c38a3217225f323cb20042186208e4059bac921dc208c211801413420a000206004404002302035203f01373139dc201725cb409020273e332051f9001b21b6404f215b20012d71245b216d20eb00384db50133202db540bc20012c5d2db24ff821e44004201320ec227722b4265e4010602b204cdb4a20b90161383db600206004603022c020fc20d12272208a24a0207044be21f0200c217b403620a32ef226b08135218e20d5200e201b002d20704002202220fb2041006121bd20524004606122a200332e4b0237203921a18004c017312b47132035215d0161322d1920cb60056021201d4d7f0138203fdea004801780b32381209001326120a6a01740a2279c202c4003802b002e47f83f3d20aa40b220623ae42028217f2369618d2164221a21644dad413e281f2da820036063204320e520df2008232e20392237274f211c40b7200740622071405d2026210f28aeef09c03170420222c83a9e21562f852162620a2170e50088418021e5436620d9205023a64095200320aa2900205e208320680134612691a0e620012045212ea00f201f2aae2031208e204820da20a0006141864003611a219844e821ab200180112062003643fc22354024209d207c203d21c2200122124005c2e9201924e1006c209d206e4106422b2013207420b7213200392006003942cc0132682338206c2049200422cc20662f864008265a00613284236a400440852f4c20522210269821b24001214c204a0031407e20075f6c21212133200c201022e1202420832011414d402620ed61f320a4200a407621a52436e402abc4953f1e261600752f89c0113d192011e4018e013130409b013437256520500134612204301e4074407680ad49a722b621082007600520cd41de448e809842b120bd002d24844199e0052d204da02d20c4013761309c003850a182c532c4202e32a80120322206202a200133c0203420d922c520942130289b21d22a8923b92038208525a60068200b66d82044202c2068207f23a801366128cb003448d041ed2001002d22212207c00d413453dae0010f268d4058223022bb2083215c20c4600501356122db227d4004204a209b435726ae201e211a819921182146201020b4200b61e2200602613133215729374005803c25bd002d270901336342d4202720b1205120472003423b46be21d02047254681fd205a2136209c42af20a22003413a2040411220380038212ee802a74b00459b2691c1f58207e100f5024d3132416043af013376233a3233210d400460a4257e2066210923d4206440b1200a013573238820f560e1363ba13e20862012631e20bd210e200d20fb23a20073201120e3200a20be621d21ba006320d7633c445721f3205c003226cc205120f221c2430c20215e5ea0f9200a204441fc208e203a2016205f404020b4205f21b8200640ae22842082205124ca2004828441cc202f003324b5455460c22047003143992102400440f468df2f052036602e41cd21b920c3404c2060470420012f10200c408b23034009203021c5207620c3408f66d84005012e398a3ae102752d792136652523c920fb20292ac2203c411b20dc203500372005201822822007415a205c20b8200920010032233c233a2079200120402331215240a9202f40f2214720082425202d267643c94003202d22b822f723a80035218a219d201d280121014004801f220d238c27b0204920ca204b203220e040b5217525dc2003209a48a961a843ef422b253c2dc2257d013476206303613632202002805300352071003823c6220a20ab40952165611e206d202321d460552005415e207e207346f3207e20836226216040924c342155201469a04014006c432f223e203d212d203a2025201f2362012e34258421dc600f42c5600522a7200c206d2021207a201040832001002d20a0a0022011401c42b5228c016131208540fe200121346075a645207540553607e50753437d61e76cfd425540c421be202f617a60072006207722c6209e20200031e602f12015212c45490036413342f120aa200a82e3291c200f0234613120a0440a212d210d003945ae006c201a230c209a215b382e213527ff200120a720032da9200f403d41114334243a204b4091444a2250202141a0203a51ae200b20198001405281662041002e2f8020570020600440822a05204221c8006c2158432e401620fd20042018274a403b2e02206d410727b0209800206004403c471a27f24754205c0038253a42208005201d20e122ba224c003128600261313020922baf4005401c4644003922e940d0204e415241cd2087229a20092141213b27dd42412190200d238820ae242d39884059221b24f5003622c823642044400320582001212b218d00392048204301336120cd4303200120ce205c43c82158006139800136206004201a201c20ca002028e9204a2028808f2005201d20042038406f2159205942264113860b2579022d33682130202e200a201de9010a203a2ae1006c22420061e9000d20cc4056b19020e740552167453420a920ab246a400520db206f202e00363b9f202138b840052055229957c920113008219b6005601723d200362d46003623c022a220a121b7204142d623598056207d22862027229643b82019216320b5610f40f02001209843985250402920642050609567d140964de12024205921130039393e2061220f013461211f249a82e7239a2064206100634048206a240e229428fd2043204720a4408a215c0076234f0132202002203440e0207321e62548209d419621c320b1002d20862011200e20406002217220d8419f2c59204e201620f42060209821e300202002605120848f5820444074811b400720ca405b245020578054200520bf201945512b89216b3b6a0261333920e260044052401f410823a32024616c610e224322e720a240a422b0002d20ca20bb2007205f20c1200820b4202021828002003743432184808e849e00752a0448190131302079e8111a026d3138241124bc34ac20c2208d60883cdb21054cf920c72001220b207d20a0c3e620a229a32b10323e219a20fc20102424408240cf41f1ef02a820b24019402a414f203f211b2cba2012202a2010203b2155202626ad41cf265901613521c00020600460826220411d245e206921042066222f200a482520a421092087213f208e20022025212b200520c32007400420702b54201621e84132219f204501366132ab2d28400440482e90208d445c21b9203e402a20be205f212b200a64d423ef20ae202b40742025246a4f7e22c94004204441342048259c203820582082200720050073202f4008003820782b88315c400440314078422a4d5260af40cf262d418f210b400320242058453d2151217d20262001419f4ded27cc208a45f140da201220b14021203c20042b79206d200821ea2003286660c52320202b209c23b2603c41a621ef204720242109203141482024212d4ff5a20d29dd20a024714068430c21c5885e2057222c203e20702001238d201f2016607d204b20bb422520b6604c003782b3e9013a003222b520ef293a4ab0274f422140515d5f242e203c2230603b49c32534201d204720052e132010212120102068200621ede5013f201b002d2028276b40df377b20bd52fa331349e36004815141eb20cd250b223320a8204820f7218e20ce21f7209120df84a82286204840852300202326b32143203861342119200b204a40346188219e349b405720034052208e20552063205520140036201c6068ef0149204140bb21df404522c72003003821c040bf20e4374021aa2e9c226e402141b420a8205529172029212a602720524e02217f2e0840284001407943cb002d4feb414f20a9220d4010200a0231613826184050200122d03f6f602430ef21ee2056215f41c92982e9051821c5214361c50237762e2ec340b720c820a9203522ac2001213360100073233840b122bd41192006405941cf00342cb14200203120c421ef21be5447214341ea215821d421d12005200a61d620434017422341012017200e201521054069601c205b21420061323f20772079a059213e22c42416402561f40033ec01fa20152075ca0f003780cb82e328cc20030039e101af80444f4a2131204a20a3203e205b23f5208d20b421cf26d82007303f200b2232405d216f202f20ce220c4343206f203b402621e5211b4006422d2237203323b440022207225e27390032419b20ce200120de20c0250c23c3804460d6a1a40075c61e2976fb0327f0062f004d3e2921a1438800362d5101336c445a23db25b5208d20ba20052179206120076079202d200420890076461e20f301613226e42250200161f921c10063202120e340d420952200204720a62004404b20ed4037400e613a4027613c0135682209202e203d41b42025210663296037408b2075253b2007201d2034200745152107406f28d8201a844321ab20102125403720be21f9200a408d400d2028418b425d26cd20672025015a6d2eba400b405129f9438ba2ce41b3209e006c205020082016202620b3202521b121bb6054208120092004012e3821492cae29da237920ae21e1436e2034407220cb200d20b4200920380031288a214323df8141201625e4414f20522178810f600f2076208920042065209a22f4207f600f21212dc920f0440e22f6002d207b2077205320894004201b0032f4037c2089279e20ac41e82064205a219a2050404a20fa40132140762e21232313208f2065405b205145dc207b827d201623e5407ca27b1673637269707420747970653d5c22746578742f65636d6180160f5c223e3c215b43444154415b7661722040221f687474703a2f2f7777772e77332e6f72672f323030302f7376675c222c723d640d6f63756d656e742e676574456c65400a1342794964285c226f5c22292c743d5b5c222366303977002c2008013066c00801306680110238303880080066401a1a5d2c633d3365332c763d2e352c613d446174652e6e6f7728292c6ee01269007120691f3b636f6e737420733d28293d3e287b783a3132352b4d6174682e72616e646f6d0a28292a3235302c793a3330e00916007dc03e05753d743d3e7b40fa0e613d604d20247b745b305d2e787d2ca00907797d603b666f7228402116723d312c653d742e6c656e6774683b723c653b722b2b29603d0a6e3d6628745b722d315d2c400600326006035d292c6f8017600ea01c002b40230a727565293b612b3d6020432074006e8071006e206e200d006f800d006f800d204ee0009020092090007d408c0024605800304058006580580c315d293b72657475726e20612b805700248049002420352057402e80106009e00d1301607da15809663d28742c612c722c65215fa0e303617c7c7420d20072400601243d20a7002d20b921c120aa200903792c733d61800e7371727428242a242b632a63292c7580140d6174616e3228632c24292b28653f60270350493a30c0b3057b783a742e7881a909636f732875292a732a7621be02742e7980150273696ea015007dc0a3006f60a3c09fe2029b026372652249a29e034e532865228b48ef42370d722e73657441747472696275746522b704636c61737362930062e00c1f0366696c6c201e0061403a22de0073229ce00203005d20502112182e742e6d61702873293b742e617070656e644368696c642872203581940072c0b5002420b5023d3630c0b605613d6e65772042f9003b41d802723d61435a03486f75722065032a36302b600f024d696e20ad2011800e01536522fe0064200e022f3630a060072e3030352b282e30244220090b292a28287225743c742f323f2007023a742d200502292f28200f0829297d3b6c6574206822cb40b32301076f28722c742b5c223d220c29293b66756e6374696f6e204d2202007220f861fe0065e3059d61c1006d219307312c28652d61292f21eae1010720384197439721d6062a28312d6e292b2128015b612282012a6e81d7e005160b792a6e7d29292c243d75286f2134e107a5006421820b24293b6966286e3e3d31297b2171043d5b2e2e2e2054e108820f613d657d72657175657374416e696d6140cc054672616d6528442cc0d503297d742e23db0345616368c0af034d28612c610b01292c4190848a2111216c246b0069646b23a6e20640046261736546606f026e637940a620332194e00b7f0069217b40c209296928293b5d5d3e3c2f8588083e3c2f7376673e225d";
    
    bytes private constant CURSED_CARD_DATA = hex"1f5b223c73766720786d6c6e733d5c22687474703a2f2f7777772e77332e6f7267052f323030302f2022095c222076696577426f782026053020302035306003125c223e3c646566733e3c66696c74657220696420200062202e800f03556e697440590d7573657253706163654f6e55736540350c6665476175737369616e426c752037006e20370c536f757263654772617068696320430a737464446576696174696f401e0031206e032f3e3c2f805a2042e002720068202e04776964746820460334303025200e05686569676874e0010f40ba012d31801b00792016c00b8046e045a9e004a809222c223c72616469616c20da046469656e748126007820a40063409502313538400a409402323535200a0072209e01323520ee012067a031085472616e73666f726d201908726f7461746528343520580029e00223e00fc20b207370726561644d6574686f419e067265666c65637441850973746f70206f66667365412840704011042d636f6c6f408302233838209921734015e0012720dee00627023737376027002f40aee001e7053e3c7061746880ed21f50020407d1f4d3531362e3220313139632d2e3820312d312e3720312e382d322e3620322e3402613138401e40044268201f201c40180220313940184004a01800302035204b006320420234203020400038200506342d2e336131392028e00126003420260338632d324022012d33200e003720090039404001362e206000202011013220201008332e31682d2e356131206c2051200102312d382032012e332063208300352036063520352e322d3420ac02362e372031003460170331302034404a003420a203332e366c202800324049023230202002400100312033043820352031203e80048015203904322e33203220fc0036e00012208b02352e31612020b420518069407f0032202e02312d36201302382d39207d003420956141003321060035201c40240035201e01342d205520480039200d20a0202f202b2047002d2099003620252156002d40f201386c200a2097406f2035203302342d39203f00322033400ce1074c0033203d214c02312e3660e400322053003520550238613121c70037a0c220950120302171202d206a20f9202f003740382062013368200c003921e721e5a02e80f1412ae1012d092d372e396c2d2e372e36e0052a20b74096808120ab003320600031212e208a61a40033207541164019003721ac20980133202002816e222f20db0035409a0037208d0036202a20fd212421d12096423d203f20ae20b441512009419d205d0033213e00332015214de2062221c22129e002bb013132208f21d00031206c6004807b221c2153022e376c2047213e016132216cc266405b22c9230420870035608d20f94030202c200220ae232e211520ade2049f40ec2250e203f0208c811f20324105211f204800356045231b23360020600480952089210201326320ab206b2005223e207120ed0131612292200280270037412a602c203ee0003c43162142e1026122fe203b219f21e9204b20b1231b43190031217821cbe0022a22e3012d32232b002d427b20fa40ae003522b241760038200e202f400b208f2009200b21e4200522b2209f202023b52080213a41a440e4201b200d21aa201122a4002d208900302040217f2005210c2019406242fd003222fb202ae304a0211422c240ba4337204d42e10034206842c123d32060c01e2282404620df20ad21f92157003221392069200140d80037202d003742a32103223a003320272043002021bb438f6004802a210f2064223e20a66004a0160030205f003621442071420a616720156008213021802061213122f6209f012e34209e002042ebe1049c20cf20e42045203b4132602b201640a1e105dd24b9003420a50037204620bb43f5251a0020600480902153204b2100232a8004801722d0246d4062208c00374225202a215d217e2041006124112002802a403e201744d6201d240320db21da20ff0432762d3836257a0733562d31396835332123017634201c006820190239382e205e2148209520bf22112060403e01375a265287bd27150575726c282362270f002f677080170020688f006620270077a81c013138e8051ca00f4786012d34601a4786a00a8044e70f5728810a6554757262756c656e6365806a0071206a086261736546726571752016404c4756086e756d4f6374617665490d47e202736565470d27c22031037479706520c2026672612023036c4e6f6949232776e90624e9060f003220586024004347ae054d6174726978c04a0473617475722825205c0376616c756076802ec93e2079e80c950073203268950035610d60c1800a416580090066412ea00a40e1600a6051e8052860414012002de8005103666638634a3720b84018e801540037e00c2c00612a68003680b8e0052ea9c84014e0035c0066602b40db4019e0015de00a5c0138622adc602ee0062be00b8905623332323334e02289a05a4089e908140067822b006f4169026c61734212200b073e3c636972636c65817d89fe617d800a417d003320ae4294006c222c214942d70063a04021b620c8696e4257014d32244b249e003426e445d924a7236c003126ba24b92003242523c6003223f123bc20032575200740152903201723e823954008200d20034544241f202702326131200e841501302029a6252f46bc2039201d65bf002024736400200e201623b0003223e7207e23b82995022d2e39201f206300382017494424a50031200c60732537200c244a00392077853901362d247044f120c4201d24a42078201f209320c3013320200f2080016137208040034096267120bd003520b2a4a6203b20ee20aa20eb2060203b80e024840061c02445c626300063408a207160bc400740be257120cb20c3209f20d120492003209420bc2093200b25ce20dd215a60c6202d206d25a3206a201a20dd2008401020b32003409c200d40d32724203d20124057204360e3206e218c2057205c265a2010413a2028200924ff200d409121a9200300372556203c200120bd201b255020072090200b403940034013217120272a0100612ab920982001284d208526ed20ae2019402722326031459420d22ae3203721e5205f2172202e20cc2060280b006126d4202020e1206845f300332267402520b721914013202d203320cd200d4b71203b200726894032409f205b202e2018205201356127d0206981b0209b2087409c20dd200d2267809920fc226601356120824206807e202901356c404d60822185407b226b4056006c20bf217f02613239203060044035405121db29fe0076207e015a6d2c6f0038285e003722ca210d0031623e0036210541014853200920b8202e20072011035a6d2d3720912879006321592025218b400d20092013207620912127002d214220c00038202e403c013563402a21ed202e400920050073217c405b200a015a6d26f12b9f20842042003642cb225f208522e320d02082401e20032041416f40d621e821f8221820312011022d355a6406012f67e4006400554458e40216003140b7043139306137232d207920014798415428272318206142a62921207820070061217820244026616829dc2001a0102012224d238b4003801340f720e923e5213521c120492037006c802a20bd418e012d3141a8202020d68400006c21b5203a202040012161006323e2203e44102062204101613264bb4004806822ca216c21202001401120716122403920cc20792a02006c211860c7429542dc2272240380132087205940190039e2061e41a14163253b20a22192226020b620574132200660a32272203f0132764a1b20cc219c200e238b2094213c22cf003722cfc26f20c22926203c44a3234c21642e7720b920564037209301356c43c2013276202a256429292567400520db2025207420ef220c20018011203421692075405d25322080200621ad408d221820a820110039215b6360821be2020b00322088003921280076202521a1403be102ed233e405d20484002218b20a1244ce0025d446e229e20786144422e2378407541b2202a407821200068204720fd20fb40ef21290033212f81d4003424600020600460d223da204e0036202d21c020ec205e21c24165613a20844052201721d52020202a200920612069600c4101400c407645e020304482218440132006013273205a2157217f236520744211201720b7012e336178023639202002608d226242ebe103706b93220b21712081207a20610037e6004120134337003142fd2afc201e40a481822278273b003226d6a05d209264fb4b71207c2026a1b423872351206b214b0033434c21f6003381bc43d804636c697050f100560072e305df20b700682932007620030248307a840cc030203e93ab057374796c653e33d6017b753397022d7365520e0a3a6e6f6e653b706f696e74201301657632a60073801311666f6e743a313270782076657264616e613b2b170b6c3a2365336461633961617d28e4022e6f7b80140137384001027d2e73a00f28a5e0041f8975e0021f400c06767b6d69782d622b4710642d6d6f64653a6d756c7469706c793b7452f700695400023a31734048013c2f80bd294440d7002d42ce290d6bfd00722bfd697140140020408fc019007820192a2b02726f6b4b670523623561613954a5692ae10a33211700206c3a54864aec002d215020424aec4007a05b042342424236201600683352206a00234b6e60b1b3a9057363616c65284308207f299e4056e0113aa020e0066e20792061c03502464646e01b70223320036074219c013c7233eeed010100306b0cf5001ea00fc061d3f26143610353ee81282e7f625e02563735625d21828abe0076200b204022392106618b0066607ce002450032202280450120396044017632e01f44e024be00422b794131e0029ae1020460d0006e208a0077ce0fe1150d01313120fd20c7abb2006d2039006f36c7016974a2094019e005f8006820f8e00223002e354081f8c2242bea205043c9e0073a4ebde01e3a403e611660d0006c2037c0d0f607fd37c2570d625500316da8e207c561af0073e005b6214120a4620341b4026d313752f8013138282924aa44c92c3385258607023820362788878925c6012d34291824c0258528f72bc048070034202a2033203145a3282520032520002e2a4d22ae862025556546201074984b21033661333426a60020800523ae257e25124cc42a0f252a6005201520178031287f262d20ab4062336f26652653202026214060259b28d902353920200220352001463b208727814949407e45b8262420912a1743c3205b45a72057276b20b5400446b7200b202925c8200800362030202f269620ea033161333520120020800540656a3c0120312c9a26e8800420142016298c022e33632a8a20648d3f211a270d400726ae266420b4276f2c5a213e60c9417e206a0233732d2096209120b326384042207220ac20300035284640a38005206720172053205720842024c09429e220fa207a6921204520c32072210a206c276a204329c920a621012062002d2202611726a720772015414b20206004606626b22133205501203121ba206d6005c01a3353006c40d929d4003731dd00208005601d012d3832220137202268a004801542463429207f002e320c203228e320bd4785684c209ee803ba274d4783212240c1213320de20c821a62b4b003821e80031216b354d202140db27ff2024356f202f2965200420e020e60034ec0166201320ee411b607b2c8f204d216c40932281202a00322c4d28736005202f20ca4050220b2022227720b52182203e206160052a3e21a587d7e30068024d32306c980039230f288e003235ad35ab204d200621a622032047210a207c213e235f210f200b421d4ced221f200721604007ed04a121a84082212821af2031400328f4208620cc601421b0201b2b7040a521954011201a225b006121c8222d40046088212d413b29282001801120364060202620a84003423320a221216001421620b523282145203a20a120102145202d202020e9200120d72038003322b4202f6004605c20882c742ac720380233682e4e672018804120cf003223de20c62027ad6802356136207a002060044040442c50e54238208d22b4202b831e0233372020022022202420232036443863bb20412112200323ee201f60b8402122d6224c207020072c6b207420d720a1205840ec414e211d201b6032226581e100752851c6012d93e5035c014d322a70e101f100362cd2809343ac24a2210c003221d0413180132a16208a318320028013211d206e2444200180112021209a2c1c41f3208d200321ee20aa239320c840170037200b20ae6e7220ff2213601e403920f30161332f400020600460512b22220e0120352528800480152f868f9ce001a1209d45f901376c41220134632081414a42642160407ca1502b2820b4213841d721352131200f21a720132437201f20532066204420b12b0a218322070237613340086004608360973c4d203b202b232621202057200722452007204621a6229f21f5200cc00220182013211c401d2374203f20816102003723cc20a46004606220fc0034368b21f622a5400462b24e922c52400440254ffb3b0b20a4c18640bb4bc1003442272078207e207221730339612e39215d4021809a429b200f20b3207d272820070161343b6b002060042025201b37fc20d821a0396e209d600420172019003226be003222b9234b2021205a4169214443c0200f401341500036ec00a86cf727252196200b21e8209840432049205f210941684450508601362d204ae201c5484955080020e210ce0039229c24c001397621b6006c251421a0477e205620b5002d206026c52005200723c640c320b123c5212b0076217a00373d950020600440a720d2587767d0224240ca2180219b204f20e0201242f922cf601321a141f5200800683062404140fd4005202820cd8040248720882012003127ee43bc0037456a424040163a44204044e00034211901366120fc211a2243200143574082602c2058206d2086432f40dd237120612251208d40564003033761392021d8200121fc60f6015a6d237120bb203b45910038216762e92038295321052450209d22352005236d2f980031400900632028601320662e4520630035e102cf223521d02171003681a9e60151003322372040023932768145218c204e23e5200528f12001003960f72396e900d420ad606d27a5407d209f709602326133222d401e202022a541180033211c41c8401123c5203822cb202a411c20af2095447b20f0211a340c20144027219a2024413620b5204b20113c1920d76004604d210b539200334440410a21c141f6204624322022221940c840c0204720be003720162078e1001421702127237c403121ec601e441623b32098202a209a200320342a9b201d220c015a6d21a42019277740184004408c83da20a429de21ef2045207d200440f92258002d20344018201bf5011740e0206727fd205a200a208624e92038421e40d0e1026e22060020207b26f30031214e67e3401441f0400564a225f72008607540472004201e21302022205de701ec60112043206322162418200340c540a66145408d202120cd4076408d414722552157406141af243a015a6d21ce45db006122914426615144bf20c920ef800220362008201e20fa44df247b208e2194404e40b9200c20100035201620902192436221308234208b2004229131e4230d200b2037437c6026013561c54840a424f620d52071402322b2205520c2035a4d323431a0033132682d22fd0237682d2475053335683432762005032d31307620122018200b0134762004e0000a35923d62023136682022012d396029003921802b94006880230035402300392038e0032067b803746578746505ed014d0134374d6309616c69676e6d656e742d5c02026c696e506c046d6964646c50185146032d73697a4014013234253f4047052d616e63686f4f35c0276fb0002f401be00c699a9c2e72006c2f690423636363372049e02178013133202e405ce01a786e5a0064202f45f1e001eb00396e4fe02481e00d700520646174612d2004411130a6615c4ed805736372697074dcca403c042f65636d6180162121123c215b43444154415b76617220733d646f63754175062e676574456c65400a0442794964286fe801293b40240064e012242f3c80240069e012242ff88024006fe012243dfc80240074e01224215003293b742e40d500433358222d053d6e657720442106002860c20141743dc8016275200e202cc1212034092a316533292e746f4c6f5255402f00532028046e6728756e33d6226c06642c7b6461793a225d042d646967692129012c6d20610068e004110379656172e00310117d292e7265706c616365282f5c5c2f2f672c30b3206d123b636f6e737420613d28742c652c61293d3e7b8011006ee001db0263726520b5a172014e5320af11687474703a2f2f7777772e77332e6f72672f307e01302f346a208c055c22616e696d2031005453d453224067026e2e73e005f30061c0ff024e616d20f720360074e0142f5f3c20260074e00a4a016475351e022c612b2098e00c6a20f920c103436f756e412c025c226981490069616fe009999f4920510065e00a1c0261646434a70076408a33f8007560db0172653f85046e206e7d3be200a3057175657279537571046f72416c6c21340023346401292e210f064561636828286520ca053d3e5b5b7b7421a760fa006c213320750069200f24b4002c2003003b200600326005400c032d31352c4005600d2028006420285277017d2c604374852016403f03312c313b2664002c2003003b2005e0030b202160380135352039015d2ce00d7f2063207d606a207f4007208504352c31353b6018601ea0482050e01080003220800032a080e0000ba037002e34e0e0107f406f4075208400326102012d352102003540060035a011201cc00a208e202c2011c093605be12215e0099c611c035d5b745de100b011743d3e652e617070656e644368696c64286123c704742c742e6920030164292000a34b0063a34b032c6e3d3221e10c7b696628743c6129742b3d3234a22a00282597062b652f3630292f22348370006de001362017203744d009723d742a36302b652b61202ca03c072e3030352b282e30278f20090b292a282872256e3c6e2f323f2007023a6e2d200502292f28200f012929c05b01753d20bd60500065e40085032c613d65454a06486f757273282920ad600e024d696e24932010003b20b70d613e3d32307c7c613c36297b692e7791002ed5170031657106723d283138302b2003022a632820f222ae21b400292095004d38bb032e50492f201a204be307fd62f0230b233f012c60600c42fd0728247b2d3330302a603b07636f732872297d2c2013043132302b36a0160273696e4016072960297d656c7365e00897003040b8026f296fe0077147ab024672652398026e63792075006d60ae60f3055365636f6e6420f3213180f50a31392626613c3231297b73e008f60064e00711002d80f901313980910020804201323141380235297be0072f0030e00041390d0042590c004d390b27e626f801656536b460d7a045003540870037e0094480720035e004710037402b0039e009b2e00780c0b00037e0043d60f10031206ae007f1e0073ee010bf036c69676826e8a0c0e0184780c22071007d619502737441663604696f6e4672261201287522be0069e107c5622ae20937053630302c20302213013b7522b9015d5d2860214d0b6970743e3c2f7376673e225d";
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import {JSONParserLib} from "solady/src/utils/JSONParserLib.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {LibZip} from "solady/src/utils/LibZip.sol";
import {Binding} from "./Binding.sol";
import {IFortuneTeller} from "./interface/IFortuneTeller.sol";
import "./Fortune.sol";

contract FortuneTeller is IFortuneTeller, Binding {
    using JSONParserLib for JSONParserLib.Item;
    using JSONParserLib for string;
    using LibString for uint256;
    using Fortune for uint256;

    uint256 private constant INDEX_COMMANDS = 9;
    uint256 private constant INDEX_TITLES = 10;
    uint256 private constant INDEX_OBJECT = 11;
    uint256 private constant INDEX_ANIMAL = 12;
    uint256 private constant INDEX_COLORS = 13;
    uint256 private constant INDEX_PLANES = 14;
    uint256 private constant INDEX_CURSED = 15;
    uint256 private constant INDEX_HEXES = 16;
    uint256 private constant INDEX_SINS = 17;

    uint256 private constant CURSE_INDEX_TITLE = 0;
    uint256 private constant CURSE_INDEX_DESC = 1;

    uint256 private constant PLANE_INDEX_COSMIC = 0;
    uint256 private constant PLANE_INDEX_TERRESTRIAL = 1;
    uint256 private constant PLANE_INDEX_SHADOW = 2;
    uint256 private constant PLANE_INDEX_INFERNAL = 3;

    uint256 private constant ONE_YEAR = 31536000;
    uint256 private constant TEN_YEAR = 31536000 * 10;
    uint256 private constant MAX_LUCKY = 99;

    function revealFortune (
        uint256 fortune
    ) external pure returns (string[] memory) {
        string[] memory result = new string[](FORTUNE_ELEMENTS);
        JSONParserLib.Item memory json = _decompressData();
        string memory echoPrefix = fortune.isEchoed() ? "Echo of " : '';
        result[0] =  string.concat(echoPrefix, _fortuneTitle(fortune, json));
        result[1] = _fortuneText(fortune, json);
        result[2] = _luckyColorHex(fortune);
        result[3] = _luckyNumbers(fortune);
        result[4] = _luckyColor(fortune, json);
        result[5] = _luckyCharm(fortune, json);
        result[6] = _spiritAnimal(fortune, json);
        result[7] = _astralPlane(fortune, json);
        result[8] = _futureDate(fortune);
        return result;
    }

    function revealCurse (
        uint256 curse
    ) external pure returns (string[] memory) {
        string[] memory result = new string[](CURSED_ELEMENTS);
        JSONParserLib.Item memory json = _decompressData();
        string memory echoSuffix = curse.isEchoed() ? "d Echo" : '';
        result[0] = string.concat(_curseTitle(json), echoSuffix);
        result[1] = _curseTagline(curse, json);
        result[2] = _curseText(curse, json);
        result[3] = _luckyNumbers(curse);
        result[4] = _cursedArtifact(curse, json);
        result[5] = _deadlyFamiliar(curse, json);
        result[6] = _cursedPlane(curse, json);
        result[7] = _futureDate(curse);
        return result;
    }

    function fortunateTraits (
        string[] memory revealed
    ) external pure returns (string memory) {
        return string.concat(
            '{"value":"Fortune"},',
            '{', _attribute("Lucky Numbers",   revealed[3]), '},',
            '{', _attribute("Lucky Color",     revealed[4]), '},',
            '{', _attribute("Lucky Charm",     revealed[5]), '},',
            '{', _attribute("Spirit Animal",   revealed[6]), '},',
            '{', _attribute("Astral Plane",    revealed[7]), '},',
            '{', _attribute("Auspicious Date", revealed[8]),',"display_type":"date"}'
        );
    }

    function cursedTraits (
        string[] memory revealed
    ) external pure returns (string memory) {
        return string.concat(
            '{"value":"Curse"},',
            '{', _attribute("Cursed Fate",     revealed[2]), '},',
            '{', _attribute("Unlucky Numbers", revealed[3]), '},',
            '{', _attribute("Cursed Artifact", revealed[4]), '},',
            '{', _attribute("Deadly Familiar", revealed[5]), '},',
            '{', _attribute("Astral Plane",    revealed[6]), '},',
            '{', _attribute("Ominous Date",    revealed[7]),',"display_type":"date"}'
        );
    }

    function _fortuneTitle(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_TITLES, fortune.titleIndex());
    }

    function _fortuneText(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return string.concat(
            _fortuneLine(fortune, json, 0), ' ',
            _fortuneLine(fortune, json, 3), ' ',
            _fortuneLine(fortune, json, 6)
        );
    }

    function _fortuneLine(
        uint256 fortune,
        JSONParserLib.Item memory json,
        uint256 offset
    ) private pure returns (string memory) {
        unchecked {
            string memory join = offset == 0 ? '' :
                _jsonString(json, INDEX_COMMANDS, fortune.cmdIndex(offset));
            return string.concat(
                _jsonString(json, offset,     fortune.at(offset    )), join, ' ',
                _jsonString(json, offset + 1, fortune.at(offset + 1)), ' ',
                _jsonString(json, offset + 2, fortune.at(offset + 2)), '.'
            );
        }
    }

    function _luckyNumbers(
        uint256 fortune
    ) private pure returns (string memory) {
        if ((fortune & GENESIS_MASK) == 0) return "?, ?, ?, ?, ?, ?";
        unchecked {
            return string.concat(
                (fortune.at(0) % MAX_LUCKY + 1).toString(), ', ',
                (fortune.at(1) % MAX_LUCKY + 1).toString(), ', ',
                (fortune.at(2) % MAX_LUCKY + 1).toString(), ', ',
                (fortune.at(3) % MAX_LUCKY + 1).toString(), ', ',
                (fortune.at(4) % MAX_LUCKY + 1).toString(), ', ',
                (fortune.at(5) % MAX_LUCKY + 1).toString()
            );
         }
    }

    function _luckyColor(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_COLORS, fortune.colorIndex());
    }

    function _luckyColorHex(
        uint256 fortune
    ) private pure returns (string memory) {
        uint256 index = fortune.colorIndex() * 3;
        return (
            (uint256(uint8(COLOR_DATA[index    ])) << 16) |
            (uint256(uint8(COLOR_DATA[index + 1])) << 8 ) |
            (uint256(uint8(COLOR_DATA[index + 2]))))
        .toHexStringNoPrefix(3);
    }

    function _luckyCharm(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_OBJECT, fortune.charmIndex());
    }

    function _cursedArtifact(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_OBJECT, fortune.cursedIndex());
    }

    function _spiritAnimal(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_ANIMAL, fortune.animalIndex());
    }

    function _astralPlane(
        uint256 fortune,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_PLANES, fortune.isLegend() ? PLANE_INDEX_COSMIC: PLANE_INDEX_TERRESTRIAL);
    }

    function _curseTitle(
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_CURSED, CURSE_INDEX_TITLE);
    }

    function _curseTagline(
        uint256 curse,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return string.concat(
            _jsonString(json, INDEX_CURSED, CURSE_INDEX_DESC), ' ',
            _curseText(curse, json), '.'
        );
    }

    function _curseText(
        uint256 curse,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_HEXES, curse.cursedIndex());
    }

    function _deadlyFamiliar(
        uint256 curse,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return string.concat(_spiritAnimal(curse, json), ' of ',
            _jsonString(json, INDEX_SINS, curse.deadlyIndex()));
    }

    function _cursedPlane(
        uint256 curse,
        JSONParserLib.Item memory json
    ) private pure returns (string memory) {
        return _jsonString(json, INDEX_PLANES, curse.isLegend() ? PLANE_INDEX_INFERNAL: PLANE_INDEX_SHADOW);
    }

    function _futureDate(
        uint256 prediction
    ) private pure returns (string memory) {
        unchecked {
            uint256 future = prediction.dateIndex().scaleToRange(MIN_DATE, MAX_DATE, ONE_YEAR, TEN_YEAR);
            return (((prediction >> FORTUNE_DATE_OFFSET) & FORTUNE_DATE_MASK) + future).toString();
        }
    }

    function _decompressData(
    ) private pure returns(JSONParserLib.Item memory) {
        return string(LibZip.flzDecompress(FORTUNE_FLAG)).parse();
    }

    function _jsonString(
        JSONParserLib.Item memory json,
        uint256 index,
        uint256 at
    ) private pure returns (string memory) {
        return json.at(index).at(at).value().decodeString();
    }

    function _attribute(
        string memory key,
        string memory value
    ) private pure returns (string memory) {
        return string.concat('"trait_type":"', key, '","value":"', value,'"');
    }

    bytes private constant COLOR_DATA = hex"E32636E52B50FFBF009966CCFBCEB120B2AA7FFFD4007FFFFFE4C40000FFFFB6C1CD7F32A52A2A800020DEB887702963960018007BA7FFDAB97FFF00D2691E0047ABB87333FF7F506495EDDC143C00FFFF1560BD61405150C878B22222228B22FF00FFFFD700DAA520008000FF69B44B008200A86BBDB76BBC8F8FE6E6FAFFF44F00FF00FF00FF800000E066FF19197098FB988A9A5BB8860B00BFFFCC7722808000FF8C00DA70D68B008BFFE5B4CCCCFFCD853F01796FFFC0CBDDA0DDCC8899E30B5DDE5D831C39BBCD5C5CF4C430BCB88AFA8072F4A46092000A0F52BAFF24002E8B57A0522DC0C0C087CEEB6A5ACD6A442E00FF7F4682B4E4D96FFFDA03FD5E53F28500008080E2725BD8BFD8FF6347FFC87C40E0D0E4CFE97851A9120A8F008064E34234EE82EEC682EF";

    bytes private constant FORTUNE_FLAG = hex"1f5b5b2241206275726e696e672070617373696f6e2072657665616c7320796f750b2077696c6c20736f6f6e222c8029147374206f6620656e6572677920696e646963617465e00b2b056368616e6365202906636f756e746572804a036c656164605801746f605140250167652048092074686520627265657a400de00756602b00646050207d0664657374696e79202e20b6807ba04e1564697374616e74206d656c6f64792077686973706572802240ca604703666c6565203f00672072046f75676874207de0036f02736861a0280967656e746c65206e756420a20566726f6d206620ec2020016f77e0065204676c696d6d20e3209c06686f7065206c69205700732060046520776179c09d03677569644077601de00646e101640568696464656e218d017468e1088a60bf214300704069026661692022e1020403636c6f732084a10b046d6573736120b8215b066120647265616d200ae003e8e10010026d6f6d20e9405205636c61726974213841f66059e103ac802701277320962143016374422ce00552e1013b0372697070213b207c41040a636f736d6f73207369676ec259e0012a20b300652098067069746f757320227c208b6080046361757365e0038004737061726b60a720ce0274697640aa210d0064818da0f7047374726f6b622721bf00692051e207cf6144e00125066c75636b206177214c01732c606c407be00623e001a2e20b7501737561b1e205cb00772119201901676722ac809f006d42148058803001696e211022094070621ce004ec210d01636840ec22c5016d73e00ae801747722ed204440b421f50061216ee0046fe101618029229c62bf606e4136403820666092017669e30cfb601b20804346406a41cc0273696c23d50065e10c570d6e206f6c642070726f7068656379200800652271a0ff4077404f066e20756e6578702240036564206a20bb016e65a271016d6121b82476602501636982080173642378027361798144e000d4835d006d4102006320cc0072e105bc0043227006696320666f7263249d218a64a7405be00041004421984445c21e02746861239424eae00425034563686f204163fd007423ce046675747572210323d520a8e0004c01456e63d425170064a3260373206168229aa05e602ca100004644440268617324c722c720306079404d40206082210003466f72742127002020c7006c20800175708098002c601fe0002d202800498195006e2103a09de204c6a01e2330016c6d420201706f25e50262696c22ca8027c296024d61672131224e40e602616972e2054c409a206c014d7921340063200d006e2374215d0265746520b2e000c00061211a0461626f757482560053214d002c247d4162006c23b020b84047e2067c80250074215c03756e697625aea2a2452e81b262a30054202000612165006ec4ac403104706c616e65216b4061c459406220aa402f016261201f22aa22fa016e6161b8c0b3e2054d602b02727573636f02612066245d006822f0e3044ec127402b0063262240542025406e006460d18052e000ab2023036d206265407060270373746f7222c8e40311e002a902636172204080c6202e228a4210c2ed607300652207017469201e03626f64692212610c40d0602ae00177006845bc20f103646f756222d1e00370e003c3006582d92028016c61470620ef21d5e30927407b01666920c4202903616d6269e10fc66027036c69636b2048402a20d2016e644493e7072e8028016f7740250274696d21a5e701c7e603c24027026d7572200260a5416b22e326f2e010a6026f7261240b4112026573652121e10047e10268007028e5471620a2e0077ce1004201707581dec868403e80a5e1056a047175696574e103e3036461776ee00df0e70432209820da0269727221bbe1049f4068002280f904726879746863b1026c6966223d0075e60249e20316e0012722300172202473017274206de30c0e007224500073247a0076204f00702724239c203460756456a07a007321b88172419d41bf602643dc811144b3463641a101736345a6414d20d304756e6b6e6f2102c1a18312e003ae200b0064493ee0063080b06066e1020301736f2171a0294472e30b660273706928b20073e600a4e100f32069e1004c2a152244817824d92a922465288f00756154e00876602da6bbe00150e3033c0074249a80c44122411962c449dd4151e1001d24736b5ba0c4007022792076e30011e003a3e0062a406120f421996059e0055602756e662767406d20580261206d2595016572e601ca4082e0035a037761726d2337202b006b21992203e003834063a1f80377686565643a24b4667c40932346c1eba80880f821ee6193c70aa0470059215b0420617572612b1441e800774aa4402ce6027880516029036465657024d64572205720a8006e60bdc16ba02324f72bef80f527e827ef60fc40e7609c802626e3006d20d9a1d4e20008e003984653413641e2212222ca20cc838f6b70e0014d63482aeb207c44fce101b3404e2299632d607701696e2d0d0320766f692668e10021e0007dc187a02a017475a5408953e00228405721876027c91521ad659081d26114e0047aa02720a6a406a0fc802fe0035144442026ad18e00826e00455252201742049a100722982493f220e87e841704055e0062e225b01697325bb21c3e40251248320ee23840079c0d640292084006447e52b9c212f83f7e001aee00458007226f14d8122ae007023b0213961f9802de101a9e00226840c80a2208dea02e16156218b247c2081036d6f76656846c0d98053201fe10183804b202c4728e106894103c0d4e00027a18ce1055ce0045201756e2c2300724af64109201b4320e10c5304756e79696583e1406b20e3e506d0035d2c5b222eed006320c800722089016163481e00722a59a00c00704c690061280b20384012026e73778028017272217d401100772b6c45f101626524b620100262656ca02c24702c96801c007528dd201c20b72fa76008026f6f7360084e2a006641da67b3401a026f6e662db08009006e2bde400923936093006325a4036963697a401e00642dc5605d00642a1540412eef80062ddf40352008006c2270203f006420be026c6f7040090069600f06696d696e697368601020fdc067600c247460a322360076807502656d622812403803656d706f81012277909120432e77600520dd8025026e6a6f408904656e7269634064026578682e844093230f2716402d2cba8318800c810e006680662f93421800668247006641472025006623c7800680ba2f3d403c25c325224018026f72678195016761618b0167726017222c006d201e006880cc2491405b0268656c410f24bb006460c30068260920242e4c27094056016a6f604342ff20172006007241de215001206745c8006c8069502b401e22406006811c036d61676e81d5006d3124201843292006006e2237609230dd404d20350172633036201a007081c3037072616960512dfc007481fc00702bcf61aa01717545c165312e10007561392910822c0272656a802e29b4407122ea00692ecc822a017265261240c60072805c29d6006b207300734229811545c94036200741b92b65411d2fde02656e67267640ac017375231d0065404503737566666134017465231b2048017472290c4155239a40d3201200754157226540db017765a32426e9201a03776f726b6379016120cc5902746f20a1dd2013006f28a2276400742c4940924011204d0061279920260163722d79204420152314016b206e5200722d2b806a401600695268202ac375201324f7695d634870f160422c5c2c26036f206164656461f74015215244d36c2c22faa174201944d92111605ea2abe001154711016f62214125c2805e6310604921b0233be00348a0450277656ca2012048056f6e7472696220cb474c006f6fc8604893b32011233322e542cd20140065449f22862695a026016563907f2029006d2172803b281a4059444a2057a013880a2027e301db2051006941d723d9606be001412016036963756c30220068479e8042217d006d20572c7821a8a013007568942f3f016c66297260272e040072406720db017175621940132524298c21e42016252200744645802e23d321ca0067265be0011323d7016f7420262777036d6f72798028007541af40590373686170807f01676f2afc207f2294a58300612ba602726d6f28f52016a2f52013209300742311229e0067e702a16057b43720d3007442d90061e6008f20ac651e23b28081006c27df404001696d2ae3007351f760402429f40157a01100732b82401831a3433f2024006980ba00652006006822bd0067a02925972972016f2028ab810fa869201240b4604e8104401200632f5d841ae004152199007480cc20e022c502646574854f2010615540cb22d6e000c9e00115668ea31ce00115007023e6a050e0003fe10120a01320a20072280d016d62a1e4cb4d201702736f6c64fe0061315e0077636c01727323ce60cd4011673b4be0e0001122e7332b22b0e002372403201536984a7a8029230a405f23678396601500702e9a22e8401868efe00015a0a322620063210281ad684121da0065d279e20075208201696f64884646a1ca007033862426605b266381a341fe22c34014c6f94014016f6644b628f2749e809a36fd25814029006b2396601321ad421d412652a380138eb52013e600dc20280369736b20253b28f20274616b2279802a006f2faa20280070863f202600758010651e60224e5b60230263617040bd8014533560b3e501b3202a01656e209e210f2909036f6d706c225de10010e0001b26f38581e0001100756a8700798058325b404157c1e0001000692440585121a924f7a01625498469e002aa4eaa20cd0073c0de268882eb00743321803701747240432439006934dc28f3a29a20172f8b4079568a802a027572702135204b95bb60142714a1ac4a38016361676d20162371403c287aa1eb6e93247b437944ae803d4ea8211fa2462267e0011620b7006169ae203bd675280901696380220272616429bc829844f601696ea29a2764006120aa6040e70005635f2047205245e6804235c6a0a400748144007620dd80512043a7ec201545a5403b00623521006587f900612e15262a20ba254340866051e00013037863697423bda2d12694016c2d26240265727630a4e8003d01616e44ec228141ca8070e7001b21f333c00166722ceb64e2006e225749e3769e201321842071006720356c2e4f17200f84a023132167a012b7d501736fa92ae002464a554bb136b5209c2140007922d22c7520484012205b2eb8016d61226d201d8014a057835ba02800742f7327642feb02666c79210e4d45e0021a22a3337f212a24a65360e0031a026c6f752d38ab5f2073404a23282348227e0265616b801101736b430ae0001e23d70063a7c264e9e003500072307326b48f4380b2405327b42e6c2649e002130265616723d901736f2fe1e0012874520062311e2ff522b8695fa07802666c61279cb44be0033229412ac423db2752e002170167752229006921b8027761742659e00219424331de2249e0032fcda8c2cbe00230c01ab06ae001ae036c61627934a622d904756e766569c1ba40f2006c42c80072e005dd221e00732157006c64dde00246a6722b4d2620e00417230c02776178e00313006e4c3d41502b72e0022ab4e4266521b5e001a0026f776c24b9016f74e00212007038ba026e6978457fe0035725cb399d62cc2328e00319409438442c0ce0024500732d5446fae0054428bb006420262475006c44dda1b94c822807e106ea222830e8229b006743bbc02a6014518f77e3e001c880182431016e6b6654c02f00752164e006832012007337fde0013b017468676b218de3005c00742333734b02656262e003292077201c227fe0013d2cae20ff264623fe27ace0022d0077200e2a5f405823a9e00131448530f8017261383920032150e0021b2da043922636e00331016f6c46610077e20340271a2481408be00228057a6570687972f2002720573ab03d23218ba2d62aac73ac843ee0032024d22233428444d1c0372ef64f2027d75073661d6d39c01f4129ccd6256d0079202720f601207920c1e0025c6025026c6f6f22e16b07400f4231693ce0034a42194047402024102128e0064541fb4f77c02403636f6d702901e00625046c6f79616c2b9d209140490068489ae00622403542a4a02220476ebae0038c4022c0b02708e006404257c03d57c2e0061e217642d5a05eed00724ad4e0036343f04e73c0280062215fe00749037769667434733474a0ce01617747f1e003464207c0aa22bb016b654592e00320849be00222036c6f7475e1073623ae4496a06623e6e0078ab480c02142ade006ac27b300643d7aa04221a92721636cc08ca02000672a4f6c1d014475252128b134dac5482052bc80006228897fbb229d0165794181c01800722d7125bde201084401e001382728006d214b270f211b211049584e47a03e0163792eb440a40073288b006f6341a019e2005c23e94772e00152325fe101a640586774c036270ee000f5600c613ba01d740c211220af410e624d417bc01e92704021e008750066459d02746570e100fc2466006c20d5e002eb0267617a603b40e785e7e001b4574e40572519254900684826a074600e601a211e016461e002e8026d6964273120ae481a2a3d848aa036ba80201da312a01720ff006c288e201700694a04006ec929e0001e6c87e2025d8048e001a9cb2020412d400369747564e002c6218a016c6ce30302006c8fefa05da296607e40ce6704c05a22572990244b006fb667006de000ec23d460337cf4202f005520272fbe21102bbe016f70643f425741abe0011be1036fe00a1d270840c44045656c47a5e0045be1047938f421b30022e0035f4b392229610a404526b1e0041f27c4e501242c10262d0074228de005a4e00424e00882e0051d31ffe0046048aa40c2aed3e0041b692d20d7438e613b6b9c4aa62bf1006e4d7b44112c1837c3938d01616629b5437b201067cb00614d690066405601616e222c8bdb301560850061e00042f6006a0261736b2082016265b4b34d3e211620124de00069b5b44105006e739429cc259a5061006331200065204f402a026f6d6d2b5a600920276cb72009b1a320092c0e01706c808baaa5a0be5209c0640364617a7a635d0164658fe2312222ac6fb543e3205e00652d8e26a10074406a23d736b4401483e04009006e2089007086b02359268060140072ee00aa200bb6442a36007275bba0094931200a25738033348274b5200965b640480076c08c84242012219e01686f417d276e2569611724bc6077006728824f950068321b016f6e81ad200b4367203921ac28384008026c6c7527b880d321b023dd6016006d24e361b3283101756c605101696e206f0075a029d7d82ad5270b6032216601726c915d600bc0cd006920c301676f347a802500762eda2078026c6962d89dec02e62db64262207c607223c2200a80bc016e752d566069016f722206275b805130dc0073381360190070356f653d017175218c4226636f6079017265220900632fa9207c34c2582b2035600c64be6009e10017368300753548c03a30a30064a039016e6557a0017265c21b4009e000272efb2067804b20a0621636be62bb20072a4d2066007344ae4007b6ba2c28400d01756220eb60f62045a24622268033204c046e736669782028600a016d7560d422f629b240e82aaaa011295a620902756e6d835d00752282808201756e2261416020daa14c017669333e60392d74a21d7a6963f7f4043332d82541c13963e300622b5d24a100202c4124760072936f00624991239c4b0723ced6a3e001162143017267403fe003122ba9037369617342cee00116b88c8416922ae00080006967662230606a0077c1fa2010230b2027036861707022cd62efe0001422360065499221473a4f01726e2eb0299535ec4010220f002d235d2ae3403f016b6e2b9400653780a01a2ff02b4290162ee46ecf4032d53c261c6114e00313f501504375e00319a0d9e0031230a32d9d608a6ea601666556a784d2275c40416017d5ee2f6d6102006822b65b9d30df2558204380f343c3530224090074c772326744a202726162292220ea4145006e3dd020e2e0041ae102260069235200733bac006260335327204e808d201a2bf5007480182406006942f821729b2200696063c1ea401629732be22e28401942e120476079322a22bd20120074608ee0041333a101696228e0201a80a6a02ce1022de000138a7f603e207700202f10a04c609d2213389303756d706880480376616c75608a214623c3a014210760b9366a79f5209380a523d9007044df6032361d016f728091c1ffe20519270501652d2ca721612077d8ce40634019006c541c5a1de00410e0035400692158409741a52258c085e0011700703b54026e74696645006d25b72b15280b21f26b9147de601220fb421d406724b995c7f7011a612147f124ba026f6c75a0ea34695e3c207c232d73cf403e23e3803e52bbe0020e24d73db5403aa025440927f121fb899940164295007722a00070271e814f61bf0164692ec0802b2e8c4641402c20b132f820be245964ed26d4284b2037601d036f756c2d20dd313121592187e0031840cbe3053261fa26b7006c431c3e65203420bd00742a07ed04363a3251572a21b92e4a40022d686f379820b6208594f140804019611d2005006749cc404f2a6e6013e10182e00012e200952045e000cb34c048d68b7fe00618b273406b01756e44fb006b6273c22f56e5213940f620d5a4482588a6d220ae23480068803d2014027075742012006d383485b420142fc901672029bb26aa215420be2647202a20142d946530e000100063254c016f738495201424327506e000d32144e200e5213a6d374013489960b56d5a808c21c602676574842f0061dca7e0091a4064235b006e8497e00536e1041a88afe00765e0021500735de7a0cf2240283600642e5d270c65a8e00113252261c5e0011148c12d1f67cae0011501736b292f002260116317607a830e01756e455620322632e000120071344a41616027b0b7603e340823a841700070e3001020152a8b403ee1061bc016e102730073468a016f7056c020f0a51a20160068a22a2220006632cf2142606ee00017d812201223faa2560065a6ff4014299c39c043028197a0112233239a372c4224a01988a420edbca3c47a2864416140dc02666f637087e00212e10305e00027e6026e01756e687d403d2411529e60c1e0001422306b074c950041241e23c736ca71ca2c984cd96e15036472616d4d79e00622237200702306e00026503a4191a0262304401a0079207821986825a0192674236ba06123546a3ce00239a01f2024027973694120e0043732a3e00173621420d4e00421a436407daa8f8398e004242cee37ff2f4460e2268ce00880414822e6e00023a32ee0016d46acee03a42f40e00d23e002906025486ce00646e001a8e0006fe005252c012e16d089206ae200d8e001493f8b23b027fce1079ae0132b006628e559d8e0007702736167e102ede00053e00ec402426579254020d7249d2dc4215443da4125e00319293f428560c120afe0021a81ece0075c026f6479230ee00645802a007237f2e000abe1016fe007522565e00025c225e00523293c409323896728e0021ce10ad8e10341e0022921953748e003460055a183006c40bc015768240124c8002021af0273616923de212a01646f6e16601b4136c37236a83a44218d0120755a8473f4e001242d6f016c7583caa377205328514c81e00b2520943077404d007727b228de2176e00b27e8027124993e57e00f5026840075227f27a9cd5ae0014e2e4e34a6224a9818e00118743e4b26006c2a0143cae0001a441e20c14d73e00399066570696c6f677527a000652f3ee0043181fe4436e0131b414de005698037006226823cfbe006a0801bc151e00f3b2d7a2822216e203ee003aca03da0fd252679d9e000e2801e48c923d520eb2e4c3033e1045f8022006e2a7e2188202623bce00af3453e2e00006f30ca27f4e00981027069653305206124c60063e00b6060209a4e478d006f8028e00948027269642e0140496618e00aaa86ce625701756e65b8e00b25e604e2404e0167723141e00b29919220dc411ce00390a3d94227e10411a01700272287234b2e9601726f2733e10535e00123815f29ad3617430b2ef6e3050963eae300dc41634366e0054e6023c2232165e30a50e004228346e004b5601f01646f2bbf2869e00a817709405b23d1534fe10479603c53362360e00b9a2327461980e100672388e00a3ea1124134e009980070335e002030c3e3056f607601707553c94099e209116020462de11236017365233c20a240d9007620dbe00a9a754520202dcb2b5ce2030360604516401e893de00c1e220b00637454e3007aa0b6e40c7968a741684236002043d700632e090061520ee0003fe600f52c643b7c407f6dafe0037ee00623817ee00be5e0002823c1225d4db34050442fe004cfe000272d3d60f2e60729e00120a934006920c042d6006d2217e00c9ac1f68079e2063ce0004e40b48e7502206f6324cee20421e0002563fae207dc69dee00c650069202ce603dec96aa34840aee00f224f708a11e00122006f664329c84048e00375e0044861606725a4f226956514e009256186418347bdc686e0009160486022e001b703726f6e6924a7e00e4a20276096625ee0042301756c28fc6f72402421133d0f230c905ce0007284aae4038a60f1e0046e8023c1fd0079e100f7c0b6801f2743007038ebe0048480193cee2a5723e88367e00536847a80a75da72117e003c680412b142cd640c72e96e0099b201988d43fad01697a6f0ee0006563cda1fd419764b4e00361602081fb42d8e40170c0a76020221a25cce500c8c01be200a620612e39300c3202e0045ee00021006738ee2847016869218463d1e00843478bb1c14d1b51c02eea60ef056162736f726220b6026163633ce86008f403dd016166d9c5269a016563b730246ab85341d69738400949162042400a0172652a2c408e827b63d0200a352900678079200c2095d933200df9138a6271405a036465647562fe016469311f40af0064243c35ad20764009b7b8f904792e03403a2ef2006ff90183aa1a01656e6bc46589f903832346803327d1264e205d016571b8e00165785a339ac90265786834814086309932a540f034cc303340132253b98423304707204600674934442e210621454011026c656140be0167722854200f398af900963053f90283200c22b0810802696d623926202e564730924009f90179a11b01696e3550609e34f5006fbb32275f51a9603053016044006e308c6a0d204a00652089616c400b007221c9802b200bc1163520217c006920c2403c20bf617f006d3bd7006620172059006d4a61801dcb5efd00f8006d9bf1016f6233e678f4016f624b6e203531db01636532fe400a22b3a01e291225c48014006f205f45ce83dc401322942fb7801f200b006f341ec0172ade91a54017344120562009203a60b529e9006521978043f901e63288562539ef2222208e6034016a6f34f560092657a00880a700722c3e016d6261c7200a4d85a028006efa140b808b2daba04d21d5a037485560692b1c2057c02022868077fa0928202d01736580f40373796d6223536100aacf201d229627cf51a1600c52e44062007521c401696c64110561206261747424ee32643e8303746c7920281f2d1e2030201b4f11006521fe22c42019a3fc646b201c0172693907247f35dc24c734eb803380162b9b22e53f10a1a1e0002f2018e0019622af6034e401eb734d35b0206e43d123b880562021007020884b80016365801f63de40d9e0011d4fff002d2451289d0064a01a3a8a2c5322d8c03660108036d78153452ee8c686401822e4006e210b363c231de0002e80159536201b203233458c0f20342b1640de237120a8007320770274756d42b3e0011a026e65772dc02e104694e0091af307bc203822b4006d4086206a200a41e1a0ba200d006d2af0007347db222b201f007028f00075a01e01666522a72cb227cc20a740c35389616b43bb0277617940a9006160902a986f2ce0041ae5001ee00b3722b49ff927fb6096006d80cb66900073955f20762093e6029d0161207aa8408f71a32192fa0082fc0452e0097ac99720cd21a701662dc5ef4819e0041d4272606560e9c03622722171219360e980aae0021b605220aee10425e0021f4054585fe007536017b174e003303b6e2bc9665de00432629c213a2384a1a528c6409c00682ead315fe800316035a01b25194f4e006c212e016f77747ce0001af500fa00612f91026761632201396200642175026c6566807aafb3268c2019016768601a25b2a07ec35375ec00692101201f02777269b164203d25d480b544f38277401343eb418b2500291da0af58724a0ddcfa60c460212dac23b920c3205eda3b804c2536245f36cb245956ca2b69e80482202062df22462408277a447c20f720277984806324222286212858ba2063a616a06200792967208225f060802879c0ca006edafae102480070235027f521316130e401d6e000182ebce2062ae0021a205220996a3181c550f1412a626323b223c022f56a4fe0011ce0047f202f00724f0540c801686f3d5a60e46017207b294523ec4f9ac5d923e5e00321827c006868490079801805696c6772696d40d5233f016661213de007172058007425ac832440aa8020364be404eb41622724a15903706f656d3aed026f7175217e20ade20339228821ba25fe406d212f201e006baa6444a63dbf201b601667eb81aa64bf006977ae0165782aaa2afc671a006194f726980072232a0067293be206252081a01e80c16de060c2e00119e00713bdf486f2625c22a480872ae0006b26c643a722b0b1682016026f61646350203b401bc02d40162158e4059360152156006e2210ed000a8212c01a4167002d864a007960ac0073239a37a640e62f38216c233e2958a1dfe0021de00e1601756e2899017273242b60ec806d2240216b209fa0e3c27b24545e5b036c6f64693d6a20e8017375c0683d4a0120614350273280982ca92424f7001f35df234dc0b5401c2a238242e702ef6018c290a73aa04e4413e4037434ce817a801a20ada19e602f583f25d50072298a63c2e0002d21870069664ae60931801a20944180c19a0069a181e0001c4b04fe0906402001656b40852cc73a6d006ea106c015203efd00b1a3c9601a206da29e25ab23a08180c01a0074236001756e44de83d161a32117016570217c202d21b902746f6f810629f32059209e230201646945d1cb61a27402766f7943cfe10293a4756130a01d21462c9b016c6f4767e00819627dc1188197a03620c68346e20000257fdd98405425eb26184604406d016e202aab4016a0c33819a2b2302598fd401d2112a6bee00416411581856a8e002c20d225bf268d2294564e208d2064e00516e00112463f2446e00628c015a02730cc00202c79471060473ca30065e006316012e0022e29d46d12602f25510079e0062f6012a02f2e1401726344eb006352c0a0142c116c1ce00337e00013a0234459e0043440a84043216c204f443e60fac01621cb2cd4e00917242f00628840e00630006f3fb70067e0092f00722ecf2dfbe0085fe0023d0163614248807a200b37d6e000892d4f63aba01c400d40e4e0001f3b3b615de00510e0025b0068253be004316010e00220026d6179e0003c200be00b1f23d5e005bf4027e003a5006d2626e00182600de009474023e009498015e002c0423be00410607ce003216010e002c1496a6032e00914e002256264e0044700733a99e1025c800ee004213d3b4a86817c400ce008d56014e007908014e002d30077e00468600d601f522403437279702ad521830341756775641b00432727006e6c50201504436c616972442b85170044277b2d2a201802446976261623ba423c004628a6201301466f2ee227ca8412200d0174756f78004997ea202102496e7427f48034004d2fe324d72015004d89b62009004f29dd40062dc074b20050236e284a8030005022c70069df16200c513ee0011aa04b20172350c030046f70686563405800523c73809600522f722fde8021005620080063e001c70056803941180042278d45d302416d75282c209302416e6b46a10341746861650b034261756260a3202945c8004220f8202600429d2703426f6f6b600d4f6f400820d1284540480342726f6f507b034275636b801b0275747461460043254e60110143615221014361222035be203e2193006c909b004335884045219800774018026c6f6140682007280e401034266006716a01436fd30a00432090006940890043259b605200722175602b0344616767603b02446961215340cc014475606404456c697869405501456d20eb40b4014661621600462a9827a42068004634de408000474080413002476c7967ca0047249160ef004747b8202900472a97006f248b200a0248617240e001486f725020063cfc01686f6019036f757267205240490249646f4037004a5fe82034014b6541c8004b82d9024c616d4041004c29d22c6d201d034c6f636b606e024d617220782011004d8098024d656460e56007006c81f6004d25b128c44024026972726c5a034d6f6e6f8273014d6f2bcf21904043004f25e7221e0022200900706045014f725545005029bc4092005027b12081201e20090074c2b3006fa25c00502a5b41330551756172747a202401517583d1200781ac005223660063201802526962317d6008615e01526f73f3005268210252756240f80052834b025361742d3f407c0053292040a3200701726140950053432a6194005331a6628d00532c1b41cf005320326033016967618b00532317618901537020ed20780153743602600780f800532993608a015375e1000c00532f51404c02546172645d03546561708008006834a6608b02546f6f6b8c00543e1b40fa0056527a374d22d863550344726167606f004120970276617242390041219530a66185004121ce006c3c6b20330241726d23b2016c6c41a50541786f6c6f7440490242616280b0014261328f4280014261417f2384600c7327024275663fd44038435a2e2a006c41400043602823492b0800656084234b0265746143d5004320c10370616e7a603e200c006e3767016c6c41f7235802776e662e8b209200438167234101636f209a40a5014465608403446f6c702035202380e18071004423e1201201456135fb4007016c656c83200a0246616c32b84008016c6128c1006740ab01466f5bcc0346726f6720170247617a21b1403502476972219a6009016f6f741d00472e73809c0248616d2a2540f802486177406a01486521150068604104486970706f219f02616d75434c636420580248756d407001626961ca0248796562dd03496775616008004a20750079a0ee004b23eb21ea409b004b2455410d034c656d75406e034c656f7021c1204f004c8351024c697aa00f35f08092024c796e40d0034d6163612d99202a2399006767ee004d2134006b618d23750067a0d5200a31054026a010034e61727724f62011004f253a6268044f63746f7060ce004f2e550173754262262b026e67752a89402801726340a5004f41f4400e0077403d0050227c40152007006735354027200aa4be01506123ff419123d200632442203523ca01677580260069418a0050262d007980750050362a017570964d0250756d405502526162977a005250b661d3005228f4406500522211006f38b4006f417f005321402bd72bf92062035365616844f4800a40a443a8407c03536b756e600720f0427201536e2e924026017069a03a49cf36a0401327b8a1aa01537760ff00542a02405f02546f7529c92022035475727462450357616c7261380057248b8220025765612c17202400572165406301576f700b005a5a3563ad01416c41d5610a01416d24642134202e0041b70800413aa9006826434012389b006361460041393e401020062031812902417a75646b02426973820801426c620f200663562710237920352008669a004226032c60420c200a026c79778d2a0242797a2082006961f5004330f3805d034365727532e740ed43db0270616765b9200b00722d8d0075616401436823b121c6406404436f62616c40b400433580612d02436f726183200723b8006f3f39208b004326ad2f36400928fc20060344656e69426f04456767706c20872012004538f4006169c3004626d7370b623f28f787a205467563687369410e00478ef24006330065d502477265622405486f7420506961f301496e3aed436d014a617b47044b68616b692066004c283a6006225682042386609a004c9787004d2946267e2023004d43af40ad024d61757960034d69646e4ae4401b2fb7400623384006007527fd63c1024e61764169004f3e2a4066004f53fe202063578008250c43ea034f78626c8189432c420a299e00693b4288c6200c0075203720cc4035200642c700503ad840149bcd00523afa0262657269ea005284cc00522edc016c20220a403400522094202d005324f0221360096082233c80f0005323416016006e32e540f002536170257860b847078871235e02666f614077035369656e64d7015369340941d702536b79c06d0053a211235b6160005322c586f30074375040662ffc49642703e20017200b007368670054208320fe60ec2709402f005420da24450074618a27140073837b02546f6d26de204f0054253448070554757271756f2df640132baea1a001547920d340f501556c2078e3003e02566572221701726941b5200b006d202f611b0256696f80ee00572068208983b303436f736d6853408c22872017409a245f01646f40cb02496e6629302013015d2c202c384440842a0b4c053ff4200f00734e84002c601f02312920241c41920531303078204c2b3a27c0403104353125204120e862f10539392520536c266f801b27d0026f7720200520de27a60120474a9a016e618c41401000543f8c016e6f20a640d247b9002022b789bd400d276c0120543b5a41e900428d5e25ad203549f100429a710048807900423456202b006140194aeb9489026420413642007562ee0344444f53e001a900442bab00202c16006a2f5c209d01446f4bc302205370806c0044247e002020a060190178782047253681634b10e00146014578374d21fe608671a501457834cb014c69259c02646974434e6010229242850245787022a20164202bb3644205464f4d4f20532769012d4f6974600fa0c502465544207e004632eb203025d640d9a00d2021016e733e7221fe4138a015005735e2006422a721d24013006d514b04444a20417021c80049424d2d9c01204622d862fe286f215d28c8657924aa026b204328ae0075ad310647617320466565405e400a2319667d400b2638206004484f444c20205101696763b02bc80164204045201a2259006c201832ca02427567a00f362d271405722044756d70405402496e762cc820d80169672e3c007563b7024c5020293423484177004c4c8b60ea34442044014c6526ff0464204b5943400c0069415f00614063400d27ae201a004626296029006f21a1024b6579e0000b005350360250687226e5602d0077e1049f004d20870063727820ff236e0063420f22863bae01204321f52032200d2294e1002ca00e054d616e69707580e92024034e474d494006399300742bd503205969656611024e65742b2e615d5fa521164025006fe00483200e025768692af123c0601d232201204528904169024f7270226320e001426c20e800222010237c0168793c7fe202c0401324b53ce203204e4654202400503ca00072229681130050204102746f6de2033940232499289a0067c29e2ca7207700442f2c401c600c004927476111232b0074473b002022c3026c6f6940a628f80270202661d2202f025265622160e000b500522089ee00c60352656b74407b66cd005234fb31cce4003404527567205023be204325ce02647769370de0001c4338e002e6c00e608a4030006524a9236701204239216689434d203030528254293f0177202062402c277c64404f8c6f79293823f5c15725ed05616479204c6162460153742bb4c378800ce30277204e005444bc01204461b462b2201e505a2174006c411e200ec3a5413443f8203500553d5a0074238f017075402300552d5300612d310120542832639700553fa50372696669413ee2018f015741225d214f28b12043848c21a8c32c005723c5409d407e401f24510273204e2e7e66ce25b92061c3790057275003672041643e4a67ff800fe0026b005a2aa8400f0166692d7842af4348025f62722b5a2a0620c446300057365e47f848bd40d62166600f223561e4014c7562c901456e68520a476c7574746f6e79225d5d";
}
// SPDX-License-Identifier: MIT
/**
  ______ _____   _____ ______ ___  __ _  _  _ 
 |  ____|  __ \ / ____|____  |__ \/_ | || || |
 | |__  | |__) | |        / /   ) || | \| |/ |
 |  __| |  _  /| |       / /   / / | |\_   _/ 
 | |____| | \ \| |____  / /   / /_ | |  | |   
 |______|_|  \_\\_____|/_/   |____||_|  |_|   

 - github: https://github.com/estarriolvetch/ERC721Psi
 - npm: https://www.npmjs.com/package/erc721psi

 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "solady/src/utils/LibBitmap.sol";
import "./interface/IERC721Psi.sol";

/**
 * @dev Interface of ERC721 token receiver.
 */
interface ERC721Psi__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Psi is IERC721Psi {
    
    using Address for address;
    using Strings for uint256;
    using LibBitmap for LibBitmap.Bitmap;

    LibBitmap.Bitmap private _batchHead;

    string private _name;
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;
    uint256 internal _currentIndex;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // The mask of the lower 160 bits for addresses.
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;
    // The `Transfer` event signature is given by:
    // `keccak256(bytes("Transfer(address,address,uint256)"))`.
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view virtual returns (uint256) {
        return _currentIndex - _startTokenId();
    }


    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        // The interface IDs are constants representing the first 4 bytes
        // of the XOR of all function selectors in the interface.
        // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
        // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) 
        public 
        view 
        virtual 
        override 
        returns (uint) 
    {
        if(owner == address(0)) revert BalanceQueryForZeroAddress();

        uint count;
        for( uint i = _startTokenId(); i < _nextTokenId(); ++i ){
            if(_exists(i)){
                if( owner == ownerOf(i)){
                    ++count;
                }
            }
        }
        return count;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        (address owner, ) = _ownerAndBatchHeadOf(tokenId);
        return owner;
    }

    function _ownerAndBatchHeadOf(uint256 tokenId) internal view returns (address owner, uint256 tokenIdBatchHead){
        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();
        tokenIdBatchHead = _getBatchHead(tokenId);
        owner = _owners[tokenIdBatchHead];
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if( !_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }


    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public payable virtual override {
        address owner = ownerOf(tokenId);

        if (_msgSenderERC721Psi() != owner) {
            if (!isApprovedForAll(owner, _msgSenderERC721Psi())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }
        }

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address) 
    {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _operatorApprovals[_msgSenderERC721Psi()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721Psi(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, 1, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _nextTokenId() && _startTokenId() <= tokenId;
    }

    error OperatorQueryForNonexistentToken();

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        if (!_exists(tokenId)) revert OperatorQueryForNonexistentToken();
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, "");
    }

    
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        _mint(to, quantity);
        uint256 end = _currentIndex;
        if (!_checkOnERC721Received(address(0), to, end - quantity, quantity, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
        // Reentrancy protection.
        if (_currentIndex != end) revert();
    }


    function _mint(
        address to,
        uint256 quantity
    ) internal virtual {
        uint256 nextTokenId = _nextTokenId();
        
        if (quantity == 0) revert MintZeroQuantity();
        if (to == address(0)) revert MintToZeroAddress();
        
        _beforeTokenTransfers(address(0), to, nextTokenId, quantity);
        _currentIndex += quantity;
        _owners[nextTokenId] = to;
        _batchHead.set(nextTokenId);

        uint256 toMasked;
        uint256 end = nextTokenId + quantity;

        // Use assembly to loop and emit the `Transfer` event for gas savings.
        // The duplicated `log4` removes an extra check and reduces stack juggling.
        // The assembly, together with the surrounding Solidity code, have been
        // delicately arranged to nudge the compiler into producing optimized opcodes.
        assembly {
            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            toMasked := and(to, _BITMASK_ADDRESS)
            // Emit the `Transfer` event.
            log4(
                0, // Start of data (0, since no data).
                0, // End of data (0, since no data).
                _TRANSFER_EVENT_SIGNATURE, // Signature.
                0, // `address(0)`.
                toMasked, // `to`.
                nextTokenId // `tokenId`.
            )

            // The `iszero(eq(,))` check ensures that large values of `quantity`
            // that overflows uint256 will make the loop run out of gas.
            // The compiler will optimize the `iszero` away for performance.
            for {
                let tokenId := add(nextTokenId, 1)
            } iszero(eq(tokenId, end)) {
                tokenId := add(tokenId, 1)
            } {
                // Emit the `Transfer` event. Similar to above.
                log4(0, 0, _TRANSFER_EVENT_SIGNATURE, 0, toMasked, tokenId)
            }
        }

        _afterTokenTransfers(address(0), to, nextTokenId, quantity);
    }


    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        (address owner, uint256 tokenIdBatchHead) = _ownerAndBatchHeadOf(tokenId);

        if (owner != from) revert TransferFromIncorrectOwner();

        if (!_isApprovedOrOwner(_msgSenderERC721Psi(), tokenId)) {
            revert TransferCallerNotOwnerNorApproved();
        }

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);   

        uint256 subsequentTokenId = tokenId + 1;

        if(!_batchHead.get(subsequentTokenId) &&  
            subsequentTokenId < _nextTokenId()
        ) {
            _owners[subsequentTokenId] = from;
            _batchHead.set(subsequentTokenId);
        }

        _owners[tokenId] = to;
        if(tokenId != tokenIdBatchHead) {
            _batchHead.set(tokenId);
        }

        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param startTokenId uint256 the first ID of the tokens to be transferred
     * @param quantity uint256 amount of the tokens to be transfered.
     * @param _data bytes optional data to send along with the call
     * @return r bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity,
        bytes memory _data
    ) private returns (bool r) {
        /// @dev removed isContract() in v5.0 but their ERC721 uses this check:
        if (to.code.length > 0) {
            r = true;
            for(uint256 tokenId = startTokenId; tokenId < startTokenId + quantity; tokenId++){
                try ERC721Psi__IERC721Receiver(to).onERC721Received( _msgSenderERC721Psi(), from, tokenId, _data) returns (bytes4 retval) {
                    r = r && retval == ERC721Psi__IERC721Receiver.onERC721Received.selector;
                } catch (bytes memory reason) {
                    if (reason.length == 0) {
                        revert TransferToNonERC721ReceiverImplementer();
                    } else {
                        assembly {
                            revert(add(32, reason), mload(reason))
                        }
                    }
                }
            }
            return r;
        } else {
            return true;
        }
    }

    function _getBatchHead(uint256 tokenId) internal view returns (uint256 tokenIdBatchHead) {
        tokenIdBatchHead = _batchHead.findLastSet(tokenId); 
    }


    function totalSupply() public virtual override view returns (uint256) {
        return _totalMinted();
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(`totalSupply`) in complexity.
     * It is meant to be called off-chain.
     *
     * This function is compatiable with ERC721AQueryable.
     */
    function tokensOfOwner(address owner) external view virtual returns (uint256[] memory) {
        unchecked {
            uint256 tokenIdsIdx;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            for (uint256 i = _startTokenId(); tokenIdsIdx != tokenIdsLength; ++i) {
                if (_exists(i)) {
                    if (ownerOf(i) == owner) {
                        tokenIds[tokenIdsIdx++] = i;
                    }
                }
            }
            return tokenIds;   
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    /**
     * @dev Returns the message sender (defaults to `msg.sender`).
     *
     * If you are writing GSN compatible contracts, you need to override this function.
     */
    function _msgSenderERC721Psi() internal view virtual returns (address) {
        return msg.sender;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of ERC721Psi.
 */
interface IERC721Psi {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the
     * ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();


    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see {_totalMinted}.
     */
    function totalSupply() external view returns (uint256);

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // =============================================================
    //                            IERC721
    // =============================================================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables
     * (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
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
     * @dev Safely transfers `tokenId` token from `from` to `to`,
     * checking first that contract recipients are aware of the ERC721 protocol
     * to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move
     * this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external payable;

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom}
     * whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external payable;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

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
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

interface IBinding {

    error InvalidTransferOwnership();

    function bindCryptar(address cryptar) external;

    function transferOwnership(address owner) external;
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

interface IFortune {

    function fortuneOf(uint256 tokenId) external view returns (address, uint256);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

interface IFortuneCard {

    function revealFortuneCard(bool legendary) external view returns (string[] memory);

    function revealCursedCard(bool legendary) external view returns (string[] memory);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

interface IFortuneTeller {

    function revealFortune(uint256 fortune) external pure returns (string[] memory);

    function fortunateTraits(string[] memory revealed) external pure returns (string memory);

    function revealCurse(uint256 curse) external pure returns (string[] memory);

    function cursedTraits(string[] memory revealed) external pure returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library to encode strings in Base64.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Base64.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Base64.sol)
/// @author Modified from (https://github.com/Brechtpd/base64/blob/main/base64.sol) by Brecht Devos - <brecht@loopring.org>.
library Base64 {
    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// See: https://datatracker.ietf.org/doc/html/rfc4648
    /// @param fileSafe  Whether to replace '+' with '-' and '/' with '_'.
    /// @param noPadding Whether to strip away the padding.
    function encode(bytes memory data, bool fileSafe, bool noPadding)
        internal
        pure
        returns (string memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                // Multiply by 4/3 rounded up.
                // The `shl(2, ...)` is equivalent to multiplying by 4.
                let encodedLength := shl(2, div(add(dataLength, 2), 3))

                // Set `result` to point to the start of the free memory.
                result := mload(0x40)

                // Store the table into the scratch space.
                // Offsetted by -1 byte so that the `mload` will load the character.
                // We will rewrite the free memory pointer at `0x40` later with
                // the allocated size.
                // The magic constant 0x0670 will turn "-_" into "+/".
                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                mstore(0x3f, xor("ghijklmnopqrstuvwxyz0123456789-_", mul(iszero(fileSafe), 0x0670)))

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)

                // Run over the input, 3 bytes at a time.
                for {} 1 {} {
                    data := add(data, 3) // Advance 3 bytes.
                    let input := mload(data)

                    // Write 4 bytes. Optimized for fewer stack operations.
                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))

                    ptr := add(ptr, 4) // Advance 4 bytes.
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                // Equivalent to `o = [0, 2, 1][dataLength % 3]`.
                let o := div(2, mod(dataLength, 3))
                // Offset `ptr` and pad with '='. We can simply write over the end.
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                // Set `o` to zero if there is padding.
                o := mul(iszero(iszero(noPadding)), o)
                mstore(sub(ptr, o), 0) // Zeroize the slot after the string.
                mstore(result, sub(encodedLength, o)) // Store the length.
            }
        }
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, false, false)`.
    function encode(bytes memory data) internal pure returns (string memory result) {
        result = encode(data, false, false);
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, fileSafe, false)`.
    function encode(bytes memory data, bool fileSafe)
        internal
        pure
        returns (string memory result)
    {
        result = encode(data, fileSafe, false);
    }

    /// @dev Decodes base64 encoded `data`.
    ///
    /// Supports:
    /// - RFC 4648 (both standard and file-safe mode).
    /// - RFC 3501 (63: ',').
    ///
    /// Does not support:
    /// - Line breaks.
    ///
    /// Note: For performance reasons,
    /// this function will NOT revert on invalid `data` inputs.
    /// Outputs for invalid inputs will simply be undefined behaviour.
    /// It is the user's responsibility to ensure that the `data`
    /// is a valid base64 encoded string.
    function decode(string memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                let decodedLength := mul(shr(2, dataLength), 3)

                for {} 1 {} {
                    // If padded.
                    if iszero(and(dataLength, 3)) {
                        let t := xor(mload(add(data, dataLength)), 0x3d3d)
                        // forgefmt: disable-next-item
                        decodedLength := sub(
                            decodedLength,
                            add(iszero(byte(30, t)), iszero(byte(31, t)))
                        )
                        break
                    }
                    // If non-padded.
                    decodedLength := add(decodedLength, sub(and(dataLength, 3), 1))
                    break
                }
                result := mload(0x40)

                // Write the length of the bytes.
                mstore(result, decodedLength)

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, decodedLength)

                // Load the table into the scratch space.
                // Constants are optimized for smaller bytecode with zero gas overhead.
                // `m` also doubles as the mask of the upper 6 bits.
                let m := 0xfc000000fc00686c7074787c8084888c9094989ca0a4a8acb0b4b8bcc0c4c8cc
                mstore(0x5b, m)
                mstore(0x3b, 0x04080c1014181c2024282c3034383c4044484c5054585c6064)
                mstore(0x1a, 0xf8fcf800fcd0d4d8dce0e4e8ecf0f4)

                for {} 1 {} {
                    // Read 4 bytes.
                    data := add(data, 4)
                    let input := mload(data)

                    // Write 3 bytes.
                    // forgefmt: disable-next-item
                    mstore(ptr, or(
                        and(m, mload(byte(28, input))),
                        shr(6, or(
                            and(m, mload(byte(29, input))),
                            shr(6, or(
                                and(m, mload(byte(30, input))),
                                shr(6, mload(byte(31, input)))
                            ))
                        ))
                    ))
                    ptr := add(ptr, 3)
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                mstore(end, 0) // Zeroize the slot after the bytes.
                mstore(0x60, 0) // Restore the zero slot.
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for parsing JSONs.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/JSONParserLib.sol)
library JSONParserLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The input is invalid.
    error ParsingFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // There are 6 types of variables in JSON (excluding undefined).

    /// @dev For denoting that an item has not been initialized.
    /// A item returned from `parse` will never be of an undefined type.
    /// Parsing a invalid JSON string will simply revert.
    uint8 internal constant TYPE_UNDEFINED = 0;

    /// @dev Type representing an array (e.g. `[1,2,3]`).
    uint8 internal constant TYPE_ARRAY = 1;

    /// @dev Type representing an object (e.g. `{"a":"A","b":"B"}`).
    uint8 internal constant TYPE_OBJECT = 2;

    /// @dev Type representing a number (e.g. `-1.23e+21`).
    uint8 internal constant TYPE_NUMBER = 3;

    /// @dev Type representing a string (e.g. `"hello"`).
    uint8 internal constant TYPE_STRING = 4;

    /// @dev Type representing a boolean (i.e. `true` or `false`).
    uint8 internal constant TYPE_BOOLEAN = 5;

    /// @dev Type representing null (i.e. `null`).
    uint8 internal constant TYPE_NULL = 6;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A pointer to a parsed JSON node.
    struct Item {
        // Do NOT modify the `_data` directly.
        uint256 _data;
    }

    // Private constants for packing `_data`.

    uint256 private constant _BITPOS_STRING = 32 * 7 - 8;
    uint256 private constant _BITPOS_KEY_LENGTH = 32 * 6 - 8;
    uint256 private constant _BITPOS_KEY = 32 * 5 - 8;
    uint256 private constant _BITPOS_VALUE_LENGTH = 32 * 4 - 8;
    uint256 private constant _BITPOS_VALUE = 32 * 3 - 8;
    uint256 private constant _BITPOS_CHILD = 32 * 2 - 8;
    uint256 private constant _BITPOS_SIBLING_OR_PARENT = 32 * 1 - 8;
    uint256 private constant _BITMASK_POINTER = 0xffffffff;
    uint256 private constant _BITMASK_TYPE = 7;
    uint256 private constant _KEY_INITED = 1 << 3;
    uint256 private constant _VALUE_INITED = 1 << 4;
    uint256 private constant _CHILDREN_INITED = 1 << 5;
    uint256 private constant _PARENT_IS_ARRAY = 1 << 6;
    uint256 private constant _PARENT_IS_OBJECT = 1 << 7;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   JSON PARSING OPERATION                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Parses the JSON string `s`, and returns the root.
    /// Reverts if `s` is not a valid JSON as specified in RFC 8259.
    /// Object items WILL simply contain all their children, inclusive of repeated keys,
    /// in the same order which they appear in the JSON string.
    ///
    /// Note: For efficiency, this function WILL NOT make a copy of `s`.
    /// The parsed tree WILL contain offsets to `s`.
    /// Do NOT pass in a string that WILL be modified later on.
    function parse(string memory s) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // We will use our own allocation instead.
        }
        bytes32 r = _query(_toInput(s), 255);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    JSON ITEM OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note:
    // - An item is a node in the JSON tree.
    // - The value of a string item WILL be double-quoted, JSON encoded.
    // - We make a distinction between `index` and `key`.
    //   - Items in arrays are located by `index` (uint256).
    //   - Items in objects are located by `key` (string).
    // - Keys are always strings, double-quoted, JSON encoded.
    //
    // These design choices are made to balance between efficiency and ease-of-use.

    /// @dev Returns the string value of the item.
    /// This is its exact string representation in the original JSON string.
    /// The returned string WILL have leading and trailing whitespace trimmed.
    /// All inner whitespace WILL be preserved, exactly as it is in the original JSON string.
    /// If the item's type is string, the returned string WILL be double-quoted, JSON encoded.
    ///
    /// Note: This function lazily instantiates and caches the returned string.
    /// Do NOT modify the returned string.
    function value(Item memory item) internal pure returns (string memory result) {
        bytes32 r = _query(_toInput(item), 0);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /// @dev Returns the index of the item in the array.
    /// It the item's parent is not an array, returns 0.
    function index(Item memory item) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if and(mload(item), _PARENT_IS_ARRAY) {
                result := and(_BITMASK_POINTER, shr(_BITPOS_KEY, mload(item)))
            }
        }
    }

    /// @dev Returns the key of the item in the object.
    /// It the item's parent is not an object, returns an empty string.
    /// The returned string WILL be double-quoted, JSON encoded.
    ///
    /// Note: This function lazily instantiates and caches the returned string.
    /// Do NOT modify the returned string.
    function key(Item memory item) internal pure returns (string memory result) {
        if (item._data & _PARENT_IS_OBJECT != 0) {
            bytes32 r = _query(_toInput(item), 1);
            /// @solidity memory-safe-assembly
            assembly {
                result := r
            }
        }
    }

    /// @dev Returns the key of the item in the object.
    /// It the item is neither an array nor object, returns an empty array.
    ///
    /// Note: This function lazily instantiates and caches the returned array.
    /// Do NOT modify the returned array.
    function children(Item memory item) internal pure returns (Item[] memory result) {
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := r
        }
    }

    /// @dev Returns the number of children.
    /// It the item is neither an array nor object, returns zero.
    function size(Item memory item) internal pure returns (uint256 result) {
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(r)
        }
    }

    /// @dev Returns the item at index `i` for (array).
    /// If `item` is not an array, the result's type WILL be undefined.
    /// If there is no item with the index, the result's type WILL be undefined.
    function at(Item memory item, uint256 i) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We'll allocate manually.
        }
        bytes32 r = _query(_toInput(item), 3);
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(r, 0x20), shl(5, i)))
            if iszero(and(lt(i, mload(r)), eq(and(mload(item), _BITMASK_TYPE), TYPE_ARRAY))) {
                result := 0x60 // Reset to the zero pointer.
            }
        }
    }

    /// @dev Returns the item at key `k` for (object).
    /// If `item` is not an object, the result's type WILL be undefined.
    /// The key MUST be double-quoted, JSON encoded. This is for efficiency reasons.
    /// - Correct : `item.at('"k"')`.
    /// - Wrong   : `item.at("k")`.
    /// For duplicated keys, the last item with the key WILL be returned.
    /// If there is no item with the key, the result's type WILL be undefined.
    function at(Item memory item, string memory k) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We'll allocate manually.
            result := 0x60 // Initialize to the zero pointer.
        }
        if (isObject(item)) {
            bytes32 kHash = keccak256(bytes(k));
            Item[] memory r = children(item);
            // We'll just do a linear search. The alternatives are very bloated.
            for (uint256 i = r.length << 5; i != 0;) {
                /// @solidity memory-safe-assembly
                assembly {
                    item := mload(add(r, i))
                    i := sub(i, 0x20)
                }
                if (keccak256(bytes(key(item))) != kHash) continue;
                result = item;
                break;
            }
        }
    }

    /// @dev Returns the item's type.
    function getType(Item memory item) internal pure returns (uint8 result) {
        result = uint8(item._data & _BITMASK_TYPE);
    }

    /// Note: All types are mutually exclusive.

    /// @dev Returns whether the item is of type undefined.
    function isUndefined(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_UNDEFINED;
    }

    /// @dev Returns whether the item is of type array.
    function isArray(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_ARRAY;
    }

    /// @dev Returns whether the item is of type object.
    function isObject(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_OBJECT;
    }

    /// @dev Returns whether the item is of type number.
    function isNumber(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_NUMBER;
    }

    /// @dev Returns whether the item is of type string.
    function isString(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_STRING;
    }

    /// @dev Returns whether the item is of type boolean.
    function isBoolean(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_BOOLEAN;
    }

    /// @dev Returns whether the item is of type null.
    function isNull(Item memory item) internal pure returns (bool result) {
        result = item._data & _BITMASK_TYPE == TYPE_NULL;
    }

    /// @dev Returns the item's parent.
    /// If the item does not have a parent, the result's type will be undefined.
    function parent(Item memory item) internal pure returns (Item memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x40, result) // Free the default allocation. We've already allocated.
            result := and(shr(_BITPOS_SIBLING_OR_PARENT, mload(item)), _BITMASK_POINTER)
            if iszero(result) { result := 0x60 } // Reset to the zero pointer.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     UTILITY FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Parses an unsigned integer from a string (in decimal, i.e. base 10).
    /// Reverts if `s` is not a valid uint256 string matching the RegEx `^[0-9]+$`,
    /// or if the parsed number is too big for a uint256.
    function parseUint(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            let preMulOverflowThres := div(not(0), 10)
            for { let i := 0 } 1 {} {
                i := add(i, 1)
                let digit := sub(and(mload(add(s, i)), 0xff), 48)
                let mulOverflowed := gt(result, preMulOverflowThres)
                let product := mul(10, result)
                result := add(product, digit)
                n := mul(n, iszero(or(or(mulOverflowed, lt(result, product)), gt(digit, 9))))
                if iszero(lt(i, n)) { break }
            }
            if iszero(n) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Parses a signed integer from a string (in decimal, i.e. base 10).
    /// Reverts if `s` is not a valid int256 string matching the RegEx `^[+-]?[0-9]+$`,
    /// or if the parsed number is too big for a int256.
    function parseInt(string memory s) internal pure returns (int256 result) {
        uint256 n = bytes(s).length;
        uint256 sign;
        uint256 isNegative;
        /// @solidity memory-safe-assembly
        assembly {
            if n {
                let c := and(mload(add(s, 1)), 0xff)
                isNegative := eq(c, 45)
                if or(eq(c, 43), isNegative) {
                    sign := c
                    s := add(s, 1)
                    mstore(s, sub(n, 1))
                }
                if iszero(or(sign, lt(sub(c, 48), 10))) { s := 0x60 }
            }
        }
        uint256 x = parseUint(s);
        /// @solidity memory-safe-assembly
        assembly {
            if shr(255, x) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
            if sign {
                mstore(s, sign)
                s := sub(s, 1)
                mstore(s, n)
            }
            result := xor(x, mul(xor(x, add(not(x), 1)), isNegative))
        }
    }

    /// @dev Parses an unsigned integer from a string (in hexadecimal, i.e. base 16).
    /// Reverts if `s` is not a valid uint256 hex string matching the RegEx
    /// `^(0[xX])?[0-9a-fA-F]+$`, or if the parsed number is too big for a uint256.
    function parseUintFromHex(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            // Skip two if starts with '0x' or '0X'.
            let i := shl(1, and(eq(0x3078, or(shr(240, mload(add(s, 0x20))), 0x20)), gt(n, 1)))
            for {} 1 {} {
                i := add(i, 1)
                let c :=
                    byte(
                        and(0x1f, shr(and(mload(add(s, i)), 0xff), 0x3e4088843e41bac000000000000)),
                        0x3010a071000000b0104040208000c05090d060e0f
                    )
                n := mul(n, iszero(or(iszero(c), shr(252, result))))
                result := add(shl(4, result), sub(c, 1))
                if iszero(lt(i, n)) { break }
            }
            if iszero(n) {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Decodes a JSON encoded string.
    /// The string MUST be double-quoted, JSON encoded.
    /// Reverts if the string is invalid.
    /// As you can see, it's pretty complex for a deceptively simple looking task.
    function decodeString(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            function fail() {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }

            function decodeUnicodeEscapeSequence(pIn_, end_) -> _unicode, _pOut {
                _pOut := add(pIn_, 4)
                let b_ := iszero(gt(_pOut, end_))
                let t_ := mload(pIn_) // Load the whole word.
                for { let i_ := 0 } iszero(eq(i_, 4)) { i_ := add(i_, 1) } {
                    let c_ := sub(byte(i_, t_), 48)
                    if iszero(and(shr(c_, 0x7e0000007e03ff), b_)) { fail() } // Not hexadecimal.
                    c_ := sub(c_, add(mul(gt(c_, 16), 7), shl(5, gt(c_, 48))))
                    _unicode := add(shl(4, _unicode), c_)
                }
            }

            function decodeUnicodeCodePoint(pIn_, end_) -> _unicode, _pOut {
                _unicode, _pOut := decodeUnicodeEscapeSequence(pIn_, end_)
                if iszero(or(lt(_unicode, 0xd800), gt(_unicode, 0xdbff))) {
                    let t_ := mload(_pOut) // Load the whole word.
                    end_ := mul(end_, eq(shr(240, t_), 0x5c75)) // Fail if not starting with '\\u'.
                    t_, _pOut := decodeUnicodeEscapeSequence(add(_pOut, 2), end_)
                    _unicode := add(0x10000, add(shl(10, and(0x3ff, _unicode)), and(0x3ff, t_)))
                }
            }

            function appendCodePointAsUTF8(pIn_, c_) -> _pOut {
                if iszero(gt(c_, 0x7f)) {
                    mstore8(pIn_, c_)
                    _pOut := add(pIn_, 1)
                    leave
                }
                mstore8(0x1f, c_)
                mstore8(0x1e, shr(6, c_))
                if iszero(gt(c_, 0x7ff)) {
                    mstore(pIn_, shl(240, or(0xc080, and(0x1f3f, mload(0x00)))))
                    _pOut := add(pIn_, 2)
                    leave
                }
                mstore8(0x1d, shr(12, c_))
                if iszero(gt(c_, 0xffff)) {
                    mstore(pIn_, shl(232, or(0xe08080, and(0x0f3f3f, mload(0x00)))))
                    _pOut := add(pIn_, 3)
                    leave
                }
                mstore8(0x1c, shr(18, c_))
                mstore(pIn_, shl(224, or(0xf0808080, and(0x073f3f3f, mload(0x00)))))
                _pOut := add(pIn_, shl(2, lt(c_, 0x110000)))
            }

            function chr(p_) -> _c {
                _c := byte(0, mload(p_))
            }

            let n := mload(s)
            let end := add(add(s, n), 0x1f)
            if iszero(and(gt(n, 1), eq(0x2222, or(and(0xff00, mload(add(s, 2))), chr(end))))) {
                fail() // Fail if not double-quoted.
            }
            let out := add(mload(0x40), 0x20)
            for { let curr := add(s, 0x21) } iszero(eq(curr, end)) {} {
                let c := chr(curr)
                curr := add(curr, 1)
                // Not '\\'.
                if iszero(eq(c, 92)) {
                    // Not '"'.
                    if iszero(eq(c, 34)) {
                        mstore8(out, c)
                        out := add(out, 1)
                        continue
                    }
                    curr := end
                }
                if iszero(eq(curr, end)) {
                    let escape := chr(curr)
                    curr := add(curr, 1)
                    // '"', '/', '\\'.
                    if and(shr(escape, 0x100000000000800400000000), 1) {
                        mstore8(out, escape)
                        out := add(out, 1)
                        continue
                    }
                    // 'u'.
                    if eq(escape, 117) {
                        escape, curr := decodeUnicodeCodePoint(curr, end)
                        out := appendCodePointAsUTF8(out, escape)
                        continue
                    }
                    // `{'b':'\b', 'f':'\f', 'n':'\n', 'r':'\r', 't':'\t'}`.
                    escape := byte(sub(escape, 85), 0x080000000c000000000000000a0000000d0009)
                    if escape {
                        mstore8(out, escape)
                        out := add(out, 1)
                        continue
                    }
                }
                fail()
                break
            }
            mstore(out, 0) // Zeroize the last slot.
            result := mload(0x40)
            mstore(result, sub(out, add(result, 0x20))) // Store the length.
            mstore(0x40, add(out, 0x20)) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Performs a query on the input with the given mode.
    function _query(bytes32 input, uint256 mode) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            function fail() {
                mstore(0x00, 0x10182796) // `ParsingFailed()`.
                revert(0x1c, 0x04)
            }

            function chr(p_) -> _c {
                _c := byte(0, mload(p_))
            }

            function skipWhitespace(pIn_, end_) -> _pOut {
                for { _pOut := pIn_ } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(and(shr(chr(_pOut), 0x100002600), 1)) { leave } // Not in ' \n\r\t'.
                }
            }

            function setP(packed_, bitpos_, p_) -> _packed {
                // Perform an out-of-gas revert if `p_` exceeds `_BITMASK_POINTER`.
                returndatacopy(returndatasize(), returndatasize(), gt(p_, _BITMASK_POINTER))
                _packed := or(and(not(shl(bitpos_, _BITMASK_POINTER)), packed_), shl(bitpos_, p_))
            }

            function getP(packed_, bitpos_) -> _p {
                _p := and(_BITMASK_POINTER, shr(bitpos_, packed_))
            }

            function mallocItem(s_, packed_, pStart_, pCurr_, type_) -> _item {
                _item := mload(0x40)
                // forgefmt: disable-next-item
                packed_ := setP(setP(packed_, _BITPOS_VALUE, sub(pStart_, add(s_, 0x20))),
                    _BITPOS_VALUE_LENGTH, sub(pCurr_, pStart_))
                mstore(_item, or(packed_, type_))
                mstore(0x40, add(_item, 0x20)) // Allocate memory.
            }

            function parseValue(s_, sibling_, pIn_, end_) -> _item, _pOut {
                let packed_ := setP(mload(0x00), _BITPOS_SIBLING_OR_PARENT, sibling_)
                _pOut := skipWhitespace(pIn_, end_)
                if iszero(lt(_pOut, end_)) { leave }
                for { let c_ := chr(_pOut) } 1 {} {
                    // If starts with '"'.
                    if eq(c_, 34) {
                        let pStart_ := _pOut
                        _pOut := parseStringSub(s_, packed_, _pOut, end_)
                        _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_STRING)
                        break
                    }
                    // If starts with '['.
                    if eq(c_, 91) {
                        _item, _pOut := parseArray(s_, packed_, _pOut, end_)
                        break
                    }
                    // If starts with '{'.
                    if eq(c_, 123) {
                        _item, _pOut := parseObject(s_, packed_, _pOut, end_)
                        break
                    }
                    // If starts with any in '0123456789-'.
                    if and(shr(c_, shl(45, 0x1ff9)), 1) {
                        _item, _pOut := parseNumber(s_, packed_, _pOut, end_)
                        break
                    }
                    if iszero(gt(add(_pOut, 4), end_)) {
                        let pStart_ := _pOut
                        let w_ := shr(224, mload(_pOut))
                        // 'true' in hex format.
                        if eq(w_, 0x74727565) {
                            _pOut := add(_pOut, 4)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_BOOLEAN)
                            break
                        }
                        // 'null' in hex format.
                        if eq(w_, 0x6e756c6c) {
                            _pOut := add(_pOut, 4)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_NULL)
                            break
                        }
                    }
                    if iszero(gt(add(_pOut, 5), end_)) {
                        let pStart_ := _pOut
                        let w_ := shr(216, mload(_pOut))
                        // 'false' in hex format.
                        if eq(w_, 0x66616c7365) {
                            _pOut := add(_pOut, 5)
                            _item := mallocItem(s_, packed_, pStart_, _pOut, TYPE_BOOLEAN)
                            break
                        }
                    }
                    fail()
                    break
                }
                _pOut := skipWhitespace(_pOut, end_)
            }

            function parseArray(s_, packed_, pIn_, end_) -> _item, _pOut {
                let j_ := 0
                for { _pOut := add(pIn_, 1) } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(lt(_pOut, end_)) { fail() }
                    if iszero(_item) {
                        _pOut := skipWhitespace(_pOut, end_)
                        if eq(chr(_pOut), 93) { break } // ']'.
                    }
                    _item, _pOut := parseValue(s_, _item, _pOut, end_)
                    if _item {
                        // forgefmt: disable-next-item
                        mstore(_item, setP(or(_PARENT_IS_ARRAY, mload(_item)),
                            _BITPOS_KEY, j_))
                        j_ := add(j_, 1)
                        let c_ := chr(_pOut)
                        if eq(c_, 93) { break } // ']'.
                        if eq(c_, 44) { continue } // ','.
                    }
                    _pOut := end_
                }
                _pOut := add(_pOut, 1)
                packed_ := setP(packed_, _BITPOS_CHILD, _item)
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_ARRAY)
            }

            function parseObject(s_, packed_, pIn_, end_) -> _item, _pOut {
                for { _pOut := add(pIn_, 1) } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(lt(_pOut, end_)) { fail() }
                    if iszero(_item) {
                        _pOut := skipWhitespace(_pOut, end_)
                        if eq(chr(_pOut), 125) { break } // '}'.
                    }
                    _pOut := skipWhitespace(_pOut, end_)
                    let pKeyStart_ := _pOut
                    let pKeyEnd_ := parseStringSub(s_, _item, _pOut, end_)
                    _pOut := skipWhitespace(pKeyEnd_, end_)
                    // If ':'.
                    if eq(chr(_pOut), 58) {
                        _item, _pOut := parseValue(s_, _item, add(_pOut, 1), end_)
                        if _item {
                            // forgefmt: disable-next-item
                            mstore(_item, setP(setP(or(_PARENT_IS_OBJECT, mload(_item)),
                                _BITPOS_KEY_LENGTH, sub(pKeyEnd_, pKeyStart_)),
                                    _BITPOS_KEY, sub(pKeyStart_, add(s_, 0x20))))
                            let c_ := chr(_pOut)
                            if eq(c_, 125) { break } // '}'.
                            if eq(c_, 44) { continue } // ','.
                        }
                    }
                    _pOut := end_
                }
                _pOut := add(_pOut, 1)
                packed_ := setP(packed_, _BITPOS_CHILD, _item)
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_OBJECT)
            }

            function checkStringU(p_, o_) {
                // If not in '0123456789abcdefABCDEF', revert.
                if iszero(and(shr(sub(chr(add(p_, o_)), 48), 0x7e0000007e03ff), 1)) { fail() }
                if iszero(eq(o_, 5)) { checkStringU(p_, add(o_, 1)) }
            }

            function parseStringSub(s_, packed_, pIn_, end_) -> _pOut {
                if iszero(lt(pIn_, end_)) { fail() }
                for { _pOut := add(pIn_, 1) } 1 {} {
                    let c_ := chr(_pOut)
                    if eq(c_, 34) { break } // '"'.
                    // Not '\'.
                    if iszero(eq(c_, 92)) {
                        _pOut := add(_pOut, 1)
                        continue
                    }
                    c_ := chr(add(_pOut, 1))
                    // '"', '\', '//', 'b', 'f', 'n', 'r', 't'.
                    if and(shr(sub(c_, 34), 0x510110400000000002001), 1) {
                        _pOut := add(_pOut, 2)
                        continue
                    }
                    // 'u'.
                    if eq(c_, 117) {
                        checkStringU(_pOut, 2)
                        _pOut := add(_pOut, 6)
                        continue
                    }
                    _pOut := end_
                    break
                }
                if iszero(lt(_pOut, end_)) { fail() }
                _pOut := add(_pOut, 1)
            }

            function skip0To9s(pIn_, end_, atLeastOne_) -> _pOut {
                for { _pOut := pIn_ } 1 { _pOut := add(_pOut, 1) } {
                    if iszero(lt(sub(chr(_pOut), 48), 10)) { break } // Not '0'..'9'.
                }
                if and(atLeastOne_, eq(pIn_, _pOut)) { fail() }
            }

            function parseNumber(s_, packed_, pIn_, end_) -> _item, _pOut {
                _pOut := pIn_
                if eq(chr(_pOut), 45) { _pOut := add(_pOut, 1) } // '-'.
                if iszero(lt(sub(chr(_pOut), 48), 10)) { fail() } // Not '0'..'9'.
                let c_ := chr(_pOut)
                _pOut := add(_pOut, 1)
                if iszero(eq(c_, 48)) { _pOut := skip0To9s(_pOut, end_, 0) } // Not '0'.
                if eq(chr(_pOut), 46) { _pOut := skip0To9s(add(_pOut, 1), end_, 1) } // '.'.
                let t_ := mload(_pOut)
                // 'E', 'e'.
                if eq(or(0x20, byte(0, t_)), 101) {
                    // forgefmt: disable-next-item
                    _pOut := skip0To9s(add(byte(sub(byte(1, t_), 14), 0x010001), // '+', '-'.
                        add(_pOut, 1)), end_, 1)
                }
                _item := mallocItem(s_, packed_, pIn_, _pOut, TYPE_NUMBER)
            }

            function copyStr(s_, offset_, len_) -> _sCopy {
                _sCopy := mload(0x40)
                s_ := add(s_, offset_)
                let w_ := not(0x1f)
                for { let i_ := and(add(len_, 0x1f), w_) } 1 {} {
                    mstore(add(_sCopy, i_), mload(add(s_, i_)))
                    i_ := add(i_, w_) // `sub(i_, 0x20)`.
                    if iszero(i_) { break }
                }
                mstore(_sCopy, len_) // Copy the length.
                mstore(add(add(_sCopy, 0x20), len_), 0) // Zeroize the last slot.
                mstore(0x40, add(add(_sCopy, 0x40), len_)) // Allocate memory.
            }

            function value(item_) -> _value {
                let packed_ := mload(item_)
                _value := getP(packed_, _BITPOS_VALUE) // The offset in the string.
                if iszero(and(_VALUE_INITED, packed_)) {
                    let s_ := getP(packed_, _BITPOS_STRING)
                    _value := copyStr(s_, _value, getP(packed_, _BITPOS_VALUE_LENGTH))
                    packed_ := setP(packed_, _BITPOS_VALUE, _value)
                    mstore(s_, or(_VALUE_INITED, packed_))
                }
            }

            function children(item_) -> _arr {
                _arr := 0x60 // Initialize to the zero pointer.
                let packed_ := mload(item_)
                for {} iszero(gt(and(_BITMASK_TYPE, packed_), TYPE_OBJECT)) {} {
                    if or(iszero(packed_), iszero(item_)) { break }
                    if and(packed_, _CHILDREN_INITED) {
                        _arr := getP(packed_, _BITPOS_CHILD)
                        break
                    }
                    _arr := mload(0x40)
                    let o_ := add(_arr, 0x20)
                    for { let h_ := getP(packed_, _BITPOS_CHILD) } h_ {} {
                        mstore(o_, h_)
                        let q_ := mload(h_)
                        let y_ := getP(q_, _BITPOS_SIBLING_OR_PARENT)
                        mstore(h_, setP(q_, _BITPOS_SIBLING_OR_PARENT, item_))
                        h_ := y_
                        o_ := add(o_, 0x20)
                    }
                    let w_ := not(0x1f)
                    let n_ := add(w_, sub(o_, _arr))
                    mstore(_arr, shr(5, n_))
                    mstore(0x40, o_) // Allocate memory.
                    packed_ := setP(packed_, _BITPOS_CHILD, _arr)
                    mstore(item_, or(_CHILDREN_INITED, packed_))
                    // Reverse the array.
                    if iszero(lt(n_, 0x40)) {
                        let lo_ := add(_arr, 0x20)
                        let hi_ := add(_arr, n_)
                        for {} 1 {} {
                            let temp_ := mload(lo_)
                            mstore(lo_, mload(hi_))
                            mstore(hi_, temp_)
                            hi_ := add(hi_, w_)
                            lo_ := add(lo_, 0x20)
                            if iszero(lt(lo_, hi_)) { break }
                        }
                    }
                    break
                }
            }

            function getStr(item_, bitpos_, bitposLength_, bitmaskInited_) -> _result {
                _result := 0x60 // Initialize to the zero pointer.
                let packed_ := mload(item_)
                if or(iszero(item_), iszero(packed_)) { leave }
                _result := getP(packed_, bitpos_)
                if iszero(and(bitmaskInited_, packed_)) {
                    let s_ := getP(packed_, _BITPOS_STRING)
                    _result := copyStr(s_, _result, getP(packed_, bitposLength_))
                    mstore(item_, or(bitmaskInited_, setP(packed_, bitpos_, _result)))
                }
            }

            switch mode
            // Get value.
            case 0 { result := getStr(input, _BITPOS_VALUE, _BITPOS_VALUE_LENGTH, _VALUE_INITED) }
            // Get key.
            case 1 { result := getStr(input, _BITPOS_KEY, _BITPOS_KEY_LENGTH, _KEY_INITED) }
            // Get children.
            case 3 { result := children(input) }
            // Parse.
            default {
                let p := add(input, 0x20)
                let e := add(p, mload(input))
                if iszero(eq(p, e)) {
                    let c := chr(e)
                    mstore8(e, 34) // Place a '"' at the end to speed up parsing.
                    // The `34 << 248` makes `mallocItem` preserve '"' at the end.
                    mstore(0x00, setP(shl(248, 34), _BITPOS_STRING, input))
                    result, p := parseValue(input, 0, p, e)
                    mstore8(e, c) // Restore the original char at the end.
                }
                if or(lt(p, e), iszero(result)) { fail() }
            }
        }
    }

    /// @dev Casts the input to a bytes32.
    function _toInput(string memory input) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := input
        }
    }

    /// @dev Casts the input to a bytes32.
    function _toInput(Item memory input) private pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := input
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for bit twiddling and boolean operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
/// @author Inspired by (https://graphics.stanford.edu/~seander/bithacks.html)
library LibBit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BIT TWIDDLING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Find last set.
    /// Returns the index of the most significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    function fls(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Count leading zeros.
    /// Returns the number of zeros preceding the most significant one bit.
    /// If `x` is zero, returns 256.
    function clz(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := add(xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff)), iszero(x))
        }
    }

    /// @dev Find first set.
    /// Returns the index of the least significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    /// Equivalent to `ctz` (count trailing zeros), which gives
    /// the number of zeros following the least significant one bit.
    function ffs(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Isolate the least significant bit.
            let b := and(x, add(not(x), 1))

            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, b)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, b))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, b))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, b)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) internal pure returns (uint256 c) {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }

    /// @dev Returns whether `x` is a power of 2.
    function isPo2(uint256 x) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `x && !(x & (x - 1))`.
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }

    /// @dev Returns `x` reversed at the bit level.
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        uint256 m0 = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
        uint256 m1 = m0 ^ (m0 << 2);
        uint256 m2 = m1 ^ (m1 << 1);
        r = reverseBytes(x);
        r = (m2 & (r >> 1)) | ((m2 & r) << 1);
        r = (m1 & (r >> 2)) | ((m1 & r) << 2);
        r = (m0 & (r >> 4)) | ((m0 & r) << 4);
    }

    /// @dev Returns `x` reversed at the byte level.
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        unchecked {
            // Computing masks on-the-fly reduces bytecode size by about 200 bytes.
            uint256 m0 = 0x100000000000000000000000000000001 * (~toUint(x == 0) >> 192);
            uint256 m1 = m0 ^ (m0 << 32);
            uint256 m2 = m1 ^ (m1 << 16);
            uint256 m3 = m2 ^ (m2 << 8);
            r = (m3 & (x >> 8)) | ((m3 & x) << 8);
            r = (m2 & (r >> 16)) | ((m2 & r) << 16);
            r = (m1 & (r >> 32)) | ((m1 & r) << 32);
            r = (m0 & (r >> 64)) | ((m0 & r) << 64);
            r = (r >> 128) | (r << 128);
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BOOLEAN OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A Solidity bool on the stack or memory is represented as a 256-bit word.
    // Non-zero values are true, zero is false.
    // A clean bool is either 0 (false) or 1 (true) under the hood.
    // Usually, if not always, the bool result of a regular Solidity expression,
    // or the argument of a public/external function will be a clean bool.
    // You can usually use the raw variants for more performance.
    // If uncertain, test (best with exact compiler settings).
    // Or use the non-raw variants (compiler can sometimes optimize out the double `iszero`s).

    /// @dev Returns `x & y`. Inputs must be clean.
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(x, y)
        }
    }

    /// @dev Returns `x & y`.
    function and(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns `x | y`. Inputs must be clean.
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(x, y)
        }
    }

    /// @dev Returns `x | y`.
    function or(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns 1 if `b` is true, else 0. Input must be clean.
    function rawToUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := b
        }
    }

    /// @dev Returns 1 if `b` is true, else 0.
    function toUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {LibBit} from "./LibBit.sol";

/// @notice Library for storage of packed unsigned booleans.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibBitmap.sol)
/// @author Modified from Solidity-Bits (https://github.com/estarriolvetch/solidity-bits/blob/main/contracts/BitMaps.sol)
library LibBitmap {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when a bitmap scan does not find a result.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A bitmap in storage.
    struct Bitmap {
        mapping(uint256 => uint256) map;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         OPERATIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the boolean value of the bit at `index` in `bitmap`.
    function get(Bitmap storage bitmap, uint256 index) internal view returns (bool isSet) {
        // It is better to set `isSet` to either 0 or 1, than zero vs non-zero.
        // Both cost the same amount of gas, but the former allows the returned value
        // to be reused without cleaning the upper bits.
        uint256 b = (bitmap.map[index >> 8] >> (index & 0xff)) & 1;
        /// @solidity memory-safe-assembly
        assembly {
            isSet := b
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to true.
    function set(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] |= (1 << (index & 0xff));
    }

    /// @dev Updates the bit at `index` in `bitmap` to false.
    function unset(Bitmap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
    }

    /// @dev Flips the bit at `index` in `bitmap`.
    /// Returns the boolean result of the flipped bit.
    function toggle(Bitmap storage bitmap, uint256 index) internal returns (bool newIsSet) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let shift := and(index, 0xff)
            let storageValue := xor(sload(storageSlot), shl(shift, 1))
            // It makes sense to return the `newIsSet`,
            // as it allow us to skip an additional warm `sload`,
            // and it costs minimal gas (about 15),
            // which may be optimized away if the returned value is unused.
            newIsSet := and(1, shr(shift, storageValue))
            sstore(storageSlot, storageValue)
        }
    }

    /// @dev Updates the bit at `index` in `bitmap` to `shouldSet`.
    function setTo(Bitmap storage bitmap, uint256 index, bool shouldSet) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, index))
            let storageSlot := keccak256(0x00, 0x40)
            let storageValue := sload(storageSlot)
            let shift := and(index, 0xff)
            sstore(
                storageSlot,
                // Unsets the bit at `shift` via `and`, then sets its new value via `or`.
                or(and(storageValue, not(shl(shift, 1))), shl(shift, iszero(iszero(shouldSet))))
            )
        }
    }

    /// @dev Consecutively sets `amount` of bits starting from the bit at `start`.
    function setBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, or(sload(storageSlot), shl(shift, max)))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), max)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(storageSlot, or(sload(storageSlot), shl(shift, shr(sub(256, amount), max))))
        }
    }

    /// @dev Consecutively unsets `amount` of bits starting from the bit at `start`.
    function unsetBatch(Bitmap storage bitmap, uint256 start, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let shift := and(start, 0xff)
            mstore(0x20, bitmap.slot)
            mstore(0x00, shr(8, start))
            if iszero(lt(add(shift, amount), 257)) {
                let storageSlot := keccak256(0x00, 0x40)
                sstore(storageSlot, and(sload(storageSlot), not(shl(shift, not(0)))))
                let bucket := add(mload(0x00), 1)
                let bucketEnd := add(mload(0x00), shr(8, add(amount, shift)))
                amount := and(add(amount, shift), 0xff)
                shift := 0
                for {} iszero(eq(bucket, bucketEnd)) { bucket := add(bucket, 1) } {
                    mstore(0x00, bucket)
                    sstore(keccak256(0x00, 0x40), 0)
                }
                mstore(0x00, bucket)
            }
            let storageSlot := keccak256(0x00, 0x40)
            sstore(
                storageSlot, and(sload(storageSlot), not(shl(shift, shr(sub(256, amount), not(0)))))
            )
        }
    }

    /// @dev Returns number of set bits within a range by
    /// scanning `amount` of bits starting from the bit at `start`.
    function popCount(Bitmap storage bitmap, uint256 start, uint256 amount)
        internal
        view
        returns (uint256 count)
    {
        unchecked {
            uint256 bucket = start >> 8;
            uint256 shift = start & 0xff;
            if (!(amount + shift < 257)) {
                count = LibBit.popCount(bitmap.map[bucket] >> shift);
                uint256 bucketEnd = bucket + ((amount + shift) >> 8);
                amount = (amount + shift) & 0xff;
                shift = 0;
                for (++bucket; bucket != bucketEnd; ++bucket) {
                    count += LibBit.popCount(bitmap.map[bucket]);
                }
            }
            count += LibBit.popCount((bitmap.map[bucket] >> shift) << (256 - amount));
        }
    }

    /// @dev Returns the index of the most significant set bit before the bit at `before`.
    /// If no set bit is found, returns `NOT_FOUND`.
    function findLastSet(Bitmap storage bitmap, uint256 before)
        internal
        view
        returns (uint256 setBitIndex)
    {
        uint256 bucket;
        uint256 bucketBits;
        /// @solidity memory-safe-assembly
        assembly {
            setBitIndex := not(0)
            bucket := shr(8, before)
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, not(before)) // `256 - (255 & before) - 1`.
            bucketBits := shr(offset, shl(offset, sload(keccak256(0x00, 0x40))))
            if iszero(or(bucketBits, iszero(bucket))) {
                for {} 1 {} {
                    bucket := add(bucket, setBitIndex) // `sub(bucket, 1)`.
                    mstore(0x00, bucket)
                    bucketBits := sload(keccak256(0x00, 0x40))
                    if or(bucketBits, iszero(bucket)) { break }
                }
            }
        }
        if (bucketBits != 0) {
            setBitIndex = (bucket << 8) | LibBit.fls(bucketBits);
            /// @solidity memory-safe-assembly
            assembly {
                setBitIndex := or(setBitIndex, sub(0, gt(setBitIndex, before)))
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Library for generating pseudorandom numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibPRNG.sol)
library LibPRNG {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev A pseudorandom number state in memory.
    struct PRNG {
        uint256 state;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         OPERATIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Seeds the `prng` with `state`.
    function seed(PRNG memory prng, uint256 state) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(prng, state)
        }
    }

    /// @dev Returns the next pseudorandom uint256.
    /// All bits of the returned uint256 pass the NIST Statistical Test Suite.
    function next(PRNG memory prng) internal pure returns (uint256 result) {
        // We simply use `keccak256` for a great balance between
        // runtime gas costs, bytecode size, and statistical properties.
        //
        // A high-quality LCG with a 32-byte state
        // is only about 30% more gas efficient during runtime,
        // but requires a 32-byte multiplier, which can cause bytecode bloat
        // when this function is inlined.
        //
        // Using this method is about 2x more efficient than
        // `nextRandomness = uint256(keccak256(abi.encode(randomness)))`.
        /// @solidity memory-safe-assembly
        assembly {
            result := keccak256(prng, 0x20)
            mstore(prng, result)
        }
    }

    /// @dev Returns a pseudorandom uint256, uniformly distributed
    /// between 0 (inclusive) and `upper` (exclusive).
    /// If your modulus is big, this method is recommended
    /// for uniform sampling to avoid modulo bias.
    /// For uniform sampling across all uint256 values,
    /// or for small enough moduli such that the bias is neligible,
    /// use {next} instead.
    function uniform(PRNG memory prng, uint256 upper) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := keccak256(prng, 0x20)
                mstore(prng, result)
                if iszero(lt(result, mod(sub(0, upper), upper))) { break }
            }
            result := mod(result, upper)
        }
    }

    /// @dev Shuffles the array in-place with Fisher-Yates shuffle.
    function shuffle(PRNG memory prng, uint256[] memory a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(a)
            let w := not(0)
            let mask := shr(128, w)
            if n {
                for { a := add(a, 0x20) } 1 {} {
                    // We can just directly use `keccak256`, cuz
                    // the other approaches don't save much.
                    let r := keccak256(prng, 0x20)
                    mstore(prng, r)

                    // Note that there will be a very tiny modulo bias
                    // if the length of the array is not a power of 2.
                    // For all practical purposes, it is negligible
                    // and will not be a fairness or security concern.
                    {
                        let j := add(a, shl(5, mod(shr(128, r), n)))
                        n := add(n, w) // `sub(n, 1)`.
                        if iszero(n) { break }

                        let i := add(a, shl(5, n))
                        let t := mload(i)
                        mstore(i, mload(j))
                        mstore(j, t)
                    }

                    {
                        let j := add(a, shl(5, mod(and(r, mask), n)))
                        n := add(n, w) // `sub(n, 1)`.
                        if iszero(n) { break }

                        let i := add(a, shl(5, n))
                        let t := mload(i)
                        mstore(i, mload(j))
                        mstore(j, t)
                    }
                }
            }
        }
    }

    /// @dev Shuffles the bytes in-place with Fisher-Yates shuffle.
    function shuffle(PRNG memory prng, bytes memory a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(a)
            let w := not(0)
            let mask := shr(128, w)
            if n {
                let b := add(a, 0x01)
                for { a := add(a, 0x20) } 1 {} {
                    // We can just directly use `keccak256`, cuz
                    // the other approaches don't save much.
                    let r := keccak256(prng, 0x20)
                    mstore(prng, r)

                    // Note that there will be a very tiny modulo bias
                    // if the length of the array is not a power of 2.
                    // For all practical purposes, it is negligible
                    // and will not be a fairness or security concern.
                    {
                        let o := mod(shr(128, r), n)
                        n := add(n, w) // `sub(n, 1)`.
                        if iszero(n) { break }

                        let t := mload(add(b, n))
                        mstore8(add(a, n), mload(add(b, o)))
                        mstore8(add(a, o), t)
                    }

                    {
                        let o := mod(and(r, mask), n)
                        n := add(n, w) // `sub(n, 1)`.
                        if iszero(n) { break }

                        let t := mload(add(b, n))
                        mstore8(add(a, n), mload(add(b, o)))
                        mstore8(add(a, o), t)
                    }
                }
            }
        }
    }

    /// @dev Returns a sample from the standard normal distribution denominated in `WAD`.
    function standardNormalWad(PRNG memory prng) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Technically, this is the Irwin-Hall distribution with 20 samples.
            // The chance of drawing a sample outside 10 σ from the standard normal distribution
            // is ≈ 0.000000000000000000000015, which is insignificant for most practical purposes.
            // Passes the Kolmogorov-Smirnov test for 200k samples. Uses about 322 gas.
            result := keccak256(prng, 0x20)
            mstore(prng, result)
            let n := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff43 // Prime.
            let a := 0x100000000000000000000000000000051 // Prime and a primitive root of `n`.
            let m := 0x1fffffffffffffff1fffffffffffffff1fffffffffffffff1fffffffffffffff
            let s := 0x1000000000000000100000000000000010000000000000001
            let r1 := mulmod(result, a, n)
            let r2 := mulmod(r1, a, n)
            let r3 := mulmod(r2, a, n)
            // forgefmt: disable-next-item
            result := sub(sar(96, mul(26614938895861601847173011183,
                add(add(shr(192, mul(s, add(and(m, result), and(m, r1)))),
                shr(192, mul(s, add(and(m, r2), and(m, r3))))),
                shr(192, mul(s, and(m, mulmod(r3, a, n))))))), 7745966692414833770)
        }
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
    function toHexStringChecksummed(address value) internal pure returns (string memory str) {
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
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
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
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
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
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
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
            let last := add(add(result, 0x20), k) // Zeroize the slot after the string.
            mstore(last, 0)
            mstore(0x40, add(last, 0x20)) // Allocate the memory.
            mstore(result, k) // Store the length.
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

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
                let s := mload(add(search, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }

                if iszero(lt(searchLength, 0x20)) {
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

    /// @dev Returns true if `search` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory search) internal pure returns (bool) {
        return indexOf(subject, search) != NOT_FOUND;
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
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let o := and(add(resultLength, 0x1f), w) } 1 {} {
                    mstore(add(result, o), mload(add(subject, o)))
                    o := add(o, w) // `sub(o, 0x20)`.
                    if iszero(o) { break }
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
                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }
                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))
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
            let w := not(0x1f)
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
                    for { let o := and(add(elementLength, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
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
            let w := not(0x1f)
            result := mload(0x40)
            let aLength := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLength, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLength := mload(b)
            let output := add(result, aLength)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLength, 0x20), w) } 1 {} {
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
            mstore(0x40, and(add(last, 0x1f), w))
        }
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
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
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(subject, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
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
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
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
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
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
            for {} iszero(eq(s, end)) {} {
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
    function escapeJSON(string memory s, bool addDoubleQuotes)
        internal
        pure
        returns (string memory result)
    {
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
            for {} iszero(eq(s, end)) {} {
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
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
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
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
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

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}