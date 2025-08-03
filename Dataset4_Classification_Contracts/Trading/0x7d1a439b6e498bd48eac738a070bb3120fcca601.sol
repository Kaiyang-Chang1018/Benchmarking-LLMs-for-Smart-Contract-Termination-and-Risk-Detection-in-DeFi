// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC165.sol";

/// @title ERC-1155 Multi Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-1155
/// Note: The ERC-165 identifier for this interface is 0xd9b67a26.
interface IERC1155 is IERC165 {
    /// @dev
    /// - Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
    /// - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
    /// - The `_from` argument MUST be the address of the holder whose balance is decreased.
    /// - The `_to` argument MUST be the address of the recipient whose balance is increased.
    /// - The `_id` argument MUST be the token type being transferred.
    /// - The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
    /// - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
    /// - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );

    /// @dev
    /// - Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
    /// - The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
    /// - The `_from` argument MUST be the address of the holder whose balance is decreased.
    /// - The `_to` argument MUST be the address of the recipient whose balance is increased.
    /// - The `_ids` argument MUST be the list of tokens being transferred.
    /// - The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
    /// - When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
    /// - When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );

    /// @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absence of an event assumes disabled).
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @dev MUST emit when the URI is updated for a token ID. URIs are defined in RFC 3986.
    /// The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    event URI(string _value, uint256 indexed _id);

