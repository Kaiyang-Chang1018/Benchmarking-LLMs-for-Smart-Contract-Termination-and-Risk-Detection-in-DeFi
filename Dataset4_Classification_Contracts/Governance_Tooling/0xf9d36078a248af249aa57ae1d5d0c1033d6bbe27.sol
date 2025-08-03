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
 * @notice This interface exposes the only function used by the UsdnProtocol
 * @dev Any future implementation of the rewards manager must implement this interface without modification
 */
interface IBaseLiquidationRewardsManager {
    /**
     * @notice Returns the amount of asset that needs to be sent to the liquidator
     * @param liquidatedTicks Information about the liquidated ticks
     * @param currentPrice The current price of the asset
     * @param rebased Whether an optional USDN rebase was performed
     * @param rebalancerAction The `_triggerRebalancer` action
     * @param action The type of protocol action that triggered the liquidation
     * @param rebaseCallbackResult The result of the rebase callback, if any
     * @param priceData The oracle price data blob, if any. This can be used to reward users differently depending on
     * which oracle they have used to provide a liquidation price
     * @return assetRewards_ The asset tokens to send to the liquidator as rewards (in wei)
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
 * @notice This interface exposes the only functions used or required by the UsdnProtocol
 * @dev Any future implementation of the oracle middleware must implement this interface without modification
 */
interface IBaseOracleMiddleware {
    /**
     * @notice Parse and validate some price data
     * @dev The data format is specific to the middleware and is simply forwarded from the user transaction's calldata
     * A fee amounting to exactly validationCost(data, action) must be sent or the transaction will revert
     * @param actionId A unique identifier for the current action. This identifier can be used to link a `Initiate`
     * call with the corresponding `Validate` call
     * @param targetTimestamp The target timestamp for validating the price data. For validation actions, this is the
     * timestamp of the initiation
     * @param action Type of action for which the price is requested. The middleware may use this to alter the
     * validation of the price or the returned price
     * @param data Price data, the format varies from middleware to middleware and can be different depending on the
     * action
     * @return result_ The price and timestamp as `PriceInfo`
     */
    function parseAndValidatePrice(
        bytes32 actionId,
        uint128 targetTimestamp,
        Types.ProtocolAction action,
        bytes calldata data
    ) external payable returns (PriceInfo memory result_);

    /**
     * @notice Get the required delay (in seconds) between the moment an action is initiated and the timestamp of the
     * price data used to validate that action
     * @return The validation delay
     */
    function getValidationDelay() external view returns (uint256);

    /**
     * @notice The maximum delay (in seconds) after initiation during which a low-latency price oracle can be used for
     * validation
     * @return The maximum delay for low-latency validation
     */
    function getLowLatencyDelay() external view returns (uint16);

    /**
     * @notice Returns the number of decimals for the price (constant)
     * @return The number of decimals
     */
    function getDecimals() external view returns (uint8);

    /**
     * @notice Returns the ETH cost of one price validation for the given action
     * @param data Pyth price data to be validated for which to get fee prices
     * @param action Type of action for which the price is requested
     * @return The ETH cost of one price validation
     */
    function validationCost(bytes calldata data, Types.ProtocolAction action) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @notice The price and timestamp returned by the oracle middleware
 * @dev The timestamp is the timestamp of the price data, not the timestamp of the request
 * There is no need for optimization here, the struct is only used in memory and not in storage
 * @param price The validated asset price, potentially adjusted by the middleware
 * @param neutralPrice The neutral/average price of the asset
 * @param timestamp The timestamp of the price data
 */
struct PriceInfo {
    uint256 price;
    uint256 neutralPrice;
    uint256 timestamp;
}

/**
 * @notice The price and timestamp returned by the chainlink oracle
 * @dev The timestamp is the timestamp of the price data, not the timestamp of the request
 * There is no need for optimization here, the struct is only used in memory and not in storage
 * @param price The asset price formatted by the middleware
 * @param timestamp The timestamp of the price data
 */
struct ChainlinkPriceInfo {
    int256 price;
    uint256 timestamp;
}

/**
 * @notice Struct representing a Pyth price with a uint256 price
 * @param price The price of the asset
 * @param conf The confidence interval around the price (in dollars, absolute value)
 * @param publishTime Unix timestamp describing when the price was published
 */
struct FormattedPythPrice {
    uint256 price;
    uint256 conf;
    uint256 publishTime;
}

/**
 * @notice The price and timestamp returned by the redstone oracle.
 * @dev The timestamp is the timestamp of the price data, not the timestamp of the request
 * @param price The asset price formatted by the middleware
 * @param timestamp The timestamp of the price data
 */
struct RedstonePriceInfo {
    uint256 price;
    uint256 timestamp;
}

/**
 * @notice Enum representing the confidence interval of a Pyth price
 * @dev Used by the middleware to determine which price to use in a confidence interval
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
     * @notice Returns the necessary data for the USDN protocol to update the position
     * @return pendingAssets_ The amount of assets that are pending inclusion in the protocol
     * @return maxLeverage_ The maximum leverage of the rebalancer
     * @return currentPosId_ The ID of the current position (tick == NO_POSITION_TICK if no position)
     */
    function getCurrentStateData()
        external
        view
        returns (uint128 pendingAssets_, uint256 maxLeverage_, Types.PositionId memory currentPosId_);

    /**
     * @notice Returns the minimum amount of assets to be deposited by a user
     * @return The minimum amount of assets to be deposited by a user
     */
    function getMinAssetDeposit() external view returns (uint256);

    /**
     * @notice Returns the data regarding the assets deposited by the provided user
     * @param user The address of the user
     * @return The data regarding the assets deposited by the provided user
     */
    function getUserDepositData(address user) external view returns (IRebalancerTypes.UserDeposit memory);

    /**
     * @notice Indicates that the previous version of the position was closed and a new one was opened
     * @dev If `previousPosValue` equals 0, it means the previous version got liquidated
     * @param newPosId The position ID of the new position
     * @param previousPosValue The amount of assets left in the previous position
     */
    function updatePosition(Types.PositionId calldata newPosId, uint128 previousPosValue) external;

