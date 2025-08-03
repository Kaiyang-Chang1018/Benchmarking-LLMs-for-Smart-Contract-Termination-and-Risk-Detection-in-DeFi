// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

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
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

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
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
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
            set._indexes[value] = set._values.length;
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
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
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

        /// @solidity memory-safe-assembly
        assembly {
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

        /// @solidity memory-safe-assembly
        assembly {
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEIP712} from "./IEIP712.sol";

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    /// @notice Thrown when the requested amount for a transfer is larger than the permissioned amount
    /// @param maxAmount The maximum amount a spender can request to transfer
    error InvalidAmount(uint256 maxAmount);

    /// @notice Thrown when the number of tokens permissioned to a spender does not match the number of tokens being transferred
    /// @dev If the spender does not need to transfer the number of tokens permitted, the spender can request amount 0 to be transferred
    error LengthMismatch();

    /// @notice Emits an event when the owner successfully invalidates an unordered nonce.
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Used to reconstruct the signed permit message for multiple token transfers
    /// @dev Do not need to pass in spender address as it is required that it is msg.sender
    /// @dev Note that a user still signs over a spender address
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice A map from token owner address and a caller specified word index to a bitmap. Used to set bits in the bitmap to prevent against signature replay protection
    /// @dev Uses unordered nonces so that permit messages do not need to be spent in a certain order
    /// @dev The mapping is indexed first by the token owner, then by an index specified in the nonce
    /// @dev It returns a uint256 bitmap
    /// @dev The index, or wordPosition is capped at type(uint248).max
    function nonceBitmap(address, uint256) external view returns (uint256);

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers multiple tokens using a signed permit message
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails Specifies the recipient and requested amount for the token transfer
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    /// @notice Invalidates the bits specified in mask for the bitmap at the word position
    /// @dev The wordPos is maxed at type(uint248).max
    /// @param wordPos A number to index the nonceBitmap at
    /// @param mask A bitmap masked against msg.sender's current bitmap at the word position
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {Status, Phase} from "./SaleStruct.sol";

/**
 * @author https://github.com/Theo6890
 * @title SaleStorage
 * @notice Mapps the storage layout of the {Sale} contract.
 * @dev Diamond proxy (ERC-2535) storage style.
 */
library SaleStorage {
    /**
     * @notice Struct reprensenting the main setup of the Sale.
     *
     * @param paymentToken Address of the default token used to reserve allocation through the Sale.
     *                     If `address(0)`, it means native token of the chain (ETH, BNB, etc...).
     * @param permit2 Official address of the {Permit2} library deployed by Uniswap.
     */
    struct SetUp {
        address paymentToken;
        address permit2;
    }

    /**
     * @notice Struct reprensenting the setup of each phase of the Sale.
     * @dev Status of the phase is the only value that can be updated by Sale contract itself due to user's
     *      interactions with the contract.
     *
     * @param ids List of all phases identifiers.
     * @param data Mapping of data of each phases.
     */
    struct Phases {
        string[] ids;
        mapping(string => Phase) data;
    }

    /**
     * @notice Struct reprensenting data of the Sale which are always updated by user's interactions with
     *         the Sale contract.
     *
     * @param status Enum representing the current status of the Sale.
     * @param summedMaxPhaseCap Sum of maximum cap of each phase expressed in {SetUp.paymentToken}.
     * @param totalRaised Total amount of paymentToken raised for this Sale,
     *                    expressed in {SetUp.paymentToken}.
     * @param raisedInPhase Amount of paymentToken raised for each phase, expressed in {SetUp.paymentToken}.
     * @param allocationReservedByIn Amount of paymentToken paid by phase by each user,
     *                               expressed in {SetUp.paymentToken}.
     */
    struct Ledger {
        Status status;
        uint256 summedMaxPhaseCap;
        uint256 totalRaised;
        mapping(string => uint256) raisedInPhase;
        mapping(address => mapping(string => uint256)) allocationReservedByIn;
        mapping(address => mapping(string => uint256)) freeAllocationMintedBy;
    }

    /**
     * @notice Struct reprensenting the whole storage layout of the Sale contract.
     *
     * @param setUp reprensenting the main setup of the Sale.
     * @param phases reprensenting the setup of each phase of the Sale.
     * @param ledger reprensenting data of the Sale which are always updated by user's interactions with
     *        the Sale contract.
     */
    struct SaleStruct {
        SetUp setUp;
        Phases phases;
        Ledger ledger;
    }

    /// @notice Storage position of {SaleStruct} in {Sale} contract.
    bytes32 public constant Sale_STORAGE = keccak256("common.storage");

    /**
     * @return igoStruct Whole storage of {Sale} contract.
     */
    function layout() internal pure returns (SaleStruct storage igoStruct) {
        bytes32 position = Sale_STORAGE;
        assembly {
            igoStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/**
 * @notice Shared enum representing the different status of a phase or the whole IGO.
 *
 * @custom:value NOT_STARTED IGO/Phase created but not started; allocations/buyAndMint are allowed.
 * @custom:value OPENED IGO/Phase started according to start date; allocations/buyAndMint are allowed.
 * @custom:value COMPLETED IGO/Phase everything has been sold or time has been elapsed;
 *               allocations/buyAndMint can't be reserved anymore.
 * @custom:value PAUSED IGO/Phase has been paused by the owner; allocations/buyAndMint can't be
 *               reserved until further notice.
 */
enum Status {
    NOT_STARTED,
    OPENED,
    COMPLETED,
    PAUSED
}

/**
 * @notice Struct representing an allocation of a wallet for a specific phase of a sale.
 *
 * @param phaseId Phase identifier of the in the current sale, e.g. "vpr-social-task",
 *        "sale-public-phase-1", "ino-public" etc...
 * @param maxAllocation Maximum amount to spend in {SaleStorage.SetUp.paymentToken}.
 * @param saleTokenPerPaymentToken Price per token/nft of the project behind the Sale, expressed in
 *        {SaleStorage.SetUp.paymentToken}.
 */
struct Allocation {
    string phaseId;
    uint256 maxAllocation;
    uint256 saleTokenPerPaymentToken;
}

/**
 * @notice Struct representing a buy permission signed by `msg.sender` for
 *         {SaleWritable.reserveAllocation} function to use with {Permit2} library.
 *
 * @dev Compulsory to interact with {Permit2.permitTransferFrom} in
 *      {SaleWritableInternal._reserveAllocation}.
 *
 * @param signature {Permit2} signature to transfer tokens from the buyer to {SaleVesting}.
 * @param deadline Seadline on the permit signature.
 * @param nonce Unique value for every token owner's signature to prevent signature replays.
 */
struct BuyPermission {
    bytes signature;
    uint256 deadline;
    uint256 nonce;
}

/**
 * @notice Shared struct representing the data of a phase.
 *
 * @param status Enum representing the current status of the phase.
 * @param merkleRoot Merkle root of the merkle tree containing whitelisted data.
 * @param startAt Timestamp at which the phase will be opened to reserve allocation.
 * @param endAt Timestamp at which the phase will not accept allocation reservation anymore.
 * @param maxPhaseCap Maximum amount of {SaleStorage.SetUp.paymentToken} for this phase.
 */
struct Phase {
    Status status;
    // contains wallet and allocation per wallet
    bytes32 merkleRoot;
    uint128 startAt;
    uint128 endAt;
    uint256 maxPhaseCap;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Allocation} from "../common/SaleStruct.sol";

/**
 * @notice Struct representing a user based allocation for a specific phase of a sale.
 *
 * @dev Backend is in charge of generating an allocation, which will depends on the sale type:
 *      - IGO: allocation based on the tier from which wallet is part of,
 *      - VPR IGO: off-chain backend lottery + allocation based on off-chain actions, e.g.
 *          * social task: +50% from base price,
 *          * in-game tasks: +33% from base price,
 *          * etc...
 *      - INO: allocation based on SFUND/SFNTS staked-farmed.
 *
 * @param base User based allocation data.
 * @param account Wallet address of the buyer.
 */
struct UserAllocation {
    Allocation base;
    address account;
}

/**
 * @notice Struct representing a user based allocation with a refund fee.
 *
 * @param usrData User based allocation data.
 * @param refundFee Fee to be paid by the buyer in case of refund, expressed in
 *        {SaleStorage.SetUp.paymentToken} - decimals defined in {IGOVesting.decimals}.
 */
struct UserAllocationFee {
    UserAllocation usrData;
    uint256 refundFee;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {Status, Phase} from "../SaleStruct.sol";

/**
 * @title ISaleReadable
 * @notice Interface made for read-only data from {Sale}.
 */
interface ISaleReadable {
    /**
     * @param account Address of the user.
     * @param phaseId Identifier of the phase.
     *
     * @return amount Amount of paymentToken paid by phase by each user,
     *                               expressed in {SetUp.paymentToken}.
     */
    function freeAllocationMintedBy(
        address account,
        string calldata phaseId
    ) external view returns (uint256);

    /**
     * @return Total Sum of maximum cap of each phase, expressed in {SetUp.paymentToken}.
     */
    function summedMaxPhaseCap() external view returns (uint256);

    /**
     * @param account Address of the user.
     * @param phaseId Identifier of the phase.
     *
     * @return Amount of {SaleStorage.SetUp.paymentToken} paid by `account` for the phase `phaseId`.
     *         If `address(0)` is returned, it means native (ETH, BNB, MATCI, etc...).
     */
    function allocationReservedByIn(
        address account,
        string calldata phaseId
    ) external view returns (uint256);

    /**
     * @param phaseId Identifier of the phase.
     * @return phase_ Phase struct representing the data of the phase `phaseId`.
     */
    function phase(
        string memory phaseId
    ) external view returns (Phase memory phase_);

    /// @return phaseIds_ List of all phases identifiers.
    function phaseIds() external view returns (string[] memory phaseIds_);

    /**
     * @param phaseId Identifier of the phase.
     *
     * @return Amount of {SaleStorage.SetUp.paymentToken} raised for the phase `phaseId`.
     *         If `address(0)` is returned, it means native (ETH, BNB, MATCI, etc...).
     */
    function raisedInPhase(
        string memory phaseId
    ) external view returns (uint256);

    /// @return Enum representing the current status of the Sale.
    function saleStatus() external view returns (Status);

    /**
     * @return paymentToken Address of the default token used to reserve allocation through the Sale.
     *         If `address(0)` is returned, it means native (ETH, BNB, MATCI, etc...).
     * @return permit2 Address of Permit2 contract.
     */
    function setUp()
        external
        view
        returns (address paymentToken, address permit2);

    /// @return Total amount of {SaleStorage.SetUp.paymentToken} raised for this Sale.
    function totalRaised() external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {ISaleReadable} from "../readable/ISaleReadable.sol";
import {IRestrictedWritableInternal} from "../writable/restricted/IRestrictedWritableInternal.sol";
import {ISaleWritableInternal} from "../writable/ISaleWritableInternal.sol";

import {SaleStorage} from "../SaleStorage.sol";

// import struct
import {Status, Phase} from "../SaleStruct.sol";

/**
 * @title SaleReadable
 * @notice Read-only contract of {Sale} data.
 */
contract SaleReadable is
    ISaleReadable, // 1 inherited component
    ISaleWritableInternal, // 1 inherited component
    IRestrictedWritableInternal // 1 inherited component
{
    /// @inheritdoc ISaleReadable
    function freeAllocationMintedBy(
        address account,
        string calldata phaseId
    ) external view override returns (uint256) {
        return
            SaleStorage.layout().ledger.freeAllocationMintedBy[account][
                phaseId
            ];
    }

    /// @inheritdoc ISaleReadable
    function summedMaxPhaseCap() external view override returns (uint256) {
        return SaleStorage.layout().ledger.summedMaxPhaseCap;
    }

    /// @inheritdoc ISaleReadable
    function allocationReservedByIn(
        address account,
        string calldata phaseId
    ) external view override returns (uint256) {
        return
            SaleStorage.layout().ledger.allocationReservedByIn[account][
                phaseId
            ];
    }

    /// @inheritdoc ISaleReadable
    function phase(
        string memory phaseId
    ) external view override returns (Phase memory phase_) {
        phase_ = SaleStorage.layout().phases.data[phaseId];
    }

    /// @inheritdoc ISaleReadable
    function phaseIds()
        external
        view
        override
        returns (string[] memory phaseIds_)
    {
        phaseIds_ = SaleStorage.layout().phases.ids;
    }

    /// @inheritdoc ISaleReadable
    function raisedInPhase(
        string memory phaseId
    ) external view override returns (uint256) {
        return SaleStorage.layout().ledger.raisedInPhase[phaseId];
    }

    /// @inheritdoc ISaleReadable
    function saleStatus() external view override returns (Status) {
        return SaleStorage.layout().ledger.status;
    }

    /// @inheritdoc ISaleReadable
    function setUp()
        external
        view
        override
        returns (address paymentToken, address permit2)
    {
        SaleStorage.SetUp memory setUp_ = SaleStorage.layout().setUp;
        paymentToken = setUp_.paymentToken;
        permit2 = setUp_.permit2;
    }

    /// @inheritdoc ISaleReadable
    function totalRaised() external view override returns (uint256) {
        return SaleStorage.layout().ledger.totalRaised;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {Status} from "../SaleStruct.sol";

/**
 * @title ISaleWritableInternal
 * @notice Internal interface of `SaleWritable` which defines events  and errors.
 */
interface ISaleWritableInternal {
    /// @notice Thrown when the buyer tries to spend more than {Allocation.maxAllocation}.
    error SaleWritable_AllocationExceeded(
        uint256 allocation,
        uint256 exceedsBy
    );
    /// @notice Thrown when the grand total to be raised for this Sale is exceeded.
    error SaleWritable_SummedMaxPhaseCapExceeded(
        uint256 summedMaxPhaseCap,
        uint256 exceedsBy
    );
    /// @notice Thrown when the cap (maximum amount) of the current phase is exceeded.
    error SaleWritable_MaxPhaseCapExceeded(
        string phaseId,
        uint256 maxPhaseCap,
        uint256 exceedsBy
    );

    /// @notice Thrown when `msg.sender` is not the buyer.
    error SaleWritableInternal_AccountNotAuthorized();
    /// @notice Thrown when the allocation is not found in the merkle proof.
    error SaleWritableInternal_AllocationNotFound();
    /// @notice Thrown when the phase is not opened.
    error SaleWritableInternal_PhaseNotOpened(string phaseId, Status current);
    /// @notice Thrown when the Sale is not opened.
    error SaleWritableInternal_SaleNotOpened(Status current);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {ISignatureTransfer} from "permit2/interfaces/ISignatureTransfer.sol";
import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import {RestrictedWritableInternal} from "./restricted/RestrictedWritableInternal.sol";
import {ISaleWritableInternal} from "./ISaleWritableInternal.sol";

import {SaleStorage} from "../SaleStorage.sol";

// struct import
import {Status, Phase, BuyPermission} from "../SaleStruct.sol";
import {UserAllocationFee} from "../UserAllocationStruct.sol";

/**
 * @title SaleWritableInternal
 * @notice Defines internal functions for `SaleWritable`.
 */
contract SaleWritableInternal is
    ISaleWritableInternal, // 1 inherited component
    RestrictedWritableInternal // 2 inherited components
{
    function _checkBuyReserveParams(
        uint256 reserveNow,
        UserAllocationFee calldata allocation,
        string calldata phaseId,
        uint256 summedMaxPhaseCap,
        uint256 maxPhaseCap,
        bytes32[] calldata proof
    ) internal {
        _requireAllocationNotExceededInPhase(
            reserveNow,
            allocation.usrData.account,
            allocation.usrData.base.maxAllocation,
            phaseId
        );
        _requireSummedMaxPhaseCapNotExceeded(reserveNow, summedMaxPhaseCap);
        _requireOpenedSaleAndPhase(allocation.usrData.base.phaseId);
        _requirePhaseCapNotExceeded(phaseId, maxPhaseCap, reserveNow);
        _requireValidAllocation(allocation, proof);
    }

    /**
     * @notice Update storage of the Sale when an allocation is reserved on-chain: total raised, total raised
     *      in phase, allocation reserved by buyer in phase, etc...
     *
     * @param amount Amount of tokens spent in this transaction, expressed in 
     *        {SaleStorage.SetUp.paymentToken}.
     * @param phaseId Phase linked to current allocation used by buyer.
     * @param buyer Wallet buying tokens.
     * @param maxPhaseCap Maximum amount of tokens to be sold in this phase, expressed in 
              {SaleStorage.SetUp.paymentToken}.
     */
    function _updateStorageOnBuy(
        uint256 amount,
        string calldata phaseId,
        address buyer,
        uint256 maxPhaseCap
    ) internal virtual {
        SaleStorage.Ledger storage ledger = SaleStorage.layout().ledger;

        // update raised amount
        ledger.totalRaised += amount;
        ledger.raisedInPhase[phaseId] += amount;
        ledger.allocationReservedByIn[buyer][phaseId] += amount;
        // close whole SALE if sold out
        if (ledger.totalRaised == ledger.summedMaxPhaseCap) _closeSale();
        // close PHASE if sold out
        if (ledger.raisedInPhase[phaseId] == maxPhaseCap) {
            _closePhase(phaseId);
        }
    }

    /// @notice Verify phase is opened. If the sale has not been opened before the phase, open it.
    function _requireOpenedSaleAndPhase(string memory phaseId) internal {
        // manually close phase if maxPhaseCap is NOT reached - TEMPORARY solution
        if (
            block.timestamp >= SaleStorage.layout().phases.data[phaseId].endAt
        ) {
            revert("Phase closed"); // string instead custom error as temporary solution
        }

        Phase memory phase = SaleStorage.layout().phases.data[phaseId];
        Status saleStatus = SaleStorage.layout().ledger.status;

        // open phase if necessary
        if (
            phase.status == Status.NOT_STARTED &&
            block.timestamp >= phase.startAt &&
            block.timestamp < phase.endAt
        ) {
            if (saleStatus == Status.NOT_STARTED) _openSale();
            _openPhase(phaseId);
            return;
        }
        // revert if phase can not be opened
        if (phase.status != Status.OPENED) {
            revert SaleWritableInternal_PhaseNotOpened(phaseId, phase.status);
        }
        // revert if sale can not be opened
        if (saleStatus != Status.OPENED) {
            revert SaleWritableInternal_SaleNotOpened(saleStatus);
        }
    }

    /**
     * @notice Ensure a wallet can not spend more than their allocation for the given phase.
     *
     * @param toSpend Amount of tokens to spend in this transaction, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     * @param buyer Wallet buying tokens.
     * @param allocated Maximum amount of tokens this wallet can spend in this phase, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     */
    function _requireAllocationNotExceededInPhase(
        uint256 toSpend,
        address buyer,
        uint256 allocated,
        string calldata phaseId
    ) internal view {
        uint256 totalAfterPurchase = toSpend +
            SaleStorage.layout().ledger.allocationReservedByIn[buyer][phaseId];

        // avoids replay attack
        if (totalAfterPurchase > allocated) {
            revert SaleWritable_AllocationExceeded(
                allocated,
                totalAfterPurchase - allocated
            );
        }
    }

    /**
     * @notice Verify `summedMaxPhaseCap` will not be exceeded after purchase.
     *
     * @param toSpend Amount of tokens to spend in this transaction, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     * @param summedMaxPhaseCap Total amount of tokens to be sold in this Sale, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     */
    function _requireSummedMaxPhaseCapNotExceeded(
        uint256 toSpend,
        uint256 summedMaxPhaseCap
    ) internal view {
        uint256 totalAfterPurchase = toSpend +
            SaleStorage.layout().ledger.totalRaised;
        if (totalAfterPurchase > summedMaxPhaseCap) {
            revert SaleWritable_SummedMaxPhaseCapExceeded(
                summedMaxPhaseCap,
                // by how much`summedMaxPhaseCap` is exceeded
                totalAfterPurchase - summedMaxPhaseCap
            );
        }
    }

    /**
     * @notice Verify `maxPhaseCap` will not be exceeded after purchase.
     *
     * @param phaseId Phase linked to current allocation used by buyer.
     * @param maxPhaseCap Maximum amount of tokens to be sold in this phase, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     * @param toSpend Amount of tokens to spend in this transaction, expressed in
     *        {SaleStorage.SetUp.paymentToken}.
     */
    function _requirePhaseCapNotExceeded(
        string calldata phaseId,
        uint256 maxPhaseCap,
        uint256 toSpend
    ) internal view {
        uint256 raisedAfterPurchase = toSpend +
            SaleStorage.layout().ledger.raisedInPhase[phaseId];
        if (raisedAfterPurchase > maxPhaseCap) {
            revert SaleWritable_MaxPhaseCapExceeded(
                phaseId,
                maxPhaseCap,
                // by how much `maxPhaseCap` is exceeded
                raisedAfterPurchase - maxPhaseCap
            );
        }
    }

    /**
     * @notice Verify allocation is valid.
     *
     * @param allocation Allocation to verify.
     * @param proof Merkle proof of the allocation.
     */
    function _requireValidAllocation(
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof
    ) internal view {
        if (
            !MerkleProof.verify(
                proof,
                SaleStorage
                    .layout()
                    .phases
                    .data[allocation.usrData.base.phaseId]
                    .merkleRoot,
                keccak256(abi.encode(address(this), block.chainid, allocation))
            )
        ) revert SaleWritableInternal_AllocationNotFound();
    }

    /**
     * @notice ERC20 permit and transfer in one call.
     * @param permit2 Address of the permit2 contract.
     * @param from address to transfer tokens from.
     * @param to address to transfer tokens to.
     * @param token address of the token to transfer.
     * @param amount amount of tokens to transfer.
     * @param permission BuyPermission struct containing permit signature and deadline.
     */
    function _permit2ApproveAndTransfer(
        address permit2,
        address from,
        address to,
        address token,
        uint256 amount,
        BuyPermission calldata permission
    ) internal {
        /// @dev declare {Permit2.permitTransferFrom} parameters
        ISignatureTransfer.TokenPermissions memory permitted;
        ISignatureTransfer.PermitTransferFrom memory permit;
        ISignatureTransfer.SignatureTransferDetails memory transferDetails;

        /// @dev configure {Permit2.permitTransferFrom} parameters using IGO and allocation parameters
        permitted = ISignatureTransfer.TokenPermissions({
            token: token,
            amount: amount
        });
        permit = ISignatureTransfer.PermitTransferFrom({
            permitted: permitted,
            nonce: permission.nonce,
            deadline: permission.deadline
        });
        transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: to,
            requestedAmount: amount
        });

        /// @dev {Permit2} library call
        ISignatureTransfer(permit2).permitTransferFrom(
            permit,
            transferDetails,
            from,
            permission.signature
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IGOStorage} from "../../../igo/IGOStorage.sol";
import {SaleStorage} from "../../SaleStorage.sol";

// import struct
import {Phase} from "../../SaleStruct.sol";

/**
 * @title IRestrictedWritable
 * @notice Only the owner of the contract can call these methods.
 */
interface IRestrictedWritable {
    //////////////////////////// SHARED Sale DATA ////////////////////////////
    /**
     * @notice Close the sale for good.
     * @dev Can be closed at any point in time AND NOT reversible.
     */
    function closeSale() external;

    function openSale() external;

    function pauseSale() external;

    function resumeSale() external;

    /// @dev Retrieve any ERC20 sent to the contract by mistake.
    function recoverLostERC20(address token, address to) external;

    function closePhases(string[] calldata phaseIds) external;

    // TODO: UX choice to make here, do we need both phase single field update and phase batch update?
    //////////////////////////// PHASE SINGLE UPDATE ////////////////////////////
    /**
     * @custom:audit phase can be opened even if it does not exists but as only the owner can update this
     * method we make the asumption that the owner will always be aware of this to save gast costs and it
     * can be paused at any time to update its data so it does not pose a security risk.
     */
    function openPhase(string calldata phaseId) external;

    function pausePhase(string calldata phaseId) external;

    function resumePhase(string calldata phaseId) external;

    function updatePhaseEndDate(
        string calldata phaseId,
        uint128 endAt
    ) external;

    /**
     * @notice Update `maxPhaseCap` which is the maximum amount of tokens that can be sold in a phase
     *         and the merkle root of a phase to update a single or multiple wallet allocation,
     *         refund fee, etc.
     * @dev `maxPhaseCap` is expressed in {SaleStorage.SetUp.paymentToken}.
     *
     * @param phaseId Identifier of the phase.
     * @param merkleRoot New merkle root to be saved for this phase.
     */
    function updatePhaseMaxCapAndMerkleRoot(
        string calldata phaseId,
        uint256 maxPhaseCap,
        bytes32 merkleRoot
    ) external;

    /**
     * @notice Update the merkle root of a phase to update a single or multiple wallet allocation,
     *         refund fee, payment token etc.
     *
     * @param phaseId Identifier of the phase.
     * @param merkleRoot New merkle root to be saved for this phase.
     */
    function updatePhaseMerkleRoot(
        string calldata phaseId,
        bytes32 merkleRoot
    ) external;

    function updatePhaseStartDate(
        string calldata phaseId,
        uint128 startAt
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Status} from "../../SaleStruct.sol";

/**
 * @title IRestrictedWritableInternal
 * @notice Defines event and error used in {RestrictedWritableInternal} & {RestrictedWritable}.
 */
interface IRestrictedWritableInternal {
    // @notice Thrown when `phaseIds` and `phases` arrays have different lengths.
    error RestrictedWritableInternal_DifferentArraysLength();
    // @notice Thrown when a phase {IGOStruct.Phase} is empty is {RestrictedWritableInternal._setPhases}.
    error RestrictedWritableInternal_EmptyPhase();

    //////////////////////////// THROWN ON Sale INITIALIZATION ////////////////////////////
    error RestrictedWritable_Init_OwnerIsZeroAddr();
    error RestrictedWritable_Init_PaymentTokenIsZeroAddr();
    error RestrictedWritable_Init_Permit2IsZeroAddr();

    //////////////////////////// THROWN AT ANY TIME ////////////////////////////
    /// @dev Thrown when merkle root is equal to bytes32(0).
    error RestrictedWritable_EmptyMerkleRoot();
    // @notice Thrown when a phase {IGOStruct.Phase} is empty is {RestrictedWritable.updateSetPhase}.
    error RestrictedWritable_EmptyPhase();
    error RestrictedWritable_EndInPast();
    /// @dev Thrown when a new phase is created with a status different from `NOT_STARTED`.
    error RestrictedWritable_NewPhaseStatus();
    /// @dev Thrown when the phase status is equal to `avoid`.
    error RestrictedWritable_PhaseMatched(Status avoid, Status phaseStatus);
    error RestrictedWritable_PhaseMaxCapIsZero();
    error RestrictedWritable_PhaseMerkleRootIsZero();
    /// @dev Thrown when the phase status is not equal to the one expected.
    error RestrictedWritable_PhaseNotMatched(Status expected, Status current);
    error RestrictedWritable_PhaseStartGteEnd();
    error RestrictedWritable_ReceiverIsZeroAddr();
    /// @dev Thrown when the sale status is equal to `avoid`.
    error RestrictedWritable_SaleMatched(Status avoid, Status saleStatus);
    /// @dev Thrown when the sale status is not equal to the one expected.
    error RestrictedWritable_SaleNotMatched(Status expected, Status current);
    error RestrictedWritable_StartAfterEnd();
    error RestrictedWritable_EndBeforeStart();
    error RestrictedWritable_TokenIsZeroAddr();

    event PhaseEndDateUpdated(
        string indexed phaseId,
        uint256 indexed oldEndDate,
        uint256 indexed newEndDate
    );
    event PhaseMaxCapUpdated(
        string indexed phaseId,
        uint256 indexed oldMaxCap,
        uint256 indexed newMaxCap
    );
    event PhaseMerkleRootUpdated(
        string indexed phaseId,
        bytes32 indexed oldMerkleRoot,
        bytes32 indexed newMerkleRoot
    );
    event PhaseOpened(string indexed phaseName);
    event PhasePaused(string indexed phaseName);
    event PhaseResumed(string indexed phaseName);
    event PhaseStartDateUpdated(
        string indexed phaseId,
        uint256 indexed oldStartDate,
        uint256 indexed newStartDate
    );
    event RecoveredLostERC20(
        address indexed token,
        address indexed to,
        uint256 indexed amount
    );
    event SaleClosed();
    event SaleOpened();
    event SalePaused();
    event SaleResumed();
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {Initializable} from "openzeppelin-contracts/proxy/utils/Initializable.sol";

import {IRestrictedWritable} from "./IRestrictedWritable.sol";

import {IGOStorage} from "../../../igo/IGOStorage.sol";
import {SaleStorage} from "../../SaleStorage.sol";

import {RestrictedWritableInternal} from "./RestrictedWritableInternal.sol";

// import struct
import {Status, Phase} from "../../SaleStruct.sol";

/**
 * @title RestrictedWritable
 */
contract RestrictedWritable is
    IRestrictedWritable, // 1 inherited component
    RestrictedWritableInternal, // 2 inherited component
    Initializable // 1 inherited component
{
    using SafeERC20 for IERC20;

    /// @inheritdoc IRestrictedWritable
    function closeSale() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _closeSale();
        emit SaleClosed();
    }

    function openSale() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSale(Status.NOT_STARTED);
        _openSale();

        emit SaleOpened();
    }

    function pauseSale() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSale(Status.OPENED);
        SaleStorage.layout().ledger.status = Status.PAUSED;

        emit SalePaused();
    }

    function resumeSale() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSale(Status.PAUSED);
        SaleStorage.layout().ledger.status = Status.OPENED;

        emit SaleResumed();
    }

    /// @inheritdoc IRestrictedWritable
    function recoverLostERC20(
        address token,
        address to
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (token == address(0)) revert RestrictedWritable_TokenIsZeroAddr();
        if (to == address(0)) revert RestrictedWritable_ReceiverIsZeroAddr();

        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);

        emit RecoveredLostERC20(token, to, amount);
    }

    function closePhases(
        string[] calldata phaseIds
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < phaseIds.length; i++) {
            if (
                block.timestamp >=
                SaleStorage.layout().phases.data[phaseIds[i]].endAt
            ) {
                _closePhase(phaseIds[i]);
            }
        }
    }

    //////////////////////////// PHASE SINGLE UPDATE ////////////////////////////
    /// @inheritdoc IRestrictedWritable
    function openPhase(
        string calldata phaseId
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhase(Status.NOT_STARTED, phaseId);
        _openPhase(phaseId);

        emit PhaseOpened(phaseId);
    }

    function pausePhase(
        string calldata phaseId
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhase(Status.OPENED, phaseId);
        SaleStorage.layout().phases.data[phaseId].status = Status.PAUSED;

        emit PhasePaused(phaseId);
    }

    function resumePhase(
        string calldata phaseId
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhase(Status.PAUSED, phaseId);
        SaleStorage.layout().phases.data[phaseId].status = Status.OPENED;

        emit PhaseResumed(phaseId);
    }

    function updatePhaseEndDate(
        string calldata phaseId,
        uint128 endAt
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhaseNot(Status.COMPLETED, phaseId);

        if (endAt <= block.timestamp) {
            revert RestrictedWritable_EndInPast();
        }

        if (endAt <= SaleStorage.layout().phases.data[phaseId].startAt) {
            revert RestrictedWritable_EndBeforeStart();
        }

        emit PhaseEndDateUpdated(
            phaseId,
            SaleStorage.layout().phases.data[phaseId].endAt,
            endAt
        );

        SaleStorage.layout().phases.data[phaseId].endAt = endAt;
    }

    /// @inheritdoc IRestrictedWritable
    function updatePhaseMaxCapAndMerkleRoot(
        string calldata phaseId,
        uint256 maxPhaseCap,
        bytes32 merkleRoot
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        /// @custom:audit verifies underneath the phase is not completed
        updatePhaseMerkleRoot(phaseId, merkleRoot);

        uint256 summedMaxPhaseCap = SaleStorage
            .layout()
            .ledger
            .summedMaxPhaseCap;

        summedMaxPhaseCap -= SaleStorage
            .layout()
            .phases
            .data[phaseId]
            .maxPhaseCap;
        summedMaxPhaseCap += maxPhaseCap;

        emit PhaseMaxCapUpdated(
            phaseId,
            SaleStorage.layout().phases.data[phaseId].maxPhaseCap,
            maxPhaseCap
        );
        SaleStorage.layout().phases.data[phaseId].maxPhaseCap = maxPhaseCap;
        SaleStorage.layout().ledger.summedMaxPhaseCap = summedMaxPhaseCap;
    }

    /// @inheritdoc IRestrictedWritable
    function updatePhaseMerkleRoot(
        string calldata phaseId,
        bytes32 merkleRoot
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhaseNot(Status.COMPLETED, phaseId);
        if (merkleRoot == bytes32(0)) {
            revert RestrictedWritable_EmptyMerkleRoot();
        }

        emit PhaseMerkleRootUpdated(
            phaseId,
            SaleStorage.layout().phases.data[phaseId].merkleRoot,
            merkleRoot
        );
        SaleStorage.layout().phases.data[phaseId].merkleRoot = merkleRoot;
    }

    /// @inheritdoc IRestrictedWritable
    function updatePhaseStartDate(
        string calldata phaseId,
        uint128 startAt
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isPhase(Status.NOT_STARTED, phaseId);

        if (startAt >= SaleStorage.layout().phases.data[phaseId].endAt) {
            revert RestrictedWritable_StartAfterEnd();
        }

        emit PhaseStartDateUpdated(
            phaseId,
            SaleStorage.layout().phases.data[phaseId].startAt,
            startAt
        );

        SaleStorage.layout().phases.data[phaseId].startAt = startAt;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {AccessControlEnumerable} from "openzeppelin-contracts/access/AccessControlEnumerable.sol";

import {IRestrictedWritableInternal} from "./IRestrictedWritableInternal.sol";

import {SaleStorage} from "../../SaleStorage.sol";

// import struct
import {Status, Phase} from "../../SaleStruct.sol";

/**
 * @title RestrictedWritableInternal
 * @notice Defines the internal functions of `RestrictedWritable` contract.
 */
contract RestrictedWritableInternal is
    IRestrictedWritableInternal, // 1 inherited component
    AccessControlEnumerable // 8 inherited component
{
    function _checkPhaseData(
        uint256 oldMaxPhaseCap,
        Phase calldata phase_
    ) internal view {
        if (oldMaxPhaseCap == 0) {
            // if it is a new phase phase MUST be NOT_STARTED
            if (phase_.status != Status.NOT_STARTED) {
                revert RestrictedWritable_NewPhaseStatus();
            }
        }
        if (phase_.merkleRoot == bytes32(0)) {
            revert RestrictedWritable_PhaseMerkleRootIsZero();
        }
        /**
         * @dev Phase can start in the past as we can have a phase that is already started BUT contract has
         *      been deployed later due to unexpected reasons.
         */
        if (phase_.startAt >= phase_.endAt) {
            revert RestrictedWritable_PhaseStartGteEnd();
        }

        if (phase_.endAt <= block.timestamp) {
            revert RestrictedWritable_EndInPast();
        }

        if (phase_.maxPhaseCap == 0) {
            revert RestrictedWritable_PhaseMaxCapIsZero();
        }
    }

    /// @param phaseId Phase identifier to close.
    function _closePhase(string memory phaseId) internal {
        SaleStorage.layout().phases.data[phaseId].status = Status.COMPLETED;
    }

    function _closeSale() internal {
        SaleStorage.layout().ledger.status = Status.COMPLETED;
    }

    function _initializeSale(SaleStorage.SetUp calldata saleSetUp) internal {
        if (saleSetUp.permit2 == address(0))
            revert RestrictedWritable_Init_Permit2IsZeroAddr();

        SaleStorage.layout().setUp = saleSetUp;
    }

    function _openPhase(string memory phaseId) internal {
        SaleStorage.layout().phases.data[phaseId].status = Status.OPENED;
    }

    function _openSale() internal {
        SaleStorage.layout().ledger.status = Status.OPENED;
    }

    function _setOwnerRights(address owner) internal {
        if (owner == address(0)) {
            revert RestrictedWritable_Init_OwnerIsZeroAddr();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function _checkTimestampsForUpdatedPhase(
        uint128 oldStartAt,
        uint128 oldEndAt,
        uint128 startAt,
        uint128 endAt,
        string calldata phaseId_
    ) internal view {
        // if startAt is changed, existing phase should be in NOT_STARTED state
        if (oldStartAt != startAt) {
            _isPhase(Status.NOT_STARTED, phaseId_);
        }

        // if endAt is changed, existing phase should not be in COMPLETED state
        if (oldEndAt != endAt) {
            _isPhaseNot(Status.COMPLETED, phaseId_);
        }
    }

    /**
     * @notice Set the data of phase or update it if it already exists.
     *
     * @param summedMaxPhaseCap The sum of all max amount to raise per phase before updating this phase,
     *                          expressed in {SaleStorage.SetUp.paymentToken}
     * @param oldMaxPhaseCap The max amount to raise for the phase before updating it,
     *                       expressed in {SaleStorage.SetUp.paymentToken}.
     * @param phase_ The phase's data to save.
     * @param phaseId_ The phase identifier.
     */
    function _setPhase(
        uint256 summedMaxPhaseCap,
        uint256 oldMaxPhaseCap,
        Phase calldata phase_,
        string calldata phaseId_
    ) internal {
        _checkPhaseData(oldMaxPhaseCap, phase_);

        if (oldMaxPhaseCap != 0) {
            _checkTimestampsForUpdatedPhase(
                SaleStorage.layout().phases.data[phaseId_].startAt,
                SaleStorage.layout().phases.data[phaseId_].endAt,
                phase_.startAt,
                phase_.endAt,
                phaseId_
            );
        }

        summedMaxPhaseCap -= oldMaxPhaseCap;
        summedMaxPhaseCap += phase_.maxPhaseCap;

        // if phase does not exist, push to ids
        if (oldMaxPhaseCap == 0)
            SaleStorage.layout().phases.ids.push(phaseId_);
        SaleStorage.layout().phases.data[phaseId_] = phase_;

        SaleStorage.layout().ledger.summedMaxPhaseCap = summedMaxPhaseCap;
    }

    function _isPhase(Status expected, string calldata phaseId) internal view {
        Status phaseStatus = SaleStorage.layout().phases.data[phaseId].status;

        if (phaseStatus != expected) {
            revert RestrictedWritable_PhaseNotMatched(expected, phaseStatus);
        }
    }

    /// @dev If **phase status** is NOT equals `avoid` it passes silently, otherwise it reverts.
    function _isPhaseNot(Status avoid, string calldata phaseId) internal view {
        Status phaseStatus = SaleStorage.layout().phases.data[phaseId].status;

        if (phaseStatus == avoid) {
            revert RestrictedWritable_PhaseMatched(avoid, phaseStatus);
        }
    }

    function _isSale(Status expected) internal view {
        Status current = SaleStorage.layout().ledger.status;
        if (current != expected) {
            revert RestrictedWritable_SaleNotMatched(expected, current);
        }
    }

    /// @dev If **sale status** is NOT equals `avoid` it passes silently, otherwise it reverts.
    function _isSaleNot(Status avoid) internal view {
        Status current = SaleStorage.layout().ledger.status;
        if (current == avoid) {
            revert RestrictedWritable_SaleMatched(avoid, current);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/**
 * @author https://github.com/Theo6890
 * @title IGOStorage
 * @notice Mapps the storage layout of the {IGO} contract.
 * @dev Diamond proxy (ERC-2535) storage style.
 */
library IGOStorage {
    /**
     * @notice Struct reprensenting the main setup of the IGO.
     *
     * @param vestingContract Address of the {IGOVesting} contract.
     * @param refundFeeDecimals Number of decimals used for {IIGOWritableInternal.Allocation.refundFee}.
     */
    struct SetUp {
        address vestingContract;
        uint256 refundFeeDecimals;
    }

    /**
     * @notice Struct reprensenting the whole storage layout of the IGO contract.
     *
     * @param setUp Struct reprensenting the main setup of the IGO.
     */
    struct IGOStruct {
        SetUp setUp;
    }

    /// @notice Storage position of {IGOStruct} in {IGO} contract.
    bytes32 public constant IGO_STORAGE = keccak256("igo.storage");

    /**
     * @return igoStruct Whole storage of {IGO} contract.
     */
    function layout() internal pure returns (IGOStruct storage igoStruct) {
        bytes32 position = IGO_STORAGE;
        assembly {
            igoStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {INOWritable} from "./writable/INOWritable.sol";
import {INOReadable} from "./readable/INOReadable.sol";

/**
 * @title INO
 * @notice Initial NFT Offering contract.
 * @dev Constructor replaced by the `initialize` function in {INOWritable}.
 */
contract INO is
    INOWritable, // 21 inherited component
    INOReadable // 7 inherited components
{}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

/**
 * @title INOStorage
 * @notice Mapps the storage layout of the {INO} contract.
 * @dev Diamond proxy (ERC-2535) storage style.
 */
library INOStorage {
    /**
     * @notice Struct reprensenting the main setup of the INO.
     *
     * @param paymentReceiver The address which will receive the funds from the INO.
     * @param projectWallet The address of the project issuing NFTs - transfer ownership once sale closed.
     */
    struct SetUp {
        address paymentReceiver;
        address projectWallet;
    }

    /**
     * @notice Struct reprensenting the data of the NFT collection to be deployed through INO.
     *
     * @param name The name of the NFTs to be minted during the INO.
     * @param symbol The symbol of the NFTs to be minted during the INO.
     * @param uri The base URI of the NFTs to be minted during the INO - only used for reveal on minint,
     *        otherwise the uri will be an empty string (blackbox and reveal date cases).
     * @param maxCap The maximum number of NFTs to be minted during and after (if not sold out) the INO.
     * @param startTokenId The first token id to be minted during the INO.
     */
    struct NFTCollectionData {
        string name;
        string symbol;
        string uri;
        uint256 maxCap;
        uint256 startTokenId;
    }

    /**
     * @notice Struct reprensenting the whole storage layout of the INO contract.
     *
     * @param setUp Struct reprensenting the main setup of the INO - modified by owner interactions only.
     * @param nftData Struct reprensenting the data of the NFT collection to be deployed through INO
     *                - modified by owner interactions only.
     * @param collection The address of the NFT collection to be deployed and minted through INO - modified
     *                   by owner interactions only.
     * @param phaseMaxMint Maximum number of NFTs to be minted in a specific phase - modified by owner
     *                     interactions only.
     * @param mintedInPhase Number of NFTs minted in a specific phase - modified by INO contract
     *                      interaction.
     * @param totalMinted Total number of NFTs minted in the whole INO - modified by INO contract
     *                    interaction.
     */
    struct INOStruct {
        // modified by owner interactions only
        SetUp setUp;
        NFTCollectionData nftData;
        address collection;
        mapping(string => uint256) phaseMaxMint;
        // modified by INO contract interaction
        mapping(string => uint256) mintedInPhase;
        uint256 totalMinted;
    }

    /// @notice Storage position of {INOStruct} in {INO} contract.
    bytes32 public constant INO_STORAGE = keccak256("ino.storage");

    /**
     * @return inoStruct Whole storage of {INO} contract.
     */
    function layout() internal pure returns (INOStruct storage inoStruct) {
        bytes32 position = INO_STORAGE;
        assembly {
            inoStruct.slot := position
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Phase} from "../common/SaleStruct.sol";

/**
 * @notice Struct representing a free allocation and user based for a specific phase of a sale.
 *         Whitelisted addresses will mint NFTs for free.
 *
 * @param phaseId Phase identifier of the current sale.
 * @param toMint Amount of NFT to be minted.
 * @param account Wallet address of the buyer.
 */
struct FreeAllocation {
    string phaseId;
    uint256 toMint;
    address account;
}

/**
 * @notice Struct representing a phase of an INO sale.
 *
 * @param base Phase struct from {SaleStruct} shared with IGO sales.
 * @param phaseMaxMint Maximum amount of NFTs that can be minted in this phase.
 */
struct INOPhase {
    Phase base;
    uint256 phaseMaxMint;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {INOStorage} from "../../INOStorage.sol";

/**
 * @title INFT
 * @notice Define external and public functions used by NFTs listed in INOs.
 */
interface INFT {
    /// @dev Removes default royalty information.
    function deleteDefaultRoyalty() external;

    /**
     * @notice Initialize a clones NFT to sell & mint for an INO.
     * @dev Need to be public as childs override it while calling {super.initialize()}.
     *
     * @param data The NFT collection data.
     * @param initialOwner The initial owner of the NFT collection.
     * @param ino_ The linked INO contract address.
     */
    function initialize(
        INOStorage.NFTCollectionData calldata data,
        address initialOwner,
        address ino_
    ) external;

    /**
     * @notice Mint tokens, restricted to the INO contract.
     *
     * @dev    If the implementing token uses _safeMint(), or a feeRecipient with a malicious receive()
     *         hook is specified, the token or fee recipients may be able to execute another mint in the
     *         same transaction via a separate INO contract.
     *         This is dangerous if an implementing token does not correctly update the minterNumMinted
     *         and currentTotalSupply values before transferring minted tokens, as INO references these
     *         values to enforce token limits on a per-wallet and per-stage basis.
     *
     *         ERC721A tracks these values automatically, but this note and nonReentrant modifier are left
     *         here to encourage best-practices when referencing this contract.
     *
     * @param minter The address to mint to.
     * @param quantity The number of tokens to mint.
     */
    function mint(address minter, uint256 quantity) external;

    /**
     * @notice Mint all unsold NFTs to `receiver`.
     */
    function postmintAllUnsold(address receiver) external;

    /// @notice Mints `toMint` to `receiver` and reduces the max supply if does not mint all left.
    function postmintAndReduceSupply(
        address receiver,
        uint256 toMint
    ) external returns (uint256 reducedBy);

    /**
     * @notice Allow NFT collection owner to mint NFTs to his wallet BEFORE the INO starts. Mostly used to
     *         reward the team behind the project. Can also be used if airdrops/giveaway are introduced
     *         after the INO contract has been deployed.
     * @dev Can not be called even if INO is paused.
     */
    function premint(address receiver, uint256 amount) external;

    /**
     * @notice BE CAREFUL: once max supply is reduced it can never be increased again.
     * @dev Can only reduce the max supply between `totalSupply()` and `maxSupply()`.
     */
    function reduceSupplyTo(uint256 newMaxSupply) external;

    /// @dev Resets royalty information for the token id back to the global default.
    function resetTokenRoyalty(uint256 tokenId) external;

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * @param receiver Address receiving royalties.
     * @param feeNumerator Royalties in basis points.
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external;

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) external;

    /**
     * @notice Returns a set of mint stats for the address.
     *
     * @dev NOTE: Implementing contracts should always update these numbers before transferring any tokens
     *            with _safeMint() to mitigate consequences of malicious onERC721Received() hooks.
     *
     * @param minter The minter address.
     *
     * @return minterNumMinted The number of tokens minted by `minter`.
     * @return currentTotalSupply The current total supply of NFT.
     * @return maxSupply The maximum supply of NFT.
     */
    function getMintStats(
        address minter
    )
        external
        view
        returns (
            uint256 minterNumMinted,
            uint256 currentTotalSupply,
            uint256 maxSupply
        );
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {INOStorage} from "../INOStorage.sol";

interface IINOReadable {
    /**
     * @param phaseId The ID of the phase to get the max mintable amount.
     * @return phaseMaxMint The maximum amount of NFTs that can be minted in the phase.
     */
    function phaseMaxMint(
        string calldata phaseId
    ) external view returns (uint256);

    /**
     * @return 
            - `paymentReceiver` address of the wallet to receive the payments
            - `projectWallet` address of the project which will receive
              the NFT owner rights after the INO ends.
     */
    function inoSetUp() external view returns (INOStorage.SetUp memory);

    /// @dev Amount of NFTs minted by users in a specific phase.
    function mintedInPhase(
        string calldata phaseId
    ) external view returns (uint256);

    /// @dev Address of the NFT collection contract to mint when buying.
    function nftCollection() external view returns (address);

    function nftCollectionData()
        external
        view
        returns (INOStorage.NFTCollectionData memory);

    /// @dev Amount of NFTs minted by users in the whole INO.
    function totalMinted() external view returns (uint256);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {SaleReadable} from "../../common/readable/SaleReadable.sol";

import {IINOReadable} from "./IINOReadable.sol";

import {INOStorage} from "../INOStorage.sol";

/**
 * @title INOReadable
 * @notice Initial NFT Offering contract.
 * @dev Constructor replaced by the `initialize` function in {INOWritable}.
 */
contract INOReadable is
    IINOReadable, // 1 inherited component
    SaleReadable // 5 inherited components
{
    /// @inheritdoc IINOReadable
    function phaseMaxMint(
        string calldata phaseId
    ) public view override returns (uint256) {
        return INOStorage.layout().phaseMaxMint[phaseId];
    }

    /// @inheritdoc IINOReadable
    function inoSetUp()
        public
        view
        override
        returns (INOStorage.SetUp memory)
    {
        return INOStorage.layout().setUp;
    }

    /// @inheritdoc IINOReadable
    function mintedInPhase(
        string calldata phaseId
    ) public view override returns (uint256) {
        return INOStorage.layout().mintedInPhase[phaseId];
    }

    /// @inheritdoc IINOReadable
    function nftCollection() public view override returns (address) {
        return INOStorage.layout().collection;
    }

    function nftCollectionData()
        public
        view
        override
        returns (INOStorage.NFTCollectionData memory)
    {
        return INOStorage.layout().nftData;
    }

    /// @inheritdoc IINOReadable
    function totalMinted() public view override returns (uint256) {
        return INOStorage.layout().totalMinted;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {BuyPermission} from "../../common/SaleStruct.sol";
import {UserAllocationFee} from "../../common/UserAllocationStruct.sol";
import {FreeAllocation} from "../INOStruct.sol";

/**
 * @title IINOWritable
 * @notice Defines external and public functions for {INOWritable}.
 */
interface IINOWritable {
    /**
     * @notice Buy and mint NFTs with ERC20 tokens. If {SaleStorage.SetUp.paymentToken} is not set,
     *         this function will revert and tell the user to use {buyAndMintWithNative} instead.
     *
     * @param spendNow Amount of ERC20 tokens to spend now.
     * @param allocation Allocation data of an `acount`.
     * @param proof Merkle tree proof of an `acount`'s allocation.
     * @param permission Permission data of an `acount`.
     */
    function buyAndMintWithERC20(
        uint256 spendNow,
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof,
        BuyPermission calldata permission
    ) external;

    /**
     * @notice Buy and mint NFTs with blockchain's native currency (ETH, BNB, MATIC, etc...). If
     *         {SaleStorage.SetUp.paymentToken} is set, this function will revert and tell the user to use
     *         {buyAndMintWithERC20} instead.
     *
     * @param allocation Allocation data of an `acount`.
     * @param proof Merkle tree proof of an `acount`'s allocation.
     */
    function buyAndMintWithNative(
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof
    ) external payable;

    /**
     * @notice Allows whitelisted addresses to mint NFTs for free/giveaways.
     *
     * @param allocation Allocation data of an `acount`.
     * @param proof Merkle tree proof of an `acount`'s allocation.
     */
    function freeMint(
        FreeAllocation calldata allocation,
        bytes32[] calldata proof
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {Status} from "../../common/SaleStruct.sol";

/**
 * @title IINOWritableInternal
 * @notice Defines enum, struct, event and errors for INO.
 */
interface IINOWritableInternal {
    error INO_IncorrectNativeAmount(uint256 sent, uint256 price);
    error INO_IncorrectERC20Amount(uint256 sent, uint256 price);
    error INO_MaxMintINOReached(uint256 maxMint, uint256 exceedBy);
    error INO_MaxMintInPhaseReached(uint256 maxMintInPhase, uint256 exceedBy);
    error INO_NativePaymentFailed(bytes data);
    error INO_OnlyUseMultipleOf(uint256 multiple);
    error INO_UseInstead(string);
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IINOWritable} from "./IINOWritable.sol";
import {INFT} from "../nft/interfaces/INFT.sol";

import {INOWritableInternal} from "./INOWritableInternal.sol";

import {INORestricted} from "./restricted/INORestricted.sol";

import {SaleStorage} from "../../common/SaleStorage.sol";
import {INOStorage} from "../INOStorage.sol";

// import struct
import {BuyPermission, Phase} from "../../common/SaleStruct.sol";
import {FreeAllocation} from "../INOStruct.sol";
import {UserAllocationFee} from "../../common/UserAllocationStruct.sol";

/**
 * @title INO
 * @notice Initial NFT Offering contract.
 * @dev This contract is used to deploy the NFT collection to mint/sale and handle the sale.
 */
contract INOWritable is
    IINOWritable, // 1 inherited component
    INOWritableInternal, // 6 inherited components
    INORestricted // 13 inherited components
{
    function buyAndMintWithERC20(
        uint256 spendNow,
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof,
        BuyPermission calldata permission
    ) external override {
        SaleStorage.SetUp memory saleSetUp = SaleStorage.layout().setUp;

        if (saleSetUp.paymentToken == address(0)) {
            revert INO_UseInstead("buyAndMintWithNative");
        }

        _mintAndUpdateStorage(
            spendNow,
            allocation,
            proof,
            SaleStorage.layout().ledger.summedMaxPhaseCap
        );

        /**
         * @dev transfer selected {paymentToken} to receiver wallet via permit2
         * read from storage as there is not point to pass `setUp`s as parameters, cost a bit more BUT
         * better dev experience
         */
        _permit2ApproveAndTransfer(
            saleSetUp.permit2,
            msg.sender, // allow delegate to spend
            INOStorage.layout().setUp.paymentReceiver,
            saleSetUp.paymentToken,
            spendNow,
            permission
        );
    }

    /// @inheritdoc IINOWritable
    function buyAndMintWithNative(
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof
    ) external payable override {
        uint256 spendNow = msg.value;
        if (SaleStorage.layout().setUp.paymentToken != address(0)) {
            revert INO_UseInstead("buyAndMintWithERC20");
        }

        _mintAndUpdateStorage(
            spendNow,
            allocation,
            proof,
            SaleStorage.layout().ledger.summedMaxPhaseCap
        );

        // transfer ETH to receiver wallet
        (bool ok, bytes memory data) = INOStorage
            .layout()
            .setUp
            .paymentReceiver
            .call{value: msg.value}(""); // delegate can also spend on behalf of the user
        if (!ok) {
            revert INO_NativePaymentFailed(data);
        }
    }

    function freeMint(
        FreeAllocation calldata allocation,
        bytes32[] calldata proof
    ) external override {
        _checkFreeMintParams(allocation, proof);

        _updateStorageOnFreeMint(
            allocation.phaseId,
            allocation.account,
            allocation.toMint
        );
        _updateMintedAmount(allocation.phaseId, allocation.toMint);

        INFT(INOStorage.layout().collection).mint(
            allocation.account, // allow a delegate wallet to mint on behalf of the user
            allocation.toMint // mint whole free allocation in once
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import {SaleWritableInternal} from "../../common/writable/SaleWritableInternal.sol";
import {IINOWritable} from "./IINOWritable.sol";
import {IINOWritableInternal} from "./IINOWritableInternal.sol";
import {INFT} from "../nft/interfaces/INFT.sol";

import {SaleStorage} from "../../common/SaleStorage.sol";
import {INOStorage} from "../INOStorage.sol";

// import struct
import {Phase} from "../../common/SaleStruct.sol";
import {FreeAllocation} from "../INOStruct.sol";
import {UserAllocationFee} from "../../common/UserAllocationStruct.sol";

/**
 * @title INO
 * @notice Initial NFT Offering contract.
 * @notice Defines internal functions for `INOWritable`.
 */
contract INOWritableInternal is
    SaleWritableInternal, // 4 inherited components
    IINOWritableInternal // 1 inherited component
{
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// PARAMS CHECKS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    function _checkBuyAndMintParams(
        uint256 toMint,
        uint256 reserveNow,
        UserAllocationFee calldata allocation,
        uint256 summedMaxPhaseCap,
        uint256 maxPhaseCap,
        bytes32[] calldata proof
    ) internal {
        _checkMaxMintInPhase(allocation.usrData.base.phaseId, toMint);
        _checkMaxMintWholeINO(toMint);

        _checkBuyReserveParams(
            reserveNow,
            allocation,
            allocation.usrData.base.phaseId,
            summedMaxPhaseCap,
            maxPhaseCap,
            proof
        );
    }

    function _checkFreeMintParams(
        FreeAllocation calldata allocation,
        bytes32[] calldata proof
    ) internal {
        _checkMaxMintInPhase(allocation.phaseId, allocation.toMint);
        _checkMaxMintWholeINO(allocation.toMint);

        // both replace {_checkBuyReserveParams} call
        _requireOpenedSaleAndPhase(allocation.phaseId);
        _checkValidFreeAllocation(allocation, proof);
    }

    function _checkMaxMintInPhase(
        string calldata phaseId,
        uint256 toMint
    ) internal view {
        uint256 maxMintInPhase = INOStorage.layout().phaseMaxMint[phaseId];

        uint256 mintedInPhase = INOStorage.layout().mintedInPhase[phaseId];
        uint256 newTotal = mintedInPhase + toMint;

        if (newTotal > maxMintInPhase) {
            revert INO_MaxMintInPhaseReached(
                maxMintInPhase,
                newTotal - maxMintInPhase
            );
        }
    }

    function _checkMaxMintWholeINO(uint256 toMint) internal view {
        uint256 maxMint = INOStorage.layout().nftData.maxCap;
        uint256 minted = INOStorage.layout().totalMinted;
        uint256 newTotal = minted + toMint;

        if (newTotal > maxMint) {
            revert INO_MaxMintINOReached(maxMint, newTotal - maxMint);
        }
    }

    /// @dev Different params from `SaleWritableInternal._requireValidAllocation` BUT same logic
    function _checkValidFreeAllocation(
        FreeAllocation calldata allocation,
        bytes32[] calldata proof
    ) internal view returns (bool) {
        if (
            !MerkleProof.verify(
                proof,
                SaleStorage
                    .layout()
                    .phases
                    .data[allocation.phaseId]
                    .merkleRoot,
                keccak256(abi.encode(address(this), block.chainid, allocation))
            )
        ) revert SaleWritableInternal_AllocationNotFound();

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// STORAGE UPDATE ///////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    function _mintAndUpdateStorage(
        uint256 spendNow,
        UserAllocationFee calldata allocation,
        bytes32[] calldata proof,
        uint256 summedMaxPhaseCap
    ) internal {
        string calldata phaseId = allocation.usrData.base.phaseId;
        uint256 unitPrice = allocation.usrData.base.saleTokenPerPaymentToken;
        /**
         * @custom:audit When backend creates the allocation, `maxAllocation` will be a multiple of
         *               `saleTokenPerPaymentToken` to avoid round down issue. In any case,
         *               the most important is that `spendNow` is a multiple of `saleTokenPerPaymentToken`.
         */
        uint256 maxAllocation = allocation.usrData.base.maxAllocation;
        /// @dev save the allocation of the user wallet (not the delegate wallet)
        uint256 bought = SaleStorage.layout().ledger.allocationReservedByIn[
            allocation.usrData.account
        ][phaseId];

        /**
         * @dev Solidity round down towards zero:
         *               - CAN NOT over-mint due to round up issue
         *               - CAN under-mint due to round down issue
         *
         * e.g.:
         * - maxAllocation = 100 ether
         * - saleTokenPerPaymentToken = 3 ether
         * user will mint 33 NFTs max, instead of 33.3333333333 NFTs.
         *
         * @dev To avoid under-mint issue, only allow a round down to happen if this transaction is the last one to mint all NFTs
         *      left allocated to the user in this phase.
         */
        // if not the last mint
        if (bought + spendNow != maxAllocation) {
            if (spendNow % unitPrice != 0) {
                revert INO_OnlyUseMultipleOf(unitPrice);
            }
        }

        uint256 toMint = spendNow / unitPrice;

        _checkBuyAndMintParams(
            toMint,
            spendNow,
            allocation,
            summedMaxPhaseCap,
            SaleStorage.layout().phases.data[phaseId].maxPhaseCap,
            proof
        );
        _updateStorageOnBuy( /// @custom:audit CEI pattern
            spendNow,
            phaseId,
            allocation.usrData.account,
            SaleStorage.layout().phases.data[phaseId].maxPhaseCap,
            toMint
        );

        // allow a delegate wallet to mint on behalf of the user
        INFT(INOStorage.layout().collection).mint(
            allocation.usrData.account,
            toMint
        );
    }

    function _updateMintedAmount(
        string calldata phaseId,
        uint256 toMint
    ) internal {
        INOStorage.layout().mintedInPhase[phaseId] += toMint;
        INOStorage.layout().totalMinted += toMint;
    }

    /// @custom:audit when total raised reached, it will close the phase and/or the whole sale
    function _updateStorageOnBuy(
        uint256 toSpend,
        string calldata phaseId,
        address buyer,
        uint256 maxMintPhaseCap,
        uint256 toMint
    ) internal {
        SaleWritableInternal._updateStorageOnBuy(
            toSpend,
            phaseId,
            buyer,
            maxMintPhaseCap
        );
        _updateMintedAmount(phaseId, toMint);
    }

    function _updateStorageOnFreeMint(
        string calldata phaseId,
        address buyer,
        uint256 toMint
    ) internal {
        SaleStorage.Ledger storage ledger = SaleStorage.layout().ledger;
        uint256 freeAllocationMintedBy = ledger.freeAllocationMintedBy[buyer][
            phaseId
        ];

        // avoids replay attack & whole allocation minted in one tx in {freeMint}
        if (freeAllocationMintedBy > 0) {
            revert SaleWritable_AllocationExceeded(toMint, toMint);
        }

        ledger.freeAllocationMintedBy[buyer][phaseId] += toMint;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

// import struct
import {Phase} from "../../../common/SaleStruct.sol";
import {INOPhase} from "../../INOStruct.sol";

// storage
import {INOStorage} from "../../INOStorage.sol";
import {SaleStorage} from "../../../common/SaleStorage.sol";

/**
 * @title IINORestricted
 * @notice Only the owner of the contract can call these methods.
 */
interface IINORestricted {
    /**
     * @notice Some projects will only do the sale through INO and will handle the NFT minting themselves.
     *         Others will do the mint and sale through INO. This function is used to deploy the NFT
     *         collection for the second case.
     * @dev Use {reinitializer(2)} as {initialize} is called first.
     *
     * @param nftToClone The address of the NFT to use as an NFT base.
     * @param data Data of the NFT collection to be deployed.
     */
    function deployNftToSell(
        address nftToClone,
        INOStorage.NFTCollectionData calldata data
    ) external returns (address collection);

    /**
     * @notice Use a single token for the whole INO (never changed once set here).
     *
     * @param saleSetUp Data of the sale to be deployed - common logic shared between IGOs and INOs.
     * @param owner Owner of the INO.
     * @param inoSetUp Data of the INO to be deployed.
     * @param phaseIds Default list of phase identifiers - can be empty array `new string[](0)`
     * @param phases Default list of phases - can be empty array `new INOPhase[](0)`
     */
    function initialize(
        SaleStorage.SetUp calldata saleSetUp,
        address owner,
        INOStorage.SetUp calldata inoSetUp,
        string[] calldata phaseIds,
        INOPhase[] calldata phases
    ) external;

    /**
     * @dev Update or create a phase with all its data.
     *
     * @param phaseId_ Identifier of phase to set or update.
     * @param phase_ Struct {INOPhase} containing INO phase's data to be saved.
     */
    function updateSetPhase(
        string calldata phaseId_,
        INOPhase calldata phase_
    ) external;

    /**
     * @dev Update or create multiple phases with all their data.
     *
     * @param phaseIdentifiers_ Array of identifiers of `phases`.
     * @param phases_ Array of struct {INOPhase} containing phases' data to be saved.
     */
    function updateSetPhases(
        string[] calldata phaseIdentifiers_,
        INOPhase[] calldata phases_
    ) external;

    function updatePhaseMaxMintAndMerkleRoot(
        string calldata phaseId,
        uint256 phaseMaxMint,
        bytes32 merkleRoot
    ) external;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {INOStorage} from "../../INOStorage.sol";
import {SaleStorage} from "../../../common/SaleStorage.sol";

// import struct
import {Status, Phase} from "../../../common/SaleStruct.sol";
import {INOPhase} from "../../INOStruct.sol";

/**
 * @title IINORestrictedInternal
 */
interface IINORestrictedInternal {
    error INORestricted_Init_PaymentReceiverIsZeroAddr();
    error INORestricted_Init_ProjectWalletIsZeroAddr();

    error INORestricted_SaleStarted(Status current);
    error INORestricted_Deploy_MaxCapNotSet();
    error INORestricted_Deploy_Name2CharsMin();
    error INORestricted_Deploy_NftToCloneIsZeroAddr();
    // error INORestricted_Deploy_SaleAlreadyStarted();
    error INORestricted_Deploy_Symbole1CharMin();

    event INO_DeployedNftToSell(
        address indexed collection,
        INOStorage.NFTCollectionData indexed data
    );
    event INO_Initialized(
        SaleStorage.SetUp indexed saleSetUp,
        address indexed owner,
        INOStorage.SetUp indexed igoSetUp,
        string[] phaseIds_,
        INOPhase[] phases
    );
    event INO_PhaseMaxMintUpdated(
        string indexed phaseId,
        uint256 indexed oldPhaseMaxMint,
        uint256 indexed newPhaseMaxMint
    );
    event INO_SinglePhaseUpdate(
        string indexed phaseId,
        Phase indexed oldData,
        INOPhase indexed newData
    );
    event INO_BatchPhaseUpdate(
        string[] indexed phaseId,
        INOPhase[] indexed phase
    );
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Clones} from "openzeppelin-contracts/proxy/Clones.sol";

import {INFT} from "../../nft/interfaces/INFT.sol";
import {IINORestricted} from "./IINORestricted.sol";
import {IINORestrictedInternal} from "./IINORestrictedInternal.sol";

import {RestrictedWritable} from "../../../common/writable/restricted/RestrictedWritable.sol";

// import struct
import {Status, Phase} from "../../../common/SaleStruct.sol";
import {INOPhase} from "../../INOStruct.sol";

// storage
import {INOStorage} from "../../INOStorage.sol";
import {SaleStorage} from "../../../common/SaleStorage.sol";

/**
 * @title IRestrictedWritable
 * @notice Only the owner of the contract can call these methods.
 */
contract INORestricted is
    IINORestricted,
    IINORestrictedInternal,
    RestrictedWritable
{
    /// @inheritdoc IINORestricted
    function initialize(
        SaleStorage.SetUp calldata saleSetUp,
        address owner,
        INOStorage.SetUp calldata inoSetUp,
        string[] calldata phaseIds,
        INOPhase[] calldata phases
    ) external override initializer {
        if (inoSetUp.paymentReceiver == address(0)) {
            revert INORestricted_Init_PaymentReceiverIsZeroAddr();
        }
        if (inoSetUp.projectWallet == address(0)) {
            revert INORestricted_Init_ProjectWalletIsZeroAddr();
        }

        // inherited from {RestrictedWritable.}
        _initializeSale(saleSetUp);
        _setOwnerRights(owner);

        INOStorage.layout().setUp = inoSetUp;

        // inherited from {RestrictedWritable.}
        _updateSetINOPhases(phaseIds, phases);

        emit INO_Initialized(saleSetUp, owner, inoSetUp, phaseIds, phases);
    }

    /// @inheritdoc IINORestricted
    function deployNftToSell(
        address nftToClone,
        INOStorage.NFTCollectionData calldata data
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        reinitializer(2)
        returns (address collection)
    {
        _requireSaleNotStarted();
        _checkValidClone(nftToClone);
        _checkNFTData(data);

        collection = _clone(nftToClone, data);

        INOStorage.layout().nftData = data;
        INOStorage.layout().collection = collection;

        INFT(collection).initialize(data, _msgSender(), address(this));

        emit INO_DeployedNftToSell(collection, data);
    }

    function updatePhaseMaxMintAndMerkleRoot(
        string calldata phaseId,
        uint256 phaseMaxMint,
        bytes32 merkleRoot
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        /// @custom:audit verifies underneath the phase is not completed
        updatePhaseMerkleRoot(phaseId, merkleRoot);

        emit INO_PhaseMaxMintUpdated(
            phaseId,
            INOStorage.layout().phaseMaxMint[phaseId],
            phaseMaxMint
        );

        INOStorage.layout().phaseMaxMint[phaseId] = phaseMaxMint;
    }

    /// @inheritdoc IINORestricted
    function updateSetPhase(
        string calldata phaseId_,
        INOPhase calldata phase_
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSaleNot(Status.COMPLETED);

        emit INO_SinglePhaseUpdate(
            phaseId_,
            SaleStorage.layout().phases.data[phaseId_],
            phase_
        );

        _updateSetINOPhase(phaseId_, phase_);
    } // TODO: gas report + testnet txs

    /// @inheritdoc IINORestricted
    function updateSetPhases(
        string[] calldata phaseIdentifiers_,
        INOPhase[] calldata phases_
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        _isSaleNot(Status.COMPLETED);

        // inherited from {RestrictedWritable}
        _updateSetINOPhases(phaseIdentifiers_, phases_);

        emit INO_BatchPhaseUpdate(phaseIdentifiers_, phases_);
    }

    function _clone(
        address nftToClone,
        INOStorage.NFTCollectionData calldata data
    ) internal returns (address) {
        bytes32 salt = keccak256(
            abi.encode(msg.sender, data, block.timestamp)
        );
        return Clones.cloneDeterministic(nftToClone, salt);
    }

    function _updateSetINOPhase(
        string calldata phaseId_,
        INOPhase calldata phase_
    ) internal {
        // inherited from {RestrictedWritable}
        _setPhase(
            SaleStorage.layout().ledger.summedMaxPhaseCap,
            SaleStorage.layout().phases.data[phaseId_].maxPhaseCap,
            phase_.base,
            phaseId_
        );

        INOStorage.layout().phaseMaxMint[phaseId_] = phase_.phaseMaxMint;
    }

    function _updateSetINOPhases(
        string[] calldata phaseIdentifiers_,
        INOPhase[] calldata phases_
    ) internal {
        if (phaseIdentifiers_.length != phases_.length) {
            revert RestrictedWritableInternal_DifferentArraysLength();
        }

        uint256 length = phaseIdentifiers_.length;

        //slither-disable-next-line uninitialized-local
        for (uint256 i; i < length; ++i) {
            /// @dev less¬ gas efficient, but more readable
            _updateSetINOPhase(phaseIdentifiers_[i], phases_[i]);
        }
    }

    function _requireSaleNotStarted() internal view {
        Status current = SaleStorage.layout().ledger.status;
        if (current != Status.NOT_STARTED) {
            revert INORestricted_SaleStarted(current);
        }
    }

    /// @dev Check name, symbol, and max cap of the NFT collection.
    function _checkNFTData(
        INOStorage.NFTCollectionData calldata data
    ) internal pure {
        if (bytes(data.name).length < 2) {
            revert INORestricted_Deploy_Name2CharsMin();
        }
        if (bytes(data.symbol).length < 1) {
            revert INORestricted_Deploy_Symbole1CharMin();
        }
        if (data.maxCap == 0) {
            revert INORestricted_Deploy_MaxCapNotSet();
        }
    }

    function _checkValidClone(address clone) internal pure {
        if (clone == address(0)) {
            revert INORestricted_Deploy_NftToCloneIsZeroAddr();
        }
    }
}