    /// @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
    /// @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
    /// - MUST revert if `_to` is the zero address.
    /// - MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
    /// - MUST revert on any other error.
    /// - MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
    /// - After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
    /// @param _from Source address
    /// @param _to Target address
    /// @param _id ID of the token type
    /// @param _value Transfer amount
    /// @param _data Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    /// @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
    /// @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
    /// - MUST revert if `_to` is the zero address.
    /// - MUST revert if length of `_ids` is not the same as length of `_values`.
    /// - MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
    /// - MUST revert on any other error.
    /// - MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
    /// - Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
    /// - After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
    /// @param _from Source address
    /// @param _to Target address
    /// @param _ids IDs of each token type (order and length must match _values array)
    /// @param _values Transfer amounts per token type (order and length must match _ids array)
    /// @param _data Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    /// @notice Get the balance of an account's tokens.
    /// @param _owner The address of the token holder
    /// @param _id ID of the token
    /// @return The _owner's balance of the token type requested
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    /// @notice Get the balance of multiple account/token pairs
    /// @param _owners The addresses of the token holders
    /// @param _ids ID of the tokens
    /// @return The _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    /// @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
    /// @dev MUST emit the ApprovalForAll event on success.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Queries the approval status of an operator for a given owner.
    /// @param _owner The owner of the tokens
    /// @param _operator Address of authorized operator
    /// @return True if the operator is approved, false if not
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    /// uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
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
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
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
// OpenZeppelin Contracts (last updated v5.1.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
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
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
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
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../utils/introspection/IERC165.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;

import {IERC165} from "../../utils/introspection/IERC165.sol";

/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC-1155 token type. This function is
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
     * @dev Handles the receipt of a multiple ERC-1155 token types. This function
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.20;

import {IERC165, ERC165} from "../../../utils/introspection/ERC165.sol";
import {IERC1155Receiver} from "../IERC1155Receiver.sol";

/**
 * @dev Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC-1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 */
abstract contract ERC1155Holder is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {IERC1155} from "lib/forge-std/src/interfaces/IERC1155.sol";

interface IFractionalAssets is IERC1155 {
    function totalSupply(uint256 tokenId) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {ERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {ERC1155Holder} from "lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {RewardsStream, StreamHandler} from "./streams.sol";

import {IFractionalAssets} from "src/fractional/IFractionalAssets.sol";
import {IPinlinkOracle} from "src/oracles/IPinlinkOracle.sol";

/// @notice All data from asset fractions listed for sale
struct Listing {
    // contract address containing multiple fractional assets, each of them with a tokenId
    address fractionalAssets;
    // tokenId of the asset being listed
    uint256 tokenId;
    // owner of the listing. The only one who can make modifications to the listing
    // the `seller` cannot be modified once created
    address seller;
    // number of tokens of fractions of the asset currently for sale
    // `amount` is decreased when tokens are purchased or delisted
    uint256 amount;
    // price per asset fraction in usd with 18 decimals. This does not include the fees.
    uint256 usdPricePerFraction;
    // Latets timestamp when the listing is valid
    uint256 deadline;
}

/// @title PinLink: RWA-Tokenized DePIN Marketplace
/// @author PinLink (@jacopod: https://github.com/JacoboLansac)
/// @notice A marketplace where users can trade Pinlink Fractional assets, earning rewards while assets are listed for sale
contract PinlinkShop is ERC165, ERC1155Holder, AccessControl {
    using SafeERC20 for IERC20;
    using StreamHandler for RewardsStream;

    /// @dev operator can deposit rewards, or claim unassigned rewards
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @dev admin cannot set the fee percentage above 10%
    uint256 public constant MAX_FEE_PERC = 1000;

    /// @notice divisor when calculating the purchase fee
    uint256 public constant FEE_DENOMINATOR = 10_000;

    /// @notice PIN ERC20 token address (only allowed payment token in purchases)
    address public immutable PIN;

    /// @notice ERC20 token in which rewards are distributed to all assets (USDC)
    address public immutable REWARDS_TOKEN;

    /// @notice default fee initialized at 5%
    /// @dev This percentage is the ratio between fees/payment for seller (not fees/total).
    /// @dev If fee=5%, and price=100, buyer pays 105, seller receives 100, fee receiver gets 5.
    uint256 public purchaseFeePerc = 500;

    /// @notice address to collect purchase fees
    address public feeReceiver;

    /// @notice proxy address where all rewards go when assets are withdrawn
    address public constant REWARDS_PROXY_ACCOUNT = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;

    /// @notice oracle to convert between PIN and USD pricing
    address public oracle;

    /// @notice handles the rewards streams for each asset (fractionalAssets, tokenId)
    mapping(address fractionalAssets => mapping(uint256 tokenId => RewardsStream)) public streams;

    /// keeps track of the listings per listingId
    mapping(bytes32 listingId => Listing) internal _listings;

    /// balances of how many assets are listed by a seller
    /// fractionalAssets ==> tokenId ==> seller ==> amount
    mapping(address fractionalAssets => mapping(uint256 tokenId => mapping(address seller => uint256 balance))) internal
        _listedBalances;

    ///////////////////// Errors /////////////////////

    error SenderIsNotSeller();
    error AssetNotEnabled();
    error NotEnoughTokens();
    error NotEnoughUnlistedTokens();
    error ExpectedNonZeroAmount();
    error ExpectedNonZeroPrice();
    error ExpectedNonZero();
    error InvalidParameter();
    error InvalidListingId();
    error ListingIdAlreadyExists();
    error SlippageExceeded();
    error AlreadyEnabled();
    error ListingDeadlineExpired();
    error DeadlineHasExpiredAlready();
    error InvalidOraclePrice();
    error InvalidOracleInterface();
    error StaleOraclePrice();

    ///////////////////// Events /////////////////////

    event FeeReceiverSet(address indexed receiver);
    event FeePercentageSet(uint256 newFeePerc);
    event AssetEnabled(
        address indexed fractionalAssets,
        uint256 indexed tokenId,
        uint256 assetSupply,
        address depositor,
        address receiver
    );
    event OracleSet(address indexed oracle);
    event RewardsDistributed(
        address indexed fractionalAssets,
        uint256 indexed tokenId,
        address indexed operator,
        uint256 amount,
        uint256 drippingPeriod
    );

    event Listed(
        bytes32 indexed listingId,
        address indexed seller,
        uint256 indexed tokenId,
        address fractionalAssets,
        uint256 amount,
        uint256 usdPricePerFraction,
        uint256 deadline
    );
    event Delisted(bytes32 indexed listingId, uint256 amount);
    event PriceUpdated(bytes32 indexed listingId, uint256 usdPricePerItem);
    event DeadlineExtended(bytes32 indexed listingId, uint256 newDeadline);
    event Purchased(
        bytes32 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 pinPaymentForSeller,
        uint256 usdPaymentForSeller,
        uint256 feesPerc
    );
    event Claimed(address indexed fractionalAssets, uint256 indexed tokenId, address indexed account, uint256 amount);
    event FractionsWithdrawn(
        address indexed fractionalAssets, uint256 indexed tokenId, uint256 amount, address receiver
    );
    event FractionsDeposited(
        address indexed fractionalAssets, uint256 indexed tokenId, uint256 amount, address receiver
    );

    ///////////////////////////////////////////////////

    constructor(address pin_, address pinOracle_, address rewardToken_) {
        PIN = pin_;
        REWARDS_TOKEN = rewardToken_; // USDC exclusively, in ethereum mainnet.

        oracle = pinOracle_;
        feeReceiver = msg.sender;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    modifier onlySeller(bytes32 listingId) {
        address seller = _listings[listingId].seller;
        if (seller == address(0)) revert InvalidListingId();
        if (seller != msg.sender) revert SenderIsNotSeller();
        _;
    }

    ///////////////////// only certain roles /////////////////////

    function setFeeReceiver(address receiver) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (receiver == address(0)) revert ExpectedNonZero();
        feeReceiver = receiver;
        emit FeeReceiverSet(receiver);
    }

    function setFee(uint256 newFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newFee > MAX_FEE_PERC) revert InvalidParameter();
        purchaseFeePerc = newFee;
        emit FeePercentageSet(newFee);
    }

    function setOracle(address oracle_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(IPinlinkOracle(oracle_).supportsInterface(type(IPinlinkOracle).interfaceId), InvalidOracleInterface());

        // a stale oracle will return 0. Potentially this also validates the oracle has at least 18dp
        uint256 testValue = IPinlinkOracle(oracle_).convertToUsd(PIN, 1e18);
        if (testValue < 1e6) revert InvalidOraclePrice();

        emit OracleSet(oracle_);
        oracle = oracle_;
    }

    /// @notice Enables an asset in the ecosystem
    /// @dev Once enabled, assets cannot be disabled.
    function enableAsset(address fractionalAssets, uint256 tokenId, address receiver)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        RewardsStream storage stream = streams[fractionalAssets][tokenId];

        if (stream.isEnabled()) revert AlreadyEnabled();

        uint256 assetSupply = IFractionalAssets(fractionalAssets).totalSupply(tokenId);
        stream.enableAsset(assetSupply, receiver);

        emit AssetEnabled(fractionalAssets, tokenId, assetSupply, msg.sender, receiver);
        IFractionalAssets(fractionalAssets).safeTransferFrom(msg.sender, address(this), tokenId, assetSupply, "");
    }

