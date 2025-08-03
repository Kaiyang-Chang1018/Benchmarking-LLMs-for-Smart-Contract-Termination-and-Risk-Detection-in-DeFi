// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(account),
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        // On the first call to nonReentrant, _notEntered will be true
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
import "../proxy/utils/Initializable.sol";

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
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
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
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
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
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

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

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
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
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
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
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
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
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
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "src/interfaces/IInsurancePool.sol";
import "src/interfaces/IOracle.sol";
import "src/utils/Constants.sol";
import "src/utils/ConvertUtils.sol";
import "src/PoolBalances.sol";

contract InsurancePool is
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    IInsurancePool,
    PoolBalances
{
    using MathUpgradeable for uint256;
    using SafeCast for *;
    using SafeERC20 for IERC20;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    bytes32 public constant PORTFOLIO_ROLE = keccak256("PORTFOLIO_ROLE");
    bytes32 public constant AUCTION_ROLE = keccak256("AUCTION_ROLE");
    bytes32 public constant TASK_EXECUTOR_ROLE = keccak256("TASK_EXECUTOR_ROLE");

    /// @inheritdoc IInsurancePool
    IERC20Token public immutable debtToken;

    IReservePool public reservePool;
    ITokenManager public tokenManager;
    IOracle public oracle;

    /**
     * @notice The total available balance ratio threshold, with 18 decimal places, used to limit the max investment amount.
     */
    uint256 internal _totalAvailableBalanceRatioThreshold;
    /**
     * @notice The latest CDP ID
     */
    uint256 internal _cdpId;
    /**
     * @notice The latest ID of the CDP redemption epoch, potentially including the upcoming next epoch
     */
    uint256 internal _redeemEpochId;
    /**
     * @notice The setting of CDP redemption epoch update restrictions
     */
    RedeemConfig internal _redeemConfig;
    mapping(uint256 cdpId => CDP) internal _cdp;
    mapping(address auction => mapping(address collateralToken => uint256)) internal _cdpOpenQuota;
    mapping(uint256 redeemEpochId => RedeemEpoch) internal _redeemEpoch;

    modifier onlyReservePool() {
        if (msg.sender != address(reservePool)) revert NotReservePool();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(IERC20Token debtToken_) {
        _disableInitializers();

        AddressUtils.checkContract(address(debtToken_));
        debtToken = debtToken_;
    }

    /**
     * @notice Initializes the components, roles, dependencies and the redemption config
     */
    function initialize(InitializeConfig calldata config_) public initializer {
        AddressUtils.checkNotZero(config_.governor);
        AddressUtils.checkNotZero(config_.guardian);
        AddressUtils.checkContract(config_.timelock);
        AddressUtils.checkNotZero(config_.portfolio);
        AddressUtils.checkNotZero(config_.taskExecutor);

        __Pausable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _setRoleAdmin(GOVERNOR_ROLE, GOVERNOR_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, GUARDIAN_ROLE);
        _setRoleAdmin(TIMELOCK_ROLE, GOVERNOR_ROLE);
        _setRoleAdmin(PORTFOLIO_ROLE, GUARDIAN_ROLE);
        _setRoleAdmin(AUCTION_ROLE, GUARDIAN_ROLE);
        _setRoleAdmin(TASK_EXECUTOR_ROLE, GUARDIAN_ROLE);

        _grantRole(GOVERNOR_ROLE, config_.governor);
        _grantRole(GUARDIAN_ROLE, config_.guardian);
        _grantRole(TIMELOCK_ROLE, config_.timelock);
        _grantRole(PORTFOLIO_ROLE, config_.portfolio);
        _grantRole(TASK_EXECUTOR_ROLE, config_.taskExecutor);

        _setReservePool(config_.reservePool);
        _setTokenManager(config_.tokenManager);
        _setOracle(config_.oracle);
        _setRedeemConfig(config_.redeemConfig);
        _setTotalAvailableBalanceRatioThreshold(config_.availableBalanceRatioThreshold);
    }

    /// @inheritdoc IInsurancePool
    function setReservePool(IReservePool newReservePool) external onlyRole(TIMELOCK_ROLE) {
        _setReservePool(newReservePool);
    }

    /// @inheritdoc IInsurancePool
    function setTokenManager(ITokenManager newTokenManager) external onlyRole(TIMELOCK_ROLE) {
        _setTokenManager(newTokenManager);
    }

    /// @inheritdoc IInsurancePool
    function setOracle(IOracle newOracle) external onlyRole(TIMELOCK_ROLE) {
        _setOracle(newOracle);
    }

    /// @inheritdoc IInsurancePool
    function setRedeemConfig(RedeemConfig calldata config) external onlyRole(TIMELOCK_ROLE) {
        _setRedeemConfig(config);
    }

    /// @inheritdoc IInsurancePool
    function setTotalAvailableBalanceRatioThreshold(uint256 newThreshold) external onlyRole(TIMELOCK_ROLE) {
        _setTotalAvailableBalanceRatioThreshold(newThreshold);
    }

    /// @inheritdoc IInsurancePool
    function pause() external onlyRole(GUARDIAN_ROLE) {
        _pause();
    }

    /// @inheritdoc IInsurancePool
    function unpause() external onlyRole(GUARDIAN_ROLE) {
        _unpause();
    }

    /// @inheritdoc IInsurancePool
    function depositCollateral(address token, uint256 amount) external onlyReservePool whenNotPaused nonReentrant {
        _depositCollateral(token, amount);
    }

    /// @inheritdoc IInsurancePool
    function depositCollateralFromAuction(address token, uint256 amount)
        external
        onlyRole(AUCTION_ROLE)
        whenNotPaused
        nonReentrant
    {
        _depositCollateral(token, amount);
        _setCDPOpenQuota(msg.sender, token, getCDPOpenQuota(msg.sender, token) + amount);
    }

    /// @inheritdoc IInsurancePool
    function withdrawCollateral(address token, uint256 amount) external onlyReservePool whenNotPaused nonReentrant {
        _checkAmountPositive(amount);

        if (amount > getAvailableBalance(token)) revert PoolBalanceInsufficient();

        _decreaseBalance(token, amount);

        IERC20(token).safeTransfer(msg.sender, amount);

        emit CollateralWithdrawn(token, msg.sender, amount);
    }

    /// @inheritdoc IInsurancePool
    function receivePortfolio(address token, uint256 amount)
        external
        onlyRole(PORTFOLIO_ROLE)
        whenNotPaused
        nonReentrant
    {
        _receivePortfolio(token, msg.sender, amount);
    }

    /// @inheritdoc IInsurancePool
    function sendPortfolio(address token, address receiver, uint256 amount)
        external
        onlyRole(TIMELOCK_ROLE)
        whenNotPaused
        nonReentrant
    {
        _checkRole(PORTFOLIO_ROLE, receiver);
        _sendPortfolio(token, receiver, amount);
    }

    /// @inheritdoc IInsurancePool
    function openCDP(
        address provider,
        address collateralToken,
        uint256 collateral,
        uint256 debtPrice,
        Maturity maturity,
        uint48 startTime
    ) external onlyRole(AUCTION_ROLE) whenNotPaused nonReentrant returns (uint256 cdpId) {
        AddressUtils.checkNotZero(provider);
        AddressUtils.checkNotZero(collateralToken);
        if (debtPrice == 0) revert DebtPriceInvalid();

        uint48 endTime = startTime + getMaturitySeconds(maturity);
        uint256 quota = getCDPOpenQuota(msg.sender, collateralToken);
        if (collateral == 0 || collateral > quota) revert CollateralInvalid();

        uint256 debt = ConvertUtils.convertByToPrice(
            10 ** IERC20Metadata(collateralToken).decimals(),
            10 ** IERC20Metadata(debtToken).decimals(),
            collateral,
            debtPrice,
            Constants.BASE
        );
        if (debt == 0) revert DebtInvalid();

        _setCDPOpenQuota(msg.sender, collateralToken, quota - collateral);

        cdpId = _cdpId + 1;
        _cdpId = cdpId;

        _cdp[cdpId] = CDP({
            provider: provider,
            closed: false,
            maturity: maturity,
            startTime: startTime,
            collateralToken: collateralToken,
            endTime: endTime,
            collateral: collateral,
            debt: debt,
            debtPrice: debtPrice,
            redeemedCollateral: 0,
            burnedDebt: 0
        });

        debtToken.mint(provider, debt);

        emit CDPOpened(cdpId, provider, collateralToken, collateral, debt, debtPrice, maturity, startTime, endTime);
    }

    /// @inheritdoc IInsurancePool
    function closeCDP(uint256 cdpId) external whenNotPaused nonReentrant {
        _redeemCDP(cdpId, _cdp[cdpId].collateral - _cdp[cdpId].redeemedCollateral);
    }

    /// @inheritdoc IInsurancePool
    function redeemCDP(uint256 cdpId, uint256 redeemAmount) external whenNotPaused nonReentrant {
        _redeemCDP(cdpId, redeemAmount);
    }

    /// @inheritdoc IInsurancePool
    function updateRedeemEpoch(uint32 duration, address[] calldata tokens, uint256[] calldata quotas)
        external
        onlyRole(TASK_EXECUTOR_ROLE)
        nonReentrant
        returns (uint256 epochId)
    {
        epochId = _createRedeemEpoch(duration);

        // Updates the redemption quotas only when the reserve ratio is greater than the threshold.
        // Otherwise, pauses CDP redemption for the new redemption epoch
        // with no need to update quotas as the default value for uint256 is 0.
        if (!reservePool.isReserveRatioLessThanOrEqualToMinReserveRatio()) {
            _updateRedeemEpochQuotas(epochId, tokens, quotas);
        }
    }

    /// @inheritdoc IInsurancePool
    function getCollateral(address token) public view returns (uint256) {
        return _getBalance(token);
    }

    /// @inheritdoc IInsurancePool
    function getRedeemConfig() public view returns (RedeemConfig memory) {
        return _redeemConfig;
    }

    /// @inheritdoc IInsurancePool
    function getCDPId() public view returns (uint256) {
        return _cdpId;
    }

    /// @inheritdoc IInsurancePool
    function getCDP(uint256 cdpId) public view returns (CDP memory) {
        return _cdp[cdpId];
    }

    /// @inheritdoc IInsurancePool
    function getCDPOpenQuota(address auction, address token) public view returns (uint256) {
        return _cdpOpenQuota[auction][token];
    }

    /// @inheritdoc IInsurancePool
    function getRedeemEpochId() public view returns (uint256) {
        return _redeemEpochId;
    }

    /// @inheritdoc IInsurancePool
    function getActiveRedeemEpochId() public view returns (uint256) {
        uint256 epochId = _redeemEpochId;

        if (epochId > 0) {
            // Latest
            if (_isNowInRedeemEpochPeriod(epochId)) {
                return epochId;
            }

            // Previous
            epochId--;
            if (epochId > 0 && _isNowInRedeemEpochPeriod(epochId)) {
                return epochId;
            }
        }

        revert NoActiveRedeemEpoch();
    }

    /// @inheritdoc IInsurancePool
    function getRedeemEpochPeriod(uint256 epochId) public view returns (uint48 startTime, uint48 endTime) {
        RedeemEpoch storage epoch = _redeemEpoch[epochId];
        startTime = epoch.startTime;
        endTime = epoch.endTime;
    }

    /// @inheritdoc IInsurancePool
    function getCollateralRedeemQuota(uint256 epochId, address token)
        public
        view
        returns (uint256 quota, uint256 redeemed)
    {
        RedeemEpoch storage epoch = _redeemEpoch[epochId];
        quota = epoch.quota[token];
        redeemed = epoch.redeemed[token];
    }

    /// @inheritdoc IInsurancePool
    function getTotalAvailableBalanceRatioThreshold() public view returns (uint256) {
        return _totalAvailableBalanceRatioThreshold;
    }

    /// @inheritdoc IInsurancePool
    function getMaturitySeconds(Maturity maturity) public pure returns (uint32) {
        if (maturity == Maturity.OneMonth) {
            return 4 weeks;
        } else if (maturity == Maturity.OneYear) {
            return 52 weeks;
        } else if (maturity == Maturity.TwoYears) {
            return 104 weeks;
        } else if (maturity == Maturity.ThreeYears) {
            return 156 weeks;
        } else if (maturity == Maturity.FourYears) {
            return 208 weeks;
        } else {
            revert MaturityInvalid();
        }
    }

    function _setReservePool(IReservePool newReservePool) internal {
        AddressUtils.checkContract(address(newReservePool));
        reservePool = newReservePool;
        emit ReservePoolUpdated(newReservePool);
    }

    function _setTokenManager(ITokenManager newTokenManager) internal {
        AddressUtils.checkContract(address(newTokenManager));
        tokenManager = newTokenManager;
        emit TokenManagerUpdated(newTokenManager);
    }

    function _setOracle(IOracle newOracle) internal {
        AddressUtils.checkContract(address(newOracle));
        oracle = newOracle;
        emit OracleUpdated(newOracle);
    }

    function _depositCollateral(address token, uint256 amount) internal {
        AddressUtils.checkNotZero(token);
        if (amount == 0) revert AmountInvalid();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        _increaseBalance(token, amount);

        emit CollateralDeposited(token, msg.sender, amount);
    }

    function _setRedeemConfig(RedeemConfig memory config) internal {
        if (config.minDuration < 1 hours) revert MinDurationInvalid();
        if (config.maxDuration > 30 days) revert MaxDurationInvalid();
        if (config.notBefore == 0) revert NotBeforeInvalid();

        _redeemConfig = config;

        emit RedeemConfigUpdated(config.minDuration, config.maxDuration, config.notBefore);
    }

    function _setTotalAvailableBalanceRatioThreshold(uint256 newThreshold) internal {
        if (newThreshold == 0) revert ThresholdInvalid();

        _totalAvailableBalanceRatioThreshold = newThreshold;

        emit TotalAvailableBalanceRatioThresholdUpdated(newThreshold);
    }

    function _setCDPOpenQuota(address auction, address token, uint256 newQuota) internal {
        _cdpOpenQuota[auction][token] = newQuota;

        emit CDPOpenQuotaUpdated(token, auction, newQuota);
    }

    function _redeemCDP(uint256 cdpId, uint256 redeemAmount) internal {
        address provider = msg.sender;
        CDP storage cdp = _cdp[cdpId];

        if (provider != cdp.provider) revert NotCDPProvider();
        if (cdp.closed) revert CDPAlreadyClosed();
        if (block.timestamp < cdp.endTime) revert CDPNotExpired();

        uint256 remainingCollateral = cdp.collateral - cdp.redeemedCollateral;
        if (redeemAmount == 0 || redeemAmount > remainingCollateral) revert AmountInvalid();
        if (redeemAmount > getAvailableBalance(cdp.collateralToken)) revert PoolBalanceInsufficient();

        _addCollateralRedeemed(cdp.collateralToken, redeemAmount);
        _decreaseBalance(cdp.collateralToken, redeemAmount);

        if (reservePool.isReserveRatioLessThanOrEqualToMinReserveRatio()) revert IReservePool.ReserveRatioInsufficient();

        bool closed = redeemAmount == remainingCollateral;
        uint256 burnAmount;

        if (closed) {
            // Redeems all remaining
            burnAmount = cdp.debt - cdp.burnedDebt;
            cdp.closed = true;
        } else {
            // Redeems partial
            burnAmount = ConvertUtils.convertByToPrice(
                10 ** IERC20Metadata(cdp.collateralToken).decimals(),
                10 ** IERC20Metadata(debtToken).decimals(),
                redeemAmount,
                cdp.debtPrice,
                Constants.BASE
            );

            if (burnAmount == 0) revert RedeemAmountTooSmall();
        }

        cdp.redeemedCollateral += redeemAmount;

        if (burnAmount > 0) {
            cdp.burnedDebt += burnAmount;
            debtToken.burn(provider, burnAmount);
        }

        IERC20(cdp.collateralToken).safeTransfer(provider, redeemAmount);

        emit CDPRedeemed(cdpId, provider, closed, redeemAmount, burnAmount, remainingCollateral - redeemAmount);
    }

    function _addCollateralRedeemed(address token, uint256 redeemAmount) internal {
        uint256 epochId = getActiveRedeemEpochId();
        RedeemEpoch storage epoch = _redeemEpoch[epochId];
        uint256 quota = epoch.quota[token];
        uint256 redeemed = epoch.redeemed[token];
        uint256 remaining = quota - redeemed;

        if (redeemAmount > remaining) revert RedeemAmountExceededLimit(remaining);

        redeemed += redeemAmount;
        epoch.redeemed[token] = redeemed;

        emit RedeemEpochQuotaUpdated(epochId, token, quota, redeemed);
    }

    function _createRedeemEpoch(uint32 duration) internal returns (uint256 epochId) {
        RedeemConfig storage config = _redeemConfig;

        if (duration < config.minDuration || duration > config.maxDuration) revert DurationInvalid();

        epochId = _redeemEpochId;
        uint48 startTime = epochId == 0 ? 0 : _redeemEpoch[epochId].startTime;
        uint48 endTime = epochId == 0 ? 0 : _redeemEpoch[epochId].endTime;

        if (block.timestamp < endTime) {
            if (block.timestamp < startTime || endTime - block.timestamp > config.notBefore) {
                revert NoNeedToCreateCDPRedeemEpoch();
            }

            startTime = endTime;
        } else {
            // When the first time or delayed
            startTime = block.timestamp.toUint48();
        }

        endTime = startTime + duration;

        epochId++;
        _redeemEpochId = epochId;

        RedeemEpoch storage redeemEpoch = _redeemEpoch[epochId];
        redeemEpoch.startTime = startTime;
        redeemEpoch.endTime = endTime;

        emit RedeemEpochCreated(epochId, startTime, endTime);
    }

    function _updateRedeemEpochQuotas(uint256 epochId, address[] calldata tokens, uint256[] calldata quotas) internal {
        if (tokens.length != quotas.length) revert LengthMismatched();

        RedeemEpoch storage epoch = _redeemEpoch[epochId];

        for (uint256 i; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 quota = quotas[i];

            if (tokenManager.getTokenType(token) != ITokenManager.TokenType.Asset) {
                revert ITypeTokens.NotAssetToken(token);
            }

            epoch.quota[token] = quota;

            emit RedeemEpochQuotaUpdated(epochId, token, quota, 0);
        }
    }

    function _isNowInRedeemEpochPeriod(uint256 epochId) internal view returns (bool) {
        RedeemEpoch storage epoch = _redeemEpoch[epochId];
        return block.timestamp >= epoch.startTime && block.timestamp < epoch.endTime;
    }

    function _getInvestableAmount(address token) internal view override returns (uint256) {
        (,,uint256 liabilities, uint256 ratio) = reservePool.getTotalAvailableBalanceRatio();
        uint256 threshold = _totalAvailableBalanceRatioThreshold;

        if (ratio <= threshold) {
            return 0;
        } else {
            uint256 totalInvestable = liabilities.mulDiv(ratio - threshold, Constants.BASE);
            uint256 tokenInvestable;

            if (totalInvestable > 0) {
                uint256 price = oracle.getLatestPrice(token);
                tokenInvestable = ConvertUtils.convertByFromPrice(
                    10 ** tokenManager.usd1().decimals(),
                    10 ** IERC20Metadata(token).decimals(),
                    totalInvestable,
                    price,
                    Constants.BASE
                );
            }

            return tokenInvestable == 0 ? 0 : tokenInvestable.min(getAvailableBalance(token));
        }
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "src/InsurancePool.sol";

/// @title InsurancePoolProxy
/// @notice The proxy contract to make `InsurancePool` upgradeable
contract InsurancePoolProxy is TransparentUpgradeableProxy {
    constructor(
        address logic_,
        address proxyAdmin_,
        InsurancePool.InitializeConfig memory config_
    )
        TransparentUpgradeableProxy(
            logic_,
            proxyAdmin_,
            abi.encodeWithSelector(InsurancePool.initialize.selector, config_)
        )
    {}
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "src/utils/AddressUtils.sol";
import "src/interfaces/IPoolBalances.sol";

/**
 * @title PoolBalances
 * @notice The abstract contract includes some generic functions and states that are used to manage pool assets
 *
 * @custom:storage-size 50
 */
abstract contract PoolBalances is IPoolBalances {
    using MathUpgradeable for uint256;
    using SafeERC20 for IERC20;

    /**
     * @notice Maps the token address to the balance, which includes the invested amount.
     */
    mapping(address token => uint256) internal _balance;
    /**
     * @notice Maps the token address to the portfolio used in investments
     */
    mapping(address token => uint256) internal _portfolio;

    /// @inheritdoc IPoolBalances
    function getPortfolio(address token) public view virtual returns (uint256) {
        return _portfolio[token];
    }

    /// @inheritdoc IPoolBalances
    function getAvailableBalance(address token) public view virtual returns (uint256) {
        return _getBalance(token) - getPortfolio(token);
    }

    /**
     * @notice Updates the pool balance of `token` to `newBalance`
     */
    function _setBalance(address token, uint256 newBalance) internal virtual {
        _balance[token] = newBalance;
        emit BalanceUpdated(token, newBalance);
    }

    /**
     * @notice Increases the pool balance of `token` by `amount`
     */
    function _increaseBalance(address token, uint256 amount) internal virtual {
        _setBalance(token, _getBalance(token) + amount);
    }

    /**
     * @notice Decreases the pool balance of `token` by `amount`
     */
    function _decreaseBalance(address token, uint256 amount) internal virtual {
        uint256 balance = _getBalance(token);
        if (balance < amount) revert PoolBalanceInsufficient();
        _setBalance(token, balance - amount);
    }

    /**
     * @notice Updates the portfolio of `token` to `newPortfolio`
     */
    function _setPortfolio(address token, uint256 newPortfolio) internal virtual {
        _portfolio[token] = newPortfolio;
        emit PortfolioUpdated(token, newPortfolio);
    }

    /**
     * @notice Receives portfolio `amount` of `token` from `sender`
     */
    function _receivePortfolio(address token, address sender, uint256 amount) internal virtual {
        AddressUtils.checkNotZero(token);
        AddressUtils.checkNotZero(sender);
        _checkAmountPositive(amount);
        if (sender == address(this)) revert SenderInvalid();

        uint256 portfolio = getPortfolio(token);
        if (amount > portfolio) revert AmountInvalid();

        _setPortfolio(token, portfolio - amount);

        IERC20(token).safeTransferFrom(sender, address(this), amount);

        emit PortfolioReceived(token, sender, amount);
    }

    /**
     * @notice Sends portfolio `amount` of `token` to `receiver`
     */
    function _sendPortfolio(address token, address receiver, uint256 amount) internal virtual {
        AddressUtils.checkNotZero(token);
        AddressUtils.checkNotZero(receiver);
        _checkAmountPositive(amount);
        if (receiver == address(this)) revert ReceiverInvalid();

        amount = amount.min(_getInvestableAmount(token));

        if (amount == 0) revert PoolBalanceInsufficient();

        _setPortfolio(token, getPortfolio(token) + amount);

        IERC20(token).safeTransfer(receiver, amount);

        emit PortfolioSent(token, receiver, amount);
    }

    /**
     * @notice Gets the pool balance of `token`, including the invested amount
     */
    function _getBalance(address token) internal view virtual returns (uint256) {
        return _balance[token];
    }

    function _getInvestableAmount(address token) internal view virtual returns (uint256) {
        return getAvailableBalance(token);
    }

    /**
     * @notice Reverts if `amount` is zero or negative
     */
    function _checkAmountPositive(uint256 amount) internal pure {
        if (amount == 0) revert AmountInvalid();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title Interface of Unitas ERC-20 Token
 */
interface IERC20Token is IERC20Metadata {
    function GOVERNOR_ROLE() external view returns (bytes32);
    function GUARDIAN_ROLE() external view returns (bytes32);
    function MINTER_ROLE() external view returns (bytes32);
    function setGovernor(address newGovernor, address oldGovernor) external;
    function revokeGovernor(address oldGovernor) external;
    function setGuardian(address newGuardian, address oldGuardian) external;
    function revokeGuardian(address oldGuardian) external;
    function setMinter(address newMinter, address oldMinter) external;
    function revokeMinter(address oldMinter) external;
    function pause() external;
    function unpause() external;
    function mint(address account, uint256 amount) external;
    function burn(address burner, uint256 amount) external;
    function addBlackList(address evilUser) external;
    function removeBlackList(address clearedUser) external;
    function getBlacklist(address addr) external view returns (bool);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "src/interfaces/IERC20Token.sol";
import "src/interfaces/IPoolBalances.sol";
import "src/interfaces/ITokenManager.sol";
import "src/interfaces/IReservePool.sol";

interface IInsurancePool is IPoolBalances {
    enum Maturity {
        None,
        /// 4 weeks
        OneMonth,
        /// 52 weeks
        OneYear,
        /// 104 weeks
        TwoYears,
        /// 156 weeks
        ThreeYears,
        /// 208 weeks
        FourYears
    }

    struct InitializeConfig {
        address governor;
        address guardian;
        address timelock;
        address portfolio;
        address taskExecutor;
        IReservePool reservePool;
        ITokenManager tokenManager;
        IOracle oracle;
        RedeemConfig redeemConfig;
        uint256 availableBalanceRatioThreshold;
    }

    struct CDP {
        address provider;
        bool closed;
        Maturity maturity;
        uint48 startTime;
        address collateralToken;
        uint48 endTime;
        uint256 collateral;
        uint256 debt;
        /// The price of `debtToken`/`collateralToken`
        uint256 debtPrice;
        uint256 redeemedCollateral;
        uint256 burnedDebt;
    }

    struct RedeemConfig {
        /// The min duration in seconds of a redemption epoch
        uint32 minDuration;
        /// The max duration in seconds of a redemption epoch
        uint32 maxDuration;
        /// The maximum seconds, by which the settings can be updated
        /// in advance of the start of the next CDP redemption epoch,
        /// for example, when the value is 1800,
        /// it means the settings can only be updated in 30 minutes
        /// before the start time of the next redemption epoch.
        uint32 notBefore;
    }

    struct RedeemEpoch {
        uint48 startTime;
        uint48 endTime;
        mapping(address collateralToken => uint256) quota;
        mapping(address collateralToken => uint256) redeemed;
    }

    struct UpdateRedeemEpochRequest {
        uint32 duration;
        address[] tokens;
        uint256[] quota;
    }

    event ReservePoolUpdated(IReservePool indexed newReservePool);
    event TokenManagerUpdated(ITokenManager indexed newTokenManager);
    event OracleUpdated(IOracle indexed newOracle);
    event CollateralDeposited(address indexed token, address indexed sender, uint256 amount);
    event CollateralWithdrawn(address indexed token, address indexed receiver, uint256 amount);
    event CDPOpenQuotaUpdated(address indexed token, address indexed auction, uint256 newQuota);
    event CDPOpened(
        uint256 indexed cdpId,
        address indexed provider,
        address indexed collateralToken,
        uint256 collateral,
        uint256 debt,
        uint256 debtPrice,
        Maturity maturity,
        uint48 startTime,
        uint48 endTime
    );
    event CDPRedeemed(
        uint256 indexed cdpId,
        address indexed provider,
        bool indexed closed,
        uint256 redeemAmount,
        uint256 burnAmount,
        uint256 remainingCollateral
    );
    event RedeemConfigUpdated(uint32 minDuration, uint32 maxDuration, uint32 notBefore);
    event RedeemEpochCreated(uint256 indexed epochId, uint48 startTime, uint48 endTime);
    event RedeemEpochQuotaUpdated(uint256 indexed epochId, address indexed token, uint256 quota, uint256 redeemed);
    event TotalAvailableBalanceRatioThresholdUpdated(uint256 newThreshold);

    error NotCDPProvider();
    error NotBeforeInvalid();
    error NotReservePool();
    error NoNeedToCreateCDPRedeemEpoch();
    error DurationInvalid();
    error MinDurationInvalid();
    error MaxDurationInvalid();
    error LengthMismatched();
    error CollateralInvalid();
    error DebtInvalid();
    error MaturityInvalid();
    error DebtPriceInvalid();
    error CDPNotExpired();
    error CDPAlreadyClosed();
    error NoActiveRedeemEpoch();
    error RedeemAmountExceededLimit(uint256 remaining);
    error RedeemAmountTooSmall();
    error ThresholdInvalid();

    /**
     * @notice Updates `reservePool` to `newReservePool`
     */
    function setReservePool(IReservePool newReservePool) external;
    /**
     * @notice Updates `tokenManager` to `newTokenManager`
     */
    function setTokenManager(ITokenManager newTokenManager) external;
    /**
     * @notice Updates the address of `oracle` to `newOracle`
     */
    function setOracle(IOracle newOracle) external;
    /**
     * @notice Updates CDP redemption and reserve ratio configuration using the provided `config`
     */
    function setRedeemConfig(RedeemConfig calldata config) external;
    /**
     * @notice Updates total available balance ratio threshold to `newThreshold`
     */
    function setTotalAvailableBalanceRatioThreshold(uint256 newThreshold) external;
    /**
     * @notice Pauses functions, including collateral depositing and withdrawing,
     *         portfolio receiving and sending, CDP opening and redeeming.
     */
    function pause() external;
    /**
     * @notice Resumes paused functions, allowing collateral depositing and withdrawing,
     *         portfolio receiving and sending, CDP opening and redeeming.
     */
    function unpause() external;
    /**
     * @notice Deposits the specified amount of collateral token exclusively from the reserve pool for revenue realization
     * @param token Address of the collateral token
     * @param amount Amount of the collateral
     */
    function depositCollateral(address token, uint256 amount) external;
    /**
     * @notice Deposits the specified amount of collateral token exclusively for the insurance auction.
     *         Increases the value of `_cdpOpenQuota`, which is later consumed by CDP providers when creating CDPs.
     * @param token Address of the collateral token
     * @param amount Amount of the collateral
     */
    function depositCollateralFromAuction(address token, uint256 amount) external;
    /**
     * @notice Withdraws the specified `amount` of `token` exclusively for the reserve pool
     * @param token Address of the collateral token
     * @param amount Amount of the collateral
     */
    function withdrawCollateral(address token, uint256 amount) external;
    /**
     * @notice Receives the portfolio from the sender with the portfolio role
     * @param token Address of the token
     * @param amount Amount of the portfolio
     */
    function receivePortfolio(address token, uint256 amount) external;
    /**
     * @notice Sends the portfolio to the receiver with the portfolio role, and the caller must have the timelock role.
     * @param token Address of the token
     * @param receiver Account to receive the portfolio
     * @param amount Amount of the portfolio
     */
    function sendPortfolio(address token, address receiver, uint256 amount) external;
    /**
     * @notice Opens the CDP exclusively for the insurance auction
     * @param provider Address of the bidder
     * @param collateralToken Address of the collateral token
     * @param collateral Amount of the collateral
     * @param debtPrice The price of `debtToken`/`collateralToken`
     * @param maturity CDP lock-up period
     * @param startTime CDP start time
     * @return cdpId ID of the created CDP
     */
    function openCDP(
        address provider,
        address collateralToken,
        uint256 collateral,
        uint256 debtPrice,
        Maturity maturity,
        uint48 startTime
    ) external returns (uint256 cdpId);
    /**
     * @notice Closes the CDP with `cdpId` when the lock expires.
     *         Redeems all remaining amount of the collateral token and burns the debt token.
     */
    function closeCDP(uint256 cdpId) external;
    /**
     * @notice Redeems the specified `redeemAmount` of the collateral token
     *         when the lock of the CDP with `cdpId` expires.
     *         It can redeem partially if the redemption quota of the current redemption epoch is insufficient to redeem all remaining.
     *         It will close the CDP when all remaining amount has been redeemed.
     */
    function redeemCDP(uint256 cdpId, uint256 redeemAmount) external;
    /**
     * @notice Creates the next CDP redemption epoch, restricted to task executors only.
     *         Reverts if there is already a redemption epoch that has not started yet,
     *         or if the current time is before the specified limitation.
     * @param duration Duration in seconds of the new redemption epoch
     * @param tokens Array of token addresses to set the redemption quotas for the new redemption epoch
     * @param quotas Array of redemption quotas; the array length must be the same as `tokens`
     * @return epochId ID of the new redemption epoch
     */
    function updateRedeemEpoch(uint32 duration, address[] calldata tokens, uint256[] calldata quotas)
        external
        returns (uint256 epochId);

    /**
     * @notice Gets the address of 4REX
     */
    function debtToken() external view returns (IERC20Token);
    function reservePool() external view returns (IReservePool);
    function tokenManager() external view returns (ITokenManager);
    /**
     * @notice Gets the pool collateral for the specified `token`, inclusive of the invested amount
     */
    function getCollateral(address token) external view returns (uint256);
    /**
     * @notice Gets the CDP redemption config
     */
    function getRedeemConfig() external view returns (RedeemConfig memory);
    /**
     * @notice Gets the latest CDP ID
     */
    function getCDPId() external view returns (uint256);
    /**
     * @notice Gets the CDP with the specified `cdpId`
     */
    function getCDP(uint256 cdpId) external view returns (CDP memory);
    /**
     * @notice Gets the quota of the `auction` contract that is available to create CDPs of `token`
     */
    function getCDPOpenQuota(address auction, address token) external view returns (uint256);
    /**
     * @notice Gets the latest ID of the CDP redemption epoch, potentially including the upcoming next epoch.
     */
    function getRedeemEpochId() external view returns (uint256);
    /**
     * @notice Gets the ID of the active CDP redemption epoch within the current period.
     *         Reverts if there is currently no active CDP redemption epoch.
     */
    function getActiveRedeemEpochId() external view returns (uint256);
    /**
     * @notice Gets the time range of the CDP redemption epoch for the specified `epochId`
     * @return startTime Begin time of the CDP redemption epoch
     * @return endTime End time of the CDP redemption epoch
     */
    function getRedeemEpochPeriod(uint256 epochId) external view returns (uint48 startTime, uint48 endTime);
    /**
     * @notice Gets the amount states of `token` for the CDP redemption epoch
     * @return quota Total quota
     * @return redeemed Redeemed amount. The redeemable amount to be redeemed will be `quota - redeemed`.
     */
    function getCollateralRedeemQuota(uint256 epochId, address token)
        external
        view
        returns (uint256 quota, uint256 redeemed);
    /**
     * @notice Gets the the threshold setting for the total available balance ratio
     */
    function getTotalAvailableBalanceRatioThreshold() external view returns (uint256);
    /**
     * @notice Gets the lock duration in seconds for the specified `maturity` of the `Maturity` enum
     */
    function getMaturitySeconds(Maturity maturity) external pure returns (uint32);

    function GOVERNOR_ROLE() external pure returns (bytes32);
    function GUARDIAN_ROLE() external pure returns (bytes32);
    function TIMELOCK_ROLE() external pure returns (bytes32);
    function PORTFOLIO_ROLE() external pure returns (bytes32);
    function AUCTION_ROLE() external pure returns (bytes32);
    function TASK_EXECUTOR_ROLE() external pure returns (bytes32);
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.19;

interface IOracle{
    event newPrice(address indexed _asset, uint64 _timestamp, uint256 _price);
    event StalenessThresholdUpdated(address indexed quoteToken, uint32 threshold);
    event PriceToleranceUpdated(address indexed quoteToken, uint256 minPrice, uint256 maxPrice);

    error LengthMismatched();
    error PriceStale();
    error PriceToleranceInvalid();
    error PriceNotInTolerance();
    error TokensInvalid();
    error PriceZero();
    error TimestampInvalid();

    /**
     * @notice Updates the price of `baseToken`/`asset` to the specified `price` at the given timestamp.
     *         Reverts if the price tolerance is invalid or if the new price is outside the acceptable tolerance range.
     */
    function putPrice(address asset, uint64 timestamp, uint256 price) external;

    /**
     * @notice Updates the prices
     * @param _array An array of `NewPrice` structs containing information about the new prices.
     */
    function updatePrices(NewPrice[] calldata _array) external;

    /**
     * @notice Updates staleness thresholds, reverts if the array lengths mismatched.
     * @param quoteTokens The array of quote currency addresses
     * @param thresholds The array of the staleness thresholds in seconds
     */
    function setStalenessThresholds(address[] calldata quoteTokens, uint32[] calldata thresholds) external;

    /**
     * @notice Updates the price tolerance range of USD1/`token`
     * @param quoteToken Address of the quote currency
     * @param minPrice Min price tolerance
     * @param maxPrice Max price tolerance
     */
    function setPriceTolerance(address quoteToken, uint256 minPrice, uint256 maxPrice) external;

    /**
     * @notice Returns the base token for all oracle prices, which is USD1.
     */
    function baseToken() external view returns (address);

    /**
     * @notice Gets the price info of `asset`
     */
    function getPrice(address asset) external view returns (uint64 timestamp, uint64 prevTimestamp, uint256 price, uint256 prevPrice);

    /**
     * @notice Gets a list of prices.
     * @param assets The token addresses
     * @return The prices of assets
     */
    function getPrices(address[] calldata assets) external view returns (IOracle.Price[] memory);

    /**
     * @notice Gets the latest price.
     *         Reverts if the timestamp of the price exceeds the staleness limit, or the price is zero.
     * @param quoteToken Address of the quote currency
     * @return price The price of `baseToken`/`quoteToken`
     */
    function getLatestPrice(address quoteToken) external view returns (uint256 price);

    /**
     * @notice Gets the price staleness threshold, returns `STALENESS_DEFAULT_THRESHOLD` if it is zero.
     * @param quoteToken Address of the quote token
     * @return The staleness threshold in seconds
     */
    function getStalenessThreshold(address quoteToken) external view returns (uint32);

    /**
     * @notice Gets the price tolerance of `baseToken`/`quoteToken`
     */
    function getPriceTolerance(address quoteToken) external view returns (uint256 minPrice, uint256 maxPrice);

    /**
     * @notice Gets the quote token of oracle price by two token addresses.
     *          Because of the base currencies of all oracle prices are always USD1 (e.g., USD1/USDT and USD1/USD91),
     *          one of `tokenX` or `tokenY` must be USD1, and the other must not be USD1.
     * @param tokenX Address of base currency or quote currency
     * @param tokenY Address of base currency or quote currency
     * @return quoteToken The quote currency of oracle price
     */
    function getQuoteToken(address tokenX, address tokenY) external view returns (address quoteToken);

    /**
     * @notice Gets the quote token of oracle and the latest price.
     *         Reverts if the two token addresses are invalid, the timestamp of the price exceeds the staleness limit, or the price is zero.
     * @param tokenX Address of base currency or quote currency
     * @param tokenY Address of base currency or quote currency
     */
    function getQuoteTokenAndPrice(address tokenX, address tokenY) external view returns (address quoteToken, uint256 price);

    function FEEDER_ROLE() external pure returns (bytes32);

    function GUARDIAN_ROLE() external pure returns (bytes32);

    /**
     * @notice Default threshold for staleness in seconds.
     *          When the value of `_stalenessThreshold` is zero, this default value is used.
     */
    function STALENESS_DEFAULT_THRESHOLD() external pure returns (uint32);

    function decimals() external pure returns (uint8);

    // Struct of main contract XOracle
    struct Price{
        address asset;
        uint64 timestamp;
        uint64 prev_timestamp;
        uint256 price;
        uint256 prev_price;
    }

    struct NewPrice{
        address asset;
        uint64 timestamp;
        uint256 price;
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;


interface IPoolBalances {
    /**
     * @notice Emitted when the balance of `token` is updated to `newBalance`
     */
    event BalanceUpdated(address indexed token, uint256 newBalance);
    /**
     * @notice Emitted when portfolio `amount` of `token` is received from `sender`
     */
    event PortfolioReceived(address indexed token, address indexed sender, uint256 amount);
    /**
     * @notice Emitted when portfolio `amount` of `token` is sent to `receiver`
     */
    event PortfolioSent(address indexed token, address indexed receiver, uint256 amount);
    /**
     * @notice Emitted when the portfolio of `token` is updated to `newPortfolio`
     */
    event PortfolioUpdated(address indexed token, uint256 newPortfolio);

    error SenderInvalid();
    error ReceiverInvalid();
    error AmountInvalid();
    error PoolBalanceInsufficient();

    /**
     * @notice Gets the current amount of `token` used for investment in the portfolio
     */
    function getPortfolio(address token) external view returns (uint256);
    /**
     * @notice Gets the available pool balance of `token`
     */
    function getAvailableBalance(address token) external view returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "src/interfaces/IERC20Token.sol";
import "src/interfaces/IPoolBalances.sol";
import "src/interfaces/ISwapFunctions.sol";
import "src/interfaces/ITokenManager.sol";
import "src/interfaces/IOracle.sol";

interface IReservePool is IPoolBalances, ISwapFunctions {
    enum ReserveStatus {
        /// When total reserves, total collaterals and total liabilities are zero
        Undefined,
        /// When total liabilities is zero
        Infinite,
        /// When total reserves, total collaterals and total liabilities are non-zero
        Finite
    }

    struct InitializeConfig {
        address governor;
        address guardian;
        address timelock;
        address taskExecutor;
        address oracle;
        address surplusPool;
        address insurancePool;
        ITokenManager tokenManager;
        uint256 minReserveRatio;
        uint256 maxReserveRatio;
        RevenueRealizeConfig revenueRealizeConfig;
    }

    struct RevenueRealizeConfig {
        uint96 minAssetRatio;
        /// Threshold for triggering revenue realization when the asset ratio is greater than this value
        uint96 assetRatioThreshold;
    }

    struct RealizeRevenuesVars {
        address usd1;
        uint256 realizedTokenCount;
        uint256 totalAvailable;
        uint256 liabilities;
        uint256 totalRealizable;
        address[] assetTokens;
        uint256[] prices;
        uint256[] estimatedAvailable;
    }

    /**
     * @notice Emitted when `oracle` is updated
     */
    event SetOracle(address indexed newOracle);
    /**
     * @notice Emitted when `surplusPool` is updated
     */
    event SetSurplusPool(address indexed newSurplusPool);
    /**
     * @notice Emitted when `insurancePool` is updated
     */
    event SetInsurancePool(address indexed newInsurancePool);
    /**
     * @notice Emitted when `tokenManager` is updated
     */
    event SetTokenManager(ITokenManager indexed newTokenManager);
    /**
     * @notice Emitted when `sender` swap tokens
     */
    event Swapped(
        address indexed tokenIn,
        address indexed tokenOut,
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut,
        address feeToken,
        uint256 fee,
        uint24 feeNumerator,
        uint256 price
    );
    /**
     * @notice Emitted when swapping `fee` is sent to `receiver`
     */
    event SwapFeeSent(address indexed feeToken, address indexed receiver, uint256 fee);
    event ProtocolOwnedLiquidityDeposited(address indexed token, address indexed sender, uint256 amount);
    event ProtocolOwnedLiquiditySwapped(
        address indexed tokenIn,
        address indexed tokenOut,
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut
    );
    /**
     * @notice Emitted when the protocol performs a stability burn
     */
    event StabilityBurned(address indexed token, address indexed account, uint256 amount);
    event RevenueRealizeConfigUpdated(uint96 minAssetRatio, uint96 assetRatioThreshold);
    event RevenueRealized(address indexed token, uint256 amount);
    event ReserveRatioRangeUpdated(uint256 newMinReserveRatio, uint256 newMaxReserveRatio);
    event ReserveGrowthBurned(address indexed token, uint256 amount);

    error NotSurplusPool();
    error BalanceInsufficient();
    error SwapResultInvalid();
    error ReserveRatioInsufficient();
    error ReserveRatioExceededMaxReserveRatio();
    error TokenNotSupported();
    error RevenueRealizeConfigInvalid();
    error NoNeedToRealizeRevenue();
    error MinReserveRatioInvalid();
    error MaxReserveRatioInvalid();

    /**
     * @notice Updates the address of `oracle` to `newOracle`
     */
    function setOracle(address newOracle) external;
    /**
     * @notice Updates the address of `surplusPool` to `newSurplusPool`
     */
    function setSurplusPool(address newSurplusPool) external;
    /**
     * @notice Updates the address of `insurancePool` to `newInsurancePool`
     */
    function setInsurancePool(address newInsurancePool) external;
    /**
     * @notice Updates the address of `tokenManager` to `newTokenManager`
     */
    function setTokenManager(ITokenManager newTokenManager) external;
    /**
     * @notice Updates the setting of min reserve ratio and max reserve ratio
     */
    function setReserveRatioRange(uint256 newMinReserveRatio, uint256 newMaxReserveRatio) external;
    /**
     * @notice Updates the revenue realization config
     */
    function setRevenueRealizeConfig(RevenueRealizeConfig calldata config) external;
    /**
     * @notice Pauses functions, including swapping and protocol-owned liquidity operations.
     */
    function pause() external;
    /**
     * @notice Resumes paused functions, allowing swapping and protocol-owned liquidity operations.
     */
    function unpause() external;
    /**
     * @notice Swaps tokens
     * @param tokenIn The address of the token to be spent
     * @param tokenOut The address of the token to be obtained
     * @param amountType The type of the amount
     * @param amount When `amountType` is `In`, it's the number of `tokenIn` that the user wants to spend.
     *               When `amountType` is `Out`, it's the number of `tokenOut` that the user wants to obtain.
     * @return amountIn The amount of `tokenIn` spent
     * @return amountOut The amount of `tokenOut` obtained
     */
    function swap(address tokenIn, address tokenOut, AmountType amountType, uint256 amount)
        external
        returns (uint256 amountIn, uint256 amountOut);
    /**
     * @notice Deposits the asset token or USD1 from the surplus pool only
     * @param token Address of the token
     * @param amount The amount to deposit
     */
    function depositProtocolOwnedLiquidity(address token, uint256 amount) external;
    /**
     * @notice Swaps the asset token to USD1 for surplus pool only
     * @param tokenIn The address of the asset token
     * @param amountIn The amount of `tokenIn` spent
     */
    function swapProtocolOwnedLiquidityToUSD1(address tokenIn, uint256 amountIn) external returns (uint256 amountOut);
    /**
     * @notice Burns the specified `amount` of USD1 tokens from the surplus pool balance when performing a stability burn
     */
    function burnUSD1(uint256 amount) external;
    /**
     * @notice Burns the specified `amount` of the given `token` from the reserve pool during a reserve growth burn
     */
    function reserveGrowthBurn(address token, uint256 amount) external;
    /**
     * @notice Deposits the asset tokens to the insurance pool
     *         when the available asset ratio is greater than the threshold of `_revenueRealizeConfig`.
     */
    function realizeRevenues() external;

    function oracle() external view returns (IOracle);
    function surplusPool() external view returns (address);
    function insurancePool() external view returns (address);
    function tokenManager() external view returns (ITokenManager);
    /**
     * @notice Estimates swapping result for quoting
     * @param tokenIn The address of the token to be spent
     * @param tokenOut The address of the token to be obtained
     * @param amountType The type of the amount
     * @param amount When `amountType` is `In`, it's the number of `tokenIn` that the user wants to spend.
     *               When `amountType` is `Out`, it's the number of `tokenOut` that the user wants to obtain.
     * @return amountIn The amount of `tokenIn` to be spent
     * @return amountOut The amount of `tokenOut` to be obtained
     * @return feeToken The fee token
     * @return fee Swapping fee calculated in `feeToken`
     * @return feeNumerator The numerator of the fee fraction
     * @return price The price of `tokenIn`/`tokenOut`
     */
    function estimateSwapResult(address tokenIn, address tokenOut, AmountType amountType, uint256 amount)
        external
        view
        returns (
            uint256 amountIn,
            uint256 amountOut,
            IERC20Token feeToken,
            uint256 fee,
            uint24 feeNumerator,
            uint256 price
        );
    /**
     * @notice Gets the pool reserve for the specified `token`, inclusive of the invested amount
     */
    function getReserve(address token) external view returns (uint256);
    /**
     * @notice Gets the reserve status
     * @return reserveStatus `Undefined` when `reserves`, `collaterals` and `liabilities` are zero.
     *                           `Infinite` when `liabilities` is zero.
     *                           Otherwise `Finite`.
     * @return reserves Total reserves denominated in USD1
     * @return collaterals Total collaterals denominated in USD1
     * @return liabilities Total liabilities denominated in USD1
     * @return reserveRatio The numerator of the reserve ratio is expressed in 18 decimal places
     */
    function getReserveStatus()
        external
        view
        returns (
            ReserveStatus reserveStatus,
            uint256 reserves,
            uint256 collaterals,
            uint256 liabilities,
            uint256 reserveRatio
        );

    /**
     * @notice Gets the available reserves, available collaterals, and total liabilities, all denominated in USD1,
     *         and the total available balance ratio.
     */
    function getTotalAvailableBalanceRatio()
        external
        view
        returns (uint256 availableReserves, uint256 availableCollaterals, uint256 liabilities, uint256 totalAvailableBalanceRatio);
    /**
     * @notice Gets the min reserve ratio setting
     */
    function getMinReserveRatio() external view returns (uint256);
    /**
     * @notice Gets the max reserve ratio setting
     */
    function getMaxReserveRatio() external view returns (uint256);
    /**
     * @notice Gets the revenue realization config
     */
    function getRevenueRealizeConfig() external view returns (RevenueRealizeConfig memory);
    /**
     * @notice Returns true when the reserve status is not `Infinite`,
     *         and the reserve ratio is less than or equal to the min reserve ratio.
     */
    function isReserveRatioLessThanOrEqualToMinReserveRatio() external view returns (bool);
    /**
     * @notice Returns true when the reserve ratio is greater than the max reserve ratio.
     */
    function isReserveRatioGreaterThanMaxReserveRatio() external view returns (bool);

    function GOVERNOR_ROLE() external pure returns (bytes32);
    function GUARDIAN_ROLE() external pure returns (bytes32);
    function TIMELOCK_ROLE() external pure returns (bytes32);
    function TASK_EXECUTOR_ROLE() external pure returns (bytes32);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

interface ISwapFunctions {
    enum AmountType {
        In,
        Out
    }

    struct SwapRequest {
        AmountType amountType;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint256 feeNumerator;
        uint256 feeBase;
        address feeToken;
        uint256 price;
        uint256 priceBase;
        address quoteToken;
    }

    error FeeFractionInvalid();
    error ParameterInvalid();
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "./IERC20Token.sol";
import "./ITypeTokens.sol";
import "./ITokenPairs.sol";

interface ITokenManager is ITypeTokens, ITokenPairs {
    enum TokenType {
        Undefined, // 0 indicates not in the pool
        Asset, // Asset tokens for reserve, e.g., USDT
        Stable // Stable tokens of Unitas protocol, e.g., USD1, USD91
    }

    struct PairConfig {
        address baseToken;
        address quoteToken;
        /**
         * @notice The numerator of swapping fee ratio when buying `baseToken`
         */
        uint24 buyFee;
        uint232 buyReserveRatioThreshold;
        /**
         * @notice The numerator of swapping fee ratio when selling `baseToken`
         */
        uint24 sellFee;
        uint232 sellReserveRatioThreshold;
    }

    struct TokenConfig {
        address token;
        TokenType tokenType;
    }

    /**
     * @notice Emitted when the setting of the pair is updated
     */
    event PairUpdated(
        bytes32 indexed pairHash,
        address indexed baseToken,
        address indexed quoteToken,
        uint24 buyFee,
        uint232 buyReserveRatioThreshold,
        uint24 sellFee,
        uint232 sellReserveRatioThreshold
    );

    error LengthMismatched();
    error PairsMustRemoved();
    error PairInvalid();
    error FeeNumeratorInvalid();
    error ReserveRatioThresholdInvalid();
    error USD1CannotBeRemoved();

    /**
     * @notice Adds the tokens and the pairs to the pool.
     *         The input arrays can be empty, and the update is performed only
     *         when either `tokens` or `pairs` array has values.
     * @param tokens The settings of the tokens to be added
     * @param pairs The settings of the pairs to be added
     */
    function addTokensAndPairs(TokenConfig[] calldata tokens, PairConfig[] calldata pairs) external;
    /**
     * @notice Removes the tokens and the pairs from the pool.
     *          The input arrays can be empty, and the update is performed only
     *          when either `tokens`, or `pairTokensX` and `pairTokensY` have values.
     *          Since `_removeToken` checks there must be no pairs associated with the token,
     *          removes the pairs before the tokens.
     * @param tokens The addresses of the tokens to be removed
     * @param pairTokensX The addresses of the base tokens or quote tokens to be removed
     * @param pairTokensY The addresses of the base tokens or quote tokens to be removed.
     *         The length of `pairTokensX` and `pairTokensY` must be the same.
     */
    function removeTokensAndPairs(address[] calldata tokens, address[] calldata pairTokensX, address[] calldata pairTokensY) external;
    /**
     * @notice Updates the settings of the pairs,
     *          reverts if any pair of the array is invalid or not in the pool.
     * @param pairs The settings of the pairs
     */
    function updatePairs(PairConfig[] calldata pairs) external;

    function usd1() external view returns (IERC20Token);
    /**
     * @notice Gets an array of pair settings, supporting pagination.
     *          Reverts if the index plus the count is out of bounds,
     *          or there is an overflow in the sum of index and count.
     * @param index The offset of the list
     * @param count The number of pairs to retrieve
     * @return An array of `PairConfig`
     */
    function listPairsByIndexAndCount(uint256 index, uint256 count) external view returns (PairConfig[] memory);
    /**
     * @notice Gets the token type of `token`
     */
    function getTokenType(address token) external view returns (TokenType);
    /**
     * @notice Gets the pair setting by two token addresses, reverts if the pair does not exist.
     * @param tokenX Address of base currency or quote currency
     * @param tokenY Address of base currency or quote currency
     * @return pair The setting of the pair
     */
    function getPair(address tokenX, address tokenY) external view returns (PairConfig memory pair);
    /**
     * @notice Gets the pair setting by `index`
     */
    function pairByIndex(uint256 index) external view returns (PairConfig memory pair);

    function GOVERNOR_ROLE() external pure returns (bytes32);
    function TIMELOCK_ROLE() external pure returns (bytes32);
    /**
     * @notice Gets the denominator of reserve ratio and threshold that has 18 decimals
     */
    function RESERVE_RATIO_BASE() external pure returns (uint256);
    /**
     * @notice Gets the denominator of swapping fee that has 6 decimals
     */
    function SWAP_FEE_BASE() external pure returns (uint256);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

interface ITokenPairs {
    /**
     * @notice Emitted when the pair is added to the pool
     * @param pairHash The hash of the pair
     * @param tokenX The smaller token address
     * @param tokenY The larger token address
     */
    event PairAdded(bytes32 indexed pairHash, address indexed tokenX, address indexed tokenY);
    /**
     * @notice Emitted when the pair is removed from the pool
     * @param pairHash The hash of the pair
     * @param tokenX The smaller token address
     * @param tokenY The larger token address
     */
    event PairRemoved(bytes32 indexed pairHash, address indexed tokenX, address indexed tokenY);

    error TokensNotSorted();
    error PairAlreadyInPool();
    error PairNotInPool();
    error ListPairsInputOutOfBounds();

    /**
     * @notice Gets an array of token addresses that are paired with the specified token, supporting pagination.
     *          Reverts if the index plus the count is out of bounds,
     *          or there is an overflow in the sum of index and count.
     * @param token The token address
     * @param index The offset of the list
     * @param count The number of tokens to retrieve
     * @return An array of token addresses that are paired with `token`
     */
    function listPairTokensByIndexAndCount(address token, uint256 index, uint256 count) external view returns (address[] memory);
    /**
     * @notice Sorts `tokenX` and `tokenY` and returns whether the pair is in the pool
     */
    function isPairInPool(address tokenX, address tokenY) external view returns (bool);
    /**
     * @notice Gets the total number of tokens that are paired with the specified token.
     * @param token The token address
     */
    function pairTokenLength(address token) external view returns (uint256);
    /**
     * @notice Gets the paired token address by `token` and `index`
     */
    function pairTokenByIndex(address token, uint256 index) external view returns (address);
    /**
     * @notice Gets the total number of all pairs
     */
    function pairLength() external view returns (uint256);
    /**
     * @notice Sorts `tokenX` and `tokenY` and gets the hash of the pair
     */
    function getPairHash(address tokenX, address tokenY) external pure returns (bytes32);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

interface ITypeTokens {
    /**
     * @notice Emitted when `token` is added to the pool
     */
    event TokenAdded(address indexed token, uint8 tokenType);
    /**
     * @notice Emitted when `token` is removed from the pool
     */
    event TokenRemoved(address indexed token, uint8 tokenType);

    error NotAssetToken(address token);
    error TokenNotInPool(address token);
    error TokenAlreadyInPool(address token);
    error TokenTypeInvalid();
    error ListTokensInputOutOfBounds();

    /**
     * @notice Gets an array of token addresses with the specified token type, supporting pagination.
     *          Reverts if the index plus the count is out of bounds,
     *          or there is an overflow in the sum of index and count.
     * @param tokenType The token type
     * @param index The offset of the list
     * @param count The number of tokens to retrieve
     * @return An array of token addresses belonging to `tokenType`
     */
    function listTokensByIndexAndCount(uint8 tokenType, uint256 index, uint256 count) external view returns (address[] memory);
    /**
     * @notice Returns true when `token` is in the pool
     */
    function isTokenInPool(address token) external view returns (bool);
    /**
     * @notice Gets the token count by `tokenType`
     */
    function tokenLength(uint8 tokenType) external view returns (uint256);
    /**
     * @notice Gets the token address by `tokenType` and `index`
     */
    function tokenByIndex(uint8 tokenType, uint256 index) external view returns (address);
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

library AddressUtils {
    error AddressZero();
    error AddressCodeSizeZero();

    /**
     * @notice Reverts if `account` is zero or the code size is zero
     */
    function checkContract(address account) internal view {
        checkNotZero(account);

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        if (size == 0) revert AddressCodeSizeZero();
    }

    /**
     * @notice Reverts if `account` is zero
     */
    function checkNotZero(address account) internal pure {
        if (account == address(0)) revert AddressZero();
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

library Constants {
    /*
     * @notice The denominator is mostly used to represent one in the protocol, with 18 decimal places,
     *         such as price and reserve ratio.
     */
    uint256 internal constant BASE = 1e18;
    /**
     * @notice The denominator of swapping fee that has 6 decimals
     */
    uint256 internal constant SWAP_FEE_BASE = 1e6;
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

library ConvertUtils {
    using MathUpgradeable for uint256;

    function convertByFromPrice(
        uint256 fromBase,
        uint256 toBase,
        uint256 fromAmount,
        uint256 price,
        uint256 priceBase
    ) internal pure returns (uint256) {
        return fromAmount.mulDiv(price * toBase, priceBase * fromBase);
    }

    function convertByToPrice(
        uint256 fromBase,
        uint256 toBase,
        uint256 fromAmount,
        uint256 price,
        uint256 priceBase
    ) internal pure returns (uint256) {
        return fromAmount.mulDiv(priceBase * toBase, price * fromBase);
    }
}