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
// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
import "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
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
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// TokenizedStrategy interface used for internal view delegateCalls.
import {ITokenizedStrategy} from "./interfaces/ITokenizedStrategy.sol";

/**
 * @title YearnV3 Base Strategy
 * @author yearn.finance
 * @notice
 *  BaseStrategy implements all of the required functionality to
 *  seamlessly integrate with the `TokenizedStrategy` implementation contract
 *  allowing anyone to easily build a fully permissionless ERC-4626 compliant
 *  Vault by inheriting this contract and overriding three simple functions.

 *  It utilizes an immutable proxy pattern that allows the BaseStrategy
 *  to remain simple and small. All standard logic is held within the
 *  `TokenizedStrategy` and is reused over any n strategies all using the
 *  `fallback` function to delegatecall the implementation so that strategists
 *  can only be concerned with writing their strategy specific code.
 *
 *  This contract should be inherited and the three main abstract methods
 *  `_deployFunds`, `_freeFunds` and `_harvestAndReport` implemented to adapt
 *  the Strategy to the particular needs it has to generate yield. There are
 *  other optional methods that can be implemented to further customize
 *  the strategy if desired.
 *
 *  All default storage for the strategy is controlled and updated by the
 *  `TokenizedStrategy`. The implementation holds a storage struct that
 *  contains all needed global variables in a manual storage slot. This
 *  means strategists can feel free to implement their own custom storage
 *  variables as they need with no concern of collisions. All global variables
 *  can be viewed within the Strategy by a simple call using the
 *  `TokenizedStrategy` variable. IE: TokenizedStrategy.globalVariable();.
 */