    /// @notice deposit an `amount` of rewards to be distributed linearly over a drippingPeriod for an asset
    function depositRewards(address fractionalAssets, uint256 tokenId, uint256 amount, uint256 drippingPeriod)
        external
        onlyRole(OPERATOR_ROLE)
    {
        RewardsStream storage stream = streams[fractionalAssets][tokenId];

        stream.depositRewards(amount, drippingPeriod);

        emit RewardsDistributed(fractionalAssets, tokenId, msg.sender, amount, drippingPeriod);
        IERC20(REWARDS_TOKEN).safeTransferFrom(msg.sender, address(this), amount);
    }

    /// @notice allows an admin to collect the unassigned rewards resulting from assets leaving the PinlinkShop
    function claimUnassignedRewards(address fractionalAssets, uint256 tokenId, address to)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 claimed = streams[fractionalAssets][tokenId].claimRewards(REWARDS_PROXY_ACCOUNT);
        if (claimed == 0) return;

        IERC20(REWARDS_TOKEN).safeTransfer(to, claimed);
        emit Claimed(fractionalAssets, tokenId, to, claimed);
    }

    ///////////////////// seller functions ///////////////////////////

    /// @notice lists a certain amount of fractions of a tokenId for sale, with the price denominated in USD (18 dps)
    /// @dev two identical listings sent in the same block by the same seller will revert due to a conflicting listingId
    function list(
        address fractionalAssets,
        uint256 tokenId,
        uint256 amount,
        uint256 usdPricePerFraction, // usd price with 18 decimals
        uint256 deadline
    ) external returns (bytes32 listingId) {
        listingId = _list(fractionalAssets, tokenId, amount, usdPricePerFraction, deadline);
    }

    /// @notice delists a certain amount of fractions from a listingId
    /// @dev accepts amount=type(uint256).max to delist all the fractions
    function delist(bytes32 listingId, uint256 amount) external onlySeller(listingId) {
        require(amount > 0, ExpectedNonZero());

        Listing storage listing = _listings[listingId];
        uint256 listedAmount = listing.amount;

        if (amount == type(uint256).max) {
            amount = listedAmount;
        }

        if (amount > listedAmount) revert NotEnoughTokens();

        listing.amount = listing.amount - amount;
        _listedBalances[listing.fractionalAssets][listing.tokenId][msg.sender] -= amount;

        emit Delisted(listingId, amount);
    }

