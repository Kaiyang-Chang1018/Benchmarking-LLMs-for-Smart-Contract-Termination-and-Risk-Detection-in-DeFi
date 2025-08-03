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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";
import {IERC20Permit} from "../extensions/IERC20Permit.sol";
import {Address} from "../../../utils/Address.sol";

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
     * @dev An operation with an ERC20 token failed.
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
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
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
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
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

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
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
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
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
pragma solidity 0.8.24;
 
import "@openzeppelin/contracts@5.0.2/utils/introspection/ERC165.sol";

import "../libraries/BytesLib.sol";
import "../libraries/AddressConverter.sol";
import "../libraries/DecimalsConverter.sol"; 
import "../libraries/UTSERC20DataTypes.sol";

import "./interfaces/IUTSBase.sol";
import "./interfaces/IUTSRouter.sol";

/**
 * @notice Abstract contract implementing minimal and basic functionality for sending and receiving crosschain bridges 
 * of ERC20 tokens via UTS protocol V1. 
 *
 * @dev 
 * The {__UTSBase_init} function MUST be called before using other functions of the {UTSBase} contract.
 * The {_authorizeCall} function MUST be overridden to include access restriction to the {setRouter} and 
 * {setChainConfig} functions.
 * The {_mintTo} function MUST be overridden to implement {mint}/{transfer} underlying tokens to receiver {to} address 
 * by {_router}.
 * The {_burnFrom} function MUST be overridden to implement {burn}/{transferFrom} underlying tokens from {spender}/{from}
 * address for bridging.
 */
