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
// OpenZeppelin Contracts (last updated v5.0.0) (access/extensions/IAccessControlDefaultAdminRules.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "../IAccessControl.sol";

/**
 * @dev External interface of AccessControlDefaultAdminRules declared to support ERC165 detection.
 */
interface IAccessControlDefaultAdminRules is IAccessControl {
    /**
     * @dev The new default admin is not a valid default admin.
     */
    error AccessControlInvalidDefaultAdmin(address defaultAdmin);

    /**
     * @dev At least one of the following rules was violated:
     *
     * - The `DEFAULT_ADMIN_ROLE` must only be managed by itself.
     * - The `DEFAULT_ADMIN_ROLE` must only be held by one account at the time.
     * - Any `DEFAULT_ADMIN_ROLE` transfer must be in two delayed steps.
     */
    error AccessControlEnforcedDefaultAdminRules();

    /**
     * @dev The delay for transferring the default admin delay is enforced and
     * the operation must wait until `schedule`.
     *
     * NOTE: `schedule` can be 0 indicating there's no transfer scheduled.
     */
    error AccessControlEnforcedDefaultAdminDelay(uint48 schedule);

    /**
     * @dev Emitted when a {defaultAdmin} transfer is started, setting `newAdmin` as the next
     * address to become the {defaultAdmin} by calling {acceptDefaultAdminTransfer} only after `acceptSchedule`
     * passes.
     */
    event DefaultAdminTransferScheduled(address indexed newAdmin, uint48 acceptSchedule);

    /**
     * @dev Emitted when a {pendingDefaultAdmin} is reset if it was never accepted, regardless of its schedule.
     */
    event DefaultAdminTransferCanceled();

    /**
     * @dev Emitted when a {defaultAdminDelay} change is started, setting `newDelay` as the next
     * delay to be applied between default admin transfer after `effectSchedule` has passed.
     */
    event DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule);

    /**
     * @dev Emitted when a {pendingDefaultAdminDelay} is reset if its schedule didn't pass.
     */
    event DefaultAdminDelayChangeCanceled();

    /**
     * @dev Returns the address of the current `DEFAULT_ADMIN_ROLE` holder.
     */
    function defaultAdmin() external view returns (address);

    /**
     * @dev Returns a tuple of a `newAdmin` and an accept schedule.
     *
     * After the `schedule` passes, the `newAdmin` will be able to accept the {defaultAdmin} role
     * by calling {acceptDefaultAdminTransfer}, completing the role transfer.
     *
     * A zero value only in `acceptSchedule` indicates no pending admin transfer.
     *
     * NOTE: A zero address `newAdmin` means that {defaultAdmin} is being renounced.
     */
    function pendingDefaultAdmin() external view returns (address newAdmin, uint48 acceptSchedule);

    /**
     * @dev Returns the delay required to schedule the acceptance of a {defaultAdmin} transfer started.
     *
     * This delay will be added to the current timestamp when calling {beginDefaultAdminTransfer} to set
     * the acceptance schedule.
     *
     * NOTE: If a delay change has been scheduled, it will take effect as soon as the schedule passes, making this
     * function returns the new delay. See {changeDefaultAdminDelay}.
     */
    function defaultAdminDelay() external view returns (uint48);

    /**
     * @dev Returns a tuple of `newDelay` and an effect schedule.
     *
     * After the `schedule` passes, the `newDelay` will get into effect immediately for every
     * new {defaultAdmin} transfer started with {beginDefaultAdminTransfer}.
     *
     * A zero value only in `effectSchedule` indicates no pending delay change.
     *
     * NOTE: A zero value only for `newDelay` means that the next {defaultAdminDelay}
     * will be zero after the effect schedule.
     */
    function pendingDefaultAdminDelay() external view returns (uint48 newDelay, uint48 effectSchedule);

    /**
     * @dev Starts a {defaultAdmin} transfer by setting a {pendingDefaultAdmin} scheduled for acceptance
     * after the current timestamp plus a {defaultAdminDelay}.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * Emits a DefaultAdminRoleChangeStarted event.
     */
    function beginDefaultAdminTransfer(address newAdmin) external;

    /**
     * @dev Cancels a {defaultAdmin} transfer previously started with {beginDefaultAdminTransfer}.
     *
     * A {pendingDefaultAdmin} not yet accepted can also be cancelled with this function.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * May emit a DefaultAdminTransferCanceled event.
     */
    function cancelDefaultAdminTransfer() external;

    /**
     * @dev Completes a {defaultAdmin} transfer previously started with {beginDefaultAdminTransfer}.
     *
     * After calling the function:
     *
     * - `DEFAULT_ADMIN_ROLE` should be granted to the caller.
     * - `DEFAULT_ADMIN_ROLE` should be revoked from the previous holder.
     * - {pendingDefaultAdmin} should be reset to zero values.
     *
     * Requirements:
     *
     * - Only can be called by the {pendingDefaultAdmin}'s `newAdmin`.
     * - The {pendingDefaultAdmin}'s `acceptSchedule` should've passed.
     */
    function acceptDefaultAdminTransfer() external;

    /**
     * @dev Initiates a {defaultAdminDelay} update by setting a {pendingDefaultAdminDelay} scheduled for getting
     * into effect after the current timestamp plus a {defaultAdminDelay}.
     *
     * This function guarantees that any call to {beginDefaultAdminTransfer} done between the timestamp this
     * method is called and the {pendingDefaultAdminDelay} effect schedule will use the current {defaultAdminDelay}
     * set before calling.
     *
     * The {pendingDefaultAdminDelay}'s effect schedule is defined in a way that waiting until the schedule and then
     * calling {beginDefaultAdminTransfer} with the new delay will take at least the same as another {defaultAdmin}
     * complete transfer (including acceptance).
     *
     * The schedule is designed for two scenarios:
     *
     * - When the delay is changed for a larger one the schedule is `block.timestamp + newDelay` capped by
     * {defaultAdminDelayIncreaseWait}.
     * - When the delay is changed for a shorter one, the schedule is `block.timestamp + (current delay - new delay)`.
     *
     * A {pendingDefaultAdminDelay} that never got into effect will be canceled in favor of a new scheduled change.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * Emits a DefaultAdminDelayChangeScheduled event and may emit a DefaultAdminDelayChangeCanceled event.
     */
    function changeDefaultAdminDelay(uint48 newDelay) external;

    /**
     * @dev Cancels a scheduled {defaultAdminDelay} change.
     *
     * Requirements:
     *
     * - Only can be called by the current {defaultAdmin}.
     *
     * May emit a DefaultAdminDelayChangeCanceled event.
     */
    function rollbackDefaultAdminDelay() external;

    /**
     * @dev Maximum time in seconds for an increase to {defaultAdminDelay} (that is scheduled using {changeDefaultAdminDelay})
     * to take effect. Default to 5 days.
     *
     * When the {defaultAdminDelay} is scheduled to be increased, it goes into effect after the new delay has passed with
     * the purpose of giving enough time for reverting any accidental change (i.e. using milliseconds instead of seconds)
     * that may lock the contract. However, to avoid excessive schedules, the wait is capped by this function and it can
     * be overrode for a custom {defaultAdminDelay} increase scheduling.
     *
     * IMPORTANT: Make sure to add a reasonable amount of time while overriding this value, otherwise,
     * there's a risk of setting a high new delay that goes into effect almost immediately without the
     * possibility of human intervention in the case of an input error (eg. set milliseconds instead of seconds).
     */
    function defaultAdminDelayIncreaseWait() external view returns (uint48);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC5267.sol)

pragma solidity ^0.8.20;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

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
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
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
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
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
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
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
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
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
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
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
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
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
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
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
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
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
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
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
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
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
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
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
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
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
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
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
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
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
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
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
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
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
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
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
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
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
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
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
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
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
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
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
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
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
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
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
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
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
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
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
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
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
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
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
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
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
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
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
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
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
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
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
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
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
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
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
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
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
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
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
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
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
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
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
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
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
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
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
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
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
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
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
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
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
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
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
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
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
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
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
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
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
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
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
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
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
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
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
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
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
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
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
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
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
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
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
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
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
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
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
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
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
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
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
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
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
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
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
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
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
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
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
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @notice A library for manipulating uint512 quantities.
 * @dev The 512-bit unsigned integers are represented as two uint256 "limbs", a `hi` limb for the most significant bits,
 * and a `lo` limb for the least-significant bits. The resulting uint512 quantity is obtained with `hi * 2^256 + lo`.
 */