    /* -------------------------------------------------------------------------- */
    /*                                    Admin                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Sets the minimum amount of assets to be deposited by a user
     * @dev The new minimum amount must be greater than or equal to the minimum long position of the USDN protocol
     * This function can only be called by the owner or the USDN protocol
     * @param minAssetDeposit The new minimum amount of assets to be deposited
     */
    function setMinAssetDeposit(uint256 minAssetDeposit) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IRebalancerTypes {
    /**
     * @notice The deposit data of a user
     * @dev A value of zero for the `initiateTimestamp` indicates that the deposit or withdrawal was validated
     * @param initiateTimestamp Timestamp when the deposit or withdrawal was initiated
     * @param amount The amount of assets the user deposited
     * @param entryPositionVersion The position version the user entered at
     */
    struct UserDeposit {
        uint40 initiateTimestamp;
        uint88 amount; // Max 309'485'009 tokens with 18 decimals
        uint128 entryPositionVersion;
    }

    /**
     * @notice The data for a version of the position
     * @dev The difference between the amount here and the amount saved in the USDN protocol is the liquidation bonus
     * @param amount The amount of assets used as collateral to open the position
     * @param tick The tick of the position
     * @param tickVersion The version of the tick
     * @param index The index of the position in the tick list
     * @param entryAccMultiplier The accumulated PnL multiplier of all the positions up to this one
     */
    struct PositionData {
        uint128 amount;
        int24 tick;
        uint256 tickVersion;
        uint256 index;
        uint256 entryAccMultiplier;
    }

    /**
     * @notice The parameters related to the validation process of the Rebalancer deposit/withdraw
     * @dev If the `validationDeadline` has passed, the user is blocked from interacting until the cooldown duration
     * has elapsed (since the moment of the initiate action). After the cooldown, in case of a deposit action, the user
     * must withdraw their funds with `resetDepositAssets`. After the cooldown, in case of a withdrawal action, the user
     * can initiate a new withdrawal again
     * @param validationDelay Minimum duration in seconds between an initiate action and the corresponding validate
     * action
     * @param validationDeadline Maximum duration in seconds between an initiate action and the corresponding validate
     * action
     * @param actionCooldown Duration from the initiate action during which the user can't interact with the Rebalancer
     * if the `validationDeadline` elapsed.
     * @param closeDelay Duration from the last rebalancer long position opening during which the user can't perform a
     * {initiateClosePosition}
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
     * @notice Called by the USDN token after a rebase has happened
     * @param oldDivisor The value of the divisor before the rebase
     * @param newDivisor The value of the divisor after the rebase (necessarily smaller than `oldDivisor`)
     * @return result_ Arbitrary data that will be forwarded to the caller of `rebase`
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
 * to the specifics of this token are included below
 */
interface IUsdn is IERC20, IERC20Metadata, IERC20Permit, IUsdnEvents, IUsdnErrors {
    /**
     * @notice Total number of shares in existence
     * @return shares The number of shares
     */
    function totalShares() external view returns (uint256 shares);

    /**
     * @notice Number of shares owned by `account`
     * @param account The account to query
     * @return shares The number of shares
     */
    function sharesOf(address account) external view returns (uint256 shares);

    /**
     * @notice Transfer a given amount of shares from the `msg.sender` to `to`
     * @param to Recipient of the shares
     * @param value Number of shares to transfer
     * @return `true` in case of success
     */
    function transferShares(address to, uint256 value) external returns (bool);

    /**
     * @notice Transfer a given amount of shares from the `from` to `to`
     * @dev There should be sufficient allowance for the spender. Be mindful of the rebase logic. The allowance is in
     * tokens. So, after a rebase, the same amount of shares will be worth a higher amount of tokens. In that case,
     * the allowance of the initial approval will not be enough to transfer the new amount of tokens. This can
     * also happen when your transaction is in the mempool and the rebase happens before your transaction. Also note
     * that the amount of tokens deduced from the allowance is rounded up, so the `convertToTokensRoundUp` function
     * should be used when converting shares into an allowance value.
     * @param from The owner of the shares
     * @param to Recipient of the shares
     * @param value Number of shares to transfer
     * @return `true` in case of success
     */
    function transferSharesFrom(address from, address to, uint256 value) external returns (bool);

    /**
     * @notice Restricted function to mint new shares, providing a token value
     * @dev Caller must have the MINTER_ROLE
     * @param to Account to receive the new shares
     * @param amount Amount of tokens to mint, is internally converted to the proper shares amounts
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Restricted function to mint new shares
     * @dev Caller must have the MINTER_ROLE
     * @param to Account to receive the new shares
     * @param amount Amount of shares to mint
     * @return mintedTokens_ Amount of tokens that were minted (informational)
     */
    function mintShares(address to, uint256 amount) external returns (uint256 mintedTokens_);

    /**
     * @notice Destroy a `value` amount of tokens from the caller, reducing the total supply
     * @param value Amount of tokens to burn, is internally converted to the proper shares amounts
     */
    function burn(uint256 value) external;

    /**
     * @notice Destroy a `value` amount of tokens from `account`, deducting from the caller's allowance
     * @param account Account to burn tokens from
     * @param value Amount of tokens to burn, is internally converted to the proper shares amounts
     */
    function burnFrom(address account, uint256 value) external;

    /**
     * @notice Destroy a `value` amount of shares from the caller, reducing the total supply
     * @param value Amount of shares to burn
     */
    function burnShares(uint256 value) external;

    /**
     * @notice Destroy a `value` amount of shares from `account`, deducting from the caller's allowance
     * @dev There should be sufficient allowance for the spender. Be mindful of the rebase logic. The allowance is in
     * tokens. So, after a rebase, the same amount of shares will be worth a higher amount of tokens. In that case,
     * the allowance of the initial approval will not be enough to transfer the new amount of tokens. This can
     * also happen when your transaction is in the mempool and the rebase happens before your transaction. Also note
     * that the amount of tokens deduced from the allowance is rounded up, so the `convertToTokensRoundUp` function
     * should be used when converting shares into an allowance value.
     * @param account Account to burn shares from
     * @param value Amount of shares to burn
     */
    function burnSharesFrom(address account, uint256 value) external;

    /**
     * @notice Convert a number of tokens to the corresponding amount of shares
     * @dev The conversion reverts with `UsdnMaxTokensExceeded` if the corresponding amount of shares overflows
     * @param amountTokens The amount of tokens to convert to shares
     * @return shares_ The corresponding amount of shares
     */
    function convertToShares(uint256 amountTokens) external view returns (uint256 shares_);

    /**
     * @notice Convert a number of shares to the corresponding amount of tokens
     * @dev The conversion never overflows as we are performing a division. The conversion rounds to the nearest amount
     * of tokens that minimizes the error when converting back to shares
     * @param amountShares The amount of shares to convert to tokens
     * @return tokens_ The corresponding amount of tokens
     */
    function convertToTokens(uint256 amountShares) external view returns (uint256 tokens_);

    /**
     * @notice Convert a number of shares to the corresponding amount of tokens, rounding up
     * @dev Use this function to determine the amount of a token approval, as we always round up when deducting from
     * a token transfer allowance
     * @param amountShares The amount of shares to convert to tokens
     * @return tokens_ The corresponding amount of tokens, rounded up
     */
    function convertToTokensRoundUp(uint256 amountShares) external view returns (uint256 tokens_);

    /**
     * @notice View function returning the current maximum tokens supply, given the current divisor
     * @dev This function is used to check if a conversion operation would overflow
     * @return maxTokens_ The maximum number of tokens that can exist
     */
    function maxTokens() external view returns (uint256 maxTokens_);

    /**
     * @notice Restricted function to decrease the global divisor, which effectively grows all balances and the total
     * supply
     * @dev If the provided divisor is larger than or equal to the current divisor value, no rebase will happen
     * If the new divisor is smaller than `MIN_DIVISOR`, the value will be clamped to `MIN_DIVISOR`
     * Caller must have the `REBASER_ROLE`
     * @param divisor The new divisor, should be strictly smaller than the current one and greater or equal to
     * `MIN_DIVISOR`
     * @return rebased_ Whether a rebase happened
     * @return oldDivisor_ The previous value of the divisor
     * @return callbackResult_ The result of the callback, if a rebase happened and a callback handler is defined
     */
    function rebase(uint256 divisor)
        external
        returns (bool rebased_, uint256 oldDivisor_, bytes memory callbackResult_);

    /**
     * @notice Restricted function to set the address of the rebase handler
     * @dev Emits a `RebaseHandlerUpdated` event
     * If set to the zero address, no handler will be called after a rebase
     * Caller must have the `DEFAULT_ADMIN_ROLE`
     * @param newHandler The new handler address
     */
    function setRebaseHandler(IRebaseCallback newHandler) external;

    /* -------------------------------------------------------------------------- */
    /*                             Dev view functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The current value of the divisor that converts between tokens and shares
     * @return The current divisor
     */
    function divisor() external view returns (uint256);

    /**
     * @notice The address of the rebase handler, which is called whenever a rebase happens
     * @return The rebase handler address
     */
    function rebaseHandler() external view returns (IRebaseCallback);

    /**
     * @notice The minter role signature
     * @return The role signature
     */
    function MINTER_ROLE() external pure returns (bytes32);

    /**
     * @notice The rebaser role signature
     * @return The role signature
     */
    function REBASER_ROLE() external pure returns (bytes32);

    /**
     * @notice Maximum value of the divisor, which is also the initial value
     * @return The maximum divisor
     */
    function MAX_DIVISOR() external pure returns (uint256);

    /**
     * @notice Minimum acceptable value of the divisor
     * @dev The minimum divisor that can be set. This corresponds to a growth of 1B times. Technically, 1e5 would still
     * work without precision errors
     * @return The minimum divisor
     */
    function MIN_DIVISOR() external pure returns (uint256);
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
 * protocol position
 * @dev The contract must implement the ERC-165 interface detection mechanism
 */
interface IOwnershipCallback is IERC165 {
    /**
     * @notice This function is called by the USDN protocol on the new position owner after a transfer of ownership
     * @param oldOwner The previous owner of the position
     * @param posId The unique position identifier
     */
    function ownershipCallback(address oldOwner, Types.PositionId calldata posId) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IUsdnProtocolFallback } from "./IUsdnProtocolFallback.sol";
import { IUsdnProtocolImpl } from "./IUsdnProtocolImpl.sol";

/**
 * @title IUsdnProtocol
 * @notice Interface for the USDN protocol and fallback
 */
interface IUsdnProtocol is IUsdnProtocolImpl, IUsdnProtocolFallback {
    /**
     * @notice Function to upgrade the protocol to a new implementation (check {UUPSUpgradeable})
     * @dev This function should be called by the role with the PROXY_UPGRADE_ROLE
     * Passing in empty data skips the delegatecall to `newImplementation`
     * @param newImplementation The address of the new implementation
     * @param data The data to call when upgrading to the new implementation
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

import { HugeUint } from "../../libraries/HugeUint.sol";
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

import { HugeUint } from "../../libraries/HugeUint.sol";
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
import { LibBitmap } from "solady/src/utils/LibBitmap.sol";

import { DoubleEndedQueue } from "../../libraries/DoubleEndedQueue.sol";
import { HugeUint } from "../../libraries/HugeUint.sol";
import { IBaseLiquidationRewardsManager } from "../LiquidationRewardsManager/IBaseLiquidationRewardsManager.sol";
import { IBaseOracleMiddleware } from "../OracleMiddleware/IBaseOracleMiddleware.sol";
import { IBaseRebalancer } from "../Rebalancer/IBaseRebalancer.sol";
import { IUsdn } from "../Usdn/IUsdn.sol";

interface IUsdnProtocolTypes {
    /**
     * @notice All possible action types for the protocol
     * @dev This is used for pending actions and to interact with the oracle middleware
     * @param None No particular action
     * @param Initialize The contract is being initialized
     * @param InitiateDeposit Initiating a `deposit` action
     * @param ValidateDeposit Validating a `deposit` action
     * @param InitiateWithdrawal Initiating a `withdraw` action
     * @param ValidateWithdrawal Validating a `withdraw` action
     * @param InitiateOpenPosition Initiating an `open` position action
     * @param ValidateOpenPosition Validating an `open` position action
     * @param InitiateClosePosition Initiating a `close` position action
     * @param ValidateClosePosition Validating a `close` position action
     * @param Liquidation The price is requested for a liquidation action
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
     * @notice The outcome of the call targeting a long position
     * @param Processed The call did what it was supposed to do
     * An initiate close has been completed / a pending action was validated
     * @param Liquidated The position has been liquidated by this call
     * @param PendingLiquidations The call cannot be completed because of pending liquidations
     * Try calling the `liquidate` function with a fresh price to unblock the situation
     */
    enum LongActionOutcome {
        Processed,
        Liquidated,
        PendingLiquidations
    }

    /**
     * @notice Classifies how far in its logic the `_triggerRebalancer` function made it to
     * @dev Used to estimate the gas spent by the function call to more accurately calculate liquidation rewards
     * @param None The rebalancer is not set
     * @param NoImbalance The protocol imbalance is not reached
     * @param PendingLiquidation The rebalancer position should be liquidated
     * @param NoCloseNoOpen The action neither closes nor opens a position
     * @param Closed The action only closes a position
     * @param Opened The action only opens a position
     * @param ClosedOpened The action closes and opens a position
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
     * @notice Information about a long user position
     * @param validated Whether the position was validated
     * @param timestamp The timestamp of the position start
     * @param user The user's address
     * @param totalExpo The total exposure of the position (0 for vault deposits). The product of the initial
     * collateral and the initial leverage
     * @param amount The amount of initial collateral in the position
     */
    struct Position {
        bool validated; // 1 byte
        uint40 timestamp; // 5 bytes. Max 1_099_511_627_775 (36812-02-20 01:36:15)
        address user; // 20 bytes
        uint128 totalExpo; // 16 bytes. Max 340_282_366_920_938_463_463.374_607_431_768_211_455 ether
        uint128 amount; // 16 bytes
    }

    /**
     * @notice A pending action in the queue
     * @param action The action type
     * @param timestamp The timestamp of the initiate action
     * @param var0 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param to The `to` address
     * @param validator The `validator` address
     * @param securityDepositValue The security deposit of the pending action
     * @param var1 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var2 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var3 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var4 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var5 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var6 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
     * @param var7 See `DepositPendingAction`, `WithdrawalPendingAction` and `LongPendingAction`
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
     * @notice A pending action in the queue for a vault deposit
     * @param action The action type
     * @param timestamp The timestamp of the initiate action
     * @param feeBps Fee for the deposit, in BPS
     * @param to The `to` address
     * @param validator The `validator` address
     * @param securityDepositValue The security deposit of the pending action
     * @param _unused Unused field to align the struct to `PendingAction`
     * @param amount The amount of assets of the pending deposit
     * @param assetPrice The price of the asset at the time of the last update
     * @param totalExpo The total exposure at the time of the last update
     * @param balanceVault The balance of the vault at the time of the last update
     * @param balanceLong The balance of the long position at the time of the last update
     * @param usdnTotalShares The total supply of USDN shares at the time of the action
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
     * @notice A pending action in the queue for a vault withdrawal
     * @param action The action type
     * @param timestamp The timestamp of the initiate action
     * @param feeBps Fee for the withdrawal, in BPS
     * @param to The `to` address
     * @param validator The `validator` address
     * @param securityDepositValue The security deposit of the pending action
     * @param sharesLSB 3 least significant bytes of the withdrawal shares amount (uint152)
     * @param sharesMSB 16 most significant bytes of the withdrawal shares amount (uint152)
     * @param assetPrice The price of the asset at the time of the last update
     * @param totalExpo The total exposure at the time of the last update
     * @param balanceVault The balance of the vault at the time of the last update
     * @param balanceLong The balance of the long position at the time of the last update
     * @param usdnTotalShares The total shares supply of USDN at the time of the action
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
     * @notice A pending action in the queue for a long position
     * @param action The action type
     * @param timestamp The timestamp of the initiate action
     * @param closeLiqPenalty The liquidation penalty of the tick (only used when closing a position)
     * @param to The `to` address
     * @param validator The `validator` address
     * @param securityDepositValue The security deposit of the pending action
     * @param tick The tick of the position
     * @param closeAmount The portion of the initial position amount to close (only used when closing a position)
     * @param closePosTotalExpo The total expo of the position (only used when closing a position)
     * @param tickVersion The version of the tick
     * @param index The index of the position in the tick list
     * @param liqMultiplier A fixed precision representation of the liquidation multiplier (with
     * `LIQUIDATION_MULTIPLIER_DECIMALS` decimals) used to calculate the effective price for a given tick number
     * @param closeBoundedPositionValue The amount that was removed from the long balance on `initiateClosePosition`
     * (only used when closing a position)
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
     * @notice The data allowing to validate an actionable pending action
     * @param priceData An array of bytes, each representing the data to be forwarded to the oracle middleware to
     * validate
     * a pending action in the queue
     * @param rawIndices An array of raw indices in the pending actions queue, in the same order as the corresponding
     * priceData
     */
    struct PreviousActionsData {
        bytes[] priceData;
        uint128[] rawIndices;
    }

    /**
     * @notice Information of a liquidated tick
     * @param totalPositions The total number of positions in the tick
     * @param totalExpo The total expo of the tick
     * @param remainingCollateral The remaining collateral after liquidation
     * @param tickPrice The corresponding price
     * @param priceWithoutPenalty The price without the liquidation penalty
     */
    struct LiqTickInfo {
        uint256 totalPositions;
        uint256 totalExpo;
        int256 remainingCollateral;
        uint128 tickPrice;
        uint128 priceWithoutPenalty;
    }

    /**
     * @notice The effects of executed liquidations on the protocol
     * @param liquidatedPositions The total number of liquidated positions
     * @param remainingCollateral The remaining collateral after liquidation
     * @param newLongBalance The new balance of the long side
     * @param newVaultBalance The new balance of the vault side
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate)
     * @param liquidatedTicks Information about the liquidated ticks
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
     * @notice Accumulator for tick data
     * @param totalExpo The sum of the total expo of each position in the tick
     * @param totalPos The number of positions in the tick
     * @param liquidationPenalty The liquidation penalty for the positions in the tick
     * @dev Since the liquidation penalty is a parameter that can be updated, we need to ensure that positions that get
     * created with a given penalty, use this penalty throughout their lifecycle. As such, once a tick gets populated by
     * a first position, it gets assigned the current liquidation penalty parameter value and can't use another value
     * until it gets liquidated or all positions exit the tick
     */
    struct TickData {
        uint256 totalExpo;
        uint248 totalPos;
        uint24 liquidationPenalty;
    }

    /**
     * @notice The unique identifier for a long position
     * @param tick The tick of the position
     * @param tickVersion The version of the tick
     * @param index The index of the position in the tick list
     */
    struct PositionId {
        int24 tick;
        uint256 tickVersion;
        uint256 index;
    }

    /**
     * @notice Parameters for the internal `_initiateOpenPosition` function
     * @param user The address of the user initiating the open position
     * @param to The address that will be the owner of the position
     * @param validator The address that will validate the open position
     * @param amount The amount of assets to deposit
     * @param desiredLiqPrice The desired liquidation price, including the liquidation penalty
     * @param userMaxPrice The maximum price at which the position can be opened. The userMaxPrice is compared with the
     * price after confidence interval, penalty, etc...
     * @param userMaxLeverage The maximum leverage for the newly created position
     * @param deadline The deadline of the open position to be initiated
     * @param securityDepositValue The value of the security deposit for the newly created pending action
     * @param currentPriceData The current price data (used to calculate the temporary leverage and entry price,
     * pending validation)
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
     * @notice Parameters for the internal `_prepareInitiateOpenPosition` function
     * @param validator The address of the validator
     * @param amount The amount of assets to deposit
     * @param desiredLiqPrice The desired liquidation price, including the liquidation penalty
     * @param userMaxPrice The maximum price at which the position can be opened. The userMaxPrice is compared with the
     * price after confidence interval, penalty, etc...
     * @param userMaxLeverage The maximum leverage for the newly created position
     * @param currentPriceData The current price data
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
     * @notice Parameters for the internal `_prepareClosePositionData` function
     * @param to The address that will receive the assets
     * @param validator The address of the pending action validator
     * @param posId The unique identifier of the position
     * @param amountToClose The amount of collateral to remove from the position's amount
     * @param userMinPrice The minimum price at which the position can be closed
     * @param deadline The deadline until the position can be closed
     * @param currentPriceData The current price data
     * @param delegationSignature An EIP712 signature that proves the caller is authorized by the owner of the position
     * to close it on their behalf
     * @param domainSeparatorV4 The domain separator v4
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
     * @notice Parameters for the internal `_initiateClosePosition` function
     * @param to The address that will receive the closed amount
     * @param validator The address that will validate the close position
     * @param posId The position id
     * @param amountToClose The amount to close
     * @param userMinPrice The minimum price at which the position can be closed
     * @param deadline The deadline of the close position to be initiated
     * @param securityDepositValue The value of the security deposit for the newly created pending action
     * @param domainSeparatorV4 The domain separator v4 for EIP712 signature
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
     * @dev Structure to hold the transient data during `_initiateClosePosition`
     * @param pos The position to close
     * @param liquidationPenalty The liquidation penalty
     * @param totalExpoToClose The total expo to close
     * @param lastPrice The price after the last balances update
     * @param tempPositionValue The bounded value of the position that was removed from the long balance
     * @param longTradingExpo The long trading expo
     * @param liqMulAcc The liquidation multiplier accumulator
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate)
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
     * @dev Structure to hold the transient data during `_validateOpenPosition`
     * @param action The long pending action
     * @param startPrice The new entry price of the position
     * @param lastPrice The price of the last balances update
     * @param tickHash The tick hash
     * @param pos The position object
     * @param liqPriceWithoutPenaltyNorFunding The liquidation price without penalty nor funding used to calculate the
     * user leverage and the new total expo
     * @param liqPriceWithoutPenalty The new liquidation price without penalty
     * @param leverage The new leverage
     * @param oldPosValue The value of the position according to the old entry price and the _lastPrice
     * @param liquidationPenalty The liquidation penalty for the position's tick
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate)
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
     * @dev Structure to hold the transient data during `_initiateOpenPosition`
     * @param adjustedPrice The adjusted price with position fees applied
     * @param posId The new position id
     * @param liquidationPenalty The liquidation penalty
     * @param positionTotalExpo The total expo of the position. The product of the initial collateral and the initial
     * leverage
     * @param positionValue The value of the position, taking into account the position fee
     * @param liqMultiplier The liquidation multiplier represented with fixed precision
     * @param isLiquidationPending Whether some ticks are still populated above the current price (left to liquidate)
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
     * @notice Structure to hold the state of the protocol
     * @param totalExpo The long total expo
     * @param tradingExpo The long trading expo
     * @param longBalance The long balance
     * @param vaultBalance The vault balance
     * @param liqMultiplierAccumulator The liquidation multiplier accumulator
     */
    struct CachedProtocolState {
        uint256 totalExpo;
        uint256 tradingExpo;
        uint256 longBalance;
        uint256 vaultBalance;
        HugeUint.Uint512 liqMultiplierAccumulator;
    }

    /**
     * @notice Structure to hold transient data during the `_calcRebalancerPositionTick` function
     * @param protocolMaxLeverage The protocol maximum leverage
     * @param longImbalanceTargetBps The long imbalance target in basis points
     * @param tradingExpoToFill The trading expo to fill
     * @param highestUsableTradingExpo The highest usable trading expo
     * @param currentLiqPenalty The current liquidation penalty
     * @param liqPriceWithoutPenalty The liquidation price without penalty
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
     * @notice Structure to hold the return values of the `_calcRebalancerPositionTick` function
     * @param tick The tick of the rebalancer position, includes liquidation penalty
     * @param totalExpo The total expo of the rebalancer position
     * @param liquidationPenalty The liquidation penalty of the tick
     */
    struct RebalancerPositionData {
        int24 tick;
        uint128 totalExpo;
        uint24 liquidationPenalty;
    }

    /**
     * @notice Data structure for the `_applyPnlAndFunding` function
     * @param tempLongBalance The new balance of the long side, could be negative (temporarily)
     * @param tempVaultBalance The new balance of the vault side, could be negative (temporarily)
     * @param lastPrice The last price
     */
    struct ApplyPnlAndFundingData {
        int256 tempLongBalance;
        int256 tempVaultBalance;
        uint128 lastPrice;
    }

    /**
     * @notice Data structure for tick to price conversion functions
     * @param tradingExpo The long side trading expo
     * @param accumulator The liquidation multiplier accumulator
     * @param tickSpacing The tick spacing
     */
    struct TickPriceConversionData {
        uint256 tradingExpo;
        HugeUint.Uint512 accumulator;
        int24 tickSpacing;
    }

    /**
     * @custom:storage-location erc7201:UsdnProtocol.storage.main
     * @notice Structure to hold the state of the protocol
     * @param _tickSpacing The liquidation tick spacing for storing long positions
     * @dev A tick spacing of 1 is equivalent to a 0.01% increase in liquidation price between ticks. A tick spacing of
     * 100 is equivalent to a ~1.005% increase in liquidation price between ticks
     * @param _asset The asset ERC20 contract
     * Assets with a blacklist are not supported because the protocol would be DoS if transfers revert
     * @param _assetDecimals The asset decimals
     * @param _priceFeedDecimals The price feed decimals (18)
     * @param _usdn The USDN ERC20 contract
     * @param _sdex The SDEX ERC20 contract
     * @param _usdnMinDivisor The minimum divisor for USDN
     * @param _oracleMiddleware The oracle middleware contract
     * @param _liquidationRewardsManager The liquidation rewards manager contract
     * @param _rebalancer The rebalancer contract
     * @param _isRebalancer Whether an address is or has been a rebalancer
     * @param _minLeverage The minimum leverage for a position
     * @param _maxLeverage The maximum leverage for a position
     * @param _lowLatencyValidatorDeadline The deadline for a user to confirm their action with a low-latency oracle
     * @dev After this deadline, any user can validate the action with the low-latency oracle until the
     * OracleMiddleware's _lowLatencyDelay. This is an offset compared to the timestamp of the initiate action
     * @param _onChainValidatorDeadline The deadline for a user to confirm their action with an on-chain oracle
     * @dev After this deadline, any user can validate the action with the on-chain oracle. This is an offset compared
     * to the timestamp of the initiate action + the oracle middleware's _lowLatencyDelay
     * @param _safetyMarginBps Safety margin for the liquidation price of newly open positions, in basis points
     * @param _liquidationIteration The number of iterations to perform during the user's action (in tick)
     * @param _protocolFeeBps The protocol fee in basis points
     * @param _rebalancerBonusBps Part of the remaining collateral that is given as a bonus to the Rebalancer upon
     * liquidation of a tick, in basis points. The rest is sent to the Vault balance
     * @param _liquidationPenalty The liquidation penalty (in ticks)
     * @param _EMAPeriod The moving average period of the funding rate
     * @param _fundingSF The scaling factor (SF) of the funding rate
     * @param _feeThreshold The threshold above which the fee will be sent
     * @param _openExpoImbalanceLimitBps The imbalance limit of the long expo for open actions (in basis points)
     * @dev As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of long the open rebalancing mechanism is triggered, preventing the opening of a new long position
     * @param _withdrawalExpoImbalanceLimitBps The imbalance limit of the long expo for withdrawal actions (in basis
     * points)
     * @dev As soon as the difference between vault expo and long expo exceeds this basis point limit in favor of long,
     * the withdrawal rebalancing mechanism is triggered, preventing the withdrawal of the existing vault position
     * @param _depositExpoImbalanceLimitBps The imbalance limit of the vault expo for deposit actions (in basis points)
     * @dev As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of the vault, the deposit vault rebalancing mechanism is triggered, preventing the opening of a new vault
     * position
     * @param _closeExpoImbalanceLimitBps The imbalance limit of the vault expo for close actions (in basis points)
     * @dev As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of the vault, the close rebalancing mechanism is triggered, preventing the close of an existing long position
     * @param _rebalancerCloseExpoImbalanceLimitBps The imbalance limit of the vault expo for close actions from the
     * rebalancer (in basis points)
     * @dev As soon as the difference between the vault expo and the long expo exceeds this basis point limit in favor
     * of the vault, the close rebalancing mechanism is triggered, preventing the close of an existing long position
     * from the rebalancer contract
     * @param _longImbalanceTargetBps The target imbalance on the long side (in basis points)
     * @dev This value will be used to calculate how much of the missing trading expo the rebalancer position will try
     * to compensate
     * A negative value means the rebalancer will compensate enough to go above the equilibrium
     * A positive value means the rebalancer will compensate but stay below the equilibrium
     * @param _positionFeeBps The position fee in basis points
     * @param _vaultFeeBps The fee for vault deposits and withdrawals, in basis points
     * @param _sdexBurnOnDepositRatio The ratio of USDN to SDEX tokens to burn on deposit
     * @param _feeCollector The fee collector's address
     * @param _securityDepositValue The deposit required for a new position
     * @param _targetUsdnPrice The nominal (target) price of USDN (with _priceFeedDecimals)
     * @param _usdnRebaseThreshold The USDN price threshold to trigger a rebase (with _priceFeedDecimals)
     * @param _minLongPosition The minimum long position size (with `_assetDecimals`)
     * @param _lastFundingPerDay The funding rate calculated at the last update timestamp
     * @param _lastPrice The price of the asset during the last balances update (with price feed decimals)
     * @param _lastUpdateTimestamp The timestamp of the last balances update
     * @param _pendingProtocolFee The pending protocol fee accumulator
     * @param _pendingActions The pending actions by the user (1 per user max)
     * @dev The value stored is an index into the `pendingActionsQueue` deque, shifted by one. A value of 0 means no
     * pending action. Since the deque uses uint128 indices, the highest index will not overflow when adding one
     * @param _pendingActionsQueue The queue of pending actions
     * @param _balanceVault  The balance of deposits (with asset decimals)
     * @param _pendingBalanceVault The unreflected balance change due to pending vault actions (with asset decimals)
     * @param _EMA The exponential moving average of the funding (0.0003 at initialization)
     * @param _balanceLong The balance of long positions (with asset decimals)
     * @param _totalExpo The total exposure of the long positions (with asset decimals)
     * @param _liqMultiplierAccumulator The accumulator used to calculate the liquidation multiplier
     * @dev This is the sum, for all ticks, of the total expo of positions inside the tick, multiplied by the
     * unadjusted price of the tick which is `_tickData[tickHash].liquidationPenalty` below
     * The unadjusted price is obtained with `TickMath.getPriceAtTick
     * @param _tickVersion The liquidation tick version
     * @param _longPositions The long positions per versioned tick (liquidation price)
     * @param _tickData Accumulated data for a given tick and tick version
     * @param _highestPopulatedTick The highest tick with a position
     * @param _totalLongPositions Cache of the total long positions count
     * @param _tickBitmap The bitmap used to quickly find populated ticks
     * @param _protocolFallbackAddr The address of the fallback contract
     * @param _nonce The user EIP712 nonce
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
 * of the sequence (called front and back)
 * @dev Storage use is optimized, and all operations are O(1) constant time
 *
 * The struct is called `Deque` and holds `PendingAction`s. This data structure can only be used in storage, and not in
 * memory
 */
library DoubleEndedQueue {
    /// @dev Indicates that an operation (e.g. {front}) couldn't be completed due to the queue being empty
    error QueueEmpty();

    /// @dev Indicates that a push operation couldn't be completed due to the queue being full
    error QueueFull();

    /// @dev Indicates that an operation (e.g. {atRaw}) couldn't be completed due to an index being out of bounds
    error QueueOutOfBounds();

    /**
     * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior
     *
     * The first item is at data[begin] and the last item is at data[end - 1]. This range can wrap around
     * @param _begin The index of the first item in the queue
     * @param _end The index of the item after the last item in the queue
     * @param _data The items in the queue
     */
    struct Deque {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 index => Types.PendingAction) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue
     * Reverts with {QueueFull} if the queue is full
     * @param deque The queue
     * @param value The item to insert
     * @return backIndex_ The raw index of the inserted item
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
     * @dev Removes the item at the end of the queue and returns it
     * Reverts with {QueueEmpty} if the queue is empty
     * @param deque The queue
     * @return value_ The removed item
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
     * @dev Inserts an item at the beginning of the queue
     * Reverts with {QueueFull} if the queue is full
     * @param deque The queue
     * @param value The item to insert
     * @return frontIndex_ The raw index of the inserted item
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
     * @dev Removes the item at the beginning of the queue and returns it
     * Reverts with `QueueEmpty` if the queue is empty
     * @param deque The queue
     * @return value_ The removed item
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
     * @dev Returns the item at the beginning of the queue
     * Reverts with `QueueEmpty` if the queue is empty
     * @param deque The queue
     * @return value_ The item at the front of the queue
     * @return rawIndex_ The raw index of the returned item
     */
    function front(Deque storage deque) external view returns (Types.PendingAction memory value_, uint128 rawIndex_) {
        if (empty(deque)) {
            revert QueueEmpty();
        }
        rawIndex_ = deque._begin;
        value_ = deque._data[rawIndex_];
    }

    /**
     * @dev Returns the item at the end of the queue
     * Reverts with `QueueEmpty` if the queue is empty
     * @param deque The queue
     * @return value_ The item at the back of the queue
     * @return rawIndex_ The raw index of the returned item
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
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and the last item at
     * `length(deque) - 1`
     * Reverts with `QueueOutOfBounds` if the index is out of bounds
     * @param deque The queue
     * @param index The index of the item to return
     * @return value_ The item at the given index
     * @return rawIndex_ The raw index of the item
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
     * @dev Return the item at a position in the queue given by `rawIndex`, indexing into the underlying storage array
     * directly
     * Reverts with `QueueOutOfBounds` if the index is out of bounds
     * @param deque The queue
     * @param rawIndex The index of the item to return
     * @return value_ The item at the given index
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
     * to zero and the queue's begin and end indices are not updated
     * @param deque The queue
     * @param rawIndex The index of the item to delete
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
     * @dev Check if the raw index is valid (in bounds)
     * @param deque The queue
     * @param rawIndex The raw index to check
     * @return valid_ Whether the raw index is valid
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
     * @dev Returns the number of items in the queue
     * @param deque The queue
     * @return length_ The number of items in the queue
     */
    function length(Deque storage deque) public view returns (uint256 length_) {
        unchecked {
            length_ = uint256(deque._end - deque._begin);
        }
    }

    /**
     * @dev Returns true if the queue is empty
     * @param deque The queue
     * @return empty_ True if the queue is empty
     */
    function empty(Deque storage deque) internal view returns (bool empty_) {
        empty_ = deque._end == deque._begin;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

/**
 * @notice A library for manipulating uint512 quantities
 * The 512-bit unsigned integers are represented as two uint256 "limbs", a `hi` limb for the most significant bits,
 * and a `lo` limb for the least-significant bits. The resulting uint512 quantity is obtained with `hi * 2^256 + lo`
 */
library HugeUint {
    /// @notice Indicates that the division failed because the divisor is zero or the result overflows a uint256
    error HugeUintDivisionFailed();

    /// @notice Indicates that the addition overflowed a uint512
    error HugeUintAddOverflow();

    /// @notice Indicates that the subtraction underflowed
    error HugeUintSubUnderflow();

    /// @notice Indicates that the multiplication overflowed a uint512
    error HugeUintMulOverflow();

    /**
     * @notice A 512-bit integer represented as two 256-bit limbs
     * @dev The integer value can be reconstructed as `hi * 2^256 + lo`
     * @param hi The most-significant bits (higher limb) of the integer
     * @param lo The least-significant bits (lower limb) of the integer
     */
    struct Uint512 {
        uint256 hi;
        uint256 lo;
    }

    /**
     * @notice Wrap a uint256 into a Uint512 integer
     * @param x A uint256 integer
     * @return The same value as a 512-bit integer
     */
    function wrap(uint256 x) internal pure returns (Uint512 memory) {
        return Uint512({ hi: 0, lo: x });
    }

    /**
     * @notice Calculate the sum `a + b` of two 512-bit unsigned integers
     * @dev This function will revert if the result overflows a uint512
     * @param a The first operand
     * @param b The second operand
     * @return res_ The sum of `a` and `b`
     */
    function add(Uint512 memory a, Uint512 memory b) external pure returns (Uint512 memory res_) {
        (res_.lo, res_.hi) = _add(a.lo, a.hi, b.lo, b.hi);
        // check for overflow, i.e. if the result is less than b
        if (res_.hi < b.hi || (res_.hi == b.hi && res_.lo < b.lo)) {
            revert HugeUintAddOverflow();
        }
    }

    /**
     * @notice Calculate the difference `a - b` of two 512-bit unsigned integers
     * @dev This function will revert if `b > a`
     * @param a The first operand
     * @param b The second operand
     * @return res_ The difference `a - b`
     */
    function sub(Uint512 memory a, Uint512 memory b) external pure returns (Uint512 memory res_) {
        // check for underflow
        if (a.hi < b.hi || (a.hi == b.hi && a.lo < b.lo)) {
            revert HugeUintSubUnderflow();
        }
        (res_.lo, res_.hi) = _sub(a.lo, a.hi, b.lo, b.hi);
    }

    /**
     * @notice Calculate the product `a * b` of two 256-bit unsigned integers using the Chinese remainder theorem
     * @param a The first operand
     * @param b The second operand
     * @return res_ The product `a * b` of the operands as an unsigned 512-bit integer
     */
    function mul(uint256 a, uint256 b) external pure returns (Uint512 memory res_) {
        (res_.lo, res_.hi) = _mul256(a, b);
    }

    /**
     * @notice Calculate the product `a * b` of a 512-bit unsigned integer and a 256-bit unsigned integer
     * @dev This function reverts if the result overflows a uint512
     * @param a The first operand
     * @param b The second operand
     * @return res_ The product `a * b` of the operands as an unsigned 512-bit integer
     */
    function mul(Uint512 memory a, uint256 b) external pure returns (Uint512 memory res_) {
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
     * @notice Calculate the division `floor(a / b)` of a 512-bit unsigned integer by an unsigned 256-bit integer
     * @dev The call will revert if the result doesn't fit inside a uint256 or if the denominator is zero
     * @param a The numerator as a 512-bit unsigned integer
     * @param b The denominator as a 256-bit unsigned integer
     * @return res_ The division `floor(a / b)` of the operands as an unsigned 256-bit integer
     */
    function div(Uint512 memory a, uint256 b) external pure returns (uint256 res_) {
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
     * @notice Compute the division floor(a/b) of two 512-bit integers, knowing the result fits inside a uint256
     * @dev Credits chfast (Apache 2.0 License): https://github.com/chfast/intx
     * This function will revert if the second operand is zero or if the result doesn't fit inside a uint256
     * @param a The numerator as a 512-bit integer
     * @param b The denominator as a 512-bit integer
     * @return res_ The quotient floor(a/b)
     */
    function div(Uint512 memory a, Uint512 memory b) external pure returns (uint256 res_) {
        res_ = _div(a.lo, a.hi, b.lo, b.hi);
    }

    /**
     * @notice Calculate the sum `a + b` of two 512-bit unsigned integers
     * @dev Credits Remco Bloemen (MIT license): https://2π.com/17/512-bit-division/
     * The result is not checked for overflow, the caller must ensure that the result fits inside a uint512
     * @param a0 The low limb of the first operand
     * @param a1 The high limb of the first operand
     * @param b0 The low limb of the second operand
     * @param b1 The high limb of the second operand
     * @return lo_ The low limb of the result of `a + b`
     * @return hi_ The high limb of the result of `a + b`
     */
    function _add(uint256 a0, uint256 a1, uint256 b0, uint256 b1) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := add(a0, b0)
            hi_ := add(add(a1, b1), lt(lo_, a0))
        }
    }

    /**
     * @notice Calculate the difference `a - b` of two 512-bit unsigned integers
     * @dev Credits Remco Bloemen (MIT license): https://2π.com/17/512-bit-division/
     * The result is not checked for underflow, the caller must ensure that the second operand is less than or equal to
     * the first operand
     * @param a0 The low limb of the first operand
     * @param a1 The high limb of the first operand
     * @param b0 The low limb of the second operand
     * @param b1 The high limb of the second operand
     * @return lo_ The low limb of the result of `a - b`
     * @return hi_ The high limb of the result of `a - b`
     */
    function _sub(uint256 a0, uint256 a1, uint256 b0, uint256 b1) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := sub(a0, b0)
            hi_ := sub(sub(a1, b1), lt(a0, b0))
        }
    }

    /**
     * @notice Calculate the product `a * b` of two 256-bit unsigned integers using the Chinese remainder theorem
     * @dev Credits Remco Bloemen (MIT license): https://2π.com/17/chinese-remainder-theorem/
     * and Solady (MIT license): https://github.com/Vectorized/solady/
     * @param a The first operand
     * @param b The second operand
     * @return lo_ The low limb of the result of `a * b`
     * @return hi_ The high limb of the result of `a * b`
     */
    function _mul256(uint256 a, uint256 b) internal pure returns (uint256 lo_, uint256 hi_) {
        assembly {
            lo_ := mul(a, b)
            let mm := mulmod(a, b, not(0)) // (a * b) % uint256.max
            hi_ := sub(mm, add(lo_, lt(mm, lo_)))
        }
    }

    /**
     * @notice Calculate the division `floor(a / b)` of a 512-bit unsigned integer by an unsigned 256-bit integer
     * @dev Credits Solady (MIT license): https://github.com/Vectorized/solady/
     * The caller must ensure that the result fits inside a uint256 and that the division is non-zero
     * For performance reasons, the caller should ensure that the numerator high limb (hi) is non-zero
     * @param a0 The low limb of the numerator
     * @param a1 The high limb of the  numerator
     * @param b The denominator as a 256-bit unsigned integer
     * @return res_ The division `floor(a / b)` of the operands as an unsigned 256-bit integer
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
     * @notice Compute the division of a 768-bit integer `a` by a 512-bit integer `b`, knowing the reciprocal of `b`
     * @dev Credits chfast (Apache 2.0 License): https://github.com/chfast/intx
     * @param a0 The LSB of the numerator
     * @param a1 The middle limb of the numerator
     * @param a2 The MSB of the numerator
     * @param b0 The low limb of the divisor
     * @param b1 The high limb of the divisor
     * @param v The reciprocal `v` as defined in `_reciprocal_2`
     * @return The quotient floor(a/b)
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
     * @notice Compute the division floor(a/b) of two 512-bit integers, knowing the result fits inside a uint256
     * @dev Credits chfast (Apache 2.0 License): https://github.com/chfast/intx
     * @param a0 LSB of the numerator
     * @param a1 MSB of the numerator
     * @param b0 LSB of the divisor
     * @param b1 MSB of the divisor
     * @return res_ The quotient floor(a/b)
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
     * @notice Compute the reciprocal `v = floor((2^512-1) / d) - 2^256`
     * @dev The input must be normalized (d >= 2^255)
     * @param d The input value
     * @return v_ The reciprocal of d
     */
    function _reciprocal(uint256 d) internal pure returns (uint256 v_) {
        if (d & 0x8000000000000000000000000000000000000000000000000000000000000000 == 0) {
            revert HugeUintDivisionFailed();
        }
        v_ = _div256(type(uint256).max, type(uint256).max - d, d);
    }

    /**
     * @notice Compute the reciprocal `v = floor((2^768-1) / d) - 2^256`, where d is a uint512 integer
     * @dev Credits chfast (Apache 2.0 License): https://github.com/chfast/intx
     * @param d0 LSB of the input
     * @param d1 MSB of the input
     * @return v_ The reciprocal of d
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
     * @notice Count the number of consecutive zero bits, starting from the left
     * @dev Credits Solady (MIT license): https://github.com/Vectorized/solady/
     * @param x An unsigned integer
     * @return n_ The number of zeroes starting from the most significant bit
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
            if gt(x, div(not(0), y)) {
                if y {
                    mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                    revert(0x1c, 0x04)
                }
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
            z := mul(x, y)
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if iszero(eq(div(z, y), x)) {
                if y {
                    mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            z := add(iszero(iszero(mod(z, WAD))), div(z, WAD))
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
            // Equivalent to `require(y != 0 && x <= type(uint256).max / WAD)`.
            if iszero(mul(y, lt(x, add(1, div(not(0), WAD))))) {
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
            if iszero(mul(y, eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, y)
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
            // Equivalent to `require(y != 0 && x <= type(uint256).max / WAD)`.
            if iszero(mul(y, lt(x, add(1, div(not(0), WAD))))) {
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
            (int256 wad, int256 p) = (int256(WAD), x);
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

    /// @dev Returns `a * b == x * y`, with full precision.
    function fullMulEq(uint256 a, uint256 b, uint256 x, uint256 y)
        internal
        pure
        returns (bool result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := and(eq(mul(a, b), mul(x, y)), eq(mulmod(x, y, not(0)), mulmod(a, b, not(0))))
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // 512-bit multiply `[p1 p0] = x * y`.
            // Compute the product mod `2**256` and mod `2**256 - 1`
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that `product = p1 * 2**256 + p0`.

            // Temporarily use `z` as `p0` to save gas.
            z := mul(x, y) // Lower 256 bits of `x * y`.
            for {} 1 {} {
                // If overflows.
                if iszero(mul(or(iszero(x), eq(div(z, x), y)), d)) {
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(z, lt(mm, z))) // Upper 256 bits of `x * y`.

                    /*------------------- 512 by 256 division --------------------*/

                    // Make division exact by subtracting the remainder from `[p1 p0]`.
                    let r := mulmod(x, y, d) // Compute remainder using mulmod.
                    let t := and(d, sub(0, d)) // The least significant bit of `d`. `t >= 1`.
                    // Make sure `z` is less than `2**256`. Also prevents `d == 0`.
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
                    z :=
                        mul(
                            // Divide [p1 p0] by the factors of two.
                            // Shift in bits from `p1` into `p0`. For this we need
                            // to flip `t` such that it is `2**256 / t`.
                            or(mul(sub(p1, gt(r, z)), add(div(sub(0, t), t), 1)), div(sub(z, r), t)),
                            mul(sub(2, mul(d, inv)), inv) // inverse mod 2**256
                        )
                    break
                }
                z := div(z, d)
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
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            let mm := mulmod(x, y, not(0))
            let p1 := sub(mm, add(z, lt(mm, z)))
            let t := and(d, sub(0, d))
            let r := mulmod(x, y, d)
            d := div(d, t)
            let inv := xor(2, mul(3, d))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            inv := mul(inv, sub(2, mul(d, inv)))
            z :=
                mul(
                    or(mul(sub(p1, gt(r, z)), add(div(sub(0, t), t), 1)), div(sub(z, r), t)),
                    mul(sub(2, mul(d, inv)), inv)
                )
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        z = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                z := add(z, 1)
                if iszero(z) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Calculates `floor(x * y / 2 ** n)` with full precision.
    /// Throws if result overflows a uint256.
    /// Credit to Philogy under MIT license:
    /// https://github.com/SorellaLabs/angstrom/blob/main/contracts/src/libraries/X128MathLib.sol
    function fullMulDivN(uint256 x, uint256 y, uint8 n) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Temporarily use `z` as `p0` to save gas.
            z := mul(x, y) // Lower 256 bits of `x * y`. We'll call this `z`.
            for {} 1 {} {
                if iszero(or(iszero(x), eq(div(z, x), y))) {
                    let k := and(n, 0xff) // `n`, cleaned.
                    let mm := mulmod(x, y, not(0))
                    let p1 := sub(mm, add(z, lt(mm, z))) // Upper 256 bits of `x * y`.
                    //         |      p1     |      z     |
                    // Before: | p1_0 ¦ p1_1 | z_0  ¦ z_1 |
                    // Final:  |   0  ¦ p1_0 | p1_1 ¦ z_0 |
                    // Check that final `z` doesn't overflow by checking that p1_0 = 0.
                    if iszero(shr(k, p1)) {
                        z := add(shl(sub(256, k), p1), shr(k, z))
                        break
                    }
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
                z := shr(and(n, 0xff), z)
                break
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

    /// @dev Returns `x`, the modular multiplicative inverse of `a`, such that `(a * x) % n == 1`.
    function invMod(uint256 a, uint256 n) internal pure returns (uint256 x) {
        /// @solidity memory-safe-assembly
        assembly {
            let g := n
            let r := mod(a, n)
            for { let y := 1 } 1 {} {
                let q := div(g, r)
                let t := g
                g := r
                r := sub(t, mul(r, q))
                let u := x
                x := y
                y := sub(u, mul(y, q))
                if iszero(r) { break }
            }
            x := mul(eq(g, 1), add(x, mul(slt(x, 0), n)))
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
    function ternary(bool condition, uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), iszero(condition)))
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
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // Makeshift lookup table to nudge the approximate log2 result.
            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))
            // Newton-Raphson's.
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            // Round down.
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
            z := sub(z, gt(999999999999999999, sub(mulmod(z, z, x), 1))) // Round down.
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`, rounded down.
    /// Formally verified by xuwinnie:
    /// https://github.com/vectorized/solady/blob/main/audits/xuwinnie-solady-cbrt-proof.pdf
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            if (x <= type(uint256).max / 10 ** 36) return cbrt(x * 10 ** 36);
            z = (1 + cbrt(x)) * 10 ** 12;
            z = (fullMulDivUnchecked(x, 10 ** 36, z * z) + z + z) / 3;
        }
        /// @solidity memory-safe-assembly
        assembly {
            let p := x
            for {} 1 {} {
                if iszero(shr(229, p)) {
                    if iszero(shr(199, p)) {
                        p := mul(p, 100000000000000000) // 10 ** 17.
                        break
                    }
                    p := mul(p, 100000000) // 10 ** 8.
                    break
                }
                if iszero(shr(249, p)) { p := mul(p, 100) }
                break
            }
            let t := mulmod(mul(z, z), z, p)
            z := sub(z, gt(lt(t, shr(1, p)), iszero(t))) // Round down.
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := 1
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for {} x { x := sub(x, 1) } { z := mul(z, x) }
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
        unchecked {
            z = (uint256(x) + uint256(x >> 255)) ^ uint256(x >> 255);
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(xor(sub(0, gt(x, y)), sub(y, x)), gt(x, y))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(xor(sub(0, sgt(x, y)), sub(y, x)), sgt(x, y))
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
        if (begin > end) (t, begin, end) = (~t, ~begin, ~end);
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
        if (begin > end) (t, begin, end) = (~t, ~begin, ~end);
        if (t <= begin) return a;
        if (t >= end) return b;
        // forgefmt: disable-next-item
        unchecked {
            if (b >= a) return int256(uint256(a) + fullMulDiv(uint256(b - a),
                uint256(t - begin), uint256(end - begin)));
            return int256(uint256(a) - fullMulDiv(uint256(a - b),
                uint256(t - begin), uint256(end - begin)));
        }
    }

    /// @dev Returns if `x` is an even number. Some people may need this.
    function isEven(uint256 x) internal pure returns (bool) {
        return x & uint256(1) == uint256(0);
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

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
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

    /// @dev The ERC20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

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
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                success := lt(or(iszero(extcodesize(token)), returndatasize()), success)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
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
            let success := call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
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
            let success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
            if iszero(and(eq(mload(0x00), 1), success)) {
                if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                    mstore(0x34, 0) // Store 0 for the `amount`.
                    mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                    pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                    mstore(0x34, amount) // Store back the original `amount`.
                    // Retry the approval, reverting upon failure.
                    success := call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    if iszero(and(eq(mload(0x00), 1), success)) {
                        // Check the `extcodesize` again just in case the token selfdestructs lol.
                        if iszero(lt(or(iszero(extcodesize(token)), returndatasize()), success)) {
                            mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                            revert(0x1c, 0x04)
                        }
                    }
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
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Returns the total supply of the `token`.
    /// Reverts if the token does not exist or does not implement `totalSupply()`.
    function totalSupply(address token) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x18160ddd) // `totalSupply()`.
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))
            ) {
                mstore(0x00, 0x54cd9435) // `TotalSupplyQueryFailed()`.
                revert(0x1c, 0x04)
            }
            result := mload(0x00)
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(
                and(
                    call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00),
                    lt(iszero(extcodesize(token)), exists) // Token has code and Permit2 exists.
                )
            ) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(add(m, 0x94), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `1` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero( // Revert if token does not have code, or if the call fails.
            mul(extcodesize(token), call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00))) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from "@openzeppelin-contracts-5/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin-contracts-5/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin-contracts-5/utils/ReentrancyGuard.sol";
import { ERC165 } from "@openzeppelin-contracts-5/utils/introspection/ERC165.sol";
import { IERC165, IOwnershipCallback } from "@smardex-usdn-contracts/interfaces/UsdnProtocol/IOwnershipCallback.sol";
import { IUsdnProtocol } from "@smardex-usdn-contracts/interfaces/UsdnProtocol/IUsdnProtocol.sol";
import { IUsdnProtocolTypes } from "@smardex-usdn-contracts/interfaces/UsdnProtocol/IUsdnProtocolTypes.sol";
import { FixedPointMathLib } from "solady-0.0.281/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady-0.0.281/utils/SafeTransferLib.sol";

import { IFarmingRange } from "./interfaces/IFarmingRange.sol";
import { IUsdnLongFarming } from "./interfaces/IUsdnLongFarming.sol";

/**
 * @title USDN Long Positions Farming
 * @notice A contract for farming USDN long positions to earn rewards.
 */
contract UsdnLongFarming is ERC165, ReentrancyGuard, IUsdnLongFarming, Ownable2Step {
    using SafeTransferLib for address;

    /**
     * @dev Scaling factor for {_accRewardPerShare}.
     * In the worst case of having 1 wei of reward tokens per block for a duration of 1 block, and with a total number
     * of shares equivalent to 500 million wstETH, the accumulator value increment would still be 2e11 which is
     * precise enough.
     */
    uint256 public constant SCALING_FACTOR = 1e38;

    /// @notice Denominator for the rewards multiplier, will give a 0.01% basis point.
    uint256 public constant BPS_DIVISOR = 10_000;

    /// @notice The address of the USDN protocol contract.
    IUsdnProtocol public immutable USDN_PROTOCOL;

    /// @notice The address of the SmarDex rewards provider contract, which is the source of the reward tokens.
    IFarmingRange public immutable REWARDS_PROVIDER;

    /// @notice The ID of the campaign in the SmarDex rewards provider contract which provides reward tokens to this
    /// contract.
    uint256 public immutable CAMPAIGN_ID;

    /// @notice The address of the reward token.
    IERC20 public immutable REWARD_TOKEN;

    /// @dev The position information for each locked position, identified by the hash of its `PositionId`.
    mapping(bytes32 => PositionInfo) internal _positions;

    /// @dev The total number of locked positions.
    uint256 internal _positionsCount;

    /// @dev The sum of all locked positions' initial trading exposure.
    uint256 internal _totalShares;

    /**
     * @dev Accumulated reward tokens per share multiplied by {SCALING_FACTOR}.
     * The factor is necessary to represent rewards per shares with enough precision for very small reward quantities
     * and large total number of shares.
     * In the worst case of having a very large number of reward tokens per block (1000e18) and a very small total
     * number of shares (1 wei), this number would not overflow for 1.158e18 blocks which is ~440 billion years.
     */
    uint256 internal _accRewardPerShare;

    /// @dev Block number when the last rewards were calculated.
    uint256 internal _lastRewardBlock;

    /// @dev Ratio of the rewards to be distributed to the notifier in basis points: default is 30%.
    uint16 internal _notifierRewardsBps = 3000;

    /**
     * @param usdnProtocol The address of the USDN protocol contract.
     * @param rewardsProvider The address of the SmarDex rewards provider contract.
     * @param campaignId The campaign ID in the SmarDex rewards provider contract which provides reward tokens to this
     * contract.
     */
    constructor(IUsdnProtocol usdnProtocol, IFarmingRange rewardsProvider, uint256 campaignId) Ownable(msg.sender) {
        USDN_PROTOCOL = usdnProtocol;
        REWARDS_PROVIDER = rewardsProvider;
        CAMPAIGN_ID = campaignId;
        IFarmingRange.CampaignInfo memory info = rewardsProvider.campaignInfo(campaignId);
        REWARD_TOKEN = IERC20(address(info.rewardToken));
        IERC20 farmingToken = IERC20(address(info.stakingToken));
        // this contract is the sole depositor of the farming token in the SmarDex rewards provider contract,
        // and will receive all of the rewards
        address(farmingToken).safeTransferFrom(msg.sender, address(this), 1);
        farmingToken.approve(address(rewardsProvider), 1);
        rewardsProvider.deposit(campaignId, 1);
    }

    /// @inheritdoc IUsdnLongFarming
    function setNotifierRewardsBps(uint16 notifierRewardsBps) external onlyOwner {
        if (notifierRewardsBps > BPS_DIVISOR) {
            revert UsdnLongFarmingInvalidNotifierRewardsBps();
        }
        _notifierRewardsBps = notifierRewardsBps;
        emit NotifierRewardsBpsUpdated(notifierRewardsBps);
    }

    /// @inheritdoc IUsdnLongFarming
    function getPositionInfo(int24 tick, uint256 tickVersion, uint256 index)
        external
        view
        returns (PositionInfo memory info_)
    {
        bytes32 positionIdHash = _hashPositionId(tick, tickVersion, index);
        return _positions[positionIdHash];
    }

    /// @inheritdoc IUsdnLongFarming
    function getPositionsCount() external view returns (uint256 count_) {
        return _positionsCount;
    }

    /// @inheritdoc IUsdnLongFarming
    function getTotalShares() external view returns (uint256 shares_) {
        return _totalShares;
    }

    /// @inheritdoc IUsdnLongFarming
    function getAccRewardPerShare() external view returns (uint256 accRewardPerShare_) {
        return _accRewardPerShare;
    }

    /// @inheritdoc IUsdnLongFarming
    function getLastRewardBlock() external view returns (uint256 block_) {
        return _lastRewardBlock;
    }

    /// @inheritdoc IUsdnLongFarming
    function pendingRewards(int24 tick, uint256 tickVersion, uint256 index) external view returns (uint256 rewards_) {
        if (_totalShares == 0) {
            return 0;
        }

        uint256 periodRewards = REWARDS_PROVIDER.pendingReward(CAMPAIGN_ID, address(this));
        uint256 newAccRewardPerShare = _calcAccRewardPerShare(periodRewards);
        bytes32 positionIdHash = _hashPositionId(tick, tickVersion, index);
        (rewards_,) = _calcRewards(_positions[positionIdHash], newAccRewardPerShare);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IOwnershipCallback).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IUsdnLongFarming
    function getNotifierRewardsBps() external view returns (uint16 notifierRewardsBps_) {
        return _notifierRewardsBps;
    }

    /// @inheritdoc IOwnershipCallback
    function ownershipCallback(address oldOwner, IUsdnProtocolTypes.PositionId calldata posId) external nonReentrant {
        if (msg.sender != address(USDN_PROTOCOL)) {
            revert UsdnLongFarmingInvalidCallbackCaller();
        }

        (IUsdnProtocolTypes.Position memory pos,) =
            USDN_PROTOCOL.getLongPosition(IUsdnProtocolTypes.PositionId(posId.tick, posId.tickVersion, posId.index));

        if (!pos.validated) {
            revert UsdnLongFarmingPendingPosition();
        }
        _registerDeposit(oldOwner, pos, posId.tick, posId.tickVersion, posId.index);
    }

    /// @inheritdoc IUsdnLongFarming
    function harvest(int24 tick, uint256 tickVersion, uint256 index)
        external
        nonReentrant
        returns (bool isLiquidated_, uint256 rewards_)
    {
        bytes32 positionIdHash = _hashPositionId(tick, tickVersion, index);

        (bool isLiquidated, uint256 rewards, uint256 newRewardDebt, address owner) = _harvest(positionIdHash);

        if (isLiquidated) {
            _slash(positionIdHash, owner, rewards, msg.sender, tick, tickVersion, index);
            return (true, 0);
        } else if (rewards > 0) {
            _positions[positionIdHash].rewardDebt = newRewardDebt;
            _sendRewards(owner, rewards, tick, tickVersion, index);
            return (false, rewards);
        }
    }

    /// @inheritdoc IUsdnLongFarming
    function withdraw(int24 tick, uint256 tickVersion, uint256 index)
        external
        nonReentrant
        returns (bool isLiquidated_, uint256 rewards_)
    {
        bytes32 positionIdHash = _hashPositionId(tick, tickVersion, index);

        address owner;
        (isLiquidated_, rewards_,, owner) = _harvest(positionIdHash);

        if (isLiquidated_) {
            _slash(positionIdHash, owner, rewards_, msg.sender, tick, tickVersion, index);
            return (true, 0);
        }
        if (msg.sender != owner) {
            revert UsdnLongFarmingNotPositionOwner();
        }

        _deletePosition(positionIdHash);

        if (rewards_ > 0) {
            _sendRewards(owner, rewards_, tick, tickVersion, index);
        }

        emit Withdraw(owner, tick, tickVersion, index);
        USDN_PROTOCOL.transferPositionOwnership(IUsdnProtocolTypes.PositionId(tick, tickVersion, index), owner, "");
    }

    /**
     * @notice Hashes a USDN long position's ID to use as key in the {_positions} mapping.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position inside the tick.
     * @return hash_ The hash of the position ID.
     */
    function _hashPositionId(int24 tick, uint256 tickVersion, uint256 index) internal pure returns (bytes32 hash_) {
        hash_ = keccak256(abi.encode(tick, tickVersion, index));
    }

    /**
     * @notice Records the information for a new position deposit.
     * @dev Uses the initial position trading expo as shares.
     * @param owner The prior USDN protocol position owner.
     * @param position The USDN protocol position to deposit.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position inside the tick.
     */
    function _registerDeposit(
        address owner,
        IUsdnProtocolTypes.Position memory position,
        int24 tick,
        uint256 tickVersion,
        uint256 index
    ) internal {
        _updateRewards();
        uint128 initialTradingExpo = position.totalExpo - position.amount;
        PositionInfo memory posInfo = PositionInfo({
            owner: owner,
            tick: tick,
            tickVersion: tickVersion,
            index: index,
            rewardDebt: FixedPointMathLib.fullMulDiv(initialTradingExpo, _accRewardPerShare, SCALING_FACTOR),
            shares: initialTradingExpo
        });

        _totalShares += posInfo.shares;
        _positionsCount++;
        bytes32 positionIdHash = _hashPositionId(tick, tickVersion, index);
        _positions[positionIdHash] = posInfo;

        emit Deposit(posInfo.owner, tick, tickVersion, index);
    }

    /**
     * @notice Updates {_lastRewardBlock}, harvests pending rewards from the SmarDex rewards provider contract, and
     * updates {_accRewardPerShare}.
     * @dev If no deposited position exists, {_lastRewardBlock} will be updated, but rewards will not be harvested.
     */
    function _updateRewards() internal {
        if (_lastRewardBlock == block.number) {
            return;
        }

        _lastRewardBlock = block.number;

        if (_totalShares == 0) {
            return;
        }

        uint256 rewardsBalanceBefore = REWARD_TOKEN.balanceOf(address(this));

        // farming harvest
        uint256[] memory campaignsIds = new uint256[](1);
        campaignsIds[0] = CAMPAIGN_ID;
        // slither-disable-next-line reentrancy-no-eth
        REWARDS_PROVIDER.harvest(campaignsIds);

        uint256 periodRewards = REWARD_TOKEN.balanceOf(address(this)) - rewardsBalanceBefore;

        if (periodRewards > 0) {
            _accRewardPerShare = _calcAccRewardPerShare(periodRewards);
        }
    }

    /**
     * @notice Verifies if the position has been liquidated in the USDN protocol and calculates the rewards to be
     * distributed.
     * @param positionIdHash The hash of the position ID.
     * @return isLiquidated_ Whether the position has been liquidated.
     * @return rewards_ The rewards amount to be distributed.
     * @return newRewardDebt_ The new reward debt for the position.
     * @return owner_ The owner of the position.
     */
    function _harvest(bytes32 positionIdHash)
        internal
        returns (bool isLiquidated_, uint256 rewards_, uint256 newRewardDebt_, address owner_)
    {
        _updateRewards();
        PositionInfo memory posInfo = _positions[positionIdHash];
        if (posInfo.owner == address(0)) {
            revert UsdnLongFarmingInvalidPosition();
        }

        owner_ = posInfo.owner;
        (rewards_, newRewardDebt_) = _calcRewards(posInfo, _accRewardPerShare);
        isLiquidated_ = _isLiquidated(posInfo.tick, posInfo.tickVersion);
    }

    /**
     * @notice Calculates the rewards to be distributed to a position.
     * @param posInfo The position information.
     * @param accRewardPerShare The rewards per share accumulator.
     * @return rewards_ The rewards to be distributed.
     * @return newRewardDebt_ The new reward debt for the position.
     */
    function _calcRewards(PositionInfo memory posInfo, uint256 accRewardPerShare)
        internal
        pure
        returns (uint256 rewards_, uint256 newRewardDebt_)
    {
        newRewardDebt_ = FixedPointMathLib.fullMulDiv(posInfo.shares, accRewardPerShare, SCALING_FACTOR);
        rewards_ = newRewardDebt_ - posInfo.rewardDebt;
    }

    /**
     * @notice Sends the rewards to the `to` address and emits a {Harvest} event.
     * @param to The address to send the rewards to.
     * @param amount The amount of rewards to send.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position inside the tick.
     */
    function _sendRewards(address to, uint256 amount, int24 tick, uint256 tickVersion, uint256 index) internal {
        address(REWARD_TOKEN).safeTransfer(to, amount);
        emit Harvest(to, amount, tick, tickVersion, index);
    }

    /**
     * @notice Checks if a position has been liquidated in the USDN protocol.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @return isLiquidated_ Whether the position has been liquidated.
     */
    function _isLiquidated(int24 tick, uint256 tickVersion) internal view returns (bool isLiquidated_) {
        uint256 protocolTickVersion = USDN_PROTOCOL.getTickVersion(tick);
        return protocolTickVersion != tickVersion;
    }

    /**
     * @notice Slashes a position and splits the rewards between the notifier and the owner.
     * @dev The notifier and the owner can be the same address, in which case a single transfer is performed and the
     * emitted event has a zero value for the notifier rewards.
     * @param positionIdHash The hash of the position ID.
     * @param owner The owner of the position.
     * @param rewards The rewards amount to be distributed.
     * @param notifier The address which has notified the farming platform about the liquidation in the USDN protocol.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position inside the tick.
     */
    function _slash(
        bytes32 positionIdHash,
        address owner,
        uint256 rewards,
        address notifier,
        int24 tick,
        uint256 tickVersion,
        uint256 index
    ) internal {
        _deletePosition(positionIdHash);

        if (rewards == 0) {
            emit Slash(notifier, 0, 0, tick, tickVersion, index);
        } else {
            if (owner == notifier) {
                address(REWARD_TOKEN).safeTransfer(owner, rewards);
                emit Slash(notifier, 0, rewards, tick, tickVersion, index);
            } else {
                uint256 notifierRewards = rewards * _notifierRewardsBps / BPS_DIVISOR;
                uint256 ownerRewards = rewards - notifierRewards;
                address(REWARD_TOKEN).safeTransfer(owner, ownerRewards);
                address(REWARD_TOKEN).safeTransfer(notifier, notifierRewards);
                emit Slash(notifier, notifierRewards, ownerRewards, tick, tickVersion, index);
            }
        }
    }

    /**
     * @notice Calculates and returns the updated accumulated reward per share.
     * @param periodRewards The amount of rewards for the elapsed period.
     * @return accRewardPerShare_ The updated accumulated reward per share.
     */
    function _calcAccRewardPerShare(uint256 periodRewards) internal view returns (uint256 accRewardPerShare_) {
        return _accRewardPerShare + FixedPointMathLib.fullMulDiv(periodRewards, SCALING_FACTOR, _totalShares);
    }

    /**
     * @notice Deletes a position from the internal state, updates the total shares and positions count.
     * @param positionIdHash The hash of the position ID.
     */
    function _deletePosition(bytes32 positionIdHash) internal {
        _totalShares -= _positions[positionIdHash].shares;
        _positionsCount--;
        delete _positions[positionIdHash];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC20 } from "@openzeppelin-contracts-5/interfaces/IERC20.sol";

interface IFarmingRange {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct CampaignInfo {
        IERC20 stakingToken;
        IERC20 rewardToken;
        uint256 startBlock;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        uint256 totalStaked;
        uint256 totalRewards;
    }

    struct RewardInfo {
        uint256 endBlock;
        uint256 rewardPerBlock;
    }

    function addCampaignInfo(IERC20 _stakingToken, IERC20 _rewardToken, uint256 _startBlock) external;

    function addRewardInfo(uint256 _campaignID, uint256 _endBlock, uint256 _rewardPerBlock) external;

    function rewardInfoLen(uint256 campaignID) external view returns (uint256);

    function campaignInfoLen() external view returns (uint256);

    function currentEndBlock(uint256 campaignID) external view returns (uint256);

    function currentRewardPerBlock(uint256 campaignID) external view returns (uint256);

    function getMultiplier(uint256 from, uint256 to, uint256 endBlock) external returns (uint256);

    function pendingReward(uint256 campaignID, address user) external view returns (uint256);

    function updateCampaign(uint256 campaignID) external;

    function massUpdateCampaigns() external;

    function deposit(uint256 campaignID, uint256 amount) external;

    function depositWithPermit(
        uint256 campaignID,
        uint256 amount,
        bool approveMax,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function withdraw(uint256 campaignID, uint256 amount) external;

    function harvest(uint256[] calldata campaignIDs) external;

    function emergencyWithdraw(uint256 campaignID) external;

    function campaignRewardInfo(uint256 campaignID, uint256 rewardIndex)
        external
        view
        returns (uint256 endBlock, uint256 rewardPerBlock);

    function campaignInfo(uint256 campaignID) external view returns (CampaignInfo memory info_);

    function userInfo(uint256 campaignID, address user) external view returns (UserInfo memory info_);

    function rewardInfoLimit() external view returns (uint256);

    function rewardManager() external view returns (address);

    function owner() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IERC165, IOwnershipCallback } from "@smardex-usdn-contracts/interfaces/UsdnProtocol/IOwnershipCallback.sol";

import { IUsdnLongFarmingErrors } from "./IUsdnLongFarmingErrors.sol";
import { IUsdnLongFarmingEvents } from "./IUsdnLongFarmingEvents.sol";
import { IUsdnLongFarmingTypes } from "./IUsdnLongFarmingTypes.sol";

/**
 * @title USDN Long Farming Interface
 * @notice Interface for the USDN Long Farming contract.
 */
interface IUsdnLongFarming is
    IUsdnLongFarmingTypes,
    IUsdnLongFarmingErrors,
    IUsdnLongFarmingEvents,
    IERC165,
    IOwnershipCallback
{
    /**
     * @notice Sets the rewards factor for notifiers.
     * @param notifierRewardsBps The notifier rewards factor value, in basis points.
     */
    function setNotifierRewardsBps(uint16 notifierRewardsBps) external;

    /**
     * @notice Retrieves the information of a deposited USDN protocol position.
     * @param tick The tick of the position in the USDN protocol.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     * @return info_ The information of the specified position.
     */
    function getPositionInfo(int24 tick, uint256 tickVersion, uint256 index)
        external
        view
        returns (PositionInfo memory info_);

    /**
     * @notice Gets the total number of deposited positions.
     * @return count_ The total count of deposited positions.
     */
    function getPositionsCount() external view returns (uint256 count_);

    /**
     * @notice Gets the total shares of all deposited positions.
     * @dev Shares represent the trading exposure of deposited USDN positions.
     * @return shares_ The total shares of all positions.
     */
    function getTotalShares() external view returns (uint256 shares_);

    /**
     * @notice Gets the value of the rewards per share accumulator.
     * @dev This value represents the cumulative rewards per share, scaled for precision. It is updated before each user
     * action.
     * @return accRewardPerShare_ The value of the rewards per share accumulator.
     */
    function getAccRewardPerShare() external view returns (uint256 accRewardPerShare_);

    /**
     * @notice Gets the block number when the rewards accumulator was last updated.
     * @dev This value is updated before each user action.
     * @return block_ The block number of the last update.
     */
    function getLastRewardBlock() external view returns (uint256 block_);

    /**
     * @notice Gets the current notifier rewards factor, in basis points.
     * @return notifierRewardsBps_ The current notifier rewards factor value.
     */
    function getNotifierRewardsBps() external view returns (uint16 notifierRewardsBps_);

    /**
     * @notice Calculates the pending rewards for a specific position.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     * @return rewards_ The amount of pending rewards for the position.
     */
    function pendingRewards(int24 tick, uint256 tickVersion, uint256 index) external view returns (uint256 rewards_);

    /**
     * @notice Withdraws a USDN protocol position and claims its rewards.
     * @dev If the position is not liquidated, rewards are sent to the position's owner, and the position is withdrawn.
     * If liquidated, rewards are split between the `msg.sender` and the position's owner, and the position is deleted.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     * @return isLiquidated_ Indicates whether the position was liquidated.
     * @return rewards_ The amount of rewards sent to the position's owner. Returns 0 if liquidated.
     */
    function withdraw(int24 tick, uint256 tickVersion, uint256 index)
        external
        returns (bool isLiquidated_, uint256 rewards_);

    /**
     * @notice Claims rewards for a USDN protocol position and updates its status.
     * @dev If the position is not liquidated, rewards are sent to the owner, and `rewardDebt` is updated. If
     * liquidated, rewards are split between the `msg.sender` and the position's owner, and the position is deleted. This
     * function can notify the farming protocol of a liquidation and reward the notifier.
     * If there are no pending rewards, this function will not perform any actions. However, calling the function may
     * still incur a transaction fee.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     * @return isLiquidated_ Indicates whether the position was liquidated.
     * @return rewards_ The amount of rewards sent to the position's owner. Returns 0 if liquidated.
     */
    function harvest(int24 tick, uint256 tickVersion, uint256 index)
        external
        returns (bool isLiquidated_, uint256 rewards_);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title USDN Long Farming Errors
 * @dev Defines all custom events emitted by the USDN token contract.
 */
interface IUsdnLongFarmingErrors {
    /// @dev The USDN protocol position validation is pending.
    error UsdnLongFarmingPendingPosition();

    /// @dev The USDN protocol position does not exist.
    error UsdnLongFarmingInvalidPosition();

    /// @dev The specified `notifierRewardsBps` value is invalid.
    error UsdnLongFarmingInvalidNotifierRewardsBps();

    /// @dev The caller is not the owner of the USDN protocol position.
    error UsdnLongFarmingNotPositionOwner();

    /// @dev The caller of the callback function is not the USDN protocol.
    error UsdnLongFarmingInvalidCallbackCaller();
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title USDN Long Farming Events
 * @dev Defines all custom events emitted by the USDN Long Farming contract.
 */
interface IUsdnLongFarmingEvents {
    /**
     * @notice A USDN protocol user position has been deposited into the contract.
     * @param owner The owner of the deposited USDN protocol position.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     */
    event Deposit(address indexed owner, int24 tick, uint256 tickVersion, uint256 index);

    /**
     * @notice A USDN protocol user position has been withdrawn from the contract.
     * @param owner The address of the position owner.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     */
    event Withdraw(address indexed owner, int24 tick, uint256 tickVersion, uint256 index);

    /**
     * @notice The rewards have been sent to the owner of a position.
     * @param user The address of the position owner.
     * @param rewards The amount of rewards transferred.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     */
    event Harvest(address indexed user, uint256 rewards, int24 tick, uint256 tickVersion, uint256 index);

    /**
     * @notice A position has been deleted and the notifier has received part of the rewards.
     * @param notifier The address of the notifier.
     * @param notifierRewards The amount of rewards received by the notifier.
     * @param ownerRewards The amount of rewards received by the owner.
     * @param tick The tick of the position.
     * @param tickVersion The version of the tick.
     * @param index The index of the position within the tick.
     */
    event Slash(
        address indexed notifier,
        uint256 notifierRewards,
        uint256 ownerRewards,
        int24 tick,
        uint256 tickVersion,
        uint256 index
    );

    /**
     * @notice The notifier rewards factor has been updated.
     * @param newNotifierRewardsBps The new notifier rewards factor value, in basis points.
     */
    event NotifierRewardsBpsUpdated(uint16 newNotifierRewardsBps);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title USDN Long Farming Types
 * @dev Defines all custom types used by the USDN Long Farming contract.
 */
interface IUsdnLongFarmingTypes {
    /**
     * @notice Contains all information of a staked position.
     * @dev The `PositionId` is unpacked into its components to optimize storage layout.
     * @param owner The address of the position owner.
     * @param tick The tick of the position in the USDN protocol.
     * @param tickVersion The version of the tick.
     * @param index The position's index within the specified tick.
     * @param rewardDebt The cumulative rewards debt of the position.
     * Rewards entitled to a staked position at any point in time can be calculated as:
     * `pendingRewards = (pos.shares * _accRewardPerShare) - pos.rewardDebt`.
     * @param shares The initial trading exposure of the position, representing its share in the farming.
     */
    struct PositionInfo {
        address owner;
        int24 tick;
        uint256 tickVersion;
        uint256 index;
        uint256 rewardDebt;
        uint128 shares;
    }
}