abstract contract UTSBase is IUTSBase, ERC165 {
    using AddressConverter for address;
    using DecimalsConverter for uint256;
    using BytesLib for bytes;

    /// @notice Nonce used for {storeFailedExecution} executions to guarantee uniqueness.
    uint256 private _retryNonce;

    /**
     * @notice Address that can execute {redeem} and {storeFailedExecution} functions.
     * @dev Should be an authorized {UTSRouter} contract address or a zero address in case of disconnection from UTS protocol.
     */
    address private _router;

    /// @notice Address of the underlying ERC20 token.
    address internal _underlyingToken;

    /// @notice Decimals of the underlying ERC20 token.
    uint8 internal _decimals;

    /// @notice {ChainConfig} settings for the corresponding destination chain Id.
    /// @dev See the {UTSERC20DataTypes.ChainConfig} for details.
    mapping(uint256 chainId => ChainConfig dstChainConfig) internal _chainConfig;

    /**
     * @notice Receiver address for the corresponding {redeem} message hash.
     * @dev Mapping is filled only by {storeFailedExecution} function if the {redeem} call is unsuccessful.
     * IMPORTANT: Execution of the {_redeem} function with a {to} zero address MUST be forbidden.
     */
    mapping(bytes32 msgHash => address receiverAddress) private _failedExecution;

    /// @notice Indicates an error that the {UTSBase} contract initialized already.
    error UTSBase__E0();

    /// @notice Indicates an error that the function caller is not the {_router}.
    error UTSBase__E1();

    /// @notice Indicates an error that the {to} is zero address.
    error UTSBase__E2();

    /// @notice Indicates an error that the {amount} to bridge is zero.
    error UTSBase__E3();

    /// @notice Indicates an error that lengths of {allowedChainIds} and {chainConfigs} do not match in the {_setChainConfig} function.
    error UTSBase__E4();

    /// @notice Indicates an error that the destination {peerAddress} is paused for sending and receiving crosschain messages.
    error UTSBase__E5();

    /// @notice Indicates an error that the provided {dstGasLimit} is less than the minimum required amount.
    error UTSBase__E6();

    /// @notice Indicates an error that the source {Origin.peerAddress} is unauthorized in the {ChainConfig} for corresponding {Origin.chainId}.
    error UTSBase__E7();

    /**
     * @notice Emitted when the {_router} address is updated.
     * @param caller the caller address who set the new {_router} address.
     * @param newRouter the address of the new {_router}.
     */
    event RouterSet(address indexed caller, address newRouter);

    /**
     * @notice Emitted when {ChainConfig} settings are updated.
     * @param caller the caller address who set the new destination {ChainConfig} settings.
     * @param allowedChainIds new chains Ids available for bridging in both directions.
     * @param chainConfigs array of new {ChainConfig} settings for corresponding {allowedChainIds}.
     */
    event ChainConfigUpdated(address indexed caller, uint256[] allowedChainIds, ChainConfig[] chainConfigs);

    /**
     * @notice Emitted when tokens are successfully redeemed from the source chain.
     * @param to tokens receiver on the current chain.
     * @param amount received amount.
     * @param srcPeerAddressIndexed indexed source {peerAddress}.
     * @param srcPeerAddress source {peerAddress}.
     * @param srcChainId source chain Id.
     * @param sender source chain sender's address.
     */
    event Redeemed(
        address indexed to, 
        uint256 amount, 
        bytes indexed srcPeerAddressIndexed, 
        bytes srcPeerAddress,
        uint256 indexed srcChainId,
        bytes sender
    );

    /**
     * @notice Emitted when crosschain bridge message is successfully sent to a destination chain.
     * @param spender the caller address who initiate the bridge.
     * @param from tokens holder on the current chain.
     * @param dstPeerAddressIndexed indexed destination {peerAddress}.
     * @param dstPeerAddress destination {peerAddress}.
     * @param to bridged tokens receiver on the destination chain.
     * @param amount bridged tokens amount.
     * @param dstChainId destination chain Id.
     */
    event Bridged(
        address indexed spender, 
        address from, 
        bytes indexed dstPeerAddressIndexed, 
        bytes dstPeerAddress,
        bytes to, 
        uint256 amount,
        uint256 indexed dstChainId
    );

    /**
     * @notice Emitted when a {storeFailedExecution} executed in case of failed {redeem} call.
     * @param to tokens receiver on the current chain.
     * @param amount amount to receive.
     * @param customPayload user's additional data.
     * @param originIndexed indexed source chain data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @param result handled error message.
     * @param nonce unique failed execution's counter.
     */
    event ExecutionFailed(
        address indexed to, 
        uint256 amount, 
        bytes customPayload, 
        Origin indexed originIndexed, 
        Origin origin,
        bytes indexed result, 
        uint256 nonce
    );

    /**
     * @notice Initializes basic settings.
     * @param underlyingToken_ underlying ERC20 token address.
     * @dev In case this contract and ERC20 are the same contract, {underlyingToken_} should be address(this).
     *
     * @param decimals_ underlying token decimals.
     * @dev Can and MUST be called only once.
     */
    function __UTSBase_init(address underlyingToken_, uint8 decimals_) internal {
        if (_retryNonce > 0) revert UTSBase__E0();

        _underlyingToken = underlyingToken_;
        _decimals = decimals_;
        // {_retryNonce} counter increases here for two reasons: 
        // 1. to block repeated {__UTSBase_init} call
        // 2. initialize the {_retryNonce} variable to unify the gas limit calculation of the {storeFailedExecution} call
        _retryNonce = 1;
    }

    /**
     * @notice Initiates the tokens bridging.
     * @param from tokens holder on the current chain.
     * @param to bridged tokens receiver on the destination chain.
     * @param amount tokens amount to bridge to the destination chain.
     * @param dstChainId destination chain Id.
     * @param dstGasLimit {redeem} call gas limit on the destination chain.
     * @param customPayload user's additional data.
     * @param protocolPayload UTS protocol's additional data.
     * @return success call result.
     * @return bridgedAmount bridged tokens amount.
     */
    function bridge(
        address from,
        bytes calldata to, 
        uint256 amount, 
        uint256 dstChainId,
        uint64 dstGasLimit,
        bytes calldata customPayload,
        bytes calldata protocolPayload
    ) external payable virtual returns(bool success, uint256 bridgedAmount) {

        return _bridge(
            msg.sender, 
            from, 
            to, 
            amount, 
            dstChainId, 
            dstGasLimit, 
            customPayload, 
            protocolPayload
        );
    }

    /**
     * @notice Executes the tokens delivery from the source chain.
     * @param to tokens receiver on the current chain.
     * @param amount amount to receive.
     * @param customPayload user's additional data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @return success call result.
     * @dev Only the {_router} can execute this function.
     */
    function redeem(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin
    ) external payable virtual returns(bool success) {
        _onlyRouter();

        return _redeem(to, amount, customPayload, origin);
    }

    /**
     * @notice Stores failed execution's data.
     * @param to tokens receiver on the current chain.
     * @param amount tokens amount to receive.
     * @param customPayload user's additional data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @param result handled error message.
     * @dev Only the {_router} can execute this function.
     */
    function storeFailedExecution(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin,
        bytes calldata result
    ) external virtual {
        _onlyRouter();

        _failedExecution[keccak256(abi.encode(to, amount, customPayload, origin, _retryNonce))] = to;

        emit ExecutionFailed(to, amount, customPayload, origin, origin, result, _retryNonce);

        _retryNonce++;
    }

    /**
     * @notice Executes the tokens delivery after failed execution.
     * @param to tokens receiver on the current chain.
     * @param amount amount to receive.
     * @param customPayload user's additional data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @param nonce unique failed execution's counter.
     * @return success call result.
     */
    function retryRedeem(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin,
        uint256 nonce
    ) external virtual returns(bool success) {
        if (to == address(0)) return false;
        bytes32 _hash = keccak256(abi.encode(to, amount, customPayload, origin, nonce));
        if (_failedExecution[_hash] != to) return false;
        delete _failedExecution[_hash];

        return _redeem(to, amount, customPayload, origin);
    }

    /**
     * @notice Sets the destination chains settings.
     * @param allowedChainIds chains Ids available for bridging in both directions.
     * @param chainConfigs array of {ChainConfig} settings for provided {allowedChainIds}, containing:
     *        peerAddress: connected {UTSToken} or {UTSConnector} contract address on the destination chain
     *        minGasLimit: the amount of gas required to execute {redeem} function on the destination chain
     *        decimals: connected {peerAddress} decimals on the destination chain
     *        paused: flag indicating whether current contract is paused for sending/receiving messages from the connected {peerAddress}
     *
     * @return success call result.
     */
    function setChainConfig(
        uint256[] calldata allowedChainIds,
        ChainConfig[] calldata chainConfigs
    ) external virtual returns(bool success) {
        _authorizeCall();
        _setChainConfig(allowedChainIds, chainConfigs);

        return true;
    }

    /**
     * @notice Sets the UTSRouter address.
     * @param newRouter new {_router} address.
     * @return success call result.
     * @dev {_router} address has access rights to execute {redeem} and {storeFailedExecution} functions.
     */
    function setRouter(address newRouter) external virtual returns(bool success) {
        _authorizeCall();
        _setRouter(newRouter);

        return true;
    }

    /**
     * @notice Returns the UTSRouter {_router} address.
     * @return routerAddress the {UTSRouter} address.
     */
    function router() public view returns(address routerAddress) {
        return _router;
    }

    /**
     * @notice Returns the UTSBase protocol version.
     * @return UTS protocol version.
     */
    function protocolVersion() public pure virtual returns(bytes2) {
        return 0x0101;
    }

    /**
     * @notice Returns the underlying ERC20 token address.
     * @return ERC20 {_underlyingToken} address.
     */
    function underlyingToken() public view virtual returns(address) {
        return _underlyingToken;
    }

    /**
     * @notice Returns whether failed execution's data is stored. 
     * @param to tokens receiver on the current chain.
     * @param amount amount to receive.
     * @param customPayload user's additional data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @param nonce unique failed execution's counter.
     * @return isFailed result.
     */
    function isExecutionFailed(
        address to, 
        uint256 amount, 
        bytes calldata customPayload, 
        Origin calldata origin,
        uint256 nonce
    ) external view virtual returns(bool isFailed) {
        if (to == address(0)) return false;
        return _failedExecution[keccak256(abi.encode(to, amount, customPayload, origin, nonce))] == to;
    }

    /**
     * @notice Returns estimated minimal amount to pay for bridging and minimal gas limit.
     * @param dstChainId destination chain Id.
     * @param dstGasLimit {redeem} call gas limit on the destination chain.
     * @param customPayloadLength user's additional data length.
     * @param protocolPayload UTS protocol's additional data.
     * @return paymentAmount source chain native currency amount to pay for bridging.
     * @return dstMinGasLimit destination chain minimal {redeem} call gas limit.
     */
    function estimateBridgeFee(
        uint256 dstChainId, 
        uint64 dstGasLimit, 
        uint16 customPayloadLength,
        bytes calldata protocolPayload
    ) public view virtual returns(uint256 paymentAmount, uint64 dstMinGasLimit) {
        dstMinGasLimit = IUTSRouter(_router).dstMinGasLimit(dstChainId);
        uint64 _configMinGasLimit = _chainConfig[dstChainId].minGasLimit;

        return (
            IUTSRouter(_router).getBridgeFee(dstChainId, dstGasLimit, customPayloadLength, protocolPayload), 
            dstMinGasLimit >= _configMinGasLimit ? dstMinGasLimit : _configMinGasLimit
        );
    }

    /**
     * @notice Returns destination chain configs for sending and receiving crosschain messages.
     * @param chainIds destination chain Ids.
     * @return configs array of {ChainConfig} settings for provided {chainIds}.
     * @dev See the {UTSERC20DataTypes.ChainConfig} for details.
     */
    function getChainConfigs(uint256[] calldata chainIds) external view returns(ChainConfig[] memory configs) {
        configs = new ChainConfig[](chainIds.length);
        for (uint256 i; chainIds.length > i; ++i) configs[i] = _chainConfig[chainIds[i]];
    }

    /**
     * @notice Returns true if this contract implements the interface defined by `interfaceId`.
     * See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified
     * to learn more about how these ids are created.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return interfaceId == type(IUTSBase).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Internal function that initiates the tokens bridging.
     * @param spender transaction sender, must be {msg.sender}.
     * @param from tokens holder on the current chain.
     * @param to bridged tokens receiver on the destination chain.
     * @param amount tokens amount to bridge to the destination chain.
     * @param dstChainId destination chain Id.
     * @param dstGasLimit {redeem} call gas limit on the destination chain.
     * @param customPayload user's additional data.
     * @param protocolPayload UTS protocol's additional data.
     *
     * @return success call result.
     * @return bridgedAmount bridged tokens amount.
     *
     * @dev Implements all basic checks and calculations, containing:
     *      1. required destination gas limit check
     *      2. destination peer is not paused check
     *      3. amount conversion in accordance with destination token decimals
     *      4. bridged tokens amount is not zero check
     */
    function _bridge(
        address spender,
        address from,
        bytes memory to, 
        uint256 amount, 
        uint256 dstChainId, 
        uint64 dstGasLimit,
        bytes memory customPayload,
        bytes memory protocolPayload
    ) internal virtual returns(bool success, uint256 bridgedAmount) {
        if (from == address(0)) from = spender;

        ChainConfig memory config = _chainConfig[dstChainId];

        if (config.minGasLimit > dstGasLimit) revert UTSBase__E6();
        if (config.paused) revert UTSBase__E5();

        uint8 _srcDecimals = _decimals;
        amount = amount.convert(_srcDecimals, config.decimals).convert(config.decimals, _srcDecimals);

        amount = _burnFrom(
            spender,
            from,
            to, 
            amount, 
            dstChainId, 
            customPayload
        );

        if (amount == 0) revert UTSBase__E3();

        emit Bridged(spender, from, config.peerAddress, config.peerAddress, to, amount, dstChainId);

        return (
            _sendRequest(
                msg.value,
                config.peerAddress, 
                to, 
                amount,
                _srcDecimals, 
                dstChainId,
                dstGasLimit,
                customPayload,
                protocolPayload
            ), 
            amount
        );
    }

    /**
     * @notice Internal function that call {_router} contract to send crosschain bridge message.
     * @param payment the native currency amount that will be transfer to the {_router} as payment for sending this message.
     * @param dstToken the contract address on the {dstChainId} that will receive this message.
     * @param to bridged tokens receiver on the destination chain.
     * @param amount amount that {to} address will receive (before decimals conversion on the destination chain).
     * @param srcDecimals source ERC20 underlying token decimals.
     * @param dstChainId destination chain Id.
     * @param dstGasLimit {redeem} call gas limit on the destination chain.
     * @param customPayload user's additional data.
     * @param protocolPayload UTS protocol's additional data.
     *
     * @return success call result.
     *
     * @dev {customPayload} can be used to send an additional data, it will be sent to the {dstToken} contract on the 
     * destination chain in accordance with {redeem} function.
     */
    function _sendRequest(
        uint256 payment,
        bytes memory dstToken,
        bytes memory to,
        uint256 amount,
        uint8 srcDecimals,
        uint256 dstChainId,
        uint64 dstGasLimit,
        bytes memory customPayload,
        bytes memory protocolPayload
    ) internal virtual returns(bool success) {
        return IUTSRouter(_router).bridge{value: payment}( 
            dstToken,
            msg.sender.toBytes(),
            to,
            amount,
            srcDecimals,
            dstChainId,
            dstGasLimit,
            customPayload,
            protocolPayload
        );
    }

    /**
     * @notice Internal function that releases tokens to receiver by crosschain message from the source chain.
     * @param to bridged tokens receiver on the current chain.
     * @param amount amount that {to} address will receive (before decimals conversion on the current chain).
     * @param customPayload user's additional data.
     * @param origin source chain data.
     * @dev See the {UTSERC20DataTypes.Origin} for details.
     * @return success call result.
     *
     * @dev Implements all basic checks and calculations, containing:
     *      1. receiver address is not zero address check
     *      2. source peer address is allowed to send messages to this contract check
     *      3. source peer address is not paused check
     *      4. amount conversion in accordance with source token decimals
     */
    function _redeem(
        address to,
        uint256 amount,
        bytes memory customPayload,
        Origin memory origin
    ) internal virtual returns(bool success) {
        if (to == address(0)) revert UTSBase__E2();

        ChainConfig memory config = _chainConfig[origin.chainId];

        if (!config.peerAddress.equal(origin.peerAddress)) revert UTSBase__E7();
        if (config.paused) revert UTSBase__E5();
        
        amount = _mintTo(to, amount.convert(origin.decimals, _decimals), customPayload, origin);

        emit Redeemed(to, amount, origin.peerAddress, origin.peerAddress, origin.chainId, origin.sender);

        return true;
    }

    /**
     * @notice Internal function that sets the destination chains settings and emits corresponding event.
     * @param allowedChainIds chains Ids available for bridging in both directions.
     * @param chainConfigs array of {ChainConfig} settings for provided {allowedChainIds}.
     * @dev See the {UTSERC20DataTypes.ChainConfig} for details.
     */
    function _setChainConfig(uint256[] memory allowedChainIds, ChainConfig[] memory chainConfigs) internal virtual {
        if (allowedChainIds.length != chainConfigs.length) revert UTSBase__E4();
        for (uint256 i; allowedChainIds.length > i; ++i) _chainConfig[allowedChainIds[i]] = chainConfigs[i];

        emit ChainConfigUpdated(msg.sender, allowedChainIds, chainConfigs);
    }

    /**
     * @notice Internal function that sets the UTSRouter address and emits corresponding event.
     * @param newRouter new {_router} address.
     */
    function _setRouter(address newRouter) internal virtual {
        _router = newRouter;

        emit RouterSet(msg.sender, newRouter);
    }

    /**
     * @notice Internal view function that implement basic access check for {redeem} and {storeFailedExecution} functions.
     */
    function _onlyRouter() internal view {
        if (msg.sender != _router) revert UTSBase__E1();
    }

    /**
     * @dev The function MUST be overridden to include access restriction to the {setRouter} and {setChainConfig} functions.
     */
    function _authorizeCall() internal virtual;

    /**
     * @dev The function MUST be overridden to implement {mint}/{transfer} underlying tokens to receiver {to} address by {_router}.
     */
    function _mintTo(
        address to,
        uint256 amount,
        bytes memory customPayload,
        Origin memory origin
    ) internal virtual returns(uint256 receivedAmount);

    /**
     * @dev The function MUST be overridden to implement {burn}/{transferFrom} underlying tokens from {spender}/{from} 
     * address for bridging.
     *
     * IMPORTANT: If this contract IS a token itself, and the {spender} and {from} addresses are different, an {ERC20.allowance} 
     * check MUST be added.
     *
     * IMPORTANT: If this contract IS NOT a token itself, the {spender} and {from} addresses MUST be the same to prevent tokens
     * stealing via third-party allowances.
     *
     * IMPORTANT: Returned {bridgedAmount} value will be actually used for crosschain message, as it may be different from {amount}, 
     * if custom logic inside {_burnFrom} function modifies it.
     */
    function _burnFrom(
        address spender,
        address from,
        bytes memory to, 
        uint256 amount, 
        uint256 dstChainId, 
        bytes memory customPayload
    ) internal virtual returns(uint256 bridgedAmount);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts@5.0.2/access/AccessControl.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/IERC20Metadata.sol";

import "../extensions/UTSBaseIndexed.sol";

import "../interfaces/IUTSConnector.sol";

/**
 * @notice A contract that provides functionality to use UTS protocol V1 crosschain messaging for bridging 
 * existing ERC20 token.
 * 
 * A UTSConnector stores and releases underlying ERC20 tokens and interacts with the UTS protocol.
 */
contract UTSConnector is IUTSConnector, UTSBaseIndexed, AccessControl {
    using SafeERC20 for IERC20Metadata;

    /**
     * @notice Initializes basic settings with provided parameters.
     * @param _owner the address of the initial {AccessControl.DEFAULT_ADMIN_ROLE}.
     * @param underlyingToken_ underlying ERC20 token address.
     * @param _router the address of the authorized {UTSRouter}.
     * @param _allowedChainIds chains Ids available for bridging in both directions.
     * @param _chainConfigs array of {ChainConfig} settings for provided {_allowedChainIds}.
     * @dev See the {UTSERC20DataTypes.ChainConfig} for details.
     * @dev Can and MUST be called only once. Reinitialization is prevented by {UTSBase.__UTSBase_init} function.
     */
    function initializeConnector(
        address _owner,
        address underlyingToken_,
        address _router,  
        uint256[] calldata _allowedChainIds,
        ChainConfig[] calldata _chainConfigs
    ) external { 
        __UTSBase_init(underlyingToken_, IERC20Metadata(underlyingToken_).decimals());

        _setRouter(_router);
        _setChainConfig(_allowedChainIds, _chainConfigs);

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    /**
     * @notice Returns decimals value of the underlying ERC20 token.
     * @return {ERC20.decimals} of the {_underlyingToken}.
     */
    function underlyingDecimals() external view returns(uint8) {
        return _decimals;
    }

    /**
     * @notice Returns the balance of the underlying ERC20 token held by the UTSConnector.
     * @return {_underlyingToken} balance held by the {UTSConnector}.
     */
    function underlyingBalance() external view returns(uint256) {
        return IERC20Metadata(_underlyingToken).balanceOf(address(this));
    }

    /**
     * @notice Returns the name of the underlying ERC20 token.
     * @return {IERC20.name} of the {_underlyingToken}.
     */
    function underlyingName() external view returns(string memory) {
        return IERC20Metadata(_underlyingToken).name();
    }

    /**
     * @notice Returns the symbol of the underlying ERC20 token.
     * @return {IERC20.symbol} of the {_underlyingToken}.
     */
    function underlyingSymbol() external view returns(string memory) {
        return IERC20Metadata(_underlyingToken).symbol();
    }

    /**
     * @notice Returns true if this contract implements the interface defined by `interfaceId`.
     * See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified
     * to learn more about how these ids are created.
     */
    function supportsInterface(bytes4 interfaceId) public view override(UTSBase, AccessControl) returns(bool) {
        return interfaceId == type(IUTSConnector).interfaceId || super.supportsInterface(interfaceId);
    }

    function _burnFrom(
        address spender,
        address /* from */, 
        bytes memory /* to */, 
        uint256 amount, 
        uint256 /* dstChainId */, 
        bytes memory /* customPayload */
    ) internal virtual override returns(uint256) {
        IERC20Metadata(_underlyingToken).safeTransferFrom(spender, address(this), amount);

        return amount;
    }

    function _mintTo(
        address to,
        uint256 amount,
        bytes memory /* customPayload */,
        Origin memory /* origin */
    ) internal virtual override returns(uint256) {
        if (to != address(this)) IERC20Metadata(_underlyingToken).safeTransfer(to, amount);

        return amount;
    }

    function _authorizeCall() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../UTSBase.sol";

import "../interfaces/IUTSBaseExtended.sol";

/**
 * @notice Extension of {UTSBase} that allows {UTSBase} contract owner to change {ChainConfig} settings on different 
 * destination chains with a single crosschain transaction.
 */
abstract contract UTSBaseExtended is IUTSBaseExtended, UTSBase {
    using AddressConverter for address;
    using BytesLib for bytes;

    /**
     * @notice Send crosschain message that will change destination {ChainConfig}.
     * @param dstChainIds destination chains Ids to which a message will be sent to change their {ChainConfig}.
     * @param newConfigs new {ChainConfig} settings for provided {allowedChainIds} to be setted on the destination chains.
     * @return success call result.
     */
    function setChainConfigToDestination(
        uint256[] calldata dstChainIds,
        ChainConfigUpdate[] calldata newConfigs
    ) external payable returns(bool success) {
        _authorizeCall();

        if (dstChainIds.length != newConfigs.length) revert UTSBase__E4();

        bytes[] memory _dstPeers = new bytes[](dstChainIds.length);

        for (uint256 i; dstChainIds.length > i; ++i) _dstPeers[i] = _chainConfig[dstChainIds[i]].peerAddress;

        return IUTSRouter(router()).requestToUpdateConfig{value: msg.value}( 
            msg.sender.toBytes(),
            dstChainIds,
            _dstPeers,
            newConfigs
        );
    }

    /**
     * @notice Sets the destination chains settings by crosschain message.
     * @param allowedChainIds chains Ids available for bridging in both directions.
     * @param chainConfigs array of new {ChainConfig} settings for provided {allowedChainIds}.
     * @param origin source chain data.
     * @dev Only the {_router} can execute this function.
     */
    function setChainConfigByRouter(
        uint256[] calldata allowedChainIds,
        ChainConfig[] calldata chainConfigs,
        Origin calldata origin
    ) external {
        _onlyRouter();

        if (!_chainConfig[origin.chainId].peerAddress.equalStorage(origin.peerAddress)) revert UTSBase__E7();

        _setChainConfig(allowedChainIds, chainConfigs);
    }

    /**
     * @notice Returns estimated minimal amount to pay for {setChainConfigToDestination} call.
     * @param dstChainIds destination chains Ids to which a message will be sent.
     * @param configsLength {ChainConfigUpdate.allowedChainIds} length.
     * @return paymentAmount source chain native currency amount to pay for {setChainConfigToDestination} call.
     */
    function estimateUpdateFee(
        uint256[] calldata dstChainIds, 
        uint256[] calldata configsLength
    ) external view returns(uint256 paymentAmount) {
        return IUTSRouter(router()).getUpdateFee(dstChainIds, configsLength);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./UTSBaseExtended.sol";

interface IUTSFactory {

    function REGISTRY() external view returns(address);

}

interface IUTSRegistry {

    function updateChainConfigs(uint256[] calldata allowedChainIds, ChainConfig[] calldata chainConfigs) external;

    function updateRouter(address newRouter) external;

}

/**
 * @notice Extension of {UTSBase} that adds an external calls to emit events in the {UTSRegistry} to log crucial data
 * off-chain.
 *
 * @dev Сan only be used by contracts deployed by {UTSFactory} or contracts manually registered in the {UTSRegistry}.
 */
abstract contract UTSBaseIndexed is UTSBaseExtended {

    /// @notice The {UTSRegistry} contract address.
    address private immutable REGISTRY;

    /// @notice Initializes immutable {REGISTRY} variable.
    constructor() {
        REGISTRY = IUTSFactory(msg.sender).REGISTRY();
    }

    function _setChainConfig(uint256[] memory allowedChainIds, ChainConfig[] memory chainConfigs) internal virtual override {

        IUTSRegistry(REGISTRY).updateChainConfigs(allowedChainIds, chainConfigs);

        super._setChainConfig(allowedChainIds, chainConfigs);
    }

    function _setRouter(address newRouter) internal virtual override {

        IUTSRegistry(REGISTRY).updateRouter(newRouter);

        super._setRouter(newRouter);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../libraries/UTSERC20DataTypes.sol";

interface IUTSBase {

    function protocolVersion() external view returns(bytes2);

    function underlyingToken() external view returns(address underlyingTokenAddress);

    function router() external view returns(address routerAddress);

    function getChainConfigs(uint256[] calldata chainIds) external view returns(ChainConfig[] memory configs);

    function isExecutionFailed(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin,
        uint256 nonce
    ) external view returns(bool isFailed);

    function estimateBridgeFee(
        uint256 dstChainId, 
        uint64 dstGasLimit, 
        uint16 customPayloadLength,
        bytes calldata protocolPayload
    ) external view returns(uint256 paymentAmount, uint64 dstMinGasLimit);

    function setRouter(address newRouter) external returns(bool success);

    function setChainConfig(
        uint256[] calldata allowedChainIds,
        ChainConfig[] calldata chainConfigs
    ) external returns(bool success);

    function bridge(
        address from,
        bytes calldata to,
        uint256 amount,
        uint256 dstChainId,
        uint64 dstGasLimit,
        bytes calldata customPayload,
        bytes calldata protocolPayload
    ) external payable returns(bool success, uint256 bridgedAmount);

    function redeem(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin
    ) external payable returns(bool success);

    function storeFailedExecution(
        address to,
        uint256 amount,
        bytes calldata customPayload,
        Origin calldata origin,
        bytes calldata result
    ) external;

    function retryRedeem(
        address to, 
        uint256 amount, 
        bytes calldata customPayload, 
        Origin calldata origin,
        uint256 nonce
    ) external returns(bool success);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./IUTSBase.sol";

interface IUTSBaseExtended {

    function setChainConfigToDestination(
        uint256[] calldata dstChainIds,
        ChainConfigUpdate[] calldata newConfigs
    ) external payable returns(bool success);

    function setChainConfigByRouter(
        uint256[] calldata allowedChainIds,
        ChainConfig[] calldata chainConfigs,
        Origin calldata origin
    ) external;

    function estimateUpdateFee(
        uint256[] calldata dstChainIds, 
        uint256[] calldata configsLength
    ) external view returns(uint256 paymentAmount);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../libraries/UTSERC20DataTypes.sol";

interface IUTSConnector {

    function underlyingDecimals() external view returns(uint8);

    function underlyingBalance() external view returns(uint256);

    function underlyingName() external view returns(string memory);

    function underlyingSymbol() external view returns(string memory);

    function initializeConnector(
        address owner,
        address underlyingToken,
        address router,
        uint256[] calldata allowedChainIds,
        ChainConfig[] calldata chainConfigs
    ) external;

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../libraries/UTSERC20DataTypes.sol";

interface IUTSRouter {

    function MASTER_ROUTER() external view returns(address);

    function PRICE_FEED() external view returns(address);

    function protocolVersion() external view returns(bytes2);

    function getBridgeFee(
        uint256 dstChainId, 
        uint64 dstGasLimit,
        uint256 payloadLength,
        bytes calldata protocolPayload
    ) external view returns(uint256 bridgeFeeAmount);

    function getUpdateFee(
        uint256[] calldata dstChainIds, 
        uint256[] calldata configsLength
    ) external view returns(uint256 updateFeeAmount);

    function dstMinGasLimit(uint256 dstChainId) external view returns(uint64 dstMinGasLimitAmount);

    function dstProtocolFee(uint256 dstChainId) external view returns(uint16 dstProtocolFeeRate);

    function dstUpdateGas(uint256 dstChainId) external view returns(uint64 dstUpdateGasAmount);

    function setDstMinGasLimit(uint256[] calldata dstChainIds, uint64[] calldata newDstMinGasLimits) external;

    function setDstProtocolFee(uint256[] calldata dstChainIds, uint16[] calldata newDstProtocolFees) external;

    function setDstUpdateGas(uint256[] calldata dstChainIds, uint64[] calldata newDstUpdateGas) external;

    function bridge(
        bytes calldata dstToken,
        bytes calldata sender,
        bytes calldata to,
        uint256 amount,
        uint8 srcDecimals,
        uint256 dstChainId,
        uint64 dstGasLimit,
        bytes calldata customPayload,
        bytes calldata protocolPayload
    ) external payable returns(bool success);

    function requestToUpdateConfig(
        bytes calldata sender,
        uint256[] calldata dstChainIds,
        bytes[] calldata dstPeers,
        ChainConfigUpdate[] calldata newConfigs
    ) external payable returns(bool success);

    function execute(
        address peerAddress, 
        bytes1 messageType, 
        bytes calldata localParams
    ) external payable returns(uint8 opResult);

    function pause() external;

    function unpause() external;

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @notice A library contains utility functions for converting address type for the UTS protocol V1.
 */
library AddressConverter {

    function toBytes(address _address) internal pure returns(bytes memory) {
        return abi.encodePacked(_address);
    }

    function toAddress(bytes memory _params) internal pure returns(address) {
        return address(uint160(bytes20(_params)));
    }

    function toAddressPadded(bytes memory _params) internal pure returns(address addressPadded) {
        if (32 > _params.length) return address(0);

        assembly {
            addressPadded := div(mload(add(add(_params, 0x20), 12)), 0x1000000000000000000000000)
        }
    }

}
// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;

library BytesLib {

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                    // the next line is the loop condition:
                    // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {

                        } eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @notice The library contains utility function for converting amounts with different decimals values for the UTS protocol V1.
 */
library DecimalsConverter {

    function convert(uint256 amount, uint256 decimalsIn, uint256 decimalsOut) internal pure returns(uint256) {
        if (decimalsOut > decimalsIn) {
            return amount * (10 ** (decimalsOut - decimalsIn));
        } else {
            if (decimalsOut < decimalsIn) {
                return amount / (10 ** (decimalsIn - decimalsOut));
            }
        }

        return amount;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice Various structs used in the UTS protocol V1 ERC20-module contracts.

    /// @notice Destination chain {ChainConfig} settings for {UTSBase}.
    struct ChainConfig {
        bytes   peerAddress; // connected {UTSToken} or {UTSConnector} contract address on the destination chain
        uint64  minGasLimit; // the amount of gas required to execute {UTSBase.redeem} function on the destination chain
        uint8   decimals;    // connected {peerAddress} decimals on the destination chain
        bool    paused;      // flag indicating whether current contract is paused for sending/receiving messages from the connected {peerAddress}
    }

    /// @notice Destination {peerAddress} contract {ChainConfig} settings for {UTSBaseExtended.setChainConfigToDestination} function.
    struct ChainConfigUpdate {
        uint256[] allowedChainIds;  // chains Ids available for bridging in both directions
        ChainConfig[] chainConfigs; // {ChainConfig} settings
    }

    /// @notice Crosschain message source peer data.
    struct Origin {
        bytes   sender;      // source message {msg.sender} sender
        uint256 chainId;     // source chain Id
        bytes   peerAddress; // source {UTSToken} or {UTSConnector} contract address
        uint8   decimals;    // source {peerAddress} decimals
    }

    /// @notice {UTSToken} initial settings, configuration, and metadata for deployment and initialization.
    struct DeployTokenData {
        bytes     owner;               // the address of the initial {AccessControl.DEFAULT_ADMIN_ROLE}
        string    name;                // the {ERC20.name} of the {UTSToken} token
        string    symbol;              // the {ERC20.symbol} of the {UTSToken} token
        uint8     decimals;            // the {ERC20.decimals} of the {UTSToken} token
        uint256   initialSupply;       // total initial {UTSToken} supply to mint
        uint256   mintedAmountToOwner; // initial {UTSToken} supply to mint to {owner} balance
        bool      pureToken;           // flag indicating whether the {UTSToken} is use lock/unlock or mint/burn mechanism for bridging
        bool      mintable;            // flag indicating whether {owner} can mint an unlimited amount of {UTSToken} tokens
        bool      globalBurnable;      // flag indicating whether the {UTSToken} is globally burnable by anyone
        bool      onlyRoleBurnable;    // flag indicating whether only addresses with the {AccessControl.BURNER_ROLE} can burn tokens
        bool      feeModule;           // flag indicating whether the {UTSToken} is supports the fee deducting for bridging
        bytes     router;              // the address of the authorized {UTSRouter}
        uint256[] allowedChainIds;     // chains Ids available for bridging in both directions
        ChainConfig[] chainConfigs;    // {ChainConfig} settings for the corresponding {allowedChainIds}
        bytes32   salt;                // value used for precalculation of {UTSToken} contract address
    }

    /// @notice {UTSConnector} initial settings and configuration for deployment and initialization.
    struct DeployConnectorData {
        bytes     owner;            // the address of the initial {AccessControl.DEFAULT_ADMIN_ROLE}
        bytes     underlyingToken;  // underlying ERC20 token address
        bool      feeModule;        // flag indicating whether the {UTSConnector} is supports the fee deducting for bridging
        bytes     router;           // the address of the authorized {UTSRouter}
        uint256[] allowedChainIds;  // chains Ids available for bridging in both directions
        ChainConfig[] chainConfigs; // {ChainConfig} settings for the corresponding {allowedChainIds}
        bytes32   salt;             // value used for precalculation of {UTSConnector} contract address
    }

    /// @notice Metadata for the crosschain deployment request for {UTSDeploymentRouter.sendDeployRequest}.
    struct DeployMetadata {
        uint256 dstChainId;  // destination chain Id
        bool    isConnector; // flag indicating whether is {UTSConnector}(true) or {UTSToken}(false) deployment
        bytes   params;      // abi.encoded {DeployTokenData} struct or abi.encoded {DeployConnectorData} struct
    }

    /// @notice Destination chain settings for sending a crosschain deployment request in the {UTSDeploymentRouter}.
    struct DstDeployConfig {
        bytes   factory;            // destination {UTSFactory} address
        uint64  tokenDeployGas;     // the amount of gas required to deploy the {UTSToken} on the destination chain
        uint64  connectorDeployGas; // the amount of gas required to deploy the {UTSConnector} on the destination chain
        uint16  protocolFee;        // protocol fee (basis points) for crosschain deployment on the destination chain
    }