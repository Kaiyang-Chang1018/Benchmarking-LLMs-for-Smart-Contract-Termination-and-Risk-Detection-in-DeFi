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
// OpenZeppelin Contracts (last updated v5.1.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.20;

import {Ownable} from "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This extension of the {Ownable} contract includes a two-step mechanism to transfer
 * ownership, where the new owner must call {acceptOwnership} in order to replace the
 * old one. This can help prevent common mistakes, such as transfers of ownership to
 * incorrect accounts, or to contracts that are unable to interact with the
 * permission system.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     *
     * Setting `newOwner` to the zero address is allowed; this can be used to cancel an initiated ownership transfer.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (access/extensions/IAccessControlDefaultAdminRules.sol)

pragma solidity ^0.8.20;

import {IAccessControl} from "../IAccessControl.sol";

/**
 * @dev External interface of AccessControlDefaultAdminRules declared to support ERC-165 detection.
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
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[ERC-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC-20 allowance (see {IERC20-allowance}) by
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Panic.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ShortStrings.sol)

pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        assembly ("memory-safe") {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/Strings.sol)

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
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
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
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.20;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "./MessageHashUtils.sol";
import {ShortStrings, ShortString} from "../ShortStrings.sol";
import {IERC5267} from "../../interfaces/IERC5267.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP-712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP-712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP-712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/cryptography/MessageHashUtils.sol)

pragma solidity ^0.8.20;

import {Strings} from "../Strings.sol";

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[ERC-191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

import {Panic} from "../Panic.sol";
import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
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
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
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
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
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

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
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

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += SafeCast.toUint(value > 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
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
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
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

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

import {SafeCast} from "./SafeCast.sol";

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
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
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
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

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an overflow.
    error RPowOverflow();

    /// @dev The mantissa is too big to fit.
    error MantissaOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, due to an multiplication overflow.
    error SMulWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error SDivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The input outside the acceptable domain.
    error OutOfDomain();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function sMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require((x == 0 || z / x == y) && !(x == -1 && y == type(int256).min))`.
            if iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1))))) {
                mstore(0x00, 0xedcd4dd4) // `SMulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawMulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawSMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up, but without overflow checks.
    function rawMulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function sDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, WAD)
            // Equivalent to `require(y != 0 && ((x * WAD) / WAD == x))`.
            if iszero(and(iszero(iszero(y)), eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawDivWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawSDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up, but without overflow and divide by zero checks.
    function rawDivWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    /// Note: This function is an approximation.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    /// Note: This function is an approximation. Monotonically increasing.
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= (log(1e-18) * 1e18) ~ -4.15e19`.
            if (x <= -41446531673892822313) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 1e18` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 1e18) * 1e18) ≈ 135`.
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // `x` is now in the range `(-42, 136) * 1e18`. Convert to `(-42, 136) * 2**96`
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            // - The `1e18 / 2**96` factor for base conversion.
            // We do this all at once, with an intermediate result in `2**213`
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    /// Note: This function is an approximation. Monotonically increasing.
    function lnWad(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // We want to convert `x` from `10**18` fixed point to `2**96` fixed point.
            // We do this by multiplying by `2**96 / 10**18`. But since
            // `ln(x * C) = ln(x) + ln(C)`, we can simply do nothing here
            // and add `ln(2**96 / 10**18)` at the end.

            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `ln(2**96 / 10**18)`.
            // - Add `k * ln(2)`.
            // - Multiply by `10**18 / 2**96 = 5**18 >> 78`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 5**18 * 2**96`, base is now `5**18 * 2**192`.
            p := mul(1677202110996718588342820967067443963516166, p)
            // Add `ln(2) * k * 5**18 * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(16597577552685614221487285958193947469193820559219878177908093499208371, sub(159, r)), p)
            // Add `ln(2**96 / 10**18) * 5**18 * 2**192`.
            p := add(600920179829731861736702779321621459595472258049074101567377883020018308, p)
            // Base conversion: mul `2**18 / 2**192`.
            r := sar(174, p)
        }
    }

    /// @dev Returns `W_0(x)`, denominated in `WAD`.
    /// See: https://en.wikipedia.org/wiki/Lambert_W_function
    /// a.k.a. Product log function. This is an approximation of the principal branch.
    /// Note: This function is an approximation. Monotonically increasing.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            int256 wad = int256(WAD);
            int256 p = x;
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (uint256(w >> 63) == uint256(0)) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Inline log2 for more performance, since the range is small.
                    let v := shr(49, w)
                    let l := shl(3, lt(0xff, v))
                    l := add(or(l, byte(and(0x1f, shr(shr(l, v), 0x8421084210842108cc6318c6db6d54be)),
                        0x0706060506020504060203020504030106050205030304010505030400000000)), 49)
                    w := sdiv(shl(l, 7), byte(sub(l, 31), 0x0303030303030303040506080c13))
                    c := gt(l, 60)
                    i := add(2, add(gt(l, 53), c))
                }
            } else {
                int256 ll = lnWad(w = lnWad(w));
                /// @solidity memory-safe-assembly
                assembly {
                    // `w = ln(x) - ln(ln(x)) + b * ln(ln(x)) / ln(x)`.
                    w := add(sdiv(mul(ll, 1023715080943847266), w), sub(w, ll))
                    i := add(3, iszero(shr(68, x)))
                    c := iszero(shr(143, x))
                }
                if (c == uint256(0)) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != uint256(0));
                    /// @solidity memory-safe-assembly
                    assembly {
                        w := sub(w, sgt(w, 2))
                    }
                    return w;
                }
            }
            do { // Otherwise, use Halley's for faster convergence.
                int256 e = expWad(w);
                /// @solidity memory-safe-assembly
                assembly {
                    let t := add(w, wad)
                    let s := sub(mul(w, e), mul(x, wad))
                    w := sub(w, sdiv(mul(s, wad), sub(mul(e, t), sdiv(mul(add(t, wad), s), add(t, t)))))
                }
                if (p <= w) break;
                p = w;
            } while (--i != c);
            /// @solidity memory-safe-assembly
            assembly {
                w := sub(w, sgt(w, 2))
            }
            // For certain ranges of `x`, we'll use the quadratic-rate recursive formula of
            // R. Iacono and J.P. Boyd for the last iteration, to avoid catastrophic cancellation.
            if (c == uint256(0)) return w;
            int256 t = w | 1;
            /// @solidity memory-safe-assembly
            assembly {
                x := sdiv(mul(x, wad), t)
            }
            x = (t * (wad + lnWad(x)));
            /// @solidity memory-safe-assembly
            assembly {
                w := sdiv(x, add(wad, t))
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // 512-bit multiply `[p1 p0] = x * y`.
            // Compute the product mod `2**256` and mod `2**256 - 1`
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that `product = p1 * 2**256 + p0`.

            // Temporarily use `result` as `p0` to save gas.
            result := mul(x, y) // Lower 256 bits of `x * y`.
            for {} 1 {} {
                // If overflows.
                if iszero(mul(or(iszero(x), eq(div(result, x), y)), d)) {
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(result, lt(mm, result))) // Upper 256 bits of `x * y`.

                    /*------------------- 512 by 256 division --------------------*/

                    // Make division exact by subtracting the remainder from `[p1 p0]`.
                    let r := mulmod(x, y, d) // Compute remainder using mulmod.
                    let t := and(d, sub(0, d)) // The least significant bit of `d`. `t >= 1`.
                    // Make sure the result is less than `2**256`. Also prevents `d == 0`.
                    // Placing the check here seems to give more optimal stack operations.
                    if iszero(gt(d, p1)) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    d := div(d, t) // Divide `d` by `t`, which is a power of two.
                    // Invert `d mod 2**256`
                    // Now that `d` is an odd number, it has an inverse
                    // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                    // Compute the inverse by starting with a seed that is correct
                    // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                    let inv := xor(2, mul(3, d))
                    // Now use Newton-Raphson iteration to improve the precision.
                    // Thanks to Hensel's lifting lemma, this also works in modular
                    // arithmetic, doubling the correct bits in each step.
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                    inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                    result :=
                        mul(
                            // Divide [p1 p0] by the factors of two.
                            // Shift in bits from `p1` into `p0`. For this we need
                            // to flip `t` such that it is `2**256 / t`.
                            or(
                                mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)),
                                div(sub(result, r), t)
                            ),
                            mul(sub(2, mul(d, inv)), inv) // inverse mod 2**256
                        )
                    break
                }
                result := div(result, d)
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Behavior is undefined if `d` is zero or the final result cannot fit in 256 bits.
    /// Performs the full 512 bit calculation regardless.
    function fullMulDivUnchecked(uint256 x, uint256 y, uint256 d)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mul(x, y)
            let mm := mulmod(x, y, not(0))
            let p1 := sub(mm, add(result, lt(mm, result)))
            let t := and(d, sub(0, d))
            let r := mulmod(x, y, d)
            d := div(d, t)
            let inv := xor(2, mul(3, d))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            result :=
                mul(
                    or(mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)), div(sub(result, r), t)),
                    mul(sub(2, mul(d, inv)), inv)
                )
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                result := add(result, 1)
                if iszero(result) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(z, d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require(d != 0 && (y == 0 || x <= type(uint256).max / y))`.
            if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(z, d))), div(z, d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e) // `DivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Returns `condition ? x : y`, without branching.
    function ternary(bool condition, uint256 x, uint256 y) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := xor(x, mul(xor(x, y), iszero(condition)))
        }
    }

    /// @dev Exponentiate `x` to `y` by squaring, denominated in base `b`.
    /// Reverts if the computation overflows.
    function rpow(uint256 x, uint256 y, uint256 b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(b, iszero(y)) // `0 ** 0 = 1`. Otherwise, `0 ** n = 0`.
            if x {
                z := xor(b, mul(xor(b, x), and(y, 1))) // `z = isEven(y) ? scale : x`
                let half := shr(1, b) // Divide `b` by 2.
                // Divide `y` by 2 every iteration.
                for { y := shr(1, y) } y { y := shr(1, y) } {
                    let xx := mul(x, x) // Store x squared.
                    let xxRound := add(xx, half) // Round to the nearest number.
                    // Revert if `xx + half` overflowed, or if `x ** 2` overflows.
                    if or(lt(xxRound, xx), shr(128, x)) {
                        mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                        revert(0x1c, 0x04)
                    }
                    x := div(xxRound, b) // Set `x` to scaled `xxRound`.
                    // If `y` is odd:
                    if and(y, 1) {
                        let zx := mul(z, x) // Compute `z * x`.
                        let zxRound := add(zx, half) // Round to the nearest number.
                        // If `z * x` overflowed or `zx + half` overflowed:
                        if or(xor(div(zx, x), z), lt(zxRound, zx)) {
                            // Revert if `x` is non-zero.
                            if x {
                                mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                                revert(0x1c, 0x04)
                            }
                        }
                        z := div(zxRound, b) // Return properly scaled `zxRound`.
                    }
                }
            }
        }
    }

    /// @dev Returns the square root of `x`, rounded down.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`. We check `y >= 2**(k + 8)`
            // but shift right by `k` bits to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`, rounded down.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))

            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))

            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)

            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`, rounded down.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 18) return sqrt(x * 10 ** 18);
            z = (1 + sqrt(x)) * 10 ** 9;
            z = (fullMulDivUnchecked(x, 10 ** 18, z) + z) >> 1;
        }
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(z, gt(999999999999999999, sub(mulmod(z, z, x), 1)))
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`, rounded down.
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 36) return cbrt(x * 10 ** 36);
            z = (1 + cbrt(x)) * 10 ** 12;
            z = (fullMulDivUnchecked(x, 10 ** 36, z * z) + z + z) / 3;
            x = fullMulDivUnchecked(x, 10 ** 36, z * z);
        }
        /// @solidity memory-safe-assembly
        assembly {
            z := sub(z, lt(x, z))
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for {} x { x := sub(x, 1) } { result := mul(result, x) }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        r = log2(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(r, 1), x))
        }
    }

    /// @dev Returns the log10 of `x`.
    /// Returns 0 if `x` is zero.
    function log10(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 100000000000000000000000000000000000000)) {
                x := div(x, 100000000000000000000000000000000000000)
                r := 38
            }
            if iszero(lt(x, 100000000000000000000)) {
                x := div(x, 100000000000000000000)
                r := add(r, 20)
            }
            if iszero(lt(x, 10000000000)) {
                x := div(x, 10000000000)
                r := add(r, 10)
            }
            if iszero(lt(x, 100000)) {
                x := div(x, 100000)
                r := add(r, 5)
            }
            r := add(r, add(gt(x, 9), add(gt(x, 99), add(gt(x, 999), gt(x, 9999)))))
        }
    }

    /// @dev Returns the log10 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log10Up(uint256 x) internal pure returns (uint256 r) {
        r = log10(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(exp(10, r), x))
        }
    }

    /// @dev Returns the log256 of `x`.
    /// Returns 0 if `x` is zero.
    function log256(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(shr(3, r), lt(0xff, shr(r, x)))
        }
    }

    /// @dev Returns the log256 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log256Up(uint256 x) internal pure returns (uint256 r) {
        r = log256(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(shl(3, r), 1), x))
        }
    }

    /// @dev Returns the scientific notation format `mantissa * 10 ** exponent` of `x`.
    /// Useful for compressing prices (e.g. using 25 bit mantissa and 7 bit exponent).
    function sci(uint256 x) internal pure returns (uint256 mantissa, uint256 exponent) {
        /// @solidity memory-safe-assembly
        assembly {
            mantissa := x
            if mantissa {
                if iszero(mod(mantissa, 1000000000000000000000000000000000)) {
                    mantissa := div(mantissa, 1000000000000000000000000000000000)
                    exponent := 33
                }
                if iszero(mod(mantissa, 10000000000000000000)) {
                    mantissa := div(mantissa, 10000000000000000000)
                    exponent := add(exponent, 19)
                }
                if iszero(mod(mantissa, 1000000000000)) {
                    mantissa := div(mantissa, 1000000000000)
                    exponent := add(exponent, 12)
                }
                if iszero(mod(mantissa, 1000000)) {
                    mantissa := div(mantissa, 1000000)
                    exponent := add(exponent, 6)
                }
                if iszero(mod(mantissa, 10000)) {
                    mantissa := div(mantissa, 10000)
                    exponent := add(exponent, 4)
                }
                if iszero(mod(mantissa, 100)) {
                    mantissa := div(mantissa, 100)
                    exponent := add(exponent, 2)
                }
                if iszero(mod(mantissa, 10)) {
                    mantissa := div(mantissa, 10)
                    exponent := add(exponent, 1)
                }
            }
        }
    }

    /// @dev Convenience function for packing `x` into a smaller number using `sci`.
    /// The `mantissa` will be in bits [7..255] (the upper 249 bits).
    /// The `exponent` will be in bits [0..6] (the lower 7 bits).
    /// Use `SafeCastLib` to safely ensure that the `packed` number is small
    /// enough to fit in the desired unsigned integer type:
    /// ```
    ///     uint32 packed = SafeCastLib.toUint32(FixedPointMathLib.packSci(777 ether));
    /// ```
    function packSci(uint256 x) internal pure returns (uint256 packed) {
        (x, packed) = sci(x); // Reuse for `mantissa` and `exponent`.
        /// @solidity memory-safe-assembly
        assembly {
            if shr(249, x) {
                mstore(0x00, 0xce30380c) // `MantissaOverflow()`.
                revert(0x1c, 0x04)
            }
            packed := or(shl(7, x), packed)
        }
    }

    /// @dev Convenience function for unpacking a packed number from `packSci`.
    function unpackSci(uint256 packed) internal pure returns (uint256 unpacked) {
        unchecked {
            unpacked = (packed >> 7) * 10 ** (packed & 0x7f);
        }
    }

    /// @dev Returns the average of `x` and `y`. Rounds towards zero.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`. Rounds towards negative infinity.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(sar(255, x), add(sar(255, x), x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), gt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), sgt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), gt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), lt(maxValue, z)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), sgt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), slt(maxValue, z)))
        }
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`,
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(uint256 a, uint256 b, uint256 t, uint256 begin, uint256 end)
        internal
        pure
        returns (uint256)
    {
        if (begin > end) {
            t = ~t;
            begin = ~begin;
            end = ~end;
        }
        if (t <= begin) return a;
        if (t >= end) return b;
        unchecked {
            if (b >= a) return a + fullMulDiv(b - a, t - begin, end - begin);
            return a - fullMulDiv(a - b, t - begin, end - begin);
        }
    }

    /// @dev Returns `a + (b - a) * (t - begin) / (end - begin)`.
    /// with `t` clamped between `begin` and `end` (inclusive).
    /// Agnostic to the order of (`a`, `b`) and (`end`, `begin`).
    /// If `begins == end`, returns `t <= begin ? a : b`.
    function lerp(int256 a, int256 b, int256 t, int256 begin, int256 end)
        internal
        pure
        returns (int256)
    {
        if (begin > end) {
            t = int256(~uint256(t));
            begin = int256(~uint256(begin));
            end = int256(~uint256(end));
        }
        if (t <= begin) return a;
        if (t >= end) return b;
        // forgefmt: disable-next-item
        unchecked {
            if (b >= a) return int256(uint256(a) + fullMulDiv(uint256(b) - uint256(a),
                uint256(t) - uint256(begin), uint256(end) - uint256(begin)));
            return int256(uint256(a) - fullMulDiv(uint256(a) - uint256(b),
                uint256(t) - uint256(begin), uint256(end) - uint256(begin)));
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
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
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ERC165, IERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import { FixedPointMathLib } from "solady/src/utils/FixedPointMathLib.sol";

import { UsdnProtocolConstantsLibrary as Constants } from "../UsdnProtocol/libraries/UsdnProtocolConstantsLibrary.sol";
import { IBaseRebalancer } from "../interfaces/Rebalancer/IBaseRebalancer.sol";
import { IRebalancer } from "../interfaces/Rebalancer/IRebalancer.sol";
import { IOwnershipCallback } from "../interfaces/UsdnProtocol/IOwnershipCallback.sol";
import { IUsdnProtocol } from "../interfaces/UsdnProtocol/IUsdnProtocol.sol";
import { IUsdnProtocolTypes as Types } from "../interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";

/**
 * @title Rebalancer
 * @notice The goal of this contract is to push the imbalance of the USDN protocol back to an healthy level when
 * liquidations reduce long trading exposure. It will manage a single position with sufficient trading exposure to
 * re-balance the protocol after liquidations. The position will be closed and reopened as needed, utilizing new and
 * existing funds, whenever the imbalance reaches a defined threshold.
 */
contract Rebalancer is Ownable2Step, ReentrancyGuard, ERC165, IOwnershipCallback, IRebalancer, EIP712 {
    using SafeERC20 for IERC20Metadata;
    using SafeCast for uint256;

    /**
     * @dev Structure to hold the transient data during {initiateClosePosition}.
     * @param userDepositData The user deposit data.
     * @param remainingAssets The remaining rebalancer assets.
     * @param positionVersion The current rebalancer position version.
     * @param currentPositionData The current rebalancer position data.
     * @param amountToCloseWithoutBonus The user amount to close without bonus.
     * @param amountToClose The user amount to close including bonus.
     * @param protocolPosition The protocol rebalancer position.
     * @param user The address of the user that deposited the funds in the rebalancer.
     * @param balanceOfAssetBefore The balance of asset before the USDN protocol's
     * {IUsdnProtocolActions.initiateClosePosition}.
     * @param balanceOfAssetAfter The balance of asset after the USDN protocol's
     * {IUsdnProtocolActions.initiateClosePosition}.
     * @param amount The amount to close relative to the amount deposited.
     * @param to The recipient of the assets.
     * @param validator The address that should validate the open position.
     * @param userMinPrice The minimum price at which the position can be closed.
     * @param deadline The deadline of the close position to be initiated.
     * @param closeLockedUntil The timestamp by which a user must wait to perform a {initiateClosePosition}.
     */
    struct InitiateCloseData {
        UserDeposit userDepositData;
        uint88 remainingAssets;
        uint256 positionVersion;
        PositionData currentPositionData;
        uint256 amountToCloseWithoutBonus;
        uint256 amountToClose;
        Types.Position protocolPosition;
        address user;
        uint256 balanceOfAssetBefore;
        uint256 balanceOfAssetAfter;
        uint88 amount;
        address to;
        address payable validator;
        uint256 userMinPrice;
        uint256 deadline;
        uint256 closeLockedUntil;
    }

    /// @notice Reverts if the caller is not the USDN protocol nor the owner.
    modifier onlyAdmin() {
        if (msg.sender != address(_usdnProtocol) && msg.sender != owner()) {
            revert RebalancerUnauthorized();
        }
        _;
    }

    /// @notice Reverts if the caller is not the USDN protocol.
    modifier onlyProtocol() {
        if (msg.sender != address(_usdnProtocol)) {
            revert RebalancerUnauthorized();
        }
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  Constants                                 */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IRebalancer
    uint256 public constant MULTIPLIER_FACTOR = 1e38;

    /// @inheritdoc IRebalancer
    uint256 public constant MAX_ACTION_COOLDOWN = 48 hours;

    /// @inheritdoc IRebalancer
    uint256 public constant MAX_CLOSE_DELAY = 7 days;

    /// @inheritdoc IRebalancer
    bytes32 public constant INITIATE_CLOSE_TYPEHASH = keccak256(
        "InitiateClosePositionDelegation(uint88 amount,address to,uint256 userMinPrice,uint256 deadline,address depositOwner,address depositCloser,uint256 nonce)"
    );

    /* -------------------------------------------------------------------------- */
    /*                                 Immutables                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice The address of the asset used by the USDN protocol.
    IERC20Metadata internal immutable _asset;

    /// @notice The number of decimals of the asset used by the USDN protocol.
    uint256 internal immutable _assetDecimals;

    /// @notice The address of the USDN protocol.
    IUsdnProtocol internal immutable _usdnProtocol;

    /* -------------------------------------------------------------------------- */
    /*                                 Parameters                                 */
    /* -------------------------------------------------------------------------- */

    /// @notice The maximum leverage that a position can have.
    uint256 internal _maxLeverage = 3 * 10 ** Constants.LEVERAGE_DECIMALS;

    /// @notice The minimum amount of assets to be deposited by a user.
    uint256 internal _minAssetDeposit;

    /**
     * @notice The timestamp by which a user must wait to perform a {initiateClosePosition}.
     * @dev This value will be updated each time a new rebalancer long position is created.
     */
    uint256 internal _closeLockedUntil;

    /**
     * @notice The time limits for the initiate/validate process of deposits and withdrawals.
     * @dev The user must wait `validationDelay` after the initiate action to perform the corresponding validate
     * action. If the `validationDeadline` has passed, the user is blocked from interacting until the cooldown duration
     * has elapsed (since the moment of the initiate action). After the cooldown, in case of a deposit action, the user
     * must withdraw their funds with `resetDepositAssets`. After the cooldown, in case of a withdrawal action, the user
     * can initiate a new withdrawal again.
     */
    TimeLimits internal _timeLimits = TimeLimits({
        validationDelay: 24 seconds,
        validationDeadline: 20 minutes,
        actionCooldown: 4 hours,
        closeDelay: 4 hours
    });

    /* -------------------------------------------------------------------------- */
    /*                                    State                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice The current position version.
    uint128 internal _positionVersion;

    /// @notice The amount of assets waiting to be used in the next version of the position.
    uint128 internal _pendingAssetsAmount;

    /// @notice The version of the last position that got liquidated.
    uint128 internal _lastLiquidatedVersion;

    /// @notice The data about the assets deposited in this contract by users.
    mapping(address => UserDeposit) internal _userDeposit;

    /// @notice The data for the specific version of the position.
    mapping(uint256 => PositionData) internal _positionData;

    /**
     * @notice The user EIP712 nonce.
     * @dev Check {IRebalancer.getNonce} for more information.
     */
    mapping(address => uint256) internal _nonce;

    /// @param usdnProtocol The address of the USDN protocol.
    constructor(IUsdnProtocol usdnProtocol) Ownable(msg.sender) EIP712("Rebalancer", "1") {
        _usdnProtocol = usdnProtocol;
        IERC20Metadata asset = usdnProtocol.getAsset();
        _asset = asset;
        _assetDecimals = usdnProtocol.getAssetDecimals();
        _minAssetDeposit = usdnProtocol.getMinLongPosition();

        // set allowance to allow the protocol to pull assets from this contract
        asset.forceApprove(address(usdnProtocol), type(uint256).max);

        // indicate that there are no position for version 0
        _positionData[0].tick = Constants.NO_POSITION_TICK;
    }

    /// @notice Allows this contract to receive ether sent by the USDN protocol.
    receive() external payable onlyProtocol { }

    /// @inheritdoc IRebalancer
    function getAsset() external view returns (IERC20Metadata asset_) {
        return _asset;
    }

    /// @inheritdoc IRebalancer
    function getUsdnProtocol() external view returns (IUsdnProtocol protocol_) {
        return _usdnProtocol;
    }

    /// @inheritdoc IRebalancer
    function getPendingAssetsAmount() external view returns (uint128 pendingAssetsAmount_) {
        return _pendingAssetsAmount;
    }

    /// @inheritdoc IRebalancer
    function getPositionVersion() external view returns (uint128 version_) {
        return _positionVersion;
    }

    /// @inheritdoc IRebalancer
    function getPositionMaxLeverage() external view returns (uint256 maxLeverage_) {
        maxLeverage_ = _maxLeverage;
        uint256 protocolMaxLeverage = _usdnProtocol.getMaxLeverage();
        if (protocolMaxLeverage < maxLeverage_) {
            return protocolMaxLeverage;
        }
    }

    /// @inheritdoc IBaseRebalancer
    function getCurrentStateData()
        external
        view
        returns (uint128 pendingAssets_, uint256 maxLeverage_, Types.PositionId memory currentPosId_)
    {
        PositionData storage positionData = _positionData[_positionVersion];
        return (
            _pendingAssetsAmount,
            _maxLeverage,
            Types.PositionId({
                tick: positionData.tick,
                tickVersion: positionData.tickVersion,
                index: positionData.index
            })
        );
    }

    /// @inheritdoc IRebalancer
    function getLastLiquidatedVersion() external view returns (uint128 version_) {
        return _lastLiquidatedVersion;
    }

    /// @inheritdoc IBaseRebalancer
    function getMinAssetDeposit() external view returns (uint256 minAssetDeposit_) {
        return _minAssetDeposit;
    }

    /// @inheritdoc IRebalancer
    function getPositionData(uint128 version) external view returns (PositionData memory positionData_) {
        positionData_ = _positionData[version];
    }

    /// @inheritdoc IRebalancer
    function getTimeLimits() external view returns (TimeLimits memory timeLimits_) {
        return _timeLimits;
    }

    /// @inheritdoc IBaseRebalancer
    function getUserDepositData(address user) external view returns (UserDeposit memory data_) {
        return _userDeposit[user];
    }

    /// @inheritdoc IRebalancer
    function getNonce(address user) external view returns (uint256 nonce_) {
        return _nonce[user];
    }

    /// @inheritdoc IRebalancer
    function domainSeparatorV4() external view returns (bytes32 domainSeparator_) {
        return _domainSeparatorV4();
    }

    /// @inheritdoc IRebalancer
    function getCloseLockedUntil() external view returns (uint256 timestamp_) {
        return _closeLockedUntil;
    }

    /// @inheritdoc IRebalancer
    function increaseAssetAllowance(uint256 addAllowance) external {
        _asset.safeIncreaseAllowance(address(_usdnProtocol), addAllowance);
    }

    /// @inheritdoc IRebalancer
    function initiateDepositAssets(uint88 amount, address to) external nonReentrant {
        /* authorized previous states:
        - not in rebalancer
            - amount = 0
            - initiateTimestamp = 0
            - entryPositionVersion = 0
        - included in a liquidated position
            - amount > 0
            - 0 < entryPositionVersion <= _lastLiquidatedVersion
            OR
            - positionData.tickVersion != protocol.getTickVersion(positionData.tick)
        */
        if (to == address(0)) {
            revert RebalancerInvalidAddressTo();
        }
        if (amount < _minAssetDeposit) {
            revert RebalancerInsufficientAmount();
        }

        UserDeposit memory depositData = _userDeposit[to];

        // if the user entered the rebalancer before and was not liquidated
        if (depositData.entryPositionVersion > _lastLiquidatedVersion) {
            uint128 positionVersion = _positionVersion;
            PositionData storage positionData = _positionData[positionVersion];
            // if the current position was not liquidated, revert
            if (_usdnProtocol.getTickVersion(positionData.tick) == positionData.tickVersion) {
                revert RebalancerDepositUnauthorized();
            }

            // update the last liquidated version and delete the user data
            _lastLiquidatedVersion = positionVersion;
            if (depositData.entryPositionVersion == positionVersion) {
                delete depositData;
            } else {
                // if the user has pending funds, we block the deposit
                revert RebalancerDepositUnauthorized();
            }
        } else if (depositData.entryPositionVersion > 0) {
            // if the user was in a position that got liquidated, we should reset the deposit data
            delete depositData;
        } else if (depositData.initiateTimestamp > 0 || depositData.amount > 0) {
            // user is already in the rebalancer
            revert RebalancerDepositUnauthorized();
        }

        depositData.amount = amount;
        depositData.initiateTimestamp = uint40(block.timestamp);
        _userDeposit[to] = depositData;

        _asset.safeTransferFrom(msg.sender, address(this), amount);

        emit InitiatedAssetsDeposit(msg.sender, to, amount, block.timestamp);
    }

    /// @inheritdoc IRebalancer
    function validateDepositAssets() external nonReentrant {
        /* authorized previous states:
        - initiated deposit (pending)
            - amount > 0
            - entryPositionVersion == 0
            - initiateTimestamp > 0
            - timestamp is between initiateTimestamp + delay and initiateTimestamp + deadline

        amount is always > 0 if initiateTimestamp > 0
        */
        UserDeposit memory depositData = _userDeposit[msg.sender];

        if (depositData.initiateTimestamp == 0) {
            // user has no action that must be validated
            revert RebalancerNoPendingAction();
        } else if (depositData.entryPositionVersion > 0) {
            revert RebalancerDepositUnauthorized();
        }

        _checkValidationTime(depositData.initiateTimestamp);

        depositData.entryPositionVersion = _positionVersion + 1;
        depositData.initiateTimestamp = 0;
        _userDeposit[msg.sender] = depositData;
        _pendingAssetsAmount += depositData.amount;

        emit AssetsDeposited(msg.sender, depositData.amount, depositData.entryPositionVersion);
    }

    /// @inheritdoc IRebalancer
    function resetDepositAssets() external nonReentrant {
        /* authorized previous states:
        - deposit cooldown elapsed
            - entryPositionVersion == 0
            - initiateTimestamp > 0
            - cooldown elapsed
        */
        UserDeposit memory depositData = _userDeposit[msg.sender];

        if (depositData.initiateTimestamp == 0) {
            // user has not initiated a deposit
            revert RebalancerNoPendingAction();
        } else if (depositData.entryPositionVersion > 0) {
            // user has a withdrawal that must be validated
            revert RebalancerActionNotValidated();
        } else if (block.timestamp < depositData.initiateTimestamp + _timeLimits.actionCooldown) {
            // user must wait until the cooldown has elapsed, then call this function to withdraw the funds
            revert RebalancerActionCooldown();
        }

        // this unblocks the user
        delete _userDeposit[msg.sender];

        _asset.safeTransfer(msg.sender, depositData.amount);

        emit DepositRefunded(msg.sender, depositData.amount);
    }

    /// @inheritdoc IRebalancer
    function initiateWithdrawAssets() external nonReentrant {
        /* authorized previous states:
        - unincluded (pending inclusion)
            - amount > 0
            - entryPositionVersion > _positionVersion
            - initiateTimestamp == 0
        - withdrawal cooldown
            - entryPositionVersion > _positionVersion
            - initiateTimestamp > 0
            - cooldown elapsed

        amount is always > 0 if entryPositionVersion > 0 */

        UserDeposit memory depositData = _userDeposit[msg.sender];

        if (depositData.entryPositionVersion <= _positionVersion) {
            revert RebalancerWithdrawalUnauthorized();
        }
        // entryPositionVersion > _positionVersion

        if (
            depositData.initiateTimestamp > 0
                && block.timestamp < depositData.initiateTimestamp + _timeLimits.actionCooldown
        ) {
            // user must wait until the cooldown has elapsed, then call this function to restart the withdrawal process
            revert RebalancerActionCooldown();
        }
        // initiateTimestamp == 0 or cooldown elapsed

        _userDeposit[msg.sender].initiateTimestamp = uint40(block.timestamp);

        emit InitiatedAssetsWithdrawal(msg.sender);
    }

    /// @inheritdoc IRebalancer
    function validateWithdrawAssets(uint88 amount, address to) external nonReentrant {
        /* authorized previous states:
        - initiated withdrawal
            - initiateTimestamp > 0
            - entryPositionVersion > _positionVersion
            - timestamp is between initiateTimestamp + delay and initiateTimestamp + deadline
        */
        if (to == address(0)) {
            revert RebalancerInvalidAddressTo();
        }
        if (amount == 0) {
            revert RebalancerInvalidAmount();
        }

        UserDeposit memory depositData = _userDeposit[msg.sender];

        if (depositData.entryPositionVersion <= _positionVersion) {
            revert RebalancerWithdrawalUnauthorized();
        }
        if (depositData.initiateTimestamp == 0) {
            revert RebalancerNoPendingAction();
        }
        _checkValidationTime(depositData.initiateTimestamp);

        if (amount > depositData.amount) {
            revert RebalancerInvalidAmount();
        }

        // update deposit data
        if (depositData.amount == amount) {
            // we withdraw the full amount, delete the mapping entry
            delete _userDeposit[msg.sender];
        } else {
            // partial withdrawal
            unchecked {
                // checked above: amount is strictly smaller than depositData.amount
                depositData.amount -= amount;
            }
            // the remaining amount must at least be _minAssetDeposit
            if (depositData.amount < _minAssetDeposit) {
                revert RebalancerInsufficientAmount();
            }
            depositData.initiateTimestamp = 0;
            _userDeposit[msg.sender] = depositData;
        }

        // update global state
        _pendingAssetsAmount -= amount;

        _asset.safeTransfer(to, amount);

        emit AssetsWithdrawn(msg.sender, to, amount);
    }

    /// @inheritdoc IRebalancer
    function initiateClosePosition(
        uint88 amount,
        address to,
        address payable validator,
        uint256 userMinPrice,
        uint256 deadline,
        bytes calldata currentPriceData,
        Types.PreviousActionsData calldata previousActionsData,
        bytes calldata delegationData
    ) external payable nonReentrant returns (Types.LongActionOutcome outcome_) {
        InitiateCloseData memory data;
        data.amount = amount;
        data.to = to;
        data.validator = validator;
        data.userMinPrice = userMinPrice;
        data.deadline = deadline;
        data.closeLockedUntil = _closeLockedUntil;

        return _initiateClosePosition(data, currentPriceData, previousActionsData, delegationData);
    }

    /**
     * @notice Refunds any ether in this contract to the caller.
     * @dev This contract should not hold any ether so any sent to it belongs to the current caller.
     */
    function _refundEther() internal {
        uint256 amount = address(this).balance;
        if (amount > 0) {
            // slither-disable-next-line arbitrary-send-eth
            (bool success,) = msg.sender.call{ value: amount }("");
            if (!success) {
                revert RebalancerEtherRefundFailed();
            }
        }
    }

    /// @inheritdoc IBaseRebalancer
    function updatePosition(Types.PositionId calldata newPosId, uint128 previousPosValue)
        external
        onlyProtocol
        nonReentrant
    {
        uint128 positionVersion = _positionVersion;
        PositionData memory previousPositionData = _positionData[positionVersion];
        // set the multiplier accumulator to 1 by default
        uint256 accMultiplier = MULTIPLIER_FACTOR;

        // if the current position version exists
        if (previousPositionData.amount > 0) {
            // if the position has not been liquidated
            if (previousPosValue > 0) {
                // update the multiplier accumulator
                accMultiplier = FixedPointMathLib.fullMulDiv(
                    previousPosValue, previousPositionData.entryAccMultiplier, previousPositionData.amount
                );
            } else if (_lastLiquidatedVersion != positionVersion) {
                // update the last liquidated version tracker
                _lastLiquidatedVersion = positionVersion;
            }
        }

        // update the position's version
        ++positionVersion;
        _positionVersion = positionVersion;

        uint128 positionAmount = _pendingAssetsAmount + previousPosValue;
        if (newPosId.tick != Constants.NO_POSITION_TICK) {
            _positionData[positionVersion] = PositionData({
                entryAccMultiplier: accMultiplier,
                tickVersion: newPosId.tickVersion,
                index: newPosId.index,
                amount: positionAmount,
                tick: newPosId.tick
            });

            // reset the pending assets amount as they are all used in the new position
            _pendingAssetsAmount = 0;
            _closeLockedUntil = block.timestamp + _timeLimits.closeDelay;
        } else {
            _positionData[positionVersion].tick = Constants.NO_POSITION_TICK;
        }

        emit PositionVersionUpdated(positionVersion, accMultiplier, positionAmount, newPosId);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    Admin                                   */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IRebalancer
    function setPositionMaxLeverage(uint256 newMaxLeverage) external onlyOwner {
        if (newMaxLeverage > _usdnProtocol.getMaxLeverage()) {
            revert RebalancerInvalidMaxLeverage();
        } else if (newMaxLeverage <= Constants.REBALANCER_MIN_LEVERAGE) {
            revert RebalancerInvalidMaxLeverage();
        }

        _maxLeverage = newMaxLeverage;

        emit PositionMaxLeverageUpdated(newMaxLeverage);
    }

    /// @inheritdoc IBaseRebalancer
    function setMinAssetDeposit(uint256 minAssetDeposit) external onlyAdmin {
        if (_usdnProtocol.getMinLongPosition() > minAssetDeposit) {
            revert RebalancerInvalidMinAssetDeposit();
        }

        _minAssetDeposit = minAssetDeposit;
        emit MinAssetDepositUpdated(minAssetDeposit);
    }

    /// @inheritdoc IRebalancer
    function setTimeLimits(uint64 validationDelay, uint64 validationDeadline, uint64 actionCooldown, uint64 closeDelay)
        external
        onlyOwner
    {
        if (validationDelay >= validationDeadline) {
            revert RebalancerInvalidTimeLimits();
        }
        if (validationDeadline < validationDelay + 1 minutes) {
            revert RebalancerInvalidTimeLimits();
        }
        if (actionCooldown < validationDeadline) {
            revert RebalancerInvalidTimeLimits();
        }
        if (actionCooldown > MAX_ACTION_COOLDOWN) {
            revert RebalancerInvalidTimeLimits();
        }
        if (closeDelay > MAX_CLOSE_DELAY) {
            revert RebalancerInvalidTimeLimits();
        }

        _timeLimits = TimeLimits({
            validationDelay: validationDelay,
            validationDeadline: validationDeadline,
            actionCooldown: actionCooldown,
            closeDelay: closeDelay
        });

        emit TimeLimitsUpdated(validationDelay, validationDeadline, actionCooldown, closeDelay);
    }

    /// @inheritdoc IOwnershipCallback
    function ownershipCallback(address, Types.PositionId calldata) external pure {
        revert RebalancerUnauthorized(); // first version of the rebalancer contract so we are always reverting
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool isSupported_)
    {
        if (interfaceId == type(IOwnershipCallback).interfaceId) {
            return true;
        }
        if (interfaceId == type(IRebalancer).interfaceId) {
            return true;
        }
        if (interfaceId == type(IBaseRebalancer).interfaceId) {
            return true;
        }

        return super.supportsInterface(interfaceId);
    }

    /* -------------------------------------------------------------------------- */
    /*                             Internal functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Checks if the validate action happens between the validation delay and the validation deadline.
     * @dev If the block timestamp is before `initiateTimestamp` + `validationDelay`, the function will revert.
     * If the block timestamp is after `initiateTimestamp` + `validationDeadline`, the function will revert.
     * @param initiateTimestamp The timestamp of the initiate action.
     */
    function _checkValidationTime(uint40 initiateTimestamp) internal view {
        TimeLimits memory timeLimits = _timeLimits;
        if (block.timestamp < initiateTimestamp + timeLimits.validationDelay) {
            // user must wait until the delay has elapsed
            revert RebalancerValidateTooEarly();
        }
        if (block.timestamp > initiateTimestamp + timeLimits.validationDeadline) {
            // user must wait until the cooldown has elapsed, then call `resetDepositAssets` to withdraw the funds
            revert RebalancerActionCooldown();
        }
    }

    /**
     * @notice Performs the {initiateClosePosition} EIP712 delegation signature verification.
     * @dev Reverts if the function arguments don't match those included in the signature
     * and if the signer isn't the owner of the deposit.
     * @param delegationData The delegation data that should include the depositOwner and the delegation signature.
     * @param amount The amount to close relative to the amount deposited.
     * @param to The recipient of the assets.
     * @param userMinPrice The minimum price at which the position can be closed, not guaranteed.
     * @param deadline The deadline of the close position to be initiated.
     * @return depositOwner_ The owner of the assets deposited in the rebalancer.
     */
    function _verifyInitiateCloseDelegation(
        uint88 amount,
        address to,
        uint256 userMinPrice,
        uint256 deadline,
        bytes calldata delegationData
    ) internal returns (address depositOwner_) {
        bytes memory signature;
        (depositOwner_, signature) = abi.decode(delegationData, (address, bytes));

        uint256 nonce = _nonce[depositOwner_];

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    INITIATE_CLOSE_TYPEHASH, amount, to, userMinPrice, deadline, depositOwner_, msg.sender, nonce
                )
            )
        );

        if (ECDSA.recover(digest, signature) != depositOwner_) {
            revert RebalancerInvalidDelegationSignature();
        }

        _nonce[depositOwner_] = nonce + 1;
    }

    /**
     * @notice Closes a user deposited amount of the current UsdnProtocol rebalancer position.
     * @param data The structure to hold the transient data during {initiateClosePosition}.
     * @param currentPriceData The current price data (used to calculate the temporary leverage and entry price,
     * pending validation).
     * @param previousActionsData The data needed to validate actionable pending actions.
     * @param delegationData An optional delegation data that include the depositOwner and an EIP712 signature to
     * provide when closing a position on the owner's behalf.
     * @return outcome_ The outcome of the {IUsdnProtocolActions.initiateClosePosition} call to the USDN protocol.
     */
    function _initiateClosePosition(
        InitiateCloseData memory data,
        bytes calldata currentPriceData,
        Types.PreviousActionsData calldata previousActionsData,
        bytes calldata delegationData
    ) internal returns (Types.LongActionOutcome outcome_) {
        if (block.timestamp < data.closeLockedUntil) {
            revert RebalancerCloseLockedUntil(data.closeLockedUntil);
        }
        if (data.amount == 0) {
            revert RebalancerInvalidAmount();
        }
        if (delegationData.length == 0) {
            data.user = msg.sender;
        } else {
            data.user =
                _verifyInitiateCloseDelegation(data.amount, data.to, data.userMinPrice, data.deadline, delegationData);
        }

        data.userDepositData = _userDeposit[data.user];

        if (data.amount > data.userDepositData.amount) {
            revert RebalancerInvalidAmount();
        }

        data.remainingAssets = data.userDepositData.amount - data.amount;
        if (data.remainingAssets > 0 && data.remainingAssets < _minAssetDeposit) {
            revert RebalancerInvalidAmount();
        }

        if (data.userDepositData.entryPositionVersion == 0) {
            revert RebalancerUserPending();
        }

        if (data.userDepositData.entryPositionVersion <= _lastLiquidatedVersion) {
            revert RebalancerUserLiquidated();
        }

        data.positionVersion = _positionVersion;

        if (data.userDepositData.entryPositionVersion > data.positionVersion) {
            revert RebalancerUserPending();
        }

        data.currentPositionData = _positionData[data.positionVersion];

        data.amountToCloseWithoutBonus = FixedPointMathLib.fullMulDiv(
            data.amount,
            data.currentPositionData.entryAccMultiplier,
            _positionData[data.userDepositData.entryPositionVersion].entryAccMultiplier
        );

        (data.protocolPosition,) = _usdnProtocol.getLongPosition(
            Types.PositionId({
                tick: data.currentPositionData.tick,
                tickVersion: data.currentPositionData.tickVersion,
                index: data.currentPositionData.index
            })
        );

        // include bonus
        data.amountToClose = data.amountToCloseWithoutBonus
            + data.amountToCloseWithoutBonus * (data.protocolPosition.amount - data.currentPositionData.amount)
                / data.currentPositionData.amount;

        data.balanceOfAssetBefore = _asset.balanceOf(address(this));

        // slither-disable-next-line reentrancy-eth
        outcome_ = _usdnProtocol.initiateClosePosition{ value: msg.value }(
            Types.PositionId({
                tick: data.currentPositionData.tick,
                tickVersion: data.currentPositionData.tickVersion,
                index: data.currentPositionData.index
            }),
            data.amountToClose.toUint128(),
            data.userMinPrice,
            data.to,
            data.validator,
            data.deadline,
            currentPriceData,
            previousActionsData,
            ""
        );
        data.balanceOfAssetAfter = _asset.balanceOf(address(this));

        if (outcome_ == Types.LongActionOutcome.Processed) {
            if (data.remainingAssets == 0) {
                delete _userDeposit[data.user];
            } else {
                _userDeposit[data.user].amount = data.remainingAssets;
            }

            // safe cast is already made on amountToClose
            data.currentPositionData.amount -= uint128(data.amountToCloseWithoutBonus);

            if (data.currentPositionData.amount == 0) {
                PositionData memory newPositionData;
                newPositionData.tick = Constants.NO_POSITION_TICK;
                _positionData[data.positionVersion] = newPositionData;
            } else {
                _positionData[data.positionVersion].amount = data.currentPositionData.amount;
            }

            emit ClosePositionInitiated(data.user, data.amount, data.amountToClose, data.remainingAssets);
        }

        // if the rebalancer received assets, it means it was rewarded for liquidating positions
        // so we need to forward those rewards to the msg.sender
        if (data.balanceOfAssetAfter > data.balanceOfAssetBefore) {
            _asset.safeTransfer(msg.sender, data.balanceOfAssetAfter - data.balanceOfAssetBefore);
        }

        // sent back any ether left in the contract
        _refundEther();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

library UsdnProtocolConstantsLibrary {
    /// @notice Number of decimals used for a position's leverage.
    uint8 internal constant LEVERAGE_DECIMALS = 21;

    /// @notice Number of decimals used for the funding rate.
    uint8 internal constant FUNDING_RATE_DECIMALS = 18;

    /// @notice Number of decimals used for tokens within the protocol (excluding the asset).
    uint8 internal constant TOKENS_DECIMALS = 18;

    /// @notice Number of decimals used for the fixed representation of the liquidation multiplier.
    uint8 internal constant LIQUIDATION_MULTIPLIER_DECIMALS = 38;

    /// @notice Number of decimals in the scaling factor of the funding rate.
    uint8 internal constant FUNDING_SF_DECIMALS = 3;

    /**
     * @notice Minimum leverage allowed for the rebalancer to open a position.
     * @dev In edge cases where the rebalancer holds significantly more assets than the protocol,
     * opening a position with the protocol's minimum leverage could cause a large overshoot of the target,
     * potentially creating an even greater imbalance. To prevent this, the rebalancer can use leverage
     * as low as the technical minimum (10 ** LEVERAGE_DECIMALS + 1).
     */
    uint256 internal constant REBALANCER_MIN_LEVERAGE = 10 ** LEVERAGE_DECIMALS + 1; // x1.000000000000000000001

    /// @notice Divisor for the ratio of USDN to SDEX burned on deposit.
    uint256 internal constant SDEX_BURN_ON_DEPOSIT_DIVISOR = 1e8;

    /// @notice Divisor for basis point (BPS) values.
    uint256 internal constant BPS_DIVISOR = 10_000;

    /// @notice Maximum number of tick liquidations that can be processed per call.
    uint16 internal constant MAX_LIQUIDATION_ITERATION = 10;

    /// @notice Sentinel value indicating a `PositionId` that represents no position.
    int24 internal constant NO_POSITION_TICK = type(int24).min;

    /// @notice Address holding the minimum supply of USDN and the first minimum long position.
    address internal constant DEAD_ADDRESS = address(0xdead);

    /**
     * @notice Delay after which a blocked pending action can be removed after `_lowLatencyValidatorDeadline` +
     * `_onChainValidatorDeadline`.
     */
    uint16 internal constant REMOVE_BLOCKED_PENDING_ACTIONS_DELAY = 5 minutes;

    /**
     * @notice Minimum total supply of USDN allowed.
     * @dev Upon the first deposit, this amount is sent to the dead address and becomes unrecoverable.
     */
    uint256 internal constant MIN_USDN_SUPPLY = 1000;

    /**
     * @notice Minimum margin between total exposure and long balance.
     * @dev Ensures the balance long does not increase in a way that causes the trading exposure to
     * fall below this margin. If this occurs, the balance long is clamped to the total exposure minus the margin.
     */
    uint256 internal constant MIN_LONG_TRADING_EXPO_BPS = 100;

    /* -------------------------------------------------------------------------- */
    /*                                   Setters                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Minimum iterations when searching for actionable pending actions in
     * {IUsdnProtocolFallback.getActionablePendingActions}.
     */
    uint256 internal constant MIN_ACTIONABLE_PENDING_ACTIONS_ITER = 20;

    /// @notice Minimum validation deadline for validators.
    uint256 internal constant MIN_VALIDATION_DEADLINE = 60;

    /// @notice Maximum validation deadline for validators.
    uint256 internal constant MAX_VALIDATION_DEADLINE = 1 days;

    /// @notice Maximum liquidation penalty allowed.
    uint256 internal constant MAX_LIQUIDATION_PENALTY = 1500;

    /// @notice Maximum safety margin allowed in basis points.
    uint256 internal constant MAX_SAFETY_MARGIN_BPS = 2000;

    /// @notice Maximum EMA (Exponential Moving Average) period allowed.
    uint256 internal constant MAX_EMA_PERIOD = 90 days;

    /// @notice Maximum position fee allowed in basis points.
    uint256 internal constant MAX_POSITION_FEE_BPS = 2000;

    /// @notice Maximum vault fee allowed in basis points.
    uint256 internal constant MAX_VAULT_FEE_BPS = 2000;

    /// @notice Maximum ratio of SDEX rewards allowed in basis points.
    uint256 internal constant MAX_SDEX_REWARDS_RATIO_BPS = 1000;

    /// @notice Maximum ratio of SDEX to burn per minted USDN on deposit (10%).
    uint256 internal constant MAX_SDEX_BURN_RATIO = SDEX_BURN_ON_DEPOSIT_DIVISOR / 10;

    /// @notice Maximum leverage allowed.
    uint256 internal constant MAX_LEVERAGE = 100 * 10 ** LEVERAGE_DECIMALS;

    /// @notice Maximum security deposit allowed.
    uint256 internal constant MAX_SECURITY_DEPOSIT = 5 ether;

    /// @notice The highest value allowed for the minimum long position setting.
    uint256 internal constant MAX_MIN_LONG_POSITION = 10 ether;

    /// @notice Maximum protocol fee allowed in basis points.
    uint16 internal constant MAX_PROTOCOL_FEE_BPS = 3000;

    /* -------------------------------------------------------------------------- */
    /*                                   EIP712                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice EIP712 typehash for {IUsdnProtocolActions.initiateClosePosition}.
     * @dev Used within EIP712 messages for domain-specific signing, enabling recovery of the signer
     * via [ECDSA-recover](https://docs.openzeppelin.com/contracts/5.x/api/utils#ECDSA).
     */
    bytes32 internal constant INITIATE_CLOSE_TYPEHASH = keccak256(
        "InitiateClosePositionDelegation(bytes32 posIdHash,uint128 amountToClose,uint256 userMinPrice,address to,uint256 deadline,address positionOwner,address positionCloser,uint256 nonce)"
    );

    /**
     * @notice EIP712 typehash for {IUsdnProtocolActions.transferPositionOwnership}.
     * @dev Used within EIP712 messages for domain-specific signing, enabling recovery of the signer
     * via [ECDSA-recover](https://docs.openzeppelin.com/contracts/5.x/api/utils#ECDSA).
     */
    bytes32 internal constant TRANSFER_POSITION_OWNERSHIP_TYPEHASH = keccak256(
        "TransferPositionOwnershipDelegation(bytes32 posIdHash,address positionOwner,address newPositionOwner,address delegatedAddress,uint256 nonce)"
    );

    /* -------------------------------------------------------------------------- */
    /*                                Roles hashes                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Role signature for setting external contracts.
    bytes32 public constant SET_EXTERNAL_ROLE = keccak256("SET_EXTERNAL_ROLE");

    /// @notice Role signature for performing critical protocol actions.
    bytes32 public constant CRITICAL_FUNCTIONS_ROLE = keccak256("CRITICAL_FUNCTIONS_ROLE");

    /// @notice Role signature for setting protocol parameters.
    bytes32 public constant SET_PROTOCOL_PARAMS_ROLE = keccak256("SET_PROTOCOL_PARAMS_ROLE");

    /// @notice Role signature for setting USDN parameters.
    bytes32 public constant SET_USDN_PARAMS_ROLE = keccak256("SET_USDN_PARAMS_ROLE");

    /// @notice Role signature for configuring protocol options with minimal impact.
    bytes32 public constant SET_OPTIONS_ROLE = keccak256("SET_OPTIONS_ROLE");

    /// @notice Role signature for upgrading the protocol implementation.
    bytes32 public constant PROXY_UPGRADE_ROLE = keccak256("PROXY_UPGRADE_ROLE");

    /// @notice Role signature for pausing the protocol.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Role signature for unpausing the protocol.
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");

    /// @notice Admin role for managing the `SET_EXTERNAL_ROLE`.
    bytes32 public constant ADMIN_SET_EXTERNAL_ROLE = keccak256("ADMIN_SET_EXTERNAL_ROLE");

    /// @notice Admin role for managing the `CRITICAL_FUNCTIONS_ROLE`.
    bytes32 public constant ADMIN_CRITICAL_FUNCTIONS_ROLE = keccak256("ADMIN_CRITICAL_FUNCTIONS_ROLE");

    /// @notice Admin role for managing the `SET_PROTOCOL_PARAMS_ROLE`.
    bytes32 public constant ADMIN_SET_PROTOCOL_PARAMS_ROLE = keccak256("ADMIN_SET_PROTOCOL_PARAMS_ROLE");

    /// @notice Admin role for managing the `SET_USDN_PARAMS_ROLE`.
    bytes32 public constant ADMIN_SET_USDN_PARAMS_ROLE = keccak256("ADMIN_SET_USDN_PARAMS_ROLE");

    /// @notice Admin role for managing the `SET_OPTIONS_ROLE`.
    bytes32 public constant ADMIN_SET_OPTIONS_ROLE = keccak256("ADMIN_SET_OPTIONS_ROLE");

    /// @notice Admin role for managing the `PROXY_UPGRADE_ROLE`.
    bytes32 public constant ADMIN_PROXY_UPGRADE_ROLE = keccak256("ADMIN_PROXY_UPGRADE_ROLE");

    /// @notice Admin role for managing the `PAUSER_ROLE`.
    bytes32 public constant ADMIN_PAUSER_ROLE = keccak256("ADMIN_PAUSER_ROLE");

    /// @notice Admin role for managing the `UNPAUSER_ROLE`.
    bytes32 public constant ADMIN_UNPAUSER_ROLE = keccak256("ADMIN_UNPAUSER_ROLE");
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

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IUsdnProtocolTypes as Types } from "./IUsdnProtocolTypes.sol";

/**
 * @notice This interface can be implemented by contracts that wish to be notified when they become owner of a USDN
 * protocol position.
 * @dev The contract must implement the ERC-165 interface detection mechanism.
 */
interface IOwnershipCallback is IERC165 {
    /**
     * @notice Called by the USDN protocol on the new position owner after an ownership transfer occurs.
     * @dev Implementers can use this callback to perform actions triggered by the ownership change.
     * @param oldOwner The address of the previous position owner.
     * @param posId The unique position identifier.
     */
    function ownershipCallback(address oldOwner, Types.PositionId calldata posId) external;
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