    /// @notice modifies the price or deadline of a listing
    /// @dev accepts 0 as a value to keep the existing value of both parameters
    /// @dev nothing prevents from setting the existing values again. No harm either.
    function modifyListing(bytes32 listingId, uint256 usdPricePerFraction, uint256 newDeadline)
        external
        onlySeller(listingId)
    {
        if (usdPricePerFraction > 0) {
            _listings[listingId].usdPricePerFraction = usdPricePerFraction;
            emit PriceUpdated(listingId, usdPricePerFraction);
        }
        if (newDeadline > 0) {
            require(newDeadline > block.timestamp, DeadlineHasExpiredAlready());
            _listings[listingId].deadline = newDeadline;
            emit DeadlineExtended(listingId, newDeadline);
        }
    }
    /// @notice allows a buyer to purchase a certain amount of fractions from a listing
    /// @dev The buyer pays in PIN tokens, but the listing is denominated in USD.
    /// @dev The fees are added on top of the listing price, so the seller always gets the listing price
    /// @dev An oracle is used internally to convert between PIN and USD
    /// @dev the maxTotalPinAmount protects from slippage and also from a malicious sellers frontrunning the purchase and increasing the price

    function purchase(bytes32 listingId, uint256 fractionsAmount, uint256 maxTotalPinAmount) external {
        require(fractionsAmount > 0, ExpectedNonZero());

        Listing storage listing = _listings[listingId];

        address seller = listing.seller;
        uint256 tokenId = listing.tokenId;
        address fractionalAssets = listing.fractionalAssets;

        // make InvalidListingId be the one that fails first
        require(seller != address(0), InvalidListingId());
        // purchases on the exact deadline not allowed
        require(block.timestamp < listing.deadline, ListingDeadlineExpired());

        {
            // to prevent stack too deep
            uint256 listedAmount = listing.amount;
            if (listedAmount < fractionsAmount) revert NotEnoughTokens();
            // update listing information in storage
            listing.amount = listedAmount - fractionsAmount;
            _listedBalances[fractionalAssets][tokenId][seller] -= fractionsAmount;

            streams[fractionalAssets][tokenId].transferBalances(seller, msg.sender, fractionsAmount);
        }

        uint256 feesPerc = purchaseFeePerc;
        uint256 usdPaymentForSeller = listing.usdPricePerFraction * fractionsAmount;
        (uint256 pinPaymentForSeller, uint256 pinFees) = _convertAndApplyFees(usdPaymentForSeller, feesPerc);
        uint256 totalPinPayment = pinPaymentForSeller + pinFees;

        if (pinPaymentForSeller == 0) revert StaleOraclePrice();
        if (totalPinPayment > maxTotalPinAmount) revert SlippageExceeded();

        IERC20(PIN).safeTransferFrom(msg.sender, seller, pinPaymentForSeller);
        // if amount == 0, PIN transfers revert
        if (pinFees > 0) {
            IERC20(PIN).safeTransferFrom(msg.sender, feeReceiver, pinFees);
        }

        emit Purchased(
            listingId, msg.sender, seller, fractionsAmount, pinPaymentForSeller, usdPaymentForSeller, feesPerc
        );
    }

    /// @notice claims rewards for a certain asset and transfers it to the caller
    function claimRewards(address fractionalAssets, uint256 tokenId) external {
        uint256 claimed = streams[fractionalAssets][tokenId].claimRewards(msg.sender);
        if (claimed == 0) return;

        IERC20(REWARDS_TOKEN).safeTransfer(msg.sender, claimed);
        emit Claimed(fractionalAssets, tokenId, msg.sender, claimed);
    }

