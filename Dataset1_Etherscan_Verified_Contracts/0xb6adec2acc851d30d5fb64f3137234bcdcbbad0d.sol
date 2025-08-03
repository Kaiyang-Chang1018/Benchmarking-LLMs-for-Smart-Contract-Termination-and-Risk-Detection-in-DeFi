// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
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
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
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
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
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
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
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
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

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
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
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
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

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
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
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
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
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
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";
import "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success &&
            result.length >= 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
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
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
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
            require(denominator > prod1, "Math: mulDiv overflow");

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
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

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
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
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
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
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
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
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import {Ownable} from "../utils/Ownable.sol";
import {INftWrapper} from "../interfaces/INftWrapper.sol";
import {IEscrow} from "../interfaces/IEscrow.sol";
import {NftReceiver} from "../utils/NftReceiver.sol";
import {INftfiHub} from "../interfaces/INftfiHub.sol";
import {ContractKeys} from "../utils/ContractKeys.sol";
import {LoanCoordinator} from "../loans/LoanCoordinator.sol";
import {IPermittedNFTs} from "../interfaces/IPermittedNFTs.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title  Escrow
 * @author NFTfi
 * @notice Protocol wide escrow contract for NFT collateral
 * used when a user doen't have a personal escrow deployed
 **/
contract Escrow is IEscrow, Ownable, NftReceiver {
    using SafeERC20 for IERC20;

    // collateral contract => collateral id => locker contract(loan) => amount (preparing for 1155)
    mapping(address => mapping(uint256 => mapping(address => uint256))) internal _tokensLockedByLoan;

    /**
     * @dev keeps track of tokens being held as loan collateral, so we dont allow these
     * to be transferred with the aridrop draining functions
     * nft contract address => nft id => amount (in case of 1155)
     */
    mapping(address => mapping(uint256 => uint256)) internal _escrowTokens;

    // addresses of contracts thathas plugin rights
    mapping(address => bool) private plugins;

    // solhint-disable-next-line immutable-vars-naming
    INftfiHub public immutable hub;

    event Locked(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address indexed borrower,
        address loanContract
    );

    event Unlocked(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address indexed recipient,
        address loanContract
    );

    event LoanHandedOver(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address oldLoanContract,
        address newloanContract
    );

    error OnlyLoanContract();
    error CollateralNotLockedByLoan();
    error NoSuchTokenOwned();
    error NoSuchERC1155sOwned();
    error NoSuchERC721Owned();
    error NoSuchERC20Owned();
    error TokenIsCollateral();
    error CollateralDelegated();
    error NotAPlugin();

    /**
     * @notice Sets the admin of the contract.
     *
     * @param _admin - Initial admin of this contract.
     */
    constructor(address _admin, address _hub) Ownable(_admin) {
        hub = INftfiHub(_hub);
    }

    /**
     * @notice Checks if the caller is is a loan contract
     */
    modifier onlyLoan() {
        // checking that locker is a registered loan type
        // WARNING if we ever register an external account (or malicious contract) as a loan type that
        // account can steal user nfts that has been approved for this contract by locking and unlocking
        if (
            LoanCoordinator(hub.getContract(ContractKeys.LOAN_COORDINATOR)).getTypeOfLoanContract(msg.sender) ==
            bytes32(0)
        ) revert OnlyLoanContract();
        _;
    }

    /**
     * @notice Checks if the caller is the locker of the given collateral nft in the parameter
     *
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     */
    modifier onlyLockingLoan(address _nftCollateralContract, uint256 _nftCollateralId) {
        if (_tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][msg.sender] == 0)
            revert CollateralNotLockedByLoan();
        _;
    }

    /**
     * @notice Locks collateral NFT for a loan.
     *
     * @param _nftCollateralWrapper - Address of the NFT wrapper contract.
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     * @param _borrower - Address of the borrower.
     */
    function lockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _borrower
    ) external virtual override onlyLoan {
        _lockCollateral(_nftCollateralContract, _nftCollateralId);
        _transferNFT(_nftCollateralWrapper, _nftCollateralContract, _nftCollateralId, _borrower, address(this));
        emit Locked(_nftCollateralContract, _nftCollateralId, _borrower, msg.sender);
    }

    /**
     * @notice Internal function to lock collateral.
     *
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     */
    function _lockCollateral(address _nftCollateralContract, uint256 _nftCollateralId) internal {
        _tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][msg.sender] += 1;
        _escrowTokens[_nftCollateralContract][_nftCollateralId] += 1;
    }

    /**
     * @notice Unlocks collateral NFT for a loan.
     *
     * @param _nftCollateralWrapper - Address of the NFT wrapper contract.
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     * @param _recipient - Address of the recipient.
     */
    function unlockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _recipient
    ) external virtual override onlyLockingLoan(_nftCollateralContract, _nftCollateralId) {
        _unlockCollateral(_nftCollateralContract, _nftCollateralId);
        _transferNFT(_nftCollateralWrapper, _nftCollateralContract, _nftCollateralId, address(this), _recipient);
        emit Unlocked(_nftCollateralContract, _nftCollateralId, _recipient, msg.sender);
    }

    /**
     * @notice Internal function to unlock collateral.
     *
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     */
    function _unlockCollateral(address _nftCollateralContract, uint256 _nftCollateralId) internal {
        _tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][msg.sender] -= 1;
        _escrowTokens[_nftCollateralContract][_nftCollateralId] -= 1;
    }

    function handOverLoan(
        address _newLoanContract,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) external virtual override onlyLockingLoan(_nftCollateralContract, _nftCollateralId) {
        _tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][msg.sender] -= 1;
        _tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][_newLoanContract] += 1;
        emit LoanHandedOver(_nftCollateralContract, _nftCollateralId, msg.sender, _newLoanContract);
    }

    /**
     * @notice Checks if a collateral NFT is in escrow with a specific loan.
     *
      @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     * @param _loan - Address of the loan contract.
     * @return bool - True if the NFT is in escrow with the loan, false otherwise.
     */
    function isInEscrowWithLoan(
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _loan
    ) external view override returns (bool) {
        return _tokensLockedByLoan[_nftCollateralContract][_nftCollateralId][_loan] > 0;
    }

    /**
     * @dev Transfers several types of NFTs using a wrapper that knows how to handle each case.
     *
     * @param _sender - Current owner of the NF
     * @param _recipient - Recipient of the transfer
     */
    function _transferNFT(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _sender,
        address _recipient
    ) internal {
        Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "NFT not successfully transferred"
        );
    }

    /**
     * @dev Checks if the contract owns a specific NFT.
     *
     * @param _nftCollateralWrapper - Address of the NFT wrapper contract.
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     * @return bool - True if the contract owns the NFT, false otherwise.
     */
    function _isOwned(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal returns (bool) {
        bytes memory result = Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).isOwner.selector,
                address(this),
                _nftCollateralContract,
                _nftCollateralId
            ),
            "Ownership check failed"
        );
        return abi.decode(result, (bool));
    }

    /**
     * @notice used by the owner account to be able to drain sturck ERC20 tokens for revenue share
     * for the locked  collateral NFT-s
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainERC20Airdrop(address _tokenAddress, uint256 amount, address _receiver) external onlyOwner {
        // ensuring that this cannot be used to transfer any permitted, escrowed nft
        // that has the following transfer function (interpreting amount as id):
        // function transfer(address _to, uint256 _tokenId), like CryptoKitties for example
        if (_escrowTokens[_tokenAddress][amount] > 0) {
            revert TokenIsCollateral();
        }

        IERC20 tokenContract = IERC20(_tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));
        if (balance == 0) {
            revert NoSuchERC20Owned();
        }
        tokenContract.safeTransfer(_receiver, amount);
    }

    /**
     * @notice used by the owner account to be able to drain any tokens used as collateral that is not locked in a loan
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _tokenId - id token to be sent out
     * @param _receiver - receiver of the token
     */
    function withdrawNFT(address _tokenAddress, uint256 _tokenId, address _receiver) external onlyOwner {
        if (_escrowTokens[_tokenAddress][_tokenId] > 0) {
            revert TokenIsCollateral();
        }
        address tokenWrapper = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNFTWrapper(
            _tokenAddress
        );
        if (!_isOwned(tokenWrapper, _tokenAddress, _tokenId)) {
            revert NoSuchTokenOwned();
        }
        _transferNFT(tokenWrapper, _tokenAddress, _tokenId, address(this), _receiver);
    }

    /**
     * @notice used by the owner account to be able to drain stuck or airdropped NFTs
     * a check prevents draining collateral
     * @param _nftType - nft type key which is sourced from nftfi hub
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _tokenId - id token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainNFT(
        string memory _nftType,
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver
    ) external onlyOwner {
        if (_escrowTokens[_tokenAddress][_tokenId] > 0) {
            revert TokenIsCollateral();
        }
        bytes32 nftTypeKey = _getIdFromStringKey(_nftType);
        address transferWrapper = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNftTypeWrapper(
            nftTypeKey
        );
        _transferNFT(transferWrapper, _tokenAddress, _tokenId, address(this), _receiver);
    }

    /**
     * @notice Admin function for adding a plugin that can make an arbitrary function call
     * WARNING! serious security implications! plugins can move the collateral
     * @param _plugin address of the plugin
     */
    function addPlugin(address _plugin) external virtual onlyOwner {
        plugins[_plugin] = true;
    }

    /**
     * @notice Admin function for removing a plugin that can make an arbitrary function call
     * @param _plugin address of the plugin
     */
    function removePlugin(address _plugin) external virtual onlyOwner {
        plugins[_plugin] = false;
    }

    function pluginCall(address _target, bytes memory _data) external returns (bool, bytes memory) {
        if (!plugins[msg.sender]) revert NotAPlugin();
        // solhint-disable-next-line avoid-low-level-calls
        return _target.call(_data);
    }

    /**
     * @notice Returns the bytes32 representation of a string (copied from ContractKeys so we dont need it as a lib)
     * @param _key the string key
     * @return id bytes32 representation
     */
    function _getIdFromStringKey(string memory _key) internal pure returns (bytes32 id) {
        // solhint-disable-next-line custom-errors
        require(bytes(_key).length <= 32, "invalid key");

        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := mload(add(_key, 32))
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import {Escrow} from "./Escrow.sol";
import {IPersonalEscrow} from "../interfaces/IPersonalEscrow.sol";
import {IEscrow} from "../interfaces/IEscrow.sol";
import {INftWrapper} from "../interfaces/INftWrapper.sol";

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title  PersonalEscrow
 * @author NFTfi
 * @notice User-specific escrow contract
 **/
contract PersonalEscrow is IPersonalEscrow, Escrow, Initializable {
    event Initialized(address owner);

    /**
     * @dev Initializes the Escrow contract with a null owner.
     * @param _hub Address of the NftfiHub contract
     */
    constructor(address _hub) Escrow(address(0), _hub) {}

    /**
     * @notice Initializes the contract setting the owner.
     * @param _owner Address of the new owner of the excrow
     */
    function initialize(address _owner) external initializer {
        _setOwner(_owner);
        emit Initialized(_owner);
    }

    /**
     * @notice Locks the NFT collateral in the escrow.
     * @param _nftCollateralWrapper Address of the NFT collateral wrapper
     * @param _nftCollateralContract Address of the NFT collateral contract
     * @param _nftCollateralId ID of the NFT collateral
     * @param _borrower Address of the borrower
     */
    function lockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _borrower
    ) external override(IEscrow, Escrow) onlyLoan {
        // we need to check that the escrow owns more collateral tokens that the ones already locked
        // - in case of balance 0 check is FALSE: we have to attempt to transfer the token
        // - in case of non fungibles if balance is 1 and escrowed is 0, check is TRUE we have the unlocked token: OK
        // - in case of non fungibles if balance is 1 and escrowed is 1,
        //   we have the token already locked, check is FALSE - transfer will be attempted and fail
        //   (because it's unique ans is already here)
        // - in case of fungibles (1155) if balance is n + k (k>1 positive integer) and escrowed is n,
        //   check is TRUE, we have unlocked token(s): OK
        // - in case of fungibles (1155) if balance is n and escrowed is n (equal),
        //   we only have locked token(s), check is FALSE: we have to attempt to transfer the token
        if (
            _balanceOf(_nftCollateralWrapper, _nftCollateralContract, _nftCollateralId) >
            _escrowTokens[_nftCollateralContract][_nftCollateralId]
        ) {
            // we only lock, collateral is already in contract, no need to transfer
            _lockCollateral(_nftCollateralContract, _nftCollateralId);
        } else {
            // we lock and transfer
            _lockCollateral(_nftCollateralContract, _nftCollateralId);
            _transferNFT(_nftCollateralWrapper, _nftCollateralContract, _nftCollateralId, _borrower, address(this));
        }
    }

    /**
     * @dev Checks balance of a specific NFT owned by the contract.
     *
     * @param _nftCollateralWrapper - Address of the NFT wrapper contract.
     * @param _nftCollateralContract - Address of the NFT collateral contract.
     * @param _nftCollateralId - ID of the NFT collateral.
     * @return bool - True if the contract owns the NFT, false otherwise.
     */
    function _balanceOf(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal returns (uint256) {
        bytes memory result = Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).balanceOf.selector,
                address(this),
                _nftCollateralContract,
                _nftCollateralId
            ),
            "Balance check failed"
        );
        return abi.decode(result, (uint256));
    }

    /**
     * @notice Unlocks the NFT collateral from the escrow and transfers it to the recipient.
     * @param _nftCollateralWrapper Address of the NFT collateral wrapper
     * @param _nftCollateralContract Address of the NFT collateral contract
     * @param _nftCollateralId ID of the NFT collateral
     * @param _recipient Address of the recipient
     */
    function unlockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _recipient
    ) external override(IEscrow, Escrow) onlyLockingLoan(_nftCollateralContract, _nftCollateralId) {
        _unlockCollateral(_nftCollateralContract, _nftCollateralId);
        _transferNFT(_nftCollateralWrapper, _nftCollateralContract, _nftCollateralId, address(this), _recipient);
    }

    /**
     * @notice unlocks and approves for an escrow contract that is taking over, only locking loan can initiate
     * @param _nftCollateralWrapper Address of the NFT collateral wrapper
     * @param _nftCollateralContract Address of the NFT collateral contract
     * @param _nftCollateralId ID of the NFT collateral
     * @param _recipientEscrow Address of the recipient escrow contract
     */
    function handOverCollateralToEscrow(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _recipientEscrow
    ) external override onlyLockingLoan(_nftCollateralContract, _nftCollateralId) {
        _unlockCollateral(_nftCollateralContract, _nftCollateralId);
        _approveNFT(_nftCollateralWrapper, _recipientEscrow, _nftCollateralContract, _nftCollateralId);
    }

    /**
     * @notice Unlocks the NFT collateral from the escrow without transferring it.
     * @param _nftCollateralContract Address of the NFT collateral contract
     * @param _nftCollateralId ID of the NFT collateral
     */
    function unlockAndKeepCollateral(
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) external onlyLockingLoan(_nftCollateralContract, _nftCollateralId) {
        _unlockCollateral(_nftCollateralContract, _nftCollateralId);
    }

    /**
     * @dev Approves an NFT to be used by another address trough the NFT adaptor.
     *
     * @param _to - The address to approve to transfer or manage the NFT.
     * @param _nftCollateralContract - The contract address of the NFT.
     * @param _nftCollateralId - The token ID of the NFT.
     *
     * @return bool - Returns true if the approval was successful.
     */
    function _approveNFT(
        address _nftCollateralWrapper,
        address _to,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal returns (bool) {
        bytes memory result = Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).approveNFT.selector,
                _to,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "NFT not successfully approved"
        );

        return abi.decode(result, (bool));
    }

    function addPlugin(address) external pure override(Escrow) {
        revert AddingOrRemovingPluginsNotAllowed();
    }

    function removePlugin(address) external pure override(Escrow) {
        revert AddingOrRemovingPluginsNotAllowed();
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "../utils/Ownable.sol";

import {PersonalEscrow} from "./PersonalEscrow.sol";
import {IPersonalEscrowFactory} from "../interfaces/IPersonalEscrowFactory.sol";

/**
 * @title PersonalEscrowFactory
 * @author NFTfi
 * @notice Used to deploy new personal escrow contracts for specific users
 */
contract PersonalEscrowFactory is IPersonalEscrowFactory, Ownable, Pausable {
    // solhint-disable-next-line immutable-vars-naming
    address public immutable personalEscrowImplementation;
    string public baseURI;

    // Incremental token id
    uint256 public tokenCount = 0;

    mapping(address owner => address escrow) private _personalEscrowOfOwner;

    mapping(address => bool) private _isPersonalEscrow;

    event PersonalEscrowCreated(address indexed instance, address indexed owner, address creator);

    error PersonalEscrowAlreadyExistsForUser();

    /**
     * @param _personalEscrowImplementation - deployed master copy of the personal escrow contract
     */
    constructor(address _personalEscrowImplementation, address _admin) Ownable(_admin) {
        personalEscrowImplementation = _personalEscrowImplementation;
        _pause();
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev clones a new personal escrow contract
     */

    function createPersonalEscrow() external whenNotPaused returns (address) {
        if (_personalEscrowOfOwner[msg.sender] != address(0)) revert PersonalEscrowAlreadyExistsForUser();
        address instance = Clones.clone(personalEscrowImplementation);
        _personalEscrowOfOwner[msg.sender] = instance;
        _isPersonalEscrow[instance] = true;
        PersonalEscrow(instance).initialize(msg.sender);
        emit PersonalEscrowCreated(instance, msg.sender, msg.sender);
        return instance;
    }

    /**
     * @dev retunrs escrow address of the owner
     * @return address of the personal escrow
     */
    function personalEscrowOfOwner(address _owner) external view returns (address) {
        return _personalEscrowOfOwner[_owner];
    }

    /**
     * @dev checks if the address is a personal escrow
     * @return bool true if the address is a personal escrow
     */
    function isPersonalEscrow(address _escrow) external view returns (bool) {
        return _isPersonalEscrow[_escrow];
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

interface IDelegateCashPlugin {
    struct DelegationSettings {
        address to;
        bytes32 rights;
        bool isERC721;
    }

    function delegateERC721(
        uint32 loanId,
        string memory offerType,
        address to,
        address collateralContract,
        uint256 tokenId,
        bytes32 rights
    ) external;

    function isCollateralDelegated(uint32 _loanId) external view returns (bool);

    function getDelegationSettings(uint32 _loanId) external view returns (DelegationSettings memory);

    function undelegateERC721(uint32 _loanId) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

interface IERC20TransferManager {
    function transfer(address _token, address _sender, address _recipient, uint256 _amount) external;

    function safeLoanPaybackTransfer(address _token, address _sender, address _recipient, uint256 _amount) external;

    function safeAdminFeeTransfer(address _token, address _sender, address _recipient, uint256 _amount) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

interface IEscrow {
    function lockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _borrower
    ) external;

    function unlockCollateral(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _recipient
    ) external;

    function handOverLoan(address _newLoanContract, address _nftCollateralContract, uint256 _nftCollateralId) external;

    function isInEscrowWithLoan(
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _loan
    ) external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title ILoanCoordinator
 * @author NFTfi
 * @dev LoanCoordinator interface.
 */
interface ILoanCoordinator {
    enum StatusType {
        NOT_EXISTS,
        NEW,
        REPAID,
        LIQUIDATED
    }

    /**
     * @notice This struct contains data related to a loan
     *
     * @param smartNftId - The id of both the promissory note and obligation receipt.
     * @param status - The status in which the loan currently is.
     * @param loanContract - Address of the contract that created the loan.
     */
    struct Loan {
        address loanContract;
        uint64 smartNftId;
        StatusType status;
    }

    function registerLoan() external returns (uint32);

    function resetSmartNfts(uint32 _loanId) external;

    function mintObligationReceipt(uint32 _loanId, address _borrower) external;

    function mintPromissoryNote(uint32 _loanId, address _lender) external;

    function resolveLoan(uint32 _loanId, bool liquidated) external;

    function promissoryNoteToken() external view returns (address);

    function obligationReceiptToken() external view returns (address);

    function getLoanData(uint32 _loanId) external view returns (Loan memory);

    function isValidLoanId(uint32 _loanId, address _loanContract) external view returns (bool);

    function getDefaultLoanContractForOfferType(bytes32 _offerType) external view returns (address);

    function getTypeOfLoanContract(address _loanContract) external view returns (bytes32);

    function checkNonce(address _user, uint256 _nonce) external view;

    function checkAndInvalidateNonce(address _user, uint256 _nonce) external;
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title INftWrapper
 * @author NFTfi
 * @dev Interface for NFT Wrappers.
 */
interface INftWrapper {
    function transferNFT(address from, address to, address nftContract, uint256 tokenId) external returns (bool);

    function approveNFT(address to, address nftContract, uint256 tokenId) external returns (bool);

    function isOwner(address owner, address nftContract, uint256 tokenId) external view returns (bool);

    function balanceOf(address owner, address nftContract, uint256 tokenId) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title INftfiHub
 * @author NFTfi
 * @dev NftfiHub interface
 */
interface INftfiHub {
    function setContract(string calldata _contractKey, address _contractAddress) external;

    function getContract(bytes32 _contractKey) external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

interface IPermittedERC20s {
    function getERC20Permit(address _erc20) external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

interface IPermittedNFTs {
    function setNFTPermit(address _nftContract, string memory _nftType) external;

    function getNFTPermit(address _nftContract) external view returns (bytes32);

    function getNFTWrapper(address _nftContract) external view returns (address);

    function getNftTypeWrapper(bytes32 _nftType) external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {IEscrow} from "./IEscrow.sol";

interface IPersonalEscrow is IEscrow {
    error AddingOrRemovingPluginsNotAllowed();

    function handOverCollateralToEscrow(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _recipientEscrow
    ) external;
    function unlockAndKeepCollateral(address _nftCollateralContract, uint256 _nftCollateralId) external;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

interface IPersonalEscrowFactory {
    function pause() external;

    function unpause() external;

    function createPersonalEscrow() external returns (address);

    function personalEscrowOfOwner(address _owner) external view returns (address);

    function isPersonalEscrow(address _escrow) external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {Ownable} from "../utils/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title  BaseLoan
 * @author NFTfi
 * @dev Implements base functionalities common to all Loan types.
 * Mostly related to governance and security.
 */
abstract contract BaseLoan is Ownable, Pausable, ReentrancyGuard {
    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Sets the admin of the contract.
     *
     * @param _admin - Initial admin of this contract.
     */
    constructor(address _admin) Ownable(_admin) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {SmartNft} from "../smartNft/SmartNft.sol";
import {ILoanCoordinator} from "../interfaces/ILoanCoordinator.sol";
import {INftfiHub} from "../interfaces/INftfiHub.sol";
import {Ownable} from "../utils/Ownable.sol";
import {ContractKeyUtils} from "../utils/ContractKeyUtils.sol";

/**
 * @title  LoanCoordinator
 * @author NFTfi
 * @notice This contract is in charge of coordinating the creation, distribution and desctruction of the SmartNfts
 * related to a loan, the Promossory Note and Obligaiton Receipt.
 */
contract LoanCoordinator is ILoanCoordinator, Ownable {
    /* ******* */
    /* STORAGE */
    /* ******* */

    // solhint-disable-next-line immutable-vars-naming
    INftfiHub public immutable hub;

    /**
     * @dev For each loan type, records the address of the contract that implements the type
     */
    mapping(bytes32 loanType => address offerAddress) private _defaultLoanContractForOfferType;
    /**
     * @dev reverse mapping of offerTypes - for each contract address, records the associated loan type
     */
    mapping(address offerAddress => bytes32 loanType) private _typeOfLoanContract;

    mapping(address => bool) private _isLoanContractDisabled;

    /**
     * @notice A continuously increasing counter that simultaneously allows every loan to have a unique ID and provides
     * a running count of how many loans have been started by this contract.
     */
    uint32 public totalNumLoans = 0;

    uint32 public smartNftIdCounter = 0;

    // The address that deployed this contract
    // solhint-disable-next-line immutable-vars-naming
    address private immutable _deployer;
    bool private _initialized = false;

    mapping(uint32 => Loan) private loans;

    address public override promissoryNoteToken;
    address public override obligationReceiptToken;

    /**
     * @notice A mapping that takes both a user's address and a loan nonce that was first used when signing an off-chain
     * order and checks whether that nonce has previously either been used for a loan, or has been pre-emptively
     * cancelled. The nonce referred to here is not the same as an Ethereum account's nonce. We are referring instead to
     * nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi orders.
     *
     * These nonces can be any uint256 value that the user has not previously used to sign an off-chain order. Each
     * nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the borrower
     * in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would submit a
     * user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     */
    mapping(bytes32 offerType => mapping(address user => mapping(uint256 nonce => bool nonceHasBeenUsed)))
        internal _nonceHasBeenUsedForUserByOfferType;

    /* ****** */
    /* EVENTS */
    /* ****** */

    event UpdateStatus(uint32 indexed loanId, address indexed loanContract, StatusType newStatus);

    /**
     * @notice This event is fired whenever the admins register a loan type.
     *
     * @param offerType - offer type represented by keccak256('offer type').
     * @param loanContract - Address of the loan type contract.
     */
    event TypeUpdated(bytes32 indexed offerType, address indexed loanContract);

    /* ************* */
    /* CUSTOM ERRORS */
    /* ************* */

    error NotInitialized();
    error OnlyDeployer();
    error AlreadyInitialized();
    error ObligationReceiptZeroAddress();
    error PromissoryNoteZeroAddress();
    error ObligationReceiptAlreadyExists();
    error PromissoryNoteAlreadyExists();
    error NotRegisteredLoanContract();
    error DisabledLoanContract();
    error PromissoryNoteDoesntExist();
    error LoanStatusMustBeNEW();
    error CallerNotLoanCreatorContract();
    error OfferTypeIsEmpty();
    error LoanContractAlreadyRegistered();
    error FunctionInformationArityMismatch();
    error InvalidNonce();

    /**
     * @dev Function using this modifier can only be executed after this contract is initialized
     *
     */
    modifier onlyInitialized() {
        if (!_initialized) revert NotInitialized();
        _;
    }

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Sets the admin of the contract.
     * Initializes `contractTypes` with a batch of loan types. Sets `NftfiHub`.
     *
     * @param  _nftfiHub - Address of the NftfiHub contract
     * @param _admin - Initial admin of this contract.
     * @param _offerTypes - offer types represented by keccak256('offer type').
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    constructor(
        address _nftfiHub,
        address _admin,
        string[] memory _offerTypes,
        address[] memory _loanContracts
    ) Ownable(_admin) {
        hub = INftfiHub(_nftfiHub);
        _deployer = msg.sender;
        _registerOfferTypes(_offerTypes, _loanContracts);
    }

    /**
     * @dev Sets `promissoryNoteToken` and `obligationReceiptToken`.
     * It can be executed once by the deployer.
     *
     * @param  _promissoryNoteToken - Promissory Note Token address
     * @param  _obligationReceiptToken - Obligaiton Recipt Token address
     */
    function initialize(address _promissoryNoteToken, address _obligationReceiptToken) external {
        if (msg.sender != _deployer) revert OnlyDeployer();
        if (_initialized) revert AlreadyInitialized();
        if (_promissoryNoteToken == address(0)) revert PromissoryNoteZeroAddress();
        if (_obligationReceiptToken == address(0)) revert ObligationReceiptZeroAddress();

        _initialized = true;
        promissoryNoteToken = _promissoryNoteToken;
        obligationReceiptToken = _obligationReceiptToken;
    }

    /**
     * @dev This is called by the OfferType beginning the new loan.
     * It initialize the new loan data, and returns the new loan id.
     */
    function registerLoan() external override onlyInitialized returns (uint32) {
        address loanContract = msg.sender;

        if (_typeOfLoanContract[loanContract] == bytes32(0)) revert NotRegisteredLoanContract();
        if (_isLoanContractDisabled[loanContract]) revert DisabledLoanContract();

        // (loanIds start at 1)
        totalNumLoans += 1;
        Loan memory newLoan = Loan({status: StatusType.NEW, loanContract: loanContract, smartNftId: 0});

        loans[totalNumLoans] = newLoan;
        emit UpdateStatus(totalNumLoans, loanContract, StatusType.NEW);

        return totalNumLoans;
    }

    /**
     * @notice Mints a Promissory Note SmartNFT for the lender. Must be called by corresponding loan type
     *
     * @param _loanId - The ID of the loan.
     * @param _lender - The address of the lender.
     */
    function mintPromissoryNote(uint32 _loanId, address _lender) external onlyInitialized {
        address loanContract = msg.sender;

        if (_typeOfLoanContract[loanContract] == bytes32(0)) revert NotRegisteredLoanContract();

        // create smartNFTid to match the id of the promissory note if promissory note doens't exist
        uint64 smartNftId = loans[_loanId].smartNftId;
        if (smartNftId == 0) {
            smartNftIdCounter += 1;
            smartNftId = uint64(uint256(keccak256(abi.encodePacked(address(this), smartNftIdCounter))));
        }

        if (loans[_loanId].status != StatusType.NEW) revert LoanStatusMustBeNEW();
        if (SmartNft(promissoryNoteToken).exists(smartNftId)) revert PromissoryNoteAlreadyExists();

        loans[_loanId].smartNftId = smartNftId;
        // Issue an ERC721 promissory note to the lender that gives them the
        // right to either the principal-plus-interest or the collateral.
        SmartNft(promissoryNoteToken).mint(_lender, smartNftId, abi.encode(_loanId));
    }

    /**
     * @notice Mints an Obligation Receipt SmartNFT for the borrower. Must be called by corresponding loan type
     *
     * @param _loanId - The ID of the loan.
     * @param _borrower - The address of the borrower.
     */
    function mintObligationReceipt(uint32 _loanId, address _borrower) external override onlyInitialized {
        address loanContract = msg.sender;

        if (_typeOfLoanContract[loanContract] == bytes32(0)) revert NotRegisteredLoanContract();

        // create smartNFTid to match the id of the promissory note if promissory note doens't exist
        uint64 smartNftId = loans[_loanId].smartNftId;
        if (smartNftId == 0) {
            smartNftIdCounter += 1;
            smartNftId = uint64(uint256(keccak256(abi.encodePacked(address(this), smartNftIdCounter))));
        }

        if (loans[_loanId].status != StatusType.NEW) revert LoanStatusMustBeNEW();
        if (SmartNft(obligationReceiptToken).exists(smartNftId)) revert ObligationReceiptAlreadyExists();

        loans[_loanId].smartNftId = smartNftId;
        // Issue an ERC721 obligation receipt to the borrower that gives them the
        // right to pay back the loan and get the collateral back.
        SmartNft(obligationReceiptToken).mint(_borrower, smartNftId, abi.encode(_loanId));
    }

    /**
     * @notice Resets the SmartNFTs associated with a loan.
     *
     * @param _loanId - The ID of the loan.
     */
    function resetSmartNfts(uint32 _loanId) external override onlyInitialized {
        address loanContract = msg.sender;

        if (_typeOfLoanContract[loanContract] == bytes32(0)) revert NotRegisteredLoanContract();

        uint64 oldSmartNftId = loans[_loanId].smartNftId;
        if (loans[_loanId].status != StatusType.NEW) revert LoanStatusMustBeNEW();

        if (SmartNft(promissoryNoteToken).exists(oldSmartNftId)) {
            SmartNft(promissoryNoteToken).burn(oldSmartNftId);
        }

        if (SmartNft(obligationReceiptToken).exists(oldSmartNftId)) {
            SmartNft(obligationReceiptToken).burn(oldSmartNftId);
        }
    }

    /**
     * @dev This is called by the OfferType who created the loan, when a loan is resolved whether by paying back or
     * liquidating the loan.
     * It sets the loan as `RESOLVED` and burns both PromossoryNote and ObligationReceipt SmartNft's.
     *
     * @param _loanId - Id of the loan
     */
    function resolveLoan(uint32 _loanId, bool _repaid) external override onlyInitialized {
        Loan storage loan = loans[_loanId];

        if (loan.status != StatusType.NEW) revert LoanStatusMustBeNEW();

        if (loan.loanContract != msg.sender) revert CallerNotLoanCreatorContract();

        if (_repaid) {
            loan.status = StatusType.REPAID;
        } else {
            loan.status = StatusType.LIQUIDATED;
        }

        if (SmartNft(promissoryNoteToken).exists(loan.smartNftId)) {
            SmartNft(promissoryNoteToken).burn(loan.smartNftId);
        }

        if (SmartNft(obligationReceiptToken).exists(loan.smartNftId)) {
            SmartNft(obligationReceiptToken).burn(loan.smartNftId);
        }

        emit UpdateStatus(_loanId, msg.sender, loan.status);
    }

    /**
     * @dev Returns loan's data for a given id.
     *
     * @param _loanId - Id of the loan
     */
    function getLoanData(uint32 _loanId) external view override returns (Loan memory) {
        return loans[_loanId];
    }

    /**
     * @dev Returns loan's data and offerType for a given loan id.
     *
     * @param _loanId - Id of the loan
     */
    function getLoanDataAndOfferType(uint32 _loanId) external view returns (Loan memory, bytes32) {
        Loan memory loan = loans[_loanId];
        return (loan, _typeOfLoanContract[loan.loanContract]);
    }

    /**
     * @dev checks if the given id is valid for the given loan contract address
     * @param _loanId - Id of the loan
     * @param _loanContract - address og the loan contract
     */
    function isValidLoanId(uint32 _loanId, address _loanContract) external view override returns (bool validity) {
        validity = loans[_loanId].loanContract == _loanContract;
    }

    /**
     * @notice  Set or update the contract address that implements the given Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _offerType - Loan type represented by 'loan type'.
     * @param _loanContract - The address of the wrapper contract that implements the loan type's behaviour.
     */
    function registerOfferType(string memory _offerType, address _loanContract) external onlyOwner {
        _registerOfferType(_offerType, _loanContract);
    }

    /**
     * @notice Deletes the contract address associated with a given Loan Type.
     *
     * @param _offerType - Loan type represented by 'loan type'.
     * @param _loanContract - The address of the wrapper contract to be deleted.
     */
    function deleteOfferType(string memory _offerType, address _loanContract) external onlyOwner {
        bytes32 offerTypeKey = ContractKeyUtils.getIdFromStringKey(_offerType);

        delete _typeOfLoanContract[_loanContract];
        if (_defaultLoanContractForOfferType[offerTypeKey] == _loanContract) {
            delete _defaultLoanContractForOfferType[offerTypeKey];
        }
    }

    /**
     * @notice Disables a loan contract. Makes it impossible for a loan contract to register a new loan,
     * altough renegotiations of their existing loans and repayment/liquidations are still possible
     *
     * @param _loanContract - The address of the loan contract to be disabled.
     */
    function disableLoanContract(address _loanContract) external onlyOwner {
        _isLoanContractDisabled[_loanContract] = true;
    }

    /**
     * @notice Enables a loan contract.
     *
     * @param _loanContract - The address of the loan contract to be enabled.
     */
    function enableLoanContract(address _loanContract) external onlyOwner {
        _isLoanContractDisabled[_loanContract] = false;
    }

    /**
     * @notice  Batch set or update the contract addresses that implement the given batch Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _offerTypes - Loan types represented by 'loan type'.
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    function registerOfferTypes(string[] memory _offerTypes, address[] memory _loanContracts) external onlyOwner {
        _registerOfferTypes(_offerTypes, _loanContracts);
    }

    /**
     * @notice This function can be called by anyone to get the latest
     * contract address that implements the given loan type.
     *
     * @param  _offerType - The loan type, e.g. bytes32("ASSET_OFFER_LOAN")
     */
    function getDefaultLoanContractForOfferType(bytes32 _offerType) public view override returns (address) {
        return _defaultLoanContractForOfferType[_offerType];
    }

    /**
     * @notice This function can be called by anyone to get the loan type of the given contract address.
     *
     * @param  _loanContract - The loan contract
     */
    function getTypeOfLoanContract(address _loanContract) public view override returns (bytes32) {
        return _typeOfLoanContract[_loanContract];
    }

    /**
     * @notice Checks if a loan contract is disabled.
     *
     * @param _loanContract - The loan contract address.
     * @return bool - True if disabled, false otherwise.
     */
    function isLoanContractDisabled(address _loanContract) external view returns (bool) {
        return _isLoanContractDisabled[_loanContract];
    }

    /**
     * @notice  Set or update the contract address that implements the given Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _offerType - Loan type represented by 'loan type').
     * @param _loanContract - The address of the wrapper contract that implements the loan type's behaviour.
     */
    function _registerOfferType(string memory _offerType, address _loanContract) internal {
        if (bytes(_offerType).length == 0) revert OfferTypeIsEmpty();
        bytes32 offerTypeKey = ContractKeyUtils.getIdFromStringKey(_offerType);

        // delete loan contract address of old typeKey registered to this loan contract address

        if (_typeOfLoanContract[_loanContract] != bytes32(0)) revert LoanContractAlreadyRegistered();

        _defaultLoanContractForOfferType[offerTypeKey] = _loanContract;
        _typeOfLoanContract[_loanContract] = offerTypeKey;

        emit TypeUpdated(offerTypeKey, _loanContract);
    }

    /**
     * @notice  Batch set or update the contract addresses that implement the given batch Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _offerTypes - Loan types represented by keccak256('loan type').
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    function _registerOfferTypes(string[] memory _offerTypes, address[] memory _loanContracts) internal {
        if (_offerTypes.length != _loanContracts.length) revert FunctionInformationArityMismatch();

        for (uint256 i; i < _offerTypes.length; ++i) {
            _registerOfferType(_offerTypes[i], _loanContracts[i]);
        }
    }

    /**
     * @notice This function can be called by either a lender or a borrower to cancel all off-chain orders that they
     * have signed that contain this nonce. If the off-chain orders were created correctly, there should only be one
     * off-chain order that contains this nonce at all.
     *
     * The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi
     * orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain order.
     * Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the
     * borrower in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would
     * submit a user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     *
     * @param  _nonce - User nonce
     */
    function cancelLoanCommitment(bytes32 _offerType, uint256 _nonce) external {
        if (_nonceHasBeenUsedForUserByOfferType[_offerType][msg.sender][_nonce]) {
            revert InvalidNonce();
        }
        _nonceHasBeenUsedForUserByOfferType[_offerType][msg.sender][_nonce] = true;
    }

    /**
     * @notice This function can be used to view whether a particular nonce for a particular user has already been used,
     * either from a successful loan or a cancelled off-chain order.
     *
     * @param _user - The address of the user. This function works for both lenders and borrowers alike.
     * @param  _nonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain
     * NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain
     * order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or
     * the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     *
     * @return A bool representing whether or not this nonce has been used for this user.
     */
    function getWhetherNonceHasBeenUsedForUser(
        bytes32 _offerType,
        address _user,
        uint256 _nonce
    ) external view returns (bool) {
        return _nonceHasBeenUsedForUserByOfferType[_offerType][_user][_nonce];
    }

    /**
     * @notice Checks if a nonce is valid.
     *
     * @param _user - The address of the user.
     * @param _nonce - The nonce to be checked.
     */
    function checkNonce(address _user, uint256 _nonce) public view override {
        bytes32 offerType = _typeOfLoanContract[msg.sender];
        if (_nonceHasBeenUsedForUserByOfferType[offerType][_user][_nonce]) {
            revert InvalidNonce();
        }
    }

    /**
     * @notice Checks and invalidates a nonce for a user.
     *
     * @param _user - The address of the user.
     * @param _nonce - The nonce to be checked and invalidated.
     */
    function checkAndInvalidateNonce(address _user, uint256 _nonce) external override {
        bytes32 offerType = _typeOfLoanContract[msg.sender];
        if (_nonceHasBeenUsedForUserByOfferType[offerType][_user][_nonce]) {
            revert InvalidNonce();
        }
        _nonceHasBeenUsedForUserByOfferType[offerType][_user][_nonce] = true;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {
    ILoanCoordinator,
    LoanBaseMinimal,
    NFTfiSigningUtils,
    LoanChecksAndCalculations,
    LoanData
} from "./LoanBaseMinimal.sol";
import {ContractKeyUtils} from "../../utils/ContractKeyUtils.sol";

/**
 * @title  AssetOfferLoan
 * @author NFTfi
 * @notice Main contract for NFTfi Loans Type. This contract manages the ability to create NFT-backed
 * peer-to-peer loans of type Fixed (agreed to be a fixed-repayment loan) where the borrower pays the
 * maximumRepaymentAmount regardless of whether they repay early or not.
 *
 * There are two ways to commence an NFT-backed loan:
 *
 * a. The borrower accepts a lender's offer by calling `acceptOffer`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * behalf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the lender signs an off-chain message, proposing its offer terms.
 *   4. the borrower calls `acceptOffer` to accept these terms and enter into the loan. The NFT is stored in
 * the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender can mint an
 * NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest, or the
 * underlying NFT collateral if the borrower does not pay back in time, and the borrower can mint an obligation receipt
 * (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * The lender can freely transfer and trade this ERC721 promissory note as they wish, with the knowledge that
 * transferring the ERC721 promissory note tranfers the rights to principal-plus-interest and/or collateral, and that
 * they will no longer have a claim on the loan. The ERC721 promissory note itself represents that claim.
 *
 * The borrower can freely transfer and trade this ERC721 obligation receipt as they wish, with the knowledge that
 * transferring the ERC721 obligation receipt tranfers the rights right to pay back the loan and get the collateral
 * back.
 *
 *
 * A loan may end in one of two ways:
 * - First, a borrower may call NFTfi.payBackLoan() and pay back the loan plus interest at any time, in which case they
 * receive their NFT back in the same transaction.
 * - Second, if the loan's duration has passed and the loan has not been paid back yet, a lender can call
 * NFTfi.liquidateOverdueLoan(), in which case they receive the underlying NFT collateral and forfeit the rights to the
 * principal-plus-interest, which the borrower now keeps.
 */
contract AssetOfferLoan is LoanBaseMinimal {
    /* ************* */
    /* CUSTOM ERRORS */
    /* ************* */

    error InvalidLenderSignature();
    error NegativeInterestRate();
    error OriginationFeeIsTooHigh();

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `hub` and permitted erc20-s
     *
     * @param _admin - Initial admin of this contract.
     * @param  _nftfiHub - NFTfiHub address
     * @param  _permittedErc20s - list of permitted ERC20 token contract addresses
     */
    constructor(
        address _admin,
        address _nftfiHub,
        address[] memory _permittedErc20s
    ) LoanBaseMinimal(_admin, _nftfiHub, ContractKeyUtils.getIdFromStringKey("LOAN_COORDINATOR"), _permittedErc20s) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function is called by the borrower when accepting a lender's offer to begin a loan.
     *
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * @return The ID of the created loan.
     */
    function acceptOffer(
        Offer memory _offer,
        Signature memory _signature
    ) external virtual whenNotPaused nonReentrant returns (uint32) {
        address nftWrapper = _getWrapper(_offer.nftCollateralContract);
        _loanSanityChecks(_offer, nftWrapper);

        _loanSanityChecksOffer(_offer);
        return _acceptOffer(_setupLoanTerms(_offer, _signature.signer, nftWrapper), _offer, _signature);
    }

    /* ******************* */
    /* READ-ONLY FUNCTIONS */
    /* ******************* */

    /**
     * @notice This function can be used to view the current quantity of the ERC20 currency used in the specified loan
     * required by the borrower to repay their loan, measured in the smallest unit of the ERC20 currency. Note that
     * since interest accrues every second, once a borrower calls repayLoan(), the amount will have increased slightly.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     *
     * @return The amount of the specified ERC20 currency required to pay back this loan, measured in the smallest unit
     * of the specified ERC20 currency.
     */
    function getPayoffAmount(uint32 _loanId) external view override returns (uint256) {
        LoanTerms memory loan = loanIdToLoan[_loanId];
        uint256 loanDurationSoFarInSeconds = block.timestamp - uint256(loan.loanStartTime);
        uint256 interestDue = _computeInterestDue(
            loan.loanPrincipalAmount,
            loan.maximumRepaymentAmount,
            loanDurationSoFarInSeconds,
            uint256(loan.loanDuration),
            loan.isProRata
        );

        return (loan.loanPrincipalAmount) + interestDue;
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /**
     * @notice This function is called by the borrower when accepting a lender's offer to begin a loan.
     *
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * @return The ID of the created loan.
     */
    function _acceptOffer(
        LoanTerms memory _loanTerms,
        Offer memory _offer,
        Signature memory _signature
    ) internal virtual returns (uint32) {
        // Check loan nonces. These are different from Ethereum account nonces.
        // Here, these are uint256 numbers that should uniquely identify
        // each signature for each user (i.e. each user should only create one
        // off-chain signature for each nonce, with a nonce being any arbitrary
        // uint256 value that they have not used yet for an off-chain NFTfi
        // signature).
        ILoanCoordinator(hub.getContract(LOAN_COORDINATOR)).checkAndInvalidateNonce(
            _signature.signer,
            _signature.nonce
        );

        bytes32 offerType = _getOwnOfferType();

        if (!NFTfiSigningUtils.isValidLenderSignature(_offer, _signature, offerType)) {
            revert InvalidLenderSignature();
        }

        uint32 loanId = _createLoan(_loanTerms, msg.sender);

        // Emit an event with all relevant details from this transaction.
        emit LoanStarted(loanId, msg.sender, _signature.signer, _loanTerms);
        return loanId;
    }

    /**
     * @dev Creates a `LoanTerms` struct using data sent as the lender's `_offer` on `acceptOffer`.
     * This is needed in order to avoid stack too deep issues.
     *
     * @param _offer - The offer made by the lender.
     * @param _lender - The address of the lender.
     * @param _nftWrapper - The address of the NFT wrapper contract.
     * @return The `LoanTerms` struct.
     */
    function _setupLoanTerms(
        Offer memory _offer,
        address _lender,
        address _nftWrapper
    ) internal view returns (LoanTerms memory) {
        return
            LoanTerms({
                loanERC20Denomination: _offer.loanERC20Denomination,
                loanPrincipalAmount: _offer.loanPrincipalAmount,
                maximumRepaymentAmount: _offer.maximumRepaymentAmount,
                nftCollateralContract: _offer.nftCollateralContract,
                nftCollateralWrapper: _nftWrapper,
                nftCollateralId: _offer.nftCollateralId,
                loanStartTime: uint64(block.timestamp),
                loanDuration: _offer.loanDuration,
                loanInterestRateForDurationInBasisPoints: uint16(0),
                loanAdminFeeInBasisPoints: adminFeeInBasisPoints,
                borrower: msg.sender,
                lender: _lender,
                escrow: getEscrowAddress(msg.sender),
                isProRata: _offer.isProRata,
                originationFee: _offer.originationFee
            });
    }

    /**
     * @dev Calculates the interest rate for the loan based on principal amount and maximum repayment amount.
     *
     * @param _loanPrincipalAmount - The principal amount of the loan.
     * @param _maximumRepaymentAmount - The maximum repayment amount of the loan.
     * @return The interest rate for the duration of the loan in basis points.
     */
    function _calculateInterestRateForDurationInBasisPoints(
        uint256 _loanPrincipalAmount,
        uint256 _maximumRepaymentAmount,
        bool _isProRata
    ) internal pure returns (uint256) {
        if (!_isProRata) {
            return 0;
        } else {
            uint256 interest = _maximumRepaymentAmount - _loanPrincipalAmount;
            return (interest * HUNDRED_PERCENT) / _loanPrincipalAmount;
        }
    }

    /**
     * @dev Calculates the payoff amount and admin fee for the loan.
     *
     * @param _loan - Struct containing all the loan's parameters.
     * @return adminFee - The admin fee.
     * @return payoffAmount - The payoff amount.
     */
    function _payoffAndFee(
        LoanTerms memory _loan
    ) internal view override returns (uint256 adminFee, uint256 payoffAmount) {
        // Calculate amounts to send to lender and admins
        uint256 interestDue = _computeInterestDue(
            _loan.loanPrincipalAmount,
            _loan.maximumRepaymentAmount,
            block.timestamp - uint256(_loan.loanStartTime),
            uint256(_loan.loanDuration),
            _loan.isProRata
        );
        adminFee = LoanChecksAndCalculations.computeAdminFee(interestDue, uint256(_loan.loanAdminFeeInBasisPoints));
        payoffAmount = ((_loan.loanPrincipalAmount) + interestDue) - adminFee;
    }

    /**
     * @notice A convenience function that calculates the amount of interest currently due for a given loan. The
     * interest is capped at _maximumRepaymentAmount minus _loanPrincipalAmount.
     *
     * @param _loanPrincipalAmount - The total quantity of principal first loaned to the borrower, measured in the
     * smallest units of the ERC20 currency used for the loan.
     * @param _maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve
     * their collateral. If interestIsProRated is set to false, then the borrower will always have to pay this amount to
     * retrieve their collateral.
     * @param _loanDurationSoFarInSeconds - The elapsed time (in seconds) that has occurred so far since the loan began
     * until repayment.
     * @param _loanTotalDurationAgreedTo - The original duration that the borrower and lender agreed to, by which they
     * measured the interest that would be due.
     *
     * @return The quantity of interest due, measured in the smallest units of the ERC20 currency used to pay this loan.
     */
    function _computeInterestDue(
        uint256 _loanPrincipalAmount,
        uint256 _maximumRepaymentAmount,
        uint256 _loanDurationSoFarInSeconds,
        uint256 _loanTotalDurationAgreedTo,
        bool _isProRata
    ) internal pure returns (uint256) {
        // is it fixed?
        if (!_isProRata) {
            return _maximumRepaymentAmount - _loanPrincipalAmount;
        } else {
            uint256 interestDueAfterEntireDurationInBasisPoints = (_loanPrincipalAmount *
                _calculateInterestRateForDurationInBasisPoints(
                    _loanPrincipalAmount,
                    _maximumRepaymentAmount,
                    _isProRata
                ));
            uint256 interestDueAfterElapsedDuration = (interestDueAfterEntireDurationInBasisPoints *
                _loanDurationSoFarInSeconds) /
                _loanTotalDurationAgreedTo /
                uint256(HUNDRED_PERCENT);

            if (_loanPrincipalAmount + interestDueAfterElapsedDuration > _maximumRepaymentAmount) {
                return (_maximumRepaymentAmount - _loanPrincipalAmount);
            } else {
                return interestDueAfterElapsedDuration;
            }
        }
    }

    /**
     * @dev Performs validation checks on loan parameters when accepting an offer.
     *
     * @param _offer - The offer made by the lender.
     */
    function _loanSanityChecksOffer(LoanData.Offer memory _offer) internal pure {
        if (_offer.maximumRepaymentAmount < _offer.loanPrincipalAmount) {
            revert NegativeInterestRate();
        }

        if (_offer.originationFee >= _offer.loanPrincipalAmount) {
            revert OriginationFeeIsTooHigh();
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {ILoanCoordinator, AssetOfferLoan, NFTfiSigningUtils} from "./AssetOfferLoan.sol";
import {NFTfiCollectionOfferSigningUtils} from "../../utils/NFTfiCollectionOfferSigningUtils.sol";

/**
 * @title CollectionOfferLoan
 * @author NFTfi
 * @notice Main contract for NFTfi Loan Collection Type.
 * This contract manages the ability to create reoccurring NFT-backed
 * peer-to-peer loans of type Fixed (agreed to be a fixed-repayment loan) where the borrower pays the
 * maximumRepaymentAmount regardless of whether they repay early or not.
 * In collection offer type loans the collateral can be any one item (id) of a given NFT collection (contract).
 *
 * To commence an NFT-backed loan:
 *
 * The borrower accepts a lender's offer by calling `acceptOffer`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * behalf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the lender signs a reusable off-chain message, proposing its collection offer terms.
 *   4. the borrower calls `acceptOffer` to accept these terms and enter into the loan. The NFT is stored in
 * the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender receives an
 * NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest, or the
 * underlying NFT collateral if the borrower does not pay back in time, and the borrower receives obligation receipt
 * (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *  5. another borrower can also repeat step 4 until the original lender cancels or their
 * wallet runs out of funds with allowance to the contract
 *
 * The lender can freely transfer and trade this ERC721 promissory note as they wish, with the knowledge that
 * transferring the ERC721 promissory note transfers the rights to principal-plus-interest and/or collateral, and that
 * they will no longer have a claim on the loan. The ERC721 promissory note itself represents that claim.
 *
 * The borrower can freely transfer and trade this ERC721 obligation receipt as they wish, with the knowledge that
 * transferring the ERC721 obligation receipt transfers the rights right to pay back the loan and get the collateral
 * back.
 *
 *
 * A loan may end in one of two ways:
 * - First, a borrower may call NFTfi.payBackLoan() and pay back the loan plus interest at any time, in which case they
 * receive their NFT back in the same transaction.
 * - Second, if the loan's duration has passed and the loan has not been paid back yet, a lender can call
 * NFTfi.liquidateOverdueLoan(), in which case they receive the underlying NFT collateral and forfeit the rights to the
 * principal-plus-interest, which the borrower now keeps.
 */
contract CollectionOfferLoan is AssetOfferLoan {
    /* ************* */
    /* CUSTOM ERRORS */
    /* ************* */

    error CollateralIdNotInRange();
    error MinIdGreaterThanMaxId();
    error OriginalAcceptOfferDisabled();

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `hub` and permitted erc20-s
     *
     * @param _admin - Initial admin of this contract.
     * @param  _nftfiHub - NFTfiHub address
     * @param  _permittedErc20s - list of permitted ERC20 token contract addresses
     */
    constructor(
        address _admin,
        address _nftfiHub,
        address[] memory _permittedErc20s
    ) AssetOfferLoan(_admin, _nftfiHub, _permittedErc20s) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ******************* */
    /* READ-ONLY FUNCTIONS */
    /* ******************* */

    /**
     * @notice overriding to make it impossible to create a regular offer on this contract (only collection offers)
     */
    function acceptOffer(Offer memory, Signature memory) external override whenNotPaused nonReentrant returns (uint32) {
        revert OriginalAcceptOfferDisabled();
    }

    /**
     * @notice This function is called by the borrower when accepting a lender's collection offer to begin a loan.
     *
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * stolen or otherwise unwanted items
     */
    function acceptCollectionOffer(
        Offer memory _offer,
        Signature memory _signature
    ) external whenNotPaused nonReentrant returns (uint32) {
        address nftWrapper = _getWrapper(_offer.nftCollateralContract);
        _loanSanityChecks(_offer, nftWrapper);
        _loanSanityChecksOffer(_offer);
        return _acceptOffer(_setupLoanTerms(_offer, _signature.signer, nftWrapper), _offer, _signature);
    }

    /**
     * @notice This function is called by the borrower when accepting a lender's
     * collection offer with a given id range to begin a loan
     *
     * @param _offer - The offer made by the lender.
     * @param _idRange - min and max (inclusive) Id ranges for collection offers on collections,
     * like ArtBlocks, where multiple collections are defined on one contract differentiated by id-ranges
     * @param _signature - The components of the lender's signature.
     * stolen or otherwise unwanted items
     */
    function acceptCollectionOfferWithIdRange(
        Offer memory _offer,
        CollectionIdRange memory _idRange,
        Signature memory _signature
    ) external whenNotPaused nonReentrant returns (uint32) {
        address nftWrapper = _getWrapper(_offer.nftCollateralContract);
        _loanSanityChecks(_offer, nftWrapper);
        _loanSanityChecksOffer(_offer);
        _idRangeSanityCheck(_idRange);
        return
            _acceptOfferWithIdRange(
                _setupLoanTerms(_offer, _signature.signer, nftWrapper),
                _offer,
                _idRange,
                _signature
            );
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /**
     * @notice This function is called by the borrower when accepting a lender's offer
     * to begin a loan with the public function acceptCollectionOffer.
     *
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * stolen or otherwise unwanted items
     */
    function _acceptOffer(
        LoanTerms memory _loanTerms,
        Offer memory _offer,
        Signature memory _signature
    ) internal override returns (uint32) {
        // still checking the nonce for possible cancellations
        ILoanCoordinator(hub.getContract(LOAN_COORDINATOR)).checkNonce(_signature.signer, _signature.nonce);
        // Note that we are not invalidating the nonce as part of acceptOffer (as is the case for loan types in general)
        // since the nonce that the lender signed with remains valid for all loans for the collection offer

        Offer memory offerToCheck = _offer;

        offerToCheck.nftCollateralId = 0;

        bytes32 offerType = _getOwnOfferType();

        if (!NFTfiSigningUtils.isValidLenderSignature(offerToCheck, _signature, offerType)) {
            revert InvalidLenderSignature();
        }

        uint32 loanId = _createLoan(_loanTerms, msg.sender);

        // Emit an event with all relevant details from this transaction.
        emit LoanStarted(loanId, msg.sender, _signature.signer, _loanTerms);

        return loanId;
    }

    /**
     * @notice This function is called by the borrower when accepting a lender's
     * collection offer with a given id range to begin a loan
     *
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _idRange - min and max (inclusive) Id ranges for collection offers on collections,
     * like ArtBlocks, where multiple collections are defined on one contract differentiated by id-ranges
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * stolen or otherwise unwanted items
     */
    function _acceptOfferWithIdRange(
        LoanTerms memory _loanTerms,
        Offer memory _offer,
        CollectionIdRange memory _idRange,
        Signature memory _signature
    ) internal returns (uint32) {
        // still checking the nonce for possible cancellations
        ILoanCoordinator(hub.getContract(LOAN_COORDINATOR)).checkNonce(_signature.signer, _signature.nonce);
        // Note that we are not invalidating the nonce as part of acceptOffer (as is the case for loan types in general)
        // since the nonce that the lender signed with remains valid for all loans for the collection offer

        //check for id range
        if (_loanTerms.nftCollateralId < _idRange.minId || _loanTerms.nftCollateralId > _idRange.maxId) {
            revert CollateralIdNotInRange();
        }
        Offer memory offerToCheck = _offer;

        offerToCheck.nftCollateralId = 0;

        bytes32 offerType = _getOwnOfferType();

        if (
            !NFTfiCollectionOfferSigningUtils.isValidLenderSignatureWithIdRange(
                offerToCheck,
                _idRange,
                _signature,
                offerType
            )
        ) {
            revert InvalidLenderSignature();
        }

        uint32 loanId = _createLoan(_loanTerms, msg.sender);

        // Emit an event with all relevant details from this transaction.
        emit LoanStarted(loanId, msg.sender, _signature.signer, _loanTerms);

        return loanId;
    }

    function _idRangeSanityCheck(CollectionIdRange memory _idRange) internal pure {
        if (_idRange.minId > _idRange.maxId) {
            revert MinIdGreaterThanMaxId();
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {LoanData} from "./LoanData.sol";

interface ILoanBase {
    function maximumLoanDuration() external view returns (uint256);

    function adminFeeInBasisPoints() external view returns (uint16);

    // solhint-disable-next-line func-name-mixedcase
    function LOAN_COORDINATOR() external view returns (bytes32);

    function getLoanTerms(uint32) external view returns (LoanData.LoanTerms memory);

    function loanRepaidOrLiquidated(uint32) external view returns (bool);

    function getWhetherRenegotiationNonceHasBeenUsedForUser(address _user, uint256 _nonce) external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {ILoanBase} from "./ILoanBase.sol";
import {LoanData} from "./LoanData.sol";
import {LoanChecksAndCalculations} from "./LoanChecksAndCalculations.sol";
import {BaseLoan} from "../BaseLoan.sol";
import {NFTfiSigningUtils} from "../../utils/NFTfiSigningUtils.sol";
import {INftfiHub} from "../../interfaces/INftfiHub.sol";
import {ContractKeys} from "../../utils/ContractKeys.sol";
import {ContractKeyUtils} from "../../utils/ContractKeyUtils.sol";
import {ILoanCoordinator} from "../../interfaces/ILoanCoordinator.sol";
import {IPermittedERC20s} from "../../interfaces/IPermittedERC20s.sol";
import {IPermittedNFTs} from "../../interfaces/IPermittedNFTs.sol";
import {IEscrow} from "../../interfaces/IEscrow.sol";
import {IERC20TransferManager} from "../../interfaces/IERC20TransferManager.sol";
import {IPersonalEscrow} from "../../interfaces/IPersonalEscrow.sol";
import {PersonalEscrowFactory} from "../../escrow/PersonalEscrowFactory.sol";
import {INftWrapper} from "../../interfaces/INftWrapper.sol";
import {IDelegateCashPlugin} from "../../interfaces/IDelegateCashPlugin.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title  LoanBaseMinimal
 * @author NFTfi
 * @notice Main contract for NFTfi Loan Type. This contract manages the ability to create NFT-backed
 * peer-to-peer loans.
 *
 * There are two ways to commence an NFT-backed loan:
 *
 * a. The borrower accepts a lender's offer by calling `acceptOffer`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * be1alf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the lender signs an off-chain message, proposing its offer terms.
 *   4. the borrower calls `acceptOffer` to accept these terms and enter into the loan. The NFT is stored in
 * the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender can mint an
 * NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest, or the
 * underlying NFT collateral if the borrower does not pay back in time, and the borrower can mint obligation receipt
 * (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * The lender can freely transfer and trade this ERC721 promissory note as they wish, with the knowledge that
 * transferring the ERC721 promissory note tranfers the rights to principal-plus-interest and/or collateral, and that
 * they will no longer have a claim on the loan. The ERC721 promissory note itself represents that claim.
 *
 * The borrower can freely transfer and trade this ERC721 obligation receipt as they wish, with the knowledge that
 * transferring the ERC721 obligation receipt tranfers the rights right to pay back the loan and get the collateral
 * back.
 *
 * A loan may end in one of two ways:
 * - First, a borrower may call NFTfi.payBackLoan() and pay back the loan plus interest at any time, in which case they
 * receive their NFT back in the same transaction.
 * - Second, if the loan's duration has passed and the loan has not been paid back yet, a lender can call
 * NFTfi.liquidateOverdueLoan(), in which case they receive the underlying NFT collateral and forfeit the rights to the
 * principal-plus-interest, which the borrower now keeps.
 *
 *
 * If the loan was created as a ProRated type loan (pro-rata interest loan), then the user only pays the principal plus
 * pro-rata interest if repaid early.
 * However, if the loan was was created as a Fixed type loan (agreed to be a fixed-repayment loan), then the borrower
 * pays the maximumRepaymentAmount regardless of whether they repay early or not.
 *
 */
abstract contract LoanBaseMinimal is ILoanBase, IPermittedERC20s, BaseLoan, LoanData {
    using SafeERC20 for IERC20;

    /* ******* */
    /* STORAGE */
    /* ******* */

    uint16 public constant HUNDRED_PERCENT = 10000;

    // solhint-disable-next-line immutable-vars-naming
    bytes32 public immutable override LOAN_COORDINATOR;

    /**
     * @notice The maximum duration of any loan started for this loan type, measured in seconds. This is both a
     * sanity-check for borrowers and an upper limit on how long admins will have to support v1 of this contract if they
     * eventually deprecate it, as well as a check to ensure that the loan duration never exceeds the space alotted for
     * it in the loan struct.
     */
    uint256 public override maximumLoanDuration = 365 days * 4;

    /**
     * @notice The percentage of interest earned by lenders on this platform that is taken by the contract admin's as a
     * fee, measured in basis points (hundredths of a percent). The max allowed value is 10000.
     */
    uint16 public override adminFeeInBasisPoints = 500;

    /**
     * @notice A mapping from a loan's identifier to the loan's details, represted by the loan struct.
     */
    mapping(uint32 => LoanTerms) internal loanIdToLoan;

    /**
     * @notice A mapping tracking whether a loan has either been repaid or liquidated. This prevents an attacker trying
     * to repay or liquidate the same loan twice.
     */
    mapping(uint32 => bool) public override loanRepaidOrLiquidated;

    /**
     * @notice A mapping that takes both a user's address and a loan nonce that was first used when signing an off-chain
     * order and checks whether that nonce has previously either been used for a loan, or has been pre-emptively
     * cancelled. The nonce referred to here is not the same as an Ethereum account's nonce. We are referring instead to
     * nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi orders.
     *
     * These nonces can be any uint256 value that the user has not previously used to sign an off-chain order. Each
     * nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the borrower
     * in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would submit a
     * user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     */
    mapping(address => mapping(uint256 => bool)) internal _renegotiationNonceHasBeenUsedForUser;

    /**
     * @notice A mapping from an ERC20 currency address to whether that currency
     * is permitted to be used by this contract.
     */
    mapping(address => bool) private erc20Permits;

    // solhint-disable-next-line immutable-vars-naming
    INftfiHub public immutable hub;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admins change the percent of interest rates earned that they charge as a
     * fee. Note that newAdminFee can never exceed 10,000, since the fee is measured in basis points.
     *
     * @param  newAdminFee - The new admin fee measured in basis points. This is a percent of the interest paid upon a
     * loan's completion that go to the contract admins.
     */
    event AdminFeeUpdated(uint16 newAdminFee);

    /**
     * @notice This event is fired whenever the admins change the maximum duration of any loan started for this loan
     * type.
     *
     * @param  newMaximumLoanDuration - The new maximum duration.
     */
    event MaximumLoanDurationUpdated(uint256 newMaximumLoanDuration);

    event LoanCreated(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address indexed recipient,
        uint256 loanId
    );

    /**
     * @notice This event is fired whenever a borrower begins a loan by calling NFTfi.beginLoan(), which can only occur
     * after both the lender and borrower have approved their ERC721 and ERC20 contracts to use NFTfi, and when they
     * both have signed off-chain messages that agree on the terms of the loan.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     */
    event LoanStarted(uint32 indexed loanId, address indexed borrower, address indexed lender, LoanTerms loanTerms);

    /**
     * @notice This event is fired whenever a borrower successfully repays their loan, paying
     * principal-plus-interest-minus-fee to the lender in loanERC20Denomination, paying fee to owner in
     * loanERC20Denomination, and receiving their NFT collateral back.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     * @param  loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param  nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param  amountPaidToLender The amount of ERC20 that the borrower paid to the lender, measured in the smalled
     * units of loanERC20Denomination.
     * @param  adminFee The amount of interest paid to the contract admins, measured in the smalled units of
     * loanERC20Denomination and determined by adminFeeInBasisPoints. This amount never exceeds the amount of interest
     * earned.
     * @param  nftCollateralContract - The ERC721 contract of the NFT collateral
     * @param  loanERC20Denomination - The ERC20 contract of the currency being used as principal/interest for this
     * loan.
     */
    event LoanRepaid(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 amountPaidToLender,
        uint256 adminFee,
        address nftCollateralContract,
        address loanERC20Denomination
    );

    /**
     * @notice This event is fired whenever a lender liquidates an outstanding loan that is owned to them that has
     * exceeded its duration. The lender receives the underlying NFT collateral, and the borrower no longer needs to
     * repay the loan principal-plus-interest.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     * @param  loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param  nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param  loanMaturityDate - The unix time (measured in seconds) that the loan became due and was eligible for
     * liquidation.
     * @param  loanLiquidationDate - The unix time (measured in seconds) that liquidation occurred.
     * @param  nftCollateralContract - The ERC721 contract of the NFT collateral
     */
    event LoanLiquidated(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 loanMaturityDate,
        uint256 loanLiquidationDate,
        address nftCollateralContract
    );

    /**
     * @notice This event is fired when some of the terms of a loan are being renegotiated.
     *
     * @param loanId - The unique identifier for the loan to be renegotiated
     * @param newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param renegotiationFee Agreed upon fee in loan denomination that borrower pays for the lender for the
     * renegotiation, has to be paid with an ERC20 transfer loanERC20Denomination token, uses transfer from,
     * frontend will have to prompt an erc20 approve for this from the borrower to the lender
     * @param renegotiationAdminFee renegotiationFee admin portion based on determined by adminFeeInBasisPoints
     * @param isProRata - indicates if a renegotiated loan is pro-rata or fixed
     */
    event LoanRenegotiated(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint32 newLoanDuration,
        uint256 newMaximumRepaymentAmount,
        uint256 renegotiationFee,
        uint256 renegotiationAdminFee,
        bool isProRata
    );

    /**
     * @notice This event is fired whenever the admin sets a ERC20 permit.
     *
     * @param erc20Contract - Address of the ERC20 contract.
     * @param isPermitted - Signals ERC20 permit.
     */
    event ERC20Permit(address indexed erc20Contract, bool isPermitted);

    /* ************* */
    /* CUSTOM ERRORS */
    /* ************* */

    error LoanDurationOverflow();
    error BasisPointsTooHigh();
    error NoTokensOwned();
    error FunctionInformationArityMismatch();
    error TokenIsCollateral();
    error SenderNotBorrower();
    error SenderNotLender();
    error NoTokensInEscrow();
    error LoanAlreadyRepaidOrLiquidated();
    error LoanNotOverdueYet();
    error OnlyLenderCanLiquidate();
    error InvalidNonce();
    error RenegotiationSignatureInvalid();
    error ERC20ZeroAddress();
    error CurrencyDenominationNotPermitted();
    error NFTCollateralContractNotPermitted();
    error LoanDurationExceedsMaximum();
    error LoanDurationCannotBeZero();
    error ZeroPrincipal();
    error DelegationExists();

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `hub`
     *
     * @param _admin - Initial admin of this contract.
     * @param  _nftfiHub - NFTfiHub address
     * @param  _loanCoordinatorKey -
     * @param  _permittedErc20s -
     */
    constructor(
        address _admin,
        address _nftfiHub,
        bytes32 _loanCoordinatorKey,
        address[] memory _permittedErc20s
    ) BaseLoan(_admin) {
        hub = INftfiHub(_nftfiHub);
        LOAN_COORDINATOR = _loanCoordinatorKey;
        for (uint256 i; i < _permittedErc20s.length; ++i) {
            _setERC20Permit(_permittedErc20s[i], true);
        }
    }

    /* *************** */
    /* ADMIN FUNCTIONS */
    /* *************** */

    /**
     * @notice This function can be called by admins to change the maximumLoanDuration. Note that they can never change
     * maximumLoanDuration to be greater than UINT32_MAX, since that's the maximum space alotted for the duration in the
     * loan struct.
     *
     * @param _newMaximumLoanDuration - The new maximum loan duration, measured in seconds.
     */
    function updateMaximumLoanDuration(uint256 _newMaximumLoanDuration) external onlyOwner {
        if (_newMaximumLoanDuration > uint256(type(uint32).max)) {
            revert LoanDurationOverflow();
        }
        maximumLoanDuration = _newMaximumLoanDuration;
        emit MaximumLoanDurationUpdated(_newMaximumLoanDuration);
    }

    /**
     * @notice This function can be called by admins to change the percent of interest rates earned that they charge as
     * a fee. Note that newAdminFee can never exceed 10,000, since the fee is measured in basis points.
     *
     * @param _newAdminFeeInBasisPoints - The new admin fee measured in basis points. This is a percent of the interest
     * paid upon a loan's completion that go to the contract admins.
     */
    function updateAdminFee(uint16 _newAdminFeeInBasisPoints) external onlyOwner {
        if (_newAdminFeeInBasisPoints > HUNDRED_PERCENT) {
            revert BasisPointsTooHigh();
        }
        adminFeeInBasisPoints = _newAdminFeeInBasisPoints;
        emit AdminFeeUpdated(_newAdminFeeInBasisPoints);
    }

    /**
     * @notice used by the owner account to be able to drain stuck NFTs
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _tokenId - id token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainNFT(
        string memory _nftType,
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver
    ) external onlyOwner {
        bytes32 nftTypeKey = ContractKeyUtils.getIdFromStringKey(_nftType);
        address transferWrapper = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNftTypeWrapper(
            nftTypeKey
        );
        _transferNFT(transferWrapper, _tokenAddress, _tokenId, address(this), _receiver);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function setERC20Permit(address _erc20, bool _permit) external onlyOwner {
        _setERC20Permit(_erc20, _permit);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of a batch of ERC20 currency. This
     * includes both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20s - The addresses of the ERC20 currencies whose permit list status changed.
     * @param _permits - The new statuses of whether the currency is permitted or not.
     */
    function setERC20Permits(address[] memory _erc20s, bool[] memory _permits) external onlyOwner {
        if (_erc20s.length != _permits.length) {
            revert FunctionInformationArityMismatch();
        }
        for (uint256 i = 0; i < _erc20s.length; ++i) {
            _setERC20Permit(_erc20s[i], _permits[i]);
        }
    }

    /**
     * @notice Mints the obligation receipt for the borrower
     *
     * @param _loanId - The unique identifier for the loan.
     */
    function mintObligationReceipt(uint32 _loanId) external nonReentrant {
        LoanTerms memory loan = loanIdToLoan[_loanId];
        address borrower = loan.borrower;
        if (msg.sender != borrower) {
            revert SenderNotBorrower();
        }

        _checkDelegationAndUndelegate(_loanId);
        // check if colateral is in personal escrow, if yes, we need to move it to global,
        // because obligation receipt can change borrower and personal escrow is tied to one borrower
        if (
            PersonalEscrowFactory(hub.getContract(ContractKeys.PERSONAL_ESCROW_FACTORY)).isPersonalEscrow(loan.escrow)
        ) {
            _moveCollateralToGlobalEscrow(_loanId, loan);
        }

        ILoanCoordinator loanCoordinator = ILoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        loanCoordinator.mintObligationReceipt(_loanId, borrower);

        delete loanIdToLoan[_loanId].borrower;
    }

    /**
     * @notice Internal function to move collateral of the loan from personal tok global escrow,
     * will only work if loan collateral is in personal escrow
     *
     * @param _loanId - The unique identifier for the loan.
     * @param _loan loan terms
     */
    function _moveCollateralToGlobalEscrow(uint32 _loanId, LoanTerms memory _loan) internal {
        address globalEscrow = hub.getContract(ContractKeys.ESCROW);
        IPersonalEscrow(_loan.escrow).handOverCollateralToEscrow(
            _loan.nftCollateralWrapper,
            _loan.nftCollateralContract,
            _loan.nftCollateralId,
            globalEscrow
        );
        IEscrow(globalEscrow).lockCollateral(
            _loan.nftCollateralWrapper,
            _loan.nftCollateralContract,
            _loan.nftCollateralId,
            _loan.escrow
        );
        loanIdToLoan[_loanId].escrow = globalEscrow;
    }

    /**
     * @notice Mints the promissory note for the lender
     *
     * @param _loanId - The unique identifier for the loan.
     */
    function mintPromissoryNote(uint32 _loanId) external nonReentrant {
        address lender = loanIdToLoan[_loanId].lender;
        if (msg.sender != lender) {
            revert SenderNotLender();
        }
        ILoanCoordinator loanCoordinator = ILoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        loanCoordinator.mintPromissoryNote(_loanId, lender);

        delete loanIdToLoan[_loanId].lender;
    }

    /**
     * @dev makes possible to change loan duration and max repayment amount, loan duration even can be extended if
     * loan was expired but not liquidated.
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in ether that borrower pays for the lender for the renegitiation
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param _expiry - The date when the renegotiation offer expires
     * @param _isProRata - indicates if a renegotiated loan is pro-rata or fixed
     * @param _lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _isProRata
     * - _newMaximumRepaymentAmount
     * - _renegotiationFee
     * - _lender
     * - _nonce
     * - _expiry
     * - address of this contract
     * - chainId
     */
    function renegotiateLoan(
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        uint256 _lenderNonce,
        uint256 _expiry,
        bool _isProRata,
        bytes memory _lenderSignature
    ) external whenNotPaused nonReentrant {
        _renegotiateLoan(
            _loanId,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _renegotiationFee,
            _lenderNonce,
            _expiry,
            _isProRata,
            _lenderSignature
        );
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function payBackLoan(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.payBackChecks(_loanId, hub);
        (
            address borrower,
            address lender,
            LoanTerms memory loan,
            ILoanCoordinator loanCoordinator
        ) = _getPartiesAndData(_loanId);

        _payBackLoan(_loanId, borrower, lender, loan);

        bool repaid = true;
        _resolveLoanState(_loanId, loanCoordinator, repaid);
        _resolveLoanCollateralPayback(borrower, loan);
        _checkDelegationAndUndelegate(_loanId);
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function payBackLoanSafe(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.payBackChecks(_loanId, hub);
        (
            address borrower,
            address lender,
            LoanTerms memory loan,
            ILoanCoordinator loanCoordinator
        ) = _getPartiesAndData(_loanId);

        _payBackLoanSafe(_loanId, borrower, lender, loan);

        bool repaid = true;
        _resolveLoanState(_loanId, loanCoordinator, repaid);
        _resolveLoanCollateralPayback(borrower, loan);
        _checkDelegationAndUndelegate(_loanId);
    }

    /**
     * @notice This function is called by a lender once a loan has finished its duration and the borrower still has not
     * repaid. The lender can call this function to seize the underlying NFT collateral, although the lender gives up
     * all rights to the principal-plus-collateral by doing so.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause
     * the contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function liquidateOverdueLoan(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.checkLoanIdValidity(_loanId, hub);
        // Sanity check that payBackLoan() and liquidateOverdueLoan() have never been called on this loanId.
        // Depending on how the rest of the code turns out, this check may be unnecessary.
        if (loanRepaidOrLiquidated[_loanId]) {
            revert LoanAlreadyRepaidOrLiquidated();
        }

        (
            address borrower,
            address lender,
            LoanTerms memory loan,
            ILoanCoordinator loanCoordinator
        ) = _getPartiesAndData(_loanId);

        // Ensure that the loan is indeed overdue, since we can only liquidate overdue loans.
        uint256 loanMaturityDate = uint256(loan.loanStartTime) + uint256(loan.loanDuration);
        if (block.timestamp <= loanMaturityDate) {
            revert LoanNotOverdueYet();
        }
        if (msg.sender != lender) {
            revert OnlyLenderCanLiquidate();
        }

        bool repaid = false;
        _resolveLoanState(_loanId, loanCoordinator, repaid);
        _resolveLoanCollateralLiquidate(lender, loan);
        _checkDelegationAndUndelegate(_loanId);

        // Emit an event with all relevant details from this transaction.
        emit LoanLiquidated(
            _loanId,
            borrower,
            lender,
            loan.loanPrincipalAmount,
            loan.nftCollateralId,
            loanMaturityDate,
            block.timestamp,
            loan.nftCollateralContract
        );
    }

    /**
     * @notice This function can be called by either a lender or a borrower to cancel all off-chain orders that they
     * have signed that contain this nonce. If the off-chain orders were created correctly, there should only be one
     * off-chain order that contains this nonce at all.
     *
     * The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi
     * orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain order.
     * Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the
     * borrower in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would
     * submit a user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     *
     * @param  _nonce - User nonce
     */
    function cancelRefinancingCommitment(uint256 _nonce) external {
        if (_renegotiationNonceHasBeenUsedForUser[msg.sender][_nonce]) {
            revert InvalidNonce();
        }
        _renegotiationNonceHasBeenUsedForUser[msg.sender][_nonce] = true;
    }

    /* ******************* */
    /* READ-ONLY FUNCTIONS */
    /* ******************* */

    function getLoanTerms(uint32 _loanId) public view override returns (LoanTerms memory) {
        LoanTerms memory loan = loanIdToLoan[_loanId];
        return loan;
    }

    /**
     * @notice This function can be used to view the current quantity of the ERC20 currency used in the specified loan
     * required by the borrower to repay their loan, measured in the smallest unit of the ERC20 currency.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     *
     * @return The amount of the specified ERC20 currency required to pay back this loan, measured in the smallest unit
     * of the specified ERC20 currency.
     */
    function getPayoffAmount(uint32 _loanId) external view virtual returns (uint256);

    /**
     * @notice This function can be used to view whether a particular nonce for a particular user has already been used,
     * either from a successful loan or a cancelled off-chain order.
     *
     * @param _user - The address of the user. This function works for both lenders and borrowers alike.
     * @param  _nonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain
     * NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain
     * order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or
     * the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     *
     * @return A bool representing whether or not this nonce has been used for this user.
     */
    function getWhetherRenegotiationNonceHasBeenUsedForUser(
        address _user,
        uint256 _nonce
    ) external view override returns (bool) {
        return _renegotiationNonceHasBeenUsedForUser[_user][_nonce];
    }

    /**
     * @notice This function can be called by anyone to get the permit associated with the erc20 contract.
     *
     * @param _erc20 - The address of the erc20 contract.
     *
     * @return Returns whether the erc20 is permitted
     */
    function getERC20Permit(address _erc20) public view override returns (bool) {
        return erc20Permits[_erc20];
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /**
     * @dev makes possible to change loan duration and max repayment amount, loan duration even can be extended if
     * loan was expired but not liquidated. IMPORTANT: Frontend will have to propt the caller to do an ERC20 approve for
     * the fee amount from themselves (borrower/obligation reciept holder) to the lender (promissory note holder)
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in loan denomination that borrower pays for the lender and
     * the admin for the renegotiation, has to be paid with an ERC20 transfer loanERC20Denomination token,
     * uses transfer from, frontend will have to prompt an erc20 approve for this from the borrower to the lender,
     * admin fee is calculated by the loan's loanAdminFeeInBasisPoints value
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param _expiry - The date when the renegotiation offer expires
     * @param _lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _isProRata
     * - _newMaximumRepaymentAmount
     * - _renegotiationFee
     * - _lender
     * - _nonce
     * - _expiry
     * - address of this contract
     * - chainId
     */
    function _renegotiateLoan(
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        uint256 _lenderNonce,
        uint256 _expiry,
        bool _isProRata,
        bytes memory _lenderSignature
    ) internal {
        LoanTerms storage loan = loanIdToLoan[_loanId];

        (address borrower, address lender) = LoanChecksAndCalculations.renegotiationChecks(
            loan,
            _loanId,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _lenderNonce,
            hub
        );

        //invalidation after check inside previous call
        _renegotiationNonceHasBeenUsedForUser[lender][_lenderNonce] = true;

        if (
            !NFTfiSigningUtils.isValidLenderRenegotiationSignature(
                _loanId,
                _newLoanDuration,
                _isProRata,
                _newMaximumRepaymentAmount,
                _renegotiationFee,
                Signature({signer: lender, nonce: _lenderNonce, expiry: _expiry, signature: _lenderSignature})
            )
        ) {
            revert RenegotiationSignatureInvalid();
        }

        uint256 renegotiationAdminFee;
        /**
         * @notice Transfers fee to the lender immediately
         * @dev implements Checks-Effects-Interactions pattern by modifying state only after
         * the transfer happened successfully, we also add the nonReentrant modifier to
         * the pbulic versions
         */
        if (_renegotiationFee > 0) {
            renegotiationAdminFee = LoanChecksAndCalculations.computeAdminFee(
                _renegotiationFee,
                loan.loanAdminFeeInBasisPoints
            );
            // Transfer principal-plus-interest-minus-fees from the caller (always has to be borrower) to lender

            IERC20TransferManager erc20TransferManager = IERC20TransferManager(
                hub.getContract(ContractKeys.ERC20_TRANSFER_MANAGER)
            );

            erc20TransferManager.transfer(
                loan.loanERC20Denomination,
                borrower,
                lender,
                _renegotiationFee - renegotiationAdminFee
            );
            // Transfer fees from the caller (always has to be borrower) to admins
            erc20TransferManager.transfer(loan.loanERC20Denomination, borrower, owner(), renegotiationAdminFee);
        }

        loan.loanDuration = _newLoanDuration;
        loan.maximumRepaymentAmount = _newMaximumRepaymentAmount;
        loan.isProRata = _isProRata;

        // we have to reinstate borrower record here, because obligation receipt gets deleted in reMint
        if (loan.borrower == address(0) || loan.lender == address(0)) {
            ILoanCoordinator(hub.getContract(LOAN_COORDINATOR)).resetSmartNfts(_loanId);

            if (loan.borrower == address(0)) {
                loan.borrower = borrower;
            }
            if (loan.lender == address(0)) {
                loan.lender = lender;
            }
        }

        emit LoanRenegotiated(
            _loanId,
            borrower,
            lender,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _renegotiationFee,
            renegotiationAdminFee,
            _isProRata
        );
    }

    function getEscrowAddress(address _borrower) public view returns (address) {
        address personalEscrow = PersonalEscrowFactory(hub.getContract(ContractKeys.PERSONAL_ESCROW_FACTORY))
            .personalEscrowOfOwner(_borrower);
        if (personalEscrow != address(0)) {
            return personalEscrow;
        } else {
            return hub.getContract(ContractKeys.ESCROW);
        }
    }

    /**
     * @dev Transfer collateral NFT from borrower to this contract and principal from lender to the borrower and
     * registers the new loan through the loan coordinator.
     *
     * @param _loanTerms - Struct containing the loan's settings
     */
    function _createLoan(LoanTerms memory _loanTerms, address _borrower) internal returns (uint32) {
        IEscrow(_loanTerms.escrow).lockCollateral(
            _loanTerms.nftCollateralWrapper,
            _loanTerms.nftCollateralContract,
            _loanTerms.nftCollateralId,
            _borrower
        );

        uint32 loanId = _createLoanNoNftTransfer(_loanTerms, _borrower);

        return loanId;
    }

    /**
     * @dev Transfer principal from lender to the borrower and
     * registers the new loan through the loan coordinator.
     *
     * @param _loanTerms - Struct containing the loan's settings
     */
    function _createLoanNoNftTransfer(LoanTerms memory _loanTerms, address _borrower) internal returns (uint32 loanId) {
        // Issue an ERC721 promissory note to the lender that gives them the
        // right to either the principal-plus-interest or the collateral,
        // and an obligation note to the borrower that gives them the
        // right to pay back the loan and get the collateral back.
        ILoanCoordinator loanCoordinator = ILoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        loanId = loanCoordinator.registerLoan();

        // Add the loan to storage before moving collateral/principal to follow
        // the Checks-Effects-Interactions pattern.
        loanIdToLoan[loanId] = _loanTerms;

        // Transfer principal from lender to borrower leaving origination fee.
        IERC20TransferManager(hub.getContract(ContractKeys.ERC20_TRANSFER_MANAGER)).transfer(
            _loanTerms.loanERC20Denomination,
            _loanTerms.lender,
            _borrower,
            _loanTerms.loanPrincipalAmount - _loanTerms.originationFee
        );

        emit LoanCreated(_loanTerms.nftCollateralContract, _loanTerms.nftCollateralId, _borrower, loanId);

        return loanId;
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function _payBackLoan(uint32 _loanId, address _borrower, address _lender, LoanTerms memory _loan) internal {
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.

        (uint256 adminFee, uint256 payoffAmount) = _payoffAndFee(_loan);

        IERC20TransferManager erc20TransferManager = IERC20TransferManager(
            hub.getContract(ContractKeys.ERC20_TRANSFER_MANAGER)
        );

        // Transfer principal-plus-interest-minus-fees from the caller to lender
        erc20TransferManager.transfer(_loan.loanERC20Denomination, msg.sender, _lender, payoffAmount);
        // Transfer fees from the caller to admins
        erc20TransferManager.transfer(_loan.loanERC20Denomination, msg.sender, owner(), adminFee);

        // Emit an event with all relevant details from this transaction.
        emit LoanRepaid(
            _loanId,
            _borrower,
            _lender,
            _loan.loanPrincipalAmount,
            _loan.nftCollateralId,
            payoffAmount,
            adminFee,
            _loan.nftCollateralContract,
            _loan.loanERC20Denomination
        );
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function _payBackLoanSafe(uint32 _loanId, address _borrower, address _lender, LoanTerms memory _loan) internal {
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.

        (uint256 adminFee, uint256 payoffAmount) = _payoffAndFee(_loan);

        IERC20TransferManager erc20TransferManager = IERC20TransferManager(
            hub.getContract(ContractKeys.ERC20_TRANSFER_MANAGER)
        );

        // Transfer principal-plus-interest-minus-fees from the caller to lender
        erc20TransferManager.safeLoanPaybackTransfer(_loan.loanERC20Denomination, msg.sender, _lender, payoffAmount);
        // Transfer fees from the caller to admins
        erc20TransferManager.safeAdminFeeTransfer(_loan.loanERC20Denomination, msg.sender, owner(), adminFee);

        // Emit an event with all relevant details from this transaction.
        emit LoanRepaid(
            _loanId,
            _borrower,
            _lender,
            _loan.loanPrincipalAmount,
            _loan.nftCollateralId,
            payoffAmount,
            adminFee,
            _loan.nftCollateralContract,
            _loan.loanERC20Denomination
        );
    }

    /**
     * @dev Transfers several types of NFTs using a wrapper that knows how to handle each case.
     *
     * @param _sender - Current owner of the NFT
     * @param _recipient - Recipient of the transfer
     */
    function _transferNFT(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _sender,
        address _recipient
    ) internal {
        Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "NFT not successfully transferred"
        );
    }

    function _isOwner(
        address _nftCollateralWrapper,
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _owner
    ) internal returns (bool) {
        bytes memory result = Address.functionDelegateCall(
            _nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_nftCollateralWrapper).isOwner.selector,
                _owner,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "Ownership check failed"
        );
        return abi.decode(result, (bool));
    }

    /**
     * @notice A convenience function with shared functionality between `payBackLoan` and `liquidateOverdueLoan`.
     *
     * @param _borrower - The receiver of the collateral nft. The borrower when `payBackLoan` or the lender when
     * `liquidateOverdueLoan`.
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     */
    function _resolveLoanCollateralPayback(address _borrower, LoanTerms memory _loanTerms) internal {
        address collateralContract = _loanTerms.nftCollateralContract;
        uint256 collateralId = _loanTerms.nftCollateralId;

        address escrow = _loanTerms.escrow;
        if (PersonalEscrowFactory(hub.getContract(ContractKeys.PERSONAL_ESCROW_FACTORY)).isPersonalEscrow(escrow)) {
            // borrower has a personal escrow, and the collateral is in it
            IPersonalEscrow(escrow).unlockAndKeepCollateral(collateralContract, collateralId);
        } else {
            IEscrow(escrow).unlockCollateral(
                _loanTerms.nftCollateralWrapper,
                collateralContract,
                collateralId,
                _borrower
            );
        }

        // invariant check here if collateral landed where it should have
    }

    /**
     * @notice A convenience function with shared functionality between `payBackLoan` and `liquidateOverdueLoan`.
     *
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     */
    function _resolveLoanCollateralLiquidate(address _lender, LoanTerms memory _loanTerms) internal {
        // Transfer collateral from this contract to the lender, since the lender is seizing collateral for an overdue
        // loan
        address collateralContract = _loanTerms.nftCollateralContract;
        uint256 collateralId = _loanTerms.nftCollateralId;
        IEscrow(_loanTerms.escrow).unlockCollateral(
            _loanTerms.nftCollateralWrapper,
            collateralContract,
            collateralId,
            _lender
        );
    }

    function _checkDelegationAndUndelegate(uint32 _loanId) internal {
        IDelegateCashPlugin delegateCashPlugin = IDelegateCashPlugin(hub.getContract(ContractKeys.DELEGATE_PLUGIN));
        if (delegateCashPlugin.isCollateralDelegated(_loanId)) {
            delegateCashPlugin.undelegateERC721(_loanId);
        }
    }

    /**
     * @notice Resolving the loan without transferring the nft to provide a base for the bundle
     * break up of the bundled loans
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param _loanCoordinator - The loan coordinator used when creating the loan.
     */
    function _resolveLoanState(uint32 _loanId, ILoanCoordinator _loanCoordinator, bool _repaid) internal {
        // Mark loan as liquidated before doing any external transfers to follow the Checks-Effects-Interactions design
        // pattern
        loanRepaidOrLiquidated[_loanId] = true;

        // Destroy the lender's promissory note for this loan and borrower obligation receipt
        _loanCoordinator.resolveLoan(_loanId, _repaid);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function _setERC20Permit(address _erc20, bool _permit) internal {
        if (_erc20 == address(0)) {
            revert ERC20ZeroAddress();
        }
        erc20Permits[_erc20] = _permit;

        emit ERC20Permit(_erc20, _permit);
    }

    /**
     * @dev Performs some validation checks over loan parameters
     *
     */
    function _loanSanityChecks(LoanData.Offer memory _offer, address _nftWrapper) internal view {
        if (!getERC20Permit(_offer.loanERC20Denomination)) {
            revert CurrencyDenominationNotPermitted();
        }
        if (_nftWrapper == address(0)) {
            revert NFTCollateralContractNotPermitted();
        }
        if (uint256(_offer.loanDuration) > maximumLoanDuration) {
            revert LoanDurationExceedsMaximum();
        }
        if (uint256(_offer.loanDuration) == 0) {
            revert LoanDurationCannotBeZero();
        }
        if (_offer.loanPrincipalAmount == 0) {
            revert ZeroPrincipal();
        }
    }

    /**
     * @dev reads some variable values of a loan for payback functions, created to reduce code repetition
     */
    function _getPartiesAndData(
        uint32 _loanId
    )
        internal
        view
        returns (address borrower, address lender, LoanTerms memory loan, ILoanCoordinator loanCoordinator)
    {
        loanCoordinator = ILoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        ILoanCoordinator.Loan memory loanCoordinatorData = loanCoordinator.getLoanData(_loanId);
        uint256 smartNftId = loanCoordinatorData.smartNftId;
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.
        loan = loanIdToLoan[_loanId];
        if (loan.borrower != address(0)) {
            borrower = loan.borrower;
        } else {
            // Fetch current owner of loan obligation note.
            borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
        }

        if (loan.lender != address(0)) {
            lender = loan.lender;
        } else {
            // Fetch current owner of loan promissory note.
            lender = IERC721(loanCoordinator.promissoryNoteToken()).ownerOf(smartNftId);
        }
    }

    /**
     * @dev Calculates the payoff amount and admin fee
     */
    function _payoffAndFee(LoanTerms memory _loanTerms) internal view virtual returns (uint256, uint256);

    /**
     * @dev Checks that the collateral is a supported contracts and returns what wrapper to use for the loan's NFT
     * collateral contract.
     *
     * @param _nftCollateralContract - The address of the the NFT collateral contract.
     *
     * @return Address of the NftWrapper to use for the loan's NFT collateral.
     */
    function _getWrapper(address _nftCollateralContract) internal view returns (address) {
        return IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNFTWrapper(_nftCollateralContract);
    }

    function _getOwnOfferType() internal view returns (bytes32) {
        return ILoanCoordinator(hub.getContract(LOAN_COORDINATOR)).getTypeOfLoanContract(address(this));
    }

    function getERC20TransferManagerAddress() public view returns (address) {
        return hub.getContract(ContractKeys.ERC20_TRANSFER_MANAGER);
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {ILoanBase} from "./ILoanBase.sol";
import {LoanData} from "./LoanData.sol";
import {ILoanCoordinator} from "../../interfaces/ILoanCoordinator.sol";
import {INftfiHub} from "../../interfaces/INftfiHub.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title  LoanChecksAndCalculations
 * @author NFTfi
 * @notice Helper library for LoanBase
 */
library LoanChecksAndCalculations {
    uint16 private constant HUNDRED_PERCENT = 10000;

    /**
     * @dev Function that performs some validation checks before trying to repay a loan
     *
     * @param _loanId - The id of the loan being repaid
     */
    function payBackChecks(uint32 _loanId, INftfiHub _hub) external view {
        checkLoanIdValidity(_loanId, _hub);
        // Sanity check that payBackLoan() and liquidateOverdueLoan() have never been called on this loanId.
        // Depending on how the rest of the code turns out, this check may be unnecessary.
        // solhint-disable-next-line custom-errors
        require(!ILoanBase(address(this)).loanRepaidOrLiquidated(_loanId), "Loan already repaid/liquidated");
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.

        LoanData.LoanTerms memory lt = ILoanBase(address(this)).getLoanTerms(_loanId);
        // When a loan exceeds the loan term, it is expired. At this stage the Lender can call Liquidate Loan to resolve
        // the loan.
        // solhint-disable-next-line custom-errors
        require(block.timestamp <= (uint256(lt.loanStartTime) + uint256(lt.loanDuration)), "Loan is expired");
    }

    function checkLoanIdValidity(uint32 _loanId, INftfiHub _hub) public view {
        // solhint-disable-next-line custom-errors
        require(
            ILoanCoordinator(_hub.getContract(ILoanBase(address(this)).LOAN_COORDINATOR())).isValidLoanId(
                _loanId,
                address(this)
            ),
            "invalid loanId"
        );
    }

    /**
     * @dev Performs some validation checks before trying to renegotiate a loan.
     * Needed to avoid stack too deep.
     *
     * @param _loan - The main Loan Terms struct.
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @return Borrower and Lender addresses
     */
    function renegotiationChecks(
        LoanData.LoanTerms memory _loan,
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _lenderNonce,
        INftfiHub _hub
    ) external view returns (address, address) {
        checkLoanIdValidity(_loanId, _hub);
        ILoanCoordinator loanCoordinator = ILoanCoordinator(
            _hub.getContract(ILoanBase(address(this)).LOAN_COORDINATOR())
        );
        uint256 smartNftId = loanCoordinator.getLoanData(_loanId).smartNftId;

        address borrower;

        if (_loan.borrower != address(0)) {
            borrower = _loan.borrower;
        } else {
            borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
        }

        // solhint-disable-next-line custom-errors
        require(msg.sender == borrower, "Only borrower can initiate");
        // solhint-disable-next-line custom-errors
        require(block.timestamp <= (uint256(_loan.loanStartTime) + _newLoanDuration), "New duration already expired");
        // solhint-disable-next-line custom-errors
        require(
            uint256(_newLoanDuration) <= ILoanBase(address(this)).maximumLoanDuration(),
            "New duration exceeds maximum loan duration"
        );
        // solhint-disable-next-line custom-errors
        require(!ILoanBase(address(this)).loanRepaidOrLiquidated(_loanId), "Loan already repaid/liquidated");
        // solhint-disable-next-line custom-errors
        require(
            _newMaximumRepaymentAmount >= _loan.loanPrincipalAmount,
            "Negative interest rate loans are not allowed."
        );

        // Fetch current owner of loan promissory note.

        address lender;
        if (_loan.lender != address(0)) {
            lender = _loan.lender;
        } else {
            lender = IERC721(loanCoordinator.promissoryNoteToken()).ownerOf(smartNftId);
        }

        // solhint-disable-next-line custom-errors
        require(
            !ILoanBase(address(this)).getWhetherRenegotiationNonceHasBeenUsedForUser(lender, _lenderNonce),
            "Lender nonce invalid"
        );

        return (borrower, lender);
    }

    /**
     * @notice A convenience function computing the adminFee taken from a specified quantity of interest.
     *
     * @param _interestDue - The amount of interest due, measured in the smallest quantity of the ERC20 currency being
     * used to pay the interest.
     * @param _adminFeeInBasisPoints - The percent (measured in basis points) of the interest earned that will be taken
     * as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     *
     * @return The quantity of ERC20 currency (measured in smalled units of that ERC20 currency) that is due as an admin
     * fee.
     */
    function computeAdminFee(uint256 _interestDue, uint256 _adminFeeInBasisPoints) external pure returns (uint256) {
        return (_interestDue * _adminFeeInBasisPoints) / HUNDRED_PERCENT;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title  LoanData
 * @author NFTfi
 * @notice An interface containg the main Loan struct shared by Direct Loans types.
 */
interface LoanData {
    /* ********** */
    /* DATA TYPES */
    /* ********** */

    /**
     * @notice The main Loan Terms struct. This data is saved upon loan creation.
     *
     * @param loanERC20Denomination - The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * @param loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan.
     * @param nftCollateralContract - The address of the the NFT collateral contract.
     * @param nftCollateralWrapper - The NFTfi wrapper of the NFT collateral contract.
     * @param nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param loanStartTime - The block.timestamp when the loan first began (measured in seconds).
     * @param loanDuration - The amount of time (measured in seconds) that can elapse before the lender can liquidate
     * the loan and seize the underlying collateral NFT.
     * @param loanAdminFee - The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param originationFee - The amount of tokens which will stay in lender's wallet as origination fee
     * @param borrower
     * @param lender
     * @param escrow - address of the escrow contract the collateral is stored in
     * @param isProRata - indicates if a loan is pro-rata or not
     */

    struct LoanTerms {
        uint256 loanPrincipalAmount;
        uint256 maximumRepaymentAmount;
        uint256 nftCollateralId;
        address loanERC20Denomination;
        uint32 loanDuration;
        uint16 loanInterestRateForDurationInBasisPoints;
        uint16 loanAdminFeeInBasisPoints;
        uint256 originationFee;
        address nftCollateralWrapper;
        uint64 loanStartTime;
        address nftCollateralContract;
        address borrower;
        address lender;
        address escrow;
        bool isProRata;
    }

    /**
     * @notice The offer made by the lender. Used as parameter on both acceptOffer (initiated by the borrower)
     *
     * @param loanERC20Denomination - The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * @param loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always
     * have to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * @param nftCollateralContract - The address of the ERC721 contract of the NFT collateral.
     * @param nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param loanDuration - The amount of time (measured in seconds) that can elapse before the lender can liquidate
     * the loan and seize the underlying collateral NFT.
     * @param isProRata - indicates if a loan is pro-rata or not
     * @param originationFee - amount which will stay in lender's wallet
     */
    struct Offer {
        uint256 loanPrincipalAmount;
        uint256 maximumRepaymentAmount;
        uint256 nftCollateralId;
        address nftCollateralContract;
        uint32 loanDuration;
        address loanERC20Denomination;
        bool isProRata;
        uint256 originationFee;
    }

    /**
     * @notice Signature related params. Used as parameter on both acceptOffer (containing borrower signature)
     *
     * @param signer - The address of the signer. The borrower for `acceptOffer`
     * @param nonce - The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param expiry - Date when the signature expires
     * @param signature - The ECDSA signature of the borrower or the lender, obtained off-chain ahead of time, signing
     * the following combination of parameters:
     * - Lender:
     *   - Offer.loanERC20Denomination
     *   - Offer.loanPrincipalAmount
     *   - Offer.maximumRepaymentAmount
     *   - Offer.nftCollateralContract
     *   - Offer.nftCollateralId
     *   - Offer.loanDuration
     *   - Offer.isProRata
     *   - Signature.signer,
     *   - Signature.nonce,
     *   - Signature.expiry,
     *   - address of the loan type contract
     *   - chainId
     */
    struct Signature {
        uint256 nonce;
        uint256 expiry;
        address signer;
        bytes signature;
    }

    /**
     * inclusive min and max Id ranges for collection offers on collections,
     * like ArtBlocks, where multiple collections are defined on one contract differentiated by id-ranges
     */
    struct CollectionIdRange {
        uint256 minId;
        uint256 maxId;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {INftfiHub} from "../interfaces/INftfiHub.sol";

/**
 * @title SmartNft
 * @author NFTfi
 * @dev An ERC721 token which represents a very basic implementation of the NFTfi V2 SmartNFT.
 */
contract SmartNft is ERC721, AccessControl {
    using Address for address;
    using Strings for uint256;

    /**
     * @dev This struct contains data needed to find the loan linked to a SmartNft.
     */
    struct Loan {
        address loanCoordinator;
        uint256 loanId;
    }

    /* ******* */
    /* STORAGE */
    /* ******* */

    bytes32 public constant LOAN_COORDINATOR_ROLE = keccak256("LOAN_COORDINATOR_ROLE");
    bytes32 public constant BASE_URI_ROLE = keccak256("BASE_URI_ROLE");

    // solhint-disable-next-line immutable-vars-naming
    INftfiHub public immutable hub;

    // smartNftId => Loan
    mapping(uint256 => Loan) public loans;

    string public baseURI;

    /**
     * @dev Grants the contract the default admin role to `_admin`.
     * Grants LOAN_COORDINATOR_ROLE to `_loanCoordinator`.
     *
     * @param _admin - Account to set as the admin of roles
     * @param _nftfiHub - Address of the NftfiHub contract
     * @param _loanCoordinator - Initial loan coordinator
     * @param _name - Name for the SmarNFT
     * @param _symbol - Symbol for the SmarNFT
     * @param _customBaseURI - Base URI for the SmarNFT
     */
    constructor(
        address _admin,
        address _nftfiHub,
        address _loanCoordinator,
        string memory _name,
        string memory _symbol,
        string memory _customBaseURI
    ) ERC721(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(BASE_URI_ROLE, _admin);
        _setupRole(LOAN_COORDINATOR_ROLE, _loanCoordinator);
        _setBaseURI(_customBaseURI);
        hub = INftfiHub(_nftfiHub);
    }

    /**
     * @dev Grants LOAN_COORDINATOR_ROLE to `_account`.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function setLoanCoordinator(address _account) external {
        grantRole(LOAN_COORDINATOR_ROLE, _account);
    }

    /**
     * @dev Mints a new token with `_tokenId` and assigne to `_to`.
     *
     * Requirements:
     *
     * - the caller must have `LOAN_COORDINATOR_ROLE` role.
     *
     * @param _to The address reciving the SmartNft
     * @param _tokenId The id of the new SmartNft
     * @param _data Up to the first 32 bytes contains an integer which represents the loanId linked to the SmartNft
     */
    function mint(address _to, uint256 _tokenId, bytes calldata _data) external onlyRole(LOAN_COORDINATOR_ROLE) {
        // solhint-disable-next-line custom-errors
        require(_data.length > 0, "data must contain loanId");
        uint256 loanId = abi.decode(_data, (uint256));
        loans[_tokenId] = Loan({loanCoordinator: msg.sender, loanId: loanId});
        _safeMint(_to, _tokenId, _data);
    }

    /**
     * @dev Burns `_tokenId` token.
     *
     * Requirements:
     *
     * - the caller must have `LOAN_COORDINATOR_ROLE` role.
     */
    function burn(uint256 _tokenId) external onlyRole(LOAN_COORDINATOR_ROLE) {
        _burn(_tokenId);
    }

    /**
     * @dev Sets baseURI.
     * @param _customBaseURI - Base URI for the SmarNFT
     */
    function setBaseURI(string memory _customBaseURI) external onlyRole(BASE_URI_ROLE) {
        _setBaseURI(_customBaseURI);
    }

    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    /**
     * @dev Sets baseURI.
     */
    function _setBaseURI(string memory _customBaseURI) internal virtual {
        baseURI = bytes(_customBaseURI).length > 0
            ? string(abi.encodePacked(_customBaseURI, _getChainID().toString(), "/"))
            : "";
    }

    /** @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev This function gets the current chain ID.
     */
    function _getChainID() internal view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title ContractKeyUtils
 * @author NFTfi
 * @dev Common library for contract key utils
 */
library ContractKeyUtils {
    /**
     * @notice Returns the bytes32 representation of a string
     * @param _key the string key
     * @return id bytes32 representation
     */
    function getIdFromStringKey(string memory _key) public pure returns (bytes32 id) {
        // solhint-disable-next-line custom-errors
        require(bytes(_key).length <= 32, "invalid key");

        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := mload(add(_key, 32))
        }
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

/**
 * @title ContractKeys
 * @author NFTfi
 * @dev Common library for contract keys
 */
library ContractKeys {
    bytes32 public constant PERMITTED_ERC20S = bytes32("PERMITTED_ERC20S");
    bytes32 public constant PERMITTED_NFTS = bytes32("PERMITTED_NFTS");
    bytes32 public constant NFT_TYPE_REGISTRY = bytes32("NFT_TYPE_REGISTRY");
    bytes32 public constant LOAN_COORDINATOR = bytes32("LOAN_COORDINATOR");
    bytes32 public constant PERMITTED_SNFT_RECEIVER = bytes32("PERMITTED_SNFT_RECEIVER");
    bytes32 public constant ESCROW = bytes32("ESCROW");
    bytes32 public constant ERC20_TRANSFER_MANAGER = bytes32("ERC20_TRANSFER_MANAGER");
    bytes32 public constant PERSONAL_ESCROW_FACTORY = bytes32("PERSONAL_ESCROW_FACTORY");
    bytes32 public constant DELEGATE_PLUGIN = bytes32("DELEGATE_PLUGIN");
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {LoanData} from "../loans/loanTypes/LoanData.sol";
import {SignatureChecker, ECDSA} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @title  NFTfiCollectionOfferSigningUtils
 * @author NFTfi
 * @notice Helper contract for NFTfi. This contract manages verifying signatures from off-chain NFTfi orders.
 * Based on the version of this same contract used on NFTfi V1
 */
library NFTfiCollectionOfferSigningUtils {
    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev This function gets the current chain ID.
     */
    function getChainID() internal view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - isProRata: indicates if a loan is pro-rated or fixed
     * @param _idRange - min and max (inclusive) Id ranges for collection offers on collections,
     * like ArtBlocks, where multiple collections are defined on one contract differentiated by id-ranges
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer`
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * @param _offerType type of the offer registered in the coordinator
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.loanDuration
     *   - offer.isProRata
     *   - idRange.minId,
     *   - idRange.maxId,
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - _offerType
     *   - chainId
     */
    function isValidLenderSignatureWithIdRange(
        LoanData.Offer memory _offer,
        LoanData.CollectionIdRange memory _idRange,
        LoanData.Signature memory _signature,
        bytes32 _offerType
    ) internal view returns (bool) {
        // solhint-disable-next-line custom-errors
        require(block.timestamp <= _signature.expiry, "Lender Signature has expired");
        // solhint-disable-next-line custom-errors
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    getEncodedOffer(_offer),
                    abi.encodePacked(_idRange.minId, _idRange.maxId),
                    getEncodedSignature(_signature),
                    _offerType,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedOffer(LoanData.Offer memory _offer) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _offer.loanERC20Denomination,
                _offer.loanPrincipalAmount,
                _offer.maximumRepaymentAmount,
                _offer.nftCollateralContract,
                _offer.nftCollateralId,
                _offer.loanDuration,
                _offer.isProRata,
                _offer.originationFee
            );
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedSignature(LoanData.Signature memory _signature) internal pure returns (bytes memory) {
        return abi.encodePacked(_signature.signer, _signature.nonce, _signature.expiry);
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {LoanData} from "../loans/loanTypes/LoanData.sol";
import {SignatureChecker, ECDSA} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @title  NFTfiSigningUtils
 * @author NFTfi
 * @notice Helper contract for NFTfi. This contract manages verifying signatures from off-chain NFTfi orders.
 * Based on the version of this same contract used on NFTfi V1
 */
library NFTfiSigningUtils {
    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev This function gets the current chain ID.
     */
    function getChainID() internal view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - isProRata: indicates if a loan is pro-rated or fixed
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer`
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitment(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * @param _offerType type of the offer registered in the coordinator
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.loanDuration
     *   - offer.isProRata
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - _offerType
     *   - chainId
     */
    function isValidLenderSignature(
        LoanData.Offer memory _offer,
        LoanData.Signature memory _signature,
        bytes32 _offerType
    ) public view returns (bool) {
        // solhint-disable-next-line custom-errors
        require(block.timestamp <= _signature.expiry, "Lender Signature has expired");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(getEncodedOffer(_offer), getEncodedSignature(_signature), _offerType, getChainID())
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @notice This function is called in renegotiateLoan() to validate the lender's signature that the lender provided
     * off-chain to verify that they did indeed want to agree to this loan renegotiation according to these terms.
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _isProRata - indicates if loan is pro-rata or fixed
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in ether that borrower pays for the lender for the renegitiation
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer`
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitment()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * - expiry - The date when the renegotiation offer expires
     * - lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _isProRata
     * - _newMaximumRepaymentAmount
     * - _lender
     * - _lenderNonce
     * - _expiry
     * - address of this contract
     * - chainId
     */
    function isValidLenderRenegotiationSignature(
        uint256 _loanId,
        uint32 _newLoanDuration,
        bool _isProRata,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        LoanData.Signature memory _signature
    ) external view returns (bool) {
        return
            isValidLenderRenegotiationSignature(
                _loanId,
                _newLoanDuration,
                _isProRata,
                _newMaximumRepaymentAmount,
                _renegotiationFee,
                _signature,
                address(this)
            );
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidLenderRenegotiationSignature(
        uint256 _loanId,
        uint32 _newLoanDuration,
        bool _isProRata,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        // solhint-disable-next-line custom-errors
        require(block.timestamp <= _signature.expiry, "Renegotiation Signature expired");
        // solhint-disable-next-line custom-errors
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    _loanId,
                    _newLoanDuration,
                    _isProRata,
                    _newMaximumRepaymentAmount,
                    _renegotiationFee,
                    getEncodedSignature(_signature),
                    _loanContract,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedOffer(LoanData.Offer memory _offer) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _offer.loanERC20Denomination,
                _offer.loanPrincipalAmount,
                _offer.maximumRepaymentAmount,
                _offer.nftCollateralContract,
                _offer.nftCollateralId,
                _offer.loanDuration,
                _offer.isProRata,
                _offer.originationFee
            );
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedSignature(LoanData.Signature memory _signature) internal pure returns (bytes memory) {
        return abi.encodePacked(_signature.signer, _signature.nonce, _signature.expiry);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import {IERC1155Receiver, IERC165} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {ERC721Holder, IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

/**
 * @title NftReceiver
 * @author NFTfi
 * @dev Base contract with capabilities for receiving ERC1155 and ERC721 tokens
 */
abstract contract NftReceiver is IERC1155Receiver, ERC721Holder {
    /**
     *  @dev Handles the receipt of a single ERC1155 token type. This function is called at the end of a
     * `safeTransferFrom` after the balance has been updated.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if allowed
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     *  @dev Handles the receipt of a multiple ERC1155 token types. This function is called at the end of a
     * `safeBatchTransferFrom` after the balances have been updated.
     *  @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if allowed
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual override returns (bytes4) {
        // solhint-disable-next-line custom-errors
        revert("ERC1155 batch not supported");
    }

    /**
     * @dev Checks whether this contract implements the interface defined by `interfaceId`.
     * @param _interfaceId Id of the interface
     * @return true if this contract implements the interface
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return
            _interfaceId == type(IERC1155Receiver).interfaceId ||
            _interfaceId == type(IERC721Receiver).interfaceId ||
            _interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.19;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 *
 * Modified version from openzeppelin/contracts/access/Ownable.sol that allows to
 * initialize the owner using a parameter in the constructor
 */
abstract contract Ownable is Context {
    address private _owner;

    address private _ownerCandidate;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        // solhint-disable-next-line custom-errors
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }

    /**
     * @dev Requests transferring ownership of the contract to a new account (`_newOwnerCandidate`).
     * Can only be called by the current owner.
     */
    function requestTransferOwnership(address _newOwnerCandidate) public virtual onlyOwner {
        // solhint-disable-next-line custom-errors
        require(_newOwnerCandidate != address(0), "Ownable: new owner is the zero address");
        _ownerCandidate = _newOwnerCandidate;
    }

    function acceptTransferOwnership() public virtual {
        // solhint-disable-next-line custom-errors
        require(_ownerCandidate == _msgSender(), "Ownable: not owner candidate");
        _setOwner(_ownerCandidate);
        delete _ownerCandidate;
    }

    function cancelTransferOwnership() public virtual onlyOwner {
        delete _ownerCandidate;
    }

    function rejectTransferOwnership() public virtual {
        // solhint-disable-next-line custom-errors
        require(_ownerCandidate == _msgSender(), "Ownable: not owner candidate");
        delete _ownerCandidate;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Sets the owner.
     */
    function _setOwner(address _newOwner) internal {
        address oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
}