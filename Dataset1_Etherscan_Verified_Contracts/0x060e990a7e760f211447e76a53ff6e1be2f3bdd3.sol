// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AccessManaged.sol)

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
     * functions are the only execution paths where a function selector cannot be unambiguosly determined from the calldata
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AccessManager.sol)

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
 * mindful of the danger associated with functions such as {{Ownable-renounceOwnership}} or
 * {{AccessControl-renounceRole}}.
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

    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    mapping(address target => TargetConfig mode) private _targets;
    mapping(uint64 roleId => Role) private _roles;
    mapping(bytes32 operationId => Schedule) private _schedules;

    // Used to identify operations that are currently being executed via {execute}.
    // This should be transient storage when supported by the EVM.
    bytes32 private _executionId;

    /**
     * @dev Check that the caller is authorized to perform the operation, following the restrictions encoded in
     * {_getAdminRestrictions}.
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
        if (target == address(this)) {
            revert AccessManagerLockedAccount(target);
        }
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

        // if call with delay is not authorized, or if requested timing is too soon
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
     * (Note: This function was introduced due to stack too deep errors in schedule.)
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

        // If caller is not authorised, revert
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
     * @dev Check if the current call is authorized according to admin logic.
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
    ) private view returns (bool restricted, uint64 roleAdminId, uint32 executionDelay) {
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

        return (false, 0, 0);
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
     * @dev A version of {canCall} that checks for admin restrictions in this contract.
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

        (bool enabled, uint64 roleId, uint32 operationDelay) = _getAdminRestrictions(data);
        if (!enabled) {
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
// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManaged} from "./IAccessManaged.sol";
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
    error AccessManagerLockedAccount(address account);
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
     * NOTE: This function does not report the permissions of this manager itself. These are defined by the
     * {_canCallSelf} function instead.
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
    function getAccess(uint64 roleId, address account) external view returns (uint48, uint32, uint32, uint48);

    /**
     * @dev Check if a given account currently has the permission level corresponding to a given role. Note that this
     * permission might be associated with an execution delay. {getAccess} can provide more details.
     */
    function hasRole(uint64 roleId, address account) external view returns (bool, uint32);

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
    function schedule(address target, bytes calldata data, uint48 when) external returns (bytes32, uint32);

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
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

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
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

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/types/Time.sol)

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
    function _getFullAt(Delay self, uint48 timepoint) private pure returns (uint32, uint32, uint48) {
        (uint32 valueBefore, uint32 valueAfter, uint48 effect) = self.unpack();
        return effect <= timepoint ? (valueAfter, 0, 0) : (valueBefore, valueAfter, effect);
    }

    /**
     * @dev Get the current value plus the pending value and effect timepoint if there is a scheduled change. If the
     * effect timepoint is 0, then the pending value should not be considered.
     */
    function getFull(Delay self) internal view returns (uint32, uint32, uint48) {
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// Uniswap
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

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

interface IFarmKeeper {
  function updateFarm(address id, bool collectFees) external;
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
   * @dev UniSwap V3 Factory address
   */
  address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

  /**
   * @dev UniSwap V3 Non-Fungible Position Manager address
   */
  address constant NON_FUNGIBLE_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

  /**
   * @dev UniSwap Universal Router address
   */
  address constant UNIVERSAL_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

  /**
   * @dev UniSwap Permit2 address
   */
  address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

  /**
   * @dev WETH address
   */
  address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

// Uniswap
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

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
  bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

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
              POOL_INIT_CODE_HASH
            )
          )
        )
      )
    );
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