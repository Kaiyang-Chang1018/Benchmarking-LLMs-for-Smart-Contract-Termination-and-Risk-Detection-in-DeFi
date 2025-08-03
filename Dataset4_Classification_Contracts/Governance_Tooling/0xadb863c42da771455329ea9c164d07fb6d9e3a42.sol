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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

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
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
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
pragma solidity ^0.8.28;

/**
 * This contract acts as a ledger to manage a synthetic representation of BTC on EVM chains.
 * It uses a series of roles (ADMIN, GATEKEEPER, SIGNER, etc.) and a threshold mechanism for approvals.
 * The design intends to mimic a federated system that confirms and verifies BTC transactions (UTXOs)
 * on-chain before minting or burning corresponding synthetic tokens (ERC20).
 *
 * The logic revolves around three main concepts:
 * 1. Candidate UTXOs: Proposed UTXOs that need a certain number of signers to confirm their existence/validity.
 * 2. Confirmed UTXOs: Once a UTXO is confirmed by reaching the approval threshold, it can be used to mint tokens.
 * 3. Burn Requests: Users can propose burns of their tokens, which are matched with on-chain references to actual BTC spent.
 *
 * Important reasoning behind certain design decisions:
 * - Using AccessControl from OpenZeppelin to cleanly separate roles and permissions.
 * - Using ReentrancyGuard to prevent reentrancy attacks during token transfers.
 * - Using SafeERC20 for safe token operations to avoid low-level call issues.
 * - Storing UTXOs and burn requests separately, and using a mapping from UTXO keys (txid + outputNo)
 *   ensures uniqueness and straightforward lookups.
 * - The threshold approval mechanism ensures that no single entity can unilaterally confirm UTXOs or burn requests.
 * - CandidateUTXOs and UTXOs are separated to ensure a two-step confirmation: first reaching the threshold of approvals,
 *   then finalizing the UTXO for minting. This approach provides a controlled workflow.
 * - The contract attempts to be modular and upgrade-friendly by relying on well-known interfaces like IERC20Mintable and IERC20Burnable.
 * - By separating mint and burn operations and using explicit states (INIT, USED_FOR_MINT, SPENT_FOR_BURN),
 *   the contract can track the lifecycle of synthetic tokens tied to particular BTC transactions, ensuring auditability.
 */

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Interfaces for extended token functionality: burnable and mintable tokens are expected.
// This allows the contract to reduce (burn) or increase (mint) the token supply as BTC moves in/out of custody.
interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 amount) external;
}

// UTXOKey uniquely identifies a Bitcoin UTXO by using the txid and output number.
// This ensures that each tracked UTXO is unique and can be independently managed.
struct UTXOKey {
    bytes32 txid;
    uint256 outputNo;
}

// UTXOState tracks the lifecycle of a UTXO within this system:
// UNINITIALIZED: UTXO not initialized
// INIT: UTXO registered but not yet used for mint
// USED_FOR_MINT: UTXO used as backing for minted tokens
// SPENT_FOR_BURN: UTXO spent to correspond to a token burn
// These states ensure the contract can account for the status of each UTXO over time.
enum UTXOState {
    UNINITIALIZED,
    INIT,
    USED_FOR_MINT,
    SPENT_FOR_BURN
}

// BurnState tracks the lifecycle of a burn within this system:
// UNINITIALIZED: Burn not initialized
// PROPOSED: Burn proposed by a user
// CONFIRMED: Burn confirmed by a coordinator
// These states ensure the contract can account for the status of each burn over time.
enum BurnState {
    UNINITIALIZED,
    PROPOSED,
    CONFIRMED
}

