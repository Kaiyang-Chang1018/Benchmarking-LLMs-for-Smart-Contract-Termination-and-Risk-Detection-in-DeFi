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
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import { AccessControl, IAccessControl } from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import { Pausable } from "openzeppelin-contracts/contracts/utils/Pausable.sol";
import { ICanonicalBridge } from "./interfaces/ICanonicalBridge.sol";
import { ITreasury } from "./interfaces/ITreasury.sol";
import { ISemVer } from "./interfaces/ISemVer.sol";

/// @title CanonicalBridge
/// @dev A bridge contract for depositing and withdrawing ether to and from the Eclipse rollup.
contract CanonicalBridge is
    ICanonicalBridge,
    ISemVer,
    AccessControl,
    Pausable,
    ReentrancyGuard
{
    address private constant NULL_ADDRESS = address(0);
    bytes32 private constant NULL_BYTES32 = bytes32(0);
    bytes private constant NULL_BYTES = "";
    uint256 private constant NEVER = type(uint256).max;
    uint256 private constant MIN_DEPOSIT_LAMPORTS = 2_000_000;
    uint256 private constant WEI_PER_LAMPORT = 1_000_000_000;
    uint256 private constant DEFAULT_FRAUD_WINDOW_DURATION = 7 days;
    uint256 private constant MIN_FRAUD_WINDOW_DURATION = 1 days;
    uint256 private constant PRECISION = 1e18;
    uint8 private constant MAJOR_VERSION = 2;
    uint8 private constant MINOR_VERSION = 0;
    uint8 private constant PATCH_VERSION = 0;

    bytes32 public constant override PAUSER_ROLE = keccak256("Pauser");
    bytes32 public constant override STARTER_ROLE = keccak256("Starter");
    bytes32 public constant override WITHDRAW_AUTHORITY_ROLE = keccak256("WithdrawAuthority");
    bytes32 public constant override CLAIM_AUTHORITY_ROLE = keccak256("ClaimAuthority");
    bytes32 public constant override WITHDRAW_CANCELLER_ROLE = keccak256("WithdrawCanceller");
    bytes32 public constant override FRAUD_WINDOW_SETTER_ROLE = keccak256("FraudWindowSetter");
    uint256 public constant override MIN_DEPOSIT = MIN_DEPOSIT_LAMPORTS * WEI_PER_LAMPORT;
    address public immutable override TREASURY;

    uint256 public override fraudWindowDuration = 7 days;
    mapping (bytes32 withdrawMessageHash => uint256 startTime) public override startTime;
    mapping (uint64 withdrawMessageId =>  uint256 blockNumber) public override withdrawMsgIdProcessed;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @dev Ensures that bytes32 data is initialized with data.
    modifier bytes32Initialized(bytes32 _data) {
        if(_data == NULL_BYTES32) revert EmptyBytes32();
        _;
    }

    /// @dev Ensures the deposit amount and msg.value are valid, equal and they are >= to the min deposit amount.
    /// @param amountWei The amount to be deposited.
    modifier validDepositAmount(uint256 amountWei) {
        if (msg.value != amountWei) revert CanonicalBridgeTransactionRejected(0, "Deposit amount mismatch");
        if (msg.value % WEI_PER_LAMPORT != 0) revert CanonicalBridgeTransactionRejected(0, "Fractional value not allowed");
        if (msg.value < MIN_DEPOSIT) revert CanonicalBridgeTransactionRejected(0, "Deposit less than minimum");
        _;
    }

    /// @dev Ensure that withdraw messages are complete.
    modifier validWithdrawMessage(WithdrawMessage memory message) {
        if (message.from == NULL_BYTES32) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "Null message.from");
        }
        if (message.destination == NULL_ADDRESS) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "Null message.destination");
        }
        if (message.amountWei == 0) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "message.amountWei is 0");
        }
        if (message.withdrawId == 0) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "message.withdrawId is 0");
        }
        if (message.feeWei > message.amountWei) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "message.fee exceeds message.amount");
        }
        if (message.feeReceiver == NULL_ADDRESS) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "Null fee receiver");
        }
        _;
    }

    /// @dev Constructor that initializes the contract.
    constructor(address owner, address treasuryAddress) {
        /// @dev The owner receives default ACL-admin role that controls access to the
        /// operational roles that follow.
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        /// @dev These assignments are conveniences, since the owner now has user admin authority.
        _grantRole(PAUSER_ROLE, owner);
        _grantRole(STARTER_ROLE, owner);
        _grantRole(WITHDRAW_AUTHORITY_ROLE, owner);
        _grantRole(CLAIM_AUTHORITY_ROLE, owner);
        _grantRole(WITHDRAW_CANCELLER_ROLE, owner);
        _grantRole(FRAUD_WINDOW_SETTER_ROLE, owner);

        TREASURY = treasuryAddress;
        emit Deployed(msg.sender, owner, treasuryAddress);
        _setFraudWindowDuration(DEFAULT_FRAUD_WINDOW_DURATION);
    }

    /// @inheritdoc ICanonicalBridge
    function withdrawMessageStatus(
        WithdrawMessage calldata message
    )
        external
        view
        override
        validWithdrawMessage(message)
        returns (WithdrawStatus)
    {
        return withdrawMessageStatus(withdrawMessageHash(message));
    }

    /// @inheritdoc ICanonicalBridge
    function withdrawMessageStatus(bytes32 messageHash) public view override returns (WithdrawStatus) {
        uint256 startTime_ = startTime[messageHash];
        if (startTime_ == 0) return WithdrawStatus.UNKNOWN;
        if (startTime_ == NEVER) return WithdrawStatus.CLOSED;
        if (startTime_ > block.timestamp) return WithdrawStatus.PROCESSING;
        return WithdrawStatus.PENDING;
    }

    /// @inheritdoc ICanonicalBridge
    function withdrawMessageHash(WithdrawMessage memory message) public pure override returns (bytes32) {
        return keccak256(abi.encode(message));
    }

    /// @inheritdoc ISemVer
    /// @dev Retrieves the constant version details of the smart contract.
    function getVersionComponents() public pure override returns (Version memory) {
        return Version(MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION);
    }

    // Operations

    /// @inheritdoc ICanonicalBridge
    /// @dev Access controlled, pausible
    function deposit(bytes32 recipient, uint256 amountWei)
        external
        payable
        virtual
        override
        whenNotPaused
        bytes32Initialized(recipient)
        validDepositAmount(amountWei)
        nonReentrant
    {
        bool success;
        (success,) = payable(address(TREASURY)).call{value: amountWei}(abi.encodeWithSignature("depositEth()"));
        if (!success) revert CanonicalBridgeTransactionRejected(0, "failed to transfer funds to the treasury");

        // Emit deposit message
        uint256 amountGwei = amountWei / WEI_PER_LAMPORT;
        emit Deposited(msg.sender, recipient, amountWei, amountGwei);
    }

    /// @inheritdoc ICanonicalBridge
    /// @dev Access controlled, pausable
    function authorizeWithdraws(
        WithdrawMessage[] calldata messages
    )
        external
        override
        whenNotPaused
        onlyRole(WITHDRAW_AUTHORITY_ROLE)
    {
        for (uint256 i = 0; i < messages.length; i++) {
            _authorizeWithdraw(messages[i]);
        }
    }

    /// @inheritdoc ICanonicalBridge
    /// @dev Access controlled, pausable
    function authorizeWithdraw(
        WithdrawMessage calldata message
    )
        external
        override
        whenNotPaused
        onlyRole(WITHDRAW_AUTHORITY_ROLE)
    {
        _authorizeWithdraw(message);
    }

    /// @notice Inserts a withdraw authorization with a start time after the fraud window.
    /// @param message The message to record.
    /// @dev Message must pass validation rules.
    function _authorizeWithdraw(
        WithdrawMessage memory message
    )
        private
        validWithdrawMessage(message)
    {
        bytes32 messageHash = withdrawMessageHash(message);
        uint256 messageStartTime = block.timestamp + fraudWindowDuration;
        /// @dev This would occur if the relayer passed the same message twice.
        if (withdrawMessageStatus(messageHash) != WithdrawStatus.UNKNOWN) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "Message already exists");
        }
        /// @dev This would only occur if the same message Id was used for two different messages.
        if (withdrawMsgIdProcessed[message.withdrawId] != 0) {
            revert CanonicalBridgeTransactionRejected(message.withdrawId, "Message Id already exists");
        }
        startTime[messageHash] = messageStartTime;
        withdrawMsgIdProcessed[message.withdrawId] = block.number;

        /// @dev Transfer fee to feeReceiver.
        bool success = ITreasury(TREASURY).withdrawEth(
            message.feeReceiver,
            message.feeWei
        );
        /// @dev The following condition should never occur and the error should be unreachable code.
        if (!success) revert WithdrawFailed();

        emit WithdrawAuthorized(
            msg.sender,
            message,
            messageHash,
            messageStartTime
        );
    }

    /// @inheritdoc ICanonicalBridge
    /// @dev Pausable
    function claimWithdraw(
        WithdrawMessage calldata message
    )
        external
        override
        whenNotPaused
        nonReentrant
        validWithdrawMessage(message)
    {
        bool authorizedWithdrawer = (msg.sender == message.destination || hasRole(CLAIM_AUTHORITY_ROLE, msg.sender));
        if (!authorizedWithdrawer) {
            revert IAccessControl.AccessControlUnauthorizedAccount(msg.sender, CLAIM_AUTHORITY_ROLE);
        }

        bytes32 messageHash = withdrawMessageHash(message);
        if (withdrawMessageStatus(messageHash) != WithdrawStatus.PENDING) revert WithdrawUnauthorized();

        startTime[messageHash] = NEVER;
        emit WithdrawClaimed(message.destination, message.from, messageHash, message);

        /// @dev Transfer amountWei - feeWei to recipient.
        bool success = ITreasury(TREASURY).withdrawEth(
            message.destination,
            message.amountWei - message.feeWei
        );
        /// @dev The following condition should never occur and the error should be unreachable code.
        if (!success) revert WithdrawFailed();
    }

    // Admin

    /// @inheritdoc ICanonicalBridge
    /// @dev Access controlled
    function deleteWithdrawMessage(
        WithdrawMessage calldata message
    )
        external
        override
        validWithdrawMessage(message)
        onlyRole(WITHDRAW_CANCELLER_ROLE)
    {
        bytes32 messageHash = withdrawMessageHash(message);
        WithdrawStatus status = withdrawMessageStatus(messageHash);
        if (status != WithdrawStatus.PENDING && status != WithdrawStatus.PROCESSING) {
            revert CannotCancel();
        }
        startTime[messageHash] = 0;
        withdrawMsgIdProcessed[message.withdrawId] = 0;
        emit WithdrawMessageDeleted(msg.sender, message);
    }

    /// @inheritdoc ICanonicalBridge
    /// @dev Access controlled
    function setFraudWindowDuration(uint256 durationSeconds) public onlyRole(FRAUD_WINDOW_SETTER_ROLE) {
        if (durationSeconds < MIN_FRAUD_WINDOW_DURATION) revert DurationTooShort();
        _setFraudWindowDuration(durationSeconds);
    }

    function _setFraudWindowDuration(uint256 durationSeconds) internal {
        fraudWindowDuration = durationSeconds;
        emit FraudWindowSet(msg.sender, durationSeconds);
    }

    /// @dev Pause deposits
    /// @dev Access controlled
    function pause() external virtual onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @dev Unpause deposits
    /// @dev Access controlled
    function unpause() external virtual onlyRole(STARTER_ROLE) {
        _unpause();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

/// @title IEtherBridge
/// @notice Interface for a bridge contract that handles deposits of ether.
interface ICanonicalBridge {
    /// @notice Contains deposit details sent to the target rollup chain.
    /// @param sender The address which provided the ether to deposit.
    /// @param recipient Abi packed bytes32 of a base58-encoded Solana address on the target chain.
    /// @param amountGwei The amount deposited in Gwei.
    struct DepositMessage {
        address sender;
        bytes32 recipient;
        uint256 amountGwei;
    }

    /// @notice Contains withdraw details sent by an authoritative state updater.
    /// @param pubKey Public key of the primary txn signer.
    /// @param destination Receiver who can claim the withdraw.
    /// @param amountWei Amount of wei that can be withdrawn.
    /// @param withdrawId Unique identifier can be used once.
    /// @param feeReceiver The address that will receive the transaction fee.
    /// @param feeWei The amount of fee to deduct from the amountWei.
    struct WithdrawMessage {
        bytes32 from;
        address destination;
        uint256 amountWei;
        uint64 withdrawId;
        address feeReceiver;
        uint256 feeWei;
    }

    enum WithdrawStatus { UNKNOWN, PROCESSING, PENDING, CLOSED }

    /// @notice Emitted from the contract constructor.
    /// @param deployer The deployer address.
    /// @param owner The address that received the default permissions.
    /// @param treasuryAddress The address that will hold received funds.
    event Deployed(address indexed deployer, address owner, address treasuryAddress);

    /// @notice Emitted when the fraud window is set.
    /// @param sender The authority that updated the fraud window.
    /// @param durationSeconds The new fraud window.
    event FraudWindowSet(address indexed sender, uint256 durationSeconds);

    /// @notice Emitted on a successful deposit.
    /// @param sender The address of the user who made the deposit.
    /// @param recipient The recipient account on the target chain.
    /// @param amountWei The amount in wei deposited.
    event Deposited(
        address indexed sender,
        bytes32 indexed recipient,
        uint256 amountWei,
        uint256 amountLamports
    );

    /// @notice Emitted when a withdraw message is accepted.
    /// @param sender The address of the withdraw authority that forwarded the message.
    /// @param message The withdraw message accepted.
    /// @param messageHash The hash of the withdrawMessage.
    /// @param startTime The earliest timestamp when the withdraw can be executed.
    event WithdrawAuthorized(
        address indexed sender, 
        WithdrawMessage message, 
        bytes32 indexed messageHash, 
        uint256 startTime);

    /// @notice Emitted when a withdraw is claimed and executed.
    /// @param receiver The recipient of the funds who is also the requester.
    /// @param message The withdraw message includes details such as origin and amount.
    /// @param messageHash The hash of the withdrawMessage.
    event WithdrawClaimed(
        address indexed receiver,
        bytes32 indexed remoteSender,
        bytes32 indexed messageHash,
        WithdrawMessage message
    );

    /// @notice Emitted when an authorized withdraw is cancelled, by pre-image.
    /// @param authority The sender to authorized the cancellation.
    /// @param message The withdraw message that was cancelled.
    event WithdrawMessageDeleted(address authority, WithdrawMessage message);

    /// @notice Emitted when an authorized withdraw is cancelled, by hash.
    /// @param authority The sender to authorized the cancellation.
    /// @param messageHash The withdraw message hash that was cancelled.
    event WithdrawMessageHashDeleted(address indexed authority, bytes32 indexed messageHash);

    /// @notice Emitted when a withdraw authorization is cancelled.
    /// @param sender The authority that cancelled with the withdraw.
    /// @param messageHash The hash of the withdraw message that was cancelled.
    event WithdrawCancelled(address indexed sender, bytes32 indexed messageHash);

    /// @notice Emitted when the withdraw authorization is rejected.
    /// @param withdrawId The transactionId that was rejected.
    /// @dev withdrawId is 0 if deposit transaction. It is meaningful if a withdraw transaction or batch.
    error CanonicalBridgeTransactionRejected(uint64 withdrawId, string reason);

    /// @notice Emitted when the requested fraud window is less than the hard-code minimum.
    error DurationTooShort();

    /// @notice Emitted when the Treasury fails to withdraw funds as instructed.
    error WithdrawFailed();

    /// @notice Emitted when an attempted withdraw is unauthorized.
    error WithdrawUnauthorized();

    /// @notice Emitted when an unable to cancel an authorized withdraw.
    /// @dev The authorized withdraw must be in the PENDING state or it cannot be cancelled.
    error CannotCancel();

    /// @notice Emitted when a bytes32 input is empty.
    error EmptyBytes32();

    /// @notice Returns the pauser role id.
    function PAUSER_ROLE() external view returns (bytes32);

    /// @notice Returns the starter role id.
    function STARTER_ROLE() external view returns (bytes32);

    /// @notice Returns the withdraw authority role id.
    function WITHDRAW_AUTHORITY_ROLE() external view returns (bytes32);

    /// @notice Returns the claim authority role id.
    function CLAIM_AUTHORITY_ROLE() external view returns (bytes32);

    /// @notice Returns the withdraw canceller role id.
    function WITHDRAW_CANCELLER_ROLE() external view returns (bytes32);

    /// @notice Returns the fraud window duration setter role id.
    function FRAUD_WINDOW_SETTER_ROLE() external view returns (bytes32);

    /// @notice Returns the minimum wei required to acquire a single lamport.
    function MIN_DEPOSIT() external view returns (uint256);

    /// @notice Returns the address of the treasury that will receive locked funds.
    function TREASURY() external view returns (address);

    /// @notice Returns the fraud window duration that governs withdraw eligibility.
    function fraudWindowDuration() external view returns (uint256);

    /// @notice Returns the startTime of withdraw eligibility for a withdraw message hash.
    /// @param withdrawMessageHash A hash of a withdraw message.
    /// @dev Eth timestamp format is in seconds. zero is not possible for a withdraw message
    /// with a non-zero amount. 2^^256 means the withdraw has been claimed and can never
    /// be executed again.
    function startTime(bytes32 withdrawMessageHash) external view returns (uint256);

    /// @notice Returns the status of the withdraw message.
    /// @param message The message to check.
    function withdrawMessageStatus(WithdrawMessage calldata message) external view returns (WithdrawStatus);

    /// @notice Returns the status of the withdraw message.
    /// @param messageHash The message to check.
    function withdrawMessageStatus(bytes32 messageHash) external view returns (WithdrawStatus);

    /// @notice Set the duration to delay withdraw eligibility.
    /// @param durationSeconds The delay duration when withdraw messages are accepted.
    function setFraudWindowDuration(uint256 durationSeconds) external;

    /// @notice Allows users to deposit ether to the target chain.
    /// @dev Accepts Ether along with the deposit message. Emits the `Deposited` event upon success.
    /// @param recipient The recipient account on target chain.
    /// @param amountWei The amount in wei to deposit.
    function deposit(bytes32 recipient, uint256 amountWei) external payable;

    /// @notice Establishes permission to withdraw funds after the fraud window passes.
    /// @param messages abi.encoded array of Withdraw messages to authorize.
    function authorizeWithdraws(WithdrawMessage[] calldata messages) external;

    /// @notice Establishes permission to withdraw funds after the fraud window passes.
    /// @param message abi.encoded Withdraw message to authorize.
    function authorizeWithdraw(WithdrawMessage calldata message) external;

    /// @notice Allows the receiver to claim an authorized withdraw.
    /// @param message The message to execute.
    function claimWithdraw(WithdrawMessage calldata message) external;

    /// @notice Allows the fraud authority to cancel a pending withdraw.
    /// @param message The authorized withdraw message to cancel.
    function deleteWithdrawMessage(WithdrawMessage calldata message) external;

    /// @notice Returns the hash of a withdraw message.
    /// @param message The message to hash
    function withdrawMessageHash(WithdrawMessage calldata message) external pure returns (bytes32);

    /// @notice Returns the block number if the withdraw message id has been observed and recorded.
    /// @param withdrawMsgId The message id to inspect.
    function withdrawMsgIdProcessed(uint64 withdrawMsgId) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.8.21;

/**
 * @title ISemVer
 * @dev Interface for SemVer versioning within smart contracts.
 */
interface ISemVer {

    /// @dev Struct to hold the version components.
    /// @param major The major version component, incremented for incompatible API changes.
    /// @param minor The minor version component, incremented for added functionality in a backwards-compatible manner.
    /// @param patch The patch version component, incremented for backwards-compatible bug fixes.
    struct Version {
        uint8 major;
        uint8 minor;
        uint8 patch;
    }

    /// @dev Returns the major, minor, and patch components of the version as a struct.
    /// @return Version memory Returns the version details encapsulated in a Version struct.
    function getVersionComponents() external pure returns (Version memory);
}
// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.8.21;

/// @title ITreasury
/// @notice Interface for a treasury contract stores ether.
/// @dev This interface assumes the implementation will provide a fallback function to receive ether.
interface ITreasury {
    /// @notice Emitted when the treasury is re-initialized. 
    /// @param admin Address that initiated the re-initialization. 
    /// @param oldOwner Address that was granted various permissions. 
    event TreasuryReinitialized(address admin, address oldOwner);

    /// @notice Emitted when ether is deposited into the treasury.
    /// @param from The address of the sender who deposited ether.
    /// @param amountWei The amount of ether deposited.
    event TreasuryDeposit(address indexed from, uint256 amountWei);

    /// @notice Emitted when ether is withdrawn from the treasury.
    /// @param authority The sender of the withdraw instruction.
    /// @param to The address of the sender who received ether.
    /// @param amountWei The amount of ether withdrawn.
    event TreasuryWithdraw(
        address authority, 
        address indexed to, 
        uint256 amountWei
    );

    /// @notice Emitted when ether is withdrawn from the treasury during an emergency withdraw.
    /// @param to The address to which ether was sent.
    /// @param amountWei The amount of ether withdrawn.
    event EmergencyTreasuryWithdraw(address indexed to, uint256 amountWei);

    /// @notice Emitted when withdraws couldn't be sent to the receiver.
    error TreasuryTransferFailed();

    /// @notice Emitted when withdraw amount exceeds funds on hand.
    error InsufficientFunds();

    /// @notice Emitted when an input address is a prohibited address(0).
    error ZeroAddress();

    /// @notice Returns the depositor role id.
    function DEPOSITOR_ROLE() external view returns (bytes32);

    /// @notice Returns the withdraw authority role id.
    function WITHDRAW_AUTHORITY_ROLE() external view returns (bytes32);

    /// @notice Returns the pauser role id.
    function PAUSER_ROLE() external view returns (bytes32);

    /// @notice Returns the starter role id.
    function STARTER_ROLE() external view returns (bytes32);

    /// @notice Returns the upgrader role id.
    function UPGRADER_ROLE() external view returns (bytes32);

    /// @notice Returns the emergency authority role id. 
    function EMERGENCY_ROLE() external view returns (bytes32);

    /// @notice Reinitializes the Treasury. Grants roles to the owner.
    function reinitialize() external;

    /// @notice Accepts eth deposits. 
    function depositEth() external payable;

    /// @notice Withdraws Eth from the Treasury.
    /// @param to The receiver of the withdrawn Eth.
    /// @param amountWei The gross amount of Eth to withdraw.
    /// @return success True if the withdraw was succesful.
    function withdrawEth(
        address to, 
        uint256 amountWei
    ) external returns (bool success);

    /// @notice Stops deposits. Requires the PAUSER_ROLE.
    function pause() external;

    /// @notice Starts deposits. Requires the STARTER_ROLE.
    function unpause() external;

    /// @notice Withdraws an 'amount' of ether during emergencies.
    /// @param amountWei The amount of ether to be sent.
    function emergencyWithdraw(uint256 amountWei) external;
}