// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./IGarbageSale.sol";
import "./IGarbageVesting.sol";

contract GarbageSale is Pausable, AccessControl, IGarbageSale {
    using SafeERC20 for IERC20;

    struct Stage {
        uint256 tokensToSale; // Amount of tokens to sale
        uint256 tokensSold; // Sold tokens amount
        uint256 priceInUSD; // Price in USD with 8 decimals
    }

    Stage[] public stages; // Array with stages and their info

    IERC20 public garbageToken; // Token for sale
    IERC20 public usdt; // USDT token for garbage token purchasing
    IGarbageVesting public vestingContract; // Address of vesting contract
    address public treasury; // Address to receive funds

    uint256 public maxClaimableAmountInUSD; // Max amount of garbage tokens in USD (8 decimals) which can bought without vesting. Any amount of garbage above this limit will be vested.
    uint256 public currentStage; // Current stage
    uint256 public saleStartDate; // Date when garbage token sale starts
    uint256 public saleDeadline; // Deadline for garbage token sale
    uint256 public claimDate; // Date when users can claim their tokens
    uint256 public bloggerRewardPercent; // Reward percent for referrers-blogger
    uint256 public userRewardPercent; // Reward percent for referrers-user

    uint256 public totalTokensToBeDistributed; // Total amount of tokens to be distributed (sum of initial garbage tokens amount from all stages)
    uint256 public totalTokensSold; // Total amount of tokens sold
    uint256 public totalTokensClaimed; // Total amount of tokens claimed by users
    uint256 public totalRewardsClaimedEth; // Total amount of ETH claimed by referrers
    uint256 public totalRewardsClaimedUsdt; // Total amount of USDT claimed by referrers
    uint256 public totalRewardsEth; // Total amount of ETH received by referrers
    uint256 public totalRewardsUsdt; // Total amount of USDT received by referrers

    uint256 public constant PERCENT_DENOMINATOR = 10000; // so, 10% -> 1000, 5% -> 500

    bytes32 public constant WERT_ROLE = keccak256("WERT_ROLE"); // Role for wert wallet
    bytes32 public constant BLOGGER_ROLE = keccak256("BLOGGER_ROLE"); // Role for referrers-blogger
    bytes32 public constant REFERRER_ROLE = keccak256("REFERRER_ROLE"); // Role for referrers-user
    bytes32 public constant AFFILIATE_ADMIN_ROLE = keccak256("AFFILIATE_ADMIN_ROLE"); // Role for affiliate admin
    bytes32 public constant MEME_ADMIN_ROLE = keccak256("MEME_ADMIN_ROLE"); // Role for meme admin

    mapping(address => uint256) public referralRewardsEth; // Amount of ETH received by referrers
    mapping(address => uint256) public referralRewardsUsdt; // Amount of USDT received by referrers
    mapping(address => uint256) public claimableTokens; // Amount of garbage tokens claimable by users
    mapping(address => uint256) public totalGarbageBoughtInUSD; // Total amount of garbage tokens bought by user in USD (8 decimals). Needed to calculate vesting amount.

    AggregatorV3Interface public priceFeedUsdt; // Chainlink price feed for USDT
    AggregatorV3Interface public priceFeedEth; // Chainlink price feed for ETH

    event ClaimDateExtended(uint256 newClaimDate);
    event DeadlineExtended(uint256 newDeadline);
    event GarbageTokenChanged(address newGarbageToken);
    event PriceFeedEthChanged(address newPriceFeedEth);
    event PriceFeedUsdtChanged(address newPriceFeedUsdt);
    event RewardCalculated(uint256 reward, address referrer);
    event RewardPaid(address referrer, uint256 amountEth, uint256 amountUsdt);
    event RewardPercentChanged(uint256 bloggerRewardPercent, uint256 userRewardPercent);
    event RemainderWithdrawn(address treasury, uint256 amountWithdrawn);
    event StageAdded(uint256 tokens, uint256 priceInUSD);
    event TokensBought(address buyer, uint256 amount);
    event TokensClaimed(address claimer, uint256 amount);
    event TreasuryChanged(address newTreasury);
    event UsdtChanged(address newUsdt);
    event VestingContractChanged(address newVestingContract);

    error AllStagesCompleted();
    error CallerIsNotAdmin();
    error CallerIsNotAffiliateAdmin();
    error ClaimDateNotReached();
    error ContractPaused();
    error DeadlineNotReached();
    error NewDeadlineIsInPast();
    error NotEnoughTokensInLastStage();
    error NotEnoughTokensInNextStage();
    error NotEnoughTokensInStageToDistribute();
    error PercentEqualOrGreaterThanDenominator();
    error ReferrerIsNotRegistered();
    error ReferrerIsSender();
    error SaleIsStarted();
    error SaleIsNotStarted();
    error TokenSaleEnded();
    error TransferFailed();
    error ZeroAddress();
    error ZeroAmount();

    modifier nonZeroAddress(address addr) {
        if (addr == address(0)) revert ZeroAddress();
        _;
    }

    modifier nonZeroAmount(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }

    modifier whenActive() {
        if (saleStartDate > block.timestamp) {
            revert SaleIsNotStarted();
        }
        if (block.timestamp >= saleDeadline) revert TokenSaleEnded();
        if (currentStage >= stages.length) revert AllStagesCompleted();
        if (paused()) revert ContractPaused();
        _;
    }

    modifier beforeSaleStart() {
        if (block.timestamp > saleStartDate) {
            revert SaleIsStarted();
        }
        _;
    }

    constructor(
        IERC20 _token,
        IERC20 _usdt,
        IGarbageVesting _vestingContract,
        address _priceFeedEth,
        address _priceFeedUsdt,
        address _treasury
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        setMaxClaimableAmountInUSD(50_000 * 1e8); // 50k USD

        setSaleStartDate(1698168600); // Tue Oct 24 2023 17:30:00 GMT+0000
        setSaleDeadline(saleStartDate + 4 * 30 days);
        setClaimDate(saleDeadline + 1825 days);

        setVestingContract(_vestingContract);
        setTreasury(_treasury);
        setUsdt(_usdt);
        bloggerRewardPercent = 1000;
        userRewardPercent = 500;
        setPriceFeedEth(_priceFeedEth);
        setPriceFeedUsdt(_priceFeedUsdt);

        _addStages();
        setGarbageToken(_token);

        _setupRole(AFFILIATE_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(BLOGGER_ROLE, AFFILIATE_ADMIN_ROLE);
        _setRoleAdmin(REFERRER_ROLE, AFFILIATE_ADMIN_ROLE);
    }

    receive() external payable {}

    ///@notice Pause contract
    ///@dev Only admin can pause contract
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    ///@notice Unpause contract
    ///@dev Only admin can unpause contract
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @notice Buy garbage tokens with ETH
    /// @param referrer Referrer address
    /// @dev There is no purchase itself. Users collect their tokens in the claimTokens() function
    /// @dev Perform calculation of how many tokens the user is entitled to via _buyTokens() function
    /// @dev Transfer ETH to the treasury
    /// @dev Reward to the referrer is kept on the contract
    function buyTokensWithEth(address referrer) public payable whenActive nonZeroAmount(msg.value) {
        uint256 reward = _calculateRewardReferral(referrer, msg.sender, msg.value, true);
        uint256 remaining = msg.value - reward;
        _buyTokens(msg.value, true, msg.sender);
        (bool success, ) = payable(treasury).call{value: remaining}("");
        if (!success) revert TransferFailed();
    }

    /// @notice Buy garbage tokens with USDT
    /// @param usdtAmount Amount of USDT - 6 decimals
    /// @param referrer Referrer address
    /// @dev There is no purchase itself. Users collect their tokens in the claimTokens() function
    /// @dev Perform calculation of how many tokens the user is entitled to via _buyTokens() function
    /// @dev Transfer USDT to the treasury
    /// @dev Reward to the referrer is kept on the contract
    function buyTokensWithUsdt(uint256 usdtAmount, address referrer) public whenActive nonZeroAmount(usdtAmount) {
        uint256 reward = _calculateRewardReferral(referrer, msg.sender, usdtAmount, false);
        uint256 remaining = usdtAmount - reward;
        usdt.safeTransferFrom(msg.sender, treasury, remaining);
        usdt.safeTransferFrom(msg.sender, address(this), reward);
        _buyTokens(usdtAmount, false, msg.sender);
    }

    /// @notice Version of the buyTokensWithEth() function for Wert ramp.
    /// @param referrer Referrer address
    /// @param user User address for whom tokens are bought
    function buyTokensWithEthWert(address referrer, address user)
        public
        payable
        whenActive
        onlyRole(WERT_ROLE)
        nonZeroAmount(msg.value)
    {
        uint256 reward = _calculateRewardReferral(referrer, user, msg.value, true);
        uint256 remaining = msg.value - reward;
        _buyTokens(msg.value, true, user);
        (bool success, ) = payable(treasury).call{value: remaining}("");
        if (!success) revert TransferFailed();
    }

    ///@notice Claim garbage tokens by user
    ///@dev Users can claim their tokens after the claim date
    ///@dev Tokens are transferred to the user's wallet
    ///@dev Calculation of user's garbage token amount is performed in the _buyTokens() function
    function claimTokens() external {
        if (block.timestamp < claimDate) {
            revert ClaimDateNotReached();
        }
        uint256 amount = claimableTokens[msg.sender];
        claimableTokens[msg.sender] = 0;
        totalTokensClaimed += amount;
        garbageToken.safeTransfer(msg.sender, amount);
        emit TokensClaimed(msg.sender, amount);
    }

    ///@notice Claim reward in USDT/ETH by referrer
    ///@dev Referrers can claim their reward without restrictions
    ///@dev Reward is transferred to the referrer's wallet
    function claimReferralReward() external {
        uint256 amountEth = referralRewardsEth[msg.sender];
        if (amountEth != 0) {
            referralRewardsEth[msg.sender] = 0;
            totalRewardsClaimedEth += amountEth;
            (bool success, ) = payable(msg.sender).call{value: amountEth}("");
            if (!success) revert TransferFailed();
        }

        uint256 amountUsdt = referralRewardsUsdt[msg.sender];
        if (amountUsdt != 0) {
            referralRewardsUsdt[msg.sender] = 0;
            totalRewardsClaimedUsdt += amountUsdt;
            usdt.safeTransfer(msg.sender, amountUsdt);
        }
        emit RewardPaid(msg.sender, amountEth, amountUsdt);
    }

    ///@notice Withdraw remainder of garbage tokens
    ///@dev Only admin can withdraw remainder of garbage tokens
    ///@dev Remainder of garbage tokens after token sale is transferred to the treasury
    ///@dev Possible to withdraw only after token sale is ended
    function withdrawRemainder(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (block.timestamp < saleDeadline || currentStage < stages.length) {
            revert DeadlineNotReached();
        }
        garbageToken.safeTransfer(treasury, amount);
        emit RemainderWithdrawn(treasury, amount);
    }

    /// @notice Calculate garbage token amount entitled to user
    /// @param amount Amount of ETH or USDT - 18 or 6 decimals
    /// @param isEth True if amount is in ETH, false if amount is in USDT
    /// @param user User address
    /*
    If user wants to buy more tokens than there are left in the current stage,
    the missing amount is taken from the next stage at the price specified in the new stage.
    Example: a user wants to buy 100 tokens from stage 0 at the price of 0.01, but there are only 50 tokens left in stage 0.
    The shortage, i.e. 100 - 50 = 50, will be sold to the user at the new price, 0.0125, which is specified in stage 1.
    */
    function _buyTokens(
        uint256 amount,
        bool isEth,
        address user
    ) internal {
        uint256 alreadyBoughtInUSD = totalGarbageBoughtInUSD[user];
        uint256 amountInUSD = getCurrencyInUSD(amount, isEth);
        totalGarbageBoughtInUSD[user] += amountInUSD;

        if (alreadyBoughtInUSD >= maxClaimableAmountInUSD) {
            _vestTokens(amount, isEth, user);
            return;
        }

        uint256 claimableAmount = amount;

        if (alreadyBoughtInUSD + amountInUSD > maxClaimableAmountInUSD) {
            uint256 amountToVestInUSD = alreadyBoughtInUSD + amountInUSD - maxClaimableAmountInUSD;
            uint256 amountToVest = getUSDinCurrency(amountToVestInUSD, isEth);
            _vestTokens(amountToVest, isEth, user);
            claimableAmount = amount - amountToVest;
        }

        (uint256 currentStageTokens, uint256 tokensNextStage) = _calculateTokenAmountFromCurrencyAmount(
            claimableAmount,
            isEth
        );

        _subtractTokensFromCurrentStage(currentStageTokens);
        if (tokensNextStage > 0) {
            // stage is changed in the previous distribute call
            _subtractTokensFromCurrentStage(tokensNextStage);
        }
        claimableTokens[user] += currentStageTokens + tokensNextStage;
        emit TokensBought(user, currentStageTokens + tokensNextStage);
    }

    ///@notice Vest garbage tokens, adding amount for vesting in GarbageVesting contract.
    ///@param amount Amount of ETH or USDT - 18 or 6 decimals
    ///@param isEth True if amount is in ETH, false if amount is in USDT
    ///@param user User address
    function _vestTokens(
        uint256 amount,
        bool isEth,
        address user
    ) internal {
        (uint256 currentStageTokens, uint256 tokensNextStage) = _calculateTokenAmountFromCurrencyAmount(amount, isEth);

        _subtractTokensFromCurrentStage(currentStageTokens);
        if (tokensNextStage > 0) {
            // stage is changed in the previous distribute call
            _subtractTokensFromCurrentStage(tokensNextStage);
        }
        garbageToken.approve(address(vestingContract), currentStageTokens + tokensNextStage);
        vestingContract.addAmountToBeneficiary(user, currentStageTokens + tokensNextStage);
        emit TokensBought(user, currentStageTokens + tokensNextStage);
    }

    ///@notice Calculate rate in currency
    function _getRateInCurrency(uint256 stageId, bool isEth) internal view returns (uint256) {
        Stage storage stage = stages[stageId];
        // price in 18 decimals
        uint256 currentPrice = (isEth ? _getEthPrice() : _getUsdtPrice()) * 1e10;
        uint256 priceInUSDDecimals = 1e8;
        uint256 rateInCurrency = (priceInUSDDecimals * currentPrice) / stage.priceInUSD; // calculate the number of tokens in 1 unit of the selected currency based on its current price (USDT or ETH)
        return rateInCurrency;
    }

    ///@notice Validate and calculate tokens distribution for current stage. When current stage is finished, move to the next.
    function _subtractTokensFromCurrentStage(uint256 tokens) internal {
        Stage storage stage = stages[currentStage];
        if (stage.tokensToSale - stage.tokensSold < tokens) revert NotEnoughTokensInStageToDistribute();
        stage.tokensSold += tokens;
        totalTokensSold += tokens;

        if (stage.tokensSold == stage.tokensToSale) {
            currentStage++;
        }
    }

    /// @notice Calculate reward for referrer
    /// @param referrer Referrer address
    /// @param amount Amount of ETH or USDT - 18 or 6 decimals
    /// @param isEth True if amount is in ETH, false if amount is in USDT
    /// @return reward Reward amount in ETH or USDT - 18 or 6 decimals
    /// @dev Reward is calculated based on the amount of ETH or USDT sent by the user
    /// @dev Blogger referrers receive 10% of the amount sent by the user and user referrers receive 5%
    function _calculateRewardReferral(
        address referrer,
        address user,
        uint256 amount,
        bool isEth
    ) internal returns (uint256 reward) {
        if (referrer == user) revert ReferrerIsSender();
        if (referrer != address(0)) {
            if (!hasRole(REFERRER_ROLE, referrer) && !hasRole(BLOGGER_ROLE, referrer)) revert ReferrerIsNotRegistered();
            bool isBlogger = hasRole(BLOGGER_ROLE, referrer);
            uint256 rewardPercent = isBlogger ? bloggerRewardPercent : userRewardPercent;
            reward = (amount * rewardPercent) / PERCENT_DENOMINATOR;
            if (isEth) {
                referralRewardsEth[referrer] += reward;
                totalRewardsEth += reward;
            } else {
                referralRewardsUsdt[referrer] += reward;
                totalRewardsUsdt += reward;
            }
        }
        emit RewardCalculated(reward, referrer);
        return reward;
    }

    ///@notice Add all stages with tokens and price in USD
    function _addStages() internal {
        _addStage(51_282_051, 1950000);
        _addStage(47_483_381, 2106000);
        _addStage(43_966_093, 2274480);
        _addStage(40_709_346, 2456438);
        _addStage(36_874_407, 2711908);
        _addStage(32_923_578, 3037337);
        _addStage(29_396_052, 3401817);
        _addStage(26_014_205, 3844054);
        _addStage(22_819_478, 4382221);
        _addStage(18_531_329, 5396267);
    }

    ///@notice Add stage with tokens and price in USD
    function _addStage(uint256 tokensToSale, uint256 priceInUSD) internal {
        uint256 tokensToSaleWithDecimals = tokensToSale * 10**18;
        stages.push(Stage(tokensToSaleWithDecimals, 0, priceInUSD));
        totalTokensToBeDistributed += tokensToSaleWithDecimals;
        emit StageAdded(tokensToSale, priceInUSD);
    }

    ///@notice Set new treasury address
    ///@param _treasury New treasury address
    ///@dev Only admin can set new treasury address
    function setTreasury(address _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) nonZeroAddress(_treasury) {
        treasury = _treasury;
        emit TreasuryChanged(_treasury);
    }

    ///@notice Set new garbage token address
    ///@param _token New garbage token address
    ///@dev Only admin can set new garbage token address
    function setGarbageToken(IERC20 _token)
        public
        beforeSaleStart
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonZeroAddress(address(_token))
    {
        garbageToken = _token;
        emit GarbageTokenChanged(address(_token));
    }

    ///@notice Set new USDT address
    ///@param _usdt New USDT address
    ///@dev Only admin can set new USDT address
    function setUsdt(IERC20 _usdt) public onlyRole(DEFAULT_ADMIN_ROLE) nonZeroAddress(address(_usdt)) {
        usdt = _usdt;
        emit UsdtChanged(address(_usdt));
    }

    ///@notice Set new price feed for ETH
    ///@param _priceFeedEth New price feed for ETH
    ///@dev Only admin can set new price feed for ETH
    function setPriceFeedEth(address _priceFeedEth) public onlyRole(DEFAULT_ADMIN_ROLE) nonZeroAddress(_priceFeedEth) {
        priceFeedEth = AggregatorV3Interface(_priceFeedEth);
        emit PriceFeedEthChanged(_priceFeedEth);
    }

    ///@notice Set new price feed for USDT
    ///@param _priceFeedUsdt New price feed for USDT
    ///@dev Only admin can set new price feed for USDT
    function setPriceFeedUsdt(address _priceFeedUsdt)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonZeroAddress(_priceFeedUsdt)
    {
        priceFeedUsdt = AggregatorV3Interface(_priceFeedUsdt);
        emit PriceFeedUsdtChanged(_priceFeedUsdt);
    }

    ///@notice Set new sale start date
    ///@param _saleStartDate New sale start date
    ///@dev Only admin can set new sale start date
    function setSaleStartDate(uint256 _saleStartDate) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_saleStartDate < block.timestamp) {
            revert NewDeadlineIsInPast();
        }
        if (block.timestamp > saleStartDate && saleStartDate > 0) {
            revert SaleIsStarted();
        }
        saleStartDate = _saleStartDate;
    }

    ///@notice Set new claim date
    ///@param _claimDate New claim date
    ///@dev Only admin can set new claim date
    function setClaimDate(uint256 _claimDate) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_claimDate < block.timestamp) {
            revert NewDeadlineIsInPast();
        }
        claimDate = _claimDate;
        emit ClaimDateExtended(_claimDate);
    }

    ///@notice Set new sale deadline
    ///@param newDeadline New sale deadline
    ///@dev Only admin can set new sale deadline
    function setSaleDeadline(uint256 newDeadline) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newDeadline < block.timestamp || newDeadline < saleDeadline) {
            revert NewDeadlineIsInPast();
        }
        saleDeadline = newDeadline;
        emit DeadlineExtended(newDeadline);
    }

    ///@notice Set new max amount of garbage tokens in USD (8 decimals) which can be bought without vesting.
    function setMaxClaimableAmountInUSD(uint256 _maxClaimableAmountInUSD) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxClaimableAmountInUSD = _maxClaimableAmountInUSD;
    }

    ///@notice Set new address of vesting contract.
    function setVestingContract(IGarbageVesting _vestingContract)
        public
        beforeSaleStart
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonZeroAddress(address(_vestingContract))
    {
        vestingContract = _vestingContract;
        emit VestingContractChanged(address(_vestingContract));
    }

    ///@notice Return stages quantity
    function getStagesLength() external view returns (uint256) {
        return stages.length;
    }

    ///@notice Return current stage info
    ///@return tokensToSale Amount of tokens to sale
    ///@return tokensSold Sold tokens amount
    ///@return priceInUSD Price in USD with 8 decimals
    ///@return _currentStage Current stage
    ///@return nextStagePriceInUsd Price in USD with 8 decimals for next stage
    function getCurrentStageInfo()
        external
        view
        returns (
            uint256 tokensToSale,
            uint256 tokensSold,
            uint256 priceInUSD,
            uint256 _currentStage,
            uint256 nextStagePriceInUsd
        )
    {
        uint256 stageId = currentStage;
        nextStagePriceInUsd = stageId == stages.length - 1 ? 0 : stages[stageId + 1].priceInUSD;
        return (
            stages[stageId].tokensToSale,
            stages[stageId].tokensSold,
            stages[stageId].priceInUSD,
            currentStage,
            nextStagePriceInUsd
        );
    }

    ///@notice Return rewards amount in USDT and ETH for specified referrer
    function getRewardsForReferrer(address referrer) external view returns (uint256, uint256) {
        return (referralRewardsEth[referrer], referralRewardsUsdt[referrer]);
    }

    ///@notice Return user's balances in garbage token, USDT and ETH
    function getUserBalances(address user)
        external
        view
        returns (
            uint256 garbageBalance,
            uint256 usdtBalance,
            uint256 ethBalance
        )
    {
        garbageBalance = garbageToken.balanceOf(user);
        usdtBalance = usdt.balanceOf(user);
        ethBalance = address(user).balance;
    }

    ///@notice Calculate and return token amount from provided currency amount
    ///@param amount Amount of ETH or USDT - 18 or 6 decimals
    function getTokenAmountFromCurrencyAmount(uint256 amount, bool isEth) public view returns (uint256 tokens) {
        (uint256 currentStageTokens, uint256 nextStageTokens) = _calculateTokenAmountFromCurrencyAmount(amount, isEth);
        return currentStageTokens + nextStageTokens;
    }

    ///@notice Calculate currency price in USD
    ///@return priceInUSD Price in USD with 8 decimals
    function getCurrencyInUSD(uint256 currencyAmount, bool isEth) public view returns (uint256) {
        uint256 currentPrice = (isEth ? _getEthPrice() : _getUsdtPrice());
        uint256 currencyDecimals = isEth ? 1e18 : 1e6;
        uint256 usdValue = (currencyAmount * currentPrice) / currencyDecimals;
        return usdValue;
    }

    /// @notice Calculate currency amount from provided USD amount
    /// @param usdAmount Amount of USD - 8 decimals
    function getUSDinCurrency(uint256 usdAmount, bool isEth) public view returns (uint256) {
        uint256 currentPrice = (isEth ? _getEthPrice() : _getUsdtPrice());
        uint256 currencyDecimals = isEth ? 1e18 : 1e6;
        uint256 currencyValue = (usdAmount * currencyDecimals) / currentPrice;
        return currencyValue;
    }

    ///@notice Calculate and return token amount from provided currency amount
    ///@param amount Amount of ETH or USDT - 18 or 6 decimals
    ///@param isEth True if amount is in ETH, false if amount is in USDT
    function _calculateTokenAmountFromCurrencyAmount(uint256 amount, bool isEth)
        internal
        view
        returns (uint256 tokensAmount, uint256 tokensAmountNextStage)
    {
        Stage storage stage = stages[currentStage];
        uint256 _currentStage = currentStage;
        uint256 rateInCurrency = _getRateInCurrency(_currentStage, isEth); // calculate the number of tokens in 1 unit of the selected currency based on its current price (USDT or ETH)
        uint256 tokens = (amount * rateInCurrency) / (isEth ? 1e18 : 1e6); // calculate the number of tokens based on the passed amount of currency

        if (stage.tokensToSale - stage.tokensSold >= tokens) {
            return (tokens, 0);
        }

        _currentStage++;
        uint256 remainingTokens = stage.tokensToSale - stage.tokensSold;
        uint256 usedAmount = (remainingTokens * (isEth ? 1e18 : 1e6)) / rateInCurrency;
        uint256 excessAmount = amount - usedAmount;

        if (excessAmount == 0) return (remainingTokens, 0);

        if (_currentStage >= stages.length) {
            uint256 checkGarbageAmount = (excessAmount * rateInCurrency) / (isEth ? 1e18 : 1e6);
            if (checkGarbageAmount <= 1 ether) {
                return (remainingTokens, 0);
            } else {
                revert NotEnoughTokensInLastStage();
            }
        }
        Stage storage nextStage = stages[_currentStage];
        uint256 nextRateInCurrency = _getRateInCurrency(_currentStage, isEth);
        uint256 nextTokens = (excessAmount * nextRateInCurrency) / (isEth ? 1e18 : 1e6);
        if (nextTokens > nextStage.tokensToSale) revert NotEnoughTokensInNextStage();
        return (remainingTokens, nextTokens);
    }

    ///@notice Calculate and return currency amount from provided token amount
    ///@param tokens Amount of garbage tokens
    ///@param isEth True if amount to return is in ETH, false if amount to return is in USDT
    function getCurrencyAmountFromTokenAmount(uint256 tokens, bool isEth) external view returns (uint256 amount) {
        Stage storage stage = stages[currentStage];
        uint256 rateInCurrency = _getRateInCurrency(currentStage, isEth); // calculate the number of tokens in 1 unit of the selected currency based on its current price (USDT or ETH)
        if (stage.tokensToSale - stage.tokensSold >= tokens) {
            amount = (tokens * (isEth ? 1e18 : 1e6)) / rateInCurrency; // calculate the amount of currency based on the passed number of tokens
            return amount;
        }

        uint256 _currentStage = currentStage;
        uint256 remainingTokens = stage.tokensToSale - stage.tokensSold;
        uint256 usedAmount = (remainingTokens * (isEth ? 1e18 : 1e6)) / rateInCurrency;
        uint256 excessTokens = tokens - remainingTokens;

        _currentStage++;

        if (_currentStage >= stages.length) {
            if (excessTokens > 1 ether) {
                revert NotEnoughTokensInLastStage();
            } else {
                amount = (tokens * (isEth ? 1e18 : 1e6)) / rateInCurrency; // calculate the amount of currency based on the passed number of tokens
                return amount;
            }
        }
        // Calculate the amount of currency needed to buy tokens from the next stage
        Stage storage nextStage = stages[_currentStage];
        uint256 nextRateInCurrency = _getRateInCurrency(_currentStage, isEth);
        uint256 nextAmount = (excessTokens * (isEth ? 1e18 : 1e6)) / nextRateInCurrency;

        if (excessTokens > nextStage.tokensToSale) revert NotEnoughTokensInNextStage();

        amount = usedAmount + nextAmount;
    }

    ///@notice Return ETH price from Chainlink
    function _getEthPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeedEth.latestRoundData();
        return uint256(price);
    }

    ///@notice Return USDT price from Chainlink
    function _getUsdtPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeedUsdt.latestRoundData();
        return uint256(price);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGarbageSale {
    function garbageToken() external view returns (IERC20);

    function usdt() external view returns (IERC20);

    function treasury() external view returns (address);

    function currentStage() external view returns (uint256);

    function saleDeadline() external view returns (uint256);

    function claimDate() external view returns (uint256);

    function bloggerRewardPercent() external view returns (uint256);

    function userRewardPercent() external view returns (uint256);

    function totalTokensToBeDistributed() external view returns (uint256);

    function totalTokensSold() external view returns (uint256);

    function totalTokensClaimed() external view returns (uint256);

    function referralRewardsEth(address referrer) external view returns (uint256);

    function referralRewardsUsdt(address referrer) external view returns (uint256);

    function claimableTokens(address claimer) external view returns (uint256);

    function getStagesLength() external view returns (uint256);

    function getCurrentStageInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getCurrencyAmountFromTokenAmount(uint256 tokens, bool isEth) external view returns (uint256 amount);

    function getTokenAmountFromCurrencyAmount(uint256 amount, bool isEth) external view returns (uint256 tokens);

    function buyTokensWithEth(address referrer) external payable;

    function buyTokensWithUsdt(uint256 amount, address referrer) external;

    function setSaleDeadline(uint256 newDeadline) external;

    function claimTokens() external;

    function pause() external;

    function unpause() external;

    function withdrawRemainder(uint256 amount) external;
}
pragma solidity 0.8.18;

interface IGarbageVesting {
    function addAmountToBeneficiary(address _beneficiary, uint256 _amount) external;
}