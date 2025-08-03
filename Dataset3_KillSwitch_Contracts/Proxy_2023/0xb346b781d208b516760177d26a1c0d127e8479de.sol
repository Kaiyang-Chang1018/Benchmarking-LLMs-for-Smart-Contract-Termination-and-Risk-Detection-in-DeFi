// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import {Initializable} from "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
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
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)

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
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
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
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {
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
    ) internal pure returns (address, RecoverError, bytes32) {
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
pragma solidity >=0.8.20;

import {
    CoreAccessControlInitiable,
    CoreAccessControlConfig
} from "../core/CoreAccessControl/v1/CoreAccessControlInitiable.sol";
import { CoreStopGuardian } from "../core/CoreStopGuardian/v1/CoreStopGuardian.sol";

import { CoreStopGuardianTrading } from "../core/CoreStopGuardianTrading/v1/CoreStopGuardianTrading.sol";
import { DefinitiveConstants } from "../core/libraries/DefinitiveConstants.sol";
import { ICoreSimpleSwapV1 } from "../core/CoreSimpleSwap/v1/ICoreSimpleSwapV1.sol";
import { InvalidMethod } from "../core/libraries/DefinitiveErrors.sol";
import { SignatureCheckerLib } from "../tools/SoladySnippets/SignatureCheckerLib.sol";

abstract contract BaseAccessControlInitiable is CoreAccessControlInitiable, CoreStopGuardian, CoreStopGuardianTrading {
    /**
     * @dev
     * Modifiers inherited from CoreAccessControl:
     * onlyDefinitive
     * onlyWhitelisted
     * onlyClientAdmin
     * onlyDefinitiveAdmin
     *
     * Modifiers inherited from CoreStopGuardian:
     * stopGuarded
     */

    function __BaseAccessControlInitiable__init(
        CoreAccessControlConfig calldata coreAccessControlConfig
    ) internal onlyInitializing {
        __CoreAccessControlInitiable__init(coreAccessControlConfig);
        _updateGlobalTradeGuardian(DefinitiveConstants.DEFAULT_GLOBAL_TRADE_GUARDIAN);
    }

    /// @dev Validate `userOp.signature` for the `userOpHash`.
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view override returns (uint256 validationData) {
        (address signerAddress, bytes memory signature) = abi.decode(userOp.signature, (address, bytes));
        bytes4 methodSig = bytes4(userOp.callData);

        if (hasRole(DEFAULT_ADMIN_ROLE, signerAddress)) {
            // Allow clients and admin to sign any method
        } else if (methodSig == this.entryPoint.selector) {
            // Allow read only call to get entrypoint address
        } else if (_isAuthorizedDefinitiveMethod(methodSig)) {
            _checkAccountIsPerformer(signerAddress);
        } else {
            revert InvalidMethod(methodSig);
        }

        bool success = SignatureCheckerLib.isValidSignatureNow(
            signerAddress,
            SignatureCheckerLib.toEthSignedMessageHash(userOpHash),
            signature
        );

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Returns 0 if the recovered address matches the owner.
            // Else returns 1, which is equivalent to:
            // `(success ? 0 : 1) | (uint256(validUntil) << 160) | (uint256(validAfter) << (160 + 48))`
            // where `validUntil` is 0 (indefinite) and `validAfter` is 0.
            validationData := iszero(success)
        }
    }

    function _isAuthorizedDefinitiveMethod(bytes4 methodSig) internal pure returns (bool) {
        return methodSig == ICoreSimpleSwapV1.swap.selector;
    }

    /**
     * @dev Inherited from CoreStopGuardianTrading
     */
    function updateGlobalTradeGuardian(address _globalTradeGuardian) external override onlyAdmins {
        return _updateGlobalTradeGuardian(_globalTradeGuardian);
    }

    /**
     * @dev Inherited from CoreStopGuardian
     */
    function enableStopGuardian() public override onlyAdmins {
        return _enableStopGuardian();
    }

    /**
     * @dev Inherited from CoreStopGuardian
     */
    function disableStopGuardian() public override onlyClientAdmin {
        return _disableStopGuardian();
    }

    /**
     * @dev Inherited from CoreStopGuardianTrading
     */

    function disableTrading() public override onlyAdmins {
        return _disableTrading();
    }

    /**
     * @dev Inherited from CoreStopGuardianTrading
     */
    function enableTrading() public override onlyAdmins {
        return _enableTrading();
    }

    /**
     * @dev Inherited from CoreStopGuardianTrading
     */
    function disableWithdrawals() public override onlyClientAdmin {
        return _disableWithdrawals();
    }

    /**
     * @dev Inherited from CoreStopGuardianTrading
     */
    function enableWithdrawals() public override onlyClientAdmin {
        return _enableWithdrawals();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { BaseAccessControlInitiable } from "./BaseAccessControlInitiable.sol";
import { DefinitiveAssets, IERC20 } from "../core/libraries/DefinitiveAssets.sol";
import { DefinitiveConstants } from "../core/libraries/DefinitiveConstants.sol";
import { InvalidFeePercent } from "../core/libraries/DefinitiveErrors.sol";
import { IGlobalGuardian } from "../tools/GlobalGuardian/IGlobalGuardian.sol";

struct CoreFeesConfig {
    address payable feeAccount;
}

abstract contract BaseFeesInitiable is BaseAccessControlInitiable {
    using DefinitiveAssets for IERC20;

    function _handleFeesOnAmount(address token, uint256 amount, uint256 feePct) internal returns (uint256 feeAmount) {
        uint256 mMaxFeePCT = DefinitiveConstants.MAX_FEE_PCT;
        if (feePct > mMaxFeePCT) {
            revert InvalidFeePercent();
        }

        feeAmount = (amount * feePct) / mMaxFeePCT;
        if (feeAmount == 0) {
            return feeAmount;
        }

        if (token == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            if (_msgSender() == entryPoint()) {
                DefinitiveAssets.safeTransferETH(FEE_ACCOUNT(), feeAmount);
            } else {
                DefinitiveAssets.safeTransferETH(_msgSender(), feeAmount);
            }
        } else {
            IERC20(token).safeTransfer(FEE_ACCOUNT(), feeAmount);
        }
    }

    function FEE_ACCOUNT() public view returns (address) {
        return payable(IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).feeAccount());
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { BaseAccessControlInitiable } from "../../BaseAccessControlInitiable.sol";
import { IBaseNativeWrapperV1 } from "./IBaseNativeWrapperV1.sol";
import { DefinitiveAssets, IERC20 } from "../../../core/libraries/DefinitiveAssets.sol";

struct BaseNativeWrapperConfig {
    address payable wrappedNativeAssetAddress;
}

abstract contract BaseNativeWrapperInitiable is IBaseNativeWrapperV1, BaseAccessControlInitiable {
    using DefinitiveAssets for IERC20;

    /// @custom:storage-location erc7201:definitive.storage.BaseNativeWrapper
    struct BaseNativeWrapperStorage {
        address payable wrappedNativeAssetAddress;
    }

    // keccak256(abi.encode(uint256(keccak256("definitive.storage.BaseNativeWrapper")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BaseNativeWrapperStorageLocation =
        0x57fbe06c102296dbdfaa9e064bb0d9f51d09253320913950d5de84e9a7e6e100;

    function _getBaseNativeWrapperStorage()
        private
        pure
        returns (BaseNativeWrapperStorage storage baseNativeWrapperStorage)
    {
        assembly {
            baseNativeWrapperStorage.slot := BaseNativeWrapperStorageLocation
        }
    }

    function __BaseNativeWrapperInitiable__init(
        BaseNativeWrapperConfig calldata baseNativeWrapperConfig
    ) internal onlyInitializing {
        BaseNativeWrapperStorage storage s = _getBaseNativeWrapperStorage();
        s.wrappedNativeAssetAddress = baseNativeWrapperConfig.wrappedNativeAssetAddress;
    }

    function WRAPPED_NATIVE_ASSET_ADDRESS() public view returns (address payable) {
        return _getBaseNativeWrapperStorage().wrappedNativeAssetAddress;
    }

    /**
     * @notice Publicly accessible method to wrap native assets
     * @param amount Amount of native assets to wrap
     */
    function wrap(uint256 amount) public onlyWhitelisted nonReentrant {
        _wrap(amount);
        emit NativeAssetWrap(_msgSender(), amount, true /* wrappingToNative */);
    }

    /**
     * @notice Publicly accessible method to unwrap native assets
     * @param amount Amount of tokenized assets to unwrap
     */
    function unwrap(uint256 amount) public onlyWhitelisted nonReentrant {
        _unwrap(amount);
        emit NativeAssetWrap(_msgSender(), amount, false /* wrappingToNative */);
    }

    /**
     * @notice Publicly accessible method to unwrap full balance of native assets
     * @dev Method is not marked as `nonReentrant` since it is a wrapper around `unwrap`
     */
    function unwrapAll() external onlyWhitelisted {
        return unwrap(DefinitiveAssets.getBalance(WRAPPED_NATIVE_ASSET_ADDRESS()));
    }

    /**
     * @notice Internal method to wrap native assets
     * @dev Override this method with native asset wrapping implementation
     */
    function _wrap(uint256 amount) internal virtual;

    /**
     * @notice Internal method to unwrap native assets
     * @dev Override this method with native asset unwrapping implementation
     */
    function _unwrap(uint256 amount) internal virtual;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface IBaseNativeWrapperV1 {
    event NativeAssetWrap(address actor, uint256 amount, bool indexed wrappingToNative);

    function WRAPPED_NATIVE_ASSET_ADDRESS() external view returns (address payable);

    function wrap(uint256 amount) external;

    function unwrap(uint256 amount) external;

    function unwrapAll() external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { BaseAccessControlInitiable } from "./BaseAccessControlInitiable.sol";
import { AccountNotAdmin, InvalidSignature } from "../core/libraries/DefinitiveErrors.sol";

/**
 * @title BaseRecoverSignerInitiable
 * @author WardenJakx
 * @notice `isValidSignature` ensures the signer is a valid client
 */
abstract contract BaseRecoverSignerInitiable is BaseAccessControlInitiable, IERC1271 {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant EIP_1271_RETURN_VALUE = 0x1626ba7e;

    /**
     * @notice Verifies that the signer is the owner of the signing contract.
     */
    function isValidSignature(bytes32 _hash, bytes calldata _encodedSignature) external view override returns (bytes4) {
        (address clientAdminAddress, bytes memory signature) = abi.decode(_encodedSignature, (address, bytes));

        if (!hasRole(DEFAULT_ADMIN_ROLE, clientAdminAddress)) {
            revert AccountNotAdmin(clientAdminAddress);
        }

        if (clientAdminAddress.code.length > 0) {
            return IERC1271(clientAdminAddress).isValidSignature(_hash, signature);
        } else if (ECDSA.recover(_hash, signature) == clientAdminAddress) {
            return EIP_1271_RETURN_VALUE;
        }

        revert InvalidSignature();
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { BaseFeesInitiable } from "./BaseFeesInitiable.sol";
import { CoreSimpleSwapInitiable, SwapPayload } from "../core/CoreSimpleSwap/v1/CoreSimpleSwapInitiable.sol";
import { DefinitiveConstants } from "../core/libraries/DefinitiveConstants.sol";
import { InvalidFeePercent, SlippageExceeded } from "../core/libraries/DefinitiveErrors.sol";
import { ICoreSwapHandlerV1 } from "../core/CoreSwapHandler/ICoreSwapHandlerV1.sol";

abstract contract BaseSimpleSwapInitiable is BaseFeesInitiable, CoreSimpleSwapInitiable {
    function swap(
        SwapPayload[] memory payloads,
        address outputToken,
        uint256 amountOutMin,
        uint256 feePct
    ) external payable override onlyDefinitive nonReentrant stopGuarded tradingEnabled returns (uint256) {
        if (feePct > DefinitiveConstants.MAX_FEE_PCT) {
            revert InvalidFeePercent();
        }

        (uint256[] memory inputAmounts, uint256 outputAmount) = _swap(payloads, outputToken);
        if (outputAmount < amountOutMin) {
            revert SlippageExceeded(outputAmount, amountOutMin);
        }

        address[] memory swapTokens = new address[](payloads.length);
        uint256 swapTokensLength = swapTokens.length;
        for (uint256 i; i < swapTokensLength; ) {
            swapTokens[i] = payloads[i].swapToken;
            unchecked {
                ++i;
            }
        }

        uint256 feeAmount;
        if (FEE_ACCOUNT() != address(0) && outputAmount > 0 && feePct > 0) {
            feeAmount = _handleFeesOnAmount(outputToken, outputAmount, feePct);
        }
        emit SwapHandled(swapTokens, inputAmounts, outputToken, outputAmount, feeAmount);

        return outputAmount;
    }

    function _getEncodedSwapHandlerCalldata(
        SwapPayload memory payload,
        address expectedOutputToken,
        bool isDelegateCall
    ) internal pure override returns (bytes memory) {
        bytes4 selector = isDelegateCall
            ? ICoreSwapHandlerV1.swapDelegate.selector
            : ICoreSwapHandlerV1.swapCall.selector;
        ICoreSwapHandlerV1.SwapParams memory _params = ICoreSwapHandlerV1.SwapParams({
            inputAssetAddress: payload.swapToken,
            inputAmount: payload.amount,
            outputAssetAddress: expectedOutputToken,
            minOutputAmount: payload.amountOutMin,
            data: payload.handlerCalldata,
            signature: payload.signature
        });
        return abi.encodeWithSelector(selector, _params);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { CoreDeposit } from "../../../core/CoreDeposit/v1/CoreDeposit.sol";
import { CoreWithdraw } from "../../../core/CoreWithdraw/v1/CoreWithdraw.sol";
import { BaseAccessControlInitiable } from "../../BaseAccessControlInitiable.sol";

abstract contract BaseTransfersInitiable is CoreDeposit, CoreWithdraw, BaseAccessControlInitiable {
    function deposit(
        uint256[] calldata amounts,
        address[] calldata erc20Tokens
    ) external payable virtual override onlyClientAdmin nonReentrant stopGuarded {
        return _deposit(amounts, erc20Tokens);
    }

    function withdraw(
        uint256 amount,
        address erc20Token
    ) public virtual override onlyClientAdmin nonReentrant stopGuarded withdrawalsEnabled returns (bool) {
        return _withdraw(amount, erc20Token);
    }

    function withdrawTo(
        uint256 amount,
        address erc20Token,
        address to
    ) public virtual override onlyWhitelisted nonReentrant stopGuarded withdrawalsEnabled returns (bool) {
        // `to` account must be a client
        _checkRole(ROLE_CLIENT, to);

        return _withdrawTo(amount, erc20Token, to);
    }

    function withdrawAll(
        address[] calldata tokens
    ) public virtual override onlyClientAdmin nonReentrant stopGuarded withdrawalsEnabled returns (bool) {
        return _withdrawAll(tokens);
    }

    function withdrawAllTo(
        address[] calldata tokens,
        address to
    ) public virtual override onlyWhitelisted stopGuarded withdrawalsEnabled returns (bool) {
        _checkRole(ROLE_CLIENT, to);
        return _withdrawAllTo(tokens, to);
    }

    function supportsNativeAssets() public pure virtual override returns (bool) {
        return false;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { IBaseNativeWrapperV1 } from "../../BaseNativeWrapper/v1/IBaseNativeWrapperV1.sol";
import { BaseTransfersInitiable } from "../../BaseTransfers/v1/BaseTransfersInitiable.sol";
import { CoreTransfersNative } from "../../../core/CoreTransfersNative/v1/CoreTransfersNative.sol";

abstract contract BaseTransfersNativeInitiable is IBaseNativeWrapperV1, CoreTransfersNative, BaseTransfersInitiable {
    function deposit(
        uint256[] calldata amounts,
        address[] calldata assetAddresses
    ) external payable override onlyClientAdmin nonReentrant stopGuarded {
        _depositNativeAndERC20(amounts, assetAddresses);
        emit Deposit(_msgSender(), assetAddresses, amounts);
    }

    function supportsNativeAssets() public pure virtual override returns (bool) {
        return true;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { AccessControl as OZAccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ICoreAccessControlV1, CoreAccessControlConfig } from "./ICoreAccessControlV1.sol";
import { AccountNotAdmin, AccountNotWhitelisted, AccountMissingRole } from "../../libraries/DefinitiveErrors.sol";
import { IGlobalGuardian } from "../../../tools/GlobalGuardian/IGlobalGuardian.sol";
import { CoreGlobalGuardian } from "../../CoreGlobalGuardian/CoreGlobalGuardian.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { CoreAccountAbstraction, Unauthorized } from "../../CoreAccountAbstraction/CoreAccountAbstraction.sol";

abstract contract CoreAccessControlInitiable is
    ICoreAccessControlV1,
    OZAccessControl,
    Initializable,
    CoreGlobalGuardian,
    ReentrancyGuardUpgradeable,
    CoreAccountAbstraction
{
    /// @custom:storage-location erc7201:definitive.storage.CoreAccessControl
    struct CoreAccessControlStorage {
        mapping(bytes32 => RoleDataPasskeys) roles;
    }

    struct RoleDataPasskeys {
        mapping(bytes => bool) hasRole;
        bytes32 adminRole;
    }

    /* solhint-disable max-line-length */
    // keccak256(abi.encode(uint256(keccak256("definitive.storage.CoreAccessControl")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CoreAccessControlStorageLocation =
        0x2d4c43e2acbd2a853aab6947a7bb2f7cae5309ca1d492e32a85b53ceb22cc800;

    /* solhint-enable max-line-length */
    function _getCoreAccessControlStorage() private pure returns (CoreAccessControlStorage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := CoreAccessControlStorageLocation
        }
    }

    // roles
    bytes32 public constant ROLE_DEFINITIVE = keccak256("DEFINITIVE");
    bytes32 public constant ROLE_DEFINITIVE_ADMIN = keccak256("DEFINITIVE_ADMIN");
    bytes32 public constant ROLE_CLIENT = keccak256("CLIENT");
    bytes32 public constant ROLE_TRADER = keccak256("TRADER");

    modifier onlyDefinitive() {
        if (!_accountIsPerformer(_msgSender()) && msg.sender != entryPoint()) {
            revert AccountMissingRole(_msgSender(), ROLE_DEFINITIVE);
        }
        _;
    }
    modifier onlyDefinitiveAdmin() {
        bool isDefinitiveAdmin = IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).accountIsDefinitiveAdmin(_msgSender());
        if (!isDefinitiveAdmin) {
            revert AccountMissingRole(_msgSender(), ROLE_DEFINITIVE_ADMIN);
        }
        _;
    }
    modifier onlyClientAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) && msg.sender != entryPoint()) {
            revert AccountMissingRole(_msgSender(), DEFAULT_ADMIN_ROLE);
        }
        _;
    }

    // default admin + definitive admin
    modifier onlyAdmins() {
        bool isAdmins = (hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
            IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).accountIsDefinitiveAdmin(_msgSender()));
        if (!isAdmins) {
            revert AccountNotAdmin(_msgSender());
        }
        _;
    }
    // client + definitive
    modifier onlyWhitelisted() {
        bool isWhitelisted = (hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
            IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).accountIsPerformer(_msgSender()));
        if (!isWhitelisted) {
            revert AccountNotWhitelisted(_msgSender());
        }
        _;
    }

    modifier onlyEntryPointOrClient() {
        if (msg.sender != entryPoint() && !hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert Unauthorized();
        }
        _;
    }

    function isPasskeyClient(bytes memory account) public view returns (bool) {
        return _getCoreAccessControlStorage().roles[DEFAULT_ADMIN_ROLE].hasRole[account];
    }

    function isPasskeyTrader(bytes memory account) public view returns (bool) {
        return _getCoreAccessControlStorage().roles[ROLE_TRADER].hasRole[account];
    }

    function __CoreAccessControlInitiable__init(CoreAccessControlConfig calldata cfg) internal onlyInitializing {
        __ReentrancyGuard_init();

        // admin
        _grantRole(DEFAULT_ADMIN_ROLE, cfg.admin);

        uint256 cfgClientLength = cfg.client.length;
        for (uint256 i; i < cfgClientLength; ) {
            _grantRole(ROLE_CLIENT, cfg.client[i]);
            _grantRole(DEFAULT_ADMIN_ROLE, cfg.client[i]);
            unchecked {
                ++i;
            }
        }

        CoreAccessControlStorage storage $ = _getCoreAccessControlStorage();
        for (uint256 i; i < cfg.passkeyClients.length; ) {
            $.roles[DEFAULT_ADMIN_ROLE].hasRole[cfg.passkeyClients[i]] = true;

            unchecked {
                ++i;
            }
        }

        /// Traders are NOT clients as should not be able to withdraw
        /// We must create a role specific to traders (is still backwards compatible)
        for (uint256 i; i < cfg.traders.length; ) {
            $.roles[ROLE_TRADER].hasRole[cfg.passkeyTraders[i]] = true;

            unchecked {
                ++i;
            }
        }
    }

    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) public payable override onlyEntryPointOrClient returns (bytes memory result) {
        return _execute(target, value, data);
    }

    function executeBatch(
        Call[] calldata calls
    ) public payable override onlyEntryPointOrClient returns (bytes[] memory results) {
        return _executeBatch(calls);
    }

    function _checkRole(bytes32 role, address account) internal view virtual override {
        if (!hasRole(role, account)) {
            revert AccountMissingRole(account, role);
        }
    }

    function _checkAccountIsPerformer(address account) internal view virtual {
        if (!_accountIsPerformer(account)) {
            revert AccountMissingRole(account, ROLE_DEFINITIVE);
        }
    }

    function _accountIsPerformer(address account) internal view returns (bool) {
        return IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).accountIsPerformer(account);
    }

    /**
     * @dev Grants passkey client role to the given account.
     *
     * Requirements:
     * - the caller must have the DEFAULT_ADMIN_ROLE.
     */
    function grantPasskeyClientRole(bytes memory account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        CoreAccessControlStorage storage $ = _getCoreAccessControlStorage();
        if (!$.roles[DEFAULT_ADMIN_ROLE].hasRole[account]) {
            $.roles[DEFAULT_ADMIN_ROLE].hasRole[account] = true;
            emit RoleGranted(DEFAULT_ADMIN_ROLE, address(bytes20(account)), _msgSender());
        }
    }

    /**
     * @dev Revokes passkey client role from the given account.
     *
     * Requirements:
     * - the caller must have the DEFAULT_ADMIN_ROLE.
     */
    function revokePasskeyClientRole(bytes memory account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        CoreAccessControlStorage storage $ = _getCoreAccessControlStorage();
        if ($.roles[DEFAULT_ADMIN_ROLE].hasRole[account]) {
            $.roles[DEFAULT_ADMIN_ROLE].hasRole[account] = false;
            emit RoleRevoked(DEFAULT_ADMIN_ROLE, address(bytes20(account)), _msgSender());
        }
    }

    /**
     * @dev Grants passkey trader role to the given account.
     *
     * Requirements:
     * - the caller must have either the DEFAULT_ADMIN_ROLE or ROLE_TRADER.
     */
    function grantPasskeyTraderRole(bytes memory account) public virtual {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) && !hasRole(ROLE_TRADER, _msgSender())) {
            revert AccountMissingRole(_msgSender(), DEFAULT_ADMIN_ROLE);
        }
        CoreAccessControlStorage storage $ = _getCoreAccessControlStorage();
        if (!$.roles[ROLE_TRADER].hasRole[account]) {
            $.roles[ROLE_TRADER].hasRole[account] = true;
            emit RoleGranted(ROLE_TRADER, address(bytes20(account)), _msgSender());
        }
    }

    /**
     * @dev Revokes passkey trader role from the given account.
     *
     * Requirements:
     * - the caller must have the DEFAULT_ADMIN_ROLE.
     */
    function revokePasskeyTraderRole(bytes memory account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        CoreAccessControlStorage storage $ = _getCoreAccessControlStorage();
        if ($.roles[ROLE_TRADER].hasRole[account]) {
            $.roles[ROLE_TRADER].hasRole[account] = false;
            emit RoleRevoked(ROLE_TRADER, address(bytes20(account)), _msgSender());
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

struct CoreAccessControlConfig {
    address admin;
    address[] client;
    address[] traders;
    // admin = clients
    bytes[] passkeyClients;
    bytes[] passkeyTraders;
}

interface ICoreAccessControlV1 is IAccessControl {
    function ROLE_CLIENT() external returns (bytes32);

    function ROLE_DEFINITIVE() external returns (bytes32);

    function ROLE_DEFINITIVE_ADMIN() external returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import { SignatureCheckerLib } from "../../tools/SoladySnippets/SignatureCheckerLib.sol";
import { DefinitiveConstants } from "../libraries/DefinitiveConstants.sol";

error Unauthorized();

abstract contract CoreAccountAbstraction {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The packed ERC4337 user operation (userOp) struct.
    struct PackedUserOperation {
        address sender;
        uint256 nonce;
        bytes initCode; // Factory address and `factoryData` (or empty).
        bytes callData;
        bytes32 accountGasLimits; // `verificationGas` (16 bytes) and `callGas` (16 bytes).
        uint256 preVerificationGas;
        bytes32 gasFees; // `maxPriorityFee` (16 bytes) and `maxFeePerGas` (16 bytes).
        bytes paymasterAndData; // Paymaster fields (or empty).
        bytes signature;
    }

    /// @dev Call struct for the `executeBatch` function.
    struct Call {
        address target;
        uint256 value;
        bytes data;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The function selector is not recognized.
    error FnSelectorNotRecognized();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        ENTRY POINT                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the canonical ERC4337 EntryPoint contract (0.7).
    /// Override this function to return a different EntryPoint.
    function entryPoint() public view virtual returns (address) {
        return DefinitiveConstants.ENTRYPOINT_0_7;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    EXECUTION OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Execute a call from this account.
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) public payable virtual returns (bytes memory result);

    /// @dev Execute a sequence of calls from this account.
    function executeBatch(Call[] calldata calls) public payable virtual returns (bytes[] memory results);

    function _execute(address target, uint256 value, bytes calldata data) internal returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            calldatacopy(result, data.offset, data.length)
            if iszero(call(gas(), target, value, result, data.length, codesize(), 0x00)) {
                // Bubble up the revert if the call reverts.
                returndatacopy(result, 0x00, returndatasize())
                revert(result, returndatasize())
            }
            mstore(result, returndatasize()) // Store the length.
            let o := add(result, 0x20)
            returndatacopy(o, 0x00, returndatasize()) // Copy the returndata.
            mstore(0x40, add(o, returndatasize())) // Allocate the memory.
        }
    }

    function _executeBatch(Call[] calldata calls) internal returns (bytes[] memory results) {
        /// @solidity memory-safe-assembly
        assembly {
            results := mload(0x40)
            mstore(results, calls.length)
            let r := add(0x20, results)
            let m := add(r, shl(5, calls.length))
            calldatacopy(r, calls.offset, shl(5, calls.length))
            for {
                let end := m
            } iszero(eq(r, end)) {
                r := add(r, 0x20)
            } {
                let e := add(calls.offset, mload(r))
                let o := add(e, calldataload(add(e, 0x40)))
                calldatacopy(m, add(o, 0x20), calldataload(o))
                // forgefmt: disable-next-item
                if iszero(
                    call(gas(), calldataload(e), calldataload(add(e, 0x20)), m, calldataload(o), codesize(), 0x00)
                ) {
                    // Bubble up the revert if the call reverts.
                    returndatacopy(m, 0x00, returndatasize())
                    revert(m, returndatasize())
                }
                mstore(r, m) // Append `m` into `results`.
                mstore(m, returndatasize()) // Store the length,
                let p := add(m, 0x20)
                returndatacopy(p, 0x00, returndatasize()) // and copy the returndata.
                m := add(p, returndatasize()) // Advance `m`.
            }
            mstore(0x40, m) // Allocate the memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   VALIDATION OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Validates the signature and nonce.
    /// The EntryPoint will make the call to the recipient only if
    /// this validation call returns successfully.
    ///
    /// Signature failure should be reported by returning 1 (see: `_validateSignature`).
    /// This allows making a "simulation call" without a valid signature.
    /// Other failures (e.g. nonce mismatch, or invalid signature format)
    /// should still revert to signal failure.
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external payable virtual onlyEntryPoint payPrefund(missingAccountFunds) returns (uint256 validationData) {
        validationData = _validateSignature(userOp, userOpHash);
    }

    /// @dev Validate `userOp.signature` for the `userOpHash`.
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData);

    /// @dev Override to validate the nonce of the userOp.
    /// This method may validate the nonce requirement of this account.
    /// e.g.
    /// To limit the nonce to use sequenced userOps only (no "out of order" userOps):
    ///      `require(nonce < type(uint64).max)`
    /// For a hypothetical account that *requires* the nonce to be out-of-order:
    ///      `require(nonce & type(uint64).max == 0)`
    ///
    /// The actual nonce uniqueness is managed by the EntryPoint, and thus no other
    /// action is needed by the account itself.
    function _validateNonce(uint256 nonce) internal virtual {
        nonce = nonce; // Silence unused variable warning.
    }

    /// @dev Sends to the EntryPoint (i.e. `msg.sender`) the missing funds for this transaction.
    /// Subclass MAY override this modifier for better funds management.
    /// (e.g. send to the EntryPoint more than the minimum required, so that in future transactions
    /// it will not be required to send again)
    ///
    /// `missingAccountFunds` is the minimum value this modifier should send the EntryPoint,
    /// which MAY be zero, in case there is enough deposit, or the userOp has a paymaster.
    // solhint-disable-next-line no-inline-assembly
    modifier payPrefund(uint256 missingAccountFunds) virtual {
        _;
        /// @solidity memory-safe-assembly
        assembly {
            if missingAccountFunds {
                // Ignore failure (it's EntryPoint's job to verify, not the account's).
                pop(call(gas(), caller(), missingAccountFunds, codesize(), 0x00, codesize(), 0x00))
            }
        }
    }

    /// @dev Requires that the caller is the EntryPoint.
    modifier onlyEntryPoint() virtual {
        if (msg.sender != entryPoint()) revert Unauthorized();
        _;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreDepositV1 } from "./ICoreDepositV1.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { DefinitiveAssets, IERC20 } from "../../libraries/DefinitiveAssets.sol";

import { InvalidInputs } from "../../libraries/DefinitiveErrors.sol";

abstract contract CoreDeposit is ICoreDepositV1, Context {
    using DefinitiveAssets for IERC20;

    function deposit(uint256[] calldata amounts, address[] calldata assetAddresses) external payable virtual;

    function _deposit(uint256[] calldata amounts, address[] calldata erc20Tokens) internal virtual {
        _depositERC20(amounts, erc20Tokens);

        emit Deposit(_msgSender(), erc20Tokens, amounts);
    }

    function _depositERC20(uint256[] calldata amounts, address[] calldata erc20Tokens) internal {
        uint256 amountsLength = amounts.length;
        if (amountsLength != erc20Tokens.length) {
            revert InvalidInputs();
        }

        for (uint256 i; i < amountsLength; ) {
            IERC20(erc20Tokens[i]).safeTransferFrom(_msgSender(), address(this), amounts[i]);
            unchecked {
                ++i;
            }
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreDepositV1 {
    event Deposit(address indexed actor, address[] assetAddresses, uint256[] amounts);

    function deposit(uint256[] calldata amounts, address[] calldata assetAddresses) external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

abstract contract CoreGlobalGuardian {
    event GlobalTradeGuardianUpdate(address indexed globalTradeGuardian);

    /// @custom:storage-location erc7201:definitive.storage.CoreGlobalGuardian
    struct CoreGlobalGuardianStorage {
        address GLOBAL_TRADE_GUARDIAN;
    }

    /// keccak256(abi.encode(uint256(keccak256("definitive.storage.CoreGlobalGuardian"))- 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CoreGlobalGuardianStorageLocation =
        0x96888095fca464b4a45fa21ec2cd73681252b1aee41fb5e30dbff9a53008bb00;

    function _getCoreGlobalGuardianStorage() private pure returns (CoreGlobalGuardianStorage storage $) {
        assembly {
            $.slot := CoreGlobalGuardianStorageLocation
        }
    }

    function GLOBAL_TRADE_GUARDIAN() public view returns (address) {
        CoreGlobalGuardianStorage storage $ = _getCoreGlobalGuardianStorage();
        return $.GLOBAL_TRADE_GUARDIAN;
    }

    function updateGlobalTradeGuardian(address _globalTradeGuardian) external virtual;

    function _updateGlobalTradeGuardian(address _globalTradeGuardian) internal {
        CoreGlobalGuardianStorage storage $ = _getCoreGlobalGuardianStorage();
        $.GLOBAL_TRADE_GUARDIAN = _globalTradeGuardian;
        emit GlobalTradeGuardianUpdate(_globalTradeGuardian);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreMulticallV1 } from "./ICoreMulticallV1.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { DefinitiveAssets } from "../../libraries/DefinitiveAssets.sol";

/* solhint-disable max-line-length */
/**
 * @notice Implements openzeppelin/contracts/utils/Multicall.sol
 * Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5b027e517e6aee69f4b4b2f5e78274ac8ee53513/contracts/utils/Multicall.sol solhint-disable max-line-length
 */
/* solhint-enable max-line-length */
abstract contract CoreMulticall is ICoreMulticallV1 {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        uint256 dataLength = data.length;
        results = new bytes[](dataLength);
        for (uint256 i; i < dataLength; ) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
            unchecked {
                ++i;
            }
        }
    }

    function getBalance(address assetAddress) public view returns (uint256) {
        return DefinitiveAssets.getBalance(assetAddress);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreMulticallV1 {
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);

    function getBalance(address assetAddress) external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreSimpleSwapV1 } from "./ICoreSimpleSwapV1.sol";
import { DefinitiveAssets, IERC20 } from "../../libraries/DefinitiveAssets.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { CallUtils } from "../../../tools/BubbleReverts/BubbleReverts.sol";
import { DefinitiveConstants } from "../../libraries/DefinitiveConstants.sol";
import {
    InvalidSwapHandler,
    InsufficientSwapTokenBalance,
    SwapTokenIsOutputToken,
    InvalidOutputToken,
    InvalidReportedOutputAmount,
    InvalidExecutedOutputAmount
} from "../../libraries/DefinitiveErrors.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { SwapPayload } from "./ICoreSimpleSwapV1.sol";
import { CoreGlobalGuardian } from "../../CoreGlobalGuardian/CoreGlobalGuardian.sol";
import { IGlobalGuardian } from "../../../tools/GlobalGuardian/IGlobalGuardian.sol";

struct CoreSimpleSwapConfig {
    address[] swapHandlers;
}

abstract contract CoreSimpleSwapInitiable is ICoreSimpleSwapV1, Context, Initializable, CoreGlobalGuardian {
    using DefinitiveAssets for IERC20;

    function swap(
        SwapPayload[] memory payloads,
        address outputToken,
        uint256 amountOutMin,
        uint256 feePct
    ) external payable virtual returns (uint256 outputAmount);

    /* solhint-disable code-complexity */

    function _swap(
        SwapPayload[] memory payloads,
        address expectedOutputToken
    ) internal returns (uint256[] memory inputTokenAmounts, uint256 outputTokenAmount) {
        uint256 payloadsLength = payloads.length;
        inputTokenAmounts = new uint256[](payloadsLength);
        uint256 outputTokenBalanceStart = DefinitiveAssets.getBalance(expectedOutputToken);
        address mGLOBAL_TRADE_GUARDIAN = GLOBAL_TRADE_GUARDIAN();
        address mSEND_FEE_TO_SENDER_ALIAS = DefinitiveConstants.SEND_FEE_TO_SENDER_ALIAS;

        for (uint256 i; i < payloadsLength; ) {
            SwapPayload memory payload = payloads[i];

            if (
                payload.handler == mSEND_FEE_TO_SENDER_ALIAS &&
                payload.swapToken == DefinitiveConstants.NATIVE_ASSET_ADDRESS
            ) {
                inputTokenAmounts[i] = payload.amount;
                if (_msgSender() == DefinitiveConstants.ENTRYPOINT_0_7) {
                    DefinitiveAssets.safeTransferETH(
                        IGlobalGuardian(mGLOBAL_TRADE_GUARDIAN).feeAccount(),
                        payload.amount
                    );
                } else {
                    DefinitiveAssets.safeTransferETH(_msgSender(), payload.amount);
                }

                unchecked {
                    ++i;
                }
                continue;
            }

            if (payload.handler == mSEND_FEE_TO_SENDER_ALIAS) {
                inputTokenAmounts[i] = payload.amount;
                DefinitiveAssets.safeTransfer(
                    IERC20(payload.swapToken),
                    IGlobalGuardian(mGLOBAL_TRADE_GUARDIAN).feeAccount(),
                    payload.amount
                );
                unchecked {
                    ++i;
                }
                continue;
            }

            if (!IGlobalGuardian(mGLOBAL_TRADE_GUARDIAN).accountIsSwapHandler(payload.handler)) {
                revert InvalidSwapHandler();
            }

            if (expectedOutputToken == payload.swapToken) {
                revert SwapTokenIsOutputToken();
            }

            uint256 outputTokenBalanceBefore = DefinitiveAssets.getBalance(expectedOutputToken);
            inputTokenAmounts[i] = DefinitiveAssets.getBalance(payload.swapToken);

            (uint256 _outputAmount, address _outputToken) = _processSwap(payload, expectedOutputToken);

            if (_outputToken != expectedOutputToken) {
                revert InvalidOutputToken();
            }
            if (_outputAmount < payload.amountOutMin) {
                revert InvalidReportedOutputAmount();
            }
            uint256 outputTokenBalanceAfter = DefinitiveAssets.getBalance(expectedOutputToken);

            if ((outputTokenBalanceAfter - outputTokenBalanceBefore) < payload.amountOutMin) {
                revert InvalidExecutedOutputAmount();
            }

            // Update `inputTokenAmounts` to reflect the amount of tokens actually swapped
            inputTokenAmounts[i] -= DefinitiveAssets.getBalance(payload.swapToken);
            unchecked {
                ++i;
            }
        }

        outputTokenAmount = DefinitiveAssets.getBalance(expectedOutputToken) - outputTokenBalanceStart;
    }

    /* solhint-enable code-complexity */

    function _processSwap(SwapPayload memory payload, address expectedOutputToken) private returns (uint256, address) {
        // Override payload.amount with validated amount
        payload.amount = _getValidatedPayloadAmount(payload);

        bytes memory _calldata = _getEncodedSwapHandlerCalldata(payload, expectedOutputToken, payload.isDelegate);

        bool _success;
        bytes memory _returnBytes;
        if (payload.isDelegate) {
            // slither-disable-next-line all
            (_success, _returnBytes) = payload.handler.delegatecall(_calldata);
        } else {
            uint256 msgValue = _prepareAssetsForNonDelegateHandlerCall(payload, payload.amount);
            (_success, _returnBytes) = payload.handler.call{ value: msgValue }(_calldata);
        }

        if (!_success) {
            CallUtils.revertFromReturnedData(_returnBytes);
        }

        return abi.decode(_returnBytes, (uint256, address));
    }

    function _getEncodedSwapHandlerCalldata(
        SwapPayload memory payload,
        address expectedOutputToken,
        bool isDelegateCall
    ) internal pure virtual returns (bytes memory);

    function _getValidatedPayloadAmount(SwapPayload memory payload) private view returns (uint256 amount) {
        uint256 balance = DefinitiveAssets.getBalance(payload.swapToken);

        // Ensure balance > 0
        DefinitiveAssets.validateAmount(balance);

        amount = payload.amount;

        if (amount != 0 && balance < amount) {
            revert InsufficientSwapTokenBalance();
        }

        // maximum available balance if amount == 0
        if (amount == 0) {
            return balance;
        }
    }

    function _prepareAssetsForNonDelegateHandlerCall(
        SwapPayload memory payload,
        uint256 amount
    ) private returns (uint256 msgValue) {
        if (payload.swapToken == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            return amount;
        } else {
            IERC20(payload.swapToken).resetAndSafeIncreaseAllowance(payload.handler, amount);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

struct SwapPayload {
    address handler;
    uint256 amount; // set 0 for maximum available balance
    address swapToken;
    uint256 amountOutMin;
    bool isDelegate;
    bytes handlerCalldata;
    bytes signature;
}

interface ICoreSimpleSwapV1 {
    event SwapHandlerUpdate(address actor, address swapHandler, bool isEnabled);
    event SwapHandled(
        address[] swapTokens,
        uint256[] swapAmounts,
        address outputToken,
        uint256 outputAmount,
        uint256 feeAmount
    );

    function swap(
        SwapPayload[] memory payloads,
        address outputToken,
        uint256 amountOutMin,
        uint256 feePct
    ) external payable returns (uint256 outputAmount);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreStopGuardianV1 } from "./ICoreStopGuardianV1.sol";

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { StopGuardianEnabled } from "../../libraries/DefinitiveErrors.sol";

abstract contract CoreStopGuardian is ICoreStopGuardianV1, Context {
    /// @custom:storage-location erc7201:definitive.storage.CoreStopGuardian
    struct CoreStopGuardianStorage {
        bool stopGuardianEnabled;
    }

    // keccak256(abi.encode(uint256(keccak256("definitive.storage.CoreStopGuardian")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CoreStopGuardianStorageLocation =
        0x6e256963d8788aaa49f4ac4e7631ab95aeec255e6d6477beec524cf8dfccec00;

    function _getCoreStopGuardianStorage() private pure returns (CoreStopGuardianStorage storage $) {
        assembly {
            $.slot := CoreStopGuardianStorageLocation
        }
    }

    // recommended for every public/external function
    modifier stopGuarded() {
        if (STOP_GUARDIAN_ENABLED()) {
            revert StopGuardianEnabled();
        }

        _;
    }

    function STOP_GUARDIAN_ENABLED() public view override returns (bool) {
        CoreStopGuardianStorage storage $ = _getCoreStopGuardianStorage();
        return $.stopGuardianEnabled;
    }

    function enableStopGuardian() public virtual;

    function disableStopGuardian() public virtual;

    function _enableStopGuardian() internal {
        CoreStopGuardianStorage storage $ = _getCoreStopGuardianStorage();

        $.stopGuardianEnabled = true;
        emit StopGuardianUpdate(_msgSender(), true);
    }

    function _disableStopGuardian() internal {
        CoreStopGuardianStorage storage $ = _getCoreStopGuardianStorage();

        $.stopGuardianEnabled = false;
        emit StopGuardianUpdate(_msgSender(), false);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreStopGuardianV1 {
    event StopGuardianUpdate(address indexed actor, bool indexed isEnabled);

    function STOP_GUARDIAN_ENABLED() external view returns (bool);

    function enableStopGuardian() external;

    function disableStopGuardian() external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreStopGuardianTradingV1 } from "./ICoreStopGuardianTradingV1.sol";

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { WithdrawalsDisabled, TradingDisabled, GlobalStopGuardianEnabled } from "../../libraries/DefinitiveErrors.sol";
import { IGlobalGuardian } from "../../../tools/GlobalGuardian/IGlobalGuardian.sol";
import { CoreGlobalGuardian } from "../../CoreGlobalGuardian/CoreGlobalGuardian.sol";

abstract contract CoreStopGuardianTrading is ICoreStopGuardianTradingV1, Context, CoreGlobalGuardian {
    /// @custom:storage-location erc7201:definitive.storage.CoreStopGuardianTrading
    struct CoreStopGuardianTradingStorage {
        bool TRADING_GUARDIAN_TRADING_DISABLED;
        bool TRADING_GUARDIAN_WITHDRAWALS_DISABLED;
    }

    /* solhint-disable max-line-length */
    // keccak256(abi.encode(uint256(keccak256("definitive.storage.CoreStopGuardianTrading")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CoreStopGuardianTradingStorageLocation =
        0x16cbd83eaf0105ad9cb99491311ec69c270710363d0a5092df3b41a81f4a9400;

    /* solhint-enable max-line-length */

    function _getCoreStopGuardianTradingStorage() private pure returns (CoreStopGuardianTradingStorage storage $) {
        assembly {
            $.slot := CoreStopGuardianTradingStorageLocation
        }
    }

    /// 0x49feb0371fc9661748a3d1bc01dbf9f5cdeb4102767351e1c6dd1f5d331acd6d
    bytes32 internal constant GLOBAL_TRADING_HASH = keccak256("TRADING");

    modifier tradingEnabled() {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        if (IGlobalGuardian(GLOBAL_TRADE_GUARDIAN()).functionalityIsDisabled(GLOBAL_TRADING_HASH)) {
            revert GlobalStopGuardianEnabled();
        }

        if ($.TRADING_GUARDIAN_TRADING_DISABLED) {
            revert TradingDisabled();
        }
        _;
    }

    modifier withdrawalsEnabled() {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        if ($.TRADING_GUARDIAN_WITHDRAWALS_DISABLED) {
            revert WithdrawalsDisabled();
        }
        _;
    }

    function TRADING_GUARDIAN_TRADING_DISABLED() public view returns (bool) {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();
        return $.TRADING_GUARDIAN_TRADING_DISABLED;
    }

    function disableTrading() public virtual;

    function enableTrading() public virtual;

    function disableWithdrawals() public virtual;

    function enableWithdrawals() public virtual;

    function _disableTrading() internal {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        $.TRADING_GUARDIAN_TRADING_DISABLED = true;
        emit TradingDisabledUpdate(_msgSender(), true);
    }

    function _enableTrading() internal {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        delete $.TRADING_GUARDIAN_TRADING_DISABLED;
        emit TradingDisabledUpdate(_msgSender(), false);
    }

    function _disableWithdrawals() internal {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        $.TRADING_GUARDIAN_WITHDRAWALS_DISABLED = true;
        emit WithdrawalsDisabledUpdate(_msgSender(), true);
    }

    function _enableWithdrawals() internal {
        CoreStopGuardianTradingStorage storage $ = _getCoreStopGuardianTradingStorage();

        delete $.TRADING_GUARDIAN_WITHDRAWALS_DISABLED;
        emit WithdrawalsDisabledUpdate(_msgSender(), false);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreStopGuardianTradingV1 {
    event TradingDisabledUpdate(address indexed actor, bool indexed isEnabled);
    event WithdrawalsDisabledUpdate(address indexed actor, bool indexed isEnabled);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreSwapHandlerV1 {
    event Swap(
        address indexed actor,
        address indexed inputToken,
        uint256 inputAmount,
        address indexed outputToken,
        uint256 outputAmount
    );

    struct SwapParams {
        address inputAssetAddress;
        uint256 inputAmount;
        address outputAssetAddress;
        uint256 minOutputAmount;
        bytes data;
        bytes signature;
    }

    function swapCall(SwapParams calldata params) external payable returns (uint256 amountOut, address outputAsset);

    function swapDelegate(SwapParams calldata params) external payable returns (uint256 amountOut, address outputAsset);

    function swapUsingValidatedPathCall(
        SwapParams calldata params
    ) external payable returns (uint256 amountOut, address outputAsset);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ICoreTransfersNativeV1 } from "./ICoreTransfersNativeV1.sol";

import { DefinitiveAssets, IERC20 } from "../../libraries/DefinitiveAssets.sol";
import { DefinitiveConstants } from "../../libraries/DefinitiveConstants.sol";
import { InvalidInputs, InvalidMsgValue, InvalidAddress } from "../../libraries/DefinitiveErrors.sol";

abstract contract CoreTransfersNative is ICoreTransfersNativeV1, Context {
    using DefinitiveAssets for IERC20;

    /**
     * @notice Allows contract to receive native assets
     */
    receive() external payable virtual {
        emit NativeTransfer(_msgSender(), msg.value);
    }

    function _depositNativeAndERC20(uint256[] calldata amounts, address[] calldata assetAddresses) internal virtual {
        uint256 assetAddressesLength = assetAddresses.length;
        if (amounts.length != assetAddressesLength) {
            revert InvalidInputs();
        }

        bool hasNativeAsset;
        uint256 nativeAssetIndex;

        for (uint256 i; i < assetAddressesLength; ) {
            if (assetAddresses[i] == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
                if (hasNativeAsset) {
                    revert InvalidAddress(); /// Do not let users specify native_asset twice
                }

                nativeAssetIndex = i;
                hasNativeAsset = true;
                unchecked {
                    ++i;
                }
                continue;
            }
            // ERC20 tokens
            IERC20(assetAddresses[i]).safeTransferFrom(_msgSender(), address(this), amounts[i]);
            unchecked {
                ++i;
            }
        }
        // Revert if NATIVE_ASSET_ADDRESS is not in assetAddresses and msg.value is not zero
        if (!hasNativeAsset && msg.value != 0) {
            revert InvalidMsgValue();
        }

        // Revert if depositing native asset and amount != msg.value
        if (hasNativeAsset && msg.value != amounts[nativeAssetIndex]) {
            revert InvalidMsgValue();
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreTransfersNativeV1 {
    /**
     * @dev Emitted when `value` native asset is received by the contract
     */
    event NativeTransfer(address indexed from, uint256 value);

    receive() external payable;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { ICoreWithdrawV1 } from "./ICoreWithdrawV1.sol";
import { DefinitiveAssets, IERC20 } from "../../libraries/DefinitiveAssets.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { DefinitiveConstants } from "../../libraries/DefinitiveConstants.sol";

abstract contract CoreWithdraw is ICoreWithdrawV1, Context {
    using DefinitiveAssets for IERC20;

    function supportsNativeAssets() public pure virtual returns (bool);

    function withdraw(uint256 amount, address erc20Token) public virtual returns (bool);

    function withdrawTo(uint256 amount, address erc20Token, address to) public virtual returns (bool);

    function _withdraw(uint256 amount, address erc20Token) internal returns (bool) {
        return _withdrawTo(amount, erc20Token, _msgSender());
    }

    function _withdrawTo(uint256 amount, address erc20Token, address to) internal returns (bool success) {
        if (erc20Token == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            DefinitiveAssets.safeTransferETH(payable(to), amount);
        } else {
            IERC20(erc20Token).safeTransfer(to, amount);
        }

        emit Withdrawal(erc20Token, amount, to);

        success = true;
    }

    function withdrawAll(address[] calldata tokens) public virtual returns (bool);

    function withdrawAllTo(address[] calldata tokens, address to) public virtual returns (bool);

    function _withdrawAll(address[] calldata tokens) internal returns (bool) {
        return _withdrawAllTo(tokens, _msgSender());
    }

    function _withdrawAllTo(address[] calldata tokens, address to) internal returns (bool success) {
        uint256 tokenLength = tokens.length;
        for (uint256 i; i < tokenLength; ) {
            uint256 tokenBalance = DefinitiveAssets.getBalance(tokens[i]);
            if (tokenBalance > 0) {
                _withdrawTo(tokenBalance, tokens[i], to);
            }
            unchecked {
                ++i;
            }
        }
        return true;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface ICoreWithdrawV1 {
    event Withdrawal(address indexed erc20Token, uint256 amount, address indexed recipient);

    function withdrawAll(address[] calldata tokens) external returns (bool);

    function withdrawAllTo(address[] calldata tokens, address to) external returns (bool);

    function supportsNativeAssets() external pure returns (bool);

    function withdraw(uint256 amount, address erc20Token) external returns (bool);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeTransferLib } from "solmate/src/utils/SafeTransferLib.sol";
import { DefinitiveConstants } from "./DefinitiveConstants.sol";

import { InsufficientBalance, InvalidAmount, InvalidAmounts, InvalidERC20Address } from "./DefinitiveErrors.sol";

/**
 * @notice Contains methods used throughout the Definitive contracts
 * @dev This file should only be used as an internal library.
 */
library DefinitiveAssets {
    /**
     * @dev Checks if an address is a valid ERC20 token
     */
    modifier onlyValidERC20(address erc20Token) {
        if (address(erc20Token) == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            revert InvalidERC20Address();
        }
        _;
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // ↓ ERC20 and Native Asset Methods ↓
    //////////////////////////////////////////////////

    /**
     * @dev Gets the balance of an ERC20 token or native asset
     */
    function getBalance(address assetAddress) internal view returns (uint256) {
        if (assetAddress == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            return address(this).balance;
        } else if (assetAddress == address(0xdefdead)) {
            return 0; // For cases we need to set an arbitrary input asset
        } else {
            return IERC20(assetAddress).balanceOf(address(this));
        }
    }

    /**
     * @dev internal function to validate balance is higher than a given amount for ERC20 and native assets
     */
    function validateBalance(address token, uint256 amount) internal view {
        if (token == DefinitiveConstants.NATIVE_ASSET_ADDRESS) {
            validateNativeBalance(amount);
        } else {
            validateERC20Balance(token, amount);
        }
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // ↓ Native Asset Methods ↓
    //////////////////////////////////////////////////

    /**
     * @dev validates amount and balance, then uses SafeTransferLib to transfer native asset
     */
    function safeTransferETH(address recipient, uint256 amount) internal {
        if (amount > 0) {
            SafeTransferLib.safeTransferETH(payable(recipient), amount);
        }
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // ↓ ERC20 Methods ↓
    //////////////////////////////////////////////////

    /**
     * @dev Resets and increases the allowance of a spender for an ERC20 token
     */
    function resetAndSafeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal onlyValidERC20(address(token)) {
        return SafeERC20.forceApprove(token, spender, amount);
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal onlyValidERC20(address(token)) {
        if (amount > 0) {
            SafeERC20.safeTransfer(token, to, amount);
        }
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal onlyValidERC20(address(token)) {
        if (amount > 0) {
            //slither-disable-next-line arbitrary-send-erc20
            SafeERC20.safeTransferFrom(token, from, to, amount);
        }
    }

    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    // ↓ Asset Amount Helper Methods ↓
    //////////////////////////////////////////////////

    /**
     * @dev internal function to validate that amounts contains a value greater than zero
     */
    function validateAmounts(uint256[] calldata amounts) internal pure {
        bool hasValidAmounts;
        uint256 amountsLength = amounts.length;
        for (uint256 i; i < amountsLength; ) {
            if (amounts[i] > 0) {
                hasValidAmounts = true;
                break;
            }
            unchecked {
                ++i;
            }
        }

        if (!hasValidAmounts) {
            revert InvalidAmounts();
        }
    }

    /**
     * @dev internal function to validate if native asset balance is higher than the amount requested
     */
    function validateNativeBalance(uint256 amount) internal view {
        if (getBalance(DefinitiveConstants.NATIVE_ASSET_ADDRESS) < amount) {
            revert InsufficientBalance();
        }
    }

    /**
     * @dev internal function to validate balance is higher than the amount requested for a token
     */
    function validateERC20Balance(address token, uint256 amount) internal view onlyValidERC20(token) {
        if (getBalance(token) < amount) {
            revert InsufficientBalance();
        }
    }

    function validateAmount(uint256 _amount) internal pure {
        if (_amount == 0) {
            revert InvalidAmount();
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

/**
 * @notice Contains constants used throughout the Definitive contracts
 * @dev This file should only be used as an internal library.
 */
library DefinitiveConstants {
    /**
     * @notice Maximum fee percentage
     */
    uint256 internal constant MAX_FEE_PCT = 10000;

    /**
     * @notice Address to signify native assets
     */
    address internal constant NATIVE_ASSET_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @notice Maximum number of swaps allowed per block
     */
    uint8 internal constant MAX_SWAPS_PER_BLOCK = 25;

    struct Assets {
        uint256[] amounts;
        address[] addresses;
    }

    address internal constant DEFAULT_GLOBAL_TRADE_GUARDIAN = 0xE3F35754954B0B77958C72b83EC5205971463064;

    address internal constant STAGING_GLOBAL_TRADE_GUARDIAN = 0xE217abF1077eC4772E4E78Ca0802046A974cba90;

    address internal constant LOCAL_GLOBAL_TRADE_GUARDIAN = 0x92d4Ba061336C223f774A23f9a385B7eAdFA64A6;

    address internal constant GENERIC_UUPS_PROXY_IMPLEMENTATION = 0x4aEb164998DB4eB8ab945620d4d1db59E2Ad5513;

    address internal constant SEND_FEE_TO_SENDER_ALIAS = address(0xFEE);

    address internal constant BLAST_NATIVE_YIELD_CONTRACT = 0x4300000000000000000000000000000000000002;

    address internal constant BLAST_POINTS_ADDRESS = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;

    address internal constant BLAST_DEFINITIVE_OPERATOR_PROD = 0xaba36De8208002e05a757377A76D50093233Eb51;

    address internal constant BLAST_DEFINITIVE_OPERATOR_STAGING = 0xaf212671793921BCb84F04cEeEd1dec1EF742DAC;

    address internal constant ENTRYPOINT_0_7 = 0x0000000071727De22E5E9d8BAf0edAc6f37da032;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

/**
 * @notice Contains all errors used throughout the Definitive contracts
 * @dev This file should only be used as an internal library.
 * @dev When adding a new error, add alphabetically
 */

error AccountMissingRole(address _account, bytes32 _role);
error AccountNotAdmin(address);
error AccountNotWhitelisted(address);
error AddLiquidityFailed();
error AlreadyDeployed();
error AlreadyInitialized();
error BytecodeEmpty();
error DeadlineExceeded();
error DeployInitFailed();
error DeployFailed();
error BorrowFailed(uint256 errorCode);
error DecollateralizeFailed(uint256 errorCode);
error DepositMoreThanMax();
error EmptyBytecode();
error EnterAllFailed();
error EnforcedSafeLTV(uint256 invalidLTV);
error ExceededMaxDelta();
error ExceededMaxLTV();
error ExceededShareToAssetRatioDeltaThreshold();
error ExitAllFailed();
error ExitOneCoinFailed();
error GlobalStopGuardianEnabled();
error InitializeMarketsFailed();
error InputGreaterThanStaked();
error InsufficientBalance();
error InsufficientSwapTokenBalance();
error InvalidAddress();
error InvalidChain();
error InvalidAmount();
error InvalidAmounts();
error InvalidCalldata();
error InvalidDestinationSwapper();
error InvalidERC20Address();
error InvalidExecutedOutputAmount();
error InvalidFeePercent();
error InvalidHandler();
error InvalidInputs();
error InvalidMsgValue();
error InvalidSession();
error InvalidSingleHopSwap();
error InvalidMethod(bytes4 methodSig);
error InvalidMultiHopSwap();
error InvalidOutputToken();
error InvalidRedemptionRecipient(); // Used in cross-chain redeptions
error InvalidReportedOutputAmount();
error InvalidRewardsClaim();
error InvalidSignature();
error InvalidSignatureLength();
error InvalidSwapHandler();
error InvalidSwapInputAmount();
error InvalidSwapOutputToken();
error InvalidSwapPath();
error InvalidSwapPayload();
error InvalidSwapToken();
error MintMoreThanMax();
error MismatchedChainId();
error NativeAssetWrapFailed(bool wrappingToNative);
error NoSignatureVerificationSignerSet();
error RedeemMoreThanMax();
error RemoveLiquidityFailed();
error RepayDebtFailed();
error SafeHarborModeEnabled();
error SafeHarborRedemptionDisabled();
error SessionExpired();
error SlippageExceeded(uint256 _outputAmount, uint256 _outputAmountMin);
error StakeFailed();
error SupplyFailed();
error StopGuardianEnabled();
error TradingDisabled();
error SwapDeadlineExceeded();
error SwapLimitExceeded();
error SwapTokenIsOutputToken();
error TransfersLimitExceeded();
error UnstakeFailed();
error UnauthenticatedFlashloan();
error UntrustedFlashLoanSender(address);
error WithdrawMoreThanMax();
error WithdrawalsDisabled();
error ZeroShares();
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import {
    BaseNativeWrapperInitiable,
    BaseNativeWrapperConfig
} from "../../base/BaseNativeWrapper/v1/BaseNativeWrapperInitiable.sol";
import { IWETH9 } from "../../vendor/interfaces/IWETH9.sol";

abstract contract WETH9NativeWrapperInitiable is BaseNativeWrapperInitiable {
    function __WETH9NativeWrapperInitiable__init(BaseNativeWrapperConfig calldata config) internal onlyInitializing {
        __BaseNativeWrapperInitiable__init(config);
    }

    function _wrap(uint256 amount) internal override {
        // slither-disable-next-line arbitrary-send-eth
        IWETH9(WRAPPED_NATIVE_ASSET_ADDRESS()).deposit{ value: amount }();
    }

    function _unwrap(uint256 amount) internal override {
        IWETH9(WRAPPED_NATIVE_ASSET_ADDRESS()).withdraw(amount);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { CoreAccessControlConfig } from "../../../base/BaseAccessControlInitiable.sol";
import { BaseNativeWrapperConfig } from "../../../modules/native-asset-wrappers/WETH9NativeWrapperInitiable.sol";

interface ITradingVaultImplementation {
    function initialize(
        BaseNativeWrapperConfig calldata baseNativeWrapperConfig,
        CoreAccessControlConfig calldata coreAccessControlConfig,
        address _globalTradeGuardianOverride
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { BaseTransfersNativeInitiable } from "../../../base/BaseTransfersNative/v1/BaseTransfersNativeInitiable.sol";
import { BaseSimpleSwapInitiable } from "../../../base/BaseSimpleSwapInitiable.sol";
import { CoreAccessControlConfig } from "../../../base/BaseAccessControlInitiable.sol";
import { BaseRecoverSignerInitiable } from "../../../base/BaseRecoverSignerInitiable.sol";
import { CoreMulticall } from "../../../core/CoreMulticall/v1/CoreMulticall.sol";
import {
    WETH9NativeWrapperInitiable,
    BaseNativeWrapperConfig
} from "../../../modules/native-asset-wrappers/WETH9NativeWrapperInitiable.sol";
import { ITradingVaultImplementation } from "./ITradingVaultImplementation.sol";

contract TradingVaultImplementation is
    ITradingVaultImplementation,
    WETH9NativeWrapperInitiable,
    BaseTransfersNativeInitiable,
    BaseSimpleSwapInitiable,
    CoreMulticall,
    BaseRecoverSignerInitiable
{
    /// @notice Constructor on the implementation contract should call _disableInitializers()
    /// @dev https://forum.openzeppelin.com/t/what-does-disableinitializers-function-mean/28730
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        BaseNativeWrapperConfig calldata baseNativeWrapperConfig,
        CoreAccessControlConfig calldata coreAccessControlConfig,
        address _globalTradeGuardianOverride
    ) external override initializer {
        __WETH9NativeWrapperInitiable__init(baseNativeWrapperConfig);
        __BaseAccessControlInitiable__init(coreAccessControlConfig);

        if (_globalTradeGuardianOverride != address(0)) {
            _updateGlobalTradeGuardian(_globalTradeGuardianOverride);
        }
    }
}
// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.8.20;

import { InvalidCalldata } from "../../core/libraries/DefinitiveErrors.sol";

/**
 * @title Call utilities library that is absent from the OpenZeppelin
 * @author Superfluid
 * Forked from
 * https://github.com/superfluid-finance/protocol-monorepo/blob
 * /d473b4876a689efb3bbb05552040bafde364a8b2/packages/ethereum-contracts/contracts/libs/CallUtils.sol
 * (Separated by 2 lines to prevent going over 120 character per line limit)
 */
library CallUtils {
    /// @dev Bubble up the revert from the returnedData (supports Panic, Error & Custom Errors)
    /// @notice This is needed in order to provide some human-readable revert message from a call
    /// @param returnedData Response of the call
    function revertFromReturnedData(bytes memory returnedData) internal pure {
        if (returnedData.length < 4) {
            // case 1: catch all
            revert("CallUtils: target revert()"); // solhint-disable-line custom-errors
        } else {
            bytes4 errorSelector;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                errorSelector := mload(add(returnedData, 0x20))
            }
            if (errorSelector == bytes4(0x4e487b71) /* `seth sig "Panic(uint256)"` */) {
                // case 2: Panic(uint256) (Defined since 0.8.0)
                // solhint-disable-next-line max-line-length
                // ref: https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require)
                string memory reason = "CallUtils: target panicked: 0x__";
                uint256 errorCode;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    errorCode := mload(add(returnedData, 0x24))
                    let reasonWord := mload(add(reason, 0x20))
                    // [0..9] is converted to ['0'..'9']
                    // [0xa..0xf] is not correctly converted to ['a'..'f']
                    // but since panic code doesn't have those cases, we will ignore them for now!
                    let e1 := add(and(errorCode, 0xf), 0x30)
                    let e2 := shl(8, add(shr(4, and(errorCode, 0xf0)), 0x30))
                    reasonWord := or(
                        and(reasonWord, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000),
                        or(e2, e1)
                    )
                    mstore(add(reason, 0x20), reasonWord)
                }
                revert(reason);
            } else {
                // case 3: Error(string) (Defined at least since 0.7.0)
                // case 4: Custom errors (Defined since 0.8.0)
                uint256 len = returnedData.length;
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    revert(add(returnedData, 32), len)
                }
            }
        }
    }

    /**
     * @dev Helper method to parse data and extract the method signature (selector).
     *
     * Copied from: https://github.com/argentlabs/argent-contracts/
     * blob/master/contracts/modules/common/Utils.sol#L54-L60
     */
    function parseSelector(bytes memory callData) internal pure returns (bytes4 selector) {
        if (callData.length < 4) {
            revert InvalidCalldata();
        }
        // solhint-disable-next-line no-inline-assembly
        assembly {
            selector := mload(add(callData, 0x20))
        }
    }

    /**
     * @dev Pad length to 32 bytes word boundary
     */
    function padLength32(uint256 len) internal pure returns (uint256 paddedLen) {
        return ((len / 32) + (((len & 31) > 0) /* rounding? */ ? 1 : 0)) * 32;
    }

    /**
     * @dev Validate if the data is encoded correctly with abi.encode(bytesData)
     *
     * Expected ABI Encode Layout:
     * | word 1      | word 2           | word 3           | the rest...
     * | data length | bytesData offset | bytesData length | bytesData + padLength32 zeros |
     */
    function isValidAbiEncodedBytes(bytes memory data) internal pure returns (bool) {
        if (data.length < 64) return false;
        uint256 bytesOffset;
        uint256 bytesLen;
        // bytes offset is always expected to be 32
        // solhint-disable-next-line no-inline-assembly
        assembly {
            bytesOffset := mload(add(data, 32))
        }
        if (bytesOffset != 32) return false;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            bytesLen := mload(add(data, 64))
        }
        // the data length should be bytesData.length + 64 + padded bytes length
        return data.length == 64 + padLength32(bytesLen);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

interface IGlobalGuardian {
    function disable(bytes32 keyHash) external;

    function enable(bytes32 keyHash) external;

    function functionalityIsDisabled(bytes32 keyHash) external view returns (bool);

    function accountIsPerformer(address _account) external view returns (bool);

    function accountIsSwapHandler(address _account) external view returns (bool);

    function isDefinitiveAdmin() external view returns (bool);

    function isHandlerManager() external view returns (bool);

    function feeAccount() external view returns (address payable);

    function accountIsDefinitiveAdmin(address _account) external view returns (bool);

    function accountIsHandlerManager(address _account) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/* solhint-disable no-inline-assembly */

/// @notice Signature verification helper that supports both ECDSA signatures from EOAs
/// and ERC1271 signatures from smart contract wallets like Argent and Gnosis safe.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SignatureCheckerLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol)
///
/// @dev Note:
/// - The signature checking functions use the ecrecover precompile (0x1).
/// - The `bytes memory signature` variants use the identity precompile (0x4)
///   to copy memory internally.
/// - Unlike ECDSA signatures, contract signatures are revocable.
/// - As of Solady version 0.0.134, all `bytes signature` variants accept both
///   regular 65-byte `(r, s, v)` and EIP-2098 `(r, vs)` short form signatures.
///   See: https://eips.ethereum.org/EIPS/eip-2098
///   This is for calldata efficiency on smart accounts prevalent on L2s.
///
/// WARNING! Do NOT use signatures as unique identifiers:
/// - Use a nonce in the digest to prevent replay attacks on the same contract.
/// - Use EIP-712 for the digest to prevent replay attacks across different chains and contracts.
///   EIP-712 also enables readable signing of typed data for better user safety.
/// This implementation does NOT check if a signature is non-malleable.
library SignatureCheckerLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*               SIGNATURE CHECKING OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer` is a smart contract, the signature is validated with ERC1271.
    /// Otherwise, the signature is validated with `ECDSA.recover`.
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits of `signer` in case they are dirty.
            for {
                signer := shr(96, shl(96, signer))
            } signer {

            } {
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x40, mload(add(signature, 0x20))) // `r`.
                if eq(mload(signature), 64) {
                    let vs := mload(add(signature, 0x40))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    let t := staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                    // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                    if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                        isValid := 1
                        mstore(0x60, 0) // Restore the zero slot.
                        mstore(0x40, m) // Restore the free memory pointer.
                        break
                    }
                }
                if eq(mload(signature), 65) {
                    mstore(0x20, byte(0, mload(add(signature, 0x60)))) // `v`.
                    mstore(0x60, mload(add(signature, 0x40))) // `s`.
                    let t := staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                    // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                    if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                        isValid := 1
                        mstore(0x60, 0) // Restore the zero slot.
                        mstore(0x40, m) // Restore the free memory pointer.
                        break
                    }
                }
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.

                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                // Copy the `signature` over.
                let n := add(0x20, mload(signature))
                pop(staticcall(gas(), 4, signature, n, add(m, 0x44), n))
                // forgefmt: disable-next-item
                isValid := and(
                    // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                    eq(mload(d), f),
                    // Whether the staticcall does not revert.
                    // This must be placed at the end of the `and` clause,
                    // as the arguments are evaluated from right to left.
                    staticcall(
                        gas(), // Remaining gas.
                        signer, // The `signer` address.
                        m, // Offset of calldata in memory.
                        add(returndatasize(), 0x44), // Length of calldata in memory.
                        d, // Offset of returndata.
                        0x20 // Length of returndata to write.
                    )
                )
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `signer` and `hash`.
    /// If `signer` is a smart contract, the signature is validated with ERC1271.
    /// Otherwise, the signature is validated with `ECDSA.recover`.
    function isValidSignatureNowCalldata(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits of `signer` in case they are dirty.
            for {
                signer := shr(96, shl(96, signer))
            } signer {

            } {
                let m := mload(0x40)
                mstore(0x00, hash)
                if eq(signature.length, 64) {
                    let vs := calldataload(add(signature.offset, 0x20))
                    mstore(0x20, add(shr(255, vs), 27)) // `v`.
                    mstore(0x40, calldataload(signature.offset)) // `r`.
                    mstore(0x60, shr(1, shl(1, vs))) // `s`.
                    let t := staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                    // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                    if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                        isValid := 1
                        mstore(0x60, 0) // Restore the zero slot.
                        mstore(0x40, m) // Restore the free memory pointer.
                        break
                    }
                }
                if eq(signature.length, 65) {
                    mstore(0x20, byte(0, calldataload(add(signature.offset, 0x40)))) // `v`.
                    calldatacopy(0x40, signature.offset, 0x40) // `r`, `s`.
                    let t := staticcall(
                        gas(), // Amount of gas left for the transaction.
                        1, // Address of `ecrecover`.
                        0x00, // Start of input.
                        0x80, // Size of input.
                        0x01, // Start of output.
                        0x20 // Size of output.
                    )
                    // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                    if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                        isValid := 1
                        mstore(0x60, 0) // Restore the zero slot.
                        mstore(0x40, m) // Restore the free memory pointer.
                        break
                    }
                }
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.

                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), signature.length)
                // Copy the `signature` over.
                calldatacopy(add(m, 0x64), signature.offset, signature.length)
                // forgefmt: disable-next-item
                isValid := and(
                    // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                    eq(mload(d), f),
                    // Whether the staticcall does not revert.
                    // This must be placed at the end of the `and` clause,
                    // as the arguments are evaluated from right to left.
                    staticcall(
                        gas(), // Remaining gas.
                        signer, // The `signer` address.
                        m, // Offset of calldata in memory.
                        add(signature.length, 0x64), // Length of calldata in memory.
                        d, // Offset of returndata.
                        0x20 // Length of returndata to write.
                    )
                )
                break
            }
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `signer` and `hash`.
    /// If `signer` is a smart contract, the signature is validated with ERC1271.
    /// Otherwise, the signature is validated with `ECDSA.recover`.
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits of `signer` in case they are dirty.
            for {
                signer := shr(96, shl(96, signer))
            } signer {

            } {
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x20, add(shr(255, vs), 27)) // `v`.
                mstore(0x40, r) // `r`.
                mstore(0x60, shr(1, shl(1, vs))) // `s`.
                let t := staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x01, // Start of output.
                    0x20 // Size of output.
                )
                // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                    isValid := 1
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }

                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), mload(0x60)) // `s`.
                mstore8(add(m, 0xa4), mload(0x20)) // `v`.
                // forgefmt: disable-next-item
                isValid := and(
                    // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                    eq(mload(d), f),
                    // Whether the staticcall does not revert.
                    // This must be placed at the end of the `and` clause,
                    // as the arguments are evaluated from right to left.
                    staticcall(
                        gas(), // Remaining gas.
                        signer, // The `signer` address.
                        m, // Offset of calldata in memory.
                        0xa5, // Length of calldata in memory.
                        d, // Offset of returndata.
                        0x20 // Length of returndata to write.
                    )
                )
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `signer` and `hash`.
    /// If `signer` is a smart contract, the signature is validated with ERC1271.
    /// Otherwise, the signature is validated with `ECDSA.recover`.
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits of `signer` in case they are dirty.
            for {
                signer := shr(96, shl(96, signer))
            } signer {

            } {
                let m := mload(0x40)
                mstore(0x00, hash)
                mstore(0x20, and(v, 0xff)) // `v`.
                mstore(0x40, r) // `r`.
                mstore(0x60, s) // `s`.
                let t := staticcall(
                    gas(), // Amount of gas left for the transaction.
                    1, // Address of `ecrecover`.
                    0x00, // Start of input.
                    0x80, // Size of input.
                    0x01, // Start of output.
                    0x20 // Size of output.
                )
                // `returndatasize()` will be `0x20` upon success, and `0x00` otherwise.
                if iszero(or(iszero(returndatasize()), xor(signer, mload(t)))) {
                    isValid := 1
                    mstore(0x60, 0) // Restore the zero slot.
                    mstore(0x40, m) // Restore the free memory pointer.
                    break
                }

                let f := shl(224, 0x1626ba7e)
                mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m, 0x04), hash)
                let d := add(m, 0x24)
                mstore(d, 0x40) // The offset of the `signature` in the calldata.
                mstore(add(m, 0x44), 65) // Length of the signature.
                mstore(add(m, 0x64), r) // `r`.
                mstore(add(m, 0x84), s) // `s`.
                mstore8(add(m, 0xa4), v) // `v`.
                // forgefmt: disable-next-item
                isValid := and(
                    // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                    eq(mload(d), f),
                    // Whether the staticcall does not revert.
                    // This must be placed at the end of the `and` clause,
                    // as the arguments are evaluated from right to left.
                    staticcall(
                        gas(), // Remaining gas.
                        signer, // The `signer` address.
                        m, // Offset of calldata in memory.
                        0xa5, // Length of calldata in memory.
                        d, // Offset of returndata.
                        0x20 // Length of returndata to write.
                    )
                )
                mstore(0x60, 0) // Restore the zero slot.
                mstore(0x40, m) // Restore the free memory pointer.
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC1271 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC1271 operations do NOT have an ECDSA fallback.
    // These functions are intended to be used with the regular `isValidSignatureNow` functions
    // or other signature verification functions (e.g. P256).

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            // Copy the `signature` over.
            let n := add(0x20, mload(signature))
            pop(staticcall(gas(), 4, signature, n, add(m, 0x44), n))
            // forgefmt: disable-next-item
            isValid := and(
                // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                eq(mload(d), f),
                // Whether the staticcall does not revert.
                // This must be placed at the end of the `and` clause,
                // as the arguments are evaluated from right to left.
                staticcall(
                    gas(), // Remaining gas.
                    signer, // The `signer` address.
                    m, // Offset of calldata in memory.
                    add(returndatasize(), 0x44), // Length of calldata in memory.
                    d, // Offset of returndata.
                    0x20 // Length of returndata to write.
                )
            )
        }
    }

    /// @dev Returns whether `signature` is valid for `hash` for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNowCalldata(
        address signer,
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), signature.length)
            // Copy the `signature` over.
            calldatacopy(add(m, 0x64), signature.offset, signature.length)
            // forgefmt: disable-next-item
            isValid := and(
                // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                eq(mload(d), f),
                // Whether the staticcall does not revert.
                // This must be placed at the end of the `and` clause,
                // as the arguments are evaluated from right to left.
                staticcall(
                    gas(), // Remaining gas.
                    signer, // The `signer` address.
                    m, // Offset of calldata in memory.
                    add(signature.length, 0x64), // Length of calldata in memory.
                    d, // Offset of returndata.
                    0x20 // Length of returndata to write.
                )
            )
        }
    }

    /// @dev Returns whether the signature (`r`, `vs`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), shr(1, shl(1, vs))) // `s`.
            mstore8(add(m, 0xa4), add(shr(255, vs), 27)) // `v`.
            // forgefmt: disable-next-item
            isValid := and(
                // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                eq(mload(d), f),
                // Whether the staticcall does not revert.
                // This must be placed at the end of the `and` clause,
                // as the arguments are evaluated from right to left.
                staticcall(
                    gas(), // Remaining gas.
                    signer, // The `signer` address.
                    m, // Offset of calldata in memory.
                    0xa5, // Length of calldata in memory.
                    d, // Offset of returndata.
                    0x20 // Length of returndata to write.
                )
            )
        }
    }

    /// @dev Returns whether the signature (`v`, `r`, `s`) is valid for `hash`
    /// for an ERC1271 `signer` contract.
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            let f := shl(224, 0x1626ba7e)
            mstore(m, f) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
            mstore(add(m, 0x04), hash)
            let d := add(m, 0x24)
            mstore(d, 0x40) // The offset of the `signature` in the calldata.
            mstore(add(m, 0x44), 65) // Length of the signature.
            mstore(add(m, 0x64), r) // `r`.
            mstore(add(m, 0x84), s) // `s`.
            mstore8(add(m, 0xa4), v) // `v`.
            // forgefmt: disable-next-item
            isValid := and(
                // Whether the returndata is the magic value `0x1626ba7e` (left-aligned).
                eq(mload(d), f),
                // Whether the staticcall does not revert.
                // This must be placed at the end of the `and` clause,
                // as the arguments are evaluated from right to left.
                staticcall(
                    gas(), // Remaining gas.
                    signer, // The `signer` address.
                    m, // Offset of calldata in memory.
                    0xa5, // Length of calldata in memory.
                    d, // Offset of returndata.
                    0x20 // Length of returndata to write.
                )
            )
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     ERC6492 OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Note: These ERC6492 operations do NOT have an ECDSA fallback.
    // These functions are intended to be used with the regular `isValidSignatureNow` functions
    // or other signature verification functions (e.g. P256).
    // The calldata variants are excluded for brevity.

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt to
    /// deploy / prepare the `signer` smart account before doing a regular ERC1271 check.
    /// Note: This function is NOT reentrancy safe.
    function isValidERC6492SignatureNowAllowSideEffects(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                pop(staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_))
                _isValid := and(
                    eq(mload(d_), f_),
                    staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                )
            }
            for {
                let n := mload(signature)
            } 1 {

            } {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    isValid := callIsValidSignature(signer, hash, signature)
                    break
                }
                let o := add(signature, 0x20) // Signature bytes.
                let d := add(o, mload(add(o, 0x20))) // Factory calldata.
                if iszero(extcodesize(signer)) {
                    if iszero(call(gas(), mload(o), 0, add(d, 0x20), mload(d), codesize(), 0x00)) {
                        break
                    }
                }
                let s := add(o, mload(add(o, 0x40))) // Inner signature.
                isValid := callIsValidSignature(signer, hash, s)
                if iszero(isValid) {
                    if call(gas(), mload(o), 0, add(d, 0x20), mload(d), codesize(), 0x00) {
                        isValid := callIsValidSignature(signer, hash, s)
                    }
                }
                break
            }
        }
    }

    /// @dev Returns whether `signature` is valid for `hash`.
    /// If the signature is postfixed with the ERC6492 magic number, it will attempt
    /// to use a reverting verifier to deploy / prepare the `signer` smart account
    /// and do a `isValidSignature` check via the reverting verifier.
    /// Note: This function is reentrancy safe.
    /// The reverting verifier must be be deployed.
    /// Otherwise, the function will return false if `signer` is not yet deployed / prepared.
    /// See: https://gist.github.com/Vectorized/846a474c855eee9e441506676800a9ad
    function isValidERC6492SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal returns (bool isValid) {
        /// @solidity memory-safe-assembly
        assembly {
            function callIsValidSignature(signer_, hash_, signature_) -> _isValid {
                let m_ := mload(0x40)
                let f_ := shl(224, 0x1626ba7e)
                mstore(m_, f_) // `bytes4(keccak256("isValidSignature(bytes32,bytes)"))`.
                mstore(add(m_, 0x04), hash_)
                let d_ := add(m_, 0x24)
                mstore(d_, 0x40) // The offset of the `signature` in the calldata.
                let n_ := add(0x20, mload(signature_))
                pop(staticcall(gas(), 4, signature_, n_, add(m_, 0x44), n_))
                _isValid := and(
                    eq(mload(d_), f_),
                    staticcall(gas(), signer_, m_, add(returndatasize(), 0x44), d_, 0x20)
                )
            }
            for {
                let n := mload(signature)
            } 1 {

            } {
                if iszero(eq(mload(add(signature, n)), mul(0x6492, div(not(isValid), 0xffff)))) {
                    isValid := callIsValidSignature(signer, hash, signature)
                    break
                }
                if extcodesize(signer) {
                    let o := add(signature, 0x20) // Signature bytes.
                    isValid := callIsValidSignature(signer, hash, add(o, mload(add(o, 0x40))))
                    if isValid {
                        break
                    }
                }
                let m := mload(0x40)
                mstore(m, signer)
                mstore(add(m, 0x20), hash)
                let willBeZeroIfRevertingVerifierExists := call(
                    gas(), // Remaining gas.
                    0x00007bd799e4A591FeA53f8A8a3E9f931626Ba7e, // Reverting verifier.
                    0, // Send zero ETH.
                    m, // Start of memory.
                    add(returndatasize(), 0x40), // Length of calldata in memory.
                    staticcall(gas(), 4, add(signature, 0x20), n, add(m, 0x40), n), // 1.
                    0x00 // Length of returndata to write.
                )
                isValid := gt(returndatasize(), willBeZeroIfRevertingVerifierExists)
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HASHING OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an Ethereum Signed Message, created from a `hash`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x20, hash) // Store into scratch space for keccak256.
            mstore(0x00, "\x00\x00\x00\x00\x19Ethereum Signed Message:\n32") // 28 bytes.
            result := keccak256(0x04, 0x3c) // `32 * 2 - (32 - 28) = 60 = 0x3c`.
        }
    }

    /// @dev Returns an Ethereum Signed Message, created from `s`.
    /// This produces a hash corresponding to the one signed with the
    /// [`eth_sign`](https://eth.wiki/json-rpc/API#eth_sign)
    /// JSON-RPC method as part of EIP-191.
    /// Note: Supports lengths of `s` up to 999999 bytes.
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let sLength := mload(s)
            let o := 0x20
            mstore(o, "\x19Ethereum Signed Message:\n") // 26 bytes, zero-right-padded.
            mstore(0x00, 0x00)
            // Convert the `s.length` to ASCII decimal representation: `base10(s.length)`.
            for {
                let temp := sLength
            } 1 {

            } {
                o := sub(o, 1)
                mstore8(o, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) {
                    break
                }
            }
            let n := sub(0x3a, o) // Header length: `26 + 32 - o`.
            // Throw an out-of-offset error (consumes all gas) if the header exceeds 32 bytes.
            returndatacopy(returndatasize(), returndatasize(), gt(n, 0x20))
            mstore(s, or(mload(0x00), mload(n))) // Temporarily store the header.
            result := keccak256(add(s, sub(0x20, n)), add(n, sLength))
            mstore(s, sLength) // Restore the length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   EMPTY CALLDATA HELPERS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns an empty calldata bytes.
    function emptySignature() internal pure returns (bytes calldata signature) {
        /// @solidity memory-safe-assembly
        assembly {
            signature.length := 0
        }
    }
}

/* solhint-enable no-inline-assembly */
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

interface IWETH9 {
    function balanceOf(address) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
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