abstract contract BaseStrategy {
    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Used on TokenizedStrategy callback functions to make sure it is post
     * a delegateCall from this address to the TokenizedStrategy.
     */
    modifier onlySelf() {
        _onlySelf();
        _;
    }

    /**
     * @dev Use to assure that the call is coming from the strategies management.
     */
    modifier onlyManagement() {
        TokenizedStrategy.requireManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the keeper.
     */
    modifier onlyKeepers() {
        TokenizedStrategy.requireKeeperOrManagement(msg.sender);
        _;
    }

    /**
     * @dev Use to assure that the call is coming from either the strategies
     * management or the emergency admin.
     */
    modifier onlyEmergencyAuthorized() {
        TokenizedStrategy.requireEmergencyAuthorized(msg.sender);
        _;
    }

    /**
     * @dev Require that the msg.sender is this address.
     */
    function _onlySelf() internal view {
        require(msg.sender == address(this), "!self");
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This is the address of the TokenizedStrategy implementation
     * contract that will be used by all strategies to handle the
     * accounting, logic, storage etc.
     *
     * Any external calls to the that don't hit one of the functions
     * defined in this base or the strategy will end up being forwarded
     * through the fallback function, which will delegateCall this address.
     *
     * This address should be the same for every strategy, never be adjusted
     * and always be checked before any integration with the Strategy.
     */
    address public constant tokenizedStrategyAddress =
        0xBB51273D6c746910C7C06fe718f30c936170feD0;

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Underlying asset the Strategy is earning yield on.
     * Stored here for cheap retrievals within the strategy.
     */
    ERC20 internal immutable asset;

    /**
     * @dev This variable is set to address(this) during initialization of each strategy.
     *
     * This can be used to retrieve storage data within the strategy
     * contract as if it were a linked library.
     *
     *       i.e. uint256 totalAssets = TokenizedStrategy.totalAssets()
     *
     * Using address(this) will mean any calls using this variable will lead
     * to a call to itself. Which will hit the fallback function and
     * delegateCall that to the actual TokenizedStrategy.
     */
    ITokenizedStrategy internal immutable TokenizedStrategy;

    /**
     * @notice Used to initialize the strategy on deployment.
     *
     * This will set the `TokenizedStrategy` variable for easy
     * internal view calls to the implementation. As well as
     * initializing the default storage variables based on the
     * parameters and using the deployer for the permissioned roles.
     *
     * @param _asset Address of the underlying asset.
     * @param _name Name the strategy will use.
     */
    constructor(address _asset, string memory _name) {
        asset = ERC20(_asset);

        // Set instance of the implementation for internal use.
        TokenizedStrategy = ITokenizedStrategy(address(this));

        // Initialize the strategy's storage variables.
        _delegateCall(
            abi.encodeCall(
                ITokenizedStrategy.initialize,
                (_asset, _name, msg.sender, msg.sender, msg.sender)
            )
        );

        // Store the tokenizedStrategyAddress at the standard implementation
        // address storage slot so etherscan picks up the interface. This gets
        // stored on initialization and never updated.
        assembly {
            sstore(
                // keccak256('eip1967.proxy.implementation' - 1)
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                tokenizedStrategyAddress
            )
        }
    }

    /*//////////////////////////////////////////////////////////////
                NEEDED TO BE OVERRIDDEN BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Can deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can attempt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal virtual;

    /**
     * @dev Should attempt to free the '_amount' of 'asset'.
     *
     * NOTE: The amount of 'asset' that is already loose has already
     * been accounted for.
     *
     * This function is called during {withdraw} and {redeem} calls.
     * Meaning that unless a whitelist is implemented it will be
     * entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * Should not rely on asset.balanceOf(address(this)) calls other than
     * for diff accounting purposes.
     *
     * Any difference between `_amount` and what is actually freed will be
     * counted as a loss and passed on to the withdrawer. This means
     * care should be taken in times of illiquidity. It may be better to revert
     * if withdraws are simply illiquid so not to realize incorrect losses.
     *
     * @param _amount, The amount of 'asset' to be freed.
     */
    function _freeFunds(uint256 _amount) internal virtual;

    /**
     * @dev Internal function to harvest all rewards, redeploy any idle
     * funds and return an accurate accounting of all funds currently
     * held by the Strategy.
     *
     * This should do any needed harvesting, rewards selling, accrual,
     * redepositing etc. to get the most accurate view of current assets.
     *
     * NOTE: All applicable assets including loose assets should be
     * accounted for in this function.
     *
     * Care should be taken when relying on oracles or swap values rather
     * than actual amounts as all Strategy profit/loss accounting will
     * be done based on this returned value.
     *
     * This can still be called post a shutdown, a strategist can check
     * `TokenizedStrategy.isShutdown()` to decide if funds should be
     * redeployed or simply realize any profits/losses.
     *
     * @return _totalAssets A trusted and accurate account for the total
     * amount of 'asset' the strategy currently holds including idle funds.
     */
    function _harvestAndReport()
        internal
        virtual
        returns (uint256 _totalAssets);

    /*//////////////////////////////////////////////////////////////
                    OPTIONAL TO OVERRIDE BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Optional function for strategist to override that can
     *  be called in between reports.
     *
     * If '_tend' is used tendTrigger() will also need to be overridden.
     *
     * This call can only be called by a permissioned role so may be
     * through protected relays.
     *
     * This can be used to harvest and compound rewards, deposit idle funds,
     * perform needed position maintenance or anything else that doesn't need
     * a full report for.
     *
     *   EX: A strategy that can not deposit funds without getting
     *       sandwiched can use the tend when a certain threshold
     *       of idle to totalAssets has been reached.
     *
     * This will have no effect on PPS of the strategy till report() is called.
     *
     * @param _totalIdle The current amount of idle funds that are available to deploy.
     */
    function _tend(uint256 _totalIdle) internal virtual {}

    /**
     * @dev Optional trigger to override if tend() will be used by the strategy.
     * This must be implemented if the strategy hopes to invoke _tend().
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     */
    function _tendTrigger() internal view virtual returns (bool) {
        return false;
    }

    /**
     * @notice Returns if tend() should be called by a keeper.
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     * @return . Calldata for the tend call.
     */
    function tendTrigger() external view virtual returns (bool, bytes memory) {
        return (
            // Return the status of the tend trigger.
            _tendTrigger(),
            // And the needed calldata either way.
            abi.encodeWithSelector(ITokenizedStrategy.tend.selector)
        );
    }

    /**
     * @notice Gets the max amount of `asset` that an address can deposit.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any deposit or mints to enforce
     * any limits desired by the strategist. This can be used for either a
     * traditional deposit limit or for implementing a whitelist etc.
     *
     *   EX:
     *      if(isAllowed[_owner]) return super.availableDepositLimit(_owner);
     *
     * This does not need to take into account any conversion rates
     * from shares to assets. But should know that any non max uint256
     * amounts may be converted to shares. So it is recommended to keep
     * custom amounts low enough as not to cause overflow when multiplied
     * by `totalSupply`.
     *
     * @param . The address that is depositing into the strategy.
     * @return . The available amount the `_owner` can deposit in terms of `asset`
     */
    function availableDepositLimit(
        address /*_owner*/
    ) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @notice Gets the max amount of `asset` that can be withdrawn.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any withdraw or redeem to enforce
     * any limits desired by the strategist. This can be used for illiquid
     * or sandwichable strategies. It should never be lower than `totalIdle`.
     *
     *   EX:
     *       return TokenIzedStrategy.totalIdle();
     *
     * This does not need to take into account the `_owner`'s share balance
     * or conversion rates from shares to assets.
     *
     * @param . The address that is withdrawing from the strategy.
     * @return . The available amount that can be withdrawn in terms of `asset`
     */
    function availableWithdrawLimit(
        address /*_owner*/
    ) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Optional function for a strategist to override that will
     * allow management to manually withdraw deployed funds from the
     * yield source if a strategy is shutdown.
     *
     * This should attempt to free `_amount`, noting that `_amount` may
     * be more than is currently deployed.
     *
     * NOTE: This will not realize any profits or losses. A separate
     * {report} will be needed in order to record any profit/loss. If
     * a report may need to be called after a shutdown it is important
     * to check if the strategy is shutdown during {_harvestAndReport}
     * so that it does not simply re-deploy all funds that had been freed.
     *
     * EX:
     *   if(freeAsset > 0 && !TokenizedStrategy.isShutdown()) {
     *       depositFunds...
     *    }
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function _emergencyWithdraw(uint256 _amount) internal virtual {}

    /*//////////////////////////////////////////////////////////////
                        TokenizedStrategy HOOKS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Can deploy up to '_amount' of 'asset' in yield source.
     * @dev Callback for the TokenizedStrategy to call during a {deposit}
     * or {mint} to tell the strategy it can deploy funds.
     *
     * Since this can only be called after a {deposit} or {mint}
     * delegateCall to the TokenizedStrategy msg.sender == address(this).
     *
     * Unless a whitelist is implemented this will be entirely permissionless
     * and thus can be sandwiched or otherwise manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can
     * attempt to deposit in the yield source.
     */
    function deployFunds(uint256 _amount) external virtual onlySelf {
        _deployFunds(_amount);
    }

    /**
     * @notice Should attempt to free the '_amount' of 'asset'.
     * @dev Callback for the TokenizedStrategy to call during a withdraw
     * or redeem to free the needed funds to service the withdraw.
     *
     * This can only be called after a 'withdraw' or 'redeem' delegateCall
     * to the TokenizedStrategy so msg.sender == address(this).
     *
     * @param _amount The amount of 'asset' that the strategy should attempt to free up.
     */
    function freeFunds(uint256 _amount) external virtual onlySelf {
        _freeFunds(_amount);
    }

    /**
     * @notice Returns the accurate amount of all funds currently
     * held by the Strategy.
     * @dev Callback for the TokenizedStrategy to call during a report to
     * get an accurate accounting of assets the strategy controls.
     *
     * This can only be called after a report() delegateCall to the
     * TokenizedStrategy so msg.sender == address(this).
     *
     * @return . A trusted and accurate account for the total amount
     * of 'asset' the strategy currently holds including idle funds.
     */
    function harvestAndReport() external virtual onlySelf returns (uint256) {
        return _harvestAndReport();
    }

    /**
     * @notice Will call the internal '_tend' when a keeper tends the strategy.
     * @dev Callback for the TokenizedStrategy to initiate a _tend call in the strategy.
     *
     * This can only be called after a tend() delegateCall to the TokenizedStrategy
     * so msg.sender == address(this).
     *
     * We name the function `tendThis` so that `tend` calls are forwarded to
     * the TokenizedStrategy.

     * @param _totalIdle The amount of current idle funds that can be
     * deployed during the tend
     */
    function tendThis(uint256 _totalIdle) external virtual onlySelf {
        _tend(_totalIdle);
    }

    /**
     * @notice Will call the internal '_emergencyWithdraw' function.
     * @dev Callback for the TokenizedStrategy during an emergency withdraw.
     *
     * This can only be called after a emergencyWithdraw() delegateCall to
     * the TokenizedStrategy so msg.sender == address(this).
     *
     * We name the function `shutdownWithdraw` so that `emergencyWithdraw`
     * calls are forwarded to the TokenizedStrategy.
     *
     * @param _amount The amount of asset to attempt to free.
     */
    function shutdownWithdraw(uint256 _amount) external virtual onlySelf {
        _emergencyWithdraw(_amount);
    }

    /**
     * @dev Function used to delegate call the TokenizedStrategy with
     * certain `_calldata` and return any return values.
     *
     * This is used to setup the initial storage of the strategy, and
     * can be used by strategist to forward any other call to the
     * TokenizedStrategy implementation.
     *
     * @param _calldata The abi encoded calldata to use in delegatecall.
     * @return . The return value if the call was successful in bytes.
     */
    function _delegateCall(
        bytes memory _calldata
    ) internal returns (bytes memory) {
        // Delegate call the tokenized strategy with provided calldata.
        (bool success, bytes memory result) = tokenizedStrategyAddress
            .delegatecall(_calldata);

        // If the call reverted. Return the error.
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        // Return the result.
        return result;
    }

    /**
     * @dev Execute a function on the TokenizedStrategy and return any value.
     *
     * This fallback function will be executed when any of the standard functions
     * defined in the TokenizedStrategy are called since they wont be defined in
     * this contract.
     *
     * It will delegatecall the TokenizedStrategy implementation with the exact
     * calldata and return any relevant values.
     *
     */
    fallback() external {
        // load our target address
        address _tokenizedStrategyAddress = tokenizedStrategyAddress;
        // Execute external function using delegatecall and return any value.
        assembly {
            // Copy function selector and any arguments.
            calldatacopy(0, 0, calldatasize())
            // Execute function delegatecall.
            let result := delegatecall(
                gas(),
                _tokenizedStrategyAddress,
                0,
                calldatasize(),
                0,
                0
            )
            // Get any return value
            returndatacopy(0, 0, returndatasize())
            // Return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

// Interface that implements the 4626 standard and the implementation functions
interface ITokenizedStrategy is IERC4626, IERC20Permit {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event StrategyShutdown();

    event NewTokenizedStrategy(
        address indexed strategy,
        address indexed asset,
        string apiVersion
    );

    event Reported(
        uint256 profit,
        uint256 loss,
        uint256 protocolFees,
        uint256 performanceFees
    );

    event UpdatePerformanceFeeRecipient(
        address indexed newPerformanceFeeRecipient
    );

    event UpdateKeeper(address indexed newKeeper);

    event UpdatePerformanceFee(uint16 newPerformanceFee);

    event UpdateManagement(address indexed newManagement);

    event UpdateEmergencyAdmin(address indexed newEmergencyAdmin);

    event UpdateProfitMaxUnlockTime(uint256 newProfitMaxUnlockTime);

    event UpdatePendingManagement(address indexed newPendingManagement);

    /*//////////////////////////////////////////////////////////////
                           INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    function initialize(
        address _asset,
        string memory _name,
        address _management,
        address _performanceFeeRecipient,
        address _keeper
    ) external;

    /*//////////////////////////////////////////////////////////////
                    NON-STANDARD 4626 OPTIONS
    //////////////////////////////////////////////////////////////*/

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 maxLoss
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 maxLoss
    ) external returns (uint256);

    /*//////////////////////////////////////////////////////////////
                        MODIFIER HELPERS
    //////////////////////////////////////////////////////////////*/

    function requireManagement(address _sender) external view;

    function requireKeeperOrManagement(address _sender) external view;

    function requireEmergencyAuthorized(address _sender) external view;

    /*//////////////////////////////////////////////////////////////
                        KEEPERS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tend() external;

    function report() external returns (uint256 _profit, uint256 _loss);

    /*//////////////////////////////////////////////////////////////
                        CONSTANTS
    //////////////////////////////////////////////////////////////*/

    function MAX_FEE() external view returns (uint16);

    function FACTORY() external view returns (address);

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function apiVersion() external view returns (string memory);

    function pricePerShare() external view returns (uint256);

    function management() external view returns (address);

    function pendingManagement() external view returns (address);

    function keeper() external view returns (address);

    function emergencyAdmin() external view returns (address);

    function performanceFee() external view returns (uint16);

    function performanceFeeRecipient() external view returns (address);

    function fullProfitUnlockDate() external view returns (uint256);

    function profitUnlockingRate() external view returns (uint256);

    function profitMaxUnlockTime() external view returns (uint256);

    function lastReport() external view returns (uint256);

    function isShutdown() external view returns (bool);

    function unlockedShares() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    function setPendingManagement(address) external;

    function acceptManagement() external;

    function setKeeper(address _keeper) external;

    function setEmergencyAdmin(address _emergencyAdmin) external;

    function setPerformanceFee(uint16 _performanceFee) external;

    function setPerformanceFeeRecipient(
        address _performanceFeeRecipient
    ) external;

    function setProfitMaxUnlockTime(uint256 _profitMaxUnlockTime) external;

    function shutdownStrategy() external;

    function emergencyWithdraw(uint256 _amount) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {ITermController} from "./interfaces/term/ITermController.sol";
import {ITermRepoToken} from "./interfaces/term/ITermRepoToken.sol";
import {ITermRepoServicer} from "./interfaces/term/ITermRepoServicer.sol";
import {ITermRepoCollateralManager} from "./interfaces/term/ITermRepoCollateralManager.sol";
import {ITermDiscountRateAdapter} from "./interfaces/term/ITermDiscountRateAdapter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RepoTokenUtils} from "./RepoTokenUtils.sol";

struct RepoTokenListNode {
    address next;
}

struct RepoTokenListData {
    address head;
    mapping(address => RepoTokenListNode) nodes;
    mapping(address => uint256) discountRates;
    /// @notice keyed by collateral token
    mapping(address => uint256) collateralTokenParams;
}

/*//////////////////////////////////////////////////////////////
                        LIBRARY: RepoTokenList
//////////////////////////////////////////////////////////////*/

library RepoTokenList {
    address internal constant NULL_NODE = address(0);
    uint256 internal constant INVALID_AUCTION_RATE = 0;
    uint256 internal constant ZERO_AUCTION_RATE = 1; //Set to lowest nonzero number so that it is not confused with INVALID_AUCTION_RATe but still calculates as if 0.

    error InvalidRepoToken(address token);

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Retrieves the redemption (maturity) timestamp of a repoToken
     * @param repoToken The address of the repoToken
     * @return redemptionTimestamp The timestamp indicating when the repoToken matures
     *
     * @dev This function calls the `config()` method on the repoToken to retrieve its configuration details,
     * including the redemption timestamp, which it then returns.
     */
    function getRepoTokenMaturity(
        address repoToken
    ) internal view returns (uint256 redemptionTimestamp) {
        (redemptionTimestamp, , , ) = ITermRepoToken(repoToken).config();
    }

    /**
     * @notice Get the next node in the list
     * @param listData The list data
     * @param current The current node
     * @return The next node
     */
    function _getNext(
        RepoTokenListData storage listData,
        address current
    ) private view returns (address) {
        return listData.nodes[current].next;
    }

    /**
     * @notice Count the number of nodes in the list
     * @param listData The list data
     * @return count The number of nodes in the list
     */
    function _count(
        RepoTokenListData storage listData
    ) private view returns (uint256 count) {
        if (listData.head == NULL_NODE) return 0;
        address current = listData.head;
        while (current != NULL_NODE) {
            count++;
            current = _getNext(listData, current);
        }
    }

    /**
     * @notice Returns an array of addresses representing the repoTokens currently held in the list data
     * @param listData The list data
     * @return holdingsArray An array of addresses of the repoTokens held in the list
     *
     * @dev This function iterates through the list of repoTokens and returns their addresses in an array.
     * It first counts the number of repoTokens, initializes an array of that size, and then populates the array
     * with the addresses of the repoTokens.
     */
    function holdings(
        RepoTokenListData storage listData
    ) internal view returns (address[] memory holdingsArray) {
        uint256 count = _count(listData);
        if (count > 0) {
            holdingsArray = new address[](count);
            uint256 i;
            address current = listData.head;
            while (current != NULL_NODE) {
                holdingsArray[i++] = current;
                current = _getNext(listData, current);
            }
        }
    }

    /**
     * @notice Get the weighted time to maturity of the strategy's holdings of a specified repoToken
     * @param repoToken The address of the repoToken
     * @param repoTokenBalanceInBaseAssetPrecision The balance of the repoToken in base asset precision
     * @return weightedTimeToMaturity The weighted time to maturity in seconds x repoToken balance in base asset precision
     */
    function getRepoTokenWeightedTimeToMaturity(
        address repoToken,
        uint256 repoTokenBalanceInBaseAssetPrecision
    ) internal view returns (uint256 weightedTimeToMaturity) {
        uint256 currentMaturity = getRepoTokenMaturity(repoToken);

        if (currentMaturity > block.timestamp) {
            uint256 timeToMaturity = _getRepoTokenTimeToMaturity(
                currentMaturity
            );
            // Not matured yet
            weightedTimeToMaturity =
                timeToMaturity *
                repoTokenBalanceInBaseAssetPrecision;
        }
    }

    /**
     * @notice This function calculates the cumulative weighted time to maturity and cumulative amount of all repoTokens in the list.
     * @param listData The list data
     * @param discountRateAdapter The discount rate adapter
     * @param repoToken The address of the repoToken (optional)
     * @param repoTokenAmount The amount of the repoToken (optional)
     * @param purchaseTokenPrecision The precision of the purchase token
     * @return cumulativeWeightedTimeToMaturity The cumulative weighted time to maturity for all repoTokens
     * @return cumulativeRepoTokenAmount The cumulative repoToken amount across all repoTokens
     * @return found Whether the specified repoToken was found in the list
     *
     * @dev The `repoToken` and `repoTokenAmount` parameters are optional and provide flexibility
     * to adjust the calculations to include the provided repoToken and amount. If `repoToken` is
     * set to `address(0)` or `repoTokenAmount` is `0`, the function calculates the cumulative
     * data without specific token adjustments.
     */
    function getCumulativeRepoTokenData(
        RepoTokenListData storage listData,
        ITermDiscountRateAdapter discountRateAdapter,
        address repoToken,
        uint256 repoTokenAmount,
        uint256 purchaseTokenPrecision
    )
        internal
        view
        returns (
            uint256 cumulativeWeightedTimeToMaturity,
            uint256 cumulativeRepoTokenAmount,
            bool found
        )
    {
        // Return early if the list is empty
        if (listData.head == NULL_NODE) return (0, 0, false);

        // Initialize the current pointer to the head of the list
        address current = listData.head;
        while (current != NULL_NODE) {
            uint256 repoTokenBalance = ITermRepoToken(current).balanceOf(
                address(this)
            );

            // Process if the repo token has a positive balance
            if (repoTokenBalance > 0) {
                // Add repoTokenAmount if the current token matches the specified repoToken
                if (repoToken == current) {
                    repoTokenBalance += repoTokenAmount;
                    found = true;
                }

                // Convert the repo token balance to base asset precision
                uint256 repoTokenBalanceInBaseAssetPrecision = RepoTokenUtils
                    .getNormalizedRepoTokenAmount(
                        current,
                        repoTokenBalance,
                        purchaseTokenPrecision,
                        discountRateAdapter.repoRedemptionHaircut(current)
                    );

                // Calculate the weighted time to maturity
                uint256 weightedTimeToMaturity = getRepoTokenWeightedTimeToMaturity(
                        current,
                        repoTokenBalanceInBaseAssetPrecision
                    );

                // Accumulate the results
                cumulativeWeightedTimeToMaturity += weightedTimeToMaturity;
                cumulativeRepoTokenAmount += repoTokenBalanceInBaseAssetPrecision;
            }

            // Move to the next repo token in the list
            current = _getNext(listData, current);
        }
    }

    /**
     * @notice Get the present value of repoTokens
     * @param listData The list data
     * @param discountRateAdapter The discount rate adapter
     * @param purchaseTokenPrecision The precision of the purchase token
     * @return totalPresentValue The total present value of the repoTokens
     * @dev  Aggregates the present value of all repoTokens in the list.
     */
    function getPresentValue(
        RepoTokenListData storage listData,
        ITermDiscountRateAdapter discountRateAdapter,
        uint256 purchaseTokenPrecision
    ) internal view returns (uint256 totalPresentValue) {
        // If the list is empty, return 0
        if (listData.head == NULL_NODE) return 0;

        address current = listData.head;
        while (current != NULL_NODE) {
            uint256 currentMaturity = getRepoTokenMaturity(current);
            uint256 repoTokenBalance = ITermRepoToken(current).balanceOf(
                address(this)
            );
            uint256 discountRate = discountRateAdapter.getDiscountRate(current);

            // Convert repo token balance to base asset precision
            // (ratePrecision * repoPrecision * purchasePrecision) / (repoPrecision * ratePrecision) = purchasePrecision
            uint256 repoTokenBalanceInBaseAssetPrecision = RepoTokenUtils
                .getNormalizedRepoTokenAmount(
                    current,
                    repoTokenBalance,
                    purchaseTokenPrecision,
                    discountRateAdapter.repoRedemptionHaircut(current)
                );

            // Calculate present value based on maturity
            if (currentMaturity > block.timestamp) {
                totalPresentValue += RepoTokenUtils.calculatePresentValue(
                    repoTokenBalanceInBaseAssetPrecision,
                    purchaseTokenPrecision,
                    currentMaturity,
                    discountRate
                );
            } else {
                totalPresentValue += repoTokenBalanceInBaseAssetPrecision;
            }

            // Move to the next token in the list
            current = _getNext(listData, current);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Calculates the time remaining until a repoToken matures
     * @param redemptionTimestamp The redemption timestamp of the repoToken
     * @return uint256 The time remaining (in seconds) until the repoToken matures
     *
     * @dev This function calculates the difference between the redemption timestamp and the current block timestamp
     * to determine how many seconds are left until the repoToken reaches its maturity.
     */
    function _getRepoTokenTimeToMaturity(
        uint256 redemptionTimestamp
    ) private view returns (uint256) {
        return redemptionTimestamp - block.timestamp;
    }

    /**
     * @notice Removes and redeems matured repoTokens from the list data
     * @param listData The list data
     *
     * @dev Iterates through the list of repoTokens and removes those that have matured. If a matured repoToken has a balance,
     * the function attempts to redeem it. This helps maintain the list by clearing out matured repoTokens and redeeming their balances.
     */
    function removeAndRedeemMaturedTokens(
        RepoTokenListData storage listData
    ) internal {
        if (listData.head == NULL_NODE) return;

        address current = listData.head;
        address prev = current;
        while (current != NULL_NODE) {
            address next;
            if (getRepoTokenMaturity(current) <= block.timestamp) {
                bool removeMaturedToken;
                uint256 repoTokenBalance = ITermRepoToken(current).balanceOf(
                    address(this)
                );

                if (repoTokenBalance > 0) {
                    (, , address termRepoServicer, ) = ITermRepoToken(current)
                        .config();
                    try
                        ITermRepoServicer(termRepoServicer)
                            .redeemTermRepoTokens(
                                address(this),
                                repoTokenBalance
                            )
                    {
                        removeMaturedToken = true;
                    } catch {
                        // redemption failed, do not remove token from the list
                    }
                } else {
                    // already redeemed
                    removeMaturedToken = true;
                }

                next = _getNext(listData, current);

                if (removeMaturedToken) {
                    if (current == listData.head) {
                        listData.head = next;
                    }

                    listData.nodes[prev].next = next;
                    delete listData.nodes[current];
                    delete listData.discountRates[current];
                }
            } else {
                /// @dev early exit because list is sorted
                break;
            }

            prev = current;
            current = next;
        }
    }

    /**
     * @notice Validates a repoToken against specific criteria
     * @param listData The list data
     * @param repoToken The repoToken to validate
     * @param asset The address of the base asset
     * @return isRepoTokenValid Whether the repoToken is valid
     * @return redemptionTimestamp The redemption timestamp of the validated repoToken
     *
     * @dev Ensures the repoToken is deployed, matches the purchase token, is not matured, and meets collateral requirements.
     * Reverts with `InvalidRepoToken` if any validation check fails.
     */
    function validateRepoToken(
        RepoTokenListData storage listData,
        ITermRepoToken repoToken,
        address asset
    )
        internal
        view
        returns (bool isRepoTokenValid, uint256 redemptionTimestamp)
    {
        // Retrieve repo token configuration
        address purchaseToken;
        address collateralManager;
        (redemptionTimestamp, purchaseToken, , collateralManager) = repoToken
            .config();

        // Validate purchase token
        if (purchaseToken != asset) {
            return (false, redemptionTimestamp);
        }

        // Check if repo token has matured
        if (redemptionTimestamp < block.timestamp) {
            return (false, redemptionTimestamp);
        }

        // Validate collateral token ratios
        uint256 numTokens = ITermRepoCollateralManager(collateralManager)
            .numOfAcceptedCollateralTokens();
        for (uint256 i; i < numTokens; i++) {
            address currentToken = ITermRepoCollateralManager(collateralManager)
                .collateralTokens(i);
            uint256 minCollateralRatio = listData.collateralTokenParams[
                currentToken
            ];

            if (minCollateralRatio == 0) {
                return (false, redemptionTimestamp);
            } else if (
                ITermRepoCollateralManager(collateralManager)
                    .maintenanceCollateralRatios(currentToken) <
                minCollateralRatio
            ) {
                return (false, redemptionTimestamp);
            }
        }
        return (true, redemptionTimestamp);
    }

    /**
     * @notice Validate and insert a repoToken into the list data
     * @param listData The list data
     * @param repoToken The repoToken to validate and insert
     * @param discountRateAdapter The discount rate adapter
     * @param asset The address of the base asset
     * @return validRepoToken Whether the repoToken is valid
     * @return redemptionTimestamp The redemption timestamp of the validated repoToken
     */
    function validateAndInsertRepoToken(
        RepoTokenListData storage listData,
        ITermRepoToken repoToken,
        ITermDiscountRateAdapter discountRateAdapter,
        address asset
    ) internal returns (bool validRepoToken, uint256 redemptionTimestamp) {
        uint256 discountRate = listData.discountRates[address(repoToken)];
        if (discountRate != INVALID_AUCTION_RATE) {
            (redemptionTimestamp, , , ) = repoToken.config();

            // skip matured repoTokens
            if (redemptionTimestamp < block.timestamp) {
                return (false, redemptionTimestamp); //revert InvalidRepoToken(address(repoToken));
            }

            uint256 oracleRate;
            try
                discountRateAdapter.getDiscountRate(address(repoToken))
            returns (uint256 rate) {
                oracleRate = rate;
            } catch {}

            if (oracleRate != 0) {
                if (discountRate != oracleRate) {
                    listData.discountRates[address(repoToken)] = oracleRate;
                }
            }
        } else {
            try
                discountRateAdapter.getDiscountRate(address(repoToken))
            returns (uint256 rate) {
                discountRate = rate == 0 ? ZERO_AUCTION_RATE : rate;
            } catch {
                discountRate = INVALID_AUCTION_RATE;
                return (false, redemptionTimestamp);
            }

            bool isRepoTokenValid;

            (isRepoTokenValid, redemptionTimestamp) = validateRepoToken(
                listData,
                repoToken,
                asset
            );
            if (!isRepoTokenValid) {
                return (false, redemptionTimestamp);
            }
            insertSorted(listData, address(repoToken));
            listData.discountRates[address(repoToken)] = discountRate;
        }

        return (true, redemptionTimestamp);
    }

    /**
     * @notice Insert a repoToken into the list in a sorted manner
     * @param listData The list data
     * @param repoToken The address of the repoToken to be inserted
     *
     * @dev Inserts the `repoToken` into the `listData` while maintaining the list sorted by the repoTokens' maturity timestamps.
     * The function iterates through the list to find the correct position for the new `repoToken` and updates the pointers accordingly.
     */
    function insertSorted(
        RepoTokenListData storage listData,
        address repoToken
    ) internal {
        // Start at the head of the list
        address current = listData.head;

        // If the list is empty, set the new repoToken as the head
        if (current == NULL_NODE) {
            listData.head = repoToken;
            listData.nodes[repoToken].next = NULL_NODE;
            return;
        }

        uint256 maturityToInsert = getRepoTokenMaturity(repoToken);

        address prev;
        while (current != NULL_NODE) {
            // If the repoToken is already in the list, exit
            if (current == repoToken) {
                break;
            }

            uint256 currentMaturity = getRepoTokenMaturity(current);

            // Insert repoToken before current if its maturity is less than current maturity
            if (maturityToInsert < currentMaturity) {
                if (prev == NULL_NODE) {
                    listData.head = repoToken;
                } else {
                    listData.nodes[prev].next = repoToken;
                }
                listData.nodes[repoToken].next = current;
                break;
            }

            // Move to the next node
            address next = _getNext(listData, current);

            // If at the end of the list, insert repoToken after current
            if (next == NULL_NODE) {
                listData.nodes[current].next = repoToken;
                listData.nodes[repoToken].next = NULL_NODE;
                break;
            }

            prev = current;
            current = next;
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ITermRepoToken} from "./interfaces/term/ITermRepoToken.sol";

/*//////////////////////////////////////////////////////////////
                        LIBRARY: RepoTokenUtils
//////////////////////////////////////////////////////////////*/

library RepoTokenUtils {
    uint256 internal constant THREESIXTY_DAYCOUNT_SECONDS = 360 days;
    uint256 internal constant RATE_PRECISION = 1e18;

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Calculate the present value of a repoToken
     * @param repoTokenAmountInBaseAssetPrecision The amount of repoToken in base asset precision
     * @param purchaseTokenPrecision The precision of the purchase token
     * @param redemptionTimestamp The redemption timestamp of the repoToken
     * @param discountRate The auction rate
     * @return presentValue The present value of the repoToken
     */
    function calculatePresentValue(
        uint256 repoTokenAmountInBaseAssetPrecision,
        uint256 purchaseTokenPrecision,
        uint256 redemptionTimestamp,
        uint256 discountRate
    ) internal view returns (uint256 presentValue) {
        uint256 timeLeftToMaturityDayFraction = block.timestamp >
            redemptionTimestamp
            ? 0
            : ((redemptionTimestamp - block.timestamp) *
                purchaseTokenPrecision) / THREESIXTY_DAYCOUNT_SECONDS;

        // repoTokenAmountInBaseAssetPrecision / (1 + r * days / 360)
        presentValue =
            (repoTokenAmountInBaseAssetPrecision * purchaseTokenPrecision) /
            (purchaseTokenPrecision +
                ((discountRate * timeLeftToMaturityDayFraction) /
                    RATE_PRECISION));

        return
            presentValue > repoTokenAmountInBaseAssetPrecision
                ? repoTokenAmountInBaseAssetPrecision
                : presentValue;
    }

    /**
     * @notice Get the normalized amount of a repoToken in base asset precision
     * @param repoToken The address of the repoToken
     * @param repoTokenAmount The amount of the repoToken
     * @param purchaseTokenPrecision The precision of the purchase token
     * @param repoRedemptionHaircut The haircut to be applied to the repoToken for bad debt
     * @return repoTokenAmountInBaseAssetPrecision The normalized amount of the repoToken in base asset precision
     */
    function getNormalizedRepoTokenAmount(
        address repoToken,
        uint256 repoTokenAmount,
        uint256 purchaseTokenPrecision,
        uint256 repoRedemptionHaircut
    ) internal view returns (uint256 repoTokenAmountInBaseAssetPrecision) {
        uint256 repoTokenPrecision = 10 ** ERC20(repoToken).decimals();
        uint256 redemptionValue = ITermRepoToken(repoToken).redemptionValue();
        repoTokenAmountInBaseAssetPrecision = repoRedemptionHaircut != 0
            ? (redemptionValue *
                repoRedemptionHaircut *
                repoTokenAmount *
                purchaseTokenPrecision) /
                (repoTokenPrecision * RATE_PRECISION * 1e18)
            : (redemptionValue * repoTokenAmount * purchaseTokenPrecision) /
                (repoTokenPrecision * RATE_PRECISION);
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {BaseStrategy, ERC20} from "@tokenized-strategy/BaseStrategy.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ITermRepoToken} from "./interfaces/term/ITermRepoToken.sol";
import {ITermRepoServicer} from "./interfaces/term/ITermRepoServicer.sol";
import {ITermController} from "./interfaces/term/ITermController.sol";
import {ITermVaultEvents} from "./interfaces/term/ITermVaultEvents.sol";
import {ITermAuctionOfferLocker} from "./interfaces/term/ITermAuctionOfferLocker.sol";
import {ITermDiscountRateAdapter} from "./interfaces/term/ITermDiscountRateAdapter.sol";
import {ITermAuction} from "./interfaces/term/ITermAuction.sol";
import {RepoTokenList, RepoTokenListData} from "./RepoTokenList.sol";
import {TermAuctionList, TermAuctionListData, PendingOffer} from "./TermAuctionList.sol";
import {RepoTokenUtils} from "./RepoTokenUtils.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// Import interfaces for many popular DeFi projects, or add your own!
//import "../interfaces/<protocol>/<Interface>.sol";

/**
 * The `TokenizedStrategy` variable can be used to retrieve the strategies
 * specific storage data your contract.
 *
 *       i.e. uint256 totalAssets = TokenizedStrategy.totalAssets()
 *
 * This can not be used for write functions. Any TokenizedStrategy
 * variables that need to be updated post deployment will need to
 * come from an external call from the strategies specific `management`.
 */

// NOTE: To implement permissioned functions you can use the onlyManagement, onlyEmergencyAuthorized and onlyKeepers modifiers

contract Strategy is BaseStrategy, Pausable, AccessControl {
    using SafeERC20 for IERC20;
    using RepoTokenList for RepoTokenListData;
    using TermAuctionList for TermAuctionListData;

    /**
     * @notice Constructor to initialize the Strategy contract
     * @param _asset The address of the asset
     * @param _yearnVault The address of the Yearn vault
     * @param _discountRateAdapter The address of the discount rate adapter
     * @param _eventEmitter The address of the event emitter
     * @param _governorAddress The address of the governor
     * @param _termController The address of the term controller
     * @param _repoTokenConcentrationLimit The concentration limit for repoTokens
     * @param _timeToMaturityThreshold The time to maturity threshold
     * @param _requiredReserveRatio The required reserve ratio
     * @param _discountRateMarkup The discount rate markup
     */
    struct StrategyParams {
        address _asset;
        address _yearnVault;
        address _discountRateAdapter;
        address _eventEmitter;
        address _governorAddress;
        address _termController;
        uint256 _repoTokenConcentrationLimit;
        uint256 _timeToMaturityThreshold;
        uint256 _requiredReserveRatio;
        uint256 _discountRateMarkup;
    }

    struct StrategyState {
        address assetVault;
        address eventEmitter;
        address governorAddress;
        ITermController prevTermController;
        ITermController currTermController;
        ITermDiscountRateAdapter discountRateAdapter;
        uint256 timeToMaturityThreshold;
        uint256 requiredReserveRatio;
        uint256 discountRateMarkup;
        uint256 repoTokenConcentrationLimit;
    }

    // Custom errors
    error InvalidTermAuction(address auction);
    error TimeToMaturityAboveThreshold();
    error BalanceBelowRequiredReserveRatio();
    error InsufficientLiquidBalance(uint256 have, uint256 want);
    error RepoTokenConcentrationTooHigh(address repoToken);
    error RepoTokenBlacklisted(address repoToken);
    error DepositPaused();
    error AuctionNotOpen();
    error ZeroPurchaseTokenAmount();
    error OfferNotFound();

    bytes32 internal constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    // Immutable state variables
    ITermVaultEvents internal immutable TERM_VAULT_EVENT_EMITTER;
    uint256 internal immutable PURCHASE_TOKEN_PRECISION;
    IERC4626 internal immutable YEARN_VAULT;

    /// @notice State variables
    bool internal depositLock;
    address internal pendingGovernor;

    RepoTokenListData internal repoTokenListData;
    TermAuctionListData internal termAuctionListData;
    string internal tokenSymbol;

    StrategyState public strategyState;
    mapping(address => bool) public repoTokenBlacklist;

    modifier notBlacklisted(address repoToken) {
        if (repoTokenBlacklist[repoToken]) {
            revert RepoTokenBlacklisted(repoToken);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                    MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Pause the contract
     */
    function pauseDeposit() external onlyRole(GOVERNOR_ROLE) {
        depositLock = true;
        TERM_VAULT_EVENT_EMITTER.emitDepositPaused();
    }

    /**
     * @notice Unpause the contract
     */
    function unpauseDeposit() external onlyRole(GOVERNOR_ROLE) {
        depositLock = false;
        TERM_VAULT_EVENT_EMITTER.emitDepositUnpaused();
    }

    /**
     * @notice Pause the contract
     */
    function pauseStrategy() external onlyRole(GOVERNOR_ROLE) {
        _pause();
        depositLock = true;
        //TERM_VAULT_EVENT_EMITTER.emitStrategyPaused();
    }

    /**
     * @notice Unpause the contract
     */
    function unpauseStrategy() external onlyRole(GOVERNOR_ROLE) {
        _unpause();
        depositLock = false;
        //TERM_VAULT_EVENT_EMITTER.emitStrategyUnpaused();
    }

    function setPendingGovernor(
        address newGovernor
    ) external onlyRole(GOVERNOR_ROLE) {
        require(newGovernor != address(0));
        pendingGovernor = newGovernor;
    }

    function acceptGovernor() external {
        require(msg.sender == pendingGovernor, "!pendingGovernor");
        _revokeRole(GOVERNOR_ROLE, strategyState.governorAddress);
        _grantRole(GOVERNOR_ROLE, pendingGovernor);
        strategyState.governorAddress = pendingGovernor;
        TERM_VAULT_EVENT_EMITTER.emitNewGovernor(pendingGovernor);
        pendingGovernor = address(0);
    }

    /**
     * @notice Set the term controller
     * @param newTermControllerAddr The address of the new term controller
     */
    function setTermController(
        address newTermControllerAddr
    ) external onlyRole(GOVERNOR_ROLE) {
        require(newTermControllerAddr != address(0));
        require(
            ITermController(newTermControllerAddr)
                .getProtocolReserveAddress() != address(0)
        );
        address currentIteration = repoTokenListData.head;
        while (currentIteration != address(0)) {
            if (!_isTermDeployed(currentIteration)) {
                revert RepoTokenList.InvalidRepoToken(currentIteration);
            }
            currentIteration = repoTokenListData.nodes[currentIteration].next;
        }
        address current = address(strategyState.currTermController);
        TERM_VAULT_EVENT_EMITTER.emitTermControllerUpdated(
            current,
            newTermControllerAddr
        );
        strategyState.prevTermController = ITermController(current);
        strategyState.currTermController = ITermController(
            newTermControllerAddr
        );
    }

    /**
     * @notice Set the discount rate adapter used to price repoTokens
     * @param newAdapter The address of the new discount rate adapter
     */
    function setDiscountRateAdapter(
        address newAdapter
    ) external onlyRole(GOVERNOR_ROLE) {
        ITermDiscountRateAdapter newDiscountRateAdapter = ITermDiscountRateAdapter(
                newAdapter
            );
        require(
            address(newDiscountRateAdapter.currTermController()) != address(0)
        );
        TERM_VAULT_EVENT_EMITTER.emitDiscountRateAdapterUpdated(
            address(strategyState.discountRateAdapter),
            newAdapter
        );
        strategyState.discountRateAdapter = newDiscountRateAdapter;
    }

    /**
     * @notice Set the weighted time to maturity cap
     * @param newTimeToMaturityThreshold The new weighted time to maturity cap
     */
    function setTimeToMaturityThreshold(
        uint256 newTimeToMaturityThreshold
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitTimeToMaturityThresholdUpdated(
            strategyState.timeToMaturityThreshold,
            newTimeToMaturityThreshold
        );
        strategyState.timeToMaturityThreshold = newTimeToMaturityThreshold;
    }

    /**
     * @notice Set the required reserve ratio
     * @dev This function can only be called by management
     * @param newRequiredReserveRatio The new required reserve ratio (in 1e18 precision)
     */
    function setRequiredReserveRatio(
        uint256 newRequiredReserveRatio
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitRequiredReserveRatioUpdated(
            strategyState.requiredReserveRatio,
            newRequiredReserveRatio
        );
        strategyState.requiredReserveRatio = newRequiredReserveRatio;
    }

    /**
     * @notice Set the repoToken concentration limit
     * @param newRepoTokenConcentrationLimit The new repoToken concentration limit
     */
    function setRepoTokenConcentrationLimit(
        uint256 newRepoTokenConcentrationLimit
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitRepoTokenConcentrationLimitUpdated(
            strategyState.repoTokenConcentrationLimit,
            newRepoTokenConcentrationLimit
        );
        strategyState
            .repoTokenConcentrationLimit = newRepoTokenConcentrationLimit;
    }

    /**
     * @notice Set the markup that the vault will receive in excess of the oracle rate
     * @param newDiscountRateMarkup The new auction rate markup
     */
    function setDiscountRateMarkup(
        uint256 newDiscountRateMarkup
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitDiscountRateMarkupUpdated(
            strategyState.discountRateMarkup,
            newDiscountRateMarkup
        );
        strategyState.discountRateMarkup = newDiscountRateMarkup;
    }
    /**
     * @notice Set the collateral token parameters
     * @param tokenAddr The address of the collateral token to be accepted
     * @param minCollateralRatio The minimum collateral ratio accepted by the strategy
     */
    function setCollateralTokenParams(
        address tokenAddr,
        uint256 minCollateralRatio
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitMinCollateralRatioUpdated(
            tokenAddr,
            minCollateralRatio
        );
        repoTokenListData.collateralTokenParams[tokenAddr] = minCollateralRatio;
    }

    function setRepoTokenBlacklist(
        address repoToken,
        bool blacklisted
    ) external onlyRole(GOVERNOR_ROLE) {
        TERM_VAULT_EVENT_EMITTER.emitRepoTokenBlacklistUpdated(
            repoToken,
            blacklisted
        );
        repoTokenBlacklist[repoToken] = blacklisted;
    }

    /*//////////////////////////////////////////////////////////////
                    VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function symbol() external view returns (string memory) {
        return tokenSymbol;
    }

    /**
     * @notice Calculates the total value of all assets managed by the strategy
     * @return The total asset value in the purchase token precision
     *
     * @dev This function aggregates the total liquid balance, the present value of all repoTokens,
     * and the present value of all pending offers to calculate the total asset value.
     */
    function totalAssetValue() external view returns (uint256) {
        return _totalAssetValue(_totalLiquidBalance());
    }

    /**
     * @notice Get the total liquid balance of the assets managed by the strategy
     * @return The total liquid balance in the purchase token precision
     *
     * @dev This function aggregates the balance of the underlying asset held directly by the strategy
     * and the balance of the asset held in the Yearn Vault to calculate the total liquid balance.
     */
    function totalLiquidBalance() external view returns (uint256) {
        return _totalLiquidBalance();
    }

    /**
     * @notice Calculate the liquid reserve ratio
     * @param liquidBalance The current liquid balance of the strategy
     * @return The liquid reserve ratio in 1e18 precision
     *
     * @dev This function calculates the ratio of liquid balance to total asset value.
     * It returns 0 if the total asset value is 0 to avoid division by zero.
     */
    function _liquidReserveRatio(
        uint256 liquidBalance
    ) internal view returns (uint256) {
        uint256 assetValue = _totalAssetValue(liquidBalance);
        if (assetValue == 0) return 0;
        return (liquidBalance * 1e18) / assetValue;
    }

    /**
     * @notice Get the current liquid reserve ratio of the strategy
     * @return The current liquid reserve ratio in 1e18 precision
     *
     * @dev This function calculates the liquid reserve ratio based on the current
     * total liquid balance of the strategy.
     */
    function liquidReserveRatio() external view returns (uint256) {
        return _liquidReserveRatio(_totalLiquidBalance());
    }

    /**
     * @notice Returns an array of addresses representing the repoTokens currently held by the strategy
     * @return address[] An array of addresses of the repoTokens held by the strategy
     *
     * @dev This function calls the `holdings` function from the `RepoTokenList` library to get the list
     * of repoTokens currently held in the `RepoTokenListData` structure.
     */
    function repoTokenHoldings() external view returns (address[] memory) {
        return repoTokenListData.holdings();
    }

    /**
     * @notice Get an array of pending offers submitted into Term auctions
     * @return bytes32[] An array of `bytes32` values representing the IDs of the pending offers
     *
     * @dev This function calls the `pendingOffers` function from the `TermAuctionList` library to get the list
     * of pending offers currently submitted into Term auctions from the `TermAuctionListData` structure.
     */
    function pendingOffers() external view returns (bytes32[] memory) {
        return termAuctionListData.pendingOffers();
    }

    /**
     * @notice Calculate the concentration ratio of a specific repoToken in the strategy
     * @param repoToken The address of the repoToken to calculate the concentration for
     * @return The concentration ratio of the repoToken in the strategy (in 1e18 precision)
     *
     * @dev This function computes the current concentration ratio of a specific repoToken
     * in the strategy's portfolio. It reverts if the repoToken address is zero. The calculation
     * is based on the current total asset value and does not consider any additional purchases
     * or removals of the repoToken.
     */
    function getRepoTokenConcentrationRatio(
        address repoToken
    ) external view returns (uint256) {
        if (repoToken == address(0)) {
            revert RepoTokenList.InvalidRepoToken(address(0));
        }
        return
            _getRepoTokenConcentrationRatio(
                repoToken,
                0,
                _totalAssetValue(_totalLiquidBalance()),
                0
            );
    }

    /**
     * @notice Simulates the weighted time to maturity for a specified repoToken and amount, including the impact on the entire strategy's holdings
     * @param repoToken The address of the repoToken to be simulated
     * @param amount The amount of the repoToken to be simulated
     * @return simulatedWeightedMaturity The simulated weighted time to maturity for the entire strategy
     * @return simulatedRepoTokenConcentrationRatio The concentration ratio of the repoToken in the strategy (in 1e18 precision)
     * @return simulatedLiquidityRatio The simulated liquidity ratio after the transaction
     *
     * @dev This function simulates the effects of a potential transaction on the strategy's key metrics.
     * It calculates the new weighted time to maturity and liquidity ratio, considering the specified
     * repoToken and amount. For existing repoTokens, use address(0) as the repoToken parameter.
     * The function performs various checks and calculations, including:
     * - Validating the repoToken (if not address(0))
     * - Calculating the present value of the transaction
     * - Estimating the impact on the strategy's liquid balance
     * - Computing the new weighted maturity and liquidity ratio
     */
    function simulateTransaction(
        address repoToken,
        uint256 amount
    )
        external
        view
        returns (
            uint256 simulatedWeightedMaturity,
            uint256 simulatedRepoTokenConcentrationRatio,
            uint256 simulatedLiquidityRatio
        )
    {
        // do not validate if we are simulating with existing repoTokens
        uint256 liquidBalance = _totalLiquidBalance();
        uint256 repoTokenAmountInBaseAssetPrecision;
        uint256 proceeds;
        if (repoToken != address(0)) {
            if (!_isTermDeployed(repoToken)) {
                revert RepoTokenList.InvalidRepoToken(repoToken);
            }

            (
                bool isRepoTokenValid,
                uint256 redemptionTimestamp
            ) = repoTokenListData.validateRepoToken(
                    ITermRepoToken(repoToken),
                    address(asset)
                );

            if (!isRepoTokenValid) {
                revert RepoTokenList.InvalidRepoToken(repoToken);
            }

            uint256 discountRate = strategyState
                .discountRateAdapter
                .getDiscountRate(repoToken);
            uint256 repoRedemptionHaircut = strategyState
                .discountRateAdapter
                .repoRedemptionHaircut(repoToken);
            repoTokenAmountInBaseAssetPrecision = RepoTokenUtils
                .getNormalizedRepoTokenAmount(
                    repoToken,
                    amount,
                    PURCHASE_TOKEN_PRECISION,
                    repoRedemptionHaircut
                );
            proceeds = RepoTokenUtils.calculatePresentValue(
                repoTokenAmountInBaseAssetPrecision,
                PURCHASE_TOKEN_PRECISION,
                redemptionTimestamp,
                discountRate + strategyState.discountRateMarkup
            );
        }

        simulatedWeightedMaturity = _calculateWeightedMaturity(
            repoToken,
            amount,
            liquidBalance - proceeds
        );

        if (repoToken != address(0)) {
            simulatedRepoTokenConcentrationRatio = _getRepoTokenConcentrationRatio(
                repoToken,
                repoTokenAmountInBaseAssetPrecision,
                _totalAssetValue(liquidBalance),
                proceeds
            );
        }

        uint256 assetValue = _totalAssetValue(liquidBalance);

        if (assetValue == 0) {
            simulatedLiquidityRatio = 0;
        } else {
            simulatedLiquidityRatio =
                ((liquidBalance - proceeds) * 10 ** 18) /
                assetValue;
        }
    }

    /**
     * @notice Calculates the present value of a specified repoToken based on its discount rate, redemption timestamp, and amount
     * @param repoToken The address of the repoToken
     * @param discountRate The discount rate to be used in the present value calculation
     * @param amount The amount of the repoToken to be discounted
     * @return uint256 The present value of the specified repoToken and amount
     *
     * @dev This function retrieves the redemption timestamp, calculates the repoToken precision,
     * normalizes the repoToken amount to base asset precision, and calculates the present value
     * using the provided discount rate and redemption timestamp.
     */
    function calculateRepoTokenPresentValue(
        address repoToken,
        uint256 discountRate,
        uint256 amount
    ) public view returns (uint256) {
        (uint256 redemptionTimestamp, , , ) = ITermRepoToken(repoToken)
            .config();
        uint256 repoTokenAmountInBaseAssetPrecision = RepoTokenUtils
            .getNormalizedRepoTokenAmount(
                repoToken,
                amount,
                PURCHASE_TOKEN_PRECISION,
                strategyState.discountRateAdapter.repoRedemptionHaircut(
                    repoToken
                )
            );
        return
            RepoTokenUtils.calculatePresentValue(
                repoTokenAmountInBaseAssetPrecision,
                PURCHASE_TOKEN_PRECISION,
                redemptionTimestamp,
                discountRate
            );
    }

    /**
     * @notice Calculates the present value of a specified repoToken held by the strategy
     * @param repoToken The address of the repoToken to value
     * @return uint256 The present value of the specified repoToken
     *
     * @dev This function calculates the present value of the specified repoToken from both
     * the `repoTokenListData` and `termAuctionListData` structures, then sums these values
     * to provide a comprehensive valuation.
     */
    function getRepoTokenHoldingValue(
        address repoToken
    ) public view returns (uint256) {
        uint256 repoTokenHoldingPV;
        if (repoTokenListData.discountRates[repoToken] != 0) {
            address tokenTermController;
            if (strategyState.currTermController.isTermDeployed(repoToken)) {
                tokenTermController = address(strategyState.currTermController);
            } else if (
                strategyState.prevTermController.isTermDeployed(repoToken)
            ) {
                tokenTermController = address(strategyState.prevTermController);
            }
            repoTokenHoldingPV = calculateRepoTokenPresentValue(
                repoToken,
                strategyState.discountRateAdapter.getDiscountRate(
                    tokenTermController,
                    repoToken
                ),
                ITermRepoToken(repoToken).balanceOf(address(this))
            );
        }
        return
            repoTokenHoldingPV +
            termAuctionListData.getPresentValue(
                repoTokenListData,
                strategyState.discountRateAdapter,
                PURCHASE_TOKEN_PRECISION,
                repoToken
            );
    }

    /*//////////////////////////////////////////////////////////////
                    INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Withdraw assets from the Yearn vault
     * @param amount The amount to withdraw
     */
    function _withdrawAsset(uint256 amount) private {
        YEARN_VAULT.withdraw(amount, address(this), address(this));
    }

    /**
     * @dev Retrieves the asset balance from the Yearn Vault
     * @return The balance of assets in the purchase token precision
     */
    function _assetBalance() private view returns (uint256) {
        return
            YEARN_VAULT.convertToAssets(YEARN_VAULT.balanceOf(address(this)));
    }

    /**
     * @notice Calculates the total liquid balance of the assets managed by the strategy
     * @return uint256 The total liquid balance of the assets
     *
     * @dev This function aggregates the balance of the underlying asset held directly by the strategy
     * and the balance of the asset held in the Yearn Vault to calculate the total liquid balance.
     */
    function _totalLiquidBalance() private view returns (uint256) {
        uint256 underlyingBalance = IERC20(asset).balanceOf(address(this));
        return _assetBalance() + underlyingBalance;
    }

    /**
     * @notice Calculates the total value of all assets managed by the strategy (internal function)
     * @return totalValue The total value of all assets
     *
     * @dev This function aggregates the total liquid balance, the present value of all repoTokens,
     * and the present value of all pending offers to calculate the total asset value.
     */
    function _totalAssetValue(
        uint256 liquidBalance
    ) internal view returns (uint256 totalValue) {
        return
            liquidBalance +
            repoTokenListData.getPresentValue(
                strategyState.discountRateAdapter,
                PURCHASE_TOKEN_PRECISION
            ) +
            termAuctionListData.getPresentValue(
                repoTokenListData,
                strategyState.discountRateAdapter,
                PURCHASE_TOKEN_PRECISION,
                address(0)
            );
    }

    /**
     * @notice Calculates the concentration ratio of a specific repoToken in the strategy
     * @param repoToken The address of the repoToken to calculate the concentration for
     * @param repoTokenAmountInBaseAssetPrecision The amount of the repoToken in base asset precision to be added
     * @param assetValue The current total asset value of the strategy
     * @param liquidBalanceToRemove The amount of liquid balance to be removed from the strategy
     * @return The concentration ratio of the repoToken in the strategy (in 1e18 precision)
     *
     * @dev This function computes the concentration ratio of a specific repoToken, considering both
     * existing holdings and a potential new addition. It adjusts the total asset value, normalizes
     * values to 1e18 precision, and handles the case where total asset value might be zero.
     */
    function _getRepoTokenConcentrationRatio(
        address repoToken,
        uint256 repoTokenAmountInBaseAssetPrecision,
        uint256 assetValue,
        uint256 liquidBalanceToRemove
    ) private view returns (uint256) {
        // Retrieve the current value of the repoToken held by the strategy and add the new repoToken amount
        uint256 repoTokenValue = getRepoTokenHoldingValue(repoToken) +
            repoTokenAmountInBaseAssetPrecision;

        // Retrieve the total asset value of the strategy and adjust it for the new repoToken amount and liquid balance to be removed
        uint256 adjustedTotalAssetValue = assetValue +
            repoTokenAmountInBaseAssetPrecision -
            liquidBalanceToRemove;

        // Normalize the repoToken value and total asset value to 1e18 precision
        repoTokenValue = (repoTokenValue * 1e18) / PURCHASE_TOKEN_PRECISION;
        adjustedTotalAssetValue =
            (adjustedTotalAssetValue * 1e18) /
            PURCHASE_TOKEN_PRECISION;

        // Calculate the repoToken concentration
        return
            adjustedTotalAssetValue == 0
                ? 0
                : (repoTokenValue * 1e18) / adjustedTotalAssetValue;
    }

    /**
     * @notice Validate the concentration of a repoToken against the strategy's limit
     * @param repoToken The address of the repoToken to validate
     * @param repoTokenAmountInBaseAssetPrecision The amount of the repoToken in base asset precision
     * @param assetValue The current total asset value of the strategy
     * @param liquidBalanceToRemove The amount of liquid balance to be removed from the strategy
     *
     * @dev This function calculates the concentration ratio of the specified repoToken
     * and compares it against the predefined concentration limit. It reverts with a
     * RepoTokenConcentrationTooHigh error if the concentration exceeds the limit.
     */
    function _validateRepoTokenConcentration(
        address repoToken,
        uint256 repoTokenAmountInBaseAssetPrecision,
        uint256 assetValue,
        uint256 liquidBalanceToRemove
    ) private view {
        uint256 repoTokenConcentration = _getRepoTokenConcentrationRatio(
            repoToken,
            repoTokenAmountInBaseAssetPrecision,
            assetValue,
            liquidBalanceToRemove
        );

        // Check if the repoToken concentration exceeds the predefined limit
        if (
            repoTokenConcentration > strategyState.repoTokenConcentrationLimit
        ) {
            revert RepoTokenConcentrationTooHigh(repoToken);
        }
    }

    /**
     * @notice Calculates the weighted time to maturity for the strategy's holdings, including the impact of a specified repoToken and amount
     * @param repoToken The address of the repoToken (optional)
     * @param repoTokenAmount The amount of the repoToken to be included in the calculation
     * @param liquidBalance The liquid balance of the strategy
     * @return uint256 The weighted time to maturity in seconds for the entire strategy, including the specified repoToken and amount
     *
     * @dev This function aggregates the cumulative weighted time to maturity and the cumulative amount of both existing repoTokens
     * and offers, then calculates the weighted time to maturity for the entire strategy. It considers both repoTokens and auction offers.
     * The `repoToken` and `repoTokenAmount` parameters are optional and provide flexibility to adjust the calculations to include
     * the provided repoToken amount. If `repoToken` is set to `address(0)` or `repoTokenAmount` is `0`, the function calculates
     * the cumulative data without specific token adjustments.
     */
    function _calculateWeightedMaturity(
        address repoToken,
        uint256 repoTokenAmount,
        uint256 liquidBalance
    ) private view returns (uint256) {
        // Initialize cumulative weighted time to maturity and cumulative amount
        uint256 cumulativeWeightedTimeToMaturity; // in seconds
        uint256 cumulativeAmount; // in purchase token precision

        // Get cumulative data from repoToken list
        (
            uint256 cumulativeRepoTokenWeightedTimeToMaturity,
            uint256 cumulativeRepoTokenAmount,
            bool foundInRepoTokenList
        ) = repoTokenListData.getCumulativeRepoTokenData(
                strategyState.discountRateAdapter,
                repoToken,
                repoTokenAmount,
                PURCHASE_TOKEN_PRECISION
            );

        // Accumulate repoToken data
        cumulativeWeightedTimeToMaturity += cumulativeRepoTokenWeightedTimeToMaturity;
        cumulativeAmount += cumulativeRepoTokenAmount;

        (
            uint256 cumulativeOfferWeightedTimeToMaturity,
            uint256 cumulativeOfferAmount,
            bool foundInOfferList
        ) = termAuctionListData.getCumulativeOfferData(
                repoTokenListData,
                strategyState.discountRateAdapter,
                repoToken,
                repoTokenAmount,
                PURCHASE_TOKEN_PRECISION
            );

        // Accumulate offer data
        cumulativeWeightedTimeToMaturity += cumulativeOfferWeightedTimeToMaturity;
        cumulativeAmount += cumulativeOfferAmount;

        if (
            !foundInRepoTokenList &&
            !foundInOfferList &&
            repoToken != address(0)
        ) {
            uint256 repoRedemptionHaircut = strategyState
                .discountRateAdapter
                .repoRedemptionHaircut(repoToken);
            uint256 repoTokenAmountInBaseAssetPrecision = RepoTokenUtils
                .getNormalizedRepoTokenAmount(
                    repoToken,
                    repoTokenAmount,
                    PURCHASE_TOKEN_PRECISION,
                    repoRedemptionHaircut
                );

            cumulativeAmount += repoTokenAmountInBaseAssetPrecision;
            cumulativeWeightedTimeToMaturity += RepoTokenList
                .getRepoTokenWeightedTimeToMaturity(
                    repoToken,
                    repoTokenAmountInBaseAssetPrecision
                );
        }

        // Avoid division by zero
        if (cumulativeAmount == 0 && liquidBalance == 0) {
            return 0;
        }

        // Calculate and return weighted time to maturity
        // time * purchaseTokenPrecision / purchaseTokenPrecision
        return
            cumulativeWeightedTimeToMaturity /
            (cumulativeAmount + liquidBalance);
    }

    /**
     * @notice Checks if a term contract is marked as deployed in either the current or previous term controller
     * @param termContract The address of the term contract to check
     * @return bool True if the term contract is deployed, false otherwise
     *
     * @dev This function first checks the current term controller, then the previous one if necessary.
     * It handles cases where either controller might be unset (address(0)).
     */
    function _isTermDeployed(address termContract) private view returns (bool) {
        ITermController currTermController = strategyState.currTermController;
        ITermController prevTermController = strategyState.prevTermController;
        if (
            address(currTermController) != address(0) &&
            currTermController.isTermDeployed(termContract)
        ) {
            return true;
        }
        if (
            address(prevTermController) != address(0) &&
            prevTermController.isTermDeployed(termContract)
        ) {
            return true;
        }
        return false;
    }

    /**
     * @notice Rebalances the strategy's assets by sweeping assets and redeeming matured repoTokens
     * @param liquidAmountRequired The amount of liquid assets required to be maintained by the strategy
     *
     * @dev This function removes completed auction offers, redeems matured repoTokens, and adjusts the underlying
     * balance to maintain the required liquidity. It ensures that the strategy has sufficient liquid assets while
     * optimizing asset allocation.
     */
    function _redeemRepoTokens(uint256 liquidAmountRequired) private {
        // Remove completed auction offers
        termAuctionListData.removeCompleted(
            repoTokenListData,
            strategyState.discountRateAdapter,
            address(asset)
        );

        // Remove and redeem matured repoTokens
        repoTokenListData.removeAndRedeemMaturedTokens();

        uint256 liquidity = IERC20(asset).balanceOf(address(this));

        // Deposit excess underlying balance into Yearn Vault
        if (liquidity > liquidAmountRequired) {
            unchecked {
                YEARN_VAULT.deposit(
                    liquidity - liquidAmountRequired,
                    address(this)
                );
            }
            // Withdraw shortfall from Yearn Vault to meet required liquidity
        } else if (liquidity < liquidAmountRequired) {
            unchecked {
                _withdrawAsset(liquidAmountRequired - liquidity);
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                    STRATEGIST FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Validates a term auction and repo token, and retrieves the associated offer locker
     * @param termAuction The term auction contract to validate
     * @param repoToken The repo token address to validate
     * @return ITermAuctionOfferLocker The offer locker associated with the validated term auction
     *
     * @dev This function performs several validation steps: verifying term auction and repo token deployment,
     * matching repo token to auction's term repo ID, validating repo token against strategy requirements,
     * and ensuring the auction is open. It reverts with specific error messages on validation failures.
     */
    function _validateAndGetOfferLocker(
        ITermAuction termAuction,
        address repoToken
    ) private view returns (ITermAuctionOfferLocker) {
        // Verify that the term auction and repo token are valid and deployed by term
        if (!_isTermDeployed(address(termAuction))) {
            revert InvalidTermAuction(address(termAuction));
        }
        if (!_isTermDeployed(repoToken)) {
            revert RepoTokenList.InvalidRepoToken(repoToken);
        }

        if (
            termAuction.termRepoId() != ITermRepoToken(repoToken).termRepoId()
        ) {
            revert RepoTokenList.InvalidRepoToken(repoToken);
        }

        // Validate purchase token, min collateral ratio and insert the repoToken if necessary
        (bool isValid, ) = repoTokenListData.validateRepoToken(
            ITermRepoToken(repoToken),
            address(asset)
        );

        if (!isValid) {
            revert RepoTokenList.InvalidRepoToken(repoToken);
        }

        // Prepare and submit the offer
        ITermAuctionOfferLocker offerLocker = ITermAuctionOfferLocker(
            termAuction.termAuctionOfferLocker()
        );
        if (
            block.timestamp <= offerLocker.auctionStartTime() ||
            block.timestamp >= offerLocker.revealTime()
        ) {
            revert AuctionNotOpen();
        }

        return offerLocker;
    }

    /**
     * @notice Submits an offer into a term auction for a specified repoToken
     * @param termAuction The address of the term auction
     * @param repoToken The address of the repoToken
     * @param idHash The hash of the offer ID
     * @param offerPriceHash The hash of the offer price
     * @param purchaseTokenAmount The amount of purchase tokens being offered
     * @return offerIds An array of offer IDs for the submitted offers
     *
     * @dev This function validates the underlying repoToken, checks concentration limits, ensures the auction is open,
     * and rebalances liquidity to support the offer submission. It handles both new offers and edits to existing offers.
     */
    function submitAuctionOffer(
        ITermAuction termAuction,
        address repoToken,
        bytes32 idHash,
        bytes32 offerPriceHash,
        uint256 purchaseTokenAmount
    )
        external
        whenNotPaused
        notBlacklisted(repoToken)
        onlyManagement
        returns (bytes32[] memory offerIds)
    {
        if (purchaseTokenAmount == 0) {
            revert ZeroPurchaseTokenAmount();
        }

        ITermAuctionOfferLocker offerLocker = _validateAndGetOfferLocker(
            termAuction,
            repoToken
        );

        // Sweep assets, redeem matured repoTokens and ensure liquid balances up to date
        _redeemRepoTokens(0);

        uint256 newOfferAmount = purchaseTokenAmount;
        uint256 currentOfferAmount = termAuctionListData
            .offers[idHash]
            .offerAmount;

        // Submit the offer and lock it in the auction
        ITermAuctionOfferLocker.TermAuctionOfferSubmission memory offer;
        offer.id = idHash;
        offer.offeror = address(this);
        offer.offerPriceHash = offerPriceHash;
        offer.amount = purchaseTokenAmount;
        offer.purchaseToken = address(asset);

        // InsufficientLiquidBalance checked inside _submitOffer
        offerIds = _submitOffer(
            termAuction,
            offerLocker,
            offer,
            repoToken,
            newOfferAmount,
            currentOfferAmount
        );

        // Retrieve the total liquid balance
        uint256 liquidBalance = _totalLiquidBalance();
        uint256 totalAssetValue = _totalAssetValue(liquidBalance);
        require(totalAssetValue > 0);
        uint256 liquidReserveRatio = (liquidBalance * 1e18) / totalAssetValue; // NOTE: we require totalAssetValue > 0 above

        // Check that new offer does not violate reserve ratio constraint
        if (liquidReserveRatio < strategyState.requiredReserveRatio) {
            revert BalanceBelowRequiredReserveRatio();
        }

        // Calculate the resulting weighted time to maturity
        // Passing in 0 adjustment because offer and balance already updated
        uint256 resultingWeightedTimeToMaturity = _calculateWeightedMaturity(
            address(0),
            0,
            liquidBalance
        );

        // Check if the resulting weighted time to maturity exceeds the threshold
        if (
            resultingWeightedTimeToMaturity >
            strategyState.timeToMaturityThreshold
        ) {
            revert TimeToMaturityAboveThreshold();
        }

        // Passing in 0 amount and 0 liquid balance adjustment because offer and balance already updated
        _validateRepoTokenConcentration(repoToken, 0, totalAssetValue, 0);
    }

    /**
     * @dev Submits an offer to a term auction and locks it using the offer locker.
     * @param auction The term auction contract
     * @param offerLocker The offer locker contract
     * @param offer The offer details
     * @param repoToken The address of the repoToken
     * @param newOfferAmount The amount of the new offer
     * @param currentOfferAmount The amount of the current offer, if it exists
     * @return offerIds An array of offer IDs for the submitted offers
     */
    function _submitOffer(
        ITermAuction auction,
        ITermAuctionOfferLocker offerLocker,
        ITermAuctionOfferLocker.TermAuctionOfferSubmission memory offer,
        address repoToken,
        uint256 newOfferAmount,
        uint256 currentOfferAmount
    ) private returns (bytes32[] memory offerIds) {
        // Retrieve the repo servicer contract
        ITermRepoServicer repoServicer = ITermRepoServicer(
            offerLocker.termRepoServicer()
        );

        // Prepare the offer submission details
        ITermAuctionOfferLocker.TermAuctionOfferSubmission[]
            memory offerSubmissions = new ITermAuctionOfferLocker.TermAuctionOfferSubmission[](
                1
            );
        offerSubmissions[0] = offer;

        // Handle additional asset withdrawal if the new offer amount is greater than the current amount
        if (newOfferAmount > currentOfferAmount) {
            uint256 offerDebit;
            unchecked {
                // checked above
                offerDebit = newOfferAmount - currentOfferAmount;
            }

            uint256 liquidBalance = _totalLiquidBalance();
            if (liquidBalance < offerDebit) {
                revert InsufficientLiquidBalance(liquidBalance, offerDebit);
            }

            _withdrawAsset(offerDebit);
            IERC20(asset).safeApprove(
                address(repoServicer.termRepoLocker()),
                offerDebit
            );
        }

        // Submit the offer and get the offer IDs
        offerIds = offerLocker.lockOffers(offerSubmissions);

        if (offerIds.length == 0) {
            revert OfferNotFound();
        }

        // Update the pending offers list
        if (currentOfferAmount == 0) {
            // new offer
            termAuctionListData.insertPending(
                offerIds[0],
                PendingOffer({
                    repoToken: repoToken,
                    offerAmount: offer.amount,
                    termAuction: auction,
                    offerLocker: offerLocker
                })
            );
        } else {
            // Edit offer, overwrite existing
            PendingOffer storage pendingOffer = termAuctionListData.offers[
                offerIds[0]
            ];
            pendingOffer.offerAmount = offer.amount;
        }

        if (newOfferAmount < currentOfferAmount) {
            YEARN_VAULT.deposit(
                IERC20(asset).balanceOf(address(this)),
                address(this)
            );
        }
    }

    /**
     * @dev Removes specified offers from a term auction and performs related cleanup.
     * @param termAuction The address of the term auction from which offers will be deleted.
     * @param offerIds An array of offer IDs to be deleted.
     */
    function deleteAuctionOffers(
        address termAuction,
        bytes32[] calldata offerIds
    ) external onlyManagement {
        // Validate if the term auction is deployed by term
        if (!_isTermDeployed(termAuction)) {
            revert InvalidTermAuction(termAuction);
        }

        // Retrieve the auction and offer locker contracts
        ITermAuction auction = ITermAuction(termAuction);
        ITermAuctionOfferLocker offerLocker = ITermAuctionOfferLocker(
            auction.termAuctionOfferLocker()
        );

        // Unlock the specified offers
        offerLocker.unlockOffers(offerIds);

        // Update the term auction list data and remove completed offers
        termAuctionListData.removeCompleted(
            repoTokenListData,
            strategyState.discountRateAdapter,
            address(asset)
        );

        // Sweep any remaining assets and redeem repoTokens
        _redeemRepoTokens(0);
    }

    /**
     * @notice Required for post-processing after auction clos
     */
    function auctionClosed() external {
        _redeemRepoTokens(0);
    }

    /*//////////////////////////////////////////////////////////////
                    PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Allows the sale of a specified amount of a repoToken in exchange for assets.
     * @param repoToken The address of the repoToken to be sold.
     * @param repoTokenAmount The amount of the repoToken to be sold.
     */
    function sellRepoToken(
        address repoToken,
        uint256 repoTokenAmount
    ) external whenNotPaused notBlacklisted(repoToken) {
        // Ensure the amount of repoTokens to sell is greater than zero
        require(repoTokenAmount > 0);

        // Make sure repo token is valid and deployed by Term
        if (!_isTermDeployed(repoToken)) {
            revert RepoTokenList.InvalidRepoToken(repoToken);
        }

        // Validate and insert the repoToken into the list, retrieve auction rate and redemption timestamp
        (bool isRepoTokenValid, uint256 redemptionTimestamp) = repoTokenListData
            .validateAndInsertRepoToken(
                ITermRepoToken(repoToken),
                strategyState.discountRateAdapter,
                address(asset)
            );

        if (!isRepoTokenValid) {
            revert RepoTokenList.InvalidRepoToken(repoToken);
        }

        // Sweep assets and redeem repoTokens, if needed
        _redeemRepoTokens(0);

        // Retrieve total asset value and liquid balance and ensure they are greater than zero
        uint256 liquidBalance = _totalLiquidBalance();
        require(liquidBalance > 0);
        uint256 totalAssetValue = _totalAssetValue(liquidBalance);
        require(totalAssetValue > 0);

        uint256 discountRate = strategyState
            .discountRateAdapter
            .getDiscountRate(repoToken);

        // Calculate the repoToken amount in base asset precision
        uint256 repoTokenAmountInBaseAssetPrecision = RepoTokenUtils
            .getNormalizedRepoTokenAmount(
                repoToken,
                repoTokenAmount,
                PURCHASE_TOKEN_PRECISION,
                strategyState.discountRateAdapter.repoRedemptionHaircut(
                    repoToken
                )
            );

        // Calculate the proceeds from selling the repoToken
        uint256 proceeds = RepoTokenUtils.calculatePresentValue(
            repoTokenAmountInBaseAssetPrecision,
            PURCHASE_TOKEN_PRECISION,
            redemptionTimestamp,
            discountRate + strategyState.discountRateMarkup
        );

        // Ensure the liquid balance is sufficient to cover the proceeds
        if (liquidBalance < proceeds) {
            revert InsufficientLiquidBalance(liquidBalance, proceeds);
        }

        // Calculate resulting time to maturity after the sale and ensure it doesn't exceed the threshold
        uint256 resultingTimeToMaturity = _calculateWeightedMaturity(
            repoToken,
            repoTokenAmount,
            liquidBalance - proceeds
        );
        if (resultingTimeToMaturity > strategyState.timeToMaturityThreshold) {
            revert TimeToMaturityAboveThreshold();
        }

        // Ensure the remaining liquid balance is above the liquidity threshold
        uint256 newLiquidReserveRatio = ((liquidBalance - proceeds) * 1e18) /
            totalAssetValue; // NOTE: we require totalAssetValue > 0 above
        if (newLiquidReserveRatio < strategyState.requiredReserveRatio) {
            revert BalanceBelowRequiredReserveRatio();
        }

        // Validate resulting repoToken concentration to ensure it meets requirements
        _validateRepoTokenConcentration(
            repoToken,
            repoTokenAmountInBaseAssetPrecision,
            totalAssetValue,
            proceeds
        );

        // withdraw from underlying vault
        _withdrawAsset(proceeds);

        // Transfer repoTokens from the sender to the contract
        IERC20(repoToken).safeTransferFrom(
            msg.sender,
            address(this),
            repoTokenAmount
        );

        // Transfer the proceeds in assets to the sender
        IERC20(asset).safeTransfer(msg.sender, proceeds);
    }

    /**
     * @notice Constructor to initialize the Strategy contract
     * @param _name The name of the strategy
    
     */
    constructor(
        string memory _name,
        string memory _symbol,
        StrategyParams memory _params
    ) BaseStrategy(_params._asset, _name) {
        YEARN_VAULT = IERC4626(_params._yearnVault);
        TERM_VAULT_EVENT_EMITTER = ITermVaultEvents(_params._eventEmitter);
        PURCHASE_TOKEN_PRECISION = 10 ** ERC20(asset).decimals();

        IERC20(_params._asset).safeApprove(
            _params._yearnVault,
            type(uint256).max
        );
        tokenSymbol = _symbol;

        strategyState = StrategyState({
            assetVault: address(YEARN_VAULT),
            eventEmitter: address(TERM_VAULT_EVENT_EMITTER),
            governorAddress: _params._governorAddress,
            prevTermController: ITermController(address(0)),
            currTermController: ITermController(_params._termController),
            discountRateAdapter: ITermDiscountRateAdapter(
                _params._discountRateAdapter
            ),
            timeToMaturityThreshold: _params._timeToMaturityThreshold,
            requiredReserveRatio: _params._requiredReserveRatio,
            discountRateMarkup: _params._discountRateMarkup,
            repoTokenConcentrationLimit: _params._repoTokenConcentrationLimit
        });

        _grantRole(GOVERNOR_ROLE, _params._governorAddress);
    }

    /*//////////////////////////////////////////////////////////////
                NEEDED TO BE OVERRIDDEN BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Can deploy up to '_amount' of 'asset' in the yield source.
     *
     * This function is called at the end of a {deposit} or {mint}
     * call. Meaning that unless a whitelist is implemented it will
     * be entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * @param _amount The amount of 'asset' that the strategy can attempt
     * to deposit in the yield source.
     */
    function _deployFunds(uint256 _amount) internal override whenNotPaused {
        if (depositLock) {
            revert DepositPaused();
        }

        _redeemRepoTokens(0);
    }

    /**
     * @dev Should attempt to free the '_amount' of 'asset'.
     *
     * NOTE: The amount of 'asset' that is already loose has already
     * been accounted for.
     *
     * This function is called during {withdraw} and {redeem} calls.
     * Meaning that unless a whitelist is implemented it will be
     * entirely permissionless and thus can be sandwiched or otherwise
     * manipulated.
     *
     * Should not rely on asset.balanceOf(address(this)) calls other than
     * for diff accounting purposes.
     *
     * Any difference between `_amount` and what is actually freed will be
     * counted as a loss and passed on to the withdrawer. This means
     * care should be taken in times of illiquidity. It may be better to revert
     * if withdraws are simply illiquid so not to realize incorrect losses.
     *
     * @param _amount, The amount of 'asset' to be freed.
     */
    function _freeFunds(uint256 _amount) internal override whenNotPaused {
        _redeemRepoTokens(_amount);
    }

    /**
     * @dev Internal function to harvest all rewards, redeploy any idle
     * funds and return an accurate accounting of all funds currently
     * held by the Strategy.
     *
     * This should do any needed harvesting, rewards selling, accrual,
     * redepositing etc. to get the most accurate view of current assets.
     *
     * NOTE: All applicable assets including loose assets should be
     * accounted for in this function.
     *
     * Care should be taken when relying on oracles or swap values rather
     * than actual amounts as all Strategy profit/loss accounting will
     * be done based on this returned value.
     *
     * This can still be called post a shutdown, a strategist can check
     * `TokenizedStrategy.isShutdown()` to decide if funds should be
     * redeployed or simply realize any profits/losses.
     *
     * @return _totalAssets A trusted and accurate account for the total
     * amount of 'asset' the strategy currently holds including idle funds.
     */
    function _harvestAndReport()
        internal
        override
        whenNotPaused
        returns (uint256 _totalAssets)
    {
        _redeemRepoTokens(0);
        return _totalAssetValue(_totalLiquidBalance());
    }

    /*//////////////////////////////////////////////////////////////
                    OPTIONAL TO OVERRIDE BY STRATEGIST
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the max amount of `asset` that can be withdrawn.
     * @dev Defaults to an unlimited amount for any address. But can
     * be overridden by strategists.
     *
     * This function will be called before any withdraw or redeem to enforce
     * any limits desired by the strategist. This can be used for illiquid
     * or sandwichable strategies.
     *
     *   EX:
     *       return asset.balanceOf(yieldSource);
     *
     * This does not need to take into account the `_owner`'s share balance
     * or conversion rates from shares to assets.
     *
     * @param . The address that is withdrawing from the strategy.
     * @return . The available amount that can be withdrawn in terms of `asset`
     */
    function availableWithdrawLimit(
        address /*_owner*/
    ) public view override returns (uint256) {
        return _totalLiquidBalance();
    }

    /**
     * @dev Optional function for strategist to override that can
     *  be called in between reports.
     *
     * If '_tend' is used tendTrigger() will also need to be overridden.
     *
     * This call can only be called by a permissioned role so may be
     * through protected relays.
     *
     * This can be used to harvest and compound rewards, deposit idle funds,
     * perform needed position maintenance or anything else that doesn't need
     * a full report for.
     *
     *   EX: A strategy that can not deposit funds without getting
     *       sandwiched can use the tend when a certain threshold
     *       of idle to totalAssets has been reached.
     *
     * This will have no effect on PPS of the strategy till report() is called.
     *
     * @param _totalIdle The current amount of idle funds that are available to deploy.
     *
    function _tend(uint256 _totalIdle) internal override {}
    */

    /**
     * @dev Optional trigger to override if tend() will be used by the strategy.
     * This must be implemented if the strategy hopes to invoke _tend().
     *
     * @return . Should return true if tend() should be called by keeper or false if not.
     *
    function _tendTrigger() internal view override returns (bool) {}
    */

    /**
     * @dev Optional function for a strategist to override that will
     * allow management to manually withdraw deployed funds from the
     * yield source if a strategy is shutdown.
     *
     * This should attempt to free `_amount`, noting that `_amount` may
     * be more than is currently deployed.
     *
     * NOTE: This will not realize any profits or losses. A separate
     * {report} will be needed in order to record any profit/loss. If
     * a report may need to be called after a shutdown it is important
     * to check if the strategy is shutdown during {_harvestAndReport}
     * so that it does not simply re-deploy all funds that had been freed.
     *
     * EX:
     *   if(freeAsset > 0 && !TokenizedStrategy.isShutdown()) {
     *       depositFunds...
     *    }
     *
     * @param _amount The amount of asset to attempt to free.
     *
    function _emergencyWithdraw(uint256 _amount) internal override {
        EX:
            _amount = min(_amount, aToken.balanceOf(address(this)));
            _freeFunds(_amount);
    }
    */
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {ITermController} from "./interfaces/term/ITermController.sol";
import {ITermAuction} from "./interfaces/term/ITermAuction.sol";
import {ITermAuctionOfferLocker} from "./interfaces/term/ITermAuctionOfferLocker.sol";
import {ITermRepoToken} from "./interfaces/term/ITermRepoToken.sol";
import {ITermRepoServicer} from "./interfaces/term/ITermRepoServicer.sol";
import {ITermDiscountRateAdapter} from "./interfaces/term/ITermDiscountRateAdapter.sol";
import {RepoTokenList, RepoTokenListData} from "./RepoTokenList.sol";
import {RepoTokenUtils} from "./RepoTokenUtils.sol";

// In-storage representation of an offer object
struct PendingOffer {
    address repoToken;
    uint256 offerAmount;
    ITermAuction termAuction;
    ITermAuctionOfferLocker offerLocker;
}

struct TermAuctionListNode {
    bytes32 next;
}

struct TermAuctionListData {
    bytes32 head;
    mapping(bytes32 => TermAuctionListNode) nodes;
    mapping(bytes32 => PendingOffer) offers;
}

/*//////////////////////////////////////////////////////////////
                        LIBRARY: TermAuctionList
//////////////////////////////////////////////////////////////*/

library TermAuctionList {
    using RepoTokenList for RepoTokenListData;

    bytes32 internal constant NULL_NODE = bytes32(0);

    /*//////////////////////////////////////////////////////////////
                        PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Get the next node in the list
     * @param listData The list data
     * @param current The current node
     * @return The next node
     */
    function _getNext(
        TermAuctionListData storage listData,
        bytes32 current
    ) private view returns (bytes32) {
        return listData.nodes[current].next;
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Count the number of nodes in the list
     * @param listData The list data
     * @return count The number of nodes in the list
     */
    function _count(
        TermAuctionListData storage listData
    ) internal view returns (uint256 count) {
        if (listData.head == NULL_NODE) return 0;
        bytes32 current = listData.head;
        while (current != NULL_NODE) {
            count++;
            current = _getNext(listData, current);
        }
    }

    /**
     * @notice Retrieves an array of offer IDs representing the pending offers
     * @param listData The list data
     * @return offers An array of offer IDs representing the pending offers
     *
     * @dev This function iterates through the list of offers and gathers their IDs into an array of `bytes32`.
     * This makes it easier to process and manage the pending offers.
     */
    function pendingOffers(
        TermAuctionListData storage listData
    ) internal view returns (bytes32[] memory offers) {
        uint256 count = _count(listData);
        if (count > 0) {
            offers = new bytes32[](count);
            uint256 i;
            bytes32 current = listData.head;
            while (current != NULL_NODE) {
                offers[i++] = current;
                current = _getNext(listData, current);
            }
        }
    }

    /**
     * @notice Inserts a new pending offer into the list data
     * @param listData The list data
     * @param offerId The ID of the offer to be inserted
     * @param pendingOffer The `PendingOffer` struct containing details of the offer to be inserted
     *
     * @dev This function inserts a new pending offer while maintaining the list sorted by auction address.
     * The function iterates through the list to find the correct position for the new `offerId` and updates the pointers accordingly.
     */
    function insertPending(
        TermAuctionListData storage listData,
        bytes32 offerId,
        PendingOffer memory pendingOffer
    ) internal {
        bytes32 current = listData.head;
        require(!pendingOffer.termAuction.auctionCompleted());

        // If the list is empty, set the new repoToken as the head
        if (current == NULL_NODE) {
            listData.head = offerId;
            listData.nodes[offerId].next = NULL_NODE;
            listData.offers[offerId] = pendingOffer;
            return;
        }

        bytes32 prev;
        while (current != NULL_NODE) {
            // If the offerId is already in the list, exit
            if (current == offerId) {
                break;
            }

            address currentAuction = address(
                listData.offers[current].termAuction
            );
            address auctionToInsert = address(pendingOffer.termAuction);

            // Insert offer before current if the auction address to insert is less than current auction address
            if (auctionToInsert < currentAuction) {
                if (prev == NULL_NODE) {
                    listData.head = offerId;
                } else {
                    listData.nodes[prev].next = offerId;
                }
                listData.nodes[offerId].next = current;
                break;
            }

            // Move to the next node
            bytes32 next = _getNext(listData, current);

            // If at the end of the list, insert repoToken after current
            if (next == NULL_NODE) {
                listData.nodes[current].next = offerId;
                listData.nodes[offerId].next = NULL_NODE;
                break;
            }

            prev = current;
            current = next;
        }
        listData.offers[offerId] = pendingOffer;
    }

    /**
     * @notice Removes completed or cancelled offers from the list data and processes the corresponding repoTokens
     * @param listData The list data
     * @param repoTokenListData The repoToken list data
     * @param discountRateAdapter The discount rate adapter
     * @param asset The address of the asset
     *
     * @dev This function iterates through the list of offers and removes those that are completed or cancelled.
     * It processes the corresponding repoTokens by validating and inserting them if necessary. This helps maintain
     * the list by clearing out inactive offers and ensuring repoTokens are correctly processed.
     */
    function removeCompleted(
        TermAuctionListData storage listData,
        RepoTokenListData storage repoTokenListData,
        ITermDiscountRateAdapter discountRateAdapter,
        address asset
    ) internal {
        // Return if the list is empty
        if (listData.head == NULL_NODE) return;

        bytes32 current = listData.head;
        bytes32 prev = current;
        while (current != NULL_NODE) {
            PendingOffer memory offer = listData.offers[current];
            bytes32 next = _getNext(listData, current);

            uint256 offerAmount = offer.offerLocker.lockedOffer(current).amount;
            bool removeNode;

            if (offer.termAuction.auctionCompleted()) {
                // If auction is completed and closed, mark for removal and prepare to insert repo token
                removeNode = true;
                // Auction still open => include offerAmount in totalValue
                // (otherwise locked purchaseToken will be missing from TV)
                // Auction completed but not closed => include offer.offerAmount in totalValue
                // because the offerLocker will have already removed the offer.
                // This applies if the repoToken hasn't been added to the repoTokenList
                // (only for new auctions, not reopenings).
                (
                    bool isValidRepoToken,
                    uint256 redemptionTimestamp
                ) = repoTokenListData.validateAndInsertRepoToken(
                        ITermRepoToken(offer.repoToken),
                        discountRateAdapter,
                        asset
                    );
                if (
                    !isValidRepoToken && block.timestamp > redemptionTimestamp
                ) {
                    ITermRepoToken repoToken = ITermRepoToken(offer.repoToken);
                    (, , address repoServicerAddr, ) = repoToken.config();
                    ITermRepoServicer repoServicer = ITermRepoServicer(
                        repoServicerAddr
                    );
                    try
                        repoServicer.redeemTermRepoTokens(
                            address(this),
                            repoToken.balanceOf(address(this))
                        )
                    {} catch {}
                }
            } else {
                if (offer.termAuction.auctionCancelledForWithdrawal()) {
                    // If auction was canceled for withdrawal, remove the node and unlock offers manually
                    bytes32[] memory offerIds = new bytes32[](1);
                    offerIds[0] = current;
                    try offer.offerLocker.unlockOffers(offerIds) {
                        // unlocking offer in this scenario withdraws offer amount
                        removeNode = true;
                    } catch {
                        removeNode = false;
                    }
                } else {
                    if (offerAmount == 0) {
                        // If offer amount is zero, it indicates the auction was canceled or deleted
                        removeNode = true;
                    }
                }
            }

            if (removeNode) {
                // Update the list to remove the current node
                delete listData.nodes[current];
                delete listData.offers[current];
                if (current == listData.head) {
                    listData.head = next;
                } else {
                    listData.nodes[prev].next = next;
                    current = prev;
                }
            }

            // Move to the next node
            prev = current;
            current = next;
        }
    }

    /**
     * @notice Calculates the total present value of all relevant offers related to a specified repoToken
     * @param listData The list data
     * @param repoTokenListData The repoToken list data
     * @param discountRateAdapter The discount rate adapter
     * @param purchaseTokenPrecision The precision of the purchase token
     * @param repoTokenToMatch The address of the repoToken to match (optional)
     * @return totalValue The total present value of the offers
     *
     * @dev This function calculates the present value of offers in the list. If `repoTokenToMatch` is provided,
     * it will filter the calculations to include only the specified repoToken. If `repoTokenToMatch` is not provided,
     * it will aggregate the present value of all repoTokens in the list. This provides flexibility for both aggregate
     * and specific token evaluations.
     */
    function getPresentValue(
        TermAuctionListData storage listData,
        RepoTokenListData storage repoTokenListData,
        ITermDiscountRateAdapter discountRateAdapter,
        uint256 purchaseTokenPrecision,
        address repoTokenToMatch
    ) internal view returns (uint256 totalValue) {
        // Return 0 if the list is empty
        if (listData.head == NULL_NODE) return 0;
        address edgeCaseAuction; // NOTE: handle edge case, assumes that pendingOffer is properly sorted by auction address

        bytes32 current = listData.head;
        while (current != NULL_NODE) {
            PendingOffer storage offer = listData.offers[current];

            // Filter by specific repo token if provided, address(0) bypasses this filter
            if (
                repoTokenToMatch != address(0) &&
                offer.repoToken != repoTokenToMatch
            ) {
                // Not a match, skip
                // Move to the next token in the list
                current = _getNext(listData, current);
                continue;
            }

            uint256 offerAmount = offer.offerLocker.lockedOffer(current).amount;

            // Handle new or unseen repo tokens
            /// @dev offer processed, but auctionClosed not yet called and auction is new so repoToken not on List and wont be picked up
            /// checking repoTokendiscountRates to make sure we are not double counting on re-openings
            if (
                offer.termAuction.auctionCompleted() &&
                repoTokenListData.discountRates[offer.repoToken] == 0
            ) {
                if (edgeCaseAuction != address(offer.termAuction)) {
                    uint256 repoTokenAmountInBaseAssetPrecision = RepoTokenUtils
                        .getNormalizedRepoTokenAmount(
                            offer.repoToken,
                            ITermRepoToken(offer.repoToken).balanceOf(
                                address(this)
                            ),
                            purchaseTokenPrecision,
                            discountRateAdapter.repoRedemptionHaircut(
                                offer.repoToken
                            )
                        );
                    totalValue += RepoTokenUtils.calculatePresentValue(
                        repoTokenAmountInBaseAssetPrecision,
                        purchaseTokenPrecision,
                        RepoTokenList.getRepoTokenMaturity(offer.repoToken),
                        discountRateAdapter.getDiscountRate(offer.repoToken)
                    );

                    // Mark the edge case auction as processed to avoid double counting
                    // since multiple offers can be tied to the same auction, we need to mark
                    // the edge case auction as processed to avoid double counting
                    edgeCaseAuction = address(offer.termAuction);
                }
            } else {
                // Add the offer amount to the total value
                totalValue += offerAmount;
            }

            // Move to the next token in the list
            current = _getNext(listData, current);
        }
    }

    /**
     * @notice Get cumulative offer data for a specified repoToken
     * @param listData The list data
     * @param repoTokenListData The repoToken list data
     * @param discountRateAdapter The discount rate adapter
     * @param repoToken The address of the repoToken (optional)
     * @param newOfferAmount The new offer amount for the specified repoToken
     * @param purchaseTokenPrecision The precision of the purchase token
     * @return cumulativeWeightedTimeToMaturity The cumulative weighted time to maturity
     * @return cumulativeOfferAmount The cumulative repoToken amount
     * @return found Whether the specified repoToken was found in the list
     *
     * @dev This function calculates cumulative data for all offers in the list. The `repoToken` and `newOfferAmount`
     * parameters are optional and provide flexibility to include the newOfferAmount for a specified repoToken in the calculation.
     * If `repoToken` is set to `address(0)` or `newOfferAmount` is `0`, the function calculates the cumulative data
     * without adjustments.
     */
    function getCumulativeOfferData(
        TermAuctionListData storage listData,
        RepoTokenListData storage repoTokenListData,
        ITermDiscountRateAdapter discountRateAdapter,
        address repoToken,
        uint256 newOfferAmount,
        uint256 purchaseTokenPrecision
    )
        internal
        view
        returns (
            uint256 cumulativeWeightedTimeToMaturity,
            uint256 cumulativeOfferAmount,
            bool found
        )
    {
        // If the list is empty, return 0s and false
        if (listData.head == NULL_NODE) return (0, 0, false);
        address edgeCaseAuction; // NOTE: handle edge case, assumes that pendingOffer is properly sorted by auction address

        bytes32 current = listData.head;
        while (current != NULL_NODE) {
            PendingOffer storage offer = listData.offers[current];

            uint256 offerAmount;
            if (offer.repoToken == repoToken) {
                offerAmount = newOfferAmount;
                found = true;
            } else {
                // Retrieve the current offer amount from the offer locker
                offerAmount = offer.offerLocker.lockedOffer(current).amount;

                // Handle new repo tokens or reopening auctions
                /// @dev offer processed, but auctionClosed not yet called and auction is new so repoToken not on List and wont be picked up
                /// checking repoTokendiscountRates to make sure we are not double counting on re-openings
                if (
                    offer.termAuction.auctionCompleted() &&
                    repoTokenListData.discountRates[offer.repoToken] == 0
                ) {
                    // use normalized repoToken amount if repoToken is not in the list
                    if (edgeCaseAuction != address(offer.termAuction)) {
                        offerAmount = RepoTokenUtils
                            .getNormalizedRepoTokenAmount(
                                offer.repoToken,
                                ITermRepoToken(offer.repoToken).balanceOf(
                                    address(this)
                                ),
                                purchaseTokenPrecision,
                                discountRateAdapter.repoRedemptionHaircut(
                                    offer.repoToken
                                )
                            );

                        // Mark the edge case auction as processed to avoid double counting
                        // since multiple offers can be tied to the same auction, we need to mark
                        // the edge case auction as processed to avoid double counting
                        edgeCaseAuction = address(offer.termAuction);
                    }
                }
            }

            if (offerAmount > 0) {
                // Calculate weighted time to maturity
                uint256 weightedTimeToMaturity = RepoTokenList
                    .getRepoTokenWeightedTimeToMaturity(
                        offer.repoToken,
                        offerAmount
                    );

                cumulativeWeightedTimeToMaturity += weightedTimeToMaturity;
                cumulativeOfferAmount += offerAmount;
            }

            // Move to the next token in the list
            current = _getNext(listData, current);
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

interface ITermAuction {
    function termAuctionOfferLocker() external view returns (address);

    function termRepoId() external view returns (bytes32);

    function auctionEndTime() external view returns (uint256);

    function auctionCompleted() external view returns (bool);

    function auctionCancelledForWithdrawal() external view returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

interface ITermAuctionOfferLocker {
    /// @dev TermAuctionOfferSubmission represents an offer submission to offeror an amount of money for a specific interest rate
    struct TermAuctionOfferSubmission {
        /// @dev For an existing offer this is the unique onchain identifier for this offer. For a new offer this is a randomized input that will be used to generate the unique onchain identifier.
        bytes32 id;
        /// @dev The address of the offeror
        address offeror;
        /// @dev Hash of the offered price as a percentage of the initial loaned amount vs amount returned at maturity. This stores 9 decimal places
        bytes32 offerPriceHash;
        /// @dev The maximum amount of purchase tokens that can be lent
        uint256 amount;
        /// @dev The address of the ERC20 purchase token
        address purchaseToken;
    }

    /// @dev TermAuctionOffer represents an offer to offeror an amount of money for a specific interest rate
    struct TermAuctionOffer {
        /// @dev Unique identifier for this bid
        bytes32 id;
        /// @dev The address of the offeror
        address offeror;
        /// @dev Hash of the offered price as a percentage of the initial loaned amount vs amount returned at maturity. This stores 9 decimal places
        bytes32 offerPriceHash;
        /// @dev Revealed offer price. This is not valid unless isRevealed is true. This stores 18 decimal places
        uint256 offerPriceRevealed;
        /// @dev The maximum amount of purchase tokens that can be lent
        uint256 amount;
        /// @dev The address of the ERC20 purchase token
        address purchaseToken;
        /// @dev Is offer price revealed
        bool isRevealed;
    }

    /// @dev TermAuctionRevealedOffer represents a revealed offer to offeror an amount of money for a specific interest rate
    struct TermAuctionRevealedOffer {
        /// @dev Unique identifier for this bid
        bytes32 id;
        /// @dev The address of the offeror
        address offeror;
        /// @dev The offered price as a percentage of the initial loaned amount vs amount returned at maturity. This stores 9 decimal places
        uint256 offerPriceRevealed;
        /// @dev The maximum amount of purchase tokens offered
        uint256 amount;
        /// @dev The address of the lent ERC20 token
        address purchaseToken;
    }

    function termRepoId() external view returns (bytes32);

    function termAuctionId() external view returns (bytes32);

    function auctionStartTime() external view returns (uint256);

    function auctionEndTime() external view returns (uint256);

    function revealTime() external view returns (uint256);

    function purchaseToken() external view returns (address);

    function termRepoServicer() external view returns (address);

    function lockedOffer(
        bytes32 id
    ) external view returns (TermAuctionOffer memory);

    /// @param offerSubmissions An array of offer submissions
    /// @return A bytes32 array of unique on chain offer ids.
    function lockOffers(
        TermAuctionOfferSubmission[] calldata offerSubmissions
    ) external returns (bytes32[] memory);

    function unlockOffers(bytes32[] calldata offerIds) external;
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

struct AuctionMetadata {
    bytes32 termAuctionId;
    uint256 auctionClearingRate;
    uint256 auctionClearingBlockTimestamp;
}

interface ITermController {
    function isTermDeployed(
        address contractAddress
    ) external view returns (bool);

    function getProtocolReserveAddress() external view returns (address);

    function getTermAuctionResults(
        bytes32 termRepoId
    )
        external
        view
        returns (AuctionMetadata[] memory auctionMetadata, uint8 numOfAuctions);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {ITermController} from "./ITermController.sol";
interface ITermDiscountRateAdapter {
    function currTermController() external view returns (ITermController);
    function repoRedemptionHaircut(address) external view returns (uint256);
    function getDiscountRate(address repoToken) external view returns (uint256);
    function getDiscountRate(
        address termController,
        address repoToken
    ) external view returns (uint256);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

interface ITermRepoCollateralManager {
    function maintenanceCollateralRatios(
        address
    ) external view returns (uint256);

    function numOfAcceptedCollateralTokens() external view returns (uint8);

    function collateralTokens(uint256 index) external view returns (address);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

interface ITermRepoServicer {
    function redeemTermRepoTokens(
        address redeemer,
        uint256 amountToRedeem
    ) external;

    function termRepoToken() external view returns (address);

    function termRepoLocker() external view returns (address);

    function purchaseToken() external view returns (address);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITermRepoToken is IERC20 {
    function redemptionValue() external view returns (uint256);

    function config()
        external
        view
        returns (
            uint256 redemptionTimestamp,
            address purchaseToken,
            address termRepoServicer,
            address termRepoCollateralManager
        );

    function termRepoId() external view returns (bytes32);
}
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.18;

interface ITermVaultEvents {
    event VaultContractPaired(address vault);

    event TermControllerUpdated(address oldController, address newController);

    event TimeToMaturityThresholdUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    );

    event RequiredReserveRatioUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    );

    event DiscountRateMarkupUpdated(uint256 oldMarkup, uint256 newMarkup);

    event MinCollateralRatioUpdated(
        address collateral,
        uint256 minCollateralRatio
    );

    event RepoTokenConcentrationLimitUpdated(
        uint256 oldLimit,
        uint256 newLimit
    );

    event DepositPaused();

    event DepositUnpaused();

    /*
    event StrategyPaused();

    event StrategyUnpaused();
    */

    event DiscountRateAdapterUpdated(
        address indexed oldAdapter,
        address indexed newAdapter
    );

    event RepoTokenBlacklistUpdated(
        address indexed repoToken,
        bool blacklisted
    );

    event NewGovernor(address newGovernor);

    function emitTermControllerUpdated(
        address oldController,
        address newController
    ) external;

    function emitTimeToMaturityThresholdUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    ) external;

    function emitRequiredReserveRatioUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    ) external;

    function emitDiscountRateMarkupUpdated(
        uint256 oldMarkup,
        uint256 newMarkup
    ) external;

    function emitMinCollateralRatioUpdated(
        address collateral,
        uint256 minCollateralRatio
    ) external;

    function emitRepoTokenConcentrationLimitUpdated(
        uint256 oldLimit,
        uint256 newLimit
    ) external;

    function emitDepositPaused() external;

    function emitDepositUnpaused() external;
    /*

    function emitStrategyPaused() external;

    function emitStrategyUnpaused() external;*/

    function emitDiscountRateAdapterUpdated(
        address oldAdapter,
        address newAdapter
    ) external;

    function emitRepoTokenBlacklistUpdated(
        address repoToken,
        bool blacklisted
    ) external;

    function emitNewGovernor(address newGovernor) external;
}