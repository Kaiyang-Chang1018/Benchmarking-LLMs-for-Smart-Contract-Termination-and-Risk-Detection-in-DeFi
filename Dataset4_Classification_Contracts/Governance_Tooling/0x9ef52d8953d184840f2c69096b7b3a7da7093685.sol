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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC1363} from "../../../interfaces/IERC1363.sol";
import {Address} from "../../../utils/Address.sol";

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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Address.sol)

pragma solidity ^0.8.20;

import {Errors} from "./Errors.sol";

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

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
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert Errors.FailedCall();
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
     * {Errors.FailedCall} error.
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
            revert Errors.InsufficientBalance(address(this).balance, value);
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
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
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
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Errors.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

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
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

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
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
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
// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

// Main information: stake and claim
struct AssetsInfo {
    uint256 stakedAmount;
    uint256 accumulatedReward;
    uint256 lastRewardUpdateTime;
    uint256[] pendingClaimQueueIDs;
    StakeItem[] stakeHistory;
    ClaimItem[] claimHistory;
}
struct StakeItem {
    address token;
    address user;
    uint256 amount;
    uint256 stakeTimestamp;
}
struct ClaimItem {
    bool isDone;
    address token;
    address user;
    uint256 totalAmount;
    uint256 principalAmount;
    uint256 rewardAmount;
    uint256 requestTime;
    uint256 claimTime;
}

interface IVault {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                             events                                                ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    event Stake(address indexed _user, address indexed _token, uint256 indexed _amount);
    event RequestClaim(address _user, address indexed _token, uint256 indexed _amount, uint256 indexed _id);
    event ClaimAssets(address indexed _user, address indexed _token, uint256 indexed _amount, uint256 _id);
    event UpdateRewardRate(address _token, uint256 _oldRewardRate, uint256 _newRewardRate);
    event UpdateCeffu(address _oldCeffu, address _newCeffu);
    event UpdateStakeLimit(address indexed _token, uint256 _oldMinAmount, uint256 _oldMaxAmount, uint256 _newMinAmount, uint256 _newMaxAmount);
    event CeffuReceive(address indexed _token, address _ceffu, uint256 indexed _amount);
    event AddSupportedToken(address indexed _token, uint256 _minAmount, uint256 _maxAmount);
    event EmergencyWithdrawal(address indexed _token, address indexed _receiver);
    event UpdateWaitingTime(uint256 _oldWaitingTime, uint256 _newWaitingTIme);
    event ZkTokenCreated(address indexed _token);
    event FlashWithdraw(address indexed _user, address indexed _token, uint256 indexed _amount, uint _fee);
    event UpdatePenaltyRate(uint indexed oldRate, uint indexed newRate);
    event CancelClaim(address indexed user, address indexed _token, uint256 indexed _amount, uint256 _id);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                             write                                                 ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function stake_66380860(address _token, uint256 _stakedAmount) external;
    function requestClaim_8135334(address _token, uint256 _amount) external returns(uint256);
    function cancelClaim(uint _queueId, address _token) external;
    function claim_41202704(uint256 _queueID, address token) external;
    function flashWithdrawWithPenalty(address _token, uint256 _amount) external;