contract xcBTCLedger is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;

    // Core token that represents synthetic BTC. Must be compatible with mint and burn operations.
    IERC20Metadata public token;

    // The treasuryAddress is where service fees go.
    address public treasuryAddress;

    // Gatekeeper and custody addresses for BTC are stored as bytes32.
    // The contract doesn't decode these, it just stores them for reference.
    bytes public btcGatekeeperAddress;
    bytes public btcCustodyAddress;

    // Various economic parameters:
    // serviceFee: The fee taken for each mint/burn process.
    // minBurnAmount: The minimum amount of tokens a user must burn at once.
    // maxBTCNetworkFee: A cap on allowed fees for a burn transaction.
    // maxUTXOCountPerTx: Limit how many UTXOs can be used per burn operation (to prevent complexity and DoS).
    // burnIdCounter: A counter to generate unique burn IDs.
    // threshold: Minimum number of signers required to confirm a UTXO, change UTXO or burn.
    uint256 public serviceFee;
    uint256 public minBurnAmount;
    uint256 public maxBTCNetworkFee;
    uint256 public maxUTXOCountPerTx;
    uint256 public burnIdCounter;
    uint8 public threshold;

    // Role definitions:
    // COORDINATOR_ROLE: Coordinators can perform actions related to verifying users and controlling burns.
    // SIGNER_ROLE: Signers confirm UTXOs and burns. Multiple signers are needed to reach threshold approvals.
    // VERIFIED_USER_ROLE: Users that have been verified by the operator.
    bytes32 public constant COORDINATOR_ROLE = keccak256("COORDINATOR_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    bytes32 public constant VERIFIED_USER_ROLE =
        keccak256("VERIFIED_USER_ROLE");

    // Struct UTXO: Holds state and signature approvals for a confirmed UTXO.
    // The mapping from address to bool tracks who approved it; from address to bytes tracks associated signatures.
    // signatureCount helps track how many have signed it.
    // This structure ensures that each UTXO is verifiably approved by multiple signers.
    struct UTXO {
        address receiver;
        UTXOState state;
        uint8 signatureCount;
        uint256 amount;
        mapping(address => bool) approvers; // Which signers approved this UTXO
        mapping(address => bytes) signatures; // Signatures from each approver (used during burn)
        address[] approverAddresses; // List of approvers to facilitate iteration and cleanup (used during burn)
    }

    // CandidateUTXO: A proposed UTXO that isn't confirmed yet. It awaits approvals from a threshold of signers.
    // Once the threshold is met, it becomes a fully confirmed UTXO and can be minted.
    struct CandidateUTXO {
        address receiver;
        uint8 approvals;
        uint256 amount;
        mapping(address => bool) approvers;
        address[] approverAddresses;
    }

    // Burn structure:
    // A burn request initiated by a user proposes destroying tokens in exchange for the underlying BTC.
    // The burn must be confirmed by signers and must match actual BTC spent (USED_FOR_MINT UTXOs).
    // UTXO references ensure the burn corresponds to actual BTC movements.
    struct Burn {
        address proposer;
        BurnState state;
        uint256 amount;
        uint256 fee;
        string receiver;
        UTXOKey[] utxoKeys;
        mapping(bytes32 => bool) utxoKeyHashes;
    }

    // UTXOInfo is used for reading out details of a UTXO, including signatures, for external inspection.
    // This struct helps front-ends and off-chain systems see the full picture of a UTXO.
    struct UTXOInfo {
        bytes32 txid;
        address receiver;
        uint256 outputNo;
        uint8 state;
        uint8 signatureCount;
        uint256 amount;
        address[] approverAddresses;
        bytes[] signatures;
    }

    // Mappings to store UTXOs and candidate UTXOs by their unique key (txid + outputNo).
    mapping(bytes32 => UTXO) public utxoMap;
    mapping(bytes32 => CandidateUTXO) public candidateUtxoMap;

    // Burns are stored by an incrementing burnId. This allows tracking multiple concurrent burns.
    mapping(uint256 => Burn) public burnsMap;

    // A global list of all confirmed UTXOs (utxoKeysList) and a mapping to their index allows enumeration and cleanup.
    UTXOKey[] public utxoKeysList;
    mapping(bytes32 => uint256) public utxoKeyIndexMap;

    // Events log important actions so that off-chain systems can react and store historical data.
    event BurnProposed(
        uint256 burnId,
        address proposer,
        string receiver,
        uint256 amount
    );
    event BurnConfirmed(uint256 burnId, uint256 fee);
    event BurnCanceled(uint256 burnId);
    event MintConfirmed(bytes32 txid, uint256 outputNo);
    event UTXOConfirmed(bytes32 txid, uint256 outputNo);
    event ApprovalReceived(bytes32 txid, uint256 outputNo, address approver);
    event AddressVerified(address addr, bool verified);

    // Custom errors save gas and provide descriptive revert reasons.
    error AmountTooLow();
    error UTXOAlreadyConfirmed();
    error TooManyUTXOs();
    error InvalidUTXOState();
    error NotAllowed();
    error FeeTooHigh();
    error DuplicateApproval();
    error UTXONotPartOfBurn();
    error SignatureCannotBeSet();
    error InvalidBurnState();
    error ReceiverNotSet();
    error RenouncingRolesIsDisabled();
    error MismatchedInputLengths();
    error BurnDoesNotExist();
    error AmountMismatch();
    error ReceiverMismatch();

    constructor(
        address _token,
        address _treasuryAddress,
        uint256 _serviceFee,
        uint256 _minBurnAmount,
        uint256 _maxBTCNetworkFee,
        uint256 _maxUTXOCountPerTx,
        uint8 _threshold
    ) {
        token = IERC20Metadata(_token);
        treasuryAddress = _treasuryAddress;
        serviceFee = _serviceFee;
        minBurnAmount = _minBurnAmount;
        maxBTCNetworkFee = _maxBTCNetworkFee;
        maxUTXOCountPerTx = _maxUTXOCountPerTx;
        threshold = _threshold;

        // Assigning roles at construction. DEFAULT_ADMIN_ROLE can grant/revoke other roles.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Whitelisting addresses for users ensures only verified users can propose burns. This is done for KYC purposes.
    function verifyAddress(
        address addr,
        bool verified
    ) external onlyRole(COORDINATOR_ROLE) {
        if (verified) {
            _grantRole(VERIFIED_USER_ROLE, addr);
        } else {
            _revokeRole(VERIFIED_USER_ROLE, addr);
        }
        emit AddressVerified(addr, verified);
    }

    // proposeBurn: A verified user proposes to burn tokens in exchange for a BTC address.
    // The burn remains in PROPOSED state until confirmed by signers.
    // This ensures only properly verified users can create burns and unlock BTC from custody.
    // During this step, the tokens are transferred to the contract until they are either burned or returned.
    function proposeBurn(
        uint256 amount,
        string memory receiver
    ) external nonReentrant onlyRole(VERIFIED_USER_ROLE) {
        if (amount < minBurnAmount) revert AmountTooLow();
        // The burn amount must also cover serviceFee; ensures no negative net burn occurs.
        if (amount < serviceFee) revert AmountTooLow();

        // User transfers tokens to this contract. This ensures the contract holds the tokens before the burn is confirmed.
        token.safeTransferFrom(msg.sender, address(this), amount);

        Burn storage newBurn = burnsMap[burnIdCounter];
        newBurn.proposer = msg.sender;
        newBurn.receiver = receiver;
        newBurn.amount = amount;
        newBurn.state = BurnState.PROPOSED;

        emit BurnProposed(
            burnIdCounter,
            newBurn.proposer,
            newBurn.receiver,
            newBurn.amount
        );

        burnIdCounter++;
    }

    // Helper function to generate UTXO key hash
    function _generateUTXOKeyHash(
        bytes32 txid,
        uint256 outputNo
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(txid, outputNo));
    }

    // Helper function to clean up burn UTXOs
    function _cleanupBurnUTXOs(Burn storage burn) internal {
        uint256 utxoKeysLength = burn.utxoKeys.length;
        for (uint256 i = 0; i < utxoKeysLength; i++) {
            bytes32 utxoKeyHash = _generateUTXOKeyHash(
                burn.utxoKeys[i].txid,
                burn.utxoKeys[i].outputNo
            );
            delete burn.utxoKeyHashes[utxoKeyHash];
        }
    }

    // Helper function to manage UTXO list additions
    function _addToUTXOList(
        bytes32 txid,
        uint256 outputNo,
        bytes32 utxoKeyHash
    ) internal {
        uint256 index = utxoKeysList.length;
        utxoKeysList.push(UTXOKey(txid, outputNo));
        utxoKeyIndexMap[utxoKeyHash] = index;
    }

    // Helper function to clean up approvers
    function _cleanupApprovers(
        address[] storage approverAddresses,
        mapping(address => bool) storage approvers
    ) internal {
        uint256 approversCount = approverAddresses.length;
        for (uint256 i = 0; i < approversCount; i++) {
            address approver = approverAddresses[i];
            delete approvers[approver];
        }
    }

    // Helper function to clean up approvers and signatures
    function _cleanupApproversAndSignatures(
        address[] storage approverAddresses,
        mapping(address => bool) storage approvers,
        mapping(address => bytes) storage signatures
    ) internal {
        uint256 approversCount = approverAddresses.length;
        for (uint256 i = 0; i < approversCount; i++) {
            address approver = approverAddresses[i];
            delete approvers[approver];
            delete signatures[approver];
        }
    }

    // cancelBurn: Allows the proposer or a coordinator to cancel a proposed burn, returning tokens to the proposer.
    // This enables dispute resolution or user refunds if something goes wrong before confirmation.
    function cancelBurn(uint256 burnId) external nonReentrant {
        Burn storage burn = burnsMap[burnId];
        if (burn.state == BurnState.UNINITIALIZED) revert BurnDoesNotExist();
        if (burn.state != BurnState.PROPOSED) revert InvalidBurnState();

        if (
            burn.proposer != msg.sender &&
            !hasRole(COORDINATOR_ROLE, msg.sender)
        ) revert NotAllowed();

        uint256 amount = burn.amount;
        address proposer = burn.proposer;

        _cleanupBurnUTXOs(burn);
        // Delete before external call to avoid reentrancy issues
        delete burnsMap[burnId];

        token.safeTransfer(proposer, amount);

        emit BurnCanceled(burnId);
    }

    // confirmBurn: A coordinator finalizes a burn by referencing USED_FOR_MINT UTXOs.
    // The caller of this method (usually the backend) selects a set of UTXOs to use for a specific burn.
    // It checks that enough UTXOs are included (regarding amount), that the fees are within range, and that serviceFee is covered.
    // Then it burns the corresponding tokens from this contract's balance and transfers the serviceFee to treasury.
    function confirmBurn(
        UTXOKey[] calldata utxoKeys,
        uint256 btcTxfee,
        uint256 burnId
    ) external nonReentrant onlyRole(COORDINATOR_ROLE) {
        Burn storage burn = burnsMap[burnId];
        if (burn.state == BurnState.UNINITIALIZED) revert BurnDoesNotExist();
        if (burn.state != BurnState.PROPOSED) revert InvalidBurnState();

        uint256 utxoKeysLength = utxoKeys.length;
        if (utxoKeysLength > maxUTXOCountPerTx) revert TooManyUTXOs();
        if (btcTxfee > maxBTCNetworkFee) revert FeeTooHigh();
        if (burn.amount < serviceFee + btcTxfee) revert AmountTooLow();

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < utxoKeysLength; i++) {
            UTXOKey calldata utxoKey = utxoKeys[i];
            bytes32 utxoKeyHash = _generateUTXOKeyHash(
                utxoKey.txid,
                utxoKey.outputNo
            );
            UTXO storage utxo = utxoMap[utxoKeyHash];
            if (utxo.state != UTXOState.USED_FOR_MINT)
                revert InvalidUTXOState();
            if (utxo.signatureCount != 0) revert SignatureCannotBeSet();

            totalAmount += utxo.amount;
            // Mark UTXO as spent to back the burn, ensuring it can't be reused.
            utxo.state = UTXOState.SPENT_FOR_BURN;

            burn.utxoKeyHashes[utxoKeyHash] = true;
            burn.utxoKeys.push(
                UTXOKey({txid: utxoKey.txid, outputNo: utxoKey.outputNo})
            );
        }

        // Ensures that total UTXO amount covers the requested burn amount plus fee.
        if (totalAmount < burn.amount) revert AmountTooLow();

        burn.fee = btcTxfee;
        burn.state = BurnState.CONFIRMED;

        uint256 amountToBurn = burn.amount - serviceFee;

        // Service fee goes to the treasury
        token.safeTransfer(treasuryAddress, serviceFee);

        // Burn the net amount from contract's balance, reducing total supply to reflect BTC spent.
        IERC20Burnable(address(token)).burn(amountToBurn);

        emit BurnConfirmed(burnId, btcTxfee);
    }

    // signBurn: Signers can attach signatures to UTXOs that are part of confirmed burns.
    // The burn is already confirmed, after gathering enough BTC signatures the BTC can be unlocked from the custody address via multisig.
    function signBurn(
        uint256 burnId,
        bytes32[] calldata txids,
        uint256[] calldata outputNos,
        bytes[] calldata signatures
    ) external onlyRole(SIGNER_ROLE) {
        Burn storage burn = burnsMap[burnId];
        if (burn.state != BurnState.CONFIRMED) revert InvalidBurnState();

        uint256 txidsLength = txids.length;
        if (txidsLength != signatures.length || txidsLength != outputNos.length)
            revert MismatchedInputLengths();

        for (uint256 i = 0; i < txidsLength; i++) {
            bytes32 utxoKeyHash = _generateUTXOKeyHash(txids[i], outputNos[i]);
            if (!burn.utxoKeyHashes[utxoKeyHash]) revert UTXONotPartOfBurn();

            UTXO storage utxo = utxoMap[utxoKeyHash];
            if (utxo.approvers[msg.sender]) revert DuplicateApproval();

            // Store signatures from signers. Approvers can't sign twice to prevent double counting.
            utxo.signatures[msg.sender] = signatures[i];
            utxo.approvers[msg.sender] = true;
            utxo.signatureCount++;
            utxo.approverAddresses.push(msg.sender);
        }
    }

    struct ConfirmChangeUTXOInfo {
        bytes32 txid;
        uint256 outputNo;
        uint256 amount;
    }

    // Private helper function to handle common UTXO confirmation logic
    function _confirmUTXO(
        bytes32 txid,
        uint256 outputNo,
        address receiver,
        uint256 amount,
        bool isChangeUTXO
    ) private {
        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);

        if (!isChangeUTXO && receiver == address(0)) revert ReceiverNotSet();

        // Prevent reconfirming an already confirmed UTXO
        if (utxoMap[utxoKeyHash].state > UTXOState.UNINITIALIZED) {
            revert UTXOAlreadyConfirmed();
        }

        CandidateUTXO storage candidate = candidateUtxoMap[utxoKeyHash];
        bool isNewUTXO = candidate.approverAddresses.length == 0;

        if (candidate.approvers[msg.sender]) revert DuplicateApproval();
        if (!isNewUTXO && candidate.amount != amount) revert AmountMismatch();
        if (!isNewUTXO && candidate.receiver != receiver)
            revert ReceiverMismatch();

        candidate.receiver = receiver;
        candidate.amount = amount;
        candidate.approvers[msg.sender] = true;
        candidate.approvals++;
        candidate.approverAddresses.push(msg.sender);

        // If threshold reached, move from candidate to fully confirmed UTXO
        if (candidate.approvals >= threshold) {
            UTXO storage utxo = utxoMap[utxoKeyHash];
            utxo.receiver = receiver;
            utxo.amount = amount;
            utxo.state = isChangeUTXO
                ? UTXOState.USED_FOR_MINT
                : UTXOState.INIT;

            _addToUTXOList(txid, outputNo, utxoKeyHash);

            // Delete all entries in the mapping
            _cleanupApprovers(candidate.approverAddresses, candidate.approvers);
            delete candidateUtxoMap[utxoKeyHash];

            emit UTXOConfirmed(txid, outputNo);
        } else {
            emit ApprovalReceived(txid, outputNo, msg.sender);
        }
    }

    function confirmUtxo(
        bytes32 txid,
        uint256 outputNo,
        address receiver,
        uint256 amount
    ) external onlyRole(SIGNER_ROLE) {
        if (amount < serviceFee) revert AmountTooLow();
        _confirmUTXO(txid, outputNo, receiver, amount, false);
    }

    function confirmChangeUTXOs(
        ConfirmChangeUTXOInfo[] calldata createdUtxos
    ) external onlyRole(SIGNER_ROLE) {
        uint256 createdUtxosLength = createdUtxos.length;
        for (uint256 i = 0; i < createdUtxosLength; i++) {
            _confirmUTXO(
                createdUtxos[i].txid,
                createdUtxos[i].outputNo,
                address(0), // Change UTXOs have no direct receiver
                createdUtxos[i].amount,
                true
            );
        }
    }

    // getCandidateUtxo: View function to inspect a candidate UTXO's current status and approvers
    function getCandidateUtxo(
        bytes32 txid,
        uint256 outputNo
    )
        external
        view
        returns (
            address receiver,
            uint256 amount,
            uint256 approvals,
            address[] memory approverAddresses
        )
    {
        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);
        CandidateUTXO storage candidate = candidateUtxoMap[utxoKeyHash];

        return (
            candidate.receiver,
            candidate.amount,
            candidate.approvals,
            candidate.approverAddresses
        );
    }

    // getUTXO: View function to inspect a UTXO's current status and who has approved it.
    function getUTXO(
        bytes32 txid,
        uint256 outputNo
    )
        external
        view
        returns (
            UTXOState state,
            address receiver,
            uint256 amount,
            uint8 signatureCount,
            address[] memory approverAddresses
        )
    {
        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);
        UTXO storage utxo = utxoMap[utxoKeyHash];
        return (
            utxo.state,
            utxo.receiver,
            utxo.amount,
            utxo.signatureCount,
            utxo.approverAddresses
        );
    }

    // getBurnWithUTXOs: Returns burn details along with the full UTXO info (including signatures).
    // This gives complete transparency on how the burn was backed and by which signers.
    function getBurnWithUTXOs(
        uint256 burnId
    )
        external
        view
        returns (
            address proposer,
            string memory receiver,
            uint256 amount,
            BurnState state,
            uint256 fee,
            UTXOInfo[] memory utxos
        )
    {
        Burn storage burn = burnsMap[burnId];

        if (burn.state == BurnState.UNINITIALIZED) revert BurnDoesNotExist();

        proposer = burn.proposer;
        receiver = burn.receiver;
        amount = burn.amount;
        state = burn.state;
        fee = burn.fee;

        uint256 utxoCount = burn.utxoKeys.length;
        utxos = new UTXOInfo[](utxoCount);

        // Extracts UTXO and signature data for off-chain analysis.
        for (uint256 i = 0; i < utxoCount; i++) {
            UTXOKey storage utxoKey = burn.utxoKeys[i];
            bytes32 utxoKeyHash = _generateUTXOKeyHash(
                utxoKey.txid,
                utxoKey.outputNo
            );
            UTXO storage utxo = utxoMap[utxoKeyHash];

            UTXOInfo memory utxoInfo;
            utxoInfo.txid = utxoKey.txid;
            utxoInfo.outputNo = utxoKey.outputNo;
            utxoInfo.state = uint8(utxo.state);
            utxoInfo.receiver = utxo.receiver;
            utxoInfo.amount = utxo.amount;
            utxoInfo.signatureCount = utxo.signatureCount;

            uint256 approversCount = utxo.approverAddresses.length;
            utxoInfo.approverAddresses = new address[](approversCount);
            utxoInfo.signatures = new bytes[](approversCount);

            for (uint256 j = 0; j < approversCount; j++) {
                utxoInfo.signatures[j] = utxo.signatures[
                    utxo.approverAddresses[j]
                ];
                utxoInfo.approverAddresses[j] = utxo.approverAddresses[j];
            }
            utxos[i] = utxoInfo;
        }
    }

    // Added function for admins to set UTXOs directly
    function setUTXO(
        bytes32 txid,
        uint256 outputNo,
        address receiver,
        uint256 amount,
        UTXOState utxoState
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (utxoState > UTXOState.SPENT_FOR_BURN) revert InvalidUTXOState();

        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);

        UTXO storage utxo = utxoMap[utxoKeyHash];
        bool isNewUTXO = utxo.state == UTXOState.UNINITIALIZED;

        utxo.receiver = receiver;
        utxo.amount = amount;
        utxo.state = utxoState;

        if (isNewUTXO) {
            _addToUTXOList(txid, outputNo, utxoKeyHash);
        }
    }

    // removeUTXO: Allows admin to remove a UTXO entirely.
    // Used for cleanups or correcting data. Requires careful handling since UTXOs back minted tokens.
    function removeUTXO(
        bytes32 txid,
        uint256 outputNo
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);
        deleteUTXO(utxoKeyHash);
    }

    // mint: Coordinator can convert a confirmed (INIT state) UTXO into minted tokens if there are enough confirmations that the UTXO was moved from the candidateMap to the utxoMap.
    // The receiver gets netAmount = amount - serviceFee, and the serviceFee goes to the treasury.
    // The UTXO transitions to USED_FOR_MINT state, ensuring it cannot be reused.
    function mint(
        bytes32 txid,
        uint256 outputNo
    ) external nonReentrant onlyRole(COORDINATOR_ROLE) {
        bytes32 utxoKeyHash = _generateUTXOKeyHash(txid, outputNo);
        UTXO storage utxo = utxoMap[utxoKeyHash];
        if (utxo.state != UTXOState.INIT) revert InvalidUTXOState();
        if (utxo.receiver == address(0)) revert ReceiverNotSet();
        if (utxo.amount < serviceFee) revert AmountTooLow();

        uint256 netAmount = utxo.amount - serviceFee;

        // Mint the tokens as per the confirmed UTXO value.
        IERC20Mintable(address(token)).mint(utxo.receiver, netAmount);
        IERC20Mintable(address(token)).mint(treasuryAddress, serviceFee);

        utxo.state = UTXOState.USED_FOR_MINT;

        emit MintConfirmed(txid, outputNo);
    }

    // removeBurn: Allows an admin to remove a burn record.
    // If the burn was just proposed (not confirmed), it returns tokens to the proposer.
    // If confirmed, removing should only be done in special/admin circumstances.
    function removeBurn(
        uint256 burnId
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        Burn storage burn = burnsMap[burnId];
        if (burn.state == BurnState.PROPOSED) {
            // If not confirmed yet, return tokens to the proposer.
            token.safeTransfer(burn.proposer, burn.amount);
        }
        _cleanupBurnUTXOs(burn);
        delete burnsMap[burnId];
    }

    // getLatestBurnId: View function to see the most recently created burnId.
    // Useful for quickly referencing the current state of burns.
    function getLatestBurnId() external view returns (uint256) {
        return burnIdCounter > 0 ? burnIdCounter - 1 : 0;
    }

    // deleteUTXO: Internal cleanup function that also removes the UTXOKey from the global list,
    // ensuring data consistency. It clears all signature and approval data.
    function deleteUTXO(bytes32 utxoKeyHash) internal {
        UTXO storage utxo = utxoMap[utxoKeyHash];
        _cleanupApproversAndSignatures(
            utxo.approverAddresses,
            utxo.approvers,
            utxo.signatures
        );

        uint256 index = utxoKeyIndexMap[utxoKeyHash];
        uint256 lastIndex = utxoKeysList.length - 1;
        if (index != lastIndex) {
            UTXOKey storage lastKey = utxoKeysList[lastIndex];
            utxoKeysList[index] = lastKey;
            bytes32 lastKeyHash = _generateUTXOKeyHash(
                lastKey.txid,
                lastKey.outputNo
            );
            utxoKeyIndexMap[lastKeyHash] = index;
        }
        utxoKeysList.pop();
        delete utxoKeyIndexMap[utxoKeyHash];
        delete utxoMap[utxoKeyHash];
    }

    // NOTE: because only the admin can set the threshold and btc addresses, we don't need to add validation

    function setBTCGatekeeperAddress(
        bytes memory _btcGatekeeperAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        btcGatekeeperAddress = _btcGatekeeperAddress;
    }

    function setBTCCustodyAddress(
        bytes memory _btcCustodyAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        btcCustodyAddress = _btcCustodyAddress;
    }

    function setMaxBTCNetworkFee(
        uint256 _maxBTCNetworkFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        maxBTCNetworkFee = _maxBTCNetworkFee;
    }

    // setMaxUTXOCountPerTx: Admin can adjust the maximum number of UTXOs that can be processed per burn.
    // This gives flexibility if there's a need to handle more or fewer UTXOs in a single tx over time.
    function setMaxUTXOCountPerTx(
        uint256 _maxUTXOCountPerTx
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        maxUTXOCountPerTx = _maxUTXOCountPerTx;
    }

    function setMinBurnAmount(
        uint256 _minBurnAmount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        minBurnAmount = _minBurnAmount;
    }

    function setServiceFee(
        uint256 _serviceFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        serviceFee = _serviceFee;
    }

    function setThreshold(
        uint8 _threshold
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        threshold = _threshold;
    }

    function setTreasuryAddress(
        address _treasuryAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasuryAddress = _treasuryAddress;
    }

    // Prevent addresses from removing their own roles. Admins can still remove roles from other addresses.
    function renounceRole(bytes32, address) public virtual override {
        revert RenouncingRolesIsDisabled();
    }
}