library HugeUint {
    /// @notice Indicates that the division failed because the divisor is zero or the result overflows a uint256.
    error HugeUintDivisionFailed();

    /// @notice Indicates that the addition overflowed a uint512.
    error HugeUintAddOverflow();

    /// @notice Indicates that the subtraction underflowed.
    error HugeUintSubUnderflow();

    /// @notice Indicates that the multiplication overflowed a uint512.
    error HugeUintMulOverflow();

    /**
     * @notice A 512-bit integer represented as two 256-bit limbs.
     * @dev The integer value can be reconstructed as `hi * 2^256 + lo`.
     * @param hi The most-significant bits (higher limb) of the integer.
     * @param lo The least-significant bits (lower limb) of the integer.
     */
    struct Uint512 {
        uint256 hi;
        uint256 lo;
    }

    /**
     * @notice Wraps a uint256 into a {Uint512} integer.
     * @param x A uint256 integer.
     * @return The same value as a 512-bit integer.
     */
    function wrap(uint256 x) internal pure returns (Uint512 memory) {
        return Uint512({ hi: 0, lo: x });
    }

    /**
     * @notice Calculates the sum `a + b` of two 512-bit unsigned integers.
     * @dev This function will revert if the result overflows a uint512.
     * @param a The first operand.
     * @param b The second operand.
     * @return res_ The sum of `a` and `b`.
     */
    function add(Uint512 memory a, Uint512 memory b) internal pure returns (Uint512 memory res_) {
        (res_.lo, res_.hi) = _add(a.lo, a.hi, b.lo, b.hi);
        // check for overflow, i.e. if the result is less than b
        if (res_.hi < b.hi || (res_.hi == b.hi && res_.lo < b.lo)) {
            revert HugeUintAddOverflow();
        }
    }

    /**
     * @notice Calculates the difference `a - b` of two 512-bit unsigned integers.
     * @dev This function will revert if `b > a`.
     * @param a The first operand.
     * @param b The second operand.
     * @return res_ The difference `a - b`.
     */
    function sub(Uint512 memory a, Uint512 memory b) internal pure returns (Uint512 memory res_) {
        // check for underflow
        if (a.hi < b.hi || (a.hi == b.hi && a.lo < b.lo)) {
            revert HugeUintSubUnderflow();
        }
        (res_.lo, res_.hi) = _sub(a.lo, a.hi, b.lo, b.hi);
    }

    /**
     * @notice Calculates the product `a * b` of two 256-bit unsigned integers using the Chinese remainder theorem.
     * @param a The first operand.
     * @param b The second operand.
     * @return res_ The product `a * b` of the operands as an unsigned 512-bit integer.
     */
    function mul(uint256 a, uint256 b) internal pure returns (Uint512 memory res_) {
        (res_.lo, res_.hi) = _mul256(a, b);
    }

    /**
     * @notice Calculates the product `a * b` of a 512-bit unsigned integer and a 256-bit unsigned integer.
     * @dev This function reverts if the result overflows a uint512.
     * @param a The first operand.
     * @param b The second operand.
     * @return res_ The product `a * b` of the operands as an unsigned 512-bit integer.
     */
    function mul(Uint512 memory a, uint256 b) internal pure returns (Uint512 memory res_) {
        if ((a.hi == 0 && a.lo == 0) || b == 0) {
            return res_;
        }
        (res_.lo, res_.hi) = _mul256(a.lo, b);
        unchecked {
            uint256 p = a.hi * b;
            if (p / b != a.hi) {
                revert HugeUintMulOverflow();
            }
            res_.hi += p;
            if (res_.hi < p) {
                revert HugeUintMulOverflow();
            }
        }
    }

    /**
     * @notice Calculates the division `floor(a / b)` of a 512-bit unsigned integer by an unsigned 256-bit integer.
     * @dev The call will revert if the result doesn't fit inside a uint256 or if the denominator is zero.
     * @param a The numerator as a 512-bit unsigned integer.
     * @param b The denominator as a 256-bit unsigned integer.
     * @return res_ The division `floor(a / b)` of the operands as an unsigned 256-bit integer.
     */
    function div(Uint512 memory a, uint256 b) internal pure returns (uint256 res_) {
        // make sure the output fits inside a uint256, also prevents b == 0
        if (b <= a.hi) {
            revert HugeUintDivisionFailed();
        }
        // if the numerator is smaller than the denominator, the result is zero
        if (a.hi == 0 && a.lo < b) {
            return 0;
        }
        // the first operand fits in 256 bits, we can use the Solidity division operator
        if (a.hi == 0) {
            unchecked {
                return a.lo / b;
            }
        }
        res_ = _div256(a.lo, a.hi, b);
    }

    /**
     * @notice Computes the division `floor(a/b)` of two 512-bit integers, knowing the result fits inside a uint256.
     * @dev Credits chfast (Apache 2.0 License): <https://github.com/chfast/intx>.
     * This function will revert if the second operand is zero or if the result doesn't fit inside a uint256.
     * @param a The numerator as a 512-bit integer.
     * @param b The denominator as a 512-bit integer.
     * @return res_ The quotient floor(a/b).
     */
    function div(Uint512 memory a, Uint512 memory b) internal pure returns (uint256 res_) {
        res_ = _div(a.lo, a.hi, b.lo, b.hi);
    }

    /**
     * @notice Calculates the sum `a + b` of two 512-bit unsigned integers.
     * @dev Credits Remco Bloemen (MIT license): <https://2π.com/17/512-bit-division>.
     * The result is not checked for overflow, the caller must ensure that the result fits inside a uint512.
     * @param a0 The low limb of the first operand.
     * @param a1 The high limb of the first operand.
     * @param b0 The low limb of the second operand.
     * @param b1 The high limb of the second operand.
     * @return lo_ The low limb of the result of `a + b`.
     * @return hi_ The high limb of the result of `a + b`.
     */
    function _add(uint256 a0, uint256 a1, uint256 b0, uint256 b1) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := add(a0, b0)
            hi_ := add(add(a1, b1), lt(lo_, a0))
        }
    }

    /**
     * @notice Calculates the difference `a - b` of two 512-bit unsigned integers.
     * @dev Credits Remco Bloemen (MIT license): <https://2π.com/17/512-bit-division>.
     * The result is not checked for underflow, the caller must ensure that the second operand is less than or equal to
     * the first operand.
     * @param a0 The low limb of the first operand.
     * @param a1 The high limb of the first operand.
     * @param b0 The low limb of the second operand.
     * @param b1 The high limb of the second operand.
     * @return lo_ The low limb of the result of `a - b`.
     * @return hi_ The high limb of the result of `a - b`.
     */
    function _sub(uint256 a0, uint256 a1, uint256 b0, uint256 b1) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := sub(a0, b0)
            hi_ := sub(sub(a1, b1), lt(a0, b0))
        }
    }

    /**
     * @notice Calculates the product `a * b` of two 256-bit unsigned integers using the Chinese remainder theorem.
     * @dev Credits Remco Bloemen (MIT license): <https://2π.com/17/chinese-remainder-theorem>
     * and Solady (MIT license): <https://github.com/Vectorized/solady>.
     * @param a The first operand.
     * @param b The second operand.
     * @return lo_ The low limb of the result of `a * b`.
     * @return hi_ The high limb of the result of `a * b`.
     */
    function _mul256(uint256 a, uint256 b) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := mul(a, b)
            let mm := mulmod(a, b, not(0)) // (a * b) % uint256.max
            hi_ := sub(mm, add(lo_, lt(mm, lo_)))
        }
    }

    /**
     * @notice Calculates the division `floor(a / b)` of a 512-bit unsigned integer by an unsigned 256-bit integer.
     * @dev Credits Solady (MIT license): <https://github.com/Vectorized/solady>.
     * The caller must ensure that the result fits inside a uint256 and that the division is non-zero.
     * For performance reasons, the caller should ensure that the numerator high limb (hi) is non-zero.
     * @param a0 The low limb of the numerator.
     * @param a1 The high limb of the  numerator.
     * @param b The denominator as a 256-bit unsigned integer.
     * @return res_ The division `floor(a / b)` of the operands as an unsigned 256-bit integer.
     */
    function _div256(uint256 a0, uint256 a1, uint256 b) internal pure returns (uint256 res_) {
        uint256 r;
        assembly {
            // to make the division exact, we find out the remainder of the division of a by b
            r := mulmod(a1, not(0), b) // (a1 * uint256.max) % b
            r := addmod(r, a1, b) // (r + a1) % b
            r := addmod(r, a0, b) // (r + a0) % b

            // `t` is the least significant bit of `b`
            // always greater or equal to 1
            let t := and(b, sub(0, b))
            // divide `b` by `t`, which is a power of two
            b := div(b, t)
            // invert `b mod 2**256`
            // now that `b` is an odd number, it has an inverse
            // modulo `2**256` such that `b * inv = 1 mod 2**256`
            // compute the inverse by starting with a seed that is
            // correct for four bits. That is, `b * inv = 1 mod 2**4`
            let inv := xor(2, mul(3, b))
            // now use Newton-Raphson iteration to improve the precision
            // thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step
            inv := mul(inv, sub(2, mul(b, inv))) // inverse mod 2**8
            inv := mul(inv, sub(2, mul(b, inv))) // inverse mod 2**16
            inv := mul(inv, sub(2, mul(b, inv))) // inverse mod 2**32
            inv := mul(inv, sub(2, mul(b, inv))) // inverse mod 2**64
            inv := mul(inv, sub(2, mul(b, inv))) // inverse mod 2**128
            res_ :=
                mul(
                    // divide [a1 a0] by the factors of two
                    // shift in bits from `a1` into `a0`
                    // for this we need to flip `t` such that it is `2**256 / t`
                    or(mul(sub(a1, gt(r, a0)), add(div(sub(0, t), t), 1)), div(sub(a0, r), t)),
                    // inverse mod 2**256
                    mul(inv, sub(2, mul(b, inv)))
                )
        }
    }

    /**
     * @notice Computes the division of a 768-bit integer `a` by a 512-bit integer `b`, knowing the reciprocal of `b`.
     * @dev Credits chfast (Apache 2.0 License): <https://github.com/chfast/intx>.
     * @param a0 The LSB of the numerator.
     * @param a1 The middle limb of the numerator.
     * @param a2 The MSB of the numerator.
     * @param b0 The low limb of the divisor.
     * @param b1 The high limb of the divisor.
     * @param v The reciprocal `v` as defined in `_reciprocal_2`.
     * @return The quotient floor(a/b).
     */
    function _div_2(uint256 a0, uint256 a1, uint256 a2, uint256 b0, uint256 b1, uint256 v)
        internal
        pure
        returns (uint256)
    {
        (uint256 q0, uint256 q1) = _mul256(v, a2);
        (q0, q1) = _add(q0, q1, a1, a2);
        (uint256 t0, uint256 t1) = _mul256(b0, q1);
        uint256 r1;
        assembly {
            r1 := sub(a1, mul(q1, b1))
        }
        uint256 r0;
        (r0, r1) = _sub(a0, r1, t0, t1);
        (r0, r1) = _sub(r0, r1, b0, b1);
        assembly {
            q1 := add(q1, 1)
        }
        if (r1 >= q0) {
            assembly {
                q1 := sub(q1, 1)
            }
            (r0, r1) = _add(r0, r1, b0, b1);
        }
        if (r1 > b1 || (r1 == b1 && r0 >= b0)) {
            assembly {
                q1 := add(q1, 1)
            }
            // we don't care about the remainder
            // (r0, r1) = _sub(r0, r1, b0, b1);
        }
        return q1;
    }

    /**
     * @notice Computes the division floor(a/b) of two 512-bit integers, knowing the result fits inside a uint256.
     * @dev Credits chfast (Apache 2.0 License): <https://github.com/chfast/intx>.
     * @param a0 LSB of the numerator.
     * @param a1 MSB of the numerator.
     * @param b0 LSB of the divisor.
     * @param b1 MSB of the divisor.
     * @return res_ The quotient floor(a/b).
     */
    function _div(uint256 a0, uint256 a1, uint256 b0, uint256 b1) internal pure returns (uint256 res_) {
        if (b1 == 0) {
            // prevent division by zero
            if (b0 == 0) {
                revert HugeUintDivisionFailed();
            }
            // if both operands fit inside a uint256, we can use the Solidity division operator
            if (a1 == 0) {
                unchecked {
                    return a0 / b0;
                }
            }
            // if the result fits inside a uint256, we can use the `div(Uint512,uint256)` function
            if (b0 > a1) {
                return _div256(a0, a1, b0);
            }
            revert HugeUintDivisionFailed();
        }

        // if the numerator is smaller than the denominator, the result is zero
        if (a1 < b1 || (a1 == b1 && a0 < b0)) {
            return 0;
        }

        // division algo
        uint256 lsh = _clz(b1);
        if (lsh == 0) {
            // numerator is equal or larger than the denominator, and the denominator is at least 0b1000...
            // the result is necessarily 1
            return 1;
        }

        uint256 bn_lo;
        uint256 bn_hi;
        uint256 an_lo;
        uint256 an_hi;
        uint256 an_ex;
        assembly {
            let rsh := sub(256, lsh)
            bn_lo := shl(lsh, b0)
            bn_hi := or(shl(lsh, b1), shr(rsh, b0))
            an_lo := shl(lsh, a0)
            an_hi := or(shl(lsh, a1), shr(rsh, a0))
            an_ex := shr(rsh, a1)
        }
        uint256 v = _reciprocal_2(bn_lo, bn_hi);
        res_ = _div_2(an_lo, an_hi, an_ex, bn_lo, bn_hi, v);
    }

    /**
     * @notice Computes the reciprocal `v = floor((2^512-1) / d) - 2^256`.
     * @dev The input must be normalized (d >= 2^255).
     * @param d The input value.
     * @return v_ The reciprocal of d.
     */
    function _reciprocal(uint256 d) internal pure returns (uint256 v_) {
        if (d & 0x8000000000000000000000000000000000000000000000000000000000000000 == 0) {
            revert HugeUintDivisionFailed();
        }
        v_ = _div256(type(uint256).max, type(uint256).max - d, d);
    }

    /**
     * @notice Computes the reciprocal `v = floor((2^768-1) / d) - 2^256`, where d is a uint512 integer.
     * @dev Credits chfast (Apache 2.0 License): <https://github.com/chfast/intx>.
     * @param d0 LSB of the input.
     * @param d1 MSB of the input.
     * @return v_ The reciprocal of d.
     */
    function _reciprocal_2(uint256 d0, uint256 d1) internal pure returns (uint256 v_) {
        v_ = _reciprocal(d1);
        uint256 p;
        assembly {
            p := mul(d1, v_)
            p := add(p, d0)
            if lt(p, d0) {
                // carry out
                v_ := sub(v_, 1)
                if iszero(lt(p, d1)) {
                    v_ := sub(v_, 1)
                    p := sub(p, d1)
                }
                p := sub(p, d1)
            }
        }
        (uint256 t0, uint256 t1) = _mul256(v_, d0);
        assembly {
            p := add(p, t1)
            if lt(p, t1) {
                // carry out
                v_ := sub(v_, 1)
                if and(iszero(lt(p, d1)), or(gt(p, d1), iszero(lt(t0, d0)))) {
                    // if (<p, t0> >= <d1, d0>)
                    v_ := sub(v_, 1)
                }
            }
        }
    }

    /**
     * @notice Counts the number of consecutive zero bits, starting from the left.
     * @dev Credits Solady (MIT license): <https://github.com/Vectorized/solady>.
     * @param x An unsigned integer.
     * @return n_ The number of zeroes starting from the most significant bit.
     */
    function _clz(uint256 x) internal pure returns (uint256 n_) {
        if (x == 0) {
            return 256;
        }
        assembly {
            n_ := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            n_ := or(n_, shl(6, lt(0xffffffffffffffff, shr(n_, x))))
            n_ := or(n_, shl(5, lt(0xffffffff, shr(n_, x))))
            n_ := or(n_, shl(4, lt(0xffff, shr(n_, x))))
            n_ := or(n_, shl(3, lt(0xff, shr(n_, x))))
            n_ :=
                add(
                    xor(
                        n_,
                        byte(
                            and(0x1f, shr(shr(n_, x), 0x8421084210842108cc6318c6db6d54be)),
                            0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff
                        )
                    ),
                    iszero(x)
                )
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
            x := and(x, add(not(x), 1))
            // For the upper 3 bits of the result, use a De Bruijn-like lookup.
            // Credit to adhusson: https://blog.adhusson.com/cheap-find-first-set-evm/
            // forgefmt: disable-next-item
            r := shl(5, shr(252, shl(shl(2, shr(250, mul(x,
                0xb6db6db6ddddddddd34d34d349249249210842108c6318c639ce739cffffffff))),
                0x8040405543005266443200005020610674053026020000107506200176117077)))
            // For the lower 5 bits of the result, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, x)), 0x1f),
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
            uint256 m0 = 0x100000000000000000000000000000001 * (~toUint(x == uint256(0)) >> 192);
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

    /// @dev Returns the index of the most significant set bit in `[0..upTo]`.
    /// If no set bit is found, returns `NOT_FOUND`.
    function findLastSet(Bitmap storage bitmap, uint256 upTo)
        internal
        view
        returns (uint256 setBitIndex)
    {
        setBitIndex = NOT_FOUND;
        uint256 bucket = upTo >> 8;
        uint256 bits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, not(upTo)) // `256 - (255 & upTo) - 1`.
            bits := shr(offset, shl(offset, sload(keccak256(0x00, 0x40))))
            if iszero(or(bits, iszero(bucket))) {
                for {} 1 {} {
                    bucket := add(bucket, setBitIndex) // `sub(bucket, 1)`.
                    mstore(0x00, bucket)
                    bits := sload(keccak256(0x00, 0x40))
                    if or(bits, iszero(bucket)) { break }
                }
            }
        }
        if (bits != 0) {
            setBitIndex = (bucket << 8) | LibBit.fls(bits);
            /// @solidity memory-safe-assembly
            assembly {
                setBitIndex := or(setBitIndex, sub(0, gt(setBitIndex, upTo)))
            }
        }
    }

    /// @dev Returns the index of the least significant unset bit in `[begin..upTo]`.
    /// If no unset bit is found, returns `NOT_FOUND`.
    function findFirstUnset(Bitmap storage bitmap, uint256 begin, uint256 upTo)
        internal
        view
        returns (uint256 unsetBitIndex)
    {
        unsetBitIndex = NOT_FOUND;
        uint256 bucket = begin >> 8;
        uint256 negBits;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, bucket)
            mstore(0x20, bitmap.slot)
            let offset := and(0xff, begin)
            negBits := shl(offset, shr(offset, not(sload(keccak256(0x00, 0x40)))))
            if iszero(negBits) {
                let lastBucket := shr(8, upTo)
                for {} 1 {} {
                    bucket := add(bucket, 1)
                    mstore(0x00, bucket)
                    negBits := not(sload(keccak256(0x00, 0x40)))
                    if or(negBits, gt(bucket, lastBucket)) { break }
                }
                if gt(bucket, lastBucket) {
                    negBits := shl(and(0xff, not(upTo)), shr(and(0xff, not(upTo)), negBits))
                }
            }
        }
        if (negBits != 0) {
            uint256 r = (bucket << 8) | LibBit.ffs(negBits);
            /// @solidity memory-safe-assembly
            assembly {
                unsetBitIndex := or(r, sub(0, or(gt(r, upTo), lt(r, begin))))
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes as Types } from "../UsdnProtocol/IUsdnProtocolTypes.sol";

/**
 * @title IBaseLiquidationRewardsManager
 * @notice This interface exposes the only function used by the UsdnProtocol.
 * @dev Future implementations of the rewards manager must implement this interface without modifications.
 */
interface IBaseLiquidationRewardsManager {
    /**
     * @notice Computes the amount of assets to reward a liquidator.
     * @param liquidatedTicks Information about the liquidated ticks.
     * @param currentPrice The current price of the asset.
     * @param rebased Indicates whether a USDN rebase was performed.
     * @param rebalancerAction The action performed by the {UsdnProtocolLongLibrary._triggerRebalancer} function.
     * @param action The type of protocol action that triggered the liquidation.
     * @param rebaseCallbackResult The result of the rebase callback, if any.
     * @param priceData The oracle price data, if any. This can be used to differentiate rewards based on the oracle
     * used to provide the liquidation price.
     * @return assetRewards_ The amount of asset tokens to reward the liquidator.
     */
    function getLiquidationRewards(
        Types.LiqTickInfo[] calldata liquidatedTicks,
        uint256 currentPrice,
        bool rebased,
        Types.RebalancerAction rebalancerAction,
        Types.ProtocolAction action,
        bytes calldata rebaseCallbackResult,
        bytes calldata priceData
    ) external view returns (uint256 assetRewards_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes as Types } from "../UsdnProtocol/IUsdnProtocolTypes.sol";
import { PriceInfo } from "./IOracleMiddlewareTypes.sol";

/**
 * @title Base Oracle Middleware interface
 * @notice This interface exposes the only functions used or required by the USDN Protocol.
 * @dev Any current or future implementation of the oracle middleware must be compatible with
 * this interface without any modification.
 */
interface IBaseOracleMiddleware {
    /**
     * @notice Parse and validate `data` and returns the corresponding price data.
     * @dev The data format is specific to the middleware and is simply forwarded from the user transaction's calldata.
     * A fee amounting to exactly {validationCost} (with the same `data` and `action`) must be sent or the transaction
     * will revert.
     * @param actionId A unique identifier for the current action. This identifier can be used to link an `Initiate`
     * call with the corresponding `Validate` call.
     * @param targetTimestamp The target timestamp for validating the price data. For validation actions, this is the
     * timestamp of the initiation.
     * @param action Type of action for which the price is requested. The middleware may use this to alter the
     * validation of the price or the returned price.
     * @param data The data to be used to communicate with oracles, the format varies from middleware to middleware and
     * can be different depending on the action.
     * @return result_ The price and timestamp as {IOracleMiddlewareTypes.PriceInfo}.
     */
    function parseAndValidatePrice(
        bytes32 actionId,
        uint128 targetTimestamp,
        Types.ProtocolAction action,
        bytes calldata data
    ) external payable returns (PriceInfo memory result_);

    /**
     * @notice Gets the required delay (in seconds) between the moment an action is initiated and the timestamp of the
     * price data used to validate that action.
     * @return delay_ The validation delay.
     */
    function getValidationDelay() external view returns (uint256 delay_);

    /**
     * @notice Gets The maximum amount of time (in seconds) after initiation during which a low-latency price oracle can
     * be used for validation.
     * @return delay_ The maximum delay for low-latency validation.
     */
    function getLowLatencyDelay() external view returns (uint16 delay_);

    /**
     * @notice Gets the number of decimals for the price.
     * @return decimals_ The number of decimals.
     */
    function getDecimals() external view returns (uint8 decimals_);

    /**
     * @notice Returns the cost of one price validation for the given action (in native token).
     * @param data Price data for which to get the fee.
     * @param action Type of the action for which the price is requested.
     * @return cost_ The cost of one price validation (in native token).
     */
    function validationCost(bytes calldata data, Types.ProtocolAction action) external view returns (uint256 cost_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @notice The price and timestamp returned by the oracle middleware.
 * @param price The validated asset price, potentially adjusted by the middleware.
 * @param neutralPrice The neutral/average price of the asset.
 * @param timestamp The timestamp of the price data.
 */
struct PriceInfo {
    uint256 price;
    uint256 neutralPrice;
    uint256 timestamp;
}

/**
 * @notice The price and timestamp returned by the Chainlink oracle.
 * @param price The asset price formatted by the middleware.
 * @param timestamp When the price was published on chain.
 */
struct ChainlinkPriceInfo {
    int256 price;
    uint256 timestamp;
}

/**
 * @notice Representation of a Pyth price with a uint256 price.
 * @param price The price of the asset.
 * @param conf The confidence interval around the price (in dollars, absolute value).
 * @param publishTime Unix timestamp describing when the price was published.
 */
struct FormattedPythPrice {
    uint256 price;
    uint256 conf;
    uint256 publishTime;
}

/**
 * @notice The price and timestamp returned by the Redstone oracle.
 * @param price The asset price formatted by the middleware.
 * @param timestamp The timestamp of the price data.
 */
struct RedstonePriceInfo {
    uint256 price;
    uint256 timestamp;
}

/**
 * @notice The different confidence interval of a Pyth price.
 * @dev Applied to the neutral price and available as `price`.
 * @param Up Adjusted price at the upper bound of the confidence interval.
 * @param Down Adjusted price at the lower bound of the confidence interval.
 * @param None Neutral price without adjustment.
 */
enum ConfidenceInterval {
    Up,
    Down,
    None
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes as Types } from "../UsdnProtocol/IUsdnProtocolTypes.sol";
import { IRebalancerTypes } from "./IRebalancerTypes.sol";

interface IBaseRebalancer {
    /**
     * @notice Returns the necessary data for the USDN protocol to update the position.
     * @return pendingAssets_ The amount of assets that are pending inclusion in the protocol.
     * @return maxLeverage_ The maximum leverage of the rebalancer.
     * @return currentPosId_ The ID of the current position (`tick` == `NO_POSITION_TICK` if no position).
     */
    function getCurrentStateData()
        external
        view
        returns (uint128 pendingAssets_, uint256 maxLeverage_, Types.PositionId memory currentPosId_);

    /**
     * @notice Returns the minimum amount of assets a user can deposit in the rebalancer.
     * @return minAssetDeposit_ The minimum amount of assets that can be deposited by a user.
     */
    function getMinAssetDeposit() external view returns (uint256 minAssetDeposit_);

    /**
     * @notice Returns the data regarding the assets deposited by the provided user.
     * @param user The address of the user.
     * @return data_ The data regarding the assets deposited by the provided user.
     */
    function getUserDepositData(address user) external view returns (IRebalancerTypes.UserDeposit memory data_);

    /**
     * @notice Indicates that the previous version of the position was closed and a new one was opened.
     * @dev If `previousPosValue` equals 0, it means the previous version got liquidated.
     * @param newPosId The position ID of the new position.
     * @param previousPosValue The amount of assets left in the previous position.
     */
    function updatePosition(Types.PositionId calldata newPosId, uint128 previousPosValue) external;

    /* -------------------------------------------------------------------------- */
    /*                                    Admin                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Sets the minimum amount of assets to be deposited by a user.
     * @dev The new minimum amount must be greater than or equal to the minimum long position of the USDN protocol.
     * This function can only be called by the owner or the USDN protocol.
     * @param minAssetDeposit The new minimum amount of assets to be deposited.
     */
    function setMinAssetDeposit(uint256 minAssetDeposit) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IUsdnProtocolTypes as Types } from "../../interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";
import { IUsdnProtocol } from "../UsdnProtocol/IUsdnProtocol.sol";
import { IBaseRebalancer } from "./IBaseRebalancer.sol";
import { IRebalancerErrors } from "./IRebalancerErrors.sol";
import { IRebalancerEvents } from "./IRebalancerEvents.sol";
import { IRebalancerTypes } from "./IRebalancerTypes.sol";

interface IRebalancer is IBaseRebalancer, IRebalancerErrors, IRebalancerEvents, IRebalancerTypes {
    /**
     * @notice Gets the value of the multiplier at 1x.
     * @dev Also helps to normalize the result of multiplier calculations.
     * @return factor_ The multiplier factor.
     */
    function MULTIPLIER_FACTOR() external view returns (uint256 factor_);

    /**
     * @notice The maximum cooldown time between actions.
     * @return cooldown_ The maximum cooldown time between actions.
     */
    function MAX_ACTION_COOLDOWN() external view returns (uint256 cooldown_);

    /**
     * @notice The EIP712 {initiateClosePosition} typehash.
     * @dev By including this hash into the EIP712 message for this domain, this can be used together with
     * [ECDSA-recover](https://docs.openzeppelin.com/contracts/5.x/api/utils#ECDSA) to obtain the signer of a message.
     * @return typehash_ The EIP712 {initiateClosePosition} typehash.
     */
    function INITIATE_CLOSE_TYPEHASH() external view returns (bytes32 typehash_);

    /**
     * @notice Gets the maximum amount of seconds to wait to execute a {initiateClosePosition} since a new rebalancer
     * long position has been created.
     * @return closeDelay_ The max close delay value.
     */
    function MAX_CLOSE_DELAY() external view returns (uint256 closeDelay_);

    /**
     * @notice Returns the address of the asset used by the USDN protocol.
     * @return asset_ The address of the asset used by the USDN protocol.
     */
    function getAsset() external view returns (IERC20Metadata asset_);

    /**
     * @notice Returns the address of the USDN protocol.
     * @return protocol_ The address of the USDN protocol.
     */
    function getUsdnProtocol() external view returns (IUsdnProtocol protocol_);

    /**
     * @notice Returns the version of the current position (0 means no position open).
     * @return version_ The version of the current position.
     */
    function getPositionVersion() external view returns (uint128 version_);

    /**
     * @notice Returns the maximum leverage the rebalancer position can have.
     * @dev In some edge cases during the calculation of the rebalancer position's tick, this value might be
     * exceeded by a slight margin.
     * @dev Returns the max leverage of the USDN Protocol if it's lower than the rebalancer's.
     * @return maxLeverage_ The maximum leverage.
     */
    function getPositionMaxLeverage() external view returns (uint256 maxLeverage_);

    /**
     * @notice Returns the amount of assets deposited and waiting for the next version to be opened.
     * @return pendingAssetsAmount_ The amount of pending assets.
     */
    function getPendingAssetsAmount() external view returns (uint128 pendingAssetsAmount_);

    /**
     * @notice Returns the data of the provided version of the position.
     * @param version The version of the position.
     * @return positionData_ The data for the provided version of the position.
     */
    function getPositionData(uint128 version) external view returns (PositionData memory positionData_);

    /**
     * @notice Gets the time limits for the action validation process.
     * @return timeLimits_ The time limits.
     */
    function getTimeLimits() external view returns (TimeLimits memory timeLimits_);

    /**
     * @notice Increases the allowance of assets for the USDN protocol spender by `addAllowance`.
     * @param addAllowance Amount to add to the allowance of the USDN Protocol.
     */
    function increaseAssetAllowance(uint256 addAllowance) external;

    /**
     * @notice Returns the version of the last position that got liquidated.
     * @dev 0 means no liquidated version yet.
     * @return version_ The version of the last position that got liquidated.
     */
    function getLastLiquidatedVersion() external view returns (uint128 version_);

    /**
     * @notice Gets the nonce a user can use to generate a delegation signature.
     * @dev This is to prevent replay attacks when using an EIP712 delegation signature.
     * @param user The user address of the deposited amount in the rebalancer.
     * @return nonce_ The user's nonce.
     */
    function getNonce(address user) external view returns (uint256 nonce_);

    /**
     * @notice Gets the domain separator v4 used for EIP-712 signatures.
     * @return domainSeparator_ The domain separator v4.
     */
    function domainSeparatorV4() external view returns (bytes32 domainSeparator_);

    /**
     * @notice Gets the timestamp by which a user must wait to perform a {initiateClosePosition}.
     * @return timestamp_ The timestamp until which the position cannot be closed.
     */
    function getCloseLockedUntil() external view returns (uint256 timestamp_);

    /**
     * @notice Deposits assets into this contract to be included in the next position after validation
     * @dev The user must call {validateDepositAssets} between `_timeLimits.validationDelay` and.
     * `_timeLimits.validationDeadline` seconds after this action.
     * @param amount The amount in assets that will be deposited into the rebalancer.
     * @param to The address which will need to validate and which will own the position.
     */
    function initiateDepositAssets(uint88 amount, address to) external;

    /**
     * @notice Validates a deposit to be included in the next position version.
     * @dev The `to` from the `initiateDepositAssets` must call this function between `_timeLimits.validationDelay` and
     * `_timeLimits.validationDeadline` seconds after the initiate action. After that, the user must wait until
     * `_timeLimits.actionCooldown` seconds has elapsed, and then can call `resetDepositAssets` to retrieve their
     * assets.
     */
    function validateDepositAssets() external;

    /**
     * @notice Retrieves the assets for a failed deposit due to waiting too long before calling {validateDepositAssets}.
     * @dev The user must wait `_timeLimits.actionCooldown` since the {initiateDepositAssets} before calling this
     * function.
     */
    function resetDepositAssets() external;

    /**
     * @notice Withdraws assets that were not yet included in a position.
     * @dev The user must call {validateWithdrawAssets} between `_timeLimits.validationDelay` and
     * `_timeLimits.validationDeadline` seconds after this action.
     */
    function initiateWithdrawAssets() external;

    /**
     * @notice Validates a withdrawal of assets that were not yet included in a position.
     * @dev The user must call this function between `_timeLimits.validationDelay` and `_timeLimits.validationDeadline`
     * seconds after {initiateWithdrawAssets}. After that, the user must wait until the cooldown has elapsed, and then
     * can call {initiateWithdrawAssets} again or wait to be included in the next position.
     * @param amount The amount of assets to withdraw.
     * @param to The recipient of the assets.
     */
    function validateWithdrawAssets(uint88 amount, address to) external;

    /**
     * @notice Closes the provided amount from the current rebalancer's position.
     * @dev The rebalancer allows partially closing its position to withdraw the user's assets + PnL.
     * The remaining amount needs to be above `_minAssetDeposit`. The validator is always the `msg.sender`, which means
     * the user must call `validateClosePosition` on the protocol side after calling this function.
     * @param amount The amount to close relative to the amount deposited.
     * @param to The recipient of the assets.
     * @param validator The address that should validate the open position.
     * @param userMinPrice The minimum price at which the position can be closed.
     * @param deadline The deadline of the close position to be initiated.
     * @param currentPriceData The current price data.
     * @param previousActionsData The data needed to validate actionable pending actions.
     * @param delegationData An optional delegation data that include the depositOwner and an EIP712 signature to
     * provide when closing a position on the owner's behalf.
     * If used, it needs to be encoded with `abi.encode(depositOwner, abi.encodePacked(r, s, v))`.
     * @return outcome_ The outcome of the UsdnProtocol's `initiateClosePosition` call, check
     * {IUsdnProtocolActions.initiateClosePosition} for more details.
     */
    function initiateClosePosition(
        uint88 amount,
        address to,
        address payable validator,
        uint256 userMinPrice,
        uint256 deadline,
        bytes calldata currentPriceData,
        Types.PreviousActionsData calldata previousActionsData,
        bytes calldata delegationData
    ) external payable returns (Types.LongActionOutcome outcome_);

    /* -------------------------------------------------------------------------- */
    /*                                    Admin                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Updates the max leverage a position can have.
     * @dev `newMaxLeverage` must be between the min and max leverage of the USDN protocol.
     * This function can only be called by the owner of the contract.
     * @param newMaxLeverage The new max leverage.
     */
    function setPositionMaxLeverage(uint256 newMaxLeverage) external;

    /**
     * @notice Sets the various time limits in seconds.
     * @dev This function can only be called by the owner of the contract.
     * @param validationDelay The amount of time to wait before an initiate can be validated.
     * @param validationDeadline The amount of time a user has to validate an initiate.
     * @param actionCooldown The amount of time to wait after the deadline has passed before trying again.
     * @param closeDelay The close delay that will be applied to the next long position opening.
     */
    function setTimeLimits(uint64 validationDelay, uint64 validationDeadline, uint64 actionCooldown, uint64 closeDelay)
        external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Rebalancer Errors
 * @notice Defines all custom errors thrown by the Rebalancer contract.
 */
interface IRebalancerErrors {
    /// @dev The user's assets are not used in a position.
    error RebalancerUserPending();

    /// @dev The user's assets were in a position that has been liquidated.
    error RebalancerUserLiquidated();

    /// @dev The `to` address is invalid.
    error RebalancerInvalidAddressTo();

    /// @dev The amount of assets is invalid.
    error RebalancerInvalidAmount();

    /// @dev The amount to deposit is insufficient.
    error RebalancerInsufficientAmount();

    /// @dev The given maximum leverage is invalid.
    error RebalancerInvalidMaxLeverage();

    /// @dev The given minimum asset deposit is invalid.
    error RebalancerInvalidMinAssetDeposit();

    /// @dev The given time limits are invalid.
    error RebalancerInvalidTimeLimits();

    /// @dev The caller is not authorized to perform the action.
    error RebalancerUnauthorized();

    /// @dev The user can't initiate or validate a deposit at this time.
    error RebalancerDepositUnauthorized();

    /// @dev The user must validate their deposit or withdrawal.
    error RebalancerActionNotValidated();

    /// @dev The user has no pending deposit or withdrawal requiring validation.
    error RebalancerNoPendingAction();

    /// @dev Ton was attempted too early, the user must wait for `_timeLimits.validationDelay`.
    error RebalancerValidateTooEarly();

    /// @dev Ton was attempted too late, the user must wait for `_timeLimits.actionCooldown`.
    error RebalancerActionCooldown();

    /// @dev The user can't initiate or validate a withdrawal at this time.
    error RebalancerWithdrawalUnauthorized();

    /// @dev The address was unable to accept the Ether refund.
    error RebalancerEtherRefundFailed();

    /// @dev The signature provided for delegation is invalid.
    error RebalancerInvalidDelegationSignature();

    /**
     * @dev The user can't initiate a close position until the given timestamp has passed.
     * @param closeLockedUntil The timestamp until which the user must wait to perform a close position action.
     */
    error RebalancerCloseLockedUntil(uint256 closeLockedUntil);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes as Types } from "../../interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";

/**
 * @title Rebalancer Events
 * @notice Defines all custom events emitted by the Rebalancer contract.
 */
interface IRebalancerEvents {
    /**
     * @notice A user initiates a deposit into the Rebalancer.
     * @param payer The address of the user initiating the deposit.
     * @param to The address the assets will be assigned to.
     * @param amount The amount of assets deposited.
     * @param timestamp The timestamp of the action.
     */
    event InitiatedAssetsDeposit(address indexed payer, address indexed to, uint256 amount, uint256 timestamp);

    /**
     * @notice Assets are successfully deposited into the contract.
     * @param user The address of the user.
     * @param amount The amount of assets deposited.
     * @param positionVersion The version of the position in which the assets will be used.
     */
    event AssetsDeposited(address indexed user, uint256 amount, uint256 positionVersion);

    /**
     * @notice A deposit is refunded after failing to meet the validation deadline.
     * @param user The address of the user.
     * @param amount The amount of assets refunded.
     */
    event DepositRefunded(address indexed user, uint256 amount);

    /**
     * @notice A user initiates the withdrawal of their pending assets.
     * @param user The address of the user.
     */
    event InitiatedAssetsWithdrawal(address indexed user);

    /**
     * @notice Pending assets are withdrawn from the contract.
     * @param user The original owner of the position.
     * @param to The address the assets are sent to.
     * @param amount The amount of assets withdrawn.
     */
    event AssetsWithdrawn(address indexed user, address indexed to, uint256 amount);

    /**
     * @notice A user initiates a close position action through the rebalancer.
     * @param user The address of the rebalancer user.
     * @param rebalancerAmountToClose The amount of rebalancer assets to close.
     * @param amountToClose The amount to close, taking into account the previous versions PnL.
     * @param rebalancerAmountRemaining The remaining rebalancer assets of the user.
     */
    event ClosePositionInitiated(
        address indexed user, uint256 rebalancerAmountToClose, uint256 amountToClose, uint256 rebalancerAmountRemaining
    );

    /**
     * @notice The maximum leverage is updated.
     * @param newMaxLeverage The updated value for the maximum leverage.
     */
    event PositionMaxLeverageUpdated(uint256 newMaxLeverage);

    /**
     * @notice The minimum asset deposit requirement is updated.
     * @param minAssetDeposit The updated minimum amount of assets to be deposited by a user.
     */
    event MinAssetDepositUpdated(uint256 minAssetDeposit);

    /**
     * @notice The position version is updated.
     * @param newPositionVersion The updated version of the position.
     * @param entryAccMultiplier The accumulated multiplier at the opening of the new version.
     * @param amount The amount of assets injected into the position as collateral by the rebalancer.
     * @param positionId The ID of the new position in the USDN protocol.
     */
    event PositionVersionUpdated(
        uint128 newPositionVersion, uint256 entryAccMultiplier, uint128 amount, Types.PositionId positionId
    );

    /**
     * @notice Time limits are updated.
     * @param validationDelay The updated validation delay.
     * @param validationDeadline The updated validation deadline.
     * @param actionCooldown The updated action cooldown.
     * @param closeDelay The updated close delay.
     */
    event TimeLimitsUpdated(
        uint256 validationDelay, uint256 validationDeadline, uint256 actionCooldown, uint256 closeDelay
    );
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Rebalancer Types
 * @notice Defines all custom types used by the Rebalancer contract.
 */
interface IRebalancerTypes {
    /**
     * @notice Represents the deposit data of a user.
     * @dev A value of zero for `initiateTimestamp` indicates that the deposit or withdrawal has been validated.
     * @param initiateTimestamp The timestamp when the deposit or withdrawal was initiated.
     * @param amount The amount of assets deposited by the user.
     * @param entryPositionVersion The version of the position the user entered.
     */
    struct UserDeposit {
        uint40 initiateTimestamp;
        uint88 amount; // maximum 309'485'009 tokens with 18 decimals
        uint128 entryPositionVersion;
    }

    /**
     * @notice Represents data for a specific version of a position.
     * @dev The difference between `amount` here and the amount saved in the USDN protocol is the liquidation bonus.
     * @param amount The amount of assets used as collateral to open the position.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position in the tick list.
     * @param entryAccMultiplier The accumulated PnL multiplier of all positions up to this one.
     */
    struct PositionData {
        uint128 amount;
        int24 tick;
        uint256 tickVersion;
        uint256 index;
        uint256 entryAccMultiplier;
    }

    /**
     * @notice Defines parameters related to the validation process for rebalancer deposits and withdrawals.
     * @dev If `validationDeadline` has passed, the user must wait until the cooldown duration has elapsed. Then, for
     * deposit actions, the user must retrieve its funds using {IRebalancer.resetDepositAssets}. For withdrawal actions,
     * the user can simply initiate a new withdrawal.
     * @param validationDelay The minimum duration in seconds between an initiate action and the corresponding validate
     * action.
     * @param validationDeadline The maximum duration in seconds between an initiate action and the corresponding
     * validate action.
     * @param actionCooldown The duration in seconds from the initiate action during which the user can't interact with
     * the rebalancer if the `validationDeadline` is exceeded.
     * @param closeDelay The Duration in seconds from the last rebalancer long position opening during which the user
     * can't perform an {IRebalancer.initiateClosePosition}.
     */
    struct TimeLimits {
        uint64 validationDelay;
        uint64 validationDeadline;
        uint64 actionCooldown;
        uint64 closeDelay;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IRebaseCallback {
    /**
     * @notice Called by the USDN token after a rebase has happened.
     * @param oldDivisor The value of the divisor before the rebase.
     * @param newDivisor The value of the divisor after the rebase (necessarily smaller than `oldDivisor`).
     * @return result_ Arbitrary data that will be forwarded to the caller of `rebase`.
     */
    function rebaseCallback(uint256 oldDivisor, uint256 newDivisor) external returns (bytes memory result_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import { IRebaseCallback } from "./IRebaseCallback.sol";
import { IUsdnErrors } from "./IUsdnErrors.sol";
import { IUsdnEvents } from "./IUsdnEvents.sol";

/**
 * @title USDN token interface
 * @notice Implements the ERC-20 token standard as well as the EIP-2612 permit extension. Additional functions related
 * to the specifics of this token are included below.
 */
interface IUsdn is IERC20, IERC20Metadata, IERC20Permit, IUsdnEvents, IUsdnErrors {
    /**
     * @notice Returns the total number of shares in existence.
     * @return shares_ The number of shares.
     */
    function totalShares() external view returns (uint256 shares_);

    /**
     * @notice Returns the number of shares owned by `account`.
     * @param account The account to query.
     * @return shares_ The number of shares.
     */
    function sharesOf(address account) external view returns (uint256 shares_);

    /**
     * @notice Transfers a given amount of shares from the `msg.sender` to `to`.
     * @param to Recipient of the shares.
     * @param value Number of shares to transfer.
     * @return success_ Indicates whether the transfer was successfully executed.
     */
    function transferShares(address to, uint256 value) external returns (bool success_);

    /**
     * @notice Transfers a given amount of shares from the `from` to `to`.
     * @dev There should be sufficient allowance for the spender. Be mindful of the rebase logic. The allowance is in
     * tokens. So, after a rebase, the same amount of shares will be worth a higher amount of tokens. In that case,
     * the allowance of the initial approval will not be enough to transfer the new amount of tokens. This can
     * also happen when your transaction is in the mempool and the rebase happens before your transaction. Also note
     * that the amount of tokens deduced from the allowance is rounded up, so the `convertToTokensRoundUp` function
     * should be used when converting shares into an allowance value.
     * @param from The owner of the shares.
     * @param to Recipient of the shares.
     * @param value Number of shares to transfer.
     * @return success_ Indicates whether the transfer was successfully executed.
     */
    function transferSharesFrom(address from, address to, uint256 value) external returns (bool success_);

    /**
     * @notice Mints new shares, providing a token value.
     * @dev Caller must have the MINTER_ROLE.
     * @param to Account to receive the new shares.
     * @param amount Amount of tokens to mint, is internally converted to the proper shares amounts.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Mints new shares, providing a share value.
     * @dev Caller must have the MINTER_ROLE.
     * @param to Account to receive the new shares.
     * @param amount Amount of shares to mint.
     * @return mintedTokens_ Amount of tokens that were minted (informational).
     */
    function mintShares(address to, uint256 amount) external returns (uint256 mintedTokens_);

    /**
     * @notice Destroys a `value` amount of tokens from the caller, reducing the total supply.
     * @param value Amount of tokens to burn, is internally converted to the proper shares amounts.
     */
    function burn(uint256 value) external;

    /**
     * @notice Destroys a `value` amount of tokens from `account`, deducting from the caller's allowance.
     * @param account Account to burn tokens from.
     * @param value Amount of tokens to burn, is internally converted to the proper shares amounts.
     */
    function burnFrom(address account, uint256 value) external;

    /**
     * @notice Destroys a `value` amount of shares from the caller, reducing the total supply.
     * @param value Amount of shares to burn.
     */
    function burnShares(uint256 value) external;

    /**
     * @notice Destroys a `value` amount of shares from `account`, deducting from the caller's allowance.
     * @dev There should be sufficient allowance for the spender. Be mindful of the rebase logic. The allowance is in
     * tokens. So, after a rebase, the same amount of shares will be worth a higher amount of tokens. In that case,
     * the allowance of the initial approval will not be enough to transfer the new amount of tokens. This can
     * also happen when your transaction is in the mempool and the rebase happens before your transaction. Also note
     * that the amount of tokens deduced from the allowance is rounded up, so the `convertToTokensRoundUp` function
     * should be used when converting shares into an allowance value.
     * @param account Account to burn shares from.
     * @param value Amount of shares to burn.
     */
    function burnSharesFrom(address account, uint256 value) external;

    /**
     * @notice Converts a number of tokens to the corresponding amount of shares.
     * @dev The conversion reverts with `UsdnMaxTokensExceeded` if the corresponding amount of shares overflows.
     * @param amountTokens The amount of tokens to convert to shares.
     * @return shares_ The corresponding amount of shares.
     */
    function convertToShares(uint256 amountTokens) external view returns (uint256 shares_);

    /**
     * @notice Converts a number of shares to the corresponding amount of tokens.
     * @dev The conversion never overflows as we are performing a division. The conversion rounds to the nearest amount
     * of tokens that minimizes the error when converting back to shares.
     * @param amountShares The amount of shares to convert to tokens.
     * @return tokens_ The corresponding amount of tokens.
     */
    function convertToTokens(uint256 amountShares) external view returns (uint256 tokens_);

    /**
     * @notice Converts a number of shares to the corresponding amount of tokens, rounding up.
     * @dev Use this function to determine the amount of a token approval, as we always round up when deducting from
     * a token transfer allowance.
     * @param amountShares The amount of shares to convert to tokens.
     * @return tokens_ The corresponding amount of tokens, rounded up.
     */
    function convertToTokensRoundUp(uint256 amountShares) external view returns (uint256 tokens_);

    /**
     * @notice Returns the current maximum tokens supply, given the current divisor.
     * @dev This function is used to check if a conversion operation would overflow.
     * @return maxTokens_ The maximum number of tokens that can exist.
     */
    function maxTokens() external view returns (uint256 maxTokens_);

    /**
     * @notice Decreases the global divisor, which effectively grows all balances and the total supply.
     * @dev If the provided divisor is larger than or equal to the current divisor value, no rebase will happen
     * If the new divisor is smaller than `MIN_DIVISOR`, the value will be clamped to `MIN_DIVISOR`.
     * Caller must have the `REBASER_ROLE`.
     * @param newDivisor The new divisor, should be strictly smaller than the current one and greater or equal to
     * `MIN_DIVISOR`.
     * @return rebased_ Whether a rebase happened.
     * @return oldDivisor_ The previous value of the divisor.
     * @return callbackResult_ The result of the callback, if a rebase happened and a callback handler is defined.
     */
    function rebase(uint256 newDivisor)
        external
        returns (bool rebased_, uint256 oldDivisor_, bytes memory callbackResult_);

    /**
     * @notice Sets the rebase handler address.
     * @dev Emits a `RebaseHandlerUpdated` event.
     * If set to the zero address, no handler will be called after a rebase.
     * Caller must have the `DEFAULT_ADMIN_ROLE`.
     * @param newHandler The new handler address.
     */
    function setRebaseHandler(IRebaseCallback newHandler) external;

    /* -------------------------------------------------------------------------- */
    /*                             Dev view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Gets the current value of the divisor that converts between tokens and shares.
     * @return divisor_ The current divisor.
     */
    function divisor() external view returns (uint256 divisor_);

    /**
     * @notice Gets the rebase handler address, which is called whenever a rebase happens.
     * @return rebaseHandler_ The rebase handler address.
     */
    function rebaseHandler() external view returns (IRebaseCallback rebaseHandler_);

    /**
     * @notice Gets the minter role signature.
     * @return minter_role_ The role signature.
     */
    function MINTER_ROLE() external pure returns (bytes32 minter_role_);

    /**
     * @notice Gets the rebaser role signature.
     * @return rebaser_role_ The role signature.
     */
    function REBASER_ROLE() external pure returns (bytes32 rebaser_role_);

    /**
     * @notice Gets the maximum value of the divisor, which is also the initial value.
     * @return maxDivisor_ The maximum divisor.
     */
    function MAX_DIVISOR() external pure returns (uint256 maxDivisor_);

    /**
     * @notice Gets the minimum acceptable value of the divisor.
     * @dev The minimum divisor that can be set. This corresponds to a growth of 1B times. Technically, 1e5 would still
     * work without precision errors.
     * @return minDivisor_ The minimum divisor.
     */
    function MIN_DIVISOR() external pure returns (uint256 minDivisor_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Errors for the USDN token contract
 * @notice Defines all custom errors emitted by the USDN token contract.
 */
interface IUsdnErrors {
    /**
     * @dev The amount of tokens exceeds the maximum allowed limit.
     * @param value The invalid token value.
     */
    error UsdnMaxTokensExceeded(uint256 value);

    /**
     * @dev The sender's share balance is insufficient.
     * @param sender The sender's address.
     * @param balance The current share balance of the sender.
     * @param needed The required amount of shares for the transfer.
     */
    error UsdnInsufficientSharesBalance(address sender, uint256 balance, uint256 needed);

    /// @dev The divisor value in storage is invalid (< 1).
    error UsdnInvalidDivisor();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IRebaseCallback } from "./IRebaseCallback.sol";

/**
 * @title Events for the USDN token contract
 * @notice Defines all custom events emitted by the USDN token contract.
 */
interface IUsdnEvents {
    /**
     * @notice The divisor was updated, emitted during a rebase.
     * @param oldDivisor The divisor value before the rebase.
     * @param newDivisor The new divisor value.
     */
    event Rebase(uint256 oldDivisor, uint256 newDivisor);

    /**
     * @notice The rebase handler address was updated.
     * @dev The rebase handler is a contract that is called when a rebase occurs.
     * @param newHandler The address of the new rebase handler contract.
     */
    event RebaseHandlerUpdated(IRebaseCallback newHandler);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

import { IUsdn } from "./IUsdn.sol";
import { IWusdnErrors } from "./IWusdnErrors.sol";
import { IWusdnEvents } from "./IWusdnEvents.sol";

/**
 * @title Wusdn Interface
 * @notice Interface for the Wrapped Ultimate Synthetic Delta Neutral (WUSDN) token.
 */
interface IWusdn is IERC20Metadata, IERC20Permit, IWusdnEvents, IWusdnErrors {
    /**
     * @notice Returns the address of the USDN token.
     * @return The address of the USDN token.
     */
    function USDN() external view returns (IUsdn);

    /**
     * @notice Returns the ratio used to convert USDN shares to WUSDN amounts.
     * @dev This ratio is initialized in the constructor based on the maximum divisor of the USDN token.
     * @return The conversion ratio between USDN shares and WUSDN amounts.
     */
    function SHARES_RATIO() external view returns (uint256);

    /**
     * @notice Wraps a given amount of USDN into WUSDN.
     * @dev This function may use slightly less than `usdnAmount` due to rounding errors.
     * For a more precise operation, use {wrapShares}.
     * @param usdnAmount The amount of USDN to wrap.
     * @return wrappedAmount_ The amount of WUSDN received.
     */
    function wrap(uint256 usdnAmount) external returns (uint256 wrappedAmount_);

    /**
     * @notice Wraps a given amount of USDN into WUSDN and sends it to a specified address.
     * @dev This function may use slightly less than `usdnAmount` due to rounding errors.
     * For a more precise operation, use {wrapShares}.
     * @param usdnAmount The amount of USDN to wrap.
     * @param to The address to receive the WUSDN.
     * @return wrappedAmount_ The amount of WUSDN received.
     */
    function wrap(uint256 usdnAmount, address to) external returns (uint256 wrappedAmount_);

    /**
     * @notice Wraps a given amount of USDN shares into WUSDN and sends it to a specified address.
     * @param usdnShares The amount of USDN shares to wrap.
     * @param to The address to receive the WUSDN.
     * @return wrappedAmount_ The amount of WUSDN received.
     */
    function wrapShares(uint256 usdnShares, address to) external returns (uint256 wrappedAmount_);

    /**
     * @notice Unwraps a given amount of WUSDN into USDN.
     * @param wusdnAmount The amount of WUSDN to unwrap.
     * @return usdnAmount_ The amount of USDN received.
     */
    function unwrap(uint256 wusdnAmount) external returns (uint256 usdnAmount_);

    /**
     * @notice Unwraps a given amount of WUSDN into USDN and sends it to a specified address.
     * @param wusdnAmount The amount of WUSDN to unwrap.
     * @param to The address to receive the USDN.
     * @return usdnAmount_ The amount of USDN received.
     */
    function unwrap(uint256 wusdnAmount, address to) external returns (uint256 usdnAmount_);

    /**
     * @notice Computes the amount of WUSDN that would be received for a given amount of USDN.
     * @dev The actual amount received may differ slightly due to rounding errors.
     * For a precise value, use {previewWrapShares}.
     * @param usdnAmount The amount of USDN to wrap.
     * @return wrappedAmount_ The estimated amount of WUSDN that would be received.
     */
    function previewWrap(uint256 usdnAmount) external view returns (uint256 wrappedAmount_);

    /**
     * @notice Computes the amount of WUSDN that would be received for a given amount of USDN shares.
     * @param usdnShares The amount of USDN shares to wrap.
     * @return wrappedAmount_ The amount of WUSDN that would be received.
     */
    function previewWrapShares(uint256 usdnShares) external view returns (uint256 wrappedAmount_);

    /**
     * @notice Returns the exchange rate between WUSDN and USDN.
     * @return usdnAmount_ The amount of USDN that corresponds to 1 WUSDN.
     */
    function redemptionRate() external view returns (uint256 usdnAmount_);

    /**
     * @notice Computes the amount of USDN that would be received for a given amount of WUSDN.
     * @dev The actual amount received may differ slightly due to rounding errors.
     * For a precise value, use {previewUnwrapShares}.
     * @param wusdnAmount The amount of WUSDN to unwrap.
     * @return usdnAmount_ The estimated amount of USDN that would be received.
     */
    function previewUnwrap(uint256 wusdnAmount) external view returns (uint256 usdnAmount_);

    /**
     * @notice Computes the amount of USDN shares that would be received for a given amount of WUSDN.
     * @param wusdnAmount The amount of WUSDN to unwrap.
     * @return usdnSharesAmount_ The amount of USDN shares that would be received.
     */
    function previewUnwrapShares(uint256 wusdnAmount) external view returns (uint256 usdnSharesAmount_);

    /**
     * @notice Returns the total amount of USDN held by the contract.
     * @return The total amount of USDN held by the contract.
     */
    function totalUsdnBalance() external view returns (uint256);

    /**
     * @notice Returns the total amount of USDN shares held by the contract.
     * @return The total amount of USDN shares held by the contract.
     */
    function totalUsdnShares() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Errors For The WUSDN Token Contract
 * @notice Defines all custom errors emitted by the WUSDN token contract.
 */
interface IWusdnErrors {
    /**
     * @dev The user has insufficient USDN balance to wrap the given `usdnAmount`.
     * @param usdnAmount The amount of USDN the user attempted to wrap.
     */
    error WusdnInsufficientBalance(uint256 usdnAmount);

    /**
     * @dev The user is attempting to wrap an amount of USDN shares that is lower than the minimum:
     * {IWusdn.SHARES_RATIO}, required by the WUSDN token. This results in a wrapped amount of zero WUSDN.
     */
    error WusdnWrapZeroAmount();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Events for the WUSDN Token Contract
 * @notice Defines all custom events emitted by the WUSDN token contract.
 */
interface IWusdnEvents {
    /**
     * @notice The user wrapped USDN to mint WUSDN tokens.
     * @param from The address of the user who wrapped the USDN.
     * @param to The address of the recipient who received the WUSDN tokens.
     * @param usdnAmount The amount of USDN tokens wrapped.
     * @param wusdnAmount The amount of WUSDN tokens minted.
     */
    event Wrap(address indexed from, address indexed to, uint256 usdnAmount, uint256 wusdnAmount);

    /**
     * @notice The user unwrapped WUSDN tokens to redeem USDN.
     * @param from The address of the user who unwrapped the WUSDN tokens.
     * @param to The address of the recipient who received the USDN tokens.
     * @param wusdnAmount The amount of WUSDN tokens unwrapped.
     * @param usdnAmount The amount of USDN tokens redeemed.
     */
    event Unwrap(address indexed from, address indexed to, uint256 wusdnAmount, uint256 usdnAmount);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IUsdn } from "../Usdn/IUsdn.sol";

/**
 * @notice This interface can be implemented by contracts that wish to transfer tokens during initiate actions.
 * @dev The contract must implement the ERC-165 interface detection mechanism.
 */
interface IPaymentCallback is IERC165 {
    /**
     * @notice Triggered by the USDN protocol to transfer asset tokens during `initiate` actions.
     * @dev Implementations must ensure that the `msg.sender` is the USDN protocol for security purposes.
     * @param token The address of the ERC20 token to be transferred.
     * @param amount The amount of tokens to transfer.
     * @param to The recipient's address.
     */
    function transferCallback(IERC20Metadata token, uint256 amount, address to) external;

    /**
     * @notice Triggered by the USDN protocol during the {IUsdnProtocolActions.initiateWithdrawal} process to transfer
     * USDN shares.
     * @dev Implementations must verify that the `msg.sender` is the USDN protocol.
     * @param usdn The address of the USDN protocol.
     * @param shares The number of USDN shares to transfer to the protocol (`msg.sender`).
     */
    function usdnTransferCallback(IUsdn usdn, uint256 shares) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolFallback } from "./IUsdnProtocolFallback.sol";
import { IUsdnProtocolImpl } from "./IUsdnProtocolImpl.sol";

/**
 * @title IUsdnProtocol
 * @notice Interface for the USDN protocol and fallback.
 */
interface IUsdnProtocol is IUsdnProtocolImpl, IUsdnProtocolFallback {
    /**
     * @notice Upgrades the protocol to a new implementation (check
     * [UUPSUpgradeable](https://docs.openzeppelin.com/contracts/5.x/api/proxy#UUPSUpgradeable)).
     * @dev This function should be called by the role with the PROXY_UPGRADE_ROLE.
     * @param newImplementation The address of the new implementation.
     * @param data The data to call when upgrading to the new implementation. Passing in empty data skips the
     * delegatecall to `newImplementation`.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes } from "./IUsdnProtocolTypes.sol";

/**
 * @title IUsdnProtocolActions
 * @notice Interface for the USDN Protocol Actions.
 */
interface IUsdnProtocolActions is IUsdnProtocolTypes {
    /**
     * @notice Initiates an open position action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * Requires `_securityDepositValue` to be included in the transaction value. In case of pending liquidations, this
     * function will not initiate the position (`isInitiated_` would be false).
     * The user's input for price and leverage is not guaranteed due to the price difference between the initiate and
     * validate actions.
     * @param amount The amount of assets to deposit.
     * @param desiredLiqPrice The desired liquidation price, including the penalty.
     * @param userMaxPrice The user's wanted maximum price at which the position can be opened.
     * @param userMaxLeverage The user's wanted maximum leverage for the new position.
     * @param to The address that will owns of the position.
     * @param validator The address that is supposed to validate the opening and receive the security deposit. If not
     * an EOA, it must be a contract that implements a `receive` function.
     * @param deadline The deadline for initiating the open position.
     * @param currentPriceData The price data used for temporary leverage and entry price computations.
     * @param previousActionsData The data needed to validate actionable pending actions.
     * @return isInitiated_ Whether the position was successfully initiated. If false, the security deposit was refunded
     * @return posId_ The unique position identifier. If the position was not initiated, the tick number will be
     * `NO_POSITION_TICK`.
     */
    function initiateOpenPosition(
        uint128 amount,
        uint128 desiredLiqPrice,
        uint128 userMaxPrice,
        uint256 userMaxLeverage,
        address to,
        address payable validator,
        uint256 deadline,
        bytes calldata currentPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (bool isInitiated_, PositionId memory posId_);

    /**
     * @notice Validates a pending open position action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * It is possible for this operation to change the tick, tick version and index of the position, in which case we  emit
     * the `LiquidationPriceUpdated` event.
     * This function always sends the security deposit to the validator. So users wanting to earn the corresponding
     * security deposit must use `validateActionablePendingActions`.
     * In case liquidations are pending (`outcome_ == LongActionOutcome.PendingLiquidations`), the pending action will
     * not be removed from the queue, and the user will have to try again.
     * In case the position was liquidated by this call (`outcome_ == LongActionOutcome.Liquidated`), this function will
     * refund the security deposit and remove the pending action from the queue.
     * @param validator The address associated with the pending open position. If not an EOA, it must be a contract that
     * implements a `receive` function.
     * @param openPriceData The price data for the pending open position.
     * @param previousActionsData The data needed to validate actionable pending actions.
     * @return outcome_ The effect on the pending action (processed, liquidated, or pending liquidations).
     * @return posId_ The position ID after validation (or `NO_POSITION_TICK` if liquidated).
     */
    function validateOpenPosition(
        address payable validator,
        bytes calldata openPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (LongActionOutcome outcome_, PositionId memory posId_);

    /**
     * @notice Initiates a close position action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * Requires `_securityDepositValue` to be included in the transaction value.
     * If the current tick version is greater than the tick version of the position (when it was opened), then the
     * position has been liquidated and the transaction will revert.
     * In case liquidations are pending (`outcome_ == LongActionOutcome.PendingLiquidations`), the pending action will
     * not be removed from the queue, and the user will have to try again.
     * In case the position was liquidated by this call (`outcome_ == LongActionOutcome.Liquidated`), this function will
     * refund the security deposit and remove the pending action from the queue.
     * The user's input for the price is not guaranteed due to the price difference between the initiate and validate
     * actions.
     * @param posId The unique identifier of the position to close.
     * @param amountToClose The amount of collateral to remove.
     * @param userMinPrice The user's wanted minimum price for closing the position.
     * @param to The address that will receive the assets.
     * @param validator The address that is supposed to validate the closing and receive the security deposit. If not an
     * EOA, it must be a contract that implements a `receive` function.
     * @param deadline The deadline for initiating the close position.
     * @param currentPriceData The price data for temporary calculations.
     * @param previousActionsData The data needed to validate actionable pending actions.
     * @param delegationSignature Optional EIP712 signature for delegated action.
     * @return outcome_ The effect on the pending action (processed, liquidated, or pending liquidations).
     */
    function initiateClosePosition(
        PositionId calldata posId,
        uint128 amountToClose,
        uint256 userMinPrice,
        address to,
        address payable validator,
        uint256 deadline,
        bytes calldata currentPriceData,
        PreviousActionsData calldata previousActionsData,
        bytes calldata delegationSignature
    ) external payable returns (LongActionOutcome outcome_);

    /**
     * @notice Validates a pending close position action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * This function calculates the final exit price, determines the profit of the long position, and performs the
     * payout.
     * This function always sends the security deposit to the validator. So users wanting to earn the corresponding
     * security deposit must use `validateActionablePendingActions`.
     * In case liquidations are pending (`outcome_ == LongActionOutcome.PendingLiquidations`),
     * the pending action will not be removed from the queue, and the user will have to try again.
     * In case the position was liquidated by this call (`outcome_ == LongActionOutcome.Liquidated`),
     * this function will refund the security deposit and remove the pending action from the queue.
     * @param validator The address associated with the pending close position. If not an EOA, it must be a contract
     * that implements a `receive` function.
     * @param closePriceData The price data for the pending close position action.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @return outcome_ The outcome of the action (processed, liquidated, or pending liquidations).
     */
    function validateClosePosition(
        address payable validator,
        bytes calldata closePriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (LongActionOutcome outcome_);

    /**
     * @notice Initiates a deposit of assets into the vault to mint USDN.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * Requires `_securityDepositValue` to be included in the transaction value.
     * In case liquidations are pending, this function might not initiate the deposit, and `success_` would be false.
     * The user's input for the shares is not guaranteed due to the price difference between the initiate and validate
     * actions.
     * @param amount The amount of assets to deposit.
     * @param sharesOutMin The minimum amount of USDN shares to receive.
     * @param to The address that will receive the USDN tokens.
     * @param validator The address that is supposed to validate the deposit and receive the security deposit. If not an
     * EOA, it must be a contract that implements a `receive` function.
     * @param deadline The deadline for initiating the deposit.
     * @param currentPriceData The current price data.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @return success_ Indicates whether the deposit was successfully initiated.
     */
    function initiateDeposit(
        uint128 amount,
        uint256 sharesOutMin,
        address to,
        address payable validator,
        uint256 deadline,
        bytes calldata currentPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (bool success_);

    /**
     * @notice Validates a pending deposit action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * This function always sends the security deposit to the validator. So users wanting to earn the corresponding
     * security deposit must use `validateActionablePendingActions`.
     * If liquidations are pending, the validation may fail, and `success_` would be false.
     * @param validator The address associated with the pending deposit action. If not an EOA, it must be a contract
     * that implements a `receive` function.
     * @param depositPriceData The price data for the pending deposit action.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @return success_ Indicates whether the deposit was successfully validated.
     */
    function validateDeposit(
        address payable validator,
        bytes calldata depositPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (bool success_);

    /**
     * @notice Initiates a withdrawal of assets from the vault using USDN tokens.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * Requires `_securityDepositValue` to be included in the transaction value.
     * Note that in case liquidations are pending, this function might not initiate the withdrawal, and `success_` would
     * be false.
     * The user's input for the minimum amount is not guaranteed due to the price difference between the initiate and
     * validate actions.
     * @param usdnShares The amount of USDN shares to burn.
     * @param amountOutMin The minimum amount of assets to receive.
     * @param to The address that will receive the assets.
     * @param validator The address that is supposed to validate the withdrawal and receive the security deposit. If not
     * an EOA, it must be a contract that implements a `receive` function.
     * @param deadline The deadline for initiating the withdrawal.
     * @param currentPriceData The current price data.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @return success_ Indicates whether the withdrawal was successfully initiated.
     */
    function initiateWithdrawal(
        uint152 usdnShares,
        uint256 amountOutMin,
        address to,
        address payable validator,
        uint256 deadline,
        bytes calldata currentPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (bool success_);

    /**
     * @notice Validates a pending withdrawal action.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * This function always sends the security deposit to the validator. So users wanting to earn the corresponding
     * security deposit must use `validateActionablePendingActions`.
     * In case liquidations are pending, this function might not validate the withdrawal, and `success_` would be false.
     * @param validator The address associated with the pending withdrawal action. If not an EOA, it must be a contract
     * that implements a `receive` function.
     * @param withdrawalPriceData The price data for the pending withdrawal action.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @return success_ Indicates whether the withdrawal was successfully validated.
     */
    function validateWithdrawal(
        address payable validator,
        bytes calldata withdrawalPriceData,
        PreviousActionsData calldata previousActionsData
    ) external payable returns (bool success_);

    /**
     * @notice Liquidates positions based on the provided asset price.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * Each tick is liquidated in constant time. The tick version is incremented for each liquidated tick.
     * @param currentPriceData The price data.
     * @return liquidatedTicks_ Information about the liquidated ticks.
     */
    function liquidate(bytes calldata currentPriceData)
        external
        payable
        returns (LiqTickInfo[] memory liquidatedTicks_);

    /**
     * @notice Manually validates actionable pending actions.
     * @dev Consult the current oracle middleware for price data format and possible oracle fee.
     * The timestamp for each pending action is calculated by adding the `OracleMiddleware.validationDelay` to its
     * initiation timestamp.
     * @param previousActionsData The data required to validate actionable pending actions.
     * @param maxValidations The maximum number of actionable pending actions to validate. At least one validation will
     * be performed.
     * @return validatedActions_ The number of successfully validated actions.
     */
    function validateActionablePendingActions(PreviousActionsData calldata previousActionsData, uint256 maxValidations)
        external
        payable
        returns (uint256 validatedActions_);

    /**
     * @notice Transfers the ownership of a position to another address.
     * @dev This function reverts if the caller is not the position owner, if the position does not exist, or if the new
     * owner's address is the zero address.
     * If the new owner is a contract that implements the `IOwnershipCallback` interface, its `ownershipCallback`
     * function will be invoked after the transfer.
     * @param posId The unique identifier of the position.
     * @param newOwner The address of the new position owner.
     * @param delegationSignature An optional EIP712 signature to authorize the transfer on the owner's behalf.
     */
    function transferPositionOwnership(PositionId calldata posId, address newOwner, bytes calldata delegationSignature)
        external;

    /**
     * @notice Retrieves the domain separator used in EIP-712 signatures.
     * @return domainSeparatorV4_ The domain separator compliant with EIP-712.
     */
    function domainSeparatorV4() external view returns (bytes32 domainSeparatorV4_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title IUsdnProtocolCore
 * @notice Interface for the core layer of the USDN protocol.
 */
interface IUsdnProtocolCore {
    /**
     * @notice Computes the predicted funding value since the last state update for the specified timestamp.
     * @dev The funding value, when multiplied by the long trading exposure, represents the asset balance to be
     * transferred to the vault side, or to the long side if the value is negative.
     * Reverts with `UsdnProtocolTimestampTooOld` if the given timestamp is older than the last state update.
     * @param timestamp The timestamp to use for the computation.
     * @return funding_ The funding magnitude (with `FUNDING_RATE_DECIMALS` decimals) since the last update timestamp.
     * @return fundingPerDay_ The funding rate per day (with `FUNDING_RATE_DECIMALS` decimals).
     * @return oldLongExpo_ The long trading exposure recorded at the last state update.
     */
    function funding(uint128 timestamp)
        external
        view
        returns (int256 funding_, int256 fundingPerDay_, int256 oldLongExpo_);

    /**
     * @notice Initializes the protocol by making an initial deposit and creating the first long position.
     * @dev This function can only be called once. No other user actions can be performed until the protocol
     * is initialized.
     * @param depositAmount The amount of assets to deposit.
     * @param longAmount The amount of assets for the long position.
     * @param desiredLiqPrice The desired liquidation price for the long position, excluding the liquidation penalty.
     * @param currentPriceData The encoded current price data.
     */
    function initialize(
        uint128 depositAmount,
        uint128 longAmount,
        uint128 desiredLiqPrice,
        bytes calldata currentPriceData
    ) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { HugeUint } from "@smardex-solidity-libraries-1/HugeUint.sol";

import { IBaseLiquidationRewardsManager } from "../LiquidationRewardsManager/IBaseLiquidationRewardsManager.sol";
import { IBaseOracleMiddleware } from "../OracleMiddleware/IBaseOracleMiddleware.sol";
import { IBaseRebalancer } from "../Rebalancer/IBaseRebalancer.sol";
import { IUsdn } from "../Usdn/IUsdn.sol";
import { IUsdnProtocolTypes } from "./IUsdnProtocolTypes.sol";

/**
 * @title IUsdnProtocolFallback
 * @notice Interface for the USDN protocol fallback functions
 */
interface IUsdnProtocolFallback is IUsdnProtocolTypes {
    /**
     * @notice Retrieves the list of pending actions that must be validated by the next user action in the protocol.
     * @dev If this function returns a non-empty list of pending actions, then the next user action MUST include the
     * corresponding list of price update data and raw indices as the last parameter. The user that processes those
     * pending actions will receive the corresponding security deposit.
     * @param currentUser The address of the user that will submit the price signatures for third-party actions
     * validations. This is used to filter out their actions from the returned list.
     * @param lookAhead Additionally to pending actions which are actionable at this moment `block.timestamp`, the
     * function will also return pending actions which will be actionable `lookAhead` seconds later. It is recommended
     * to use a non-zero value in order to account for the interval where the validation transaction will be pending. A
     * value of 30 seconds should already account for most situations and avoid reverts in case an action becomes
     * actionable after a user submits their transaction.
     * @param maxIter The maximum number of iterations when looking through the queue to find actionable pending
     * actions. This value will be clamped to [MIN_ACTIONABLE_PENDING_ACTIONS_ITER,_pendingActionsQueue.length()].
     * @return actions_ The pending actions if any, otherwise an empty array.
     * @return rawIndices_ The raw indices of the actionable pending actions in the queue if any, otherwise an empty
     * array. Each entry corresponds to the action in the `actions_` array, at the same index.
     */
    function getActionablePendingActions(address currentUser, uint256 lookAhead, uint256 maxIter)
        external
        view
        returns (PendingAction[] memory actions_, uint128[] memory rawIndices_);

    /**
     * @notice Retrieves the pending action with `user` as the given validator.
     * @param user The user's address.
     * @return action_ The pending action if any, otherwise a struct with all fields set to zero and
     * `ProtocolAction.None`.
     */
    function getUserPendingAction(address user) external view returns (PendingAction memory action_);

    /**
     * @notice Computes the hash generated from the given tick number and version.
     * @param tick The tick number.
     * @param version The tick version.
     * @return hash_ The hash of the given tick number and version.
     */
    function tickHash(int24 tick, uint256 version) external pure returns (bytes32 hash_);

    /**
     * @notice Computes the liquidation price of the given tick number, taking into account the effects of funding.
     * @dev Uses the values from storage for the various variables. Note that ticks that are
     * not a multiple of the tick spacing cannot contain a long position.
     * @param tick The tick number.
     * @return price_ The liquidation price.
     */
    function getEffectivePriceForTick(int24 tick) external view returns (uint128 price_);

    /**
     * @notice Computes the liquidation price of the given tick number, taking into account the effects of funding.
     * @dev Uses the given values instead of the ones from the storage. Note that ticks that are not a multiple of the
     * tick spacing cannot contain a long position.
     * @param tick The tick number.
     * @param assetPrice The current/projected price of the asset.
     * @param longTradingExpo The trading exposure of the long side (total expo - balance long).
     * @param accumulator The liquidation multiplier accumulator.
     * @return price_ The liquidation price.
     */
    function getEffectivePriceForTick(
        int24 tick,
        uint256 assetPrice,
        uint256 longTradingExpo,
        HugeUint.Uint512 memory accumulator
    ) external view returns (uint128 price_);

    /**
     * @notice Computes an estimate of the amount of assets received when withdrawing.
     * @dev The result is a rough estimate and does not take into account rebases and liquidations.
     * @param usdnShares The amount of USDN shares to use in the withdrawal.
     * @param price The current/projected price of the asset.
     * @param timestamp The The timestamp corresponding to `price`.
     * @return assetExpected_ The expected amount of assets to be received.
     */
    function previewWithdraw(uint256 usdnShares, uint128 price, uint128 timestamp)
        external
        view
        returns (uint256 assetExpected_);

    /**
     * @notice Computes an estimate of USDN tokens to be minted and SDEX tokens to be burned when depositing.
     * @dev The result is a rough estimate and does not take into account rebases and liquidations.
     * @param amount The amount of assets to deposit.
     * @param price The current/projected price of the asset.
     * @param timestamp The timestamp corresponding to `price`.
     * @return usdnSharesExpected_ The amount of USDN shares to be minted.
     * @return sdexToBurn_ The amount of SDEX tokens to be burned.
     */
    function previewDeposit(uint256 amount, uint128 price, uint128 timestamp)
        external
        view
        returns (uint256 usdnSharesExpected_, uint256 sdexToBurn_);

    /**
     * @notice Refunds the security deposit to the given validator if it has a liquidated initiated long position.
     * @dev The security deposit is always sent to the validator even if the pending action is actionable.
     * @param validator The address of the validator (must be payable as it will receive some native currency).
     */
    function refundSecurityDeposit(address payable validator) external;

    /// @notice Sends the accumulated SDEX token fees to the dead address. This function can be called by anyone.
    function burnSdex() external;

    /* -------------------------------------------------------------------------- */
    /*                               Admin functions                              */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Removes a stuck pending action and performs the minimal amount of cleanup necessary.
     * @dev This function can only be called by the owner of the protocol, it serves as an escape hatch if a
     * pending action ever gets stuck due to something internal reverting unexpectedly.
     * It will not refund any fees or burned SDEX.
     * @param validator The address of the validator of the stuck pending action.
     * @param to Where the retrieved funds should be sent (security deposit, assets, usdn). Must be payable.
     */
    function removeBlockedPendingAction(address validator, address payable to) external;

    /**
     * @notice Removes a stuck pending action with no cleanup.
     * @dev This function can only be called by the owner of the protocol, it serves as an escape hatch if a
     * pending action ever gets stuck due to something internal reverting unexpectedly.
     * Always try to use `removeBlockedPendingAction` first, and only call this function if the other one fails.
     * It will not refund any fees or burned SDEX.
     * @param validator The address of the validator of the stuck pending action.
     * @param to Where the retrieved funds should be sent (security deposit, assets, usdn). Must be payable.
     */
    function removeBlockedPendingActionNoCleanup(address validator, address payable to) external;

    /**
     * @notice Removes a stuck pending action and performs the minimal amount of cleanup necessary.
     * @dev This function can only be called by the owner of the protocol, it serves as an escape hatch if a
     * pending action ever gets stuck due to something internal reverting unexpectedly.
     * It will not refund any fees or burned SDEX.
     * @param rawIndex The raw index of the stuck pending action.
     * @param to Where the retrieved funds should be sent (security deposit, assets, usdn). Must be payable.
     */
    function removeBlockedPendingAction(uint128 rawIndex, address payable to) external;

    /**
     * @notice Removes a stuck pending action with no cleanup.
     * @dev This function can only be called by the owner of the protocol, it serves as an escape hatch if a
     * pending action ever gets stuck due to something internal reverting unexpectedly.
     * Always try to use `removeBlockedPendingAction` first, and only call this function if the other one fails.
     * It will not refund any fees or burned SDEX.
     * @param rawIndex The raw index of the stuck pending action.
     * @param to Where the retrieved funds should be sent (security deposit, assets, usdn). Must be payable.
     */
    function removeBlockedPendingActionNoCleanup(uint128 rawIndex, address payable to) external;

    /* -------------------------------------------------------------------------- */
    /*                             Immutables getters                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The number of ticks between usable ticks. Only tick numbers that are a multiple of the tick spacing can
     * be used for storing long positions.
     * @dev A tick spacing of 1 is equivalent to a 0.01% increase in price between ticks. A tick spacing of 100 is.
     * equivalent to a ~1.005% increase in price between ticks.
     * @return tickSpacing_ The tick spacing.
     */
    function getTickSpacing() external view returns (int24 tickSpacing_);

    /**
     * @notice Gets the address of the protocol's underlying asset (ERC20 token).
     * @return asset_ The address of the asset token.
     */
    function getAsset() external view returns (IERC20Metadata asset_);

    /**
     * @notice Gets the address of the SDEX ERC20 token.
     * @return sdex_ The address of the SDEX token.
     */
    function getSdex() external view returns (IERC20Metadata sdex_);

    /**
     * @notice Gets the number of decimals of the asset's price feed.
     * @return decimals_ The number of decimals of the asset's price feed.
     */
    function getPriceFeedDecimals() external view returns (uint8 decimals_);

    /**
     * @notice Gets the number of decimals of the underlying asset token.
     * @return decimals_ The number of decimals of the asset token.
     */
    function getAssetDecimals() external view returns (uint8 decimals_);

    /**
     * @notice Gets the address of the USDN ERC20 token.
     * @return usdn_ The address of USDN ERC20 token.
     */
    function getUsdn() external view returns (IUsdn usdn_);

    /**
     * @notice Gets the `MIN_DIVISOR` constant of the USDN token.
     * @dev Check the USDN contract for more information.
     * @return minDivisor_ The `MIN_DIVISOR` constant of the USDN token.
     */
    function getUsdnMinDivisor() external view returns (uint256 minDivisor_);

    /* -------------------------------------------------------------------------- */
    /*                             Parameters getters                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Gets the oracle middleware contract.
     * @return oracleMiddleware_ The address of the oracle middleware contract.
     */
    function getOracleMiddleware() external view returns (IBaseOracleMiddleware oracleMiddleware_);

    /**
     * @notice Gets the liquidation rewards manager contract.
     * @return liquidationRewardsManager_ The address of the liquidation rewards manager contract.
     */
    function getLiquidationRewardsManager()
        external
        view
        returns (IBaseLiquidationRewardsManager liquidationRewardsManager_);

    /**
     * @notice Gets the rebalancer contract.
     * @return rebalancer_ The address of the rebalancer contract.
     */
    function getRebalancer() external view returns (IBaseRebalancer rebalancer_);

    /**
     * @notice Gets the lowest leverage that can be used to open a long position.
     * @return minLeverage_ The minimum leverage (with `LEVERAGE_DECIMALS` decimals).
     */
    function getMinLeverage() external view returns (uint256 minLeverage_);

    /**
     * @notice Gets the highest leverage that can be used to open a long position.
     * @dev A position can have a leverage a bit higher than this value under specific conditions involving
     * a change to the liquidation penalty setting.
     * @return maxLeverage_ The maximum leverage value (with `LEVERAGE_DECIMALS` decimals).
     */
    function getMaxLeverage() external view returns (uint256 maxLeverage_);

    /**
     * @notice Gets the deadline of the exclusivity period for the validator of a pending action with a low-latency
     * oracle.
     * @dev After this deadline, any user can validate the action with the low-latency oracle until the
     * OracleMiddleware's `_lowLatencyDelay`, and retrieve the security deposit for the pending action.
     * @return deadline_ The low-latency validation deadline of a validator (in seconds).
     */
    function getLowLatencyValidatorDeadline() external view returns (uint128 deadline_);

    /**
     * @notice Gets the deadline of the exclusivity period for the validator to confirm their action with the on-chain
     * oracle.
     * @dev After this deadline, any user can validate the pending action with the on-chain oracle and retrieve its
     * security deposit.
     * @return deadline_ The on-chain validation deadline of a validator (in seconds)
     */
    function getOnChainValidatorDeadline() external view returns (uint128 deadline_);

    /**
     * @notice Gets the liquidation penalty applied to the liquidation price when opening a position.
     * @return liquidationPenalty_ The liquidation penalty (in ticks).
     */
    function getLiquidationPenalty() external view returns (uint24 liquidationPenalty_);

    /**
     * @notice Gets the safety margin for the liquidation price of newly open positions.
     * @return safetyMarginBps_ The safety margin (in basis points).
     */
    function getSafetyMarginBps() external view returns (uint256 safetyMarginBps_);

    /**
     * @notice Gets the number of tick liquidations to perform when attempting to
     * liquidate positions during user actions.
     * @return iterations_ The number of iterations for liquidations during user actions.
     */
    function getLiquidationIteration() external view returns (uint16 iterations_);

    /**
     * @notice Gets the time frame for the EMA calculations.
     * @dev The EMA is set to the last funding rate when the time elapsed between 2 actions is greater than this value.
     * @return period_ The time frame of the EMA (in seconds).
     */
    function getEMAPeriod() external view returns (uint128 period_);

    /**
     * @notice Gets the scaling factor (SF) of the funding rate.
     * @return scalingFactor_ The scaling factor (with `FUNDING_SF_DECIMALS` decimals).
     */
    function getFundingSF() external view returns (uint256 scalingFactor_);

    /**
     * @notice Gets the fee taken by the protocol during the application of funding.
     * @return feeBps_ The fee applied to the funding (in basis points).
     */
    function getProtocolFeeBps() external view returns (uint16 feeBps_);

    /**
     * @notice Gets the fee applied when a long position is opened or closed.
     * @return feeBps_ The fee applied to a long position (in basis points).
     */
    function getPositionFeeBps() external view returns (uint16 feeBps_);

    /**
     * @notice Gets the fee applied during a vault deposit or withdrawal.
     * @return feeBps_ The fee applied to a vault action (in basis points).
     */
    function getVaultFeeBps() external view returns (uint16 feeBps_);

    /**
     * @notice Gets the rewards ratio given to the caller when burning SDEX tokens.
     * @return rewardsBps_ The rewards ratio (in basis points).
     */
    function getSdexRewardsRatioBps() external view returns (uint16 rewardsBps_);

    /**
     * @notice Gets the part of the remaining collateral given as a bonus to the Rebalancer upon liquidation of a tick.
     * @return bonusBps_ The fraction of the remaining collateral for the Rebalancer bonus (in basis points).
     */
    function getRebalancerBonusBps() external view returns (uint16 bonusBps_);

    /**
     * @notice Gets the ratio of SDEX tokens to burn per minted USDN.
     * @return ratio_ The ratio (to be divided by SDEX_BURN_ON_DEPOSIT_DIVISOR).
     */
    function getSdexBurnOnDepositRatio() external view returns (uint32 ratio_);

    /**
     * @notice Gets the amount of native tokens used as security deposit when opening a new position.
     * @return securityDeposit_ The amount of assets to use as a security deposit (in ether).
     */
    function getSecurityDepositValue() external view returns (uint64 securityDeposit_);

    /**
     * @notice Gets the threshold to reach to send accumulated fees to the fee collector.
     * @return threshold_ The amount of accumulated fees to reach (in `_assetDecimals`).
     */
    function getFeeThreshold() external view returns (uint256 threshold_);

    /**
     * @notice Gets the address of the fee collector.
     * @return feeCollector_ The address of the fee collector.
     */
    function getFeeCollector() external view returns (address feeCollector_);

    /**
     * @notice Returns the amount of time to wait before an action can be validated.
     * @dev This is also the amount of time to add to the initiate action timestamp to fetch the correct price data to
     * validate said action with a low-latency oracle.
     * @return delay_ The validation delay (in seconds).
     */
    function getMiddlewareValidationDelay() external view returns (uint256 delay_);

    /**
     * @notice Gets the expo imbalance limit when depositing assets (in basis points).
     * @return depositExpoImbalanceLimitBps_ The deposit expo imbalance limit.
     */
    function getDepositExpoImbalanceLimitBps() external view returns (int256 depositExpoImbalanceLimitBps_);

    /**
     * @notice Gets the expo imbalance limit when withdrawing assets (in basis points).
     * @return withdrawalExpoImbalanceLimitBps_ The withdrawal expo imbalance limit.
     */
    function getWithdrawalExpoImbalanceLimitBps() external view returns (int256 withdrawalExpoImbalanceLimitBps_);

    /**
     * @notice Gets the expo imbalance limit when opening a position (in basis points).
     * @return openExpoImbalanceLimitBps_ The open expo imbalance limit.
     */
    function getOpenExpoImbalanceLimitBps() external view returns (int256 openExpoImbalanceLimitBps_);

    /**
     * @notice Gets the expo imbalance limit when closing a position (in basis points).
     * @return closeExpoImbalanceLimitBps_ The close expo imbalance limit.
     */
    function getCloseExpoImbalanceLimitBps() external view returns (int256 closeExpoImbalanceLimitBps_);

    /**
     * @notice Returns the limit of the imbalance in bps to close the rebalancer position.
     * @return rebalancerCloseExpoImbalanceLimitBps_ The limit of the imbalance in bps to close the rebalancer position.
     */
    function getRebalancerCloseExpoImbalanceLimitBps()
        external
        view
        returns (int256 rebalancerCloseExpoImbalanceLimitBps_);

    /**
     * @notice Returns the imbalance desired on the long side after the creation of a rebalancer position.
     * @dev The creation of the rebalancer position aims for this target but does not guarantee reaching it.
     * @return targetLongImbalance_ The target long imbalance.
     */
    function getLongImbalanceTargetBps() external view returns (int256 targetLongImbalance_);

    /**
     * @notice Gets the nominal (target) price of USDN.
     * @return price_ The price of the USDN token after a rebase (in `_priceFeedDecimals`).
     */
    function getTargetUsdnPrice() external view returns (uint128 price_);

    /**
     * @notice Gets the USDN token price above which a rebase should occur.
     * @return threshold_ The rebase threshold (in `_priceFeedDecimals`).
     */
    function getUsdnRebaseThreshold() external view returns (uint128 threshold_);

    /**
     * @notice Gets the minimum collateral amount when opening a long position.
     * @return minLongPosition_ The minimum amount (with `_assetDecimals`).
     */
    function getMinLongPosition() external view returns (uint256 minLongPosition_);

    /* -------------------------------------------------------------------------- */
    /*                                State getters                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Gets the value of the funding rate at the last timestamp (`getLastUpdateTimestamp`).
     * @return lastFunding_ The last value of the funding rate (per day) with `FUNDING_RATE_DECIMALS` decimals.
     */
    function getLastFundingPerDay() external view returns (int256 lastFunding_);

    /**
     * @notice Gets the neutral price of the asset used during the last update of the vault and long balances.
     * @return lastPrice_ The most recent known price of the asset (in `_priceFeedDecimals`).
     */
    function getLastPrice() external view returns (uint128 lastPrice_);

    /**
     * @notice Gets the timestamp of the last time a fresh price was provided.
     * @return lastTimestamp_ The timestamp of the last update.
     */
    function getLastUpdateTimestamp() external view returns (uint128 lastTimestamp_);

    /**
     * @notice Gets the fees that were accumulated by the contract and are yet to be sent
     * to the fee collector (in `_assetDecimals`).
     * @return protocolFees_ The amount of accumulated fees still in the contract.
     */
    function getPendingProtocolFee() external view returns (uint256 protocolFees_);

    /**
     * @notice Gets the amount of assets backing the USDN token.
     * @return balanceVault_ The amount of assets on the vault side (in `_assetDecimals`).
     */
    function getBalanceVault() external view returns (uint256 balanceVault_);

    /**
     * @notice Gets the pending balance updates due to pending vault actions.
     * @return pendingBalanceVault_ The unreflected balance change due to pending vault actions (in `_assetDecimals`).
     */
    function getPendingBalanceVault() external view returns (int256 pendingBalanceVault_);

    /**
     * @notice Gets the exponential moving average of the funding rate per day.
     * @return ema_ The exponential moving average of the funding rate per day.
     */
    function getEMA() external view returns (int256 ema_);

    /**
     * @notice Gets the summed value of all the currently open long positions at `_lastUpdateTimestamp`.
     * @return balanceLong_ The balance of the long side (in `_assetDecimals`).
     */
    function getBalanceLong() external view returns (uint256 balanceLong_);

    /**
     * @notice Gets the total exposure of all currently open long positions.
     * @return totalExpo_ The total exposure of the longs (in `_assetDecimals`).
     */
    function getTotalExpo() external view returns (uint256 totalExpo_);

    /**
     * @notice Gets the accumulator used to calculate the liquidation multiplier.
     * @return accumulator_ The liquidation multiplier accumulator.
     */
    function getLiqMultiplierAccumulator() external view returns (HugeUint.Uint512 memory accumulator_);

    /**
     * @notice Gets the current version of the given tick.
     * @param tick The tick number.
     * @return tickVersion_ The version of the tick.
     */
    function getTickVersion(int24 tick) external view returns (uint256 tickVersion_);

    /**
     * @notice Gets the tick data for the current tick version.
     * @param tick The tick number.
     * @return tickData_ The tick data.
     */
    function getTickData(int24 tick) external view returns (TickData memory tickData_);

    /**
     * @notice Gets the long position at the provided tick and index.
     * @param tick The tick number.
     * @param index The position index.
     * @return position_ The long position.
     */
    function getCurrentLongPosition(int24 tick, uint256 index) external view returns (Position memory position_);

    /**
     * @notice Gets the highest tick that has an open position.
     * @return tick_ The highest populated tick.
     */
    function getHighestPopulatedTick() external view returns (int24 tick_);

    /**
     * @notice Gets the total number of long positions currently open.
     * @return totalLongPositions_ The number of long positions.
     */
    function getTotalLongPositions() external view returns (uint256 totalLongPositions_);

    /**
     * @notice Gets the address of the fallback contract.
     * @return fallback_ The address of the fallback contract.
     */
    function getFallbackAddress() external view returns (address fallback_);

    /**
     * @notice Gets the pause status of the USDN protocol.
     * @return isPaused_ True if it's paused, false otherwise.
     */
    function isPaused() external view returns (bool isPaused_);

    /**
     * @notice Gets the nonce a user can use to generate a delegation signature.
     * @dev This is to prevent replay attacks when using an eip712 delegation signature.
     * @param user The address of the user.
     * @return nonce_ The user's nonce.
     */
    function getNonce(address user) external view returns (uint256 nonce_);

    /* -------------------------------------------------------------------------- */
    /*                                   Setters                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Replaces the OracleMiddleware contract with a new implementation.
     * @dev Cannot be the 0 address.
     * @param newOracleMiddleware The address of the new contract.
     */
    function setOracleMiddleware(IBaseOracleMiddleware newOracleMiddleware) external;

    /**
     * @notice Sets the fee collector address.
     * @dev  Cannot be the zero address.
     * @param newFeeCollector The address of the fee collector.
     */
    function setFeeCollector(address newFeeCollector) external;

    /**
     * @notice Replaces the LiquidationRewardsManager contract with a new implementation.
     * @dev Cannot be the 0 address.
     * @param newLiquidationRewardsManager The address of the new contract.
     */
    function setLiquidationRewardsManager(IBaseLiquidationRewardsManager newLiquidationRewardsManager) external;

    /**
     * @notice Replaces the Rebalancer contract with a new implementation.
     * @param newRebalancer The address of the new contract.
     */
    function setRebalancer(IBaseRebalancer newRebalancer) external;

    /**
     * @notice Sets the new deadlines of the exclusivity period for the validator to confirm its action and get its
     * security deposit back.
     * @param newLowLatencyValidatorDeadline The new exclusivity deadline for low-latency validation (offset from
     * initiate timestamp).
     * @param newOnChainValidatorDeadline The new exclusivity deadline for on-chain validation (offset from initiate
     * timestamp + oracle middleware's low latency delay).
     */
    function setValidatorDeadlines(uint128 newLowLatencyValidatorDeadline, uint128 newOnChainValidatorDeadline)
        external;

    /**
     * @notice Sets the minimum long position size.
     * @dev This value is used to prevent users from opening positions that are too small and not worth liquidating.
     * @param newMinLongPosition The new minimum long position size (with `_assetDecimals`).
     */
    function setMinLongPosition(uint256 newMinLongPosition) external;

    /**
     * @notice Sets the new minimum leverage for a position.
     * @param newMinLeverage The new minimum leverage.
     */
    function setMinLeverage(uint256 newMinLeverage) external;

    /**
     * @notice Sets the new maximum leverage for a position.
     * @param newMaxLeverage The new maximum leverage.
     */
    function setMaxLeverage(uint256 newMaxLeverage) external;

    /**
     * @notice Sets the new liquidation penalty (in ticks).
     * @param newLiquidationPenalty The new liquidation penalty.
     */
    function setLiquidationPenalty(uint24 newLiquidationPenalty) external;

    /**
     * @notice Sets the new exponential moving average period of the funding rate.
     * @param newEMAPeriod The new EMA period.
     */
    function setEMAPeriod(uint128 newEMAPeriod) external;

    /**
     * @notice Sets the new scaling factor (SF) of the funding rate.
     * @param newFundingSF The new scaling factor (SF) of the funding rate.
     */
    function setFundingSF(uint256 newFundingSF) external;

    /**
     * @notice Sets the protocol fee.
     * @dev Fees are charged when the funding is applied (Example: 50 bps -> 0.5%).
     * @param newFeeBps The fee to be charged (in basis points).
     */
    function setProtocolFeeBps(uint16 newFeeBps) external;

    /**
     * @notice Sets the position fee.
     * @param newPositionFee The new position fee (in basis points).
     */
    function setPositionFeeBps(uint16 newPositionFee) external;

    /**
     * @notice Sets the vault fee.
     * @param newVaultFee The new vault fee (in basis points).
     */
    function setVaultFeeBps(uint16 newVaultFee) external;

    /**
     * @notice Sets the rewards ratio given to the caller when burning SDEX tokens.
     * @param newRewardsBps The new rewards ratio (in basis points).
     */
    function setSdexRewardsRatioBps(uint16 newRewardsBps) external;

    /**
     * @notice Sets the rebalancer bonus.
     * @param newBonus The bonus (in basis points).
     */
    function setRebalancerBonusBps(uint16 newBonus) external;

    /**
     * @notice Sets the ratio of SDEX tokens to burn per minted USDN.
     * @param newRatio The new ratio.
     */
    function setSdexBurnOnDepositRatio(uint32 newRatio) external;

    /**
     * @notice Sets the security deposit value.
     * @dev The maximum value of the security deposit is 2^64 - 1 = 18446744073709551615 = 18.4 ethers.
     * @param securityDepositValue The security deposit value.
     * This value cannot be greater than MAX_SECURITY_DEPOSIT.
     */
    function setSecurityDepositValue(uint64 securityDepositValue) external;

    /**
     * @notice Sets the imbalance limits (in basis point).
     * @dev `newLongImbalanceTargetBps` needs to be lower than `newCloseLimitBps` and
     * higher than the additive inverse of `newWithdrawalLimitBps`.
     * @param newOpenLimitBps The new open limit.
     * @param newDepositLimitBps The new deposit limit.
     * @param newWithdrawalLimitBps The new withdrawal limit.
     * @param newCloseLimitBps The new close limit.
     * @param newRebalancerCloseLimitBps The new rebalancer close limit.
     * @param newLongImbalanceTargetBps The new target imbalance limit for the long side.
     * A positive value will target below equilibrium, a negative one will target above equilibrium.
     * If negative, the rebalancerCloseLimit will be useless since the minimum value is 1.
     */
    function setExpoImbalanceLimits(
        uint256 newOpenLimitBps,
        uint256 newDepositLimitBps,
        uint256 newWithdrawalLimitBps,
        uint256 newCloseLimitBps,
        uint256 newRebalancerCloseLimitBps,
        int256 newLongImbalanceTargetBps
    ) external;

    /**
     * @notice Sets the new safety margin for the liquidation price of newly open positions.
     * @param newSafetyMarginBps The new safety margin (in basis points).
     */
    function setSafetyMarginBps(uint256 newSafetyMarginBps) external;

    /**
     * @notice Sets the new number of liquidations iteration for user actions.
     * @param newLiquidationIteration The new number of liquidation iteration.
     */
    function setLiquidationIteration(uint16 newLiquidationIteration) external;

    /**
     * @notice Sets the minimum amount of fees to be collected before they can be withdrawn.
     * @param newFeeThreshold The minimum amount of fees to be collected before they can be withdrawn.
     */
    function setFeeThreshold(uint256 newFeeThreshold) external;

    /**
     * @notice Sets the target USDN price.
     * @dev When a rebase of USDN occurs, it will bring the price back down to this value.
     * @param newPrice The new target price (with `_priceFeedDecimals`).
     * This value cannot be greater than `_usdnRebaseThreshold`.
     */
    function setTargetUsdnPrice(uint128 newPrice) external;

    /**
     * @notice Sets the USDN rebase threshold.
     * @dev When the price of USDN exceeds this value, a rebase will be triggered.
     * @param newThreshold The new threshold value (with `_priceFeedDecimals`).
     * This value cannot be smaller than `_targetUsdnPrice` or greater than uint128(2 * 10 ** s._priceFeedDecimals)
     */
    function setUsdnRebaseThreshold(uint128 newThreshold) external;

    /**
     * @notice Pauses related USDN protocol functions.
     * @dev Pauses simultaneously all initiate/validate, refundSecurityDeposit and transferPositionOwnership functions.
     * Before pausing, this function will call `_applyPnlAndFunding` with `_lastPrice` and the current timestamp.
     * This is done to stop the funding rate from accumulating while the protocol is paused. Be sure to call {unpause}
     * to update `_lastUpdateTimestamp` when unpausing.
     */
    function pause() external;

    /**
     * @notice Pauses related USDN protocol functions without applying PnLs and the funding.
     * @dev Pauses simultaneously all initiate/validate, refundSecurityDeposit and transferPositionOwnership functions.
     * This safe version will not call `_applyPnlAndFunding` before pausing.
     */
    function pauseSafe() external;

    /**
     * @notice Unpauses related USDN protocol functions.
     * @dev Unpauses simultaneously all initiate/validate, refundSecurityDeposit and transferPositionOwnership
     * functions. This function will set `_lastUpdateTimestamp` to the current timestamp to prevent any funding during
     * the pause. Only meant to be called after a {pause} call.
     */
    function unpause() external;

    /**
     * @notice Unpauses related USDN protocol functions without updating `_lastUpdateTimestamp`.
     * @dev Unpauses simultaneously all initiate/validate, refundSecurityDeposit and transferPositionOwnership
     * functions. This safe version will not set `_lastUpdateTimestamp` to the current timestamp.
     */
    function unpauseSafe() external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IAccessControlDefaultAdminRules } from
    "@openzeppelin/contracts/access/extensions/IAccessControlDefaultAdminRules.sol";
import { IERC5267 } from "@openzeppelin/contracts/interfaces/IERC5267.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IBaseLiquidationRewardsManager } from "../LiquidationRewardsManager/IBaseLiquidationRewardsManager.sol";
import { IBaseOracleMiddleware } from "../OracleMiddleware/IBaseOracleMiddleware.sol";
import { IUsdn } from "../Usdn/IUsdn.sol";
import { IUsdnProtocolActions } from "./IUsdnProtocolActions.sol";
import { IUsdnProtocolCore } from "./IUsdnProtocolCore.sol";
import { IUsdnProtocolFallback } from "./IUsdnProtocolFallback.sol";
import { IUsdnProtocolLong } from "./IUsdnProtocolLong.sol";
import { IUsdnProtocolVault } from "./IUsdnProtocolVault.sol";

/**
 * @title IUsdnProtocolImpl
 * @notice Interface for the implementation of the USDN protocol (completed with {IUsdnProtocolFallback})
 */
interface IUsdnProtocolImpl is
    IUsdnProtocolActions,
    IUsdnProtocolVault,
    IUsdnProtocolLong,
    IUsdnProtocolCore,
    IAccessControlDefaultAdminRules,
    IERC5267
{
    /**
     * @notice Initializes the protocol's storage with the given values.
     * @dev This function should be called on deployment when creating the proxy.
     * It can only be called once.
     * @param usdn The USDN ERC20 contract address (must have a total supply of 0).
     * @param sdex The SDEX ERC20 contract address.
     * @param asset The ERC20 contract address of the token held in the vault.
     * @param oracleMiddleware The oracle middleware contract address.
     * @param liquidationRewardsManager The liquidation rewards manager contract address.
     * @param tickSpacing The number of ticks between usable ticks.
     * @param feeCollector The address that will receive the protocol fees.
     * @param protocolFallback The address of the contract that contains the remaining functions of the protocol.
     * Any call with a function signature not present in this contract will be delegated to the fallback contract.
     */
    function initializeStorage(
        IUsdn usdn,
        IERC20Metadata sdex,
        IERC20Metadata asset,
        IBaseOracleMiddleware oracleMiddleware,
        IBaseLiquidationRewardsManager liquidationRewardsManager,
        int24 tickSpacing,
        address feeCollector,
        IUsdnProtocolFallback protocolFallback
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { HugeUint } from "@smardex-solidity-libraries-1/HugeUint.sol";

import { IUsdnProtocolTypes } from "./IUsdnProtocolTypes.sol";

/**
 * @title IUsdnProtocolLong
 * @notice Interface for the long side layer of the USDN protocol.
 */
interface IUsdnProtocolLong is IUsdnProtocolTypes {
    /**
     * @notice Gets the value of the lowest usable tick, taking into account the tick spacing.
     * @dev Note that the effective minimum tick of a newly open long position also depends on the minimum allowed
     * leverage value and the current value of the liquidation price multiplier.
     * @return tick_ The lowest usable tick.
     */
    function minTick() external view returns (int24 tick_);

    /**
     * @notice Gets the liquidation price from a desired one by taking into account the tick rounding.
     * @param desiredLiqPriceWithoutPenalty The desired liquidation price without the penalty.
     * @param assetPrice The current price of the asset.
     * @param longTradingExpo The trading exposition of the long side.
     * @param accumulator The liquidation multiplier accumulator.
     * @param tickSpacing The tick spacing.
     * @param liquidationPenalty The liquidation penalty set on the tick.
     * @return liqPrice_ The new liquidation price without the penalty.
     */
    function getLiqPriceFromDesiredLiqPrice(
        uint128 desiredLiqPriceWithoutPenalty,
        uint256 assetPrice,
        uint256 longTradingExpo,
        HugeUint.Uint512 memory accumulator,
        int24 tickSpacing,
        uint24 liquidationPenalty
    ) external view returns (uint128 liqPrice_);

    /**
     * @notice Gets the value of a long position when the asset price is equal to the given price, at the given
     * timestamp.
     * @dev If the current price is smaller than the liquidation price of the position without the liquidation penalty,
     * then the value of the position is negative.
     * @param posId The unique position identifier.
     * @param price The asset price.
     * @param timestamp The timestamp of the price.
     * @return value_ The position value in assets.
     */
    function getPositionValue(PositionId calldata posId, uint128 price, uint128 timestamp)
        external
        view
        returns (int256 value_);

    /**
     * @notice Gets the tick number corresponding to a given price, accounting for funding effects.
     * @dev Uses the stored parameters for calculation.
     * @param price The asset price.
     * @return tick_ The tick number, a multiple of the tick spacing.
     */
    function getEffectiveTickForPrice(uint128 price) external view returns (int24 tick_);

    /**
     * @notice Gets the tick number corresponding to a given price, accounting for funding effects.
     * @param price The asset price.
     * @param assetPrice The current price of the asset.
     * @param longTradingExpo The trading exposition of the long side.
     * @param accumulator The liquidation multiplier accumulator.
     * @param tickSpacing The tick spacing.
     * @return tick_ The tick number, a multiple of the tick spacing.
     */
    function getEffectiveTickForPrice(
        uint128 price,
        uint256 assetPrice,
        uint256 longTradingExpo,
        HugeUint.Uint512 memory accumulator,
        int24 tickSpacing
    ) external view returns (int24 tick_);

    /**
     * @notice Retrieves the liquidation penalty assigned to the given tick if there are positions in it, otherwise
     * retrieve the current setting value from storage.
     * @param tick The tick number.
     * @return liquidationPenalty_ The liquidation penalty, in tick spacing units.
     */
    function getTickLiquidationPenalty(int24 tick) external view returns (uint24 liquidationPenalty_);

    /**
     * @notice Gets a long position identified by its tick, tick version and index.
     * @param posId The unique position identifier.
     * @return pos_ The position data.
     * @return liquidationPenalty_ The liquidation penalty for that position.
     */
    function getLongPosition(PositionId calldata posId)
        external
        view
        returns (Position memory pos_, uint24 liquidationPenalty_);

    /**
     * @notice Gets the predicted value of the long balance for the given asset price and timestamp.
     * @dev The effects of the funding and any PnL of the long positions since the last contract state
     * update is taken into account, as well as the fees. If the provided timestamp is older than the last state
     * update, the function reverts with `UsdnProtocolTimestampTooOld`. The value cannot be below 0.
     * @param currentPrice The given asset price.
     * @param timestamp The timestamp corresponding to the given price.
     * @return available_ The long balance value in assets.
     */
    function longAssetAvailableWithFunding(uint128 currentPrice, uint128 timestamp)
        external
        view
        returns (uint256 available_);

    /**
     * @notice Gets the predicted value of the long trading exposure for the given asset price and timestamp.
     * @dev The effects of the funding and any profit or loss of the long positions since the last contract state
     * update is taken into account. If the provided timestamp is older than the last state update, the function reverts
     * with `UsdnProtocolTimestampTooOld`. The value cannot be below 0.
     * @param currentPrice The given asset price.
     * @param timestamp The timestamp corresponding to the given price.
     * @return expo_ The long trading exposure value in assets.
     */
    function longTradingExpoWithFunding(uint128 currentPrice, uint128 timestamp)
        external
        view
        returns (uint256 expo_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { HugeUint } from "@smardex-solidity-libraries-1/HugeUint.sol";
import { LibBitmap } from "solady/src/utils/LibBitmap.sol";

import { DoubleEndedQueue } from "../../libraries/DoubleEndedQueue.sol";
import { IBaseLiquidationRewardsManager } from "../LiquidationRewardsManager/IBaseLiquidationRewardsManager.sol";
import { IBaseOracleMiddleware } from "../OracleMiddleware/IBaseOracleMiddleware.sol";
import { IBaseRebalancer } from "../Rebalancer/IBaseRebalancer.sol";
import { IUsdn } from "../Usdn/IUsdn.sol";

interface IUsdnProtocolTypes {
    /**
     * @notice All possible action types for the protocol.
     * @dev This is used for pending actions and to interact with the oracle middleware.
     * @param None No particular action.
     * @param Initialize The contract is being initialized.
     * @param InitiateDeposit Initiating a `deposit` action.
     * @param ValidateDeposit Validating a `deposit` action.
     * @param InitiateWithdrawal Initiating a `withdraw` action.
     * @param ValidateWithdrawal Validating a `withdraw` action.
     * @param InitiateOpenPosition Initiating an `open` position action.
     * @param ValidateOpenPosition Validating an `open` position action.
     * @param InitiateClosePosition Initiating a `close` position action.
     * @param ValidateClosePosition Validating a `close` position action.
     * @param Liquidation The price is requested for a liquidation action.
     */
    enum ProtocolAction {
        None,
        Initialize,
        InitiateDeposit,
        ValidateDeposit,
        InitiateWithdrawal,
        ValidateWithdrawal,
        InitiateOpenPosition,
        ValidateOpenPosition,
        InitiateClosePosition,
        ValidateClosePosition,
        Liquidation
    }

    /**
     * @notice The outcome of the call targeting a long position.
     * @param Processed The call did what it was supposed to do.
     * An initiate close has been completed / a pending action was validated.
     * @param Liquidated The position has been liquidated by this call.
     * @param PendingLiquidations The call cannot be completed because of pending liquidations.
     * Try calling the {IUsdnProtocolActions.liquidate} function with a fresh price to unblock the situation.
     */
    enum LongActionOutcome {
        Processed,
        Liquidated,
        PendingLiquidations
    }

    /**
     * @notice Classifies how far in its logic the {UsdnProtocolLongLibrary._triggerRebalancer} function made it to.
     * @dev Used to estimate the gas spent by the function call to more accurately calculate liquidation rewards.
     * @param None The rebalancer is not set.
     * @param NoImbalance The protocol imbalance is not reached.
     * @param PendingLiquidation The rebalancer position should be liquidated.
     * @param NoCloseNoOpen The action neither closes nor opens a position.
     * @param Closed The action only closes a position.
     * @param Opened The action only opens a position.
     * @param ClosedOpened The action closes and opens a position.
     */
    enum RebalancerAction {
        None,
        NoImbalance,
        PendingLiquidation,
        NoCloseNoOpen,
        Closed,
        Opened,
        ClosedOpened
    }

    /**
     * @notice Information about a long user position.
     * @param validated Whether the position was validated.
     * @param timestamp The timestamp of the position start.
     * @param user The user's address.
     * @param totalExpo The total exposure of the position (0 for vault deposits). The product of the initial
     * collateral and the initial leverage.
     * @param amount The amount of initial collateral in the position.
     */
    struct Position {
        bool validated; // 1 byte
        uint40 timestamp; // 5 bytes. Max 1_099_511_627_775 (36812-02-20 01:36:15)
        address user; // 20 bytes
        uint128 totalExpo; // 16 bytes. Max 340_282_366_920_938_463_463.374_607_431_768_211_455 ether
        uint128 amount; // 16 bytes
    }

    /**
     * @notice A pending action in the queue.
     * @param action The action type.
     * @param timestamp The timestamp of the initiate action.
     * @param var0 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param to The target of the action.
     * @param validator The address that is supposed to validate the action.
     * @param securityDepositValue The security deposit of the pending action.
     * @param var1 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var2 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var3 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var4 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var5 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var6 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     * @param var7 See {DepositPendingAction}, {WithdrawalPendingAction} and {LongPendingAction}.
     */
    struct PendingAction {
        ProtocolAction action; // 1 byte
        uint40 timestamp; // 5 bytes
        uint24 var0; // 3 bytes
        address to; // 20 bytes
        address validator; // 20 bytes
        uint64 securityDepositValue; // 8 bytes
        int24 var1; // 3 bytes
        uint128 var2; // 16 bytes
        uint128 var3; // 16 bytes
        uint256 var4; // 32 bytes
        uint256 var5; // 32 bytes
        uint256 var6; // 32 bytes
        uint256 var7; // 32 bytes
    }

    /**
     * @notice A pending action in the queue for a vault deposit.
     * @param action The action type.
     * @param timestamp The timestamp of the initiate action.
     * @param feeBps Fee for the deposit, in BPS.
     * @param to The recipient of the funds.
     * @param validator The address that is supposed to validate the action.
     * @param securityDepositValue The security deposit of the pending action.
     * @param _unused Unused field to align the struct to `PendingAction`.
     * @param amount The amount of assets of the pending deposit.
     * @param assetPrice The price of the asset at the time of the last update.
     * @param totalExpo The total exposure at the time of the last update.
     * @param balanceVault The balance of the vault at the time of the last update.
     * @param balanceLong The balance of the long position at the time of the last update.
     * @param usdnTotalShares The total supply of USDN shares at the time of the action.
     */
    struct DepositPendingAction {
        ProtocolAction action; // 1 byte
        uint40 timestamp; // 5 bytes
        uint24 feeBps; // 3 bytes
        address to; // 20 bytes
        address validator; // 20 bytes
        uint64 securityDepositValue; // 8 bytes
        uint24 _unused; // 3 bytes
        uint128 amount; // 16 bytes
        uint128 assetPrice; // 16 bytes
        uint256 totalExpo; // 32 bytes
        uint256 balanceVault; // 32 bytes
        uint256 balanceLong; // 32 bytes
        uint256 usdnTotalShares; // 32 bytes
    }

    /**
     * @notice A pending action in the queue for a vault withdrawal.
     * @param action The action type.
     * @param timestamp The timestamp of the initiate action.
     * @param feeBps Fee for the withdrawal, in BPS.
     * @param to The recipient of the funds.
     * @param validator The address that is supposed to validate the action.
     * @param securityDepositValue The security deposit of the pending action.
     * @param sharesLSB 3 least significant bytes of the withdrawal shares amount (uint152).
     * @param sharesMSB 16 most significant bytes of the withdrawal shares amount (uint152).
     * @param assetPrice The price of the asset at the time of the last update.
     * @param totalExpo The total exposure at the time of the last update.
     * @param balanceVault The balance of the vault at the time of the last update.
     * @param balanceLong The balance of the long position at the time of the last update.
     * @param usdnTotalShares The total shares supply of USDN at the time of the action.
     */
    struct WithdrawalPendingAction {
        ProtocolAction action; // 1 byte
        uint40 timestamp; // 5 bytes
        uint24 feeBps; // 3 bytes
        address to; // 20 bytes
        address validator; // 20 bytes
        uint64 securityDepositValue; // 8 bytes
        uint24 sharesLSB; // 3 bytes
        uint128 sharesMSB; // 16 bytes
        uint128 assetPrice; // 16 bytes
        uint256 totalExpo; // 32 bytes
        uint256 balanceVault; // 32 bytes
        uint256 balanceLong; // 32 bytes
        uint256 usdnTotalShares; // 32 bytes
    }

    /**
     * @notice A pending action in the queue for a long position.
     * @param action The action type.
     * @param timestamp The timestamp of the initiate action.
     * @param closeLiqPenalty The liquidation penalty of the tick (only used when closing a position).
     * @param to The recipient of the position.
     * @param validator The address that is supposed to validate the action.
     * @param securityDepositValue The security deposit of the pending action.
     * @param tick The tick of the position.
     * @param closeAmount The portion of the initial position amount to close (only used when closing a position).
     * @param closePosTotalExpo The total expo of the position (only used when closing a position).
     * @param tickVersion The version of the tick.
     * @param index The index of the position in the tick list.
     * @param liqMultiplier A fixed precision representation of the liquidation multiplier (with
     * `LIQUIDATION_MULTIPLIER_DECIMALS` decimals) used to calculate the effective price for a given tick number.
     * @param closeBoundedPositionValue The amount that was removed from the long balance on
     * {IUsdnProtocolActions.initiateClosePosition} (only used when closing a position).
     */
    struct LongPendingAction {
        ProtocolAction action; // 1 byte
        uint40 timestamp; // 5 bytes
        uint24 closeLiqPenalty; // 3 bytes
        address to; // 20 bytes
        address validator; // 20 bytes
        uint64 securityDepositValue; // 8 bytes
        int24 tick; // 3 bytes
        uint128 closeAmount; // 16 bytes
        uint128 closePosTotalExpo; // 16 bytes
        uint256 tickVersion; // 32 bytes
        uint256 index; // 32 bytes
        uint256 liqMultiplier; // 32 bytes
        uint256 closeBoundedPositionValue; // 32 bytes
    }

    /**
     * @notice The data allowing to validate an actionable pending action.
     * @param priceData An array of bytes, each representing the data to be forwarded to the oracle middleware to
     * validate a pending action in the queue.
     * @param rawIndices An array of raw indices in the pending actions queue, in the same order as the corresponding
     * priceData.
     */
    struct PreviousActionsData {
        bytes[] priceData;
        uint128[] rawIndices;
    }

    /**
     * @notice Information of a liquidated tick.
     * @param totalPositions The total number of positions in the tick.
     * @param totalExpo The total expo of the tick.
     * @param remainingCollateral The remaining collateral after liquidation.
     * @param tickPrice The corresponding price.
     * @param priceWithoutPenalty The price without the liquidation penalty.
     */
    struct LiqTickInfo {
        uint256 totalPositions;
        uint256 totalExpo;
        int256 remainingCollateral;
        uint128 tickPrice;
        uint128 priceWithoutPenalty;
    }

    /**
     * @notice The effects of executed liquidations on the protocol.
     * @param liquidatedPositions The total number of liquidated positions.
     * @param remainingCollateral The remaining collateral after liquidation.
     * @param newLongBalance The new balance of the long side.
     * @param newVaultBalance The new balance of the vault side.
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate).
     * @param liquidatedTicks Information about the liquidated ticks.
     */
    struct LiquidationsEffects {
        uint256 liquidatedPositions;
        int256 remainingCollateral;
        uint256 newLongBalance;
        uint256 newVaultBalance;
        bool isLiquidationPending;
        LiqTickInfo[] liquidatedTicks;
    }

    /**
     * @notice Accumulator for tick data.
     * @param totalExpo The sum of the total expo of each position in the tick.
     * @param totalPos The number of positions in the tick.
     * @param liquidationPenalty The liquidation penalty for the positions in the tick.
     * @dev Since the liquidation penalty is a parameter that can be updated, we need to ensure that positions that get
     * created with a given penalty, use this penalty throughout their lifecycle. As such, once a tick gets populated by
     * a first position, it gets assigned the current liquidation penalty parameter value and can't use another value
     * until it gets liquidated or all positions exit the tick.
     */
    struct TickData {
        uint256 totalExpo;
        uint248 totalPos;
        uint24 liquidationPenalty;
    }

    /**
     * @notice The unique identifier for a long position.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position in the tick list.
     */
    struct PositionId {
        int24 tick;
        uint256 tickVersion;
        uint256 index;
    }

    /**
     * @notice Parameters for the internal {UsdnProtocolActionsLongLibrary._initiateOpenPosition} function.
     * @param user The address of the user initiating the open position.
     * @param to The address that will be the owner of the position.
     * @param validator The address that is supposed to validate the action.
     * @param amount The amount of assets to deposit.
     * @param desiredLiqPrice The desired liquidation price, including the liquidation penalty.
     * @param userMaxPrice The maximum price at which the position can be opened. The userMaxPrice is compared with the
     * price after confidence interval, penalty, etc...
     * @param userMaxLeverage The maximum leverage for the newly created position.
     * @param deadline The deadline of the open position to be initiated.
     * @param securityDepositValue The value of the security deposit for the newly created pending action.
     * @param currentPriceData The current price data (used to calculate the temporary leverage and entry price,
     * pending validation).
     */
    struct InitiateOpenPositionParams {
        address user;
        address to;
        address validator;
        uint128 amount;
        uint128 desiredLiqPrice;
        uint128 userMaxPrice;
        uint256 userMaxLeverage;
        uint256 deadline;
        uint64 securityDepositValue;
    }

    /**
     * @notice Parameters for the internal {UsdnProtocolLongLibrary._prepareInitiateOpenPosition} function.
     * @param validator The address that is supposed to validate the action.
     * @param amount The amount of assets to deposit.
     * @param desiredLiqPrice The desired liquidation price, including the liquidation penalty.
     * @param userMaxPrice The maximum price at which the position can be opened. The userMaxPrice is compared with the
     * price after confidence interval, penalty, etc...
     * @param userMaxLeverage The maximum leverage for the newly created position.
     * @param currentPriceData The current price data.
     */
    struct PrepareInitiateOpenPositionParams {
        address validator;
        uint128 amount;
        uint128 desiredLiqPrice;
        uint256 userMaxPrice;
        uint256 userMaxLeverage;
        bytes currentPriceData;
    }

    /**
     * @notice Parameters for the internal {UsdnProtocolActionsUtilsLibrary._prepareClosePositionData} function.
     * @param to The recipient of the funds.
     * @param validator The address that is supposed to validate the action.
     * @param posId The unique identifier of the position.
     * @param amountToClose The amount of collateral to remove from the position's amount.
     * @param userMinPrice The minimum price at which the position can be closed.
     * @param deadline The deadline until the position can be closed.
     * @param currentPriceData The current price data.
     * @param delegationSignature An EIP712 signature that proves the caller is authorized by the owner of the position
     * to close it on their behalf.
     * @param domainSeparatorV4 The domain separator v4.
     */
    struct PrepareInitiateClosePositionParams {
        address to;
        address validator;
        PositionId posId;
        uint128 amountToClose;
        uint256 userMinPrice;
        uint256 deadline;
        bytes currentPriceData;
        bytes delegationSignature;
        bytes32 domainSeparatorV4;
    }

    /**
     * @notice Parameters for the internal {UsdnProtocolActionsLongLibrary._initiateClosePosition} function.
     * @param to The recipient of the funds.
     * @param validator The address that is supposed to validate the action.
     * @param posId The unique identifier of the position.
     * @param amountToClose The amount to close.
     * @param userMinPrice The minimum price at which the position can be closed.
     * @param deadline The deadline of the close position to be initiated.
     * @param securityDepositValue The value of the security deposit for the newly created pending action.
     * @param domainSeparatorV4 The domain separator v4 for EIP712 signature.
     */
    struct InitiateClosePositionParams {
        address to;
        address payable validator;
        uint256 deadline;
        PositionId posId;
        uint128 amountToClose;
        uint256 userMinPrice;
        uint64 securityDepositValue;
        bytes32 domainSeparatorV4;
    }

    /**
     * @dev Structure to hold the transient data during {UsdnProtocolActionsLongLibrary._initiateClosePosition}
     * @param pos The position to close.
     * @param liquidationPenalty The liquidation penalty.
     * @param totalExpoToClose The total expo to close.
     * @param lastPrice The price after the last balances update.
     * @param tempPositionValue The bounded value of the position that was removed from the long balance.
     * @param longTradingExpo The long trading expo.
     * @param liqMulAcc The liquidation multiplier accumulator.
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate).
     */
    struct ClosePositionData {
        Position pos;
        uint24 liquidationPenalty;
        uint128 totalExpoToClose;
        uint128 lastPrice;
        uint256 tempPositionValue;
        uint256 longTradingExpo;
        HugeUint.Uint512 liqMulAcc;
        bool isLiquidationPending;
    }

    /**
     * @dev Structure to hold the transient data during {UsdnProtocolActionsLongLibrary._validateOpenPosition}.
     * @param action The long pending action.
     * @param startPrice The new entry price of the position.
     * @param lastPrice The price of the last balances update.
     * @param tickHash The tick hash.
     * @param pos The position object.
     * @param liqPriceWithoutPenaltyNorFunding The liquidation price without penalty nor funding used to calculate the
     * user leverage and the new total expo.
     * @param liqPriceWithoutPenalty The new liquidation price without penalty.
     * @param leverage The new leverage.
     * @param oldPosValue The value of the position according to the old entry price and the _lastPrice.
     * @param liquidationPenalty The liquidation penalty for the position's tick.
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate).
     */
    struct ValidateOpenPositionData {
        LongPendingAction action;
        uint128 startPrice;
        uint128 lastPrice;
        bytes32 tickHash;
        Position pos;
        uint128 liqPriceWithoutPenaltyNorFunding;
        uint128 liqPriceWithoutPenalty;
        uint256 leverage;
        uint256 oldPosValue;
        uint24 liquidationPenalty;
        bool isLiquidationPending;
    }

    /**
     * @dev Structure to hold the transient data during {UsdnProtocolActionsLongLibrary._initiateOpenPosition}.
     * @param adjustedPrice The adjusted price with position fees applied.
     * @param posId The unique identifier of the position.
     * @param liquidationPenalty The liquidation penalty.
     * @param positionTotalExpo The total expo of the position. The product of the initial collateral and the initial
     * leverage.
     * @param positionValue The value of the position, taking into account the position fee.
     * @param liqMultiplier The liquidation multiplier represented with fixed precision.
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate).
     */
    struct InitiateOpenPositionData {
        uint128 adjustedPrice;
        PositionId posId;
        uint24 liquidationPenalty;
        uint128 positionTotalExpo;
        uint256 positionValue;
        uint256 liqMultiplier;
        bool isLiquidationPending;
    }

    /**
     * @notice Structure to hold the state of the protocol.
     * @param totalExpo The long total expo.
     * @param tradingExpo The long trading expo.
     * @param longBalance The long balance.
     * @param vaultBalance The vault balance.
     * @param liqMultiplierAccumulator The liquidation multiplier accumulator.
     */
    struct CachedProtocolState {
        uint256 totalExpo;
        uint256 tradingExpo;
        uint256 longBalance;
        uint256 vaultBalance;
        HugeUint.Uint512 liqMultiplierAccumulator;
    }

    /**
     * @notice Structure to hold transient data during the {UsdnProtocolActionsLongLibrary._calcRebalancerPositionTick}
     * function.
     * @param protocolMaxLeverage The protocol maximum leverage.
     * @param longImbalanceTargetBps The long imbalance target in basis points.
     * @param tradingExpoToFill The trading expo to fill.
     * @param highestUsableTradingExpo The highest usable trading expo.
     * @param currentLiqPenalty The current liquidation penalty.
     * @param liqPriceWithoutPenalty The liquidation price without penalty.
     */
    struct CalcRebalancerPositionTickData {
        uint256 protocolMaxLeverage;
        int256 longImbalanceTargetBps;
        uint256 tradingExpoToFill;
        uint256 highestUsableTradingExpo;
        uint24 currentLiqPenalty;
        uint128 liqPriceWithoutPenalty;
    }

    /**
     * @notice Structure to hold the return values of the {UsdnProtocolActionsLongLibrary._calcRebalancerPositionTick}
     * function.
     * @param tick The tick of the rebalancer position, includes liquidation penalty.
     * @param totalExpo The total expo of the rebalancer position.
     * @param liquidationPenalty The liquidation penalty of the tick.
     */
    struct RebalancerPositionData {
        int24 tick;
        uint128 totalExpo;
        uint24 liquidationPenalty;
    }

    /**
     * @notice Data structure for the {UsdnProtocolCoreLibrary._applyPnlAndFunding} function.
     * @param tempLongBalance The new balance of the long side, could be negative (temporarily).
     * @param tempVaultBalance The new balance of the vault side, could be negative (temporarily).
     * @param lastPrice The last price.
     */
    struct ApplyPnlAndFundingData {
        int256 tempLongBalance;
        int256 tempVaultBalance;
        uint128 lastPrice;
    }

    /**
     * @notice Data structure for tick to price conversion functions.
     * @param tradingExpo The long side trading expo.
     * @param accumulator The liquidation multiplier accumulator.
     * @param tickSpacing The tick spacing.
     */
    struct TickPriceConversionData {
        uint256 tradingExpo;
        HugeUint.Uint512 accumulator;
        int24 tickSpacing;
    }

    /**
     * @custom:storage-location erc7201:UsdnProtocol.storage.main.
     * @notice Structure to hold the state of the protocol.
     * @param _tickSpacing The liquidation tick spacing for storing long positions.
     * A tick spacing of 1 is equivalent to a 0.01% increase in liquidation price between ticks. A tick spacing of
     * 100 is equivalent to a ~1.005% increase in liquidation price between ticks.
     * @param _asset The asset ERC20 contract.
     * Assets with a blacklist are not supported because the protocol would be DoS if transfers revert.
     * @param _assetDecimals The number of decimals used by the `_asset`.
     * @param _priceFeedDecimals The price feed decimals (18).
     * @param _usdn The USDN ERC20 contract.
     * @param _sdex The SDEX ERC20 contract.
     * @param _usdnMinDivisor The minimum divisor for USDN.
     * @param _oracleMiddleware The oracle middleware contract.
     * @param _liquidationRewardsManager The liquidation rewards manager contract.
     * @param _rebalancer The rebalancer contract.
     * @param _isRebalancer Whether an address is or has been a rebalancer.
     * @param _minLeverage The minimum leverage for a position.
     * @param _maxLeverage The maximum leverage for a position.
     * @param _lowLatencyValidatorDeadline The deadline for a user to confirm their action with a low-latency oracle.
     * After this deadline, any user can validate the action with the low-latency oracle until the
     * OracleMiddleware's _lowLatencyDelay. This is an offset compared to the timestamp of the initiate action.
     * @param _onChainValidatorDeadline The deadline for a user to confirm their action with an on-chain oracle.
     * After this deadline, any user can validate the action with the on-chain oracle. This is an offset compared
     * to the timestamp of the initiate action + the oracle middleware's _lowLatencyDelay.
     * @param _safetyMarginBps Safety margin for the liquidation price of newly open positions, in basis points.
     * @param _liquidationIteration The number of iterations to perform during the user's action (in tick).
     * @param _protocolFeeBps The protocol fee in basis points.
     * @param _rebalancerBonusBps Part of the remaining collateral that is given as a bonus to the Rebalancer upon
     * liquidation of a tick, in basis points. The rest is sent to the Vault balance.
     * @param _liquidationPenalty The liquidation penalty (in ticks).
     * @param _EMAPeriod The moving average period of the funding rate.
     * @param _fundingSF The scaling factor (SF) of the funding rate.
     * @param _feeThreshold The threshold above which the fee will be sent.
     * @param _openExpoImbalanceLimitBps The imbalance limit of the long expo for open actions (in basis points).
     * As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of long the open rebalancing mechanism is triggered, preventing the opening of a new long position.
     * @param _withdrawalExpoImbalanceLimitBps The imbalance limit of the long expo for withdrawal actions (in basis
     * points). As soon as the difference between vault expo and long expo exceeds this basis point limit in favor of
     * long, the withdrawal rebalancing mechanism is triggered, preventing the withdrawal of the existing vault
     * position.
     * @param _depositExpoImbalanceLimitBps The imbalance limit of the vault expo for deposit actions (in basis points).
     * As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of the vault, the deposit vault rebalancing mechanism is triggered, preventing the opening of a new vault
     * position.
     * @param _closeExpoImbalanceLimitBps The imbalance limit of the vault expo for close actions (in basis points).
     * As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of the vault, the close rebalancing mechanism is triggered, preventing the close of an existing long position.
     * @param _rebalancerCloseExpoImbalanceLimitBps The imbalance limit of the vault expo for close actions from the
     * rebalancer (in basis points). As soon as the difference between the vault expo and the long expo exceeds this
     * basis point limit in favor of the vault, the close rebalancing mechanism is triggered, preventing the close of an
     * existing long position from the rebalancer contract.
     * @param _longImbalanceTargetBps The target imbalance on the long side (in basis points)
     * This value will be used to calculate how much of the missing trading expo the rebalancer position will try
     * to compensate. A negative value means the rebalancer will compensate enough to go above the equilibrium. A
     * positive value means the rebalancer will compensate but stay below the equilibrium.
     * @param _positionFeeBps The position fee in basis points.
     * @param _vaultFeeBps The fee for vault deposits and withdrawals, in basis points.
     * @param _sdexRewardsRatioBps The ratio of SDEX rewards to send to the user (in basis points).
     * @param _sdexBurnOnDepositRatio The ratio of USDN to SDEX tokens to burn on deposit.
     * @param _feeCollector The fee collector's address.
     * @param _securityDepositValue The deposit required for a new position.
     * @param _targetUsdnPrice The nominal (target) price of USDN (with _priceFeedDecimals).
     * @param _usdnRebaseThreshold The USDN price threshold to trigger a rebase (with _priceFeedDecimals).
     * @param _minLongPosition The minimum long position size (with `_assetDecimals`).
     * @param _lastFundingPerDay The funding rate calculated at the last update timestamp.
     * @param _lastPrice The price of the asset during the last balances update (with price feed decimals).
     * @param _lastUpdateTimestamp The timestamp of the last balances update.
     * @param _pendingProtocolFee The pending protocol fee accumulator.
     * @param _pendingActions The pending actions by the user (1 per user max).
     * The value stored is an index into the `pendingActionsQueue` deque, shifted by one. A value of 0 means no
     * pending action. Since the deque uses uint128 indices, the highest index will not overflow when adding one.
     * @param _pendingActionsQueue The queue of pending actions.
     * @param _balanceVault The balance of deposits (with `_assetDecimals`).
     * @param _pendingBalanceVault The unreflected balance change due to pending vault actions (with `_assetDecimals`).
     * @param _EMA The exponential moving average of the funding (0.0003 at initialization).
     * @param _balanceLong The balance of long positions (with `_assetDecimals`).
     * @param _totalExpo The total exposure of the long positions (with `_assetDecimals`).
     * @param _liqMultiplierAccumulator The accumulator used to calculate the liquidation multiplier.
     * This is the sum, for all ticks, of the total expo of positions inside the tick, multiplied by the
     * unadjusted price of the tick which is `_tickData[tickHash].liquidationPenalty` below
     * The unadjusted price is obtained with `TickMath.getPriceAtTick.
     * @param _tickVersion The liquidation tick version.
     * @param _longPositions The long positions per versioned tick (liquidation price).
     * @param _tickData Accumulated data for a given tick and tick version.
     * @param _highestPopulatedTick The highest tick with a position.
     * @param _totalLongPositions Cache of the total long positions count.
     * @param _tickBitmap The bitmap used to quickly find populated ticks.
     * @param _protocolFallbackAddr The address of the fallback contract.
     * @param _nonce The user EIP712 nonce.
     */
    struct Storage {
        // immutable
        int24 _tickSpacing;
        IERC20Metadata _asset;
        uint8 _assetDecimals;
        uint8 _priceFeedDecimals;
        IUsdn _usdn;
        IERC20Metadata _sdex;
        uint256 _usdnMinDivisor;
        // parameters
        IBaseOracleMiddleware _oracleMiddleware;
        IBaseLiquidationRewardsManager _liquidationRewardsManager;
        IBaseRebalancer _rebalancer;
        mapping(address => bool) _isRebalancer;
        uint256 _minLeverage;
        uint256 _maxLeverage;
        uint128 _lowLatencyValidatorDeadline;
        uint128 _onChainValidatorDeadline;
        uint256 _safetyMarginBps;
        uint16 _liquidationIteration;
        uint16 _protocolFeeBps;
        uint16 _rebalancerBonusBps;
        uint24 _liquidationPenalty;
        uint128 _EMAPeriod;
        uint256 _fundingSF;
        uint256 _feeThreshold;
        int256 _openExpoImbalanceLimitBps;
        int256 _withdrawalExpoImbalanceLimitBps;
        int256 _depositExpoImbalanceLimitBps;
        int256 _closeExpoImbalanceLimitBps;
        int256 _rebalancerCloseExpoImbalanceLimitBps;
        int256 _longImbalanceTargetBps;
        uint16 _positionFeeBps;
        uint16 _vaultFeeBps;
        uint16 _sdexRewardsRatioBps;
        uint32 _sdexBurnOnDepositRatio;
        address _feeCollector;
        uint64 _securityDepositValue;
        uint128 _targetUsdnPrice;
        uint128 _usdnRebaseThreshold;
        uint256 _minLongPosition;
        // state
        int256 _lastFundingPerDay;
        uint128 _lastPrice;
        uint128 _lastUpdateTimestamp;
        uint256 _pendingProtocolFee;
        // pending actions queue
        mapping(address => uint256) _pendingActions;
        DoubleEndedQueue.Deque _pendingActionsQueue;
        // vault
        uint256 _balanceVault;
        int256 _pendingBalanceVault;
        // long positions
        int256 _EMA;
        uint256 _balanceLong;
        uint256 _totalExpo;
        HugeUint.Uint512 _liqMultiplierAccumulator;
        mapping(int24 => uint256) _tickVersion;
        mapping(bytes32 => Position[]) _longPositions;
        mapping(bytes32 => TickData) _tickData;
        int24 _highestPopulatedTick;
        uint256 _totalLongPositions;
        LibBitmap.Bitmap _tickBitmap;
        // fallback
        address _protocolFallbackAddr;
        // EIP712
        mapping(address => uint256) _nonce;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title IUsdnProtocolVault
 * @notice Interface for the vault layer of the USDN protocol.
 */
interface IUsdnProtocolVault {
    /**
     * @notice Calculates the predicted USDN token price based on the given asset price and timestamp.
     * @dev The effects of the funding and the PnL of the long positions since the last contract state update are taken
     * into account.
     * @param currentPrice The current or predicted asset price.
     * @param timestamp The timestamp corresponding to `currentPrice`.
     * @return price_ The predicted USDN token price.
     */
    function usdnPrice(uint128 currentPrice, uint128 timestamp) external view returns (uint256 price_);

    /**
     * @notice Calculates the USDN token price based on the given asset price at the current timestamp.
     * @dev The effects of the funding and the PnL of the long positions since the last contract state update are taken
     * into account.
     * @param currentPrice The asset price at `block.timestamp`.
     * @return price_ The calculated USDN token price.
     */
    function usdnPrice(uint128 currentPrice) external view returns (uint256 price_);

    /**
     * @notice Gets the amount of assets in the vault for the given asset price and timestamp.
     * @dev The effects of the funding, the PnL of the long positions and the accumulated fees since the last contract
     * state update are taken into account, but not liquidations. If the provided timestamp is older than the last
     * state update, the function reverts with `UsdnProtocolTimestampTooOld`.
     * @param currentPrice The current or predicted asset price.
     * @param timestamp The timestamp corresponding to `currentPrice` (must not be earlier than `_lastUpdateTimestamp`).
     * @return available_ The available vault balance (cannot be less than 0).
     */
    function vaultAssetAvailableWithFunding(uint128 currentPrice, uint128 timestamp)
        external
        view
        returns (uint256 available_);
}
// SPDX-License-Identifier: MIT
// based on the OpenZeppelin implementation
pragma solidity ^0.8.20;

import { IUsdnProtocolTypes as Types } from "../interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";

/**
 * @notice A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends
 * of the sequence (called front and back).
 * @dev Storage use is optimized, and all operations are O(1) constant time.
 *
 * The struct is called `Deque` and holds {IUsdnProtocolTypes.PendingAction}'s. This data structure can only be used in
 * storage, and not in memory.
 */
library DoubleEndedQueue {
    /// @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
    error QueueEmpty();

    /// @dev A push operation couldn't be completed due to the queue being full.
    error QueueFull();

    /// @dev An operation (e.g. {atRaw}) couldn't be completed due to an index being out of bounds.
    error QueueOutOfBounds();

    /**
     * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * The first item is at `data[begin]` and the last item is at `data[end - 1]`. This range can wrap around.
     * @param _begin The index of the first item in the queue.
     * @param _end The index of the item after the last item in the queue.
     * @param _data The items in the queue.
     */
    struct Deque {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 index => Types.PendingAction) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     * Reverts with {QueueFull} if the queue is full.
     * @param deque The queue.
     * @param value The item to insert.
     * @return backIndex_ The raw index of the inserted item.
     */
    function pushBack(Deque storage deque, Types.PendingAction memory value) external returns (uint128 backIndex_) {
        unchecked {
            backIndex_ = deque._end;
            if (backIndex_ + 1 == deque._begin) {
                revert QueueFull();
            }
            deque._data[backIndex_] = value;
            deque._end = backIndex_ + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     * Reverts with {QueueEmpty} if the queue is empty.
     * @param deque The queue.
     * @return value_ The removed item.
     */
    function popBack(Deque storage deque) public returns (Types.PendingAction memory value_) {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex == deque._begin) {
                revert QueueEmpty();
            }
            --backIndex;
            value_ = deque._data[backIndex];
            delete deque._data[backIndex];
            deque._end = backIndex;
        }
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     * Reverts with {QueueFull} if the queue is full.
     * @param deque The queue.
     * @param value The item to insert.
     * @return frontIndex_ The raw index of the inserted item.
     */
    function pushFront(Deque storage deque, Types.PendingAction memory value) external returns (uint128 frontIndex_) {
        unchecked {
            frontIndex_ = deque._begin - 1;
            if (frontIndex_ == deque._end) {
                revert QueueFull();
            }
            deque._data[frontIndex_] = value;
            deque._begin = frontIndex_;
        }
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     * Reverts with {QueueEmpty} if the queue is empty.
     * @param deque The queue.
     * @return value_ The removed item.
     */
    function popFront(Deque storage deque) public returns (Types.PendingAction memory value_) {
        unchecked {
            uint128 frontIndex = deque._begin;
            if (frontIndex == deque._end) {
                revert QueueEmpty();
            }
            value_ = deque._data[frontIndex];
            delete deque._data[frontIndex];
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     * Reverts with {QueueEmpty} if the queue is empty.
     * @param deque The queue.
     * @return value_ The item at the front of the queue.
     * @return rawIndex_ The raw index of the returned item.
     */
    function front(Deque storage deque) external view returns (Types.PendingAction memory value_, uint128 rawIndex_) {
        if (empty(deque)) {
            revert QueueEmpty();
        }
        rawIndex_ = deque._begin;
        value_ = deque._data[rawIndex_];
    }

    /**
     * @dev Returns the item at the end of the queue.
     * Reverts with {QueueEmpty} if the queue is empty.
     * @param deque The queue.
     * @return value_ The item at the back of the queue.
     * @return rawIndex_ The raw index of the returned item.
     */
    function back(Deque storage deque) external view returns (Types.PendingAction memory value_, uint128 rawIndex_) {
        if (empty(deque)) {
            revert QueueEmpty();
        }
        unchecked {
            rawIndex_ = deque._end - 1;
            value_ = deque._data[rawIndex_];
        }
    }

    /**
     * @dev Returns the item at a position in the queue given by `index`, with the first item at 0 and the last item at
     * `length(deque) - 1`.
     * Reverts with {QueueOutOfBounds} if the index is out of bounds.
     * @param deque The queue.
     * @param index The index of the item to return.
     * @return value_ The item at the given index.
     * @return rawIndex_ The raw index of the item.
     */
    function at(Deque storage deque, uint256 index)
        external
        view
        returns (Types.PendingAction memory value_, uint128 rawIndex_)
    {
        if (index >= length(deque)) {
            revert QueueOutOfBounds();
        }
        // by construction, length is a uint128, so the check above ensures that
        // the index can be safely downcast to a uint128
        unchecked {
            rawIndex_ = deque._begin + uint128(index);
            value_ = deque._data[rawIndex_];
        }
    }

    /**
     * @dev Returns the item at a position in the queue given by `rawIndex`, indexing into the underlying storage array
     * directly.
     * Reverts with {QueueOutOfBounds} if the index is out of bounds.
     * @param deque The queue.
     * @param rawIndex The index of the item to return.
     * @return value_ The item at the given index.
     */
    function atRaw(Deque storage deque, uint128 rawIndex) external view returns (Types.PendingAction memory value_) {
        if (!isValid(deque, rawIndex)) {
            revert QueueOutOfBounds();
        }
        value_ = deque._data[rawIndex];
    }

    /**
     * @dev Deletes the item at a position in the queue given by `rawIndex`, indexing into the underlying storage array
     * directly. If clearing the front or back item, then the bounds are updated. Otherwise, the values are simply set
     * to zero and the queue's begin and end indices are not updated.
     * @param deque The queue.
     * @param rawIndex The index of the item to delete.
     */
    function clearAt(Deque storage deque, uint128 rawIndex) external {
        uint128 backIndex = deque._end;
        unchecked {
            backIndex--;
        }
        if (rawIndex == deque._begin) {
            popFront(deque); // reverts if empty
        } else if (rawIndex == backIndex) {
            popBack(deque); // reverts if empty
        } else {
            // we don't care to revert if this is not a valid index, since we're just clearing it
            delete deque._data[rawIndex];
        }
    }

    /**
     * @dev Checks if the raw index is valid (in bounds).
     * @param deque The queue.
     * @param rawIndex The raw index to check.
     * @return valid_ Whether the raw index is valid.
     */
    function isValid(Deque storage deque, uint128 rawIndex) public view returns (bool valid_) {
        if (deque._begin > deque._end) {
            // here the values are split at the beginning and end of the range, so invalid indices are in the middle
            if (rawIndex < deque._begin && rawIndex >= deque._end) {
                return false;
            }
        } else if (rawIndex < deque._begin || rawIndex >= deque._end) {
            return false;
        }
        valid_ = true;
    }

    /**
     * @dev Returns the number of items in the queue.
     * @param deque The queue.
     * @return length_ The number of items in the queue.
     */
    function length(Deque storage deque) public view returns (uint256 length_) {
        unchecked {
            length_ = uint256(deque._end - deque._begin);
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     * @param deque The queue.
     * @return empty_ True if the queue is empty.
     */
    function empty(Deque storage deque) internal view returns (bool empty_) {
        empty_ = deque._end == deque._begin;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title AllowanceTransfer
/// @notice Handles ERC20 token permissions through signature based allowance setting and ERC20 token transfers by checking allowed amounts
/// @dev Requires user's token approval on the Permit2 contract
interface IAllowanceTransfer is IEIP712 {
    /// @notice Thrown when an allowance on a token has expired.
    /// @param deadline The timestamp at which the allowed amount is no longer valid
    error AllowanceExpired(uint256 deadline);

    /// @notice Thrown when an allowance on a token has been depleted.
    /// @param amount The maximum amount allowed
    error InsufficientAllowance(uint256 amount);

    /// @notice Thrown when too many nonces are invalidated.
    error ExcessiveInvalidation();

    /// @notice Emits an event when the owner successfully invalidates an ordered nonce.
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );

    /// @notice Emits an event when the owner successfully sets permissions on a token for the spender.
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
    );

    /// @notice Emits an event when the owner successfully sets permissions using a permit signature on a token for the spender.
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );

    /// @notice Emits an event when the owner sets the allowance back to 0 with the lockdown function.
    event Lockdown(address indexed owner, address token, address spender);

    /// @notice The permit data for a token
    struct PermitDetails {
        // ERC20 token address
        address token;
        // the maximum amount allowed to spend
        uint160 amount;
        // timestamp at which a spender's token allowances become invalid
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice The permit message signed for a single token allowance
    struct PermitSingle {
        // the permit data for a single token alownce
        PermitDetails details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The permit message signed for multiple token allowances
    struct PermitBatch {
        // the permit data for multiple token allowances
        PermitDetails[] details;
        // address permissioned on the allowed tokens
        address spender;
        // deadline on the permit signature
        uint256 sigDeadline;
    }

    /// @notice The saved permissions
    /// @dev This info is saved per owner, per token, per spender and all signed over in the permit message
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    struct PackedAllowance {
        // amount allowed
        uint160 amount;
        // permission expiry
        uint48 expiration;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint48 nonce;
    }

    /// @notice A token spender pair.
    struct TokenSpenderPair {
        // the token the spender is approved
        address token;
        // the spender address
        address spender;
    }

    /// @notice Details for a token transfer.
    struct AllowanceTransferDetails {
        // the owner of the token
        address from;
        // the recipient of the token
        address to;
        // the amount of the token
        uint160 amount;
        // the token to be transferred
        address token;
    }

    /// @notice A mapping from owner address to token address to spender address to PackedAllowance struct, which contains details and conditions of the approval.
    /// @notice The mapping is indexed in the above order see: allowance[ownerAddress][tokenAddress][spenderAddress]
    /// @dev The packed slot holds the allowed amount, expiration at which the allowed amount is no longer valid, and current nonce thats updated on any signature based approvals.
    function allowance(address user, address token, address spender)
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);

    /// @notice Approves the spender to use up to amount of the specified token up until the expiration
    /// @param token The token to approve
    /// @param spender The spender address to approve
    /// @param amount The approved amount of the token
    /// @param expiration The timestamp at which the approval is no longer valid
    /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
    /// @dev Setting amount to type(uint160).max sets an unlimited approval
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;

    /// @notice Permit a spender to a given amount of the owners token via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitSingle Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;

    /// @notice Permit a spender to the signed amounts of the owners tokens via the owner's EIP-712 signature
    /// @dev May fail if the owner's nonce was invalidated in-flight by invalidateNonce
    /// @param owner The owner of the tokens being approved
    /// @param permitBatch Data signed over by the owner specifying the terms of approval
    /// @param signature The owner's signature over the permit data
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfer approved tokens in a batch
    /// @param transferDetails Array of owners, recipients, amounts, and tokens for the transfers
    /// @dev Requires the from addresses to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;

    /// @notice Enables performing a "lockdown" of the sender's Permit2 identity
    /// by batch revoking approvals
    /// @param approvals Array of approvals to revoke.
    function lockdown(TokenSpenderPair[] calldata approvals) external;

    /// @notice Invalidate nonces for a given (token, spender) pair
    /// @param token The token to invalidate nonces for
    /// @param spender The spender to invalidate nonces for
    /// @param newNonce The new nonce to set. Invalidates all nonces less than it.
    /// @dev Can't invalidate more than 2**16 nonces per transaction.
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeCast160 {
    /// @notice Thrown when a valude greater than type(uint160).max is cast to uint160
    error UnsafeCast();

    /// @notice Safely casts uint256 to uint160
    /// @param value The uint256 to be cast
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) revert UnsafeCast();
        return uint160(value);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {Constants} from '../libraries/Constants.sol';

contract LockAndMsgSender {
    error ContractLocked();

    address internal constant NOT_LOCKED_FLAG = address(1);
    address internal lockedBy = NOT_LOCKED_FLAG;

    modifier isNotLocked() {
        if (msg.sender != address(this)) {
            if (lockedBy != NOT_LOCKED_FLAG) revert ContractLocked();
            lockedBy = msg.sender;
            _;
            lockedBy = NOT_LOCKED_FLAG;
        } else {
            _;
        }
    }

    /// @notice Calculates the recipient address for a command
    /// @param recipient The recipient or recipient-flag for the command
    /// @return output The resultant recipient for the command
    function map(address recipient) internal view returns (address) {
        if (recipient == Constants.MSG_SENDER) {
            return lockedBy;
        } else if (recipient == Constants.ADDRESS_THIS) {
            return address(this);
        } else {
            return recipient;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IWETH9} from '../interfaces/external/IWETH9.sol';

/// @title Constant state
/// @notice Constant state used by the Universal Router
library Constants {
    /// @dev Used for identifying cases when this contract's balance of a token is to be used as an input
    /// This value is equivalent to 1<<255, i.e. a singular 1 in the most significant bit.
    uint256 internal constant CONTRACT_BALANCE = 0x8000000000000000000000000000000000000000000000000000000000000000;

    /// @dev Used for identifying cases when a v2 pair has already received input tokens
    uint256 internal constant ALREADY_PAID = 0;

    /// @dev Used as a flag for identifying the transfer of ETH instead of a token
    address internal constant ETH = address(0);

    /// @dev Used as a flag for identifying that msg.sender should be used, saves gas by sending more 0 bytes
    address internal constant MSG_SENDER = address(1);

    /// @dev Used as a flag for identifying address(this) should be used, saves gas by sending more 0 bytes
    address internal constant ADDRESS_THIS = address(2);

    /// @dev The length of the bytes encoded address
    uint256 internal constant ADDR_SIZE = 20;

    /// @dev The length of the bytes encoded fee
    uint256 internal constant V3_FEE_SIZE = 3;

    /// @dev The offset of a single token address (20) and pool fee (3)
    uint256 internal constant NEXT_V3_POOL_OFFSET = ADDR_SIZE + V3_FEE_SIZE;

    /// @dev The offset of an encoded pool key
    /// Token (20) + Fee (3) + Token (20) = 43
    uint256 internal constant V3_POP_OFFSET = NEXT_V3_POOL_OFFSET + ADDR_SIZE;

    /// @dev The minimum length of an encoding that contains 2 or more pools
    uint256 internal constant MULTIPLE_V3_POOLS_MIN_LENGTH = V3_POP_OFFSET + NEXT_V3_POOL_OFFSET;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {Constants} from '../libraries/Constants.sol';
import {PaymentsImmutables} from '../modules/PaymentsImmutables.sol';
import {SafeTransferLib} from 'solmate/src/utils/SafeTransferLib.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';
import {ERC721} from 'solmate/src/tokens/ERC721.sol';
import {ERC1155} from 'solmate/src/tokens/ERC1155.sol';

/// @title Payments contract
/// @notice Performs various operations around the payment of ETH and tokens
abstract contract Payments is PaymentsImmutables {
    using SafeTransferLib for ERC20;
    using SafeTransferLib for address;

    error InsufficientToken();
    error InsufficientETH();
    error InvalidBips();
    error InvalidSpender();

    uint256 internal constant FEE_BIPS_BASE = 10_000;

    /// @notice Pays an amount of ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive the payment
    /// @param value The amount to pay
    function pay(address token, address recipient, uint256 value) internal {
        if (token == Constants.ETH) {
            recipient.safeTransferETH(value);
        } else {
            if (value == Constants.CONTRACT_BALANCE) {
                value = ERC20(token).balanceOf(address(this));
            }

            ERC20(token).safeTransfer(recipient, value);
        }
    }

    /// @notice Approves a protocol to spend ERC20s in the router
    /// @param token The token to approve
    /// @param spender Which protocol to approve
    function approveERC20(ERC20 token, Spenders spender) internal {
        // check spender is one of our approved spenders
        address spenderAddress;
        /// @dev use 0 = Opensea Conduit for both Seaport v1.4 and v1.5
        if (spender == Spenders.OSConduit) spenderAddress = OPENSEA_CONDUIT;
        else if (spender == Spenders.Sudoswap) spenderAddress = SUDOSWAP;
        else revert InvalidSpender();

        // set approval
        token.safeApprove(spenderAddress, type(uint256).max);
    }

    /// @notice Pays a proportion of the contract's ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive payment
    /// @param bips Portion in bips of whole balance of the contract
    function payPortion(address token, address recipient, uint256 bips) internal {
        if (bips == 0 || bips > FEE_BIPS_BASE) revert InvalidBips();
        if (token == Constants.ETH) {
            uint256 balance = address(this).balance;
            uint256 amount = (balance * bips) / FEE_BIPS_BASE;
            recipient.safeTransferETH(amount);
        } else {
            uint256 balance = ERC20(token).balanceOf(address(this));
            uint256 amount = (balance * bips) / FEE_BIPS_BASE;
            ERC20(token).safeTransfer(recipient, amount);
        }
    }

    /// @notice Sweeps all of the contract's ERC20 or ETH to an address
    /// @param token The token to sweep (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive payment
    /// @param amountMinimum The minimum desired amount
    function sweep(address token, address recipient, uint256 amountMinimum) internal {
        uint256 balance;
        if (token == Constants.ETH) {
            balance = address(this).balance;
            if (balance < amountMinimum) revert InsufficientETH();
            if (balance > 0) recipient.safeTransferETH(balance);
        } else {
            balance = ERC20(token).balanceOf(address(this));
            if (balance < amountMinimum) revert InsufficientToken();
            if (balance > 0) ERC20(token).safeTransfer(recipient, balance);
        }
    }

    /// @notice Sweeps an ERC721 to a recipient from the contract
    /// @param token The ERC721 token to sweep
    /// @param recipient The address that will receive payment
    /// @param id The ID of the ERC721 to sweep
    function sweepERC721(address token, address recipient, uint256 id) internal {
        ERC721(token).safeTransferFrom(address(this), recipient, id);
    }

    /// @notice Sweeps all of the contract's ERC1155 to an address
    /// @param token The ERC1155 token to sweep
    /// @param recipient The address that will receive payment
    /// @param id The ID of the ERC1155 to sweep
    /// @param amountMinimum The minimum desired amount
    function sweepERC1155(address token, address recipient, uint256 id, uint256 amountMinimum) internal {
        uint256 balance = ERC1155(token).balanceOf(address(this), id);
        if (balance < amountMinimum) revert InsufficientToken();
        ERC1155(token).safeTransferFrom(address(this), recipient, id, balance, bytes(''));
    }

    /// @notice Wraps an amount of ETH into WETH
    /// @param recipient The recipient of the WETH
    /// @param amount The amount to wrap (can be CONTRACT_BALANCE)
    function wrapETH(address recipient, uint256 amount) internal {
        if (amount == Constants.CONTRACT_BALANCE) {
            amount = address(this).balance;
        } else if (amount > address(this).balance) {
            revert InsufficientETH();
        }
        if (amount > 0) {
            WETH9.deposit{value: amount}();
            if (recipient != address(this)) {
                WETH9.transfer(recipient, amount);
            }
        }
    }

    /// @notice Unwraps all of the contract's WETH into ETH
    /// @param recipient The recipient of the ETH
    /// @param amountMinimum The minimum amount of ETH desired
    function unwrapWETH9(address recipient, uint256 amountMinimum) internal {
        uint256 value = WETH9.balanceOf(address(this));
        if (value < amountMinimum) {
            revert InsufficientETH();
        }
        if (value > 0) {
            WETH9.withdraw(value);
            if (recipient != address(this)) {
                recipient.safeTransferETH(value);
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IWETH9} from '../interfaces/external/IWETH9.sol';
import {IAllowanceTransfer} from 'permit2/src/interfaces/IAllowanceTransfer.sol';

struct PaymentsParameters {
    address permit2;
    address weth9;
    address openseaConduit;
    address sudoswap;
}

contract PaymentsImmutables {
    /// @dev WETH9 address
    IWETH9 internal immutable WETH9;

    /// @dev Permit2 address
    IAllowanceTransfer internal immutable PERMIT2;

    /// @dev The address of OpenSea's conduit used in both Seaport 1.4 and Seaport 1.5
    address internal immutable OPENSEA_CONDUIT;

    // @dev The address of Sudoswap's router
    address internal immutable SUDOSWAP;

    enum Spenders {
        OSConduit,
        Sudoswap
    }

    constructor(PaymentsParameters memory params) {
        WETH9 = IWETH9(params.weth9);
        PERMIT2 = IAllowanceTransfer(params.permit2);
        OPENSEA_CONDUIT = params.openseaConduit;
        SUDOSWAP = params.sudoswap;
    }
}
pragma solidity ^0.8.17;

import {IAllowanceTransfer} from 'permit2/src/interfaces/IAllowanceTransfer.sol';
import {SafeCast160} from 'permit2/src/libraries/SafeCast160.sol';
import {Payments} from './Payments.sol';
import {Constants} from '../libraries/Constants.sol';

/// @title Payments through Permit2
/// @notice Performs interactions with Permit2 to transfer tokens
abstract contract Permit2Payments is Payments {
    using SafeCast160 for uint256;

    error FromAddressIsNotOwner();

    /// @notice Performs a transferFrom on Permit2
    /// @param token The token to transfer
    /// @param from The address to transfer from
    /// @param to The recipient of the transfer
    /// @param amount The amount to transfer
    function permit2TransferFrom(address token, address from, address to, uint160 amount) internal {
        PERMIT2.transferFrom(from, to, amount, token);
    }

    /// @notice Performs a batch transferFrom on Permit2
    /// @param batchDetails An array detailing each of the transfers that should occur
    function permit2TransferFrom(IAllowanceTransfer.AllowanceTransferDetails[] memory batchDetails, address owner)
        internal
    {
        uint256 batchLength = batchDetails.length;
        for (uint256 i = 0; i < batchLength; ++i) {
            if (batchDetails[i].from != owner) revert FromAddressIsNotOwner();
        }
        PERMIT2.transferFrom(batchDetails);
    }

    /// @notice Either performs a regular payment or transferFrom on Permit2, depending on the payer address
    /// @param token The token to transfer
    /// @param payer The address to pay for the transfer
    /// @param recipient The recipient of the transfer
    /// @param amount The amount to transfer
    function payOrPermit2Transfer(address token, address payer, address recipient, uint256 amount) internal {
        if (payer == address(this)) pay(token, recipient, amount);
        else permit2TransferFrom(token, payer, recipient, amount.toUint160());
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

struct UniswapParameters {
    address v2Factory;
    address v3Factory;
    bytes32 pairInitCodeHash;
    bytes32 poolInitCodeHash;
}

contract UniswapImmutables {
    /// @dev The address of UniswapV2Factory
    address internal immutable UNISWAP_V2_FACTORY;

    /// @dev The UniswapV2Pair initcodehash
    bytes32 internal immutable UNISWAP_V2_PAIR_INIT_CODE_HASH;

    /// @dev The address of UniswapV3Factory
    address internal immutable UNISWAP_V3_FACTORY;

    /// @dev The UniswapV3Pool initcodehash
    bytes32 internal immutable UNISWAP_V3_POOL_INIT_CODE_HASH;

    constructor(UniswapParameters memory params) {
        UNISWAP_V2_FACTORY = params.v2Factory;
        UNISWAP_V2_PAIR_INIT_CODE_HASH = params.pairInitCodeHash;
        UNISWAP_V3_FACTORY = params.v3Factory;
        UNISWAP_V3_POOL_INIT_CODE_HASH = params.poolInitCodeHash;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import {IUniswapV2Pair} from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

/// @title Uniswap v2 Helper Library
/// @notice Calculates the recipient address for a command
library UniswapV2Library {
    error InvalidReserves();
    error InvalidPath();

    /// @notice Calculates the v2 address for a pair without making any external calls
    /// @param factory The address of the v2 factory
    /// @param initCodeHash The hash of the pair initcode
    /// @param tokenA One of the tokens in the pair
    /// @param tokenB The other token in the pair
    /// @return pair The resultant v2 pair address
    function pairFor(address factory, bytes32 initCodeHash, address tokenA, address tokenB)
        internal
        pure
        returns (address pair)
    {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = pairForPreSorted(factory, initCodeHash, token0, token1);
    }

    /// @notice Calculates the v2 address for a pair and the pair's token0
    /// @param factory The address of the v2 factory
    /// @param initCodeHash The hash of the pair initcode
    /// @param tokenA One of the tokens in the pair
    /// @param tokenB The other token in the pair
    /// @return pair The resultant v2 pair address
    /// @return token0 The token considered token0 in this pair
    function pairAndToken0For(address factory, bytes32 initCodeHash, address tokenA, address tokenB)
        internal
        pure
        returns (address pair, address token0)
    {
        address token1;
        (token0, token1) = sortTokens(tokenA, tokenB);
        pair = pairForPreSorted(factory, initCodeHash, token0, token1);
    }

    /// @notice Calculates the v2 address for a pair assuming the input tokens are pre-sorted
    /// @param factory The address of the v2 factory
    /// @param initCodeHash The hash of the pair initcode
    /// @param token0 The pair's token0
    /// @param token1 The pair's token1
    /// @return pair The resultant v2 pair address
    function pairForPreSorted(address factory, bytes32 initCodeHash, address token0, address token1)
        private
        pure
        returns (address pair)
    {
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), initCodeHash)
                    )
                )
            )
        );
    }

    /// @notice Calculates the v2 address for a pair and fetches the reserves for each token
    /// @param factory The address of the v2 factory
    /// @param initCodeHash The hash of the pair initcode
    /// @param tokenA One of the tokens in the pair
    /// @param tokenB The other token in the pair
    /// @return pair The resultant v2 pair address
    /// @return reserveA The reserves for tokenA
    /// @return reserveB The reserves for tokenB
    function pairAndReservesFor(address factory, bytes32 initCodeHash, address tokenA, address tokenB)
        private
        view
        returns (address pair, uint256 reserveA, uint256 reserveB)
    {
        address token0;
        (pair, token0) = pairAndToken0For(factory, initCodeHash, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    /// @notice Given an input asset amount returns the maximum output amount of the other asset
    /// @param amountIn The token input amount
    /// @param reserveIn The reserves available of the input token
    /// @param reserveOut The reserves available of the output token
    /// @return amountOut The output amount of the output token
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        if (reserveIn == 0 || reserveOut == 0) revert InvalidReserves();
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /// @notice Returns the input amount needed for a desired output amount in a single-hop trade
    /// @param amountOut The desired output amount
    /// @param reserveIn The reserves available of the input token
    /// @param reserveOut The reserves available of the output token
    /// @return amountIn The input amount of the input token
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        if (reserveIn == 0 || reserveOut == 0) revert InvalidReserves();
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    /// @notice Returns the input amount needed for a desired output amount in a multi-hop trade
    /// @param factory The address of the v2 factory
    /// @param initCodeHash The hash of the pair initcode
    /// @param amountOut The desired output amount
    /// @param path The path of the multi-hop trade
    /// @return amount The input amount of the input token
    /// @return pair The first pair in the trade
    function getAmountInMultihop(address factory, bytes32 initCodeHash, uint256 amountOut, address[] memory path)
        internal
        view
        returns (uint256 amount, address pair)
    {
        if (path.length < 2) revert InvalidPath();
        amount = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            uint256 reserveIn;
            uint256 reserveOut;

            (pair, reserveIn, reserveOut) = pairAndReservesFor(factory, initCodeHash, path[i - 1], path[i]);
            amount = getAmountIn(amount, reserveIn, reserveOut);
        }
    }

    /// @notice Sorts two tokens to return token0 and token1
    /// @param tokenA The first token to sort
    /// @param tokenB The other token to sort
    /// @return token0 The smaller token by address value
    /// @return token1 The larger token by address value
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later

/// @title Library for Bytes Manipulation
pragma solidity ^0.8.0;

import {Constants} from '../../../libraries/Constants.sol';

library BytesLib {
    error SliceOutOfBounds();

    /// @notice Returns the address starting at byte 0
    /// @dev length and overflow checks must be carried out before calling
    /// @param _bytes The input bytes string to slice
    /// @return _address The address starting at byte 0
    function toAddress(bytes calldata _bytes) internal pure returns (address _address) {
        if (_bytes.length < Constants.ADDR_SIZE) revert SliceOutOfBounds();
        assembly {
            _address := shr(96, calldataload(_bytes.offset))
        }
    }

    /// @notice Returns the pool details starting at byte 0
    /// @dev length and overflow checks must be carried out before calling
    /// @param _bytes The input bytes string to slice
    /// @return token0 The address at byte 0
    /// @return fee The uint24 starting at byte 20
    /// @return token1 The address at byte 23
    function toPool(bytes calldata _bytes) internal pure returns (address token0, uint24 fee, address token1) {
        if (_bytes.length < Constants.V3_POP_OFFSET) revert SliceOutOfBounds();
        assembly {
            let firstWord := calldataload(_bytes.offset)
            token0 := shr(96, firstWord)
            fee := and(shr(72, firstWord), 0xffffff)
            token1 := shr(96, calldataload(add(_bytes.offset, 23)))
        }
    }

    /// @notice Decode the `_arg`-th element in `_bytes` as a dynamic array
    /// @dev The decoding of `length` and `offset` is universal,
    /// whereas the type declaration of `res` instructs the compiler how to read it.
    /// @param _bytes The input bytes string to slice
    /// @param _arg The index of the argument to extract
    /// @return length Length of the array
    /// @return offset Pointer to the data part of the array
    function toLengthOffset(bytes calldata _bytes, uint256 _arg)
        internal
        pure
        returns (uint256 length, uint256 offset)
    {
        uint256 relativeOffset;
        assembly {
            // The offset of the `_arg`-th element is `32 * arg`, which stores the offset of the length pointer.
            // shl(5, x) is equivalent to mul(32, x)
            let lengthPtr := add(_bytes.offset, calldataload(add(_bytes.offset, shl(5, _arg))))
            length := calldataload(lengthPtr)
            offset := add(lengthPtr, 0x20)
            relativeOffset := sub(offset, _bytes.offset)
        }
        if (_bytes.length < length + relativeOffset) revert SliceOutOfBounds();
    }

    /// @notice Decode the `_arg`-th element in `_bytes` as `bytes`
    /// @param _bytes The input bytes string to extract a bytes string from
    /// @param _arg The index of the argument to extract
    function toBytes(bytes calldata _bytes, uint256 _arg) internal pure returns (bytes calldata res) {
        (uint256 length, uint256 offset) = toLengthOffset(_bytes, _arg);
        assembly {
            res.length := length
            res.offset := offset
        }
    }

    /// @notice Decode the `_arg`-th element in `_bytes` as `address[]`
    /// @param _bytes The input bytes string to extract an address array from
    /// @param _arg The index of the argument to extract
    function toAddressArray(bytes calldata _bytes, uint256 _arg) internal pure returns (address[] calldata res) {
        (uint256 length, uint256 offset) = toLengthOffset(_bytes, _arg);
        assembly {
            res.length := length
            res.offset := offset
        }
    }

    /// @notice Decode the `_arg`-th element in `_bytes` as `bytes[]`
    /// @param _bytes The input bytes string to extract a bytes array from
    /// @param _arg The index of the argument to extract
    function toBytesArray(bytes calldata _bytes, uint256 _arg) internal pure returns (bytes[] calldata res) {
        (uint256 length, uint256 offset) = toLengthOffset(_bytes, _arg);
        assembly {
            res.length := length
            res.offset := offset
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;

import {BytesLib} from './BytesLib.sol';
import {Constants} from '../../../libraries/Constants.sol';

/// @title Functions for manipulating path data for multihop swaps
library V3Path {
    using BytesLib for bytes;

    /// @notice Returns true iff the path contains two or more pools
    /// @param path The encoded swap path
    /// @return True if path contains two or more pools, otherwise false
    function hasMultiplePools(bytes calldata path) internal pure returns (bool) {
        return path.length >= Constants.MULTIPLE_V3_POOLS_MIN_LENGTH;
    }

    /// @notice Decodes the first pool in path
    /// @param path The bytes encoded swap path
    /// @return tokenA The first token of the given pool
    /// @return fee The fee level of the pool
    /// @return tokenB The second token of the given pool
    function decodeFirstPool(bytes calldata path) internal pure returns (address, uint24, address) {
        return path.toPool();
    }

    /// @notice Gets the segment corresponding to the first pool in the path
    /// @param path The bytes encoded swap path
    /// @return The segment containing all data necessary to target the first pool in the path
    function getFirstPool(bytes calldata path) internal pure returns (bytes calldata) {
        return path[:Constants.V3_POP_OFFSET];
    }

    function decodeFirstToken(bytes calldata path) internal pure returns (address tokenA) {
        tokenA = path.toAddress();
    }

    /// @notice Skips a token + fee element
    /// @param path The swap path
    function skipToken(bytes calldata path) internal pure returns (bytes calldata) {
        return path[Constants.NEXT_V3_POOL_OFFSET:];
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {V3Path} from './V3Path.sol';
import {BytesLib} from './BytesLib.sol';
import {SafeCast} from '@uniswap/v3-core/contracts/libraries/SafeCast.sol';
import {IUniswapV3Pool} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import {IUniswapV3SwapCallback} from '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';
import {Constants} from '../../../libraries/Constants.sol';
import {Permit2Payments} from '../../Permit2Payments.sol';
import {UniswapImmutables} from '../UniswapImmutables.sol';
import {Constants} from '../../../libraries/Constants.sol';
import {ERC20} from 'solmate/src/tokens/ERC20.sol';

/// @title Router for Uniswap v3 Trades
abstract contract V3SwapRouter is UniswapImmutables, Permit2Payments, IUniswapV3SwapCallback {
    using V3Path for bytes;
    using BytesLib for bytes;
    using SafeCast for uint256;

    error V3InvalidSwap();
    error V3TooLittleReceived();
    error V3TooMuchRequested();
    error V3InvalidAmountOut();
    error V3InvalidCaller();

    /// @dev Used as the placeholder value for maxAmountIn, because the computed amount in for an exact output swap
    /// can never actually be this value
    uint256 private constant DEFAULT_MAX_AMOUNT_IN = type(uint256).max;

    /// @dev Transient storage variable used for checking slippage
    uint256 private maxAmountInCached = DEFAULT_MAX_AMOUNT_IN;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;

    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        if (amount0Delta <= 0 && amount1Delta <= 0) revert V3InvalidSwap(); // swaps entirely within 0-liquidity regions are not supported
        (, address payer) = abi.decode(data, (bytes, address));
        bytes calldata path = data.toBytes(0);

        // because exact output swaps are executed in reverse order, in this case tokenOut is actually tokenIn
        (address tokenIn, uint24 fee, address tokenOut) = path.decodeFirstPool();

        if (computePoolAddress(tokenIn, tokenOut, fee) != msg.sender) revert V3InvalidCaller();

        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0 ? (tokenIn < tokenOut, uint256(amount0Delta)) : (tokenOut < tokenIn, uint256(amount1Delta));

        if (isExactInput) {
            // Pay the pool (msg.sender)
            payOrPermit2Transfer(tokenIn, payer, msg.sender, amountToPay);
        } else {
            // either initiate the next swap or pay
            if (path.hasMultiplePools()) {
                // this is an intermediate step so the payer is actually this contract
                path = path.skipToken();
                _swap(-amountToPay.toInt256(), msg.sender, path, payer, false);
            } else {
                if (amountToPay > maxAmountInCached) revert V3TooMuchRequested();
                // note that because exact output swaps are executed in reverse order, tokenOut is actually tokenIn
                payOrPermit2Transfer(tokenOut, payer, msg.sender, amountToPay);
            }
        }
    }

    /// @notice Performs a Uniswap v3 exact input swap
    /// @param recipient The recipient of the output tokens
    /// @param amountIn The amount of input tokens for the trade
    /// @param amountOutMinimum The minimum desired amount of output tokens
    /// @param path The path of the trade as a bytes string
    /// @param payer The address that will be paying the input
    function v3SwapExactInput(
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum,
        bytes calldata path,
        address payer
    ) internal {
        // use amountIn == Constants.CONTRACT_BALANCE as a flag to swap the entire balance of the contract
        if (amountIn == Constants.CONTRACT_BALANCE) {
            address tokenIn = path.decodeFirstToken();
            amountIn = ERC20(tokenIn).balanceOf(address(this));
        }

        uint256 amountOut;
        while (true) {
            bool hasMultiplePools = path.hasMultiplePools();

            // the outputs of prior swaps become the inputs to subsequent ones
            (int256 amount0Delta, int256 amount1Delta, bool zeroForOne) = _swap(
                amountIn.toInt256(),
                hasMultiplePools ? address(this) : recipient, // for intermediate swaps, this contract custodies
                path.getFirstPool(), // only the first pool is needed
                payer, // for intermediate swaps, this contract custodies
                true
            );

            amountIn = uint256(-(zeroForOne ? amount1Delta : amount0Delta));

            // decide whether to continue or terminate
            if (hasMultiplePools) {
                payer = address(this);
                path = path.skipToken();
            } else {
                amountOut = amountIn;
                break;
            }
        }

        if (amountOut < amountOutMinimum) revert V3TooLittleReceived();
    }

    /// @notice Performs a Uniswap v3 exact output swap
    /// @param recipient The recipient of the output tokens
    /// @param amountOut The amount of output tokens to receive for the trade
    /// @param amountInMaximum The maximum desired amount of input tokens
    /// @param path The path of the trade as a bytes string
    /// @param payer The address that will be paying the input
    function v3SwapExactOutput(
        address recipient,
        uint256 amountOut,
        uint256 amountInMaximum,
        bytes calldata path,
        address payer
    ) internal {
        maxAmountInCached = amountInMaximum;
        (int256 amount0Delta, int256 amount1Delta, bool zeroForOne) =
            _swap(-amountOut.toInt256(), recipient, path, payer, false);

        uint256 amountOutReceived = zeroForOne ? uint256(-amount1Delta) : uint256(-amount0Delta);

        if (amountOutReceived != amountOut) revert V3InvalidAmountOut();

        maxAmountInCached = DEFAULT_MAX_AMOUNT_IN;
    }

    /// @dev Performs a single swap for both exactIn and exactOut
    /// For exactIn, `amount` is `amountIn`. For exactOut, `amount` is `-amountOut`
    function _swap(int256 amount, address recipient, bytes calldata path, address payer, bool isExactIn)
        private
        returns (int256 amount0Delta, int256 amount1Delta, bool zeroForOne)
    {
        (address tokenIn, uint24 fee, address tokenOut) = path.decodeFirstPool();

        zeroForOne = isExactIn ? tokenIn < tokenOut : tokenOut < tokenIn;

        (amount0Delta, amount1Delta) = IUniswapV3Pool(computePoolAddress(tokenIn, tokenOut, fee)).swap(
            recipient,
            zeroForOne,
            amount,
            (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1),
            abi.encode(path, payer)
        );
    }

    function computePoolAddress(address tokenA, address tokenB, uint24 fee) private view returns (address pool) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            UNISWAP_V3_FACTORY,
                            keccak256(abi.encode(tokenA, tokenB, fee)),
                            UNISWAP_V3_POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IUniswapV3PoolImmutables.sol';
import './pool/IUniswapV3PoolState.sol';
import './pool/IUniswapV3PoolDerivedState.sol';
import './pool/IUniswapV3PoolActions.sol';
import './pool/IUniswapV3PoolOwnerActions.sol';
import './pool/IUniswapV3PoolEvents.sol';

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        // Storing these outside the loop saves ~15 gas per iteration.
        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/// @notice A generic interface for a contract which properly accepts ERC1155 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import {
    UniswapImmutables,
    UniswapParameters
} from "@uniswap/universal-router/contracts/modules/uniswap/UniswapImmutables.sol";
import {
    PaymentsImmutables, PaymentsParameters
} from "@uniswap/universal-router/contracts/modules/PaymentsImmutables.sol";

import { Dispatcher } from "./base/Dispatcher.sol";
import { IUniversalRouter } from "./interfaces/IUniversalRouter.sol";
import { RouterParameters } from "./base/RouterImmutables.sol";
import { Commands } from "./libraries/Commands.sol";
import { UsdnProtocolImmutables, UsdnProtocolParameters } from "./modules/usdn/UsdnProtocolImmutables.sol";
import { LidoImmutables } from "./modules/lido/LidoImmutables.sol";
import { SmardexImmutables, SmardexParameters } from "./modules/smardex/SmardexImmutables.sol";

contract UniversalRouter is IUniversalRouter, Dispatcher {
    /**
     * @notice Reverts if the transaction deadline has passed
     * @param deadline The deadline to check
     */
    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert TransactionDeadlinePassed();
        _;
    }

    /**
     * @param params The immutable parameters of the router
     */
    constructor(RouterParameters memory params)
        UniswapImmutables(
            UniswapParameters(params.v2Factory, params.v3Factory, params.pairInitCodeHash, params.poolInitCodeHash)
        )
        PaymentsImmutables(PaymentsParameters(params.permit2, params.weth9, address(0), address(0)))
        UsdnProtocolImmutables(UsdnProtocolParameters(params.usdnProtocol, params.wusdn, params.permit2))
        LidoImmutables(params.wstEth)
        SmardexImmutables(SmardexParameters(params.smardexFactory, params.weth9, params.permit2))
    { }

    /// @inheritdoc IUniversalRouter
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline)
        external
        payable
        checkDeadline(deadline)
    {
        execute(commands, inputs);
    }

    /// @inheritdoc IUniversalRouter
    function execute(bytes calldata commands, bytes[] calldata inputs) public payable isNotLocked {
        bool success;
        bytes memory output;
        uint256 numCommands = commands.length;
        if (inputs.length != numCommands) {
            revert LengthMismatch();
        }

        // loop through all given commands, execute them and pass along outputs as defined
        for (uint256 commandIndex = 0; commandIndex < numCommands;) {
            bytes1 command = commands[commandIndex];

            bytes calldata input = inputs[commandIndex];

            (success, output) = dispatch(command, input);

            if (!success && successRequired(command)) {
                revert ExecutionFailed({ commandIndex: commandIndex, message: output });
            }

            unchecked {
                commandIndex++;
            }
        }
    }

    /**
     * @notice Verifies if a command requires success or not
     * @param command The command to check
     * @return True if the command requires success, false otherwise
     */
    function successRequired(bytes1 command) internal pure returns (bool) {
        return command & Commands.FLAG_ALLOW_REVERT == 0;
    }

    /// @notice To receive ETH from WETH
    receive() external payable { }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import { Payments } from "@uniswap/universal-router/contracts/modules/Payments.sol";
import { BytesLib } from "@uniswap/universal-router/contracts/modules/uniswap/v3/BytesLib.sol";
import { V3SwapRouter } from "@uniswap/universal-router/contracts/modules/uniswap/v3/V3SwapRouter.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { IUsdnProtocolTypes } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";

import { IUsdnProtocolRouterTypes } from "../interfaces/usdn/IUsdnProtocolRouterTypes.sol";
import { IPaymentLibTypes } from "../interfaces/usdn/IPaymentLibTypes.sol";
import { ISmardexRouter } from "../interfaces/smardex/ISmardexRouter.sol";
import { Commands } from "../libraries/Commands.sol";
import { UsdnProtocolRouterLib } from "../libraries/usdn/UsdnProtocolRouterLib.sol";
import { SmardexRouterLib } from "../libraries/smardex/SmardexRouterLib.sol";
import { LidoRouterLib } from "../libraries/lido/LidoRouterLib.sol";
import { UniswapV2RouterLib } from "../libraries/uniswap/UniswapV2RouterLib.sol";
import { LidoImmutables } from "../modules/lido/LidoImmutables.sol";
import { SmardexRouter } from "../modules/smardex/SmardexRouter.sol";
import { UsdnProtocolRouter } from "../modules/usdn/UsdnProtocolRouter.sol";
import { Sweep } from "../modules/Sweep.sol";
import { LockAndMap } from "../modules/usdn/LockAndMap.sol";

/**
 * @title Decodes and Executes Commands
 * @notice Called by the UniversalRouter contract to efficiently decode and execute a singular command
 */
abstract contract Dispatcher is
    Payments,
    Sweep,
    V3SwapRouter,
    SmardexRouter,
    LockAndMap,
    UsdnProtocolRouter,
    LidoImmutables
{
    using BytesLib for bytes;

    /**
     * @notice Indicates that the command type is invalid
     * @param commandType The command type
     */
    error InvalidCommandType(uint256 commandType);

    /**
     * @notice Decodes and executes the given command with the given inputs
     * @dev 2 masks are used to enable use of a nested-if statement in execution for efficiency reasons
     * @param commandType The command type to execute
     * @param inputs The inputs to execute the command with
     * @return success_ True on success of the command, false on failure
     * @return output_ The outputs or error messages, if any, from the command
     */
    function dispatch(bytes1 commandType, bytes calldata inputs)
        internal
        returns (bool success_, bytes memory output_)
    {
        uint256 command = uint8(commandType & Commands.COMMAND_TYPE_MASK);

        success_ = true;

        if (command < Commands.FOURTH_IF_BOUNDARY) {
            if (command < Commands.THIRD_IF_BOUNDARY) {
                if (command < Commands.SECOND_IF_BOUNDARY) {
                    if (command < Commands.FIRST_IF_BOUNDARY) {
                        if (command == Commands.V3_SWAP_EXACT_IN) {
                            // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                            address recipient;
                            uint256 amountIn;
                            uint256 amountOutMin;
                            bool payerIsUser;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amountIn := calldataload(add(inputs.offset, 0x20))
                                amountOutMin := calldataload(add(inputs.offset, 0x40))
                                // 0x60 offset is the path, decoded below
                                payerIsUser := calldataload(add(inputs.offset, 0x80))
                            }
                            bytes calldata path = inputs.toBytes(3);
                            address payer = payerIsUser ? lockedBy : address(this);
                            v3SwapExactInput(map(recipient), amountIn, amountOutMin, path, payer);
                        } else if (command == Commands.V3_SWAP_EXACT_OUT) {
                            // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                            address recipient;
                            uint256 amountOut;
                            uint256 amountInMax;
                            bool payerIsUser;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amountOut := calldataload(add(inputs.offset, 0x20))
                                amountInMax := calldataload(add(inputs.offset, 0x40))
                                // 0x60 offset is the path, decoded below
                                payerIsUser := calldataload(add(inputs.offset, 0x80))
                            }
                            bytes calldata path = inputs.toBytes(3);
                            address payer = payerIsUser ? lockedBy : address(this);
                            v3SwapExactOutput(map(recipient), amountOut, amountInMax, path, payer);
                        } else if (command == Commands.PERMIT2_TRANSFER_FROM) {
                            // equivalent: abi.decode(inputs, (address, address, uint160))
                            address token;
                            address recipient;
                            uint160 amount;
                            assembly {
                                token := calldataload(inputs.offset)
                                recipient := calldataload(add(inputs.offset, 0x20))
                                amount := calldataload(add(inputs.offset, 0x40))
                            }
                            permit2TransferFrom(token, lockedBy, map(recipient), amount);
                        } else if (command == Commands.PERMIT2_PERMIT_BATCH) {
                            (IAllowanceTransfer.PermitBatch memory permitBatch,) =
                                abi.decode(inputs, (IAllowanceTransfer.PermitBatch, bytes));
                            bytes calldata data = inputs.toBytes(1);
                            PERMIT2.permit(lockedBy, permitBatch, data);
                        } else if (command == Commands.SWEEP) {
                            // equivalent:  abi.decode(inputs, (address, address, uint256, uint256))
                            address token;
                            address recipient;
                            uint256 amountOutMin;
                            uint256 amountOutThreshold;
                            assembly {
                                token := calldataload(inputs.offset)
                                recipient := calldataload(add(inputs.offset, 0x20))
                                amountOutMin := calldataload(add(inputs.offset, 0x40))
                                amountOutThreshold := calldataload(add(inputs.offset, 0x60))
                            }
                            Sweep.sweep(token, map(recipient), amountOutMin, amountOutThreshold);
                        } else if (command == Commands.TRANSFER) {
                            // equivalent:  abi.decode(inputs, (address, address, uint256))
                            address token;
                            address recipient;
                            uint256 value;
                            assembly {
                                token := calldataload(inputs.offset)
                                recipient := calldataload(add(inputs.offset, 0x20))
                                value := calldataload(add(inputs.offset, 0x40))
                            }
                            Payments.pay(token, map(recipient), value);
                        } else if (command == Commands.PAY_PORTION) {
                            // equivalent:  abi.decode(inputs, (address, address, uint256))
                            address token;
                            address recipient;
                            uint256 bips;
                            assembly {
                                token := calldataload(inputs.offset)
                                recipient := calldataload(add(inputs.offset, 0x20))
                                bips := calldataload(add(inputs.offset, 0x40))
                            }
                            Payments.payPortion(token, map(recipient), bips);
                        } else {
                            revert InvalidCommandType(command);
                        }
                    } else {
                        if (command == Commands.V2_SWAP_EXACT_IN) {
                            // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                            address recipient;
                            uint256 amountIn;
                            uint256 amountOutMin;
                            bool payerIsUser;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amountIn := calldataload(add(inputs.offset, 0x20))
                                amountOutMin := calldataload(add(inputs.offset, 0x40))
                                // 0x60 offset is the path, decoded below
                                payerIsUser := calldataload(add(inputs.offset, 0x80))
                            }
                            address[] calldata path = inputs.toAddressArray(3);
                            address payer = payerIsUser ? lockedBy : address(this);
                            UniswapV2RouterLib.v2SwapExactInput(
                                UNISWAP_V2_FACTORY,
                                UNISWAP_V2_PAIR_INIT_CODE_HASH,
                                PERMIT2,
                                map(recipient),
                                amountIn,
                                amountOutMin,
                                path,
                                payer
                            );
                        } else if (command == Commands.V2_SWAP_EXACT_OUT) {
                            // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                            address recipient;
                            uint256 amountOut;
                            uint256 amountInMax;
                            bool payerIsUser;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amountOut := calldataload(add(inputs.offset, 0x20))
                                amountInMax := calldataload(add(inputs.offset, 0x40))
                                // 0x60 offset is the path, decoded below
                                payerIsUser := calldataload(add(inputs.offset, 0x80))
                            }
                            address[] calldata path = inputs.toAddressArray(3);
                            address payer = payerIsUser ? lockedBy : address(this);
                            UniswapV2RouterLib.v2SwapExactOutput(
                                UNISWAP_V2_FACTORY,
                                UNISWAP_V2_PAIR_INIT_CODE_HASH,
                                PERMIT2,
                                map(recipient),
                                amountOut,
                                amountInMax,
                                path,
                                payer
                            );
                        } else if (command == Commands.PERMIT2_PERMIT) {
                            // equivalent: abi.decode(inputs, (IAllowanceTransfer.PermitSingle, bytes))
                            IAllowanceTransfer.PermitSingle calldata permitSingle;
                            assembly {
                                permitSingle := inputs.offset
                            }
                            bytes calldata data = inputs.toBytes(6); // permitSingle takes first 6 slots (0..5)
                            PERMIT2.permit(lockedBy, permitSingle, data);
                        } else if (command == Commands.WRAP_ETH) {
                            // equivalent: abi.decode(inputs, (address, uint256))
                            address recipient;
                            uint256 amount;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amount := calldataload(add(inputs.offset, 0x20))
                            }
                            Payments.wrapETH(map(recipient), amount);
                        } else if (command == Commands.UNWRAP_WETH) {
                            // equivalent: abi.decode(inputs, (address, uint256))
                            address recipient;
                            uint256 amountMin;
                            assembly {
                                recipient := calldataload(inputs.offset)
                                amountMin := calldataload(add(inputs.offset, 0x20))
                            }
                            Payments.unwrapWETH9(map(recipient), amountMin);
                        } else if (command == Commands.PERMIT2_TRANSFER_FROM_BATCH) {
                            (IAllowanceTransfer.AllowanceTransferDetails[] memory batchDetails) =
                                abi.decode(inputs, (IAllowanceTransfer.AllowanceTransferDetails[]));
                            permit2TransferFrom(batchDetails, lockedBy);
                        } else if (command == Commands.PERMIT) {
                            /*
                                equivalent: abi.decode(
                                    inputs, (
                                        address,
                                        address,
                                        address,
                                        uint256,
                                        uint256,
                                        uint8,
                                        bytes32,
                                        bytes32
                                    )
                                )
                            */
                            address token;
                            address owner;
                            address spender;
                            uint256 amount;
                            uint256 deadline;
                            uint8 v;
                            bytes32 r;
                            bytes32 s;
                            assembly {
                                token := calldataload(inputs.offset)
                                owner := calldataload(add(inputs.offset, 0x20))
                                spender := calldataload(add(inputs.offset, 0x40))
                                amount := calldataload(add(inputs.offset, 0x60))
                                deadline := calldataload(add(inputs.offset, 0x80))
                                v := calldataload(add(inputs.offset, 0xa0))
                                r := calldataload(add(inputs.offset, 0xc0))
                                s := calldataload(add(inputs.offset, 0xe0))
                            }
                            // protect against griefing
                            (success_, output_) = token.call(
                                abi.encodeWithSelector(
                                    IERC20Permit.permit.selector, owner, spender, amount, deadline, v, r, s
                                )
                            );
                        } else if (command == Commands.TRANSFER_FROM) {
                            // equivalent:  abi.decode(inputs, (address, address, uint256))
                            address token;
                            address recipient;
                            uint256 amount;
                            assembly {
                                token := calldataload(inputs.offset)
                                recipient := calldataload(add(inputs.offset, 0x20))
                                amount := calldataload(add(inputs.offset, 0x40))
                            }

                            (success_, output_) = token.call(
                                abi.encodeWithSelector(IERC20.transferFrom.selector, lockedBy, map(recipient), amount)
                            );
                        } else {
                            revert InvalidCommandType(command);
                        }
                    }
                } else {
                    // comment for the eights actions(INITIATE and VALIDATE) of the USDN protocol
                    // we don't allow the transaction to revert if the actions was not successful (due to pending
                    // liquidations), so we ignore the success boolean. This is because it's important to perform
                    // liquidations if they are needed, and it would be a big waste of gas for the user to revert
                    if (command == Commands.INITIATE_DEPOSIT) {
                        IUsdnProtocolRouterTypes.InitiateDepositData memory data =
                            abi.decode(inputs, (IUsdnProtocolRouterTypes.InitiateDepositData));
                        data.to = _mapSafe(data.to);
                        data.validator = _mapSafe(data.validator);
                        UsdnProtocolRouterLib.usdnInitiateDeposit(PROTOCOL_ASSET, USDN_PROTOCOL, data);
                    } else if (command == Commands.INITIATE_WITHDRAWAL) {
                        (
                            IPaymentLibTypes.PaymentType payment,
                            uint256 usdnShares,
                            uint256 amountOutMin,
                            address to,
                            address validator,
                            uint256 deadline,
                            bytes memory currentPriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 ethAmount
                        ) = abi.decode(
                            inputs,
                            (
                                IPaymentLibTypes.PaymentType,
                                uint256,
                                uint256,
                                address,
                                address,
                                uint256,
                                bytes,
                                IUsdnProtocolTypes.PreviousActionsData,
                                uint256
                            )
                        );
                        UsdnProtocolRouterLib.usdnInitiateWithdrawal(
                            USDN,
                            USDN_PROTOCOL,
                            payment,
                            usdnShares,
                            amountOutMin,
                            _mapSafe(to),
                            _mapSafe(validator),
                            deadline,
                            currentPriceData,
                            previousActionsData,
                            ethAmount
                        );
                    } else if (command == Commands.INITIATE_OPEN) {
                        IUsdnProtocolRouterTypes.InitiateOpenPositionData memory data =
                            abi.decode(inputs, (IUsdnProtocolRouterTypes.InitiateOpenPositionData));
                        data.to = _mapSafe(data.to);
                        data.validator = _mapSafe(data.validator);
                        UsdnProtocolRouterLib.usdnInitiateOpenPosition(PROTOCOL_ASSET, USDN_PROTOCOL, data);
                    } else if (command == Commands.INITIATE_CLOSE) {
                        (IUsdnProtocolRouterTypes.InitiateClosePositionData memory data) =
                            abi.decode(inputs, (IUsdnProtocolRouterTypes.InitiateClosePositionData));
                        // slither-disable-next-line arbitrary-send-eth
                        (success_, output_) = address(USDN_PROTOCOL).call{ value: data.ethAmount }(
                            abi.encodeWithSelector(
                                USDN_PROTOCOL.initiateClosePosition.selector,
                                data.posId,
                                data.amountToClose,
                                data.userMinPrice,
                                data.to,
                                payable(data.validator),
                                data.deadline,
                                data.currentPriceData,
                                data.previousActionsData,
                                data.delegationSignature
                            )
                        );
                    } else if (command == Commands.VALIDATE_DEPOSIT) {
                        (
                            address validator,
                            bytes memory depositPriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 ethAmount
                        ) = abi.decode(inputs, (address, bytes, IUsdnProtocolTypes.PreviousActionsData, uint256));
                        UsdnProtocolRouterLib.usdnValidateDeposit(
                            USDN_PROTOCOL, map(validator), depositPriceData, previousActionsData, ethAmount
                        );
                    } else if (command == Commands.VALIDATE_WITHDRAWAL) {
                        (
                            address validator,
                            bytes memory withdrawalPriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 ethAmount
                        ) = abi.decode(inputs, (address, bytes, IUsdnProtocolTypes.PreviousActionsData, uint256));
                        UsdnProtocolRouterLib.usdnValidateWithdrawal(
                            USDN_PROTOCOL, map(validator), withdrawalPriceData, previousActionsData, ethAmount
                        );
                    } else if (command == Commands.VALIDATE_OPEN) {
                        (
                            address validator,
                            bytes memory depositPriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 ethAmount
                        ) = abi.decode(inputs, (address, bytes, IUsdnProtocolTypes.PreviousActionsData, uint256));
                        UsdnProtocolRouterLib.usdnValidateOpenPosition(
                            USDN_PROTOCOL, map(validator), depositPriceData, previousActionsData, ethAmount
                        );
                    } else if (command == Commands.VALIDATE_CLOSE) {
                        (
                            address validator,
                            bytes memory closePriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 ethAmount
                        ) = abi.decode(inputs, (address, bytes, IUsdnProtocolTypes.PreviousActionsData, uint256));
                        UsdnProtocolRouterLib.usdnValidateClosePosition(
                            USDN_PROTOCOL, map(validator), closePriceData, previousActionsData, ethAmount
                        );
                    } else if (command == Commands.LIQUIDATE) {
                        // equivalent: abi.decode(inputs, (bytes, uint256))
                        uint256 ethAmount;
                        assembly {
                            // 0x00 offset is the currentPriceData, decoded below
                            ethAmount := calldataload(add(inputs.offset, 0x20))
                        }
                        bytes memory currentPriceData = inputs.toBytes(0);
                        UsdnProtocolRouterLib.usdnLiquidate(USDN_PROTOCOL, currentPriceData, ethAmount);
                    } else if (command == Commands.VALIDATE_PENDING) {
                        (
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            uint256 maxValidations,
                            uint256 ethAmount
                        ) = abi.decode(inputs, (IUsdnProtocolTypes.PreviousActionsData, uint256, uint256));
                        UsdnProtocolRouterLib.usdnValidateActionablePendingActions(
                            USDN_PROTOCOL, previousActionsData, maxValidations, ethAmount
                        );
                    } else if (command == Commands.TRANSFER_POSITION_OWNERSHIP) {
                        (IUsdnProtocolTypes.PositionId memory posId, address newOwner, bytes memory delegationSignature)
                        = abi.decode(inputs, (IUsdnProtocolTypes.PositionId, address, bytes));
                        (success_, output_) = address(USDN_PROTOCOL).call(
                            abi.encodeWithSelector(
                                USDN_PROTOCOL.transferPositionOwnership.selector,
                                posId,
                                map(newOwner),
                                delegationSignature
                            )
                        );
                    } else if (command == Commands.REBALANCER_INITIATE_DEPOSIT) {
                        // equivalent: abi.decode(inputs, (uint256, address))
                        uint256 amount;
                        address to;
                        assembly {
                            amount := calldataload(inputs.offset)
                            to := calldataload(add(inputs.offset, 0x20))
                        }
                        (success_, output_) =
                            UsdnProtocolRouterLib.rebalancerInitiateDeposit(USDN_PROTOCOL, amount, map(to));
                    } else if (command == Commands.REBALANCER_INITIATE_CLOSE) {
                        (
                            uint88 amount,
                            address to,
                            address validator,
                            uint256 userMinPrice,
                            uint256 deadline,
                            bytes memory currentPriceData,
                            IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
                            bytes memory delegationData,
                            uint256 ethAmount
                        ) = abi.decode(
                            inputs,
                            (
                                uint88,
                                address,
                                address,
                                uint256,
                                uint256,
                                bytes,
                                IUsdnProtocolTypes.PreviousActionsData,
                                bytes,
                                uint256
                            )
                        );
                        (success_, output_) = UsdnProtocolRouterLib.rebalancerInitiateClosePosition(
                            USDN_PROTOCOL,
                            amount,
                            _mapSafe(to),
                            payable(_mapSafe(validator)),
                            userMinPrice,
                            deadline,
                            currentPriceData,
                            previousActionsData,
                            delegationData,
                            ethAmount
                        );
                    } else {
                        revert InvalidCommandType(command);
                    }
                }
            } else {
                if (command == Commands.WRAP_USDN) {
                    // equivalent: abi.decode(inputs, (uint256, address))
                    uint256 usdnSharesAmount;
                    address recipient;
                    assembly {
                        usdnSharesAmount := calldataload(inputs.offset)
                        recipient := calldataload(add(inputs.offset, 0x20))
                    }
                    UsdnProtocolRouterLib.wrapUSDNShares(USDN, WUSDN, usdnSharesAmount, map(recipient));
                } else if (command == Commands.UNWRAP_WUSDN) {
                    // equivalent: abi.decode(inputs, (uint256, address))
                    uint256 wusdnAmount;
                    address recipient;
                    assembly {
                        wusdnAmount := calldataload(inputs.offset)
                        recipient := calldataload(add(inputs.offset, 0x20))
                    }
                    UsdnProtocolRouterLib.unwrapUSDN(WUSDN, wusdnAmount, map(recipient));
                } else if (command == Commands.WRAP_STETH) {
                    // equivalent: abi.decode(inputs, (uint256, address))
                    uint256 stethAmount;
                    address recipient;
                    assembly {
                        stethAmount := calldataload(inputs.offset)
                        recipient := calldataload(add(inputs.offset, 0x20))
                    }
                    success_ = LidoRouterLib.wrapSTETH(STETH, WSTETH, stethAmount, map(recipient));
                } else if (command == Commands.UNWRAP_WSTETH) {
                    // equivalent: abi.decode(inputs, (uint256, address))
                    uint256 wstethAmount;
                    address recipient;
                    assembly {
                        wstethAmount := calldataload(inputs.offset)
                        recipient := calldataload(add(inputs.offset, 0x20))
                    }
                    success_ = LidoRouterLib.unwrapWSTETH(STETH, WSTETH, wstethAmount, map(recipient));
                } else if (command == Commands.USDN_TRANSFER_SHARES_FROM) {
                    // equivalent:  abi.decode(inputs, (address, uint256))
                    address recipient;
                    uint256 sharesAmount;
                    assembly {
                        recipient := calldataload(inputs.offset)
                        sharesAmount := calldataload(add(inputs.offset, 0x20))
                    }
                    (success_, output_) = address(USDN).call(
                        abi.encodeWithSelector(USDN.transferSharesFrom.selector, lockedBy, map(recipient), sharesAmount)
                    );
                } else {
                    revert InvalidCommandType(command);
                }
            }
        } else {
            if (command == Commands.SMARDEX_SWAP_EXACT_IN) {
                // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                address recipient;
                uint256 amountIn;
                uint256 amountOutMin;
                bool payerIsUser;
                assembly {
                    recipient := calldataload(inputs.offset)
                    amountIn := calldataload(add(inputs.offset, 0x20))
                    amountOutMin := calldataload(add(inputs.offset, 0x40))
                    // 0x60 offset is the path, decoded below
                    payerIsUser := calldataload(add(inputs.offset, 0x80))
                }
                bytes calldata path = inputs.toBytes(3);
                address payer = payerIsUser ? lockedBy : address(this);
                _smardexSwapExactInput(map(recipient), amountIn, amountOutMin, path, payer);
            } else if (command == Commands.SMARDEX_SWAP_EXACT_OUT) {
                // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                address recipient;
                uint256 amountOut;
                uint256 amountInMax;
                bool payerIsUser;
                assembly {
                    recipient := calldataload(inputs.offset)
                    amountOut := calldataload(add(inputs.offset, 0x20))
                    amountInMax := calldataload(add(inputs.offset, 0x40))
                    // 0x60 offset is the path, decoded below
                    payerIsUser := calldataload(add(inputs.offset, 0x80))
                }
                bytes calldata path = inputs.toBytes(3);
                address payer = payerIsUser ? lockedBy : address(this);
                _smardexSwapExactOutput(map(recipient), amountOut, amountInMax, path, payer);
            } else if (command == Commands.SMARDEX_ADD_LIQUIDITY) {
                (ISmardexRouter.AddLiquidityParams memory params, address to, bool payerIsUser, uint256 deadline) =
                    abi.decode(inputs, (ISmardexRouter.AddLiquidityParams, address, bool, uint256));
                address payer = payerIsUser ? lockedBy : address(this);
                (success_, output_) = SmardexRouterLib.addLiquidity(SMARDEX_FACTORY, params, map(to), payer, deadline);
            } else if (command == Commands.SMARDEX_REMOVE_LIQUIDITY) {
                (ISmardexRouter.RemoveLiquidityParams memory params, address to, bool payerIsUser, uint256 deadline) =
                    abi.decode(inputs, (ISmardexRouter.RemoveLiquidityParams, address, bool, uint256));
                address payer = payerIsUser ? lockedBy : address(this);
                (success_, output_) =
                    SmardexRouterLib.removeLiquidity(SMARDEX_FACTORY, PERMIT2, params, map(to), payer, deadline);
            } else {
                revert InvalidCommandType(command);
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IUsdnProtocol } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocol.sol";
import { IWusdn } from "usdn-contracts/src/interfaces/Usdn/IWusdn.sol";

import { ISmardexFactory } from "../interfaces/smardex/ISmardexFactory.sol";

/**
 * @dev Structure to hold the immutable parameters for the router
 * @param permit2 The permit2 address
 * @param weth9 The WETH9 address
 * @param v2Factory The v2 factory address
 * @param v3Factory The v3 factory address
 * @param pairInitCodeHash The v2 pair hash
 * @param poolInitCodeHash The v3 pool hash
 * @param usdnProtocol The USDN protocol address
 * @param wstEth The WstETH address
 * @param wusdn The wrapped usdn address
 * @param smardexFactory The smardex factory
 */
struct RouterParameters {
    address permit2;
    address weth9;
    address v2Factory;
    address v3Factory;
    bytes32 pairInitCodeHash;
    bytes32 poolInitCodeHash;
    IUsdnProtocol usdnProtocol;
    address wstEth;
    IWusdn wusdn;
    ISmardexFactory smardexFactory;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISweepErrors {
    /// @notice Reverts when the recipient is invalid
    error SweepInvalidRecipient();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniversalRouter {
    /**
     * @notice Indicates that a required command has failed
     * @param commandIndex The index of the command that failed
     * @param message The error message
     */
    error ExecutionFailed(uint256 commandIndex, bytes message);

    /// @notice Thrown when attempting to send ETH directly to the contract
    error ETHNotAccepted();

    /// @notice Thrown when executing commands with an expired deadline
    error TransactionDeadlinePassed();

    /// @notice Thrown when attempting to execute commands and an incorrect number of inputs are provided
    error LengthMismatch();

    /**
     * @notice Executes encoded commands along with provided inputs. Reverts if the deadline has expired
     * @param commands A set of concatenated commands, each 1 byte in length
     * @param inputs An array of byte strings containing abi encoded inputs for each command
     * @param deadline The deadline by which the transaction must be executed
     */
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;

    /**
     * @notice Executes encoded commands along with provided inputs
     * @param commands A set of concatenated commands, each 1 byte in length
     * @param inputs An array of byte strings containing abi encoded inputs for each command
     */
    function execute(bytes calldata commands, bytes[] calldata inputs) external payable;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStETH } from "./IStETH.sol";

interface ILidoImmutables {
    /**
     * @notice Getter for the steth token
     * @return The steth token
     */
    function STETH() external view returns (IStETH);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

interface IStETH is IERC20Metadata, IERC20Permit {
    /// @notice The operation failed because the contract is paused
    error EnforcedPause();

    /// @notice The operation failed because the contract is not paused
    error ExpectedPause();

    /**
     * @notice Service event for initialization
     * @param eip712StETH The EIP712 helper contract for stETH
     */
    event EIP712StETHInitialized(address eip712StETH);

    /**
     * @notice Emitted when the pause is triggered by `account`
     * @param account The caller address
     */
    event Paused(address account);

    /**
     * @notice Emitted when the pause is lifted by `account`
     * @param account The caller address
     */
    event Unpaused(address account);

    /**
     * @notice An executed shares transfer from `sender` to `recipient`
     * @dev Emitted in pair with an ERC20-defined `Transfer` event
     * @param from The from address
     * @param to The to address
     * @param sharesValue The amount of transferred shares
     */
    event TransferShares(address indexed from, address indexed to, uint256 sharesValue);

    /**
     * @notice An executed `burnShares` request
     * @dev Reports simultaneously burnt shares amount
     * and corresponding stETH amount
     * The stETH amount is calculated twice: before and after the burning incurred rebase.
     * @param account The holder of the burnt shares
     * @param preRebaseTokenAmount The amount of stETH the burnt shares corresponded to before the burn
     * @param postRebaseTokenAmount The amount of stETH the burnt shares corresponded to after the burn
     * @param sharesAmount The amount of burnt shares
     */
    event SharesBurnt(
        address indexed account, uint256 preRebaseTokenAmount, uint256 postRebaseTokenAmount, uint256 sharesAmount
    );

    /**
     * @notice Get the sum of all ETH balances in the protocol
     * @dev Equals to the total supply of stETH
     * @return The entire amount of Ether controlled by the protocol
     */
    function getTotalPooledEther() external view returns (uint256);

    /**
     * @notice Atomically increases the allowance granted to `_spender` by the caller by `_addedValue`
     * @dev This is an alternative to `approve` that can be used as a mitigation for
     * problems described in:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b709eae01d1da91902d06ace340df6b324e6f049/contracts/token/ERC20/IERC20.sol#L57
     * Emits an `Approval` event indicating the updated allowance
     * Requirements:
     * - `_spender` cannot be the the zero address
     * @param _spender The token spender
     * @param _addedValue The token allowance amount to add
     * @return Whether the call is successful
     */
    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);

    /**
     * @notice Atomically decreases the allowance granted to `_spender` by the caller by `_subtractedValue`
     * @dev This is an alternative to `approve` that can be used as a mitigation for
     * problems described in:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b709eae01d1da91902d06ace340df6b324e6f049/contracts/token/ERC20/IERC20.sol#L57
     * Emits an `Approval` event indicating the updated allowance
     * Requirements:
     * - `_spender` cannot be the zero address
     * - `_spender` must have allowance for the caller of at least `_subtractedValue`
     * @param _spender The token spender
     * @param _subtractedValue The token allowance amount to subtract
     * @return Whether the call is successful
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);

    /**
     * @notice Get the total amount of shares
     * @dev The sum of all accounts' shares can be an arbitrary number, therefore
     * it is necessary to store it in order to calculate each account's relative share
     * @return The total amount of shares in existence
     */
    function getTotalShares() external view returns (uint256);

    /**
     * @notice Get the stETH shares of an address
     * @param _account The _account address
     * @return The amount of shares owned by `_account`
     */
    function sharesOf(address _account) external view returns (uint256);

    /**
     * @notice Get the amount of shares by protocol-controlled Ether
     * @param _ethAmount The eth amount
     * @return The amount of shares that corresponds to `_ethAmount` protocol-controlled Ether
     */
    function getSharesByPooledEth(uint256 _ethAmount) external view returns (uint256);

    /**
     * @notice Get the amount of protocol-controlled Ether by shares
     * @param _sharesAmount The stETH shares amount
     * @return The amount of Ether that corresponds to `_sharesAmount` token shares
     */
    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);

    /**
     * @notice Moves `_sharesAmount` token shares from the caller's account to the `_recipient` account
     * @dev The `_sharesAmount` argument is the amount of shares, not tokens
     * Emits a `TransferShares` event
     * Emits a `Transfer` event
     * Requirements:
     * - `_recipient` cannot be the zero address
     * - the caller must have at least `_sharesAmount` shares
     * - the contract must not be paused
     * @param _recipient The recipient address
     * @param _sharesAmount The shares amount
     * @return The amount of transferred tokens
     */
    function transferShares(address _recipient, uint256 _sharesAmount) external returns (uint256);

    /**
     * @notice Moves `_sharesAmount` token shares from the `_sender` account to the `_recipient` account
     * @dev The `_sharesAmount` argument is the amount of shares, not tokens
     * Emits a `TransferShares` event
     * Emits a `Transfer` event
     * Requirements:
     * - `_sender` and `_recipient` cannot be the zero addresses
     * - `_sender` must have at least `_sharesAmount` shares
     * - the caller must have allowance for `_sender`'s tokens of at least `getPooledEthByShares(_sharesAmount)`
     * - the contract must not be paused
     * @param _sender The sender address
     * @param _recipient The recipient address
     * @param _sharesAmount The shares amount
     * @return The amount of transferred tokens
     */
    function transferSharesFrom(address _sender, address _recipient, uint256 _sharesAmount)
        external
        returns (uint256);

    /**
     * @notice Get whether the contract is paused
     * @return The `pause` value, true if the contract is paused, and false otherwise
     */
    function paused() external returns (bool);

    /**
     * @notice Get the EIP712 domain values
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP712
     * signature
     * NB: comparing to the full-fledged ERC-5267 version:
     * - `salt` and `extensions` are unused
     * - `flags` is hex"0f" or 01111b
     * using shortened returns to reduce a bytecode size
     * @return name The domain name
     * @return version The domain version
     * @return chainId The domain chainId
     * @return verifyingContract The domain contract address
     */
    function eip712Domain()
        external
        view
        returns (string memory name, string memory version, uint256 chainId, address verifyingContract);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

interface IWstETH is IERC20Metadata, IERC20Permit {
    /**
     * @notice Exchanges stETH to wstETH
     * @param _stETHAmount The amount of stETH to wrap in exchange for wstETH
     * @dev Requirements:
     *  - `_stETHAmount` must be non-zero
     *  - msg.sender must approve at least `_stETHAmount` stETH to this contract
     *  - msg.sender must have at least `_stETHAmount` of stETH
     * User should first approve `_stETHAmount` to the WstETH contract
     * @return Amount of wstETH user receives after wrap
     */
    function wrap(uint256 _stETHAmount) external returns (uint256);

    /**
     * @notice Exchanges wstETH to stETH
     * @param _wstETHAmount The amount of wstETH to unwrap in exchange for stETH
     * @dev Requirements:
     *  - `_wstETHAmount` must be non-zero
     *  - msg.sender must have at least `_wstETHAmount` wstETH
     * @return The amount of stETH user receives after unwrap
     */
    function unwrap(uint256 _wstETHAmount) external returns (uint256);

    /**
     * @notice Get the amount of wstETH for a given amount of stETH
     * @param _stETHAmount The amount of stETH
     * @return The amount of wstETH for a given stETH amount
     */
    function getWstETHByStETH(uint256 _stETHAmount) external view returns (uint256);

    /**
     * @notice Get the amount of stETH for a given amount of wstETH
     * @param _wstETHAmount The amount of wstETH
     * @return The amount of stETH for a given wstETH amount
     */
    function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);

    /**
     * @notice Get the amount of stETH for a one wstETH
     * @return The amount of stETH for 1 wstETH
     */
    function stEthPerToken() external view returns (uint256);

    /**
     * @notice Get the amount of wstETH for a one stETH
     * @return The amount of wstETH for a 1 stETH
     */
    function tokensPerStEth() external view returns (uint256);

    /**
     * @notice Get the address of stETH
     * @return The address of stETH
     */
    function stETH() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISmardexFactory {
    /**
     * @notice Emitted at each SmardexPair created
     * @param token0 The address of the token0
     * @param token1 The address of the token1
     * @param pair The address of the SmardexPair created
     * @param totalPair The number of SmardexPair created so far
     */
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 totalPair);

    /**
     * @notice Emitted at each SmardexPair manually added
     * @param token0 The address of the token0
     * @param token1 The address of the token1
     * @param pair The address of the SmardexPair created
     * @param totalPair The number of SmardexPair created so far
     */
    event PairAdded(address indexed token0, address indexed token1, address pair, uint256 totalPair);

    /**
     * @notice Emitted each time feesLP and feesPool are changed
     * @param feesLP The new feesLP
     * @param feesPool The new feesPool
     */
    event FeesChanged(uint256 indexed feesLP, uint256 indexed feesPool);

    /**
     * @notice Emitted when the feeTo is updated
     * @param previousFeeTo The previous feeTo address
     * @param newFeeTo The new feeTo address
     */
    event FeeToUpdated(address indexed previousFeeTo, address indexed newFeeTo);

    /**
     * @notice Return the address fees will be transferred
     * @return Which the address fees will be transferred
     */
    function feeTo() external view returns (address);

    /**
     * @notice Get the pair address of 2 tokens
     * @param tokenA The token A of the pair
     * @param tokenB The token B of the pair
     * @return pair_ The address of the pair of 2 tokens
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair_);

    /**
     * @notice Return the address of the pair at index
     * @param index The index of the pair
     * @return pair_ The address of the pair
     */
    function allPairs(uint256 index) external view returns (address pair_);

    /**
     * @notice Get the quantity of pairs
     * @return The quantity of pairs
     */
    function allPairsLength() external view returns (uint256);

    /**
     * @notice Return numerators of pair fees, denominator is 1_000_000
     * @return feesLP_ The numerator of fees sent to LP at pair creation
     * @return feesPool_ The numerator of fees sent to Pool at pair creation
     */
    function getDefaultFees() external view returns (uint128 feesLP_, uint128 feesPool_);

    /**
     * @notice Whether whitelist is open
     * @return open_ True if the whitelist is open, false otherwise
     */
    function whitelistOpen() external view returns (bool open_);

    /**
     * @notice Create pair with 2 address
     * @param tokenA The address of tokenA
     * @param tokenB The address of tokenB
     * @return pair_ The address of the pair created
     */
    function createPair(address tokenA, address tokenB) external returns (address pair_);

    /**
     * @notice Set the address who will receive fees, can only be call by the owner
     * @param feeTo The address to replace
     */
    function setFeeTo(address feeTo) external;

    /**
     * @notice Set feesLP and feesPool for each new pair (onlyOwner)
     * @notice The sum of new feesLp and feesPool must be <= FEES_MAX = 10% FEES_BASE
     * @param feesLP The new numerator of fees sent to LP, must be >= 1
     * @param feesPool The new numerator of fees sent to Pool, could be = 0
     */
    function setFees(uint128 feesLP, uint128 feesPool) external;

    /**
     * @notice Disable whitelist (onlyOwner)
     * whitelist cannot be re-opened after that.
     */
    function closeWhitelist() external;

    /**
     * @notice Add a pair manually
     * @param pair The pair address to add (must be an ISmardexPair)
     */
    function addPair(address pair) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

interface ISmardexPair is IERC20, IERC20Permit {
    /**
     * @notice Swap parameters used by function swap
     * @param amountCalculated The return amount from getAmountIn/Out is always positive but to avoid too much cast, is
     * int
     * @param fictiveReserveIn The fictive reserve of the in-token of the pair
     * @param fictiveReserveOut The fictive reserve of the out-token of the pair
     * @param priceAverageIn The in-token ratio component of the price average
     * @param priceAverageOut The out-token ratio component of the price average
     * @param token0 The address of the token0
     * @param token1 The address of the token1
     * @param balanceIn The contract balance of the in-token
     * @param balanceOut The contract balance of the out-token
     */
    struct SwapParams {
        int256 amountCalculated;
        uint256 fictiveReserveIn;
        uint256 fictiveReserveOut;
        uint256 priceAverageIn;
        uint256 priceAverageOut;
        address token0;
        address token1;
        uint256 balanceIn;
        uint256 balanceOut;
    }

    /**
     * @notice Emitted at each mint
     * @dev The amount of LP-token sent can be caught using the transfer event of the pair
     * @param sender The address calling the mint function (usually the Router contract)
     * @param to The address that receives the LP-tokens
     * @param amount0 The amount of token0 to be added in liquidity
     * @param amount1 The amount of token1 to be added in liquidity
     */
    event Mint(address indexed sender, address indexed to, uint256 amount0, uint256 amount1);

    /**
     * @notice Emitted at each burn
     * @dev The amount of LP-token sent can be caught using the transfer event of the pair
     * @param sender The address calling the burn function (usually the Router contract)
     * @param to The address that receives the tokens
     * @param amount0 The amount of token0 to be withdrawn
     * @param amount1 The amount of token1 to be withdrawn
     */
    event Burn(address indexed sender, address indexed to, uint256 amount0, uint256 amount1);

    /**
     * @notice Emitted at each swap
     * @dev One of the 2 amount is always negative, the other one is always positive. The positive one is the one that
     * the user send to the contract, the negative one is the one that the contract send to the user.
     * @param sender The address calling the swap function (usually the Router contract)
     * @param to The address that receives the out-tokens
     * @param amount0 The amount of token0 to be swapped
     * @param amount1 The amount of token1 to be swapped
     */
    event Swap(address indexed sender, address indexed to, int256 amount0, int256 amount1);

    /**
     * @notice Emitted each time the fictive reserves are changed (mint, burn, swap)
     * @param reserve0 The new reserve of token0
     * @param reserve1 The new reserve of token1
     * @param fictiveReserve0 The new fictive reserve of token0
     * @param fictiveReserve1 The new fictive reserve of token1
     * @param priceAverage0 The new priceAverage of token0
     * @param priceAverage1 The new priceAverage of token1
     */
    event Sync(
        uint256 reserve0,
        uint256 reserve1,
        uint256 fictiveReserve0,
        uint256 fictiveReserve1,
        uint256 priceAverage0,
        uint256 priceAverage1
    );

    /**
     * @notice Emitted each time feesLP and feesPool are changed
     * @param feesLP The new feesLP
     * @param feesPool The new feesPool
     */
    event FeesChanged(uint256 indexed feesLP, uint256 indexed feesPool);

    /**
     * @notice Get the factory address
     * @return The address of the factory
     */
    function factory() external view returns (address);

    /**
     * @notice Get the token0 address
     * @return The address of the token0
     */
    function token0() external view returns (address);

    /**
     * @notice Get the token1 address
     * @return The address of the token1
     */
    function token1() external view returns (address);

    /**
     * @notice Called once by the factory at time of deployment
     * @param token0 The address of token0
     * @param token1 The address of token1
     * @param feesLP The feesLP numerator
     * @param feesPool The feesPool numerator
     */
    function initialize(address token0, address token1, uint128 feesLP, uint128 feesPool) external;

    /**
     * @notice Return current Reserves of both token in the pair,
     *  corresponding to token balance - pending fees
     * @return reserve0_ The current reserve of token0 - pending fee0
     * @return reserve1_ The current reserve of token1 - pending fee1
     */
    function getReserves() external view returns (uint256 reserve0_, uint256 reserve1_);

    /**
     * @notice Return current fictive reserves of both token in the pair
     * @return fictiveReserve0_ The current fictive reserve of token0
     * @return fictiveReserve1_ The current fictive reserve of token1
     */
    function getFictiveReserves() external view returns (uint256 fictiveReserve0_, uint256 fictiveReserve1_);

    /**
     * @notice Return current pending fees of both token in the pair
     * @return fees0_ The current pending fees of token0
     * @return fees1_ The current pending fees of token1
     */
    function getFeeToAmounts() external view returns (uint256 fees0_, uint256 fees1_);

    /**
     * @notice Return numerators of pair fees, denominator is 1_000_000
     * @return feesLP_ The numerator of fees sent to LP
     * @return feesPool_ The numerator of fees sent to Pool
     */
    function getPairFees() external view returns (uint128 feesLP_, uint128 feesPool_);

    /**
     * @notice Return last updated price average at timestamp of both token in the pair,
     *  read price0Average/price1Average for current price of token0/token1
     * @return priceAverage0_ The current price for token0
     * @return priceAverage1_ The current price for token1
     * @return blockTimestampLast_ The last block timestamp when price was updated
     */
    function getPriceAverage()
        external
        view
        returns (uint256 priceAverage0_, uint256 priceAverage1_, uint256 blockTimestampLast_);

    /**
     * @notice Return current price average of both token in the pair for provided currentTimeStamp
     *  read price0Average/price1Average for current price of token0/token1
     * @param fictiveReserveIn The fictive reserve of the tokenIn
     * @param fictiveReserveOut The fictive reserve of the tokenOut
     * @param priceAverageLastTimestamp The price average of the last timestamp
     * @param priceAverageIn The current price for token0
     * @param priceAverageOut The current price for token1
     * @param currentTimestamp The block timestamp to get price
     * @return priceAverageIn_ The current price for token0
     * @return priceAverageOut_ The current price for token1
     */
    function getUpdatedPriceAverage(
        uint256 fictiveReserveIn,
        uint256 fictiveReserveOut,
        uint256 priceAverageLastTimestamp,
        uint256 priceAverageIn,
        uint256 priceAverageOut,
        uint256 currentTimestamp
    ) external pure returns (uint256 priceAverageIn_, uint256 priceAverageOut_);

    /**
     * @notice Mint lp tokens proportionally of added tokens in balance. Should be called from a contract
     * that makes safety checks like the SmardexRouter
     * @param to The address who will receive minted tokens
     * @param amount0 The amount of token0 to provide
     * @param amount1 The amount of token1 to provide
     * @param payer The address that will be paying the input
     * @return liquidity_ The amount of lp tokens minted and sent to the address defined in parameter
     */
    function mint(address to, uint256 amount0, uint256 amount1, address payer) external returns (uint256 liquidity_);

    /**
     * @notice Burn lp tokens in the balance of the contract. Sends to the defined address the amount of token0 and
     * token1 proportionally of the amount burned. Should be called from a contract that makes safety checks like the
     * SmardexRouter
     * @param to The address who will receive tokens
     * @return amount0_ The amount of token0 sent to the address defined in parameter
     * @return amount1_ The amount of token0 sent to the address defined in parameter
     */
    function burn(address to) external returns (uint256 amount0_, uint256 amount1_);

    /**
     * @notice Swaps tokens. Sends to the defined address the amount of token0 and token1 defined in parameters.
     * Tokens to trade should be already sent in the contract.
     * Swap function will check if the resulted balance is correct with current reserves and reserves fictive.
     * Should be called from a contract that makes safety checks like the SmardexRouter
     * @param to The address who will receive tokens
     * @param zeroForOne The token0 to token1
     * @param amountSpecified The amount of token wanted
     * @param data The used for flash swap, data.length must be 0 for regular swap
     * @return amount0_ The amount0
     * @return amount1_ The amount1
     */
    function swap(address to, bool zeroForOne, int256 amountSpecified, bytes calldata data)
        external
        returns (int256 amount0_, int256 amount1_);

    /**
     * @notice Set feesLP and feesPool of the pair
     * @dev The sum of new feesLp and feesPool must be <= 100_000
     * @param feesLP The new numerator of fees sent to LP, must be >= 1
     * @param feesPool The new numerator of fees sent to Pool, could be = 0
     */
    function setFees(uint128 feesLP, uint128 feesPool) external;

    /**
     * @notice Withdraw all reserve on the pair in case no liquidity has never been provided
     * @param to The address who will receive tokens
     */
    function skim(address to) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISmardexRouter {
    /**
     * @notice Parameters used by the {SmardexRouterLib.addLiquidity} function.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @param amountADesired The amount of `tokenA` to add as liquidity.
     * if the B/A price is <= `amountBDesired`/`amountADesired`.
     * @param amountBDesired The amount of `tokenB` to add as liquidity.
     * if the A/B price is <= `amountADesired`/`amountBDesired`.
     * @param amountAMin This bounds the extent to which the B/A price can go up before the transaction reverts.
     * Must be <= `amountADesired`.
     * @param amountBMin This bounds the extent to which the A/B price can go up before the transaction reverts.
     * Must be <= `amountBDesired`.
     * @param fictiveReserveB The fictive reserve of tokenB at time of submission.
     * @param fictiveReserveAMin The minimum fictive reserve of `tokenA` indicating the extent to which the A/B price
     * can go down.
     * @param fictiveReserveAMax The maximum fictive reserve of `tokenA` indicating the extent to which the A/B price
     * can go up.
     */
    struct AddLiquidityParams {
        address tokenA;
        address tokenB;
        uint256 amountADesired;
        uint256 amountBDesired;
        uint256 amountAMin;
        uint256 amountBMin;
        uint128 fictiveReserveB;
        uint128 fictiveReserveAMin;
        uint128 fictiveReserveAMax;
    }

    /**
     * @notice The data used by the callback of a token pair's mint function.
     * @param token0 The address of the first token of the pair.
     * @param token1 The address of the second token of the pair.
     * @param amount0 The amount of `token0` to provide.
     * @param amount1 The amount of `token1` to provide.
     * @param payer The address of the payer to provide token for the mint.
     */
    struct MintCallbackData {
        address token0;
        address token1;
        uint256 amount0;
        uint256 amount1;
        address payer;
    }

    /**
     * @notice The data used by the {SmardexRouterLib.removeLiquidity} function.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @param liquidity The amount of LP tokens to remove.
     * @param amountAMin The minimum amountA to receive.
     * @param amountBMin The minimum amountB to receive.
     */
    struct RemoveLiquidityParams {
        address tokenA;
        address tokenB;
        uint256 liquidity;
        uint256 amountAMin;
        uint256 amountBMin;
    }

    /**
     * @notice The data used by the callback of the {SmardexRouter}'s swap functions.
     * @param path The path of the swap, array of token addresses tightly packed.
     * @param payer The address of the payer for the swap.
     */
    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    /**
     * @notice The callback function called by {SmardexPair.mint}.
     * @param data The callback data.
     */
    function smardexMintCallback(MintCallbackData calldata data) external;

    /**
     * @notice The callback function called after a swap.
     * @dev The negative amount is tokens to be received, positive is required to pay to pair
     * @param amount0Delta The amount of token0 for the swap.
     * @param amount1Delta The amount of token1 for the swap.
     * @param data The data for the router path and payer for the swap.
     */
    function smardexSwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISmardexRouterErrors {
    /// @notice The amount of token received is lower than the limit.
    error TooLittleReceived();

    /// @notice The amount of tokens to pay is higher than the limit.
    error ExcessiveInputAmount();

    /// @notice The recipient is invalid.
    error InvalidRecipient();

    /// @notice `msg.sender` is not the expected token pair.
    error InvalidPair();

    /// @notice Token amounts given to the callback are invalid.
    error CallbackInvalidAmount();

    /// @notice The price is too high for the swap.
    error PriceTooHigh();

    /// @notice The price is too low for the swap.
    error PriceTooLow();

    /// @notice The amount of asset B is below the minimum.
    error InsufficientAmountB();

    /// @notice The amount of asset A to pay is above the desired amount.
    error InsufficientAmountADesired();

    /// @notice The amount of asset A is below the minimum.
    error InsufficientAmountA();

    /// @notice The deadline for the action was exceeded.
    error DeadlineExceeded();

    /// @notice The provided token address is invalid.
    error InvalidTokenAddress();
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

interface IUniswapV2Router {
    /**
     * @dev Structure to hold the data for a swap
     * @param input The input token address
     * @param output The output token address
     * @param nextPair The next pair to swap to
     * @param reserve0 The reserve0 of the pair
     * @param reserve1 The reserve1 of the pair
     * @param reserveInput The reserve of the input token
     * @param reserveOutput The reserve of the output token
     * @param amountInput The amount of input tokens
     * @param amountOutput The amount of output tokens
     * @param amount0Out The amount of token0 to swap
     * @param amount1Out The amount of token1 to swap
     */
    struct V2SwapData {
        address input;
        address output;
        address nextPair;
        uint256 reserve0;
        uint256 reserve1;
        uint256 reserveInput;
        uint256 reserveOutput;
        uint256 amountInput;
        uint256 amountOutput;
        uint256 amount0Out;
        uint256 amount1Out;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

interface IUniswapV2RouterErrors {
    /// @notice The amount received is too low.
    error UniswapV2TooLittleReceived();
    /// @notice The amount requested is too high.
    error UniswapV2TooMuchRequested();
    /// @notice The path is invalid.
    error UniswapV2InvalidPath();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPaymentLibTypes {
    /**
     * @notice Indicates the type of payment in the USDN protocol action callbacks
     * @param None The no payment value
     * @param Transfer The transfer payment value from the contract balance
     * @param TransferFrom The transferFrom payment value to use standard approval or permit
     * @param Permit2 The permit2 payment value to use permit2
     */
    enum PaymentType {
        None,
        Transfer,
        TransferFrom,
        Permit2
    }

    /**
     * @notice Indicates the USDN protocol action in the callbacks
     * @param Withdrawal The withdrawal action
     * @param Deposit The deposit action
     * @param Open The open action
     */
    enum PaymentAction {
        Withdrawal,
        Deposit,
        Open
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUsdnProtocolRouterErrors {
    /// @notice Reverts when the sender is invalid
    error UsdnProtocolRouterInvalidSender();

    /// @notice Reverts when the payment is invalid
    error UsdnProtocolRouterInvalidPayment();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolTypes } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";
import { IPaymentLibTypes } from "../../interfaces/usdn/IPaymentLibTypes.sol";

interface IUsdnProtocolRouterTypes {
    /**
     * @notice The router USDN protocol initiate open position data struct
     * @param payment The USDN protocol payment method
     * @param amount The amount of assets used to open the position
     * @param desiredLiqPrice The desired liquidation price for the position
     * @param userMaxPrice The maximum price
     * @param userMaxLeverage The maximum leverage
     * @param to The address that will receive the position
     * @param validator The address that should validate the open position (receives the security deposit back)
     * @param deadline The transaction deadline
     * @param currentPriceData The current price data
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     */
    struct InitiateOpenPositionData {
        IPaymentLibTypes.PaymentType payment;
        uint256 amount;
        uint256 desiredLiqPrice;
        uint256 userMaxPrice;
        uint256 userMaxLeverage;
        address to;
        address validator;
        uint256 deadline;
        bytes currentPriceData;
        IUsdnProtocolTypes.PreviousActionsData previousActionsData;
        uint256 ethAmount;
    }

    /**
     * @notice The router USDN protocol deposit data struct
     * @param payment The USDN protocol payment method
     * @param amount The amount of asset to deposit into the vault
     * @param sharesOutMin The minimum amount of shares to receive
     * @param to The address that will receive the USDN tokens upon validation
     * @param validator The address that should validate the deposit (receives the security deposit back)
     * @param deadline The transaction deadline
     * @param currentPriceData The current price data
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     */
    struct InitiateDepositData {
        IPaymentLibTypes.PaymentType payment;
        uint256 amount;
        uint256 sharesOutMin;
        address to;
        address validator;
        uint256 deadline;
        bytes currentPriceData;
        IUsdnProtocolTypes.PreviousActionsData previousActionsData;
        uint256 ethAmount;
    }

    /**
     * @notice The router usdnProtocol initiate close position data struct
     * @param posId The unique identifier of the position to close
     * @param amountToClose The amount of collateral to remove from the position's amount
     * @param userMinPrice The minimum price at which the position can be closed (with _priceFeedDecimals). Note that
     * @param to The address that will receive the assets
     * @param validator The address that will validate the close action
     * @param deadline The deadline of the close position to be initiated
     * @param currentPriceData The current price data
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param delegationSignature The EIP712 initiateClosePosition delegation signature
     * @param ethAmount The amount of Ether to send with the transaction
     */
    struct InitiateClosePositionData {
        IUsdnProtocolTypes.PositionId posId;
        uint128 amountToClose;
        uint256 userMinPrice;
        address to;
        address validator;
        uint256 deadline;
        bytes currentPriceData;
        IUsdnProtocolTypes.PreviousActionsData previousActionsData;
        bytes delegationSignature;
        uint256 ethAmount;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

/**
 * @title Commands Library
 * @notice Command Flags used to decode commands
 */
library Commands {
    // masks to extract certain bits of commands
    bytes1 internal constant FLAG_ALLOW_REVERT = 0x80;
    bytes1 internal constant COMMAND_TYPE_MASK = 0x3f;

    uint256 constant V3_SWAP_EXACT_IN = 0x00;
    uint256 constant V3_SWAP_EXACT_OUT = 0x01;
    uint256 constant PERMIT2_TRANSFER_FROM = 0x02;
    uint256 constant PERMIT2_PERMIT_BATCH = 0x03;
    uint256 constant SWEEP = 0x04;
    uint256 constant TRANSFER = 0x05;
    uint256 constant PAY_PORTION = 0x06;
    // COMMAND_PLACEHOLDER from 0x07 to 0x0f (all unused)

    // the commands are executed in nested if blocks to minimize gas consumption
    // the following constant defines one of the boundaries where the if blocks split commands
    uint256 constant FIRST_IF_BOUNDARY = 0x10;

    uint256 constant V2_SWAP_EXACT_IN = 0x10;
    uint256 constant V2_SWAP_EXACT_OUT = 0x11;
    uint256 constant PERMIT2_PERMIT = 0x12;
    uint256 constant WRAP_ETH = 0x13;
    uint256 constant UNWRAP_WETH = 0x14;
    uint256 constant PERMIT2_TRANSFER_FROM_BATCH = 0x15;
    uint256 constant PERMIT = 0x16;
    uint256 constant TRANSFER_FROM = 0x17;
    // COMMAND_PLACEHOLDER from 0x18 to 0x1f (all unused)

    // the commands are executed in nested if blocks to minimize gas consumption
    // the following constant defines one of the boundaries where the if blocks split commands
    uint256 constant SECOND_IF_BOUNDARY = 0x20;

    uint256 constant INITIATE_DEPOSIT = 0x20;
    uint256 constant INITIATE_WITHDRAWAL = 0x21;
    uint256 constant INITIATE_OPEN = 0x22;
    uint256 constant INITIATE_CLOSE = 0x23;
    uint256 constant VALIDATE_DEPOSIT = 0x24;
    uint256 constant VALIDATE_WITHDRAWAL = 0x25;
    uint256 constant VALIDATE_OPEN = 0x26;
    uint256 constant VALIDATE_CLOSE = 0x27;
    uint256 constant LIQUIDATE = 0x28;
    uint256 constant TRANSFER_POSITION_OWNERSHIP = 0x29;
    uint256 constant VALIDATE_PENDING = 0x2a;
    uint256 constant REBALANCER_INITIATE_DEPOSIT = 0x2b;
    uint256 constant REBALANCER_INITIATE_CLOSE = 0x2c;
    // COMMAND_PLACEHOLDER from 0x2d to 0x2f (all unused)

    // the commands are executed in nested if blocks to minimize gas consumption
    // the following constant defines one of the boundaries where the if blocks split commands
    uint256 constant THIRD_IF_BOUNDARY = 0x30;

    uint256 constant WRAP_USDN = 0x30;
    uint256 constant UNWRAP_WUSDN = 0x31;
    uint256 constant WRAP_STETH = 0x32;
    uint256 constant UNWRAP_WSTETH = 0x33;
    uint256 constant USDN_TRANSFER_SHARES_FROM = 0x34;
    // COMMAND_PLACEHOLDER from 0x35 to 0x37 (all unused)

    // the commands are executed in nested if blocks to minimize gas consumption
    // the following constant defines one of the boundaries where the if blocks split commands
    uint256 constant FOURTH_IF_BOUNDARY = 0x38;

    uint256 constant SMARDEX_SWAP_EXACT_IN = 0x38;
    uint256 constant SMARDEX_SWAP_EXACT_OUT = 0x39;
    uint256 constant SMARDEX_ADD_LIQUIDITY = 0x3a;
    uint256 constant SMARDEX_REMOVE_LIQUIDITY = 0x3b;
    // COMMAND_PLACEHOLDER from 0x3c to 0x3f (all unused)
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

library TransientStorageLib {
    /**
     * @notice Set the transient value
     * @dev Uses the transient storage
     * @param slot The slot value
     * @param value The value to store
     */
    function setTransientValue(bytes32 slot, bytes32 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @notice Get the transient value
     * @dev Uses the transient storage
     * @param slot The slot value
     * @return value_ The value to return
     */
    function getTransientValue(bytes32 slot) internal view returns (bytes32 value_) {
        assembly ("memory-safe") {
            value_ := tload(slot)
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";

import { IWstETH } from "../../interfaces/lido/IWstETH.sol";
import { IStETH } from "../../interfaces/lido/IStETH.sol";

/// @title Router library for Lido
library LidoRouterLib {
    using SafeERC20 for IWstETH;
    using SafeERC20 for IStETH;

    /**
     * @notice Wrap all of the contract's stETH into wstETH
     * @param steth The steth contract
     * @param wsteth The wsteth contract
     * @param amount The stETH amount
     * @param recipient The recipient of the wstETH
     * @return Whether the wrapping was successful
     */
    function wrapSTETH(IStETH steth, IWstETH wsteth, uint256 amount, address recipient) external returns (bool) {
        if (amount == 0) {
            return false;
        }

        if (amount == Constants.CONTRACT_BALANCE) {
            amount = steth.balanceOf(address(this));
        }

        steth.forceApprove(address(wsteth), amount);
        amount = wsteth.wrap(amount);

        if (recipient != address(this)) {
            wsteth.safeTransfer(recipient, amount);
        }

        return true;
    }

    /**
     * @notice Unwraps all of the contract's wstETH into stETH
     * @param steth The steth contract
     * @param wsteth The wsteth contract
     * @param amount The wstETH amount
     * @param recipient The recipient of the stETH
     * @return Whether the unwrapping was successful
     */
    function unwrapWSTETH(IStETH steth, IWstETH wsteth, uint256 amount, address recipient) external returns (bool) {
        if (amount == 0) {
            return false;
        }

        if (amount == Constants.CONTRACT_BALANCE) {
            amount = wsteth.balanceOf(address(this));
        }

        uint256 stEthSharesBefore = steth.sharesOf(address(this));
        wsteth.unwrap(amount);
        uint256 stEthSharesAmount = steth.sharesOf(address(this)) - stEthSharesBefore;

        if (stEthSharesAmount == 0) {
            return false;
        }

        if (recipient != address(this)) {
            steth.transferShares(recipient, stEthSharesAmount);
        }

        return true;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

/**
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 * @custom:url https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
library BytesLib {
    /**
     * @notice Perform a slice from a bytes offset
     * @param memBytes The bytes to perform the parsing
     * @param start The start offset
     * @param length The slice length from start
     * @return A sliced bytes
     */
    function slice(bytes memory memBytes, uint256 start, uint256 length) internal pure returns (bytes memory) {
        require(length + 31 >= length, "slice_overflow");
        require(start + length >= start, "slice_overflow");
        require(memBytes.length >= start + length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(memBytes, lengthmod), mul(0x20, iszero(lengthmod))), start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    /**
     * @notice Parse and return an address from a specified bytes offset
     * @param memBytes The bytes to perform the parsing
     * @param start The start offset
     * @return A parsed address
     */
    function toAddress(bytes memory memBytes, uint256 start) internal pure returns (address) {
        require(start + 20 >= start, "toAddress_overflow");
        require(memBytes.length >= start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(memBytes, 0x20), start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

// libraries
import "./BytesLib.sol";

/**
 * @title Functions for manipulating path data for multi-hop swaps
 * @custom:from UniswapV3
 * @custom:url https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/Path.sol
 * @custom:editor SmarDex team
 */
library Path {
    using BytesLib for bytes;

    /// @dev Indicates that the path length is invalid
    error InvalidPath();

    /// @dev The length of the bytes encoded address
    uint256 private constant ADDR_SIZE = 20;
    /// @dev The offset of a single token address
    uint256 private constant NEXT_OFFSET = ADDR_SIZE;
    /// @dev The offset of an encoded pool key
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    /// @dev The minimum length of an encoding that contains 2 or more pools
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    /**
     * @notice Returns true if the path contains two or more pools
     * @param path The encoded swap path
     * @return True if path contains two or more pools, otherwise false
     */
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    /**
     * @notice Decodes the first pool in path
     * @param path The bytes encoded swap path
     * @return tokenA_ The first token of the given pool
     * @return tokenB_ The second token of the given pool
     */
    function decodeFirstPool(bytes memory path) internal pure returns (address tokenA_, address tokenB_) {
        tokenA_ = path.toAddress(0);
        tokenB_ = path.toAddress(NEXT_OFFSET);
    }

    /**
     * @notice Decodes the first token in path
     * @param path The bytes encoded swap path
     * @return tokenA_ The first token of the given pool
     */
    function decodeFirstToken(bytes memory path) internal pure returns (address tokenA_) {
        tokenA_ = path.toAddress(0);
    }

    /**
     * @notice Gets the segment corresponding to the first pool in the path
     * @param path The bytes encoded swap path
     * @return The segment containing all data necessary to target the first pool in the path
     */
    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    /**
     * @notice Skips a token from the buffer and returns the remainder
     * @dev Require a calldata path
     * @param path The swap path
     * @return The remaining token elements in the path
     */
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }

    /**
     * @notice Returns the path addresses concatenated in a reversed order as a packed bytes array
     * @param path The swap path
     * @return encoded_ The bytes array containing the packed addresses
     */
    function encodeTightlyPackedReversed(bytes memory path) external pure returns (bytes memory encoded_) {
        if (path.length == 0 || path.length % ADDR_SIZE > 0) {
            revert InvalidPath();
        }
        uint256 len = path.length / ADDR_SIZE;
        uint256 offSet = (len - 1) * ADDR_SIZE;
        for (uint256 i = len; i != 0;) {
            encoded_ = bytes.concat(encoded_, abi.encodePacked(path.toAddress(offSet)));
            unchecked {
                offSet -= ADDR_SIZE;
                --i;
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { ISmardexPair } from "../../interfaces/smardex/ISmardexPair.sol";

library PoolHelpers {
    /// @notice The given amount of asset is insufficient.
    error InsufficientAmount();
    /// @notice The amount of liquidity in the pair is insufficient.
    error InsufficientLiquidity();

    /**
     * @notice Gets the real and fictive reserves for a pair.
     * @param pair The pair to get the reserves of.
     * @param tokenA The address of `tokenA`.
     * @return reserveA_ The reserve of `tokenA`.
     * @return reserveB_ The reserve of `tokenB`.
     * @return fictiveReserveA_ The fictive reserve of `tokenA`.
     * @return fictiveReserveB_ The fictive reserve of `tokenB`.
     */
    function getAllReserves(ISmardexPair pair, address tokenA)
        internal
        view
        returns (uint256 reserveA_, uint256 reserveB_, uint256 fictiveReserveA_, uint256 fictiveReserveB_)
    {
        (uint256 reserve0, uint256 reserve1) = pair.getReserves();
        (uint256 fictiveReserve0, uint256 fictiveReserve1) = pair.getFictiveReserves();
        if (tokenA == pair.token0()) {
            reserveA_ = reserve0;
            reserveB_ = reserve1;
            fictiveReserveA_ = fictiveReserve0;
            fictiveReserveB_ = fictiveReserve1;
        } else {
            reserveA_ = reserve1;
            reserveB_ = reserve0;
            fictiveReserveA_ = fictiveReserve1;
            fictiveReserveB_ = fictiveReserve0;
        }
    }

    /**
     * @notice Calculates the estimated amount of `tokenB` received for the given amount of `tokenA`.
     * @param amountA The amount of `tokenA` to exchange.
     * @param reserveA The reserve of `tokenA`.
     * @param reserveB The reserve of `tokenB`.
     * @return amountB_ The estimated amount of `tokenB` to be received.
     */
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB_) {
        if (amountA == 0) {
            revert InsufficientAmount();
        }
        if (reserveA == 0 || reserveB == 0) {
            revert InsufficientLiquidity();
        }

        amountB_ = (amountA * reserveB) / reserveA;
    }

    /**
     * @notice Sorts the given amounts of tokens by token address in ascending order.
     * @param tokenA The `tokenA` address.
     * @param tokenB The `tokenB` address
     * @param amountA The amount of `tokenA`
     * @param amountB The amount of `tokenB`
     * @return amount0_ The amount of `token0`
     * @return amount1_ The amount of `token1`
     */
    function sortAmounts(address tokenA, address tokenB, uint256 amountA, uint256 amountB)
        internal
        pure
        returns (uint256 amount0_, uint256 amount1_)
    {
        bool orderedPair = tokenA < tokenB;
        if (orderedPair) {
            amount0_ = amountA;
            amount1_ = amountB;
        } else {
            amount0_ = amountB;
            amount1_ = amountA;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";

import { ISmardexFactory } from "../../interfaces/smardex/ISmardexFactory.sol";
import { ISmardexPair } from "../../interfaces/smardex/ISmardexPair.sol";
import { ISmardexRouter } from "../../interfaces/smardex/ISmardexRouter.sol";
import { ISmardexRouterErrors } from "../../interfaces/smardex/ISmardexRouterErrors.sol";
import { Path } from "./Path.sol";
import { PoolHelpers } from "./PoolHelpers.sol";
import { Payment } from "../../utils/Payment.sol";

/// @title Router library for Smardex
library SmardexRouterLib {
    using Path for bytes;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeERC20 for IERC20;

    /// @notice The address size
    uint8 private constant ADDR_SIZE = 20;

    /**
     * @notice The Smardex callback for Smardex swap
     * @param smardexFactory The Smardex factory contract
     * @param permit2 The permit2 contract
     * @param amount0Delta The amount of token0 for the swap (negative is incoming, positive is required to pay to pair)
     * @param amount1Delta The amount of token1 for the swap (negative is incoming, positive is required to pay to pair)
     * @param data The data path and payer for the swap
     * @return amountInCached_ Cached input amount, used to check slippage
     */
    function smardexSwapCallback(
        ISmardexFactory smardexFactory,
        IAllowanceTransfer permit2,
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external returns (uint256 amountInCached_) {
        if (amount0Delta <= 0 && amount1Delta <= 0) {
            revert ISmardexRouterErrors.CallbackInvalidAmount();
        }

        ISmardexRouter.SwapCallbackData memory decodedData = abi.decode(data, (ISmardexRouter.SwapCallbackData));
        (address tokenIn, address tokenOut) = decodedData.path.decodeFirstPool();

        if (msg.sender != smardexFactory.getPair(tokenIn, tokenOut)) {
            revert ISmardexRouterErrors.InvalidPair();
        }

        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0 ? (tokenIn < tokenOut, uint256(amount0Delta)) : (tokenOut < tokenIn, uint256(amount1Delta));

        if (isExactInput) {
            Payment.pay(permit2, tokenIn, decodedData.payer, msg.sender, amountToPay);
        } else if (decodedData.path.hasMultiplePools()) {
            decodedData.path = decodedData.path.skipToken();
            _swapExactOut(smardexFactory, amountToPay, msg.sender, decodedData);
        } else {
            amountInCached_ = amountToPay;
            // swap in/out because exact output swaps are reversed
            tokenIn = tokenOut;
            Payment.pay(permit2, tokenIn, decodedData.payer, msg.sender, amountToPay);
        }
    }

    /**
     * @notice The callback called during a mint of LP token on Smardex.
     * @param smardexFactory The Smardex factory contract.
     * @param permit2 The permit2 contract.
     * @param data The data required to execute the callback.
     */
    function smardexMintCallback(
        ISmardexFactory smardexFactory,
        IAllowanceTransfer permit2,
        ISmardexRouter.MintCallbackData calldata data
    ) external {
        if (data.amount0 == 0 && data.amount1 == 0) {
            revert ISmardexRouterErrors.CallbackInvalidAmount();
        }

        if (msg.sender != smardexFactory.getPair(data.token0, data.token1)) {
            revert ISmardexRouterErrors.InvalidPair();
        }

        Payment.pay(permit2, data.token0, data.payer, msg.sender, data.amount0);
        Payment.pay(permit2, data.token1, data.payer, msg.sender, data.amount1);
    }

    /**
     * @notice Performs a Smardex exact input swap
     * @dev Use router balance if the payer is the router or use permit2 from msg.sender
     * @param smardexFactory The Smardex factory contract
     * @param recipient The recipient of the output tokens
     * @param amountIn The amount of input tokens for the trade
     * @param path The path of the trade as a bytes string
     * @param payer The address that will be paying the input
     * @return amountOut_ The amount out
     */
    function smardexSwapExactInput(
        ISmardexFactory smardexFactory,
        address recipient,
        uint256 amountIn,
        bytes memory path,
        address payer
    ) external returns (uint256 amountOut_) {
        // use amountIn == Constants.CONTRACT_BALANCE as a flag to swap the entire balance of the contract
        if (amountIn == Constants.CONTRACT_BALANCE && payer == address(this)) {
            address tokenIn = path.decodeFirstToken();
            amountIn = IERC20(tokenIn).balanceOf(address(this));
        }

        while (true) {
            bool hasMultiplePools = path.hasMultiplePools();
            amountIn = _swapExactIn(
                smardexFactory,
                amountIn,
                hasMultiplePools ? address(this) : recipient,
                // only the first pool in the path is necessary
                ISmardexRouter.SwapCallbackData({ path: path.getFirstPool(), payer: payer })
            );

            if (hasMultiplePools) {
                payer = address(this);
                path = path.skipToken();
            } else {
                amountOut_ = amountIn;
                break;
            }
        }
    }

    /**
     * @notice Performs a Smardex exact output swap
     * @dev Use router balance if the payer is the router or use permit2 from msg.sender
     * @param smardexFactory The Smardex factory contract
     * @param recipient The recipient of the output tokens
     * @param amountOut The amount of output tokens to receive for the swap
     * @param path The path of the trade as a bytes string
     * @param payer The address that will be paying the input
     * @return amountIn_ The amount of input tokens to pay
     */
    function smardexSwapExactOutput(
        ISmardexFactory smardexFactory,
        address recipient,
        uint256 amountOut,
        bytes memory path,
        address payer
    ) external returns (uint256 amountIn_) {
        // path needs to be reversed to get the amountIn that we will ask from the next pair hop
        bytes memory reversedPath = path.encodeTightlyPackedReversed();

        amountIn_ = _swapExactOut(
            smardexFactory, amountOut, recipient, ISmardexRouter.SwapCallbackData({ path: reversedPath, payer: payer })
        );
    }

    /**
     * @notice Adds liquidity in a Smardex pool.
     * @dev During the mint of the liquidity tokens, {smardexSwapCallback} will be called which will call for a transfer
     * of the tokens to the pair. Use the router's balance if the payer is the router or use permit2 if it's msg.sender.
     * @param smardexFactory The Smardex factory contract.
     * @param params The smardex add liquidity params.
     * @param receiver The liquidity receiver address.
     * @param payer The payer address.
     * @param deadline The deadline before which the liquidity must be added.
     * @return success_ Whether the liquidity was successfully added.
     * @return output_ The output which contains amountA, amountB and the amount of liquidity tokens minted.
     */
    function addLiquidity(
        ISmardexFactory smardexFactory,
        ISmardexRouter.AddLiquidityParams calldata params,
        address receiver,
        address payer,
        uint256 deadline
    ) external returns (bool success_, bytes memory output_) {
        if (block.timestamp > deadline) {
            revert ISmardexRouterErrors.DeadlineExceeded();
        }

        address pair = _getTokenPair(smardexFactory, params.tokenA, params.tokenB, receiver);
        (uint256 amountA, uint256 amountB) = _computesLiquidityToAdd(params, pair);
        (uint256 amount0, uint256 amount1) = PoolHelpers.sortAmounts(params.tokenA, params.tokenB, amountA, amountB);
        uint256 liquidity = ISmardexPair(pair).mint(receiver, amount0, amount1, payer);
        return (true, abi.encode(amountA, amountB, liquidity));
    }

    /**
     * @notice Removes liquidity from a Smardex pool.
     * @param smardexFactory The Smardex factory contract.
     * @param permit2 The permit2 contract.
     * @param params The parameters for removing liquidity.
     * @param payer The payer address.
     * @param receiver The recipient of the tokens.
     * @param deadline The deadline before which the liquidity must be removed.
     * @return success_ Whether the liquidity was successfully removed.
     * @return output_ The output which contains the amount of tokenA and tokenB received.
     */
    function removeLiquidity(
        ISmardexFactory smardexFactory,
        IAllowanceTransfer permit2,
        ISmardexRouter.RemoveLiquidityParams calldata params,
        address receiver,
        address payer,
        uint256 deadline
    ) external returns (bool success_, bytes memory output_) {
        if (block.timestamp > deadline) {
            revert ISmardexRouterErrors.DeadlineExceeded();
        }
        if (params.tokenA == params.tokenB) {
            revert ISmardexRouterErrors.InvalidTokenAddress();
        }
        if (params.tokenA == address(0) || params.tokenB == address(0)) {
            revert ISmardexRouterErrors.InvalidTokenAddress();
        }

        ISmardexPair pair = ISmardexPair(smardexFactory.getPair(params.tokenA, params.tokenB));

        if (address(pair) == address(0)) {
            revert ISmardexRouterErrors.InvalidPair();
        }

        Payment.pay(permit2, address(pair), payer, address(pair), params.liquidity);

        (uint256 amount0, uint256 amount1) = pair.burn(receiver);
        (uint256 amountA, uint256 amountB) = params.tokenA < params.tokenB ? (amount0, amount1) : (amount1, amount0);

        if (amountA < params.amountAMin) {
            revert ISmardexRouterErrors.InsufficientAmountA();
        }
        if (amountB < params.amountBMin) {
            revert ISmardexRouterErrors.InsufficientAmountB();
        }

        return (true, abi.encode(amountA, amountB));
    }

    /**
     * @notice Internal function to swap quantity of token to receive a determined quantity
     * @param smardexFactory The Smardex factory contract
     * @param amountOut The quantity to receive
     * @param to The address that will receive the token
     * @param data The SwapCallbackData data of the swap to transmit
     * @return amountIn_ The amount of token to pay
     */
    function _swapExactOut(
        ISmardexFactory smardexFactory,
        uint256 amountOut,
        address to,
        ISmardexRouter.SwapCallbackData memory data
    ) private returns (uint256 amountIn_) {
        if (to == address(0)) {
            revert ISmardexRouterErrors.InvalidRecipient();
        }

        (address tokenOut, address tokenIn) = data.path.decodeFirstPool();
        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) = ISmardexPair(smardexFactory.getPair(tokenIn, tokenOut)).swap(
            to, zeroForOne, -amountOut.toInt256(), abi.encode(data)
        );

        if (zeroForOne) {
            amountIn_ = uint256(amount0);
        } else {
            amountIn_ = uint256(amount1);
        }
    }

    /**
     * @notice Internal function to swap a determined quantity of token
     * @param smardexFactory The Smardex factory contract
     * @param amountIn The quantity to swap
     * @param to The address that will receive the token
     * @param data The SwapCallbackData data of the swap to transmit
     * @return amountOut_ The amount of token that _to will receive
     */
    function _swapExactIn(
        ISmardexFactory smardexFactory,
        uint256 amountIn,
        address to,
        ISmardexRouter.SwapCallbackData memory data
    ) private returns (uint256 amountOut_) {
        // allow swapping to the router address with address 0
        if (to == address(0)) {
            to = address(this);
        }

        (address tokenIn, address tokenOut) = data.path.decodeFirstPool();
        bool _zeroForOne = tokenIn < tokenOut;
        (int256 amount0, int256 amount1) = ISmardexPair(smardexFactory.getPair(tokenIn, tokenOut)).swap(
            to, _zeroForOne, amountIn.toInt256(), abi.encode(data)
        );
        amountOut_ = (_zeroForOne ? -amount1 : -amount0).toUint256();
    }

    /**
     * @notice Gets the pair depending on the pair.
     * @dev Creates the pair if it doesn't exists.
     * @param smardexFactory The smardex factory.
     * @param tokenA The address of the first token of the pair.
     * @param tokenB The address of the second token of the pair.
     * @param skimReceiver The recipient of the possibly skimmed tokens.
     * @return pair_ The address of the pool where the liquidity was added.
     */
    function _getTokenPair(ISmardexFactory smardexFactory, address tokenA, address tokenB, address skimReceiver)
        private
        returns (address pair_)
    {
        pair_ = smardexFactory.getPair(tokenA, tokenB);
        // If the pair does not exist, create it
        if (pair_ == address(0)) {
            pair_ = smardexFactory.createPair(tokenA, tokenB);
        }

        if (ISmardexPair(pair_).totalSupply() == 0) {
            ISmardexPair(pair_).skim(skimReceiver); // in case some tokens are already on the pair
        }
    }

    /**
     * @notice Computes the amount of tokens to add as liquidity based on the given parameters.
     * @param params Parameters of the liquidity to add.
     * @param pair The token pair to add liquidity to.
     * @return amountA_ The amount of tokenA to send to the pool.
     * @return amountB_ The amount of tokenB to send to the pool.
     */
    function _computesLiquidityToAdd(ISmardexRouter.AddLiquidityParams calldata params, address pair)
        internal
        view
        returns (uint256 amountA_, uint256 amountB_)
    {
        (uint256 reserveA, uint256 reserveB, uint256 reserveAFic, uint256 reserveBFic) =
            PoolHelpers.getAllReserves(ISmardexPair(pair), params.tokenA);

        if (reserveA == 0 && reserveB == 0) {
            (amountA_, amountB_) = (params.amountADesired, params.amountBDesired);
        } else {
            uint256 product = reserveAFic * params.fictiveReserveB;

            if (product > params.fictiveReserveAMax * reserveBFic) {
                revert ISmardexRouterErrors.PriceTooHigh();
            }
            if (product < params.fictiveReserveAMin * reserveBFic) {
                revert ISmardexRouterErrors.PriceTooLow();
            }

            uint256 amountBOptimal = PoolHelpers.quote(params.amountADesired, reserveA, reserveB);

            if (amountBOptimal <= params.amountBDesired) {
                if (amountBOptimal < params.amountBMin) {
                    revert ISmardexRouterErrors.InsufficientAmountB();
                }

                (amountA_, amountB_) = (params.amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = PoolHelpers.quote(params.amountBDesired, reserveB, reserveA);

                // sanity check
                if (amountAOptimal > params.amountADesired) {
                    revert ISmardexRouterErrors.InsufficientAmountADesired();
                }
                if (amountAOptimal < params.amountAMin) {
                    revert ISmardexRouterErrors.InsufficientAmountA();
                }

                (amountA_, amountB_) = (amountAOptimal, params.amountBDesired);
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import { UniswapV2Library } from "@uniswap/universal-router/contracts/modules/uniswap/v2/UniswapV2Library.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { SafeTransferLib } from "solmate/src/utils/SafeTransferLib.sol";

import { IUniswapV2Router } from "../../interfaces/uniswap/IUniswapV2Router.sol";
import { IUniswapV2RouterErrors } from "../../interfaces/uniswap/IUniswapV2RouterErrors.sol";
import { Payment } from "../../utils/Payment.sol";

/// @title Router library for Uniswap v2
library UniswapV2RouterLib {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using SafeTransferLib for address;

    /**
     * @notice Performs a Uniswap v2 exact input swap
     * @param uniswapV2Factory The address of UniswapV2Factory
     * @param uniswapV2PairInitCodeHash The UniswapV2Pair init code hash
     * @param permit2 The permit2 contract
     * @param recipient The recipient of the output tokens
     * @param amountIn The amount of input tokens for the trade
     * @param amountOutMinimum The minimum desired amount of output tokens
     * @param path The path of the trade as an array of token addresses
     * @param payer The address that will be paying the input
     */
    function v2SwapExactInput(
        address uniswapV2Factory,
        bytes32 uniswapV2PairInitCodeHash,
        IAllowanceTransfer permit2,
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address[] calldata path,
        address payer
    ) external {
        address firstPair = UniswapV2Library.pairFor(uniswapV2Factory, uniswapV2PairInitCodeHash, path[0], path[1]);
        if (
            amountIn != Constants.ALREADY_PAID // amountIn of 0 to signal that the pair already has the tokens
        ) {
            Payment.pay(permit2, path[0], payer, firstPair, amountIn);
        }

        IERC20 tokenOut = IERC20(path[path.length - 1]);
        uint256 balanceBefore = tokenOut.balanceOf(recipient);

        _v2Swap(uniswapV2Factory, uniswapV2PairInitCodeHash, path, recipient, firstPair);

        uint256 amountOut = tokenOut.balanceOf(recipient) - balanceBefore;
        if (amountOut < amountOutMinimum) {
            revert IUniswapV2RouterErrors.UniswapV2TooLittleReceived();
        }
    }

    /**
     * @notice Performs a Uniswap v2 exact output swap
     * @param uniswapV2Factory The address of UniswapV2Factory
     * @param uniswapV2PairInitCodeHash The UniswapV2Pair init code hash
     * @param permit2 The permit2 contract
     * @param recipient The recipient of the output tokens
     * @param amountOut The amount of output tokens to receive for the trade
     * @param amountInMaximum The maximum desired amount of input tokens
     * @param path The path of the trade as an array of token addresses
     * @param payer The address that will be paying the input
     */
    function v2SwapExactOutput(
        address uniswapV2Factory,
        bytes32 uniswapV2PairInitCodeHash,
        IAllowanceTransfer permit2,
        address recipient,
        uint256 amountOut,
        uint256 amountInMaximum,
        address[] calldata path,
        address payer
    ) external {
        (uint256 amountIn, address firstPair) =
            UniswapV2Library.getAmountInMultihop(uniswapV2Factory, uniswapV2PairInitCodeHash, amountOut, path);
        if (amountIn > amountInMaximum) {
            revert IUniswapV2RouterErrors.UniswapV2TooMuchRequested();
        }

        Payment.pay(permit2, path[0], payer, firstPair, amountIn);
        _v2Swap(uniswapV2Factory, uniswapV2PairInitCodeHash, path, recipient, firstPair);
    }

    /**
     * @notice Checks if the path is valid and performs the swap
     * @param uniswapV2Factory The address of UniswapV2Factory
     * @param uniswapV2PairInitCodeHash The UniswapV2Pair init code hash
     * @param path The path of the trade as an array of token addresses
     * @param recipient The recipient of the output tokens
     * @param pair The address of the pair to start the swap
     */
    function _v2Swap(
        address uniswapV2Factory,
        bytes32 uniswapV2PairInitCodeHash,
        address[] calldata path,
        address recipient,
        address pair
    ) internal {
        unchecked {
            if (path.length < 2) {
                revert IUniswapV2RouterErrors.UniswapV2InvalidPath();
            }

            // cached to save on duplicate operations
            (address token0,) = UniswapV2Library.sortTokens(path[0], path[1]);
            uint256 finalPairIndex = path.length - 1;
            uint256 penultimatePairIndex = finalPairIndex - 1;
            for (uint256 i; i < finalPairIndex; i++) {
                IUniswapV2Router.V2SwapData memory data;

                (data.input, data.output) = (path[i], path[i + 1]);

                (data.reserve0, data.reserve1,) = IUniswapV2Pair(pair).getReserves();

                (data.reserveInput, data.reserveOutput) =
                    data.input == token0 ? (data.reserve0, data.reserve1) : (data.reserve1, data.reserve0);

                data.amountInput = IERC20(data.input).balanceOf(pair) - data.reserveInput;

                data.amountOutput =
                    UniswapV2Library.getAmountOut(data.amountInput, data.reserveInput, data.reserveOutput);

                (data.amount0Out, data.amount1Out) =
                    data.input == token0 ? (uint256(0), data.amountOutput) : (data.amountOutput, uint256(0));
                (data.nextPair, token0) = i < penultimatePairIndex
                    ? UniswapV2Library.pairAndToken0For(
                        uniswapV2Factory, uniswapV2PairInitCodeHash, data.output, path[i + 2]
                    )
                    : (recipient, address(0));
                IUniswapV2Pair(pair).swap(data.amount0Out, data.amount1Out, data.nextPair, new bytes(0));
                pair = data.nextPair;
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { IPaymentLibTypes } from "../../interfaces/usdn/IPaymentLibTypes.sol";
import { TransientStorageLib } from "../TransientStorageLib.sol";

library PaymentLib {
    /// @notice The transient payment storage slot
    bytes32 private constant TRANSIENT_PAYMENT_SLOT =
        keccak256(abi.encode(uint256(keccak256("transient.payment")) - 1)) & ~bytes32(uint256(0xff));

    /**
     * @notice Set the payment value
     * @param payment The payment value
     */
    function setPayment(IPaymentLibTypes.PaymentType payment) internal {
        TransientStorageLib.setTransientValue(TRANSIENT_PAYMENT_SLOT, bytes32(uint256(payment)));
    }

    /**
     * @notice Get the payment value
     * @return payment_ The payment value
     */
    function getPayment() internal view returns (IPaymentLibTypes.PaymentType payment_) {
        payment_ = IPaymentLibTypes.PaymentType(uint256(TransientStorageLib.getTransientValue(TRANSIENT_PAYMENT_SLOT)));
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";
import { IUsdn } from "usdn-contracts/src/interfaces/Usdn/IUsdn.sol";
import { IWusdn } from "usdn-contracts/src/interfaces/Usdn/IWusdn.sol";
import { IUsdnProtocol } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocol.sol";
import { IUsdnProtocolTypes } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";
import { IRebalancer } from "usdn-contracts/src/interfaces/Rebalancer/IRebalancer.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";

import { IUsdnProtocolRouterTypes } from "../../interfaces/usdn/IUsdnProtocolRouterTypes.sol";
import { IPaymentLibTypes } from "../../interfaces/usdn/IPaymentLibTypes.sol";
import { IUsdnProtocolRouterErrors } from "../../interfaces/usdn/IUsdnProtocolRouterErrors.sol";
import { PaymentLib } from "./PaymentLib.sol";

/// @title Router library for UsdnProtocol
library UsdnProtocolRouterLib {
    using SafeCast for uint256;
    using SafeERC20 for IERC20Metadata;
    using SafeERC20 for IUsdn;

    /**
     * @notice The payment modifier
     * @param payment The payment value
     * @param action The USDN protocol action
     */
    modifier usePayment(IPaymentLibTypes.PaymentType payment, IPaymentLibTypes.PaymentAction action) {
        if (
            payment == IPaymentLibTypes.PaymentType.None
                || (action == IPaymentLibTypes.PaymentAction.Withdrawal && payment == IPaymentLibTypes.PaymentType.Permit2)
        ) {
            revert IUsdnProtocolRouterErrors.UsdnProtocolRouterInvalidPayment();
        }

        PaymentLib.setPayment(payment);
        _;
        PaymentLib.setPayment(IPaymentLibTypes.PaymentType.None);
    }

    /**
     * @notice Initiate a deposit into the USDN protocol vault
     * @dev Check the protocol's documentation for information about how this function should be used
     * Note: the deposit can fail without reverting, in case there are some pending liquidations in the protocol
     * @param protocolAsset The USDN protocol asset
     * @param usdnProtocol The USDN protocol
     * @param data The USDN initiateDeposit router data
     * @return success_ Whether the deposit was successful
     */
    function usdnInitiateDeposit(
        IERC20Metadata protocolAsset,
        IUsdnProtocol usdnProtocol,
        IUsdnProtocolRouterTypes.InitiateDepositData memory data
    ) external usePayment(data.payment, IPaymentLibTypes.PaymentAction.Deposit) returns (bool success_) {
        // use amount == Constants.CONTRACT_BALANCE as a flag to deposit the entire balance of the contract
        if (data.amount == Constants.CONTRACT_BALANCE) {
            data.amount = protocolAsset.balanceOf(address(this));
        }
        // slither-disable-next-line arbitrary-send-eth
        success_ = usdnProtocol.initiateDeposit{ value: data.ethAmount }(
            // cast is made here to allow the {CONTRACT_BALANCE} value
            data.amount.toUint128(),
            data.sharesOutMin,
            data.to,
            payable(data.validator),
            data.deadline,
            data.currentPriceData,
            data.previousActionsData
        );
    }

    /**
     * @notice Validate a deposit into the USDN protocol vault
     * @dev Check the protocol's documentation for information about how this function should be used
     * @param usdnProtocol The USDN protocol
     * @param validator The address that should validate the deposit (receives the security deposit)
     * @param depositPriceData The price data corresponding to the validator's pending deposit action
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the deposit was successfully
     */
    function usdnValidateDeposit(
        IUsdnProtocol usdnProtocol,
        address validator,
        bytes memory depositPriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 ethAmount
    ) external returns (bool success_) {
        // slither-disable-next-line arbitrary-send-eth
        success_ =
            usdnProtocol.validateDeposit{ value: ethAmount }(payable(validator), depositPriceData, previousActionsData);
    }

    /**
     * @notice Initiate a withdrawal from the USDN protocol vault
     * @dev Check the protocol's documentation for information about how this function should be used
     * Note: the withdrawal can fail without reverting, in case there are some pending liquidations in the protocol
     * @param usdn The USDN token
     * @param usdnProtocol The USDN protocol
     * @param payment The USDN protocol payment method
     * @param sharesAmount The amount of USDN shares to burn
     * @param amountOutMin The minimum amount of assets to receive
     * @param to The address that will receive the asset upon validation
     * @param validator The address that should validate the withdrawal (receives the security deposit back)
     * @param deadline The transaction deadline
     * @param currentPriceData The current price data
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the withdrawal was successful
     */
    function usdnInitiateWithdrawal(
        IUsdn usdn,
        IUsdnProtocol usdnProtocol,
        IPaymentLibTypes.PaymentType payment,
        uint256 sharesAmount,
        uint256 amountOutMin,
        address to,
        address validator,
        uint256 deadline,
        bytes memory currentPriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 ethAmount
    ) external usePayment(payment, IPaymentLibTypes.PaymentAction.Withdrawal) returns (bool success_) {
        // use amount == Constants.CONTRACT_BALANCE as a flag to withdraw the entire balance of the contract
        if (sharesAmount == Constants.CONTRACT_BALANCE) {
            sharesAmount = usdn.sharesOf(address(this));
        }
        // slither-disable-next-line arbitrary-send-eth
        success_ = usdnProtocol.initiateWithdrawal{ value: ethAmount }(
            sharesAmount.toUint152(),
            amountOutMin,
            to,
            payable(validator),
            deadline,
            currentPriceData,
            previousActionsData
        );
    }

    /**
     * @notice Validate a withdrawal into the USDN protocol vault
     * @dev Check the protocol's documentation for information about how this function should be used
     * Note: the withdrawal can fail without reverting, in case there are some pending liquidations in the protocol
     * @param usdnProtocol The USDN protocol
     * @param validator The address that should validate the withdrawal (receives the security deposit)
     * @param withdrawalPriceData The price data corresponding to the validator's pending deposit action
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the withdrawal was successful
     */
    function usdnValidateWithdrawal(
        IUsdnProtocol usdnProtocol,
        address validator,
        bytes memory withdrawalPriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 ethAmount
    ) external returns (bool success_) {
        // slither-disable-next-line arbitrary-send-eth
        success_ = usdnProtocol.validateWithdrawal{ value: ethAmount }(
            payable(validator), withdrawalPriceData, previousActionsData
        );
    }

    /**
     * @notice Initiate an open position in the USDN protocol
     * @dev Check the protocol's documentation for information about how this function should be used
     * Note: the open position can fail without reverting, in case there are some pending liquidations in the protocol
     * @param protocolAsset The USDN protocol asset
     * @param usdnProtocol The USDN protocol
     * @param data The initiateOpenPosition router data
     * @return success_ Whether the open position was successful
     * @return posId_ The position ID of the newly opened position
     */
    function usdnInitiateOpenPosition(
        IERC20Metadata protocolAsset,
        IUsdnProtocol usdnProtocol,
        IUsdnProtocolRouterTypes.InitiateOpenPositionData memory data
    )
        external
        usePayment(data.payment, IPaymentLibTypes.PaymentAction.Open)
        returns (bool success_, IUsdnProtocolTypes.PositionId memory posId_)
    {
        // use amount == Constants.CONTRACT_BALANCE as a flag to deposit the entire balance of the contract
        if (data.amount == Constants.CONTRACT_BALANCE) {
            data.amount = protocolAsset.balanceOf(address(this));
        }
        protocolAsset.forceApprove(address(usdnProtocol), data.amount);
        // we send the full ETH balance, and the protocol will refund any excess
        // slither-disable-next-line arbitrary-send-eth
        (success_, posId_) = usdnProtocol.initiateOpenPosition{ value: data.ethAmount }(
            data.amount.toUint128(),
            data.desiredLiqPrice.toUint128(),
            data.userMaxPrice.toUint128(),
            data.userMaxLeverage,
            data.to,
            payable(data.validator),
            data.deadline,
            data.currentPriceData,
            data.previousActionsData
        );
    }

    /**
     * @notice Validate an open position in the USDN protocol
     * @dev Check the protocol's documentation for information about how this function should be used
     * @param usdnProtocol The USDN protocol
     * @param validator The address that should validate the open position (receives the security deposit)
     * @param openPositionPriceData The price data corresponding to the validator's pending open position action
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the open position was successful
     */
    function usdnValidateOpenPosition(
        IUsdnProtocol usdnProtocol,
        address validator,
        bytes memory openPositionPriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 ethAmount
    ) external returns (bool success_) {
        // slither-disable-next-line arbitrary-send-eth
        (IUsdnProtocolTypes.LongActionOutcome outcome_,) = usdnProtocol.validateOpenPosition{ value: ethAmount }(
            payable(validator), openPositionPriceData, previousActionsData
        );
        return outcome_ == IUsdnProtocolTypes.LongActionOutcome.Processed;
    }

    /**
     * @notice Validate a close position in the USDN protocol
     * @dev Check the protocol's documentation for information about how this function should be used
     * @param usdnProtocol The USDN protocol
     * @param validator The address of the validator
     * @param closePriceData The price data corresponding to the position's close
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the close position was successful
     */
    function usdnValidateClosePosition(
        IUsdnProtocol usdnProtocol,
        address validator,
        bytes memory closePriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 ethAmount
    ) external returns (bool success_) {
        // slither-disable-next-line arbitrary-send-eth
        IUsdnProtocolTypes.LongActionOutcome outcome_ = usdnProtocol.validateClosePosition{ value: ethAmount }(
            payable(validator), closePriceData, previousActionsData
        );
        return outcome_ == IUsdnProtocolTypes.LongActionOutcome.Processed;
    }

    /**
     * @notice Validate actionable pending action in the USDN protocol
     * @dev Check the protocol's documentation for information about how this function should be used
     * @param usdnProtocol The USDN protocol
     * @param previousActionsData The data needed to validate actionable pending actions
     * @param maxValidations The maximum number of pending actions to validate
     * @param ethAmount The amount of Ether to send with the transaction
     */
    function usdnValidateActionablePendingActions(
        IUsdnProtocol usdnProtocol,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        uint256 maxValidations,
        uint256 ethAmount
    ) external {
        // slither-disable-next-line arbitrary-send-eth
        usdnProtocol.validateActionablePendingActions{ value: ethAmount }(previousActionsData, maxValidations);
    }

    /**
     * @notice Wrap the usdn shares value into wusdn
     * @param usdn The USDN token
     * @param wusdn The WUSDN token
     * @param value The USDN value in shares
     * @param receiver The WUSDN receiver
     */
    function wrapUSDNShares(IUsdn usdn, IWusdn wusdn, uint256 value, address receiver) external {
        if (value == Constants.CONTRACT_BALANCE) {
            value = usdn.sharesOf(address(this));
        }

        if (value > 0) {
            // due to the rounding in the USDN's `balanceOf` function,
            // we approve max uint256 then reset to 0
            usdn.forceApprove(address(wusdn), type(uint256).max);
            wusdn.wrapShares(value, receiver);
            usdn.approve(address(wusdn), 0);
        }
    }

    /**
     * @notice Unwrap the wusdn value into usdn
     * @param wusdn The WUSDN token
     * @param value The WUSDN value
     * @param receiver The USDN receiver
     */
    function unwrapUSDN(IWusdn wusdn, uint256 value, address receiver) external {
        if (value == Constants.CONTRACT_BALANCE) {
            value = wusdn.balanceOf(address(this));
        }

        if (value > 0) {
            wusdn.unwrap(value, receiver);
        }
    }

    /**
     * @notice Performs tick liquidations of the USDN protocol
     * @param usdnProtocol The USDN protocol
     * @param currentPriceData The current price data
     * @param ethAmount The amount of Ether to send with the transaction
     */
    function usdnLiquidate(IUsdnProtocol usdnProtocol, bytes memory currentPriceData, uint256 ethAmount) external {
        // slither-disable-next-line arbitrary-send-eth
        usdnProtocol.liquidate{ value: ethAmount }(currentPriceData);
    }

    /**
     * @notice Performs rebalancer initiate deposit
     * @param usdnProtocol The USDN protocol
     * @param amount The initiateDeposit amount
     * @param to The address for which the deposit will be initiated
     * @return success_ Whether the initiate deposit is successful
     * @return data_ The transaction data
     */
    function rebalancerInitiateDeposit(IUsdnProtocol usdnProtocol, uint256 amount, address to)
        external
        returns (bool success_, bytes memory data_)
    {
        address rebalancerAddress = address(usdnProtocol.getRebalancer());

        if (rebalancerAddress == address(0)) {
            return (false, "");
        }

        IERC20Metadata asset = IRebalancer(rebalancerAddress).getAsset();

        if (amount == Constants.CONTRACT_BALANCE) {
            amount = asset.balanceOf(address(this));
        }

        if (amount == 0) {
            return (false, "");
        }

        asset.forceApprove(rebalancerAddress, amount);

        (success_, data_) = rebalancerAddress.call(
            abi.encodeWithSelector(IRebalancer.initiateDepositAssets.selector, amount.toUint88(), to)
        );
    }

    /**
     * @notice Performs a rebalancer initiate close position
     * @param usdnProtocol The USDN protocol
     * @param amount The amount to close
     * @param to The address for which the close will be initiated
     * @param validator The address that will receive the security deposit
     * @param userMinPrice The minimum price of the close position
     * @param deadline The initiate close position deadline
     * @param currentPriceData The current price data
     * @param previousActionsData The previous action price data
     * @param delegationData The delegation data
     * @param ethAmount The amount of Ether to send with the transaction
     * @return success_ Whether the initiate deposit is successful
     * @return data_ The transaction data
     */
    function rebalancerInitiateClosePosition(
        IUsdnProtocol usdnProtocol,
        uint256 amount,
        address to,
        address payable validator,
        uint256 userMinPrice,
        uint256 deadline,
        bytes memory currentPriceData,
        IUsdnProtocolTypes.PreviousActionsData memory previousActionsData,
        bytes memory delegationData,
        uint256 ethAmount
    ) external returns (bool success_, bytes memory data_) {
        address rebalancerAddress = address(usdnProtocol.getRebalancer());

        if (rebalancerAddress == address(0)) {
            return (false, "");
        }

        // slither-disable-next-line arbitrary-send-eth
        (success_, data_) = rebalancerAddress.call{ value: ethAmount }(
            abi.encodeWithSelector(
                IRebalancer.initiateClosePosition.selector,
                amount.toUint88(),
                to,
                validator,
                userMinPrice,
                deadline,
                currentPriceData,
                previousActionsData,
                delegationData
            )
        );
    }

    /**
     * @notice Callback function to be called during initiate functions to transfer tokens to the protocol contract
     * @dev The implementation must ensure that the `msg.sender` is the protocol contract
     * @param usdnProtocol The USDN protocol contract address
     * @param lockedBy The router lockedBy address
     * @param permit2 The permit2 contract
     * @param token The token to transfer
     * @param amount The amount to transfer
     * @param to The address of the recipient
     */
    function transferCallback(
        address usdnProtocol,
        address lockedBy,
        IAllowanceTransfer permit2,
        IERC20Metadata token,
        uint256 amount,
        address to
    ) external {
        if (msg.sender != usdnProtocol) {
            revert IUsdnProtocolRouterErrors.UsdnProtocolRouterInvalidSender();
        }

        IPaymentLibTypes.PaymentType payment = PaymentLib.getPayment();

        if (payment == IPaymentLibTypes.PaymentType.Transfer) {
            token.safeTransfer(to, amount);
        } else if (payment == IPaymentLibTypes.PaymentType.TransferFrom) {
            // slither-disable-next-line arbitrary-send-erc20
            token.safeTransferFrom(lockedBy, to, amount);
        } else if (payment == IPaymentLibTypes.PaymentType.Permit2) {
            permit2.transferFrom(lockedBy, to, amount.toUint160(), address(token));
        } else {
            // sanity check: this should never happen
            revert IUsdnProtocolRouterErrors.UsdnProtocolRouterInvalidPayment();
        }
    }

    /**
     * @notice Callback function to be called during `initiateWithdrawal` to transfer USDN shares to the protocol
     * @dev The implementation must ensure that the `msg.sender` is the protocol contract
     * @param usdnProtocol The USDN protocol contract address
     * @param usdn The USDN contract address
     * @param lockedBy The router lockedBy address
     * @param shares The amount of USDN shares to transfer to the `msg.sender`
     */
    function usdnTransferCallback(address usdnProtocol, IUsdn usdn, address lockedBy, uint256 shares) external {
        if (msg.sender != usdnProtocol) {
            revert IUsdnProtocolRouterErrors.UsdnProtocolRouterInvalidSender();
        }

        IPaymentLibTypes.PaymentType payment = PaymentLib.getPayment();

        if (payment == IPaymentLibTypes.PaymentType.Transfer) {
            usdn.transferShares(msg.sender, shares);
        } else if (payment == IPaymentLibTypes.PaymentType.TransferFrom) {
            usdn.transferSharesFrom(lockedBy, msg.sender, shares);
        } else {
            // sanity check: this should never happen
            revert IUsdnProtocolRouterErrors.UsdnProtocolRouterInvalidPayment();
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { Payments } from "@uniswap/universal-router/contracts/modules/Payments.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";
import { SafeTransferLib } from "solmate/src/utils/SafeTransferLib.sol";
import { ERC20 } from "solmate/src/tokens/ERC20.sol";

import { ISweepErrors } from "../interfaces/ISweepErrors.sol";

/**
 * @title Sweep contract
 * @notice Sweeps all of the contract's ERC20 or ETH to an address
 */
abstract contract Sweep {
    using SafeTransferLib for ERC20;
    using SafeTransferLib for address;

    /**
     * @notice Sweeps all of the contract's ERC20 or ETH to an address
     * @param token The token to sweep (can be ETH using Constants.ETH)
     * @param recipient The address that will receive payment
     * @param amountOutMin The minimum desired amount
     * @param amountOutThreshold The minimum amount to activate the sweep
     */
    function sweep(address token, address recipient, uint256 amountOutMin, uint256 amountOutThreshold) internal {
        uint256 balance;
        if (token == Constants.ETH) {
            if (recipient == address(0)) {
                revert ISweepErrors.SweepInvalidRecipient();
            }
            balance = address(this).balance;
            if (balance < amountOutMin) {
                revert Payments.InsufficientETH();
            }
            if (balance >= amountOutThreshold) {
                recipient.safeTransferETH(balance);
            }
        } else {
            balance = ERC20(token).balanceOf(address(this));
            if (balance < amountOutMin) {
                revert Payments.InsufficientToken();
            }
            if (balance >= amountOutThreshold) {
                ERC20(token).safeTransfer(recipient, balance);
            }
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IWstETH } from "../../interfaces/lido/IWstETH.sol";
import { IStETH } from "../../interfaces/lido/IStETH.sol";
import { ILidoImmutables } from "../../interfaces/lido/ILidoImmutables.sol";

contract LidoImmutables is ILidoImmutables {
    /// @inheritdoc ILidoImmutables
    IStETH public immutable STETH;

    /// @dev The address of the wrapped steth
    IWstETH internal immutable WSTETH;

    /// @param wsteth The address of wrapped steth
    constructor(address wsteth) {
        WSTETH = IWstETH(wsteth);
        STETH = IStETH(WSTETH.stETH());
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IWETH9 } from "@uniswap/universal-router/contracts/interfaces/external/IWETH9.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";

import { ISmardexFactory } from "../../interfaces/smardex/ISmardexFactory.sol";

/**
 * @notice The Smardex parameters struct
 * @param smardexFactory The Smardex factory
 * @param weth The wrapped ETH address
 * @param permit2 The permit2 address
 */
struct SmardexParameters {
    ISmardexFactory smardexFactory;
    address weth;
    address permit2;
}

contract SmardexImmutables {
    /// @dev The Smardex factory
    ISmardexFactory internal immutable SMARDEX_FACTORY;

    /// @dev The wrapped ETH
    IWETH9 internal immutable WETH;

    /// @dev The permit2 contract
    IAllowanceTransfer internal immutable SMARDEX_PERMIT2;

    /// @param params The Smardex parameters
    constructor(SmardexParameters memory params) {
        SMARDEX_FACTORY = params.smardexFactory;
        WETH = IWETH9(params.weth);
        SMARDEX_PERMIT2 = IAllowanceTransfer(params.permit2);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { ISmardexRouter } from "../../interfaces/smardex/ISmardexRouter.sol";
import { ISmardexRouterErrors } from "../../interfaces/smardex/ISmardexRouterErrors.sol";
import { Path } from "../../libraries/smardex/Path.sol";
import { SmardexRouterLib } from "../../libraries/smardex/SmardexRouterLib.sol";
import { SmardexImmutables } from "./SmardexImmutables.sol";

/// @title Router for Smardex
abstract contract SmardexRouter is ISmardexRouter, SmardexImmutables {
    /// @dev Transient storage variable used for checking slippage
    uint256 private amountInCached = type(uint256).max;

    /// @dev The size in bytes of a single address
    uint8 private constant ADDR_SIZE = 20;

    /// @inheritdoc ISmardexRouter
    function smardexSwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        uint256 amountIn =
            SmardexRouterLib.smardexSwapCallback(SMARDEX_FACTORY, SMARDEX_PERMIT2, amount0Delta, amount1Delta, data);
        if (amountIn > 0) {
            amountInCached = amountIn;
        }
    }

    /// @inheritdoc ISmardexRouter
    function smardexMintCallback(MintCallbackData calldata data) external {
        SmardexRouterLib.smardexMintCallback(SMARDEX_FACTORY, SMARDEX_PERMIT2, data);
    }

    /**
     * @notice Performs a Smardex exact input swap
     * @dev Use router balance if payer is the router or use permit2 from msg.sender
     * @param recipient The recipient of the output tokens
     * @param amountIn The amount of input tokens for the trade
     * @param amountOutMinimum The minimum desired amount of output tokens
     * @param path The path of the trade as a bytes string
     * @param payer The address that will be paying the input
     */
    function _smardexSwapExactInput(
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum,
        bytes calldata path,
        address payer
    ) internal {
        uint256 amountOut = SmardexRouterLib.smardexSwapExactInput(SMARDEX_FACTORY, recipient, amountIn, path, payer);

        if (amountOut < amountOutMinimum) {
            revert ISmardexRouterErrors.TooLittleReceived();
        }
    }

    /**
     * @notice Performs a Smardex exact output swap
     * @dev Use router balance if payer is the router or use permit2 from msg.sender
     * @param recipient The recipient of the output tokens
     * @param amountOut The amount of output tokens to receive for the trade
     * @param amountInMax The maximum desired amount of input tokens
     * @param path The path of the trade as a bytes string
     * @param payer The address that will be paying the input
     */
    function _smardexSwapExactOutput(
        address recipient,
        uint256 amountOut,
        uint256 amountInMax,
        bytes calldata path,
        address payer
    ) internal {
        uint256 amountIn = SmardexRouterLib.smardexSwapExactOutput(SMARDEX_FACTORY, recipient, amountOut, path, payer);

        // amountIn is the right one for the first hop, otherwise we need the cached amountIn from callback
        if (path.length > 2 * ADDR_SIZE) {
            amountIn = amountInCached;
        }

        if (amountIn > amountInMax) {
            revert ISmardexRouterErrors.ExcessiveInputAmount();
        }

        amountInCached = type(uint256).max;
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { LockAndMsgSender } from "@uniswap/universal-router/contracts/base/LockAndMsgSender.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";

contract LockAndMap is LockAndMsgSender {
    /// @notice Reverts when the recipient is invalid
    error LockAndMapInvalidRecipient();

    /**
     *  @notice Calculates the recipient address for a command
     *  @dev Reverts if the recipient is the router address
     *  @param recipient The recipient or recipient-flag for the command
     *  @return output_ The resultant recipient for the command
     */
    function _mapSafe(address recipient) internal view returns (address output_) {
        if (recipient == Constants.ADDRESS_THIS || recipient == address(this)) {
            revert LockAndMapInvalidRecipient();
        } else if (recipient == Constants.MSG_SENDER) {
            return lockedBy;
        } else {
            return recipient;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IUsdnProtocol } from "usdn-contracts/src/interfaces/UsdnProtocol/IUsdnProtocol.sol";
import { IUsdn } from "usdn-contracts/src/interfaces/Usdn/IUsdn.sol";
import { IWusdn } from "usdn-contracts/src/interfaces/Usdn/IWusdn.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";

struct UsdnProtocolParameters {
    IUsdnProtocol usdnProtocol;
    IWusdn wusdn;
    address permit2;
}

contract UsdnProtocolImmutables {
    /// @dev The address of the USDN protocol
    IUsdnProtocol internal immutable USDN_PROTOCOL;

    /// @dev The address of the protocol asset
    IERC20Metadata internal immutable PROTOCOL_ASSET;

    /// @dev The address of the SDEX token
    IERC20Metadata internal immutable SDEX;

    /// @dev The address of the USDN
    IUsdn internal immutable USDN;

    /// @dev The address of the WUSDN
    IWusdn internal immutable WUSDN;

    /// @dev The permit2 contract
    IAllowanceTransfer internal immutable USDN_PROTOCOL_PERMIT2;

    /// @param params The immutable parameters for the USDN protocol
    constructor(UsdnProtocolParameters memory params) {
        USDN_PROTOCOL = params.usdnProtocol;
        PROTOCOL_ASSET = params.usdnProtocol.getAsset();
        SDEX = params.usdnProtocol.getSdex();
        WUSDN = params.wusdn;
        USDN = params.wusdn.USDN();
        USDN_PROTOCOL_PERMIT2 = IAllowanceTransfer(params.permit2);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.26;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC165, IERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IPaymentCallback } from "usdn-contracts/src/interfaces/UsdnProtocol/IPaymentCallback.sol";
import { IUsdn } from "usdn-contracts/src/interfaces/Usdn/IUsdn.sol";

import { UsdnProtocolImmutables } from "./UsdnProtocolImmutables.sol";
import { UsdnProtocolRouterLib } from "../../libraries/usdn/UsdnProtocolRouterLib.sol";
import { LockAndMap } from "./LockAndMap.sol";

/// @title Router for UsdnProtocol
abstract contract UsdnProtocolRouter is UsdnProtocolImmutables, IPaymentCallback, ERC165, LockAndMap {
    /// @inheritdoc IPaymentCallback
    function transferCallback(IERC20Metadata token, uint256 amount, address to) external {
        UsdnProtocolRouterLib.transferCallback(
            address(USDN_PROTOCOL), lockedBy, USDN_PROTOCOL_PERMIT2, token, amount, to
        );
    }

    /// @inheritdoc IPaymentCallback
    function usdnTransferCallback(IUsdn usdn, uint256 shares) external {
        UsdnProtocolRouterLib.usdnTransferCallback(address(USDN_PROTOCOL), usdn, lockedBy, shares);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        if (interfaceId == type(IPaymentCallback).interfaceId) {
            return true;
        }

        return super.supportsInterface(interfaceId);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { Constants } from "@uniswap/universal-router/contracts/libraries/Constants.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { SafeTransferLib } from "solmate/src/utils/SafeTransferLib.sol";

/// @title Payment library for swapping
library Payment {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;
    using SafeTransferLib for address;

    /**
     * @notice Transfers the given amount of `token` to `recipient` from `payer`.
     * @dev Uses Permit2 if `payer` is not `address(this)`, otherwise, uses safe transfers.
     * @param permit2 The permit2 contract
     * @param token The token to transfer
     * @param payer The address to pay for the transfer
     * @param recipient The recipient of the transfer
     * @param amount The amount to transfer
     */
    function pay(IAllowanceTransfer permit2, address token, address payer, address recipient, uint256 amount)
        external
    {
        if (payer == address(this)) {
            if (token == Constants.ETH) {
                recipient.safeTransferETH(amount);
            } else {
                if (amount == Constants.CONTRACT_BALANCE) {
                    amount = IERC20(token).balanceOf(address(this));
                }

                IERC20(token).safeTransfer(recipient, amount);
            }
        } else {
            permit2.transferFrom(payer, recipient, amount.toUint160(), token);
        }
    }
}