    /// @notice claims rewards for multiple assets and transfers them to the caller
    function claimRewardsMultiple(address fractionalAssets, uint256[] calldata tokenIds) external {
        uint256 totalClaimed;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // stream.claimRewards resets the rewards, so no harm in putting the same tokenId multiple times
            uint256 claimed = streams[fractionalAssets][tokenIds[i]].claimRewards(msg.sender);
            totalClaimed += claimed;
            if (claimed > 0) {
                // we emit here individual events for each tokenId for accountability reasons
                emit Claimed(fractionalAssets, tokenIds[i], msg.sender, claimed);
            }
        }
        if (totalClaimed > 0) {
            IERC20(REWARDS_TOKEN).safeTransfer(msg.sender, totalClaimed);
        }
    }

    /// @notice withdraws an asset outside of the Pinlink ecosystem.
    /// @dev Listed assets cannot be withdrawn, they have to be first delisted
    /// @dev When assets are withdrawn, the corresponding rewards are redirected to the REWARDS_PROXY_ACCOUNT account
    function withdrawAsset(address fractionalAssets, uint256 tokenId, uint256 amount, address receiver) external {
        if (amount == 0) revert ExpectedNonZeroAmount();
        if (_nonListedBalance(fractionalAssets, tokenId, msg.sender) < amount) revert NotEnoughUnlistedTokens();

        // this does't transfer the assets, but only the internal accounting of staking balances
        streams[fractionalAssets][tokenId].transferBalances(msg.sender, REWARDS_PROXY_ACCOUNT, amount);

        emit FractionsWithdrawn(fractionalAssets, tokenId, amount, receiver);
        IFractionalAssets(fractionalAssets).safeTransferFrom(address(this), receiver, tokenId, amount, "");
    }

    /// @notice deposit an enabled asset into the ecosystem
    /// @dev the assets are automatically staked as they enter in the ecosystem
    function depositAsset(address fractionalAssets, uint256 tokenId, uint256 amount) external {
        _deposit(fractionalAssets, tokenId, amount);
    }

    function depositAndList(
        address fractionalAssets,
        uint256 tokenId,
        uint256 amount,
        uint256 usdPricePerFraction,
        uint256 deadline
    ) external returns (bytes32 listingId) {
        _deposit(fractionalAssets, tokenId, amount);
        listingId = _list(fractionalAssets, tokenId, amount, usdPricePerFraction, deadline);
    }

    function rescueToken(address erc20Token, address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (erc20Token == address(REWARDS_TOKEN)) revert InvalidParameter();

        // PIN is not expected to stay in this contract balance, so it is ok to recover
        IERC20(erc20Token).safeTransfer(to, IERC20(erc20Token).balanceOf(address(this)));
    }

    /////////////////// view ///////////////////

    /// @notice returns the total amount of PIN tokens to pay for a certain amount of fractions of a listingId
    /// @dev This view function should not revert, so when the quote request is invalid, it will return "error codes":
    ///      - uint256.max - 1: not enough fractions in listing
    ///      - uint256.max - 2: listing deadline has expired
    ///      - uint256.max - 3: stale oracle price
    /// @dev This returns uint256.max if the price is stale, if the quote request is invalid
    ///      Invalid request == not enough fractions, past deadline, invalid listing, ... etc
    function getQuoteInTokens(bytes32 listingId, uint256 fractionsAmount)
        external
        view
        returns (uint256 totalPurchasePriceInPIN)
    {
        // not worth checking that fractionsAmount must be greater than 0
        if (_listings[listingId].amount < fractionsAmount) return type(uint256).max - 1;
        if (_listings[listingId].deadline <= block.timestamp) return type(uint256).max - 2;

        uint256 usdForSeller = _listings[listingId].usdPricePerFraction * fractionsAmount;
        (uint256 pinForSeller, uint256 pinFees) = _convertAndApplyFees(usdForSeller, purchaseFeePerc);

        // in the case of oracle staleness or wrong token, IPinlinkOracle should revert
        if (pinForSeller == 0) return type(uint256).max - 3;

        totalPurchasePriceInPIN = pinForSeller + pinFees;
    }

    function getAssetInfo(address fractionalAssets, uint256 tokenId)
        external
        view
        returns (
            uint256 assetSupply,
            uint256 currentGlobalRewardsPerStaked,
            uint256 lastDepositTimestamp,
            uint256 drippingPeriod
        )
    {
        RewardsStream storage stream = streams[fractionalAssets][tokenId];
        return (stream.assetSupply, stream.globalRewardsPerStaked(), stream.lastDepositTimestamp, stream.drippingPeriod);
    }

    /// @notice Returns the `amount` of an asset owned by `account`, and the amount of them that are listed
    /// @dev Note that the `listedBalance` and `notListedBalance` ignore the deadline parameter here, so this is only an approximation
    function getBalances(address fractionalAssets, uint256 tokenId, address account)
        external
        view
        returns (uint256 stakedBalance, uint256 listedBalance, uint256 notListedBalance)
    {
        /// listedBalance is a subset of stakedBalance, so `stakedBalance >= listedBalance` always
        stakedBalance = streams[fractionalAssets][tokenId].stakedBalances[account];
        listedBalance = _listedBalances[fractionalAssets][tokenId][account];
        notListedBalance = stakedBalance - listedBalance;
    }

    /// @notice returns a listing object with all its attributes
    function getListing(bytes32 listingId) external view returns (Listing memory) {
        return _listings[listingId];
    }

    /// @notice returns True if the admins have enabled the asset in the ecosystem
    function isAssetEnabled(address fractionalAssets, uint256 tokenId) external view returns (bool) {
        return streams[fractionalAssets][tokenId].isEnabled();
    }

    function getPendingRewards(address fractionalAssets, uint256 tokenId, address account)
        external
        view
        returns (uint256)
    {
        return streams[fractionalAssets][tokenId].getPendingRewards(account);
    }

    function getRewardsConstants()
        public
        pure
        returns (
            uint256 minRewardsDepositAmount,
            uint256 maxAssetSupply,
            uint256 minDrippingPeriod,
            uint256 maxDrippingPeriod
        )
    {
        return (
            StreamHandler.MIN_REWARDS_DEPOSIT_AMOUNT,
            StreamHandler.MAX_ASSET_SUPPLY,
            StreamHandler.MIN_DRIPPING_PERIOD,
            StreamHandler.MAX_DRIPPING_PERIOD
        );
    }

    /////////////////// ERC165 compliancy ///////////////////

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, AccessControl, ERC1155Holder)
        returns (bool)
    {
        return ERC1155Holder.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    /////////////////// internal functions ///////////////////

    /// @dev listing with same price in same block reverts. Wait one block to list the exact same listing
    function _list(
        address fractionalAssets,
        uint256 tokenId,
        uint256 amount,
        uint256 usdPricePerFraction, // usd price with 18 decimals
        uint256 deadline
    ) internal returns (bytes32 listingId) {
        listingId = keccak256(
            abi.encode(fractionalAssets, tokenId, msg.sender, amount, usdPricePerFraction, deadline, block.number)
        );

        require(amount > 0, ExpectedNonZeroAmount());
        require(deadline > block.timestamp, DeadlineHasExpiredAlready());
        require(usdPricePerFraction > 0, ExpectedNonZeroPrice());
        require(_listings[listingId].seller == address(0), ListingIdAlreadyExists());

        if (amount > _nonListedBalance(fractionalAssets, tokenId, msg.sender)) revert NotEnoughUnlistedTokens();

        // register listing information
        _listings[listingId] = Listing({
            fractionalAssets: fractionalAssets,
            tokenId: tokenId,
            seller: msg.sender,
            amount: amount,
            usdPricePerFraction: usdPricePerFraction,
            deadline: deadline
        });

        _listedBalances[fractionalAssets][tokenId][msg.sender] += amount;

        emit Listed(listingId, msg.sender, tokenId, fractionalAssets, amount, usdPricePerFraction, deadline);
    }

    /// @notice Converts the usd payment for the seller into pin using the oracle, and calculates the fees
    /// @dev the fees/total does not match the feePerc.
    /// @dev Intentionally, feesPerc is the percentage between fees/paymentForSeller
    function _convertAndApplyFees(uint256 usdPaymentForSeller, uint256 _feesPerc)
        internal
        view
        returns (uint256 pinPaymentForSeller, uint256 pinFees)
    {
        pinPaymentForSeller = IPinlinkOracle(oracle).convertFromUsd(address(PIN), usdPaymentForSeller);

        // No harm in rounding against the protocol. Max 1 wei lost per purchase.
        pinFees = (pinPaymentForSeller * _feesPerc) / FEE_DENOMINATOR;
    }

    function _deposit(address fractionalAssets, uint256 tokenId, uint256 amount) internal {
        if (amount == 0) revert ExpectedNonZeroAmount();
        // it is only possible to deposit in already enabled assets in the ecosystem
        if (!streams[fractionalAssets][tokenId].isEnabled()) revert AssetNotEnabled();

        // When assets are withdrawn, the rewards are directed to the feeReceiver.
        // When they are deposited back, they are redirected to the staker who deposits
        streams[fractionalAssets][tokenId].transferBalances(REWARDS_PROXY_ACCOUNT, msg.sender, amount);

        emit FractionsDeposited(fractionalAssets, tokenId, amount, msg.sender);
        IFractionalAssets(fractionalAssets).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
    }

    function _nonListedBalance(address fractionalAssets, uint256 tokenId, address account)
        internal
        view
        returns (uint256)
    {
        uint256 accountBalance = streams[fractionalAssets][tokenId].stakedBalances[account];
        uint256 listedBalance = _listedBalances[fractionalAssets][tokenId][account];

        return (accountBalance > listedBalance) ? accountBalance - listedBalance : 0;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

// note each physical asset is represented by a tokenId within a fractional contract
// This contract supports rewards streaming towards multiple fractional assets, and multiple tokenIds within each fractional asset
// A single reward token is common to all staked assets

error PinlinkRewards_AmountTooLow();
error PinlinkRewards_AlreadyEnabled();
error PinlinkRewards_AssetNotEnabled();
error PinlinkRewards_DepositRewardsTooEarly();
error PinlinkRewards_AssetSupplyTooHigh();
error PinlinkRewards_AssetSupplyIsZero();
error PinlinkRewards_DrippingPeriodTooLong();
error PinlinkRewards_DrippingPeriodTooShort();

/// @title RewardsStreamer
/// @notice This struct is used to store the rewards data for each fractional token and each tokenId
struct RewardsStream {
    /// @notice global rewards per staked token, scaled up by PRECISION
    uint256 globalRewardsPerStakedTarget;
    /// @notice the totalSupply, which is static and cannot be modified
    uint256 assetSupply;
    /// @notice the amount that is being dripped
    uint256 deltaGlobalRewardsPerStaked;
    /// @notice timestamp when rewards were last deposited
    uint256 lastDepositTimestamp;
    /// @notice the current length of the dripping period
    uint256 drippingPeriod;
    // staked of each account in this physical asset
    mapping(address => uint256) stakedBalances;
    // Earned rewards that haven't been yet claimed
    mapping(address => uint256) pendingRewards;
    // claimed rewards of each account in this physical asset
    mapping(address => uint256) updatedRewardsPerStaked;
}

library StreamHandler {
    using StreamHandler for RewardsStream;

    uint256 constant PRECISION = 1e18;

    // The rewards are calculated dividing by the asset supply.
    // The larger the supply the larger the reminder, which is lost as rounding errors
    uint256 constant MAX_ASSET_SUPPLY = 150;

    // a minimum of $0.01 in every deposit, to minimize rounding errors
    uint256 constant MIN_REWARDS_DEPOSIT_AMOUNT = 1e4;

    // The dripping period is the period of time after which deposited rewards are fully dripped
    uint256 constant MIN_DRIPPING_PERIOD = 6 hours;
    uint256 constant MAX_DRIPPING_PERIOD = 15 days;

    function isEnabled(RewardsStream storage self) internal view returns (bool) {
        return self.assetSupply > 0;
    }

    function isDrippingPeriodFinished(RewardsStream storage self) internal view returns (bool) {
        return block.timestamp > self.lastDepositTimestamp + self.drippingPeriod;
    }

    function enableAsset(RewardsStream storage self, uint256 assetSupply, address receiver) internal {
        require(assetSupply > 0, PinlinkRewards_AssetSupplyIsZero());
        require(assetSupply < MAX_ASSET_SUPPLY, PinlinkRewards_AssetSupplyTooHigh());
        // At the beginning, all supply starts earing rewards for the receiver until purchased (admin account)
        self.updateRewards(receiver);
        self.stakedBalances[receiver] += assetSupply;
        // assetSupply is immutable so the following field cannot be modified ever again
        self.assetSupply = assetSupply;
    }

    function transferBalances(RewardsStream storage self, address from, address to, uint256 amount) internal {
        self.updateRewards(from);
        self.updateRewards(to);
        self.stakedBalances[from] -= amount;
        self.stakedBalances[to] += amount;
    }

    function claimRewards(RewardsStream storage self, address account) internal returns (uint256 claimed) {
        self.updateRewards(account);
        claimed = self.pendingRewards[account];
        delete self.pendingRewards[account];
    }

    function depositRewards(RewardsStream storage self, uint256 amount, uint256 drippingPeriod) internal {
        if (drippingPeriod > MAX_DRIPPING_PERIOD) revert PinlinkRewards_DrippingPeriodTooLong();
        if (drippingPeriod < MIN_DRIPPING_PERIOD) revert PinlinkRewards_DrippingPeriodTooShort();

        if (!self.isDrippingPeriodFinished()) revert PinlinkRewards_DepositRewardsTooEarly();
        if (!self.isEnabled()) revert PinlinkRewards_AssetNotEnabled();

        // This ensures rounding errors are negligible (less than 0.01$ per deposit)
        if (amount < MIN_REWARDS_DEPOSIT_AMOUNT) revert PinlinkRewards_AmountTooLow();

        // The number of fractions per asset is expected to be on the order of 100.
        // Thus, precision loss will usually be negligible (on the order of less than 100 wei)
        // Therefore, precision loss is deliberately ignored here to save gas
        uint256 delta = (amount * PRECISION) / self.assetSupply;
        /// The dripping mechanism is to avoid step jumps in rewards
        self.globalRewardsPerStakedTarget += delta;
        self.deltaGlobalRewardsPerStaked = delta;
        self.lastDepositTimestamp = block.timestamp;
        self.drippingPeriod = drippingPeriod;
    }

    /// @dev This function returns the global rewards per staked token,
    ///     accounting for a dripping factor to avoid step jumps
    /// @dev at deposit, this returns the previous globalRewardsPerStaked before depositing (no jump)
    /// @dev after drippingPeriod, this returns the target globalRewardsPerStakedTarget
    function globalRewardsPerStaked(RewardsStream storage self) internal view returns (uint256) {
        if (self.lastDepositTimestamp == 0) return 0;

        // safe subtraction as is always less or equal to block.timestamp
        uint256 timeSinceDeposit = block.timestamp - self.lastDepositTimestamp;

        uint256 _drippingDuration = self.drippingPeriod;
        // if the _drippingDuration has passed, then locked is 0
        // at deposit, locked has to be deltaGlobalRewardsPerStaked
        // during the _drippingDuration, locked is an interpolation between deltaGlobalRewardsPerStaked and 0
        uint256 locked = (timeSinceDeposit > _drippingDuration)
            ? 0
            : self.deltaGlobalRewardsPerStaked * (_drippingDuration - (timeSinceDeposit)) / _drippingDuration;

        /// return the target after _drippingDuration, and before that, an interpolation between last and new target
        return self.globalRewardsPerStakedTarget - locked;
    }

    function updateRewards(RewardsStream storage self, address account) internal {
        uint256 globalPerStaked = self.globalRewardsPerStaked();
        self.pendingRewards[account] += self._pendingRewardsSinceLastUpdate(globalPerStaked, account);
        self.updatedRewardsPerStaked[account] = globalPerStaked;
    }

    /// @dev output is is reward tokens (not scaled by PRECISION)
    function getPendingRewards(RewardsStream storage self, address account) internal view returns (uint256) {
        uint256 globalPerStaked = self.globalRewardsPerStaked();
        return self.pendingRewards[account] + self._pendingRewardsSinceLastUpdate(globalPerStaked, account);
    }

    /// @dev output is is reward tokens (not scaled by PRECISION)
    function _pendingRewardsSinceLastUpdate(RewardsStream storage self, uint256 globalPerStaked, address account)
        internal
        view
        returns (uint256)
    {
        // this can't underflow, because this always holds: `globalRewardsPerStaked() >= updatedRewardsPerStaked[account]`
        return (self.stakedBalances[account] * (globalPerStaked - self.updatedRewardsPerStaked[account])) / PRECISION;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {IERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

/// @title Pinlink Oracles Interface
/// @notice Interface for oracles to integrate with the PinlinkShop
interface IPinlinkOracle is IERC165 {
    ////////////////////// EVENTS ///////////////////////

    event PriceUpdated(uint256 indexed usdPerToken);

    ////////////////////// ERRORS ///////////////////////

    error PinlinkCentralizedOracle__InvalidToken();

    /// @notice Converts an amount of a token to USD (18 decimals)
    /// @dev If the price is stale, it should NOT revert, but return 0.
    function convertToUsd(address _token, uint256 _amount) external view returns (uint256);

    /// @notice Converts an amount of USD (18 decimals) to a token amount
    /// @dev If the price is stale, it should NOT revert, but return 0.
    function convertFromUsd(address _token, uint256 _usdAmount) external view returns (uint256);

    /// @notice Returns the timestamp of the last price update
    function lastPriceUpdateTimestamp() external view returns (uint256);

    /// @notice Returns the time in seconds before the price is considered stale
    function STALENESS_THRESHOLD() external view returns (uint256);
}