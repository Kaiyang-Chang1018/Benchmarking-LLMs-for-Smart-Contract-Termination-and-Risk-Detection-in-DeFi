// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

interface BlacklistEvents {
    /// @dev Emitted when `account` is blacklisted
    event Blacklisted(address indexed account);

    /// @dev Emitted when `account` is removed from the blacklist
    event Unblacklisted(address indexed account);
}

abstract contract Blacklist is BlacklistEvents, Context {
    /// @dev maps if an address has been blacklisted
    mapping(address => bool) private _blacklist;

    constructor() {}

    /// @dev only allows non-blacklisted addresses to call a function
    modifier onlyNotBlacklisted() {
        require(!isBlacklisted(_msgSender()), "Blacklist: caller is blacklisted");
        _;
    }

    /// @dev add address to blacklist
    function _addBlacklist(address account) internal virtual {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    /// @dev remove address from blacklist
    function _removeBlacklist(address account) internal virtual {
        _blacklist[account] = false;
        emit Unblacklisted(account);
    }

    /// @dev checks if address is blacklisted
    function isBlacklisted(address account) public view virtual returns (bool) {
        return _blacklist[account];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Blacklist} from "./Blacklist.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/ABDKMathQuad.sol";
import "./interfaces/IMinter.sol";

contract DutchAuctionMinter is Pausable, AccessControl, Blacklist, ReentrancyGuard {

    /// minterType for this minter
    string public constant minterType = "DutchAuctionMinter";
    
    bytes16 public HalfPeriod;
    bytes16 public BaseValue;

    // @notice Amount of time in seconds after each price drops
    uint256 public priceDropSlot;

    // @notice Role for pausing the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice ERC-721 pass contract whose tokens are minted by this auction
    /// @dev Must implement mint(address)
    IMinter public passes;

    /// @notice ERC-721 pass contract, which tokens needed to mint passes
    IERC721 public mintPasses;

    /// @notice Minimum amount of mint passes to mint pass
    uint256 public minMintPasses;

    /// @notice Timestamp when this auction starts allowing minting
    uint256 public startTime;

    /// @notice Starting price for the Dutch auction
    uint256 public startPrice;

    /// @notice Resting price where price descent ends
    uint256 public restPrice;

    /// @notice time of half period
    uint256 public halfPeriod;

    /// @notice total amount of minted passes
    uint256 public totalSupply;

    /// @notice maximum amount of passes which can be minted
    uint256 public maxMint;

    mapping(address => uint256) public mintCount;

    uint256 private pauseStart;
    uint256 private pastPauseDelay;

    address public beneficiary;

    uint256 public projectId;

    /// @notice Determines if users without mint passes can mint item
    bool public mintPublic;

    /// @notice An event to be emitted upon pass purchases for the benefit of the UI
    event Purchase(address purchaser, uint256 tokenId, uint256 price);

    /// @notice An event emitted when mint being open for everyone or not.
    /// @dev open - true if mint open for everyone, false if not
    event MintPublicUpdated(bool open);

    /// @notice An event emitted when mint passes contract changed
    /// @dev newMintPasses - address of new mint passes contract
    event MintPassesUpdated(address newMintPasses);

    /// @notice An error returned when the auction has already started.
    error AlreadyStarted();
    /// @notice An error returned when the auction has not yet started.
    error NotYetStarted();
    /// @notice An error returned when funds transfer was not passed.
    error FailedPaying(address payee, bytes data);
    /// @notice An error returned when minting is not available for user.
    /// (mint not yet open for everyone and user don't have enough mint passes)
    error MintNotAvailable();

    constructor(
        IMinter passes_,
        IERC721 mintPasses_,
        uint256 startTime_,
        uint256 startPrice_,
        uint256 restPrice_,
        uint256 priceDropSlot_,
        uint256 halfPeriod_,
        uint256 maxMint_,
        uint256 minMintPasses_,
        uint256 projectId_,
        address beneficiary_,
        address pauser
    ) {
        // CHECKS inputs
        require(address(passes_) != address(0), "Pass contract must not be the zero address");
        require(address(mintPasses_) != address(0), "Mint pass contract must not be the zero address");
        // require(passes_.supportsInterface(0x6a627842), "Pass contract must implement mint(address)"); // TODO: fix support of manifold mitner
        require(startTime_ >= block.timestamp, "Start time cannot be in the past");

        require(startPrice_ > 1e15, "Start price too low: check that prices are in wei");
        require(restPrice_ > 1e15, "Rest price too low: check that prices are in wei");
        require(startPrice_ >= restPrice_, "Start price must not be lower than rest price");
        require(priceDropSlot_ > 0, "Price drop slot must be greater than 0");
        require(halfPeriod_ > 0, "Half period must be greater than 0");
        require(minMintPasses_ > 0, "Minimum mint passes must be greater than 0");
        require(beneficiary_ != address(0), "Beneficiary must not be the zero address");
        require(maxMint_ > 0, "Max mint must be greater than 0");

        // EFFECTS
        passes = passes_;
        startTime = startTime_;
        startPrice = startPrice_;
        restPrice = restPrice_;
        priceDropSlot = priceDropSlot_;
        halfPeriod = halfPeriod_;
        maxMint = maxMint_;
        beneficiary = beneficiary_;
        mintPasses = mintPasses_;
        minMintPasses = minMintPasses_;
        projectId = projectId_;

        HalfPeriod = ABDKMathQuad.fromUInt(halfPeriod);
        BaseValue = ABDKMathQuad.fromUInt(startPrice);


        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, pauser);
    }

    modifier started() {
        if (!isStarted()) revert NotYetStarted();
        _;
    }

    modifier unstarted() {
        if (isStarted()) revert AlreadyStarted();
        _;
    }

    // PUBLIC FUNCTIONS

    /// @notice Mint a pass on the `passes` contract. Must include at least `currentPrice`.
    function mint() external payable started whenNotPaused onlyNotBlacklisted nonReentrant {
        // CHECKS inputs
        uint256 price = msg.value;
        uint256 cPrice = currentPrice();
        require(price >= cPrice, "Insufficient payment");
        require(totalSupply < maxMint, "Maximum mint reached");

        if (!mintPublic && mintPasses.balanceOf(msg.sender) < minMintPasses) {
            revert MintNotAvailable();
        }

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: mintCount cannot exceed maxMint
            mintCount[msg.sender]++;
        }

        // EFFECTS + INTERACTIONS: call mint on known contract (passes.mint contains no external interactions)
        totalSupply++;
        uint256 id = passes.mint(msg.sender, projectId, msg.sender);

        emit Purchase(msg.sender, id, cPrice);

        refundIfOver(cPrice);
    }

    /// @notice Mint up to three passes on the `passes` contract. Must include at least `currentPrice` * `quantity`.
    /// @param quantity The number of passes to mint: must be 1, 2, or 3
    function mintMultiple(uint256 quantity) external payable started whenNotPaused onlyNotBlacklisted nonReentrant {
        // CHECKS inputs
        uint256 alreadyMinted = mintCount[msg.sender];
        require(quantity > 0, "Must mint at least one pass");
        uint256 payment = msg.value;
        uint256 price = payment / quantity;
        uint256 cPrice = currentPrice();
        require(price >= cPrice, "Insufficient payment");
        require(totalSupply + quantity <= maxMint, "Maximum mint reached");

        if (!mintPublic && mintPasses.balanceOf(msg.sender) < minMintPasses) {
            revert MintNotAvailable();
        }

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: totalSupply cannot exceed max mint
            totalSupply = totalSupply + quantity;
            // Unchecked arithmetic: mintCount cannot exceed totalSupply and maxMint
            mintCount[msg.sender] = alreadyMinted + quantity;
        }

        // EFFECTS + INTERACTIONS: call mint on known contract (passes.mint contains no external interactions)
        // One call without try/catch to make sure at least one is minted.
        for (uint256 i = 0; i < quantity; i++) {
            uint256 id = passes.mint(msg.sender, projectId, msg.sender);
            emit Purchase(msg.sender, id, cPrice);
        }

        refundIfOver(cPrice * quantity);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    // OWNER FUNCTIONS

    function setProjectId(uint256 projectId_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        projectId = projectId_;
    }

    /// @notice Update the passes contract address
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setPasses(IMinter passes_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(address(passes_) != address(0), "Pass contract must not be the zero address");
        // require(passes_.supportsInterface(0x6a627842), "Pass contract must support mint(address)"); // TODO
        // EFFECTS
        passes = passes_;
    }

    /// @notice Pause this contract
    /// @dev Can only be called by the contract `owner`
    function pause() public onlyRole(PAUSER_ROLE) {
        // CHECKS + EFFECTS: `Pausable` handles checking permissions and setting pause state
        super._pause();
        // More EFFECTS
        pauseStart = block.timestamp;
    }

    /// @notice Resume this contract
    /// @dev Can only be called by the contract `owner`. Pricing tiers will pick up where they left off.
    function unpause() public onlyRole(PAUSER_ROLE) {
        // CHECKS + EFFECTS: `Pausable` handles checking permissions and setting pause state
        super._unpause();
        // More EFFECTS
        if (block.timestamp <= startTime) {
            return;
        }
        // Find the amount time the auction should have been live, but was paused
        unchecked {
            // Unchecked arithmetic: computed value will be < block.timestamp and >= 0
            if (pauseStart < startTime) {
                pastPauseDelay = block.timestamp - startTime;
            } else {
                pastPauseDelay += (block.timestamp - pauseStart);
            }
        }
    }

    /// @notice adds an address to blacklist blocking them from minting
    /// @dev Can only be called by the contract `owner`.
    /// @param account The address to add to the blacklist
    function addBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _addBlacklist(account);
    }

    /// @notice removes an address from blacklist allowing them to once again mint
    /// @dev Can only be called by the contract `owner`.
    /// @param account The address to removed to the blacklist
    function removeBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _removeBlacklist(account);
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 balanceAvailable = address(this).balance;
        (bool success, bytes memory data) = beneficiary.call{value: balanceAvailable}("");
        if (!success) revert FailedPaying(beneficiary, data);
    }

    /// @notice Update the auction start time
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setStartTime(uint256 startTime_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(startTime_ >= block.timestamp, "New start time cannot be in the past");
        // EFFECTS
        startTime = startTime_;
    }

    /// @notice Update the auction start time
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setMaxMint(uint256 maxMint_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(maxMint_ > 0, "Max mint must be greater than 0");
        // EFFECTS
        maxMint = maxMint_;
    }

    ///@notice Update the minimum number of passes required to mint
    ///@dev Can only be called by the contract `owner`.
    function setMinMintPasses(uint256 minMintPasses_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(minMintPasses_ > 0, "Min mint passes must be greater than 0");
        // EFFECTS
        minMintPasses = minMintPasses_;
    }

    /// @notice Update the auction price range and rate of decrease
    /// @dev Since the values are validated against each other, they are all set together. Can only be called by the
    ///  contract `owner`. Reverts if the auction has already started.
    function setPriceRange(uint256 startPrice_, uint256 restPrice_, uint256 priceDropSlot_, uint256 halfPeriod_)
        external
        unstarted
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // CHECKS inputs
        require(startPrice_ > 1e15, "Start price too low: check that prices are in wei");
        require(restPrice_ > 1e15, "Rest price too low: check that prices are in wei");
        require(startPrice_ >= restPrice_, "Start price must not be lower than rest price");
        require(priceDropSlot_ > 0, "Price drop slot must be greater than 0");
        require(halfPeriod_ > 0, "Half period must be greater than 0");

        // EFFECTS
        startPrice = startPrice_;
        restPrice = restPrice_;
        priceDropSlot = priceDropSlot_;
        halfPeriod = halfPeriod_;

        HalfPeriod = ABDKMathQuad.fromUInt(halfPeriod);
        BaseValue = ABDKMathQuad.fromUInt(startPrice);
    }

    function setMintPasses(IERC721 mintPasses_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintPasses = mintPasses_;
        emit MintPassesUpdated(address(mintPasses));
    }

    function setMintPublic(bool mintPublic_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintPublic = mintPublic_;
        emit MintPublicUpdated(mintPublic);
    }

    // VIEW FUNCTIONS

    /// @notice Query the current price
    function currentPrice() public view returns (uint256) {
        uint256 time = timeElapsed();
        unchecked {
            time = (time / priceDropSlot) * priceDropSlot;
        }

        //function fromUInt (uint256 x) internal pure returns (bytes16)
        bytes16 currentTime = ABDKMathQuad.fromUInt(time);

        //first: currentTime / half period
        bytes16 step0 = ABDKMathQuad.div(currentTime, HalfPeriod);

        //second: pow_2
        bytes16 step1 = ABDKMathQuad.pow_2(step0);

        //then: startPrice / step1
        bytes16 step2 = ABDKMathQuad.div(BaseValue, step1);

        //last
        uint256 value = ABDKMathQuad.toUInt(step2);

        if (value < restPrice) {
            value = restPrice;
        }

        return value;
    }

    /// @notice Returns time of total decay period
    function decayTime() public view returns (uint256) {
        bytes16 step0 = ABDKMathQuad.log_2(BaseValue);
        bytes16 step1 = ABDKMathQuad.log_2(ABDKMathQuad.fromUInt(restPrice));

        bytes16 result = ABDKMathQuad.mul(HalfPeriod, ABDKMathQuad.sub(step0, step1));
        uint256 t = ABDKMathQuad.toUInt(result);
        unchecked {
            //padding 10
            t = ((t + 10) / 10) * 10;
        }

        return t;
    }

    /// @notice Returns timestamp of next price drop
    function nextPriceDrop() public view returns (uint256) {
        if (!isStarted()) return startTime + priceDropSlot;

        uint256 timeUntilNextDrop = priceDropSlot - (timeElapsed() % priceDropSlot);

        return block.timestamp + timeUntilNextDrop;
    }

    function endTime() public view returns (uint256) {
        return startTime + decayTime() + pastPauseDelay;
    }

    function isStarted() internal view returns (bool) {
        return (paused() ? pauseStart : block.timestamp) >= startTime;
    }

    function timeElapsed() internal view returns (uint256) {
        if (!isStarted()) return 0;
        unchecked {
            // pastPauseDelay cannot be greater than the time passed since startTime.
            if (!paused()) {
                return block.timestamp - startTime - pastPauseDelay;
            }

            // pastPauseDelay cannot be greater than the time between startTime and pauseStart.
            return pauseStart - startTime - pastPauseDelay;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IMinter {
    function mint(address _to, uint256 _projectId, address sender) external returns (uint256 _tokenId);
}
// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.8.17;

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */
library ABDKMathQuad {
    /*
    * 0.
    */
    bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

    /*
    * -0.
    */
    bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

    /*
    * +Infinity.
    */
    bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

    /*
    * -Infinity.
    */
    bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

    /*
    * Canonical NaN value.
    */
    bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

    /**
     * Convert signed 256-bit integer number into quadruple precision number.
     *
     * @param x signed 256-bit integer number
     * @return quadruple precision number
     */
    function fromInt(int256 x) internal pure returns (bytes16) {
        unchecked {
            if (x == 0) {
                return bytes16(0);
            } else {
                // We rely on overflow behavior here
                uint256 result = uint256(x > 0 ? x : -x);

                uint256 msb = mostSignificantBit(result);
                if (msb < 112) result <<= 112 - msb;
                else if (msb > 112) result >>= msb - 112;

                result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
                if (x < 0) result |= 0x80000000000000000000000000000000;

                return bytes16(uint128(result));
            }
        }
    }

    /**
     * Convert quadruple precision number into signed 256-bit integer number
     * rounding towards zero.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 256-bit integer number
     */
    function toInt(bytes16 x) internal pure returns (int256) {
        unchecked {
            uint256 exponent = uint128(x) >> 112 & 0x7FFF;

            require(exponent <= 16638); // Overflow
            if (exponent < 16383) return 0; // Underflow

            uint256 result = uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 0x10000000000000000000000000000;

            if (exponent < 16495) result >>= 16495 - exponent;
            else if (exponent > 16495) result <<= exponent - 16495;

            if (uint128(x) >= 0x80000000000000000000000000000000) {
                // Negative
                require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256(result); // We rely on overflow behavior here
            } else {
                require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256(result);
            }
        }
    }

    /**
     * Convert unsigned 256-bit integer number into quadruple precision number.
     *
     * @param x unsigned 256-bit integer number
     * @return quadruple precision number
     */
    function fromUInt(uint256 x) internal pure returns (bytes16) {
        unchecked {
            if (x == 0) {
                return bytes16(0);
            } else {
                uint256 result = x;

                uint256 msb = mostSignificantBit(result);
                if (msb < 112) result <<= 112 - msb;
                else if (msb > 112) result >>= msb - 112;

                result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

                return bytes16(uint128(result));
            }
        }
    }

    /**
     * Convert quadruple precision number into unsigned 256-bit integer number
     * rounding towards zero.  Revert on underflow.  Note, that negative floating
     * point numbers in range (-1.0 .. 0.0) may be converted to unsigned integer
     * without error, because they are rounded to zero.
     *
     * @param x quadruple precision number
     * @return unsigned 256-bit integer number
     */
    function toUInt(bytes16 x) internal pure returns (uint256) {
        unchecked {
            uint256 exponent = uint128(x) >> 112 & 0x7FFF;

            if (exponent < 16383) return 0; // Underflow

            require(uint128(x) < 0x80000000000000000000000000000000); // Negative

            require(exponent <= 16638); // Overflow
            uint256 result = uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 0x10000000000000000000000000000;

            if (exponent < 16495) result >>= 16495 - exponent;
            else if (exponent > 16495) result <<= exponent - 16495;

            return result;
        }
    }

    /**
     * Convert signed 128.128 bit fixed point number into quadruple precision
     * number.
     *
     * @param x signed 128.128 bit fixed point number
     * @return quadruple precision number
     */
    function from128x128(int256 x) internal pure returns (bytes16) {
        unchecked {
            if (x == 0) {
                return bytes16(0);
            } else {
                // We rely on overflow behavior here
                uint256 result = uint256(x > 0 ? x : -x);

                uint256 msb = mostSignificantBit(result);
                if (msb < 112) result <<= 112 - msb;
                else if (msb > 112) result >>= msb - 112;

                result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
                if (x < 0) result |= 0x80000000000000000000000000000000;

                return bytes16(uint128(result));
            }
        }
    }

    /**
     * Convert quadruple precision number into signed 128.128 bit fixed point
     * number.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 128.128 bit fixed point number
     */
    function to128x128(bytes16 x) internal pure returns (int256) {
        unchecked {
            uint256 exponent = uint128(x) >> 112 & 0x7FFF;

            require(exponent <= 16510); // Overflow
            if (exponent < 16255) return 0; // Underflow

            uint256 result = uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 0x10000000000000000000000000000;

            if (exponent < 16367) result >>= 16367 - exponent;
            else if (exponent > 16367) result <<= exponent - 16367;

            if (uint128(x) >= 0x80000000000000000000000000000000) {
                // Negative
                require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256(result); // We rely on overflow behavior here
            } else {
                require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256(result);
            }
        }
    }

    /**
     * Convert signed 64.64 bit fixed point number into quadruple precision
     * number.
     *
     * @param x signed 64.64 bit fixed point number
     * @return quadruple precision number
     */
    function from64x64(int128 x) internal pure returns (bytes16) {
        unchecked {
            if (x == 0) {
                return bytes16(0);
            } else {
                // We rely on overflow behavior here
                uint256 result = uint128(x > 0 ? x : -x);

                uint256 msb = mostSignificantBit(result);
                if (msb < 112) result <<= 112 - msb;
                else if (msb > 112) result >>= msb - 112;

                result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
                if (x < 0) result |= 0x80000000000000000000000000000000;

                return bytes16(uint128(result));
            }
        }
    }

    /**
     * Convert quadruple precision number into signed 64.64 bit fixed point
     * number.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 64.64 bit fixed point number
     */
    function to64x64(bytes16 x) internal pure returns (int128) {
        unchecked {
            uint256 exponent = uint128(x) >> 112 & 0x7FFF;

            require(exponent <= 16446); // Overflow
            if (exponent < 16319) return 0; // Underflow

            uint256 result = uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 0x10000000000000000000000000000;

            if (exponent < 16431) result >>= 16431 - exponent;
            else if (exponent > 16431) result <<= exponent - 16431;

            if (uint128(x) >= 0x80000000000000000000000000000000) {
                // Negative
                require(result <= 0x80000000000000000000000000000000);
                return -int128(int256(result)); // We rely on overflow behavior here
            } else {
                require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128(int256(result));
            }
        }
    }

    /**
     * Convert octuple precision number into quadruple precision number.
     *
     * @param x octuple precision number
     * @return quadruple precision number
     */
    function fromOctuple(bytes32 x) internal pure returns (bytes16) {
        unchecked {
            bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

            uint256 exponent = uint256(x) >> 236 & 0x7FFFF;
            uint256 significand = uint256(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (exponent == 0x7FFFF) {
                if (significand > 0) return NaN;
                else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            }

            if (exponent > 278526) {
                return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            } else if (exponent < 245649) {
                return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
            } else if (exponent < 245761) {
                significand =
                    (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
                exponent = 0;
            } else {
                significand >>= 124;
                exponent -= 245760;
            }

            uint128 result = uint128(significand | exponent << 112);
            if (negative) result |= 0x80000000000000000000000000000000;

            return bytes16(result);
        }
    }

    /**
     * Convert quadruple precision number into octuple precision number.
     *
     * @param x quadruple precision number
     * @return octuple precision number
     */
    function toOctuple(bytes16 x) internal pure returns (bytes32) {
        unchecked {
            uint256 exponent = uint128(x) >> 112 & 0x7FFF;

            uint256 result = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (exponent == 0x7FFF) {
                exponent = 0x7FFFF;
            } // Infinity or NaN
            else if (exponent == 0) {
                if (result > 0) {
                    uint256 msb = mostSignificantBit(result);
                    result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    exponent = 245649 + msb;
                }
            } else {
                result <<= 124;
                exponent += 245760;
            }

            result |= exponent << 236;
            if (uint128(x) >= 0x80000000000000000000000000000000) {
                result |= 0x8000000000000000000000000000000000000000000000000000000000000000;
            }

            return bytes32(result);
        }
    }

    /**
     * Convert double precision number into quadruple precision number.
     *
     * @param x double precision number
     * @return quadruple precision number
     */
    function fromDouble(bytes8 x) internal pure returns (bytes16) {
        unchecked {
            uint256 exponent = uint64(x) >> 52 & 0x7FF;

            uint256 result = uint64(x) & 0xFFFFFFFFFFFFF;

            if (exponent == 0x7FF) {
                exponent = 0x7FFF;
            } // Infinity or NaN
            else if (exponent == 0) {
                if (result > 0) {
                    uint256 msb = mostSignificantBit(result);
                    result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    exponent = 15309 + msb;
                }
            } else {
                result <<= 60;
                exponent += 15360;
            }

            result |= exponent << 112;
            if (x & 0x8000000000000000 > 0) {
                result |= 0x80000000000000000000000000000000;
            }

            return bytes16(uint128(result));
        }
    }

    /**
     * Convert quadruple precision number into double precision number.
     *
     * @param x quadruple precision number
     * @return double precision number
     */
    function toDouble(bytes16 x) internal pure returns (bytes8) {
        unchecked {
            bool negative = uint128(x) >= 0x80000000000000000000000000000000;

            uint256 exponent = uint128(x) >> 112 & 0x7FFF;
            uint256 significand = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (exponent == 0x7FFF) {
                if (significand > 0) {
                    return 0x7FF8000000000000;
                } // NaN
                else {
                    return negative
                        ? bytes8(0xFFF0000000000000) // -Infinity
                        : bytes8(0x7FF0000000000000);
                } // Infinity
            }

            if (exponent > 17406) {
                return negative
                    ? bytes8(0xFFF0000000000000) // -Infinity
                    : bytes8(0x7FF0000000000000);
            } // Infinity
            else if (exponent < 15309) {
                return negative
                    ? bytes8(0x8000000000000000) // -0
                    : bytes8(0x0000000000000000);
            } // 0
            else if (exponent < 15361) {
                significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
                exponent = 0;
            } else {
                significand >>= 60;
                exponent -= 15360;
            }

            uint64 result = uint64(significand | exponent << 52);
            if (negative) result |= 0x8000000000000000;

            return bytes8(result);
        }
    }

    /**
     * Test whether given quadruple precision number is NaN.
     *
     * @param x quadruple precision number
     * @return true if x is NaN, false otherwise
     */
    function isNaN(bytes16 x) internal pure returns (bool) {
        unchecked {
            return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF > 0x7FFF0000000000000000000000000000;
        }
    }

    /**
     * Test whether given quadruple precision number is positive or negative
     * infinity.
     *
     * @param x quadruple precision number
     * @return true if x is positive or negative infinity, false otherwise
     */
    function isInfinity(bytes16 x) internal pure returns (bool) {
        unchecked {
            return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0x7FFF0000000000000000000000000000;
        }
    }

    /**
     * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
     * is positive.  Note that sign (-0) is zero.  Revert if x is NaN.
     *
     * @param x quadruple precision number
     * @return sign of x
     */
    function sign(bytes16 x) internal pure returns (int8) {
        unchecked {
            uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

            if (absoluteX == 0) return 0;
            else if (uint128(x) >= 0x80000000000000000000000000000000) return -1;
            else return 1;
        }
    }

    /**
     * Calculate sign (x - y).  Revert if either argument is NaN, or both
     * arguments are infinities of the same sign.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return sign (x - y)
     */
    function cmp(bytes16 x, bytes16 y) internal pure returns (int8) {
        unchecked {
            uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

            uint128 absoluteY = uint128(y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            require(absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

            // Not infinities of the same sign
            require(x != y || absoluteX < 0x7FFF0000000000000000000000000000);

            if (x == y) {
                return 0;
            } else {
                bool negativeX = uint128(x) >= 0x80000000000000000000000000000000;
                bool negativeY = uint128(y) >= 0x80000000000000000000000000000000;

                if (negativeX) {
                    if (negativeY) return absoluteX > absoluteY ? -1 : int8(1);
                    else return -1;
                } else {
                    if (negativeY) return 1;
                    else return absoluteX > absoluteY ? int8(1) : -1;
                }
            }
        }
    }

    /**
     * Test whether x equals y.  NaN, infinity, and -infinity are not equal to
     * anything.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return true if x equals to y, false otherwise
     */
    function eq(bytes16 x, bytes16 y) internal pure returns (bool) {
        unchecked {
            if (x == y) {
                return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF < 0x7FFF0000000000000000000000000000;
            } else {
                return false;
            }
        }
    }

    /**
     * Calculate x + y.  Special values behave in the following way:
     *
     * NaN + x = NaN for any x.
     * Infinity + x = Infinity for any finite x.
     * -Infinity + x = -Infinity for any finite x.
     * Infinity + Infinity = Infinity.
     * -Infinity + -Infinity = -Infinity.
     * Infinity + -Infinity = -Infinity + Infinity = NaN.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return quadruple precision number
     */
    function add(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        unchecked {
            uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
            uint256 yExponent = uint128(y) >> 112 & 0x7FFF;

            if (xExponent == 0x7FFF) {
                if (yExponent == 0x7FFF) {
                    if (x == y) return x;
                    else return NaN;
                } else {
                    return x;
                }
            } else if (yExponent == 0x7FFF) {
                return y;
            } else {
                bool xSign = uint128(x) >= 0x80000000000000000000000000000000;
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                bool ySign = uint128(y) >= 0x80000000000000000000000000000000;
                uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (yExponent == 0) yExponent = 1;
                else ySignifier |= 0x10000000000000000000000000000;

                if (xSignifier == 0) {
                    return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
                } else if (ySignifier == 0) {
                    return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
                } else {
                    int256 delta = int256(xExponent) - int256(yExponent);

                    if (xSign == ySign) {
                        if (delta > 112) {
                            return x;
                        } else if (delta > 0) {
                            ySignifier >>= uint256(delta);
                        } else if (delta < -112) {
                            return y;
                        } else if (delta < 0) {
                            xSignifier >>= uint256(-delta);
                            xExponent = yExponent;
                        }

                        xSignifier += ySignifier;

                        if (xSignifier >= 0x20000000000000000000000000000) {
                            xSignifier >>= 1;
                            xExponent += 1;
                        }

                        if (xExponent == 0x7FFF) {
                            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                        } else {
                            if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
                            else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                            return bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
                        }
                    } else {
                        if (delta > 0) {
                            xSignifier <<= 1;
                            xExponent -= 1;
                        } else if (delta < 0) {
                            ySignifier <<= 1;
                            xExponent = yExponent - 1;
                        }

                        if (delta > 112) ySignifier = 1;
                        else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256(delta - 1)) + 1;
                        else if (delta < -112) xSignifier = 1;
                        else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256(-delta - 1)) + 1;

                        if (xSignifier >= ySignifier) {
                            xSignifier -= ySignifier;
                        } else {
                            xSignifier = ySignifier - xSignifier;
                            xSign = ySign;
                        }

                        if (xSignifier == 0) {
                            return POSITIVE_ZERO;
                        }

                        uint256 msb = mostSignificantBit(xSignifier);

                        if (msb == 113) {
                            xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                            xExponent += 1;
                        } else if (msb < 112) {
                            uint256 shift = 112 - msb;
                            if (xExponent > shift) {
                                xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                                xExponent -= shift;
                            } else {
                                xSignifier <<= xExponent - 1;
                                xExponent = 0;
                            }
                        } else {
                            xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                        }

                        if (xExponent == 0x7FFF) {
                            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                        } else {
                            return bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
                        }
                    }
                }
            }
        }
    }

    /**
     * Calculate x - y.  Special values behave in the following way:
     *
     * NaN - x = NaN for any x.
     * Infinity - x = Infinity for any finite x.
     * -Infinity - x = -Infinity for any finite x.
     * Infinity - -Infinity = Infinity.
     * -Infinity - Infinity = -Infinity.
     * Infinity - Infinity = -Infinity - -Infinity = NaN.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return quadruple precision number
     */
    function sub(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        unchecked {
            return add(x, y ^ 0x80000000000000000000000000000000);
        }
    }

    /**
     * Calculate x * y.  Special values behave in the following way:
     *
     * NaN * x = NaN for any x.
     * Infinity * x = Infinity for any finite positive x.
     * Infinity * x = -Infinity for any finite negative x.
     * -Infinity * x = -Infinity for any finite positive x.
     * -Infinity * x = Infinity for any finite negative x.
     * Infinity * 0 = NaN.
     * -Infinity * 0 = NaN.
     * Infinity * Infinity = Infinity.
     * Infinity * -Infinity = -Infinity.
     * -Infinity * Infinity = -Infinity.
     * -Infinity * -Infinity = Infinity.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return quadruple precision number
     */
    function mul(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        unchecked {
            uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
            uint256 yExponent = uint128(y) >> 112 & 0x7FFF;

            if (xExponent == 0x7FFF) {
                if (yExponent == 0x7FFF) {
                    if (x == y) return x ^ y & 0x80000000000000000000000000000000;
                    else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
                    else return NaN;
                } else {
                    if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
                    else return x ^ y & 0x80000000000000000000000000000000;
                }
            } else if (yExponent == 0x7FFF) {
                if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
                else return y ^ x & 0x80000000000000000000000000000000;
            } else {
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (yExponent == 0) yExponent = 1;
                else ySignifier |= 0x10000000000000000000000000000;

                xSignifier *= ySignifier;
                if (xSignifier == 0) {
                    return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;
                }

                xExponent += yExponent;

                uint256 msb = xSignifier >= 0x200000000000000000000000000000000000000000000000000000000
                    ? 225
                    : xSignifier >= 0x100000000000000000000000000000000000000000000000000000000
                        ? 224
                        : mostSignificantBit(xSignifier);

                if (xExponent + msb < 16496) {
                    // Underflow
                    xExponent = 0;
                    xSignifier = 0;
                } else if (xExponent + msb < 16608) {
                    // Subnormal
                    if (xExponent < 16496) {
                        xSignifier >>= 16496 - xExponent;
                    } else if (xExponent > 16496) {
                        xSignifier <<= xExponent - 16496;
                    }
                    xExponent = 0;
                } else if (xExponent + msb > 49373) {
                    xExponent = 0x7FFF;
                    xSignifier = 0;
                } else {
                    if (msb > 112) {
                        xSignifier >>= msb - 112;
                    } else if (msb < 112) {
                        xSignifier <<= 112 - msb;
                    }

                    xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                    xExponent = xExponent + msb - 16607;
                }

                return bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | xExponent << 112 | xSignifier)
                );
            }
        }
    }

    /**
     * Calculate x / y.  Special values behave in the following way:
     *
     * NaN / x = NaN for any x.
     * x / NaN = NaN for any x.
     * Infinity / x = Infinity for any finite non-negative x.
     * Infinity / x = -Infinity for any finite negative x including -0.
     * -Infinity / x = -Infinity for any finite non-negative x.
     * -Infinity / x = Infinity for any finite negative x including -0.
     * x / Infinity = 0 for any finite non-negative x.
     * x / -Infinity = -0 for any finite non-negative x.
     * x / Infinity = -0 for any finite non-negative x including -0.
     * x / -Infinity = 0 for any finite non-negative x including -0.
     *
     * Infinity / Infinity = NaN.
     * Infinity / -Infinity = -NaN.
     * -Infinity / Infinity = -NaN.
     * -Infinity / -Infinity = NaN.
     *
     * Division by zero behaves in the following way:
     *
     * x / 0 = Infinity for any finite positive x.
     * x / -0 = -Infinity for any finite positive x.
     * x / 0 = -Infinity for any finite negative x.
     * x / -0 = Infinity for any finite negative x.
     * 0 / 0 = NaN.
     * 0 / -0 = NaN.
     * -0 / 0 = NaN.
     * -0 / -0 = NaN.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return quadruple precision number
     */
    function div(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        unchecked {
            uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
            uint256 yExponent = uint128(y) >> 112 & 0x7FFF;

            if (xExponent == 0x7FFF) {
                if (yExponent == 0x7FFF) return NaN;
                else return x ^ y & 0x80000000000000000000000000000000;
            } else if (yExponent == 0x7FFF) {
                if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
                else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
            } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
                if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
                else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
            } else {
                uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (yExponent == 0) yExponent = 1;
                else ySignifier |= 0x10000000000000000000000000000;

                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) {
                    if (xSignifier != 0) {
                        uint256 shift = 226 - mostSignificantBit(xSignifier);

                        xSignifier <<= shift;

                        xExponent = 1;
                        yExponent += shift - 114;
                    }
                } else {
                    xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
                }

                xSignifier = xSignifier / ySignifier;
                if (xSignifier == 0) {
                    return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;
                }

                assert(xSignifier >= 0x1000000000000000000000000000);

                uint256 msb = xSignifier >= 0x80000000000000000000000000000
                    ? mostSignificantBit(xSignifier)
                    : xSignifier >= 0x40000000000000000000000000000
                        ? 114
                        : xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

                if (xExponent + msb > yExponent + 16497) {
                    // Overflow
                    xExponent = 0x7FFF;
                    xSignifier = 0;
                } else if (xExponent + msb + 16380 < yExponent) {
                    // Underflow
                    xExponent = 0;
                    xSignifier = 0;
                } else if (xExponent + msb + 16268 < yExponent) {
                    // Subnormal
                    if (xExponent + 16380 > yExponent) {
                        xSignifier <<= xExponent + 16380 - yExponent;
                    } else if (xExponent + 16380 < yExponent) {
                        xSignifier >>= yExponent - xExponent - 16380;
                    }

                    xExponent = 0;
                } else {
                    // Normal
                    if (msb > 112) {
                        xSignifier >>= msb - 112;
                    }

                    xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                    xExponent = xExponent + msb + 16269 - yExponent;
                }

                return bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | xExponent << 112 | xSignifier)
                );
            }
        }
    }

    /**
     * Calculate -x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function neg(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            return x ^ 0x80000000000000000000000000000000;
        }
    }

    /**
     * Calculate |x|.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function abs(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        }
    }

    /**
     * Calculate square root of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function sqrt(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            if (uint128(x) > 0x80000000000000000000000000000000) {
                return NaN;
            } else {
                uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
                if (xExponent == 0x7FFF) {
                    return x;
                } else {
                    uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    if (xExponent == 0) xExponent = 1;
                    else xSignifier |= 0x10000000000000000000000000000;

                    if (xSignifier == 0) return POSITIVE_ZERO;

                    bool oddExponent = xExponent & 0x1 == 0;
                    xExponent = xExponent + 16383 >> 1;

                    if (oddExponent) {
                        if (xSignifier >= 0x10000000000000000000000000000) {
                            xSignifier <<= 113;
                        } else {
                            uint256 msb = mostSignificantBit(xSignifier);
                            uint256 shift = (226 - msb) & 0xFE;
                            xSignifier <<= shift;
                            xExponent -= shift - 112 >> 1;
                        }
                    } else {
                        if (xSignifier >= 0x10000000000000000000000000000) {
                            xSignifier <<= 112;
                        } else {
                            uint256 msb = mostSignificantBit(xSignifier);
                            uint256 shift = (225 - msb) & 0xFE;
                            xSignifier <<= shift;
                            xExponent -= shift - 112 >> 1;
                        }
                    }

                    uint256 r = 0x10000000000000000000000000000;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1;
                    r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
                    uint256 r1 = xSignifier / r;
                    if (r1 < r) r = r1;

                    return bytes16(uint128(xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
                }
            }
        }
    }

    /**
     * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function log_2(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            if (uint128(x) > 0x80000000000000000000000000000000) {
                return NaN;
            } else if (x == 0x3FFF0000000000000000000000000000) {
                return POSITIVE_ZERO;
            } else {
                uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
                if (xExponent == 0x7FFF) {
                    return x;
                } else {
                    uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    if (xExponent == 0) xExponent = 1;
                    else xSignifier |= 0x10000000000000000000000000000;

                    if (xSignifier == 0) return NEGATIVE_INFINITY;

                    bool resultNegative;
                    uint256 resultExponent = 16495;
                    uint256 resultSignifier;

                    if (xExponent >= 0x3FFF) {
                        resultNegative = false;
                        resultSignifier = xExponent - 0x3FFF;
                        xSignifier <<= 15;
                    } else {
                        resultNegative = true;
                        if (xSignifier >= 0x10000000000000000000000000000) {
                            resultSignifier = 0x3FFE - xExponent;
                            xSignifier <<= 15;
                        } else {
                            uint256 msb = mostSignificantBit(xSignifier);
                            resultSignifier = 16493 - msb;
                            xSignifier <<= 127 - msb;
                        }
                    }

                    if (xSignifier == 0x80000000000000000000000000000000) {
                        if (resultNegative) resultSignifier += 1;
                        uint256 shift = 112 - mostSignificantBit(resultSignifier);
                        resultSignifier <<= shift;
                        resultExponent -= shift;
                    } else {
                        uint256 bb = resultNegative ? 1 : 0;
                        while (resultSignifier < 0x10000000000000000000000000000) {
                            resultSignifier <<= 1;
                            resultExponent -= 1;

                            xSignifier *= xSignifier;
                            uint256 b = xSignifier >> 255;
                            resultSignifier += b ^ bb;
                            xSignifier >>= 127 + b;
                        }
                    }

                    return bytes16(
                        uint128(
                            (resultNegative ? 0x80000000000000000000000000000000 : 0) | resultExponent << 112
                                | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                        )
                    );
                }
            }
        }
    }

    /**
     * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function ln(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            return mul(log_2(x), 0x3FFE62E42FEFA39EF35793C7673007E5);
        }
    }

    /**
     * Calculate 2^x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function pow_2(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            bool xNegative = uint128(x) > 0x80000000000000000000000000000000;
            uint256 xExponent = uint128(x) >> 112 & 0x7FFF;
            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (xExponent == 0x7FFF && xSignifier != 0) {
                return NaN;
            } else if (xExponent > 16397) {
                return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
            } else if (xExponent < 16255) {
                return 0x3FFF0000000000000000000000000000;
            } else {
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                if (xExponent > 16367) {
                    xSignifier <<= xExponent - 16367;
                } else if (xExponent < 16367) {
                    xSignifier >>= 16367 - xExponent;
                }

                if (xNegative && xSignifier > 0x406E00000000000000000000000000000000) {
                    return POSITIVE_ZERO;
                }

                if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                    return POSITIVE_INFINITY;
                }

                uint256 resultExponent = xSignifier >> 128;
                xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xNegative && xSignifier != 0) {
                    xSignifier = ~xSignifier;
                    resultExponent += 1;
                }

                uint256 resultSignifier = 0x80000000000000000000000000000000;
                if (xSignifier & 0x80000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
                }
                if (xSignifier & 0x40000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
                }
                if (xSignifier & 0x20000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
                }
                if (xSignifier & 0x10000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
                }
                if (xSignifier & 0x8000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
                }
                if (xSignifier & 0x4000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
                }
                if (xSignifier & 0x2000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
                }
                if (xSignifier & 0x1000000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
                }
                if (xSignifier & 0x800000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
                }
                if (xSignifier & 0x400000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
                }
                if (xSignifier & 0x200000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
                }
                if (xSignifier & 0x100000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
                }
                if (xSignifier & 0x80000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
                }
                if (xSignifier & 0x40000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
                }
                if (xSignifier & 0x20000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
                }
                if (xSignifier & 0x10000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
                }
                if (xSignifier & 0x8000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
                }
                if (xSignifier & 0x4000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
                }
                if (xSignifier & 0x2000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
                }
                if (xSignifier & 0x1000000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
                }
                if (xSignifier & 0x800000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
                }
                if (xSignifier & 0x400000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
                }
                if (xSignifier & 0x200000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
                }
                if (xSignifier & 0x100000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
                }
                if (xSignifier & 0x80000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
                }
                if (xSignifier & 0x40000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
                }
                if (xSignifier & 0x20000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
                }
                if (xSignifier & 0x10000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
                }
                if (xSignifier & 0x8000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
                }
                if (xSignifier & 0x4000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
                }
                if (xSignifier & 0x2000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
                }
                if (xSignifier & 0x1000000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
                }
                if (xSignifier & 0x800000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
                }
                if (xSignifier & 0x400000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
                }
                if (xSignifier & 0x200000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
                }
                if (xSignifier & 0x100000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
                }
                if (xSignifier & 0x80000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
                }
                if (xSignifier & 0x40000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
                }
                if (xSignifier & 0x20000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
                }
                if (xSignifier & 0x10000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
                }
                if (xSignifier & 0x8000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
                }
                if (xSignifier & 0x4000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
                }
                if (xSignifier & 0x2000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
                }
                if (xSignifier & 0x1000000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
                }
                if (xSignifier & 0x800000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
                }
                if (xSignifier & 0x400000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
                }
                if (xSignifier & 0x200000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
                }
                if (xSignifier & 0x100000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
                }
                if (xSignifier & 0x80000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
                }
                if (xSignifier & 0x40000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
                }
                if (xSignifier & 0x20000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
                }
                if (xSignifier & 0x10000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
                }
                if (xSignifier & 0x8000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
                }
                if (xSignifier & 0x4000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
                }
                if (xSignifier & 0x2000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
                }
                if (xSignifier & 0x1000000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
                }
                if (xSignifier & 0x800000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
                }
                if (xSignifier & 0x400000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
                }
                if (xSignifier & 0x200000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
                }
                if (xSignifier & 0x100000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
                }
                if (xSignifier & 0x80000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
                }
                if (xSignifier & 0x40000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
                }
                if (xSignifier & 0x20000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
                }
                if (xSignifier & 0x10000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
                }
                if (xSignifier & 0x8000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
                }
                if (xSignifier & 0x4000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
                }
                if (xSignifier & 0x2000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
                }
                if (xSignifier & 0x1000000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
                }
                if (xSignifier & 0x800000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
                }
                if (xSignifier & 0x400000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
                }
                if (xSignifier & 0x200000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
                }
                if (xSignifier & 0x100000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
                }
                if (xSignifier & 0x80000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
                }
                if (xSignifier & 0x40000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
                }
                if (xSignifier & 0x20000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
                }
                if (xSignifier & 0x10000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
                }
                if (xSignifier & 0x8000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
                }
                if (xSignifier & 0x4000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
                }
                if (xSignifier & 0x2000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
                }
                if (xSignifier & 0x1000000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
                }
                if (xSignifier & 0x800000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
                }
                if (xSignifier & 0x400000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
                }
                if (xSignifier & 0x200000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
                }
                if (xSignifier & 0x100000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
                }
                if (xSignifier & 0x80000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
                }
                if (xSignifier & 0x40000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
                }
                if (xSignifier & 0x20000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
                }
                if (xSignifier & 0x10000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
                }
                if (xSignifier & 0x8000000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
                }
                if (xSignifier & 0x4000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
                }
                if (xSignifier & 0x2000000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
                }
                if (xSignifier & 0x1000000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
                }
                if (xSignifier & 0x800000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
                }
                if (xSignifier & 0x400000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
                }
                if (xSignifier & 0x200000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
                }
                if (xSignifier & 0x100000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
                }
                if (xSignifier & 0x80000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
                }
                if (xSignifier & 0x40000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
                }
                if (xSignifier & 0x20000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
                }
                if (xSignifier & 0x10000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
                }
                if (xSignifier & 0x8000000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
                }
                if (xSignifier & 0x4000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
                }
                if (xSignifier & 0x2000000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
                }
                if (xSignifier & 0x1000000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
                }
                if (xSignifier & 0x800000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
                }
                if (xSignifier & 0x400000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
                }
                if (xSignifier & 0x200000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
                }
                if (xSignifier & 0x100000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
                }
                if (xSignifier & 0x80000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
                }
                if (xSignifier & 0x40000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
                }
                if (xSignifier & 0x20000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
                }
                if (xSignifier & 0x10000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
                }
                if (xSignifier & 0x8000 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
                }
                if (xSignifier & 0x4000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
                }
                if (xSignifier & 0x2000 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
                }
                if (xSignifier & 0x1000 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
                }
                if (xSignifier & 0x800 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
                }
                if (xSignifier & 0x400 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
                }
                if (xSignifier & 0x200 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
                }
                if (xSignifier & 0x100 > 0) {
                    resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
                }
                if (xSignifier & 0x80 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
                }
                if (xSignifier & 0x40 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
                }
                if (xSignifier & 0x20 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
                }
                if (xSignifier & 0x10 > 0) {
                    resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
                }
                if (xSignifier & 0x8 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
                }
                if (xSignifier & 0x4 > 0) {
                    resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;
                }

                if (!xNegative) {
                    resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    resultExponent += 0x3FFF;
                } else if (resultExponent <= 0x3FFE) {
                    resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                    resultExponent = 0x3FFF - resultExponent;
                } else {
                    resultSignifier = resultSignifier >> resultExponent - 16367;
                    resultExponent = 0;
                }

                return bytes16(uint128(resultExponent << 112 | resultSignifier));
            }
        }
    }

    /**
     * Calculate e^x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function exp(bytes16 x) internal pure returns (bytes16) {
        unchecked {
            return pow_2(mul(x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
        }
    }

    /**
     * Get index of the most significant non-zero bit in binary representation of
     * x.  Reverts if x is zero.
     *
     * @return index of the most significant non-zero bit in binary representation
     *         of x
     */
    function mostSignificantBit(uint256 x) private pure returns (uint256) {
        unchecked {
            require(x > 0);

            uint256 result = 0;

            if (x >= 0x100000000000000000000000000000000) {
                x >>= 128;
                result += 128;
            }
            if (x >= 0x10000000000000000) {
                x >>= 64;
                result += 64;
            }
            if (x >= 0x100000000) {
                x >>= 32;
                result += 32;
            }
            if (x >= 0x10000) {
                x >>= 16;
                result += 16;
            }
            if (x >= 0x100) {
                x >>= 8;
                result += 8;
            }
            if (x >= 0x10) {
                x >>= 4;
                result += 4;
            }
            if (x >= 0x4) {
                x >>= 2;
                result += 2;
            }
            if (x >= 0x2) result += 1; // No need to shift x anymore

            return result;
        }
    }
}