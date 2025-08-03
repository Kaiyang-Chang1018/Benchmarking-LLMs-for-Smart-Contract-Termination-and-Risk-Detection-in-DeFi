// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is
  Initializable,
  IAccessControlEnumerableUpgradeable,
  AccessControlUpgradeable
{
  function __AccessControlEnumerable_init() internal onlyInitializing {}

  function __AccessControlEnumerable_init_unchained()
    internal
    onlyInitializing
  {}

  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

  mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
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
  function getRoleMember(bytes32 role, uint256 index)
    public
    view
    virtual
    override
    returns (address)
  {
    return _roleMembers[role].at(index);
  }

  /**
   * @dev Returns the number of accounts that have `role`. Can be used
   * together with {getRoleMember} to enumerate all bearers of a role.
   */
  function getRoleMemberCount(bytes32 role)
    public
    view
    virtual
    override
    returns (uint256)
  {
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
  function _revokeRole(bytes32 role, address account)
    internal
    virtual
    override
  {
    super._revokeRole(role, account);
    _roleMembers[role].remove(account);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/utils/ERC165Upgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is
  Initializable,
  ContextUpgradeable,
  IAccessControlUpgradeable,
  ERC165Upgradeable
{
  function __AccessControl_init() internal onlyInitializing {}

  function __AccessControl_init_unchained() internal onlyInitializing {}

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
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev Returns `true` if `account` has been granted `role`.
   */
  function hasRole(bytes32 role, address account)
    public
    view
    virtual
    override
    returns (bool)
  {
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
            StringsUpgradeable.toHexString(uint160(account), 20),
            " is missing role ",
            StringsUpgradeable.toHexString(uint256(role), 32)
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
  function getRoleAdmin(bytes32 role)
    public
    view
    virtual
    override
    returns (bytes32)
  {
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
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
    require(
      account == _msgSender(),
      "AccessControl: can only renounce roles for self"
    );

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

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
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
  function getRoleMember(bytes32 role, uint256 index)
    external
    view
    returns (address);

  /**
   * @dev Returns the number of accounts that have `role`. Can be used
   * together with {getRoleMember} to enumerate all bearers of a role.
   */
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
  /**
   * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
   *
   * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
   * {RoleAdminChanged} not being emitted signaling this.
   *
   * _Available since v3.1._
   */
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );

  /**
   * @dev Emitted when `account` is granted `role`.
   *
   * `sender` is the account that originated the contract call, an admin role
   * bearer except when using {AccessControl-_setupRole}.
   */
  event RoleGranted(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );

  /**
   * @dev Emitted when `account` is revoked `role`.
   *
   * `sender` is the account that originated the contract call:
   *   - if using `revokeRole`, it is the admin role bearer
   *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
   */
  event RoleRevoked(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );

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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "contracts/external/openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
   * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
   */
  modifier initializer() {
    bool isTopLevelCall = !_initializing;
    require(
      (isTopLevelCall && _initialized < 1) ||
        (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
   * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
   * initialization step. This is essential to configure modules that are added through upgrades and that require
   * initialization.
   *
   * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
   * a contract, executing them in the right order is up to the developer or operator.
   */
  modifier reinitializer(uint8 version) {
    require(
      !_initializing && _initialized < version,
      "Initializable: contract is already initialized"
    );
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
   */
  function _disableInitializers() internal virtual {
    require(!_initializing, "Initializable: contract is initializing");
    if (_initialized < type(uint8).max) {
      _initialized = type(uint8).max;
      emit Initialized(type(uint8).max);
    }
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
  function __Pausable_init() internal onlyInitializing {
    __Pausable_init_unchained();
  }

  function __Pausable_init_unchained() internal onlyInitializing {
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

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(
      success,
      "Address: unable to send value, recipient may have reverted"
    );
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
  function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return functionCall(target, data, "Address: low-level call failed");
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
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return
      functionCallWithValue(
        target,
        data,
        value,
        "Address: low-level call with value failed"
      );
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
    require(
      address(this).balance >= value,
      "Address: insufficient balance for call"
    );
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
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
    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
   * revert reason using the provided one.
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal onlyInitializing {}

  function __Context_init_unchained() internal onlyInitializing {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts-upgradeable/utils/IERC165Upgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
  function __ERC165_init() internal onlyInitializing {}

  function __ERC165_init_unchained() internal onlyInitializing {}

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return interfaceId == type(IERC165Upgradeable).interfaceId;
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 * ```
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
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
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
  function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
  {
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
  function remove(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
  {
    return _remove(set._inner, value);
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(Bytes32Set storage set, bytes32 value)
    internal
    view
    returns (bool)
  {
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
  function at(Bytes32Set storage set, uint256 index)
    internal
    view
    returns (bytes32)
  {
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
  function values(Bytes32Set storage set)
    internal
    view
    returns (bytes32[] memory)
  {
    return _values(set._inner);
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
  function remove(AddressSet storage set, address value)
    internal
    returns (bool)
  {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
  {
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
  function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
  {
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
  function values(AddressSet storage set)
    internal
    view
    returns (address[] memory)
  {
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
  function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(value));
  }

  /**
   * @dev Returns the number of values on the set. O(1).
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
  function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
  {
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
  function values(UintSet storage set)
    internal
    view
    returns (uint256[] memory)
  {
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  uint8 private constant _ADDRESS_LENGTH = 20;

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts/access/IAccessControl.sol";
import "contracts/external/openzeppelin/contracts/utils/Context.sol";
import "contracts/external/openzeppelin/contracts/utils/Strings.sol";
import "contracts/external/openzeppelin/contracts/utils/ERC165.sol";

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
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
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
 * accounts that have been granted it.
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
    _checkRole(role, _msgSender());
    _;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControl).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev Returns `true` if `account` has been granted `role`.
   */
  function hasRole(bytes32 role, address account)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _roles[role].members[account];
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
            Strings.toHexString(uint160(account), 20),
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
  function getRoleAdmin(bytes32 role)
    public
    view
    virtual
    override
    returns (bytes32)
  {
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
   */
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
   */
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
   */
  function renounceRole(bytes32 role, address account) public virtual override {
    require(
      account == _msgSender(),
      "AccessControl: can only renounce roles for self"
    );

    _revokeRole(role, account);
  }

  /**
   * @dev Grants `role` to `account`.
   *
   * If `account` had not been already granted `role`, emits a {RoleGranted}
   * event. Note that unlike {grantRole}, this function doesn't perform any
   * checks on the calling account.
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

import "contracts/external/openzeppelin/contracts/access/IAccessControlEnumerable.sol";
import "contracts/external/openzeppelin/contracts/access/AccessControl.sol";
import "contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is
  IAccessControlEnumerable,
  AccessControl
{
  using EnumerableSet for EnumerableSet.AddressSet;

  mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlEnumerable).interfaceId ||
      super.supportsInterface(interfaceId);
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
  function getRoleMember(bytes32 role, uint256 index)
    public
    view
    virtual
    override
    returns (address)
  {
    return _roleMembers[role].at(index);
  }

  /**
   * @dev Returns the number of accounts that have `role`. Can be used
   * together with {getRoleMember} to enumerate all bearers of a role.
   */
  function getRoleMemberCount(bytes32 role)
    public
    view
    virtual
    override
    returns (uint256)
  {
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
  function _revokeRole(bytes32 role, address account)
    internal
    virtual
    override
  {
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
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );

  /**
   * @dev Emitted when `account` is granted `role`.
   *
   * `sender` is the account that originated the contract call, an admin role
   * bearer except when using {AccessControl-_setupRole}.
   */
  event RoleGranted(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );

  /**
   * @dev Emitted when `account` is revoked `role`.
   *
   * `sender` is the account that originated the contract call:
   *   - if using `revokeRole`, it is the admin role bearer
   *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
   */
  event RoleRevoked(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );

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

import "contracts/external/openzeppelin/contracts/access/IAccessControl.sol";

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
  function getRoleMember(bytes32 role, uint256 index)
    external
    view
    returns (address);

  /**
   * @dev Returns the number of accounts that have `role`. Can be used
   * together with {getRoleMember} to enumerate all bearers of a role.
   */
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts/token/IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts/token/IERC20.sol";

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "contracts/external/openzeppelin/contracts/utils/IERC165.sol";

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
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return interfaceId == type(IERC165).interfaceId;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
 * ```
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
        bytes32 lastvalue = set._values[lastIndex];

        // Move the last value to the index where the value to delete is
        set._values[toDeleteIndex] = lastvalue;
        // Update the index for the moved value
        set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
  function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
  {
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
  function remove(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
  {
    return _remove(set._inner, value);
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(Bytes32Set storage set, bytes32 value)
    internal
    view
    returns (bool)
  {
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
  function at(Bytes32Set storage set, uint256 index)
    internal
    view
    returns (bytes32)
  {
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
  function values(Bytes32Set storage set)
    internal
    view
    returns (bytes32[] memory)
  {
    return _values(set._inner);
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
  function remove(AddressSet storage set, address value)
    internal
    returns (bool)
  {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
  {
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
  function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
  {
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
  function values(AddressSet storage set)
    internal
    view
    returns (address[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;

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
  function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(value));
  }

  /**
   * @dev Returns the number of values on the set. O(1).
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
  function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
  {
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
  function values(UintSet storage set)
    internal
    view
    returns (uint256[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;

    assembly {
      result := store
    }

    return result;
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

// This interface is not inherited directly by RWA, instead, it is a
// subset of functions provided by all RWA tokens that the RWA Hub
// Client uses.
import "contracts/external/openzeppelin/contracts/token/IERC20.sol";

interface IRWALike is IERC20 {
  function mint(address to, uint256 amount) external;

  function burn(uint256 amount) external;

  function burnFrom(address from, uint256 amount) external;
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

/**
 * @title IKYCRegistry
 * @author Ondo Finance
 * @notice The interface for Ondo's KYC Registry contract
 */
interface IKYCRegistry {
  /**
   * @notice Retrieves KYC status of an account
   *
   * @param kycRequirementGroup The KYC group for which we wish to check
   * @param account             The account we wish to retrieve KYC status for
   *
   * @return bool Whether the `account` is KYC'd
   */
  function getKYCStatus(
    uint256 kycRequirementGroup,
    address account
  ) external view returns (bool);

  /**
   * @notice View function for the public nested mapping of kycState
   *
   * @param kycRequirementGroup The KYC group to view
   * @param account             The account to check if KYC'd
   */
  function kycState(
    uint256 kycRequirementGroup,
    address account
  ) external view returns (bool);
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

import "contracts/kyc/IKYCRegistry.sol";

/**
 * @title IKYCRegistryClient
 * @author Ondo Finance
 * @notice The client interface Ondo's KYC Registry contract.
 */
interface IKYCRegistryClient {
  /// @notice Returns what KYC group this client checks accounts for
  function kycRequirementGroup() external view returns (uint256);

  /// @notice Returns reference to the KYC registry that this client queries
  function kycRegistry() external view returns (IKYCRegistry);

  /// @notice Sets the KYC group
  function setKYCRequirementGroup(uint256 group) external;

  /// @notice Sets the KYC registry reference
  function setKYCRegistry(address registry) external;

  /// @notice Error for when caller attempts to set the KYC registry refernce
  ///         to the zero address.
  error RegistryZeroAddress();

  /**
   * @dev Event for when the KYC registry reference is set
   *
   * @param oldRegistry The old registry
   * @param newRegistry The new registry
   */
  event KYCRegistrySet(address oldRegistry, address newRegistry);

  /**
   * @dev Event for when the KYC group for this client is set
   *
   * @param oldRequirementGroup The old KYC group
   * @param newRequirementGroup The new KYC group
   */
  event KYCRequirementGroupSet(
    uint256 oldRequirementGroup,
    uint256 newRequirementGroup
  );
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

import "contracts/kyc/IKYCRegistry.sol";
import "contracts/kyc/IKYCRegistryClient.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/**
 * @title KYCRegistryClientInitializable
 * @author Ondo Finance
 * @notice This abstract contract manages state required for clients
 *         of the KYC registry.
 */
abstract contract KYCRegistryClientUpgradeable is
  Initializable,
  IKYCRegistryClient
{
  // KYC Registry address
  IKYCRegistry public override kycRegistry;
  // KYC requirement group
  uint256 public override kycRequirementGroup;

  /**
   * @notice Initialize the contract by setting registry variable
   *
   * @param _kycRegistry         Address of the registry contract
   * @param _kycRequirementGroup KYC requirement group associated with this
   *                             client
   *
   * @dev Function should be called by the inheriting contract on
   *      initialization
   */
  function __KYCRegistryClientInitializable_init(
    address _kycRegistry,
    uint256 _kycRequirementGroup
  ) internal onlyInitializing {
    __KYCRegistryClientInitializable_init_unchained(
      _kycRegistry,
      _kycRequirementGroup
    );
  }

  /**
   * @dev Internal function to future-proof parent linearization. Matches OZ
   *      upgradeable suggestions
   */
  function __KYCRegistryClientInitializable_init_unchained(
    address _kycRegistry,
    uint256 _kycRequirementGroup
  ) internal onlyInitializing {
    _setKYCRegistry(_kycRegistry);
    _setKYCRequirementGroup(_kycRequirementGroup);
  }

  /**
   * @notice Sets the KYC registry address for this client
   *
   * @param _kycRegistry The new KYC registry address
   */
  function _setKYCRegistry(address _kycRegistry) internal {
    if (_kycRegistry == address(0)) {
      revert RegistryZeroAddress();
    }
    address oldKYCRegistry = address(kycRegistry);
    kycRegistry = IKYCRegistry(_kycRegistry);
    emit KYCRegistrySet(oldKYCRegistry, _kycRegistry);
  }

  /**
   * @notice Sets the KYC registry requirement group for this
   *         client to check kyc status for
   *
   * @param _kycRequirementGroup The new KYC group
   */
  function _setKYCRequirementGroup(uint256 _kycRequirementGroup) internal {
    uint256 oldKYCLevel = kycRequirementGroup;
    kycRequirementGroup = _kycRequirementGroup;
    emit KYCRequirementGroupSet(oldKYCLevel, _kycRequirementGroup);
  }

  /**
   * @notice Checks whether an address has been KYC'd
   *
   * @param account The address to check
   */
  function _getKYCStatus(address account) internal view returns (bool) {
    return kycRegistry.getKYCStatus(kycRequirementGroup, account);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[50] private __gap;
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

import "contracts/external/openzeppelin/contracts/token/IERC20.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "contracts/kyc/KYCRegistryClientUpgradeable.sol";
import "contracts/rwaOracles/IRWAOracle.sol";

/**
 * @title Interest-bearing ERC20-like token for OUSG.
 *
 * rOUSG balances are dynamic and represent the holder's share of the underlying OUSG
 * controlled by the protocol. To calculate each account's balance, we do
 *
 *   shares[account] * ousgPrice
 *
 * For example, if we assume that we have the following:
 *
 *   ousgPrice = 105 (18 decimals)
 *   rousg.sharesOf(user1) -> 1 (22 decimals)
 *   rousg.sharesOf(user2) -> 4 (22 decimals)
 *   ousg.balanceOf(rousg) -> 5 OUSG (18 decimals)
 *
 * Below would be the balances of the users:
 *
 *   rousg.balanceOf(user1) -> 105 rOUSG (18 decimals)
 *   rousg.balanceOf(user2) -> 420 rOUSG (18 decimals)
 *
 * Since balances of all token holders change when the price of OUSG changes, this
 * token cannot fully implement ERC20 standard: it only emits `Transfer` events
 * upon explicit transfer between holders. In contrast, when total amount of pooled
 * Cash increases, no `Transfer` events are generated: doing so would require emitting
 * an event for each token holder and thus running an unbounded loop.
 *
 */

contract ROUSG is
  Initializable,
  ContextUpgradeable,
  PausableUpgradeable,
  AccessControlEnumerableUpgradeable,
  KYCRegistryClientUpgradeable,
  IERC20Upgradeable,
  IERC20MetadataUpgradeable
{
  /**
   * @dev rOUSG balances are dynamic and are calculated based on the accounts' shares (OUSG)
   * and the the price of OUSG. Account shares aren't
   * normalized, so the contract also stores the sum of all shares to calculate
   * each account's token balance which equals to:
   *
   *   shares[account] * ousgPrice
   */
  mapping(address => uint256) private shares;

  /// @dev Allowances are nominated in tokens, not token shares.
  mapping(address => mapping(address => uint256)) private allowances;

  // Total shares in existence
  uint256 public totalShares;

  // Address of the oracle that provides the `ousgPrice`
  IRWAOracle public oracle;

  // Address of the OUSG token
  IERC20 public ousg;

  // Used to scale up ousg amount -> shares
  uint256 public constant OUSG_TO_ROUSG_SHARES_MULTIPLIER = 10_000;

  // Name of the token
  string internal _name;

  // Symbol of the token
  string internal _symbol;

  // Error when redeeming shares < `OUSG_TO_ROUSG_SHARES_MULTIPLIER`
  error UnwrapTooSmall();

  // Error when setting the oracle address to zero
  error CannotSetToZeroAddress();

  /// @dev Role based access control roles
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURN_ROLE");
  bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(
    address _kycRegistry,
    uint256 requirementGroup,
    address _ousg,
    address guardian,
    address _oracle
  ) public virtual initializer {
    __rOUSG_init(_kycRegistry, requirementGroup, _ousg, guardian, _oracle);
  }

  function __rOUSG_init(
    address _kycRegistry,
    uint256 requirementGroup,
    address _ousg,
    address guardian,
    address _oracle
  ) internal onlyInitializing {
    __rOUSG_init_unchained(
      _kycRegistry,
      requirementGroup,
      _ousg,
      guardian,
      _oracle
    );
  }

  function __rOUSG_init_unchained(
    address _kycRegistry,
    uint256 _requirementGroup,
    address _ousg,
    address guardian,
    address _oracle
  ) internal onlyInitializing {
    __KYCRegistryClientInitializable_init(_kycRegistry, _requirementGroup);
    ousg = IERC20(_ousg);
    oracle = IRWAOracle(_oracle);
    _grantRole(DEFAULT_ADMIN_ROLE, guardian);
    _grantRole(PAUSER_ROLE, guardian);
    _grantRole(BURNER_ROLE, guardian);
    _grantRole(CONFIGURER_ROLE, guardian);
    _name = "Ondo Short-Term U.S. Government Bond Fund (Rebasing)";
    _symbol = "rOUSG";
  }

  /**
   * @notice Emitted when the name is set
   *
   * @param oldName The old name of the token
   * @param newName The new name of the token
   */
  event NameSet(string oldName, string newName);

  /**
   * @notice Emitted when the symbol is set
   *
   * @param oldSymbol The old symbol of the token
   * @param newSymbol The new symbol of the token
   */

  event SymbolSet(string oldSymbol, string newSymbol);
  /**
   * @notice An executed shares transfer from `sender` to `recipient`.
   *
   * @dev emitted in pair with an ERC20-defined `Transfer` event.
   */
  event TransferShares(
    address indexed from,
    address indexed to,
    uint256 sharesValue
  );

  /**
   * @notice Emitted when the oracle address is set
   *
   * @param oldOracle The address of the old oracle
   * @param newOracle The address of the new oracle
   */
  event OracleSet(address indexed oldOracle, address indexed newOracle);

  /**
   * @return the name of the token.
   */
  function name() public view returns (string memory) {
    return _name;
  }

  /**
   * @return the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  /**
   * @return the number of decimals for getting user representation of a token amount.
   */
  function decimals() public pure returns (uint8) {
    return 18;
  }

  /**
   * @return the amount of tokens in existence.
   */
  function totalSupply() public view returns (uint256) {
    return
      (totalShares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);
  }

  /**
   * @return the amount of tokens owned by the `_account`.
   *
   * @dev Balances are dynamic and equal the `_account`'s OUSG shares multiplied
   *      by the price of OUSG
   */
  function balanceOf(address _account) public view returns (uint256) {
    return
      (_sharesOf(_account) * getOUSGPrice()) /
      (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);
  }

  /**
   * @notice Moves `_amount` tokens from the caller's account to the `_recipient` account.
   *
   * @return a boolean value indicating whether the operation succeeded.
   * Emits a `Transfer` event.
   * Emits a `TransferShares` event.
   *
   * Requirements:
   *
   * - `_recipient` cannot be the zero address.
   * - the caller must have a balance of at least `_amount`.
   * - the contract must not be paused.
   *
   * @dev The `_amount` argument is the amount of tokens, not shares.
   */
  function transfer(address _recipient, uint256 _amount) public returns (bool) {
    _transfer(msg.sender, _recipient, _amount);
    return true;
  }

  /**
   * @return the remaining number of tokens that `_spender` is allowed to spend
   * on behalf of `_owner` through `transferFrom`. This is zero by default.
   *
   * @dev This value changes when `approve` or `transferFrom` is called.
   */
  function allowance(
    address _owner,
    address _spender
  ) public view returns (uint256) {
    return allowances[_owner][_spender];
  }

  /**
   * @notice Sets `_amount` as the allowance of `_spender` over the caller's tokens.
   *
   * @return a boolean value indicating whether the operation succeeded.
   * Emits an `Approval` event.
   *
   * Requirements:
   *
   * - `_spender` cannot be the zero address.
   * - the contract must not be paused.
   *
   * @dev The `_amount` argument is the amount of tokens, not shares.
   */
  function approve(address _spender, uint256 _amount) public returns (bool) {
    _approve(msg.sender, _spender, _amount);
    return true;
  }

  /**
   * @notice Moves `_amount` tokens from `_sender` to `_recipient` using the
   * allowance mechanism. `_amount` is then deducted from the caller's
   * allowance.
   *
   * @return a boolean value indicating whether the operation succeeded.
   *
   * Emits a `Transfer` event.
   * Emits a `TransferShares` event.
   * Emits an `Approval` event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `_sender` and `_recipient` cannot be the zero addresses.
   * - `_sender` must have a balance of at least `_amount`.
   * - the caller must have allowance for `_sender`'s tokens of at least `_amount`.
   * - the contract must not be paused.
   *
   * @dev The `_amount` argument is the amount of tokens, not shares.
   */
  function transferFrom(
    address _sender,
    address _recipient,
    uint256 _amount
  ) public returns (bool) {
    uint256 currentAllowance = allowances[_sender][msg.sender];
    require(currentAllowance >= _amount, "TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");

    _transfer(_sender, _recipient, _amount);
    _approve(_sender, msg.sender, currentAllowance - _amount);
    return true;
  }

  /**
   * @notice Atomically increases the allowance granted to `_spender` by the caller by `_addedValue`.
   *
   * This is an alternative to `approve` that can be used as a mitigation for
   * problems described in:
   * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42
   * Emits an `Approval` event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `_spender` cannot be the the zero address.
   * - the contract must not be paused.
   */
  function increaseAllowance(
    address _spender,
    uint256 _addedValue
  ) public returns (bool) {
    _approve(
      msg.sender,
      _spender,
      allowances[msg.sender][_spender] + _addedValue
    );
    return true;
  }

  /**
   * @notice Atomically decreases the allowance granted to `_spender` by the caller by `_subtractedValue`.
   *
   * This is an alternative to `approve` that can be used as a mitigation for
   * problems described in:
   * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42
   * Emits an `Approval` event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `_spender` cannot be the zero address.
   * - `_spender` must have allowance for the caller of at least `_subtractedValue`.
   * - the contract must not be paused.
   */
  function decreaseAllowance(
    address _spender,
    uint256 _subtractedValue
  ) public returns (bool) {
    uint256 currentAllowance = allowances[msg.sender][_spender];
    require(
      currentAllowance >= _subtractedValue,
      "DECREASED_ALLOWANCE_BELOW_ZERO"
    );
    _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
    return true;
  }

  /**
   * @return the amount of shares owned by `_account`.
   *
   * @dev This is the equivalent to the amount of OUSG wrapped by `_account`.
   */
  function sharesOf(address _account) public view returns (uint256) {
    return _sharesOf(_account);
  }

  /**
   * @return the amount of shares that corresponds to `_rOUSGAmount` of rOUSG
   */
  function getSharesByROUSG(
    uint256 _rOUSGAmount
  ) public view returns (uint256) {
    return
      (_rOUSGAmount * 1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER) / getOUSGPrice();
  }

  /**
   * @return the amount of rOUSG that corresponds to `_shares` of OUSG.
   */
  function getROUSGByShares(uint256 _shares) public view returns (uint256) {
    return
      (_shares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);
  }

  function getOUSGPrice() public view returns (uint256 price) {
    (price, ) = oracle.getPriceData();
  }

  /**
   * @notice Moves `_sharesAmount` token shares from the caller's account to the `_recipient` account.
   *
   * @return amount of transferred tokens.
   * Emits a `TransferShares` event.
   * Emits a `Transfer` event.
   *
   * Requirements:
   *
   * - `_recipient` cannot be the zero address.
   * - the caller must have at least `_sharesAmount` shares.
   * - the contract must not be paused.
   *
   * @dev The `_sharesAmount` argument is the amount of shares, not tokens.
   */
  function transferShares(
    address _recipient,
    uint256 _sharesAmount
  ) public returns (uint256) {
    _transferShares(msg.sender, _recipient, _sharesAmount);
    emit TransferShares(msg.sender, _recipient, _sharesAmount);
    uint256 tokensAmount = getROUSGByShares(_sharesAmount);
    emit Transfer(msg.sender, _recipient, tokensAmount);
    return tokensAmount;
  }

  /**
   * @notice Function called by users to wrap their OUSG tokens
   *
   * @param _OUSGAmount The amount of OUSG Tokens to wrap
   *
   * @dev KYC checks implicit in OUSG Transfer
   */
  function wrap(uint256 _OUSGAmount) external whenNotPaused {
    require(_OUSGAmount > 0, "rOUSG: can't wrap zero OUSG tokens");
    uint256 ousgSharesAmount = _OUSGAmount * OUSG_TO_ROUSG_SHARES_MULTIPLIER;
    _mintShares(msg.sender, ousgSharesAmount);
    ousg.transferFrom(msg.sender, address(this), _OUSGAmount);
    emit Transfer(address(0), msg.sender, getROUSGByShares(ousgSharesAmount));
    emit TransferShares(address(0), msg.sender, ousgSharesAmount);
  }

  /**
   * @notice Function called by users to unwrap their rOUSG tokens by rOUSG amount
   *
   * @param _rOUSGAmount The amount of rOUSG to unwrap
   *
   * @dev KYC checks implicit in OUSG Transfer
   */
  function unwrap(uint256 _rOUSGAmount) external whenNotPaused {
    require(_rOUSGAmount > 0, "rOUSG: can't unwrap zero rOUSG tokens");
    uint256 ousgSharesAmount = getSharesByROUSG(_rOUSGAmount);
    if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)
      revert UnwrapTooSmall();
    _burnShares(msg.sender, ousgSharesAmount);
    ousg.transfer(
      msg.sender,
      ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER
    );
    emit Transfer(msg.sender, address(0), _rOUSGAmount);
    emit TransferShares(msg.sender, address(0), ousgSharesAmount);
  }

  /**
   * @notice Function called by users to unwrap their rOUSG tokens by shares
   *
   * @param _sharesAmount The amount of shares to transfer
   *
   * @dev KYC checks implicit in OUSG Transfer
   * @dev This is a more precise unwrap, as it avoids the division by price when converting rOUSG to shares
   */
  function unwrapShares(uint256 _sharesAmount) external whenNotPaused {
    if (_sharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)
      revert UnwrapTooSmall();

    uint256 rOUSGAmount = getROUSGByShares(_sharesAmount);

    _burnShares(msg.sender, _sharesAmount);
    ousg.transfer(msg.sender, _sharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER);
    emit Transfer(msg.sender, address(0), rOUSGAmount);
    emit TransferShares(msg.sender, address(0), _sharesAmount);
  }

  /**
   * @notice Moves `_amount` tokens from `_sender` to `_recipient`.
   * Emits a `Transfer` event.
   * Emits a `TransferShares` event.
   */
  function _transfer(
    address _sender,
    address _recipient,
    uint256 _amount
  ) internal {
    uint256 _sharesToTransfer = getSharesByROUSG(_amount);
    _transferShares(_sender, _recipient, _sharesToTransfer);
    emit Transfer(_sender, _recipient, _amount);
    emit TransferShares(_sender, _recipient, _sharesToTransfer);
  }

  /**
   * @notice Sets `_amount` as the allowance of `_spender` over the `_owner` s tokens.
   *
   * Emits an `Approval` event.
   *
   * Requirements:
   *
   * - `_owner` cannot be the zero address.
   * - `_spender` cannot be the zero address.
   * - the contract must not be paused.
   */
  function _approve(
    address _owner,
    address _spender,
    uint256 _amount
  ) internal whenNotPaused {
    require(_owner != address(0), "APPROVE_FROM_ZERO_ADDRESS");
    require(_spender != address(0), "APPROVE_TO_ZERO_ADDRESS");

    allowances[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  /**
   * @return the amount of shares owned by `_account`.
   */
  function _sharesOf(address _account) internal view returns (uint256) {
    return shares[_account];
  }

  /**
   * @notice Moves `_sharesAmount` shares from `_sender` to `_recipient`.
   *
   * Requirements:
   *
   * - `_sender` cannot be the zero address.
   * - `_recipient` cannot be the zero address.
   * - `_sender` must hold at least `_sharesAmount` shares.
   * - the contract must not be paused.
   */
  function _transferShares(
    address _sender,
    address _recipient,
    uint256 _sharesAmount
  ) internal whenNotPaused {
    require(_sender != address(0), "TRANSFER_FROM_THE_ZERO_ADDRESS");
    require(_recipient != address(0), "TRANSFER_TO_THE_ZERO_ADDRESS");

    _beforeTokenTransfer(_sender, _recipient, _sharesAmount);

    uint256 currentSenderShares = shares[_sender];
    require(
      _sharesAmount <= currentSenderShares,
      "TRANSFER_AMOUNT_EXCEEDS_BALANCE"
    );

    shares[_sender] = currentSenderShares - _sharesAmount;
    shares[_recipient] += _sharesAmount;
  }

  /**
   * @notice Creates `_sharesAmount` shares and assigns them to `_recipient`, increasing the total amount of shares.
   *
   * Requirements:
   *
   * - `_recipient` cannot be the zero address.
   * - the contract must not be paused.
   */
  function _mintShares(address _recipient, uint256 _sharesAmount) internal {
    require(_recipient != address(0), "MINT_TO_THE_ZERO_ADDRESS");

    _beforeTokenTransfer(address(0), _recipient, _sharesAmount);

    totalShares += _sharesAmount;

    shares[_recipient] += _sharesAmount;
  }

  /**
   * @notice Destroys `_sharesAmount` shares from `_account`'s holdings, decreasing the total amount of shares.
   * @dev This doesn't decrease the token total supply.
   *
   * Requirements:
   *
   * - `_account` cannot be the zero address.
   * - `_account` must hold at least `_sharesAmount` shares.
   * - the contract must not be paused.
   */
  function _burnShares(address _account, uint256 _sharesAmount) internal {
    require(_account != address(0), "BURN_FROM_THE_ZERO_ADDRESS");

    _beforeTokenTransfer(_account, address(0), _sharesAmount);

    uint256 accountShares = shares[_account];
    require(_sharesAmount <= accountShares, "BURN_AMOUNT_EXCEEDS_BALANCE");

    totalShares -= _sharesAmount;

    shares[_account] = accountShares - _sharesAmount;
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256
  ) internal view {
    // Check constraints when `transferFrom` is called to facliitate
    // a transfer between two parties that are not `from` or `to`.
    if (from != msg.sender && to != msg.sender) {
      require(_getKYCStatus(msg.sender), "rOUSG: 'sender' address not KYC'd");
    }

    if (from != address(0)) {
      // If not minting
      require(_getKYCStatus(from), "rOUSG: 'from' address not KYC'd");
    }

    if (to != address(0)) {
      // If not burning
      require(_getKYCStatus(to), "rOUSG: 'to' address not KYC'd");
    }
  }

  /**
   * @notice Sets the Oracle address
   * @dev The new oracle must comply with the IRWAOracle interface
   * @param _oracle Address of the new oracle
   */
  function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_oracle == address(0)) {
      revert CannotSetToZeroAddress();
    }
    emit OracleSet(address(oracle), _oracle);
    oracle = IRWAOracle(_oracle);
  }

  /**
   * @notice Sets the token name
   * @param newName New name of the token
   */
  function setName(
    string memory newName
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    emit NameSet(_name, newName);
    _name = newName;
  }

  /**
   * @notice Sets the token symbol
   * @param newSymbol New symbol of the token
   */
  function setSymbol(
    string memory newSymbol
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    emit SymbolSet(_symbol, newSymbol);
    _symbol = newSymbol;
  }

  /**
   * @notice Admin burn function to burn rOUSG tokens from any account
   * @param _account The account to burn tokens from
   * @param _sharesAmount  The amount of OUSG shares to burn
   * @dev Burns shares and transfers OUSG (if any) to `msg.sender`
   */
  function burnShares(
    address _account,
    uint256 _sharesAmount
  ) external onlyRole(BURNER_ROLE) {
    require(_sharesAmount > 0, "rOUSG: can't burn zero shares");

    uint256 rOUSGAmount = getROUSGByShares(_sharesAmount);

    _burnShares(_account, _sharesAmount);
    emit TransferShares(_account, address(0), _sharesAmount);

    if (_sharesAmount >= OUSG_TO_ROUSG_SHARES_MULTIPLIER) {
      ousg.transfer(
        msg.sender,
        _sharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER
      );
      emit Transfer(_account, address(0), rOUSGAmount);
    }
  }

  function pause() external onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
    _unpause();
  }

  function setKYCRegistry(
    address registry
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setKYCRegistry(registry);
  }

  function setKYCRequirementGroup(
    uint256 group
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setKYCRequirementGroup(group);
  }
}
/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

interface IRWAOracle {
  /// @notice Retrieve RWA price data
  function getPriceData()
    external
    view
    returns (uint256 price, uint256 timestamp);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IAdminSubscriptionChecker {
  function checkAndUpdateAdminSubscriptionAllowance(
    address admin,
    uint256 usdAmount
  ) external;
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOUSG_InstantManager {
  function subscribe(
    address depositToken,
    uint256 depositAmount,
    uint256 minimumRwaReceived
  ) external returns (uint256 rwaAmountOut);

  function subscribeRebasingOUSG(
    address depositToken,
    uint256 depositAmount,
    uint256 minimumRwaReceived
  ) external returns (uint256 rousgAmountOut);

  function adminSubscribe(
    address recipient,
    uint256 rwaAmount,
    bytes32 metadata
  ) external;

  function adminSubscribeRebasingOUSG(
    address recipient,
    uint256 rousgAmount,
    bytes32 metadata
  ) external;

  function redeem(
    uint256 rwaAmount,
    address receivingToken,
    uint256 minimumTokenReceived
  ) external returns (uint256 receiveTokenAmount);

  function redeemRebasingOUSG(
    uint256 rwaAmount,
    address receivingToken,
    uint256 minimumTokenReceived
  ) external returns (uint256 receiveTokenAmount);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoCompliance {
  function checkIsCompliant(address rwaToken, address user) external;
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoFees {
  function getAndUpdateFee(
    address rwaToken,
    address stablecoin,
    bytes32 userID,
    uint256 usdValue
  ) external returns (uint256 usdFee);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoIDRegistry {
  function getRegisteredID(
    address rwaToken,
    address user
  ) external view returns (bytes32 userID);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoOracle {
  function getAssetPrice(address token) external view returns (uint256 price);
}
// SPDX-License-Identifier: MIT
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoRateLimiter {
  enum TransactionType {
    SUBSCRIPTION,
    REDEMPTION
  }

  function checkAndUpdateRateLimit(
    TransactionType transactionType,
    address rwaToken,
    bytes32 userID,
    uint256 usdValue
  ) external;
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IOndoTokenRouter {
  function depositToken(
    address rwaToken,
    address tokenToDeposit,
    uint256 depositAmount
  ) external;

  function withdrawToken(
    address rwaTokenRedeemed,
    address tokenToWithdraw,
    bytes32 userID,
    uint256 withdrawAmount
  ) external;

  function availableToWithdraw(
    address rwaToken,
    address tokenToWithdraw,
    bytes32 userID
  ) external view returns (uint256 totalAvailable);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface ITokenRecipient {
  /**
   * @notice Emitted when tokens are deposited into the recipient
   * @param  depositToken       The address of the token deposited
   * @param  depositDestination The address of the recipient contract that received the tokens
   * @param  depositAmount      The amount of tokens that were deposited, denoted in the decimals
   *                            of `depositToken`
   */
  event TokensDeposited(
    address indexed depositToken,
    address indexed depositDestination,
    uint256 depositAmount
  );

  /// Error thrown for insufficient ERC20 token allowance
  error InsufficientAllowance();

  /// Error thrown when attempting to set a zero address
  error ZeroAddressNotAllowed();

  function depositToken(address depositToken, uint256 depositAmount) external;
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface ITokenSource {
  /**
   * @notice Emitted when tokens are withdrawn from the source
   * @param  requestedBy    The address of the account that requested the withdraw
   * @param  withdrawnFrom  The address of the source contract from which the tokens were withdrawn
   * @param  withdrawToken  The address of the token that was withdrawn
   * @param  withdrawAmount The amount of tokens that were withdrawn, denoted in the decimals of
   *                        `withdrawToken`
   */
  event TokensWithdrawn(
    address indexed requestedBy,
    address indexed withdrawnFrom,
    address indexed withdrawToken,
    uint256 withdrawAmount
  );

  /// Thrown when the requested token is not the expected token
  error InvalidTokenAddressForTokenSource();

  /// Thrown when attempting to set an address to address(0) which is not allowed
  error ZeroAddressNotAllowed();

  function withdrawToken(
    address tokenToWithdraw,
    uint256 withdrawAmount
  ) external;

  function availableToWithdraw(
    address tokenToWithdraw
  ) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;
import "contracts/xManager/interfaces/ITokenSource.sol";
import "contracts/xManager/interfaces/ITokenRecipient.sol";
import "contracts/xManager/interfaces/IOndoTokenRouter.sol";
import "contracts/xManager/interfaces/IOndoIDRegistry.sol";
import "contracts/xManager/interfaces/IOndoCompliance.sol";
import "contracts/xManager/interfaces/IOndoRateLimiter.sol";
import "contracts/xManager/interfaces/IOndoOracle.sol";
import "contracts/xManager/interfaces/IOndoFees.sol";
import "contracts/xManager/interfaces/IAdminSubscriptionChecker.sol";
import "contracts/interfaces/IRWALike.sol";
import "contracts/xManager/rwaManagers/IBaseRWAManagerEvents.sol";
import "contracts/xManager/rwaManagers/IBaseRWAManagerErrors.sol";
import "contracts/external/openzeppelin/contracts/token/IERC20Metadata.sol";
import "contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol";
import "contracts/external/openzeppelin/contracts/token/SafeERC20.sol";

/**
 * @title  BaseRWAManager
 * @author Ondo Finance
 * @notice The BaseRWAManager contract contains the core logic for processing subscriptions
 *         and redemptions of RWA tokens. The abstract logic of this contract never touches
 *         RWA tokens, so inheriting child classes may implement the RWA token processing as they
 *         see fit.
 *         The responsibilities of this contract are:
 *          - Receiving deposits of tokens and depositing them into the OndoTokenRouter
 *          - Calculating the amount of RWA tokens to mint and/or transfer
 *            based on the deposit amount of subscriptions
 *          - Calculating the amount of tokens to return to users based on the redemption amount
 *          - Withdrawing tokens from the OndoTokenRouter and sending them to users
 *          - Enforcing the minimum deposit and redemption amounts
 *          - Ensuring users are registered with the OndoIDRegistry
 *          - Ensuring users are compliant with the OndoCompliance contract
 *         -  Checking user-specific and global rate limits
 *         -  Calculating the fees incurred by users for subscriptions and
 *            redemptions
 */
abstract contract BaseRWAManager is
  IBaseRWAManagerEvents,
  IBaseRWAManagerErrors,
  ReentrancyGuard,
  AccessControlEnumerable
{
  using SafeERC20 for IERC20;
  /// The decimals normalizer for USD
  uint256 public constant USD_NORMALIZER = 1e18;

  /// The decimals normalizer for the RWA token
  uint256 public immutable RWA_NORMALIZER;

  /// Role to configure the contract
  bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

  /// Role to pause subscriptions and redemptions
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  /// Role to manually service a subscription to RWA tokens
  bytes32 public constant ADMIN_SUBSCRIPTION_ROLE =
    keccak256("ADMIN_SUBSCRIPTION_ROLE");

  /**
   * @notice Minimum USD amount required to subscribe to a RWA token, denoted in USD with 18
   *         decimals.
   */
  uint256 public minimumDepositUSD;

  /**
   * @notice Minimum USD amount required to perform an RWA token redemption to be allowed,
   *         denoted in USD with 18 decimals
   */
  uint256 public minimumRedemptionUSD;

  /// Minimum price of RWA token that this contract will use, denoted in USD with 18 decimals
  uint256 public minimumRwaPrice;

  /// Whether subscriptions are paused for this contract
  bool public subscribePaused;

  /// Whether redemptions are paused for this contract
  bool public redeemPaused;

  /// The contract address for the RWA token this contract is responsible for
  address public immutable rwaToken;

  /// The `OndoTokenRouter` contract address
  IOndoTokenRouter public ondoTokenRouter;

  /// The `OndoOracle` contract address
  IOndoOracle public ondoOracle;

  /// The `OndoCompliance` contract address
  IOndoCompliance public ondoCompliance;

  /// The `OndoIDRegistry` contract address
  IOndoIDRegistry public ondoIDRegistry;

  /// The `OndoRateLimiter` contract address
  IOndoRateLimiter public ondoRateLimiter;

  /// The `OndoFees` contract for managing subscription fees
  IOndoFees public ondoSubscriptionFees;

  /// The `OndoFees` contract for managing redemption fees
  IOndoFees public ondoRedemptionFees;

  /// The `AdminSubscriptionChecker` contract
  IAdminSubscriptionChecker public adminSubscriptionChecker;

  /// Mapping of accepted subscription tokens
  mapping(address => bool) public acceptedSubscriptionTokens;

  /// Mapping of accepted redemption tokens
  mapping(address => bool) public acceptedRedemptionTokens;

  /**
   * @param _defaultAdmin         The default admin role for the contract
   * @param _rwaToken             The RWA token address
   * @param _minimumDepositUSD    The minimum subscription amount, denoted in USD with 18 decimals
   * @param _minimumRedemptionUSD The minimum redemption amount, denoted in USD with 18 decimals
   */
  constructor(
    address _defaultAdmin,
    address _rwaToken,
    uint256 _minimumDepositUSD,
    uint256 _minimumRedemptionUSD
  ) {
    if (_rwaToken == address(0)) revert TokenAddressCantBeZero();

    rwaToken = _rwaToken;
    RWA_NORMALIZER = 10 ** IERC20Metadata(_rwaToken).decimals();
    minimumDepositUSD = _minimumDepositUSD;
    minimumRedemptionUSD = _minimumRedemptionUSD;
    _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
  }

  /**
   * @notice Internal function for processing subscriptions
   * @param  depositToken       The token to deposit
   * @param  depositAmount      The amount of tokens to deposit, in decimals of the
   *                            token being deposited
   * @param  minimumRwaReceived The minimum amount of RWA tokens to receive, in
   *                            decimals of the RWA token
   * @return rwaAmountOut       The amount of RWA tokens to mint or transfer, in
   *                            decimals of the RWA token
   * @dev    This function will transfer the deposit tokens from the `msg.sender` to this contract
   *         and then deposit them via the `OndoTokenRouter`. The mint or transfer of the RWA token
   *         must be done in the child class.
   */
  function _processSubscription(
    address depositToken,
    uint256 depositAmount,
    uint256 minimumRwaReceived
  ) internal whenSubscribeNotPaused returns (uint256 rwaAmountOut) {
    if (!acceptedSubscriptionTokens[depositToken]) revert TokenNotAccepted();
    if (
      IERC20(depositToken).allowance(_msgSender(), address(this)) <
      depositAmount
    ) revert InsufficientAllowance();

    // Reverts if user address is not compliant
    ondoCompliance.checkIsCompliant(rwaToken, _msgSender());
    bytes32 userId = ondoIDRegistry.getRegisteredID(rwaToken, _msgSender());
    if (userId == bytes32(0)) revert UserNotRegistered();

    IERC20(depositToken).safeTransferFrom(
      _msgSender(),
      address(this),
      depositAmount
    );
    IERC20(depositToken).forceApprove(address(ondoTokenRouter), depositAmount);

    ondoTokenRouter.depositToken(rwaToken, depositToken, depositAmount);

    // USD values are normalized to 18 decimals
    uint256 depositUSDValue = (ondoOracle.getAssetPrice(depositToken) *
      depositAmount) / 10 ** IERC20Metadata(depositToken).decimals();

    if (depositUSDValue < minimumDepositUSD) revert DepositAmountTooSmall();

    // Fee in USD with 18 decimals
    uint256 fee = ondoSubscriptionFees.getAndUpdateFee(
      rwaToken,
      depositToken,
      userId,
      depositUSDValue
    );

    if (fee > depositUSDValue) revert FeeGreaterThanSubscription();

    // Prices are returned in 18 decimals.
    rwaAmountOut =
      ((((depositUSDValue - fee) * USD_NORMALIZER) / _getRwaPrice()) *
        RWA_NORMALIZER) /
      USD_NORMALIZER;

    if (rwaAmountOut < minimumRwaReceived) revert RwaReceiveAmountTooSmall();

    ondoRateLimiter.checkAndUpdateRateLimit(
      IOndoRateLimiter.TransactionType.SUBSCRIPTION,
      rwaToken,
      userId,
      depositUSDValue
    );

    emit Subscription(
      _msgSender(),
      userId,
      rwaAmountOut,
      depositToken,
      depositAmount,
      depositUSDValue,
      fee
    );
  }

  /**
   * @notice Internal function for processing redemptions
   * @param  rwaAmount            The amount of RWA tokens to redeem, in decimals of
   *                              the RWA token
   * @param  receivingToken       The token the user receives
   * @param  minimumTokenReceived The minimum amount of tokens to receive, in
   *                              decimals of `receivingToken`
   * @return receiveTokenAmount   The amount of tokens to sent back to the caller,
   *                              in decimals of `receivingToken`
   * @dev    This function will send tokens to send back to the caller to service redemptions.
   *         The transfer/burn of the RWA itself must be done in the child class.
   */
  function _processRedemption(
    uint256 rwaAmount,
    address receivingToken,
    uint256 minimumTokenReceived
  ) internal whenRedeemNotPaused returns (uint256 receiveTokenAmount) {
    if (!acceptedRedemptionTokens[receivingToken]) revert TokenNotAccepted();

    // Reverts if the user address is not compliant
    ondoCompliance.checkIsCompliant(rwaToken, _msgSender());
    bytes32 userId = ondoIDRegistry.getRegisteredID(rwaToken, _msgSender());
    if (userId == bytes32(0)) revert UserNotRegistered();

    // USD values are normalized to 18 decimals
    uint256 redemptionUSDValue = (_getRwaPrice() * rwaAmount) / RWA_NORMALIZER;
    if (redemptionUSDValue < minimumRedemptionUSD)
      revert RedemptionAmountTooSmall();

    // Fee is denoted in USD with 18 decimals
    uint256 fee = ondoRedemptionFees.getAndUpdateFee(
      rwaToken,
      receivingToken,
      userId,
      redemptionUSDValue
    );

    if (fee > redemptionUSDValue) revert FeeGreaterThanRedemption();

    ondoRateLimiter.checkAndUpdateRateLimit(
      IOndoRateLimiter.TransactionType.REDEMPTION,
      rwaToken,
      userId,
      redemptionUSDValue
    );

    // Prices are returned in 18 decimals
    receiveTokenAmount =
      ((redemptionUSDValue - fee) *
        10 ** IERC20Metadata(receivingToken).decimals()) /
      ondoOracle.getAssetPrice(receivingToken);

    if (receiveTokenAmount < minimumTokenReceived)
      revert ReceiveAmountTooSmall();

    ondoTokenRouter.withdrawToken(
      address(rwaToken),
      receivingToken,
      userId,
      receiveTokenAmount
    );

    IERC20(receivingToken).safeTransfer(_msgSender(), receiveTokenAmount);

    emit Redemption(
      _msgSender(),
      userId,
      rwaAmount,
      receivingToken,
      receiveTokenAmount,
      redemptionUSDValue,
      fee
    );
  }

  /**
   * @notice Admin function to service a subscription whose corresponding deposit been made outside
   *         of this contracts system. This is almost identical to the `_processSubscription`
   *         function, but skips the deposit token transfer and fee calculation (fees are
   *         managed off-chain). The mint and/or transfer itself must be done in the child contract
   *         implementation.
   * @param  recipient The address to send the RWA tokens to
   * @param  rwaAmount The amount of RWA tokens to mint and/or transfer
   * @param  metadata  Additional metadata to emit with the subscription
   */
  function _adminProcessSubscription(
    address recipient,
    uint256 rwaAmount,
    bytes32 metadata
  ) internal onlyRole(ADMIN_SUBSCRIPTION_ROLE) {
    // Will revert if the user is not compliant.
    ondoCompliance.checkIsCompliant(rwaToken, recipient);
    bytes32 userId = ondoIDRegistry.getRegisteredID(rwaToken, recipient);
    if (userId == bytes32(0)) revert UserNotRegistered();

    // All USD values are normalized to 18 decimals.
    uint256 depositUSDValue = (rwaAmount * _getRwaPrice()) / RWA_NORMALIZER;

    adminSubscriptionChecker.checkAndUpdateAdminSubscriptionAllowance(
      _msgSender(),
      depositUSDValue
    );
    ondoRateLimiter.checkAndUpdateRateLimit(
      IOndoRateLimiter.TransactionType.SUBSCRIPTION,
      rwaToken,
      userId,
      depositUSDValue
    );
    emit AdminSubscription(
      _msgSender(),
      recipient,
      userId,
      rwaAmount,
      depositUSDValue,
      metadata
    );
  }

  /**
   * @notice Gets the rwa token price from the oracle
   * @return rwaPrice The price of the RWA token
   */
  function _getRwaPrice() internal view returns (uint256 rwaPrice) {
    rwaPrice = ondoOracle.getAssetPrice(rwaToken);
    if (rwaPrice < minimumRwaPrice) revert RWAPriceTooLow();
  }

  /**
   * @notice Sets whether a token is accepted for subscriptions
   * @param  token    The token address
   * @param  accepted Whether the token is accepted for subscription
   */
  function setAcceptedSubscriptionToken(
    address token,
    bool accepted
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (token == address(0)) revert TokenAddressCantBeZero();
    // Ensure the oracle supports the token
    if (accepted) ondoOracle.getAssetPrice(token);
    emit AcceptedSubscriptionTokenSet(token, accepted);
    acceptedSubscriptionTokens[token] = accepted;
  }

  /**
   * @notice Sets whether a token is accepted for redemption.
   * @param  token    The token address
   * @param  accepted Whether the token is accepted for redemption
   */
  function setAcceptedRedemptionToken(
    address token,
    bool accepted
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (token == address(0)) revert TokenAddressCantBeZero();
    // Ensure the oracle supports the token
    if (accepted) ondoOracle.getAssetPrice(token);
    emit AcceptedRedemptionTokenSet(token, accepted);
    acceptedRedemptionTokens[token] = accepted;
  }

  /**
   * @notice Admin function to set the `OndoTokenRouter` contract
   * @param  _ondoTokenRouter The `OndoTokenRouter` contract address
   */
  function setOndoTokenRouter(
    address _ondoTokenRouter
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoTokenRouter == address(0)) revert RouterAddressCantBeZero();
    emit OndoTokenRouterSet(address(ondoTokenRouter), _ondoTokenRouter);
    ondoTokenRouter = IOndoTokenRouter(_ondoTokenRouter);
  }

  /**
   * @notice Admin function to set the `OndoOracle` contract
   * @param  _ondoOracle The `OndoOracle` contract address
   * @dev    Will revert if new `OndoOracle` contract returns a price lower than the minimum
   *         configured price of the RWA token
   */
  function setOndoOracle(
    address _ondoOracle
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoOracle == address(0)) revert OracleAddressCantBeZero();
    emit OndoOracleSet(address(ondoOracle), _ondoOracle);
    ondoOracle = IOndoOracle(_ondoOracle);

    uint256 price = ondoOracle.getAssetPrice(rwaToken);
    if (price < minimumRwaPrice) revert RWAPriceTooLow();
  }

  /**
   * @notice Sets the `OndoCompliance` contract
   * @param  _ondoCompliance The `OndoCompliance` contract address
   */
  function setOndoCompliance(
    address _ondoCompliance
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoCompliance == address(0)) revert ComplianceAddressCantBeZero();
    emit OndoComplianceSet(address(ondoCompliance), _ondoCompliance);
    ondoCompliance = IOndoCompliance(_ondoCompliance);

    // Ensure that the `OndoCompliance` interface is supported and
    // this contract is compliant
    ondoCompliance.checkIsCompliant(rwaToken, address(this));
  }

  /**
   * @notice Sets the `OndoIDRegistry` contract
   * @param  _ondoIDRegistry The `OndoIDRegistry` contract address
   */
  function setOndoIDRegistry(
    address _ondoIDRegistry
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoIDRegistry == address(0)) revert IDRegistryAddressCantBeZero();
    emit OndoIDRegistrySet(address(ondoIDRegistry), _ondoIDRegistry);
    ondoIDRegistry = IOndoIDRegistry(_ondoIDRegistry);
    // Ensure that the `OndoIDRegistry` interface is supported
    ondoIDRegistry.getRegisteredID(rwaToken, address(this));
  }

  /**
   * @notice Sets the `OndoRateLimiter` contract
   * @param  _ondoRateLimiter The `OndoRateLimiter` contract address
   */
  function setOndoRateLimiter(
    address _ondoRateLimiter
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoRateLimiter == address(0)) revert RateLimiterAddressCantBeZero();
    emit OndoRateLimiterSet(address(ondoRateLimiter), _ondoRateLimiter);
    ondoRateLimiter = IOndoRateLimiter(_ondoRateLimiter);
  }

  /**
   * @notice Sets the `AdminSubscriptionChecker` contract
   * @param  _adminSubscriptionChecker The `AdminSubscriptionChecker` contract address
   */
  function setAdminSubscriptionChecker(
    address _adminSubscriptionChecker
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_adminSubscriptionChecker == address(0))
      revert AdminSubscriptionCheckerAddressCantBeZero();
    emit AdminSubscriptionCheckerSet(
      address(adminSubscriptionChecker),
      _adminSubscriptionChecker
    );
    adminSubscriptionChecker = IAdminSubscriptionChecker(
      _adminSubscriptionChecker
    );
  }

  /**
   * @notice Sets the `OndoFees` contract for subscriptions
   * @param  _ondoSubscriptionFees The `OndoFees` contract address
   */
  function setOndoSubscriptionFees(
    address _ondoSubscriptionFees
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoSubscriptionFees == address(0)) revert FeesAddressCantBeZero();
    emit OndoSubscriptionFeesSet(
      address(ondoSubscriptionFees),
      _ondoSubscriptionFees
    );
    ondoSubscriptionFees = IOndoFees(_ondoSubscriptionFees);
  }

  /**
   * @notice Sets the `OndoFees` contract for redemptions
   * @param  _ondoRedemptionFees The `OndoFees` contract address
   */
  function setOndoRedemptionFees(
    address _ondoRedemptionFees
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_ondoRedemptionFees == address(0)) revert FeesAddressCantBeZero();
    emit OndoRedemptionFeesSet(
      address(ondoRedemptionFees),
      _ondoRedemptionFees
    );
    ondoRedemptionFees = IOndoFees(_ondoRedemptionFees);
  }

  /**
   * @notice Sets the minimum amount required for a subscription
   * @param  _minimumDepositUSD The minimum amount required to subscribe, denoted in
   *                            USD with 18 decimals
   */
  function setMinimumDepositAmount(
    uint256 _minimumDepositUSD
  ) external onlyRole(CONFIGURER_ROLE) {
    emit MinimumDepositAmountSet(minimumDepositUSD, _minimumDepositUSD);
    minimumDepositUSD = _minimumDepositUSD;
  }

  /**
   * @notice Sets the minimum amount to redeem
   * @param  _minimumRedemptionUSD The minimum amount required to redeem,
   *                               denoted in USD with 18.
   */
  function setMinimumRedemptionAmount(
    uint256 _minimumRedemptionUSD
  ) external onlyRole(CONFIGURER_ROLE) {
    emit MinimumRedemptionAmountSet(
      minimumRedemptionUSD,
      _minimumRedemptionUSD
    );
    minimumRedemptionUSD = _minimumRedemptionUSD;
  }

  /**
   * @notice Sets the minimum price of RWA token
   * @param  _minimumRwaPrice The minimum price of the RWA token
   */
  function setMinimumRwaPrice(
    uint256 _minimumRwaPrice
  ) external onlyRole(CONFIGURER_ROLE) {
    emit MinimumRwaPriceSet(minimumRwaPrice, _minimumRwaPrice);
    minimumRwaPrice = _minimumRwaPrice;
  }

  /**
   * @notice Rescue and transfer tokens locked in this contract
   * @param  token  The address of the token
   * @param  to     The address of the recipient
   * @param  amount The amount of token to transfer
   */
  function retrieveTokens(
    address token,
    address to,
    uint256 amount
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    IERC20(token).safeTransfer(to, amount);
  }

  /*//////////////////////////////////////////////////////////////
                          Pause/Unpause
  //////////////////////////////////////////////////////////////*/

  /// Pause the subscribe functionality.
  function pauseSubscribe() external onlyRole(PAUSER_ROLE) {
    subscribePaused = true;
    emit SubscribePaused();
  }

  /// Unpause the subscribe functionality.
  function unpauseSubscribe() external onlyRole(DEFAULT_ADMIN_ROLE) {
    subscribePaused = false;
    emit SubscribeUnpaused();
  }

  /// Pause the redeem functionality.
  function pauseRedeem() external onlyRole(PAUSER_ROLE) {
    redeemPaused = true;
    emit RedeemPaused();
  }

  /// Unpause the redeem functionality.
  function unpauseRedeem() external onlyRole(DEFAULT_ADMIN_ROLE) {
    redeemPaused = false;
    emit RedeemUnpaused();
  }

  /// Ensure that the subscribe functionality is not paused
  modifier whenSubscribeNotPaused() {
    if (subscribePaused) revert SubscriptionsPaused();
    _;
  }

  /// Ensure that the redeem functionality is not paused
  modifier whenRedeemNotPaused() {
    if (redeemPaused) revert RedemptionsPaused();
    _;
  }
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IBaseRWAManagerErrors {
  /// Error emitted when the token address is zero
  error TokenAddressCantBeZero();

  /// Error emitted when the token is not accepted for subscription
  error TokenNotAccepted();

  /// Error emitted when the allowance is insufficient
  error InsufficientAllowance();

  /// Error emitted when the deposit amount is too small
  error DepositAmountTooSmall();

  /// Error emitted when rwa amount is below the `minimumRwaReceived` in a subscription
  error RwaReceiveAmountTooSmall();

  /// Error emitted when the user is not registered with the ID registry
  error UserNotRegistered();

  /// Error emitted when the redemption amount is too small
  error RedemptionAmountTooSmall();

  /// Error emitted when the receive amount is below the `minimumReceiveAmount` in a redemption
  error ReceiveAmountTooSmall();

  /// Error emitted when attempting to set the `OndoTokenRouter` address to zero
  error RouterAddressCantBeZero();

  /// Error emitted when attempting to set the `OndoOracle` address to zero
  error OracleAddressCantBeZero();

  /// Error emitted when attempting to set the `OndoCompliance` address to zero
  error ComplianceAddressCantBeZero();

  /// Error emitted when attempting to set the `OndoIDRegistry` address to zero
  error IDRegistryAddressCantBeZero();

  /// Error emitted when attempting to set the `OndoRateLimiter` address to zero
  error RateLimiterAddressCantBeZero();

  /// Error emitted when attempting to set the `OndoFees` address to zero
  error FeesAddressCantBeZero();

  /// Error emitted when attempting to set the `AdminSubscriptionChecker` address to zero
  error AdminSubscriptionCheckerAddressCantBeZero();

  /// Error emitted when the price of RWA token returned from the oracle is below the minimum price
  error RWAPriceTooLow();

  /// Error emitted when the subscription functionality is paused
  error SubscriptionsPaused();

  /// Error emitted when the redemption functionality is paused
  error RedemptionsPaused();

  /// Error emitted when the fee is greater than the redemption amount
  error FeeGreaterThanRedemption();

  /// Error emitted when the fee is greater than the subscription amount
  error FeeGreaterThanSubscription();
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

interface IBaseRWAManagerEvents {
  /**
   * @notice Event emitted when a user subscribes to an RWA token
   * @param  subscriber      The address of the subscriber
   * @param  subscriberId    The user ID of the subscriber
   * @param  rwaAmount       The amount of RWA tokens minted and/or transferred, in
   *                         decimals of the RWA token
   * @param  depositToken    The token deposited
   * @param  depositAmount   The amount of tokens deposited, in decimals of the
   *                         token
   * @param  depositUSDValue The USD value of the deposit, in 18 decimals
   * @param  fee             The fee charged for the subscription, in USD with 18 decimals
   */
  event Subscription(
    address indexed subscriber,
    bytes32 indexed subscriberId,
    uint256 rwaAmount,
    address depositToken,
    uint256 depositAmount,
    uint256 depositUSDValue,
    uint256 fee
  );

  /**
   * @notice Event emitted when a user redeems an RWA token
   * @param  redeemer           The address of the redeemer
   * @param  redeemerId         The user ID of the redeemer
   * @param  rwaAmount          The amount of RWA tokens redeemed, in decimals of
   *                            the RWA token
   * @param  receivingToken     The token received
   * @param  receiveTokenAmount The amount of tokens received, in decimals of the
   *                            token
   * @param  redemptionUSDValue The USD value of the redemption, in 18 decimals
   * @param  fee                The fee charged for the redemption, in USD with 18 decimals
   */
  event Redemption(
    address indexed redeemer,
    bytes32 indexed redeemerId,
    uint256 rwaAmount,
    address receivingToken,
    uint256 receiveTokenAmount,
    uint256 redemptionUSDValue,
    uint256 fee
  );

  /**
   * @notice Event emitted when an admin completes a subscription for a recipient
   * @param  adminCaller  The address of the admin account executing the subscription
   * @param  recipient    The address of the recipient that receives the RWA tokens
   * @param  recipientId  The user ID of the recipient
   * @param  rwaAmount    The amount of RWA tokens minted and/or transferred, in
   *                      decimals of the RWA token
   * @param  usdAmount    The USD value of the subscription, in 18 decimals
   * @param  metadata     Additional metadata to associate with the subscription
   */
  event AdminSubscription(
    address indexed adminCaller,
    address indexed recipient,
    bytes32 indexed recipientId,
    uint256 rwaAmount,
    uint256 usdAmount,
    bytes32 metadata
  );

  /**
   * @notice Event emitted when the `OndoTokenRouter` contract is set
   * @param  oldOndoTokenRouter The old `OndoTokenRouter` contract address
   * @param  newOndoTokenRouter The new `OndoTokenRouter` contract address
   */
  event OndoTokenRouterSet(
    address indexed oldOndoTokenRouter,
    address indexed newOndoTokenRouter
  );

  /**
   * @notice Event emitted when the `OndoOracle` contract is set
   * @param  oldOndoOracle The old `OndoOracle` contract address
   * @param  newOndoOracle The new `OndoOracle` contract address
   */
  event OndoOracleSet(
    address indexed oldOndoOracle,
    address indexed newOndoOracle
  );

  /**
   * @notice Event emitted when the `OndoCompliance` contract is set.
   * @param  oldOndoCompliance The old `OndoCompliance` contract address
   * @param  newOndoCompliance The new `OndoCompliance` contract address
   */
  event OndoComplianceSet(
    address indexed oldOndoCompliance,
    address indexed newOndoCompliance
  );

  /**
   * @notice Event emitted when the `OndoIDRegistry` contract is set
   * @param  oldOndoIDRegistry The old `OndoIDRegistry` contract address
   * @param  newOndoIDRegistry The new `OndoIDRegistry` contract address
   */
  event OndoIDRegistrySet(
    address indexed oldOndoIDRegistry,
    address indexed newOndoIDRegistry
  );

  /**
   * @notice Event emitted when the `OndoRateLimiter` contract is set
   * @param  oldOndoRateLimiter The old `OndoRateLimiter` contract address
   * @param  newOndoRateLimiter The new `OndoRateLimiter` contract address
   */
  event OndoRateLimiterSet(
    address indexed oldOndoRateLimiter,
    address indexed newOndoRateLimiter
  );

  /**
   * @notice Event emitted when the `OndoFees` subscription contract is set
   * @param  oldOndoSubscriptionFees The old `OndoFees` contract address for subscriptions
   * @param  newOndoSubscriptionFees The new `OndoFees` contract address for subscriptions
   */
  event OndoSubscriptionFeesSet(
    address indexed oldOndoSubscriptionFees,
    address indexed newOndoSubscriptionFees
  );

  /**
   * @notice Event emitted when the `OndoFees` redemption contract is set
   * @param  oldOndoRedemptionFees The old `OndoFees` contract address for redemptions
   * @param  newOndoRedemptionFees The new `OndoFees` contract address for redemptions
   */
  event OndoRedemptionFeesSet(
    address indexed oldOndoRedemptionFees,
    address indexed newOndoRedemptionFees
  );

  /**
   * @notice Event emitted when the `AdminSubscriptionChecker` contract is set
   * @param  oldAdminSubscriptionChecker The old `AdminSubscriptionChecker` contract address
   * @param  newAdminSubscriptionChecker The new `AdminSubscriptionChecker` contract address
   */
  event AdminSubscriptionCheckerSet(
    address indexed oldAdminSubscriptionChecker,
    address indexed newAdminSubscriptionChecker
  );

  /**
   * @notice Event emitted when a token's supported status is set for subscriptions
   * @param  token    The token address
   * @param  accepted Whether the token is accepted for deposit
   */
  event AcceptedSubscriptionTokenSet(
    address indexed token,
    bool indexed accepted
  );

  /**
   * @notice Event emitted when a token's supported status for redemptions
   * @param  token    The token address
   * @param  accepted Whether the token is accepted for redemption
   */
  event AcceptedRedemptionTokenSet(
    address indexed token,
    bool indexed accepted
  );

  /**
   * @notice Event emitted when subscription minimum is set
   * @param  oldMinDepositAmount Old subscription minimum
   * @param  newMinDepositAmount New subscription minimum
   */
  event MinimumDepositAmountSet(
    uint256 indexed oldMinDepositAmount,
    uint256 indexed newMinDepositAmount
  );

  /**
   * @notice Event emitted when redeem minimum is set
   * @param  oldMinRedemptionAmount Old redeem minimum
   * @param  newMinRedemptionAmount New redeem minimum
   */
  event MinimumRedemptionAmountSet(
    uint256 indexed oldMinRedemptionAmount,
    uint256 indexed newMinRedemptionAmount
  );

  /**
   * @notice Event emitted when the minimum RWA token price is set
   * @param  oldMinimumRwaPrice Old minimum RWA token price
   * @param  newMinimumRwaPrice New minimum RWA token price
   */
  event MinimumRwaPriceSet(
    uint256 indexed oldMinimumRwaPrice,
    uint256 indexed newMinimumRwaPrice
  );

  /// Event emitted when subscription functionality is paused
  event SubscribePaused();

  /// Event emitted when subscription functionality is unpaused
  event SubscribeUnpaused();

  /// Event emitted when redeem functionality is paused
  event RedeemPaused();

  /// Event emitted when redeem functionality is unpaused
  event RedeemUnpaused();
}
// SPDX-License-Identifier: BUSL-1.1
/*
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

import "contracts/xManager/rwaManagers/BaseRWAManager.sol";
import "contracts/interfaces/IRWALike.sol";
import "contracts/ousg/rOUSG.sol";
import "contracts/xManager/interfaces/IOUSG_InstantManager.sol";

/**
 * @title  OUSG_InstantManager
 * @author Ondo Finance
 * @notice This contract manages instant subscriptions and redemptions of OUSG and rOUSG tokens,
 *         with support for conversion between OUSG and rOUSG.
 *
 *         This contract allows for:
 *         - Users to instantly subscribe to OUSG or rOUSG by depositing supported tokens
 *         - Users to redeem OUSG or rOUSG back to supported tokens
 *         - An admin to execute manual subscriptions for specialized use cases
 */
contract OUSG_InstantManager is BaseRWAManager, IOUSG_InstantManager {
  /// The rebasing OUSG token contract
  ROUSG public immutable rousg;

  /// Helper constant for converting between OUSG tokens and rOUSG shares
  uint256 public constant OUSG_TO_ROUSG_SHARES_MULTIPLIER = 10_000;

  /**
   * @notice Event emitted when a user mints rOUSG
   * @param  recipient      Address of the recipient
   * @param  ousgAmountOut  Amount of OUSG wrapped for the user
   * @param  rousgAmountOut Amount of rOUSG sent to user
   * @param  depositToken   Address of the token deposited
   * @param  depositAmount  Amount of tokens deposited, denoted in decimals of `depositToken`
   */
  event InstantSubscriptionRebasingOUSG(
    address indexed recipient,
    uint256 ousgAmountOut,
    uint256 rousgAmountOut,
    address depositToken,
    uint256 depositAmount
  );

  /**
   * @notice Event emitted when a user redeems rOUSG
   * @param  redeemer           Address of the redeemer
   * @param  ousgAmountIn       Amount of OUSG unwrapped for the user
   * @param  rousgAmountIn      Amount of the rOUSG burned for the redemption
   * @param  receivingToken     Address of the token received
   * @param  receiveTokenAmount Amount of tokens received, denoted in decimals of `receivingToken`
   */
  event InstantRedemptionRebasingOUSG(
    address indexed redeemer,
    uint256 ousgAmountIn,
    uint256 rousgAmountIn,
    address receivingToken,
    uint256 receiveTokenAmount
  );

  /**
   * @notice Event emitted when an admin mints rOUSG
   * @param  recipient   Address of the recipient
   * @param  ousgAmount  Amount of OUSG wrapped for the user
   * @param  rousgAmount Amount of rOUSG sent to recipient
   * @param  metadata    Metadata for the subscription
   */
  event AdminSubscriptionRebasingOUSG(
    address indexed recipient,
    uint256 ousgAmount,
    uint256 rousgAmount,
    bytes32 metadata
  );

  /// Error emitted when setting the rOUSG address to the zero address
  error RebasingOUSGCantBeZeroAddress();

  /**
   * @param _defaultAdmin            The default admin address
   * @param _rwaToken                The OUSG token address
   * @param _rousg                   The rOUSG token address
   * @param _minimumDepositAmount    The minimum deposit amount
   * @param _minimumRedemptionAmount The minimum redemption amount
   */
  constructor(
    address _defaultAdmin,
    address _rwaToken,
    address _rousg,
    uint256 _minimumDepositAmount,
    uint256 _minimumRedemptionAmount
  )
    BaseRWAManager(
      _defaultAdmin,
      _rwaToken,
      _minimumDepositAmount,
      _minimumRedemptionAmount
    )
  {
    if (_rousg == address(0)) revert RebasingOUSGCantBeZeroAddress();
    rousg = ROUSG(_rousg);
  }

  /**
   * @notice Subscribes to the RWA using the specified deposit token and amount
   * @param  depositToken       The address of the token to be deposited
   * @param  depositAmount      The amount of the deposit token to be deposited, expected to be in
   *                            decimals of `depositToken`
   * @param  minimumRwaReceived The minimum amount of RWA to be received from the subscription,
   *                            expected to be in decimals of the RWA token
   * @return rwaAmountOut       The amount of RWA received from the subscription, expected to be in
   *                            decimals of the RWA token
   */
  function subscribe(
    address depositToken,
    uint256 depositAmount,
    uint256 minimumRwaReceived
  ) external nonReentrant returns (uint256 rwaAmountOut) {
    rwaAmountOut = _processSubscription(
      depositToken,
      depositAmount,
      minimumRwaReceived
    );
    IRWALike(rwaToken).mint(_msgSender(), rwaAmountOut);
  }

  /**
   * @notice Subscribes to rOUSG. This works similar to `subscribe`, but
   *         wraps the OUSG into rOUSG before transferring to the user.
   * @param  depositToken       The token to deposit
   * @param  depositAmount      Amount of tokens to deposit, denoted in decimals of the
   *                           `depositToken`
   * @param  minimumRwaReceived Minimum amount of RWA to receive, in decimals of rOUSG
   * @return rousgAmountOut     Amount of rOUSG received, in decimals of rOUSG
   */
  function subscribeRebasingOUSG(
    address depositToken,
    uint256 depositAmount,
    uint256 minimumRwaReceived
  ) external nonReentrant returns (uint256 rousgAmountOut) {
    uint256 minimumOusgAmonut = rousg.getSharesByROUSG(minimumRwaReceived) /
      OUSG_TO_ROUSG_SHARES_MULTIPLIER;
    uint256 ousgAmountOut = _processSubscription(
      depositToken,
      depositAmount,
      minimumOusgAmonut
    );

    IRWALike(rwaToken).mint(address(this), ousgAmountOut);
    IRWALike(rwaToken).approve(address(rousg), ousgAmountOut);
    rousg.wrap(ousgAmountOut);
    rousgAmountOut = rousg.transferShares(
      _msgSender(),
      ousgAmountOut * OUSG_TO_ROUSG_SHARES_MULTIPLIER
    );

    emit InstantSubscriptionRebasingOUSG(
      _msgSender(),
      ousgAmountOut,
      rousgAmountOut,
      depositToken,
      depositAmount
    );
  }

  /**
   * @notice Allows an admin to subscribe on behalf of a recipient with the specified RWA amount
   *         and metadata
   * @param  recipient The address of the recipient
   * @param  rwaAmount The amount of RWA to be subscribed, expected to be in decimals of the RWA
   *                   token
   * @param  metadata  Additional metadata associated with the subscription
   */
  function adminSubscribe(
    address recipient,
    uint256 rwaAmount,
    bytes32 metadata
  ) external nonReentrant {
    _adminProcessSubscription(recipient, rwaAmount, metadata);
    IRWALike(rwaToken).mint(recipient, rwaAmount);
  }

  /**
   * @notice Performs an admin subscription to rOUSG. This works similar to
   *         `adminSubscribe`, but wraps the OUSG to rOUSG before transferring the tokens
   *         to the user.
   * @param  recipient    Recipient of the rOUSG
   * @param  rousgAmount  Amount of rOUSG to send, in decimals of rOUSG
   * @param  metadata     Metadata for the subscription
   */
  function adminSubscribeRebasingOUSG(
    address recipient,
    uint256 rousgAmount,
    bytes32 metadata
  ) external nonReentrant {
    uint256 ousgAmount = rousg.getSharesByROUSG(rousgAmount) /
      OUSG_TO_ROUSG_SHARES_MULTIPLIER;
    _adminProcessSubscription(recipient, ousgAmount, metadata);
    IRWALike(rwaToken).mint(address(this), ousgAmount);
    IRWALike(rwaToken).approve(address(rousg), ousgAmount);
    rousg.wrap(ousgAmount);
    rousg.transferShares(
      recipient,
      ousgAmount * OUSG_TO_ROUSG_SHARES_MULTIPLIER
    );

    emit AdminSubscriptionRebasingOUSG(
      recipient,
      ousgAmount,
      rousgAmount,
      metadata
    );
  }

  /**
   * @notice Redeems the specified amount of RWA for the receiving token
   * @param  rwaAmount            The amount of RWA to be redeemed, expected to be in decimals of
   *                              the RWA token
   * @param  receivingToken       The address of the token to receive
   * @param  minimumTokenReceived The minimum amount of the receiving token to be received,
   *                              expected to be in decimals of `receivingToken`
   * @return receiveTokenAmount   The amount of the token received from the redemption, expected
   *                              to be in decimals of the `receivingToken`
   */
  function redeem(
    uint256 rwaAmount,
    address receivingToken,
    uint256 minimumTokenReceived
  ) external nonReentrant returns (uint256 receiveTokenAmount) {
    if (IRWALike(rwaToken).allowance(_msgSender(), address(this)) < rwaAmount)
      revert InsufficientAllowance();
    IRWALike(rwaToken).transferFrom(_msgSender(), address(this), rwaAmount);
    IRWALike(rwaToken).burn(rwaAmount);

    receiveTokenAmount = _processRedemption(
      rwaAmount,
      receivingToken,
      minimumTokenReceived
    );
  }

  /**
   * @notice Performs a rOUSG redemption. This works similar to `redeem`, but
   *         unwraps the rOUSG to OUSG before processing the redemption.
   * @param  rwaAmount            Amount of rOUSG to redeem, in precision of rOUSG.
   * @param  receivingToken       Token to receive
   * @param  minimumTokenReceived Minimum amount of tokens to receive, denoted in decimals of
   *                              `receivingToken`
   * @return receiveTokenAmount   Amount of tokens received, denoted in decimals of
   *                             `receivingToken`
   */
  function redeemRebasingOUSG(
    uint256 rwaAmount,
    address receivingToken,
    uint256 minimumTokenReceived
  ) external nonReentrant returns (uint256 receiveTokenAmount) {
    if (rousg.allowance(_msgSender(), address(this)) < rwaAmount)
      revert InsufficientAllowance();

    rousg.transferFrom(_msgSender(), address(this), rwaAmount);
    rousg.unwrap(rwaAmount);
    uint256 ousgAmountIn = rousg.getSharesByROUSG(rwaAmount) /
      OUSG_TO_ROUSG_SHARES_MULTIPLIER;
    IRWALike(rwaToken).burn(ousgAmountIn);
    receiveTokenAmount = _processRedemption(
      ousgAmountIn,
      receivingToken,
      minimumTokenReceived
    );
    emit InstantRedemptionRebasingOUSG(
      _msgSender(),
      ousgAmountIn,
      rwaAmount,
      receivingToken,
      receiveTokenAmount
    );
  }
}