    function sendLpTokens(address token, address to, uint amount, bool flag) external;
    function transferToCeffu(address _token, uint256 _amount) external;
    function emergencyWithdraw(address _token, address _receiver) external;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                        configuration                                              ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function addSupportedToken(address _token, uint256 _minAmount, uint256 _maxAmount, address _zkToken) external;
    function setRewardRate(address _token, uint256 _newRewardRate) external;
    function setPenaltyRate(uint256 _newRate) external;
    function setAirdropAddr(address newAirdropAddr) external;
    function setStakeLimit(address _token, uint256 _minAmount, uint256 _maxAmount) external;
    function setCeffu(address _newCeffu) external;
    function setWaitingTime(uint256 _newWaitingTIme) external;
    function pause() external;
    function unpause() external;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                          view / pure                                              ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function convertToShares(uint tokenAmount, address _token) external view returns (uint256);
    function convertToAssets(uint shares, address _token) external view returns (uint256);
    function getClaimableRewardsWithTargetTime(address _user, address _token, uint256 _targetTime) external view returns (uint256);
    function getClaimableAssets(address _user, address _token) external view returns (uint256);
    function getClaimableRewards(address _user, address _token) external view returns (uint256);
    function getTotalRewards(address _user, address _token) external view returns (uint256);
    function getStakedAmount(address _user, address _token) external view returns (uint256);
    function getContractBalance(address _token) external view returns (uint256);
    function getStakeHistory(address _user, address _token, uint256 _index) external view returns (StakeItem memory);
    function getClaimHistory(address _user, address _token, uint256 _index) external view returns (ClaimItem memory);
    function getStakeHistoryLength(address _user, address _token) external view returns(uint256);
    function getClaimHistoryLength(address _user, address _token) external view returns(uint256);
    function getCurrentRewardRate(address _token) external view returns(uint256, uint256);
    function getClaimQueueInfo(uint256 _index) external view returns(ClaimItem memory);
    function getClaimQueueIDs(address _user, address _token) external view returns(uint256[] memory);
    function getTVL(address _token) external view returns(uint256);
    function getZKTokenAmount(address _user, address _token) external view returns(uint256);
    function lastClaimQueueID() external view returns(uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

interface IWithdrawVault {
    function transfer(address, address, uint256) external;
    function addSupportedToken(address) external;
    function setVault(address) external;
    function getSupportedTokens() external view returns (address[] memory);
    function getBalance(address) external view returns (uint256);
    function emergencyWithdraw(address, address, uint) external;
    function transferToCeffu(address token, uint amount)external;
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IzkToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function setMinter(address minter, address vault) external;
    function updateAllowance(address from, address to, uint256 amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./IzkToken.sol";
import "./IWithdrawVault.sol";
import "./IVault.sol";
import "./utils.sol";

contract Vault is Pausable, AccessControl, IVault {
    using SafeERC20 for IERC20;
    using SafeERC20 for IzkToken;

    mapping(address => uint256) private tvl;

    // Supported tokens list
    mapping(address => bool) public supportedTokens;

    //zkTokens list
    mapping(address => IzkToken) public supportedTokenToZkToken;
    mapping(address => address) public zkTokenToSupportedToken;

    uint256 public lastClaimQueueID = 10_000;
    mapping(uint256 => ClaimItem) private claimQueue;

    // Main information
    mapping(address => mapping(address => AssetsInfo)) private userAssetsInfo;

    // Reward rate
    struct RewardRateState {
        address token;
        uint256 rewardRate;
        uint256 updatedTime;
    }
    mapping(address => RewardRateState[]) private rewardRateState;

    // Role
    bytes32 private constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 private constant BOT_ROLE = keccak256("BOT_ROLE");

    // Misc
    address private ceffu;
    uint256 private penaltyRate = 50; // 0.5%
    mapping(address => uint256) public minStakeAmount;
    mapping(address => uint256) public maxStakeAmount;
    uint256 public WAITING_TIME;
    uint256 private constant BASE = 10_000;

    mapping(address => uint256) public totalStakeAmountByToken;
    mapping(address => uint256) private _lastRewardUpdatedTime;
    mapping(address => uint256) public totalRewardsAmountByToken;

    uint256 private initialTime;
    IWithdrawVault private withdrawVault;
    address private airdropAddr;

    bool flashNotEnable;
    bool cancelNotEnable = true;

    constructor(
        address[] memory _tokens,
        address[] memory _zkTokens,
        uint256[] memory _newRewardRate,
        uint256[] memory _minStakeAmount,
        uint256[] memory _maxStakeAmount,
        address _admin,
        address _bot,
        address _ceffu,
        uint256 _waitingTime,
        address payable withdrawVaultAddress,
        address _airdropAddr
    ) {
        Utils.CheckIsZeroAddress(_ceffu);
        Utils.CheckIsZeroAddress(_admin);
        Utils.CheckIsZeroAddress(_bot);
        airdropAddr = _airdropAddr;

        uint256 len = _tokens.length;
        require(Utils.MustGreaterThanZero(len));
        require(
            len == _newRewardRate.length &&
            len == _minStakeAmount.length &&
            len == _maxStakeAmount.length && 
            len == _zkTokens.length
        );

        // Grant role
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(PAUSER_ROLE, _admin);
        _grantRole(BOT_ROLE, _bot);

        ceffu = _ceffu;
        emit UpdateCeffu(address(0), _ceffu);

        WAITING_TIME = _waitingTime;
        emit UpdateWaitingTime(0, _waitingTime);

        initialTime = block.timestamp;

        // Set the supported tokens and reward rate
        for (uint256 i = 0; i < len; i++) {
            require(_minStakeAmount[i] < _maxStakeAmount[i]);

            // supported tokens
            address token = _tokens[i];
            minStakeAmount[token] = _minStakeAmount[i];
            maxStakeAmount[token] = _maxStakeAmount[i];
            supportedTokens[token] = true;
            emit AddSupportedToken(token, _minStakeAmount[i], _maxStakeAmount[i]);

            IzkToken tokenTemp = IzkToken(_zkTokens[i]);
            supportedTokenToZkToken[token] = tokenTemp;
            zkTokenToSupportedToken[address(tokenTemp)] = token;
            emit ZkTokenCreated(address(tokenTemp));

            // reward rate
            RewardRateState memory rewardRateItem = RewardRateState({
                token: token,
                rewardRate: _newRewardRate[i],
                updatedTime: block.timestamp
            });
            rewardRateState[token].push(rewardRateItem);
            emit UpdateRewardRate(token, 0, _newRewardRate[i]);

            _lastRewardUpdatedTime[token] = block.timestamp;
        
        }

        withdrawVault = IWithdrawVault(withdrawVaultAddress);

        _pause();
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                           Controller                                              ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////


    modifier OnlyFlashEnable{
        require(!flashNotEnable, "flash withdraw not enable");
    _;
    }
    modifier OnlyCancelEnable{
        require(!cancelNotEnable, "cancel claim not enable");
    _;
    }

    event FlashStatusChanged(bool indexed oldStatus, bool indexed newStatus);
    event CancelStatusChanged(bool indexed oldStatus, bool indexed newStatus);

    function setFlashEnable(bool _enable) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(_enable != flashNotEnable, "nothing changed");
        bool oldStatus = flashNotEnable;
        flashNotEnable = _enable;
        emit FlashStatusChanged(oldStatus, _enable);
    }
    function setCancelEnable(bool _enable) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(_enable != cancelNotEnable, "nothing changed");
        bool oldStatus = cancelNotEnable;
        cancelNotEnable = _enable;

        emit CancelStatusChanged(oldStatus, _enable);
    }

    modifier onlySupportedToken(address _token) {
        require(supportedTokens[_token], "Unsupported");
        _;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                             write                                                 ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    // function signature: 000000ed, the less function matching, the more gas saved
    function stake_66380860(address _token,  uint256 _stakedAmount) external onlySupportedToken(_token) whenNotPaused {
        AssetsInfo storage assetsInfo = userAssetsInfo[msg.sender][_token];
        uint256 currentStakedAmount = assetsInfo.stakedAmount;

        require(Utils.Add(currentStakedAmount, _stakedAmount) >= minStakeAmount[_token]);
        require(Utils.Add(currentStakedAmount, _stakedAmount) <= maxStakeAmount[_token]);

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _stakedAmount);

        _updateRewardState(msg.sender, _token);
        uint256 exchangeRate = _getExchangeRate(_token);

        totalStakeAmountByToken[_token] += _stakedAmount;
        uint256 mintAmount = _stakedAmount * 1e18 / exchangeRate;
        supportedTokenToZkToken[_token].mint(msg.sender, mintAmount);

        // update status
        assetsInfo.stakeHistory.push(
            StakeItem({
                stakeTimestamp: block.timestamp,
                amount: _stakedAmount,
                token: _token,
                user: msg.sender
            })
        );
        unchecked {
            assetsInfo.stakedAmount += _stakedAmount;
            tvl[_token] += _stakedAmount;
        }

        emit Stake(msg.sender, _token, _stakedAmount);
    }

    // function signature: 0000004e, the less function matching, the more gas saved
    function requestClaim_8135334(
        address _token, 
        uint256 _amount
    ) external onlySupportedToken(_token) whenNotPaused returns(uint256 _returnID) {
        _updateRewardState(msg.sender, _token);
        uint256 exchangeRate = _getExchangeRate(_token);

        AssetsInfo storage assetsInfo = userAssetsInfo[msg.sender][_token];
        uint256 currentStakedAmount = assetsInfo.stakedAmount;
        uint256 currentAccumulatedRewardAmount = assetsInfo.accumulatedReward;

        require(
            Utils.MustGreaterThanZero(_amount) && 
            (_amount <= Utils.Add(currentStakedAmount, currentAccumulatedRewardAmount) || _amount == type(uint256).max), 
            "Invalid amount"
        );

        ClaimItem storage queueItem = claimQueue[lastClaimQueueID];

        // Withdraw from reward first; if insufficient, continue withdrawing from principal
        uint256 totalAmount = _amount;
        (totalAmount, , ) = _handleWithdraw(_amount, assetsInfo, queueItem, false);

        require(totalAmount > 0, "No assets to withdraw");

        // update status
        assetsInfo.pendingClaimQueueIDs.push(lastClaimQueueID);

        totalStakeAmountByToken[_token] -= queueItem.principalAmount;
        totalRewardsAmountByToken[_token] -= queueItem.rewardAmount;

        uint256 sharesToBurn = totalAmount * 1e18 / exchangeRate;
        uint256 zkBalance = supportedTokenToZkToken[_token].balanceOf(msg.sender);
        
        if(sharesToBurn > zkBalance || assetsInfo.stakedAmount == 0) sharesToBurn = zkBalance;

        supportedTokenToZkToken[_token].burn(msg.sender, sharesToBurn);

        // update queue
        queueItem.token = _token;
        queueItem.user = msg.sender;
        queueItem.totalAmount = totalAmount;
        queueItem.requestTime = block.timestamp;
        queueItem.claimTime = Utils.Add(block.timestamp, WAITING_TIME);

        unchecked {
            _returnID = lastClaimQueueID;
            ++lastClaimQueueID;
        }

        emit RequestClaim(msg.sender, _token, totalAmount, _returnID);
    }

    function cancelClaim(uint256 _queueId, address _token) external whenNotPaused OnlyCancelEnable{
        ClaimItem memory claimItem = claimQueue[_queueId];
        delete claimQueue[_queueId];

        address token = claimItem.token;
        AssetsInfo storage assetsInfo = userAssetsInfo[msg.sender][token];
        uint256[] memory pendingClaimQueueIDs = userAssetsInfo[msg.sender][token].pendingClaimQueueIDs;
        
        require(Utils.MustGreaterThanZero(claimItem.totalAmount));
        require(claimItem.user == msg.sender);
        require(!claimItem.isDone, "claimed");
        require(token == _token, "wrong token");

        for(uint256 i = 0; i < pendingClaimQueueIDs.length; i++) {
            if(pendingClaimQueueIDs[i] == _queueId) {
                assetsInfo.pendingClaimQueueIDs[i] = pendingClaimQueueIDs[pendingClaimQueueIDs.length-1];
                assetsInfo.pendingClaimQueueIDs.pop();
                break;
            }
        }

        uint256 principal = claimItem.principalAmount;
        uint256 reward = claimItem.rewardAmount;

        assetsInfo.stakedAmount += principal;
        assetsInfo.accumulatedReward += reward;
        assetsInfo.lastRewardUpdateTime = block.timestamp;

        _updateRewardState(msg.sender, _token);
        uint256 exchangeRate = _getExchangeRate(_token);
        uint256 amountToMint = (principal + reward) * 1e18 / exchangeRate;

        totalStakeAmountByToken[_token] += principal;
        totalRewardsAmountByToken[_token] += reward;

        supportedTokenToZkToken[_token].mint(msg.sender, amountToMint);

        emit CancelClaim(msg.sender, _token, principal + reward, _queueId);
    }

    // function signature: 000000e5, the less function matching, the more gas saved
    function claim_41202704(uint256 _queueID, address _token) external whenNotPaused{
        ClaimItem memory claimItem = claimQueue[_queueID];
        address token = claimItem.token;
        AssetsInfo storage assetsInfo = userAssetsInfo[msg.sender][token];
        uint256[] memory pendingClaimQueueIDs = userAssetsInfo[msg.sender][token].pendingClaimQueueIDs;
        
        require(Utils.MustGreaterThanZero(claimItem.totalAmount));
        require(block.timestamp >= claimItem.claimTime);
        require(claimItem.user == msg.sender);
        require(!claimItem.isDone, "claimed");
        require(token == _token, "wrong token");

        // update status
        claimQueue[_queueID].isDone = true;
        for(uint256 i = 0; i < pendingClaimQueueIDs.length; i++) {
            if(pendingClaimQueueIDs[i] == _queueID) {
                assetsInfo.pendingClaimQueueIDs[i] = pendingClaimQueueIDs[pendingClaimQueueIDs.length-1];
                assetsInfo.pendingClaimQueueIDs.pop();
                break;
            }
        }
        tvl[token] -= claimItem.principalAmount;

        assetsInfo.claimHistory.push(
            ClaimItem({
                isDone: true,
                token: token,
                user: msg.sender,
                totalAmount: claimItem.totalAmount,
                principalAmount: claimItem.principalAmount,
                rewardAmount: claimItem.rewardAmount,
                requestTime: claimItem.requestTime,
                claimTime: block.timestamp
            })
        );
        withdrawVault.transfer(token, msg.sender, claimItem.totalAmount);

        emit ClaimAssets(msg.sender, token, claimItem.totalAmount, _queueID);
    }

    function flashWithdrawWithPenalty(
        address _token,
        uint256 _amount
    ) external onlySupportedToken(_token) whenNotPaused OnlyFlashEnable{
        AssetsInfo storage assetsInfo = userAssetsInfo[msg.sender][_token];
        _updateRewardState(msg.sender, _token);
        uint256 exchangeRate = _getExchangeRate(_token);

        uint256 currentStakedAmount = assetsInfo.stakedAmount;
        uint256 currentAccumulatedRewardAmount = assetsInfo.accumulatedReward;

        require(
            Utils.MustGreaterThanZero(_amount) && 
            (_amount <= Utils.Add(currentStakedAmount, currentAccumulatedRewardAmount) || _amount == type(uint256).max)
        );

        uint256 totalAmount = _amount;
        uint256 principalAmount;
        uint256 rewardAmount;
        (totalAmount, principalAmount, rewardAmount) = _handleWithdraw(_amount, assetsInfo, claimQueue[lastClaimQueueID], true);

        require(totalAmount > 0, "no assets to withdraw");
    
        totalStakeAmountByToken[_token] -= principalAmount;
        totalRewardsAmountByToken[_token] -= rewardAmount;

        uint256 sharesToBurn = (totalAmount * 1e18) / exchangeRate;
        uint256 zkBalance = supportedTokenToZkToken[_token].balanceOf(msg.sender);

        if(sharesToBurn > zkBalance || assetsInfo.stakedAmount == 0) sharesToBurn = zkBalance;

        supportedTokenToZkToken[_token].burn(msg.sender, sharesToBurn);

        uint256 amountToSent = totalAmount * (BASE - penaltyRate) / BASE;
        uint256 fee = totalAmount - amountToSent;

        require(getContractBalance(_token) >= amountToSent, "not enough balance");

        IERC20(_token).safeTransfer(msg.sender, amountToSent);

        tvl[_token] -= principalAmount;

        assetsInfo.claimHistory.push(
            ClaimItem({
                isDone: true,
                token: _token,
                user: msg.sender,
                totalAmount: totalAmount,
                principalAmount: principalAmount,
                rewardAmount: rewardAmount,
                requestTime: block.timestamp,
                claimTime: block.timestamp
            })
        );

        emit FlashWithdraw(msg.sender, _token, totalAmount, fee);
    }

    function _handleWithdraw(
        uint256 _amount,
        AssetsInfo storage assetsInfo,
        ClaimItem storage queueItem,
        bool isFlash
    ) internal returns(uint256, uint256, uint256){
        uint256 totalAmount = _amount;
        uint256 principalAmount;
        uint256 rewardAmount;
        uint256 currentAccumulatedRewardAmount = assetsInfo.accumulatedReward;
        if(_amount == type(uint256).max){
            totalAmount = Utils.Add(currentAccumulatedRewardAmount, assetsInfo.stakedAmount);
            rewardAmount = currentAccumulatedRewardAmount;

            assetsInfo.accumulatedReward = 0;

            principalAmount = assetsInfo.stakedAmount;
            assetsInfo.stakedAmount = 0;
        }else if(currentAccumulatedRewardAmount >= _amount) {
            assetsInfo.accumulatedReward -= _amount;
            rewardAmount = _amount;
        } else {
            rewardAmount = currentAccumulatedRewardAmount;
            assetsInfo.accumulatedReward = 0;

            uint256 difference = _amount - currentAccumulatedRewardAmount;
            assetsInfo.stakedAmount -= difference;
            principalAmount = difference;
        }
        if(!isFlash) {
            queueItem.rewardAmount = rewardAmount;
            queueItem.principalAmount = principalAmount;

        }
        return(totalAmount, principalAmount, rewardAmount);
    }

    function _updateRewardState(address _user, address _token) internal {
        AssetsInfo storage assetsInfo = userAssetsInfo[_user][_token];
        uint256 newAccumulatedReward = 0;
        uint256 newAccumulatedRewardForAll;
        if(assetsInfo.lastRewardUpdateTime != 0) { // not the first time to stake
            newAccumulatedReward = _getClaimableRewards(_user, _token);
        }
        
        newAccumulatedRewardForAll = _getClaimableRewards(address(this), _token);

        assetsInfo.accumulatedReward = newAccumulatedReward;
        assetsInfo.lastRewardUpdateTime = block.timestamp;

        _lastRewardUpdatedTime[_token] = block.timestamp;
        totalRewardsAmountByToken[_token] = newAccumulatedRewardForAll;
    }

    function _getExchangeRate(address _token) internal view returns(uint256 exchangeRate){
        uint256 totalSupplyZKToken = supportedTokenToZkToken[_token].totalSupply();
        if (totalSupplyZKToken == 0) {
            exchangeRate = 1e18;
        } else {
            exchangeRate = ((totalStakeAmountByToken[_token] + totalRewardsAmountByToken[_token]) * 1e18) / totalSupplyZKToken;
        }
    }

    function convertToShares(uint256 tokenAmount, address _token) public view returns(uint256 shares) {
        uint256 totalSupplyZKToken = supportedTokenToZkToken[_token].totalSupply();
        uint256 totalStaked = totalStakeAmountByToken[_token];
        uint256 totalRewards = _getClaimableRewards(address(this), _token);

        uint256 exchangeRate = totalSupplyZKToken == 0 ? 
        1e18 : (totalStaked + totalRewards) * 1e18 / totalSupplyZKToken;
        shares = (tokenAmount * 1e18) / exchangeRate;
    }

    function convertToAssets(uint256 shares, address _token) public view returns(uint256 tokenAmount) {
        uint256 totalSupplyZKToken = supportedTokenToZkToken[_token].totalSupply();
        uint256 totalStaked = totalStakeAmountByToken[_token];
        uint256 totalRewards = _getClaimableRewards(address(this), _token);

        uint256 exchangeRate = totalSupplyZKToken == 0 ? 
        1e18 : (totalStaked + totalRewards) * 1e18 / totalSupplyZKToken;

        tokenAmount = (shares * exchangeRate) / 1e18;
    }

    function transferOrTransferFrom(address token, address from, address to, uint256 amount) public returns (bool) {
        require(from != to, "from can not be same as the to");
        require(amount > 0, "amount must be greater than 0");

        uint256 tokenBefore = getZKTokenAmount(from, token);
        require(tokenBefore >= amount, "balance");
        if(msg.sender != from){
            require(supportedTokenToZkToken[token].allowance(from, msg.sender) >= amount, "allowance");
            supportedTokenToZkToken[token].updateAllowance(from, msg.sender, amount);
            supportedTokenToZkToken[token].transferFrom(from, to, amount);
        }else{
            supportedTokenToZkToken[token].transferFrom(msg.sender, to, amount);
        }

        _assetsInfoUpdate(token, from, to, amount, tokenBefore);

        return true;
    }

    // airdrop
    function sendLpTokens(address token, address to, uint256 amount, bool flag) external {
        require(msg.sender == airdropAddr);
        supportedTokenToZkToken[token].transferFrom(airdropAddr, to, amount);
        
        AssetsInfo storage assetsInfo = userAssetsInfo[to][token];
        if(flag == true){
            assetsInfo.lastRewardUpdateTime = initialTime;
        }else{
            _updateRewardState(to, token);
        }

        assetsInfo.stakedAmount += amount;

        totalStakeAmountByToken[token] += amount;
        tvl[token] += amount;
    }

    function _assetsInfoUpdate(address token, address from, address to, uint256 amount, uint256 tokenBefore) internal{
        _updateRewardState(from, token);
        _updateRewardState(to, token);
        AssetsInfo storage assetsInfoFrom = userAssetsInfo[from][token];
        uint256 stakedAmount = assetsInfoFrom.stakedAmount;
        uint256 accumulatedReward = assetsInfoFrom.accumulatedReward;

        AssetsInfo storage assetsInfoTo = userAssetsInfo[to][token];

        uint256 percent = amount * 1e18 / tokenBefore;
        uint256 deltaStaked = (stakedAmount * percent / 1e18);
        uint256 deltaReward = (accumulatedReward * percent / 1e18);

        assetsInfoTo.stakedAmount += deltaStaked;
        assetsInfoFrom.stakedAmount -= deltaStaked;
        assetsInfoTo.accumulatedReward += deltaReward;
        assetsInfoFrom.accumulatedReward -= deltaReward;
        assetsInfoTo.lastRewardUpdateTime = block.timestamp ;
    }

    function transferToCeffu(
        address _token,
        uint256 _amount
    ) external onlySupportedToken(_token) onlyRole(BOT_ROLE) {
        require(Utils.MustGreaterThanZero(_amount), "must > 0");
        require(_amount <= IERC20(_token).balanceOf(address(this)), "Not enough balance");

        IERC20(_token).safeTransfer(ceffu, _amount);

        emit CeffuReceive(_token, ceffu, _amount);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                          emergency                                                ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function emergencyWithdraw(address _token, address _receiver) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // `_token` could be not supported, so that we could sweep the tokens which are sent to this contract accidentally
        Utils.CheckIsZeroAddress(_token);
        Utils.CheckIsZeroAddress(_receiver);

        IERC20(_token).safeTransfer(_receiver, IERC20(_token).balanceOf(address(this)));
        emit EmergencyWithdrawal(_token, _receiver);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                        configuration                                              ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function addSupportedToken(
        address _token,
        uint256 _minAmount,
        uint256 _maxAmount,
        address _zkToken
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Utils.CheckIsZeroAddress(_token);
        require(!supportedTokens[_token], "Supported");

        // update the supported tokens
        supportedTokens[_token] = true;
        setStakeLimit(_token, _minAmount, _maxAmount);
        emit AddSupportedToken(_token, _minAmount, _maxAmount);

        IzkToken tokenTemp = IzkToken(_zkToken);
        supportedTokenToZkToken[_token] = tokenTemp;
        zkTokenToSupportedToken[address(tokenTemp)] = _token;
        emit ZkTokenCreated(address(tokenTemp));
    }

    function setRewardRate(
        address _token, 
        uint256 _newRewardRate
    ) external onlySupportedToken(_token) onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_newRewardRate < BASE, "Invalid rate");

        RewardRateState[] memory rewardRateArray = rewardRateState[_token];
        uint256 currentRewardRate = rewardRateArray[rewardRateArray.length - 1].rewardRate;
        require(currentRewardRate != _newRewardRate && Utils.MustGreaterThanZero(_newRewardRate), "Invalid new rate");

        // add the new reward rate to the array
        RewardRateState memory rewardRateItem = RewardRateState({
            updatedTime: block.timestamp,
            token: _token,
            rewardRate: _newRewardRate
        });
        rewardRateState[_token].push(rewardRateItem);

        emit UpdateRewardRate(_token, currentRewardRate, _newRewardRate);
    }

    function setAirdropAddr(address newAirdropAddr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        //allow equal address(0), when we want to disable airdrop
        airdropAddr = newAirdropAddr;
    }

    function setPenaltyRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newRate <= BASE && newRate != penaltyRate, "Invalid");

        emit UpdatePenaltyRate(penaltyRate, newRate);
        penaltyRate = newRate;
    }


