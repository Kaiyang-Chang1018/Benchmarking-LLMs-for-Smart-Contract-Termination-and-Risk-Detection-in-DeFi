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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
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
     *
     * CAUTION: See Security Considerations above.
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
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

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
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
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
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
     * - The `operator` cannot be the caller.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
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
 * ```solidity
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
pragma solidity 0.8.24;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {
    IERC1155Receiver,
    IERC165
} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IMeldBridgeBase} from "./interfaces/IMeldBridgeBase.sol";
import {Errors} from "./libraries/Errors.sol";

/**
 * @title MeldBridgeBase
 * @notice This contract is the base contract for the MeldBridgePanoptic and MeldBridgeReceiver contracts
 * @dev Handles the supported tokens and roles
 * @author MELD team
 */
contract MeldBridgeBase is
    AccessControlEnumerable,
    IMeldBridgeBase,
    IERC721Receiver,
    IERC1155Receiver
{
    bytes32 public constant override CONFIGURATION_ROLE = keccak256("CONFIGURATION_ROLE");
    bytes32 public constant override EXECUTION_ROLE = keccak256("EXECUTION_ROLE");

    // mapping for supported tokens
    mapping(address => bool) public override supportedTokens;

    // mapping for processed requests
    mapping(bytes32 requestID => bool processed) public override processedRequests;

    /**
     * @notice  Modifier to check if the token is supported
     * @param _token Address of the token
     */
    modifier onlySupportedToken(address _token) {
        require(supportedTokens[_token], Errors.TOKEN_NOT_SUPPORTED);
        _;
    }

    /**
     * @notice  Modifier to check if the request has not been processed
     * @param _requestID ID of the request
     */
    modifier onlyUnprocessedRequest(bytes32 _requestID) {
        require(!processedRequests[_requestID], Errors.REQUEST_ALREADY_PROCESSED);
        _;
    }

    /**
     * @notice  Modifier to check if the amount is positive
     * @param _amount Amount to check
     */
    modifier onlyPositiveAmount(uint256 _amount) {
        require(_amount > 0, Errors.INVALID_AMOUNT);
        _;
    }

    /**
     * @inheritdoc IMeldBridgeBase
     */
    function setSupportedToken(
        address _token,
        bool _supported
    ) external override onlyRole(CONFIGURATION_ROLE) {
        supportedTokens[_token] = _supported;

        emit SupportedTokenSet(msg.sender, _token, _supported);
    }

    /**
     * @inheritdoc IMeldBridgeBase
     */
    function checkRole(bytes32 _role, address _account) external view override {
        return _checkRole(_role, _account);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(AccessControlEnumerable, IERC165) returns (bool) {
        return
            _interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @inheritdoc IERC721Receiver
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @inheritdoc IERC1155Receiver
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @inheritdoc IERC1155Receiver
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) public pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MeldBridgeBase} from "./MeldBridgeBase.sol";
import {IMeldBridgeReceiver} from "./interfaces/IMeldBridgeReceiver.sol";
import {IBaseERC20} from "./interfaces/IBaseERC20.sol";
import {IBaseERC721} from "./interfaces/IBaseERC721.sol";
import {IBaseERC1155} from "./interfaces/IBaseERC1155.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {MeldFarmingManager} from "./MeldFarmingManager.sol";
import {Errors} from "./libraries/Errors.sol";

/**
 * @author  MELD team
 * @title   MeldBridgeReceiver
 * @notice  This contract is the receiver contract for the Meld Bridge. It is responsible for receiving tokens from the original network of the tokens and re-staking them
 */

contract MeldBridgeReceiver is IMeldBridgeReceiver, MeldBridgeBase {
    using SafeERC20 for IBaseERC20;

    address payable public override wETHAddress;

    bytes32 public constant override REBALANCER_ROLE = keccak256("REBALANCER_ROLE");

    MeldFarmingManager private farmingManager;

    /**
     * @notice Constructor
     * @param _defaultAdmin Address of the default admin
     * @param _wETH Address of the WETH contract
     * @param _treasury Address of the treasury
     */
    constructor(address _defaultAdmin, address _wETH, address _treasury) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        wETHAddress = payable(_wETH);
        emit WETHAddressSet(msg.sender, _wETH);
        farmingManager = new MeldFarmingManager(address(this), _treasury);
        emit MeldFarmingManagerDeployed(msg.sender, address(farmingManager));
    }

    /**
     * @notice Function to receive native tokens
     * @dev Only can receive from the WETH contract
     */
    receive() external payable {
        require(msg.sender == wETHAddress, Errors.MBR_ONLY_WETH_ALLOWED);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function bridge(
        address _token,
        uint256 _amount
    ) public override onlySupportedToken(_token) onlyPositiveAmount(_amount) {
        IBaseERC20(_token).safeTransferFrom(msg.sender, address(farmingManager), _amount);

        farmingManager.deposit(_token, _amount, "");

        emit BridgeRequested(msg.sender, _token, _amount);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function bridgeNative() public payable override {
        require(supportedTokens[address(0)], Errors.MBR_NATIVE_NOT_SUPPORTED);
        require(msg.value > 0, Errors.INVALID_AMOUNT);

        IWETH weth = IWETH(wETHAddress);

        uint256 wethBalanceBefore = weth.balanceOf(address(this));
        weth.deposit{value: msg.value}();
        require(
            weth.balanceOf(address(this)) == msg.value + wethBalanceBefore,
            Errors.MBR_NATIVE_WRAPPING_FAILED
        );
        IBaseERC20(wETHAddress).safeTransfer(address(farmingManager), msg.value);
        farmingManager.deposit(wETHAddress, msg.value, "");

        emit BridgeRequested(msg.sender, address(0), msg.value);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function bridgeERC721(
        address _token,
        uint256 _tokenId
    ) public override onlySupportedToken(_token) {
        IBaseERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenId);

        emit BridgeERC721Requested(msg.sender, _token, _tokenId);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function bridgeERC1155(
        address _token,
        uint256 _tokenId,
        uint256 _amount
    ) public override onlySupportedToken(_token) onlyPositiveAmount(_amount) {
        IBaseERC1155(_token).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

        emit BridgeERC1155Requested(msg.sender, _token, _tokenId, _amount);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawToUser(
        address _token,
        address _to,
        uint256 _amount,
        bytes32 _requestID,
        bytes calldata _extra
    )
        public
        override
        onlyRole(EXECUTION_ROLE)
        onlySupportedToken(_token)
        onlyUnprocessedRequest(_requestID)
        onlyPositiveAmount(_amount)
    {
        if (_token == address(0)) {
            farmingManager.withdraw(wETHAddress, _amount, _extra);
            IBaseERC20(wETHAddress).safeTransferFrom(
                address(farmingManager),
                address(this),
                _amount
            );
            IWETH(wETHAddress).withdraw(_amount);
            payable(_to).transfer(_amount);
        } else {
            farmingManager.withdraw(_token, _amount, _extra);
            IBaseERC20(_token).safeTransferFrom(address(farmingManager), _to, _amount);
        }

        processedRequests[_requestID] = true;

        emit WithdrawnToUser(_token, _to, _amount, _requestID);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawERC721ToUser(
        address _token,
        address _to,
        uint256 _tokenId,
        bytes32 _requestID
    )
        public
        override
        onlyRole(EXECUTION_ROLE)
        onlySupportedToken(_token)
        onlyUnprocessedRequest(_requestID)
    {
        IBaseERC721(_token).safeTransferFrom(address(this), _to, _tokenId);

        processedRequests[_requestID] = true;

        emit WithdrawnERC721ToUser(_token, _to, _tokenId, _requestID);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawERC1155ToUser(
        address _token,
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes32 _requestID
    )
        public
        override
        onlyRole(EXECUTION_ROLE)
        onlySupportedToken(_token)
        onlyUnprocessedRequest(_requestID)
        onlyPositiveAmount(_amount)
    {
        IBaseERC1155(_token).safeTransferFrom(address(this), _to, _tokenId, _amount, "");

        processedRequests[_requestID] = true;

        emit WithdrawnERC1155ToUser(_token, _to, _tokenId, _amount, _requestID);
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawToUsers(
        address _token,
        address[] memory _tos,
        uint256[] memory _amounts,
        bytes32[] memory _requestIDs,
        bytes[] calldata _extra
    ) public override {
        require(
            _tos.length == _amounts.length &&
                _amounts.length == _requestIDs.length &&
                _requestIDs.length == _extra.length,
            Errors.INVALID_ARRAY_LENGTH
        );

        for (uint256 i = 0; i < _tos.length; i++) {
            withdrawToUser(_token, _tos[i], _amounts[i], _requestIDs[i], _extra[i]);
        }
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawERC721ToUsers(
        address _token,
        address[] memory _tos,
        uint256[] memory _tokenIds,
        bytes32[] memory _requestIDs
    ) public override {
        require(
            _tos.length == _tokenIds.length && _tokenIds.length == _requestIDs.length,
            Errors.INVALID_ARRAY_LENGTH
        );

        for (uint256 i = 0; i < _tos.length; i++) {
            withdrawERC721ToUser(_token, _tos[i], _tokenIds[i], _requestIDs[i]);
        }
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function withdrawERC1155ToUsers(
        address _token,
        address[] memory _tos,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        bytes32[] memory _requestIDs
    ) public override {
        require(
            _tos.length == _tokenIds.length &&
                _tokenIds.length == _requestIDs.length &&
                _tokenIds.length == _amounts.length,
            Errors.INVALID_ARRAY_LENGTH
        );

        for (uint256 i = 0; i < _tos.length; i++) {
            withdrawERC1155ToUser(_token, _tos[i], _tokenIds[i], _amounts[i], _requestIDs[i]);
        }
    }

    /**
     * @inheritdoc IMeldBridgeReceiver
     */
    function getFarmingManagerAddress() public view returns (address) {
        return address(farmingManager);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMeldFarming, IMeldFarmingManager} from "./interfaces/IMeldFarmingManager.sol";
import {ILockedAdapter} from "./interfaces/ILockedAdapter.sol";
import {IMeldBridgeReceiver} from "./interfaces/IMeldBridgeReceiver.sol";
import {Errors} from "./libraries/Errors.sol";

/**
 * @title Meld Farming Manager contract
 * @notice Contract that manages the yield farming adapters
 * @author MELD team
 */
contract MeldFarmingManager is IMeldFarmingManager {
    using SafeERC20 for IERC20;

    mapping(uint256 index => address adapterAddress) public override adapterAddresses;
    mapping(address adapterAddress => AdapterConfig config) private adapters;
    uint256 public override numAdapters;

    mapping(address => YieldAssetConfig) private yieldAssetConfigs;

    IMeldBridgeReceiver public override bridge;
    address public override treasury;

    /**
     * @notice Modifier to check that only the bridge can call the function
     */
    modifier onlyBridge() {
        require(msg.sender == address(bridge), Errors.MFM_ONLY_BRIDGE_ALLOWED);
        _;
    }

    /**
     * @notice Modifier to check that the caller has the required role
     * @dev It queries the bridge contract to check the role
     * @param _role Role required to call the function
     */
    modifier onlyRole(bytes32 _role) {
        bridge.checkRole(_role, msg.sender);
        _;
    }

    /**
     * @notice Constructor of the contract
     * @param _bridge Address of the Meld Bridge Receiver contract
     * @param _treasury Address of the treasury
     */
    constructor(address _bridge, address _treasury) {
        bridge = IMeldBridgeReceiver(_bridge);
        emit BridgeSet(msg.sender, _bridge);
        _setTreasury(_treasury);
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function addAdapter(
        string memory _adapterId,
        address _adapterAddress,
        bool _locked
    ) external override onlyRole(bridge.CONFIGURATION_ROLE()) {
        require(bytes(_adapterId).length > 0, Errors.MFM_INVALID_ADAPTER_ID);
        require(!adapters[_adapterAddress].exists, Errors.MFM_ADAPTER_ALREADY_EXISTS);
        require(_adapterAddress != address(0), Errors.INVALID_ADDRESS);
        IMeldFarming adapter = IMeldFarming(_adapterAddress);
        require(
            adapter.supportsInterface(type(IMeldFarming).interfaceId),
            Errors.MFM_ADAPTER_IS_NOT_MELD_FARMING
        );
        require(adapter.meldFarmingManager() == address(this), Errors.MFM_INVALID_ADAPTER_MFM);

        adapters[_adapterAddress] = AdapterConfig({
            adapterIdStr: _adapterId,
            enabled: true,
            locked: _locked,
            exists: true
        });
        adapterAddresses[numAdapters] = _adapterAddress;
        numAdapters++;
        emit AdapterAdded(msg.sender, _adapterId, _adapterAddress, _locked);
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function setAdapterEnabled(
        address _adapterAddress,
        bool _enabled
    ) external override onlyRole(bridge.CONFIGURATION_ROLE()) {
        AdapterConfig storage adapter = adapters[_adapterAddress];
        require(adapter.exists, Errors.MFM_ADAPTER_DOES_NOT_EXIST);
        adapter.enabled = _enabled;
        emit AdapterEnabled(msg.sender, _adapterAddress, _enabled);
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function configAsset(
        address _asset,
        address[] memory _adaptersAddresses
    ) external override onlyRole(bridge.CONFIGURATION_ROLE()) {
        YieldAssetConfig storage yaConfig = yieldAssetConfigs[_asset];

        address[] memory tempAdapterAddresses = new address[](
            yaConfig.numAdapters + _adaptersAddresses.length
        );
        address tempAdapterAddress;
        YieldAssetAdapter memory tempAdapter;
        uint256 tempNumAdapters = yaConfig.numAdapters;

        _safeApproveAll(IERC20(_asset), address(bridge));

        // We create an array of size oldList + newList of adapter ids
        // If the adapter already exists, we set its id in the same position
        // If the adapter doesn't exist, we set its id after the last position of the old list and update that pointer
        // Once that it's done, we have to reorganize the info to remove the empty spaces

        for (uint256 i = 0; i < _adaptersAddresses.length; i++) {
            require(adapters[_adaptersAddresses[i]].exists, Errors.MFM_ADAPTER_DOES_NOT_EXIST);
            // Iterate over the new list of adapters
            tempAdapterAddress = _adaptersAddresses[i];
            tempAdapter = yaConfig.adapters[tempAdapterAddress];
            if (tempAdapter.exists) {
                // If the adapter already exists, set its id in the tempAdapterAddresss
                tempAdapterAddresses[tempAdapter.index] = tempAdapterAddress;
            } else {
                // If the adapter doesn't exist, add it to the list
                tempAdapterAddresses[tempNumAdapters] = tempAdapterAddress;
                yaConfig.adapterIndex[tempNumAdapters] = tempAdapterAddress;
                yaConfig.adapters[tempAdapterAddress] = YieldAssetAdapter({
                    yieldDeposit: 0,
                    lastTimestampRewardsClaimed: 0,
                    index: tempNumAdapters,
                    exists: true
                });

                _safeApproveAll(IERC20(_asset), tempAdapterAddress);
                tempNumAdapters++;
            }
        }

        emit AssetConfigSet(msg.sender, _asset, _adaptersAddresses);
        if (tempNumAdapters == 0) {
            return;
        }

        uint256 rewardsClaimed = 0;
        uint256 tempRewards;

        for (uint256 i = 0; i < yaConfig.numAdapters; i++) {
            if (tempAdapterAddresses[i] != address(0)) {
                // Position not empty
                continue;
            }
            // Position empty

            // Withdraw all from the adapter

            address oldAdapterAddress = adapterAddresses[i];

            AdapterConfig memory adapterConfig = adapters[oldAdapterAddress];

            _checkAdapterEnabled(adapterConfig);

            uint256 adapterAssetDepositAmount = yaConfig.adapters[oldAdapterAddress].yieldDeposit;

            yaConfig.liquidDeposit += IMeldFarming(oldAdapterAddress).withdraw(
                _asset,
                adapterAssetDepositAmount,
                ""
            );
            tempRewards = IMeldFarming(oldAdapterAddress).claimRewards(_asset, "", false);
            rewardsClaimed += tempRewards;
            emit RewardsClaimed(msg.sender, _asset, oldAdapterAddress, tempRewards);

            // Remove old position
            delete yaConfig.adapters[oldAdapterAddress];
            for (; tempNumAdapters > i; tempNumAdapters--) {
                if (tempAdapterAddresses[tempNumAdapters - 1] == address(0)) {
                    // Last position empty
                    continue;
                }
                tempAdapterAddresses[i] = tempAdapterAddresses[tempNumAdapters - 1];
                yaConfig.adapters[tempAdapterAddresses[i]].index = i;
                yaConfig.adapterIndex[i] = tempAdapterAddresses[i];
                tempAdapterAddresses[tempNumAdapters - 1] = address(0);
                tempNumAdapters--;
                break;
            }
        }

        yaConfig.numAdapters = _adaptersAddresses.length;

        if (rewardsClaimed > 0) {
            IERC20(_asset).safeTransfer(treasury, rewardsClaimed);
        }
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function setTreasury(
        address _treasury
    ) external override onlyRole(bridge.CONFIGURATION_ROLE()) {
        _setTreasury(_treasury);
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function rebalance(
        RebalancingInfo[] calldata _rebalanceInfo
    ) external override onlyRole(bridge.REBALANCER_ROLE()) {
        require(_rebalanceInfo.length > 0, Errors.INVALID_ARRAY_LENGTH);
        for (uint256 i = 0; i < _rebalanceInfo.length; i++) {
            RebalancingInfo calldata rebalanceInfo = _rebalanceInfo[i];
            _checkAdapterEnabled(adapters[rebalanceInfo.adapterAddress]);
            IMeldFarming adapter = IMeldFarming(rebalanceInfo.adapterAddress);

            YieldAssetConfig storage yaConfig = yieldAssetConfigs[rebalanceInfo.asset];
            if (rebalanceInfo.action == RebalanceAction.DEPOSIT) {
                require(
                    rebalanceInfo.amount <= yaConfig.liquidDeposit,
                    Errors.MFM_NOT_ENOUGH_FUNDS
                );
                adapter.deposit(rebalanceInfo.asset, rebalanceInfo.amount, rebalanceInfo.extra);
                yaConfig.liquidDeposit -= rebalanceInfo.amount;
                yaConfig.adapters[rebalanceInfo.adapterAddress].yieldDeposit += rebalanceInfo
                    .amount;
            } else if (rebalanceInfo.action == RebalanceAction.WITHDRAW) {
                require(
                    rebalanceInfo.amount <=
                        yaConfig.adapters[rebalanceInfo.adapterAddress].yieldDeposit,
                    Errors.MFM_NOT_ENOUGH_FUNDS
                );
                uint256 amount = adapter.withdraw(
                    rebalanceInfo.asset,
                    rebalanceInfo.amount,
                    rebalanceInfo.extra
                );
                require(amount == rebalanceInfo.amount, Errors.MFM_AMOUNT_MISMATCH);
                yaConfig.liquidDeposit += rebalanceInfo.amount;
                yaConfig.adapters[rebalanceInfo.adapterAddress].yieldDeposit -= rebalanceInfo
                    .amount;
            } else if (rebalanceInfo.action == RebalanceAction.REQUEST_WITHDRAW) {
                ILockedAdapter(address(adapter)).requestWithdraw(
                    rebalanceInfo.asset,
                    rebalanceInfo.amount,
                    rebalanceInfo.extra
                );
            }
            emit Rebalanced(
                msg.sender,
                rebalanceInfo.asset,
                rebalanceInfo.adapterAddress,
                rebalanceInfo.amount,
                rebalanceInfo.action
            );
        }
    }

    /**
     * @inheritdoc IMeldFarming
     */
    function deposit(address _asset, uint256 _amount, bytes calldata) external override onlyBridge {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];

        assetConfig.liquidDeposit += _amount;

        emit Deposited(_asset, _amount);
    }

    /**
     * @inheritdoc IMeldFarming
     */
    function withdraw(
        address _asset,
        uint256 _amount,
        bytes calldata _extra
    ) external override onlyBridge returns (uint256) {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        uint256 remainingAmount = _amount;

        if (remainingAmount > assetConfig.liquidDeposit) {
            remainingAmount -= assetConfig.liquidDeposit;
            assetConfig.liquidDeposit = 0;
            for (uint256 i = 0; i < assetConfig.numAdapters; i++) {
                address adapterAddress = assetConfig.adapterIndex[i];
                IMeldFarming adapter = IMeldFarming(adapterAddress);
                YieldAssetAdapter storage yaAdapter = assetConfig.adapters[adapterAddress];
                AdapterConfig memory adapterConfig = adapters[adapterAddress];
                if (!adapterConfig.enabled) {
                    continue;
                }
                uint256 adapterAvailableLiquidity = adapter.getAvailableLiquidity(_asset);
                if (adapterAvailableLiquidity == 0) {
                    continue;
                }
                if (adapterAvailableLiquidity >= remainingAmount) {
                    adapter.withdraw(_asset, remainingAmount, _extra);
                    yaAdapter.yieldDeposit -= remainingAmount;
                    remainingAmount = 0;
                    break;
                } else {
                    adapter.withdraw(_asset, adapterAvailableLiquidity, _extra);
                    yaAdapter.yieldDeposit = 0;
                    remainingAmount -= adapterAvailableLiquidity;
                }
            }
            require(remainingAmount == 0, Errors.MFM_NOT_ENOUGH_FUNDS);
        } else {
            assetConfig.liquidDeposit -= remainingAmount;
        }
        emit Withdrawn(_asset, _amount);

        return _amount;
    }

    /**
     * @inheritdoc IMeldFarming
     */
    function claimRewards(
        address _asset,
        bytes calldata _extra,
        bool _withdrawOnlyAvailable
    ) external override onlyRole(bridge.REBALANCER_ROLE()) returns (uint256) {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        require(assetConfig.numAdapters > 0, Errors.MFM_NO_ADAPTERS_CONFIGURED);
        uint256 totalRewards;
        for (uint256 i = 0; i < assetConfig.numAdapters; i++) {
            address adapterAddress = assetConfig.adapterIndex[i];
            YieldAssetAdapter storage yaAdapter = assetConfig.adapters[adapterAddress];
            AdapterConfig memory adapterConfig = adapters[adapterAddress];
            if (!adapterConfig.enabled) {
                continue;
            }
            uint256 rewards = IMeldFarming(adapterAddress).claimRewards(
                _asset,
                _extra,
                _withdrawOnlyAvailable
            );
            if (rewards > 0) {
                totalRewards += rewards;
                yaAdapter.lastTimestampRewardsClaimed = block.timestamp;
            }
            emit RewardsClaimed(msg.sender, _asset, adapterAddress, rewards);
        }
        IERC20(_asset).safeTransfer(treasury, totalRewards);
        return totalRewards;
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function getAllAdapters() external view override returns (AdapterConfig[] memory) {
        AdapterConfig[] memory adaptersConfig = new AdapterConfig[](numAdapters);
        for (uint256 i = 0; i < numAdapters; i++) {
            adaptersConfig[i] = adapters[adapterAddresses[i]];
        }
        return adaptersConfig;
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function getAdapter(
        address _adapterAddress
    ) external view override returns (AdapterConfig memory) {
        return adapters[_adapterAddress];
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function getYieldAssetConfig(
        address _asset
    )
        external
        view
        override
        returns (
            string[] memory assetAdapterIds,
            address[] memory assetAdapterAddresses,
            uint256[] memory yieldDeposit,
            uint256[] memory lastTimestampRewardsClaimed,
            uint256 liquidDeposit,
            uint256 totalDeposit,
            uint256 totalAvailableLiquidity
        )
    {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        uint256 assetNumAdapters = assetConfig.numAdapters;
        liquidDeposit = assetConfig.liquidDeposit;
        totalDeposit = liquidDeposit;
        totalAvailableLiquidity = liquidDeposit;
        assetAdapterIds = new string[](assetNumAdapters);
        yieldDeposit = new uint256[](assetNumAdapters);
        lastTimestampRewardsClaimed = new uint256[](assetNumAdapters);
        assetAdapterAddresses = new address[](assetNumAdapters);
        address tempAdapterAddress;
        YieldAssetAdapter memory tempAdapter;
        for (uint256 i = 0; i < assetNumAdapters; i++) {
            tempAdapterAddress = assetConfig.adapterIndex[i];
            assetAdapterIds[i] = adapters[tempAdapterAddress].adapterIdStr;
            tempAdapter = assetConfig.adapters[tempAdapterAddress];
            yieldDeposit[i] = tempAdapter.yieldDeposit;
            totalDeposit += tempAdapter.yieldDeposit;
            totalAvailableLiquidity += IMeldFarming(tempAdapterAddress).getAvailableLiquidity(
                _asset
            );
            assetAdapterAddresses[i] = tempAdapterAddress;
            lastTimestampRewardsClaimed[i] = tempAdapter.lastTimestampRewardsClaimed;
        }
    }

    /**
     * @inheritdoc IMeldFarmingManager
     */
    function getTotalDeposit(address _asset) external view override returns (uint256) {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        uint256 total = assetConfig.liquidDeposit;
        address tempAdapterAddress;
        for (uint256 i = 0; i < assetConfig.numAdapters; i++) {
            tempAdapterAddress = assetConfig.adapterIndex[i];
            total += assetConfig.adapters[tempAdapterAddress].yieldDeposit;
        }
        return total;
    }

    /**
     * @inheritdoc IMeldFarming
     * @dev This includes the funds in the Meld Farming Manager plus the funds in the non-locked adapters
     */
    function getAvailableLiquidity(address _asset) external view override returns (uint256) {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        uint256 total = assetConfig.liquidDeposit;
        address tempAdapterAddress;
        for (uint256 i = 0; i < assetConfig.numAdapters; i++) {
            tempAdapterAddress = assetConfig.adapterIndex[i];
            if (!adapters[tempAdapterAddress].locked) {
                total += IMeldFarming(tempAdapterAddress).getAvailableLiquidity(_asset);
            }
        }
        return total;
    }

    /**
     * @inheritdoc IMeldFarming
     * @dev This is the sum of the rewards of the adapters configured for the asset
     */
    function getRewardsAmount(address _asset) external view override returns (uint256) {
        YieldAssetConfig storage assetConfig = yieldAssetConfigs[_asset];
        uint256 total;
        address tempAdapterAddress;
        for (uint256 i = 0; i < assetConfig.numAdapters; i++) {
            tempAdapterAddress = assetConfig.adapterIndex[i];
            total += IMeldFarming(tempAdapterAddress).getRewardsAmount(_asset);
        }
        return total;
    }

    /**
     * @inheritdoc IMeldFarming
     * @dev This function is intended for the Yield Adapters, but this contract must implement the same interface
     */
    function meldFarmingManager() external view override returns (address) {
        return address(this);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 _interfaceId) public pure override returns (bool) {
        return _interfaceId == type(IMeldFarming).interfaceId;
    }

    /**
     * @notice Private function to set the treasury address
     * @param _treasury Address of the treasury
     */
    function _setTreasury(address _treasury) private {
        require(_treasury != address(0), Errors.INVALID_ADDRESS);
        emit TreasuryUpdated(msg.sender, treasury, _treasury);
        treasury = _treasury;
    }

    /**
     * @notice Private function to safe approve all the tokens to the spender
     * @param _token Token to approve
     * @param _spender Spender to approve
     */
    function _safeApproveAll(IERC20 _token, address _spender) private {
        uint256 allowance = _token.allowance(address(this), _spender);
        uint256 increaseAllowance = type(uint256).max - allowance;
        if (increaseAllowance > 0) {
            _token.safeIncreaseAllowance(_spender, increaseAllowance);
        }
    }

    /**
     * @notice Private function to check if the adapter is enabled
     * @dev It reverts if the adapter is not enabled
     * @param _adapter Adapter configuration
     */
    function _checkAdapterEnabled(AdapterConfig memory _adapter) private pure {
        require(_adapter.enabled, Errors.MFM_ADAPTER_DISABLED);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title Base ERC1155 interface
 * @notice Interface for interacting with ERC1155 tokens with mint and burn functions
 * @author MELD team
 */
interface IBaseERC1155 is IERC1155 {
    /**
     * @notice Mint new tokens
     * @param _to Address to mint tokens to
     * @param _id Token ID to mint
     * @param _amount Amount of tokens to mint
     * @param _data Additional data
     */
    function mint(address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

    /**
     * @notice Burn tokens
     * @param _id Token ID to burn
     * @param _amount Amount of tokens to burn
     */
    function burn(uint256 _id, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Base ERC20 interface
 * @notice Interface for interacting with ERC20 tokens with mint and burn functions
 * @author MELD team
 */
interface IBaseERC20 is IERC20 {
    /**
     * @notice Mint new tokens
     * @param _account Address to mint tokens to
     * @param _amount Amount of tokens to mint
     */
    function mint(address _account, uint256 _amount) external;

    /**
     * @notice Burn tokens
     * @param _amount Amount of tokens to burn
     */
    function burn(uint256 _amount) external;

    /**
     * @notice Get the number of decimals for the token
     * @return Number of decimals
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Base ERC721 interface
 * @notice Interface for interacting with ERC721 tokens with mint and burn functions
 * @author MELD team
 */
interface IBaseERC721 is IERC721 {
    /**
     * @notice Mint new tokens
     * @param _account Address to mint tokens to
     * @param _tokenId Token ID to mint
     */
    function mint(address _account, uint256 _tokenId) external;

    /**
     * @notice Burn tokens
     * @param _tokenId Token ID to burn
     */
    function burn(uint256 _tokenId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title Locked Adapter interface
 * @notice Interface for the locked adapters, to add the requestWithdraw function
 * @author MELD team
 */
interface ILockedAdapter {
    /**
     * @notice Request a withdraw from the adapter, so the funds can be withdrawn in the future
     * @param _asset Address of the asset to withdraw
     * @param _amount Amount to withdraw
     * @param _extra Extra data for the withdraw
     */
    function requestWithdraw(address _asset, uint256 _amount, bytes calldata _extra) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title Meld Bridge Base interface
 * @notice Interface for the Meld Bridge Base contract, to set supported tokens and check roles
 * @author MELD team
 */
interface IMeldBridgeBase {
    /**
     * @notice Emitted when a token is supported or unsupported
     * @param executedBy Address that executed the event
     * @param token Address of the token
     * @param supported True if the token is supported, false if unsupported
     */
    event SupportedTokenSet(address indexed executedBy, address indexed token, bool supported);

    /**
     * @notice Set the supported status of a token
     * @param _token Address of the token
     * @param _supported True if the token is supported, false if unsupported
     */
    function setSupportedToken(address _token, bool _supported) external;

    /**
     * @notice Check if an account has a role. Reverts if the account does not have the role
     * @param _role Role to check
     * @param _account Account to check
     */
    function checkRole(bytes32 _role, address _account) external view;

    /**
     * @notice Role for configuration
     * @return Role
     */
    function CONFIGURATION_ROLE() external view returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice Role for execution of requests
     * @return Role
     */
    function EXECUTION_ROLE() external view returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice Check if a token is supported
     * @param _token Address of the token
     * @return True if the token is supported
     */
    function supportedTokens(address _token) external view returns (bool);

    /**
     * @notice Check if a request has been processed
     * @param _requestId ID of the request
     * @return True if the request has been processed
     */
    function processedRequests(bytes32 _requestId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IMeldBridgeBase} from "./IMeldBridgeBase.sol";

/**
 * @title Meld Bridge Receiver interface
 * @notice Interface for interacting with the Meld Bridge Receiver contract
 * @author MELD team
 */
interface IMeldBridgeReceiver is IMeldBridgeBase {
    /**
     * @notice Event emitted when a user requests to bridge tokens
     * @param user Address of the user
     * @param token Address of the token
     * @param amount Amount of tokens to bridge
     */
    event BridgeRequested(address indexed user, address indexed token, uint256 amount);

    /**
     * @notice Event emitted when the wETH address is set
     * @param executedBy Address that executed the action
     * @param wETH Address of the wETH contract
     */
    event WETHAddressSet(address indexed executedBy, address indexed wETH);

    /**
     * @notice Event emitted when the Meld Farming Manager is deployed
     * @param executedBy Address that executed the action
     * @param meldFarmingManagerAddress Address of the Meld Farming Manager
     */
    event MeldFarmingManagerDeployed(
        address indexed executedBy,
        address indexed meldFarmingManagerAddress
    );

    /**
     * @notice Event emitted when a user requests to bridge ERC721 tokens
     * @param user Address of the user
     * @param token Address of the token
     * @param tokenId Token ID to bridge
     */
    event BridgeERC721Requested(address indexed user, address indexed token, uint256 tokenId);

    /**
     * @notice Event emitted when a user requests to bridge ERC1155 tokens
     * @param user Address of the user
     * @param token Address of the token
     * @param tokenId Token ID to bridge
     * @param amount Amount of tokens to bridge
     */
    event BridgeERC1155Requested(
        address indexed user,
        address indexed token,
        uint256 tokenId,
        uint256 amount
    );

    /**
     * @notice Event emitted when ERC20 tokens are withdrawn to a user
     * @param token Address of the token
     * @param to Address of the user
     * @param amount Amount of tokens withdrawn
     * @param requestID ID of the request
     */
    event WithdrawnToUser(
        address indexed token,
        address indexed to,
        uint256 amount,
        bytes32 indexed requestID
    );

    /**
     * @notice Event emitted when ERC721 tokens are withdrawn to a user
     * @param token Address of the token
     * @param to Address of the user
     * @param tokenId Token ID withdrawn
     * @param requestID ID of the request
     */
    event WithdrawnERC721ToUser(
        address indexed token,
        address indexed to,
        uint256 tokenId,
        bytes32 indexed requestID
    );

    /**
     * @notice Event emitted when ERC1155 tokens are withdrawn to a user
     * @param token Address of the token
     * @param to Address of the user
     * @param tokenId Token ID withdrawn
     * @param amount Amount of tokens withdrawn
     * @param requestID ID of the request
     */
    event WithdrawnERC1155ToUser(
        address indexed token,
        address indexed to,
        uint256 tokenId,
        uint256 amount,
        bytes32 indexed requestID
    );

    /**
     * @notice Function called to bridge ERC20 tokens
     * @param _token Address of the token
     * @param _amount Amount of tokens to bridge
     */
    function bridge(address _token, uint256 _amount) external;

    /**
     * @notice Function called to bridge native tokens
     * @dev This function is payable so the amount of tokens to bridge is the value sent with the transaction
     */
    function bridgeNative() external payable;

    /**
     * @notice Function called to bridge ERC721 tokens
     * @param _token Address of the token
     * @param _tokenId Token ID to bridge
     */
    function bridgeERC721(address _token, uint256 _tokenId) external;

    /**
     * @notice Function called to bridge ERC1155 tokens
     * @param _token Address of the token
     * @param _tokenId Token ID to bridge
     * @param _amount Amount of tokens to bridge
     */
    function bridgeERC1155(address _token, uint256 _tokenId, uint256 _amount) external;

    /**
     * @notice Function called to withdraw tokens to a user
     * @param _token Address of the token
     * @param _to Address of the user
     * @param _amount Amount of tokens to withdraw
     * @param _requestID ID of the request
     * @param _extra Additional data
     */
    function withdrawToUser(
        address _token,
        address _to,
        uint256 _amount,
        bytes32 _requestID,
        bytes calldata _extra
    ) external;

    /**
     * @notice Function called to withdraw ERC721 tokens to a user
     * @param _token Address of the token
     * @param _to Address of the user
     * @param _tokenId Token ID to withdraw
     * @param _requestID ID of the request
     */
    function withdrawERC721ToUser(
        address _token,
        address _to,
        uint256 _tokenId,
        bytes32 _requestID
    ) external;

    /**
     * @notice Function called to withdraw ERC1155 tokens to a user
     * @param _token Address of the token
     * @param _to Address of the user
     * @param _tokenId Token ID to withdraw
     * @param _amount Amount of tokens to withdraw
     * @param _requestID ID of the request
     */
    function withdrawERC1155ToUser(
        address _token,
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes32 _requestID
    ) external;

    /**
     * @notice Function called to withdraw tokens to multiple users
     * @param _token Address of the token
     * @param _to Addresses of the users
     * @param _amount Amounts of tokens to withdraw
     * @param _requestID IDs of the requests
     * @param _extra Additional data
     */
    function withdrawToUsers(
        address _token,
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes32[] calldata _requestID,
        bytes[] calldata _extra
    ) external;

    /**
     * @notice Function called to withdraw ERC721 tokens to multiple users
     * @param _token Address of the token
     * @param _to Addresses of the users
     * @param _tokenId Token IDs to withdraw
     * @param _requestID IDs of the requests
     */
    function withdrawERC721ToUsers(
        address _token,
        address[] calldata _to,
        uint256[] calldata _tokenId,
        bytes32[] calldata _requestID
    ) external;

    /**
     * @notice Function called to withdraw ERC1155 tokens to multiple users
     * @param _token Address of the token
     * @param _to Addresses of the users
     * @param _tokenId Token IDs to withdraw
     * @param _amount Amounts of tokens to withdraw
     * @param _requestID IDs of the requests
     */
    function withdrawERC1155ToUsers(
        address _token,
        address[] calldata _to,
        uint256[] calldata _tokenId,
        uint256[] calldata _amount,
        bytes32[] calldata _requestID
    ) external;

    /**
     * @notice Returns the bytes32 identifier for the REBALANCER_ROLE
     */
    function REBALANCER_ROLE() external view returns (bytes32); // solhint-disable-line func-name-mixedcase

    /**
     * @notice Returns the address of the wETH contract
     */
    function wETHAddress() external view returns (address payable);

    /**
     * @notice Returns the address of the Meld Farming Manager
     */
    function getFarmingManagerAddress() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title Meld Farming interface
 * @notice Interface for the Meld Farming Manager contract as well as the adapters
 * @author MELD team
 */
interface IMeldFarming is IERC165 {
    /**
     * @notice Emitted when an asset is deposited
     * @param asset Address of the asset
     * @param amount Amount deposited
     */
    event Deposited(address indexed asset, uint256 amount);

    /**
     * @notice Emitted when an asset is withdrawn
     * @param asset Address of the asset
     * @param amount Amount withdrawn
     */
    event Withdrawn(address indexed asset, uint256 amount);

    /**
     * @notice Deposits funds into the Meld Farming Manager or the adapter
     * @param _asset Address of the asset to deposit
     * @param _amount Amount to deposit
     * @param _extra Extra data for the deposit
     */
    function deposit(address _asset, uint256 _amount, bytes calldata _extra) external;

    /**
     * @notice Withdraws funds from the Meld Farming Manager or the adapter
     * @param _asset Address of the asset to withdraw
     * @param _amount Amount to withdraw
     * @param _extra Extra data for the withdraw
     * @return Amount withdrawn
     */
    function withdraw(
        address _asset,
        uint256 _amount,
        bytes calldata _extra
    ) external returns (uint256);

    /**
     * @notice Claims rewards from the adapter
     * @param _asset Address of the asset to claim
     * @param _extra Extra data for the claim
     * @param _withdrawOnlyAvailable If true, only claims the rewards up to the available liquidity. If false and there's not enough liquidity, it reverts
     * @return Amount claimed
     */
    function claimRewards(
        address _asset,
        bytes calldata _extra,
        bool _withdrawOnlyAvailable
    ) external returns (uint256);

    /**
     * @notice Returns the total available liquidity for a given asset
     * @param _asset Address of the asset
     * @return Available liquidity
     */
    function getAvailableLiquidity(address _asset) external view returns (uint256);

    /**
     * @notice Returns the amount of rewards available for the `_asset`
     * @param _asset Address of the asset
     * @return Amount of rewards available
     */
    function getRewardsAmount(address _asset) external view returns (uint256);

    /**
     * @notice Returns the address of the Meld Farming Manager
     * @return Address of the Meld Farming Manager
     */
    function meldFarmingManager() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IMeldFarming} from "./IMeldFarming.sol";
import {IMeldBridgeReceiver} from "./IMeldBridgeReceiver.sol";

/**
 * @title Meld Farming Manager interface
 * @notice Interface for the Meld Farming Manager contract
 * @dev This interface also includes the IMeldFarming interface
 * @author MELD team
 */
interface IMeldFarmingManager is IMeldFarming {
    struct AdapterConfig {
        string adapterIdStr;
        bool enabled;
        bool locked;
        bool exists;
    }

    struct YieldAssetAdapter {
        uint256 yieldDeposit;
        uint256 index;
        uint256 lastTimestampRewardsClaimed;
        bool exists;
    }

    struct YieldAssetConfig {
        uint256 liquidDeposit;
        mapping(uint256 index => address adapterAddress) adapterIndex;
        mapping(address adapterAddress => YieldAssetAdapter) adapters;
        uint256 numAdapters;
    }

    struct RebalancingInfo {
        address asset;
        address adapterAddress;
        uint256 amount;
        RebalanceAction action;
        bytes extra;
    }

    enum RebalanceAction {
        NONE,
        DEPOSIT,
        WITHDRAW,
        REQUEST_WITHDRAW
    }

    /**
     * @notice Emitted when the Meld Bridge Receiver contract is set
     * @param bridge Address of the Meld Bridge Receiver contract
     */
    event BridgeSet(address indexed executedBy, address bridge);

    /**
     * @notice Emitted when the treasury address is updated
     * @param executedBy Address that executed the function
     * @param oldTreasury Address of the old treasury
     * @param newTreasury Address of the new treasury
     */
    event TreasuryUpdated(
        address indexed executedBy,
        address indexed oldTreasury,
        address indexed newTreasury
    );

    /**
     * @notice Emitted when a new adapter is added
     * @param executedBy Address that executed the function
     * @param adapterIdStr String ID of the adapter
     * @param adapterAddress Address of the adapter
     * @param locked Boolean indicating if the adapter is locked
     */
    event AdapterAdded(
        address executedBy,
        string indexed adapterIdStr,
        address indexed adapterAddress,
        bool locked
    );

    /**
     * @notice Emitted when an adapter is enabled or disabled
     * @param executedBy Address that executed the function
     * @param adapterAddress Address of the adapter
     * @param enabled Boolean indicating if the adapter is enabled
     */
    event AdapterEnabled(address indexed executedBy, address indexed adapterAddress, bool enabled);

    /**
     * @notice Emitted when an asset is configured with adapters
     * @param executedBy Address that executed the function
     * @param asset Address of the asset
     * @param adapterAddresses Array of adapter addresses
     */
    event AssetConfigSet(
        address indexed executedBy,
        address indexed asset,
        address[] adapterAddresses
    );

    /**
     * @notice Emitted when rewards are claimed
     * @param executedBy Address that executed the function
     * @param asset Address of the asset
     * @param adapterAddress Address of the adapter
     * @param amount Amount claimed
     */
    event RewardsClaimed(
        address indexed executedBy,
        address indexed asset,
        address indexed adapterAddress,
        uint256 amount
    );

    /**
     * @notice Emitted when a rebalance is executed
     * @param executedBy Address that executed the function
     * @param asset Address of the asset
     * @param adapterAddress Address of the adapter
     * @param amount Amount rebalanced
     * @param action Rebalance action. 0: None, 1: Deposit, 2: Withdraw, 3: Request Withdraw
     */
    event Rebalanced(
        address executedBy,
        address indexed asset,
        address indexed adapterAddress,
        uint256 amount,
        RebalanceAction indexed action
    );

    /**
     * @notice Adds a new adapter to the Meld Farming Manager
     * @param _adapterId String ID of the adapter
     * @param _adapterAddress Address of the adapter
     * @param _locked Boolean indicating if the adapter is locked
     */
    function addAdapter(string memory _adapterId, address _adapterAddress, bool _locked) external;

    /**
     * @notice Enables or disables an adapter
     * @param _adapterAddress Address of the adapter
     * @param _enabled Boolean indicating if the adapter is enabled
     */
    function setAdapterEnabled(address _adapterAddress, bool _enabled) external;

    /**
     * @notice Configures an asset with adapters
     * @dev The list of adapters will be the new one, so any previous configuration will be overwritten
     * @dev To remove all adapters, pass an empty array
     * @dev It is needed to call this function even if no adapters will be used for the asset
     * @param _asset Address of the asset
     * @param _adaptersAddresses Array of adapter addresses
     */
    function configAsset(address _asset, address[] memory _adaptersAddresses) external;

    /**
     * @notice Sets the treasury address that will receive the rewards
     * @param _treasury Address of the treasury
     */
    function setTreasury(address _treasury) external;

    /**
     * @notice Moves funds between the adapters and the Meld Farming Manager
     * @param _rebalanceInfo Array of RebalancingInfo, indicating the asset, adapter, amount and action
     */
    function rebalance(RebalancingInfo[] calldata _rebalanceInfo) external;

    /**
     * @notice Returns the adapter address for a given index
     * @param _index Index of the adapter
     * @return Adapter address
     */
    function adapterAddresses(uint256 _index) external view returns (address);

    /**
     * @notice Returns the number of adapters
     * @return Number of adapters
     */
    function numAdapters() external view returns (uint256);

    /**
     * @notice Returns the Meld Bridge Receiver contract address
     * @return Meld Bridge Receiver contract address
     */
    function bridge() external view returns (IMeldBridgeReceiver);

    /**
     * @notice Returns the treasury address
     * @return Treasury address
     */
    function treasury() external view returns (address);

    /**
     * @notice Returns the adapter configuration for a given ID
     * @param _adapterAddress Address of the adapter
     * @return Adapter configuration
     */
    function getAdapter(address _adapterAddress) external view returns (AdapterConfig memory);

    /**
     * @notice Returns the adapter configuration for all adapters
     * @return Array of every Adapter configuration
     */
    function getAllAdapters() external view returns (AdapterConfig[] memory);

    /**
     * @notice Returns the asset configuration for a given asset
     * @param _asset Address of the asset
     * @return assetAdapterIds Array of the adapter IDs for each adapter
     * @return assetAdapterAddressess Array of the adapter addresses for each adapter
     * @return yieldDeposit Array of the yield deposit for each adapter
     * @return lastTimestampRewardsClaimed Array of the last timestamp rewards claimed for each adapter
     * @return liquidDeposit Liquid deposit for the asset
     * @return totalDeposit Total deposit for the asset
     * @return totalAvailableLiquidity Total available liquidity for the asset
     */
    function getYieldAssetConfig(
        address _asset
    )
        external
        view
        returns (
            string[] memory assetAdapterIds,
            address[] memory assetAdapterAddressess,
            uint256[] memory yieldDeposit,
            uint256[] memory lastTimestampRewardsClaimed,
            uint256 liquidDeposit,
            uint256 totalDeposit,
            uint256 totalAvailableLiquidity
        );

    /**
     * @notice Returns the total deposit for a given asset
     * @param _asset Address of the asset
     * @return Total deposit
     */
    function getTotalDeposit(address _asset) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title Wrapped AVAX/ETH interface
 * @notice Interface for interacting with the Wrapped AVAX/ETH token
 * @dev This interface is used to interact with the Wrapped AVAX/ETH token
 * @author MELD team
 */
interface IWETH is IERC20Metadata {
    /**
     * @notice Emmited when ETH is deposited to receive WETH
     * @param dst Address that receives the WETH
     * @param wad Amount of ETH deposited
     */
    event Deposit(address indexed dst, uint wad);

    /**
     * @notice Emmited when ETH is withdrawn
     * @param src Address that withdraws the ETH
     * @param wad Amount of ETH withdrawn
     */
    event Withdrawal(address indexed src, uint wad);

    /**
     * @notice Deposit ETH to receive WETH
     * @dev This function is payable so the amount of ETH deposited is the value sent with the transaction
     */
    function deposit() external payable;

    /**
     * @notice Withdraw ETH burning WETH
     * @param _wad Amount of ETH to withdraw
     */
    function withdraw(uint256 _wad) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title Errors library
 * @notice Defines the error messages emitted by the different contracts of the Meld Bridge
 * @dev Error messages prefix glossary:
 * - MBP: Meld Bridge Panoptic
 * - MBR: Meld Bridge Receiver
 * - MFM: Meld Farming Manager
 * - BYA: Base Yield Adapter
 * @author MELD team
 */
library Errors {
    string public constant INVALID_ARRAY_LENGTH = "Invalid array length";
    string public constant TOKEN_NOT_SUPPORTED = "Token is not supported";
    string public constant REQUEST_ALREADY_PROCESSED = "Request already processed";
    string public constant INVALID_ADDRESS = "Invalid address";
    string public constant INVALID_AMOUNT = "Invalid amount";

    string public constant MBP_REQUEST_NOT_PROCESSED = "MeldBridgePanoptic: Request not processed";
    string public constant MBP_NETWORK_NOT_SUPPORTED =
        "MeldBridgePanoptic: Network is not supported for this token";
    string public constant MBP_INSUFFICIENT_FEE = "MeldBridgePanoptic: Insufficient fee";
    string public constant MBP_TRANSFERRING_FEE_FAILED =
        "MeldBridgePanoptic: Transferring fee failed";
    string public constant MBP_SIGNATURE_EXPIRED = "MeldBridgePanoptic: Signature is expired";

    string public constant MBR_ONLY_WETH_ALLOWED =
        "MeldBridgeReceiver: Only WETH can deposit ETH directly to the contract";
    string public constant MBR_NATIVE_NOT_SUPPORTED =
        "MeldBridgeReceiver: Native Token is not supported";
    string public constant MBR_NATIVE_WRAPPING_FAILED =
        "MeldBridgeReceiver: Native wrapping failed";
    string public constant MBR_NATIVE_TOKEN_NOT_WETH =
        "MeldBridgeReceiver: Native token withdraw is not WETH";

    string public constant MFM_ONLY_BRIDGE_ALLOWED =
        "MeldFarmingManager: Only bridge can call this function";
    string public constant MFM_ADAPTER_ALREADY_EXISTS =
        "MeldFarmingManager: Adapter already exists";
    string public constant MFM_ADAPTER_ADDRESS_ALREADY_EXISTS =
        "MeldFarmingManager: Adapter address already exists";
    string public constant MFM_ADAPTER_DOES_NOT_EXIST =
        "MeldFarmingManager: Adapter does not exist";
    string public constant MFM_ADAPTER_DISABLED = "MeldFarmingManager: Adapter is disabled";
    string public constant MFM_AMOUNT_MISMATCH = "MeldFarmingManager: Amount mismatch";
    string public constant MFM_NOT_ENOUGH_FUNDS = "MeldFarmingManager: Not enough funds";
    string public constant MFM_INVALID_ADAPTER_ID = "MeldFarmingManager: Invalid adapter ID";
    string public constant MFM_NO_ADAPTERS_CONFIGURED =
        "MeldFarmingManager: No adapters configured";
    string public constant MFM_INVALID_ADAPTER_MFM =
        "MeldFarmingManager: Invalid adapter MeldFarmingManager address";
    string public constant MFM_ADAPTER_IS_NOT_MELD_FARMING =
        "MeldFarmingManager: Adapter does not implement IMeldFarming";

    string public constant RT_NO_TOKENS_TO_RESCUE = "RescueTokens: No tokens to rescue";
    string public constant RT_RESCUER_NOT_OWNER =
        "RescueTokens: Contract is not the owner of the token";

    string public constant BYA_ONLY_FARMING_MANAGER_ALLOWED =
        "BaseYieldAdapter: Only MeldFarmingManager can call this function";

    string public constant AAVE_ADAPTER_INCONSISTENT_ATOKEN_BALANCE =
        "AaveAdapter: Inconsistent aToken balance";
    string public constant AAVE_ADAPTER_INVALID_WITHDRAWN_AMOUNT =
        "AaveAdapter: Invalid withdrawn amount";

    string public constant GOGOPOOL_ONLY_WAVAX_ALLOWED = "GoGoPoolAdapter: Only WAVAX is allowed";
    string public constant GOGOPOOL_AVAX_RECEIVED_OUTSIDE_WINDOW =
        "GoGoPoolAdapter: AVAX received outside window";
}