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
// OpenZeppelin Contracts (last updated v5.1.0) (access/manager/AccessManaged.sol)

pragma solidity ^0.8.20;

import {IAuthority} from "./IAuthority.sol";
import {AuthorityUtils} from "./AuthorityUtils.sol";
import {IAccessManager} from "./IAccessManager.sol";
import {IAccessManaged} from "./IAccessManaged.sol";
import {Context} from "../../utils/Context.sol";

/**
 * @dev This contract module makes available a {restricted} modifier. Functions decorated with this modifier will be
 * permissioned according to an "authority": a contract like {AccessManager} that follows the {IAuthority} interface,
 * implementing a policy that allows certain callers to access certain functions.
 *
 * IMPORTANT: The `restricted` modifier should never be used on `internal` functions, judiciously used in `public`
 * functions, and ideally only used in `external` functions. See {restricted}.
 */
abstract contract AccessManaged is Context, IAccessManaged {
    address private _authority;

    bool private _consumingSchedule;

    /**
     * @dev Initializes the contract connected to an initial authority.
     */
    constructor(address initialAuthority) {
        _setAuthority(initialAuthority);
    }

    /**
     * @dev Restricts access to a function as defined by the connected Authority for this contract and the
     * caller and selector of the function that entered the contract.
     *
     * [IMPORTANT]
     * ====
     * In general, this modifier should only be used on `external` functions. It is okay to use it on `public`
     * functions that are used as external entry points and are not called internally. Unless you know what you're
     * doing, it should never be used on `internal` functions. Failure to follow these rules can have critical security
     * implications! This is because the permissions are determined by the function that entered the contract, i.e. the
     * function at the bottom of the call stack, and not the function where the modifier is visible in the source code.
     * ====
     *
     * [WARNING]
     * ====
     * Avoid adding this modifier to the https://docs.soliditylang.org/en/v0.8.20/contracts.html#receive-ether-function[`receive()`]
     * function or the https://docs.soliditylang.org/en/v0.8.20/contracts.html#fallback-function[`fallback()`]. These
     * functions are the only execution paths where a function selector cannot be unambiguously determined from the calldata
     * since the selector defaults to `0x00000000` in the `receive()` function and similarly in the `fallback()` function
     * if no calldata is provided. (See {_checkCanCall}).
     *
     * The `receive()` function will always panic whereas the `fallback()` may panic depending on the calldata length.
     * ====
     */
    modifier restricted() {
        _checkCanCall(_msgSender(), _msgData());
        _;
    }

    /// @inheritdoc IAccessManaged
    function authority() public view virtual returns (address) {
        return _authority;
    }

    /// @inheritdoc IAccessManaged
    function setAuthority(address newAuthority) public virtual {
        address caller = _msgSender();
        if (caller != authority()) {
            revert AccessManagedUnauthorized(caller);
        }
        if (newAuthority.code.length == 0) {
            revert AccessManagedInvalidAuthority(newAuthority);
        }
        _setAuthority(newAuthority);
    }

    /// @inheritdoc IAccessManaged
    function isConsumingScheduledOp() public view returns (bytes4) {
        return _consumingSchedule ? this.isConsumingScheduledOp.selector : bytes4(0);
    }

    /**
     * @dev Transfers control to a new authority. Internal function with no access restriction. Allows bypassing the
     * permissions set by the current authority.
     */
    function _setAuthority(address newAuthority) internal virtual {
        _authority = newAuthority;
        emit AuthorityUpdated(newAuthority);
    }

    /**
     * @dev Reverts if the caller is not allowed to call the function identified by a selector. Panics if the calldata
     * is less than 4 bytes long.
     */
    function _checkCanCall(address caller, bytes calldata data) internal virtual {
        (bool immediate, uint32 delay) = AuthorityUtils.canCallWithDelay(
            authority(),
            caller,
            address(this),
            bytes4(data[0:4])
        );
        if (!immediate) {
            if (delay > 0) {
                _consumingSchedule = true;
                IAccessManager(authority()).consumeScheduledOp(caller, data);
                _consumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (access/manager/AccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManager} from "./IAccessManager.sol";
import {IAccessManaged} from "./IAccessManaged.sol";
import {Address} from "../../utils/Address.sol";
import {Context} from "../../utils/Context.sol";
import {Multicall} from "../../utils/Multicall.sol";
import {Math} from "../../utils/math/Math.sol";
import {Time} from "../../utils/types/Time.sol";

/**
 * @dev AccessManager is a central contract to store the permissions of a system.
 *
 * A smart contract under the control of an AccessManager instance is known as a target, and will inherit from the
 * {AccessManaged} contract, be connected to this contract as its manager and implement the {AccessManaged-restricted}
 * modifier on a set of functions selected to be permissioned. Note that any function without this setup won't be
 * effectively restricted.
 *
 * The restriction rules for such functions are defined in terms of "roles" identified by an `uint64` and scoped
 * by target (`address`) and function selectors (`bytes4`). These roles are stored in this contract and can be
 * configured by admins (`ADMIN_ROLE` members) after a delay (see {getTargetAdminDelay}).
 *
 * For each target contract, admins can configure the following without any delay:
 *
 * * The target's {AccessManaged-authority} via {updateAuthority}.
 * * Close or open a target via {setTargetClosed} keeping the permissions intact.
 * * The roles that are allowed (or disallowed) to call a given function (identified by its selector) through {setTargetFunctionRole}.
 *
 * By default every address is member of the `PUBLIC_ROLE` and every target function is restricted to the `ADMIN_ROLE` until configured otherwise.
 * Additionally, each role has the following configuration options restricted to this manager's admins:
 *
 * * A role's admin role via {setRoleAdmin} who can grant or revoke roles.
 * * A role's guardian role via {setRoleGuardian} who's allowed to cancel operations.
 * * A delay in which a role takes effect after being granted through {setGrantDelay}.
 * * A delay of any target's admin action via {setTargetAdminDelay}.
 * * A role label for discoverability purposes with {labelRole}.
 *
 * Any account can be added and removed into any number of these roles by using the {grantRole} and {revokeRole} functions
 * restricted to each role's admin (see {getRoleAdmin}).
 *
 * Since all the permissions of the managed system can be modified by the admins of this instance, it is expected that
 * they will be highly secured (e.g., a multisig or a well-configured DAO).
 *
 * NOTE: This contract implements a form of the {IAuthority} interface, but {canCall} has additional return data so it
 * doesn't inherit `IAuthority`. It is however compatible with the `IAuthority` interface since the first 32 bytes of
 * the return data are a boolean as expected by that interface.
 *
 * NOTE: Systems that implement other access control mechanisms (for example using {Ownable}) can be paired with an
 * {AccessManager} by transferring permissions (ownership in the case of {Ownable}) directly to the {AccessManager}.
 * Users will be able to interact with these contracts through the {execute} function, following the access rules
 * registered in the {AccessManager}. Keep in mind that in that context, the msg.sender seen by restricted functions
 * will be {AccessManager} itself.
 *
 * WARNING: When granting permissions over an {Ownable} or {AccessControl} contract to an {AccessManager}, be very
 * mindful of the danger associated with functions such as {Ownable-renounceOwnership} or
 * {AccessControl-renounceRole}.
 */
contract AccessManager is Context, Multicall, IAccessManager {
    using Time for *;

    // Structure that stores the details for a target contract.
    struct TargetConfig {
        mapping(bytes4 selector => uint64 roleId) allowedRoles;
        Time.Delay adminDelay;
        bool closed;
    }

    // Structure that stores the details for a role/account pair. This structures fit into a single slot.
    struct Access {
        // Timepoint at which the user gets the permission.
        // If this is either 0 or in the future, then the role permission is not available.
        uint48 since;
        // Delay for execution. Only applies to restricted() / execute() calls.
        Time.Delay delay;
    }

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => Access access) members;
        // Admin who can grant or revoke permissions.
        uint64 admin;
        // Guardian who can cancel operations targeting functions that need this role.
        uint64 guardian;
        // Delay in which the role takes effect after being granted.
        Time.Delay grantDelay;
    }

    // Structure that stores the details for a scheduled operation. This structure fits into a single slot.
    struct Schedule {
        // Moment at which the operation can be executed.
        uint48 timepoint;
        // Operation nonce to allow third-party contracts to identify the operation.
        uint32 nonce;
    }

    /**
     * @dev The identifier of the admin role. Required to perform most configuration operations including
     * other roles' management and target restrictions.
     */
    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0

    /**
     * @dev The identifier of the public role. Automatically granted to all addresses with no delay.
     */
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    mapping(address target => TargetConfig mode) private _targets;
    mapping(uint64 roleId => Role) private _roles;
    mapping(bytes32 operationId => Schedule) private _schedules;

    // Used to identify operations that are currently being executed via {execute}.
    // This should be transient storage when supported by the EVM.
    bytes32 private _executionId;

    /**
     * @dev Check that the caller is authorized to perform the operation.
     * See {AccessManager} description for a detailed breakdown of the authorization logic.
     */
    modifier onlyAuthorized() {
        _checkAuthorized();
        _;
    }

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) {
            revert AccessManagerInvalidInitialAdmin(address(0));
        }

        // admin is active immediately and without any execution delay.
        _grantRole(ADMIN_ROLE, initialAdmin, 0, 0);
    }

    // =================================================== GETTERS ====================================================
    /// @inheritdoc IAccessManager
    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) public view virtual returns (bool immediate, uint32 delay) {
        if (isTargetClosed(target)) {
            return (false, 0);
        } else if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(target, selector), 0);
        } else {
            uint64 roleId = getTargetFunctionRole(target, selector);
            (bool isMember, uint32 currentDelay) = hasRole(roleId, caller);
            return isMember ? (currentDelay == 0, currentDelay) : (false, 0);
        }
    }

    /// @inheritdoc IAccessManager
    function expiration() public view virtual returns (uint32) {
        return 1 weeks;
    }

    /// @inheritdoc IAccessManager
    function minSetback() public view virtual returns (uint32) {
        return 5 days;
    }

    /// @inheritdoc IAccessManager
    function isTargetClosed(address target) public view virtual returns (bool) {
        return _targets[target].closed;
    }

    /// @inheritdoc IAccessManager
    function getTargetFunctionRole(address target, bytes4 selector) public view virtual returns (uint64) {
        return _targets[target].allowedRoles[selector];
    }

    /// @inheritdoc IAccessManager
    function getTargetAdminDelay(address target) public view virtual returns (uint32) {
        return _targets[target].adminDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getRoleAdmin(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].admin;
    }

    /// @inheritdoc IAccessManager
    function getRoleGuardian(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].guardian;
    }

    /// @inheritdoc IAccessManager
    function getRoleGrantDelay(uint64 roleId) public view virtual returns (uint32) {
        return _roles[roleId].grantDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getAccess(
        uint64 roleId,
        address account
    ) public view virtual returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) {
        Access storage access = _roles[roleId].members[account];

        since = access.since;
        (currentDelay, pendingDelay, effect) = access.delay.getFull();

        return (since, currentDelay, pendingDelay, effect);
    }

    /// @inheritdoc IAccessManager
    function hasRole(
        uint64 roleId,
        address account
    ) public view virtual returns (bool isMember, uint32 executionDelay) {
        if (roleId == PUBLIC_ROLE) {
            return (true, 0);
        } else {
            (uint48 hasRoleSince, uint32 currentDelay, , ) = getAccess(roleId, account);
            return (hasRoleSince != 0 && hasRoleSince <= Time.timestamp(), currentDelay);
        }
    }

    // =============================================== ROLE MANAGEMENT ===============================================
    /// @inheritdoc IAccessManager
    function labelRole(uint64 roleId, string calldata label) public virtual onlyAuthorized {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }
        emit RoleLabel(roleId, label);
    }

    /// @inheritdoc IAccessManager
    function grantRole(uint64 roleId, address account, uint32 executionDelay) public virtual onlyAuthorized {
        _grantRole(roleId, account, getRoleGrantDelay(roleId), executionDelay);
    }

    /// @inheritdoc IAccessManager
    function revokeRole(uint64 roleId, address account) public virtual onlyAuthorized {
        _revokeRole(roleId, account);
    }

    /// @inheritdoc IAccessManager
    function renounceRole(uint64 roleId, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessManagerBadConfirmation();
        }
        _revokeRole(roleId, callerConfirmation);
    }

    /// @inheritdoc IAccessManager
    function setRoleAdmin(uint64 roleId, uint64 admin) public virtual onlyAuthorized {
        _setRoleAdmin(roleId, admin);
    }

    /// @inheritdoc IAccessManager
    function setRoleGuardian(uint64 roleId, uint64 guardian) public virtual onlyAuthorized {
        _setRoleGuardian(roleId, guardian);
    }

    /// @inheritdoc IAccessManager
    function setGrantDelay(uint64 roleId, uint32 newDelay) public virtual onlyAuthorized {
        _setGrantDelay(roleId, newDelay);
    }

    /**
     * @dev Internal version of {grantRole} without access control. Returns true if the role was newly granted.
     *
     * Emits a {RoleGranted} event.
     */
    function _grantRole(
        uint64 roleId,
        address account,
        uint32 grantDelay,
        uint32 executionDelay
    ) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        bool newMember = _roles[roleId].members[account].since == 0;
        uint48 since;

        if (newMember) {
            since = Time.timestamp() + grantDelay;
            _roles[roleId].members[account] = Access({since: since, delay: executionDelay.toDelay()});
        } else {
            // No setback here. Value can be reset by doing revoke + grant, effectively allowing the admin to perform
            // any change to the execution delay within the duration of the role admin delay.
            (_roles[roleId].members[account].delay, since) = _roles[roleId].members[account].delay.withUpdate(
                executionDelay,
                0
            );
        }

        emit RoleGranted(roleId, account, executionDelay, since, newMember);
        return newMember;
    }

    /**
     * @dev Internal version of {revokeRole} without access control. This logic is also used by {renounceRole}.
     * Returns true if the role was previously granted.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function _revokeRole(uint64 roleId, address account) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        if (_roles[roleId].members[account].since == 0) {
            return false;
        }

        delete _roles[roleId].members[account];

        emit RoleRevoked(roleId, account);
        return true;
    }

    /**
     * @dev Internal version of {setRoleAdmin} without access control.
     *
     * Emits a {RoleAdminChanged} event.
     *
     * NOTE: Setting the admin role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to set grant or revoke such role.
     */
    function _setRoleAdmin(uint64 roleId, uint64 admin) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        _roles[roleId].admin = admin;

        emit RoleAdminChanged(roleId, admin);
    }

    /**
     * @dev Internal version of {setRoleGuardian} without access control.
     *
     * Emits a {RoleGuardianChanged} event.
     *
     * NOTE: Setting the guardian role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to cancel any scheduled operation for such role.
     */
    function _setRoleGuardian(uint64 roleId, uint64 guardian) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        _roles[roleId].guardian = guardian;

        emit RoleGuardianChanged(roleId, guardian);
    }

    /**
     * @dev Internal version of {setGrantDelay} without access control.
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function _setGrantDelay(uint64 roleId, uint32 newDelay) internal virtual {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        uint48 effect;
        (_roles[roleId].grantDelay, effect) = _roles[roleId].grantDelay.withUpdate(newDelay, minSetback());

        emit RoleGrantDelayChanged(roleId, newDelay, effect);
    }

    // ============================================= FUNCTION MANAGEMENT ==============================================
    /// @inheritdoc IAccessManager
    function setTargetFunctionRole(
        address target,
        bytes4[] calldata selectors,
        uint64 roleId
    ) public virtual onlyAuthorized {
        for (uint256 i = 0; i < selectors.length; ++i) {
            _setTargetFunctionRole(target, selectors[i], roleId);
        }
    }

    /**
     * @dev Internal version of {setTargetFunctionRole} without access control.
     *
     * Emits a {TargetFunctionRoleUpdated} event.
     */
    function _setTargetFunctionRole(address target, bytes4 selector, uint64 roleId) internal virtual {
        _targets[target].allowedRoles[selector] = roleId;
        emit TargetFunctionRoleUpdated(target, selector, roleId);
    }

    /// @inheritdoc IAccessManager
    function setTargetAdminDelay(address target, uint32 newDelay) public virtual onlyAuthorized {
        _setTargetAdminDelay(target, newDelay);
    }

    /**
     * @dev Internal version of {setTargetAdminDelay} without access control.
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function _setTargetAdminDelay(address target, uint32 newDelay) internal virtual {
        uint48 effect;
        (_targets[target].adminDelay, effect) = _targets[target].adminDelay.withUpdate(newDelay, minSetback());

        emit TargetAdminDelayUpdated(target, newDelay, effect);
    }

    // =============================================== MODE MANAGEMENT ================================================
    /// @inheritdoc IAccessManager
    function setTargetClosed(address target, bool closed) public virtual onlyAuthorized {
        _setTargetClosed(target, closed);
    }

    /**
     * @dev Set the closed flag for a contract. This is an internal setter with no access restrictions.
     *
     * Emits a {TargetClosed} event.
     */
    function _setTargetClosed(address target, bool closed) internal virtual {
        _targets[target].closed = closed;
        emit TargetClosed(target, closed);
    }

    // ============================================== DELAYED OPERATIONS ==============================================
    /// @inheritdoc IAccessManager
    function getSchedule(bytes32 id) public view virtual returns (uint48) {
        uint48 timepoint = _schedules[id].timepoint;
        return _isExpired(timepoint) ? 0 : timepoint;
    }

    /// @inheritdoc IAccessManager
    function getNonce(bytes32 id) public view virtual returns (uint32) {
        return _schedules[id].nonce;
    }

    /// @inheritdoc IAccessManager
    function schedule(
        address target,
        bytes calldata data,
        uint48 when
    ) public virtual returns (bytes32 operationId, uint32 nonce) {
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        (, uint32 setback) = _canCallExtended(caller, target, data);

        uint48 minWhen = Time.timestamp() + setback;

        // If call with delay is not authorized, or if requested timing is too soon, revert
        if (setback == 0 || (when > 0 && when < minWhen)) {
            revert AccessManagerUnauthorizedCall(caller, target, _checkSelector(data));
        }

        // Reuse variable due to stack too deep
        when = uint48(Math.max(when, minWhen)); // cast is safe: both inputs are uint48

        // If caller is authorised, schedule operation
        operationId = hashOperation(caller, target, data);

        _checkNotScheduled(operationId);

        unchecked {
            // It's not feasible to overflow the nonce in less than 1000 years
            nonce = _schedules[operationId].nonce + 1;
        }
        _schedules[operationId].timepoint = when;
        _schedules[operationId].nonce = nonce;
        emit OperationScheduled(operationId, nonce, when, caller, target, data);

        // Using named return values because otherwise we get stack too deep
    }

    /**
     * @dev Reverts if the operation is currently scheduled and has not expired.
     *
     * NOTE: This function was introduced due to stack too deep errors in schedule.
     */
    function _checkNotScheduled(bytes32 operationId) private view {
        uint48 prevTimepoint = _schedules[operationId].timepoint;
        if (prevTimepoint != 0 && !_isExpired(prevTimepoint)) {
            revert AccessManagerAlreadyScheduled(operationId);
        }
    }

    /// @inheritdoc IAccessManager
    // Reentrancy is not an issue because permissions are checked on msg.sender. Additionally,
    // _consumeScheduledOp guarantees a scheduled operation is only executed once.
    // slither-disable-next-line reentrancy-no-eth
    function execute(address target, bytes calldata data) public payable virtual returns (uint32) {
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        (bool immediate, uint32 setback) = _canCallExtended(caller, target, data);

        // If call is not authorized, revert
        if (!immediate && setback == 0) {
            revert AccessManagerUnauthorizedCall(caller, target, _checkSelector(data));
        }

        bytes32 operationId = hashOperation(caller, target, data);
        uint32 nonce;

        // If caller is authorised, check operation was scheduled early enough
        // Consume an available schedule even if there is no currently enforced delay
        if (setback != 0 || getSchedule(operationId) != 0) {
            nonce = _consumeScheduledOp(operationId);
        }

        // Mark the target and selector as authorised
        bytes32 executionIdBefore = _executionId;
        _executionId = _hashExecutionId(target, _checkSelector(data));

        // Perform call
        Address.functionCallWithValue(target, data, msg.value);

        // Reset execute identifier
        _executionId = executionIdBefore;

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function cancel(address caller, address target, bytes calldata data) public virtual returns (uint32) {
        address msgsender = _msgSender();
        bytes4 selector = _checkSelector(data);

        bytes32 operationId = hashOperation(caller, target, data);
        if (_schedules[operationId].timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (caller != msgsender) {
            // calls can only be canceled by the account that scheduled them, a global admin, or by a guardian of the required role.
            (bool isAdmin, ) = hasRole(ADMIN_ROLE, msgsender);
            (bool isGuardian, ) = hasRole(getRoleGuardian(getTargetFunctionRole(target, selector)), msgsender);
            if (!isAdmin && !isGuardian) {
                revert AccessManagerUnauthorizedCancel(msgsender, caller, target, selector);
            }
        }

        delete _schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        uint32 nonce = _schedules[operationId].nonce;
        emit OperationCanceled(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function consumeScheduledOp(address caller, bytes calldata data) public virtual {
        address target = _msgSender();
        if (IAccessManaged(target).isConsumingScheduledOp() != IAccessManaged.isConsumingScheduledOp.selector) {
            revert AccessManagerUnauthorizedConsume(target);
        }
        _consumeScheduledOp(hashOperation(caller, target, data));
    }

    /**
     * @dev Internal variant of {consumeScheduledOp} that operates on bytes32 operationId.
     *
     * Returns the nonce of the scheduled operation that is consumed.
     */
    function _consumeScheduledOp(bytes32 operationId) internal virtual returns (uint32) {
        uint48 timepoint = _schedules[operationId].timepoint;
        uint32 nonce = _schedules[operationId].nonce;

        if (timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (timepoint > Time.timestamp()) {
            revert AccessManagerNotReady(operationId);
        } else if (_isExpired(timepoint)) {
            revert AccessManagerExpired(operationId);
        }

        delete _schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        emit OperationExecuted(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function hashOperation(address caller, address target, bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(abi.encode(caller, target, data));
    }

    // ==================================================== OTHERS ====================================================
    /// @inheritdoc IAccessManager
    function updateAuthority(address target, address newAuthority) public virtual onlyAuthorized {
        IAccessManaged(target).setAuthority(newAuthority);
    }

    // ================================================= ADMIN LOGIC ==================================================
    /**
     * @dev Check if the current call is authorized according to admin and roles logic.
     *
     * WARNING: Carefully review the considerations of {AccessManaged-restricted} since they apply to this modifier.
     */
    function _checkAuthorized() private {
        address caller = _msgSender();
        (bool immediate, uint32 delay) = _canCallSelf(caller, _msgData());
        if (!immediate) {
            if (delay == 0) {
                (, uint64 requiredRole, ) = _getAdminRestrictions(_msgData());
                revert AccessManagerUnauthorizedAccount(caller, requiredRole);
            } else {
                _consumeScheduledOp(hashOperation(caller, address(this), _msgData()));
            }
        }
    }

    /**
     * @dev Get the admin restrictions of a given function call based on the function and arguments involved.
     *
     * Returns:
     * - bool restricted: does this data match a restricted operation
     * - uint64: which role is this operation restricted to
     * - uint32: minimum delay to enforce for that operation (max between operation's delay and admin's execution delay)
     */
    function _getAdminRestrictions(
        bytes calldata data
    ) private view returns (bool adminRestricted, uint64 roleAdminId, uint32 executionDelay) {
        if (data.length < 4) {
            return (false, 0, 0);
        }

        bytes4 selector = _checkSelector(data);

        // Restricted to ADMIN with no delay beside any execution delay the caller may have
        if (
            selector == this.labelRole.selector ||
            selector == this.setRoleAdmin.selector ||
            selector == this.setRoleGuardian.selector ||
            selector == this.setGrantDelay.selector ||
            selector == this.setTargetAdminDelay.selector
        ) {
            return (true, ADMIN_ROLE, 0);
        }

        // Restricted to ADMIN with the admin delay corresponding to the target
        if (
            selector == this.updateAuthority.selector ||
            selector == this.setTargetClosed.selector ||
            selector == this.setTargetFunctionRole.selector
        ) {
            // First argument is a target.
            address target = abi.decode(data[0x04:0x24], (address));
            uint32 delay = getTargetAdminDelay(target);
            return (true, ADMIN_ROLE, delay);
        }

        // Restricted to that role's admin with no delay beside any execution delay the caller may have.
        if (selector == this.grantRole.selector || selector == this.revokeRole.selector) {
            // First argument is a roleId.
            uint64 roleId = abi.decode(data[0x04:0x24], (uint64));
            return (true, getRoleAdmin(roleId), 0);
        }

        return (false, getTargetFunctionRole(address(this), selector), 0);
    }

    // =================================================== HELPERS ====================================================
    /**
     * @dev An extended version of {canCall} for internal usage that checks {_canCallSelf}
     * when the target is this contract.
     *
     * Returns:
     * - bool immediate: whether the operation can be executed immediately (with no delay)
     * - uint32 delay: the execution delay
     */
    function _canCallExtended(
        address caller,
        address target,
        bytes calldata data
    ) private view returns (bool immediate, uint32 delay) {
        if (target == address(this)) {
            return _canCallSelf(caller, data);
        } else {
            return data.length < 4 ? (false, 0) : canCall(caller, target, _checkSelector(data));
        }
    }

    /**
     * @dev A version of {canCall} that checks for restrictions in this contract.
     */
    function _canCallSelf(address caller, bytes calldata data) private view returns (bool immediate, uint32 delay) {
        if (data.length < 4) {
            return (false, 0);
        }

        if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(address(this), _checkSelector(data)), 0);
        }

        (bool adminRestricted, uint64 roleId, uint32 operationDelay) = _getAdminRestrictions(data);

        // isTargetClosed apply to non-admin-restricted function
        if (!adminRestricted && isTargetClosed(address(this))) {
            return (false, 0);
        }

        (bool inRole, uint32 executionDelay) = hasRole(roleId, caller);
        if (!inRole) {
            return (false, 0);
        }

        // downcast is safe because both options are uint32
        delay = uint32(Math.max(operationDelay, executionDelay));
        return (delay == 0, delay);
    }

    /**
     * @dev Returns true if a call with `target` and `selector` is being executed via {executed}.
     */
    function _isExecuting(address target, bytes4 selector) private view returns (bool) {
        return _executionId == _hashExecutionId(target, selector);
    }

    /**
     * @dev Returns true if a schedule timepoint is past its expiration deadline.
     */
    function _isExpired(uint48 timepoint) private view returns (bool) {
        return timepoint + expiration() <= Time.timestamp();
    }

    /**
     * @dev Extracts the selector from calldata. Panics if data is not at least 4 bytes
     */
    function _checkSelector(bytes calldata data) private pure returns (bytes4) {
        return bytes4(data[0:4]);
    }

    /**
     * @dev Hashing function for execute protection
     */
    function _hashExecutionId(address target, bytes4 selector) private pure returns (bytes32) {
        return keccak256(abi.encode(target, selector));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AuthorityUtils.sol)

pragma solidity ^0.8.20;

import {IAuthority} from "./IAuthority.sol";

library AuthorityUtils {
    /**
     * @dev Since `AccessManager` implements an extended IAuthority interface, invoking `canCall` with backwards compatibility
     * for the preexisting `IAuthority` interface requires special care to avoid reverting on insufficient return data.
     * This helper function takes care of invoking `canCall` in a backwards compatible way without reverting.
     */
    function canCallWithDelay(
        address authority,
        address caller,
        address target,
        bytes4 selector
    ) internal view returns (bool immediate, uint32 delay) {
        (bool success, bytes memory data) = authority.staticcall(
            abi.encodeCall(IAuthority.canCall, (caller, target, selector))
        );
        if (success) {
            if (data.length >= 0x40) {
                (immediate, delay) = abi.decode(data, (bool, uint32));
            } else if (data.length >= 0x20) {
                immediate = abi.decode(data, (bool));
            }
        }
        return (immediate, delay);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAccessManaged.sol)

pragma solidity ^0.8.20;

interface IAccessManaged {
    /**
     * @dev Authority that manages this contract was updated.
     */
    event AuthorityUpdated(address authority);

    error AccessManagedUnauthorized(address caller);
    error AccessManagedRequiredDelay(address caller, uint32 delay);
    error AccessManagedInvalidAuthority(address authority);

    /**
     * @dev Returns the current authority.
     */
    function authority() external view returns (address);

    /**
     * @dev Transfers control to a new authority. The caller must be the current authority.
     */
    function setAuthority(address) external;

    /**
     * @dev Returns true only in the context of a delayed restricted call, at the moment that the scheduled operation is
     * being consumed. Prevents denial of service for delayed restricted calls in the case that the contract performs
     * attacker controlled calls.
     */
    function isConsumingScheduledOp() external view returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (access/manager/IAccessManager.sol)

pragma solidity ^0.8.20;

import {Time} from "../../utils/types/Time.sol";

interface IAccessManager {
    /**
     * @dev A delayed operation was scheduled.
     */
    event OperationScheduled(
        bytes32 indexed operationId,
        uint32 indexed nonce,
        uint48 schedule,
        address caller,
        address target,
        bytes data
    );

    /**
     * @dev A scheduled operation was executed.
     */
    event OperationExecuted(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev A scheduled operation was canceled.
     */
    event OperationCanceled(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev Informational labelling for a roleId.
     */
    event RoleLabel(uint64 indexed roleId, string label);

    /**
     * @dev Emitted when `account` is granted `roleId`.
     *
     * NOTE: The meaning of the `since` argument depends on the `newMember` argument.
     * If the role is granted to a new member, the `since` argument indicates when the account becomes a member of the role,
     * otherwise it indicates the execution delay for this account and roleId is updated.
     */
    event RoleGranted(uint64 indexed roleId, address indexed account, uint32 delay, uint48 since, bool newMember);

    /**
     * @dev Emitted when `account` membership or `roleId` is revoked. Unlike granting, revoking is instantaneous.
     */
    event RoleRevoked(uint64 indexed roleId, address indexed account);

    /**
     * @dev Role acting as admin over a given `roleId` is updated.
     */
    event RoleAdminChanged(uint64 indexed roleId, uint64 indexed admin);

    /**
     * @dev Role acting as guardian over a given `roleId` is updated.
     */
    event RoleGuardianChanged(uint64 indexed roleId, uint64 indexed guardian);

    /**
     * @dev Grant delay for a given `roleId` will be updated to `delay` when `since` is reached.
     */
    event RoleGrantDelayChanged(uint64 indexed roleId, uint32 delay, uint48 since);

    /**
     * @dev Target mode is updated (true = closed, false = open).
     */
    event TargetClosed(address indexed target, bool closed);

    /**
     * @dev Role required to invoke `selector` on `target` is updated to `roleId`.
     */
    event TargetFunctionRoleUpdated(address indexed target, bytes4 selector, uint64 indexed roleId);

    /**
     * @dev Admin delay for a given `target` will be updated to `delay` when `since` is reached.
     */
    event TargetAdminDelayUpdated(address indexed target, uint32 delay, uint48 since);

    error AccessManagerAlreadyScheduled(bytes32 operationId);
    error AccessManagerNotScheduled(bytes32 operationId);
    error AccessManagerNotReady(bytes32 operationId);
    error AccessManagerExpired(bytes32 operationId);
    error AccessManagerLockedRole(uint64 roleId);
    error AccessManagerBadConfirmation();
    error AccessManagerUnauthorizedAccount(address msgsender, uint64 roleId);
    error AccessManagerUnauthorizedCall(address caller, address target, bytes4 selector);
    error AccessManagerUnauthorizedConsume(address target);
    error AccessManagerUnauthorizedCancel(address msgsender, address caller, address target, bytes4 selector);
    error AccessManagerInvalidInitialAdmin(address initialAdmin);

    /**
     * @dev Check if an address (`caller`) is authorised to call a given function on a given contract directly (with
     * no restriction). Additionally, it returns the delay needed to perform the call indirectly through the {schedule}
     * & {execute} workflow.
     *
     * This function is usually called by the targeted contract to control immediate execution of restricted functions.
     * Therefore we only return true if the call can be performed without any delay. If the call is subject to a
     * previously set delay (not zero), then the function should return false and the caller should schedule the operation
     * for future execution.
     *
     * If `immediate` is true, the delay can be disregarded and the operation can be immediately executed, otherwise
     * the operation can be executed if and only if delay is greater than 0.
     *
     * NOTE: The IAuthority interface does not include the `uint32` delay. This is an extension of that interface that
     * is backward compatible. Some contracts may thus ignore the second return argument. In that case they will fail
     * to identify the indirect workflow, and will consider calls that require a delay to be forbidden.
     *
     * NOTE: This function does not report the permissions of the admin functions in the manager itself. These are defined by the
     * {AccessManager} documentation.
     */
    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) external view returns (bool allowed, uint32 delay);

    /**
     * @dev Expiration delay for scheduled proposals. Defaults to 1 week.
     *
     * IMPORTANT: Avoid overriding the expiration with 0. Otherwise every contract proposal will be expired immediately,
     * disabling any scheduling usage.
     */
    function expiration() external view returns (uint32);

    /**
     * @dev Minimum setback for all delay updates, with the exception of execution delays. It
     * can be increased without setback (and reset via {revokeRole} in the case event of an
     * accidental increase). Defaults to 5 days.
     */
    function minSetback() external view returns (uint32);

    /**
     * @dev Get whether the contract is closed disabling any access. Otherwise role permissions are applied.
     *
     * NOTE: When the manager itself is closed, admin functions are still accessible to avoid locking the contract.
     */
    function isTargetClosed(address target) external view returns (bool);

    /**
     * @dev Get the role required to call a function.
     */
    function getTargetFunctionRole(address target, bytes4 selector) external view returns (uint64);

    /**
     * @dev Get the admin delay for a target contract. Changes to contract configuration are subject to this delay.
     */
    function getTargetAdminDelay(address target) external view returns (uint32);

    /**
     * @dev Get the id of the role that acts as an admin for the given role.
     *
     * The admin permission is required to grant the role, revoke the role and update the execution delay to execute
     * an operation that is restricted to this role.
     */
    function getRoleAdmin(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role that acts as a guardian for a given role.
     *
     * The guardian permission allows canceling operations that have been scheduled under the role.
     */
    function getRoleGuardian(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role current grant delay.
     *
     * Its value may change at any point without an event emitted following a call to {setGrantDelay}.
     * Changes to this value, including effect timepoint are notified in advance by the {RoleGrantDelayChanged} event.
     */
    function getRoleGrantDelay(uint64 roleId) external view returns (uint32);

    /**
     * @dev Get the access details for a given account for a given role. These details include the timepoint at which
     * membership becomes active, and the delay applied to all operation by this user that requires this permission
     * level.
     *
     * Returns:
     * [0] Timestamp at which the account membership becomes valid. 0 means role is not granted.
     * [1] Current execution delay for the account.
     * [2] Pending execution delay for the account.
     * [3] Timestamp at which the pending execution delay will become active. 0 means no delay update is scheduled.
     */
    function getAccess(
        uint64 roleId,
        address account
    ) external view returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect);

    /**
     * @dev Check if a given account currently has the permission level corresponding to a given role. Note that this
     * permission might be associated with an execution delay. {getAccess} can provide more details.
     */
    function hasRole(uint64 roleId, address account) external view returns (bool isMember, uint32 executionDelay);

    /**
     * @dev Give a label to a role, for improved role discoverability by UIs.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleLabel} event.
     */
    function labelRole(uint64 roleId, string calldata label) external;

    /**
     * @dev Add `account` to `roleId`, or change its execution delay.
     *
     * This gives the account the authorization to call any function that is restricted to this role. An optional
     * execution delay (in seconds) can be set. If that delay is non 0, the user is required to schedule any operation
     * that is restricted to members of this role. The user will only be able to execute the operation after the delay has
     * passed, before it has expired. During this period, admin and guardians can cancel the operation (see {cancel}).
     *
     * If the account has already been granted this role, the execution delay will be updated. This update is not
     * immediate and follows the delay rules. For example, if a user currently has a delay of 3 hours, and this is
     * called to reduce that delay to 1 hour, the new delay will take some time to take effect, enforcing that any
     * operation executed in the 3 hours that follows this update was indeed scheduled before this update.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - granted role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleGranted} event.
     */
    function grantRole(uint64 roleId, address account, uint32 executionDelay) external;

    /**
     * @dev Remove an account from a role, with immediate effect. If the account does not have the role, this call has
     * no effect.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - revoked role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function revokeRole(uint64 roleId, address account) external;

    /**
     * @dev Renounce role permissions for the calling account with immediate effect. If the sender is not in
     * the role this call has no effect.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function renounceRole(uint64 roleId, address callerConfirmation) external;

    /**
     * @dev Change admin role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleAdminChanged} event
     */
    function setRoleAdmin(uint64 roleId, uint64 admin) external;

    /**
     * @dev Change guardian role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGuardianChanged} event
     */
    function setRoleGuardian(uint64 roleId, uint64 guardian) external;

    /**
     * @dev Update the delay for granting a `roleId`.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function setGrantDelay(uint64 roleId, uint32 newDelay) external;

    /**
     * @dev Set the role required to call functions identified by the `selectors` in the `target` contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetFunctionRoleUpdated} event per selector.
     */
    function setTargetFunctionRole(address target, bytes4[] calldata selectors, uint64 roleId) external;

    /**
     * @dev Set the delay for changing the configuration of a given target contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function setTargetAdminDelay(address target, uint32 newDelay) external;

    /**
     * @dev Set the closed flag for a contract.
     *
     * Closing the manager itself won't disable access to admin methods to avoid locking the contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetClosed} event.
     */
    function setTargetClosed(address target, bool closed) external;

    /**
     * @dev Return the timepoint at which a scheduled operation will be ready for execution. This returns 0 if the
     * operation is not yet scheduled, has expired, was executed, or was canceled.
     */
    function getSchedule(bytes32 id) external view returns (uint48);

    /**
     * @dev Return the nonce for the latest scheduled operation with a given id. Returns 0 if the operation has never
     * been scheduled.
     */
    function getNonce(bytes32 id) external view returns (uint32);

    /**
     * @dev Schedule a delayed operation for future execution, and return the operation identifier. It is possible to
     * choose the timestamp at which the operation becomes executable as long as it satisfies the execution delays
     * required for the caller. The special value zero will automatically set the earliest possible time.
     *
     * Returns the `operationId` that was scheduled. Since this value is a hash of the parameters, it can reoccur when
     * the same parameters are used; if this is relevant, the returned `nonce` can be used to uniquely identify this
     * scheduled operation from other occurrences of the same `operationId` in invocations of {execute} and {cancel}.
     *
     * Emits a {OperationScheduled} event.
     *
     * NOTE: It is not possible to concurrently schedule more than one operation with the same `target` and `data`. If
     * this is necessary, a random byte can be appended to `data` to act as a salt that will be ignored by the target
     * contract if it is using standard Solidity ABI encoding.
     */
    function schedule(
        address target,
        bytes calldata data,
        uint48 when
    ) external returns (bytes32 operationId, uint32 nonce);

    /**
     * @dev Execute a function that is delay restricted, provided it was properly scheduled beforehand, or the
     * execution delay is 0.
     *
     * Returns the nonce that identifies the previously scheduled operation that is executed, or 0 if the
     * operation wasn't previously scheduled (if the caller doesn't have an execution delay).
     *
     * Emits an {OperationExecuted} event only if the call was scheduled and delayed.
     */
    function execute(address target, bytes calldata data) external payable returns (uint32);

    /**
     * @dev Cancel a scheduled (delayed) operation. Returns the nonce that identifies the previously scheduled
     * operation that is cancelled.
     *
     * Requirements:
     *
     * - the caller must be the proposer, a guardian of the targeted function, or a global admin
     *
     * Emits a {OperationCanceled} event.
     */
    function cancel(address caller, address target, bytes calldata data) external returns (uint32);

    /**
     * @dev Consume a scheduled operation targeting the caller. If such an operation exists, mark it as consumed
     * (emit an {OperationExecuted} event and clean the state). Otherwise, throw an error.
     *
     * This is useful for contract that want to enforce that calls targeting them were scheduled on the manager,
     * with all the verifications that it implies.
     *
     * Emit a {OperationExecuted} event.
     */
    function consumeScheduledOp(address caller, bytes calldata data) external;

    /**
     * @dev Hashing function for delayed operations.
     */
    function hashOperation(address caller, address target, bytes calldata data) external view returns (bytes32);

    /**
     * @dev Changes the authority of a target managed by this manager instance.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     */
    function updateAuthority(address target, address newAuthority) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAuthority.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard interface for permissioning originally defined in Dappsys.
 */
interface IAuthority {
    /**
     * @dev Returns true if the caller can invoke on a target the function identified by a function selector.
     */
    function canCall(address caller, address target, bytes4 selector) external view returns (bool allowed);
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
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
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
// OpenZeppelin Contracts (last updated v5.2.0) (utils/Address.sol)

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

        (bool success, bytes memory returndata) = recipient.call{value: amount}("");
        if (!success) {
            _revert(returndata);
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Multicall.sol)

pragma solidity ^0.8.20;

import {Address} from "./Address.sol";
import {Context} from "./Context.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * Consider any assumption about calldata validation performed by the sender may be violated if it's not especially
 * careful about sending transactions invoking {multicall}. For example, a relay address that filters function
 * selectors won't filter calls nested within a {multicall} operation.
 *
 * NOTE: Since 5.0.1 and 4.9.4, this contract identifies non-canonical contexts (i.e. `msg.sender` is not {_msgSender}).
 * If a non-canonical context is identified, the following self `delegatecall` appends the last bytes of `msg.data`
 * to the subcall. This makes it safe to use with {ERC2771Context}. Contexts that don't affect the resolution of
 * {_msgSender} are not propagated to subcalls.
 */
abstract contract Multicall is Context {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        bytes memory context = msg.sender == _msgSender()
            ? new bytes(0)
            : msg.data[msg.data.length - _contextSuffixLength():];

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), bytes.concat(data[i], context));
        }
        return results;
    }
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
// OpenZeppelin Contracts (last updated v5.1.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

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
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
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
            set._positions[value] = set._values.length;
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
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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

        assembly ("memory-safe") {
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

        assembly ("memory-safe") {
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

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/types/Time.sol)

pragma solidity ^0.8.20;

import {Math} from "../math/Math.sol";
import {SafeCast} from "../math/SafeCast.sol";

/**
 * @dev This library provides helpers for manipulating time-related objects.
 *
 * It uses the following types:
 * - `uint48` for timepoints
 * - `uint32` for durations
 *
 * While the library doesn't provide specific types for timepoints and duration, it does provide:
 * - a `Delay` type to represent duration that can be programmed to change value automatically at a given point
 * - additional helper functions
 */
library Time {
    using Time for *;

    /**
     * @dev Get the block timestamp as a Timepoint.
     */
    function timestamp() internal view returns (uint48) {
        return SafeCast.toUint48(block.timestamp);
    }

    /**
     * @dev Get the block number as a Timepoint.
     */
    function blockNumber() internal view returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    // ==================================================== Delay =====================================================
    /**
     * @dev A `Delay` is a uint32 duration that can be programmed to change value automatically at a given point in the
     * future. The "effect" timepoint describes when the transitions happens from the "old" value to the "new" value.
     * This allows updating the delay applied to some operation while keeping some guarantees.
     *
     * In particular, the {update} function guarantees that if the delay is reduced, the old delay still applies for
     * some time. For example if the delay is currently 7 days to do an upgrade, the admin should not be able to set
     * the delay to 0 and upgrade immediately. If the admin wants to reduce the delay, the old delay (7 days) should
     * still apply for some time.
     *
     *
     * The `Delay` type is 112 bits long, and packs the following:
     *
     * ```
     *   | [uint48]: effect date (timepoint)
     *   |           | [uint32]: value before (duration)
     *   ↓           ↓       ↓ [uint32]: value after (duration)
     * 0xAAAAAAAAAAAABBBBBBBBCCCCCCCC
     * ```
     *
     * NOTE: The {get} and {withUpdate} functions operate using timestamps. Block number based delays are not currently
     * supported.
     */
    type Delay is uint112;

    /**
     * @dev Wrap a duration into a Delay to add the one-step "update in the future" feature
     */
    function toDelay(uint32 duration) internal pure returns (Delay) {
        return Delay.wrap(duration);
    }

    /**
     * @dev Get the value at a given timepoint plus the pending value and effect timepoint if there is a scheduled
     * change after this timepoint. If the effect timepoint is 0, then the pending value should not be considered.
     */
    function _getFullAt(
        Delay self,
        uint48 timepoint
    ) private pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        (valueBefore, valueAfter, effect) = self.unpack();
        return effect <= timepoint ? (valueAfter, 0, 0) : (valueBefore, valueAfter, effect);
    }

    /**
     * @dev Get the current value plus the pending value and effect timepoint if there is a scheduled change. If the
     * effect timepoint is 0, then the pending value should not be considered.
     */
    function getFull(Delay self) internal view returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        return _getFullAt(self, timestamp());
    }

    /**
     * @dev Get the current value.
     */
    function get(Delay self) internal view returns (uint32) {
        (uint32 delay, , ) = self.getFull();
        return delay;
    }

    /**
     * @dev Update a Delay object so that it takes a new duration after a timepoint that is automatically computed to
     * enforce the old delay at the moment of the update. Returns the updated Delay object and the timestamp when the
     * new delay becomes effective.
     */
    function withUpdate(
        Delay self,
        uint32 newValue,
        uint32 minSetback
    ) internal view returns (Delay updatedDelay, uint48 effect) {
        uint32 value = self.get();
        uint32 setback = uint32(Math.max(minSetback, value > newValue ? value - newValue : 0));
        effect = timestamp() + setback;
        return (pack(value, newValue, effect), effect);
    }

    /**
     * @dev Split a delay into its components: valueBefore, valueAfter and effect (transition timepoint).
     */
    function unpack(Delay self) internal pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        uint112 raw = Delay.unwrap(self);

        valueAfter = uint32(raw);
        valueBefore = uint32(raw >> 32);
        effect = uint48(raw >> 64);

        return (valueBefore, valueAfter, effect);
    }

    /**
     * @dev pack the components into a Delay object.
     */
    function pack(uint32 valueBefore, uint32 valueAfter, uint48 effect) internal pure returns (Delay) {
        return Delay.wrap((uint112(effect) << 64) | (uint112(valueBefore) << 32) | uint112(valueAfter));
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.4.0;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.4.0;

/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol
library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// OpenZeppelin
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/access/manager/AccessManaged.sol';
import '@openzeppelin/contracts/utils/Multicall.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

// Libary
import './lib/Constants.sol';
import './lib/Farms.sol';
import './lib/uniswap/PoolAddress.sol';
import './lib/uniswap/LiquidityAmounts.sol';
import './lib/uniswap/PositionValue.sol';

// Proxy
import './proxy/TokenProxy.sol';

// Interfaces
import './interfaces/IIncentiveToken.sol';
import './interfaces/IFarmKeeper.sol';
import './interfaces/IPeggedFarmKeeper.sol';

// Other Contracts
import './UniversalBuyAndBurn.sol';

/**
 * @title Pegged FarmKeeper: A Uniswap V3 Farming Protocol, built on a root FarmKeeper, extending for "stable farms"
 *        Stable farms will allow to contribute liquditiy in a tight range around e.g. a 1:1 peg.
 * @notice Manages liquidity farms for Uniswap V3 pools with integrated buy-and-burn mechanism
 * @dev Inspired by MasterChef, adapted for Uniswap V3 and Universal Buy And Burn
 *
 *  ███████╗ █████╗ ██████╗ ███╗   ███╗██╗  ██╗███████╗███████╗██████╗ ███████╗██████╗
 *  ██╔════╝██╔══██╗██╔══██╗████╗ ████║██║ ██╔╝██╔════╝██╔════╝██╔══██╗██╔════╝██╔══██╗
 *  █████╗  ███████║██████╔╝██╔████╔██║█████╔╝ █████╗  █████╗  ██████╔╝█████╗  ██████╔╝
 *  ██╔══╝  ██╔══██║██╔══██╗██║╚██╔╝██║██╔═██╗ ██╔══╝  ██╔══╝  ██╔═══╝ ██╔══╝  ██╔══██╗
 *  ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██╗███████╗███████╗██║     ███████╗██║  ██║
 *  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
 *
 *
 * Key Features:
 * 1. Uniswap V3 Compatibility: Manages farms for Uniswap V3 liquidity positions
 * 2. Flexible Reward System: Distributes incentive tokens as rewards based on liquidity provision
 * 3. Fee Collection: Collects and distributes fees from Uniswap V3 positions
 * 4. Buy-and-Burn Integration: Automatically sends collected fees to a buy-and-burn mechanism
 * 5. Protocol Fee: Allows for collection of protocol fees on each farm
 * 6. Acts as a Sub-FarmKeeper instance by adding a proxy pool. Incentive tokens minted to this
 *    proxy pool are then distributed to the regular FarmKeeper rules.
 *
 * How it works:
 * - Users deposit liquidity into farms, receiving a share of the farm's total liquidity
 * - The contract manages a single Uniswap V3 position for each farm
 * - Rewards (incentive tokens) are collected from FarmKeeper and distributed based on users' liquidity share and time
 * - Fees collected from Uniswap V3 positions are:
 *   a) Sent to the buy-and-burn contract for designated input tokens
 *   b) Distributed to users for non-input tokens
 * - Users can withdraw their liquidity and claim rewards at any time
 *
 * Security features:
 * - Access control using OpenZeppelin's AccessManaged
 * - Reentrancy protection through function ordering and ReentrancyGuard
 * - Slippage protection for liquidity operations
 */
contract PeggedFarmKeeper is IPeggedFarmKeeper, AccessManaged, Multicall, ReentrancyGuard {
  using Farms for Farms.Map;
  using SafeERC20 for IERC20;

  // -----------------------------------------
  // Type declarations
  // -----------------------------------------
  struct AddFarmParams {
    address tokenA;
    address tokenB;
    uint24 fee;
    uint56 allocPoints;
    uint256 protocolFee;
    uint32 priceTwa;
    uint256 slippage;
    int24 minTick;
    int24 maxTick;
  }

  struct Ticks {
    int24 minTick;
    int24 maxTick;
  }

  // -----------------------------------------
  // State variables
  // -----------------------------------------
  /** @notice The farms managed by this contract */
  Farms.Map private _farms;

  /** @notice Accumulated protocol fees for each token */
  mapping(address token => uint256 amount) public protocolFees;

  /** @notice Min. and Max. Tick per farm-id */
  mapping(address id => Ticks ticks) public ticks;

  /** @notice Indicates if the contract has been successfully initialized */
  bool public initialized;

  /** @notice The IncentiveToken contract */
  IIncentiveToken public incentiveToken;

  /** @notice The TINC buy and burn contract */
  UniversalBuyAndBurn public buyAndBurn;

  /** @notice The FarmKeeper instance owning the icentive token */
  IFarmKeeper public rootKeeper;

  /** @notice Proxy Tokens for root FarmKeeper */
  ProxyToken private _proxyTokenA;
  ProxyToken private _proxyTokenB;

  /** @notice The farm ID used to interact with the root farm keeper instance */
  address public rootKeeperFarmId;

  /** @notice Accumulated incentive tokens per share */
  uint256 private _globalAccIncentiveTokenPerShare;

  /** @notice Total allocation points across all farms */
  uint256 public totalAllocPoints;
  // -----------------------------------------
  // Events
  // -----------------------------------------
  event FarmEnabled(address indexed id, AddFarmParams params);
  event FeeDistributed(address indexed id, address indexed user, address indexed token, uint256 amount);
  event IncentiveTokenDistributed(address indexed id, address indexed user, uint256 amount);
  event Deposit(
    address indexed id,
    address indexed user,
    uint128 liquidity,
    uint256 amountToken0,
    uint256 amountToken1
  );
  event Withdraw(
    address indexed id,
    address indexed user,
    uint256 liquidity,
    uint256 amountToken0,
    uint256 amountToken1
  );
  event ProtocolFeesCollected(address indexed token, uint256 amount);

  event SlippageUpdated(address indexed id, uint256 newSlippage);
  event PriceTwaUpdated(address indexed id, uint32 newTwa);
  event ProtocolFeeUpdated(address indexed id, uint256 newFee);
  event AllocationUpdated(address indexed id, uint256 allocPoints);

  // -----------------------------------------
  // Errors
  // -----------------------------------------
  error InvalidLiquidityAmount();
  error InvalidPriceTwa();
  error InvalidSlippage();
  error InvalidFee();
  error InvalidAllocPoints();
  error InvalidTokenId();
  error InvalidFarmId();
  error AlreadyInitialized();
  error InvalidIncentiveToken();
  error DuplicatedFarm();
  error TotalAllocationCannotBeZero();
  error InvalidTicks();

  // -----------------------------------------
  // Modifiers
  // -----------------------------------------

  // -----------------------------------------
  // Constructor
  // -----------------------------------------
  /**
   * @notice Creates a new instance of the contract
   * @param incentiveTokenAddress The address of the Incentive Token contract
   * @param universalBuyAndBurnAddress The address of the Universal Buy And Burn contract
   * @param rootKeeperAddress The address of the root farm keeper contract
   * @param manager The address of the Access Manager contract
   */
  constructor(
    address incentiveTokenAddress,
    address universalBuyAndBurnAddress,
    address rootKeeperAddress,
    address manager
  ) AccessManaged(manager) {
    incentiveToken = IIncentiveToken(incentiveTokenAddress);
    buyAndBurn = UniversalBuyAndBurn(universalBuyAndBurnAddress);
    rootKeeper = IFarmKeeper(rootKeeperAddress);

    // Deploy two helper tokens, mint supply, deploy a pool
    _proxyTokenA = new ProxyToken();
    _proxyTokenB = new ProxyToken();

    PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(
      address(_proxyTokenA),
      address(_proxyTokenB),
      Constants.FEE_TIER_1_PERCENT
    );

    // 1:1 initial price
    rootKeeperFarmId = INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER)
      .createAndInitializePoolIfNecessary(poolKey.token0, poolKey.token1, poolKey.fee, 79228162514264337593543950336);
  }

  // -----------------------------------------
  // Receive function
  // -----------------------------------------

  // -----------------------------------------
  // Fallback function
  // -----------------------------------------

  // -----------------------------------------
  // External functions
  // -----------------------------------------
  /**
   * @notice Initializes the FarmKeeper contract
   * @dev Can only be called once and must be called by the contract manager after ownership of
   * the incentive token has been successfully transfered to the farm keeper.
   */
  function initialize() external restricted {
    if (initialized) revert AlreadyInitialized();

    // Try to access the farm view (must be enabled in root farm keeper), will revert if not available
    rootKeeper.farmView(rootKeeperFarmId);
    initialized = true;

    // Deposit into root farm keeper, holding 100% of the liquidity in this pool
    (address token0, address token1, uint128 liquidity, uint256 amount0, uint256 amount1) = rootKeeper
      .getLiquidityForAmount(rootKeeperFarmId, address(_proxyTokenA), 1000 ether);

    ProxyToken(token0).mint(address(this), amount0);
    ProxyToken(token1).mint(address(this), amount1);
    ProxyToken(token0).approve(address(rootKeeper), amount0);
    ProxyToken(token1).approve(address(rootKeeper), amount1);

    rootKeeper.deposit(rootKeeperFarmId, liquidity, block.timestamp);
  }

  /**
   * @notice Allows a user to deposit liquidity into a farm
   * Setting liquidity to zero allows to pull fees and incentive tokens
   * without modifying the liquidity position by the user.
   * @param id The ID of the farm to deposit into
   * @param liquidity The amount of liquidity to deposit
   * @param slippage Allow users to override default slippage settings (0: default, otherwise override, in basis points)
   * @param deadline The Unix timestamp by which the transaction must be confirmed.
   * If the transaction is pending in the mempool beyond this time, it will revert,
   * preventing any further interaction with the Uniswap LP position.
   */
  function deposit(address id, uint128 liquidity, uint256 slippage, uint256 deadline) external nonReentrant {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    User storage user = _farms.user(id, msg.sender);

    // Always collect reward
    _collectReward();

    // Update farm and collect fees
    _updateFarm(farm, true);

    // Distribute pending rewards and fees
    uint256 pendingIncentiveTokens = Math.mulDiv(
      user.liquidity,
      farm.accIncentiveTokenPerShare,
      Constants.SCALE_FACTOR_1E18
    ) - user.rewardCheckpoint;
    uint256 pendingFeeToken0 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken0, Constants.SCALE_FACTOR_1E18) -
      user.feeCheckpointToken0;
    uint256 pendingFeeToken1 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken1, Constants.SCALE_FACTOR_1E18) -
      user.feeCheckpointToken1;

    uint128 addedLiquidity = 0;
    uint256 amountToken0 = 0;
    uint256 amountToken1 = 0;

    // Allow to call this function without modifying liquidity
    // to pull rewards only
    if (liquidity > 0) {
      if (farm.lp.tokenId == 0) {
        // Create LP position and refund caller
        (addedLiquidity, amountToken0, amountToken1) = _createLiquidityPosition(farm, liquidity, slippage, deadline);
      } else {
        // Add liquidity to existing position
        (addedLiquidity, amountToken0, amountToken1) = _addLiquidity(farm, liquidity, slippage, deadline);
      }
    }

    // Update state
    user.liquidity += addedLiquidity;
    user.rewardCheckpoint = Math.mulDiv(user.liquidity, farm.accIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18);
    user.feeCheckpointToken0 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken0, Constants.SCALE_FACTOR_1E18);
    user.feeCheckpointToken1 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken1, Constants.SCALE_FACTOR_1E18);

    // Payout pending tokens
    if (pendingIncentiveTokens > 0) {
      _safeTransferToken(address(incentiveToken), msg.sender, pendingIncentiveTokens);
      emit IncentiveTokenDistributed(id, msg.sender, pendingIncentiveTokens);
    }
    if (pendingFeeToken0 > 0) {
      _safeTransferToken(farm.poolKey.token0, msg.sender, pendingFeeToken0);
      emit FeeDistributed(id, msg.sender, farm.poolKey.token0, pendingFeeToken0);
    }
    if (pendingFeeToken1 > 0) {
      _safeTransferToken(farm.poolKey.token1, msg.sender, pendingFeeToken1);
      emit FeeDistributed(id, msg.sender, farm.poolKey.token1, pendingFeeToken1);
    }

    emit Deposit(id, msg.sender, liquidity, amountToken0, amountToken1);
  }

  /**
   * @notice Allows a user to withdraw liquidity from a farm
   * To harvest incentive tokens and fees, call `deposit` with liquidity amount of 0.
   * @param id The ID of the farm to withdraw from
   * @param liquidity The amount of liquidity to withdraw
   * @param slippage Allow users to override default slippage settings (0: default, otherwise override, in basis points)
   * @param deadline The Unix timestamp by which the transaction must be confirmed.
   * If the transaction is pending in the mempool beyond this time, it will revert,
   * preventing any further interaction with the Uniswap LP position.
   */
  function withdraw(address id, uint128 liquidity, uint256 slippage, uint256 deadline) external nonReentrant {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    User storage user = _farms.user(id, msg.sender);

    if (user.liquidity < liquidity || liquidity == 0) {
      revert InvalidLiquidityAmount();
    }

    // Always collect reward
    _collectReward();

    // Update farms and collect fees
    _updateFarm(farm, true);

    // Calculate pending rewards and fees
    uint256 pendingIncentiveTokens = Math.mulDiv(
      user.liquidity,
      farm.accIncentiveTokenPerShare,
      Constants.SCALE_FACTOR_1E18
    ) - user.rewardCheckpoint;
    uint256 pendingFeeToken0 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken0, Constants.SCALE_FACTOR_1E18) -
      user.feeCheckpointToken0;
    uint256 pendingFeeToken1 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken1, Constants.SCALE_FACTOR_1E18) -
      user.feeCheckpointToken1;

    // Update state
    user.liquidity -= liquidity;
    user.rewardCheckpoint = Math.mulDiv(user.liquidity, farm.accIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18);
    user.feeCheckpointToken0 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken0, Constants.SCALE_FACTOR_1E18);
    user.feeCheckpointToken1 = Math.mulDiv(user.liquidity, farm.accFeePerShareForToken1, Constants.SCALE_FACTOR_1E18);

    // Decrease liquidity
    (uint256 amountToken0, uint256 amountToken1) = _decreaseLiquidity(farm, liquidity, msg.sender, slippage, deadline);

    // Payout pending tokens
    if (pendingIncentiveTokens > 0) {
      // Transfer Incentive Tokens
      _safeTransferToken(address(incentiveToken), msg.sender, pendingIncentiveTokens);
      emit IncentiveTokenDistributed(id, msg.sender, pendingIncentiveTokens);
    }
    if (pendingFeeToken0 > 0) {
      _safeTransferToken(farm.poolKey.token0, msg.sender, pendingFeeToken0);
      emit FeeDistributed(id, msg.sender, farm.poolKey.token0, pendingFeeToken0);
    }
    if (pendingFeeToken1 > 0) {
      _safeTransferToken(farm.poolKey.token1, msg.sender, pendingFeeToken1);
      emit FeeDistributed(id, msg.sender, farm.poolKey.token1, pendingFeeToken1);
    }

    emit Withdraw(id, msg.sender, liquidity, amountToken0, amountToken1);
  }

  /**
   * @notice Updates a specific farm and collect fees
   * @param id The ID of the farm to update
   * @param collectFees collect trading fees accumulated by the liquidity provided
   */
  function updateFarm(address id, bool collectFees) external nonReentrant {
    if (!_farms.contains(id)) revert InvalidFarmId();

    // Always collect reward
    _collectReward();

    Farm storage farm = _farms.get(id);
    _updateFarm(farm, collectFees);
  }

  /**
   * @notice Enables a new farm
   * @param params The parameters for the new farm
   */
  function enableFarm(AddFarmParams calldata params) external restricted {
    PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(params.tokenA, params.tokenB, params.fee);

    // Derive a unique-ID to allow multiple farms with different min. and max. ticks
    // use case: move range by a few percent by disabling and enabling a new farm
    address id = address(
      uint160(
        uint256(
          keccak256(
            abi.encode(
              PoolAddress.computeAddress(Constants.FACTORY, poolKey),
              int256(params.minTick),
              int256(params.maxTick)
            )
          )
        )
      )
    );

    // Check for duplicates
    if (_farms.contains(id)) revert DuplicatedFarm();

    _validateAllocPoints(params.allocPoints);
    _validatePriceTwa(params.priceTwa);
    _validateSlippage(params.slippage);
    _validateProtocolFee(params.protocolFee);
    _validateTicks(params.fee, params.minTick, params.maxTick);

    // Ensure valid allocations points when enabling a farm
    if (totalAllocPoints + params.allocPoints <= 0) revert InvalidAllocPoints();

    // Update all farms but do not collect fees as only
    // the incentive token allocations are affected by enabling a new farm
    massUpdateFarms(false);

    // Append new farm
    _farms.add(
      Farm({
        id: id,
        poolKey: poolKey,
        lp: LP({tokenId: 0, liquidity: 0}),
        allocPoints: params.allocPoints,
        // Use lastRewardTime as checkpoint
        // If a farm is enabled with zero allocation, setting the allocation later will take the snapshot
        lastRewardTime: params.allocPoints > 0
          ? Math.mulDiv(params.allocPoints, _globalAccIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18)
          : 0,
        accIncentiveTokenPerShare: 0,
        accFeePerShareForToken0: 0,
        accFeePerShareForToken1: 0,
        protocolFee: params.protocolFee,
        priceTwa: params.priceTwa,
        slippage: params.slippage
      })
    );

    ticks[id].minTick = params.minTick;
    ticks[id].maxTick = params.maxTick;

    totalAllocPoints += params.allocPoints;
    emit FarmEnabled(id, params);
  }

  /**
   * @notice Sets the slippage percentage for buy and burn minimum received amount
   * @param id The ID of the farm to update
   * @param slippage The new slippage value (from 0% to 15%)
   */
  function setSlippage(address id, uint256 slippage) external restricted {
    if (!_farms.contains(id)) revert InvalidFarmId();

    _validateSlippage(slippage);
    _farms.get(id).slippage = slippage;
    emit SlippageUpdated(id, slippage);
  }

  /**
   * @notice Sets the TWA value used for requesting quotes
   * @param id The ID of the farm to update
   * @param mins TWA in minutes
   */
  function setPriceTwa(address id, uint32 mins) external restricted {
    if (!_farms.contains(id)) revert InvalidFarmId();

    _validatePriceTwa(mins);
    _farms.get(id).priceTwa = mins;
    emit PriceTwaUpdated(id, mins);
  }

  /**
   * @notice Sets the protocol fee for a farm
   * @param id The ID of the farm to update
   * @param fee The new protocol fee
   */
  function setProtocolFee(address id, uint256 fee) external restricted {
    if (!_farms.contains(id)) revert InvalidFarmId();

    _validateProtocolFee(fee);
    Farm storage farm = _farms.get(id);

    // Always collect reward
    _collectReward();

    // collect fees and distribute with the old protocol fee
    // before the new setting takes effect
    _updateFarm(farm, true);
    farm.protocolFee = fee;

    emit ProtocolFeeUpdated(id, fee);
  }

  /**
   * @notice Collect accumulated protocol fees for a specific token
   * @param token The address of the token to withdraw fees for
   */
  function collectProtocolFee(address token) external restricted {
    uint256 protocolFee = protocolFees[token];
    protocolFees[token] = 0;

    if (protocolFee > 0) {
      IERC20(token).safeTransfer(msg.sender, protocolFee);
    }

    emit ProtocolFeesCollected(token, protocolFee);
  }

  /**
   * @notice Updates the allocation points for a given farm
   * @param id The ID of the farm to update
   * @param allocPoints The new allocation points
   */
  function setAllocation(address id, uint256 allocPoints) external restricted {
    if (!_farms.contains(id)) revert InvalidFarmId();

    _validateAllocPoints(allocPoints);
    Farm storage farm = _farms.get(id);

    // Update all farms but do not collect fees as only
    // the INC token distribution is affected by modifying allocations
    massUpdateFarms(false);

    if (farm.allocPoints > allocPoints) {
      if (totalAllocPoints - (farm.allocPoints - allocPoints) <= 0) revert TotalAllocationCannotBeZero();
    }

    // Re-Enabling a farm, update checkpoint using new farm allocation
    if (farm.allocPoints == 0) {
      farm.lastRewardTime = Math.mulDiv(allocPoints, _globalAccIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18);
    }

    totalAllocPoints = totalAllocPoints - farm.allocPoints + allocPoints;
    farm.allocPoints = allocPoints;

    emit AllocationUpdated(id, allocPoints);
  }

  /**
   * @notice Retrieves all farms
   * @return An array of all Farms
   */
  function farmViews() external view returns (FarmView[] memory) {
    Farm[] memory farms = _farms.values();
    FarmView[] memory views = new FarmView[](farms.length);

    for (uint256 idx = 0; idx < farms.length; idx++) {
      views[idx] = farmView(farms[idx].id);
    }

    return views;
  }

  /**
   * @notice Retrieves a user view for a specific farm
   * @param id The ID of the farm
   * @param userId The address of the user
   * @return A UserView struct with the user's farm information
   */
  function userView(address id, address userId) external view returns (UserView memory) {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    User storage user = _farms.user(id, userId);

    if (user.liquidity == 0) {
      return
        UserView({
          token0: farm.poolKey.token0,
          token1: farm.poolKey.token1,
          liquidity: user.liquidity,
          balanceToken0: 0,
          balanceToken1: 0,
          pendingFeeToken0: 0,
          pendingFeeToken1: 0,
          pendingIncentiveTokens: 0
        });
    }

    (
      uint256 accIncentiveTokenPerShare,
      uint256 accFeePerShareForToken0,
      uint256 accFeePerShareForToken1
    ) = _getSharesAtBlockTimestamp(farm);

    (uint160 slotPrice, ) = _getTwaPrice(PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey), 0);
    Ticks storage tick = ticks[farm.id];

    (uint256 balanceToken0, uint256 balanceToken1) = LiquidityAmounts.getAmountsForLiquidity(
      slotPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      user.liquidity
    );

    return
      UserView({
        token0: farm.poolKey.token0,
        token1: farm.poolKey.token1,
        liquidity: user.liquidity,
        balanceToken0: balanceToken0,
        balanceToken1: balanceToken1,
        pendingFeeToken0: Math.mulDiv(user.liquidity, accFeePerShareForToken0, Constants.SCALE_FACTOR_1E18) -
          user.feeCheckpointToken0,
        pendingFeeToken1: Math.mulDiv(user.liquidity, accFeePerShareForToken1, Constants.SCALE_FACTOR_1E18) -
          user.feeCheckpointToken1,
        pendingIncentiveTokens: Math.mulDiv(user.liquidity, accIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18) -
          user.rewardCheckpoint
      });
  }

  /**
   * @notice Calculates the token amounts required for a given liquidity amount
   * @param id The unique identifier of the farm
   * @param liquidity The amount of liquidity to provide
   * @return token0 The address of the first token in the pair
   * @return token1 The address of the second token in the pair
   * @return amount0 The desired amount of token0
   * @return amount1 The desired amount of token1
   */
  function getAmountsForLiquidity(
    address id,
    uint128 liquidity
  ) external view returns (address token0, address token1, uint256 amount0, uint256 amount1) {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    Ticks storage tick = ticks[farm.id];

    (uint160 slotPrice, ) = _getTwaPrice(PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey), 0);

    // Calculate amounts based on current slot price
    (amount0, amount1) = LiquidityAmounts.getAmountsForLiquidity(
      slotPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      liquidity
    );

    token0 = farm.poolKey.token0;
    token1 = farm.poolKey.token1;
  }

  /**
   * @notice Calculates the liquidity and token amounts for a given token amount
   * @param id The unique identifier of the farm
   * @param token The address of the token to provide
   * @param amount The amount of the token to provide
   * @return token0 The address of the first token in the pair
   * @return token1 The address of the second token in the pair
   * @return liquidity The calculated liquidity amount
   * @return amount0 The amount of token0 required
   * @return amount1 The amount of token1 required
   */
  function getLiquidityForAmount(
    address id,
    address token,
    uint256 amount
  ) external view returns (address token0, address token1, uint128 liquidity, uint256 amount0, uint256 amount1) {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    Ticks storage tick = ticks[farm.id];

    token0 = farm.poolKey.token0;
    token1 = farm.poolKey.token1;

    // Get prices
    (uint160 slotPrice, ) = _getTwaPrice(PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey), 0);
    uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tick.minTick);
    uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tick.maxTick);

    // Price is below range
    if (slotPrice <= sqrtRatioAX96) {
      if (token == token0) {
        liquidity = LiquidityAmounts.getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount);
      } else {
        // Cannot add given token below range
        liquidity = 0;
        amount0 = 0;
        amount1 = 0;

        return (token0, token1, liquidity, amount0, amount1);
      }
    }
    // Price is in range
    else if (slotPrice < sqrtRatioBX96) {
      if (token == token0) {
        liquidity = LiquidityAmounts.getLiquidityForAmount0(slotPrice, sqrtRatioBX96, amount);
      } else if (token == token1) {
        liquidity = LiquidityAmounts.getLiquidityForAmount1(sqrtRatioAX96, slotPrice, amount);
      } else {
        revert InvalidTokenId();
      }
    }
    // Price is above range
    else {
      if (token == token1) {
        liquidity = LiquidityAmounts.getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount);
      } else {
        // Cannot add given token below range
        liquidity = 0;
        amount0 = 0;
        amount1 = 0;

        return (token0, token1, liquidity, amount0, amount1);
      }
    }

    // Calculate amounts based on the slot price
    (amount0, amount1) = LiquidityAmounts.getAmountsForLiquidity(
      slotPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      liquidity
    );
  }

  /**
   * @notice Computes the unique identifier for a Uniswap V3 pool
   * @param tokenA The address of the first token in the pair
   * @param tokenB The address of the second token in the pair
   * @param fee The fee tier of the pool
   * @param minTick minimum Tick for the LP position
   * @param maxTick maximum Tick for the LP position
   * @return id The computed address of the Uniswap V3 pool
   */
  function getFarmId(
    address tokenA,
    address tokenB,
    uint24 fee,
    int24 minTick,
    int24 maxTick
  ) external pure returns (address id) {
    PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(tokenA, tokenB, fee);
    id = address(
      uint160(
        uint256(
          keccak256(
            abi.encode(PoolAddress.computeAddress(Constants.FACTORY, poolKey), int256(minTick), int256(maxTick))
          )
        )
      )
    );
  }

  /**
   * @notice Computes the pool address for a farm ID
   */
  function getPoolForId(address id) external view returns (address) {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    return PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey);
  }

  // -----------------------------------------
  // Public functions
  // -----------------------------------------
  /**
   * @notice Retrieves detailed information about a specific farm
   * @param id The unique identifier of the farm
   * @return A FarmView struct containing comprehensive farm details
   */
  function farmView(address id) public view returns (FarmView memory) {
    if (!_farms.contains(id)) revert InvalidFarmId();

    Farm storage farm = _farms.get(id);
    Ticks storage tick = ticks[id];

    (uint160 slotPrice, ) = _getTwaPrice(PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey), 0);
    (uint256 balanceToken0, uint256 balanceToken1) = LiquidityAmounts.getAmountsForLiquidity(
      slotPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      farm.lp.liquidity
    );

    (
      uint256 accIncentiveTokenPerShare,
      uint256 accFeePerShareForToken0,
      uint256 accFeePerShareForToken1
    ) = _getSharesAtBlockTimestamp(farm);

    return
      FarmView({
        id: farm.id,
        poolKey: farm.poolKey,
        lp: farm.lp,
        allocPoints: farm.allocPoints,
        // @dev: Last reward time is used as the checkpoint in share calculations in pegged farm keeper
        lastRewardTime: farm.lastRewardTime,
        // @dev: accumulated share values have been updated to the current block time and **do not**
        // reflect the values captured at last reward time
        accIncentiveTokenPerShare: accIncentiveTokenPerShare,
        accFeePerShareForToken0: accFeePerShareForToken0,
        accFeePerShareForToken1: accFeePerShareForToken1,
        protocolFee: farm.protocolFee,
        priceTwa: farm.priceTwa,
        slippage: farm.slippage,
        balanceToken0: balanceToken0,
        balanceToken1: balanceToken1
      });
  }

  /**
   * @notice Updates reward variables for all farms
   * @dev This function can be gas-intensive, use cautiously
   * @param collectFees optionally, collect fees on every farm
   */
  function massUpdateFarms(bool collectFees) public nonReentrant {
    uint256 length = _farms.length();

    // Always collect reward
    _collectReward();

    // Iterate all farms and update them
    for (uint256 idx = 0; idx < length; idx++) {
      Farm storage farm = _farms.at(idx);
      _updateFarm(farm, collectFees);
    }
  }

  // -----------------------------------------
  // Internal functions
  // -----------------------------------------

  // -----------------------------------------
  // Private functions
  // -----------------------------------------
  function _updateFarm(Farm storage farm, bool collectFees) private {
    // Total liquidity
    uint256 liquidity = farm.lp.liquidity;

    // Collect fees if needed, possible even if incentive token are not issued yet
    if (collectFees) {
      _collectFees(farm);
    }

    // NOOP if allocation points are zero
    // Checkpoint is updated when changing the allocation points from zero to a value
    if (farm.allocPoints == 0) {
      return;
    }

    // Take checkpoint if liquidity is zero
    // This might leave incentive tokens in the farm but ensures a fair distribution
    // across users
    if (liquidity == 0) {
      farm.lastRewardTime = Math.mulDiv(
        farm.allocPoints,
        _globalAccIncentiveTokenPerShare,
        Constants.SCALE_FACTOR_1E18
      );
      return;
    }

    // Update incentive tokens for this farm from global pool
    // Use lastRewardTime as checkpoint variable in pegged farm implementation
    uint256 incentiveTokenReward = Math.mulDiv(
      farm.allocPoints,
      _globalAccIncentiveTokenPerShare,
      Constants.SCALE_FACTOR_1E18
    ) - farm.lastRewardTime;

    // Use lastRewardTime as checkpoint variable in pegged farm implementation
    farm.lastRewardTime = Math.mulDiv(farm.allocPoints, _globalAccIncentiveTokenPerShare, Constants.SCALE_FACTOR_1E18);

    // Scale shares by scaling factor and liquidity
    farm.accIncentiveTokenPerShare += Math.mulDiv(incentiveTokenReward, Constants.SCALE_FACTOR_1E18, liquidity);
  }

  function _collectReward() private {
    // Only start collecting rewards once a farms is active
    if (totalAllocPoints == 0) return;

    uint256 balanceBefore = incentiveToken.balanceOf(address(this));

    // Collect pending tokens
    rootKeeper.deposit(rootKeeperFarmId, 0, block.timestamp);
    uint256 collected = incentiveToken.balanceOf(address(this)) - balanceBefore;

    // Update global shares
    _globalAccIncentiveTokenPerShare += Math.mulDiv(collected, Constants.SCALE_FACTOR_1E18, totalAllocPoints);
  }

  function _collectFees(Farm storage farm) private {
    // Cache State Variables
    uint256 liquidity = farm.lp.liquidity;
    uint256 tokenId = farm.lp.tokenId;
    INonfungiblePositionManager manager = INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER);

    // Do nothing if shared LP position has not been minted yet or there is no liquidity
    // and hence no fees will be collected
    if (tokenId <= 0 || liquidity == 0) return;

    // Collect the maximum amount possible of both tokens
    INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams(
      tokenId,
      address(this),
      type(uint128).max,
      type(uint128).max
    );
    (uint256 amount0, uint256 amount1) = manager.collect(params);

    // Identify tokens which are accepted as input for buy and burn
    bool isInputToken0 = buyAndBurn.isInputToken(farm.poolKey.token0);
    bool isInputToken1 = buyAndBurn.isInputToken(farm.poolKey.token1);

    // Handle token0
    if (isInputToken0) {
      uint256 protocolFee = 0;

      if (farm.protocolFee > 0) {
        protocolFee = Math.mulDiv(amount0, farm.protocolFee, Constants.BASIS);
        protocolFees[farm.poolKey.token0] += protocolFee;
      }

      // Send core tokens to the buy and burn contract
      _safeTransferToken(farm.poolKey.token0, address(buyAndBurn), amount0 - protocolFee);
    } else {
      farm.accFeePerShareForToken0 += Math.mulDiv(amount0, Constants.SCALE_FACTOR_1E18, liquidity);
    }

    // Handle token1
    if (isInputToken1) {
      uint256 protocolFee = 0;

      if (farm.protocolFee > 0) {
        protocolFee = Math.mulDiv(amount1, farm.protocolFee, Constants.BASIS);
        protocolFees[farm.poolKey.token1] += protocolFee;
      }

      // Send core tokens to the buy and burn contract
      _safeTransferToken(farm.poolKey.token1, address(buyAndBurn), amount1 - protocolFee);
    } else {
      farm.accFeePerShareForToken1 += Math.mulDiv(amount1, Constants.SCALE_FACTOR_1E18, liquidity);
    }
  }

  function _createLiquidityPosition(
    Farm storage farm,
    uint128 liquidity,
    uint256 slippage,
    uint256 deadline
  ) private returns (uint128, uint256, uint256) {
    (
      uint256 desiredAmount0,
      uint256 desiredAmount1,
      uint256 minAmount0,
      uint256 minAmount1
    ) = _getDesiredAmountsForLiquidity(farm, liquidity, slippage > 0 ? slippage : farm.slippage);

    // Transfer tokens to the Farm Keeper
    IERC20(farm.poolKey.token0).safeTransferFrom(msg.sender, address(this), desiredAmount0);
    IERC20(farm.poolKey.token1).safeTransferFrom(msg.sender, address(this), desiredAmount1);

    IERC20(farm.poolKey.token0).safeIncreaseAllowance(Constants.NON_FUNGIBLE_POSITION_MANAGER, desiredAmount0);
    IERC20(farm.poolKey.token1).safeIncreaseAllowance(Constants.NON_FUNGIBLE_POSITION_MANAGER, desiredAmount1);

    // Mint the shared liquidity position
    INonfungiblePositionManager manager = INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER);
    Ticks storage tick = ticks[farm.id];

    INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams({
      token0: farm.poolKey.token0,
      token1: farm.poolKey.token1,
      fee: farm.poolKey.fee,
      tickLower: tick.minTick,
      tickUpper: tick.maxTick,
      amount0Desired: desiredAmount0,
      amount1Desired: desiredAmount1,
      amount0Min: minAmount0,
      amount1Min: minAmount1,
      recipient: address(this),
      deadline: deadline
    });

    (uint256 tokenId, uint128 mintedLiquidity, uint256 usedAmount0, uint256 usedAmount1) = manager.mint(mintParams);

    // Refund unused tokens
    uint256 unusedAmount0 = desiredAmount0 - usedAmount0;
    uint256 unusedAmount1 = desiredAmount1 - usedAmount1;

    if (unusedAmount0 > 0) {
      _safeTransferToken(farm.poolKey.token0, msg.sender, unusedAmount0);
    }

    if (unusedAmount1 > 0) {
      _safeTransferToken(farm.poolKey.token1, msg.sender, unusedAmount1);
    }

    // Update state
    farm.lp.tokenId = tokenId;
    farm.lp.liquidity += mintedLiquidity;

    // Reset allowance
    IERC20(farm.poolKey.token0).forceApprove(Constants.NON_FUNGIBLE_POSITION_MANAGER, 0);
    IERC20(farm.poolKey.token1).forceApprove(Constants.NON_FUNGIBLE_POSITION_MANAGER, 0);

    return (mintedLiquidity, usedAmount0, usedAmount1);
  }

  function _addLiquidity(
    Farm storage farm,
    uint128 liquidity,
    uint256 slippage,
    uint256 deadline
  ) private returns (uint128, uint256, uint256) {
    (
      uint256 desiredAmount0,
      uint256 desiredAmount1,
      uint256 minAmount0,
      uint256 minAmount1
    ) = _getDesiredAmountsForLiquidity(farm, liquidity, slippage > 0 ? slippage : farm.slippage);

    // Transfer tokens to the Farm Keeper
    IERC20(farm.poolKey.token0).safeTransferFrom(msg.sender, address(this), desiredAmount0);
    IERC20(farm.poolKey.token1).safeTransferFrom(msg.sender, address(this), desiredAmount1);

    IERC20(farm.poolKey.token0).safeIncreaseAllowance(Constants.NON_FUNGIBLE_POSITION_MANAGER, desiredAmount0);
    IERC20(farm.poolKey.token1).safeIncreaseAllowance(Constants.NON_FUNGIBLE_POSITION_MANAGER, desiredAmount1);

    INonfungiblePositionManager manager = INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER);

    (uint128 addedLiquidity, uint256 usedAmount0, uint256 usedAmount1) = manager.increaseLiquidity(
      INonfungiblePositionManager.IncreaseLiquidityParams({
        tokenId: farm.lp.tokenId,
        amount0Desired: desiredAmount0,
        amount1Desired: desiredAmount1,
        amount0Min: minAmount0,
        amount1Min: minAmount1,
        deadline: deadline
      })
    );

    // Refund unused tokens
    uint256 unusedAmount0 = desiredAmount0 - usedAmount0;
    uint256 unusedAmount1 = desiredAmount1 - usedAmount1;

    if (unusedAmount0 > 0) {
      _safeTransferToken(farm.poolKey.token0, msg.sender, unusedAmount0);
    }

    if (unusedAmount1 > 0) {
      _safeTransferToken(farm.poolKey.token1, msg.sender, unusedAmount1);
    }

    // Update state
    farm.lp.liquidity += addedLiquidity;

    // Reset allowance
    IERC20(farm.poolKey.token0).forceApprove(Constants.NON_FUNGIBLE_POSITION_MANAGER, 0);
    IERC20(farm.poolKey.token1).forceApprove(Constants.NON_FUNGIBLE_POSITION_MANAGER, 0);

    // Track liquidity added by each individual user
    return (addedLiquidity, usedAmount0, usedAmount1);
  }

  function _decreaseLiquidity(
    Farm storage farm,
    uint128 liquidity,
    address to,
    uint256 slippage,
    uint256 deadline
  ) private returns (uint256 amount0, uint256 amount1) {
    INonfungiblePositionManager manager = INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER);
    (, , uint256 minAmount0, uint256 minAmount1) = _getDesiredAmountsForLiquidity(
      farm,
      liquidity,
      slippage > 0 ? slippage : farm.slippage
    );

    (amount0, amount1) = manager.decreaseLiquidity(
      INonfungiblePositionManager.DecreaseLiquidityParams({
        tokenId: farm.lp.tokenId,
        liquidity: liquidity,
        amount0Min: minAmount0,
        amount1Min: minAmount1,
        deadline: deadline
      })
    );

    // Directly transfer tokens to caller
    INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams(
      farm.lp.tokenId,
      to,
      uint128(amount0),
      uint128(amount1)
    );
    manager.collect(params);
    farm.lp.liquidity -= liquidity;
  }

  function _safeTransferToken(address token, address to, uint256 amount) private {
    uint256 balanace = IERC20(token).balanceOf(address(this));

    if (amount > 0) {
      // In case if rounding error causes farm keeper to not have enough tokens.
      if (amount > balanace) {
        IERC20(token).safeTransfer(to, balanace);
      } else {
        IERC20(token).safeTransfer(to, amount);
      }
    }
  }

  function _getTwaPrice(address id, uint32 priceTwa) private view returns (uint160 slotPrice, uint160 twaPrice) {
    // Default to current price
    IUniswapV3Pool pool = IUniswapV3Pool(id);
    (slotPrice, , , , , , ) = pool.slot0();

    // Default TWA price to slot
    twaPrice = slotPrice;

    uint32 secondsAgo = uint32(priceTwa * 60);
    uint32 oldestObservation = 0;

    // Load oldest observation if cardinality greater than zero
    oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(id);

    // Limit to oldest observation (fallback)
    if (oldestObservation < secondsAgo) {
      secondsAgo = oldestObservation;
    }

    // If TWAP is enabled and price history exists, consult oracle
    if (secondsAgo > 0) {
      // Consult the Oracle Library for TWAP
      (int24 arithmeticMeanTick, ) = OracleLibrary.consult(id, secondsAgo);

      // Convert tick to sqrtPriceX96
      twaPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
    }
  }

  function _getDesiredAmountsForLiquidity(
    Farm storage farm,
    uint128 liquidity,
    uint256 slippage
  ) private view returns (uint256 desiredAmount0, uint256 desiredAmount1, uint256 minAmount0, uint256 minAmount1) {
    (uint160 slotPrice, uint160 twaPrice) = _getTwaPrice(
      PoolAddress.computeAddress(Constants.FACTORY, farm.poolKey),
      farm.priceTwa
    );
    Ticks storage tick = ticks[farm.id];

    // Calculate desired amounts based on current slot price
    (desiredAmount0, desiredAmount1) = LiquidityAmounts.getAmountsForLiquidity(
      slotPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      liquidity
    );

    // Calculate minimal amounts based on TWA price for slippage protection
    (minAmount0, minAmount1) = LiquidityAmounts.getAmountsForLiquidity(
      twaPrice,
      TickMath.getSqrtRatioAtTick(tick.minTick),
      TickMath.getSqrtRatioAtTick(tick.maxTick),
      liquidity
    );

    // Apply slippage
    minAmount0 = (minAmount0 * (Constants.BASIS - slippage)) / Constants.BASIS;
    minAmount1 = (minAmount1 * (Constants.BASIS - slippage)) / Constants.BASIS;
  }

  function _getSharesAtBlockTimestamp(
    Farm storage farm
  )
    private
    view
    returns (uint256 accIncentiveTokenPerShare, uint256 accFeePerShareForToken0, uint256 accFeePerShareForToken1)
  {
    accIncentiveTokenPerShare = farm.accIncentiveTokenPerShare;
    accFeePerShareForToken0 = farm.accFeePerShareForToken0;
    accFeePerShareForToken1 = farm.accFeePerShareForToken1;

    // Do not perform any updates if liquidity is zero
    if (farm.lp.liquidity <= 0) {
      return (accIncentiveTokenPerShare, accFeePerShareForToken0, accFeePerShareForToken1);
    }

    UserView memory pending = rootKeeper.userView(rootKeeperFarmId, address(this));
    uint256 pendingGlobalAccIncentiveTokenPerShare = _globalAccIncentiveTokenPerShare;

    if (pending.pendingIncentiveTokens > 0) {
      pendingGlobalAccIncentiveTokenPerShare += Math.mulDiv(
        pending.pendingIncentiveTokens,
        Constants.SCALE_FACTOR_1E18,
        totalAllocPoints
      );
    }

    uint256 pendingIncentiveTokenReward = Math.mulDiv(
      farm.allocPoints,
      pendingGlobalAccIncentiveTokenPerShare,
      Constants.SCALE_FACTOR_1E18
    ) - farm.lastRewardTime;

    if (pendingIncentiveTokenReward > 0) {
      accIncentiveTokenPerShare += Math.mulDiv(
        pendingIncentiveTokenReward,
        Constants.SCALE_FACTOR_1E18,
        farm.lp.liquidity
      );
    }

    // Try update fees if LP token exists
    if (farm.lp.tokenId > 0) {
      (uint256 pendingFeeAmount0, uint256 pendingFeeAmount1) = PositionValue.fees(
        INonfungiblePositionManager(Constants.NON_FUNGIBLE_POSITION_MANAGER),
        farm.lp.tokenId
      );

      bool isInputToken0 = buyAndBurn.isInputToken(farm.poolKey.token0);
      bool isInputToken1 = buyAndBurn.isInputToken(farm.poolKey.token1);

      if (!isInputToken0 && pendingFeeAmount0 > 0) {
        accFeePerShareForToken0 += Math.mulDiv(pendingFeeAmount0, Constants.SCALE_FACTOR_1E18, farm.lp.liquidity);
      }

      if (!isInputToken1 && pendingFeeAmount1 > 0) {
        accFeePerShareForToken1 += Math.mulDiv(pendingFeeAmount1, Constants.SCALE_FACTOR_1E18, farm.lp.liquidity);
      }
    }
  }

  function _validatePriceTwa(uint32 mins) private pure {
    if (mins < 5 || mins > 60) revert InvalidPriceTwa();
  }

  function _validateSlippage(uint256 slippage) private pure {
    if (slippage < 1 || slippage > 2500) revert InvalidSlippage();
  }

  function _validateProtocolFee(uint256 fee) private pure {
    if (fee > 2500) revert InvalidFee();
  }

  function _validateAllocPoints(uint256 allocPoints) private pure {
    if (allocPoints > Constants.MAX_ALLOCATION_POINTS) revert InvalidAllocPoints();
  }

  function _validateTicks(uint24 fee, int24 minTick, int24 maxTick) private pure {
    // Check that minTick and maxTick are within the global limits
    if (minTick < Constants.MIN_TICK || maxTick > Constants.MAX_TICK) revert InvalidTicks();

    // Check that minTick is less than maxTick
    require(minTick < maxTick, 'minTick must be less than maxTick');

    // Validate tick alignment with fee-specific tick spacing
    int24 tickSpacing = _getTickSpacing(fee);
    if (minTick % tickSpacing != 0 || maxTick % tickSpacing != 0) revert InvalidTicks();
  }

  // Function to get tick spacing based on fee tier
  function _getTickSpacing(uint24 fee) private pure returns (int24) {
    if (fee == 100) return 1; // 0.01% fee tier
    if (fee == 500) return 10; // 0.05% fee tier
    if (fee == 3000) return 60; // 0.3% fee tier
    if (fee == 10000) return 200; // 1% fee tier
    if (fee == 20000) return 4; // 0.02% fee tier
    if (fee == 30000) return 6; // 0.03% fee tier
    if (fee == 40000) return 8; // 0.04% fee tier

    revert InvalidTicks();
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// OpenZeppelins
import '@openzeppelin/contracts/access/manager/AccessManager.sol';
import '@openzeppelin/contracts/access/manager/AccessManaged.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/Multicall.sol';
import '@openzeppelin/contracts/utils/math/SafeCast.sol';

// Library
import './lib/Constants.sol';
import './lib/InputTokens.sol';
import './lib/uniswap/PoolAddress.sol';
import './lib/uniswap/Oracle.sol';
import './lib/uniswap/TickMath.sol';
import './lib/uniswap/PathDecoder.sol';

// Interfaces
import './interfaces/IBurnProxy.sol';
import './interfaces/IPermit2.sol';
import './interfaces/IUniversalRouter.sol';
import './interfaces/IOutputToken.sol';
import './interfaces/IFarmKeeper.sol';
import './interfaces/IUniswapV3Pool.sol';

/**
 * @title UniversalBuyAndBurn
 * @notice A contract for buying and burning an output token using various ERC20 input tokens
 * @dev This contract enables a flexible buy-and-burn mechanism for tokenomics management
 *
 *  ██████╗ ██╗   ██╗██╗   ██╗     ██████╗     ██████╗ ██╗   ██╗██████╗ ███╗   ██╗
 *  ██╔══██╗██║   ██║╚██╗ ██╔╝    ██╔════╝     ██╔══██╗██║   ██║██╔══██╗████╗  ██║
 *  ██████╔╝██║   ██║ ╚████╔╝     ███████╗     ██████╔╝██║   ██║██████╔╝██╔██╗ ██║
 *  ██╔══██╗██║   ██║  ╚██╔╝      ╚════██║     ██╔══██╗██║   ██║██╔══██╗██║╚██╗██║
 *  ██████╔╝╚██████╔╝   ██║       ███████║     ██████╔╝╚██████╔╝██║  ██║██║ ╚████║
 *  ╚═════╝  ╚═════╝    ╚═╝       ╚══════╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
 *
 * Key features:
 * - Supports multiple input tokens for buying and burning a single output token
 * - Configurable parameters for each input token (e.g., cap per swap, cooldown interval, incentive fee)
 * - Direct burning of input tokens or swapping for output tokens before burning
 * - Uses Uniswap V3 for token swaps with customizable swap paths
 * - Implements a Time-Weighted Average Price (TWAP) mechanism for price quotes
 * - Includes slippage protection for swaps
 * - Provides incentives for users triggering the buy-and-burn process
 *
 * Security features:
 * - Access control using OpenZeppelin's AccessManaged
 * - Reentrancy protection
 * - Cooldown periods between buy-and-burn operations
 *
 * Restrictions:
 * - Requires a deployment of the UniSwap Universal Router
 * - Limits Swap paths to V3 pools only
 */
contract UniversalBuyAndBurn is AccessManaged, ReentrancyGuard, Multicall {
  using InputTokens for InputTokens.Map;
  using PathDecoder for PathDecoder.Hop;
  using SafeERC20 for IERC20;

  // -----------------------------------------
  // Type declarations
  // -----------------------------------------

  /**
   * @notice Function parameters to pass when enabling a new input token
   */
  struct EnableInputToken {
    address id;
    uint256 capPerSwap;
    uint256 interval;
    uint256 incentiveFee;
    IBurnProxy burnProxy;
    uint256 burnPercentage;
    uint32 priceTwa;
    uint256 slippage;
    bytes path;
    bool paused;
  }

  // -----------------------------------------
  // State variables
  // -----------------------------------------
  InputTokens.Map private _inputTokens;

  /**
   * @dev Tracks the total amount of output tokens purchased and burned.
   * This accumulates the output tokens bought and subsequently burned over time.
   */
  uint256 public totalOutputTokensBurned;

  /**
   * @dev The output token. A public burn function with a
   * function signature function burn(uint256 amount) is mandatory.
   */
  IOutputToken public outputToken;

  // -----------------------------------------
  // Events
  // -----------------------------------------
  /**
   * @notice Emitted when output tokens are bought with an input token and are subsequently burned.
   * @dev This event indicates both the purchase and burning of output tokens in a single transaction.
   * Depending on the input token settings, might also burn input tokens directly.
   * @param inputTokenAddress The input token address.
   * @param toBuy The amount of input tokens used to buy and burn the output token.
   * @param toBurn The amount of input tokens directly burned.
   * @param incentiveFee The amout of input tokens payed as incentive fee to run the function.
   * @param outputTokensBurned The amount of output tokens burned.
   * @param caller The function caller
   */
  event BuyAndBurn(
    address indexed inputTokenAddress,
    uint256 toBuy,
    uint256 toBurn,
    uint256 incentiveFee,
    uint256 outputTokensBurned,
    address caller
  );

  /**
   * @notice Emitted when a new input token is activated for the first time
   * @param inputTokenAddress the Input Token Identifier (address)
   */
  event InputTokenEnabled(address indexed inputTokenAddress, EnableInputToken params);

  /**
   * Events emitted when a input token parameter is updated
   */
  event CapPerSwapUpdated(address indexed inputTokenAddress, uint256 newCap);
  event BuyAndBurnIntervalUpdated(address indexed inputTokenAddress, uint256 newInterval);
  event IncentiveFeeUpdated(address indexed inputTokenAddress, uint256 newFee);
  event SlippageUpdated(address indexed inputTokenAddress, uint256 newSlippage);
  event PriceTwaUpdated(address indexed inputTokenAddress, uint32 newTwa);
  event BurnPercentageUpdated(address indexed inputTokenAddress, uint256 newPercentage);
  event BurnProxyUpdated(address indexed inputTokenAddress, address newProxy);
  event SwapPathUpdated(address indexed inputTokenAddress, bytes newPath);
  event PausedUpdated(address indexed inputTokenAddress, bool paused);
  event DisabledUpdated(address indexed inputTOkenAddress, bool disabled);

  // -----------------------------------------
  // Errors
  // -----------------------------------------
  error InvalidCaller();
  error CooldownPeriodActive();
  error NoInputTokenBalance();
  error InvalidInputTokenAddress();
  error InputTokenAlreadyEnabled();
  error InvalidCapPerSwap();
  error InvalidInterval();
  error InvalidIncentiveFee();
  error InvalidBurnProxy();
  error InvalidBurnPercentage();
  error InvalidPriceTwa();
  error InvalidSlippage();
  error InvalidSwapPath();
  error InputTokenPaused();

  // -----------------------------------------
  // Modifiers
  // -----------------------------------------

  // -----------------------------------------
  // Constructor
  // -----------------------------------------
  /**
   * @notice Creates a new instance of the contract.
   */
  constructor(IOutputToken outputToken_, address manager) AccessManaged(manager) {
    // store the output token interface
    outputToken = outputToken_;
  }

  // -----------------------------------------
  // Receive function
  // -----------------------------------------

  // -----------------------------------------
  // Fallback function
  // -----------------------------------------

  // -----------------------------------------
  // External functions
  // -----------------------------------------
  /**
   * @notice Buys Output tokens using an input token and then burns them.
   * @dev This function swaps an approved input token for Output tokens using the universal swap router,
   *      then burns the Output tokens.
   *      It includes security checks to prevent abuse (e.g., reentrancy, bot interactions, cooldown periods).
   *      The function also handles an incentive fee for the caller and can burn input tokens directly if specified.
   * @param inputTokenAddress The address of the input token to be used for buying Output tokens.
   * @custom:events Emits a BoughtAndBurned event after successfully buying and burning Output tokens.
   * @custom:security nonReentrant
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidCaller Thrown if the caller is not the transaction origin (prevents contract calls).
   * @custom:error NoInputTokenBalance Thrown if there are no tokens left in the contract.
   * @custom:error CooldownPeriodActive Thrown if the function is called before the cooldown period has elapsed.
   * @custom:error InputTokenPaused Thrown if the buyAndBurn for the specified input token is paused.
   */
  function buyAndBurn(address inputTokenAddress) external nonReentrant {
    // Ensure processing a valid input token
    if (!_inputTokens.contains(inputTokenAddress)) {
      revert InvalidInputTokenAddress();
    }
    InputToken storage inputTokenInfo = _inputTokens.get(inputTokenAddress);

    // prevent contract accounts (bots) from calling this function
    // becomes obsolete with EIP-3074, there are other measures in
    // place to make MEV attacks inefficient (cap per swap, interval control)
    if (msg.sender != tx.origin) {
      revert InvalidCaller();
    }

    if (inputTokenInfo.paused) {
      revert InputTokenPaused();
    }

    // keep a minium gap of interval between each call
    // update stored timestamp
    if (block.timestamp - inputTokenInfo.lastCallTs <= inputTokenInfo.interval) {
      revert CooldownPeriodActive();
    }
    inputTokenInfo.lastCallTs = block.timestamp;

    // Get the input token amount to buy and incentive fee
    // this call will revert if there are no input tokens left in the contract
    (uint256 toBuy, uint256 toBurn, uint256 incentiveFee) = _getAmounts(inputTokenInfo);

    if (toBuy == 0 && toBurn == 0) {
      revert NoInputTokenBalance();
    }

    // Burn Input Tokens
    if (toBurn > 0) {
      // Send tokens to the burn proxy
      IERC20(inputTokenAddress).safeTransfer(address(inputTokenInfo.burnProxy), toBurn);

      // Execute burn
      inputTokenInfo.burnProxy.burn();
    }

    // Buy Output Tokens and burn them
    uint256 outputTokensBought = 0;
    if (toBuy > 0) {
      uint256 estimatedMinimumOutput = estimateMinimumOutputAmount(
        inputTokenInfo.path,
        inputTokenInfo.slippage,
        inputTokenInfo.priceTwa,
        toBuy
      );

      _approveForSwap(inputTokenAddress, toBuy);

      // Commands for the Universal Router
      bytes memory commands = abi.encodePacked(
        bytes1(0x00) // V3 swap exact input
      );

      // Inputs for the Universal Router
      bytes[] memory inputs = new bytes[](1);
      inputs[0] = abi.encode(
        address(this), // Recipient is the buy and burn contract
        toBuy,
        estimatedMinimumOutput,
        inputTokenInfo.path,
        true // Payer is the buy and burn contract
      );

      uint256 balanceBefore = outputToken.balanceOf(address(this));

      // Execute the swap
      IUniversalRouter(Constants.UNIVERSAL_ROUTER).execute(commands, inputs, block.timestamp);
      outputTokensBought = outputToken.balanceOf(address(this)) - balanceBefore;

      // Burn the tokens bought
      outputToken.burn(outputTokensBought);
    }

    if (incentiveFee > 0) {
      // Send incentive fee
      IERC20(inputTokenAddress).safeTransfer(msg.sender, incentiveFee);
    }

    // Update state
    inputTokenInfo.totalTokensUsedForBuyAndBurn += toBuy;
    inputTokenInfo.totalTokensBurned += toBurn;
    inputTokenInfo.totalIncentiveFee += incentiveFee;

    totalOutputTokensBurned += outputTokensBought;

    // Emit events
    emit BuyAndBurn(inputTokenAddress, toBuy, toBurn, incentiveFee, outputTokensBought, msg.sender);
  }

  /**
   * @notice Enables a new input token for buyAndBurn operations.
   * @dev This function can only be called by the contract owner or authorized addresses.
   *      It sets up all necessary parameters for a new input token.
   * @param params A struct containing all the parameters for the new input token.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is zero.
   * @custom:error InputTokenAlreadyEnabled Thrown if the input token is already enabled.
   * @custom:error Various errors for invalid parameter values (see validation functions).
   * @custom:event Emits an InputTokenEnabled event with the new input token address and all its parameters.
   */
  function enableInputToken(EnableInputToken calldata params) external restricted {
    if (params.id == address(0)) revert InvalidInputTokenAddress();
    if (_inputTokens.contains(params.id)) revert InputTokenAlreadyEnabled();

    _validateCapPerSwap(params.capPerSwap);
    _validateInterval(params.interval);
    _validateIncentiveFee(params.incentiveFee);
    _validateBurnProxy(address(params.burnProxy));
    _validateBurnPercentage(params.burnPercentage);
    _validatePriceTwa(params.priceTwa);
    _validateSlippage(params.slippage);

    // Allow to enable an input token without a valid path
    // if all tokens are burned
    if (params.burnPercentage < Constants.BASIS) {
      _validatePath(PathDecoder.decode(params.path));
    }

    _inputTokens.add(
      InputToken({
        id: params.id,
        totalTokensUsedForBuyAndBurn: 0,
        totalTokensBurned: 0,
        totalIncentiveFee: 0,
        lastCallTs: 0,
        capPerSwap: params.capPerSwap,
        interval: params.interval,
        incentiveFee: params.incentiveFee,
        burnProxy: IBurnProxy(params.burnProxy),
        burnPercentage: params.burnPercentage,
        priceTwa: params.priceTwa,
        slippage: params.slippage,
        path: params.path,
        paused: params.paused,
        disabled: false
      })
    );

    emit InputTokenEnabled(params.id, params);
  }

  /**
   * @notice Sets the maximum amount of input tokens that can be used per buyAndBurn call.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the cap.
   * @param amount The maximum amount of input tokens allowed per swap, in the token's native decimals.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidCapPerSwap Thrown if the cap per swap is zero.
   * @custom:event Emits a CapPerSwapUpdated event with the input token address and new cap value.
   */
  function setCapPerSwap(address inputTokenAddress, uint256 amount) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateCapPerSwap(amount);
    _inputTokens.get(inputTokenAddress).capPerSwap = amount;
    emit CapPerSwapUpdated(inputTokenAddress, amount);
  }

  /**
   * @notice Sets the minimum time interval between buyAndBurn calls for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the interval.
   * @param secs The cooldown period in seconds between buyAndBurn calls.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidInterval Thrown if the interval is not between 60
   *               seconds (1 minute) and 43200 seconds (12 hours).
   * @custom:event Emits a BuyAndBurnIntervalUpdated event with the input token address and new interval value.
   */
  function setBuyAndBurnInterval(address inputTokenAddress, uint256 secs) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateInterval(secs);
    _inputTokens.get(inputTokenAddress).interval = secs;
    emit BuyAndBurnIntervalUpdated(inputTokenAddress, secs);
  }

  /**
   * @notice Sets the incentive fee percentage for buyAndBurn calls for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the incentive fee.
   * @param incentiveFee The incentive fee in basis points (0 = 0.0%, 1000 = 10%).
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidIncentiveFee Thrown if the incentive fee is not between 0 (0.0%) and 1000 (10%).
   * @custom:event Emits an IncentiveFeeUpdated event with the input token address and new fee value.
   */
  function setIncentiveFee(address inputTokenAddress, uint256 incentiveFee) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateIncentiveFee(incentiveFee);
    _inputTokens.get(inputTokenAddress).incentiveFee = incentiveFee;
    emit IncentiveFeeUpdated(inputTokenAddress, incentiveFee);
  }

  /**
   * @notice Sets the slippage tolerance percentage for buyAndBurn swaps for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the slippage tolerance.
   * @param slippage The slippage tolerance in basis points (1 = 0.01%, 2500 = 25%).
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidSlippage Thrown if the slippage is not between 1 (0.01%) and 2500 (25%).
   * @custom:event Emits a SlippageUpdated event with the input token address and new slippage value.
   */
  function setSlippage(address inputTokenAddress, uint256 slippage) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateSlippage(slippage);
    _inputTokens.get(inputTokenAddress).slippage = slippage;
    emit SlippageUpdated(inputTokenAddress, slippage);
  }

  /**
   * @notice Sets the Time-Weighted Average (TWA) period for price quotes used in buyAndBurn
   * swaps for a specific input token. Allows to disable TWA by setting mins to zero.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the TWA period.
   * @param mins The TWA period in minutes.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidPriceTwa Thrown if the TWA period is not between 0 minutes and 60 minutes (1 hour).
   * @custom:event Emits a PriceTwaUpdated event with the input token address and new TWA value.
   */
  function setPriceTwa(address inputTokenAddress, uint32 mins) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validatePriceTwa(mins);
    _inputTokens.get(inputTokenAddress).priceTwa = mins;
    emit PriceTwaUpdated(inputTokenAddress, mins);
  }

  /**
   * @notice Sets the percentage of input tokens to be directly burned in buyAndBurn
   * operations for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the burn percentage.
   * @param burnPercentage The percentage of input tokens to be burned, expressed in basis points (0-10000).
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidBurnPercentage Thrown if the burn percentage is greater than 10000 basis points (100%).
   * @custom:event Emits a BurnPercentageUpdated event with the input token address and new burn percentage value.
   */
  function setBurnPercentage(address inputTokenAddress, uint256 burnPercentage) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateBurnPercentage(burnPercentage);

    InputToken storage token = _inputTokens.get(inputTokenAddress);

    if (burnPercentage < Constants.BASIS) {
      // Ensure a valid path exists if burn percentage is less than 100%
      if (token.path.length < PathDecoder.V3_POP_OFFSET) {
        revert InvalidSwapPath();
      }

      _validatePath(PathDecoder.decode(token.path));
    }

    token.burnPercentage = burnPercentage;
    emit BurnPercentageUpdated(inputTokenAddress, burnPercentage);
  }

  /**
   * @notice Sets the burn proxy address for a specific input token in buyAndBurn operations.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the burn proxy.
   * @param proxy The address of the burn proxy contract.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidBurnProxy Thrown if the proxy address is set to the zero address.
   * @custom:event Emits a BurnProxyUpdated event with the input token address and new burn proxy address.
   */
  function setBurnProxy(address inputTokenAddress, address proxy) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validateBurnProxy(proxy);
    _inputTokens.get(inputTokenAddress).burnProxy = IBurnProxy(proxy);
    emit BurnProxyUpdated(inputTokenAddress, proxy);
  }

  /**
   * @notice Sets the Uniswap swap path for a specific input token in buyAndBurn operations.
   * @dev This function can only be called by the contract owner or authorized addresses.
   * @param inputTokenAddress The address of the input token for which to set the swap path.
   * @param path The encoded swap path as a bytes array.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:error InvalidSwapPath Thrown if the provided path is invalid (does not end with the output token).
   * @custom:event Emits a SwapPathUpdated event with the input token address and new swap path.
   */
  function setSwapPath(address inputTokenAddress, bytes calldata path) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _validatePath(PathDecoder.decode(path));
    _inputTokens.get(inputTokenAddress).path = path;
    emit SwapPathUpdated(inputTokenAddress, path);
  }

  /**
   * @notice Pauses or unpauses buyAndBurn for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   *      It allows for temporary suspension of buyAndBurn operations for a particular input token.
   * @param inputTokenAddress The address of the input token for which to set the pause state.
   * @param paused True to pause operations, false to unpause.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:event Emits a PausedUpdated event with the input token address and new pause state.
   */
  function setPaused(address inputTokenAddress, bool paused) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();
    _inputTokens.get(inputTokenAddress).paused = paused;
    emit PausedUpdated(inputTokenAddress, paused);
  }

  /**
   * @notice Sets the disabled state for a specific input token.
   * @dev This function can only be called by the contract owner or authorized addresses.
   *      It marks the specified input token as disabled or enabled, affecting its usability by
   *      external contracts interacting with the universal buy and burn instance. This does not
   *      directly pause buyAndBurn operations; use `setPaused` to pause them.
   * @param farmKeeper the farm keeper address to trigger updates when disabling a token
   * @param farmIds the farm to update
   * @param inputTokenAddress The address of the input token for which to set the disabled state.
   * @param disabled True to disable the token, false to enable.
   * @custom:security restricted
   * @custom:error InvalidInputTokenAddress Thrown if the input token address is not approved.
   * @custom:event DisabledUpdated Emitted with the input token address and new disabled state.
   */
  function setDisabled(
    address farmKeeper,
    address[] calldata farmIds,
    address inputTokenAddress,
    bool disabled
  ) external restricted {
    if (!_inputTokens.contains(inputTokenAddress)) revert InvalidInputTokenAddress();

    if (farmKeeper != address(0)) {
      for (uint256 idx = 0; idx < farmIds.length; idx++) {
        IFarmKeeper(farmKeeper).updateFarm(farmIds[idx], true);
      }
    }

    _inputTokens.get(inputTokenAddress).disabled = disabled;
    emit DisabledUpdated(inputTokenAddress, disabled);
  }

  /**
   * @notice Retrieves an array of all registered input tokens and their current states.
   * @dev This function provides a comprehensive view of all input tokens, including
   *      calculated values for the next buyAndBurn operation.
   * @return InputTokenView[] An array of InputTokenView structs, each containing
   *         detailed information about an input token.
   * @custom:struct InputTokenView {
   *   address id;                      // Address of the input token
   *   uint256 totalTokensUsedForBuyAndBurn;  // Total amount of tokens used to buy and burn output tokens
   *   uint256 totalTokensBurned;       // Total amount of tokens directly burned
   *   uint256 totalIncentiveFee;       // Total amount of tokens paid as incentive fees
   *   uint256 lastCallTs;              // Timestamp of the last buyAndBurn call
   *   uint256 capPerSwap;              // Maximum amount allowed per swap
   *   uint256 interval;                // Cooldown period between buyAndBurn calls
   *   uint256 incentiveFee;            // Current incentive fee percentage
   *   address burnProxy;               // Address of the burn proxy contract
   *   uint256 burnPercentage;          // Percentage of tokens to be directly burned
   *   uint32 priceTwa;                 // Time-Weighted Average period for price quotes
   *   uint256 slippage;                // Slippage tolerance for swaps
   *   bool paused;                     // Buy and burn with the given input token is paused
   *   uint256 balance;                 // Current balance of the token in this contract
   *   uint256 nextToBuy;               // Amount to be used for buying in the next operation
   *   uint256 nextToBurn;              // Amount to be directly burned in the next operation
   *   uint256 nextIncentiveFee;        // Incentive fee for the next operation
   *   uint256 nextCall;                // The UTC timestamp when buy and burn can be called next
   * }
   */
  function inputTokens() external view returns (InputTokenView[] memory) {
    InputToken[] memory tokens = _inputTokens.values();
    InputTokenView[] memory views = new InputTokenView[](tokens.length);

    for (uint256 idx = 0; idx < tokens.length; idx++) {
      views[idx] = inputToken(tokens[idx].id);
    }

    return views;
  }

  /**
   * @notice Checks if a given address is registered as an input token.
   * @dev This function provides a way to verify if an address is in the list of approved input tokens.
   * It returns true if the address is a registered input token and is not disabled. This function can be used
   * by external contracts to determine if they should interact with the universal buy and burn instance using
   * the specified input token. Note that even if the function returns false, it is still possible to send
   * funds to the buy and burn instance, but such actions may not be desired or expected.
   *
   * @param inputTokenAddress The address to check.
   * @return bool Returns true if the address is a registered and active input token (not disabled),
   * false otherwise.
   */
  function isInputToken(address inputTokenAddress) external view returns (bool) {
    if (_inputTokens.contains(inputTokenAddress)) {
      return !_inputTokens.get(inputTokenAddress).disabled;
    }

    return false;
  }

  // -----------------------------------------
  // Public functions
  // -----------------------------------------
  /**
   * @notice Retrieves the InputTokenView for a specific input token.
   * @param inputTokenAddress The address of the input token to query.
   * @return inputTokenView The InputTokenView struct containing all information about the specified input token.
   */
  function inputToken(address inputTokenAddress) public view returns (InputTokenView memory inputTokenView) {
    InputToken memory token = _inputTokens.get(inputTokenAddress);

    inputTokenView.id = token.id;
    inputTokenView.totalTokensUsedForBuyAndBurn = token.totalTokensUsedForBuyAndBurn;
    inputTokenView.totalTokensBurned = token.totalTokensBurned;
    inputTokenView.totalIncentiveFee = token.totalIncentiveFee;
    inputTokenView.lastCallTs = token.lastCallTs;
    inputTokenView.capPerSwap = token.capPerSwap;
    inputTokenView.interval = token.interval;
    inputTokenView.incentiveFee = token.incentiveFee;
    inputTokenView.burnProxy = address(token.burnProxy);
    inputTokenView.burnPercentage = token.burnPercentage;
    inputTokenView.priceTwa = token.priceTwa;
    inputTokenView.slippage = token.slippage;
    inputTokenView.paused = token.paused;
    inputTokenView.disabled = token.disabled;
    inputTokenView.path = token.path;

    inputTokenView.balance = IERC20(token.id).balanceOf(address(this));
    (uint256 toBuy, uint256 toBurn, uint256 incentiveFee) = _getAmounts(token);

    inputTokenView.nextToBuy = toBuy;
    inputTokenView.nextToBurn = toBurn;
    inputTokenView.nextIncentiveFee = incentiveFee;
    inputTokenView.nextCall = token.lastCallTs + token.interval + 1;
  }

  /**
   * @notice Get a quote for output token for a given input token amount
   * @dev Uses Time-Weighted Average Price (TWAP) and falls back to the pool price if TWAP is not available.
   * @param inputTokenAddress Address of an ERC20 token contract used as the input token
   * @param outputTokenAddress Address of an ERC20 token contract used as the output token
   * @param fee The fee tier of the pool
   * @param twap The time period in minutes for TWAP calculation (can be set to zero to fallback to pool ratio)
   * @param inputTokenAmount The amount of input token for which the output token quote is needed
   * @return quote The amount of output token
   * @dev This function computes the TWAP of output token in terms of the input token
   *      using the Uniswap V3 pools and the Oracle Library.
   * @dev Limitations: This function assumes both input and output tokens have 18 decimals.
   *      For tokens with different decimals, additional scaling would be required.
   */
  function getQuote(
    address inputTokenAddress,
    address outputTokenAddress,
    uint24 fee,
    uint256 twap,
    uint256 inputTokenAmount
  ) public view returns (uint256 quote, uint32 secondsAgo) {
    address poolAddress = PoolAddress.computeAddress(
      Constants.FACTORY,
      PoolAddress.getPoolKey(inputTokenAddress, outputTokenAddress, fee)
    );

    // Default to current price
    IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
    (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();

    secondsAgo = uint32(twap * 60);
    uint32 oldestObservation = 0;

    // Load oldest observation if cardinality greather than zero
    oldestObservation = OracleLibrary.getOldestObservationSecondsAgo(poolAddress);

    // Limit to oldest observation
    if (oldestObservation < secondsAgo) {
      secondsAgo = oldestObservation;
    }

    // If TWAP is enabled and price history exists, consult oracle
    if (secondsAgo > 0) {
      // Consult the Oracle Library for TWAP
      (int24 arithmeticMeanTick, ) = OracleLibrary.consult(poolAddress, secondsAgo);

      // Convert tick to sqrtPriceX96
      sqrtPriceX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
    }

    return (
      OracleLibrary.getQuoteForSqrtRatioX96(sqrtPriceX96, inputTokenAmount, inputTokenAddress, outputTokenAddress),
      secondsAgo
    );
  }

  /**
   * @notice Calculate Minimum Amount Out for a swap along a path (including multiple hops)
   * @dev Calculates the minimum amount of output tokens expected along a swap path
   * @param path The encoded swap path
   * @param slippage The allowed slippage in basis points (e.g., 100 for 1%)
   * @param twap The time period in minutes for TWAP calculation
   * @param inputAmount The amount of input tokens to be swapped
   * @return amountOutMinimum The minimum amount of output tokens expected from the swap
   * @dev Limitations:
   *      1. The slippage is applied to the final output amount, not to each hop individually.
   *      2. This calculation does not account for potential price impact of the swap itself.
   */
  function estimateMinimumOutputAmount(
    bytes memory path,
    uint256 slippage,
    uint256 twap,
    uint256 inputAmount
  ) public view returns (uint256 amountOutMinimum) {
    PathDecoder.Hop[] memory hops = PathDecoder.decode(path);
    uint256 currentAmount = inputAmount;

    for (uint256 idx = 0; idx < hops.length; idx++) {
      (currentAmount, ) = getQuote(hops[idx].tokenIn, hops[idx].tokenOut, hops[idx].fee, twap, currentAmount);
    }

    // Apply slippage to the final amount
    amountOutMinimum = (currentAmount * (Constants.BASIS - slippage)) / Constants.BASIS;
  }

  // -----------------------------------------
  // Internal functions
  // -----------------------------------------

  // -----------------------------------------
  // Private functions
  // -----------------------------------------
  function _getAmounts(
    InputToken memory inputTokenInfo
  ) private view returns (uint256 toBuy, uint256 toBurn, uint256 incentiveFee) {
    IERC20 token = IERC20(inputTokenInfo.id);

    // Core Token Balance of this contract
    uint256 inputAmount = token.balanceOf(address(this));
    uint256 capPerSwap = inputTokenInfo.capPerSwap;
    if (inputAmount > capPerSwap) {
      inputAmount = capPerSwap;
    }

    if (inputAmount == 0) {
      return (0, 0, 0);
    }

    incentiveFee = (inputAmount * inputTokenInfo.incentiveFee) / Constants.BASIS;
    inputAmount -= incentiveFee;

    if (inputTokenInfo.burnPercentage == Constants.BASIS) {
      // Burn 100% of the input tokens
      return (0, inputAmount, incentiveFee);
    } else if (inputTokenInfo.burnPercentage == 0) {
      // Burn 0% of the input tokens
      return (inputAmount, 0, incentiveFee);
    }

    // Calculate amounts
    toBurn = (inputAmount * inputTokenInfo.burnPercentage) / Constants.BASIS;
    toBuy = inputAmount - toBurn;

    return (toBuy, toBurn, incentiveFee);
  }

  function _approveForSwap(address token, uint256 amount) private {
    // Approve transfer via permit2
    IERC20(token).safeIncreaseAllowance(Constants.PERMIT2, amount);

    // Give universal router access to tokens via permit2
    // If the inputted expiration is 0, the allowance only lasts the duration of the block.
    IPermit2(Constants.PERMIT2).approve(token, Constants.UNIVERSAL_ROUTER, SafeCast.toUint160(amount), 0);
  }

  function _validatePath(PathDecoder.Hop[] memory hops) private view {
    if (hops[hops.length - 1].tokenOut != address(outputToken)) {
      revert InvalidSwapPath();
    }
  }

  function _validateCapPerSwap(uint256 amount) private pure {
    if (amount == 0) revert InvalidCapPerSwap();
  }

  function _validateInterval(uint256 secs) private pure {
    if (secs < 60 || secs > 43200) revert InvalidInterval();
  }

  function _validateIncentiveFee(uint256 fee) private pure {
    if (fee > 1000) revert InvalidIncentiveFee();
  }

  function _validateBurnProxy(address proxy) private pure {
    if (proxy == address(0)) revert InvalidBurnProxy();
  }

  function _validateBurnPercentage(uint256 percentage) private pure {
    if (percentage > Constants.BASIS) revert InvalidBurnPercentage();
  }

  function _validatePriceTwa(uint32 mins) private pure {
    if (mins > 60) revert InvalidPriceTwa();
  }

  function _validateSlippage(uint256 slippage) private pure {
    if (slippage < 1 || slippage > 2500) revert InvalidSlippage();
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IBurnProxy {
  /**
   * @dev Burns all tokens held by this contract and updates the total burned tokens count.
   *
   *      The function retrieves the balance of token to burn
   *      held by the contract itself. If the balance is non-zero, it proceeds to burn
   *      those tokens however possible. After burning the tokens, it updates
   *      state variable to reflect the new total amount of burned tokens.
   *      Finally, it emits a `Burned` event indicating
   *      the address that initiated the burn and the amount of tokens burned.
   *
   * Emits a `Burned` event with the caller's address and the amount burned.
   */
  function burn() external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import '../lib/Farms.sol';

/**
 * @dev Interface for the (non-pegged) farm keeper
 */
interface IFarmKeeper {
  function updateFarm(address id, bool collectFees) external;

  function farmView(address id) external view returns (FarmView memory);

  function userView(address id, address userId) external view returns (UserView memory);

  function deposit(address id, uint128 liquidity, uint256 deadline) external;

  function getLiquidityForAmount(
    address id,
    address token,
    uint256 amount
  ) external view returns (address token0, address token1, uint128 liquidity, uint256 amount0, uint256 amount1);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// OpenZeppelin
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol';

/**
 * @title IIncentiveToken
 * @dev Interface for the Incentive Token, extending standard ERC20 and ERC20Permit functionality
 */
interface IIncentiveToken is IERC20, IERC20Permit {
  /**
   * @notice Mints new tokens to a specified account
   * @dev This function can only be called by the FarmKeeper contract
   * @param account The address that will receive the minted tokens
   * @param amount The amount of tokens to mint
   */
  function mint(address account, uint256 amount) external;

  /**
   * @notice Returns the address of the current owner
   * @dev This function allows the FarmKeeper contract to verify ownership
   * @return The address of the current owner
   */
  function owner() external view returns (address);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;
pragma abicoder v2;

/// @title Non-fungible token for positions
/// @notice Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
/// and authorized.
interface INonfungiblePositionManager {
  /// @notice Emitted when liquidity is increased for a position NFT
  /// @dev Also emitted when a token is minted
  /// @param tokenId The ID of the token for which liquidity was increased
  /// @param liquidity The amount by which liquidity for the NFT position was increased
  /// @param amount0 The amount of token0 that was paid for the increase in liquidity
  /// @param amount1 The amount of token1 that was paid for the increase in liquidity
  event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
  /// @notice Emitted when liquidity is decreased for a position NFT
  /// @param tokenId The ID of the token for which liquidity was decreased
  /// @param liquidity The amount by which liquidity for the NFT position was decreased
  /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
  /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
  event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
  /// @notice Emitted when tokens are collected for a position NFT
  /// @dev The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior
  /// @param tokenId The ID of the token for which underlying tokens were collected
  /// @param recipient The address of the account that received the collected tokens
  /// @param amount0 The amount of token0 owed to the position that was collected
  /// @param amount1 The amount of token1 owed to the position that was collected
  event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

  /// @notice Returns the position information associated with a given token ID.
  /// @dev Throws if the token ID is not valid.
  /// @param tokenId The ID of the token that represents the position
  /// @return nonce The nonce for permits
  /// @return operator The address that is approved for spending
  /// @return token0 The address of the token0 for a specific pool
  /// @return token1 The address of the token1 for a specific pool
  /// @return fee The fee associated with the pool
  /// @return tickLower The lower end of the tick range for the position
  /// @return tickUpper The higher end of the tick range for the position
  /// @return liquidity The liquidity of the position
  /// @return feeGrowthInside0LastX128 The fee growth of token0 as of the last action on the individual position
  /// @return feeGrowthInside1LastX128 The fee growth of token1 as of the last action on the individual position
  /// @return tokensOwed0 The uncollected amount of token0 owed to the position as of the last computation
  /// @return tokensOwed1 The uncollected amount of token1 owed to the position as of the last computation
  function positions(
    uint256 tokenId
  )
    external
    view
    returns (
      uint96 nonce,
      address operator,
      address token0,
      address token1,
      uint24 fee,
      int24 tickLower,
      int24 tickUpper,
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    );

  struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
  }

  /// @notice Creates a new position wrapped in a NFT
  /// @dev Call this when the pool does exist and is initialized. Note that if the pool is created but not initialized
  /// a method does not exist, i.e. the pool is assumed to be initialized.
  /// @param params The params necessary to mint a position, encoded as `MintParams` in calldata
  /// @return tokenId The ID of the token that represents the minted position
  /// @return liquidity The amount of liquidity for this position
  /// @return amount0 The amount of token0
  /// @return amount1 The amount of token1
  function mint(
    MintParams calldata params
  ) external payable returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
  /// @param params tokenId The ID of the token for which liquidity is being increased,
  /// amount0Desired The desired amount of token0 to be spent,
  /// amount1Desired The desired amount of token1 to be spent,
  /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
  /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
  /// deadline The time by which the transaction must be included to effect the change
  /// @return liquidity The new liquidity amount as a result of the increase
  /// @return amount0 The amount of token0 to acheive resulting liquidity
  /// @return amount1 The amount of token1 to acheive resulting liquidity
  function increaseLiquidity(
    IncreaseLiquidityParams calldata params
  ) external payable returns (uint128 liquidity, uint256 amount0, uint256 amount1);

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  /// @notice Decreases the amount of liquidity in a position and accounts it to the position
  /// @param params tokenId The ID of the token for which liquidity is being decreased,
  /// amount The amount by which liquidity will be decreased,
  /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
  /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
  /// deadline The time by which the transaction must be included to effect the change
  /// @return amount0 The amount of token0 accounted to the position's tokens owed
  /// @return amount1 The amount of token1 accounted to the position's tokens owed
  function decreaseLiquidity(
    DecreaseLiquidityParams calldata params
  ) external payable returns (uint256 amount0, uint256 amount1);

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }

  /// @notice Collects up to a maximum amount of fees owed to a specific position to the recipient
  /// @param params tokenId The ID of the NFT for which tokens are being collected,
  /// recipient The account that should receive the tokens,
  /// amount0Max The maximum amount of token0 to collect,
  /// amount1Max The maximum amount of token1 to collect
  /// @return amount0 The amount of fees collected in token0
  /// @return amount1 The amount of fees collected in token1
  function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

  /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
  /// must be collected first.
  /// @param tokenId The ID of the token that is being burned
  function burn(uint256 tokenId) external payable;

  /// @notice create and initialize a pool if necessary
  function createAndInitializePoolIfNecessary(
    address token0,
    address token1,
    uint24 fee,
    uint160 sqrtPriceX96
  ) external payable returns (address pool);

  function factory() external view returns (address factory);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// OpenZeppelin
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol';

interface IOutputToken is IERC20, IERC20Permit {
  function burn(uint256 amount) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import '../lib/Farms.sol';

/**
 * @dev Interface for the (pegged) farm keeper
 */
interface IPeggedFarmKeeper {
  function updateFarm(address id, bool collectFees) external;

  function farmView(address id) external view returns (FarmView memory);

  function userView(address id, address userId) external view returns (UserView memory);

  function deposit(address id, uint128 liquidity, uint256 slippage, uint256 deadline) external;

  function getLiquidityForAmount(
    address id,
    address token,
    uint256 amount
  ) external view returns (address token0, address token1, uint128 liquidity, uint256 amount0, uint256 amount1);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IPermit2 {
  /// @notice Approves the spender to use up to amount of the specified token up until the expiration
  /// @param token The token to approve
  /// @param spender The spender address to approve
  /// @param amount The approved amount of the token
  /// @param expiration The timestamp at which the approval is no longer valid
  /// @dev The packed allowance also holds a nonce, which will stay unchanged in approve
  /// @dev Setting amount to type(uint160).max sets an unlimited approval
  function approve(address token, address spender, uint160 amount, uint48 expiration) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

interface IUniswapV3Pool {
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
  function ticks(
    int24 tick
  )
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

  /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
  /// @dev This value can overflow the uint256
  function feeGrowthGlobal0X128() external view returns (uint256);

  /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
  /// @dev This value can overflow the uint256
  function feeGrowthGlobal1X128() external view returns (uint256);

  function observe(
    uint32[] calldata secondsAgos
  ) external view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

  /// @notice Returns data about a specific observation index
  /// @param index The element of the observations array to fetch
  /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
  /// ago, rather than at a specific index in the array.
  /// @return blockTimestamp The timestamp of the observation,
  /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
  /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
  /// Returns initialized whether the observation has been initialized and the values are safe to use
  function observations(
    uint256 index
  )
    external
    view
    returns (uint32 blockTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, bool initialized);

  /// @notice Increase the maximum number of price and liquidity observations that this pool will store
  /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
  /// the input observationCardinalityNext.
  /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
  function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

  /// @notice The amounts of token0 and token1 that are owed to the protocol
  /// @dev Protocol fees will never exceed uint128 max in either token
  function protocolFees() external view returns (uint128 token0, uint128 token1);

  /// @notice The first of the two tokens of the pool, sorted by address
  /// @return The token contract address
  function token0() external view returns (address);

  /// @notice The second of the two tokens of the pool, sorted by address
  /// @return The token contract address
  function token1() external view returns (address);

  /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
  /// @return The fee
  function fee() external view returns (uint24);
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

interface IUniversalRouter {
  /// @notice Executes encoded commands along with provided inputs. Reverts if deadline has expired.
  /// @param commands A set of concatenated commands, each 1 byte in length
  /// @param inputs An array of byte strings containing abi encoded inputs for each command
  /// @param deadline The deadline by which the transaction must be executed
  function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/**
 * @title Constants Library
 * @notice Library containing constant values used throughout the protocol
 * @dev This library defines various constants to ensure consistency across the system
 */
library Constants {
  // -----------------------------------------
  // Common
  // -----------------------------------------
  /**
   * @dev Base unit for percentage calculations (100% = 10000)
   */
  uint256 constant BASIS = 10_000;

  /**
   * @dev Scaling factor for high-precision calculations
   */
  uint256 constant SCALE_FACTOR_1E12 = 1e12;
  uint256 constant SCALE_FACTOR_1E18 = 1e18;

  /**
   * @notice Ticks for LP Positions
   */
  int24 constant MIN_TICK = -887200;
  int24 constant MAX_TICK = -MIN_TICK;

  /**
   * @notice UniSwap V3 fee tiers
   */
  uint24 constant FEE_TIER_1_PERCENT = 10000;

  // -----------------------------------------
  // Farm Keeper
  // -----------------------------------------
  /**
   * @notice Constant rate of TINC emission per second
   * @dev Set to 1 TINC per second (1e18 considering 18 decimals)
   */
  uint256 public constant INCENTIVE_TOKEN_PER_SECOND = 1e18;

  /**
   * @notice Maximum allocation points that can be assigned to a single farm
   * @dev Limits the relative weight of a farm in the reward distribution
   */
  uint256 public constant MAX_ALLOCATION_POINTS = 4000;

  // -----------------------------------------
  // Addresses
  // -----------------------------------------
  /**
   * @dev V3 DEX Factory address
   */
  address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

  /**
   * @dev V3 DEX Non-Fungible Position Manager address
   */
  address constant NON_FUNGIBLE_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

  /**
   * @dev V3 DEX Universal Router address
   */
  address constant UNIVERSAL_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

  /**
   * @dev V3 DEX Permit2 address
   */
  address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

  /**
   * @dev Wrapped native token address (WETH, WPLS...)
   */
  address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /**
   * @dev V3 DEX Init Code Hash
   */
  bytes32 constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import './uniswap/PoolAddress.sol';

/**
 * @title LP Struct
 * @notice Represents a UniSwap V3 liquidity position
 * @dev Stores the token ID and liquidity amount for a UniSwap V3 position
 */
struct LP {
  uint256 tokenId;
  uint128 liquidity;
}

/**
 * @title User Struct
 * @notice Represents a user's position in a farm
 * @dev Stores user's liquidity and checkpoints for reward and fee calculations
 */
struct User {
  /**
   * @dev Amount of liquidity the user contributed to the shared LP position
   */
  uint128 liquidity;
  /**
   * @dev Checkpoint for reward calculations (not scaled)
   */
  uint256 rewardCheckpoint;
  /**
   * @dev Checkpoint for fee calculations (token0, not scaled)
   */
  uint256 feeCheckpointToken0;
  /**
   * @dev Checkpoint for fee calculations (token1, not scaled)
   */
  uint256 feeCheckpointToken1;

  // Reward Calculation and Scaling Explanation:
  // To maintain precision with integer math, we use a scaling factor (e.g., 1e12).
  // The farm's accIncentiveTokenPerShare is stored scaled up by this factor.
  //
  // At any given time, the pending reward for a user is calculated as:
  //
  //   pending reward = (user.liquidity * farm.accIncentiveTokenPerShare) / SCALE_FACTOR - user.rewardCheckpoint
  //
  // Where:
  // - farm.accIncentiveTokenPerShare is scaled up by SCALE_FACTOR (e.g., 1e12)
  // - user.rewardCheckpoint is NOT scaled (it's the result of a previous scaled calculation)
  //
  // This scaling allows for precise fractional reward calculations even with integer math.
  //
  // When a user deposits or withdraws liquidity:
  //   1. The farm's `accIncentiveTokenPerShare` (scaled) is updated to reflect accumulated rewards.
  //   2. The user's pending reward is calculated and sent to their address.
  //   3. The user's `liquidity` is updated based on their deposit or withdrawal.
  //   4. The user's `rewardCheckpoint` is set to: (user.liquidity * farm.accIncentiveTokenPerShare) / SCALE_FACTOR
  //      This establishes a new baseline for future reward calculations.
  //
  // The scaling ensures accurate reward distribution proportional to users' liquidity
  // and time in the farm, even when dealing with small fractions of tokens.
}

/**
 * @title UserView Struct
 * @notice Represents a view of a user's position in a farm
 * @dev Used for external queries to get user's current state in a farm
 */
struct UserView {
  address token0;
  address token1;
  uint128 liquidity;
  uint256 balanceToken0;
  uint256 balanceToken1;
  uint256 pendingFeeToken0;
  uint256 pendingFeeToken1;
  uint256 pendingIncentiveTokens;
}

/**
 * @title Farm Struct
 * @notice Represents information about a specific farm
 * @dev Stores all relevant data for a farm, including pool info, rewards, and fees
 */
struct Farm {
  /**
   * @dev The pool address to uniquely identify the farm
   */
  address id;
  /**
   * @dev Helper struct to hold pool information
   */
  PoolAddress.PoolKey poolKey;
  /**
   * @dev Liquidity information for this farm
   */
  LP lp;
  /**
   * @dev How many allocation points assigned to this pool. INC to distribute per second.
   */
  uint256 allocPoints;
  /**
   * @dev Last time that INC distribution occurs
   */
  uint256 lastRewardTime;
  /**
   * @dev Accumulated INC per share
   */
  uint256 accIncentiveTokenPerShare;
  /**
   * @dev Accumulated fees for token0 per share
   */
  uint256 accFeePerShareForToken0;
  /**
   * @dev Accumulated fees for token1 per share
   */
  uint256 accFeePerShareForToken1;
  /**
   * @dev The protocol fee for this pair in basis points
   */
  uint256 protocolFee;
  /**
   * @dev Specifies the value in minutes for the time-weighted average when quoting output tokens
   */
  uint32 priceTwa;
  /**
   * @dev Maximum slippage percentage acceptable when manipulating liquidity
   */
  uint256 slippage;
}

/**
 * @title FarmView Struct
 * @notice Represents a view of a farm
 * @dev Used for external queries to get a farms current state
 */
struct FarmView {
  address id;
  PoolAddress.PoolKey poolKey;
  LP lp;
  uint256 allocPoints;
  uint256 lastRewardTime;
  uint256 accIncentiveTokenPerShare;
  uint256 accFeePerShareForToken0;
  uint256 accFeePerShareForToken1;
  uint256 protocolFee;
  uint32 priceTwa;
  uint256 slippage;
  uint256 balanceToken0;
  uint256 balanceToken1;
}

/**
 * @title Farms Library
 * @notice Library for managing a collection of Farm structs
 * @dev Provides functions for adding, removing, and querying farms
 */
library Farms {
  /**
   * @dev Struct to store Farms in an array with mappings for efficient lookups
   */
  struct Map {
    Farm[] _farms; // Array storage for all farms
    mapping(address id => uint256 position) _positions; // Mapping of farm id to their position in the array
    mapping(address farmId => mapping(address userId => User user)) _users; // Mapping of farm id to their users
  }

  /**
   * @dev Get a user for a farm
   * @param map The map to get the user from
   * @param farm The farm address
   * @param id The user id (address)
   * @return User The user struct for the given farm and user address
   */
  function user(Map storage map, address farm, address id) internal view returns (User storage) {
    return map._users[farm][id];
  }

  /**
   * @dev Add a farm to the map
   * @param map The map to add the farm to
   * @param farm The farm to be added
   * @return bool True if farm was added, false if it already existed
   */
  function add(Map storage map, Farm memory farm) internal returns (bool) {
    if (!contains(map, farm)) {
      map._farms.push(farm);
      // Store the index + 1, using 0 as a sentinel value for "not in map"
      map._positions[farm.id] = map._farms.length;
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Retrieve a farm for a given id
   * @param map The map to search in
   * @param id The id of the farm whose info to retrieve
   * @return Farm The info associated with the farm
   */
  function get(Map storage map, address id) internal view returns (Farm storage) {
    uint256 idx = map._positions[id];
    require(idx != 0, 'Info for id does not exist');
    return map._farms[idx - 1];
  }

  /**
   * @dev Remove a farm from the map
   * @param map The map to remove the farm from
   * @param farm The farm to be removed
   * @return bool True if the farm was removed, false if it didn't exist
   */
  function remove(Map storage map, Farm calldata farm) internal returns (bool) {
    uint256 position = map._positions[farm.id];

    if (position != 0) {
      uint256 valueIndex = position - 1;
      uint256 lastIndex = map._farms.length - 1;

      if (valueIndex != lastIndex) {
        Farm storage lastElement = map._farms[lastIndex];
        map._farms[valueIndex] = lastElement;
        map._positions[lastElement.id] = position;
      }

      map._farms.pop();
      delete map._positions[farm.id];

      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Check if a farm exists in the map
   * @param map The map to check
   * @param farm The farm to look for
   * @return bool True if the farm exists, false otherwise
   */
  function contains(Map storage map, Farm memory farm) internal view returns (bool) {
    return map._positions[farm.id] != 0;
  }

  /**
   * @dev Check if a farm exists in the map
   * @param map The map to check
   * @param id The farm id
   * @return bool True if the farm exists, false otherwise
   */
  function contains(Map storage map, address id) internal view returns (bool) {
    return map._positions[id] != 0;
  }

  /**
   * @dev Get the number of farms in the map
   * @param map The map to check
   * @return uint256 The number of farms in the map
   */
  function length(Map storage map) internal view returns (uint256) {
    return map._farms.length;
  }

  /**
   * @dev Get a farm at a specific index in the map
   * @param map The map to query
   * @param index The index of the farm to retrieve
   * @return Farm The farm at the specified index
   */
  function at(Map storage map, uint256 index) internal view returns (Farm storage) {
    require(index < map._farms.length, 'Index out of bounds');
    return map._farms[index];
  }

  /**
   * @dev Get all farms in the map
   * @param map The map to query
   * @return Farm[] An array containing all farms in the map
   * @notice This function may be gas-intensive for large sets and should be used cautiously
   */
  function values(Map storage map) internal view returns (Farm[] memory) {
    return map._farms;
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// Interfaces
import '../interfaces/IBurnProxy.sol';

/**
 * @title InputToken Struct
 * @notice Represents an Input-Token and holds stats and parameters for buy and burn
 * @dev This struct is used to store all relevant information for an input token in the buy and burn process
 */
struct InputToken {
  /**
   * @dev The input token address used as a unique identifier
   */
  address id;
  // -----------------------------------------
  // Stats
  // -----------------------------------------
  /**
   * @dev Accumulates total tokens used for buy and burn of the output token
   */
  uint256 totalTokensUsedForBuyAndBurn;
  /**
   * @dev Accumulates total tokens burned
   */
  uint256 totalTokensBurned;
  /**
   * @dev Accumulates total tokens paid as incentive fee to run public functions
   */
  uint256 totalIncentiveFee;
  // -----------------------------------------
  // Internal Variables
  // -----------------------------------------
  /**
   * @dev Timestamp of the last buy and burn operation for this core token to track intervals
   */
  uint256 lastCallTs;
  // -----------------------------------------
  // Parameters
  // -----------------------------------------
  /**
   * @dev Limits the amount of core token that can be used per swap to control swap sizes
   */
  uint256 capPerSwap;
  /**
   * @dev Minimum time interval (in seconds) required between successive buy and burn operations
   */
  uint256 interval;
  /**
   * @dev The incentive fee in basis points to call buy and burn
   */
  uint256 incentiveFee;
  /**
   * @dev The burn proxy for the input token
   */
  IBurnProxy burnProxy;
  /**
   * @dev The amount of input token to burn directly for each buy and burn call (between 0 and 100% in basis points)
   */
  uint256 burnPercentage;
  /**
   * @dev Specifies the value in minutes for the time-weighted average when calculating the output token amount
   * for slippage protection. Can be set to zero to disable.
   */
  uint32 priceTwa;
  /**
   * @dev Maximum slippage percentage acceptable when buying tokens.
   * Slippage is expressed as a percentage (in basis points).
   */
  uint256 slippage;
  /**
   * @dev The swap path (format must be compatible with the UniSwap universal router)
   */
  bytes path;
  /**
   * @dev Indicates whether buy and burn operations for this input token are paused.
   * When `paused` is true, buy and burn actions are temporarily halted, but funds can still be
   * sent and accumulated for future use. The `isInputToken` function will return true if the input
   * token is paused but not disabled, allowing funds to be collected without executing buy and burn
   * operations until unpaused.
   */
  bool paused;
  /**
   * @dev Indicates whether the input token is disabled for external contracts.
   * If `disabled` is true, it signals to external contracts to stop sending funds for this input token,
   * even though buy and burn operations are still active. Setting `disabled` to true does not pause
   * buy and burn operations. Both `paused` and `disabled` must be true to fully deactivate the input
   * token, stopping both new deposits from external contracts and buy and burn actions.
   *
   * Note: `isInputToken` is an advisory view function, and external contracts or users may still send
   * funds to the universal buy and burn instance regardless of its result.
   */
  bool disabled;
}

/**
 * @title InputTokenView Struct
 * @notice Represents an Input-Token and holds stats and parameters for buy and burn including balances
 * @dev This struct is used to implement frontends adding balance and information about the next round.
 * Usage in another smart contract may be gas-intensive for large sets and should be used cautiously
 */
struct InputTokenView {
  address id;
  uint256 totalTokensUsedForBuyAndBurn;
  uint256 totalTokensBurned;
  uint256 totalIncentiveFee;
  uint256 lastCallTs;
  uint256 capPerSwap;
  uint256 interval;
  uint256 incentiveFee;
  address burnProxy;
  uint256 burnPercentage;
  uint32 priceTwa;
  uint256 slippage;
  bytes path;
  bool paused;
  bool disabled;
  // Additional view parameters
  /**
   * @dev Current balance of the input token
   */
  uint256 balance;
  /**
   * @dev Amount of tokens to be bought in the next round
   */
  uint256 nextToBuy;
  /**
   * @dev Amount of tokens to be burned in the next round
   */
  uint256 nextToBurn;
  /**
   * @dev Amount of incentive fee for the next round
   */
  uint256 nextIncentiveFee;
  /**
   * @dev The UTC timestamp when buy and burn can be called next
   */
  uint256 nextCall;
}

/**
 * @title InputTokens Library
 * @dev Library for managing a collection of InputToken structs
 */
library InputTokens {
  /**
   * @dev Struct to store InputTokens in an array with a mapping for efficient lookups
   */
  struct Map {
    InputToken[] _tokens; // Array storage for all tokens
    mapping(address token => uint256 position) _positions; // Mapping of token id to their position in the array
  }

  /**
   * @dev Add a token info to the map
   * @param map The map to add the token info to
   * @param token The token info to be added
   * @return bool True if token was added, false if it already existed
   */
  function add(Map storage map, InputToken memory token) internal returns (bool) {
    if (!contains(map, token)) {
      map._tokens.push(token);
      // Store the index + 1, using 0 as a sentinel value for "not in map"
      map._positions[token.id] = map._tokens.length;
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Retrieve a token info for a given token address
   * @param map The map to search in
   * @param tokenAddress The token address of the token whose info to retrieve
   * @return InputToken The info associated with the token
   */
  function get(Map storage map, address tokenAddress) internal view returns (InputToken storage) {
    uint256 idx = map._positions[tokenAddress];
    require(idx != 0, 'Input token does not exist');
    return map._tokens[idx - 1];
  }

  /**
   * @dev Remove a token info from the map
   * @param map The map to remove the token info from
   * @param token The token to be removed
   * @return bool True if the token info was removed, false if it didn't exist
   */
  function remove(Map storage map, InputToken calldata token) internal returns (bool) {
    uint256 position = map._positions[token.id];

    if (position != 0) {
      uint256 valueIndex = position - 1;
      uint256 lastIndex = map._tokens.length - 1;

      if (valueIndex != lastIndex) {
        InputToken storage lastElement = map._tokens[lastIndex];
        map._tokens[valueIndex] = lastElement;
        map._positions[lastElement.id] = position;
      }

      map._tokens.pop();
      delete map._positions[token.id];

      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Check if a token exists in the map
   * @param map The map to check
   * @param token The token to look for
   * @return bool True if the token exists, false otherwise
   */
  function contains(Map storage map, InputToken memory token) internal view returns (bool) {
    return map._positions[token.id] != 0;
  }

  /**
   * @dev Check if a token info exists in the map
   * @param map The map to check
   * @param tokenAddress The token address to check
   * @return bool True if the token info exists, false otherwise
   */
  function contains(Map storage map, address tokenAddress) internal view returns (bool) {
    return map._positions[tokenAddress] != 0;
  }

  /**
   * @dev Get the number of tokens in the map
   * @param map The map to check
   * @return uint256 The number of tokens in the map
   */
  function length(Map storage map) internal view returns (uint256) {
    return map._tokens.length;
  }

  /**
   * @dev Get a token info at a specific index in the map
   * @param map The map to query
   * @param index The index of the token to retrieve
   * @return InputToken The token info at the specified index
   */
  function at(Map storage map, uint256 index) internal view returns (InputToken storage) {
    require(index < map._tokens.length, 'Index out of bounds');
    return map._tokens[index];
  }

  /**
   * @dev Get all info for tokens in the map
   * @param map The map to query
   * @return InputToken[] An array containing all tokens in the map
   * @notice This function may be gas-intensive for large sets and should be used cautiously
   */
  function values(Map storage map) internal view returns (InputToken[] memory) {
    return map._tokens;
  }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

// Use OpenZeppelin replacement for FullMath
import '@openzeppelin/contracts/utils/math/Math.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint96.sol';

/// @title Liquidity amount functions
/// @notice Provides functions for computing liquidity amounts from token amounts and prices
library LiquidityAmounts {
  /// @notice Downcasts uint256 to uint128
  /// @param x The uint258 to be downcasted
  /// @return y The passed value, downcasted to uint128
  function toUint128(uint256 x) private pure returns (uint128 y) {
    require((y = uint128(x)) == x);
  }

  /// @notice Computes the amount of liquidity received for a given amount of token0 and price range
  /// @dev Calculates amount0 * (sqrt(upper) * sqrt(lower)) / (sqrt(upper) - sqrt(lower))
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param amount0 The amount0 being sent in
  /// @return liquidity The amount of returned liquidity
  function getLiquidityForAmount0(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    uint256 intermediate = Math.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
    return toUint128(Math.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
  }

  /// @notice Computes the amount of liquidity received for a given amount of token1 and price range
  /// @dev Calculates amount1 / (sqrt(upper) - sqrt(lower)).
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param amount1 The amount1 being sent in
  /// @return liquidity The amount of returned liquidity
  function getLiquidityForAmount1(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    return toUint128(Math.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
  }

  /// @notice Computes the maximum amount of liquidity received for a given amount of token0, token1, the current
  /// pool prices and the prices at the tick boundaries
  /// @param sqrtRatioX96 A sqrt price representing the current pool prices
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param amount0 The amount of token0 being sent in
  /// @param amount1 The amount of token1 being sent in
  /// @return liquidity The maximum amount of liquidity received
  function getLiquidityForAmounts(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

    if (sqrtRatioX96 <= sqrtRatioAX96) {
      liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
    } else if (sqrtRatioX96 < sqrtRatioBX96) {
      uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
      uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

      liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    } else {
      liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
    }
  }

  /// @notice Computes the amount of token0 for a given amount of liquidity and a price range
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param liquidity The liquidity being valued
  /// @return amount0 The amount of token0
  function getAmount0ForLiquidity(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount0) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

    return
      Math.mulDiv(uint256(liquidity) << FixedPoint96.RESOLUTION, sqrtRatioBX96 - sqrtRatioAX96, sqrtRatioBX96) /
      sqrtRatioAX96;
  }

  /// @notice Computes the amount of token1 for a given amount of liquidity and a price range
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param liquidity The liquidity being valued
  /// @return amount1 The amount of token1
  function getAmount1ForLiquidity(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount1) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

    return Math.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
  }

  /// @notice Computes the token0 and token1 value for a given amount of liquidity, the current
  /// pool prices and the prices at the tick boundaries
  /// @param sqrtRatioX96 A sqrt price representing the current pool prices
  /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
  /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
  /// @param liquidity The liquidity being valued
  /// @return amount0 The amount of token0
  /// @return amount1 The amount of token1
  function getAmountsForLiquidity(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount0, uint256 amount1) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

    if (sqrtRatioX96 <= sqrtRatioAX96) {
      amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    } else if (sqrtRatioX96 < sqrtRatioBX96) {
      amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
      amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
    } else {
      amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// Interfaces
import '../../interfaces/IUniswapV3Pool.sol';

// OpenZeppelin
import '@openzeppelin/contracts/utils/math/Math.sol';

/**
 * @notice Adapted Uniswap V3 OracleLibrary computation to be compliant with Solidity 0.8.x and later.
 *
 * Documentation for Auditors:
 *
 * Solidity Version: Updated the Solidity version pragma to ^0.8.0. This change ensures compatibility
 * with Solidity version 0.8.x.
 *
 * Safe Arithmetic Operations: Solidity 0.8.x automatically checks for arithmetic overflows/underflows.
 * Therefore, the code no longer needs to use SafeMath library (or similar) for basic arithmetic operations.
 * This change simplifies the code and reduces the potential for errors related to manual overflow/underflow checking.
 *
 * Overflow/Underflow: With the introduction of automatic overflow/underflow checks in Solidity 0.8.x,
 * the code is inherently safer and less prone to certain types of arithmetic errors.
 *
 * Removal of SafeMath Library: Since Solidity 0.8.x handles arithmetic operations safely, the use of SafeMath library
 * is omitted in this update.
 *
 * Git-style diff for the `consult` function:
 *
 * ```diff
 * function consult(address pool, uint32 secondsAgo)
 *     internal
 *     view
 *     returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
 * {
 *     require(secondsAgo != 0, 'BP');
 *
 *     uint32[] memory secondsAgos = new uint32[](2);
 *     secondsAgos[0] = secondsAgo;
 *     secondsAgos[1] = 0;
 *
 *     (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
 *         IUniswapV3Pool(pool).observe(secondsAgos);
 *
 *     int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
 *     uint160 secondsPerLiquidityCumulativesDelta =
 *         secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];
 *
 * -   arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
 * +   int56 secondsAgoInt56 = int56(uint56(secondsAgo));
 * +   arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgoInt56);
 *     // Always round to negative infinity
 * -   if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;
 * +   if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgoInt56 != 0)) arithmeticMeanTick--;
 *
 * -   uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
 * +   uint192 secondsAgoUint192 = uint192(secondsAgo);
 * +   uint192 secondsAgoX160 = secondsAgoUint192 * type(uint160).max;
 *     harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
 * }
 * ```
 */

/// @title Oracle library
/// @notice Provides functions to integrate with V3 pool oracle
library OracleLibrary {
  /// @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool
  /// @param pool Address of the pool that we want to observe
  /// @param secondsAgo Number of seconds in the past from which to calculate the time-weighted means
  /// @return arithmeticMeanTick The arithmetic mean tick from (block.timestamp - secondsAgo) to block.timestamp
  /// @return harmonicMeanLiquidity The harmonic mean liquidity from (block.timestamp - secondsAgo) to block.timestamp
  function consult(
    address pool,
    uint32 secondsAgo
  ) internal view returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) {
    require(secondsAgo != 0, 'BP');

    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo;
    secondsAgos[1] = 0;

    (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool)
      .observe(secondsAgos);

    int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
    uint160 secondsPerLiquidityCumulativesDelta;
    unchecked {
      secondsPerLiquidityCumulativesDelta =
        secondsPerLiquidityCumulativeX128s[1] -
        secondsPerLiquidityCumulativeX128s[0];
    }

    // Safe casting of secondsAgo to int56 for division
    int56 secondsAgoInt56 = int56(uint56(secondsAgo));
    arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgoInt56);
    // Always round to negative infinity
    if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgoInt56 != 0)) arithmeticMeanTick--;

    // Safe casting of secondsAgo to uint192 for multiplication
    uint192 secondsAgoUint192 = uint192(secondsAgo);
    harmonicMeanLiquidity = uint128(
      (secondsAgoUint192 * uint192(type(uint160).max)) / (uint192(secondsPerLiquidityCumulativesDelta) << 32)
    );
  }

  /// @notice Given a pool, it returns the number of seconds ago of the oldest stored observation
  /// @param pool Address of Uniswap V3 pool that we want to observe
  /// @return secondsAgo The number of seconds ago of the oldest observation stored for the pool
  function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo) {
    (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
    require(observationCardinality > 0, 'NI');

    (uint32 observationTimestamp, , , bool initialized) = IUniswapV3Pool(pool).observations(
      (observationIndex + 1) % observationCardinality
    );

    // The next index might not be initialized if the cardinality is in the process of increasing
    // In this case the oldest observation is always in index 0
    if (!initialized) {
      (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
    }

    secondsAgo = uint32(block.timestamp) - observationTimestamp;
  }

  /// @notice Given a tick and a token amount, calculates the amount of token received in exchange
  /// a slightly modified version of the UniSwap library getQuoteAtTick to accept a sqrtRatioX96 as input parameter
  /// @param sqrtRatioX96 The sqrt ration
  /// @param baseAmount Amount of token to be converted
  /// @param baseToken Address of an ERC20 token contract used as the baseAmount denomination
  /// @param quoteToken Address of an ERC20 token contract used as the quoteAmount denomination
  /// @return quoteAmount Amount of quoteToken received for baseAmount of baseToken
  function getQuoteForSqrtRatioX96(
    uint160 sqrtRatioX96,
    uint256 baseAmount,
    address baseToken,
    address quoteToken
  ) internal pure returns (uint256 quoteAmount) {
    // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
    if (sqrtRatioX96 <= type(uint128).max) {
      uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
      quoteAmount = baseToken < quoteToken
        ? Math.mulDiv(ratioX192, baseAmount, 1 << 192)
        : Math.mulDiv(1 << 192, baseAmount, ratioX192);
    } else {
      uint256 ratioX128 = Math.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
      quoteAmount = baseToken < quoteToken
        ? Math.mulDiv(ratioX128, baseAmount, 1 << 128)
        : Math.mulDiv(1 << 128, baseAmount, ratioX128);
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

library PathDecoder {
  /// @dev The length of the bytes encoded address
  uint256 internal constant ADDR_SIZE = 20;

  /// @dev The length of the bytes encoded fee
  uint256 internal constant V3_FEE_SIZE = 3;

  /// @dev The offset of a single token address (20) and pool fee (3)
  uint256 internal constant NEXT_V3_POOL_OFFSET = ADDR_SIZE + V3_FEE_SIZE;

  /// @dev The offset of an encoded pool key
  /// Token (20) + Fee (3) + Token (20) = 43
  uint256 internal constant V3_POP_OFFSET = NEXT_V3_POOL_OFFSET + ADDR_SIZE;

  struct Hop {
    address tokenIn;
    address tokenOut;
    uint24 fee;
  }

  /// @notice Decodes the swap path
  /// @param path The bytes of the swap path
  /// @return hops The decoded array of Hop structs
  function decode(bytes memory path) internal pure returns (Hop[] memory hops) {
    require(path.length >= V3_POP_OFFSET, 'Path too short');
    require((path.length - ADDR_SIZE) % NEXT_V3_POOL_OFFSET == 0, 'Invalid path length');

    uint256 numHops = (path.length - ADDR_SIZE) / NEXT_V3_POOL_OFFSET;
    hops = new Hop[](numHops);

    for (uint256 i = 0; i < numHops; i++) {
      (address tokenIn, uint24 fee, address tokenOut) = toPool(path, i * NEXT_V3_POOL_OFFSET);
      hops[i] = Hop(tokenIn, tokenOut, fee);
    }
  }

  /// @notice Returns the pool details starting at the given offset
  /// @dev has been modified to from the UniSwap library to work with bytes memory
  /// @param _bytes The input bytes memory to decode
  /// @param _start The starting offset for this pool in the path
  /// @return tokenIn The first token address
  /// @return fee The pool fee
  /// @return tokenOut The second token address
  function toPool(
    bytes memory _bytes,
    uint256 _start
  ) internal pure returns (address tokenIn, uint24 fee, address tokenOut) {
    require(_start + V3_POP_OFFSET <= _bytes.length, 'Invalid pool offset');
    assembly {
      let poolData := mload(add(add(_bytes, 32), _start))
      tokenIn := shr(96, poolData)
      fee := and(shr(72, poolData), 0xffffff)
      tokenOut := shr(96, mload(add(add(_bytes, 55), _start)))
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import '../Constants.sol';

/**
 * @notice Adapted Uniswap V3 pool address computation to be compliant with Solidity 0.8.x and later.
 * @dev Changes were made to address the stricter type conversion rules in newer Solidity versions.
 *      Original Uniswap V3 code directly converted a uint256 to an address, which is disallowed in Solidity 0.8.x.
 *      Adaptation Steps:
 *        1. The `pool` address is computed by first hashing pool parameters.
 *        2. The resulting `uint256` hash is then explicitly cast to `uint160` before casting to `address`.
 *           This two-step conversion process is necessary due to the Solidity 0.8.x restriction.
 *           Direct conversion from `uint256` to `address` is disallowed to prevent mistakes
 *           that can occur due to the size mismatch between the types.
 *        3. Added a require statement to ensure `token0` is less than `token1`, maintaining
 *           Uniswap's invariant and preventing pool address calculation errors.
 * @param factory The Uniswap V3 factory contract address.
 * @param key The PoolKey containing token addresses and fee tier.
 * @return pool The computed address of the Uniswap V3 pool.
 * @custom:modification Explicit type conversion from `uint256` to `uint160` then to `address`.
 *
 * function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
 *     require(key.token0 < key.token1);
 *     pool = address(
 *         uint160( // Explicit conversion to uint160 added for compatibility with Solidity 0.8.x
 *             uint256(
 *                 keccak256(
 *                     abi.encodePacked(
 *                         hex'ff',
 *                         factory,
 *                         keccak256(abi.encode(key.token0, key.token1, key.fee)),
 *                         POOL_INIT_CODE_HASH
 *                     )
 *                 )
 *             )
 *         )
 *     );
 * }
 */

/// @dev This code is copied from Uniswap V3 which uses an older compiler version.
/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
library PoolAddress {
  /// @notice The identifying key of the pool
  struct PoolKey {
    address token0;
    address token1;
    uint24 fee;
  }

  /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
  /// @param tokenA The first token of a pool, unsorted
  /// @param tokenB The second token of a pool, unsorted
  /// @param fee The fee level of the pool
  /// @return Poolkey The pool details with ordered token0 and token1 assignments
  function getPoolKey(address tokenA, address tokenB, uint24 fee) internal pure returns (PoolKey memory) {
    if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
    return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
  }

  /// @notice Deterministically computes the pool address given the factory and PoolKey
  /// @param factory The Uniswap V3 factory contract address
  /// @param key The PoolKey
  /// @return pool The contract address of the V3 pool
  function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
    require(key.token0 < key.token1);
    pool = address(
      uint160( // Convert uint256 to uint160 first
        uint256(
          keccak256(
            abi.encodePacked(
              hex'ff',
              factory,
              keccak256(abi.encode(key.token0, key.token1, key.fee)),
              Constants.POOL_INIT_CODE_HASH
            )
          )
        )
      )
    );
  }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

library PositionKey {
  /// @dev Returns the key of the position in the core library
  function compute(address owner, int24 tickLower, int24 tickUpper) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(owner, tickLower, tickUpper));
  }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

// Use OpenZeppelin replacement for FullMath
import '@openzeppelin/contracts/utils/math/Math.sol';

// UniSwap Core
import '@uniswap/v3-core/contracts/libraries/FixedPoint128.sol';

// Interfaces
import '../../interfaces/INonfungiblePositionManager.sol';
import '../../interfaces/IUniswapV3Pool.sol';

// Lib
import './TickMath.sol';
import './LiquidityAmounts.sol';
import './PoolAddress.sol';
import './PositionKey.sol';

/// @title Returns information about the token value held in a Uniswap V3 NFT
library PositionValue {
  /// @notice Returns the total amounts of token0 and token1, i.e. the sum of fees and principal
  /// that a given nonfungible position manager token is worth
  /// @param positionManager The Uniswap V3 NonfungiblePositionManager
  /// @param tokenId The tokenId of the token for which to get the total value
  /// @param sqrtRatioX96 The square root price X96 for which to calculate the principal amounts
  /// @return amount0 The total amount of token0 including principal and fees
  /// @return amount1 The total amount of token1 including principal and fees
  function total(
    INonfungiblePositionManager positionManager,
    uint256 tokenId,
    uint160 sqrtRatioX96
  ) internal view returns (uint256 amount0, uint256 amount1) {
    (uint256 amount0Principal, uint256 amount1Principal) = principal(positionManager, tokenId, sqrtRatioX96);
    (uint256 amount0Fee, uint256 amount1Fee) = fees(positionManager, tokenId);
    return (amount0Principal + amount0Fee, amount1Principal + amount1Fee);
  }

  /// @notice Calculates the principal (currently acting as liquidity) owed to the token owner in the event
  /// that the position is burned
  /// @param positionManager The Uniswap V3 NonfungiblePositionManager
  /// @param tokenId The tokenId of the token for which to get the total principal owed
  /// @param sqrtRatioX96 The square root price X96 for which to calculate the principal amounts
  /// @return amount0 The principal amount of token0
  /// @return amount1 The principal amount of token1
  function principal(
    INonfungiblePositionManager positionManager,
    uint256 tokenId,
    uint160 sqrtRatioX96
  ) internal view returns (uint256 amount0, uint256 amount1) {
    (, , , , , int24 tickLower, int24 tickUpper, uint128 liquidity, , , , ) = positionManager.positions(tokenId);

    return
      LiquidityAmounts.getAmountsForLiquidity(
        sqrtRatioX96,
        TickMath.getSqrtRatioAtTick(tickLower),
        TickMath.getSqrtRatioAtTick(tickUpper),
        liquidity
      );
  }

  struct FeeParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidity;
    uint256 positionFeeGrowthInside0LastX128;
    uint256 positionFeeGrowthInside1LastX128;
    uint256 tokensOwed0;
    uint256 tokensOwed1;
  }

  /// @notice Calculates the total fees owed to the token owner
  /// @param positionManager The Uniswap V3 NonfungiblePositionManager
  /// @param tokenId The tokenId of the token for which to get the total fees owed
  /// @return amount0 The amount of fees owed in token0
  /// @return amount1 The amount of fees owed in token1
  function fees(
    INonfungiblePositionManager positionManager,
    uint256 tokenId
  ) internal view returns (uint256 amount0, uint256 amount1) {
    (
      ,
      ,
      address token0,
      address token1,
      uint24 fee,
      int24 tickLower,
      int24 tickUpper,
      uint128 liquidity,
      uint256 positionFeeGrowthInside0LastX128,
      uint256 positionFeeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    ) = positionManager.positions(tokenId);
    return
      _fees(
        FeeParams({
          token0: token0,
          token1: token1,
          fee: fee,
          tickLower: tickLower,
          tickUpper: tickUpper,
          liquidity: liquidity,
          positionFeeGrowthInside0LastX128: positionFeeGrowthInside0LastX128,
          positionFeeGrowthInside1LastX128: positionFeeGrowthInside1LastX128,
          tokensOwed0: tokensOwed0,
          tokensOwed1: tokensOwed1
        })
      );
  }

  function _fees(FeeParams memory feeParams) private view returns (uint256 amount0, uint256 amount1) {
    (uint256 poolFeeGrowthInside0LastX128, uint256 poolFeeGrowthInside1LastX128) = _getFeeGrowthInside(
      IUniswapV3Pool(
        PoolAddress.computeAddress(
          Constants.FACTORY,
          PoolAddress.PoolKey({token0: feeParams.token0, token1: feeParams.token1, fee: feeParams.fee})
        )
      ),
      feeParams.tickLower,
      feeParams.tickUpper
    );

    unchecked {
      amount0 =
        Math.mulDiv(
          poolFeeGrowthInside0LastX128 - feeParams.positionFeeGrowthInside0LastX128,
          feeParams.liquidity,
          FixedPoint128.Q128
        ) +
        feeParams.tokensOwed0;

      amount1 =
        Math.mulDiv(
          poolFeeGrowthInside1LastX128 - feeParams.positionFeeGrowthInside1LastX128,
          feeParams.liquidity,
          FixedPoint128.Q128
        ) +
        feeParams.tokensOwed1;
    }
  }

  function _getFeeGrowthInside(
    IUniswapV3Pool pool,
    int24 tickLower,
    int24 tickUpper
  ) private view returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) {
    (, int24 tickCurrent, , , , , ) = pool.slot0();
    (, , uint256 lowerFeeGrowthOutside0X128, uint256 lowerFeeGrowthOutside1X128, , , , ) = pool.ticks(tickLower);
    (, , uint256 upperFeeGrowthOutside0X128, uint256 upperFeeGrowthOutside1X128, , , , ) = pool.ticks(tickUpper);

    unchecked {
      if (tickCurrent < tickLower) {
        feeGrowthInside0X128 = lowerFeeGrowthOutside0X128 - upperFeeGrowthOutside0X128;
        feeGrowthInside1X128 = lowerFeeGrowthOutside1X128 - upperFeeGrowthOutside1X128;
      } else if (tickCurrent < tickUpper) {
        uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
        uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();
        feeGrowthInside0X128 = feeGrowthGlobal0X128 - lowerFeeGrowthOutside0X128 - upperFeeGrowthOutside0X128;
        feeGrowthInside1X128 = feeGrowthGlobal1X128 - lowerFeeGrowthOutside1X128 - upperFeeGrowthOutside1X128;
      } else {
        feeGrowthInside0X128 = upperFeeGrowthOutside0X128 - lowerFeeGrowthOutside0X128;
        feeGrowthInside1X128 = upperFeeGrowthOutside1X128 - lowerFeeGrowthOutside1X128;
      }
    }
  }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

/**
 * @notice Adapted Uniswap V3 TickMath library computation to be compliant with Solidity 0.8.x and later.
 *
 * Documentation for Auditors:
 *
 * Solidity Version: Updated the Solidity version pragma to ^0.8.0. This change ensures compatibility
 * with Solidity version 0.8.x.
 *
 * Safe Arithmetic Operations: Solidity 0.8.x automatically checks for arithmetic overflows/underflows.
 * Therefore, the code no longer needs to use the SafeMath library (or similar) for basic arithmetic operations.
 * This change simplifies the code and reduces the potential for errors related to manual overflow/underflow checking.
 *
 * Explicit Type Conversion: The explicit conversion of `MAX_TICK` from `int24` to `uint256` in the `require` statement
 * is safe and necessary for comparison with `absTick`, which is a `uint256`. This conversion is compliant with
 * Solidity 0.8.x's type system and does not introduce any arithmetic risk.
 *
 * Overflow/Underflow: With the introduction of automatic overflow/underflow checks in Solidity 0.8.x,
 * the code is inherently safer and less prone to certain types of arithmetic errors.
 *
 * Removal of SafeMath Library: Since Solidity 0.8.x handles arithmetic operations safely, the use of the SafeMath
 * library is omitted in this update.
 *
 * Use unchecked to allow phantom overflows as intended in the original UniSwap V3 code.
 *
 * Git-style diff for the TickMath library:
 *
 * ```diff
 * - pragma solidity >=0.5.0 <0.8.0;
 * + pragma solidity ^0.8.0;
 *
 *   function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
 *       uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
 * -     require(absTick <= uint256(MAX_TICK), 'T');
 * +     require(absTick <= uint256(int256(MAX_TICK)), 'T'); // Explicit type conversion
 *       for Solidity 0.8.x compatibility
 *       // ... (rest of the function)
 *   }
 *
 * function getTickAtSqrtRatio(
 *     uint160 sqrtPriceX96
 * ) internal pure returns (int24 tick) {
 *     // [Code for calculating the tick based on sqrtPriceX96 remains unchanged]
 *
 * -   tick = tickLow == tickHi
 * -       ? tickLow
 * -       : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
 * -       ? tickHi
 * -       : tickLow;
 * +   if (tickLow == tickHi) {
 * +       tick = tickLow;
 * +   } else {
 * +       tick = (getSqrtRatioAtTick(tickHi) <= sqrtPriceX96) ? tickHi : tickLow;
 * +   }
 * }
 * ```
 *
 * Note: Other than the pragma version change and the explicit type conversion
 * in the `require` statement, the original functions
 * within the TickMath library are compatible with Solidity 0.8.x without requiring
 * any further modifications. This is due to
 * the fact that the logic within these functions already adheres to safe arithmetic
 * practices and does not involve operations
 * that would be affected by the 0.8.x compiler's built-in checks.
 */

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
  /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
  int24 internal constant MIN_TICK = -887272;
  /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
  int24 internal constant MAX_TICK = -MIN_TICK;

  /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  /// @notice Calculates sqrt(1.0001^tick) * 2^96
  /// @dev Throws if |tick| > max tick
  /// @param tick The input tick for the above formula
  /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets
  /// at the given tick
  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
    unchecked {
      uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
      require(absTick <= uint256(int256(MAX_TICK)), 'T'); // Explicit type conversion for Solidity 0.8.x compatibility

      uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
      if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
      if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
      if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
      if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
      if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
      if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
      if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
      if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
      if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
      if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
      if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
      if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
      if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
      if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
      if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
      if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
      if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
      if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
      if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

      if (tick > 0) ratio = type(uint256).max / ratio;

      // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
      // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
      // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
      sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
  }

  /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
  /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
  /// ever return.
  /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
  /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
  function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
    unchecked {
      // second inequality must be < because the price can never reach the price at the max tick
      require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
      uint256 ratio = uint256(sqrtPriceX96) << 32;

      uint256 r = ratio;
      uint256 msb = 0;

      assembly {
        let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(5, gt(r, 0xFFFFFFFF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(4, gt(r, 0xFFFF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(3, gt(r, 0xFF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(2, gt(r, 0xF))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := shl(1, gt(r, 0x3))
        msb := or(msb, f)
        r := shr(f, r)
      }
      assembly {
        let f := gt(r, 0x1)
        msb := or(msb, f)
      }

      if (msb >= 128) r = ratio >> (msb - 127);
      else r = ratio << (127 - msb);

      int256 log_2 = (int256(msb) - 128) << 64;

      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(63, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(62, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(61, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(60, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(59, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(58, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(57, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(56, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(55, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(54, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(53, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(52, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(51, f))
        r := shr(f, r)
      }
      assembly {
        r := shr(127, mul(r, r))
        let f := shr(128, r)
        log_2 := or(log_2, shl(50, f))
      }

      int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

      int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
      int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

      // Adjusted logic for determining the tick
      if (tickLow == tickHi) {
        tick = tickLow;
      } else {
        tick = (getSqrtRatioAtTick(tickHi) <= sqrtPriceX96) ? tickHi : tickLow;
      }
    }
  }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ProxyToken is ERC20, Ownable {
  constructor() ERC20('Proxy Token', 'PT') Ownable(msg.sender) {}

  function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
  }
}