    function setCeffu(address _newCeffu) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Utils.CheckIsZeroAddress(_newCeffu);
        require(_newCeffu != ceffu);

        emit UpdateCeffu(ceffu, _newCeffu);
        ceffu = _newCeffu;
    }

    function setStakeLimit(
        address _token,
        uint256 _minAmount,
        uint256 _maxAmount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) onlySupportedToken(_token) {
        require(Utils.MustGreaterThanZero(_minAmount) && _minAmount < _maxAmount);

        emit UpdateStakeLimit(_token, minStakeAmount[_token], maxStakeAmount[_token], _minAmount, _maxAmount);
        minStakeAmount[_token] = _minAmount;
        maxStakeAmount[_token] = _maxAmount;
    }

    function setWaitingTime(uint256 _newWaitingTime) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(_newWaitingTime != WAITING_TIME, "Invalid");

        emit UpdateWaitingTime(WAITING_TIME, _newWaitingTime);
        WAITING_TIME = _newWaitingTime;        
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                          view / pure                                              ///
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    function calculateReward(
        uint256 _stakedAmount, 
        uint256 _rewardRate, 
        uint256 _elapsedTime
    ) internal pure returns (uint256 result) {
        // (stakedAmount * rewardRate * elapsedTime) / (ONE_YEAR * 10000)
        // Parameter descriptions:
        // - stakedAmount: The amount staked by the user
        // - rewardRate: The annual reward rate (e.g., 700 means 7%)
        // - elapsedTime: The time interval over which the reward is calculated, in seconds
        // - ONE_YEAR: The total number of seconds in one year (365.25 days)
        assembly {
            // uint256 ONE_YEAR = uint256(365.25 * 24 * 60 * 60); // 365.25 days per year: 31557600
            let ONE_YEAR := 31557600

            // Calculate numerator = stakedAmount * rewardRate * elapsedTime
            let numerator := mul(_stakedAmount, _rewardRate)
            numerator := mul(numerator, _elapsedTime)

            // Calculate denominator = ONE_YEAR * 10000
            let denominator := mul(ONE_YEAR, BASE)

            // Perform the division result = numerator / denominator
            result := div(numerator, denominator)
        }
    }

    function _getClaimableRewards(address _user, address _token) internal view returns (uint256) {
        uint256 currentStakedAmount;
        uint256 lastRewardUpdate;
        uint256 currentRewardAmount;

        if(_user != address(this)){
            AssetsInfo memory assetsInfo = userAssetsInfo[_user][_token];
            currentStakedAmount = assetsInfo.stakedAmount;
            lastRewardUpdate = assetsInfo.lastRewardUpdateTime;
            currentRewardAmount = assetsInfo.accumulatedReward;
        } else {
            currentStakedAmount = totalStakeAmountByToken[_token];
            lastRewardUpdate = _lastRewardUpdatedTime[_token];
            currentRewardAmount = totalRewardsAmountByToken[_token];
        }

        RewardRateState[] memory rewardRateArray = rewardRateState[_token];
        uint256 rewardRateLength = rewardRateArray.length;
        RewardRateState memory currentRewardRateState = rewardRateArray[rewardRateLength - 1];

        if(lastRewardUpdate == 0) return 0;

        // 1. Retrieve the last deposit time `begin`
        // 2. Retrieve the current deposit time `end`
        // 3. Check whether the reward rate changed between time `begin` and time `end`
        // 4. Determine if the reward rate has changed since the last deposit:
        //    - If no changes occurred, directly calculate and add the reward.
        //    - If changes occurred, divide the deposit time into segments based on different rates 
        //      and accumulate the rewards accordingly.
        if(currentRewardRateState.updatedTime <= lastRewardUpdate){
            /*
                   begin                   end
                    |~~~~~~ position ~~~~~~~|
                |--------- reward rate 1 --------------|--------- upcoming reward rate 2 --------------|
            */

            uint256 elapsedTime = block.timestamp - lastRewardUpdate;
            uint256 reward = calculateReward(
                currentStakedAmount,
                currentRewardRateState.rewardRate,
                elapsedTime
            );

            return currentRewardAmount + reward;
        } else {
            /*
                   begin                                                       end
                    |~~~~~~~~~~~~~~~~~~~~~~ position ~~~~~~~~~~~~~~~~~~~~~~~~~~~|
                |--------- reward rate 1 --------------|-- reward rate 2 --|-------- reward rate 3 --------|
            */

            // a. based on the reward rate at the time of the last stake, find the corresponding index in the rate array
            uint256 beginIndex = 0;
            for (uint256 i = 0; i < rewardRateLength; i++) {
                if (lastRewardUpdate < rewardRateArray[i].updatedTime) {
                    beginIndex = i;
                    break;
                }
            }

            // b. iterate to the latest-1 reward rate
            uint256 tempLastRewardUpdateTime = lastRewardUpdate;
            for (uint256 i = beginIndex; i < rewardRateLength; i++) {
                if(i == 0) continue;

                uint256 tempElapsedTime = rewardRateArray[i].updatedTime - tempLastRewardUpdateTime;
                uint256 tempReward = calculateReward(
                    currentStakedAmount,
                    rewardRateArray[i - 1].rewardRate,
                    tempElapsedTime
                );
                tempLastRewardUpdateTime = rewardRateArray[i].updatedTime;
                unchecked{
                    currentRewardAmount += tempReward;
                }
            }

            // c. the reward generated by the latest reward rate
            uint256 elapsedTime = block.timestamp - currentRewardRateState.updatedTime;
            uint256 reward = calculateReward(
                currentStakedAmount,
                currentRewardRateState.rewardRate,
                elapsedTime
            );

            return currentRewardAmount + reward;
        }
    }

    // principal + rewards
    function getClaimableAssets(address _user, address _token) external view returns (uint256) {
        AssetsInfo memory assetsInfo = userAssetsInfo[_user][_token];
        
        return Utils.Add(assetsInfo.stakedAmount, _getClaimableRewards(_user, _token));
    }

    // current rewards
    function getClaimableRewards(address _user, address _token) external view returns (uint256) {
        return _getClaimableRewards(_user, _token);
    }

    // history rewards + current rewards
    function getTotalRewards(address _user, address _token) external view returns (uint256) {
        uint256 historyRewards = 0;
        uint256 currentRewards = _getClaimableRewards(_user, _token);

        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];
        for(uint256 i = 0; i < stakeInfo.claimHistory.length; i++) {
            historyRewards += stakeInfo.claimHistory[i].rewardAmount;
        }

        return Utils.Add(historyRewards, currentRewards);
    }

    // Calculate the total withdrawable amount for a user at a future time, 
    // based on the user's current staked amount and the current reward rate.
    function getClaimableRewardsWithTargetTime(
        address _user,
        address _token,
        uint256 _targetTime
    ) external view returns (uint256) {
        require(_targetTime > block.timestamp, "Invalid time");

        AssetsInfo memory assetsInfo = userAssetsInfo[_user][_token];
        RewardRateState[] memory rewardRateArray = rewardRateState[_token];
        RewardRateState memory currentRewardRateState = rewardRateArray[rewardRateArray.length - 1];

        uint256 newAccumulatedReward = 0;
        if(assetsInfo.lastRewardUpdateTime != 0) { // not the first time to stake
            newAccumulatedReward = _getClaimableRewards(_user, _token);
        }

        uint256 elapsedTime = _targetTime - block.timestamp;
        uint256 reward = calculateReward(
            assetsInfo.stakedAmount,
            currentRewardRateState.rewardRate,
            elapsedTime
        );

        return Utils.Add(newAccumulatedReward, reward);
    }

    function getStakedAmount(address _user, address _token) public view onlySupportedToken(_token) returns (uint256) {
        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];
        return stakeInfo.stakedAmount;
    }

    function getZKTokenAmount(address _user, address _token) public view onlySupportedToken(_token) returns (uint256) {
        return supportedTokenToZkToken[_token].balanceOf(_user);
    }

    function getContractBalance(address _token) public view returns (uint256) {
        Utils.CheckIsZeroAddress(_token);
        return IERC20(_token).balanceOf(address(this));
    }

    function getStakeHistory(
        address _user,
        address _token,
        uint256 _index
    ) external view onlySupportedToken(_token) returns (StakeItem memory) {
        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];
        require(_index < stakeInfo.stakeHistory.length, "index");

        return stakeInfo.stakeHistory[_index];
    }

    function getClaimHistory(
        address _user,
        address _token,
        uint256 _index
    ) external view onlySupportedToken(_token) returns (ClaimItem memory) {
        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];
        require(_index < stakeInfo.claimHistory.length, "index");

        return stakeInfo.claimHistory[_index];
    }

    function getStakeHistoryLength(address _user, address _token) external view returns(uint256) {
        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];

        return stakeInfo.stakeHistory.length;
    }
    function getClaimHistoryLength(address _user, address _token) public view returns(uint256) {
        AssetsInfo memory stakeInfo = userAssetsInfo[_user][_token];
        
        return stakeInfo.claimHistory.length;
    }

    // Check the current withdrawal request in progress for a specific user
    function getClaimQueueIDs(address _user, address _token) external view returns (uint256[] memory) {
        AssetsInfo memory assetsInfo = userAssetsInfo[_user][_token];
        return assetsInfo.pendingClaimQueueIDs;
    }

    // Measure the reward rate as a percentage, and return the numerator and denominator
    function getCurrentRewardRate(address _token) external view returns (uint256, uint256) {
        RewardRateState[] memory rewardRateStateArray = rewardRateState[_token];
        RewardRateState memory currentRewardRateState = rewardRateStateArray[rewardRateStateArray.length - 1];

        return (currentRewardRateState.rewardRate, BASE);
    }

    function getClaimQueueInfo(uint256 _index) external view returns(ClaimItem memory) {
        return claimQueue[_index];
    }

    function getTVL(address _token) external view returns(uint256){
        return tvl[_token];
    }

    receive() external payable {
        revert();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

library Utils {
    // Use this when we are certain that an overflow will not occur
    function Add(uint _a, uint _b) public pure returns (uint256) {
        assembly {
            mstore(0x0, add(_a, _b))
            return(0x0, 32)
        }
    }

    function CheckIsZeroAddress(address _address) public pure returns (bool) {
        assembly {
            if iszero(_address) {
                mstore(0x00, 0x20)
                mstore(0x20, 0x0c)
                mstore(0x40, 0x5a65726f20416464726573730000000000000000000000000000000000000000) // load hex of "Zero Address" to memory
                revert(0x00, 0x60)
            }
        }
        return true;
    }

    function MustGreaterThanZero(uint256 _value) internal pure returns (bool result) {
        assembly {
            // The 'iszero' opcode returns 1 if the input is zero, and 0 otherwise.
            // So, 'iszero(iszero(_value))' returns 1 if value > 0, and 0 if value == 0.
            result := iszero(iszero(_value))
        }
    }

}